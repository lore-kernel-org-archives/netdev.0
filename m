From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Thu, 4 Dec 2003 00:03:20 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312032345190.1168-100000@u.domain.uli>
References: <20031202163902.2deb43a7.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: herbert@gondor.apana.org.au, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031202163902.2deb43a7.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 2 Dec 2003, David S. Miller wrote:

> You changes mean that for routes with specific output interfaces,
> we will ignore ICMPs for those routes that arrive on other interfaces
> due to assymetric routing.
>
> Why don't you create a seperate patch that just has the TOS masking
> changes?  That's much less controversial and thus something I'm likely
> to apply.

	Here is a new version, all changes are:

- ip_rt_redirect works for entries oif=IIF and oif=0 as before

- ip_rt_redirect now supports RTO_ONLINK

- ip_rt_frag_needed now supports RTO_ONLINK and all oif!=0

- ifindex is not anymore a hash key. This is required for
ip_rt_frag_needed to deliver the event to all entries no
matter the oif key. I'm not sure if this is for good or for
bad for the hash table distribution. I hope jenkins hash is
ready for this as it is not a common case to have multiple
oifs per one saddr-daddr-tos.

- __ip_route_output_key now ignores illegal bits (bit 1) from tos

diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	Wed Dec  3 23:37:00 2003
+++ b/net/ipv4/route.c	Wed Dec  3 23:37:00 2003
@@ -967,11 +967,11 @@
 void ip_rt_redirect(u32 old_gw, u32 daddr, u32 new_gw,
 		    u32 saddr, u8 tos, struct net_device *dev)
 {
-	int i, k;
+	int i, j;
 	struct in_device *in_dev = in_dev_get(dev);
 	struct rtable *rth, **rthp;
 	u32  skeys[2] = { saddr, 0 };
-	int  ikeys[2] = { dev->ifindex, 0 };
+	u8 toskeys[2];
 
 	tos &= IPTOS_RT_MASK;
 
@@ -992,11 +992,12 @@
 			goto reject_redirect;
 	}
 
