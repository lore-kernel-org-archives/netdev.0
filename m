From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH-2.6.28] net: jme.c rxdesc.flags is __le16, other missing
 endian swaps
Date: Mon, 17 Nov 2008 13:30:05 -0800
Message-ID: <1226957405.6150.8.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:50971 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbYKQVaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 16:30:09 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1115452yxm.1
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 13:30:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the minimal patch to fix endian mismatches.  These are
probably bugs on big-endian arches, noops on little endian.

jme_rxsum_ok could be improved to directly take a __le16 and
change all of the masks/sets to be in little-endian, but
has not been done here to keep the patch small.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave, could use confirmation here, but looks almost certainly like a bugfix
for big-endian.

 drivers/net/jme.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 81c6cdc..665e70d 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -912,23 +912,23 @@ jme_alloc_and_feed_skb(struct jme_adapter *jme, int idx)
 		skb_put(skb, framesize);
 		skb->protocol = eth_type_trans(skb, jme->dev);
 
-		if (jme_rxsum_ok(jme, rxdesc->descwb.flags))
+		if (jme_rxsum_ok(jme, le16_to_cpu(rxdesc->descwb.flags)))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		else
 			skb->ip_summed = CHECKSUM_NONE;
 
-		if (rxdesc->descwb.flags & RXWBFLAG_TAGON) {
+		if (rxdesc->descwb.flags & cpu_to_le16(RXWBFLAG_TAGON)) {
 			if (jme->vlgrp) {
 				jme->jme_vlan_rx(skb, jme->vlgrp,
-					le32_to_cpu(rxdesc->descwb.vlan));
+					le16_to_cpu(rxdesc->descwb.vlan));
 				NET_STAT(jme).rx_bytes += 4;
 			}
 		} else {
 			jme->jme_rx(skb);
 		}
 
-		if ((le16_to_cpu(rxdesc->descwb.flags) & RXWBFLAG_DEST) ==
-				RXWBFLAG_DEST_MUL)
+		if ((rxdesc->descwb.flags & cpu_to_le16(RXWBFLAG_DEST)) ==
+		    cpu_to_le16(RXWBFLAG_DEST_MUL))
 			++(NET_STAT(jme).multicast);
 
 		jme->dev->last_rx = jiffies;
@@ -961,7 +961,7 @@ jme_process_receive(struct jme_adapter *jme, int limit)
 		rxdesc = rxring->desc;
 		rxdesc += i;
 
-		if ((rxdesc->descwb.flags & RXWBFLAG_OWN) ||
+		if ((rxdesc->descwb.flags & cpu_to_le16(RXWBFLAG_OWN)) ||
 		!(rxdesc->descwb.desccnt & RXWBDCNT_WBCPL))
 			goto out;
 
@@ -1763,10 +1763,9 @@ jme_expand_header(struct jme_adapter *jme, struct sk_buff *skb)
 }
 
 static int
-jme_tx_tso(struct sk_buff *skb,
-		u16 *mss, u8 *flags)
+jme_tx_tso(struct sk_buff *skb, __le16 *mss, u8 *flags)
 {
-	*mss = skb_shinfo(skb)->gso_size << TXDESC_MSS_SHIFT;
+	*mss = cpu_to_le16(skb_shinfo(skb)->gso_size << TXDESC_MSS_SHIFT);
 	if (*mss) {
 		*flags |= TXFLAG_LSEN;
 
@@ -1826,11 +1825,11 @@ jme_tx_csum(struct jme_adapter *jme, struct sk_buff *skb, u8 *flags)
 }
 
 static inline void
-jme_tx_vlan(struct sk_buff *skb, u16 *vlan, u8 *flags)
+jme_tx_vlan(struct sk_buff *skb, __le16 *vlan, u8 *flags)
 {
 	if (vlan_tx_tag_present(skb)) {
 		*flags |= TXFLAG_TAGON;
-		*vlan = vlan_tx_tag_get(skb);
+		*vlan = cpu_to_le16(vlan_tx_tag_get(skb));
 	}
 }
 
-- 
1.6.0.4.994.g16bd3e



