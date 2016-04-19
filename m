From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH net-next 8/8] net: ipv4: listify ip_rcv_finish
Date: Tue, 19 Apr 2016 14:37:28 +0100
Message-ID: <57163498.50705@solarflare.com>
References: <5716338E.4050003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:48661 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752887AbcDSNhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 09:37:37 -0400
In-Reply-To: <5716338E.4050003@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 net/ipv4/ip_input.c | 58 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 53 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index e7d0d85..5bbc409 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -308,7 +308,8 @@ drop:
 	return true;
 }
 
-static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
+static int ip_rcv_finish_core(struct net *net, struct sock *sk,
+			      struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
@@ -385,13 +386,22 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 			goto drop;
 	}
 
-	return dst_input(skb);
+	return NET_RX_SUCCESS;
 
 drop:
 	kfree_skb(skb);
 	return NET_RX_DROP;
 }
 
+static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
+{
+	int ret = ip_rcv_finish_core(net, sk, skb);
+
+	if (ret != NET_RX_DROP)
+		ret = dst_input(skb);
+	return ret;
+}
+
 /*
  * 	Main IP Receive routine.
  */
@@ -501,16 +511,54 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 		       ip_rcv_finish);
 }
 
+static void ip_sublist_rcv_finish(struct sk_buff_head *list)
+{
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(list)) != NULL)
+		dst_input(skb);
+}
+
+static void ip_list_rcv_finish(struct net *net, struct sock *sk,
+			       struct sk_buff_head *list)
+{
+	struct dst_entry *curr_dst = NULL;
+	struct sk_buff_head sublist;
+	struct sk_buff *skb;
+
+	__skb_queue_head_init(&sublist);
+
+	while ((skb = __skb_dequeue(list)) != NULL) {
+		struct dst_entry *dst;
+
+		if (ip_rcv_finish_core(net, sk, skb) == NET_RX_DROP)
+			continue;
+
+		dst = skb_dst(skb);
+		if (skb_queue_empty(&sublist)) {
+			curr_dst = dst;
+		} else if (curr_dst != dst) {
+			/* dispatch old sublist */
+			ip_sublist_rcv_finish(&sublist);
+			/* start new sublist */
+			__skb_queue_head_init(&sublist);
+			curr_dst = dst;
+		}
+		/* add to current sublist */
+		__skb_queue_tail(&sublist, skb);
+	}
+	/* dispatch final sublist */
+	ip_sublist_rcv_finish(&sublist);
+}
+
 static void ip_sublist_rcv(struct sk_buff_head *list, struct net_device *dev,
 			   struct net *net)
 {
 	struct sk_buff_head sublist;
-	struct sk_buff *skb;
 
 	NF_HOOK_LIST(NFPROTO_IPV4, NF_INET_PRE_ROUTING, net, NULL,
 		     list, &sublist, dev, NULL, ip_rcv_finish);
-	while ((skb = __skb_dequeue(&sublist)) != NULL)
-		ip_rcv_finish(net, NULL, skb);
+	ip_list_rcv_finish(net, NULL, &sublist);
 }
 
 /* Receive a list of IP packets */
