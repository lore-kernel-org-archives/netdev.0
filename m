From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 8/9] sky2: add GRO support
Date: Wed, 17 Jun 2009 10:30:39 -0700
Message-ID: <20090617173140.297221387@vyatta.com>
References: <20090617173031.703636683@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45312 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757637AbZFQReD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 13:34:03 -0400
Content-Disposition: inline; filename=sky2-gro.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for generic receive offload.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-06-17 10:29:58.250810500 -0700
+++ b/drivers/net/sky2.c	2009-06-17 10:29:59.249757381 -0700
@@ -2373,6 +2373,26 @@ static inline void sky2_tx_done(struct n
 	}
 }
 
+static inline void sky2_skb_rx(const struct sky2_port *sky2,
+ 			       u32 status, struct sk_buff *skb)
+{
+#ifdef SKY2_VLAN_TAG_USED
+	u16 vlan_tag = be16_to_cpu(sky2->rx_tag);
+	if (sky2->vlgrp && (status & GMR_FS_VLAN)) {
+		if (skb->ip_summed == CHECKSUM_NONE)
+			vlan_hwaccel_receive_skb(skb, sky2->vlgrp, vlan_tag);
+		else
+			vlan_gro_receive(&sky2->hw->napi, sky2->vlgrp,
+					 vlan_tag, skb);
+ 		return;
+ 	}
+#endif
+ 	if (skb->ip_summed == CHECKSUM_NONE)
+ 		netif_receive_skb(skb);
+ 	else
+ 		napi_gro_receive(&sky2->hw->napi, skb);
+}
+
 static inline void sky2_rx_done(struct sky2_hw *hw, unsigned port,
 				unsigned packets, unsigned bytes)
 {
@@ -2438,14 +2458,7 @@ static int sky2_status_intr(struct sky2_
 
 			skb->protocol = eth_type_trans(skb, dev);
 
-#ifdef SKY2_VLAN_TAG_USED
-			if (sky2->vlgrp && (status & GMR_FS_VLAN)) {
-				vlan_hwaccel_receive_skb(skb,
-							 sky2->vlgrp,
-							 be16_to_cpu(sky2->rx_tag));
-			} else
-#endif
-				netif_receive_skb(skb);
+			sky2_skb_rx(sky2, status, skb);
 
 			/* Stop after net poll weight */
 			if (++work_done >= to_do)

-- 

