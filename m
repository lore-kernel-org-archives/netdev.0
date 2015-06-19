From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [net-next] vmxnet3: Changes for vmxnet3 adapter version 2 (fwd)
Date: Fri, 19 Jun 2015 13:38:29 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1506191337150.12845@promg-1n-a-dhcp378.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pv-drivers@vmware.com, rachel_lunnon@stormagic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:48747 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754154AbbFSUhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 16:37:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Make the driver understand adapter version 2.

Cc: Rachel Lunnon <rachel_lunnon@stormagic.com>
Signed-off-by: Guolin Yang <gyang@vmware.com>
Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
--

diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index 3718d02..221a530 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -1,7 +1,7 @@
 /*
  * Linux driver for VMware's vmxnet3 ethernet NIC.
  *
- * Copyright (C) 2008-2009, VMware, Inc. All Rights Reserved.
+ * Copyright (C) 2008-2015, VMware, Inc. All Rights Reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the
@@ -277,6 +277,40 @@ struct Vmxnet3_RxCompDesc {
 #endif  /* __BIG_ENDIAN_BITFIELD */
 };
 
+struct Vmxnet3_RxCompDescExt {
+	__le32		dword1;
+	u8		segCnt;       /* Number of aggregated packets */
+	u8		dupAckCnt;    /* Number of duplicate Acks */
+	__le16		tsDelta;      /* TCP timestamp difference */
+	__le32		dword2;
+#ifdef __BIG_ENDIAN_BITFIELD
+	u32		gen:1;        /* generation bit */
+	u32		type:7;       /* completion type */
+	u32		fcs:1;        /* Frame CRC correct */
+	u32		frg:1;        /* IP Fragment */
+	u32		v4:1;         /* IPv4 */
+	u32		v6:1;         /* IPv6 */
+	u32		ipc:1;        /* IP Checksum Correct */
+	u32		tcp:1;        /* TCP packet */
+	u32		udp:1;        /* UDP packet */
+	u32		tuc:1;        /* TCP/UDP Checksum Correct */
+	u32		mss:16;
+#else
+	u32		mss:16;
+	u32		tuc:1;        /* TCP/UDP Checksum Correct */
+	u32		udp:1;        /* UDP packet */
+	u32		tcp:1;        /* TCP packet */
+	u32		ipc:1;        /* IP Checksum Correct */
+	u32		v6:1;         /* IPv6 */
+	u32		v4:1;         /* IPv4 */
+	u32		frg:1;        /* IP Fragment */
+	u32		fcs:1;        /* Frame CRC correct */
+	u32		type:7;       /* completion type */
+	u32		gen:1;        /* generation bit */
+#endif  /* __BIG_ENDIAN_BITFIELD */
+};
+
+
 /* fields in RxCompDesc we access via Vmxnet3_GenericDesc.dword[3] */
 #define VMXNET3_RCD_TUC_SHIFT	16
 #define VMXNET3_RCD_IPC_SHIFT	19
@@ -310,6 +344,7 @@ union Vmxnet3_GenericDesc {
 	struct Vmxnet3_RxDesc		rxd;
 	struct Vmxnet3_TxCompDesc	tcd;
 	struct Vmxnet3_RxCompDesc	rcd;
+	struct Vmxnet3_RxCompDescExt 	rcdExt;
 };
 
 #define VMXNET3_INIT_GEN       1
@@ -361,6 +396,7 @@ enum {
 /* completion descriptor types */
 #define VMXNET3_CDTYPE_TXCOMP      0    /* Tx Completion Descriptor */
 #define VMXNET3_CDTYPE_RXCOMP      3    /* Rx Completion Descriptor */
+#define VMXNET3_CDTYPE_RXCOMP_LRO  4    /* Rx Completion Descriptor for LRO */
 
 enum {
 	VMXNET3_GOS_BITS_UNK    = 0,   /* unknown */
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index ab53975..da11bb5 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1163,6 +1163,52 @@ vmxnet3_rx_error(struct vmxnet3_rx_queue *rq, struct Vmxnet3_RxCompDesc *rcd,
 }
 
 
+static u32
+vmxnet3_get_hdr_len(struct vmxnet3_adapter *adapter, struct sk_buff *skb,
+		    union Vmxnet3_GenericDesc *gdesc)
+{
+	u32 hlen, maplen;
+	union {
+		void *ptr;
+		struct ethhdr *eth;
+		struct iphdr *ipv4;
+		struct ipv6hdr *ipv6;
+		struct tcphdr *tcp;
+	} hdr;
+	BUG_ON(gdesc->rcd.tcp == 0);
+
+	maplen = skb_headlen(skb);
+	if (unlikely(sizeof(struct iphdr) + sizeof(struct tcphdr) > maplen))
+		return 0;
+
+	hdr.eth = eth_hdr(skb);
+	if (gdesc->rcd.v4) {
+		BUG_ON(hdr.eth->h_proto != htons(ETH_P_IP));
+		hdr.ptr += sizeof(struct ethhdr);
+		BUG_ON(hdr.ipv4->protocol != IPPROTO_TCP);
+		hlen = hdr.ipv4->ihl << 2;
+		hdr.ptr += hdr.ipv4->ihl << 2;
+	} else if (gdesc->rcd.v6) {
+		BUG_ON(hdr.eth->h_proto != htons(ETH_P_IPV6));
+		hdr.ptr += sizeof(struct ethhdr);
+		/* Use an estimated value, since we also need to handle
+		 * TSO case.
+		 */
+		if (hdr.ipv6->nexthdr != IPPROTO_TCP)
+			return sizeof(struct ipv6hdr) + sizeof(struct tcphdr);
+		hlen = sizeof(struct ipv6hdr);
+		hdr.ptr += sizeof(struct ipv6hdr);
+	} else {
+		/* Non-IP pkt, dont estimate header length */
+		return 0;
+	}
+
+	if (hlen + sizeof(struct tcphdr) > maplen)
+		return 0;
+
+	return (hlen + (hdr.tcp->doff << 2));
+}
+
 static int
 vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 		       struct vmxnet3_adapter *adapter, int quota)
@@ -1174,6 +1220,7 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 	bool skip_page_frags = false;
 	struct Vmxnet3_RxCompDesc *rcd;
 	struct vmxnet3_rx_ctx *ctx = &rq->rx_ctx;
+	u16 segCnt = 0, mss = 0;
 #ifdef __BIG_ENDIAN_BITFIELD
 	struct Vmxnet3_RxDesc rxCmdDesc;
 	struct Vmxnet3_RxCompDesc rxComp;
@@ -1262,7 +1309,19 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 						       PCI_DMA_FROMDEVICE);
 			rxd->addr = cpu_to_le64(rbi->dma_addr);
 			rxd->len = rbi->len;
