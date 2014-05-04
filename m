From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: rename local_df to ignore_df
Date: Sun,  4 May 2014 16:39:18 -0700
Message-ID: <1399246758-29795-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35124 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbaEDXja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 19:39:30 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so7499912pdi.30
        for <netdev@vger.kernel.org>; Sun, 04 May 2014 16:39:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by several people, rename local_df to ignore_df,
since it means "ignore df bit if it is set".

Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Florian Westphal <fw@strlen.de>
Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 08074a8..8120004 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -426,7 +426,7 @@ static inline u32 skb_mstamp_us_delta(const struct =
skb_mstamp *t1,
  *	@csum_start: Offset from skb->head where checksumming should start
  *	@csum_offset: Offset from csum_start where checksum should be store=
d
  *	@priority: Packet queueing priority
- *	@local_df: allow local fragmentation
+ *	@ignore_df: allow local fragmentation
  *	@cloned: Head may be cloned (check refcnt to be sure)
  *	@ip_summed: Driver fed us an IP checksum
  *	@nohdr: Payload reference only, must not modify header
@@ -514,7 +514,7 @@ struct sk_buff {
 	};
 	__u32			priority;
 	kmemcheck_bitfield_begin(flags1);
-	__u8			local_df:1,
+	__u8			ignore_df:1,
 				cloned:1,
 				ip_summed:2,
 				nohdr:1,
diff --git a/include/net/ip.h b/include/net/ip.h
index 3ec2b0f..612f3fd 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -281,7 +281,7 @@ static inline bool ip_sk_use_pmtu(const struct sock=
 *sk)
 	return inet_sk(sk)->pmtudisc < IP_PMTUDISC_PROBE;
 }
