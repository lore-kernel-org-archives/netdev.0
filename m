From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Sat, 6 Dec 2003 09:52:01 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312060907070.1673-100000@u.domain.uli>
References: <20031205124309.1490a2f4.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: herbert@gondor.apana.org.au, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031205124309.1490a2f4.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Fri, 5 Dec 2003, David S. Miller wrote:

> Let's discuss what RTO_ONLINK means :)
>
> It means, "Do not route this packet".  It goes to the local subnet
> and that's the end of the story.  Therefore there are no PMTU nor
> redirects to handle when this TOS bit is set.

	You are right about the case with redirects but for PMTUD
I'm still not sure. Here is one example: host A (we) thinks
that host B is onlink (rt_dst == rt_gateway). But host B runs
DNAT, tunneling or cluster software and forwards the packet
through other hosts which generate frag_needed. Such example
is IPVS TUN mode, I now see that it is not working because IPVS
on host B does not handle correctly the ICMP error and it can
not reach host A - a new difficult thing to fix.

> RTO_ONLINK is set by these two cases:
>
> 1) ARP
> 2) RAW/UDP sockets when MSG_DONTROUTE is specified by the user.

	UDP+RTO_ONLINK+PMTUD is still valid if we want to support
the above example setup. But I'm not sure someone will use
such combination of parameters. Should I remove the RTO_ONLINK
case from PMTUD?

	I have some questions about the redirects:

	Assume we have direct (rt_dst==rt_gateway) route with
SCOPE_HOST and shared_media is ON (if shared media is OFF
ip_fib_check_default already avoids SCOPE_HOST routes). I do
not see whether the standards cover such case, our target sends redirect
message but we are sure we hit the target IP directly. Is it supposed we
to change rt_gateway if rt_gateway==rt_dst ? I now included
such check in ip_rt_redirect but may be have to remove it.
IOW, the question is whether the ICMP redirects modify only
routes via gateway when shared_media is ON?

> So this patch still needs some work.

	OK, here is a new version, may be before the final one.
Changes from previous version:

- removed the RTO_ONLINK case from ip_rt_redirect

- removed the useless 'saddr && daddr' check which was added in
previous changes

- added temporarily 'rth->rt_dst == rth->rt_gateway' in
ip_rt_redirect. Is it needed?

diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	Sat Dec  6 09:05:58 2003
+++ b/net/ipv4/route.c	Sat Dec  6 09:05:58 2003
@@ -967,11 +967,10 @@
 void ip_rt_redirect(u32 old_gw, u32 daddr, u32 new_gw,
 		    u32 saddr, u8 tos, struct net_device *dev)
 {
-	int i, k;
+	int i;
 	struct in_device *in_dev = in_dev_get(dev);
 	struct rtable *rth, **rthp;
 	u32  skeys[2] = { saddr, 0 };
-	int  ikeys[2] = { dev->ifindex, 0 };
 
 	tos &= IPTOS_RT_MASK;
 
@@ -993,10 +992,7 @@
 	}
 
 	for (i = 0; i < 2; i++) {
-		for (k = 0; k < 2; k++) {
-			unsigned hash = rt_hash_code(daddr,
-						     skeys[i] ^ (ikeys[k] << 5),
-						     tos);
+			unsigned hash = rt_hash_code(daddr, skeys[i], tos);
 
 			rthp=&rt_hash_table[hash].chain;
 
@@ -1008,7 +1004,9 @@
 				if (rth->fl.fl4_dst != daddr ||
 				    rth->fl.fl4_src != skeys[i] ||
 				    rth->fl.fl4_tos != tos ||
-				    rth->fl.oif != ikeys[k] ||
+				    (rth->fl.oif &&
+				     rth->fl.oif != dev->ifindex) ||
+				    rth->rt_dst == rth->rt_gateway ||
 				    rth->fl.iif != 0) {
 					rthp = &rth->u.rt_next;
 					continue;
@@ -1075,7 +1073,6 @@
 			rcu_read_unlock();
 		do_next:
 			;
-		}
 	}
 	in_dev_put(in_dev);
 	return;
@@ -1105,8 +1102,7 @@
 		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
 			   rt->u.dst.expires) {
 			unsigned hash = rt_hash_code(rt->fl.fl4_dst,
-						     rt->fl.fl4_src ^
-							(rt->fl.oif << 5),
+						     rt->fl.fl4_src,
 						     rt->fl.fl4_tos);
 #if RT_CACHE_DEBUG >= 1
 			printk(KERN_DEBUG "ip_rt_advice: redirect to "
@@ -1239,19 +1235,21 @@
 
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
@@ -1261,7 +1259,7 @@
 			    rth->fl.fl4_src == skeys[i] &&
 			    rth->rt_dst  == daddr &&
 			    rth->rt_src  == iph->saddr &&
-			    rth->fl.fl4_tos == tos &&
+			    rth->fl.fl4_tos == toskeys[j] &&
 			    rth->fl.iif == 0 &&
 			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU))) {
 				unsigned short mtu = new_mtu;
@@ -1503,7 +1501,7 @@
 	RT_CACHE_STAT_INC(in_slow_mc);
 
 	in_dev_put(in_dev);
-	hash = rt_hash_code(daddr, saddr ^ (dev->ifindex << 5), tos);
+	hash = rt_hash_code(daddr, saddr, tos);
 	return rt_intern_hash(hash, rth, (struct rtable**) &skb->dst);
 
 e_nobufs:
@@ -1554,7 +1552,7 @@
 	if (!in_dev)
 		goto out;
 
-	hash = rt_hash_code(daddr, saddr ^ (fl.iif << 5), tos);
+	hash = rt_hash_code(daddr, saddr, tos);
 
 	/* Check for the most weird martians, which can be not detected
 	   by fib_lookup.
@@ -1847,7 +1845,7 @@
 	int iif = dev->ifindex;
 
 	tos &= IPTOS_RT_MASK;
-	hash = rt_hash_code(daddr, saddr ^ (iif << 5), tos);
+	hash = rt_hash_code(daddr, saddr, tos);
 
 	rcu_read_lock();
 	for (rth = rt_hash_table[hash].chain; rth; rth = rth->u.rt_next) {
@@ -2190,7 +2188,7 @@
 
 	rth->rt_flags = flags;
 
-	hash = rt_hash_code(oldflp->fl4_dst, oldflp->fl4_src ^ (oldflp->oif << 5), tos);
+	hash = rt_hash_code(oldflp->fl4_dst, oldflp->fl4_src, tos);
 	err = rt_intern_hash(hash, rth, rp);
 done:
 	if (free_res)
@@ -2213,8 +2211,9 @@
 {
 	unsigned hash;
 	struct rtable *rth;
+	u8 tos = flp->fl4_tos & (IPTOS_RT_MASK | RTO_ONLINK);
 
-	hash = rt_hash_code(flp->fl4_dst, flp->fl4_src ^ (flp->oif << 5), flp->fl4_tos);
+	hash = rt_hash_code(flp->fl4_dst, flp->fl4_src, tos);
 
 	rcu_read_lock();
 	for (rth = rt_hash_table[hash].chain; rth; rth = rth->u.rt_next) {
@@ -2226,8 +2225,7 @@
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
