From: Alan Ott <alan@signal11.us>
Subject: [PATCH v2 2/2] 6lowpan: Handle uncompressed IPv6 packets over 6LoWPAN
Date: Thu, 17 Jan 2013 00:09:48 -0500
Message-ID: <1358399388-30062-3-git-send-email-alan@signal11.us>
References: <1358315037-10043-1-git-send-email-alan@signal11.us>
 <1358399388-30062-1-git-send-email-alan@signal11.us>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Tony Cheneau <tony.cheneau@amnesiak.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alan Ott <alan@signal11.us>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358399388-30062-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handle the reception of uncompressed packets (dispatch type = IPv6).

Signed-off-by: Alan Ott <alan@signal11.us>
---
 net/ieee802154/6lowpan.c | 41 ++++++++++++++++++++++++++++++++---------
 1 file changed, 32 insertions(+), 9 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 1714cfa..09cba81 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1147,19 +1147,42 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 
 	/* check that it's our buffer */
-	switch (skb->data[0] & 0xe0) {
-	case LOWPAN_DISPATCH_IPHC:	/* ipv6 datagram */
-	case LOWPAN_DISPATCH_FRAG1:	/* first fragment header */
-	case LOWPAN_DISPATCH_FRAGN:	/* next fragments headers */
-		local_skb = skb_clone(skb, GFP_ATOMIC);
+	if (skb->data[0] == LOWPAN_DISPATCH_IPV6) {
+		/* Copy the packet so that the IPv6 header is
+		 * properly aligned.
+		 */
+		local_skb = skb_copy_expand(skb, NET_SKB_PAD - 1,
+					    skb_tailroom(skb), GFP_ATOMIC);
 		if (!local_skb)
 			goto drop;
-		lowpan_process_data(local_skb);
 
+		local_skb->protocol = htons(ETH_P_IPV6);
+		local_skb->pkt_type = PACKET_HOST;
+
+		/* Pull off the 1-byte of 6lowpan header. */
+		skb_pull(local_skb, 1);
+		skb_reset_network_header(local_skb);
+		skb_set_transport_header(local_skb, sizeof(struct ipv6hdr));
+
+		lowpan_give_skb_to_devices(local_skb);
+
+		kfree_skb(local_skb);
 		kfree_skb(skb);
-		break;
-	default:
-		break;
+	} else {
+		switch (skb->data[0] & 0xe0) {
+		case LOWPAN_DISPATCH_IPHC:	/* ipv6 datagram */
+		case LOWPAN_DISPATCH_FRAG1:	/* first fragment header */
+		case LOWPAN_DISPATCH_FRAGN:	/* next fragments headers */
+			local_skb = skb_clone(skb, GFP_ATOMIC);
+			if (!local_skb)
+				goto drop;
+			lowpan_process_data(local_skb);
+
+			kfree_skb(skb);
+			break;
+		default:
+			break;
+		}
 	}
 
 	return NET_RX_SUCCESS;
-- 
1.7.11.2
