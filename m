From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next v2] ieee802154: properly unshare skbs in ieee802154 *_rcv functions
Date: Mon, 17 Mar 2014 18:30:19 +0100
Message-ID: <1395077419-20456-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from selenium.quasiparticle.net ([188.40.96.248]:42492 "EHLO
	quasiparticle.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756696AbaCQRal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 13:30:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ieee802154 sockets do not properly unshare received skbs, which leads to
panics (at least) when they are used in conjunction with 6lowpan, so
run skb_share_check on received skbs.
6lowpan also contains a use-after-free, which is trivially fixed by
replacing the inlined skb_share_check with the explicit call.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/ieee802154/6lowpan_rtnl.c | 29 +++++++++++++----------------
 net/ieee802154/dgram.c        |  4 ++++
 net/ieee802154/raw.c          |  4 ++++
 3 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 6060394..0f5a69e 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -447,10 +447,13 @@ static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[])
 static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct packet_type *pt, struct net_device *orig_dev)
 {
-	struct sk_buff *local_skb;
 	struct ieee802154_hdr hdr;
 	int ret;
 
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
+		goto drop;
+
 	if (!netif_running(dev))
 		goto drop_skb;
 
@@ -460,42 +463,36 @@ static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (ieee802154_hdr_peek_addrs(skb, &hdr) < 0)
 		goto drop_skb;
 
-	local_skb = skb_clone(skb, GFP_ATOMIC);
-	if (!local_skb)
-		goto drop_skb;
-
-	kfree_skb(skb);
-
 	/* check that it's our buffer */
 	if (skb->data[0] == LOWPAN_DISPATCH_IPV6) {
-		local_skb->protocol = htons(ETH_P_IPV6);
-		local_skb->pkt_type = PACKET_HOST;
+		skb->protocol = htons(ETH_P_IPV6);
+		skb->pkt_type = PACKET_HOST;
 
 		/* Pull off the 1-byte of 6lowpan header. */
-		skb_pull(local_skb, 1);
+		skb_pull(skb, 1);
 
-		ret = lowpan_give_skb_to_devices(local_skb, NULL);
+		ret = lowpan_give_skb_to_devices(skb, NULL);
 		if (ret == NET_RX_DROP)
 			goto drop;
 	} else {
 		switch (skb->data[0] & 0xe0) {
 		case LOWPAN_DISPATCH_IPHC:	/* ipv6 datagram */
-			ret = process_data(local_skb, &hdr);
+			ret = process_data(skb, &hdr);
 			if (ret == NET_RX_DROP)
 				goto drop;
 			break;
 		case LOWPAN_DISPATCH_FRAG1:	/* first fragment header */
-			ret = lowpan_frag_rcv(local_skb, LOWPAN_DISPATCH_FRAG1);
+			ret = lowpan_frag_rcv(skb, LOWPAN_DISPATCH_FRAG1);
 			if (ret == 1) {
-				ret = process_data(local_skb, &hdr);
+				ret = process_data(skb, &hdr);
 				if (ret == NET_RX_DROP)
 					goto drop;
 			}
 			break;
 		case LOWPAN_DISPATCH_FRAGN:	/* next fragments headers */
-			ret = lowpan_frag_rcv(local_skb, LOWPAN_DISPATCH_FRAGN);
+			ret = lowpan_frag_rcv(skb, LOWPAN_DISPATCH_FRAGN);
 			if (ret == 1) {
-				ret = process_data(local_skb, &hdr);
+				ret = process_data(skb, &hdr);
 				if (ret == NET_RX_DROP)
 					goto drop;
 			}
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 4c47154..6d251a3 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -329,6 +329,10 @@ out:
 
 static int dgram_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
+		return NET_RX_DROP;
+
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index e5258cf..74d54fa 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -213,6 +213,10 @@ out:
 
 static int raw_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
+		return NET_RX_DROP;
+
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
-- 
1.9.0
