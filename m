From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Tue, 2 Dec 2003 03:53:53 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312020341520.2728-100000@u.domain.uli>
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

On Mon, 1 Dec 2003, David S. Miller wrote:

> I disagree, and this is related to my most recent email
> in this thread.
>
> This packet we are reacting to for PMTU purposes could only
> have come from us if the TOS matches precisely.

	Here is what I have for today. I assume all ip_route_output
callers provide valid tos (not a wildcard). As result, only RTO_ONLINK and 
oif have wildcard value. I'm not sure if ip_rt_frag_needed needs an iif 
argument, may be yes?

	Also, it seems ip_rt_redirect needs the 'tos, tos | RTO_ONLINK'
array too as in ip_rt_frag_needed. Not included yet.

	Another problem: it seems __ip_route_output_key does not
hash with valid tos key bits, fix included below:

--- net/ipv4/route.c.orig	Tue Dec  2 03:25:59 2003
+++ net/ipv4/route.c	Tue Dec  2 03:37:27 2003
@@ -1239,19 +1239,25 @@
 
 unsigned short ip_rt_frag_needed(struct iphdr *iph, unsigned short new_mtu)
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
+	int iif = 0; // Can be argument
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
@@ -1261,7 +1267,8 @@
 			    rth->fl.fl4_src == skeys[i] &&
 			    rth->rt_dst  == daddr &&
 			    rth->rt_src  == iph->saddr &&
-			    rth->fl.fl4_tos == tos &&
+			    rth->fl.fl4_tos == toskeys[j] &&
+			    rth->fl.oif == ikeys[k] &&
 			    rth->fl.iif == 0 &&
 			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU))) {
 				unsigned short mtu = new_mtu;
@@ -2214,7 +2221,8 @@
 	unsigned hash;
 	struct rtable *rth;
 
-	hash = rt_hash_code(flp->fl4_dst, flp->fl4_src ^ (flp->oif << 5), flp->fl4_tos);
+	hash = rt_hash_code(flp->fl4_dst, flp->fl4_src ^ (flp->oif << 5),
+		flp->fl4_tos & (IPTOS_RT_MASK | RTO_ONLINK));
 
 	rcu_read_lock();
 	for (rth = rt_hash_table[hash].chain; rth; rth = rth->u.rt_next) {

Regards

--
Julian Anastasov <ja@ssi.bg>
