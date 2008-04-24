From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: [PATCH] [IPV4]: Update MTU to all related cache entries in ip_rt_frag_needed()
Date: Thu, 24 Apr 2008 13:05:27 +0300
Message-ID: <48105B67.7060804@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:22502 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbYDXKFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 06:05:20 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1199433nfb.21
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 03:05:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add struct net_device parameter to ip_rt_frag_needed() and update MTU to
cache entries where ifindex is specified. This is similar to what is
already done in ip_rt_redirect().

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
I noticed this bug when using GRE tunnel bound to specific device. This
causes ip_gre to use ifindex in ip_route_output_key() lookups and the
results are not proper unless the MTU is updated for entries where
ifindex is specified (causing my tunneled packets to be dropped).

I have a patch for older kernels too if this is good for -stable.

 include/net/route.h |    2 +-
 net/ipv4/icmp.c     |    3 ++-
 net/ipv4/route.c    |   38 ++++++++++++++++++++++----------------
 3 files changed, 25 insertions(+), 18 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index c633880..fc836ff 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -116,7 +116,7 @@ extern int		__ip_route_output_key(struct net *, struct rtable **, const struct f
 extern int		ip_route_output_key(struct net *, struct rtable **, struct flowi *flp);
 extern int		ip_route_output_flow(struct net *, struct rtable **rp, struct flowi *flp, struct sock *sk, int flags);
 extern int		ip_route_input(struct sk_buff*, __be32 dst, __be32 src, u8 tos, struct net_device *devin);
-extern unsigned short	ip_rt_frag_needed(struct net *net, struct iphdr *iph, unsigned short new_mtu);
+extern unsigned short	ip_rt_frag_needed(struct net *net, struct iphdr *iph, unsigned short new_mtu, struct net_device *dev);
 extern void		ip_rt_send_redirect(struct sk_buff *skb);
 
 extern unsigned		inet_addr_type(struct net *net, __be32 addr);
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index c67d00e..8739735 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -691,7 +691,8 @@ static void icmp_unreach(struct sk_buff *skb)
 					       NIPQUAD(iph->daddr));
 			} else {
 				info = ip_rt_frag_needed(net, iph,
-						     ntohs(icmph->un.frag.mtu));
+							 ntohs(icmph->un.frag.mtu),
+							 skb->dev);
 				if (!info)
 					goto out;
 			}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 780e948..0d2f4da 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1429,11 +1429,13 @@ static inline unsigned short guess_mtu(unsigned short old_mtu)
 }
 
 unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
-				 unsigned short new_mtu)
+				 unsigned short new_mtu,
+				 struct net_device *dev)
 {
-	int i;
+	int i, k;
 	unsigned short old_mtu = ntohs(iph->tot_len);
 	struct rtable *rth;
+	int  ikeys[2] = { dev->ifindex, 0 };
 	__be32  skeys[2] = { iph->saddr, 0, };
 	__be32  daddr = iph->daddr;
 	unsigned short est_mtu = 0;
@@ -1441,22 +1443,26 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 	if (ipv4_config.no_pmtu_disc)
 		return 0;
 
-	for (i = 0; i < 2; i++) {
-		unsigned hash = rt_hash(daddr, skeys[i], 0);
+	for (k = 0; k < 2; k++) {
+		for (i = 0; i < 2; i++) {
+			unsigned hash = rt_hash(daddr, skeys[i], ikeys[k]);
 
-		rcu_read_lock();
-		for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
-		     rth = rcu_dereference(rth->u.dst.rt_next)) {
-			if (rth->fl.fl4_dst == daddr &&
-			    rth->fl.fl4_src == skeys[i] &&
-			    rth->rt_dst  == daddr &&
-			    rth->rt_src  == iph->saddr &&
-			    rth->fl.iif == 0 &&
-			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU)) &&
-			    net_eq(dev_net(rth->u.dst.dev), net) &&
-			    rth->rt_genid == atomic_read(&rt_genid)) {
+			rcu_read_lock();
+			for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
+			     rth = rcu_dereference(rth->u.dst.rt_next)) {
 				unsigned short mtu = new_mtu;
 
+				if (rth->fl.fl4_dst != daddr ||
+				    rth->fl.fl4_src != skeys[i] ||
+				    rth->rt_dst != daddr ||
+				    rth->rt_src != iph->saddr ||
+				    rth->fl.oif != ikeys[k] ||
+				    rth->fl.iif != 0 ||
+				    dst_metric_locked(&rth->u.dst, RTAX_MTU) ||
+				    !net_eq(dev_net(rth->u.dst.dev), net) ||
+				    rth->rt_genid != atomic_read(&rt_genid))
+					continue;
+
 				if (new_mtu < 68 || new_mtu >= old_mtu) {
 
 					/* BSD 4.2 compatibility hack :-( */
@@ -1482,8 +1488,8 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 					est_mtu = mtu;
 				}
 			}
+			rcu_read_unlock();
 		}
-		rcu_read_unlock();
 	}
 	return est_mtu ? : new_mtu;
 }
-- 
1.5.2.5

