From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: sock_def_readable() and friends RCU
 conversion
Date: Fri, 30 Apr 2010 19:26:28 +0200
Message-ID: <1272648388.2301.15.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop> <1272454432.14068.4.camel@bigi>
		 <1272458001.2267.0.camel@edumazet-laptop> <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
	 <1272548980.2222.87.camel@edumazet-laptop> <1272549408.4258.189.camel@bigi>
		 <1272573383.3969.8.camel@bigi> <1272574909.2209.150.camel@edumazet-laptop>
	 <4BDAE156.8070800@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:48525 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933278Ab0D3R0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:26:35 -0400
Received: by bwz19 with SMTP id 19so273766bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 10:26:33 -0700 (PDT)
In-Reply-To: <4BDAE156.8070800@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 30 avril 2010 =C3=A0 09:55 -0400, Brian Bloniarz a =C3=A9cr=
it :

>=20
> This patch boots for me, I haven't noticed any strangeness yet.
>=20
> I ran a few benchmarks (the multicast fan-out mcasttest.c
> from last year, a few other things we have lying around).
> I think I see a modest improvement from this and your other
> 2 packets. Presumably the big wins are where multiple cores
> perform bh for the same socket, that's not the case in
> these benchmarks. If it's appropriate:
>=20
> Tested-by: Brian Bloniarz <bmb@athenacr.com>
>=20
> > Next one will be able to coalesce wakeup calls (they'll be delayed =
at
> > the end of net_rx_action(), like a patch I did last year to help
> > multicast reception)
>=20
> Keep em coming :)

Thanks for testing !

Here is a respin of "net: relax dst refcnt in input path"
patch for net-next-2.6

Not ready for inclusion, but seems to work quite well on multicast
load : I get about 20% more packets on mcasttest

(Avoid atomic ops on dst entries on input path, and partly on forwading
path). On mccasttest, all sockets share same dst, so producer/consumers
all fight on a single cache line.

Old ref (for informations) :
http://kerneltrap.org/mailarchive/linux-netdev/2009/7/22/6248753