=20
-static inline bool ip_sk_local_df(const struct sock *sk)
+static inline bool ip_sk_ignore_df(const struct sock *sk)
 {
 	return inet_sk(sk)->pmtudisc < IP_PMTUDISC_DO ||
 	       inet_sk(sk)->pmtudisc =3D=3D IP_PMTUDISC_OMIT;
@@ -316,7 +316,7 @@ static inline void ip_select_ident(struct sk_buff *=
skb, struct dst_entry *dst, s
 {
 	struct iphdr *iph =3D ip_hdr(skb);
=20
-	if ((iph->frag_off & htons(IP_DF)) && !skb->local_df) {
+	if ((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) {
 		/* This is only to work around buggy Windows95/2000
 		 * VJ compression implementations.  If the ID field
 		 * does not change, they drop every other packet in
@@ -332,7 +332,7 @@ static inline void ip_select_ident_more(struct sk_b=
uff *skb, struct dst_entry *d
 {
 	struct iphdr *iph =3D ip_hdr(skb);
=20
-	if ((iph->frag_off & htons(IP_DF)) && !skb->local_df) {
+	if ((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) {
 		if (sk && inet_sk(sk)->inet_daddr) {
 			iph->id =3D htons(inet_sk(sk)->inet_id);
 			inet_sk(sk)->inet_id +=3D 1 + more;
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 6c4f5ea..38e41e4 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -185,7 +185,7 @@ static inline bool ip6_sk_accept_pmtu(const struct =
sock *sk)
 	       inet6_sk(sk)->pmtudisc !=3D IPV6_PMTUDISC_OMIT;
 }
=20
-static inline bool ip6_sk_local_df(const struct sock *sk)
+static inline bool ip6_sk_ignore_df(const struct sock *sk)
 {
 	return inet6_sk(sk)->pmtudisc < IPV6_PMTUDISC_DO ||
 	       inet6_sk(sk)->pmtudisc =3D=3D IPV6_PMTUDISC_OMIT;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1b62343..3d74530 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -694,7 +694,7 @@ static void __copy_skb_header(struct sk_buff *new, =
const struct sk_buff *old)
 #endif
 	memcpy(new->cb, old->cb, sizeof(old->cb));
 	new->csum		=3D old->csum;
-	new->local_df		=3D old->local_df;
+	new->ignore_df		=3D old->ignore_df;
 	new->pkt_type		=3D old->pkt_type;
 	new->ip_summed		=3D old->ip_summed;
 	skb_copy_queue_mapping(new, old);
@@ -3913,7 +3913,7 @@ void skb_scrub_packet(struct sk_buff *skb, bool x=
net)
 	skb->tstamp.tv64 =3D 0;
 	skb->pkt_type =3D PACKET_HOST;
 	skb->skb_iif =3D 0;
-	skb->local_df =3D 0;
+	skb->ignore_df =3D 0;
 	skb_dst_drop(skb);
 	skb->mark =3D 0;
 	secpath_reset(skb);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index be8abe7..8ac422f 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -42,12 +42,12 @@
 static bool ip_may_fragment(const struct sk_buff *skb)
 {
 	return unlikely((ip_hdr(skb)->frag_off & htons(IP_DF)) =3D=3D 0) ||
-	       !skb->local_df;
+	       !skb->ignore_df;
 }
=20
 static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu=
)
 {
-	if (skb->len <=3D mtu || skb->local_df)
+	if (skb->len <=3D mtu || skb->ignore_df)
 		return false;
=20
 	if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <=3D mtu)
@@ -60,7 +60,7 @@ static bool ip_gso_exceeds_dst_mtu(const struct sk_bu=
ff *skb)
 {
 	unsigned int mtu;
=20
-	if (skb->local_df || !skb_is_gso(skb))
+	if (skb->ignore_df || !skb_is_gso(skb))
 		return false;
=20
 	mtu =3D ip_dst_mtu_maybe_forward(skb_dst(skb), true);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 1cbeba5..8f88509 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -370,7 +370,7 @@ packet_routed:
 	skb_reset_network_header(skb);
 	iph =3D ip_hdr(skb);
 	*((__be16 *)iph) =3D htons((4 << 12) | (5 << 8) | (inet->tos & 0xff))=
;
-	if (ip_dont_fragment(sk, &rt->dst) && !skb->local_df)
+	if (ip_dont_fragment(sk, &rt->dst) && !skb->ignore_df)
 		iph->frag_off =3D htons(IP_DF);
 	else
 		iph->frag_off =3D 0;
@@ -456,7 +456,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(=
struct sk_buff *))
 	iph =3D ip_hdr(skb);
=20
 	mtu =3D ip_skb_dst_mtu(skb);
-	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->local_df) ||
+	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
 		     (IPCB(skb)->frag_max_size &&
 		      IPCB(skb)->frag_max_size > mtu))) {
 		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
@@ -821,7 +821,7 @@ static int __ip_append_data(struct sock *sk,
=20
 	fragheaderlen =3D sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen =3D ((mtu - fragheaderlen) & ~7) + fragheaderlen;
-	maxnonfragsize =3D ip_sk_local_df(sk) ? 0xFFFF : mtu;
+	maxnonfragsize =3D ip_sk_ignore_df(sk) ? 0xFFFF : mtu;
=20
 	if (cork->length + length > maxnonfragsize - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
@@ -1144,7 +1144,7 @@ ssize_t	ip_append_page(struct sock *sk, struct fl=
owi4 *fl4, struct page *page,
=20
 	fragheaderlen =3D sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen =3D ((mtu - fragheaderlen) & ~7) + fragheaderlen;
-	maxnonfragsize =3D ip_sk_local_df(sk) ? 0xFFFF : mtu;
+	maxnonfragsize =3D ip_sk_ignore_df(sk) ? 0xFFFF : mtu;
=20
 	if (cork->length + size > maxnonfragsize - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, fl4->daddr, inet->inet_dport,
@@ -1305,10 +1305,10 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	 * to fragment the frame generated here. No matter, what transforms
 	 * how transforms change size of the packet, it will come out.
 	 */
-	skb->local_df =3D ip_sk_local_df(sk);
+	skb->ignore_df =3D ip_sk_ignore_df(sk);
=20
 	/* DF bit is set when we want to see DF on outgoing frames.
-	 * If local_df is set too, we still allow to fragment this frame
+	 * If ignore_df is set too, we still allow to fragment this frame
 	 * locally. */
 	if (inet->pmtudisc =3D=3D IP_PMTUDISC_DO ||
 	    inet->pmtudisc =3D=3D IP_PMTUDISC_PROBE ||
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 40e701f..8e8c018 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -25,7 +25,7 @@ static int xfrm4_tunnel_check_size(struct sk_buff *sk=
b)
 	if (IPCB(skb)->flags & IPSKB_XFRM_TUNNEL_SIZE)
 		goto out;
=20
-	if (!(ip_hdr(skb)->frag_off & htons(IP_DF)) || skb->local_df)
+	if (!(ip_hdr(skb)->frag_off & htons(IP_DF)) || skb->ignore_df)
 		goto out;
=20
 	mtu =3D dst_mtu(skb_dst(skb));
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 40e7581..e270c0b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -219,7 +219,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, =
struct flowi6 *fl6,
 	skb->mark =3D sk->sk_mark;
=20
 	mtu =3D dst_mtu(dst);
-	if ((skb->len <=3D mtu) || skb->local_df || skb_is_gso(skb)) {
+	if ((skb->len <=3D mtu) || skb->ignore_df || skb_is_gso(skb)) {
 		IP6_UPD_PO_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_OUT, skb->len);
 		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
@@ -344,7 +344,7 @@ static unsigned int ip6_dst_mtu_forward(const struc=
t dst_entry *dst)
=20
 static bool ip6_pkt_too_big(const struct sk_buff *skb, unsigned int mt=
u)
 {
-	if (skb->len <=3D mtu || skb->local_df)
+	if (skb->len <=3D mtu || skb->ignore_df)
 		return false;
=20
 	if (IP6CB(skb)->frag_max_size && IP6CB(skb)->frag_max_size > mtu)
@@ -555,7 +555,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)=
(struct sk_buff *))
 	/* We must not fragment if the socket is set to force MTU discovery
 	 * or if the skb it not generated by a local socket.
 	 */
-	if (unlikely(!skb->local_df && skb->len > mtu) ||
+	if (unlikely(!skb->ignore_df && skb->len > mtu) ||
 		     (IP6CB(skb)->frag_max_size &&
 		      IP6CB(skb)->frag_max_size > mtu)) {
 		if (skb->sk && dst_allfrag(skb_dst(skb)))
@@ -1230,7 +1230,7 @@ int ip6_append_data(struct sock *sk, int getfrag(=
void *from, char *to,
 			      sizeof(struct frag_hdr) : 0) +
 			     rt->rt6i_nfheader_len;
=20
-		if (ip6_sk_local_df(sk))
+		if (ip6_sk_ignore_df(sk))
 			maxnonfragsize =3D sizeof(struct ipv6hdr) + IPV6_MAXPLEN;
 		else
 			maxnonfragsize =3D mtu;
@@ -1540,7 +1540,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	}
=20
 	/* Allow local fragmentation. */
-	skb->local_df =3D ip6_sk_local_df(sk);
+	skb->ignore_df =3D ip6_sk_ignore_df(sk);
=20
 	*final_dst =3D fl6->daddr;
 	__skb_pull(skb, skb_network_header_len(skb));
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilt=
er/nf_conntrack_reasm.c
index 767ab8d..0d5279f 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -451,7 +451,7 @@ nf_ct_frag6_reasm(struct frag_queue *fq, struct net=
_device *dev)
 	}
 	sub_frag_mem_limit(&fq->q, head->truesize);
=20
-	head->local_df =3D 1;
+	head->ignore_df =3D 1;
 	head->next =3D NULL;
 	head->dev =3D dev;
 	head->tstamp =3D fq->q.stamp;
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 19ef329..f47c8b1 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -78,7 +78,7 @@ static int xfrm6_tunnel_check_size(struct sk_buff *sk=
b)
 	if (mtu < IPV6_MIN_MTU)
 		mtu =3D IPV6_MIN_MTU;
=20
-	if (!skb->local_df && skb->len > mtu) {
+	if (!skb->ignore_df && skb->len > mtu) {
 		skb->dev =3D dst->dev;
=20
 		if (xfrm6_local_dontfrag(skb))
@@ -120,7 +120,7 @@ int xfrm6_prepare_output(struct xfrm_state *x, stru=
ct sk_buff *skb)
 #endif
=20
 	skb->protocol =3D htons(ETH_P_IPV6);
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	return x->outer_mode->output2(x, skb);
 }
@@ -150,7 +150,7 @@ static int __xfrm6_output(struct sk_buff *skb)
 	if (skb->len > mtu && xfrm6_local_dontfrag(skb)) {
 		xfrm6_local_rxpmtu(skb, mtu);
 		return -EMSGSIZE;
-	} else if (!skb->local_df && skb->len > mtu && skb->sk) {
+	} else if (!skb->ignore_df && skb->len > mtu && skb->sk) {
 		xfrm_local_error(skb, mtu);
 		return -EMSGSIZE;
 	}
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index a4e37d7..6ea7604 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1128,7 +1128,7 @@ static int l2tp_xmit_core(struct l2tp_session *se=
ssion, struct sk_buff *skb,
 	}
=20
 	/* Queue the packet to IP for output */
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
 #if IS_ENABLED(CONFIG_IPV6)
 	if (tunnel->sock->sk_family =3D=3D PF_INET6 && !tunnel->v4mapped)
 		error =3D inet6_csk_xmit(tunnel->sock, skb, NULL);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs=
_xmit.c
index c47444e..487b55e 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -562,7 +562,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs=
_conn *cp,
 	ip_send_check(iph);
=20
 	/* Another hack: avoid icmp_send in ip_fragment */
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 0);
 	rcu_read_unlock();
@@ -590,7 +590,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip=
_vs_conn *cp,
 		goto tx_error;
=20
 	/* Another hack: avoid icmp_send in ip_fragment */
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 0);
 	rcu_read_unlock();
@@ -684,7 +684,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_co=
nn *cp,
 	   MTU problem. */
=20
 	/* Another hack: avoid icmp_send in ip_fragment */
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	rc =3D ip_vs_nat_send_or_cont(NFPROTO_IPV4, skb, cp, local);
 	rcu_read_unlock();
@@ -774,7 +774,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs=
_conn *cp,
 	   MTU problem. */
=20
 	/* Another hack: avoid icmp_send in ip_fragment */
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	rc =3D ip_vs_nat_send_or_cont(NFPROTO_IPV6, skb, cp, local);
 	rcu_read_unlock();
@@ -886,7 +886,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs=
_conn *cp,
 	ip_select_ident(skb, &rt->dst, NULL);
=20
 	/* Another hack: avoid icmp_send in ip_fragment */
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	ret =3D ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret =3D=3D NF_ACCEPT)
@@ -974,7 +974,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip=
_vs_conn *cp,
 	iph->hop_limit		=3D	old_iph->hop_limit;
=20
 	/* Another hack: avoid icmp_send in ip_fragment */
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	ret =3D ip_vs_tunnel_xmit_prepare(skb, cp);
 	if (ret =3D=3D NF_ACCEPT)
@@ -1023,7 +1023,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_c=
onn *cp,
 	ip_send_check(ip_hdr(skb));
=20
 	/* Another hack: avoid icmp_send in ip_fragment */
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 0);
 	rcu_read_unlock();
@@ -1060,7 +1060,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_v=
s_conn *cp,
 	}
=20
 	/* Another hack: avoid icmp_send in ip_fragment */
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	ip_vs_send_or_cont(NFPROTO_IPV6, skb, cp, 0);
 	rcu_read_unlock();
@@ -1157,7 +1157,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs=
_conn *cp,
 	ip_vs_nat_icmp(skb, pp, cp, 0);
=20
 	/* Another hack: avoid icmp_send in ip_fragment */
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	rc =3D ip_vs_nat_send_or_cont(NFPROTO_IPV4, skb, cp, local);
 	rcu_read_unlock();
@@ -1249,7 +1249,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip=
_vs_conn *cp,
 	ip_vs_nat_icmp_v6(skb, pp, cp, 0);
=20
 	/* Another hack: avoid icmp_send in ip_fragment */
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	rc =3D ip_vs_nat_send_or_cont(NFPROTO_IPV6, skb, cp, local);
 	rcu_read_unlock();
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index ebb6e24..0856f01 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -172,7 +172,7 @@ static int gre_tnl_send(struct vport *vport, struct=
 sk_buff *skb)
 	df =3D OVS_CB(skb)->tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
 		htons(IP_DF) : 0;
=20
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	return iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
 			     OVS_CB(skb)->tun_key->ipv4_dst, IPPROTO_GRE,
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxla=
n.c
index 21cceb3..a93efa3 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -170,7 +170,7 @@ static int vxlan_tnl_send(struct vport *vport, stru=
ct sk_buff *skb)
 	df =3D OVS_CB(skb)->tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
 		htons(IP_DF) : 0;
=20
-	skb->local_df =3D 1;
+	skb->ignore_df =3D 1;
=20
 	inet_get_local_port_range(net, &port_min, &port_max);
 	src_port =3D vxlan_src_port(port_min, port_max, skb);
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 2b1738e..4dc5d9e 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -216,7 +216,7 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct=
 sctp_transport *transport)
 	IP6_ECN_flow_xmit(sk, fl6->flowlabel);
=20
 	if (!(transport->param_flags & SPP_PMTUD_ENABLE))
-		skb->local_df =3D 1;
+		skb->ignore_df =3D 1;
=20
 	SCTP_INC_STATS(sock_net(sk), SCTP_MIB_OUTSCTPPACKS);
=20
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 0f4d15f..01ab8e0 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -591,7 +591,7 @@ int sctp_packet_transmit(struct sctp_packet *packet=
)
=20
 	pr_debug("***sctp_transmit_packet*** skb->len:%d\n", nskb->len);
=20
-	nskb->local_df =3D packet->ipfragok;
+	nskb->ignore_df =3D packet->ipfragok;
 	tp->af_specific->sctp_xmit(nskb, tp);
=20
 out:
