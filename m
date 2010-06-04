From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH nf-next-2.6] conntrack: IPS_UNTRACKED bit
Date: Fri, 04 Jun 2010 18:25:32 +0200
Message-ID: <1275668732.2482.201.camel@edumazet-laptop>
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
	 <1275368732.2478.88.camel@edumazet-laptop> <4C04DE73.6050605@trash.net>
	 <1275388310.2738.2.camel@edumazet-laptop> <4C04E3E2.7020209@trash.net>
	 <1275409203.2738.227.camel@edumazet-laptop> <4C08E62A.9020607@trash.net>
	 <AANLkTilKEpFTg5bH8d9UE3a3DVJNAGYz10Jgkt6lXtJ0@mail.gmail.com>
	 <4C08F1A4.2050906@trash.net>  <1275654964.2482.150.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:38239 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab0FDQZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 12:25:37 -0400
In-Reply-To: <1275654964.2482.150.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 juin 2010 =C3=A0 14:36 +0200, Eric Dumazet a =C3=A9crit =
:
> Le vendredi 04 juin 2010 =C3=A0 14:29 +0200, Patrick McHardy a =C3=A9=
crit :
> > Changli Gao wrote:
> > > On Fri, Jun 4, 2010 at 7:40 PM, Patrick McHardy <kaber@trash.net>=
 wrote:
> > >> Eric Dumazet wrote:
> > >>> Obviously, an IPS_UNTRACKED bit would be much easier to impleme=
nt.
> > >>> Would it be acceptable ?
> > >> That also would be fine. However the main idea behind using a nf=
ctinfo
> > >> bit was that we wouldn't need the untracked conntrack anymore at=
 all.
> > >> But I guess a per-cpu untrack conntrack would already be an impr=
ovement
> > >> over the current situation.
> > >=20
> > > I think Eric didn't mean ip_conntrack_info but ip_conntrack_statu=
s
> > > bit. Since we have had a IPS_TEMPLATE bit, I think another
> > > IPS_UNTRACKED bit is also acceptable.
> >=20
> > Yes, of course. But using one of these bits implies that we'd still
> > have the untracked conntrack.
>=20
> Yes, it was my idea, with a per_cpu untracked conntrack.
>=20
> I'll submit a patch, thanks.
>=20
>=20

Here is first part, introducing IPS_UNTRACKED bit and various helpers t=
o
abstract nf_conntrack_untracked access.

I'll cook second patch in a couple of hours for per_cpu conversion.

Thanks !

[PATCH nf-next-2.6] conntrack: IPS_UNTRACKED bit

NOTRACK makes all cpus share a cache line on nf_conntrack_untracked
twice per packet. This is bad for performance.
__read_mostly annotation is also a bad choice.

This patch introduces IPS_UNTRACKED bit so that we can use later a
per_cpu untrack structure more easily.

A new helper, nf_ct_untracked_get() returns a pointer to
nf_conntrack_untracked.

Another one, nf_ct_untracked_status_or() is used by nf_nat_init() to ad=
d
IPS_NAT_DONE_MASK bits to untracked status.

nf_ct_is_untracked() prototype is changed to work on a nf_conn pointer.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netfilter/nf_conntrack_common.h  |    4 ++++
 include/net/netfilter/nf_conntrack.h           |   12 +++++++++---
 include/net/netfilter/nf_conntrack_core.h      |    2 +-
 net/ipv4/netfilter/nf_nat_core.c               |    2 +-
 net/ipv4/netfilter/nf_nat_standalone.c         |    2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
 net/netfilter/nf_conntrack_core.c              |   11 ++++++++---
 net/netfilter/nf_conntrack_netlink.c           |    2 +-
 net/netfilter/xt_CT.c                          |    4 ++--
 net/netfilter/xt_NOTRACK.c                     |    2 +-
 net/netfilter/xt_TEE.c                         |    4 ++--
 net/netfilter/xt_cluster.c                     |    2 +-
 net/netfilter/xt_conntrack.c                   |   11 ++++++-----
 net/netfilter/xt_socket.c                      |    2 +-
 net/netfilter/xt_state.c                       |   14 ++++++++------
 15 files changed, 47 insertions(+), 29 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/li=
