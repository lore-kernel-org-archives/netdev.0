From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv4: delete the statements limit icmp message in ip_error()
Date: Sun, 12 Jan 2014 17:52:20 +0800
Message-ID: <52D265D4.9050600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63965 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbaALJwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 04:52:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Because after the icmp_send() is called, the icmpv4_xrlim_allow()
will be called to limit the icmp message too.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/route.c | 21 +--------------------
 1 file changed, 1 insertion(+), 20 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f8da282..e521de1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -900,10 +900,7 @@ static int ip_error(struct sk_buff *skb)
 {
 	struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
 	struct rtable *rt = skb_rtable(skb);
-	struct inet_peer *peer;
-	unsigned long now;
 	struct net *net;
-	bool send;
 	int code;
 
 	net = dev_net(rt->dst.dev);
@@ -936,23 +933,7 @@ static int ip_error(struct sk_buff *skb)
 		break;
 	}
 
-	peer = inet_getpeer_v4(net->ipv4.peers, ip_hdr(skb)->saddr, 1);
-
-	send = true;
-	if (peer) {
-		now = jiffies;
-		peer->rate_tokens += now - peer->rate_last;
-		if (peer->rate_tokens > ip_rt_error_burst)
-			peer->rate_tokens = ip_rt_error_burst;
-		peer->rate_last = now;
-		if (peer->rate_tokens >= ip_rt_error_cost)
-			peer->rate_tokens -= ip_rt_error_cost;
-		else
-			send = false;
-		inet_putpeer(peer);
-	}
-	if (send)
-		icmp_send(skb, ICMP_DEST_UNREACH, code, 0);
+	icmp_send(skb, ICMP_DEST_UNREACH, code, 0);
 
 out:	kfree_skb(skb);
 	return 0;
-- 
1.8.3.1
