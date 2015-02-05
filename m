From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 19/29] net: vrf: Add vrf context to skb
Date: Wed,  4 Feb 2015 18:34:20 -0700
Message-ID: <1423100070-31848-20-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:48221 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966724AbbBEBgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:09 -0500
Received: by mail-ig0-f174.google.com with SMTP id b16so39146692igk.1
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:09 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ingress skb's inherit vrf context from the net_device. For TX skb's
inherit the vrf context from the socket originating the packet. Update
SKB related net_ctx macros to set vrf.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/skbuff.h   |  7 ++++---
 include/net/sock.h       |  2 ++
 include/net/tcp.h        |  1 +
 net/core/dev.c           |  1 +
 net/core/fib_rules.c     |  2 ++
 net/core/neighbour.c     |  2 ++
 net/core/skbuff.c        | 12 ++++++++++++
 net/ipv4/devinet.c       |  2 ++
 net/ipv4/icmp.c          |  2 +-
 net/ipv4/ip_output.c     |  2 ++
 net/ipv4/syncookies.c    |  1 +
 net/ipv4/tcp_ipv4.c      |  3 ++-
 net/netlink/af_netlink.c | 12 ++++++++++++
 13 files changed, 44 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a5dfef469d07..bdbee41e8032 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -522,6 +522,7 @@ struct sk_buff {
 	};
 	struct sock		*sk;
 	struct net_device	*dev;
+	__u32			vrf;
 
 	/*
 	 * This is the control buffer. It is free to use for every
@@ -665,9 +666,9 @@ struct sk_buff {
 	atomic_t		users;
 };
 
-#define SKB_NET_CTX_DEV(skb)  { .net = dev_net((skb)->dev) }
-#define SKB_NET_CTX_DST(skb)  { .net = dev_net(skb_dst((skb))->dev) }
-#define SKB_NET_CTX_SOCK(skb) { .net = sock_net((skb)->sk) }
+#define SKB_NET_CTX_DEV(skb)  { .net = dev_net((skb)->dev),	     .vrf = (skb)->vrf }
+#define SKB_NET_CTX_DST(skb)  { .net = dev_net(skb_dst((skb))->dev), .vrf = (skb)->vrf }
+#define SKB_NET_CTX_SOCK(skb) { .net = sock_net((skb)->sk),	     .vrf = (skb)->vrf }
 
 #ifdef __KERNEL__
 /*
diff --git a/include/net/sock.h b/include/net/sock.h
index a7cd250e9daf..d3668b691f82 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1976,6 +1976,7 @@ static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 	skb_orphan(skb);
 	skb->sk = sk;
 	skb->destructor = sock_wfree;
+	skb->vrf = sk->sk_vrf;
 	skb_set_hash_from_sk(skb, sk);
 	/*
 	 * We used to take a refcount on sk, but following operation
@@ -1990,6 +1991,7 @@ static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 	skb_orphan(skb);
 	skb->sk = sk;
 	skb->destructor = sock_rfree;
+	skb->vrf = sk->sk_vrf;
 	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
 	sk_mem_charge(sk, skb->truesize);
 }
diff --git a/include/net/tcp.h b/include/net/tcp.h
index b8fdc6bab3f3..ed46170de42a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1155,6 +1155,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->ir_rmt_port = tcp_hdr(skb)->source;
 	ireq->ir_num = ntohs(tcp_hdr(skb)->dest);
 	ireq->ir_mark = inet_request_mark(sk, skb);
+	ireq->ir_vrf = skb->vrf;
 }
 
 extern void tcp_openreq_init_rwin(struct request_sock *req,
diff --git a/net/core/dev.c b/net/core/dev.c
index 0d50b2c1944e..d64f5b107dba 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3698,6 +3698,7 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 
 another_round:
 	skb->skb_iif = skb->dev->ifindex;
+	skb->vrf = skb->dev->nd_vrf;
 
 	__this_cpu_inc(softnet_data.processed);
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index b793196f9521..9a1a4a23b6f6 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -690,6 +690,8 @@ static void notify_rule_change(int event, struct fib_rule *rule,
 	if (skb == NULL)
 		goto errout;
 
+	skb->vrf = ops->fro_vrf;
+
 	err = fib_nl_fill_rule(skb, rule, pid, nlh->nlmsg_seq, event, 0, ops);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in fib_rule_nlmsg_size() */
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f64e178738de..0fbbe70be170 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2780,6 +2780,8 @@ static void __neigh_notify(struct neighbour *n, int type, int flags)
 	if (skb == NULL)
 		goto errout;
 
+	skb->vrf = n->dev->nd_vrf;
+
 	err = neigh_fill_info(skb, n, 0, 0, type, flags);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in neigh_nlmsg_size() */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a5bff2767f15..61a75e891342 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -251,6 +251,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb->end = skb->tail + size;
 	skb->mac_header = (typeof(skb->mac_header))~0U;
 	skb->transport_header = (typeof(skb->transport_header))~0U;
