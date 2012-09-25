From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 1/4] gre: fix handling of key 0
Date: Mon, 24 Sep 2012 21:12:23 -0700
Message-ID: <20120925041259.115596016@vyatta.com>
References: <20120925041222.056704869@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:44181 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751769Ab2IYEQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 00:16:27 -0400
Content-Disposition: inline; filename=gre-key0.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE driver incorrectly uses zero as a flag value. Zero is a perfectly
valid value for key, and the tunnel should match packets with no key only
with tunnels created without key, and vice versa.

This is a slightly visible  change since previously it might be possible to
construct a working tunnel that sent key 0 and received only because
of the key wildcard of zero.  I.e the sender sent key of zero, but tunnel
was defined without key.

Note: using gre key 0 requires iproute2 utilities v3.2 or later.
The original utility code was broken as well.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/ip_gre.c	2012-08-15 08:59:22.958704223 -0700
+++ b/net/ipv4/ip_gre.c	2012-09-12 09:40:04.420959235 -0700
@@ -214,11 +214,25 @@ static struct rtnl_link_stats64 *ipgre_g
 	return tot;
 }
 
+/* Does key in tunnel parameters match packet */
+static bool ipgre_key_match(const struct ip_tunnel_parm *p,
+			    __u32 flags, __be32 key)
+{
+	if (p->i_flags & GRE_KEY) {
+		if (flags & GRE_KEY)
+			return key == p->i_key;
+		else
+			return false;	/* key expected, none present */
+	} else
+		return !(flags & GRE_KEY);
+}
+
 /* Given src, dst and key, find appropriate for input tunnel. */
 
 static struct ip_tunnel *ipgre_tunnel_lookup(struct net_device *dev,
 					     __be32 remote, __be32 local,
-					     __be32 key, __be16 gre_proto)
+					     __u32 flags, __be32 key,
+					     __be16 gre_proto)
 {
 	struct net *net = dev_net(dev);
 	int link = dev->ifindex;
@@ -233,10 +247,12 @@ static struct ip_tunnel *ipgre_tunnel_lo
 	for_each_ip_tunnel_rcu(ign->tunnels_r_l[h0 ^ h1]) {
 		if (local != t->parms.iph.saddr ||
 		    remote != t->parms.iph.daddr ||
-		    key != t->parms.i_key ||
 		    !(t->dev->flags & IFF_UP))
 			continue;
 
+		if (!ipgre_key_match(&t->parms, flags, key))
+			continue;
+
 		if (t->dev->type != ARPHRD_IPGRE &&
 		    t->dev->type != dev_type)
 			continue;
@@ -257,10 +273,12 @@ static struct ip_tunnel *ipgre_tunnel_lo
 
 	for_each_ip_tunnel_rcu(ign->tunnels_r[h0 ^ h1]) {
 		if (remote != t->parms.iph.daddr ||
-		    key != t->parms.i_key ||
 		    !(t->dev->flags & IFF_UP))
 			continue;
 
+		if (!ipgre_key_match(&t->parms, flags, key))
+			continue;
+
 		if (t->dev->type != ARPHRD_IPGRE &&
 		    t->dev->type != dev_type)
 			continue;
@@ -283,10 +301,12 @@ static struct ip_tunnel *ipgre_tunnel_lo
 		if ((local != t->parms.iph.saddr &&
 		     (local != t->parms.iph.daddr ||
 		      !ipv4_is_multicast(local))) ||
-		    key != t->parms.i_key ||
 		    !(t->dev->flags & IFF_UP))
 			continue;
 
+		if (!ipgre_key_match(&t->parms, flags, key))
+			continue;
+
 		if (t->dev->type != ARPHRD_IPGRE &&
 		    t->dev->type != dev_type)
 			continue;
@@ -489,6 +509,7 @@ static void ipgre_err(struct sk_buff *sk
 	const int code = icmp_hdr(skb)->code;
 	struct ip_tunnel *t;
 	__be16 flags;
+	__be32 key = 0;
 
 	flags = p[0];
 	if (flags&(GRE_CSUM|GRE_KEY|GRE_SEQ|GRE_ROUTING|GRE_VERSION)) {
@@ -505,6 +526,9 @@ static void ipgre_err(struct sk_buff *sk
 	if (skb_headlen(skb) < grehlen)
 		return;
 
+	if (flags & GRE_KEY)
+		key = *(((__be32 *)p) + (grehlen / 4) - 1);
+
 	switch (type) {
 	default:
 	case ICMP_PARAMETERPROB:
@@ -535,9 +559,8 @@ static void ipgre_err(struct sk_buff *sk
 
 	rcu_read_lock();
 	t = ipgre_tunnel_lookup(skb->dev, iph->daddr, iph->saddr,
-				flags & GRE_KEY ?
-				*(((__be32 *)p) + (grehlen / 4) - 1) : 0,
-				p[1]);
+				flags, key, p[1]);
+
 	if (t == NULL)
 		goto out;
 
@@ -642,9 +665,10 @@ static int ipgre_rcv(struct sk_buff *skb
 	gre_proto = *(__be16 *)(h + 2);
 
 	rcu_read_lock();
-	if ((tunnel = ipgre_tunnel_lookup(skb->dev,
-					  iph->saddr, iph->daddr, key,
-					  gre_proto))) {
+	tunnel = ipgre_tunnel_lookup(skb->dev,
+				     iph->saddr, iph->daddr, flags, key,
+				     gre_proto);
+	if (tunnel) {
 		struct pcpu_tstats *tstats;
 
 		secpath_reset(skb);
