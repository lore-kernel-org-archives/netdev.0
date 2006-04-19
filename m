From: akpm@osdl.org
Subject: [patch 07/10] forcedeth: suggested cleanups
Date: Tue, 18 Apr 2006 21:04:22 -0700
Message-ID: <200604190405.k3J454VA008001@shell0.pdx.osdl.net>
Cc: linville@tuxdriver.com, netdev@vger.kernel.org, akpm@osdl.org,
	ioe-lkml@rameria.de, manfred@colorfullife.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:7628 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750765AbWDSEFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 00:05:55 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Ingo Oeser <ioe-lkml@rameria.de>

general:
	- endian annotation of the ring descriptors

nv_getlen():
	- use htons() instead of __constant_htons()
          to improvde readability and let the compiler constant fold it.

nv_rx_process():
	- use a real for() loop in processing instead of goto and break
	- consolidate rx_errors increment
	- count detected rx_length_errors

Signed-off-by: Ingo Oeser <ioe-lkml@rameria.de>
Cc: Manfred Spraul <manfred@colorfullife.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/forcedeth.c |   59 ++++++++++++++++----------------------
 1 files changed, 26 insertions(+), 33 deletions(-)

diff -puN drivers/net/forcedeth.c~forcedeth-suggested-cleanups drivers/net/forcedeth.c
--- devel/drivers/net/forcedeth.c~forcedeth-suggested-cleanups	2006-04-10 23:21:26.000000000 -0700
+++ devel-akpm/drivers/net/forcedeth.c	2006-04-10 23:21:26.000000000 -0700
@@ -328,17 +328,18 @@ enum {
 	NvRegMSIXIrqStatus = 0x3f0,
 };
 
-/* Big endian: should work, but is untested */
+/* Big endian: should work, but is untested.
+ * So give arch maintainers a hint here. -ioe */
 struct ring_desc {
-	u32 PacketBuffer;
-	u32 FlagLen;
+	__le32 PacketBuffer;
+	__le32 FlagLen;
 };
 
 struct ring_desc_ex {
-	u32 PacketBufferHigh;
-	u32 PacketBufferLow;
-	u32 TxVlan;
-	u32 FlagLen;
+	__le32 PacketBufferHigh;
+	__le32 PacketBufferLow;
+	__le32 TxVlan;
+	__le32 FlagLen;
 };
 
 typedef union _ring_type {
@@ -1403,7 +1404,7 @@ static int nv_getlen(struct net_device *
 	int protolen;	/* length as stored in the proto field */
 
 	/* 1) calculate len according to header */
-	if ( ((struct vlan_ethhdr *)packet)->h_vlan_proto == __constant_htons(ETH_P_8021Q)) {
+	if (((struct vlan_ethhdr *)packet)->h_vlan_proto == htons(ETH_P_8021Q)) {
 		protolen = ntohs( ((struct vlan_ethhdr *)packet)->h_vlan_encapsulated_proto );
 		hdrlen = VLAN_HLEN;
 	} else {
@@ -1453,12 +1454,10 @@ static void nv_rx_process(struct net_dev
 	u32 vlanflags = 0;
 
 
-	for (;;) {
+	for (; np->cur_rx - np->refill_rx < RX_RING; np->cur_rx++) {
 		struct sk_buff *skb;
 		int len;
 		int i;
-		if (np->cur_rx - np->refill_rx >= RX_RING)
-			break;	/* we scanned the whole ring - do not continue */
 
 		i = np->cur_rx % RX_RING;
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
@@ -1498,33 +1497,29 @@ static void nv_rx_process(struct net_dev
 		/* look at what we actually got: */
 		if (np->desc_ver == DESC_VER_1) {
 			if (!(Flags & NV_RX_DESCRIPTORVALID))
-				goto next_pkt;
+				continue;
 
 			if (Flags & NV_RX_ERROR) {
 				if (Flags & NV_RX_MISSEDFRAME) {
 					np->stats.rx_missed_errors++;
-					np->stats.rx_errors++;
-					goto next_pkt;
+					goto error_pkt;
 				}
 				if (Flags & (NV_RX_ERROR1|NV_RX_ERROR2|NV_RX_ERROR3)) {
-					np->stats.rx_errors++;
-					goto next_pkt;
+					goto error_pkt;
 				}
 				if (Flags & NV_RX_CRCERR) {
 					np->stats.rx_crc_errors++;
-					np->stats.rx_errors++;
-					goto next_pkt;
+					goto error_pkt;
 				}
 				if (Flags & NV_RX_OVERFLOW) {
 					np->stats.rx_over_errors++;
-					np->stats.rx_errors++;
-					goto next_pkt;
+					goto error_pkt;
 				}
 				if (Flags & NV_RX_ERROR4) {
 					len = nv_getlen(dev, np->rx_skbuff[i]->data, len);
 					if (len < 0) {
-						np->stats.rx_errors++;
-						goto next_pkt;
+						np->stats.rx_length_errors++;
+						goto error_pkt;
 					}
 				}
 				/* framing errors are soft errors. */
@@ -1536,28 +1531,25 @@ static void nv_rx_process(struct net_dev
 			}
 		} else {
 			if (!(Flags & NV_RX2_DESCRIPTORVALID))
-				goto next_pkt;
+				continue;
 
 			if (Flags & NV_RX2_ERROR) {
 				if (Flags & (NV_RX2_ERROR1|NV_RX2_ERROR2|NV_RX2_ERROR3)) {
-					np->stats.rx_errors++;
-					goto next_pkt;
+					goto error_pkt;
 				}
 				if (Flags & NV_RX2_CRCERR) {
 					np->stats.rx_crc_errors++;
-					np->stats.rx_errors++;
-					goto next_pkt;
+					goto error_pkt;
 				}
 				if (Flags & NV_RX2_OVERFLOW) {
 					np->stats.rx_over_errors++;
-					np->stats.rx_errors++;
-					goto next_pkt;
+					goto error_pkt;
 				}
 				if (Flags & NV_RX2_ERROR4) {
 					len = nv_getlen(dev, np->rx_skbuff[i]->data, len);
 					if (len < 0) {
-						np->stats.rx_errors++;
-						goto next_pkt;
+						np->stats.rx_length_errors++;
+						goto error_pkt;
 					}
 				}
 				/* framing errors are soft errors */
@@ -1593,8 +1585,9 @@ static void nv_rx_process(struct net_dev
 		dev->last_rx = jiffies;
 		np->stats.rx_packets++;
 		np->stats.rx_bytes += len;
-next_pkt:
-		np->cur_rx++;
+		continue;
+error_pkt:
+		np->stats.rx_errors++;
 	}
 }
 
_
