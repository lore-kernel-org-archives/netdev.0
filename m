From: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC v4 1/2] iwlwifi: pcie: allow to build an A-MSDU using TSO core
Date: Thu, 22 Oct 2015 16:07:11 +0300
Message-ID: <1445519232-11111-1-git-send-email-emmanuel.grumbach@intel.com>
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When the op_mode sends an skb whose payload is bigger than
MSS, PCIe will create an A-MSDU out of it. PCIe assumes
that the skb that is coming from the op_mode can fit in one
A-MSDU. It is the op_mode's responsibility to make sure
that this guarantee holds.

Additional headers need to be built for the subframes.
The TSO core code takes care of the IP / TCP headers and
the driver takes care of the 802.11 subframe headers.

These headers are stored on a per-cpu page that is re-used
for all the packets handled on that same CPU. Each skb
holds a reference to that page and releases the page when
it is reclaimed. When the page gets full, it is released
and a new one is allocated.

Since any SKB that doesn't go through the fast-xmit path
of mac80211 will be segmented, we can assume here that the
packet is not WEP / TKIP and has a proper SNAP header.

Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
v4: * Create a helper to free the skb's ref to the hdr page
    * add comment on that clarifies that the headers fit in a page
    * return -ENOMEM if the per_cpu variable allocation failed
    * don't zero the per_cpu struct after allocation
---
 drivers/net/wireless/iwlwifi/iwl-devtrace-data.h |  16 ++
 drivers/net/wireless/iwlwifi/iwl-trans.h         |   6 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h     |   7 +
 drivers/net/wireless/iwlwifi/pcie/trans.c        |  15 ++
 drivers/net/wireless/iwlwifi/pcie/tx.c           | 287 ++++++++++++++++++++++-
 5 files changed, 326 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace-data.h b/drivers/net/wireless/iwlwifi/iwl-devtrace-data.h
index 71a78ce..59d9edf 100644
--- a/drivers/net/wireless/iwlwifi/iwl-devtrace-data.h
+++ b/drivers/net/wireless/iwlwifi/iwl-devtrace-data.h
@@ -51,6 +51,22 @@ TRACE_EVENT(iwlwifi_dev_tx_data,
 	TP_printk("[%s] TX frame data", __get_str(dev))
 );
 