+	skb->vrf = VRF_DEFAULT;
 
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
@@ -514,6 +515,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
+		skb->vrf = dev->nd_vrf;
 	}
 
 	return skb;
@@ -832,6 +834,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #endif
 #endif
 
+	new->vrf = old->vrf;
 }
 
 /*
@@ -864,6 +867,8 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 	atomic_inc(&(skb_shinfo(skb)->dataref));
 	skb->cloned = 1;
 
+	n->vrf = skb->vrf;
+
 	return n;
 #undef C
 }
@@ -1057,6 +1062,9 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 		BUG();
 
 	copy_skb_header(n, skb);
+
+	n->vrf = skb->vrf;
+
 	return n;
 }
 EXPORT_SYMBOL(skb_copy);
@@ -1120,6 +1128,8 @@ struct sk_buff *__pskb_copy_fclone(struct sk_buff *skb, int headroom,
 	}
 
 	copy_skb_header(n, skb);
+
+	n->vrf = skb->vrf;
 out:
 	return n;
 }
@@ -1294,6 +1304,8 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 
 	skb_headers_offset_update(n, newheadroom - oldheadroom);
 
+	n->vrf = skb->vrf;
+
 	return n;
 }
 EXPORT_SYMBOL(skb_copy_expand);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a0182f79f6bf..59de98a44508 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1603,6 +1603,8 @@ static void rtmsg_ifa(int event, struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 	if (skb == NULL)
 		goto errout;
 
+	skb->vrf = ifa->ifa_dev->dev->nd_vrf;
+
 	err = inet_fill_ifaddr(skb, ifa, portid, seq, event, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in inet_nlmsg_size() */
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f64de76f55ef..2d1e98e6ad14 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -389,7 +389,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	struct ipcm_cookie ipc;
 	struct rtable *rt = skb_rtable(skb);
 	struct net *net = dev_net(rt->dst.dev);
-	struct net_ctx dev_ctx = { .net = net };
+	struct net_ctx dev_ctx = { .net = net, .vrf = skb->vrf };
 	struct flowi4 fl4;
 	struct sock *sk;
 	struct inet_sock *inet;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 126d6edea34e..383bac145bf4 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -471,6 +471,8 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	to->ipvs_property = from->ipvs_property;
 #endif
 	skb_copy_secmark(to, from);
+
+	to->vrf = from->vrf;
 }
 
 /*
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 14b7a772c7a9..7702e1f94174 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -340,6 +340,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	ireq->ir_loc_addr	= ip_hdr(skb)->daddr;
 	ireq->ir_rmt_addr	= ip_hdr(skb)->saddr;
 	ireq->ir_mark		= inet_request_mark(sk, skb);
+	ireq->ir_vrf		= skb->vrf;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
 	ireq->wscale_ok		= tcp_opt.wscale_ok;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ceb5616a4273..24089b9534bf 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1368,6 +1368,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		sk_nocaps_add(newsk, NETIF_F_GSO_MASK);
 	}
 #endif
+	newsk->sk_vrf = skb->vrf;
 
 	if (__inet_inherit_port(sk, newsk) < 0)
 		goto put_and_exit;
@@ -1395,7 +1396,7 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct sock *nsk;
 	struct request_sock **prev;
-	struct net_ctx ctx = { .net = sock_net(sk) };
+	struct net_ctx ctx = { .net = sock_net(sk), .vrf = skb->vrf };
 	/* Find possible connection requests. */
 	struct request_sock *req = inet_csk_search_req(sk, &prev, th->source,
 						       iph->saddr, iph->daddr);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a36777b7cfb6..bd613406e033 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1736,6 +1736,14 @@ static struct sk_buff *netlink_trim(struct sk_buff *skb, gfp_t allocation)
 	return skb;
 }
 
+/*
+ * kernel sockets are all in vrf 1 (default vrf). Transactions
+ * (e.g., add/delete address/route) are happening in other vrfs.
+ * Packets for transactions from userpsace are funneled through the
+ * kernel sockets. Handle this case by resetting skb vrf after ownership
+ * assignment. rtnetlink based functions need to use skb->vrf for
+ * decisions which is set to the original userspace socket's vrf id.
+ */
 static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 				  struct sock *ssk)
 {
@@ -1744,8 +1752,11 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 
 	ret = -ECONNREFUSED;
 	if (nlk->netlink_rcv != NULL) {
+		__u32 vrf = skb->vrf;
 		ret = skb->len;
 		netlink_skb_set_owner_r(skb, sk);
+		/* use vrf from sending socket, not kernel's socket context */
+		skb->vrf = vrf;
 		NETLINK_CB(skb).sk = ssk;
 		netlink_deliver_tap_kernel(sk, ssk, skb);
 		nlk->netlink_rcv(skb);
@@ -2313,6 +2324,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (skb == NULL)
 		goto out;
 
+	skb->vrf = sk->sk_vrf;
 	NETLINK_CB(skb).portid	= nlk->portid;
 	NETLINK_CB(skb).dst_group = dst_group;
 	NETLINK_CB(skb).creds	= scm.creds;
-- 
1.9.3 (Apple Git-50)
