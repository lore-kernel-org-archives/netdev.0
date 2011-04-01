From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 4/9 net-next-2.6] qlcnic: Code changes to improve
 performance
Date: Thu, 31 Mar 2011 21:36:34 -0700
Message-ID: <alpine.OSX.2.00.1103312135340.47460@n5102mn2hhgf91.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1outboundpool.messaging.microsoft.com ([216.32.181.181]:6339
	"EHLO CH1EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751399Ab1DAEhh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2011 00:37:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Optimized code that resulted in achieving lower
CPU utilization on transmit path and higher throughput for small
packet sizes (64 bytes).

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |   30 +++---
 drivers/net/qlcnic/qlcnic_main.c |  210 ++++++++++++++++++--------------------
 2 files changed, 115 insertions(+), 125 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 15d950a..a5b28d1 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -434,50 +434,49 @@ struct qlcnic_adapter_stats {
  * be one Rcv Descriptor for normal packets, one for jumbo and may be others.
  */
 struct qlcnic_host_rds_ring {
-       u32 producer;
+       void __iomem *crb_rcv_producer;
+       struct rcv_desc *desc_head;
+       struct qlcnic_rx_buffer *rx_buf_arr;
        u32 num_desc;
+       u32 producer;
        u32 dma_size;
        u32 skb_size;
        u32 flags;
-       void __iomem *crb_rcv_producer;
-       struct rcv_desc *desc_head;
-       struct qlcnic_rx_buffer *rx_buf_arr;
        struct list_head free_list;
        spinlock_t lock;
        dma_addr_t phys_addr;
-};
+} ____cacheline_internodealigned_in_smp;

 struct qlcnic_host_sds_ring {
        u32 consumer;
        u32 num_desc;
        void __iomem *crb_sts_consumer;
-       void __iomem *crb_intr_mask;

        struct status_desc *desc_head;
        struct qlcnic_adapter *adapter;
        struct napi_struct napi;
        struct list_head free_list[NUM_RCV_DESC_RINGS];

+       void __iomem *crb_intr_mask;
        int irq;

        dma_addr_t phys_addr;
        char name[IFNAMSIZ+4];
-};
+} ____cacheline_internodealigned_in_smp;

 struct qlcnic_host_tx_ring {
        u32 producer;
-       __le32 *hw_consumer;
        u32 sw_consumer;
-       void __iomem *crb_cmd_producer;
        u32 num_desc;
-
-       struct netdev_queue *txq;
-
-       struct qlcnic_cmd_buffer *cmd_buf_arr;
+       void __iomem *crb_cmd_producer;
        struct cmd_desc_type0 *desc_head;
+       struct qlcnic_cmd_buffer *cmd_buf_arr;
+       __le32 *hw_consumer;
+
        dma_addr_t phys_addr;
        dma_addr_t hw_cons_phys_addr;
-};
+       struct netdev_queue *txq;
+} ____cacheline_internodealigned_in_smp;

 /*
  * Receive context. There is one such structure per instance of the
@@ -1328,8 +1327,7 @@ static const struct qlcnic_brdinfo qlcnic_boards[] = {

 static inline u32 qlcnic_tx_avail(struct qlcnic_host_tx_ring *tx_ring)
 {
-       smp_mb();
-       if (tx_ring->producer < tx_ring->sw_consumer)
+       if (likely(tx_ring->producer < tx_ring->sw_consumer))
                return tx_ring->sw_consumer - tx_ring->producer;
        else
                return tx_ring->sw_consumer + tx_ring->num_desc -
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index dde7e44..3b740f5 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1861,6 +1861,7 @@ static void qlcnic_change_filter(struct qlcnic_adapter *adapter,
        vlan_req->vlan_id = vlan_id;

        tx_ring->producer = get_next_index(producer, tx_ring->num_desc);
+       smp_mb();
 }

 #define QLCNIC_MAC_HASH(MAC)\
@@ -1921,58 +1922,122 @@ qlcnic_send_filter(struct qlcnic_adapter *adapter,
        spin_unlock(&adapter->mac_learn_lock);
 }

-static void
-qlcnic_tso_check(struct net_device *netdev,
-               struct qlcnic_host_tx_ring *tx_ring,
+static int
+qlcnic_tx_pkt(struct qlcnic_adapter *adapter,
                struct cmd_desc_type0 *first_desc,
                struct sk_buff *skb)
 {
-       u8 opcode = TX_ETHER_PKT;
-       __be16 protocol = skb->protocol;
-       u16 flags = 0;
-       int copied, offset, copy_len, hdr_len = 0, tso = 0;
+       u8 opcode = 0, hdr_len = 0;
+       u16 flags = 0, vlan_tci = 0;
+       int copied, offset, copy_len;
        struct cmd_desc_type0 *hwdesc;
        struct vlan_ethhdr *vh;
-       struct qlcnic_adapter *adapter = netdev_priv(netdev);
+       struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
+       u16 protocol = ntohs(skb->protocol);
        u32 producer = tx_ring->producer;
-       __le16 vlan_oob = first_desc->flags_opcode &
-                               cpu_to_le16(FLAGS_VLAN_OOB);
+
+       if (protocol == ETH_P_8021Q) {
+               vh = (struct vlan_ethhdr *)skb->data;
+               flags = FLAGS_VLAN_TAGGED;
+               vlan_tci = vh->h_vlan_TCI;
+       } else if (vlan_tx_tag_present(skb)) {
+               flags = FLAGS_VLAN_OOB;
+               vlan_tci = vlan_tx_tag_get(skb);
+       }
+       if (unlikely(adapter->pvid)) {
+               if (vlan_tci && !(adapter->flags & QLCNIC_TAGGING_ENABLED))
+                       return -EIO;
+               if (vlan_tci && (adapter->flags & QLCNIC_TAGGING_ENABLED))
+                       goto set_flags;
+
+               flags = FLAGS_VLAN_OOB;
+               vlan_tci = adapter->pvid;
+       }
+set_flags:
+       qlcnic_set_tx_vlan_tci(first_desc, vlan_tci);
+       qlcnic_set_tx_flags_opcode(first_desc, flags, opcode);

        if (*(skb->data) & BIT_0) {
                flags |= BIT_0;
                memcpy(&first_desc->eth_addr, skb->data, ETH_ALEN);
        }
-
-       if ((netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)) &&
+       opcode = TX_ETHER_PKT;
+       if ((adapter->netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)) &&
                        skb_shinfo(skb)->gso_size > 0) {

                hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);

                first_desc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
                first_desc->total_hdr_length = hdr_len;
-               if (vlan_oob) {
+
+               opcode = (protocol == ETH_P_IPV6) ? TX_TCP_LSO6 : TX_TCP_LSO;
+
+               /* For LSO, we need to copy the MAC/IP/TCP headers into
+               * the descriptor ring */
+               copied = 0;
+               offset = 2;
+
+               if (flags & FLAGS_VLAN_OOB) {
                        first_desc->total_hdr_length += VLAN_HLEN;
                        first_desc->tcp_hdr_offset = VLAN_HLEN;
                        first_desc->ip_hdr_offset = VLAN_HLEN;
                        /* Only in case of TSO on vlan device */
                        flags |= FLAGS_VLAN_TAGGED;
+
+                       /* Create a TSO vlan header template for firmware */
+
+                       hwdesc = &tx_ring->desc_head[producer];
+                       tx_ring->cmd_buf_arr[producer].skb = NULL;
+
+                       copy_len = min((int)sizeof(struct cmd_desc_type0) -
+                               offset, hdr_len + VLAN_HLEN);
+
+                       vh = (struct vlan_ethhdr *)((char *) hwdesc + 2);
+                       skb_copy_from_linear_data(skb, vh, 12);
+                       vh->h_vlan_proto = htons(ETH_P_8021Q);
+                       vh->h_vlan_TCI = htons(vlan_tci);
+
+                       skb_copy_from_linear_data_offset(skb, 12,
+                               (char *)vh + 16, copy_len - 16);
+
+                       copied = copy_len - VLAN_HLEN;
+                       offset = 0;
+
+                       producer = get_next_index(producer, tx_ring->num_desc);
                }

