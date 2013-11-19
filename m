From: Wolfgang Walter <linux@stwm.de>
Subject: Re: ipv6 fragmentation-related panic in netfilter
Date: Tue, 19 Nov 2013 23:27:40 +0100
Message-ID: <3998760.5g9L5dp08X@h2o.as.studentenwerk.mhn.de>
References: <2060a7d2-c307-4e30-b1d4-0bd26c904d6f@gmail.com> <19807032.ebUJct12DE@h2o.as.studentenwerk.mhn.de> <20131119124032.GS16541@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Tomas Hlavacek <tmshlvck@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131119124032.GS16541@order.stressinduktion.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 19. November 2013, 13:40:32 schrieb Hannes Frederic Sowa:
> On Tue, Nov 19, 2013 at 12:11:24PM +0100, Wolfgang Walter wrote:
> > Are there patches available? I can crash my 3.12 kernel easily doin=
g
> >=20
> > 	fping -p 20 -l -b 4000 bla
> >=20
> > 3.11.x does not expose this problem.
>=20
> Yes, see here:
>=20
> http://patchwork.ozlabs.org/patch/288967/
> http://patchwork.ozlabs.org/patch/288970/
>=20

This fixed it. The second patch did not cleanly apply to 3.12 due to
formatting changes or because some functions in 3.12 get

	unsigned int hooknum

instead of

	const struct nf_hook_ops *ops

I hopefully got it right:at least it works and no crashes any more :-).

I hope both patches go into stable soon.

Thanks,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts


Here is the modified version of the second patch if someone needs it (b=
ut no guarantee that it is correct):


diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c2d8933..f66f346 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -333,11 +333,6 @@ typedef unsigned int sk_buff_data_t;
 typedef unsigned char *sk_buff_data_t;
 #endif
=20
-#if defined(CONFIG_NF_DEFRAG_IPV4) || defined(CONFIG_NF_DEFRAG_IPV4_MO=
DULE) || \
-    defined(CONFIG_NF_DEFRAG_IPV6) || defined(CONFIG_NF_DEFRAG_IPV6_MO=
DULE)
-#define NET_SKBUFF_NF_DEFRAG_NEEDED 1
-#endif
-
 /**=20
  *	struct sk_buff - socket buffer
  *	@next: Next buffer in list
@@ -370,7 +365,6 @@ typedef unsigned char *sk_buff_data_t;
  *	@protocol: Packet protocol from driver
  *	@destructor: Destruct function
  *	@nfct: Associated connection, if any
- *	@nfct_reasm: netfilter conntrack re-assembly pointer
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
  *	@skb_iif: ifindex of device we arrived on
  *	@tc_index: Traffic control index
@@ -459,9 +453,6 @@ struct sk_buff {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
 	struct nf_conntrack	*nfct;
 #endif
-#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
-	struct sk_buff		*nfct_reasm;
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	struct nf_bridge_info	*nf_bridge;
 #endif
@@ -2605,18 +2596,6 @@ static inline void nf_conntrack_get(struct nf_co=
nntrack *nfct)
 		atomic_inc(&nfct->use);
 }
 #endif
-#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
-static inline void nf_conntrack_get_reasm(struct sk_buff *skb)
-{
-	if (skb)
-		atomic_inc(&skb->users);
-}
-static inline void nf_conntrack_put_reasm(struct sk_buff *skb)
-{
-	if (skb)
-		kfree_skb(skb);
-}
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 static inline void nf_bridge_put(struct nf_bridge_info *nf_bridge)
 {
@@ -2635,10 +2614,6 @@ static inline void nf_reset(struct sk_buff *skb)
 	nf_conntrack_put(skb->nfct);
 	skb->nfct =3D NULL;
 #endif
-#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
-	nf_conntrack_put_reasm(skb->nfct_reasm);
-	skb->nfct_reasm =3D NULL;
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	nf_bridge_put(skb->nf_bridge);
 	skb->nf_bridge =3D NULL;
@@ -2660,10 +2635,6 @@ static inline void __nf_copy(struct sk_buff *dst=
, const struct sk_buff *src)
 	nf_conntrack_get(src->nfct);
 	dst->nfctinfo =3D src->nfctinfo;
 #endif
-#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
-	dst->nfct_reasm =3D src->nfct_reasm;
-	nf_conntrack_get_reasm(src->nfct_reasm);
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	dst->nf_bridge  =3D src->nf_bridge;
 	nf_bridge_get(src->nf_bridge);
@@ -2675,9 +2646,6 @@ static inline void nf_copy(struct sk_buff *dst, c=
onst struct sk_buff *src)
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
 	nf_conntrack_put(dst->nfct);
 #endif
-#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
-	nf_conntrack_put_reasm(dst->nfct_reasm);
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	nf_bridge_put(dst->nf_bridge);
 #endif
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9c4d37e..772252d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -109,7 +109,6 @@ extern int ip_vs_conn_tab_size;
 struct ip_vs_iphdr {
 	__u32 len;	/* IPv4 simply where L4 starts
 			   IPv6 where L4 Transport Header starts */