Not-Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

 include/linux/skbuff.h    |   45 +++++++++++++++++++++++++++++++++-
 include/net/dst.h         |   47 +++++++++++++++++++++++++++++++++---
 include/net/route.h       |    2 -
 include/net/sock.h        |    2 +
 net/bridge/br_netfilter.c |    2 -
 net/core/dev.c            |    3 ++
 net/core/skbuff.c         |    3 +-
 net/core/sock.c           |    6 ++++
 net/ipv4/arp.c            |    2 -
 net/ipv4/icmp.c           |    8 +++---
 net/ipv4/ip_forward.c     |    1=20
 net/ipv4/ip_fragment.c    |    2 -
 net/ipv4/ip_input.c       |    2 -
 net/ipv4/ip_options.c     |   11 ++++----
 net/ipv4/netfilter.c      |    8 +++---
 net/ipv4/route.c          |   15 +++++++----
 net/ipv4/xfrm4_input.c    |    2 -
 net/ipv6/ip6_tunnel.c     |    2 -
 net/netfilter/nf_queue.c  |    2 +
 net/sched/sch_generic.c   |    2 -
 20 files changed, 136 insertions(+), 31 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 82f5116..6195bcf 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -414,16 +414,59 @@ struct sk_buff {
=20
 #include <asm/system.h>
=20
+/*
+ * skb might have a dst pointer attached, refcounted or not
+ * _skb_dst low order bit is set if refcount was taken
+ */
+#define SKB_DST_NOREF	1UL
+#define SKB_DST_PTRMASK	~(SKB_DST_NOREF)
+
+/**
+ * skb_dst - returns skb dst_entry
+ * @skb: buffer
+ *
+ * Returns skb dst_entry, regardless of reference taken or not.
+ */
 static inline struct dst_entry *skb_dst(const struct sk_buff *skb)
 {
-	return (struct dst_entry *)skb->_skb_dst;
+	return (struct dst_entry *)(skb->_skb_dst & SKB_DST_PTRMASK);
 }
=20
+/**
+ * skb_dst_set - sets skb dst
+ * @skb: buffer
+ * @dst: dst entry
+ *
+ * Sets skb dst, assuming a reference was taken on dst and should
+ * be released by skb_dst_drop()
+ */
 static inline void skb_dst_set(struct sk_buff *skb, struct dst_entry *=
dst)
 {
 	skb->_skb_dst =3D (unsigned long)dst;
 }
=20
+/**
+ * skb_dst_set_noref - sets skb dst, without a reference
+ * @skb: buffer
+ * @dst: dst entry
+ *
+ * Sets skb dst, assuming a reference was _not_ taken on dst
+ * skb_dst_drop() should not dst_release() this dst
+ */
+static inline void skb_dst_set_noref(struct sk_buff *skb, struct dst_e=
ntry *dst)
+{
+	skb->_skb_dst =3D (unsigned long)dst | SKB_DST_NOREF;
+}
+
+/**
+ * skb_dst_is_noref - Test is skb dst isnt refcounted
+ * @skb: buffer
+ */
+static inline bool skb_dst_is_noref(const struct sk_buff *skb)
+{
+	return (skb->_skb_dst & SKB_DST_NOREF) && skb_dst(skb);
+}
+
 static inline struct rtable *skb_rtable(const struct sk_buff *skb)
 {
 	return (struct rtable *)skb_dst(skb);
diff --git a/include/net/dst.h b/include/net/dst.h
index aac5a5f..ad6ea9e 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -168,6 +168,12 @@ static inline void dst_use(struct dst_entry *dst, =
unsigned long time)
 	dst->lastuse =3D time;
 }
=20
+static inline void dst_use_noref(struct dst_entry *dst, unsigned long =
time)
+{
+	dst->__use++;
+	dst->lastuse =3D time;
+}
+
 static inline
 struct dst_entry * dst_clone(struct dst_entry * dst)
 {
@@ -177,11 +183,46 @@ struct dst_entry * dst_clone(struct dst_entry * d=
st)
 }
=20
 extern void dst_release(struct dst_entry *dst);
+
+static inline void __skb_dst_drop(unsigned long _skb_dst)
+{
+	if (!(_skb_dst & SKB_DST_NOREF))
+		dst_release((struct dst_entry *)(_skb_dst & SKB_DST_PTRMASK));
+}
+
+/**
+ * skb_dst_drop - drops skb dst
+ * @skb: buffer
+ *
+ * Drops dst reference count if a reference was taken.
+ */
 static inline void skb_dst_drop(struct sk_buff *skb)
 {
-	if (skb->_skb_dst)
-		dst_release(skb_dst(skb));
-	skb->_skb_dst =3D 0UL;
+	if (skb->_skb_dst) {
+		__skb_dst_drop(skb->_skb_dst);
+		skb->_skb_dst =3D 0UL;
+	}
+}
+
+static inline void skb_dst_copy(struct sk_buff *nskb, const struct sk_=
buff *oskb)
+{
+	nskb->_skb_dst =3D oskb->_skb_dst;
+	if (!(nskb->_skb_dst & SKB_DST_NOREF))
+		dst_clone(skb_dst(nskb));
+}
+
+/**
+ * skb_dst_force - makes sure skb dst is refcounted
+ * @skb: buffer
+ *
+ * If dst is not yet refcounted, let's do it
+ */
+static inline void skb_dst_force(struct sk_buff *skb)
+{
+	if (skb->_skb_dst & SKB_DST_NOREF) {
+		skb->_skb_dst &=3D ~SKB_DST_NOREF;
+		dst_clone(skb_dst(skb));
+	}
 }
=20
 /* Children define the path of the packet through the
diff --git a/include/net/route.h b/include/net/route.h
index 2c9fba7..443f6d4 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -112,7 +112,7 @@ extern void		rt_cache_flush_batch(void);
 extern int		__ip_route_output_key(struct net *, struct rtable **, cons=
t struct flowi *flp);
 extern int		ip_route_output_key(struct net *, struct rtable **, struct=
 flowi *flp);
 extern int		ip_route_output_flow(struct net *, struct rtable **rp, str=
uct flowi *flp, struct sock *sk, int flags);
-extern int		ip_route_input(struct sk_buff*, __be32 dst, __be32 src, u8=
 tos, struct net_device *devin);
+extern int		ip_route_input(struct sk_buff*, __be32 dst, __be32 src, u8=
 tos, struct net_device *devin, bool noref);
 extern unsigned short	ip_rt_frag_needed(struct net *net, struct iphdr =
*iph, unsigned short new_mtu, struct net_device *dev);
 extern void		ip_rt_send_redirect(struct sk_buff *skb);
=20
diff --git a/include/net/sock.h b/include/net/sock.h
index d361c77..0a0f14d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -598,6 +598,8 @@ static inline int sk_stream_memory_free(struct sock=
 *sk)
 /* OOB backlog add */
 static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *s=
kb)
 {
+	/* dont let skb dst not referenced, we are going to leave rcu lock */
+	skb_dst_force(skb);
 	if (!sk->sk_backlog.tail) {
 		sk->sk_backlog.head =3D sk->sk_backlog.tail =3D skb;
 	} else {
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4c4977d..c943ad4 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -350,7 +350,7 @@ static int br_nf_pre_routing_finish(struct sk_buff =
*skb)
 	}
 	nf_bridge->mask ^=3D BRNF_NF_BRIDGE_PREROUTING;
 	if (dnat_took_place(skb)) {
-		if ((err =3D ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, d=
ev))) {
+		if ((err =3D ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, d=
ev, false))) {
 			struct flowi fl =3D {
 				.nl_u =3D {
 					.ip4_u =3D {
diff --git a/net/core/dev.c b/net/core/dev.c
index 100dcbd..c331b0e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2047,6 +2047,8 @@ static inline int __dev_xmit_skb(struct sk_buff *=
skb, struct Qdisc *q,
 		 * waiting to be sent out; and the qdisc is not running -
 		 * xmit the skb directly.
 		 */
+		if (!(dev->priv_flags & IFF_XMIT_DST_RELEASE))
+			skb_dst_force(skb);
 		__qdisc_update_bstats(q, skb->len);
 		if (sch_direct_xmit(skb, q, dev, txq, root_lock))
 			__qdisc_run(q);
@@ -2055,6 +2057,7 @@ static inline int __dev_xmit_skb(struct sk_buff *=
skb, struct Qdisc *q,
=20
 		rc =3D NET_XMIT_SUCCESS;
 	} else {
+		skb_dst_force(skb);
 		rc =3D qdisc_enqueue_root(skb, q);
 		qdisc_run(q);
 	}
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4218ff4..f400196 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -531,7 +531,8 @@ static void __copy_skb_header(struct sk_buff *new, =
const struct sk_buff *old)
 	new->transport_header	=3D old->transport_header;
 	new->network_header	=3D old->network_header;
 	new->mac_header		=3D old->mac_header;
-	skb_dst_set(new, dst_clone(skb_dst(old)));
+
+	skb_dst_copy(new, old);
 	new->rxhash		=3D old->rxhash;
 #ifdef CONFIG_XFRM
 	new->sp			=3D secpath_get(old->sp);
diff --git a/net/core/sock.c b/net/core/sock.c
index 5104175..894bed6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -307,6 +307,11 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_=
buff *skb)
 	 */
 	skb_len =3D skb->len;
=20
+	/* we escape from rcu protected region, make sure we dont leak
+	 * a norefcounted dst
+	 */
+	skb_dst_force(skb);
+
 	spin_lock_irqsave(&list->lock, flags);
 	skb->dropcount =3D atomic_read(&sk->sk_drops);
 	__skb_queue_tail(list, skb);
@@ -1535,6 +1540,7 @@ static void __release_sock(struct sock *sk)
 		do {
 			struct sk_buff *next =3D skb->next;
=20
+			WARN_ON_ONCE(skb_dst_is_noref(skb));
 			skb->next =3D NULL;
 			sk_backlog_rcv(sk, skb);
=20
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 6e74706..502ac9f 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -854,7 +854,7 @@ static int arp_process(struct sk_buff *skb)
 	}
=20
 	if (arp->ar_op =3D=3D htons(ARPOP_REQUEST) &&
-	    ip_route_input(skb, tip, sip, 0, dev) =3D=3D 0) {
+	    ip_route_input(skb, tip, sip, 0, dev, true) =3D=3D 0) {
=20
 		rt =3D skb_rtable(skb);
 		addr_type =3D rt->rt_type;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f3d339f..a113c08 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -587,20 +587,20 @@ void icmp_send(struct sk_buff *skb_in, int type, =
int code, __be32 info)
 			err =3D __ip_route_output_key(net, &rt2, &fl);
 		else {
 			struct flowi fl2 =3D {};
-			struct dst_entry *odst;
+			unsigned long odst;
=20
 			fl2.fl4_dst =3D fl.fl4_src;
 			if (ip_route_output_key(net, &rt2, &fl2))
 				goto relookup_failed;
=20
 			/* Ugh! */
-			odst =3D skb_dst(skb_in);
+			odst =3D skb_in->_skb_dst; /* save old dst */
 			err =3D ip_route_input(skb_in, fl.fl4_dst, fl.fl4_src,
-					     RT_TOS(tos), rt2->u.dst.dev);
+					     RT_TOS(tos), rt2->u.dst.dev, false);
=20
 			dst_release(&rt2->u.dst);
 			rt2 =3D skb_rtable(skb_in);
-			skb_dst_set(skb_in, odst);
+			skb_in->_skb_dst =3D odst; /* restore old dst */
 		}
=20
 		if (err)
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index af10942..0f58609 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -57,6 +57,7 @@ int ip_forward(struct sk_buff *skb)
 	struct rtable *rt;	/* Route we use */
 	struct ip_options * opt	=3D &(IPCB(skb)->opt);
=20
+/*	pr_err("ip_forward() skb->dst=3D%lx\n", skb->_skb_dst);*/
 	if (skb_warn_if_lro(skb))
 		goto drop;
=20
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 75347ea..cbcde7a 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -220,7 +220,7 @@ static void ip_expire(unsigned long arg)
 		if (qp->user =3D=3D IP_DEFRAG_CONNTRACK_IN && !skb_dst(head)) {
 			const struct iphdr *iph =3D ip_hdr(head);
 			int err =3D ip_route_input(head, iph->daddr, iph->saddr,
-						 iph->tos, head->dev);
+						 iph->tos, head->dev, false);
 			if (unlikely(err))
 				goto out_rcu_unlock;
=20
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index f8ab7a3..5d365e8 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -332,7 +332,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	 */
 	if (skb_dst(skb) =3D=3D NULL) {
 		int err =3D ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
-					 skb->dev);
+					 skb->dev, true);
 		if (unlikely(err)) {
 			if (err =3D=3D -EHOSTUNREACH)
 				IP_INC_STATS_BH(dev_net(skb->dev),
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 4c09a31..1b65d68 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -601,6 +601,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	unsigned char *optptr =3D skb_network_header(skb) + opt->srr;
 	struct rtable *rt =3D skb_rtable(skb);
 	struct rtable *rt2;
+	unsigned long odst;
 	int err;
=20
 	if (!opt->srr)
@@ -624,16 +625,16 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 		}
 		memcpy(&nexthop, &optptr[srrptr-1], 4);
=20
-		rt =3D skb_rtable(skb);
+		odst =3D skb->_skb_dst;
 		skb_dst_set(skb, NULL);
-		err =3D ip_route_input(skb, nexthop, iph->saddr, iph->tos, skb->dev)=
;
+		err =3D ip_route_input(skb, nexthop, iph->saddr, iph->tos, skb->dev,=
 false);
 		rt2 =3D skb_rtable(skb);
 		if (err || (rt2->rt_type !=3D RTN_UNICAST && rt2->rt_type !=3D RTN_L=
OCAL)) {
-			ip_rt_put(rt2);
-			skb_dst_set(skb, &rt->u.dst);
+			skb_dst_drop(skb);
+			skb->_skb_dst =3D odst;
 			return -EINVAL;
 		}
-		ip_rt_put(rt);
+		__skb_dst_drop(odst);
 		if (rt2->rt_type !=3D RTN_LOCAL)
 			break;
 		/* Superfast 8) loopback forward */
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 82fb43c..e505007 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -17,7 +17,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned =
addr_type)
 	const struct iphdr *iph =3D ip_hdr(skb);
 	struct rtable *rt;
 	struct flowi fl =3D {};
-	struct dst_entry *odst;
+	unsigned long odst;
 	unsigned int hh_len;
 	unsigned int type;
=20
@@ -51,14 +51,14 @@ int ip_route_me_harder(struct sk_buff *skb, unsigne=
d addr_type)
 		if (ip_route_output_key(net, &rt, &fl) !=3D 0)
 			return -1;
=20
-		odst =3D skb_dst(skb);
+		odst =3D skb->_skb_dst;
 		if (ip_route_input(skb, iph->daddr, iph->saddr,
-				   RT_TOS(iph->tos), rt->u.dst.dev) !=3D 0) {
+				   RT_TOS(iph->tos), rt->u.dst.dev, false) !=3D 0) {
 			dst_release(&rt->u.dst);
 			return -1;
 		}
 		dst_release(&rt->u.dst);
-		dst_release(odst);
+		__skb_dst_drop(odst);
 	}
=20
 	if (skb_dst(skb)->error)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a947428..4f169ce 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2300,7 +2300,7 @@ martian_source:
 }
=20
 int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-		   u8 tos, struct net_device *dev)
