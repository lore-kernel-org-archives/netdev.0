From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC nf-next-2.6] conntrack: per cpu nf_conntrack_untracked
Date: Tue, 01 Jun 2010 18:20:03 +0200
Message-ID: <1275409203.2738.227.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
	 <1271948029.7895.5707.camel@edumazet-laptop>
	 <20100422155123.GA2524@linux.vnet.ibm.com>
	 <1271952128.7895.5851.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	 <1272056237.4599.7.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>
	 <1272139861.20714.525.camel@edumazet-laptop>
	 <1272292568.13192.43.camel@jdb-workstation>
	 <1275340896.2478.26.camel@edumazet-laptop>
	 <AANLkTikw3uonDB4nPXg8FVFN_07F_wq0SA_ayyAHL6VM@mail.gmail.com>
	 <1275368732.2478.88.camel@edumazet-laptop>  <4C04DE73.6050605@trash.net>
	 <1275388310.2738.2.camel@edumazet-laptop>  <4C04E3E2.7020209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:52074 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920Ab0FAQUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 12:20:09 -0400
In-Reply-To: <4C04E3E2.7020209@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 juin 2010 =C3=A0 12:41 +0200, Patrick McHardy a =C3=A9crit =
:

> > BTW, I notice nf_conntrack_untracked is incorrectly annotated
> > '__read_mostly'.
> >=20
> > It can be written very often :(
> >=20
> > Should'nt we special case it and let be really const ?
>=20
> That would need quite a bit of special-casing to avoid touching
> the reference counts. So far this is completely hidden, so I'd
> say it just shouldn't be marked __read_mostly. Alternatively we
> can make "untracked" a nfctinfo state.

I tried this suggestion, (a new IP_CT_UNTRACKED ctinfo), over a per_cpu
untracked ct, but its a bit hard.

=46or example, I cannot find a way to change ctnetlink_conntrack_event(=
) :

	if (ct =3D=3D &nf_conntrack_untracked)
		return 0;

Maybe this piece of code is not necessary, we should not come here
anyway, or it means several packets could store events for this (shared=
)
ct ?

Obviously, an IPS_UNTRACKED bit would be much easier to implement.
Would it be acceptable ?


Preliminary patch with IP_CT_UNTRACKED, probably not working at all...

 include/linux/netfilter/nf_conntrack_common.h  |    3 +
 include/net/netfilter/nf_conntrack.h           |   11 +++--
 include/net/netfilter/nf_conntrack_core.h      |    2=20
 net/ipv4/netfilter/nf_nat_core.c               |    4 +
 net/ipv4/netfilter/nf_nat_standalone.c         |    2=20
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    4 -
 net/netfilter/nf_conntrack_core.c              |   32 +++++++++------
 net/netfilter/nf_conntrack_netlink.c           |    6 +-
 net/netfilter/xt_CT.c                          |   13 +++---
 net/netfilter/xt_NOTRACK.c                     |    4 -
 net/netfilter/xt_TEE.c                         |    8 +--
 net/netfilter/xt_cluster.c                     |    2=20
 net/netfilter/xt_conntrack.c                   |    2=20
 net/netfilter/xt_socket.c                      |    2=20
 14 files changed, 58 insertions(+), 37 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/li=
nux/netfilter/nf_conntrack_common.h
index 14e6d32..5f7c947 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -15,6 +15,9 @@ enum ip_conntrack_info {
            IP_CT_DIR_ORIGINAL); may be a retransmission. */
 	IP_CT_NEW,
=20
+	/* Untracked */
+	IP_CT_UNTRACKED,
+
 	/* >=3D this indicates reply direction */
 	IP_CT_IS_REPLY,
=20
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilt=
er/nf_conntrack.h
index bde095f..884ade9 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -175,7 +175,7 @@ static inline struct nf_conn *
 nf_ct_get(const struct sk_buff *skb, enum ip_conntrack_info *ctinfo)
 {
 	*ctinfo =3D skb->nfctinfo;
-	return (struct nf_conn *)skb->nfct;
+	return container_of(skb->nfct, struct nf_conn, ct_general);
 }
=20
 /* decrement reference count on a conntrack */
@@ -261,7 +261,7 @@ extern s16 (*nf_ct_nat_offset)(const struct nf_conn=
 *ct,
 			       u32 seq);
=20
 /* Fake conntrack entry for untracked connections */
-extern struct nf_conn nf_conntrack_untracked;
+DECLARE_PER_CPU(struct nf_conn, pcpu_nf_conntrack_untracked);
=20
 /* Iterate over all conntracks: if iter returns true, it's deleted. */
 extern void
@@ -291,7 +291,12 @@ static inline int nf_ct_is_dying(struct nf_conn *c=
t)
=20
 static inline int nf_ct_is_untracked(const struct sk_buff *skb)
 {
-	return (skb->nfct =3D=3D &nf_conntrack_untracked.ct_general);
+	return (skb->nfctinfo =3D=3D IP_CT_UNTRACKED);
+}
+
+static inline int nf_ct_is_tracked(const struct sk_buff *skb)
+{
+	return (skb->nfctinfo !=3D IP_CT_UNTRACKED);
 }
=20
 extern int nf_conntrack_set_hashsize(const char *val, struct kernel_pa=
ram *kp);
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/ne=
tfilter/nf_conntrack_core.h
index 3d7524f..8dd05ea 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -60,7 +60,7 @@ static inline int nf_conntrack_confirm(struct sk_buff=
 *skb)
 	struct nf_conn *ct =3D (struct nf_conn *)skb->nfct;
 	int ret =3D NF_ACCEPT;
=20
-	if (ct && ct !=3D &nf_conntrack_untracked) {
+	if (ct && nf_ct_is_tracked(skb)) {
 		if (!nf_ct_is_confirmed(ct))
 			ret =3D __nf_conntrack_confirm(skb);
 		if (likely(ret =3D=3D NF_ACCEPT))
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_n=
at_core.c
index 4f8bddb..a797999 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -719,6 +719,7 @@ static int __init nf_nat_init(void)
 {
 	size_t i;
 	int ret;
+	int cpu;
=20
 	need_ipv4_conntrack();
=20
@@ -742,7 +743,8 @@ static int __init nf_nat_init(void)
 	spin_unlock_bh(&nf_nat_lock);
=20
 	/* Initialize fake conntrack so that NAT will skip it */
-	nf_conntrack_untracked.status |=3D IPS_NAT_DONE_MASK;
+	for_each_possible_cpu(cpu)
+		per_cpu(pcpu_nf_conntrack_untracked,cpu).status |=3D IPS_NAT_DONE_MA=
SK;
=20
 	l3proto =3D nf_ct_l3proto_find_get((u_int16_t)AF_INET);
=20
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilte=
r/nf_nat_standalone.c
index beb2581..17af2bb 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -98,7 +98,7 @@ nf_nat_fn(unsigned int hooknum,
 		return NF_ACCEPT;
=20
 	/* Don't try to NAT if this packet is not conntracked */
-	if (ct =3D=3D &nf_conntrack_untracked)
+	if (ctinfo =3D=3D IP_CT_UNTRACKED)
 		return NF_ACCEPT;
=20
 	nat =3D nfct_nat(ct);
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/=
netfilter/nf_conntrack_proto_icmpv6.c
index 9be8177..b67029c 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -208,8 +208,8 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	type =3D icmp6h->icmp6_type - 130;
 	if (type >=3D 0 && type < sizeof(noct_valid_new) &&
 	    noct_valid_new[type]) {
-		skb->nfct =3D &nf_conntrack_untracked.ct_general;
-		skb->nfctinfo =3D IP_CT_NEW;
+		skb->nfct =3D &__get_cpu_var(pcpu_nf_conntrack_untracked).ct_general=
;
+		skb->nfctinfo =3D IP_CT_UNTRACKED;
 		nf_conntrack_get(skb->nfct);
 		return NF_ACCEPT;
 	}
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index eeeb8bc..eea5df1 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -62,8 +62,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 unsigned int nf_conntrack_max __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_max);
=20
-struct nf_conn nf_conntrack_untracked __read_mostly;
-EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
+DEFINE_PER_CPU(struct nf_conn, pcpu_nf_conntrack_untracked);
+EXPORT_PER_CPU_SYMBOL(pcpu_nf_conntrack_untracked);
=20
 static int nf_conntrack_hash_rnd_initted;
 static unsigned int nf_conntrack_hash_rnd;
@@ -1185,10 +1185,16 @@ static void nf_ct_release_dying_list(struct net=
 *net)
=20
 static void nf_conntrack_cleanup_init_net(void)
 {
-	/* wait until all references to nf_conntrack_untracked are dropped */
-	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
+	int cpu, use;
+	for (;;) {
+		use =3D 0;
+		for_each_possible_cpu(cpu)
+			use +=3D atomic_read(&per_cpu(pcpu_nf_conntrack_untracked, cpu).ct_=
general.use) - 1;
+		/* wait until all references to nf_conntrack_untracked are dropped *=
/
+		if (!use)
+			break;
 		schedule();
-
+	}
 	nf_conntrack_helper_fini();
 	nf_conntrack_proto_fini();
 #ifdef CONFIG_NF_CONNTRACK_ZONES
@@ -1325,6 +1331,7 @@ static int nf_conntrack_init_init_net(void)
 {
 	int max_factor =3D 8;
 	int ret;
+	int cpu;
=20
 	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
 	 * machine has 512 buckets. >=3D 1GB machines have 16384 buckets. */
@@ -1362,14 +1369,15 @@ static int nf_conntrack_init_init_net(void)
 	if (ret < 0)
 		goto err_extend;
 #endif
-	/* Set up fake conntrack: to never be deleted, not in any hashes */
-#ifdef CONFIG_NET_NS
-	nf_conntrack_untracked.ct_net =3D &init_net;
-#endif
-	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
-	/*  - and look it like as a confirmed connection */
-	set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
+	/* Set up fake conntracks: to never be deleted, not in any hashes */
+	for_each_possible_cpu(cpu) {
+		struct nf_conn *ct =3D &per_cpu(pcpu_nf_conntrack_untracked, cpu);
=20
+		write_pnet(&ct->ct_net, &init_net);
+		atomic_set(&ct->ct_general.use, 1);
+	/*  - and look it like as a confirmed connection */
+		__set_bit(IPS_CONFIRMED_BIT, &ct->status);
+	}
 	return 0;
=20
 #ifdef CONFIG_NF_CONNTRACK_ZONES
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_co=
nntrack_netlink.c
index c42ff6a..ac21514 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -479,9 +479,9 @@ ctnetlink_conntrack_event(unsigned int events, stru=
ct nf_ct_event *item)
 	unsigned int flags =3D 0, group;
 	int err;
=20
-	/* ignore our fake conntrack entry */
-	if (ct =3D=3D &nf_conntrack_untracked)
-		return 0;
+//	/* ignore our fake conntrack entry */
+//	if (ct =3D=3D &nf_conntrack_untracked)
+//		return 0;
=20
 	if (events & (1 << IPCT_DESTROY)) {
 		type =3D IPCTNL_MSG_CT_DELETE;
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 562bf32..5723f9a 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -29,9 +29,13 @@ static unsigned int xt_ct_target(struct sk_buff *skb=
,
 	if (skb->nfct !=3D NULL)
 		return XT_CONTINUE;
=20
+	skb->nfctinfo =3D IP_CT_NEW;
+	if (info->flags & XT_CT_NOTRACK) {
+		ct =3D &__get_cpu_var(pcpu_nf_conntrack_untracked);
+		skb->nfctinfo =3D IP_CT_UNTRACKED;
+	}
 	atomic_inc(&ct->ct_general.use);
 	skb->nfct =3D &ct->ct_general;
-	skb->nfctinfo =3D IP_CT_NEW;
=20
 	return XT_CONTINUE;
 }
@@ -67,8 +71,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param=
 *par)
 		return -EINVAL;
=20
 	if (info->flags & XT_CT_NOTRACK) {
-		ct =3D &nf_conntrack_untracked;
-		atomic_inc(&ct->ct_general.use);
+		ct =3D &__get_cpu_var(pcpu_nf_conntrack_untracked);
 		goto out;
 	}
=20
@@ -132,14 +135,14 @@ static void xt_ct_tg_destroy(const struct xt_tgdt=
or_param *par)
 	struct nf_conn *ct =3D info->ct;
 	struct nf_conn_help *help;
=20
-	if (ct !=3D &nf_conntrack_untracked) {
+	if (!(info->flags & XT_CT_NOTRACK)) {
 		help =3D nfct_help(ct);
 		if (help)
 			module_put(help->helper->me);
=20
 		nf_ct_l3proto_module_put(par->family);
+		nf_ct_put(info->ct);
 	}
-	nf_ct_put(info->ct);
 }
=20
 static struct xt_target xt_ct_tg __read_mostly =3D {
diff --git a/net/netfilter/xt_NOTRACK.c b/net/netfilter/xt_NOTRACK.c
index 512b912..9547b58 100644
--- a/net/netfilter/xt_NOTRACK.c
+++ b/net/netfilter/xt_NOTRACK.c
@@ -23,8 +23,8 @@ notrack_tg(struct sk_buff *skb, const struct xt_actio=
n_param *par)
 	   If there is a real ct entry correspondig to this packet,
 	   it'll hang aroun till timing out. We don't deal with it
 	   for performance reasons. JK */
-	skb->nfct =3D &nf_conntrack_untracked.ct_general;
-	skb->nfctinfo =3D IP_CT_NEW;
+	skb->nfct =3D &__get_cpu_var(pcpu_nf_conntrack_untracked).ct_general;
+	skb->nfctinfo =3D IP_CT_UNTRACKED;
 	nf_conntrack_get(skb->nfct);
=20
 	return XT_CONTINUE;
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 859d9fd..b8e46b3 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -104,8 +104,8 @@ tee_tg4(struct sk_buff *skb, const struct xt_action=
_param *par)
 #ifdef WITH_CONNTRACK
 	/* Avoid counting cloned packets towards the original connection. */
 	nf_conntrack_put(skb->nfct);
-	skb->nfct     =3D &nf_conntrack_untracked.ct_general;
-	skb->nfctinfo =3D IP_CT_NEW;
+	skb->nfct     =3D &__get_cpu_var(pcpu_nf_conntrack_untracked).ct_gene=
ral;
+	skb->nfctinfo =3D IP_CT_UNTRACKED;
 	nf_conntrack_get(skb->nfct);
 #endif
 	/*
@@ -177,8 +177,8 @@ tee_tg6(struct sk_buff *skb, const struct xt_action=
_param *par)
=20
 #ifdef WITH_CONNTRACK
 	nf_conntrack_put(skb->nfct);
-	skb->nfct     =3D &nf_conntrack_untracked.ct_general;
-	skb->nfctinfo =3D IP_CT_NEW;
+	skb->nfct     =3D &__get_cpu_var(pcpu_nf_conntrack_untracked).ct_gene=
ral;
+	skb->nfctinfo =3D IP_CT_UNTRACKED;
 	nf_conntrack_get(skb->nfct);
 #endif
 	if (par->hooknum =3D=3D NF_INET_PRE_ROUTING ||
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 30b95a1..b26f94d 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -120,7 +120,7 @@ xt_cluster_mt(const struct sk_buff *skb, struct xt_=
action_param *par)
 	if (ct =3D=3D NULL)
 		return false;
=20
-	if (ct =3D=3D &nf_conntrack_untracked)
+	if (nf_ct_is_untracked(skb))
 		return false;
=20
 	if (ct->master)
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.=
c
index 39681f1..95bcfbb 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -123,7 +123,7 @@ conntrack_mt(const struct sk_buff *skb, struct xt_a=
ction_param *par,
=20
 	ct =3D nf_ct_get(skb, &ctinfo);
=20
-	if (ct =3D=3D &nf_conntrack_untracked)
+	if (nf_ct_is_untracked(skb))
 		statebit =3D XT_CONNTRACK_STATE_UNTRACKED;
 	else if (ct !=3D NULL)
 		statebit =3D XT_CONNTRACK_STATE_BIT(ctinfo);
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 3d54c23..1f760b5 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -127,7 +127,7 @@ socket_match(const struct sk_buff *skb, struct xt_a=
ction_param *par,
 	 * reply packet of an established SNAT-ted connection. */
=20
 	ct =3D nf_ct_get(skb, &ctinfo);
-	if (ct && (ct !=3D &nf_conntrack_untracked) &&
+	if (ct && nf_ct_is_tracked(skb) &&
 	    ((iph->protocol !=3D IPPROTO_ICMP &&
 	      ctinfo =3D=3D IP_CT_IS_REPLY + IP_CT_ESTABLISHED) ||
 	     (iph->protocol =3D=3D IPPROTO_ICMP &&