+	toskeys[0] = tos;
+	toskeys[1] = tos | RTO_ONLINK;
+	if (saddr && daddr)
 	for (i = 0; i < 2; i++) {
-		for (k = 0; k < 2; k++) {
-			unsigned hash = rt_hash_code(daddr,
-						     skeys[i] ^ (ikeys[k] << 5),
-						     tos);
+		for (j = 0; j < 2; j++) {
+			unsigned hash = rt_hash_code(daddr, skeys[i], toskeys[j]);
 
 			rthp=&rt_hash_table[hash].chain;
 
@@ -1007,8 +1008,9 @@
 				smp_read_barrier_depends();
 				if (rth->fl.fl4_dst != daddr ||
 				    rth->fl.fl4_src != skeys[i] ||
-				    rth->fl.fl4_tos != tos ||
-				    rth->fl.oif != ikeys[k] ||
+				    rth->fl.fl4_tos != toskeys[j] ||
+				    (rth->fl.oif &&
+				     rth->fl.oif != dev->ifindex) ||
 				    rth->fl.iif != 0) {
 					rthp = &rth->u.rt_next;
 					continue;
@@ -1105,8 +1107,7 @@
 		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
 			   rt->u.dst.expires) {
 			unsigned hash = rt_hash_code(rt->fl.fl4_dst,
-						     rt->fl.fl4_src ^
-							(rt->fl.oif << 5),
+						     rt->fl.fl4_src,
 						     rt->fl.fl4_tos);
 #if RT_CACHE_DEBUG >= 1
 			printk(KERN_DEBUG "ip_rt_advice: redirect to "
@@ -1239,19 +1240,21 @@
 
 unsigned short ip_rt_frag_needed(struct iphdr *iph, unsigned short new_mtu)
 {
-	int i;
+	int i, j;
 	unsigned short old_mtu = ntohs(iph->tot_len);
 	struct rtable *rth;
 	u32  skeys[2] = { iph->saddr, 0, };
 	u32  daddr = iph->daddr;
 	u8   tos = iph->tos & IPTOS_RT_MASK;
 	unsigned short est_mtu = 0;
+	u8 toskeys[2] = { tos, tos | RTO_ONLINK };
 
 	if (ipv4_config.no_pmtu_disc)
 		return 0;
 
+	for (j = 0; j < 2; j++)
 	for (i = 0; i < 2; i++) {
-		unsigned hash = rt_hash_code(daddr, skeys[i], tos);
+		unsigned hash = rt_hash_code(daddr, skeys[i], toskeys[j]);
 
 		rcu_read_lock();
 		for (rth = rt_hash_table[hash].chain; rth;
@@ -1261,7 +1264,7 @@
 			    rth->fl.fl4_src == skeys[i] &&
 			    rth->rt_dst  == daddr &&
 			    rth->rt_src  == iph->saddr &&
-			    rth->fl.fl4_tos == tos &&
+			    rth->fl.fl4_tos == toskeys[j] &&
 			    rth->fl.iif == 0 &&
 			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU))) {
 				unsigned short mtu = new_mtu;
@@ -1503,7 +1506,7 @@
 	RT_CACHE_STAT_INC(in_slow_mc);
 
 	in_dev_put(in_dev);
-	hash = rt_hash_code(daddr, saddr ^ (dev->ifindex << 5), tos);
+	hash = rt_hash_code(daddr, saddr, tos);
 	return rt_intern_hash(hash, rth, (struct rtable**) &skb->dst);
 
 e_nobufs:
@@ -1554,7 +1557,7 @@
 	if (!in_dev)
 		goto out;
 
-	hash = rt_hash_code(daddr, saddr ^ (fl.iif << 5), tos);
+	hash = rt_hash_code(daddr, saddr, tos);
 
 	/* Check for the most weird martians, which can be not detected
 	   by fib_lookup.
@@ -1847,7 +1850,7 @@
 	int iif = dev->ifindex;
 
 	tos &= IPTOS_RT_MASK;
-	hash = rt_hash_code(daddr, saddr ^ (iif << 5), tos);
+	hash = rt_hash_code(daddr, saddr, tos);
 
 	rcu_read_lock();
 	for (rth = rt_hash_table[hash].chain; rth; rth = rth->u.rt_next) {
@@ -2190,7 +2193,7 @@
 
 	rth->rt_flags = flags;
 
-	hash = rt_hash_code(oldflp->fl4_dst, oldflp->fl4_src ^ (oldflp->oif << 5), tos);
+	hash = rt_hash_code(oldflp->fl4_dst, oldflp->fl4_src, tos);
 	err = rt_intern_hash(hash, rth, rp);
 done:
 	if (free_res)
@@ -2213,8 +2216,9 @@
 {
 	unsigned hash;
 	struct rtable *rth;
+	u8 tos = flp->fl4_tos & (IPTOS_RT_MASK | RTO_ONLINK);
 
-	hash = rt_hash_code(flp->fl4_dst, flp->fl4_src ^ (flp->oif << 5), flp->fl4_tos);
+	hash = rt_hash_code(flp->fl4_dst, flp->fl4_src, tos);
 
 	rcu_read_lock();
 	for (rth = rt_hash_table[hash].chain; rth; rth = rth->u.rt_next) {
@@ -2226,8 +2230,7 @@
 #ifdef CONFIG_IP_ROUTE_FWMARK
 		    rth->fl.fl4_fwmark == flp->fl4_fwmark &&
 #endif
-		    !((rth->fl.fl4_tos ^ flp->fl4_tos) &
-			    (IPTOS_RT_MASK | RTO_ONLINK))) {
+		    rth->fl.fl4_tos == tos) {
 			rth->u.dst.lastuse = jiffies;
 			dst_hold(&rth->u.dst);
 			rth->u.dst.__use++;

Regards

--
Julian Anastasov <ja@ssi.bg>
