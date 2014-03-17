From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next] ieee802154: properly unshare skbs in ieee802154 *_rcv functions
Date: Mon, 17 Mar 2014 16:41:28 +0100
Message-ID: <1395070888-1130-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:53957 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756604AbaCQPli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 11:41:38 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s2HFfZ9p009115
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 16:41:36 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ieee802154 sockets do not properly unshare received skbs, which leads to
panics (at least) when they are used in conjunction with 6lowpan, so
run skb_share_check on received skbs.
6lowpan also contains a use-after-free, which is trivially fixed by
replacing the inlined skb_share_check with the explicit call.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/ieee802154/6lowpan_rtnl.c |   29 +++++++++++++----------------
 net/ieee802154/dgram.c        |    3 +++
 net/ieee802154/raw.c          |    3 +++
 3 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 602c6e0..c6d1afb 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -444,51 +444,48 @@ static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[])
 static int lowpan_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct packet_type *pt, struct net_device *orig_dev)
 {
-	struct sk_buff *local_skb;
 	int ret;
 
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
+		goto drop;
+
 	if (!netif_running(dev))
 		goto drop_skb;
 
 	if (dev->type != ARPHRD_IEEE802154)
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
-			ret = process_data(local_skb);
+			ret = process_data(skb);
 			if (ret == NET_RX_DROP)
 				goto drop;
 			break;
 		case LOWPAN_DISPATCH_FRAG1:	/* first fragment header */
-			ret = lowpan_frag_rcv(local_skb, LOWPAN_DISPATCH_FRAG1);
+			ret = lowpan_frag_rcv(skb, LOWPAN_DISPATCH_FRAG1);
 			if (ret == 1) {
-				ret = process_data(local_skb);
+				ret = process_data(skb);
 				if (ret == NET_RX_DROP)
 					goto drop;
 			}
 			break;
 		case LOWPAN_DISPATCH_FRAGN:	/* next fragments headers */
-			ret = lowpan_frag_rcv(local_skb, LOWPAN_DISPATCH_FRAGN);
+			ret = lowpan_frag_rcv(skb, LOWPAN_DISPATCH_FRAGN);
 			if (ret == 1) {
-				ret = process_data(local_skb);
+				ret = process_data(skb);
 				if (ret == NET_RX_DROP)
 					goto drop;
 			}
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 66e0c90..4f6fba9 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -341,6 +341,9 @@ out:
 
 static int dgram_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
+	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+		return NET_RX_DROP;
+
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index 41f538b..fadd3bf 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -209,6 +209,9 @@ out:
 
 static int raw_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
+	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+		return NET_RX_DROP;
+
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
-- 
1.7.9.5
