From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Wed, 3 Dec 2003 01:40:06 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312030121130.1237-100000@u.domain.uli>
References: <20031201155005.1c515793.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: herbert@gondor.apana.org.au, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031201155005.1c515793.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	I'm appending new version that handles all missing cases for 
hashed values on icmp error:

- ip_rt_frag_needed now provides interface index
- ip_rt_redirect checks for tos|RTO_ONLINK too
- ip_rt_frag_needed checks also for tos|RTO_ONLINK and oif!=0
- __ip_route_output_key now ignores illegal bits (bit 1) from tos

	Please review and edit if needed.

diff -Nru a/include/net/route.h b/include/net/route.h
--- a/include/net/route.h	Tue Dec  2 23:37:17 2003
+++ b/include/net/route.h	Tue Dec  2 23:37:17 2003
@@ -122,7 +122,7 @@
 extern int		ip_route_output_key(struct rtable **, struct flowi *flp);
 extern int		ip_route_output_flow(struct rtable **rp, struct flowi *flp, struct sock *sk, int flags);
 extern int		ip_route_input(struct sk_buff*, u32 dst, u32 src, u8 tos, struct net_device *devin);
-extern unsigned short	ip_rt_frag_needed(struct iphdr *iph, unsigned short new_mtu);
+extern unsigned short	ip_rt_frag_needed(int iif, struct iphdr *iph, unsigned short new_mtu);
 extern void		ip_rt_send_redirect(struct sk_buff *skb);
 
 extern unsigned		inet_addr_type(u32 addr);
diff -Nru a/net/ipv4/icmp.c b/net/ipv4/icmp.c
--- a/net/ipv4/icmp.c	Tue Dec  2 23:37:17 2003
+++ b/net/ipv4/icmp.c	Tue Dec  2 23:37:17 2003
@@ -626,7 +626,7 @@
 							 "and DF set.\n",
 					       NIPQUAD(iph->daddr));
 			} else {
-				info = ip_rt_frag_needed(iph,
+				info = ip_rt_frag_needed(skb->dev->ifindex, iph,
 						     ntohs(icmph->un.frag.mtu));
 				if (!info)
 					goto out;
diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	Tue Dec  2 23:37:17 2003
+++ b/net/ipv4/route.c	Tue Dec  2 23:37:17 2003
@@ -967,11 +967,12 @@
 void ip_rt_redirect(u32 old_gw, u32 daddr, u32 new_gw,
 		    u32 saddr, u8 tos, struct net_device *dev)
 {
-	int i, k;
+	int i, j, k;
 	struct in_device *in_dev = in_dev_get(dev);
 	struct rtable *rth, **rthp;
 	u32  skeys[2] = { saddr, 0 };
 	int  ikeys[2] = { dev->ifindex, 0 };
+	u8 toskeys[2];
 
 	tos &= IPTOS_RT_MASK;
 
@@ -992,11 +993,15 @@
 			goto reject_redirect;
 	}
 
+	toskeys[0] = tos;
+	toskeys[1] = tos | RTO_ONLINK;
+	if (saddr && daddr)
+	for (j = 0; j < 2; j++)
 	for (i = 0; i < 2; i++) {
 		for (k = 0; k < 2; k++) {
 			unsigned hash = rt_hash_code(daddr,
 						     skeys[i] ^ (ikeys[k] << 5),
-						     tos);
+						     toskeys[j]);
 
 			rthp=&rt_hash_table[hash].chain;
 
@@ -1007,7 +1012,7 @@
 				smp_read_barrier_depends();
 				if (rth->fl.fl4_dst != daddr ||
 				    rth->fl.fl4_src != skeys[i] ||
-				    rth->fl.fl4_tos != tos ||
+				    rth->fl.fl4_tos != toskeys[j] ||
 				    rth->fl.oif != ikeys[k] ||
 				    rth->fl.iif != 0) {
 					rthp = &rth->u.rt_next;
@@ -1237,21 +1242,26 @@
 	return 68;
 }
 
-unsigned short ip_rt_frag_needed(struct iphdr *iph, unsigned short new_mtu)
+unsigned short ip_rt_frag_needed(int iif, struct iphdr *iph, unsigned short new_mtu)
 {
-	int i;
+	int i, j, k;
 	unsigned short old_mtu = ntohs(iph->tot_len);
 	struct rtable *rth;
 	u32  skeys[2] = { iph->saddr, 0, };
 	u32  daddr = iph->daddr;
 	u8   tos = iph->tos & IPTOS_RT_MASK;
 	unsigned short est_mtu = 0;
+	u8 toskeys[2] = { tos, tos | RTO_ONLINK };
+	int  ikeys[2] = { iif, 0 };
 
 	if (ipv4_config.no_pmtu_disc)
 		return 0;
 
+	for (k = 0; k < (iif ? 2 : 1); k++)
+	for (j = 0; j < 2; j++)
 	for (i = 0; i < 2; i++) {
-		unsigned hash = rt_hash_code(daddr, skeys[i], tos);
+		unsigned hash = rt_hash_code(daddr, skeys[i] ^ (ikeys[k] << 5),
+					     toskeys[j]);
 
 		rcu_read_lock();
 		for (rth = rt_hash_table[hash].chain; rth;
@@ -1261,7 +1271,8 @@
 			    rth->fl.fl4_src == skeys[i] &&
 			    rth->rt_dst  == daddr &&
 			    rth->rt_src  == iph->saddr &&
-			    rth->fl.fl4_tos == tos &&
+			    rth->fl.fl4_tos == toskeys[j] &&
+			    rth->fl.oif == ikeys[k] &&
 			    rth->fl.iif == 0 &&
 			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU))) {
 				unsigned short mtu = new_mtu;
@@ -2213,8 +2224,9 @@
 {
 	unsigned hash;
 	struct rtable *rth;
+	u8 tos = flp->fl4_tos & (IPTOS_RT_MASK | RTO_ONLINK);
 
-	hash = rt_hash_code(flp->fl4_dst, flp->fl4_src ^ (flp->oif << 5), flp->fl4_tos);
+	hash = rt_hash_code(flp->fl4_dst, flp->fl4_src ^ (flp->oif << 5), tos);
 
 	rcu_read_lock();
 	for (rth = rt_hash_table[hash].chain; rth; rth = rth->u.rt_next) {
@@ -2226,8 +2238,7 @@
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
