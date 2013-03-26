From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH v2 net-next 12/12] 6lowpan: modify udp
	compression/uncompression to match the standard
Date: Mon, 25 Mar 2013 23:59:32 -0400
Message-ID: <1364270372-19430-13-git-send-email-tony.cheneau@amnesiak.org>
References: <1364270372-19430-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364270372-19430-1-git-send-email-tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The previous code would just compress the UDP header and send the compressed
UDP header along with the uncompressed one.

Signed-off-by: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 39 ++++++++++++++++++++++++++++++++++++---
 1 file changed, 36 insertions(+), 3 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 276971b..c9c3f3d 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -284,6 +284,9 @@ lowpan_compress_udp_header(u8 **hc06_ptr, struct sk_buff *skb)
 	/* checksum is always inline */
 	memcpy(*hc06_ptr, &uh->check, 2);
 	*hc06_ptr += 2;
+
+	/* skip the UDP header */
+	skb_pull(skb, sizeof(struct udphdr));
 }
 
 static inline int lowpan_fetch_skb_u8(struct sk_buff *skb, u8 *val)
@@ -309,9 +312,8 @@ static inline int lowpan_fetch_skb_u16(struct sk_buff *skb, u16 *val)
 }
 
 static int
-lowpan_uncompress_udp_header(struct sk_buff *skb)
+lowpan_uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
 {
-	struct udphdr *uh = udp_hdr(skb);
 	u8 tmp;
 
 	if (!uh)
@@ -358,6 +360,14 @@ lowpan_uncompress_udp_header(struct sk_buff *skb)
 		/* copy checksum */
 		memcpy(&uh->check, &skb->data[0], 2);
 		skb_pull(skb, 2);
+
+		/*
+		 * UDP lenght needs to be infered from the lower layers
+		 * here, we obtain the hint from the remaining size of the
+		 * frame
+		 */
+		uh->len = htons(skb->len + sizeof(struct udphdr));
+		pr_debug("uncompressed UDP length: src = %d", uh->len);
 	} else {
 		pr_debug("ERROR: unsupported NH format\n");
 		goto err;
@@ -944,8 +954,31 @@ lowpan_process_data(struct sk_buff *skb)
 
 	/* UDP data uncompression */
 	if (iphc0 & LOWPAN_IPHC_NH_C) {
-		if (lowpan_uncompress_udp_header(skb))
+		struct udphdr uh;
+		struct sk_buff *new;
+		if (lowpan_uncompress_udp_header(skb, &uh))
 			goto drop;
+
+		/*
+		 * replace the compressed UDP head by the uncompressed UDP
+		 * header
+		 */
+		new = skb_copy_expand(skb, sizeof(struct udphdr),
+				      skb_tailroom(skb), GFP_ATOMIC);
+		kfree_skb(skb);
+
+		if (!new)
+			return -ENOMEM;
+
+		skb = new;
+
+		skb_push(skb, sizeof(struct udphdr));
+		skb_reset_transport_header(skb);
+		skb_copy_to_linear_data(skb, &uh, sizeof(struct udphdr));
+
+		lowpan_raw_dump_table(__func__, "raw UDP header dump",
+				      (u8 *)&uh, sizeof(uh));
+
 		hdr.nexthdr = UIP_PROTO_UDP;
 	}
 
-- 
1.7.12.4


------------------------------------------------------------------------------
Own the Future-Intel&reg; Level Up Game Demo Contest 2013
Rise to greatness in Intel's independent game demo contest.
Compete for recognition, cash, and the chance to get your game 
on Steam. $5K grand prize plus 10 genre and skill prizes. 
Submit your demo by 6/6/13. http://p.sf.net/sfu/intel_levelupd2d
