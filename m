From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 5/6] 6lowpan: udp use
	lowpan_fetch_skb function
Date: Thu, 14 Nov 2013 16:48:51 +0100
Message-ID: <1384444132-1427-6-git-send-email-alex.aring@gmail.com>
References: <1384444132-1427-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1384444132-1427-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Cleanup the lowpan_uncompress_udp_header function to use the
lowpan_fetch_skb function.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 40 ++++++++++++++++++----------------------
 1 file changed, 18 insertions(+), 22 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 59678da..6d7f253 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -405,40 +405,34 @@ static inline int lowpan_fetch_skb_u16(struct sk_buff *skb, u16 *val)
 static int
 lowpan_uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
 {
-	u8 tmp;
-
-	if (!uh)
-		goto err;
+	bool fail;
+	u8 tmp = 0, val = 0;
 
-	if (lowpan_fetch_skb_u8(skb, &tmp))
-		goto err;
+	fail = lowpan_fetch_skb(skb, &tmp, 1);
 
 	if ((tmp & LOWPAN_NHC_UDP_MASK) == LOWPAN_NHC_UDP_ID) {
 		pr_debug("UDP header uncompression\n");
 		switch (tmp & LOWPAN_NHC_UDP_CS_P_11) {
 		case LOWPAN_NHC_UDP_CS_P_00:
-			memcpy(&uh->source, &skb->data[0], 2);
-			memcpy(&uh->dest, &skb->data[2], 2);
-			skb_pull(skb, 4);
+			fail |= lowpan_fetch_skb(skb, &uh->source, 2);
+			fail |= lowpan_fetch_skb(skb, &uh->dest, 2);
 			break;
 		case LOWPAN_NHC_UDP_CS_P_01:
-			memcpy(&uh->source, &skb->data[0], 2);
-			uh->dest = htons(skb->data[2] +
-					 LOWPAN_NHC_UDP_8BIT_PORT);
-			skb_pull(skb, 3);
+			fail |= lowpan_fetch_skb(skb, &uh->source, 2);
+			fail |= lowpan_fetch_skb(skb, &val, 1);
+			uh->dest = htons(val + LOWPAN_NHC_UDP_8BIT_PORT);
 			break;
 		case LOWPAN_NHC_UDP_CS_P_10:
-			uh->source = htons(skb->data[0] +
-					   LOWPAN_NHC_UDP_8BIT_PORT);
-			memcpy(&uh->dest, &skb->data[1], 2);
-			skb_pull(skb, 3);
+			fail |= lowpan_fetch_skb(skb, &val, 1);
+			uh->source = htons(val + LOWPAN_NHC_UDP_8BIT_PORT);
+			fail |= lowpan_fetch_skb(skb, &uh->dest, 2);
 			break;
 		case LOWPAN_NHC_UDP_CS_P_11:
+			fail |= lowpan_fetch_skb(skb, &val, 1);
 			uh->source = htons(LOWPAN_NHC_UDP_4BIT_PORT +
-					   (skb->data[0] >> 4));
+					   (val >> 4));
 			uh->dest = htons(LOWPAN_NHC_UDP_4BIT_PORT +
-					 (skb->data[0] & 0x0f));
-			skb_pull(skb, 1);
+					 (val & 0x0f));
 			break;
 		default:
 			pr_debug("ERROR: unknown UDP format\n");
@@ -453,8 +447,7 @@ lowpan_uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
 			pr_debug("checksum elided currently not supported");
 			goto err;
 		} else {
-			memcpy(&uh->check, &skb->data[0], 2);
-			skb_pull(skb, 2);
+			fail |= lowpan_fetch_skb(skb, &uh->check, 2);
 		}
 
 		/*
@@ -469,6 +462,9 @@ lowpan_uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
 		goto err;
 	}
 
+	if (fail)
+		goto err;
+
 	return 0;
 err:
 	return -EINVAL;
-- 
1.8.4.2


------------------------------------------------------------------------------
DreamFactory - Open Source REST & JSON Services for HTML5 & Native Apps
OAuth, Users, Roles, SQL, NoSQL, BLOB Storage and External API Access
Free app hosting. Or install the open source package on any LAMP server.
Sign up and see examples for AngularJS, jQuery, Sencha Touch and Native!
http://pubads.g.doubleclick.net/gampad/clk?id=63469471&iu=/4140/ostg.clktrk