-
+			if (adapter->version == 2 &&
+			    rcd->type == VMXNET3_CDTYPE_RXCOMP_LRO) {
+				struct Vmxnet3_RxCompDescExt *rcdlro;
+				rcdlro = (struct Vmxnet3_RxCompDescExt *)rcd;
+
+				segCnt = rcdlro->segCnt;
+				BUG_ON(segCnt <= 1);
+				mss = rcdlro->mss;
+				if (unlikely(segCnt <= 1))
+					segCnt = 0;
+			} else {
+				segCnt = 0;
+			}
 		} else {
 			BUG_ON(ctx->skb == NULL && !skip_page_frags);
 
@@ -1311,12 +1370,40 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 
 		skb = ctx->skb;
 		if (rcd->eop) {
+			u32 mtu = adapter->netdev->mtu;
 			skb->len += skb->data_len;
 
 			vmxnet3_rx_csum(adapter, skb,
 					(union Vmxnet3_GenericDesc *)rcd);
 			skb->protocol = eth_type_trans(skb, adapter->netdev);
-
+			if (!rcd->tcp || !adapter->lro)
+				goto not_lro;
+
+			if (segCnt != 0 && mss != 0) {
+				skb_shinfo(skb)->gso_type = rcd->v4 ?
+					SKB_GSO_TCPV4 : SKB_GSO_TCPV6;
+				skb_shinfo(skb)->gso_size = mss;
+				skb_shinfo(skb)->gso_segs = segCnt;
+			} else if (segCnt != 0 || skb->len > mtu) {
+				u32 hlen;
+
+				hlen = vmxnet3_get_hdr_len(adapter, skb,
+					(union Vmxnet3_GenericDesc *)rcd);
+				if (hlen == 0)
+					goto not_lro;
+
+				skb_shinfo(skb)->gso_type =
+					rcd->v4 ? SKB_GSO_TCPV4 : SKB_GSO_TCPV6;
+				if (segCnt != 0) {
+					skb_shinfo(skb)->gso_segs = segCnt;
+					skb_shinfo(skb)->gso_size =
+						DIV_ROUND_UP(skb->len -
+							hlen, segCnt);
+				} else {
+					skb_shinfo(skb)->gso_size = mtu - hlen;
+				}
+			}
+not_lro:
 			if (unlikely(rcd->ts))
 				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), rcd->tci);
 
@@ -3041,14 +3128,19 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		goto err_alloc_pci;
 
 	ver = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_VRRS);
-	if (ver & 1) {
+	if (ver & 2) {
+		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_VRRS, 2);
+		adapter->version = 2;
+	} else if (ver & 1) {
 		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_VRRS, 1);
+		adapter->version = 1;
 	} else {
 		dev_err(&pdev->dev,
 			"Incompatible h/w version (0x%x) for adapter\n", ver);
 		err = -EBUSY;
 		goto err_ver;
 	}
+	dev_dbg(&pdev->dev, "Using device version %d\n", adapter->version);
 
 	ver = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_UVRS);
 	if (ver & 1) {
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 6bb769a..e9f1075 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -328,6 +328,10 @@ struct vmxnet3_adapter {
 
 	u8			__iomem *hw_addr0; /* for BAR 0 */
 	u8			__iomem *hw_addr1; /* for BAR 1 */
+	u8                              version;
+
+	bool				rxcsum;
+	bool				lro;
 
 #ifdef VMXNET3_RSS
 	struct UPT1_RSSConf		*rss_conf;
