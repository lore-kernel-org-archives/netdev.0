From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 3/6] 6lowpan: fix udp byte
	ordering
Date: Thu, 14 Nov 2013 16:48:49 +0100
Message-ID: <1384444132-1427-4-git-send-email-alex.aring@gmail.com>
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

The incoming udp header in lowpan_compress_udp_header function is
already in network byte order.

Everytime we read this values for source and destination port we need
to convert this value to host byte order.

In the outcoming header we need to set this value in network byte order
which the upcoming process assumes.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 41 ++++++++++++++++++++++-------------------
 1 file changed, 22 insertions(+), 19 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index ad6755a..616f2f6 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -338,28 +338,30 @@ lowpan_compress_udp_header(u8 **hc06_ptr, struct sk_buff *skb)
 {
 	struct udphdr *uh = udp_hdr(skb);
 
-	if (((uh->source & LOWPAN_NHC_UDP_4BIT_MASK) ==
-				LOWPAN_NHC_UDP_4BIT_PORT) &&
-	    ((uh->dest & LOWPAN_NHC_UDP_4BIT_MASK) ==
-				LOWPAN_NHC_UDP_4BIT_PORT)) {
+	if (((ntohs(uh->source) & LOWPAN_NHC_UDP_4BIT_MASK) ==
+	     LOWPAN_NHC_UDP_4BIT_PORT) &&
+	    ((ntohs(uh->dest) & LOWPAN_NHC_UDP_4BIT_MASK) ==
+	     LOWPAN_NHC_UDP_4BIT_PORT)) {
 		pr_debug("UDP header: both ports compression to 4 bits\n");
 		**hc06_ptr = LOWPAN_NHC_UDP_CS_P_11;
 		*(*hc06_ptr + 1) = /* subtraction is faster */
-		   (u8)((uh->dest - LOWPAN_NHC_UDP_4BIT_PORT) +
-		       ((uh->source & LOWPAN_NHC_UDP_4BIT_PORT) << 4));
+		   (u8)((ntohs(uh->dest) - LOWPAN_NHC_UDP_4BIT_PORT) +
+		       ((ntohs(uh->source) & LOWPAN_NHC_UDP_4BIT_PORT) << 4));
 		*hc06_ptr += 2;
-	} else if ((uh->dest & LOWPAN_NHC_UDP_8BIT_MASK) ==
+	} else if ((ntohs(uh->dest) & LOWPAN_NHC_UDP_8BIT_MASK) ==
 			LOWPAN_NHC_UDP_8BIT_PORT) {
 		pr_debug("UDP header: remove 8 bits of dest\n");
 		**hc06_ptr = LOWPAN_NHC_UDP_CS_P_01;
 		memcpy(*hc06_ptr + 1, &uh->source, 2);
-		*(*hc06_ptr + 3) = (u8)(uh->dest - LOWPAN_NHC_UDP_8BIT_PORT);
+		*(*hc06_ptr + 3) = (u8)(ntohs(uh->dest) -
+					LOWPAN_NHC_UDP_8BIT_PORT);
 		*hc06_ptr += 4;
-	} else if ((uh->source & LOWPAN_NHC_UDP_8BIT_MASK) ==
+	} else if ((ntohs(uh->source) & LOWPAN_NHC_UDP_8BIT_MASK) ==
 			LOWPAN_NHC_UDP_8BIT_PORT) {
 		pr_debug("UDP header: remove 8 bits of source\n");
 		**hc06_ptr = LOWPAN_NHC_UDP_CS_P_10;
-		*(*hc06_ptr + 1) = (u8)(uh->source - LOWPAN_NHC_UDP_8BIT_PORT);
+		*(*hc06_ptr + 1) = (u8)(ntohs(uh->source) -
+					LOWPAN_NHC_UDP_8BIT_PORT);
 		memcpy(*hc06_ptr + 2, &uh->dest, 2);
 		*hc06_ptr += 4;
 	} else {
@@ -421,20 +423,21 @@ lowpan_uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
 			break;
 		case LOWPAN_NHC_UDP_CS_P_01:
 			memcpy(&uh->source, &skb->data[0], 2);
-			uh->dest =
-			   skb->data[2] + LOWPAN_NHC_UDP_8BIT_PORT;
+			uh->dest = htons(skb->data[2] +
+					 LOWPAN_NHC_UDP_8BIT_PORT);
 			skb_pull(skb, 3);
 			break;
 		case LOWPAN_NHC_UDP_CS_P_10:
-			uh->source = skb->data[0] + LOWPAN_NHC_UDP_8BIT_PORT;
+			uh->source = htons(skb->data[0] +
+					   LOWPAN_NHC_UDP_8BIT_PORT);
 			memcpy(&uh->dest, &skb->data[1], 2);
 			skb_pull(skb, 3);
 			break;
 		case LOWPAN_NHC_UDP_CS_P_11:
-			uh->source =
-			   LOWPAN_NHC_UDP_4BIT_PORT + (skb->data[0] >> 4);
-			uh->dest =
-			   LOWPAN_NHC_UDP_4BIT_PORT + (skb->data[0] & 0x0f);
+			uh->source = htons(LOWPAN_NHC_UDP_4BIT_PORT +
+					   (skb->data[0] >> 4));
+			uh->dest = htons(LOWPAN_NHC_UDP_4BIT_PORT +
+					 (skb->data[0] & 0x0f));
 			skb_pull(skb, 1);
 			break;
 		default:
@@ -443,7 +446,7 @@ lowpan_uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
 		}
 
 		pr_debug("uncompressed UDP ports: src = %d, dst = %d\n",
-			 uh->source, uh->dest);
+			 ntohs(uh->source), ntohs(uh->dest));
 
 		/* copy checksum */
 		memcpy(&uh->check, &skb->data[0], 2);
@@ -455,7 +458,7 @@ lowpan_uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
 		 * frame
 		 */
 		uh->len = htons(skb->len + sizeof(struct udphdr));
-		pr_debug("uncompressed UDP length: src = %d", uh->len);
+		pr_debug("uncompressed UDP length: src = %d", ntohs(uh->len));
 	} else {
 		pr_debug("ERROR: unsupported NH format\n");
 		goto err;
-- 
1.8.4.2


------------------------------------------------------------------------------
DreamFactory - Open Source REST & JSON Services for HTML5 & Native Apps
OAuth, Users, Roles, SQL, NoSQL, BLOB Storage and External API Access
Free app hosting. Or install the open source package on any LAMP server.
Sign up and see examples for AngularJS, jQuery, Sencha Touch and Native!
http://pubads.g.doubleclick.net/gampad/clk?id=63469471&iu=/4140/ostg.clktrk