-	__u32 thoff_reasm; /* Transport Header Offset in nfct_reasm skb */
 	__u16 fragoffs; /* IPv6 fragment offset, 0 if first frag (or not frag=
)*/
 	__s16 protocol;
 	__s32 flags;
@@ -117,34 +116,12 @@ struct ip_vs_iphdr {
 	union nf_inet_addr daddr;
 };
=20
-/* Dependency to module: nf_defrag_ipv6 */
-#if defined(CONFIG_NF_DEFRAG_IPV6) || defined(CONFIG_NF_DEFRAG_IPV6_MO=
DULE)
-static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb=
)
-{
-	return skb->nfct_reasm;
-}
-static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int of=
fset,
-				      int len, void *buffer,
-				      const struct ip_vs_iphdr *ipvsh)
-{
-	if (unlikely(ipvsh->fragoffs && skb_nfct_reasm(skb)))
-		return skb_header_pointer(skb_nfct_reasm(skb),
-					  ipvsh->thoff_reasm, len, buffer);
-
-	return skb_header_pointer(skb, offset, len, buffer);
-}
-#else
-static inline struct sk_buff *skb_nfct_reasm(const struct sk_buff *skb=
)
-{
-	return NULL;
-}
 static inline void *frag_safe_skb_hp(const struct sk_buff *skb, int of=
fset,
 				      int len, void *buffer,
 				      const struct ip_vs_iphdr *ipvsh)
 {
 	return skb_header_pointer(skb, offset, len, buffer);
 }
-#endif
=20
 static inline void
 ip_vs_fill_ip4hdr(const void *nh, struct ip_vs_iphdr *iphdr)
@@ -171,19 +148,12 @@ ip_vs_fill_iph_skb(int af, const struct sk_buff *=
skb, struct ip_vs_iphdr *iphdr)
 			(struct ipv6hdr *)skb_network_header(skb);
 		iphdr->saddr.in6 =3D iph->saddr;
 		iphdr->daddr.in6 =3D iph->daddr;
-		/* ipv6_find_hdr() updates len, flags, thoff_reasm */
-		iphdr->thoff_reasm =3D 0;
+		/* ipv6_find_hdr() updates len, flags */
 		iphdr->len	 =3D 0;
 		iphdr->flags	 =3D 0;
 		iphdr->protocol  =3D ipv6_find_hdr(skb, &iphdr->len, -1,
 						 &iphdr->fragoffs,
 						 &iphdr->flags);
