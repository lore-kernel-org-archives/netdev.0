From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 14/22] xfrm offload v2: typhoon: add inbound offload result processing
Date: Mon, 10 Jan 2005 10:37:01 -0500
Message-ID: <20040110014300.23@ori.thedillows.org>
References: <20040110014300.22@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 00:54:54-05:00 dave@thedillows.org 
#   Add inbound packet crypto result processing to the Typhoon driver.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# drivers/net/typhoon.c
#   2005/01/10 00:54:37-05:00 dave@thedillows.org +42 -0
#   Add inbound packet crypto result processing to the Typhoon driver.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	2005-01-10 01:17:58 -05:00
+++ b/drivers/net/typhoon.c	2005-01-10 01:17:58 -05:00
@@ -130,6 +130,7 @@
 #include <asm/checksum.h>
 #include <linux/version.h>
 #include <linux/dma-mapping.h>
+#include <net/xfrm.h>
 
 #include "typhoon.h"
 #include "typhoon-firmware.h"
@@ -1680,6 +1681,43 @@
 	return 0;
 }
 
+static inline void
+typhoon_ipsec_rx(struct sk_buff *skb, u16 results)
+{
+#define CHECK_OFFLOAD(good, bad) \
+	do { if(results & (good|bad)) { \
+		unsigned int tmp = XFRM_OFFLOAD_CONF | XFRM_OFFLOAD_AUTH; \
+		tmp |= (results & good) ?  XFRM_OFFLOAD_AUTH_OK : \
+					   XFRM_OFFLOAD_AUTH_FAIL; \
+		if(skb_put_xfrm_result(skb, tmp, i)) \
+				return; \
+		i++; \
+	} } while(0)
+
+	/* We have no way to determine what the order of the SAs were on
+	 * the wire, just the 1st AH seen, the 1st ESP seen, etc.
+	 *
+	 * We just walk the stack, and pretend that AH SAs get decypted
+	 * so that if we get the order wrong, the worst case scenerio is
+	 * that we indicate the failure on the wrong SA, since we'll need
+	 * to match all SAs against the policy.
+	 *
+	 * We get a "ESP good" indication for null auth hash on ESP.
+	 */
+	/* XXX think more about security indications -- can I craft a
+	 * packet to do bad things -- maybe a NULL auth ESP packet,
+	 * and a failed AH packet?
+	 */
+	int i = 0;
+
+	CHECK_OFFLOAD(TYPHOON_RX_AH1_GOOD, TYPHOON_RX_AH1_FAIL);
+	CHECK_OFFLOAD(TYPHOON_RX_ESP1_GOOD, TYPHOON_RX_ESP1_FAIL);
+	CHECK_OFFLOAD(TYPHOON_RX_AH2_GOOD, TYPHOON_RX_AH2_FAIL);
+	CHECK_OFFLOAD(TYPHOON_RX_ESP2_GOOD, TYPHOON_RX_ESP2_FAIL);
+
+#undef CHECK_OFFLOAD
+}
+
 static int
 typhoon_rx(struct typhoon *tp, struct basic_ring *rxRing, volatile u32 * ready,
 	   volatile u32 * cleared, int budget)
@@ -1744,6 +1782,10 @@
 			new_skb->ip_summed = CHECKSUM_UNNECESSARY;
 		} else
 			new_skb->ip_summed = CHECKSUM_NONE;
+
+		if((rx->rxStatus & TYPHOON_RX_IPSEC) &&
+				!(rx->rxStatus & TYPHOON_RX_IP_FRAG))
+			typhoon_ipsec_rx(new_skb, rx->ipsecResults);
 
 		spin_lock(&tp->state_lock);
 		if(tp->vlgrp != NULL && rx->rxStatus & TYPHOON_RX_VLAN)
