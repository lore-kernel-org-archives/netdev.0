From: Kenneth Lee <liguozhu@hisilicon.com>
Subject: [PATCH 5/5] net: add Hisilicon Network Subsystem basic ethernet support
Date: Fri, 14 Aug 2015 18:30:22 +0800
Message-ID: <1439548222-231611-6-git-send-email-liguozhu@hisilicon.com>
References: <1439548222-231611-1-git-send-email-liguozhu@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kenneth Lee <liguozhu@huawei.com>
To: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<davem@davemloft.net>, <paul.gortmaker@windriver.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<huangdaode@hisilicon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:44671 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180AbbHNKhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 06:37:14 -0400
In-Reply-To: <1439548222-231611-1-git-send-email-liguozhu@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to add basic ethernet support for HNS. It is one of the way to use
the HNS acceleration engine. But most of the decoding/encoding capability
of the AE cannot be used in this way.

This submit contains the basic feature as a ethernet driver. More will be
added later.

Signed-off-by: Kenneth Lee <liguozhu@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c    | 1552 ++++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_enet.h    |   81 ++
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 1174 ++++++++++++++++
 3 files changed, 2807 insertions(+)
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_enet.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_enet.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
new file mode 100644
index 0000000..b58d5ab
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -0,0 +1,1552 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include <linux/clk.h>
+#include <linux/skbuff.h>
+#include <linux/phy.h>
+#include <linux/io.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/if_vlan.h>
+#include "hnae.h"
+#include "hns_enet.h"
+
+#define NIC_MAX_Q_PER_VF 16
+#define HNS_NIC_TX_TIMEOUT (5 * HZ)
+
+#define SERVICE_TIMER_HZ (1 * HZ)
+
+#define NIC_TX_CLEAN_MAX_NUM 256
+#define NIC_RX_CLEAN_MAX_NUM 64
+
+#define RCB_ERR_PRINT_CYCLE 1000
+
+static inline void fill_desc(struct hnae_ring *ring, void *priv,
+			     int size, dma_addr_t dma, int frag_end,
+			     int buf_num, enum hns_desc_type type)
+{
+	struct hnae_desc *desc = &ring->desc[ring->next_to_use];
+	struct hnae_desc_cb *desc_cb = &ring->desc_cb[ring->next_to_use];
+	struct sk_buff *skb;
+	__be16 protocol;
+	u32 ip_offset;
+	u32 asid_bufnum_pid = 0;
+	u32 flag_ipoffset = 0;
+
+	desc_cb->priv = priv;
+	desc_cb->length = size;
+	desc_cb->dma = dma;
+	desc_cb->type = type;
+
+	desc->addr = cpu_to_le64(dma);
+	desc->tx.send_size = cpu_to_le16((u16)size);
+
+	/*config bd buffer end */
+	flag_ipoffset |= 1 << HNS_TXD_VLD_B;
+
+	asid_bufnum_pid |= buf_num << HNS_TXD_BUFNUM_S;
+
+	if (type == DESC_TYPE_SKB) {
+		skb = (struct sk_buff *)priv;
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			protocol = skb->protocol;
+			ip_offset = ETH_HLEN;
+
+			/*if it is a SW VLAN check the next protocol*/
+			if (protocol == htons(ETH_P_8021Q)) {
+				ip_offset += VLAN_HLEN;
+				protocol = vlan_get_protocol(skb);
+				skb->protocol = protocol;
+			}
+
+			if (skb->protocol == ntohs(ETH_P_IP)) {
+				flag_ipoffset |= 1 << HNS_TXD_L3CS_B;
+				/* check for tcp/udp header */
+				flag_ipoffset |= 1 << HNS_TXD_L4CS_B;
+
+			} else if (skb->protocol == ntohs(ETH_P_IPV6)) {
+				/* ipv6 has not l3 cs, check for L4 header */
+				flag_ipoffset |= 1 << HNS_TXD_L4CS_B;
+			}
+
+			flag_ipoffset |= ip_offset << HNS_TXD_IPOFFSET_S;
+		}
+	}
+
+	flag_ipoffset |= frag_end << HNS_TXD_FE_B;
+
+	desc->tx.asid_bufnum_pid = cpu_to_le16(asid_bufnum_pid);
+	desc->tx.flag_ipoffset = cpu_to_le32(flag_ipoffset);
+
+	ring_ptr_move_fw(ring, next_to_use);
+}
+
+static inline void unfill_desc(struct hnae_ring *ring)
+{
+	ring_ptr_move_bw(ring, next_to_use);
+}
+
+int hns_nic_net_xmit_hw(struct net_device *ndev,
+			struct sk_buff *skb,
+			struct hns_nic_ring_data *ring_data)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct device *dev = priv->dev;
+	struct hnae_ring *ring = ring_data->ring;
+	struct netdev_queue *dev_queue;
+	struct skb_frag_struct *frag;
+	int buf_num;
+	dma_addr_t dma;
+	int size, next_to_use;
+	int i, j;
+	struct sk_buff *new_skb;
+
+	assert(ring->max_desc_num_per_pkt <= ring->desc_num);
+
+	/* no. of segments (plus a header) */
+	buf_num = skb_shinfo(skb)->nr_frags + 1;
+
+	if (unlikely(buf_num > ring->max_desc_num_per_pkt)) {
+		if (ring_space(ring) < 1)
+			return NETDEV_TX_BUSY;
+
+		new_skb = skb_copy(skb, GFP_ATOMIC);
+		if (!new_skb) {
+			ring->stats.sw_err_cnt++;
+			netdev_err(ndev, "no memory to xmit!\n");
+			dev_kfree_skb_any(skb);
+			return NETDEV_TX_OK;
+		}
+
+		dev_kfree_skb_any(skb);
+		skb = new_skb;
+		buf_num = 1;
+		assert(skb_shinfo(skb)->nr_frags == 1);
+	}
+
+	if (buf_num > ring_space(ring))
+		return NETDEV_TX_BUSY;
+
+	next_to_use = ring->next_to_use;
+
+	/* fill the first part */
+	size = skb_headlen(skb);
+	dma = dma_map_single(dev, skb->data, size, DMA_TO_DEVICE);
+	if (dma_mapping_error(dev, dma)) {
+		netdev_err(ndev, "TX head DMA map failed\n");
+		ring->stats.sw_err_cnt++;
+		goto out_map_head_fail;
+	}
+	fill_desc(ring, skb, size, dma, buf_num == 1 ? 1 : 0, buf_num,
+		  DESC_TYPE_SKB);
+
+	/* fill the fragments */
+	for (i = 1; i < buf_num; i++) {
+		frag = &skb_shinfo(skb)->frags[i - 1];
+		size = skb_frag_size(frag);
+		dma = skb_frag_dma_map(dev, frag, 0, size, DMA_TO_DEVICE);
+		if (dma_mapping_error(dev, dma)) {
+			netdev_err(ndev, "TX frag(%d) DMA map failed\n", i);
+			ring->stats.sw_err_cnt++;
+			goto out_map_frag_fail;
+		}
+		fill_desc(ring, skb_frag_page(frag), size, dma,
+			  buf_num - 1 == i ? 1 : 0, buf_num, DESC_TYPE_PAGE);
+	}
+
+	/*complete translate all packets*/
+	dev_queue = netdev_get_tx_queue(ndev, skb->queue_mapping);
+	netdev_tx_sent_queue(dev_queue, skb->len);
+
+	wmb(); /* commit all data before submit */
+	assert(skb->queue_mapping < priv->ae_handle->q_num);
+	hnae_queue_xmit(priv->ae_handle->qs[skb->queue_mapping], buf_num);
+	ring->stats.pkts.tx_pkts++;
+	ring->stats.bytes.tx_bytes += skb->len;
+
+	return NETDEV_TX_OK;
+
+out_map_frag_fail:
+
+	for (j = i - 1; j > 0; j--) {
+		unfill_desc(ring);
+		next_to_use = ring->next_to_use;
+		dma_unmap_page(dev, ring->desc_cb[next_to_use].dma,
+			       ring->desc_cb[next_to_use].length,
+			       DMA_TO_DEVICE);
+	}
+
+	unfill_desc(ring);
+	next_to_use = ring->next_to_use;
+	dma_unmap_single(dev, ring->desc_cb[next_to_use].dma,
+			 ring->desc_cb[next_to_use].length, DMA_TO_DEVICE);
+
+out_map_head_fail:
+	return NETDEV_TX_BUSY;
+}
+
+/**
+ * hns_nic_get_headlen - determine size of header for RSC/LRO/GRO/FCOE
+ * @data: pointer to the start of the headers
+ * @max: total length of section to find headers in
+ *
+ * This function is meant to determine the length of headers that will
+ * be recognized by hardware for LRO, GRO, and RSC offloads.  The main
+ * motivation of doing this is to only perform one pull for IPv4 TCP
+ * packets so that we can do basic things like calculating the gso_size
+ * based on the average data per packet.
+ **/
+static unsigned int hns_nic_get_headlen(unsigned char *data, u32 flag,
+					unsigned int max)
+{
+	unsigned char *network;
+	u8 hlen;
+
+	/* this should never happen, but better safe than sorry */
+	if (max < ETH_HLEN)
+		return max;
+
+	/* initialize network frame pointer */
+	network = data;
+
+	/* set first protocol and move network header forward */
+	network += ETH_HLEN;
+
+	/* handle any vlan tag if present */
+	if (hnae_get_field(flag, HNS_RXD_VLAN_M, HNS_RXD_VLAN_S)
+		== HNS_RX_FLAG_VLAN_PRESENT) {
+		if ((typeof(max))(network - data) > (max - VLAN_HLEN))
+			return max;
+
+		network += VLAN_HLEN;
+	}
+
+	/* handle L3 protocols */
+	if (hnae_get_field(flag, HNS_RXD_L3ID_M, HNS_RXD_L3ID_S)
+		== HNS_RX_FLAG_L3ID_IPV4) {
+		if ((typeof(max))(network - data) >
+					(max - sizeof(struct iphdr)))
+			return max;
+
+		/* access ihl as a u8 to avoid unaligned access on ia64 */
+		hlen = (network[0] & 0x0F) << 2;
+
+		/* verify hlen meets minimum size requirements */
+		if (hlen < sizeof(struct iphdr))
+			return network - data;
+
+		/* record next protocol if header is present */
+	} else if (hnae_get_field(flag, HNS_RXD_L3ID_M, HNS_RXD_L3ID_S)
+		== HNS_RX_FLAG_L3ID_IPV6) {
+		if ((typeof(max))(network - data) >
+						(max - sizeof(struct ipv6hdr)))
+			return max;
+
+		/* record next protocol */
+		hlen = sizeof(struct ipv6hdr);
+	} else {
+		return network - data;
+	}
+
+	/* relocate pointer to start of L4 header */
+	network += hlen;
+
+	/* finally sort out TCP/UDP */
+	if (hnae_get_field(flag, HNS_RXD_L4ID_M, HNS_RXD_L4ID_S)
+		== HNS_RX_FLAG_L4ID_TCP) {
+		if ((typeof(max))(network - data) >
+						(max - sizeof(struct tcphdr)))
+			return max;
+
+		/* access doff as a u8 to avoid unaligned access on ia64 */
+		hlen = (network[12] & 0xF0) >> 2;
+
+		/* verify hlen meets minimum size requirements */
+		if (hlen < sizeof(struct tcphdr))
+			return network - data;
+
+		network += hlen;
+	} else if (hnae_get_field(flag, HNS_RXD_L4ID_M, HNS_RXD_L4ID_S)
+		== HNS_RX_FLAG_L4ID_UDP) {
+		if ((typeof(max))(network - data) >
+						(max - sizeof(struct udphdr)))
+			return max;
+
+		network += sizeof(struct udphdr);
+	}
+
+	/* If everything has gone correctly network should be the
+	 * data section of the packet and will be the end of the header.
+	 * If not then it probably represents the end of the last recognized
+	 * header.
+	 */
+	if ((typeof(max))(network - data) < max)
+		return network - data;
+	else
+		return max;
+}
+
+static inline void hns_nic_reuse_page(struct hnae_desc_cb *desc_cb, int tsize,
+				      int last_offset)
+{
+	 /* avoid re-using remote pages,flag default unreuse */
+	if (likely(page_to_nid(desc_cb->priv) == numa_node_id())) {
+		/* move offset up to the next cache line */
+		desc_cb->page_offset += tsize;
+
+		if (desc_cb->page_offset <= last_offset) {
+			desc_cb->reuse_flag = 1;
+			/* bump ref count on page before it is given*/
+			get_page(desc_cb->priv);
+		}
+	}
+}
+
+static inline int hns_nic_poll_rx_skb(struct hns_nic_ring_data *ring_data,
+				      struct sk_buff **out_skb, int *out_bnum)
+{
+	struct hnae_ring *ring = ring_data->ring;
+	struct net_device *ndev = ring_data->napi.dev;
+	struct sk_buff *skb;
+	struct hnae_desc *desc;
+	struct hnae_desc_cb *desc_cb;
+	unsigned char *va;
+	int bnum, length, size, i, truesize, last_offset;
+	int pull_len;
+	u32 bnum_flag;
+
+	last_offset = hnae_page_size(ring) - hnae_buf_size(ring);
+	desc = &ring->desc[ring->next_to_clean];
+	desc_cb = &ring->desc_cb[ring->next_to_clean];
+	length = le16_to_cpu(desc->rx.pkt_len);
+	bnum_flag = le32_to_cpu(desc->rx.ipoff_bnum_pid_flag);
+	bnum = hnae_get_field(bnum_flag, HNS_RXD_BUFNUM_M, HNS_RXD_BUFNUM_S);
+	*out_bnum = bnum;
+	va = (unsigned char *)desc_cb->buf + desc_cb->page_offset;
+
+	skb = *out_skb = napi_alloc_skb(&ring_data->napi, HNS_RX_HEAD_SIZE);
+	if (unlikely(!skb)) {
+		netdev_err(ndev, "alloc rx skb fail\n");
+		ring->stats.sw_err_cnt++;
+		return -ENOMEM;
+	}
+
+	if (length <= HNS_RX_HEAD_SIZE) {
+		memcpy(__skb_put(skb, length), va, ALIGN(length, sizeof(long)));
+
+		/* we can reuse buffer as-is, just make sure it is local */
+		if (likely(page_to_nid(desc_cb->priv) == numa_node_id()))
+			desc_cb->reuse_flag = 1;
+		else /* this page cannot be reused so discard it */
+			put_page(desc_cb->priv);
+
+		ring_ptr_move_fw(ring, next_to_clean);
+
+		if (unlikely(bnum != 1)) { /* check err*/
+			*out_bnum = 1;
+			goto out_bnum_err;
+		}
+	} else {
+		ring->stats.seg_pkt_cnt++;
+
+		pull_len = hns_nic_get_headlen(va, bnum_flag, HNS_RX_HEAD_SIZE);
+		memcpy(__skb_put(skb, pull_len), va,
+		       ALIGN(pull_len, sizeof(long)));
+
+		size = le16_to_cpu(desc->rx.size);
+		truesize = ALIGN(size, L1_CACHE_BYTES);
+		skb_add_rx_frag(skb, 0, desc_cb->priv,
+				desc_cb->page_offset + pull_len,
+				size - pull_len, truesize - pull_len);
+
+		hns_nic_reuse_page(desc_cb, truesize, last_offset);
+		ring_ptr_move_fw(ring, next_to_clean);
+
+		if (unlikely(bnum >= (int)MAX_SKB_FRAGS)) { /* check err*/
+			*out_bnum = 1;
+			goto out_bnum_err;
+		}
+		for (i = 1; i < bnum; i++) {
+			desc = &ring->desc[ring->next_to_clean];
+			desc_cb = &ring->desc_cb[ring->next_to_clean];
+			size = le16_to_cpu(desc->rx.size);
+			truesize = ALIGN(size, L1_CACHE_BYTES);
+			skb_add_rx_frag(skb, i, desc_cb->priv,
+					desc_cb->page_offset,
+					size, truesize);
+
+			hns_nic_reuse_page(desc_cb, truesize, last_offset);
+			ring_ptr_move_fw(ring, next_to_clean);
+		}
+	}
+
+	/* check except process, free skb and jump the desc */
+	if (unlikely((!bnum) || (bnum > ring->max_desc_num_per_pkt))) {
+out_bnum_err:
+		*out_bnum = *out_bnum ? *out_bnum : 1; /* ntc moved,cannot 0*/
+		netdev_err(ndev, "invalid bnum(%d,%d,%d,%d),%016llx,%016llx\n",
+			   bnum, ring->max_desc_num_per_pkt,
+			   length, (int)MAX_SKB_FRAGS,
+			   ((u64 *)desc)[0], ((u64 *)desc)[1]);
+		ring->stats.err_bd_num++;
+		dev_kfree_skb_any(skb);
+		return -EDOM;
+	}
+
+	bnum_flag = le32_to_cpu(desc->rx.ipoff_bnum_pid_flag);
+
+	if (unlikely(!hnae_get_bit(bnum_flag, HNS_RXD_VLD_B))) {
+		netdev_err(ndev, "no valid bd,%016llx,%016llx\n",
+			   ((u64 *)desc)[0], ((u64 *)desc)[1]);
+		ring->stats.non_vld_descs++;
+		dev_kfree_skb_any(skb);
+		return -EINVAL;
+	}
+
+	if (unlikely((!desc->rx.pkt_len) ||
+		     hnae_get_bit(bnum_flag, HNS_RXD_DROP_B))) {
+		if (!(ring->stats.err_pkt_len % RCB_ERR_PRINT_CYCLE))
+			netdev_dbg(ndev,
+				   "pkt_len(%u),drop(%u),%#llx,%#llx\n",
+				   le16_to_cpu(desc->rx.pkt_len),
+				   hnae_get_bit(bnum_flag, HNS_RXD_DROP_B),
+				   ((u64 *)desc)[0], ((u64 *)desc)[1]);
+		ring->stats.err_pkt_len++;
+		dev_kfree_skb_any(skb);
+		return -EFAULT;
+	}
+
+	if (unlikely(hnae_get_bit(bnum_flag, HNS_RXD_L2E_B) ||
+		     hnae_get_bit(bnum_flag, HNS_RXD_L3E_B) ||
+		     hnae_get_bit(bnum_flag, HNS_RXD_L4E_B))) {
+		if (!(ring->stats.csum_err % RCB_ERR_PRINT_CYCLE))
+			netdev_dbg(ndev,
+				   "check err(%#x),%#llx,%#llx\n",
+				   hnae_get_bit(bnum_flag, HNS_RXD_L2E_B) |
+				   hnae_get_bit(bnum_flag, HNS_RXD_L3E_B) |
+				   hnae_get_bit(bnum_flag, HNS_RXD_L4E_B),
+				   ((u64 *)desc)[0], ((u64 *)desc)[1]);
+		ring->stats.csum_err++;
+		dev_kfree_skb_any(skb);
+		return -EFAULT;
+	}
+
+	ring->stats.pkts.rx_pkts++;
+	ring->stats.bytes.rx_bytes += skb->len;
+
+	return 0;
+}
+
+static inline void hns_nic_alloc_rx_buffers(struct hns_nic_ring_data *ring_data,
+					    int cleand_count)
+{
+	int i, ret;
+	struct hnae_desc_cb res_cbs;
+	struct hnae_desc *desc;
+	struct hnae_desc_cb *desc_cb;
+	struct hnae_ring *ring = ring_data->ring;
+	struct net_device *ndev = ring_data->napi.dev;
+
+	for (i = 0; i < cleand_count; i++) {
+		desc = &ring->desc[ring->next_to_use];
+		desc_cb = &ring->desc_cb[ring->next_to_use];
+		if (desc_cb->reuse_flag) {
+			ring->stats.reuse_pg_cnt++;
+			hnae_reuse_buffer(ring, ring->next_to_use);
+		} else {
+			ret = hnae_reserve_buffer_map(ring, &res_cbs);
+			if (ret) {
+				ring->stats.sw_err_cnt++;
+				netdev_err(ndev, "hnae reserve buffer map failed.\n");
+				break;
+			}
+			hnae_replace_buffer(ring, ring->next_to_use, &res_cbs);
+		}
+
+		ring_ptr_move_fw(ring, next_to_use);
+	}
+
+	wmb(); /* make all data has been write before submit */
+	writel_relaxed(i, ring->io_base + RCB_REG_HEAD);
+}
+
+/* return error number for error or number of desc left to take
+ */
+static void hns_nic_rx_up_pro(struct hns_nic_ring_data *ring_data,
+			      struct sk_buff *skb)
+{
+	struct net_device *ndev = ring_data->napi.dev;
+
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	skb->protocol = eth_type_trans(skb, ndev);
+	(void)napi_gro_receive(&ring_data->napi, skb);
+	ndev->last_rx = jiffies;
+}
+
+static int hns_nic_rx_poll_one(struct hns_nic_ring_data *ring_data,
+			       int budget, void *v)
+{
+	struct hnae_ring *ring = ring_data->ring;
+	struct sk_buff *skb;
+	int num, bnum, ex_num;
+#define RCB_NOF_ALLOC_RX_BUFF_ONCE 16
+	int recv_pkts, recv_bds, clean_count, err;
+
+	num = readl_relaxed(ring->io_base + RCB_REG_FBDNUM);
+	rmb(); /* make sure num taken effect before the other data is touched */
+
+	recv_pkts = 0, recv_bds = 0, clean_count = 0;
+recv:
+	while (recv_pkts < budget && recv_bds < num) {
+		/* reuse or realloc buffers*/
+		if (clean_count >= RCB_NOF_ALLOC_RX_BUFF_ONCE) {
+			hns_nic_alloc_rx_buffers(ring_data, clean_count);
+			clean_count = 0;
+		}
+
+		/* poll one pkg*/
+		err = hns_nic_poll_rx_skb(ring_data, &skb, &bnum);
+		if (unlikely(!skb)) /* this fault cannot be repaired */
+			break;
+
+		recv_bds += bnum;
+		clean_count += bnum;
+		if (unlikely(err))  /* do jump the err */
+			continue;
+
+		/* do update ip stack process*/
+		((void (*)(struct hns_nic_ring_data *, struct sk_buff *))v)(
+							ring_data, skb);
+		recv_pkts++;
+	}
+
+	/* make all data has been write before submit */
+	if (clean_count > 0) {
+		hns_nic_alloc_rx_buffers(ring_data, clean_count);
+		clean_count = 0;
+	}
+
+	if (recv_pkts < budget) {
+		ex_num = readl_relaxed(ring->io_base + RCB_REG_FBDNUM);
+		rmb(); /*complete read rx ring bd number*/
+		if (ex_num > 0) {
+			num += ex_num;
+			goto recv;
+		}
+	}
+
+	return recv_pkts;
+}
+
+static inline void hns_nic_reclaim_one_desc(struct hnae_ring *ring,
+					    int *bytes, int *pkts)
+{
+	struct hnae_desc_cb *desc_cb = &ring->desc_cb[ring->next_to_clean];
+
+	(*pkts) += (desc_cb->type == DESC_TYPE_SKB);
+	(*bytes) += desc_cb->length;
+	/* desc_cb will be cleaned, after hnae_free_buffer_detach*/
+	hnae_free_buffer_detach(ring, ring->next_to_clean);
+
+	ring_ptr_move_fw(ring, next_to_clean);
+}
+
+static int is_valid_clean_head(struct hnae_ring *ring, int h)
+{
+	int u = ring->next_to_use;
+	int c = ring->next_to_clean;
+
+	if (unlikely(h > ring->desc_num))
+		return 0;
+
+	assert(u > 0 && u < ring->desc_num);
+	assert(c > 0 && c < ring->desc_num);
+	assert(u != c && h != c); /* must be checked before call this func */
+
+	return u > c ? (h > c && h <= u) : (h > c || h <= u);
+}
+
+/* netif_tx_lock will turn down the performance, set only when necessary */
+#ifdef CONFIG_NET_POLL_CONTROLLER
+#define NETIF_TX_LOCK(ndev) netif_tx_lock(ndev)
+#define NETIF_TX_UNLOCK(ndev) netif_tx_unlock(ndev)
+#else
+#define NETIF_TX_LOCK(ndev)
+#define NETIF_TX_UNLOCK(ndev)
+#endif
+/* reclaim all desc in one budget
+ * return error or number of desc left
+ */
+static int hns_nic_tx_poll_one(struct hns_nic_ring_data *ring_data,
+			       int budget, void *v)
+{
+	struct hnae_ring *ring = ring_data->ring;
+	struct net_device *ndev = ring_data->napi.dev;
+	struct netdev_queue *dev_queue;
+	int head;
+	int bytes, pkts;
+
+	NETIF_TX_LOCK(ndev);
+
+	head = readl_relaxed(ring->io_base + RCB_REG_HEAD);
+	rmb(); /* make sure head is ready before touch any data */
+
+	if (is_ring_empty(ring) || head == ring->next_to_clean) {
+		NETIF_TX_UNLOCK(ndev);
+		return 0; /* no data to poll */
+	}
+
+	if (!is_valid_clean_head(ring, head)) {
+		netdev_err(ndev, "wrong head (%d, %d-%d)\n", head,
+			   ring->next_to_use, ring->next_to_clean);
+		ring->stats.io_err_cnt++;
+		NETIF_TX_UNLOCK(ndev);
+		return -EIO;
+	}
+
+	bytes = 0;
+	pkts = 0;
+	while (head != ring->next_to_clean)
+		hns_nic_reclaim_one_desc(ring, &bytes, &pkts);
+
+	NETIF_TX_UNLOCK(ndev);
+
+	dev_queue = netdev_get_tx_queue(ndev, ring_data->queue_index);
+	netdev_tx_completed_queue(dev_queue, pkts, bytes);
+
+	if (unlikely(netif_tx_queue_stopped(dev_queue)))
+		netif_tx_wake_queue(dev_queue);
+
+	return 0;
+}
+
+static void hns_nic_tx_clr_all_bufs(struct hns_nic_ring_data *ring_data)
+{
+	struct hnae_ring *ring = ring_data->ring;
+	struct net_device *ndev = ring_data->napi.dev;
+	struct netdev_queue *dev_queue;
+	int head;
+	int bytes, pkts;
+
+	NETIF_TX_LOCK(ndev);
+
+	head = ring->next_to_use; /* ntu :soft setted ring position*/
+	bytes = 0;
+	pkts = 0;
+	while (head != ring->next_to_clean)
+		hns_nic_reclaim_one_desc(ring, &bytes, &pkts);
+
+	NETIF_TX_UNLOCK(ndev);
+
+	dev_queue = netdev_get_tx_queue(ndev, ring_data->queue_index);
+	netdev_tx_reset_queue(dev_queue);
+}
+
+static int hns_nic_common_poll(struct napi_struct *napi, int budget)
+{
+	struct hns_nic_ring_data *ring_data =
+		container_of(napi, struct hns_nic_ring_data, napi);
+	int clean_complete = ring_data->poll_one(
+				ring_data, budget, ring_data->ex_process);
+
+	if (clean_complete >= 0 && clean_complete < budget) {
+		napi_complete(napi);
+		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
+			ring_data->ring, 0);
+	}
+
+	return clean_complete;
+}
+
+static irqreturn_t hns_irq_handle(int irq, void *dev)
+{
+	struct hns_nic_ring_data *ring_data = (struct hns_nic_ring_data *)dev;
+
+	ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
+		ring_data->ring, 1);
+	napi_schedule(&ring_data->napi);
+
+	return IRQ_HANDLED;
+}
+
+/**
+ *hns_nic_adjust_link - adjust net work mode by the phy stat or new param
+ *@ndev: net device
+ */
+static void hns_nic_adjust_link(struct net_device *ndev)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h = priv->ae_handle;
+
+	h->dev->ops->adjust_link(h, ndev->phydev->speed, ndev->phydev->duplex);
+}
+
+/**
+ *hns_nic_init_phy - init phy
+ *@ndev: net device
+ *@h: ae handle
+ * Return 0 on success, negative on failure
+ */
+int hns_nic_init_phy(struct net_device *ndev, struct hnae_handle *h)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct phy_device *phy_dev = NULL;
+
+	if (!h->phy_node)
+		return 0;
+
+	if (h->phy_if != PHY_INTERFACE_MODE_XGMII)
+		phy_dev = of_phy_connect(ndev, h->phy_node,
+					 hns_nic_adjust_link, 0, h->phy_if);
+	else
+		phy_dev = of_phy_attach(ndev, h->phy_node, 0, h->phy_if);
+
+	if (unlikely(!phy_dev) || IS_ERR(phy_dev))
+		return !phy_dev ? -ENODEV : PTR_ERR(phy_dev);
+
+	phy_dev->supported &= h->if_support;
+	phy_dev->advertising = phy_dev->supported;
+
+	if (h->phy_if == PHY_INTERFACE_MODE_XGMII)
+		phy_dev->autoneg = false;
+
+	priv->phy = phy_dev;
+
+	return 0;
+}
+
+static int hns_nic_ring_open(struct net_device *netdev, int idx)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_handle *h = priv->ae_handle;
+
+	napi_enable(&priv->ring_data[idx].napi);
+
+	enable_irq(priv->ring_data[idx].ring->irq);
+	h->dev->ops->toggle_ring_irq(priv->ring_data[idx].ring, 0);
+
+	return 0;
+}
+
+static int hns_nic_net_set_mac_address(struct net_device *ndev, void *p)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h = priv->ae_handle;
+	struct sockaddr *mac_addr = p;
+	int ret;
+
+	if (!mac_addr || !is_valid_ether_addr((const u8 *)mac_addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	ret = h->dev->ops->set_mac_addr(h, mac_addr->sa_data);
+	if (ret) {
+		netdev_err(ndev, "set_mac_address fail, ret=%d!\n", ret);
+		return ret;
+	}
+
+	memcpy(ndev->dev_addr, mac_addr->sa_data, ndev->addr_len);
+
+	return 0;
+}
+
+void hns_nic_update_stats(struct net_device *netdev)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_handle *h = priv->ae_handle;
+
+	h->dev->ops->update_stats(h, &h->net_stats);
+
+	netdev->stats.rx_bytes = h->net_stats.rx_bytes;
+	netdev->stats.rx_packets = h->net_stats.rx_packets;
+	netdev->stats.tx_bytes = h->net_stats.tx_bytes;
+	netdev->stats.tx_packets = h->net_stats.tx_packets;
+	netdev->stats.rx_crc_errors = h->net_stats.rx_crc_errors;
+	netdev->stats.rx_frame_errors = h->net_stats.rx_frame_errors;
+	netdev->stats.rx_fifo_errors = h->net_stats.rx_fifo_errors;
+	netdev->stats.rx_length_errors = h->net_stats.rx_length_errors;
+	netdev->stats.multicast = h->net_stats.multicast;
+	netdev->stats.rx_errors = h->net_stats.rx_errors;
+	netdev->stats.rx_dropped = h->net_stats.rx_dropped;
+	netdev->stats.tx_errors = h->net_stats.tx_errors;
+	netdev->stats.tx_dropped = h->net_stats.tx_dropped;
+}
+
+/* set mac addr if it is configed. or leave it to the AE driver */
+static inline void hns_init_mac_addr(struct net_device *ndev)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct device_node *node = priv->dev->of_node;
+	const void *mac_addr_temp;
+
+	mac_addr_temp = of_get_mac_address(node);
+	if (mac_addr_temp && is_valid_ether_addr(mac_addr_temp)) {
+		memcpy(ndev->dev_addr, mac_addr_temp, ndev->addr_len);
+	} else {
+		eth_hw_addr_random(ndev);
+		dev_warn(priv->dev, "No valid mac, use random mac %pM",
+			 ndev->dev_addr);
+	}
+}
+
+static void hns_nic_ring_close(struct net_device *netdev, int idx)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_handle *h = priv->ae_handle;
+
+	h->dev->ops->toggle_ring_irq(priv->ring_data[idx].ring, 1);
+	disable_irq(priv->ring_data[idx].ring->irq);
+
+	napi_disable(&priv->ring_data[idx].napi);
+}
+
+static int hns_nic_net_up(struct net_device *ndev)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h = priv->ae_handle;
+	int i, j, k;
+	int ret;
+
+	if (h->phy_node) {
+		ret = hns_nic_init_phy(ndev, h);
+		if (ret)
+			goto out;
+	}
+
+	for (i = 0; i < h->q_num * 2; i++) {
+		ret = hns_nic_ring_open(ndev, i);
+		if (ret)
+			goto out_has_some_queues;
+	}
+
+	for (k = 0; k < h->q_num; k++)
+		h->dev->ops->toggle_queue_status(h->qs[k], 1);
+
+	ret = h->dev->ops->set_mac_addr(h, ndev->dev_addr);
+	if (ret)
+		goto out_set_mac_addr_err;
+
+	ret = h->dev->ops->start ? h->dev->ops->start(h) : 0;
+	if (ret)
+		goto out_start_err;
+
+	if (priv->phy)
+		phy_start(priv->phy);
+
+	netif_tx_wake_all_queues(ndev);
+
+	clear_bit(NIC_STATE_DOWN, &priv->state);
+	(void)mod_timer(&priv->service_timer, jiffies + SERVICE_TIMER_HZ);
+
+	return 0;
+
+out_start_err:
+	netif_stop_queue(ndev);
+out_set_mac_addr_err:
+	for (k = 0; k < h->q_num; k++)
+		h->dev->ops->toggle_queue_status(h->qs[k], 0);
+out_has_some_queues:
+	for (j = i - 1; j >= 0; j--)
+		hns_nic_ring_close(ndev, j);
+out:
+	set_bit(NIC_STATE_DOWN, &priv->state);
+	return ret;
+}
+
+static void hns_nic_net_down(struct net_device *ndev)
+{
+	int i;
+	struct hnae_ae_ops *ops;
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+
+	if (test_and_set_bit(NIC_STATE_DOWN, &priv->state))
+		return;
+
+	(void)del_timer_sync(&priv->service_timer);
+	priv->link = 0;
+	netif_carrier_off(ndev);
+
+	if (priv->phy) {
+		phy_stop(priv->phy);
+		phy_disconnect(priv->phy);
+		priv->phy = NULL;
+	}
+	ops = priv->ae_handle->dev->ops;
+
+	if (ops->stop)
+		ops->stop(priv->ae_handle);
+
+	netif_tx_stop_all_queues(ndev);
+
+	for (i = priv->ae_handle->q_num - 1; i >= 0; i--) {
+		hns_nic_ring_close(ndev, i);
+		hns_nic_ring_close(ndev, i + priv->ae_handle->q_num);
+
+		/* clean tx buffers*/
+		hns_nic_tx_clr_all_bufs(priv->ring_data + i);
+	}
+}
+
+void hns_nic_net_reset(struct net_device *ndev)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *handle = priv->ae_handle;
+
+	while (test_and_set_bit(NIC_STATE_RESETTING, &priv->state))
+		usleep_range(1000, 2000);
+
+	if (handle->dev->ops->stop)
+		handle->dev->ops->stop(handle);
+	msleep(100);
+
+	if (handle->dev->ops->reset)
+		handle->dev->ops->reset(handle);
+	(void)hnae_reinit_handle(handle);
+
+	clear_bit(NIC_STATE_RESETTING, &priv->state);
+}
+
+void hns_nic_net_reinit(struct net_device *netdev)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+
+	priv->netdev->trans_start = jiffies;
+	while (test_and_set_bit(NIC_STATE_REINITING, &priv->state))
+		usleep_range(1000, 2000);
+
+	hns_nic_net_down(netdev);
+	hns_nic_net_reset(netdev);
+	(void)hns_nic_net_up(netdev);
+	clear_bit(NIC_STATE_REINITING, &priv->state);
+}
+
+static int hns_nic_net_open(struct net_device *ndev)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h = priv->ae_handle;
+	int ret;
+
+	if (test_bit(NIC_STATE_TESTING, &priv->state))
+		return -EBUSY;
+
+	priv->link = 0;
+	netif_carrier_off(ndev);
+
+	ret = netif_set_real_num_tx_queues(ndev, h->q_num);
+	if (ret < 0) {
+		netdev_err(ndev, "netif_set_real_num_tx_queues fail, ret=%d!\n",
+			   ret);
+		return ret;
+	}
+
+	ret = netif_set_real_num_rx_queues(ndev, h->q_num);
+	if (ret < 0) {
+		netdev_err(ndev,
+			   "netif_set_real_num_rx_queues fail, ret=%d!\n", ret);
+		return ret;
+	}
+
+	ret = hns_nic_net_up(ndev);
+	if (ret) {
+		netdev_err(ndev,
+			   "hns net up fail, ret=%d!\n", ret);
+		return ret;
+	}
+
+	return 0;
+}
+
+static int hns_nic_net_stop(struct net_device *ndev)
+{
+	hns_nic_net_down(ndev);
+
+	return 0;
+}
+
+static void hns_tx_timeout_reset(struct hns_nic_priv *priv);
+static void hns_nic_net_timeout(struct net_device *ndev)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+
+	hns_tx_timeout_reset(priv);
+}
+
+static int hns_nic_do_ioctl(struct net_device *netdev, struct ifreq *ifr,
+			    int cmd)
+{
+	switch (cmd) {
+	default:
+		return -ENOTSUPP;
+	}
+}
+
+/* use only for netconsole to poll with the device without interrupt */
+#ifdef CONFIG_NET_POLL_CONTROLLER
+void hns_nic_poll_controller(struct net_device *ndev)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	unsigned long flags;
+	int i;
+
+	local_irq_save(flags);
+	for (i = 0; i < priv->ae_handle->q_num * 2; i++)
+		napi_schedule(&priv->ring_data[i].napi);
+	local_irq_restore(flags);
+}
+#endif
+
+static netdev_tx_t hns_nic_net_xmit(struct sk_buff *skb,
+				    struct net_device *ndev)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	int ret;
+
+	assert(skb->queue_mapping < ndev->ae_handle->q_num);
+	ret = hns_nic_net_xmit_hw(ndev, skb,
+				  &tx_ring_data(priv, skb->queue_mapping));
+	if (ret == NETDEV_TX_OK) {
+		ndev->trans_start = jiffies;
+		ndev->stats.tx_bytes += skb->len;
+		ndev->stats.tx_packets++;
+	}
+	return (netdev_tx_t)ret;
+}
+
+static int hns_nic_change_mtu(struct net_device *ndev, int new_mtu)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h = priv->ae_handle;
+	int ret;
+
+	/* MTU < 68 is an error and causes problems on some kernels */
+	if (new_mtu < 68)
+		return -EINVAL;
+
+	if (!h->dev->ops->set_mtu)
+		return -ENOTSUPP;
+
+	if (netif_running(ndev)) {
+		hns_nic_net_stop(ndev);
+		msleep(100);
+
+		ret = h->dev->ops->set_mtu(h, new_mtu);
+		if (ret)
+			netdev_err(ndev, "set mtu fail, return value %d\n",
+				   ret);
+
+		if (hns_nic_net_open(ndev))
+			netdev_err(ndev, "hns net open fail\n");
+	} else {
+		ret = h->dev->ops->set_mtu(h, new_mtu);
+	}
+
+	if (!ret)
+		ndev->mtu = new_mtu;
+
+	return ret;
+}
+
+/**
+ * nic_set_multicast_list - set mutl mac address
+ * @netdev: net device
+ * @p: mac address
+ *
+ * return void
+ */
+void hns_set_multicast_list(struct net_device *ndev)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h = priv->ae_handle;
+	struct netdev_hw_addr *ha = NULL;
+
+	assert(priv);
+
+	if (netif_running(ndev))
+		return;
+
+	if (!h)	{
+		netdev_err(ndev, "hnae handle is null\n");
+		return;
+	}
+
+	if (h->dev->ops->set_mc_addr) {
+		netdev_for_each_mc_addr(ha, ndev)
+			if (h->dev->ops->set_mc_addr(h, ha->addr))
+				netdev_err(ndev, "set multicast fail\n");
+	}
+}
+
+struct rtnl_link_stats64 *hns_nic_get_stats64(struct net_device *ndev,
+					      struct rtnl_link_stats64 *stats)
+{
+	int idx = 0;
+	u64 tx_bytes = 0;
+	u64 rx_bytes = 0;
+	u64 tx_pkts = 0;
+	u64 rx_pkts = 0;
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h = priv->ae_handle;
+
+	for (idx = 0; idx < h->q_num; idx++) {
+		tx_bytes += h->qs[idx]->tx_ring.stats.bytes.tx_bytes;
+		tx_pkts += h->qs[idx]->tx_ring.stats.pkts.tx_pkts;
+		rx_bytes += h->qs[idx]->rx_ring.stats.bytes.rx_bytes;
+		rx_pkts += h->qs[idx]->rx_ring.stats.pkts.rx_pkts;
+	}
+
+	stats->tx_bytes = tx_bytes;
+	stats->tx_packets = tx_pkts;
+	stats->rx_bytes = rx_bytes;
+	stats->rx_packets = rx_pkts;
+
+	stats->rx_errors = ndev->stats.rx_errors;
+	stats->multicast = ndev->stats.multicast;
+	stats->rx_length_errors = ndev->stats.rx_length_errors;
+	stats->rx_crc_errors = ndev->stats.rx_crc_errors;
+	stats->rx_missed_errors = ndev->stats.rx_missed_errors;
+
+	stats->tx_errors = ndev->stats.tx_errors;
+	stats->rx_dropped = ndev->stats.rx_dropped;
+	stats->tx_dropped = ndev->stats.tx_dropped;
+	stats->collisions = ndev->stats.collisions;
+	stats->rx_over_errors = ndev->stats.rx_over_errors;
+	stats->rx_frame_errors = ndev->stats.rx_frame_errors;
+	stats->rx_fifo_errors = ndev->stats.rx_fifo_errors;
+	stats->tx_aborted_errors = ndev->stats.tx_aborted_errors;
+	stats->tx_carrier_errors = ndev->stats.tx_carrier_errors;
+	stats->tx_fifo_errors = ndev->stats.tx_fifo_errors;
+	stats->tx_heartbeat_errors = ndev->stats.tx_heartbeat_errors;
+	stats->tx_window_errors = ndev->stats.tx_window_errors;
+	stats->rx_compressed = ndev->stats.rx_compressed;
+	stats->tx_compressed = ndev->stats.tx_compressed;
+
+	return stats;
+}
+
+static const struct net_device_ops hns_nic_netdev_ops = {
+	.ndo_open = hns_nic_net_open,
+	.ndo_stop = hns_nic_net_stop,
+	.ndo_start_xmit = hns_nic_net_xmit,
+	.ndo_tx_timeout = hns_nic_net_timeout,
+	.ndo_set_mac_address = hns_nic_net_set_mac_address,
+	.ndo_change_mtu = hns_nic_change_mtu,
+	.ndo_do_ioctl = hns_nic_do_ioctl,
+	.ndo_get_stats64 = hns_nic_get_stats64,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = hns_nic_poll_controller,
+#endif
+	.ndo_set_rx_mode = hns_set_multicast_list,
+};
+
+static void hns_nic_update_link_status(struct net_device *netdev)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+
+	struct hnae_handle *h = priv->ae_handle;
+	int state = 1;
+
+	if (priv->phy) {
+		if (!genphy_update_link(priv->phy))
+			state = priv->phy->link;
+		else
+			state = 0;
+	}
+	state = state && h->dev->ops->get_status(h);
+
+	if (state != priv->link) {
+		if (state) {
+			netif_carrier_on(netdev);
+			netdev_info(netdev, "link up\n");
+		} else {
+			netif_carrier_off(netdev);
+			netdev_info(netdev, "link down\n");
+		}
+		priv->link = state;
+	}
+}
+
+/* for dumping key regs*/
+static void hns_nic_dump(struct hns_nic_priv *priv)
+{
+	struct hnae_ae_ops *ops = priv->ae_handle->dev->ops;
+	u32 *data, reg_num, i;
+
+	if (ops->get_regs_len && ops->get_regs) {
+		reg_num = ops->get_regs_len(priv->ae_handle);
+		reg_num = (reg_num + 3ul) & ~3ul;
+		data = kcalloc(reg_num, sizeof(u32), GFP_KERNEL);
+		if (data) {
+			ops->get_regs(priv->ae_handle, data);
+			for (i = 0; i < reg_num; i++)
+				pr_info("0x%08x: 0x%08x 0x%08x 0x%08x 0x%08x\n",
+					i, data[i], data[i + 1],
+					data[i + 2], data[i + 3]);
+			kfree(data);
+		}
+	}
+}
+
+/* for resetting suntask*/
+static void hns_nic_reset_subtask(struct hns_nic_priv *priv)
+{
+	enum hnae_port_type type = priv->ae_handle->port_type;
+
+	if (!test_bit(NIC_STATE2_RESET_REQUESTED, &priv->state))
+		return;
+	clear_bit(NIC_STATE2_RESET_REQUESTED, &priv->state);
+
+	/* If we're already down, removing or resetting, just bail */
+	if (test_bit(NIC_STATE_DOWN, &priv->state) ||
+	    test_bit(NIC_STATE_REMOVING, &priv->state) ||
+	    test_bit(NIC_STATE_RESETTING, &priv->state))
+		return;
+
+	hns_nic_dump(priv);
+	netdev_err(priv->netdev, "Reset %s port\n",
+		   (type == HNAE_PORT_DEBUG ? "debug" : "business"));
+
+	rtnl_lock();
+	if (type == HNAE_PORT_DEBUG) {
+		hns_nic_net_reinit(priv->netdev);
+	} else {
+		hns_nic_net_down(priv->netdev);
+		hns_nic_net_reset(priv->netdev);
+	}
+	rtnl_unlock();
+}
+
+/* for doing service complete*/
+static void hns_nic_service_event_complete(struct hns_nic_priv *priv)
+{
+	BUG_ON(!test_bit(NIC_STATE_SERVICE_SCHED, &priv->state));
+
+	smp_mb__before_atomic();
+	clear_bit(NIC_STATE_SERVICE_SCHED, &priv->state);
+}
+
+static void hns_nic_service_task(struct work_struct *work)
+{
+	struct hns_nic_priv *priv
+		= container_of(work, struct hns_nic_priv, service_task);
+	struct hnae_handle *h = priv->ae_handle;
+
+	hns_nic_update_link_status(priv->netdev);
+	h->dev->ops->update_led_status(h);
+	hns_nic_update_stats(priv->netdev);
+
+	hns_nic_reset_subtask(priv);
+	hns_nic_service_event_complete(priv);
+}
+
+static void hns_nic_task_schedule(struct hns_nic_priv *priv)
+{
+	if (!test_bit(NIC_STATE_DOWN, &priv->state) &&
+	    !test_bit(NIC_STATE_REMOVING, &priv->state) &&
+	    !test_and_set_bit(NIC_STATE_SERVICE_SCHED, &priv->state))
+		(void)schedule_work(&priv->service_task);
+}
+
+static void hns_nic_service_timer(unsigned long data)
+{
+	struct hns_nic_priv *priv = (struct hns_nic_priv *)data;
+
+	(void)mod_timer(&priv->service_timer, jiffies + SERVICE_TIMER_HZ);
+
+	hns_nic_task_schedule(priv);
+}
+
+/**
+ * hns_tx_timeout_reset - initiate reset due to Tx timeout
+ * @priv: driver private struct
+ **/
+static void hns_tx_timeout_reset(struct hns_nic_priv *priv)
+{
+	/* Do the reset outside of interrupt context */
+	if (!test_bit(NIC_STATE_DOWN, &priv->state)) {
+		set_bit(NIC_STATE2_RESET_REQUESTED, &priv->state);
+		netdev_warn(priv->netdev,
+			    "initiating reset due to tx timeout(%llu,0x%lx)\n",
+			    priv->tx_timeout_count, priv->state);
+		priv->tx_timeout_count++;
+		hns_nic_task_schedule(priv);
+	}
+}
+
+static int hns_nic_init_ring_data(struct hns_nic_priv *priv)
+{
+	struct hnae_handle *h = priv->ae_handle;
+	struct hns_nic_ring_data *rd;
+	int i, j;
+	int ret;
+
+	if (h->q_num > NIC_MAX_Q_PER_VF) {
+		ret = -EINVAL;
+		netdev_err(priv->netdev, "too much queue (%d)\n", h->q_num);
+		goto out;
+	}
+
+	priv->ring_data = kzalloc(h->q_num * sizeof(*priv->ring_data) * 2,
+				  GFP_KERNEL);
+	if (!priv->ring_data) {
+		ret = -ENOMEM;
+		netdev_err(priv->netdev, "malloc ring data fail\n");
+		goto out;
+	}
+
+	for (i = 0; i < h->q_num; i++) {
+		rd = &priv->ring_data[i];
+		rd->queue_index = i;
+		rd->ring = &h->qs[i]->tx_ring;
+		rd->poll_one = hns_nic_tx_poll_one;
+
+		snprintf(rd->ring->ring_name, RCB_RING_NAME_LEN, "eth%s-tx%d",
+			 h->ae_opts, rd->queue_index);
+		rd->ring->ring_name[RCB_RING_NAME_LEN - 1] = '\0';
+
+		ret = request_irq(rd->ring->irq,
+				  hns_irq_handle, 0, rd->ring->ring_name, rd);
+		if (ret) {
+			netdev_err(priv->netdev, "request irq(%d) fail\n",
+				   rd->ring->irq);
+			goto out_has_some_queues;
+		}
+		disable_irq(rd->ring->irq);
+		netif_napi_add(priv->netdev, &rd->napi,
+			       hns_nic_common_poll, NIC_TX_CLEAN_MAX_NUM);
+	}
+	for (i = h->q_num; i < h->q_num * 2; i++) {
+		rd = &priv->ring_data[i];
+		rd->queue_index = i - h->q_num;
+		rd->ring = &h->qs[i - h->q_num]->rx_ring;
+		rd->poll_one = hns_nic_rx_poll_one;
+		rd->ex_process = hns_nic_rx_up_pro;
+
+		snprintf(rd->ring->ring_name, RCB_RING_NAME_LEN, "eth%s-rx%d",
+			 h->ae_opts, rd->queue_index);
+		rd->ring->ring_name[RCB_RING_NAME_LEN - 1] = '\0';
+
+		ret = request_irq(rd->ring->irq,
+				  hns_irq_handle, 0, rd->ring->ring_name, rd);
+		if (ret) {
+			netdev_err(priv->netdev, "request irq(%d) fail\n",
+				   rd->ring->irq);
+			goto out_has_some_queues;
+		}
+		disable_irq(rd->ring->irq);
+		netif_napi_add(priv->netdev, &rd->napi,
+			       hns_nic_common_poll, NIC_RX_CLEAN_MAX_NUM);
+	}
+
+	return 0;
+
+out_has_some_queues:
+	for (j = i - 1; j >= 0; j--) {
+		netif_napi_del(&priv->ring_data[j].napi);
+		free_irq(priv->ring_data[j].ring->irq, &priv->ring_data[j]);
+	}
+	kfree(priv->ring_data);
+	priv->ring_data = NULL;
+out:
+	return ret;
+}
+
+static void hns_nic_uninit_ring_data(struct hns_nic_priv *priv)
+{
+	struct hnae_handle *h = priv->ae_handle;
+	int i;
+
+	for (i = 0; i < h->q_num * 2; i++) {
+		netif_napi_del(&priv->ring_data[i].napi);
+		free_irq(priv->ring_data[i].ring->irq, &priv->ring_data[i]);
+	}
+	kfree(priv->ring_data);
+}
+
+static int hns_nic_try_get_ae(struct net_device *ndev)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h;
+	int ret;
+
+	h = hnae_get_handle(&priv->netdev->dev,
+			    priv->ae_name, priv->ae_opts, NULL);
+	if (IS_ERR_OR_NULL(h)) {
+		ret = PTR_ERR(h);
+		dev_dbg(priv->dev, "has not handle, register notifier!\n");
+		goto out;
+	}
+	priv->ae_handle = h;
+
+	ret = hns_nic_init_ring_data(priv);
+	if (ret) {
+		ret = -ENOMEM;
+		goto out_init_ring_data;
+	}
+
+	ret = register_netdev(ndev);
+	if (ret) {
+		dev_err(priv->dev, "probe register netdev fail!\n");
+		goto out_reg_ndev_fail;
+	}
+	return 0;
+
+out_reg_ndev_fail:
+	hns_nic_uninit_ring_data(priv);
+	priv->ring_data = NULL;
+out_init_ring_data:
+	hnae_put_handle(priv->ae_handle);
+	priv->ae_handle = NULL;
+out:
+	return ret;
+}
+
+static int hns_nic_notifier_action(struct notifier_block *nb,
+				   unsigned long action, void *data)
+{
+	struct hns_nic_priv *priv =
+		container_of(nb, struct hns_nic_priv, notifier_block);
+
+	assert(action == HNAE_AE_REGISTER);
+
+	if (!hns_nic_try_get_ae(priv->netdev)) {
+		hnae_unregister_notifier(&priv->notifier_block);
+		priv->notifier_block.notifier_call = NULL;
+	}
+	return 0;
+}
+
+static int hns_nic_dev_probe(struct platform_device *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct net_device *ndev;
+	struct hns_nic_priv *priv;
+	struct device_node *node = dev->of_node;
+	int ret;
+
+	ndev = alloc_etherdev_mq(sizeof(struct hns_nic_priv), NIC_MAX_Q_PER_VF);
+	if (!ndev)
+		return -ENOMEM;
+
+	platform_set_drvdata(pdev, ndev);
+
+	priv = netdev_priv(ndev);
+	priv->dev = dev;
+	priv->netdev = ndev;
+
+	ret = of_property_read_string(node, "ae-name", &priv->ae_name);
+	if (ret)
+		goto out_read_string_fail;
+
+	ret = of_property_read_string(node, "ae-opts", &priv->ae_opts);
+	if (ret)
+		goto out_read_string_fail;
+
+	hns_init_mac_addr(ndev);
+
+	ndev->watchdog_timeo = HNS_NIC_TX_TIMEOUT;
+	ndev->priv_flags |= IFF_UNICAST_FLT;
+	ndev->netdev_ops = &hns_nic_netdev_ops;
+	hns_ethtool_set_ops(ndev);
+	ndev->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+		NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_GSO |
+		NETIF_F_GRO;
+	ndev->vlan_features |=
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM;
+	ndev->vlan_features |= NETIF_F_SG | NETIF_F_GSO | NETIF_F_GRO;
+
+	SET_NETDEV_DEV(ndev, dev);
+
+	if (!dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64)))
+		dev_dbg(dev, "set mask to 64bit\n");
+	else
+		dev_err(dev, "set mask to 32bit fail!\n");
+
+	/* carrier off reporting is important to ethtool even BEFORE open */
+	netif_carrier_off(ndev);
+
+	setup_timer(&priv->service_timer, hns_nic_service_timer,
+		    (unsigned long)priv);
+	INIT_WORK(&priv->service_task, hns_nic_service_task);
+
+	set_bit(NIC_STATE_SERVICE_INITED, &priv->state);
+	clear_bit(NIC_STATE_SERVICE_SCHED, &priv->state);
+	set_bit(NIC_STATE_DOWN, &priv->state);
+
+	if (hns_nic_try_get_ae(priv->netdev)) {
+		priv->notifier_block.notifier_call = hns_nic_notifier_action;
+		ret = hnae_register_notifier(&priv->notifier_block);
+		if (ret) {
+			dev_err(dev, "register notifier fail!\n");
+			goto out_notify_fail;
+		}
+		dev_dbg(dev, "has not handle, register notifier!\n");
+	}
+
+	return 0;
+
+out_notify_fail:
+	(void)cancel_work_sync(&priv->service_task);
+out_read_string_fail:
+	free_netdev(ndev);
+	return ret;
+}
+
+static int hns_nic_dev_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+
+	if (ndev->reg_state != NETREG_UNINITIALIZED)
+		unregister_netdev(ndev);
+
+	if (priv->ring_data)
+		hns_nic_uninit_ring_data(priv);
+	priv->ring_data = NULL;
+
+	if (!IS_ERR_OR_NULL(priv->ae_handle))
+		hnae_put_handle(priv->ae_handle);
+	priv->ae_handle = NULL;
+	if (priv->notifier_block.notifier_call)
+		hnae_unregister_notifier(&priv->notifier_block);
+	priv->notifier_block.notifier_call = NULL;
+
+	set_bit(NIC_STATE_REMOVING, &priv->state);
+	(void)cancel_work_sync(&priv->service_task);
+
+	free_netdev(ndev);
+	return 0;
+}
+
+static const struct of_device_id hns_enet_of_match[] = {
+	{.compatible = "hisilicon,hns-nic",},
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, hns_enet_of_match);
+
+static struct platform_driver hns_nic_dev_driver = {
+	.driver = {
+		.name = "hns-nic",
+		.owner = THIS_MODULE,
+		.of_match_table = hns_enet_of_match,
+	},
+	.probe = hns_nic_dev_probe,
+	.remove = hns_nic_dev_remove,
+};
+
+module_platform_driver(hns_nic_dev_driver);
+
+MODULE_DESCRIPTION("HISILICON HNS Ethernet driver");
+MODULE_AUTHOR("Hisilicon, Inc.");
+MODULE_LICENSE("GPL v2");
+MODULE_ALIAS("platform:hns-nic");
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.h b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
new file mode 100644
index 0000000..f632da4
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
@@ -0,0 +1,81 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __HNS_ENET_H
+#define __HNS_ENET_H
+
+#include <linux/timer.h>
+#include <linux/workqueue.h>
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
+#include <linux/netdevice.h>
+#include "hnae.h"
+
+enum hns_nic_state {
+	NIC_STATE_TESTING = 0,
+	NIC_STATE_RESETTING,
+	NIC_STATE_REINITING,
+	NIC_STATE_DOWN,
+	NIC_STATE_DISABLED,
+	NIC_STATE_REMOVING,
+	NIC_STATE_SERVICE_INITED,
+	NIC_STATE_SERVICE_SCHED,
+	NIC_STATE2_RESET_REQUESTED,
+	NIC_STATE_MAX
+};
+
+struct hns_nic_ring_data {
+	struct hnae_ring *ring;
+	struct napi_struct napi;
+	int queue_index;
+	int (*poll_one)(struct hns_nic_ring_data *, int, void *);
+	void (*ex_process)(struct hns_nic_ring_data *, struct sk_buff *);
+};
+
+struct hns_nic_priv {
+	const char *ae_name;
+	const char *ae_opts;
+	int phy_mode;
+	int phy_led_val;
+	struct phy_device *phy;
+	struct net_device *netdev;
+	struct device *dev;
+	struct hnae_handle *ae_handle;
+
+	/* the cb for nic to manage the ring buffer, the first half of the
+	 * array is for tx_ring and vice versa for the second half
+	 */
+	struct hns_nic_ring_data *ring_data;
+
+	/* The most recently read link state */
+	int link;
+	u64 tx_timeout_count;
+
+	unsigned long state;
+
+	struct timer_list service_timer;
+
+	struct work_struct service_task;
+
+	struct notifier_block notifier_block;
+};
+
+#define tx_ring_data(priv, idx) ((priv)->ring_data[idx])
+#define rx_ring_data(priv, idx) \
+	((priv)->ring_data[(priv)->ae_handle->q_num + (idx)])
+
+void hns_ethtool_set_ops(struct net_device *ndev);
+void hns_nic_net_reset(struct net_device *ndev);
+void hns_nic_net_reinit(struct net_device *netdev);
+int hns_nic_init_phy(struct net_device *ndev, struct hnae_handle *h);
+int hns_nic_net_xmit_hw(struct net_device *ndev,
+			struct sk_buff *skb,
+			struct hns_nic_ring_data *ring_data);
+
+#endif	/**__HNS_ENET_H */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
new file mode 100644
index 0000000..18f3fc5
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -0,0 +1,1174 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include "hns_enet.h"
+
+#define HNS_PHY_PAGE_REG	22
+#define HNS_PHY_PAGE_LED	3
+#define HNS_LED_FORCE_ON	9
+#define HNS_LED_FORCE_OFF	8
+#define HNS_PHY_PAGE_COPPER	0
+#define HNS_LED_FCR		16
+#define HNS_LED_PCR		17
+#define HNS_CHIP_VERSION 660
+
+#define HNS_NET_STATS_CNT 25
+
+/**
+ *hns_nic_get_link - get current link status
+ *@net_dev: net_device
+ *retuen 0 - success , negative --fail
+ */
+static u32 hns_nic_get_link(struct net_device *net_dev)
+{
+	struct hns_nic_priv *priv = netdev_priv(net_dev);
+	u32 link_stat = priv->link;
+	struct hnae_handle *h;
+
+	assert(priv && priv->ae_handle);
+	h = priv->ae_handle;
+
+	if (priv->phy) {
+		if (!genphy_update_link(priv->phy))
+			link_stat = priv->phy->link;
+		else
+			link_stat = 0;
+	}
+
+	if (h->dev && h->dev->ops && h->dev->ops->get_status)
+		link_stat = link_stat && h->dev->ops->get_status(h);
+	else
+		link_stat = 0;
+
+	return link_stat;
+}
+
+/**
+ *hns_nic_get_settings - implement ethtool get settings
+ *@net_dev: net_device
+ *@cmd: ethtool_cmd
+ *retuen 0 - success , negative --fail
+ */
+static int hns_nic_get_settings(struct net_device *net_dev,
+				struct ethtool_cmd *cmd)
+{
+	struct hns_nic_priv *priv = netdev_priv(net_dev);
+	struct hnae_handle *h;
+	u32 link_stat;
+	int ret;
+	u8 auto_neg, duplex;
+	u16 speed;
+
+	assert(priv && priv->ae_handle)
+	h = priv->ae_handle;
+
+	link_stat = hns_nic_get_link(net_dev);
+
+	if (h->dev->ops->get_info) {
+		ret = h->dev->ops->get_info(h, &auto_neg, &speed, &duplex);
+		if (ret < 0) {
+			netdev_err(net_dev,
+				   "%s get_info error!\n", __func__);
+			return -EINVAL;
+		}
+
+		cmd->autoneg = auto_neg;
+
+		if (link_stat) {
+			ethtool_cmd_speed_set(cmd, speed);
+			cmd->duplex = duplex;
+		} else {
+			ethtool_cmd_speed_set(cmd, (u32)SPEED_UNKNOWN);
+			cmd->duplex = DUPLEX_UNKNOWN;
+		}
+
+		if (auto_neg) {
+			cmd->supported |= SUPPORTED_Autoneg;
+			cmd->advertising |= ADVERTISED_Autoneg;
+			cmd->autoneg = AUTONEG_ENABLE;
+		} else {
+			cmd->autoneg = AUTONEG_DISABLE;
+		}
+	} else {
+		ethtool_cmd_speed_set(cmd, (u32)SPEED_UNKNOWN);
+		cmd->duplex = DUPLEX_UNKNOWN;
+	}
+
+	/* Phy exists, then update data from phy standard drv. */
+	if (priv->phy)
+		(void)phy_ethtool_gset(priv->phy, cmd);
+
+	if (PHY_INTERFACE_MODE_SGMII == h->phy_if) {
+		cmd->supported |= SUPPORTED_Autoneg;
+		cmd->supported |= SUPPORTED_10baseT_Half;
+		cmd->supported |= SUPPORTED_10baseT_Full;
+		cmd->supported |= SUPPORTED_100baseT_Half;
+		cmd->supported |= SUPPORTED_100baseT_Full;
+		cmd->supported |= SUPPORTED_1000baseT_Full;
+		cmd->supported |= SUPPORTED_1000baseT_Half;
+		cmd->supported |= SUPPORTED_2500baseX_Full;
+		cmd->supported |= SUPPORTED_FIBRE;
+		cmd->supported |= SUPPORTED_TP;
+
+		cmd->advertising |= ADVERTISED_1000baseT_Full;
+		cmd->advertising |= ADVERTISED_1000baseT_Half;
+
+		/* Update port type. */
+		cmd->port = PORT_TP;
+	} else if (PHY_INTERFACE_MODE_XGMII == h->phy_if) {
+		cmd->supported |= SUPPORTED_10000baseR_FEC;
+		cmd->supported |= SUPPORTED_10000baseKR_Full;
+		cmd->supported |= SUPPORTED_FIBRE;
+
+		cmd->advertising |= ADVERTISED_10000baseKR_Full;
+
+		/* Update port type. */
+		cmd->port = PORT_FIBRE;
+
+		if (link_stat) {
+			ethtool_cmd_speed_set(cmd, SPEED_10000);
+			cmd->duplex = DUPLEX_FULL;
+		}
+	}
+
+	cmd->transceiver = XCVR_EXTERNAL;
+	cmd->mdio_support = (ETH_MDIO_SUPPORTS_C45 | ETH_MDIO_SUPPORTS_C22);
+
+	return 0;
+}
+
+/**
+ *hns_nic_set_settings - implement ethtool set settings
+ *@net_dev: net_device
+ *@cmd: ethtool_cmd
+ *retuen 0 - success , negative --fail
+ */
+static int hns_nic_set_settings(struct net_device *net_dev,
+				struct ethtool_cmd *cmd)
+{
+	struct hns_nic_priv *priv       = netdev_priv(net_dev);
+	struct hnae_handle  *h;
+	int                 ret;
+
+	if (!priv || !priv->ae_handle)
+		return -ENODEV;
+
+	h = priv->ae_handle;
+
+	if (!h->dev->ops->set_info)
+		return -ENODEV;
+
+	if (!netif_running(net_dev))
+		return -ESRCH;
+
+	ret = h->dev->ops->set_info(h, cmd->autoneg, cmd->speed, cmd->duplex);
+	if (ret) {
+		netdev_err(net_dev,
+			   "set settings error!\n");
+		return ret;
+	}
+
+	if (priv->phy) {
+		(void)phy_ethtool_sset(priv->phy, cmd);
+		return 0;
+	}
+
+	/* Adjust the current link if link up. */
+	if (h->dev->ops->adjust_link && hns_nic_get_link(net_dev))
+		h->dev->ops->adjust_link(h, cmd->speed, cmd->duplex);
+	else
+		netdev_err(net_dev, "%s: not support setting!\n", __func__);
+
+	return 0;
+}
+
+static const char hns_nic_test_strs[][ETH_GSTRING_LEN] = {
+	"Mac    Loopback test",
+	"Serdes Loopback test",
+	"Phy    Loopback test"
+};
+
+static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
+{
+#define COPPER_CONTROL_REG 0
+#define PHY_LOOP_BACK BIT(14)
+	u16 val = 0;
+
+	if (phy_dev->is_c45) /* c45 branch adding for XGE PHY */
+		return -ENOTSUPP;
+
+	if (en) {
+		/* speed : 1000M */
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    HNS_PHY_PAGE_REG, 2);
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    21, 0x1046);
+		/* Force Master */
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    9, 0x1F00);
+		/* Soft-reset */
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    0, 0x9140);
+		/* If autoneg disabled,two soft-reset operations */
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    0, 0x9140);
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    22, 0xFA);
+
+		/* Default is 0x0400 */
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    1, 0x418);
+
+		/* Force 1000M Link, Default is 0x0200 */
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    7, 0x20C);
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    22, 0);
+
+		/* Enable MAC loop-back */
+		val = (u16)mdiobus_read(phy_dev->bus, phy_dev->addr,
+					COPPER_CONTROL_REG);
+		val |= PHY_LOOP_BACK;
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    COPPER_CONTROL_REG, val);
+	} else {
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    22, 0xFA);
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    1, 0x400);
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    7, 0x200);
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    22, 0);
+
+		val = (u16)mdiobus_read(phy_dev->bus, phy_dev->addr,
+					COPPER_CONTROL_REG);
+		val &= ~PHY_LOOP_BACK;
+		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
+				    COPPER_CONTROL_REG, val);
+	}
+	return 0;
+}
+
+static int __lb_setup(struct net_device *ndev,
+		      enum hnae_loop loop)
+{
+	int ret = -ENOTSUPP;
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct phy_device *phy_dev = priv->phy;
+	struct hnae_handle *h = priv->ae_handle;
+
+	switch (loop) {
+	case MAC_INTERNALLOOP_PHY:
+		if (phy_dev)
+			ret = hns_nic_config_phy_loopback(phy_dev, 0x1);
+		break;
+	case MAC_INTERNALLOOP_MAC:
+	case MAC_INTERNALLOOP_SERDES:
+		if (h->dev->ops->set_loopback)
+			ret = h->dev->ops->set_loopback(h, loop, 0x1);
+		break;
+	case MAC_LOOP_NONE:
+		if (phy_dev)
+			ret = hns_nic_config_phy_loopback(phy_dev, 0x0);
+
+		if (h->dev->ops->set_loopback) {
+			ret |= h->dev->ops->set_loopback(h,
+				MAC_INTERNALLOOP_MAC, 0x0);
+			ret |= h->dev->ops->set_loopback(h,
+				MAC_INTERNALLOOP_SERDES, 0x0);
+		}
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
+static int __lb_up(struct net_device *ndev,
+		   enum hnae_loop loop_mode)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h = priv->ae_handle;
+	int speed, duplex;
+	int ret;
+
+	hns_nic_net_reset(ndev);
+
+	if (h->phy_node) {
+		ret = hns_nic_init_phy(ndev, h);
+		if (ret)
+			return ret;
+	}
+
+	ret = __lb_setup(ndev, loop_mode);
+	if (ret)
+		return ret;
+	msleep(100);
+
+	ret = h->dev->ops->start ? h->dev->ops->start(h) : 0;
+	if (ret)
+		return ret;
+
+	if (priv->phy)
+		phy_start(priv->phy);
+
+	/* link adjust duplex*/
+	if (priv->ae_handle->phy_if != PHY_INTERFACE_MODE_XGMII)
+		speed = 1000;
+	else
+		speed = 10000;
+	duplex = 1;
+
+	h->dev->ops->adjust_link(h, speed, duplex);
+
+	return 0;
+}
+
+static void __lb_other_process(struct hns_nic_ring_data *ring_data,
+			       struct sk_buff *skb)
+{
+	struct net_device *ndev;
+	struct hnae_ring *ring;
+	struct netdev_queue *dev_queue;
+	struct sk_buff *new_skb;
+	unsigned int frame_size;
+	int check_ok;
+	u32 i;
+	char buff[33]; /* 32B data and the last character '\0' */
+
+	if (!ring_data) { /* Just for doing create frame*/
+		frame_size = skb->len;
+		memset(skb->data, 0xFF, frame_size);
+		frame_size &= ~1ul;
+		memset(&skb->data[frame_size / 2], 0xAA, frame_size / 2 - 1);
+		memset(&skb->data[frame_size / 2 + 10], 0xBE,
+		       frame_size / 2 - 11);
+		memset(&skb->data[frame_size / 2 + 12], 0xAF,
+		       frame_size / 2 - 13);
+		return;
+	}
+
+	ring = ring_data->ring;
+	ndev = ring_data->napi.dev;
+	if (is_tx_ring(ring)) { /* for tx queue reset*/
+		dev_queue = netdev_get_tx_queue(ndev, ring_data->queue_index);
+		netdev_tx_reset_queue(dev_queue);
+		return;
+	}
+
+	frame_size = skb->len;
+	frame_size &= ~1ul;
+	/* for mutl buffer*/
+	new_skb = skb_copy(skb, GFP_ATOMIC);
+	dev_kfree_skb_any(skb);
+	skb = new_skb;
+
+	check_ok = 0;
+	if (*(skb->data + 10) == 0xFF) { /* for rx check frame*/
+		if ((*(skb->data + frame_size / 2 + 10) == 0xBE) &&
+		    (*(skb->data + frame_size / 2 + 12) == 0xAF))
+			check_ok = 1;
+	}
+
+	if (check_ok) {
+		ndev->stats.rx_packets++;
+		ndev->stats.rx_bytes += skb->len;
+	} else {
+		ndev->stats.rx_frame_errors++;
+		for (i = 0; i < skb->len; i++) {
+			snprintf(buff + i % 16 * 2, 3, /* tailing \0*/
+				 "%02x", *(skb->data + i));
+			if ((i % 16 == 15) || (i == skb->len - 1))
+				pr_info("%s\n", buff);
+		}
+	}
+	dev_kfree_skb_any(skb);
+}
+
+static int __lb_clean_rings(struct hns_nic_priv *priv,
+			    int ringid0, int ringid1, int budget)
+{
+	int i, ret;
+	struct hns_nic_ring_data *ring_data;
+	struct net_device *ndev = priv->netdev;
+	unsigned long rx_packets = ndev->stats.rx_packets;
+	unsigned long rx_bytes = ndev->stats.rx_bytes;
+	unsigned long rx_frame_errors = ndev->stats.rx_frame_errors;
+
+	for (i = ringid0; i <= ringid1; i++) {
+		ring_data = &priv->ring_data[i];
+		(void)ring_data->poll_one(ring_data,
+					  budget, __lb_other_process);
+	}
+	ret = (int)(ndev->stats.rx_packets - rx_packets);
+	ndev->stats.rx_packets = rx_packets;
+	ndev->stats.rx_bytes = rx_bytes;
+	ndev->stats.rx_frame_errors = rx_frame_errors;
+	return ret;
+}
+
+static const char * const pr_test[] = {
+	"none",
+	"mac",
+	"serdes",
+	"phy",
+	NULL};
+
+/**
+ * nic_run_loopback_test -  run loopback test
+ * @nic_dev: net device
+ * @loopback_type: loopback type
+ */
+static int __lb_run_test(struct net_device *ndev,
+			 enum hnae_loop loop_mode)
+{
+#define NIC_LB_TEST_PKT_NUM_PER_CYCLE 1
+#define NIC_LB_TEST_RING_ID 0
+#define NIC_LB_TEST_FRAME_SIZE 128
+/* nic loopback test err  */
+#define NIC_LB_TEST_NO_MEM_ERR 1
+#define NIC_LB_TEST_TX_CNT_ERR 2
+#define NIC_LB_TEST_RX_CNT_ERR 3
+#define NIC_LB_TEST_RX_PKG_ERR 4
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h = priv->ae_handle;
+	int i, j, lc, good_cnt, ret_val = 0;
+	unsigned int size;
+	netdev_tx_t tx_ret_val;
+	struct sk_buff *skb;
+
+	size = NIC_LB_TEST_FRAME_SIZE;
+	/* allocate test skb */
+	skb = alloc_skb(size, GFP_KERNEL);
+	if (!skb)
+		return NIC_LB_TEST_NO_MEM_ERR;
+
+	/* place data into test skb */
+	(void)skb_put(skb, size);
+	__lb_other_process(NULL, skb);
+	skb->queue_mapping = NIC_LB_TEST_RING_ID;
+
+	lc = 1;
+	for (j = 0; j < lc; j++) {
+		/* reset count of good packets */
+		good_cnt = 0;
+		/* place 64 packets on the transmit queue*/
+		for (i = 0; i < NIC_LB_TEST_PKT_NUM_PER_CYCLE; i++) {
+			(void)skb_get(skb);
+
+			tx_ret_val = (netdev_tx_t)hns_nic_net_xmit_hw(
+				ndev, skb,
+				&tx_ring_data(priv, skb->queue_mapping));
+			if (tx_ret_val == NETDEV_TX_OK)
+				good_cnt++;
+			else
+				break;
+		}
+		if (good_cnt != NIC_LB_TEST_PKT_NUM_PER_CYCLE) {
+			ret_val = NIC_LB_TEST_TX_CNT_ERR;
+			dev_err(priv->dev, "%s lb test sent fail, cnt=0x%x, budget=0x%x\n",
+				pr_test[loop_mode], good_cnt,
+				NIC_LB_TEST_PKT_NUM_PER_CYCLE);
+			break;
+		}
+
+		/* allow 100 milliseconds for packets to go from Tx to Rx */
+		msleep(100);
+
+		good_cnt = __lb_clean_rings(priv,
+					    h->q_num, h->q_num * 2 - 1,
+					    NIC_LB_TEST_PKT_NUM_PER_CYCLE);
+		if (good_cnt != NIC_LB_TEST_PKT_NUM_PER_CYCLE) {
+			ret_val = NIC_LB_TEST_RX_CNT_ERR;
+			dev_err(priv->dev, "%s lb test recv fail, cnt=0x%x, budget=0x%x\n",
+				pr_test[loop_mode], good_cnt,
+				NIC_LB_TEST_PKT_NUM_PER_CYCLE);
+			break;
+		}
+		(void)__lb_clean_rings(priv,
+				       NIC_LB_TEST_RING_ID, NIC_LB_TEST_RING_ID,
+				       NIC_LB_TEST_PKT_NUM_PER_CYCLE);
+	}
+
+	/* free the original skb */
+	kfree_skb(skb);
+
+	return ret_val;
+}
+
+static int __lb_down(struct net_device *ndev)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h = priv->ae_handle;
+	int ret;
+
+	ret = __lb_setup(ndev, MAC_LOOP_NONE);
+	if ((ret) && (ret != -ENOTSUPP))
+		netdev_err(ndev, "%s: __lb_setup return error(%d)!\n",
+			   __func__,
+			   ret);
+
+	if (priv->phy) {
+		phy_stop(priv->phy);
+		phy_disconnect(priv->phy);
+	}
+
+	if (h->dev->ops->stop)
+		h->dev->ops->stop(h);
+
+	usleep_range(10000, 20000);
+	(void)__lb_clean_rings(priv, 0, h->q_num - 1, 256);
+
+	hns_nic_net_reset(ndev);
+
+	return 0;
+}
+
+/**
+ * hns_nic_self_test - self test
+ * @dev: net device
+ * @eth_test: test cmd
+ * @data: test result
+ */
+static void hns_nic_self_test(struct net_device *ndev,
+			      struct ethtool_test *eth_test, u64 *data)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	bool if_running = netif_running(ndev);
+#define SELF_TEST_TPYE_NUM 3
+	int st_param[SELF_TEST_TPYE_NUM][2];
+	int i;
+
+	set_bit(NIC_STATE_TESTING, &priv->state);
+
+	data[0] = ENOTSUPP;
+	data[1] = ENOTSUPP;
+	data[2] = ENOTSUPP;
+
+	st_param[0][0] = MAC_INTERNALLOOP_MAC; /* XGE not supported lb */
+	st_param[0][1] = (priv->ae_handle->phy_if != PHY_INTERFACE_MODE_XGMII);
+	st_param[1][0] = MAC_INTERNALLOOP_SERDES;
+	st_param[1][1] = 1; /*serdes must exist*/
+	st_param[2][0] = MAC_INTERNALLOOP_PHY; /* only supporte phy node*/
+	st_param[2][1] = !!(priv->ae_handle->phy_node);
+
+	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
+		if (if_running)
+			(void)dev_close(ndev);
+
+		for (i = 0; i < SELF_TEST_TPYE_NUM; i++) {
+			if (!st_param[i][1])
+				continue;	/* NEXT testing */
+
+			data[i] = __lb_up(ndev, (enum hnae_loop)st_param[i][0]);
+			if (!data[i]) {
+				data[i] = __lb_run_test(
+					ndev, (enum hnae_loop)st_param[i][0]);
+				(void)__lb_down(ndev);
+			}
+			if (data[i])
+				eth_test->flags |= ETH_TEST_FL_FAILED;
+		}
+
+		hns_nic_net_reset(priv->netdev);
+
+		if (if_running)
+			(void)dev_open(ndev);
+	}
+	/* Online tests aren't run; pass by default */
+
+	clear_bit(NIC_STATE_TESTING, &priv->state);
+
+	(void)msleep_interruptible(4 * 1000);
+}
+
+/**
+ * hns_nic_get_drvinfo - get net driver info
+ * @dev: net device
+ * @drvinfo: driver info
+ */
+static void hns_nic_get_drvinfo(struct net_device *net_dev,
+				struct ethtool_drvinfo *drvinfo)
+{
+	struct hns_nic_priv *priv = netdev_priv(net_dev);
+
+	assert(priv);
+
+	strncpy(drvinfo->version, HNAE_DRIVER_VERSION,
+		sizeof(drvinfo->version));
+	drvinfo->version[sizeof(drvinfo->version) - 1] = '\0';
+
+	strncpy(drvinfo->driver, HNAE_DRIVER_NAME, sizeof(drvinfo->driver));
+	drvinfo->driver[sizeof(drvinfo->driver) - 1] = '\0';
+
+	strncpy(drvinfo->bus_info, priv->dev->bus->name,
+		sizeof(drvinfo->bus_info));
+	drvinfo->bus_info[ETHTOOL_BUSINFO_LEN - 1] = '\0';
+
+	strncpy(drvinfo->fw_version, "N/A", ETHTOOL_FWVERS_LEN);
+	drvinfo->eedump_len = 0;
+}
+
+/**
+ * hns_get_ringparam - get ring parameter
+ * @dev: net device
+ * @param: ethtool parameter
+ */
+void hns_get_ringparam(struct net_device *net_dev,
+		       struct ethtool_ringparam *param)
+{
+	struct hns_nic_priv *priv = netdev_priv(net_dev);
+	struct hnae_ae_ops *ops;
+	struct hnae_queue *queue;
+	u32 uplimit = 0, lowlimit = 0;
+
+	queue = priv->ae_handle->qs[0];
+	ops = priv->ae_handle->dev->ops;
+
+	param->rx_max_pending = priv->ae_handle->q_num;
+	param->tx_max_pending = priv->ae_handle->q_num;
+
+	param->rx_mini_pending = priv->ae_handle->q_num;
+	param->rx_jumbo_pending = priv->ae_handle->q_num;
+	param->rx_pending = queue->rx_ring.desc_num;
+	param->tx_pending = queue->tx_ring.desc_num;
+
+	if (ops->get_ring_bdnum_limit)
+		ops->get_ring_bdnum_limit(queue, &uplimit, &lowlimit);
+
+	param->rx_mini_max_pending = lowlimit;
+	param->rx_jumbo_max_pending = uplimit;
+}
+
+/**
+ * hns_get_pauseparam - get pause parameter
+ * @dev: net device
+ * @param: pause parameter
+ */
+static void hns_get_pauseparam(struct net_device *net_dev,
+			       struct ethtool_pauseparam *param)
+{
+	struct hns_nic_priv *priv = netdev_priv(net_dev);
+	struct hnae_ae_ops *ops;
+
+	ops = priv->ae_handle->dev->ops;
+
+	if (ops->get_pauseparam)
+		ops->get_pauseparam(priv->ae_handle, &param->autoneg,
+					    &param->rx_pause, &param->tx_pause);
+}
+
+/**
+ * hns_set_pauseparam - set pause parameter
+ * @dev: net device
+ * @param: pause parameter
+ *
+ * Return 0 on success, negative on failure
+ */
+static int hns_set_pauseparam(struct net_device *net_dev,
+			      struct ethtool_pauseparam *param)
+{
+	struct hns_nic_priv *priv = netdev_priv(net_dev);
+	struct hnae_ae_ops *ops;
+
+	assert(priv || priv->ae_handle);
+
+	ops = priv->ae_handle->dev->ops;
+
+	if ((priv->ae_handle->phy_node) && (ops->set_autoneg))
+		(void)ops->set_autoneg(priv->ae_handle, param->autoneg);
+
+	if (!ops->set_pauseparam)
+		return -ESRCH;
+
+	ops->set_pauseparam(priv->ae_handle,
+				    param->rx_pause,
+				    param->tx_pause);
+
+	return 0;
+}
+
+/**
+ * hns_get_coalesce - get coalesce info.
+ * @dev: net device
+ * @ec: coalesce info.
+ *
+ * Return 0 on success, negative on failure.
+ */
+static int hns_get_coalesce(struct net_device *net_dev,
+			    struct ethtool_coalesce *ec)
+{
+	struct hns_nic_priv *priv = netdev_priv(net_dev);
+	struct hnae_ae_ops *ops;
+
+	ops = priv->ae_handle->dev->ops;
+
+	ec->use_adaptive_rx_coalesce = 1;
+	ec->use_adaptive_tx_coalesce = 1;
+
+	if ((!ops->get_coalesce_usecs) ||
+	    (!ops->get_rx_max_coalesced_frames))
+		return -ESRCH;
+
+	ops->get_coalesce_usecs(priv->ae_handle,
+					&ec->tx_coalesce_usecs,
+					&ec->rx_coalesce_usecs);
+
+	ops->get_rx_max_coalesced_frames(
+		priv->ae_handle,
+		&ec->tx_max_coalesced_frames,
+		&ec->rx_max_coalesced_frames);
+
+	return 0;
+}
+
+/**
+ * hns_set_coalesce - set coalesce info.
+ * @dev: net device
+ * @ec: coalesce info.
+ *
+ * Return 0 on success, negative on failure.
+ */
+static int hns_set_coalesce(struct net_device *net_dev,
+			    struct ethtool_coalesce *ec)
+{
+	struct hns_nic_priv *priv = netdev_priv(net_dev);
+	struct hnae_ae_ops *ops;
+	int ret;
+
+	assert(priv || priv->ae_handle);
+
+	ops = priv->ae_handle->dev->ops;
+
+	if (ec->tx_coalesce_usecs != ec->rx_coalesce_usecs)
+		return -EINVAL;
+
+	if (ec->rx_max_coalesced_frames != ec->tx_max_coalesced_frames)
+		return -EINVAL;
+
+	if ((!ops->set_coalesce_usecs) ||
+	    (!ops->set_coalesce_frames))
+		return -ESRCH;
+
+	ops->set_coalesce_usecs(priv->ae_handle,
+					ec->rx_coalesce_usecs);
+
+	ret = ops->set_coalesce_frames(
+		priv->ae_handle,
+		ec->rx_max_coalesced_frames);
+
+	return ret;
+}
+
+/**
+ * hns_get_channels - get channel info.
+ * @dev: net device
+ * @ch: channel info.
+ */
+void hns_get_channels(struct net_device *net_dev, struct ethtool_channels *ch)
+{
+	struct hns_nic_priv *priv = netdev_priv(net_dev);
+	struct hnae_ae_ops *ops;
+	u32 max_ring_pair_num, ring_pair_num;
+
+	assert(priv || priv->ae_handle);
+
+	ops = priv->ae_handle->dev->ops;
+
+	if (!ops->get_max_ringnum) {
+		netdev_err(net_dev, "don't support get max ringnum\n");
+		return;
+	}
+
+	ops->get_max_ringnum(priv->ae_handle, &max_ring_pair_num);
+
+	ch->max_rx = max_ring_pair_num;
+	ch->max_tx = max_ring_pair_num;
+	ch->max_combined = max_ring_pair_num;
+	ch->max_other = max_ring_pair_num;
+
+	if (!ops->get_ringnum) {
+		netdev_err(net_dev, "don't support get current ringnum\n");
+		return;
+	}
+
+	ops->get_ringnum(priv->ae_handle, &ring_pair_num);
+
+	ch->rx_count = ring_pair_num;
+	ch->tx_count = ring_pair_num;
+	ch->combined_count = ring_pair_num;
+	ch->other_count = ring_pair_num;
+}
+
+/**
+ * get_ethtool_stats - get detail statistics.
+ * @dev: net device
+ * @stats: statistics info.
+ * @data: statistics data.
+ */
+void hns_get_ethtool_stats(struct net_device *netdev,
+			   struct ethtool_stats *stats, u64 *data)
+{
+	u64 *p = data;
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_handle *h = priv->ae_handle;
+	const struct rtnl_link_stats64 *net_stats;
+	struct rtnl_link_stats64 temp;
+
+	if (!h->dev->ops->get_stats || !h->dev->ops->update_stats) {
+		netdev_err(netdev, "get_stats or update_stats is null!\n");
+		return;
+	}
+
+	h->dev->ops->update_stats(h, &netdev->stats);
+
+	net_stats = dev_get_stats(netdev, &temp);
+
+	/* get netdev statistics */
+	p[0] = net_stats->rx_packets;
+	p[1] = net_stats->tx_packets;
+	p[2] = net_stats->rx_bytes;
+	p[3] = net_stats->tx_bytes;
+	p[4] = net_stats->rx_errors;
+	p[5] = net_stats->tx_errors;
+	p[6] = net_stats->rx_dropped;
+	p[7] = net_stats->tx_dropped;
+	p[8] = net_stats->multicast;
+	p[9] = net_stats->collisions;
+	p[10] = net_stats->rx_over_errors;
+	p[11] = net_stats->rx_crc_errors;
+	p[12] = net_stats->rx_frame_errors;
+	p[13] = net_stats->rx_fifo_errors;
+	p[14] = net_stats->rx_missed_errors;
+	p[15] = net_stats->tx_aborted_errors;
+	p[16] = net_stats->tx_carrier_errors;
+	p[17] = net_stats->tx_fifo_errors;
+	p[18] = net_stats->tx_heartbeat_errors;
+	p[19] = net_stats->rx_length_errors;
+	p[20] = net_stats->tx_window_errors;
+	p[21] = net_stats->rx_compressed;
+	p[22] = net_stats->tx_compressed;
+
+	p[23] = (u64)netdev->rx_dropped.counter;
+	p[24] = (u64)netdev->tx_dropped.counter;
+
+	/* get driver statistics */
+	h->dev->ops->get_stats(h, &p[25]);
+}
+
+/**
+ * get_strings: Return a set of strings that describe the requested objects
+ * @dev: net device
+ * @stats: string set ID.
+ * @data: objects data.
+ */
+void hns_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_handle *h = priv->ae_handle;
+	char *buff = (char *)data;
+
+	if (!h->dev->ops->get_strings) {
+		netdev_err(netdev, "h->dev->ops->get_strings is null!\n");
+		return;
+	}
+	if (stringset == ETH_SS_TEST) {
+		memcpy(data, *hns_nic_test_strs, sizeof(hns_nic_test_strs));
+		}
+	else {
+		snprintf(buff, ETH_GSTRING_LEN, "rx_packets");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "tx_packets");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "rx_bytes");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "tx_bytes");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "rx_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "tx_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "rx_dropped");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "tx_dropped");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "multicast");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "collisions");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "rx_over_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "rx_crc_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "rx_frame_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "tx_carrier_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "rx_fifo_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "rx_missed_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "tx_aborted_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "tx_carrier_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "tx_fifo_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "tx_heartbeat_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "tx_window_errors");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "rx_compressed");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "tx_compressed");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "netdev_rx_dropped");
+		buff = buff + ETH_GSTRING_LEN;
+		snprintf(buff, ETH_GSTRING_LEN, "netdev_tx_dropped");
+		buff = buff + ETH_GSTRING_LEN;
+
+		h->dev->ops->get_strings(h, stringset, buff);
+	}
+}
+
+/**
+ * nic_get_sset_count - get string set count witch returned by nic_get_strings.
+ * @dev: net device
+ * @stringset: string set index, 0: self test string; 1: statistics string.
+ *
+ * Return string set count.
+ */
+int hns_get_sset_count(struct net_device *netdev, int stringset)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_handle *h = priv->ae_handle;
+	struct hnae_ae_ops *ops = h->dev->ops;
+
+	if (!ops->get_sset_count) {
+		netdev_err(netdev, "get_sset_count is null!\n");
+		return -EOPNOTSUPP;
+	}
+	if (stringset == ETH_SS_TEST)
+		return (sizeof(hns_nic_test_strs) / ETH_GSTRING_LEN);
+	else
+		return (HNS_NET_STATS_CNT + ops->get_sset_count(h, stringset));
+}
+
+/**
+ * hns_phy_led_set - set phy LED status.
+ * @dev: net device
+ * @value: LED state.
+ *
+ * Return 0 on success, negative on failure.
+ */
+int hns_phy_led_set(struct net_device *netdev, int value)
+{
+	int retval;
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct phy_device *phy_dev = priv->phy;
+
+	if (!phy_dev->bus) {
+		netdev_err(netdev, "phy_dev->bus is null!\n");
+		return -EINVAL;
+	}
+	retval = mdiobus_write(phy_dev->bus, phy_dev->addr,
+			       HNS_PHY_PAGE_REG, HNS_PHY_PAGE_LED);
+	retval = mdiobus_write(phy_dev->bus, phy_dev->addr, HNS_LED_FCR, value);
+	retval = mdiobus_write(phy_dev->bus, phy_dev->addr,
+			       HNS_PHY_PAGE_REG, HNS_PHY_PAGE_COPPER);
+	if (retval) {
+		netdev_err(netdev, "mdiobus_write fail !\n");
+		return retval;
+	}
+	return 0;
+}
+
+/**
+ * nic_set_phys_id - set phy identify LED.
+ * @dev: net device
+ * @state: LED state.
+ *
+ * Return 0 on success, negative on failure.
+ */
+int hns_set_phys_id(struct net_device *netdev, enum ethtool_phys_id_state state)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_handle *h = priv->ae_handle;
+	struct phy_device *phy_dev = priv->phy;
+	int ret;
+
+	if (phy_dev)
+		switch (state) {
+		case ETHTOOL_ID_ACTIVE:
+			ret = mdiobus_write(phy_dev->bus, phy_dev->addr,
+					    HNS_PHY_PAGE_REG,
+					    HNS_PHY_PAGE_LED);
+			if (ret)
+				return ret;
+
+			priv->phy_led_val = (u16)mdiobus_read(phy_dev->bus,
+							      phy_dev->addr,
+							      HNS_LED_FCR);
+
+			ret = mdiobus_write(phy_dev->bus, phy_dev->addr,
+					    HNS_PHY_PAGE_REG,
+					    HNS_PHY_PAGE_COPPER);
+			if (ret)
+				return ret;
+			return 2;
+		case ETHTOOL_ID_ON:
+			ret = hns_phy_led_set(netdev, HNS_LED_FORCE_ON);
+			if (ret)
+				return ret;
+			break;
+		case ETHTOOL_ID_OFF:
+			ret = hns_phy_led_set(netdev, HNS_LED_FORCE_OFF);
+			if (ret)
+				return ret;
+			break;
+		case ETHTOOL_ID_INACTIVE:
+			ret = mdiobus_write(phy_dev->bus, phy_dev->addr,
+					    HNS_PHY_PAGE_REG,
+					    HNS_PHY_PAGE_LED);
+			if (ret)
+				return ret;
+
+			ret = mdiobus_write(phy_dev->bus, phy_dev->addr,
+					    HNS_LED_FCR, priv->phy_led_val);
+			if (ret)
+				return ret;
+
+			ret = mdiobus_write(phy_dev->bus, phy_dev->addr,
+					    HNS_PHY_PAGE_REG,
+					    HNS_PHY_PAGE_COPPER);
+			if (ret)
+				return ret;
+			break;
+		default:
+			return -EINVAL;
+		}
+	else
+		switch (state) {
+		case ETHTOOL_ID_ACTIVE:
+			return h->dev->ops->set_led_id(h, HNAE_LED_ACTIVE);
+		case ETHTOOL_ID_ON:
+			return h->dev->ops->set_led_id(h, HNAE_LED_ON);
+		case ETHTOOL_ID_OFF:
+			return h->dev->ops->set_led_id(h, HNAE_LED_OFF);
+		case ETHTOOL_ID_INACTIVE:
+			return h->dev->ops->set_led_id(h, HNAE_LED_INACTIVE);
+		default:
+			return -EINVAL;
+		}
+
+	return 0;
+}
+
+/**
+ * hns_get_regs - get net device register
+ * @dev: net device
+ * @cmd: ethtool cmd
+ * @date: register data
+ */
+void hns_get_regs(struct net_device *net_dev, struct ethtool_regs *cmd,
+		  void *data)
+{
+	struct hns_nic_priv *priv = netdev_priv(net_dev);
+	struct hnae_ae_ops *ops;
+
+	assert(priv || priv->ae_handle);
+
+	ops = priv->ae_handle->dev->ops;
+
+	cmd->version = HNS_CHIP_VERSION;
+	if (!ops->get_regs) {
+		netdev_err(net_dev, "ops->get_regs is null!\n");
+		return;
+	}
+	ops->get_regs(priv->ae_handle, data);
+}
+
+/**
+ * nic_get_regs_len - get total register len.
+ * @dev: net device
+ *
+ * Return total register len.
+ */
+static int hns_get_regs_len(struct net_device *net_dev)
+{
+	u32 reg_num;
+	struct hns_nic_priv *priv = netdev_priv(net_dev);
+	struct hnae_ae_ops *ops;
+
+	assert(priv || priv->ae_handle);
+
+	ops = priv->ae_handle->dev->ops;
+	if (!ops->get_regs_len) {
+		netdev_err(net_dev, "ops->get_regs_len is null!\n");
+		return -EOPNOTSUPP;
+	}
+
+	reg_num = ops->get_regs_len(priv->ae_handle);
+	if (reg_num > 0)
+		return reg_num * sizeof(u32);
+	else
+		return reg_num;	/* error code */
+}
+
+/**
+ * hns_nic_nway_reset - nway reset
+ * @dev: net device
+ *
+ * Return 0 on success, negative on failure
+ */
+static int hns_nic_nway_reset(struct net_device *netdev)
+{
+	int ret = 0;
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct phy_device *phy_dev = priv->phy;
+
+	if (netif_running(netdev)) {
+		hns_nic_net_reinit(netdev);
+		if (phy_dev)
+			ret = phy_start_aneg(phy_dev);
+	}
+	return ret;
+}
+
+static struct ethtool_ops hns_ethtool_ops = {
+	.get_drvinfo = hns_nic_get_drvinfo,
+	.get_link  = hns_nic_get_link,
+	.get_settings  = hns_nic_get_settings,
+	.set_settings  = hns_nic_set_settings,
+	.get_ringparam = hns_get_ringparam,
+	.get_pauseparam = hns_get_pauseparam,
+	.set_pauseparam = hns_set_pauseparam,
+	.get_coalesce = hns_get_coalesce,
+	.set_coalesce = hns_set_coalesce,
+	.get_channels = hns_get_channels,
+	.self_test = hns_nic_self_test,
+	.get_strings = hns_get_strings,
+	.get_sset_count = hns_get_sset_count,
+	.get_ethtool_stats = hns_get_ethtool_stats,
+	.set_phys_id = hns_set_phys_id,
+	.get_regs_len = hns_get_regs_len,
+	.get_regs = hns_get_regs,
+	.nway_reset = hns_nic_nway_reset,
+};
+
+void hns_ethtool_set_ops(struct net_device *ndev)
+{
+	ndev->ethtool_ops = &hns_ethtool_ops;
+}
-- 
1.9.1
