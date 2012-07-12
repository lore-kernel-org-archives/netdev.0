From: David Miller <davem@davemloft.net>
Subject: [PATCH 04/16] ipv4: Rearrange arguments to ip_rt_redirect()
Date: Thu, 12 Jul 2012 01:11:03 -0700 (PDT)
Message-ID: <20120712.011103.2266457079037284143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758683Ab2GLILD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:11:03 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id BEFA85824C8
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:11:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Pass in the SKB rather than just the IP addresses, so that policy
and other aspects can reside in ip_rt_redirect() rather then
icmp_redirect().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    3 +--
 net/ipv4/icmp.c     |   36 ++++++------------------------------
 net/ipv4/route.c    |   23 +++++++++++++++++++----
 3 files changed, 26 insertions(+), 36 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 5236236..b140278 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -108,8 +108,7 @@ extern struct ip_rt_acct __percpu *ip_rt_acct;
 
 struct in_device;
 extern int		ip_rt_init(void);
-extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
-				       __be32 src, struct net_device *dev);
+extern void		ip_rt_redirect(struct sk_buff *skb, __be32 new_gw);
 extern void		rt_cache_flush(struct net *net, int how);
 extern void		rt_cache_flush_batch(struct net *net);
 extern struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp);
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5885146..70a7935 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -755,40 +755,16 @@ out_err:
 
 static void icmp_redirect(struct sk_buff *skb)
 {
-	const struct iphdr *iph;
-
-	if (skb->len < sizeof(struct iphdr))
-		goto out_err;
+	if (skb->len < sizeof(struct iphdr)) {
+		ICMP_INC_STATS_BH(dev_net(skb->dev), ICMP_MIB_INERRORS);
+		return;
+	}
 
-	/*
-	 *	Get the copied header of the packet that caused the redirect
-	 */
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
-		goto out;
-
-	iph = (const struct iphdr *)skb->data;
-
-	switch (icmp_hdr(skb)->code & 7) {
-	case ICMP_REDIR_NET:
-	case ICMP_REDIR_NETTOS:
-		/*
-		 * As per RFC recommendations now handle it as a host redirect.
-		 */
-	case ICMP_REDIR_HOST:
-	case ICMP_REDIR_HOSTTOS:
-		ip_rt_redirect(ip_hdr(skb)->saddr, iph->daddr,
-			       icmp_hdr(skb)->un.gateway,
-			       iph->saddr, skb->dev);
-		break;
-	}
+		return;
 
+	ip_rt_redirect(skb, icmp_hdr(skb)->un.gateway);
 	icmp_socket_deliver(skb, icmp_hdr(skb)->un.gateway);
-
-out:
-	return;
-out_err:
-	ICMP_INC_STATS_BH(dev_net(skb->dev), ICMP_MIB_INERRORS);
-	goto out;
 }
 
 /*
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a4de87f..f8921b4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1292,18 +1292,33 @@ static void ip_do_redirect(struct rtable *rt, __be32 old_gw, __be32 new_gw)
 }
 
 /* called in rcu_read_lock() section */
-void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
-		    __be32 saddr, struct net_device *dev)
+void ip_rt_redirect(struct sk_buff *skb, __be32 new_gw)
 {
-	int s, i;
+	const struct iphdr *iph = (const struct iphdr *) skb->data;
+	__be32 old_gw = ip_hdr(skb)->saddr;
+	__be32 daddr = iph->daddr;
+	__be32 saddr = iph->saddr;
+	struct net_device *dev = skb->dev;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
-	__be32 skeys[2] = { saddr, 0 };
 	int    ikeys[2] = { dev->ifindex, 0 };
+	__be32 skeys[2] = { saddr, 0 };
 	struct net *net;
+	int s, i;
 
 	if (!in_dev)
 		return;
 
+	switch (icmp_hdr(skb)->code & 7) {
+	case ICMP_REDIR_NET:
+	case ICMP_REDIR_NETTOS:
+	case ICMP_REDIR_HOST:
+	case ICMP_REDIR_HOSTTOS:
+		break;
+
+	default:
+		return;
+	}
+
 	net = dev_net(dev);
 	if (new_gw == old_gw || !IN_DEV_RX_REDIRECTS(in_dev) ||
 	    ipv4_is_multicast(new_gw) || ipv4_is_lbcast(new_gw) ||
-- 
1.7.10.4