+TRACE_EVENT(iwlwifi_dev_tx_tso_chunk,
+	TP_PROTO(const struct device *dev,
+		 u8 *data_src, size_t data_len),
+	TP_ARGS(dev, data_src, data_len),
+	TP_STRUCT__entry(
+		DEV_ENTRY
+
+		__dynamic_array(u8, data, data_len)
+	),
+	TP_fast_assign(
+		DEV_ASSIGN;
+		memcpy(__get_dynamic_array(data), data_src, data_len);
+	),
+	TP_printk("[%s] TX frame data", __get_str(dev))
+);
+
 TRACE_EVENT(iwlwifi_dev_rx_data,
 	TP_PROTO(const struct device *dev,
 		 const struct iwl_trans *trans,
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans.h b/drivers/net/wireless/iwlwifi/iwl-trans.h
index 0ceff69..6919243 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans.h
+++ b/drivers/net/wireless/iwlwifi/iwl-trans.h
@@ -379,7 +379,11 @@ static inline void iwl_free_rxb(struct iwl_rx_cmd_buffer *r)
 }
 
 #define MAX_NO_RECLAIM_CMDS	6
-
+/*
+ * The first entry in driver_data array in ieee80211_tx_info
+ * that can be used by the transport.
+ */
+#define IWL_FIRST_DRIVER_DATA 2
 #define IWL_MASK(lo, hi) ((1 << (hi)) | ((1 << (hi)) - (1 << (lo))))
 
 /*
diff --git a/drivers/net/wireless/iwlwifi/pcie/internal.h b/drivers/net/wireless/iwlwifi/pcie/internal.h
index be168d1..7da5643 100644
--- a/drivers/net/wireless/iwlwifi/pcie/internal.h
+++ b/drivers/net/wireless/iwlwifi/pcie/internal.h
@@ -295,6 +295,11 @@ iwl_pcie_get_scratchbuf_dma(struct iwl_txq *txq, int idx)
 	       sizeof(struct iwl_pcie_txq_scratch_buf) * idx;
 }
 
+struct iwl_tso_hdr_page {
+	struct page *page;
+	u8 *pos;
+};
+
 /**
  * struct iwl_trans_pcie - PCIe transport specific data
  * @rxq: all the RX queue data
@@ -332,6 +337,8 @@ struct iwl_trans_pcie {
 	struct net_device napi_dev;
 	struct napi_struct napi;
 
+	struct __percpu iwl_tso_hdr_page *tso_hdr_page;
+
 	/* INT ICT Table */
 	__le32 *ict_tbl;
 	dma_addr_t ict_tbl_dma;
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wireless/iwlwifi/pcie/trans.c
index a275318..f03c3e1 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -1601,6 +1601,7 @@ static void iwl_trans_pcie_configure(struct iwl_trans *trans,
 void iwl_trans_pcie_free(struct iwl_trans *trans)
 {
 	struct iwl_trans_pcie *trans_pcie = IWL_TRANS_GET_PCIE_TRANS(trans);
+	int i;
 
 #ifdef CPTCFG_IWLWIFI_PLATFORM_DATA
 	/* Make sure the device is on before calling pci functions again.
@@ -1631,6 +1632,15 @@ void iwl_trans_pcie_free(struct iwl_trans *trans)
 
 	iwl_pcie_free_fw_monitor(trans);
 
+	for_each_possible_cpu(i) {
+		struct iwl_tso_hdr_page *p =
+			per_cpu_ptr(trans_pcie->tso_hdr_page, i);
+
+		if (p->page)
+			__free_pages(p->page, 0);
+	}
+
+	free_percpu(trans_pcie->tso_hdr_page);
 	iwl_trans_free(trans);
 }
 
@@ -2839,6 +2849,11 @@ struct iwl_trans *iwl_trans_pcie_alloc(struct pci_dev *pdev,
 	spin_lock_init(&trans_pcie->ref_lock);
 	mutex_init(&trans_pcie->mutex);
 	init_waitqueue_head(&trans_pcie->ucode_write_waitq);
+	trans_pcie->tso_hdr_page = alloc_percpu(struct iwl_tso_hdr_page);
+	if (!trans_pcie->tso_hdr_page) {
+		ret = -ENOMEM;
+		goto out_no_pci;
+	}
 
 	ret = pci_enable_device(pdev);
 	if (ret)
diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/iwlwifi/pcie/tx.c
index c8f3967..3c699b8 100644
--- a/drivers/net/wireless/iwlwifi/pcie/tx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
@@ -30,6 +30,7 @@
 #include <linux/etherdevice.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <net/tso.h>
 
 #include "iwl-debug.h"
 #include "iwl-csr.h"
@@ -581,6 +582,18 @@ static int iwl_pcie_txq_init(struct iwl_trans *trans, struct iwl_txq *txq,
 	return 0;
 }
 
+static void iwl_pcie_free_tso_page(struct sk_buff *skb)
+{
+	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
+
+	if (info->driver_data[IWL_FIRST_DRIVER_DATA]) {
+		struct page *page =
+			info->driver_data[IWL_FIRST_DRIVER_DATA];
+		__free_pages(page, 0);
+		info->driver_data[IWL_FIRST_DRIVER_DATA] = NULL;
+	}
+}
+
 /*
  * iwl_pcie_txq_unmap -  Unmap any remaining DMA mappings and free skb's
  */
@@ -592,8 +605,12 @@ static void iwl_pcie_txq_unmap(struct iwl_trans *trans, int txq_id)
 
 	spin_lock_bh(&txq->lock);
 	while (q->write_ptr != q->read_ptr) {
+		struct sk_buff *skb = txq->entries[q->read_ptr].skb;
+
 		IWL_DEBUG_TX_REPLY(trans, "Q %d Free %d\n",
 				   txq_id, q->read_ptr);
+
+		iwl_pcie_free_tso_page(skb);
 		iwl_pcie_txq_free_tfd(trans, txq);
 		q->read_ptr = iwl_queue_inc_wrap(q->read_ptr);
 	}
@@ -1011,11 +1028,14 @@ void iwl_trans_pcie_reclaim(struct iwl_trans *trans, int txq_id, int ssn,
 	for (;
 	     q->read_ptr != tfd_num;
 	     q->read_ptr = iwl_queue_inc_wrap(q->read_ptr)) {
+		struct sk_buff *skb = txq->entries[txq->q.read_ptr].skb;
 
-		if (WARN_ON_ONCE(txq->entries[txq->q.read_ptr].skb == NULL))
+		if (WARN_ON_ONCE(skb == NULL))
 			continue;
 
-		__skb_queue_tail(skbs, txq->entries[txq->q.read_ptr].skb);
+		iwl_pcie_free_tso_page(skb);
+
+		__skb_queue_tail(skbs, skb);
 
 		txq->entries[txq->q.read_ptr].skb = NULL;
 
@@ -1881,6 +1901,258 @@ static int iwl_fill_data_tbs(struct iwl_trans *trans, struct sk_buff *skb,
 	return 0;
 }
 
+static struct iwl_tso_hdr_page *
+get_page_hdr(struct iwl_trans *trans, size_t len)
+{
+	struct iwl_trans_pcie *trans_pcie = IWL_TRANS_GET_PCIE_TRANS(trans);
+	struct iwl_tso_hdr_page *p = this_cpu_ptr(trans_pcie->tso_hdr_page);
+
+	if (!p->page)
+		goto alloc;
+
+	/* enough room on this page */
+	if (p->pos + len < (u8 *)page_address(p->page) + PAGE_SIZE)
+		return p;
+
+	/* We don't have enough room on this page, get a new one. */
+	__free_pages(p->page, 0);
+
+alloc:
+	p->page = alloc_pages(GFP_ATOMIC, 0);
+	p->pos = page_address(p->page);
+	return p;
+}
+
+static void iwl_fill_amsdu_hdr_addr(const struct ieee80211_hdr *hdr,
+				    u8 **hdr_page_pos)
+{
+	switch (hdr->frame_control &
+		cpu_to_le16(IEEE80211_FCTL_TODS |
+			    IEEE80211_FCTL_FROMDS)) {
+	/* STA */
+	case cpu_to_le16(IEEE80211_FCTL_TODS):
+		ether_addr_copy(*hdr_page_pos, hdr->addr3);
+		*hdr_page_pos += ETH_ALEN;
+
+		ether_addr_copy(*hdr_page_pos, hdr->addr2);
+		*hdr_page_pos += ETH_ALEN;
+		break;
+	/* AP */
+	case cpu_to_le16(IEEE80211_FCTL_FROMDS):
+		ether_addr_copy(*hdr_page_pos, hdr->addr1);
+		*hdr_page_pos += ETH_ALEN;
+
+		ether_addr_copy(*hdr_page_pos, hdr->addr3);
+		*hdr_page_pos += ETH_ALEN;
+		break;
+	/* TDLS or IBSS */
+	case cpu_to_le16(0):
+		ether_addr_copy(*hdr_page_pos, hdr->addr1);
+		*hdr_page_pos += ETH_ALEN;
+
+		ether_addr_copy(*hdr_page_pos, hdr->addr2);
+		*hdr_page_pos += ETH_ALEN;
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		break;
+	}
+}
+
+static void iwl_compute_pseudo_hdr_csum(void *iph, struct tcphdr *tcph,
+					bool ipv6, unsigned int len)
+{
+	if (ipv6) {
+		struct ipv6hdr *iphv6 = iph;
+
+		tcph->check = ~csum_ipv6_magic(&iphv6->saddr, &iphv6->daddr,
+					       len + tcph->doff * 4,
+					       IPPROTO_TCP, 0);
+	} else {
+		struct iphdr *iphv4 = iph;
+
+		ip_send_check(iphv4);
+		tcph->check = ~csum_tcpudp_magic(iphv4->saddr, iphv4->daddr,
+						 len + tcph->doff * 4,
+						 IPPROTO_TCP, 0);
+	}
+}
+
+static int iwl_fill_data_tbs_amsdu(struct iwl_trans *trans, struct sk_buff *skb,
+				   struct iwl_txq *txq, u8 hdr_len,
+				   struct iwl_cmd_meta *out_meta,
+				   struct iwl_device_cmd *dev_cmd, u16 tb1_len)
+{
+	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
+	struct iwl_trans_pcie *trans_pcie = txq->trans_pcie;
+	const struct ieee80211_hdr *hdr = (void *)skb->data;
+	unsigned int snap_ip_tcp_hdrlen, ip_hdrlen, total_len, hdr_room;
+	unsigned int mss = skb_shinfo(skb)->gso_size;
+	struct iwl_queue *q = &txq->q;
+	u16 length, iv_len, amsdu_pad;
+	u8 *start_hdr;
+	struct iwl_tso_hdr_page *hdr_page;
+	int ret;
+	struct tso_t tso;
+
+	/* if the packet is protected, then it must be CCMP or GCMP */
+	BUILD_BUG_ON(IEEE80211_CCMP_HDR_LEN != IEEE80211_GCMP_HDR_LEN);
+	iv_len = ieee80211_has_protected(hdr->frame_control) ?
+		IEEE80211_CCMP_HDR_LEN : 0;
+
+	trace_iwlwifi_dev_tx(trans->dev, skb,
+			     &txq->tfds[txq->q.write_ptr],
+			     sizeof(struct iwl_tfd),
+			     &dev_cmd->hdr, IWL_HCMD_SCRATCHBUF_SIZE + tb1_len,
+			     NULL, 0);
+
+	/*
+	 * Pull the ieee80211 header + IV to be able to use TSO core,
+	 * we will restore it for the tx_status flow.
+	 */
+	skb_pull(skb, hdr_len + iv_len);
+	ip_hdrlen = skb_transport_header(skb) - skb_network_header(skb);
+	snap_ip_tcp_hdrlen =
+		IEEE80211_CCMP_HDR_LEN + ip_hdrlen + tcp_hdrlen(skb);
+	total_len = skb->len - snap_ip_tcp_hdrlen;
+	amsdu_pad = 0;
+
+	/* total amount of header we may need for this A-MSDU */
+	hdr_room = DIV_ROUND_UP(total_len, mss) *
+		(3 + snap_ip_tcp_hdrlen + sizeof(struct ethhdr)) + iv_len;
+
+	/* Our device supports 9 segments at most, it will fit in 1 page */
+	hdr_page = get_page_hdr(trans, hdr_room);
+	if (!hdr_page)
+		return -ENOMEM;
+
+	get_page(hdr_page->page);
+	start_hdr = hdr_page->pos;
+	info->driver_data[IWL_FIRST_DRIVER_DATA] = hdr_page->page;
+	memcpy(hdr_page->pos, skb->data, iv_len);
+	hdr_page->pos += iv_len;
+
+	tso_start(skb, &tso);
+
+	while (total_len) {
+		/* this is the data left for this subframe */
+		unsigned int data_left =
+			min_t(unsigned int, mss, total_len);
+		struct sk_buff *csum_skb = NULL;
+		unsigned int hdr_tb_len;
+		dma_addr_t hdr_tb_phys;
+		struct tcphdr *tcph;
+		u8 *iph;
+
+		total_len -= data_left;
+
+		memset(hdr_page->pos, 0, amsdu_pad);
+		hdr_page->pos += amsdu_pad;
+		amsdu_pad = (4 - (sizeof(struct ethhdr) + snap_ip_tcp_hdrlen +
+				  data_left)) & 0x3;
+		iwl_fill_amsdu_hdr_addr(hdr, &hdr_page->pos);
+		length = snap_ip_tcp_hdrlen + mss;
+		*((__le16 *)hdr_page->pos) = cpu_to_be16(length);
+		hdr_page->pos += sizeof(length);
+
+		/*
+		 * This will copy the SNAP as well which will be considered
+		 * as MAC header.
+		 */
+		tso_build_hdr(skb, hdr_page->pos, &tso, data_left, total_len);
+		iph = hdr_page->pos + 8;
+		tcph = (void *)(iph + ip_hdrlen);
+
+		if (trans_pcie->sw_csum_tx) {
+			csum_skb = alloc_skb(data_left + tcp_hdrlen(skb),
+					     GFP_ATOMIC);
+			if (!csum_skb) {
+				ret = -ENOMEM;
+				goto out_unmap;
+			}
+
+			iwl_compute_pseudo_hdr_csum(iph, tcph,
+						    skb->protocol ==
+							htons(ETH_P_IPV6),
+						    data_left);
+
+			memcpy(skb_put(csum_skb, tcp_hdrlen(skb)),
+			       tcph, tcp_hdrlen(skb));
+			skb_set_transport_header(csum_skb, 0);
+			csum_skb->csum_start =
+				(unsigned char *)tcp_hdr(csum_skb) -
+						 csum_skb->head;
+		}
+
+		hdr_page->pos += snap_ip_tcp_hdrlen;
+
+		hdr_tb_len = hdr_page->pos - start_hdr;
+		hdr_tb_phys = dma_map_single(trans->dev, start_hdr,
+					     hdr_tb_len, DMA_TO_DEVICE);
+		if (unlikely(dma_mapping_error(trans->dev, hdr_tb_phys))) {
+			ret = -EINVAL;
+			goto out_unmap;
+		}
+		iwl_pcie_txq_build_tfd(trans, txq, hdr_tb_phys,
+				       hdr_tb_len, false);
+		trace_iwlwifi_dev_tx_tso_chunk(trans->dev, start_hdr,
+					       hdr_tb_len);
+
+		/* prepare the start_hdr for the next subframe */
+		start_hdr = hdr_page->pos;
+
+		/* put the payload */
+		while (data_left) {
+			unsigned int size = min_t(unsigned int, tso.size,
+						  data_left);
+			dma_addr_t tb_phys;
+
+			if (trans_pcie->sw_csum_tx)
+				memcpy(skb_put(csum_skb, size), tso.data, size);
+
+			tb_phys = dma_map_single(trans->dev, tso.data,
+						 size, DMA_TO_DEVICE);
+			if (unlikely(dma_mapping_error(trans->dev, tb_phys))) {
+				ret = -EINVAL;
+				goto out_unmap;
+			}
+
+			iwl_pcie_txq_build_tfd(trans, txq, tb_phys,
+					       size, false);
+			trace_iwlwifi_dev_tx_tso_chunk(trans->dev, tso.data,
+						       size);
+
+			data_left -= size;
+			tso_build_data(skb, &tso, size);
+		}
+
+		if (trans_pcie->sw_csum_tx) {
+			__wsum csum;
+
+			csum = skb_checksum(csum_skb,
+					    skb_checksum_start_offset(csum_skb),
+					    csum_skb->len -
+					    skb_checksum_start_offset(csum_skb),
+					    0);
+			dev_kfree_skb(csum_skb);
+			dma_sync_single_for_cpu(trans->dev, hdr_tb_phys,
+						hdr_tb_len, DMA_TO_DEVICE);
+			tcph->check = csum_fold(csum);
+			dma_sync_single_for_device(trans->dev, hdr_tb_phys,
+						   hdr_tb_len, DMA_TO_DEVICE);
+		}
+	}
+
+	/* re -add the WiFi header and IV */
+	skb_push(skb, hdr_len + iv_len);
+
+	return 0;
+
+out_unmap:
+	iwl_pcie_tfd_unmap(trans, out_meta, &txq->tfds[q->write_ptr]);
+	return ret;
+}
+
 int iwl_trans_pcie_tx(struct iwl_trans *trans, struct sk_buff *skb,
 		      struct iwl_device_cmd *dev_cmd, int txq_id)
 {
@@ -1993,9 +2265,16 @@ int iwl_trans_pcie_tx(struct iwl_trans *trans, struct sk_buff *skb,
 		goto out_err;
 	iwl_pcie_txq_build_tfd(trans, txq, tb1_phys, tb1_len, false);
 
-	if (unlikely(iwl_fill_data_tbs(trans, skb, txq, hdr_len,
-				       out_meta, dev_cmd, tb1_len)))
+	if (ieee80211_is_data_qos(fc) &&
+	    (*ieee80211_get_qos_ctl(hdr) & IEEE80211_QOS_CTL_A_MSDU_PRESENT)) {
+		if (unlikely(iwl_fill_data_tbs_amsdu(trans, skb, txq, hdr_len,
+						     out_meta, dev_cmd,
+						     tb1_len)))
 		goto out_err;
+	} else if (unlikely(iwl_fill_data_tbs(trans, skb, txq, hdr_len,
+				       out_meta, dev_cmd, tb1_len))) {
+		goto out_err;
+	}
 
 	/* Set up entry for this TFD in Tx byte-count array */
 	iwl_pcie_txq_update_byte_cnt_tbl(trans, txq, le16_to_cpu(tx_cmd->len));
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
