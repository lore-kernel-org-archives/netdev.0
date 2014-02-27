From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v5 3/8] 6lowpan: fix
	fragmentation on sending side
Date: Thu, 27 Feb 2014 09:06:17 +0100
Message-ID: <1393488382-1250-4-git-send-email-alex.aring@gmail.com>
References: <1393488382-1250-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1393488382-1250-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fix the fragmentation on sending side according to rfc4944.

Also add improvement to use the full payload of a PDU which calculate
the nearest divided to 8 payload length for the fragmentation datagram
size attribute.

The main issue is that the datagram size of fragmentation header use the
ipv6 payload length, but rfc4944 says it's the ipv6 payload length inclusive
network header size (and transport header size if compressed).

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 37 +++++++++++++++++++++++++++----------
 1 file changed, 27 insertions(+), 10 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 8edfea5..872c8f9 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -422,44 +422,60 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
 static int
 lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
 {
-	int  err, header_length, payload_length, tag, offset = 0;
+	int err;
+	u16 dgram_offset, dgram_size, payload_length, header_length,
+	    lowpan_size, frag_plen, offset, tag;
 	u8 head[5];
 
 	header_length = skb->mac_len;
 	payload_length = skb->len - header_length;
 	tag = lowpan_dev_info(dev)->fragment_tag++;
+	lowpan_size = skb_network_header_len(skb);
+	dgram_size = lowpan_uncompress_size(skb, &dgram_offset) -
+		     header_length;
 
 	/* first fragment header */
-	head[0] = LOWPAN_DISPATCH_FRAG1 | ((payload_length >> 8) & 0x7);
-	head[1] = payload_length & 0xff;
+	head[0] = LOWPAN_DISPATCH_FRAG1 | ((dgram_size >> 8) & 0x7);
+	head[1] = dgram_size & 0xff;
 	head[2] = tag >> 8;
 	head[3] = tag & 0xff;
 
-	err = lowpan_fragment_xmit(skb, head, header_length, LOWPAN_FRAG_SIZE,
-				   0, LOWPAN_DISPATCH_FRAG1);
+	/* calc the nearest payload length(divided to 8) for first fragment
+	 * which fits into a IEEE802154_MTU
+	 */
+	frag_plen = round_down(IEEE802154_MTU - header_length -
+			       LOWPAN_FRAG1_HEAD_SIZE - lowpan_size -
+			       IEEE802154_MFR_SIZE, 8);
 
+	err = lowpan_fragment_xmit(skb, head, header_length,
+				   frag_plen + lowpan_size, 0,
+				   LOWPAN_DISPATCH_FRAG1);
 	if (err) {
 		pr_debug("%s unable to send FRAG1 packet (tag: %d)",
 			 __func__, tag);
 		goto exit;
 	}
 
-	offset = LOWPAN_FRAG_SIZE;
+	offset = lowpan_size + frag_plen;
+	dgram_offset += frag_plen;
 
 	/* next fragment header */
 	head[0] &= ~LOWPAN_DISPATCH_FRAG1;
 	head[0] |= LOWPAN_DISPATCH_FRAGN;
 
+	frag_plen = round_down(IEEE802154_MTU - header_length -
+			       LOWPAN_FRAGN_HEAD_SIZE - IEEE802154_MFR_SIZE, 8);
+
 	while (payload_length - offset > 0) {
-		int len = LOWPAN_FRAG_SIZE;
+		int len = frag_plen;
 
-		head[4] = offset / 8;
+		head[4] = dgram_offset >> 3;
 
 		if (payload_length - offset < len)
 			len = payload_length - offset;
 
-		err = lowpan_fragment_xmit(skb, head, header_length,
-					   len, offset, LOWPAN_DISPATCH_FRAGN);
+		err = lowpan_fragment_xmit(skb, head, header_length, len,
+					   offset, LOWPAN_DISPATCH_FRAGN);
 		if (err) {
 			pr_debug("%s unable to send a subsequent FRAGN packet "
 				 "(tag: %d, offset: %d", __func__, tag, offset);
@@ -467,6 +483,7 @@ lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
 		}
 
 		offset += len;
+		dgram_offset += len;
 	}
 
 exit:
-- 
1.9.0


------------------------------------------------------------------------------
Flow-based real-time traffic analytics software. Cisco certified tool.
Monitor traffic, SLAs, QoS, Medianet, WAAS etc. with NetFlow Analyzer
Customize your own dashboards, set traffic alerts and generate reports.
Network behavioral analysis & security monitoring. All-in-one tool.
http://pubads.g.doubleclick.net/gampad/clk?id=126839071&iu=/4140/ostg.clktrk
