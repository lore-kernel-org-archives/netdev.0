From: David Miller <davem@davemloft.net>
Subject: [PATCH] tcp: Validate route interface in early demux.
Date: Thu, 21 Jun 2012 15:03:45 -0700 (PDT)
Message-ID: <20120621.150345.1099437864390577092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760581Ab2FUWDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 18:03:48 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id D3B87587173
	for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 15:03:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Otherwise we might violate reverse path filtering.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_ipv4.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 13857df..21e22a0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1676,6 +1676,7 @@ int tcp_v4_early_demux(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	const struct iphdr *iph;
 	const struct tcphdr *th;
+	struct net_device *dev;
 	struct sock *sk;
 	int err;
 
@@ -1695,10 +1696,11 @@ int tcp_v4_early_demux(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, ip_hdrlen(skb) + th->doff * 4))
 		goto out_err;
 
+	dev = skb->dev;
 	sk = __inet_lookup_established(net, &tcp_hashinfo,
 				       iph->saddr, th->source,
 				       iph->daddr, th->dest,
-				       skb->dev->ifindex);
+				       dev->ifindex);
 	if (sk) {
 		skb->sk = sk;
 		skb->destructor = sock_edemux;
@@ -1707,8 +1709,12 @@ int tcp_v4_early_demux(struct sk_buff *skb)
 			if (dst)
 				dst = dst_check(dst, 0);
 			if (dst) {
-				skb_dst_set_noref(skb, dst);
-				err = 0;
+				struct rtable *rt = (struct rtable *) dst;
+
+				if (rt->rt_iif == dev->ifindex) {
+					skb_dst_set_noref(skb, dst);
+					err = 0;
+				}
 			}
 		}
 	}
-- 
1.7.10