+		   u8 tos, struct net_device *dev, bool noref)
 {
 	struct rtable * rth;
 	unsigned	hash;
@@ -2326,10 +2326,15 @@ int ip_route_input(struct sk_buff *skb, __be32 =
daddr, __be32 saddr,
 		    rth->fl.mark =3D=3D skb->mark &&
 		    net_eq(dev_net(rth->u.dst.dev), net) &&
 		    !rt_is_expired(rth)) {
-			dst_use(&rth->u.dst, jiffies);
+			if (noref) {
+				dst_use_noref(&rth->u.dst, jiffies);
+				skb_dst_set_noref(skb, &rth->u.dst);
+			} else {
+				dst_use(&rth->u.dst, jiffies);
+				skb_dst_set(skb, &rth->u.dst);
+			}
 			RT_CACHE_STAT_INC(in_hit);
 			rcu_read_unlock();
-			skb_dst_set(skb, &rth->u.dst);
 			return 0;
 		}
 		RT_CACHE_STAT_INC(in_hlist_search);
@@ -2991,7 +2996,7 @@ static int inet_rtm_getroute(struct sk_buff *in_s=
kb, struct nlmsghdr* nlh, void
 		skb->protocol	=3D htons(ETH_P_IP);
 		skb->dev	=3D dev;
 		local_bh_disable();
-		err =3D ip_route_input(skb, dst, src, rtm->rtm_tos, dev);
+		err =3D ip_route_input(skb, dst, src, rtm->rtm_tos, dev, false);
 		local_bh_enable();
=20
 		rt =3D skb_rtable(skb);
@@ -3055,7 +3060,7 @@ int ip_rt_dump(struct sk_buff *skb,  struct netli=
nk_callback *cb)
 				continue;
 			if (rt_is_expired(rt))
 				continue;
-			skb_dst_set(skb, dst_clone(&rt->u.dst));
+			skb_dst_set_noref(skb, dst_clone(&rt->u.dst));
 			if (rt_fill_info(net, skb, NETLINK_CB(cb->skb).pid,
 					 cb->nlh->nlmsg_seq, RTM_NEWROUTE,
 					 1, NLM_F_MULTI) <=3D 0) {
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index c791bb6..0366cbc 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -28,7 +28,7 @@ static inline int xfrm4_rcv_encap_finish(struct sk_bu=
ff *skb)
 		const struct iphdr *iph =3D ip_hdr(skb);
=20
 		if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
-				   skb->dev))
+				   skb->dev, true))
 			goto drop;
 	}
 	return dst_input(skb);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2599870..7ae0fa5 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -570,7 +570,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_pa=