-               opcode = (protocol == cpu_to_be16(ETH_P_IPV6)) ?
-                               TX_TCP_LSO6 : TX_TCP_LSO;
-               tso = 1;
+               while (copied < hdr_len) {
+
+                       copy_len = min((int)sizeof(struct cmd_desc_type0) -
+                               offset, (hdr_len - copied));
+
+                       hwdesc = &tx_ring->desc_head[producer];
+                       tx_ring->cmd_buf_arr[producer].skb = NULL;
+
+                       skb_copy_from_linear_data_offset(skb, copied,
+                                (char *) hwdesc + offset, copy_len);
+
+                       copied += copy_len;
+                       offset = 0;
+
+                       producer = get_next_index(producer, tx_ring->num_desc);
+               }
+
+               tx_ring->producer = producer;
+               smp_mb();
+               adapter->stats.lso_frames++;

        } else if (skb->ip_summed == CHECKSUM_PARTIAL) {
                u8 l4proto;

-               if (protocol == cpu_to_be16(ETH_P_IP)) {
+               if (protocol == ETH_P_IP) {
                        l4proto = ip_hdr(skb)->protocol;

                        if (l4proto == IPPROTO_TCP)
                                opcode = TX_TCP_PKT;
                        else if (l4proto == IPPROTO_UDP)
                                opcode = TX_UDP_PKT;
-               } else if (protocol == cpu_to_be16(ETH_P_IPV6)) {
+               } else if (protocol == ETH_P_IPV6) {
                        l4proto = ipv6_hdr(skb)->nexthdr;

                        if (l4proto == IPPROTO_TCP)
@@ -1981,63 +2046,11 @@ qlcnic_tso_check(struct net_device *netdev,
                                opcode = TX_UDPV6_PKT;
                }
        }
-
        first_desc->tcp_hdr_offset += skb_transport_offset(skb);
        first_desc->ip_hdr_offset += skb_network_offset(skb);
        qlcnic_set_tx_flags_opcode(first_desc, flags, opcode);

-       if (!tso)
-               return;
-
-       /* For LSO, we need to copy the MAC/IP/TCP headers into
-        * the descriptor ring
-        */
-       copied = 0;
-       offset = 2;
-
-       if (vlan_oob) {
-               /* Create a TSO vlan header template for firmware */
-
-               hwdesc = &tx_ring->desc_head[producer];
-               tx_ring->cmd_buf_arr[producer].skb = NULL;
-
-               copy_len = min((int)sizeof(struct cmd_desc_type0) - offset,
-                               hdr_len + VLAN_HLEN);
-
-               vh = (struct vlan_ethhdr *)((char *)hwdesc + 2);
-               skb_copy_from_linear_data(skb, vh, 12);
-               vh->h_vlan_proto = htons(ETH_P_8021Q);
-               vh->h_vlan_TCI = (__be16)swab16((u16)first_desc->vlan_TCI);
-
-               skb_copy_from_linear_data_offset(skb, 12,
-                               (char *)vh + 16, copy_len - 16);
-
-               copied = copy_len - VLAN_HLEN;
-               offset = 0;
-
-               producer = get_next_index(producer, tx_ring->num_desc);
-       }
-
-       while (copied < hdr_len) {
-
-               copy_len = min((int)sizeof(struct cmd_desc_type0) - offset,
-                               (hdr_len - copied));
-
-               hwdesc = &tx_ring->desc_head[producer];
-               tx_ring->cmd_buf_arr[producer].skb = NULL;
-
-               skb_copy_from_linear_data_offset(skb, copied,
-                                (char *)hwdesc + offset, copy_len);
-
-               copied += copy_len;
-               offset = 0;
-
-               producer = get_next_index(producer, tx_ring->num_desc);
-       }
-
-       tx_ring->producer = producer;
-       barrier();
-       adapter->stats.lso_frames++;
+       return 0;
 }

 static int
@@ -2088,39 +2101,21 @@ out_err:
        return -ENOMEM;
 }

