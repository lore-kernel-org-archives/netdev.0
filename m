From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Tue, 2 Dec 2003 02:04:10 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312020158120.2728-100000@u.domain.uli>
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

> On Tue, 2 Dec 2003 01:30:17 +0200 (EET)
> Julian Anastasov <ja@ssi.bg> wrote:
>
> > 	I would suspect all rth->fl.fl4_tos checks too.
> > It seems we need toskeys[2] and a second for loop if tos!=0.
> > What about rewriting them to (rth->fl.fl4_tos == toskeys[j]).
>
> I disagree, and this is related to my most recent email
> in this thread.

	No, only input routes match strictly tos, ip_rt_redirect()
is such example that matches input routes.

> This packet we are reacting to for PMTU purposes could only
> have come from us if the TOS matches precisely.

	In this case we can react to packet routed with tos=0.
We match output routes only. I do not see another place that needs such 
fix.

	Example patch (not tested):

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1350  -> 1.1351 
#	    net/ipv4/route.c	1.73    -> 1.74   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/12/02	ja@ssi.bg	1.1351
# [IPV4]: ip_rt_frag_needed: fl4_tos accepts wildcard value for output routes
# --------------------------------------------
#
diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	Tue Dec  2 02:00:54 2003
+++ b/net/ipv4/route.c	Tue Dec  2 02:00:54 2003
@@ -1239,19 +1239,21 @@
 
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
+	u8 toskeys[2] = { tos, 0 };
 
 	if (ipv4_config.no_pmtu_disc)
 		return 0;
 
+	for (j = 0; j < (tos ? 2 : 1); j++)
 	for (i = 0; i < 2; i++) {
-		unsigned hash = rt_hash_code(daddr, skeys[i], tos);
+		unsigned hash = rt_hash_code(daddr, skeys[i], toskeys[j]);
 
 		rcu_read_lock();
 		for (rth = rt_hash_table[hash].chain; rth;
@@ -1261,7 +1263,7 @@
 			    rth->fl.fl4_src == skeys[i] &&
 			    rth->rt_dst  == daddr &&
 			    rth->rt_src  == iph->saddr &&
-			    rth->fl.fl4_tos == tos &&
+			    rth->fl.fl4_tos == toskeys[j] &&
 			    rth->fl.iif == 0 &&
 			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU))) {
 				unsigned short mtu = new_mtu;

Regards

--
Julian Anastasov <ja@ssi.bg>
