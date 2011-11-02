From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/6] [6LoWPAN] UDP header compression
Date: Wed,  2 Nov 2011 19:35:11 +0300
Message-ID: <1320251711-2897-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111102162520.GA2669@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111102162520.GA2669-AUGNqIMGY+bGcXpsla5Oef8+0UxHXcjY@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds support for UDP header compression.
Derived from Contiki OS.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c |   51 ++++++++++++++++++++++++++++++++++++++++++---
 net/ieee802154/6lowpan.h |    5 ++++
 2 files changed, 52 insertions(+), 4 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index c4aae4e..6da3357 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -365,8 +365,6 @@ static int lowpan_header_create(struct sk_buff *skb,
 	if (hdr->nexthdr == UIP_PROTO_UDP)
 		iphc0 |= LOWPAN_IPHC_NH_C;
 
-/* TODO: next header compression */
-
 	if ((iphc0 & LOWPAN_IPHC_NH_C) == 0) {
 		*hc06_ptr = hdr->nexthdr;
 		hc06_ptr += 1;
@@ -454,8 +452,53 @@ static int lowpan_header_create(struct sk_buff *skb,
 		}
 	}
 
-	/* TODO: UDP header compression */
-	/* TODO: Next Header compression */
+	/* UDP header compression */
+	if (hdr->nexthdr == UIP_PROTO_UDP) {
+		struct udphdr *uh = udp_hdr(skb);
+
+		pr_debug("(%s): UDP header compression\n", __func__);
+
+		if (((uh->source & LOWPAN_NHC_UDP_4BIT_MASK) ==
+					LOWPAN_NHC_UDP_4BIT_PORT) &&
+		    ((uh->dest & LOWPAN_NHC_UDP_4BIT_MASK) ==
+					LOWPAN_NHC_UDP_4BIT_PORT)) {
+			pr_debug("(%s): both ports compression to 4 bits\n",
+								__func__);
+			*hc06_ptr = LOWPAN_NHC_UDP_CS_P_11;
+			*(hc06_ptr + 1) = /* subtraction is faster */
+			   (u8)((uh->dest - LOWPAN_NHC_UDP_4BIT_PORT) +
+			       ((uh->source & LOWPAN_NHC_UDP_4BIT_PORT) << 4));
+			hc06_ptr += 2;
+		} else if ((uh->dest & LOWPAN_NHC_UDP_8BIT_MASK) ==
+				LOWPAN_NHC_UDP_8BIT_PORT) {
+			pr_debug("(%s): remove 8 bits of dest\n", __func__);
+			*hc06_ptr = LOWPAN_NHC_UDP_CS_P_01;
+			memcpy(hc06_ptr + 1, &uh->source, 2);
+			*(hc06_ptr + 3) =
+				(u8)(uh->dest - LOWPAN_NHC_UDP_8BIT_PORT);
+			hc06_ptr += 4;
+		} else if ((uh->source & LOWPAN_NHC_UDP_8BIT_MASK) ==
+				LOWPAN_NHC_UDP_8BIT_PORT) {
+			pr_debug("(%s): remove 8 bits of source\n", __func__);
+			*hc06_ptr = LOWPAN_NHC_UDP_CS_P_10;
+			memcpy(hc06_ptr + 1, &uh->dest, 2);
+			*(hc06_ptr + 3) =
+				(u8)(uh->source - LOWPAN_NHC_UDP_8BIT_PORT);
+			hc06_ptr += 4;
+		} else {
+			pr_debug("(%s): can't compress header\n", __func__);
+			*hc06_ptr = LOWPAN_NHC_UDP_CS_P_00;
+			memcpy(hc06_ptr + 1, &uh->source, 2);
+			memcpy(hc06_ptr + 3, &uh->dest, 2);
+			hc06_ptr += 5;
+		}
+
+		/* checksum is always inline */
+		memcpy(hc06_ptr, &uh->check, 2);
+		hc06_ptr += 2;
+	}
+
+	/* TODO: other NH types support? */
 
 	head[0] = iphc0;
 	head[1] = iphc1;
diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index 5d2e5a0..aeff3f3 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -219,6 +219,11 @@
 #define LOWPAN_NHC_UDP_CHECKSUMC	0x04
 #define LOWPAN_NHC_UDP_CHECKSUMI	0x00
 
+#define LOWPAN_NHC_UDP_4BIT_PORT	0xF0B0
+#define LOWPAN_NHC_UDP_4BIT_MASK	0xFFF0
+#define LOWPAN_NHC_UDP_8BIT_PORT	0xF000
+#define LOWPAN_NHC_UDP_8BIT_MASK	0xFF00
+
 /* values for port compression, _with checksum_ ie bit 5 set to 0 */
 #define LOWPAN_NHC_UDP_CS_P_00	0xF0 /* all inline */
 #define LOWPAN_NHC_UDP_CS_P_01	0xF1 /* source 16bit inline,
-- 
1.7.2.5


------------------------------------------------------------------------------
RSA&#174; Conference 2012
Save $700 by Nov 18
Register now&#33;
http://p.sf.net/sfu/rsa-sfdev2dev1