rm *opt,
 	} else {
 		ip_rt_put(rt);
 		if (ip_route_input(skb2, eiph->daddr, eiph->saddr, eiph->tos,
-				   skb2->dev) ||
+				   skb2->dev, false) ||
 		    skb_dst(skb2)->dev->type !=3D ARPHRD_TUNNEL)
 			goto out;
 	}
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index c49ef21..cb3cde4 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -9,6 +9,7 @@
 #include <linux/rcupdate.h>
 #include <net/protocol.h>
 #include <net/netfilter/nf_queue.h>
+#include <net/dst.h>
=20
 #include "nf_internals.h"
=20
@@ -170,6 +171,7 @@ static int __nf_queue(struct sk_buff *skb,
 			dev_hold(physoutdev);
 	}
 #endif
+	skb_dst_force(skb);
 	afinfo->saveroute(skb, entry);
 	status =3D qh->outfn(entry, queuenum);
=20
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index aeddabf..21e3976 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -179,7 +179,7 @@ static inline int qdisc_restart(struct Qdisc *q)
 	skb =3D dequeue_skb(q);
 	if (unlikely(!skb))
 		return 0;
-
+	WARN_ON_ONCE(skb_dst_is_noref(skb));
 	root_lock =3D qdisc_lock(q);
 	dev =3D qdisc_dev(q);
 	txq =3D netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));