nux/netfilter/nf_conntrack_common.h
index 14e6d32..1afd18c 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -76,6 +76,10 @@ enum ip_conntrack_status {
 	/* Conntrack is a template */
 	IPS_TEMPLATE_BIT =3D 11,
 	IPS_TEMPLATE =3D (1 << IPS_TEMPLATE_BIT),
+
+	/* Conntrack is a fake untracked entry */
+	IPS_UNTRACKED_BIT =3D 12,
+	IPS_UNTRACKED =3D (1 << IPS_UNTRACKED_BIT),
 };
=20
 /* Connection tracking event types */
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilt=
er/nf_conntrack.h
index bde095f..3bc38c7 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -261,7 +261,13 @@ extern s16 (*nf_ct_nat_offset)(const struct nf_con=
n *ct,
 			       u32 seq);
=20
 /* Fake conntrack entry for untracked connections */
-extern struct nf_conn nf_conntrack_untracked;
+static inline struct nf_conn *nf_ct_untracked_get(void)
+{
+	extern struct nf_conn nf_conntrack_untracked;
+
+	return &nf_conntrack_untracked;
+}
+extern void nf_ct_untracked_status_or(unsigned long bits);
=20
 /* Iterate over all conntracks: if iter returns true, it's deleted. */
 extern void
@@ -289,9 +295,9 @@ static inline int nf_ct_is_dying(struct nf_conn *ct=
)
 	return test_bit(IPS_DYING_BIT, &ct->status);
 }
=20
-static inline int nf_ct_is_untracked(const struct sk_buff *skb)
+static inline int nf_ct_is_untracked(const struct nf_conn *ct)
 {
-	return (skb->nfct =3D=3D &nf_conntrack_untracked.ct_general);
+	return test_bit(IPS_UNTRACKED_BIT, &ct->status);
 }
=20
 extern int nf_conntrack_set_hashsize(const char *val, struct kernel_pa=
ram *kp);
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/ne=
tfilter/nf_conntrack_core.h
index 3d7524f..aced085 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -60,7 +60,7 @@ static inline int nf_conntrack_confirm(struct sk_buff=
 *skb)
 	struct nf_conn *ct =3D (struct nf_conn *)skb->nfct;
 	int ret =3D NF_ACCEPT;
=20
-	if (ct && ct !=3D &nf_conntrack_untracked) {
+	if (ct && !nf_ct_is_untracked(ct)) {
 		if (!nf_ct_is_confirmed(ct))
 			ret =3D __nf_conntrack_confirm(skb);
 		if (likely(ret =3D=3D NF_ACCEPT))
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_n=
at_core.c
index 4f8bddb..c7719b2 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -742,7 +742,7 @@ static int __init nf_nat_init(void)
 	spin_unlock_bh(&nf_nat_lock);
=20
 	/* Initialize fake conntrack so that NAT will skip it */
-	nf_conntrack_untracked.status |=3D IPS_NAT_DONE_MASK;
+	nf_ct_untracked_status_or(IPS_NAT_DONE_MASK);
=20
 	l3proto =3D nf_ct_l3proto_find_get((u_int16_t)AF_INET);
=20
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilte=
r/nf_nat_standalone.c
index beb2581..6723c68 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -98,7 +98,7 @@ nf_nat_fn(unsigned int hooknum,
 		return NF_ACCEPT;
=20
 	/* Don't try to NAT if this packet is not conntracked */
-	if (ct =3D=3D &nf_conntrack_untracked)
+	if (nf_ct_is_untracked(ct))
 		return NF_ACCEPT;
=20
 	nat =3D nfct_nat(ct);
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/=
netfilter/nf_conntrack_proto_icmpv6.c
index 9be8177..1df3c8b 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -208,7 +208,7 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 	type =3D icmp6h->icmp6_type - 130;
 	if (type >=3D 0 && type < sizeof(noct_valid_new) &&
 	    noct_valid_new[type]) {
-		skb->nfct =3D &nf_conntrack_untracked.ct_general;
+		skb->nfct =3D &nf_ct_untracked_get()->ct_general;
 		skb->nfctinfo =3D IP_CT_NEW;
 		nf_conntrack_get(skb->nfct);
 		return NF_ACCEPT;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index eeeb8bc..6c1da21 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -62,7 +62,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 unsigned int nf_conntrack_max __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_max);
=20
-struct nf_conn nf_conntrack_untracked __read_mostly;
+struct nf_conn nf_conntrack_untracked;
 EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
=20
 static int nf_conntrack_hash_rnd_initted;
@@ -1321,6 +1321,12 @@ EXPORT_SYMBOL_GPL(nf_conntrack_set_hashsize);
 module_param_call(hashsize, nf_conntrack_set_hashsize, param_get_uint,
 		  &nf_conntrack_htable_size, 0600);
=20
+void nf_ct_untracked_status_or(unsigned long bits)
+{
+	nf_conntrack_untracked.status |=3D bits;
+}
+EXPORT_SYMBOL_GPL(nf_ct_untracked_status_or);
+
 static int nf_conntrack_init_init_net(void)
 {
 	int max_factor =3D 8;
@@ -1368,8 +1374,7 @@ static int nf_conntrack_init_init_net(void)
 #endif
 	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
 	/*  - and look it like as a confirmed connection */
-	set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
-
+	nf_ct_untracked_status_or(IPS_CONFIRMED | IPS_UNTRACKED);
 	return 0;
=20
 #ifdef CONFIG_NF_CONNTRACK_ZONES
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_co=
nntrack_netlink.c
index c42ff6a..5bae1cd 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -480,7 +480,7 @@ ctnetlink_conntrack_event(unsigned int events, stru=
ct nf_ct_event *item)
 	int err;
=20
 	/* ignore our fake conntrack entry */
-	if (ct =3D=3D &nf_conntrack_untracked)
+	if (nf_ct_is_untracked(ct))
 		return 0;
=20
 	if (events & (1 << IPCT_DESTROY)) {
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 562bf32..0cb6053 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -67,7 +67,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param=
 *par)
 		return -EINVAL;
=20
 	if (info->flags & XT_CT_NOTRACK) {
-		ct =3D &nf_conntrack_untracked;
+		ct =3D nf_ct_untracked_get();
 		atomic_inc(&ct->ct_general.use);
 		goto out;
 	}
@@ -132,7 +132,7 @@ static void xt_ct_tg_destroy(const struct xt_tgdtor=
_param *par)
 	struct nf_conn *ct =3D info->ct;
 	struct nf_conn_help *help;
=20
-	if (ct !=3D &nf_conntrack_untracked) {
+	if (!nf_ct_is_untracked(ct)) {
 		help =3D nfct_help(ct);
 		if (help)
 			module_put(help->helper->me);
diff --git a/net/netfilter/xt_NOTRACK.c b/net/netfilter/xt_NOTRACK.c
index 512b912..9d78218 100644
--- a/net/netfilter/xt_NOTRACK.c
+++ b/net/netfilter/xt_NOTRACK.c
@@ -23,7 +23,7 @@ notrack_tg(struct sk_buff *skb, const struct xt_actio=
n_param *par)
 	   If there is a real ct entry correspondig to this packet,
 	   it'll hang aroun till timing out. We don't deal with it
 	   for performance reasons. JK */
-	skb->nfct =3D &nf_conntrack_untracked.ct_general;
+	skb->nfct =3D &nf_ct_untracked_get()->ct_general;
 	skb->nfctinfo =3D IP_CT_NEW;
 	nf_conntrack_get(skb->nfct);
=20
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 859d9fd..7a11826 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -104,7 +104,7 @@ tee_tg4(struct sk_buff *skb, const struct xt_action=
_param *par)
 #ifdef WITH_CONNTRACK
 	/* Avoid counting cloned packets towards the original connection. */
 	nf_conntrack_put(skb->nfct);
-	skb->nfct     =3D &nf_conntrack_untracked.ct_general;
+	skb->nfct     =3D &nf_ct_untracked_get()->ct_general;
 	skb->nfctinfo =3D IP_CT_NEW;
 	nf_conntrack_get(skb->nfct);
 #endif
@@ -177,7 +177,7 @@ tee_tg6(struct sk_buff *skb, const struct xt_action=
_param *par)
=20
 #ifdef WITH_CONNTRACK
 	nf_conntrack_put(skb->nfct);
-	skb->nfct     =3D &nf_conntrack_untracked.ct_general;
+	skb->nfct     =3D &nf_ct_untracked_get()->ct_general;
 	skb->nfctinfo =3D IP_CT_NEW;
 	nf_conntrack_get(skb->nfct);
 #endif
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 30b95a1..f4af1bf 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -120,7 +120,7 @@ xt_cluster_mt(const struct sk_buff *skb, struct xt_=
action_param *par)
 	if (ct =3D=3D NULL)
 		return false;
=20
-	if (ct =3D=3D &nf_conntrack_untracked)
+	if (nf_ct_is_untracked(ct))
 		return false;
=20
 	if (ct->master)
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.=
c
index 39681f1..e536710 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -123,11 +123,12 @@ conntrack_mt(const struct sk_buff *skb, struct xt=
_action_param *par,
=20
 	ct =3D nf_ct_get(skb, &ctinfo);
=20
-	if (ct =3D=3D &nf_conntrack_untracked)
-		statebit =3D XT_CONNTRACK_STATE_UNTRACKED;
-	else if (ct !=3D NULL)
-		statebit =3D XT_CONNTRACK_STATE_BIT(ctinfo);
-	else
+	if (ct) {
+		if (nf_ct_is_untracked(ct))
+			statebit =3D XT_CONNTRACK_STATE_UNTRACKED;
+		else
+			statebit =3D XT_CONNTRACK_STATE_BIT(ctinfo);
+	} else
 		statebit =3D XT_CONNTRACK_STATE_INVALID;
=20
 	if (info->match_flags & XT_CONNTRACK_STATE) {
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 3d54c23..1ca8990 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -127,7 +127,7 @@ socket_match(const struct sk_buff *skb, struct xt_a=
ction_param *par,
 	 * reply packet of an established SNAT-ted connection. */
=20
 	ct =3D nf_ct_get(skb, &ctinfo);
-	if (ct && (ct !=3D &nf_conntrack_untracked) &&
+	if (ct && !nf_ct_is_untracked(ct) &&
 	    ((iph->protocol !=3D IPPROTO_ICMP &&
 	      ctinfo =3D=3D IP_CT_IS_REPLY + IP_CT_ESTABLISHED) ||
 	     (iph->protocol =3D=3D IPPROTO_ICMP &&
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index e12e053..a507922 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -26,14 +26,16 @@ state_mt(const struct sk_buff *skb, struct xt_actio=
n_param *par)
 	const struct xt_state_info *sinfo =3D par->matchinfo;
 	enum ip_conntrack_info ctinfo;
 	unsigned int statebit;
+	struct nf_conn *ct =3D nf_ct_get(skb, &ctinfo);
=20
-	if (nf_ct_is_untracked(skb))
-		statebit =3D XT_STATE_UNTRACKED;
-	else if (!nf_ct_get(skb, &ctinfo))
+	if (!ct)
 		statebit =3D XT_STATE_INVALID;
-	else
-		statebit =3D XT_STATE_BIT(ctinfo);
-
+	else {
+		if (nf_ct_is_untracked(ct))
+			statebit =3D XT_STATE_UNTRACKED;
+		else
+			statebit =3D XT_STATE_BIT(ctinfo);
+	}
 	return (sinfo->statemask & statebit);
 }
=20


