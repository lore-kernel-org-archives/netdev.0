From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 5/6] [6LoWPAN] UDP header decompression
Date: Wed,  2 Nov 2011 19:35:32 +0300
Message-ID: <1320251732-2934-1-git-send-email-alex.bluesman.smirnov@gmail.com>
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

This patch provides possibility to decompress UDP headers.
Derived from Contiki OS.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c |   50 +++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 49 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 6da3357..49f42a8 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -839,7 +839,55 @@ lowpan_process_data(struct sk_buff *skb)
 			goto drop;
 	}
 
-	/* TODO: UDP header parse */
+	/* UDP data uncompression */
+	if (iphc0 & LOWPAN_IPHC_NH_C) {
+		tmp = lowpan_fetch_skb_u8(skb);
+
+		if ((tmp & LOWPAN_NHC_UDP_MASK) == LOWPAN_NHC_UDP_ID) {
+			struct udphdr *uh = udp_hdr(skb);
+
+			pr_debug("(%s): UDP header uncompression\n", __func__);
+			switch (tmp & LOWPAN_NHC_UDP_CS_P_11) {
+			case LOWPAN_NHC_UDP_CS_P_00:
+				memcpy(&uh->source, &skb->data[0], 2);
+				memcpy(&uh->dest, &skb->data[2], 2);
+				skb_pull(skb, 4);
+				break;
+			case LOWPAN_NHC_UDP_CS_P_01:
+				memcpy(&uh->source, &skb->data[0], 2);
+				uh->dest =
+				   skb->data[2] + LOWPAN_NHC_UDP_8BIT_PORT;
+				skb_pull(skb, 3);
+				break;
+			case LOWPAN_NHC_UDP_CS_P_10:
+				uh->source = skb->data[0] + LOWPAN_NHC_UDP_8BIT_PORT;
+				memcpy(&uh->dest, &skb->data[1], 2);
+				skb_pull(skb, 3);
+				break;
+			case LOWPAN_NHC_UDP_CS_P_11:
+				uh->source =
+				   LOWPAN_NHC_UDP_4BIT_PORT + (skb->data[0] >> 4);
+				uh->dest =
+				   LOWPAN_NHC_UDP_4BIT_PORT + (skb->data[0] & 0x0f);
+				skb_pull(skb, 1);
+				break;
+			default:
+				pr_debug("(%s) ERROR: unknown UDP format\n", __func__);
+				goto drop;
+			}
+
+			pr_debug("(%s): uncompressed UDP ports: src = %d, dst = %d\n",
+					__func__, uh->source, uh->dest);
+
+			/* copy checksum */
+			memcpy(&uh->check, &skb->data[0], 2);
+			skb_pull(skb, 2);
+		} else {
+			pr_debug("(%s): ERROR: unsupported NH format\n",
+								__func__);
+			goto drop;
+		}
+	}
 
 	/* Not fragmented package */
 	hdr.payload_len = htons(skb->len);
-- 
1.7.2.5


------------------------------------------------------------------------------
RSA&#174; Conference 2012
Save $700 by Nov 18
Register now&#33;
http://p.sf.net/sfu/rsa-sfdev2dev1