-static int
-qlcnic_check_tx_tagging(struct qlcnic_adapter *adapter,
-                       struct sk_buff *skb,
-                       struct cmd_desc_type0 *first_desc)
+static void
+qlcnic_unmap_buffers(struct pci_dev *pdev, struct sk_buff *skb,
+                       struct qlcnic_cmd_buffer *pbuf)
 {
-       u8 opcode = 0;
-       u16 flags = 0;
-       __be16 protocol = skb->protocol;
-       struct vlan_ethhdr *vh;
+       struct qlcnic_skb_frag *nf = &pbuf->frag_array[0];
+       int nr_frags = skb_shinfo(skb)->nr_frags;
+       int i;

-       if (protocol == cpu_to_be16(ETH_P_8021Q)) {
-               vh = (struct vlan_ethhdr *)skb->data;
-               protocol = vh->h_vlan_encapsulated_proto;
-               flags = FLAGS_VLAN_TAGGED;
-               qlcnic_set_tx_vlan_tci(first_desc, ntohs(vh->h_vlan_TCI));
-       } else if (vlan_tx_tag_present(skb)) {
-               flags = FLAGS_VLAN_OOB;
-               qlcnic_set_tx_vlan_tci(first_desc, vlan_tx_tag_get(skb));
+       for (i = 0; i < nr_frags; i++) {
+               nf = &pbuf->frag_array[i+1];
+               pci_unmap_page(pdev, nf->dma, nf->length, PCI_DMA_TODEVICE);
        }
-       if (unlikely(adapter->pvid)) {
-               if (first_desc->vlan_TCI &&
-                               !(adapter->flags & QLCNIC_TAGGING_ENABLED))
-                       return -EIO;
-               if (first_desc->vlan_TCI &&
-                               (adapter->flags & QLCNIC_TAGGING_ENABLED))
-                       goto set_flags;

-               flags = FLAGS_VLAN_OOB;
-               qlcnic_set_tx_vlan_tci(first_desc, adapter->pvid);
-       }
-set_flags:
-       qlcnic_set_tx_flags_opcode(first_desc, flags, opcode);
-       return 0;
+       nf = &pbuf->frag_array[0];
+       pci_unmap_single(pdev, nf->dma, skb_headlen(skb), PCI_DMA_TODEVICE);
 }

 static inline void
@@ -2144,7 +2139,7 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
        int i, k;

        u32 producer;
-       int frag_count, no_of_desc;
+       int frag_count;
        u32 num_txd = tx_ring->num_desc;

        if (!test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
@@ -2161,12 +2156,8 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)

        frag_count = skb_shinfo(skb)->nr_frags + 1;

-       /* 4 fragments per cmd des */
-       no_of_desc = (frag_count + 3) >> 2;
-
        if (unlikely(qlcnic_tx_avail(tx_ring) <= TX_STOP_THRESH)) {
                netif_stop_queue(netdev);
-               smp_mb();
                if (qlcnic_tx_avail(tx_ring) > TX_STOP_THRESH)
                        netif_start_queue(netdev);
                else {
@@ -2183,9 +2174,6 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
        first_desc = hwdesc = &tx_ring->desc_head[producer];
        qlcnic_clear_cmddesc((u64 *)hwdesc);

-       if (qlcnic_check_tx_tagging(adapter, skb, first_desc))
-               goto drop_packet;
-
        if (qlcnic_map_tx_skb(pdev, skb, pbuf)) {
                adapter->stats.tx_dma_map_error++;
                goto drop_packet;
@@ -2229,8 +2217,10 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
        }

        tx_ring->producer = get_next_index(producer, num_txd);
+       smp_mb();

-       qlcnic_tso_check(netdev, tx_ring, first_desc, skb);
+       if (unlikely(qlcnic_tx_pkt(adapter, first_desc, skb)))
+               goto unwind_buff;

        if (qlcnic_mac_learn)
                qlcnic_send_filter(adapter, tx_ring, first_desc, skb);
@@ -2242,6 +2232,8 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)

        return NETDEV_TX_OK;

+unwind_buff:
+       qlcnic_unmap_buffers(pdev, skb, pbuf);
 drop_packet:
        adapter->stats.txdropped++;
        dev_kfree_skb_any(skb);
--
1.7.4.1


This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

