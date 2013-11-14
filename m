From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 4/6] 6lowpan: add udp warning
	for elided checksum
Date: Thu, 14 Nov 2013 16:48:50 +0100
Message-ID: <1384444132-1427-5-git-send-email-alex.aring@gmail.com>
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

Bit 5 of "UDP LOWPAN_NHC Format" indicate that the checksum can be elided.
The host need to calculate the udp checksum afterwards but this isn't
supported right now.

See:
http://tools.ietf.org/html/rfc6282#section-4.3.3
Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 11 ++++++++---
 net/ieee802154/6lowpan.h |  1 +
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 616f2f6..59678da 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -448,9 +448,14 @@ lowpan_uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
 		pr_debug("uncompressed UDP ports: src = %d, dst = %d\n",
 			 ntohs(uh->source), ntohs(uh->dest));
 
-		/* copy checksum */
-		memcpy(&uh->check, &skb->data[0], 2);
-		skb_pull(skb, 2);
+		/* checksum */
+		if (tmp & LOWPAN_NHC_UDP_CS_C) {
+			pr_debug("checksum elided currently not supported");
+			goto err;
+		} else {
+			memcpy(&uh->check, &skb->data[0], 2);
+			skb_pull(skb, 2);
+		}
 
 		/*
 		 * UDP lenght needs to be infered from the lower layers
diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index 2869c05..2bc231f 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -231,6 +231,7 @@
 #define LOWPAN_NHC_UDP_CS_P_10	0xF2 /* source = 0xF0 + 8bit inline,
 					dest = 16 bit inline */
 #define LOWPAN_NHC_UDP_CS_P_11	0xF3 /* source & dest = 0xF0B + 4bit inline */
+#define LOWPAN_NHC_UDP_CS_C	0x04 /* checksum elided */
 
 static inline bool lowpan_fetch_skb(struct sk_buff *skb,
 		void *data, const unsigned int len)
-- 
1.8.4.2


------------------------------------------------------------------------------
DreamFactory - Open Source REST & JSON Services for HTML5 & Native Apps
OAuth, Users, Roles, SQL, NoSQL, BLOB Storage and External API Access
Free app hosting. Or install the open source package on any LAMP server.
Sign up and see examples for AngularJS, jQuery, Sencha Touch and Native!
http://pubads.g.doubleclick.net/gampad/clk?id=63469471&iu=/4140/ostg.clktrk
