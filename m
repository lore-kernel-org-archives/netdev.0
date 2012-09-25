From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 2/4] gre: remove unnecessary rcu_read_lock/unlock
Date: Mon, 24 Sep 2012 21:12:24 -0700
Message-ID: <20120925041259.194332134@vyatta.com>
References: <20120925041222.056704869@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:44180 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827Ab2IYEQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 00:16:27 -0400
Content-Disposition: inline; filename=gre-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gre function pointers for receive and error handling are
always called (from gre.c) with rcu_read_lock already held.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/ipv4/ip_gre.c  |   19 ++++++-------------
 net/ipv6/ip6_gre.c |   10 +---------
 2 files changed, 7 insertions(+), 22 deletions(-)

--- a/net/ipv6/ip6_gre.c	2012-09-24 17:33:22.766821472 -0700
+++ b/net/ipv6/ip6_gre.c	2012-09-24 18:12:00.783449055 -0700
@@ -437,14 +437,12 @@ static void ip6gre_err(struct sk_buff *s
 	ipv6h = (const struct ipv6hdr *)skb->data;
 	p = (__be16 *)(skb->data + offset);
 
-	rcu_read_lock();
-
 	t = ip6gre_tunnel_lookup(skb->dev, &ipv6h->daddr, &ipv6h->saddr,
 				flags & GRE_KEY ?
 				*(((__be32 *)p) + (grehlen / 4) - 1) : 0,
 				p[1]);
 	if (t == NULL)
-		goto out;
+		return;
 
 	switch (type) {
 		__u32 teli;
@@ -489,8 +487,6 @@ static void ip6gre_err(struct sk_buff *s
 	else
 		t->err_count = 1;
 	t->err_time = jiffies;
-out:
-	rcu_read_unlock();
 }
 
 static inline void ip6gre_ecn_decapsulate_ipv4(const struct ip6_tnl *t,
@@ -528,7 +524,7 @@ static int ip6gre_rcv(struct sk_buff *sk
 	__be16 gre_proto;
 
 	if (!pskb_may_pull(skb, sizeof(struct in6_addr)))
-		goto drop_nolock;
+		goto drop;
 
 	ipv6h = ipv6_hdr(skb);
 	h = skb->data;
@@ -539,7 +535,7 @@ static int ip6gre_rcv(struct sk_buff *sk
 		   - We do not support routing headers.
 		 */
 		if (flags&(GRE_VERSION|GRE_ROUTING))
-			goto drop_nolock;
+			goto drop;
 
 		if (flags&GRE_CSUM) {
 			switch (skb->ip_summed) {
@@ -567,7 +563,6 @@ static int ip6gre_rcv(struct sk_buff *sk
 
 	gre_proto = *(__be16 *)(h + 2);
 
-	rcu_read_lock();
 	tunnel = ip6gre_tunnel_lookup(skb->dev,
 					  &ipv6h->saddr, &ipv6h->daddr, key,
 					  gre_proto);
@@ -646,14 +641,11 @@ static int ip6gre_rcv(struct sk_buff *sk
 
 		netif_rx(skb);
 
-		rcu_read_unlock();
 		return 0;
 	}
 	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
 
 drop:
-	rcu_read_unlock();
-drop_nolock:
 	kfree_skb(skb);
 	return 0;
 }
--- a/net/ipv4/ip_gre.c	2012-09-24 17:33:33.298715280 -0700
+++ b/net/ipv4/ip_gre.c	2012-09-24 18:11:52.383533752 -0700
@@ -557,37 +557,34 @@ static void ipgre_err(struct sk_buff *sk
 		break;
 	}
 
-	rcu_read_lock();
 	t = ipgre_tunnel_lookup(skb->dev, iph->daddr, iph->saddr,
 				flags, key, p[1]);
 
 	if (t == NULL)
-		goto out;
+		return;
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
 		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
 				 t->parms.link, 0, IPPROTO_GRE, 0);
-		goto out;
+		return;
 	}
 	if (type == ICMP_REDIRECT) {
 		ipv4_redirect(skb, dev_net(skb->dev), t->parms.link, 0,
 			      IPPROTO_GRE, 0);
-		goto out;
+		return;
 	}
 	if (t->parms.iph.daddr == 0 ||
 	    ipv4_is_multicast(t->parms.iph.daddr))
-		goto out;
+		return;
 
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
-		goto out;
+		return;
 
 	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
 		t->err_count++;
 	else
 		t->err_count = 1;
 	t->err_time = jiffies;
-out:
-	rcu_read_unlock();
 }
 
 static inline void ipgre_ecn_decapsulate(const struct iphdr *iph, struct sk_buff *skb)
@@ -625,7 +622,7 @@ static int ipgre_rcv(struct sk_buff *skb
 	__be16 gre_proto;
 
 	if (!pskb_may_pull(skb, 16))
-		goto drop_nolock;
+		goto drop;
 
 	iph = ip_hdr(skb);
 	h = skb->data;
@@ -636,7 +633,7 @@ static int ipgre_rcv(struct sk_buff *skb
 		   - We do not support routing headers.
 		 */
 		if (flags&(GRE_VERSION|GRE_ROUTING))
-			goto drop_nolock;
+			goto drop;
 
 		if (flags&GRE_CSUM) {
 			switch (skb->ip_summed) {
@@ -664,7 +661,6 @@ static int ipgre_rcv(struct sk_buff *skb
 
 	gre_proto = *(__be16 *)(h + 2);
 
-	rcu_read_lock();
 	tunnel = ipgre_tunnel_lookup(skb->dev,
 				     iph->saddr, iph->daddr, flags, key,
 				     gre_proto);
@@ -740,14 +736,11 @@ static int ipgre_rcv(struct sk_buff *skb
 
 		netif_rx(skb);
 
-		rcu_read_unlock();
 		return 0;
 	}
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
 drop:
-	rcu_read_unlock();
-drop_nolock:
 	kfree_skb(skb);
 	return 0;
 }