-		/* get proto from re-assembled packet and it's offset */
-		if (skb_nfct_reasm(skb))
-			iphdr->protocol =3D ipv6_find_hdr(skb_nfct_reasm(skb),
-							&iphdr->thoff_reasm,
-							-1, NULL, NULL);
-
 	} else
 #endif
 	{
diff --git a/include/net/netfilter/ipv6/nf_defrag_ipv6.h b/include/net/=
netfilter/ipv6/nf_defrag_ipv6.h
index fd79c9a..80a3f41 100644
--- a/include/net/netfilter/ipv6/nf_defrag_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
@@ -6,10 +6,7 @@ extern void nf_defrag_ipv6_enable(void);
 extern int nf_ct_frag6_init(void);
 extern void nf_ct_frag6_cleanup(void);
 extern struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 use=
r);
-extern void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *s=
kb,
-			       struct net_device *in,
-			       struct net_device *out,
-			       int (*okfn)(struct sk_buff *));
+void nf_ct_frag6_consume_orig(struct sk_buff *skb);
=20
 struct inet_frags_ctl;
=20
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d81cff1..1371cf8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -580,9 +580,6 @@ static void skb_release_head_state(struct sk_buff *=
skb)
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	nf_conntrack_put(skb->nfct);
 #endif
-#ifdef NET_SKBUFF_NF_DEFRAG_NEEDED
-	nf_conntrack_put_reasm(skb->nfct_reasm);
-#endif
 #ifdef CONFIG_BRIDGE_NETFILTER
 	nf_bridge_put(skb->nf_bridge);
 #endif
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/=
netfilter/nf_conntrack_l3proto_ipv6.c
index d6e4dd8..83ab37c 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -169,63 +169,13 @@ out:
 	return nf_conntrack_confirm(skb);
 }
=20
-static unsigned int __ipv6_conntrack_in(struct net *net,
-					unsigned int hooknum,
-					struct sk_buff *skb,
-					const struct net_device *in,
-					const struct net_device *out,
-					int (*okfn)(struct sk_buff *))
-{
-	struct sk_buff *reasm =3D skb->nfct_reasm;
-	const struct nf_conn_help *help;
-	struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-
-	/* This packet is fragmented and has reassembled packet. */
-	if (reasm) {
-		/* Reassembled packet isn't parsed yet ? */
-		if (!reasm->nfct) {
-			unsigned int ret;
-
-			ret =3D nf_conntrack_in(net, PF_INET6, hooknum, reasm);
-			if (ret !=3D NF_ACCEPT)
-				return ret;
-		}
-
-		/* Conntrack helpers need the entire reassembled packet in the
-		 * POST_ROUTING hook. In case of unconfirmed connections NAT
-		 * might reassign a helper, so the entire packet is also
-		 * required.
-		 */
-		ct =3D nf_ct_get(reasm, &ctinfo);
-		if (ct !=3D NULL && !nf_ct_is_untracked(ct)) {
-			help =3D nfct_help(ct);
-			if ((help && help->helper) || !nf_ct_is_confirmed(ct)) {
-				nf_conntrack_get_reasm(reasm);
-				NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, reasm,
-					       (struct net_device *)in,
-					       (struct net_device *)out,
-					       okfn, NF_IP6_PRI_CONNTRACK + 1);
-				return NF_DROP_ERR(-ECANCELED);
-			}
-		}
-
-		nf_conntrack_get(reasm->nfct);
-		skb->nfct =3D reasm->nfct;
-		skb->nfctinfo =3D reasm->nfctinfo;
-		return NF_ACCEPT;
-	}
-
-	return nf_conntrack_in(net, PF_INET6, hooknum, skb);
-}
-
 static unsigned int ipv6_conntrack_in(unsigned int hooknum,
 				      struct sk_buff *skb,
 				      const struct net_device *in,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
 {
-	return __ipv6_conntrack_in(dev_net(in), hooknum, skb, in, out, okfn);
+	return nf_conntrack_in(dev_net(in), PF_INET6, hooknum, skb);
 }
=20
 static unsigned int ipv6_conntrack_local(unsigned int hooknum,
@@ -239,7 +189,7 @@ static unsigned int ipv6_conntrack_local(unsigned i=
nt hooknum,
 		net_notice_ratelimited("ipv6_conntrack_local: packet too short\n");
 		return NF_ACCEPT;
 	}
-	return __ipv6_conntrack_in(dev_net(out), hooknum, skb, in, out, okfn)=
;
+	return nf_conntrack_in(dev_net(out), PF_INET6, hooknum, skb);
 }
=20
 static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly =3D {
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilt=
er/nf_conntrack_reasm.c
index dffdc1a..253566a 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -621,31 +621,16 @@ ret_orig:
 	return skb;
 }
=20
-void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
-			struct net_device *in, struct net_device *out,
-			int (*okfn)(struct sk_buff *))
+void nf_ct_frag6_consume_orig(struct sk_buff *skb)
 {
 	struct sk_buff *s, *s2;
-	unsigned int ret =3D 0;
=20
 	for (s =3D NFCT_FRAG6_CB(skb)->orig; s;) {
-		nf_conntrack_put_reasm(s->nfct_reasm);
-		nf_conntrack_get_reasm(skb);
-		s->nfct_reasm =3D skb;
-
 		s2 =3D s->next;
 		s->next =3D NULL;
-
-		if (ret !=3D -ECANCELED)
-			ret =3D NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, s,
-					     in, out, okfn,
-					     NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
-		else
-			kfree_skb(s);
-
+		consume_skb(s);
 		s =3D s2;
 	}
-	nf_conntrack_put_reasm(skb);
 }
=20
 static int nf_ct_net_init(struct net *net)
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfi=
lter/nf_defrag_ipv6_hooks.c
index aacd121..581dd9e 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -75,8 +75,11 @@ static unsigned int ipv6_defrag(unsigned int hooknum=
,
 	if (reasm =3D=3D skb)
 		return NF_ACCEPT;
=20
-	nf_ct_frag6_output(hooknum, reasm, (struct net_device *)in,
-			   (struct net_device *)out, okfn);
+	nf_ct_frag6_consume_orig(reasm);
+
+	NF_HOOK_THRESH(NFPROTO_IPV6, hooknum, reasm,
+		       (struct net_device *) in, (struct net_device *) out,
+		       okfn, NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
=20
 	return NF_STOLEN;
 }
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs=
_core.c
index 74fd00c..3581736 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1139,12 +1139,6 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *=
skb, int af)
 	ip_vs_fill_iph_skb(af, skb, &iph);
 #ifdef CONFIG_IP_VS_IPV6
 	if (af =3D=3D AF_INET6) {
-		if (!iph.fragoffs && skb_nfct_reasm(skb)) {
-			struct sk_buff *reasm =3D skb_nfct_reasm(skb);
-			/* Save fw mark for coming frags */
-			reasm->ipvs_property =3D 1;
-			reasm->mark =3D skb->mark;
-		}
 		if (unlikely(iph.protocol =3D=3D IPPROTO_ICMPV6)) {
 			int related;
 			int verdict =3D ip_vs_out_icmp_v6(skb, &related,
@@ -1614,12 +1608,6 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *s=
kb, int af)
=20
 #ifdef CONFIG_IP_VS_IPV6
 	if (af =3D=3D AF_INET6) {
-		if (!iph.fragoffs && skb_nfct_reasm(skb)) {
-			struct sk_buff *reasm =3D skb_nfct_reasm(skb);
-			/* Save fw mark for coming frags. */
-			reasm->ipvs_property =3D 1;
-			reasm->mark =3D skb->mark;
-		}
 		if (unlikely(iph.protocol =3D=3D IPPROTO_ICMPV6)) {
 			int related;
 			int verdict =3D ip_vs_in_icmp_v6(skb, &related, hooknum,
@@ -1671,9 +1659,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *sk=
b, int af)
 		/* sorry, all this trouble for a no-hit :) */
 		IP_VS_DBG_PKT(12, af, pp, skb, 0,
 			      "ip_vs_in: packet continues traversal as normal");
-		if (iph.fragoffs && !skb_nfct_reasm(skb)) {
+		if (iph.fragoffs) {
 			/* Fragment that couldn't be mapped to a conn entry
-			 * and don't have any pointer to a reasm skb
 			 * is missing module nf_defrag_ipv6
 			 */
 			IP_VS_DBG_RL("Unhandled frag, load nf_defrag_ipv6\n");
@@ -1756,38 +1743,6 @@ ip_vs_local_request4(unsigned int hooknum, struc=
t sk_buff *skb,
 #ifdef CONFIG_IP_VS_IPV6
=20
 /*
- * AF_INET6 fragment handling
- * Copy info from first fragment, to the rest of them.
- */
-static unsigned int
-ip_vs_preroute_frag6(unsigned int hooknum, struct sk_buff *skb,
-		     const struct net_device *in,
-		     const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
-{
-	struct sk_buff *reasm =3D skb_nfct_reasm(skb);
-	struct net *net;
-
-	/* Skip if not a "replay" from nf_ct_frag6_output or first fragment.
-	 * ipvs_property is set when checking first fragment
-	 * in ip_vs_in() and ip_vs_out().
-	 */
-	if (reasm)
-		IP_VS_DBG(2, "Fragment recv prop:%d\n", reasm->ipvs_property);
-	if (!reasm || !reasm->ipvs_property)
-		return NF_ACCEPT;
-
-	net =3D skb_net(skb);
-	if (!net_ipvs(net)->enable)
-		return NF_ACCEPT;
-
-	/* Copy stored fw mark, saved in ip_vs_{in,out} */
-	skb->mark =3D reasm->mark;
-
-	return NF_ACCEPT;
-}
-
-/*
  *	AF_INET6 handler in NF_INET_LOCAL_IN chain
  *	Schedule and forward packets from remote clients
  */
@@ -1924,14 +1879,6 @@ static struct nf_hook_ops ip_vs_ops[] __read_mos=
tly =3D {
 		.priority	=3D 100,
 	},
 #ifdef CONFIG_IP_VS_IPV6
-	/* After mangle & nat fetch 2:nd fragment and following */
-	{
-		.hook		=3D ip_vs_preroute_frag6,
-		.owner		=3D THIS_MODULE,
-		.pf		=3D NFPROTO_IPV6,
-		.hooknum	=3D NF_INET_PRE_ROUTING,
-		.priority	=3D NF_IP6_PRI_NAT_DST + 1,
-	},
 	/* After packet filtering, change source only for VS/NAT */
 	{
 		.hook		=3D ip_vs_reply6,
diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_=
vs_pe_sip.c
index 9ef22bd..bed5f70 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -65,7 +65,6 @@ static int get_callid(const char *dptr, unsigned int =
dataoff,
 static int
 ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 {
-	struct sk_buff *reasm =3D skb_nfct_reasm(skb);
 	struct ip_vs_iphdr iph;
 	unsigned int dataoff, datalen, matchoff, matchlen;
 	const char *dptr;
@@ -79,15 +78,10 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, st=
ruct sk_buff *skb)
 	/* todo: IPv6 fragments:
 	 *       I think this only should be done for the first fragment. /HS
 	 */
-	if (reasm) {
-		skb =3D reasm;
-		dataoff =3D iph.thoff_reasm + sizeof(struct udphdr);
-	} else
-		dataoff =3D iph.len + sizeof(struct udphdr);
+	dataoff =3D iph.len + sizeof(struct udphdr);
=20
 	if (dataoff >=3D skb->len)
 		return -EINVAL;
-	/* todo: Check if this will mess-up the reasm skb !!! /HS */
 	retc =3D skb_linearize(skb);
 	if (retc < 0)
 		return retc;
--=20
1.8.4.3


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
