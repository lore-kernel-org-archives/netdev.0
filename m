From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 13/29] net: Convert function arg from struct net to struct net_ctx
Date: Wed,  4 Feb 2015 18:34:14 -0700
Message-ID: <1423100070-31848-14-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:52370 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322AbbBEBgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:06 -0500
Received: by mail-ig0-f174.google.com with SMTP id b16so39146437igk.1
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:05 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A sweep of core and ipv4 code changing uses of struct net. Difficult to
break this into smaller patches. Functionally there is no change in
behavior.

Sysctl settings and MIB counters will stay with the namespace. Almost
all other users of struct net are converted to struct net_ctx. This is
stepping stone for follow on patches which add a VRF id to the net
context.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/inetdevice.h      |  12 ++---
 include/net/addrconf.h          |  22 ++++----
 include/net/arp.h               |   2 +-
 include/net/dst.h               |  16 +++---
 include/net/fib_rules.h         |   2 +-
 include/net/flow.h              |   3 +-
 include/net/inet6_hashtables.h  |  19 +++----
 include/net/inet_hashtables.h   |  35 ++++++-------
 include/net/ip.h                |  10 ++--
 include/net/ip6_fib.h           |   4 +-
 include/net/ip6_route.h         |  24 ++++-----
 include/net/ip_fib.h            |  25 +++++----
 include/net/neighbour.h         |   8 +--
 include/net/net_namespace.h     |   8 +--
 include/net/route.h             |  42 ++++++++--------
 include/net/transp_v6.h         |   2 +-
 include/net/udp.h               |   8 +--
 include/net/xfrm.h              |  28 +++++------
 net/core/dev.c                  |  18 +++----
 net/core/fib_rules.c            |  23 +++++----
 net/core/flow.c                 |   5 +-
 net/core/neighbour.c            |  94 +++++++++++++++++-----------------
 net/ipv4/af_inet.c              |  16 +++---
 net/ipv4/arp.c                  |  66 +++++++++++++-----------
 net/ipv4/datagram.c             |   3 +-
 net/ipv4/devinet.c              |  34 +++++++------
 net/ipv4/fib_frontend.c         |  61 +++++++++++-----------
 net/ipv4/fib_rules.c            |  10 ++--
 net/ipv4/fib_semantics.c        |  29 ++++++-----
 net/ipv4/icmp.c                 |  36 ++++++-------
 net/ipv4/igmp.c                 |  46 +++++++++--------
 net/ipv4/inet_connection_sock.c |  18 ++++---
 net/ipv4/inet_diag.c            |  13 ++---
 net/ipv4/inet_hashtables.c      |  39 +++++++-------
 net/ipv4/ip_input.c             |   6 ++-
 net/ipv4/ip_options.c           |  20 ++++----
 net/ipv4/ip_output.c            |  11 ++--
 net/ipv4/ip_sockglue.c          |  14 ++++--
 net/ipv4/ipconfig.c             |   6 ++-
 net/ipv4/ipmr.c                 |  50 ++++++++++--------
 net/ipv4/netfilter.c            |  12 ++---
 net/ipv4/ping.c                 |  39 +++++++-------
 net/ipv4/raw.c                  |  30 +++++------
 net/ipv4/route.c                | 104 +++++++++++++++++++++-----------------
 net/ipv4/syncookies.c           |   3 +-
 net/ipv4/tcp_ipv4.c             |  41 ++++++++-------
 net/ipv4/udp.c                  | 109 ++++++++++++++++++++++------------------
 net/ipv4/udp_diag.c             |  11 ++--
 net/ipv4/xfrm4_policy.c         |  12 ++---
 net/sctp/protocol.c             |   9 ++--
 net/xfrm/xfrm_policy.c          |   9 ++--
 51 files changed, 684 insertions(+), 583 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 0a21fbefdfbe..b3aa61d4253f 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -153,18 +153,18 @@ int unregister_inetaddr_notifier(struct notifier_block *nb);
 void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
 				 struct ipv4_devconf *devconf);
 
-struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref);
-static inline struct net_device *ip_dev_find(struct net *net, __be32 addr)
+struct net_device *__ip_dev_find(struct net_ctx *ctx, __be32 addr, bool devref);
+static inline struct net_device *ip_dev_find(struct net_ctx *ctx, __be32 addr)
 {
-	return __ip_dev_find(net, addr, true);
+	return __ip_dev_find(ctx, addr, true);
 }
 
 int inet_addr_onlink(struct in_device *in_dev, __be32 a, __be32 b);
-int devinet_ioctl(struct net *net, unsigned int cmd, void __user *);
+int devinet_ioctl(struct net_ctx *ctx, unsigned int cmd, void __user *);
 void devinet_init(void);
-struct in_device *inetdev_by_index(struct net *, int);
+struct in_device *inetdev_by_index(struct net_ctx *, int);
 __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope);
-__be32 inet_confirm_addr(struct net *net, struct in_device *in_dev, __be32 dst,
+__be32 inet_confirm_addr(struct net_ctx *ctx, struct in_device *in_dev, __be32 dst,
 			 __be32 local, int scope);
 struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix,
 				    __be32 mask);
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index d13573bb879e..a872e62b2003 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -56,15 +56,15 @@ struct prefix_info {
 int addrconf_init(void);
 void addrconf_cleanup(void);
 
-int addrconf_add_ifaddr(struct net *net, void __user *arg);
-int addrconf_del_ifaddr(struct net *net, void __user *arg);
-int addrconf_set_dstaddr(struct net *net, void __user *arg);
+int addrconf_add_ifaddr(struct net_ctx *ctx, void __user *arg);
+int addrconf_del_ifaddr(struct net_ctx *ctx, void __user *arg);
+int addrconf_set_dstaddr(struct net_ctx *ctx, void __user *arg);
 
-int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
+int ipv6_chk_addr(struct net_ctx *ctx, const struct in6_addr *addr,
 		  const struct net_device *dev, int strict);
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
-int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr);
+int ipv6_chk_home_addr(struct net_ctx *ctx, const struct in6_addr *addr);
 #endif
 
 bool ipv6_chk_custom_prefix(const struct in6_addr *addr,
@@ -73,11 +73,11 @@ bool ipv6_chk_custom_prefix(const struct in6_addr *addr,
 
 int ipv6_chk_prefix(const struct in6_addr *addr, struct net_device *dev);
 
-struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net,
+struct inet6_ifaddr *ipv6_get_ifaddr(struct net_ctx *ctx,
 				     const struct in6_addr *addr,
 				     struct net_device *dev, int strict);
 
-int ipv6_dev_get_saddr(struct net *net, const struct net_device *dev,
+int ipv6_dev_get_saddr(struct net_ctx *ctx, const struct net_device *dev,
 		       const struct in6_addr *daddr, unsigned int srcprefs,
 		       struct in6_addr *saddr);
 int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
@@ -116,7 +116,7 @@ static inline int addrconf_finite_timeout(unsigned long timeout)
 int ipv6_addr_label_init(void);
 void ipv6_addr_label_cleanup(void);
 void ipv6_addr_label_rtnl_register(void);
-u32 ipv6_addr_label(struct net *net, const struct in6_addr *addr,
+u32 ipv6_addr_label(struct net_ctx *ctx, const struct in6_addr *addr,
 		    int type, int ifindex);
 
 /*
@@ -205,9 +205,9 @@ void ipv6_sock_ac_close(struct sock *sk);
 int __ipv6_dev_ac_inc(struct inet6_dev *idev, const struct in6_addr *addr);
 int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr);
 void ipv6_ac_destroy_dev(struct inet6_dev *idev);
-bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
+bool ipv6_chk_acast_addr(struct net_ctx *ctx, struct net_device *dev,
 			 const struct in6_addr *addr);
-bool ipv6_chk_acast_addr_src(struct net *net, struct net_device *dev,
+bool ipv6_chk_acast_addr_src(struct net_ctx *ctx, struct net_device *dev,
 			     const struct in6_addr *addr);
 
 /* Device notifier */
@@ -215,7 +215,7 @@ int register_inet6addr_notifier(struct notifier_block *nb);
 int unregister_inet6addr_notifier(struct notifier_block *nb);
 int inet6addr_notifier_call_chain(unsigned long val, void *v);
 
-void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
+void inet6_netconf_notify_devconf(struct net_ctx *ctx, int type, int ifindex,
 				  struct ipv6_devconf *devconf);
 
 /**
diff --git a/include/net/arp.h b/include/net/arp.h
index 73c49864076b..8189c7358af5 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -48,7 +48,7 @@ static inline struct neighbour *__ipv4_neigh_lookup(struct net_device *dev, u32
 
 void arp_init(void);
 int arp_find(unsigned char *haddr, struct sk_buff *skb);
-int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg);
+int arp_ioctl(struct net_ctx *ctx, unsigned int cmd, void __user *arg);
 void arp_send(int type, int ptype, __be32 dest_ip,
 	      struct net_device *dev, __be32 src_ip,
 	      const unsigned char *dest_hw,
diff --git a/include/net/dst.h b/include/net/dst.h
index a8ae4e760778..13ee371e8486 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -323,7 +323,7 @@ static inline void skb_dst_force(struct sk_buff *skb)
  *	so make some cleanups. (no accounting done)
  */
 static inline void __skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev,
-				   struct net *net)
+				   struct net_ctx *ctx)
 {
 	skb->dev = dev;
 
@@ -334,7 +334,7 @@ static inline void __skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev,
 	 */
 	skb_clear_hash_if_not_l4(skb);
 	skb_set_queue_mapping(skb, 0);
-	skb_scrub_packet(skb, !net_eq(net, dev_net(dev)));
+	skb_scrub_packet(skb, !dev_net_ctx_eq(dev, ctx));
 }
 
 /**
@@ -347,12 +347,12 @@ static inline void __skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev,
  *	Note: this accounting is not SMP safe.
  */
 static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev,
-				 struct net *net)
+				 struct net_ctx *ctx)
 {
 	/* TODO : stats should be SMP safe */
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += skb->len;
-	__skb_tunnel_rx(skb, dev, net);
+	__skb_tunnel_rx(skb, dev, ctx);
 }
 
 /* Children define the path of the packet through the
@@ -485,7 +485,7 @@ enum {
 
 struct flowi;
 #ifndef CONFIG_XFRM
-static inline struct dst_entry *xfrm_lookup(struct net *net,
+static inline struct dst_entry *xfrm_lookup(struct net_ctx *net_ctx,
 					    struct dst_entry *dst_orig,
 					    const struct flowi *fl, struct sock *sk,
 					    int flags)
@@ -493,7 +493,7 @@ static inline struct dst_entry *xfrm_lookup(struct net *net,
 	return dst_orig;
 }
 
-static inline struct dst_entry *xfrm_lookup_route(struct net *net,
+static inline struct dst_entry *xfrm_lookup_route(struct net_ctx *ctx,
 						  struct dst_entry *dst_orig,
 						  const struct flowi *fl,
 						  struct sock *sk,
@@ -508,11 +508,11 @@ static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
 }
 
 #else
-struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
+struct dst_entry *xfrm_lookup(struct net_ctx *ctx, struct dst_entry *dst_orig,
 			      const struct flowi *fl, struct sock *sk,
 			      int flags);
 
-struct dst_entry *xfrm_lookup_route(struct net *net, struct dst_entry *dst_orig,
+struct dst_entry *xfrm_lookup_route(struct net_ctx *ctx, struct dst_entry *dst_orig,
 				    const struct flowi *fl, struct sock *sk,
 				    int flags);
 
diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index b02bd45e3e97..1a545b23494e 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -118,7 +118,7 @@ static inline u32 frh_get_table(struct fib_rule_hdr *frh, struct nlattr **nla)
 }
 
 struct fib_rules_ops *fib_rules_register(const struct fib_rules_ops *,
-					 struct net *);
+					 struct net_ctx *);
 void fib_rules_unregister(struct fib_rules_ops *);
 
 int fib_rules_lookup(struct fib_rules_ops *, struct flowi *, int flags,
diff --git a/include/net/flow.h b/include/net/flow.h
index 8109a159d1b3..07e7a58b9aac 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -205,6 +205,7 @@ static inline size_t flow_key_size(u16 family)
 #define FLOW_DIR_FWD	2
 
 struct net;
+struct net_ctx;
 struct sock;
 struct flow_cache_ops;
 
@@ -222,7 +223,7 @@ typedef struct flow_cache_object *(*flow_resolve_t)(
 		struct net *net, const struct flowi *key, u16 family,
 		u8 dir, struct flow_cache_object *oldobj, void *ctx);
 
-struct flow_cache_object *flow_cache_lookup(struct net *net,
+struct flow_cache_object *flow_cache_lookup(struct net_ctx *net_ctx,
 					    const struct flowi *key, u16 family,
 					    u8 dir, flow_resolve_t resolver,
 					    void *ctx);
diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index 9201afe083fa..7b8e7dd06cc8 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -46,21 +46,21 @@ int __inet6_hash(struct sock *sk, struct inet_timewait_sock *twp);
  *
  * The sockhash lock must be held as a reader here.
  */
-struct sock *__inet6_lookup_established(struct net *net,
+struct sock *__inet6_lookup_established(struct net_ctx *ctx,
 					struct inet_hashinfo *hashinfo,
 					const struct in6_addr *saddr,
 					const __be16 sport,
 					const struct in6_addr *daddr,
 					const u16 hnum, const int dif);
 
-struct sock *inet6_lookup_listener(struct net *net,
+struct sock *inet6_lookup_listener(struct net_ctx *ctx,
 				   struct inet_hashinfo *hashinfo,
 				   const struct in6_addr *saddr,
 				   const __be16 sport,
 				   const struct in6_addr *daddr,
 				   const unsigned short hnum, const int dif);
 
-static inline struct sock *__inet6_lookup(struct net *net,
+static inline struct sock *__inet6_lookup(struct net_ctx *ctx,
 					  struct inet_hashinfo *hashinfo,
 					  const struct in6_addr *saddr,
 					  const __be16 sport,
@@ -68,12 +68,12 @@ static inline struct sock *__inet6_lookup(struct net *net,
 					  const u16 hnum,
 					  const int dif)
 {
-	struct sock *sk = __inet6_lookup_established(net, hashinfo, saddr,
+	struct sock *sk = __inet6_lookup_established(ctx, hashinfo, saddr,
 						sport, daddr, hnum, dif);
 	if (sk)
 		return sk;
 
-	return inet6_lookup_listener(net, hashinfo, saddr, sport,
+	return inet6_lookup_listener(ctx, hashinfo, saddr, sport,
 				     daddr, hnum, dif);
 }
 
@@ -84,29 +84,30 @@ static inline struct sock *__inet6_lookup_skb(struct inet_hashinfo *hashinfo,
 					      int iif)
 {
 	struct sock *sk = skb_steal_sock(skb);
+	struct net_ctx ctx = SKB_NET_CTX_DST(skb);
 
 	if (sk)
 		return sk;
 
-	return __inet6_lookup(dev_net(skb_dst(skb)->dev), hashinfo,
+	return __inet6_lookup(&ctx, hashinfo,
 			      &ipv6_hdr(skb)->saddr, sport,
 			      &ipv6_hdr(skb)->daddr, ntohs(dport),
 			      iif);
 }
 
-struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
+struct sock *inet6_lookup(struct net_ctx *ctx, struct inet_hashinfo *hashinfo,
 			  const struct in6_addr *saddr, const __be16 sport,
 			  const struct in6_addr *daddr, const __be16 dport,
 			  const int dif);
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 
-#define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	\
+#define INET6_MATCH(__sk, __ctx, __saddr, __daddr, __ports, __dif)	\
 	(((__sk)->sk_portpair == (__ports))			&&	\
 	 ((__sk)->sk_family == AF_INET6)			&&	\
 	 ipv6_addr_equal(&(__sk)->sk_v6_daddr, (__saddr))		&&	\
 	 ipv6_addr_equal(&(__sk)->sk_v6_rcv_saddr, (__daddr))	&&	\
 	 (!(__sk)->sk_bound_dev_if	||				\
 	   ((__sk)->sk_bound_dev_if == (__dif))) 		&&	\
-	 net_eq(sock_net(__sk), (__net)))
+	 sock_net_ctx_eq((__sk), (__net)))
 
 #endif /* _INET6_HASHTABLES_H */
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index c9e8b7b7331a..9ddc1b2309ce 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -230,7 +230,7 @@ static inline void inet_ehash_locks_free(struct inet_hashinfo *hashinfo)
 }
 
 struct inet_bind_bucket *
-inet_bind_bucket_create(struct kmem_cache *cachep, struct net *net,
+inet_bind_bucket_create(struct kmem_cache *cachep, struct net_ctx *ctx,
 			struct inet_bind_hashbucket *head,
 			const unsigned short snum);
 void inet_bind_bucket_destroy(struct kmem_cache *cachep,
@@ -267,19 +267,19 @@ int __inet_hash_nolisten(struct sock *sk, struct inet_timewait_sock *tw);
 void inet_hash(struct sock *sk);
 void inet_unhash(struct sock *sk);
 
-struct sock *__inet_lookup_listener(struct net *net,
+struct sock *__inet_lookup_listener(struct net_ctx *ctx,
 				    struct inet_hashinfo *hashinfo,
 				    const __be32 saddr, const __be16 sport,
 				    const __be32 daddr,
 				    const unsigned short hnum,
 				    const int dif);
 
-static inline struct sock *inet_lookup_listener(struct net *net,
+static inline struct sock *inet_lookup_listener(struct net_ctx *ctx,
 		struct inet_hashinfo *hashinfo,
 		__be32 saddr, __be16 sport,
 		__be32 daddr, __be16 dport, int dif)
 {
-	return __inet_lookup_listener(net, hashinfo, saddr, sport,
+	return __inet_lookup_listener(ctx, hashinfo, saddr, sport,
 				      daddr, ntohs(dport), dif);
 }
 
@@ -312,23 +312,23 @@ static inline struct sock *inet_lookup_listener(struct net *net,
 				   (((__force __u64)(__be32)(__daddr)) << 32) | \
 				   ((__force __u64)(__be32)(__saddr)))
 #endif /* __BIG_ENDIAN */
-#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)	\
+#define INET_MATCH(__sk, __ctx, __cookie, __saddr, __daddr, __ports, __dif)	\
 	(((__sk)->sk_portpair == (__ports))			&&	\
 	 ((__sk)->sk_addrpair == (__cookie))			&&	\
 	 (!(__sk)->sk_bound_dev_if	||				\
 	   ((__sk)->sk_bound_dev_if == (__dif))) 		&& 	\
-	 net_eq(sock_net(__sk), (__net)))
+	 sock_net_ctx_eq((__sk), (__ctx)))
 #else /* 32-bit arch */
 #define INET_ADDR_COOKIE(__name, __saddr, __daddr) \
 	const int __name __deprecated __attribute__((unused))
 
-#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif) \
+#define INET_MATCH(__sk, __ctx, __cookie, __saddr, __daddr, __ports, __dif) \
 	(((__sk)->sk_portpair == (__ports))		&&		\
 	 ((__sk)->sk_daddr	== (__saddr))		&&		\
 	 ((__sk)->sk_rcv_saddr	== (__daddr))		&&		\
 	 (!(__sk)->sk_bound_dev_if	||				\
 	   ((__sk)->sk_bound_dev_if == (__dif))) 	&&		\
-	 net_eq(sock_net(__sk), (__net)))
+	 sock_net_ctx_eq((__sk), (__ctx)))
 #endif /* 64-bit arch */
 
 /*
@@ -337,37 +337,37 @@ static inline struct sock *inet_lookup_listener(struct net *net,
  *
  * Local BH must be disabled here.
  */
-struct sock *__inet_lookup_established(struct net *net,
+struct sock *__inet_lookup_established(struct net_ctx *ctx,
 				       struct inet_hashinfo *hashinfo,
 				       const __be32 saddr, const __be16 sport,
 				       const __be32 daddr, const u16 hnum,
 				       const int dif);
 
 static inline struct sock *
-	inet_lookup_established(struct net *net, struct inet_hashinfo *hashinfo,
+	inet_lookup_established(struct net_ctx *ctx, struct inet_hashinfo *hashinfo,
 				const __be32 saddr, const __be16 sport,
 				const __be32 daddr, const __be16 dport,
 				const int dif)
 {
-	return __inet_lookup_established(net, hashinfo, saddr, sport, daddr,
+	return __inet_lookup_established(ctx, hashinfo, saddr, sport, daddr,
 					 ntohs(dport), dif);
 }
 
-static inline struct sock *__inet_lookup(struct net *net,
+static inline struct sock *__inet_lookup(struct net_ctx *ctx,
 					 struct inet_hashinfo *hashinfo,
 					 const __be32 saddr, const __be16 sport,
 					 const __be32 daddr, const __be16 dport,
 					 const int dif)
 {
 	u16 hnum = ntohs(dport);
-	struct sock *sk = __inet_lookup_established(net, hashinfo,
+	struct sock *sk = __inet_lookup_established(ctx, hashinfo,
 				saddr, sport, daddr, hnum, dif);
 
-	return sk ? : __inet_lookup_listener(net, hashinfo, saddr, sport,
+	return sk ? : __inet_lookup_listener(ctx, hashinfo, saddr, sport,
 					     daddr, hnum, dif);
 }
 
-static inline struct sock *inet_lookup(struct net *net,
+static inline struct sock *inet_lookup(struct net_ctx *ctx,
 				       struct inet_hashinfo *hashinfo,
 				       const __be32 saddr, const __be16 sport,
 				       const __be32 daddr, const __be16 dport,
@@ -376,7 +376,7 @@ static inline struct sock *inet_lookup(struct net *net,
 	struct sock *sk;
 
 	local_bh_disable();
-	sk = __inet_lookup(net, hashinfo, saddr, sport, daddr, dport, dif);
+	sk = __inet_lookup(ctx, hashinfo, saddr, sport, daddr, dport, dif);
 	local_bh_enable();
 
 	return sk;
@@ -389,11 +389,12 @@ static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 {
 	struct sock *sk = skb_steal_sock(skb);
 	const struct iphdr *iph = ip_hdr(skb);
+	struct net_ctx ctx = SKB_NET_CTX_DST(skb);
 
 	if (sk)
 		return sk;
 	else
-		return __inet_lookup(dev_net(skb_dst(skb)->dev), hashinfo,
+		return __inet_lookup(&ctx, hashinfo,
 				     iph->saddr, sport,
 				     iph->daddr, dport, inet_iif(skb));
 }
diff --git a/include/net/ip.h b/include/net/ip.h
index 14211eaff17f..b1516fa33ac4 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -181,7 +181,7 @@ static inline __u8 ip_reply_arg_flowi_flags(const struct ip_reply_arg *arg)
 	return (arg->flags & IP_REPLY_ARG_NOSRCCHECK) ? FLOWI_FLAG_ANYSRC : 0;
 }
 
-void ip_send_unicast_reply(struct net *net, struct sk_buff *skb,
+void ip_send_unicast_reply(struct net_ctx *ctx, struct sk_buff *skb,
 			   const struct ip_options *sopt,
 			   __be32 daddr, __be32 saddr,
 			   const struct ip_reply_arg *arg,
@@ -523,11 +523,11 @@ static inline int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb)
 }
 
 void ip_options_fragment(struct sk_buff *skb);
-int ip_options_compile(struct net *net, struct ip_options *opt,
+int ip_options_compile(struct net_ctx *ctx, struct ip_options *opt,
 		       struct sk_buff *skb);
-int ip_options_get(struct net *net, struct ip_options_rcu **optp,
+int ip_options_get(struct net_ctx *ctx, struct ip_options_rcu **optp,
 		   unsigned char *data, int optlen);
-int ip_options_get_from_user(struct net *net, struct ip_options_rcu **optp,
+int ip_options_get_from_user(struct net_ctx *ctx, struct ip_options_rcu **optp,
 			     unsigned char __user *data, int optlen);
 void ip_options_undo(struct ip_options *opt);
 void ip_forward_options(struct sk_buff *skb);
@@ -539,7 +539,7 @@ int ip_options_rcv_srr(struct sk_buff *skb);
 
 void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb);
 void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb, int offset);
-int ip_cmsg_send(struct net *net, struct msghdr *msg,
+int ip_cmsg_send(struct net_ctx *ctx, struct msghdr *msg,
 		 struct ipcm_cookie *ipc, bool allow_ipv6);
 int ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
 		  unsigned int optlen);
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 20e80fa7bbdd..b9b3df17b99d 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -293,7 +293,7 @@ struct fib6_node *fib6_locate(struct fib6_node *root,
 			      const struct in6_addr *daddr, int dst_len,
 			      const struct in6_addr *saddr, int src_len);
 
-void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
+void fib6_clean_all(struct net_ctx *ctx, int (*func)(struct rt6_info *, void *arg),
 		    void *arg);
 
 int fib6_add(struct fib6_node *root, struct rt6_info *rt,
@@ -302,7 +302,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info);
 
 void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info);
 
-void fib6_run_gc(unsigned long expires, struct net *net, bool force);
+void fib6_run_gc(unsigned long expires, struct net_ctx *ctx, bool force);
 
 void fib6_gc_cleanup(void);
 
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 1d09b46c1e48..9967de3772c3 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -64,31 +64,31 @@ static inline bool rt6_need_strict(const struct in6_addr *daddr)
 
 void ip6_route_input(struct sk_buff *skb);
 
-struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
+struct dst_entry *ip6_route_output(struct net_ctx *ctx, const struct sock *sk,
 				   struct flowi6 *fl6);
-struct dst_entry *ip6_route_lookup(struct net *net, struct flowi6 *fl6,
+struct dst_entry *ip6_route_lookup(struct net_ctx *ctx, struct flowi6 *fl6,
 				   int flags);
 
 int ip6_route_init(void);
 void ip6_route_cleanup(void);
 
-int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg);
+int ipv6_route_ioctl(struct net_ctx *ctx, unsigned int cmd, void __user *arg);
 
 int ip6_route_add(struct fib6_config *cfg);
 int ip6_ins_rt(struct rt6_info *);
 int ip6_del_rt(struct rt6_info *);
 
-int ip6_route_get_saddr(struct net *net, struct rt6_info *rt,
+int ip6_route_get_saddr(struct net_ctx *ctx, struct rt6_info *rt,
 			const struct in6_addr *daddr, unsigned int prefs,
 			struct in6_addr *saddr);
 
-struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
+struct rt6_info *rt6_lookup(struct net_ctx *ctx, const struct in6_addr *daddr,
 			    const struct in6_addr *saddr, int oif, int flags);
 
 struct dst_entry *icmp6_dst_alloc(struct net_device *dev, struct flowi6 *fl6);
 int icmp6_dst_gc(void);
 
-void fib6_force_start_gc(struct net *net);
+void fib6_force_start_gc(struct net_ctx *ctx);
 
 struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    const struct in6_addr *addr, bool anycast);
@@ -107,11 +107,11 @@ void rt6_purge_dflt_routers(struct net *net);
 int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 		  const struct in6_addr *gwaddr);
 
-void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu, int oif,
+void ip6_update_pmtu(struct sk_buff *skb, struct net_ctx *ctx, __be32 mtu, int oif,
 		     u32 mark);
 void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu);
-void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark);
-void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
+void ip6_redirect(struct sk_buff *skb, struct net_ctx *ctx, int oif, u32 mark);
+void ip6_redirect_no_header(struct sk_buff *skb, struct net_ctx *ctx, int oif,
 			    u32 mark);
 void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk);
 
@@ -120,14 +120,14 @@ struct netlink_callback;
 struct rt6_rtnl_dump_arg {
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
-	struct net *net;
+	struct net_ctx *ctx;
 };
 
 int rt6_dump_route(struct rt6_info *rt, void *p_arg);
-void rt6_ifdown(struct net *net, struct net_device *dev);
+void rt6_ifdown(struct net_ctx *ctx, struct net_device *dev);
 void rt6_mtu_change(struct net_device *dev, unsigned int mtu);
 void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
-void rt6_clean_tohost(struct net *net, struct in6_addr *gateway);
+void rt6_clean_tohost(struct net_ctx *ctx, struct in6_addr *gateway);
 
 
 /*
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index dca7f30be57f..85f5ddacba8d 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -175,19 +175,19 @@ struct fib_result_nl {
 #define FIB_TABLE_HASHSZ 2
 #endif
 
-__be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
+__be32 fib_info_update_nh_saddr(struct net_ctx *ctx, struct fib_nh *nh);
 
-#define FIB_RES_SADDR(net, res)				\
+#define FIB_RES_SADDR(ctx, res)				\
 	((FIB_RES_NH(res).nh_saddr_genid ==		\
-	  atomic_read(&(net)->ipv4.dev_addr_genid)) ?	\
+	  atomic_read(&(ctx)->net->ipv4.dev_addr_genid)) ? \
 	 FIB_RES_NH(res).nh_saddr :			\
-	 fib_info_update_nh_saddr((net), &FIB_RES_NH(res)))
+	 fib_info_update_nh_saddr((ctx), &FIB_RES_NH(res)))
 #define FIB_RES_GW(res)			(FIB_RES_NH(res).nh_gw)
 #define FIB_RES_DEV(res)		(FIB_RES_NH(res).nh_dev)
 #define FIB_RES_OIF(res)		(FIB_RES_NH(res).nh_oif)
 
-#define FIB_RES_PREFSRC(net, res)	((res).fi->fib_prefsrc ? : \
-					 FIB_RES_SADDR(net, res))
+#define FIB_RES_PREFSRC(ctx, res)	((res).fi->fib_prefsrc ? : \
+					 FIB_RES_SADDR(ctx, res))
 
 struct fib_table {
 	struct hlist_node	tb_hlist;
@@ -228,9 +228,10 @@ static inline struct fib_table *fib_new_table(struct net *net, u32 id)
 	return fib_get_table(net, id);
 }
 
-static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
+static inline int fib_lookup(struct net_ctx *ctx, const struct flowi4 *flp,
 			     struct fib_result *res)
 {
+	struct net *net = ctx->net;
 	int err = -ENETUNREACH;
 
 	rcu_read_lock();
@@ -253,11 +254,13 @@ void __net_exit fib4_rules_exit(struct net *net);
 struct fib_table *fib_new_table(struct net *net, u32 id);
 struct fib_table *fib_get_table(struct net *net, u32 id);
 
-int __fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res);
+int __fib_lookup(struct net_ctx *ctx, struct flowi4 *flp, struct fib_result *res);
 
-static inline int fib_lookup(struct net *net, struct flowi4 *flp,
+static inline int fib_lookup(struct net_ctx *ctx, struct flowi4 *flp,
 			     struct fib_result *res)
 {
+	struct net *net = ctx->net;
+
 	if (!net->ipv4.fib_has_custom_rules) {
 		int err = -ENETUNREACH;
 
@@ -279,7 +282,7 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 
 		return err;
 	}
-	return __fib_lookup(net, flp, res);
+	return __fib_lookup(ctx, flp, res);
 }
 
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
@@ -307,7 +310,7 @@ static inline int fib_num_tclassid_users(struct net *net)
 /* Exported by fib_semantics.c */
 int ip_fib_check_default(__be32 gw, struct net_device *dev);
 int fib_sync_down_dev(struct net_device *dev, int force);
-int fib_sync_down_addr(struct net *net, __be32 local);
+int fib_sync_down_addr(struct net_ctx *ctx, __be32 local);
 int fib_sync_up(struct net_device *dev);
 void fib_select_multipath(struct fib_result *res);
 
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 6228edd1e483..8cf9bc2236da 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -246,7 +246,7 @@ void neigh_table_init(int index, struct neigh_table *tbl);
 int neigh_table_clear(int index, struct neigh_table *tbl);
 struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 			       struct net_device *dev);
-struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
+struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net_ctx *ctx,
 				     const void *pkey);
 struct neighbour *__neigh_create(struct neigh_table *tbl, const void *pkey,
 				 struct net_device *dev, bool want_ref);
@@ -297,12 +297,12 @@ unsigned long neigh_rand_reach_time(unsigned long base);
 
 void pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 		    struct sk_buff *skb);
-struct pneigh_entry *pneigh_lookup(struct neigh_table *tbl, struct net *net,
+struct pneigh_entry *pneigh_lookup(struct neigh_table *tbl, struct net_ctx *ctx,
 				   const void *key, struct net_device *dev,
 				   int creat);
-struct pneigh_entry *__pneigh_lookup(struct neigh_table *tbl, struct net *net,
+struct pneigh_entry *__pneigh_lookup(struct neigh_table *tbl, struct net_ctx *ctx,
 				     const void *key, struct net_device *dev);
-int pneigh_delete(struct neigh_table *tbl, struct net *net, const void *key,
+int pneigh_delete(struct neigh_table *tbl, struct net_ctx *ctx, const void *key,
 		  struct net_device *dev);
 
 static inline struct net *pneigh_net(const struct pneigh_entry *pneigh)
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index b932f2a83865..e7060b43570d 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -368,9 +368,9 @@ static inline void unregister_net_sysctl_table(struct ctl_table_header *header)
 }
 #endif
 
-static inline int rt_genid_ipv4(struct net *net)
+static inline int rt_genid_ipv4(struct net_ctx *ctx)
 {
-	return atomic_read(&net->ipv4.rt_genid);
+	return atomic_read(&ctx->net->ipv4.rt_genid);
 }
 
 static inline void rt_genid_bump_ipv4(struct net *net)
@@ -400,9 +400,9 @@ static inline void rt_genid_bump_all(struct net *net)
 	rt_genid_bump_ipv6(net);
 }
 
-static inline int fnhe_genid(struct net *net)
+static inline int fnhe_genid(struct net_ctx *ctx)
 {
-	return atomic_read(&net->fnhe_genid);
+	return atomic_read(&ctx->net->fnhe_genid);
 }
 
 static inline void fnhe_genid_bump(struct net *net)
diff --git a/include/net/route.h b/include/net/route.h
index fe22d03afb6a..5f0b770225d7 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -110,18 +110,18 @@ struct in_device;
 int ip_rt_init(void);
 void rt_cache_flush(struct net *net);
 void rt_flush_dev(struct net_device *dev);
-struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp);
-struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
+struct rtable *__ip_route_output_key(struct net_ctx *, struct flowi4 *flp);
+struct rtable *ip_route_output_flow(struct net_ctx *, struct flowi4 *flp,
 				    struct sock *sk);
-struct dst_entry *ipv4_blackhole_route(struct net *net,
+struct dst_entry *ipv4_blackhole_route(struct net_ctx *ctx,
 				       struct dst_entry *dst_orig);
 
-static inline struct rtable *ip_route_output_key(struct net *net, struct flowi4 *flp)
+static inline struct rtable *ip_route_output_key(struct net_ctx *ctx, struct flowi4 *flp)
 {
-	return ip_route_output_flow(net, flp, NULL);
+	return ip_route_output_flow(ctx, flp, NULL);
 }
 
-static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
+static inline struct rtable *ip_route_output(struct net_ctx *ctx, __be32 daddr,
 					     __be32 saddr, u8 tos, int oif)
 {
 	struct flowi4 fl4 = {
@@ -130,10 +130,10 @@ static inline struct rtable *ip_route_output(struct net *net, __be32 daddr,
 		.daddr = daddr,
 		.saddr = saddr,
 	};
-	return ip_route_output_key(net, &fl4);
+	return ip_route_output_key(ctx, &fl4);
 }
 
-static inline struct rtable *ip_route_output_ports(struct net *net, struct flowi4 *fl4,
+static inline struct rtable *ip_route_output_ports(struct net_ctx *ctx, struct flowi4 *fl4,
 						   struct sock *sk,
 						   __be32 daddr, __be32 saddr,
 						   __be16 dport, __be16 sport,
@@ -145,10 +145,10 @@ static inline struct rtable *ip_route_output_ports(struct net *net, struct flowi
 			   daddr, saddr, dport, sport);
 	if (sk)
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
-	return ip_route_output_flow(net, fl4, sk);
+	return ip_route_output_flow(ctx, fl4, sk);
 }
 
-static inline struct rtable *ip_route_output_gre(struct net *net, struct flowi4 *fl4,
+static inline struct rtable *ip_route_output_gre(struct net_ctx *ctx, struct flowi4 *fl4,
 						 __be32 daddr, __be32 saddr,
 						 __be32 gre_key, __u8 tos, int oif)
 {
@@ -159,7 +159,7 @@ static inline struct rtable *ip_route_output_gre(struct net *net, struct flowi4
 	fl4->flowi4_tos = tos;
 	fl4->flowi4_proto = IPPROTO_GRE;
 	fl4->fl4_gre_key = gre_key;
-	return ip_route_output_key(net, fl4);
+	return ip_route_output_key(ctx, fl4);
 }
 
 int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 src,
@@ -179,19 +179,19 @@ static inline int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
 	return err;
 }
 
-void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu, int oif,
+void ipv4_update_pmtu(struct sk_buff *skb, struct net_ctx *ctx, u32 mtu, int oif,
 		      u32 mark, u8 protocol, int flow_flags);
 void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu);
-void ipv4_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark,
+void ipv4_redirect(struct sk_buff *skb, struct net_ctx *ctx, int oif, u32 mark,
 		   u8 protocol, int flow_flags);
 void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk);
 void ip_rt_send_redirect(struct sk_buff *skb);
 
-unsigned int inet_addr_type(struct net *net, __be32 addr);
-unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
+unsigned int inet_addr_type(struct net_ctx *ctx, __be32 addr);
+unsigned int inet_dev_addr_type(struct net_ctx *ctx, const struct net_device *dev,
 				__be32 addr);
 void ip_rt_multicast_event(struct in_device *);
-int ip_rt_ioctl(struct net *, unsigned int cmd, void __user *arg);
+int ip_rt_ioctl(struct net_ctx *, unsigned int cmd, void __user *arg);
 void ip_rt_get_source(u8 *src, struct sk_buff *skb, struct rtable *rt);
 
 struct in_ifaddr;
@@ -260,21 +260,21 @@ static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
 					      __be16 sport, __be16 dport,
 					      struct sock *sk)
 {
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 	struct rtable *rt;
 
 	ip_route_connect_init(fl4, dst, src, tos, oif, protocol,
 			      sport, dport, sk);
 
 	if (!dst || !src) {
-		rt = __ip_route_output_key(net, fl4);
+		rt = __ip_route_output_key(&sk_ctx, fl4);
 		if (IS_ERR(rt))
 			return rt;
 		ip_rt_put(rt);
 		flowi4_update_output(fl4, oif, tos, fl4->daddr, fl4->saddr);
 	}
 	security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
-	return ip_route_output_flow(net, fl4, sk);
+	return ip_route_output_flow(&sk_ctx, fl4, sk);
 }
 
 static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable *rt,
@@ -283,6 +283,8 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
 					       struct sock *sk)
 {
 	if (sport != orig_sport || dport != orig_dport) {
+		struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
+
 		fl4->fl4_dport = dport;
 		fl4->fl4_sport = sport;
 		ip_rt_put(rt);
@@ -290,7 +292,7 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
 				     RT_CONN_FLAGS(sk), fl4->daddr,
 				     fl4->saddr);
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
-		return ip_route_output_flow(sock_net(sk), fl4, sk);
+		return ip_route_output_flow(&sk_ctx, fl4, sk);
 	}
 	return rt;
 }
diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index b927413dde86..34a8685554f9 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -40,7 +40,7 @@ void ip6_datagram_recv_common_ctl(struct sock *sk, struct msghdr *msg,
 void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
 				    struct sk_buff *skb);
 
-int ip6_datagram_send_ctl(struct net *net, struct sock *sk, struct msghdr *msg,
+int ip6_datagram_send_ctl(struct net_ctx *ctx, struct sock *sk, struct msghdr *msg,
 			  struct flowi6 *fl6, struct ipv6_txoptions *opt,
 			  int *hlimit, int *tclass, int *dontfrag);
 
diff --git a/include/net/udp.h b/include/net/udp.h
index 07f9b70962f6..2525f0e38b71 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -246,16 +246,16 @@ int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 		       char __user *optval, unsigned int optlen,
 		       int (*push_pending_frames)(struct sock *));
-struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
+struct sock *udp4_lib_lookup(struct net_ctx *ctx, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif);
-struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
+struct sock *__udp4_lib_lookup(struct net_ctx *ctx, __be32 saddr, __be16 sport,
 			       __be32 daddr, __be16 dport, int dif,
 			       struct udp_table *tbl);
-struct sock *udp6_lib_lookup(struct net *net,
+struct sock *udp6_lib_lookup(struct net_ctx *ctx,
 			     const struct in6_addr *saddr, __be16 sport,
 			     const struct in6_addr *daddr, __be16 dport,
 			     int dif);
-struct sock *__udp6_lib_lookup(struct net *net,
+struct sock *__udp6_lib_lookup(struct net_ctx *ctx,
 			       const struct in6_addr *saddr, __be16 sport,
 			       const struct in6_addr *daddr, __be16 dport,
 			       int dif, struct udp_table *tbl);
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index dc4865e90fe4..f5a0ebd4e211 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -286,15 +286,15 @@ struct xfrm_policy_afinfo {
 	unsigned short		family;
 	struct dst_ops		*dst_ops;
 	void			(*garbage_collect)(struct net *net);
-	struct dst_entry	*(*dst_lookup)(struct net *net, int tos,
+	struct dst_entry	*(*dst_lookup)(struct net_ctx *ctx, int tos,
 					       const xfrm_address_t *saddr,
 					       const xfrm_address_t *daddr);
-	int			(*get_saddr)(struct net *net, xfrm_address_t *saddr, xfrm_address_t *daddr);
+	int			(*get_saddr)(struct net_ctx *ctx, xfrm_address_t *saddr, xfrm_address_t *daddr);
 	void			(*decode_session)(struct sk_buff *skb,
 						  struct flowi *fl,
 						  int reverse);
 	int			(*get_tos)(const struct flowi *fl);
-	void			(*init_dst)(struct net *net,
+	void			(*init_dst)(struct net_ctx *ctx,
 					    struct xfrm_dst *dst);
 	int			(*init_path)(struct xfrm_dst *path,
 					     struct dst_entry *dst,
@@ -302,7 +302,7 @@ struct xfrm_policy_afinfo {
 	int			(*fill_dst)(struct xfrm_dst *xdst,
 					    struct net_device *dev,
 					    const struct flowi *fl);
-	struct dst_entry	*(*blackhole_route)(struct net *net, struct dst_entry *orig);
+	struct dst_entry	*(*blackhole_route)(struct net_ctx *ctx, struct dst_entry *orig);
 };
 
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
@@ -597,7 +597,7 @@ struct xfrm_mgr {
 	struct xfrm_policy	*(*compile_policy)(struct sock *sk, int opt, u8 *data, int len, int *dir);
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
 	int			(*notify_policy)(struct xfrm_policy *x, int dir, const struct km_event *c);
-	int			(*report)(struct net *net, u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
+	int			(*report)(struct net_ctx *ctx, u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
 	int			(*migrate)(const struct xfrm_selector *sel,
 					   u8 dir, u8 type,
 					   const struct xfrm_migrate *m,
@@ -1428,43 +1428,43 @@ static inline void xfrm_sysctl_fini(struct net *net)
 
 void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto,
 			  struct xfrm_address_filter *filter);
-int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
+int xfrm_state_walk(struct net_ctx *ctx, struct xfrm_state_walk *walk,
 		    int (*func)(struct xfrm_state *, int, void*), void *);
-void xfrm_state_walk_done(struct xfrm_state_walk *walk, struct net *net);
-struct xfrm_state *xfrm_state_alloc(struct net *net);
+void xfrm_state_walk_done(struct xfrm_state_walk *walk, struct net_ctx *ctx);
+struct xfrm_state *xfrm_state_alloc(struct net_ctx *ctx);
 struct xfrm_state *xfrm_state_find(const xfrm_address_t *daddr,
 				   const xfrm_address_t *saddr,
 				   const struct flowi *fl,
 				   struct xfrm_tmpl *tmpl,
 				   struct xfrm_policy *pol, int *err,
 				   unsigned short family);
-struct xfrm_state *xfrm_stateonly_find(struct net *net, u32 mark,
+struct xfrm_state *xfrm_stateonly_find(struct net_ctx *ctx, u32 mark,
 				       xfrm_address_t *daddr,
 				       xfrm_address_t *saddr,
 				       unsigned short family,
 				       u8 mode, u8 proto, u32 reqid);
-struct xfrm_state *xfrm_state_lookup_byspi(struct net *net, __be32 spi,
+struct xfrm_state *xfrm_state_lookup_byspi(struct net_ctx *ctx, __be32 spi,
 					      unsigned short family);
 int xfrm_state_check_expire(struct xfrm_state *x);
 void xfrm_state_insert(struct xfrm_state *x);
 int xfrm_state_add(struct xfrm_state *x);
 int xfrm_state_update(struct xfrm_state *x);
-struct xfrm_state *xfrm_state_lookup(struct net *net, u32 mark,
+struct xfrm_state *xfrm_state_lookup(struct net_ctx *ctx, u32 mark,
 				     const xfrm_address_t *daddr, __be32 spi,
 				     u8 proto, unsigned short family);
-struct xfrm_state *xfrm_state_lookup_byaddr(struct net *net, u32 mark,
+struct xfrm_state *xfrm_state_lookup_byaddr(struct net_ctx *ctx, u32 mark,
 					    const xfrm_address_t *daddr,
 					    const xfrm_address_t *saddr,
 					    u8 proto,
 					    unsigned short family);
 #ifdef CONFIG_XFRM_SUB_POLICY
 int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n,
-		   unsigned short family, struct net *net);
+		   unsigned short family, struct net_ctx *ctx);
 int xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n,
 		    unsigned short family);
 #else
 static inline int xfrm_tmpl_sort(struct xfrm_tmpl **dst, struct xfrm_tmpl **src,
-				 int n, unsigned short family, struct net *net)
+				 int n, unsigned short family, struct net_ctx *ctx)
 {
 	return -ENOSYS;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 624335140857..fa92d1046eeb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5394,10 +5394,10 @@ void netdev_adjacent_add_links(struct net_device *dev)
 {
 	struct netdev_adjacent *iter;
 
-	struct net *net = dev_net(dev);
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 
 	list_for_each_entry(iter, &dev->adj_list.upper, list) {
-		if (!net_eq(net,dev_net(iter->dev)))
+		if (!dev_net_ctx_eq(iter->dev, &dev_ctx))
 			continue;
 		netdev_adjacent_sysfs_add(iter->dev, dev,
 					  &iter->dev->adj_list.lower);
@@ -5406,7 +5406,7 @@ void netdev_adjacent_add_links(struct net_device *dev)
 	}
 
 	list_for_each_entry(iter, &dev->adj_list.lower, list) {
-		if (!net_eq(net,dev_net(iter->dev)))
+		if (!dev_net_ctx_eq(iter->dev, &dev_ctx))
 			continue;
 		netdev_adjacent_sysfs_add(iter->dev, dev,
 					  &iter->dev->adj_list.upper);
@@ -5419,10 +5419,10 @@ void netdev_adjacent_del_links(struct net_device *dev)
 {
 	struct netdev_adjacent *iter;
 
-	struct net *net = dev_net(dev);
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 
 	list_for_each_entry(iter, &dev->adj_list.upper, list) {
-		if (!net_eq(net,dev_net(iter->dev)))
+		if (!dev_net_ctx_eq(iter->dev, &dev_ctx))
 			continue;
 		netdev_adjacent_sysfs_del(iter->dev, dev->name,
 					  &iter->dev->adj_list.lower);
@@ -5431,7 +5431,7 @@ void netdev_adjacent_del_links(struct net_device *dev)
 	}
 
 	list_for_each_entry(iter, &dev->adj_list.lower, list) {
-		if (!net_eq(net,dev_net(iter->dev)))
+		if (!dev_net_ctx_eq(iter->dev, &dev_ctx))
 			continue;
 		netdev_adjacent_sysfs_del(iter->dev, dev->name,
 					  &iter->dev->adj_list.upper);
@@ -5444,10 +5444,10 @@ void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
 {
 	struct netdev_adjacent *iter;
 
-	struct net *net = dev_net(dev);
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 
 	list_for_each_entry(iter, &dev->adj_list.upper, list) {
-		if (!net_eq(net,dev_net(iter->dev)))
+		if (!dev_net_ctx_eq(iter->dev, &dev_ctx))
 			continue;
 		netdev_adjacent_sysfs_del(iter->dev, oldname,
 					  &iter->dev->adj_list.lower);
@@ -5456,7 +5456,7 @@ void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
 	}
 
 	list_for_each_entry(iter, &dev->adj_list.lower, list) {
-		if (!net_eq(net,dev_net(iter->dev)))
+		if (!dev_net_ctx_eq(iter->dev, &dev_ctx))
 			continue;
 		netdev_adjacent_sysfs_del(iter->dev, oldname,
 					  &iter->dev->adj_list.upper);
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 44706e81b2e0..b793196f9521 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -65,12 +65,12 @@ static void notify_rule_change(int event, struct fib_rule *rule,
 			       struct fib_rules_ops *ops, struct nlmsghdr *nlh,
 			       u32 pid);
 
-static struct fib_rules_ops *lookup_rules_ops(struct net *net, int family)
+static struct fib_rules_ops *lookup_rules_ops(struct net_ctx *ctx, int family)
 {
 	struct fib_rules_ops *ops;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(ops, &net->rules_ops, list) {
+	list_for_each_entry_rcu(ops, &ctx->net->rules_ops, list) {
 		if (ops->family == family) {
 			if (!try_module_get(ops->owner))
 				ops = NULL;
@@ -126,7 +126,7 @@ static int __fib_rules_register(struct fib_rules_ops *ops)
 }
 
 struct fib_rules_ops *
-fib_rules_register(const struct fib_rules_ops *tmpl, struct net *net)
+fib_rules_register(const struct fib_rules_ops *tmpl, struct net_ctx *ctx)
 {
 	struct fib_rules_ops *ops;
 	int err;
@@ -136,7 +136,7 @@ fib_rules_register(const struct fib_rules_ops *tmpl, struct net *net)
 		return ERR_PTR(-ENOMEM);
 
 	INIT_LIST_HEAD(&ops->rules_list);
-	ops->fro_net = net;
+	ops->fro_net = ctx->net;
 
 	err = __fib_rules_register(ops);
 	if (err) {
@@ -274,7 +274,8 @@ static int validate_rulemsg(struct fib_rule_hdr *frh, struct nlattr **tb,
 
 static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx sk_ctx = SKB_NET_CTX_SOCK(skb);
+	struct net *net = sk_ctx.net;
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
 	struct fib_rules_ops *ops = NULL;
 	struct fib_rule *rule, *r, *last = NULL;
@@ -284,7 +285,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frh)))
 		goto errout;
 
-	ops = lookup_rules_ops(net, frh->family);
+	ops = lookup_rules_ops(&sk_ctx, frh->family);
 	if (ops == NULL) {
 		err = -EAFNOSUPPORT;
 		goto errout;
@@ -432,7 +433,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 
 static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx sk_ctx = SKB_NET_CTX_SOCK(skb);
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
 	struct fib_rules_ops *ops = NULL;
 	struct fib_rule *rule, *tmp;
@@ -442,7 +443,7 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frh)))
 		goto errout;
 
-	ops = lookup_rules_ops(net, frh->family);
+	ops = lookup_rules_ops(&sk_ctx, frh->family);
 	if (ops == NULL) {
 		err = -EAFNOSUPPORT;
 		goto errout;
@@ -644,14 +645,14 @@ static int dump_rules(struct sk_buff *skb, struct netlink_callback *cb,
 
 static int fib_nl_dumprule(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx sk_ctx = SKB_NET_CTX_SOCK(skb);
 	struct fib_rules_ops *ops;
 	int idx = 0, family;
 
 	family = rtnl_msg_family(cb->nlh);
 	if (family != AF_UNSPEC) {
 		/* Protocol specific dump request */
-		ops = lookup_rules_ops(net, family);
+		ops = lookup_rules_ops(&sk_ctx, family);
 		if (ops == NULL)
 			return -EAFNOSUPPORT;
 
@@ -659,7 +660,7 @@ static int fib_nl_dumprule(struct sk_buff *skb, struct netlink_callback *cb)
 	}
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(ops, &net->rules_ops, list) {
+	list_for_each_entry_rcu(ops, &sk_ctx.net->rules_ops, list) {
 		if (idx < cb->args[0] || !try_module_get(ops->owner))
 			goto skip;
 
diff --git a/net/core/flow.c b/net/core/flow.c
index a0348fde1fdf..59021e0a50f1 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -189,9 +189,10 @@ static int flow_key_compare(const struct flowi *key1, const struct flowi *key2,
 }
 
 struct flow_cache_object *
-flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
+flow_cache_lookup(struct net_ctx *net_ctx, const struct flowi *key, u16 family, u8 dir,
 		  flow_resolve_t resolver, void *ctx)
 {
+	struct net *net = net_ctx->net;
 	struct flow_cache *fc = &net->xfrm.flow_cache_global;
 	struct flow_cache_percpu *fcp;
 	struct flow_cache_entry *fle, *tfle;
@@ -261,7 +262,7 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 		flo = fle->object;
 		fle->object = NULL;
 	}
-	flo = resolver(net, key, family, dir, flo, ctx);
+	flo = resolver(net_ctx, key, family, dir, flo, ctx);
 	if (fle) {
 		fle->genid = atomic_read(&net->xfrm.flow_cache_genid);
 		if (!IS_ERR(flo))
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index bd77804849cc..93a7701a7ae7 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -423,7 +423,8 @@ struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 }
 EXPORT_SYMBOL(neigh_lookup);
 
-struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
+struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl,
+				     struct net_ctx *ctx,
 				     const void *pkey)
 {
 	struct neighbour *n;
@@ -441,7 +442,7 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 	     n != NULL;
 	     n = rcu_dereference_bh(n->next)) {
 		if (!memcmp(n->primary_key, pkey, key_len) &&
-		    net_eq(dev_net(n->dev), net)) {
+		    dev_net_ctx_eq(n->dev, ctx)) {
 			if (!atomic_inc_not_zero(&n->refcnt))
 				n = NULL;
 			NEIGH_CACHE_STAT_INC(tbl, hits);
@@ -553,14 +554,14 @@ static u32 pneigh_hash(const void *pkey, int key_len)
 }
 
 static struct pneigh_entry *__pneigh_lookup_1(struct pneigh_entry *n,
-					      struct net *net,
+					      struct net_ctx *ctx,
 					      const void *pkey,
 					      int key_len,
 					      struct net_device *dev)
 {
 	while (n) {
 		if (!memcmp(n->key, pkey, key_len) &&
-		    net_eq(pneigh_net(n), net) &&
+		    pneigh_net_ctx_eq(n, ctx) &&
 		    (n->dev == dev || !n->dev))
 			return n;
 		n = n->next;
@@ -569,18 +570,19 @@ static struct pneigh_entry *__pneigh_lookup_1(struct pneigh_entry *n,
 }
 
 struct pneigh_entry *__pneigh_lookup(struct neigh_table *tbl,
-		struct net *net, const void *pkey, struct net_device *dev)
+				     struct net_ctx *ctx,
+				     const void *pkey, struct net_device *dev)
 {
 	int key_len = tbl->key_len;
 	u32 hash_val = pneigh_hash(pkey, key_len);
 
 	return __pneigh_lookup_1(tbl->phash_buckets[hash_val],
-				 net, pkey, key_len, dev);
+				 ctx, pkey, key_len, dev);
 }
 EXPORT_SYMBOL_GPL(__pneigh_lookup);
 
 struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
-				    struct net *net, const void *pkey,
+				    struct net_ctx *ctx, const void *pkey,
 				    struct net_device *dev, int creat)
 {
 	struct pneigh_entry *n;
@@ -589,7 +591,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 
 	read_lock_bh(&tbl->lock);
 	n = __pneigh_lookup_1(tbl->phash_buckets[hash_val],
-			      net, pkey, key_len, dev);
+			      ctx, pkey, key_len, dev);
 	read_unlock_bh(&tbl->lock);
 
 	if (n || !creat)
@@ -601,7 +603,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 	if (!n)
 		goto out;
 
-	write_pnet(&n->net_ctx.net, hold_net(net));
+	pneigh_net_ctx_set(n, ctx);
 	memcpy(n->key, pkey, key_len);
 	n->dev = dev;
 	if (dev)
@@ -610,7 +612,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 	if (tbl->pconstructor && tbl->pconstructor(n)) {
 		if (dev)
 			dev_put(dev);
-		release_net(net);
+		release_net(ctx->net);
 		kfree(n);
 		n = NULL;
 		goto out;
@@ -626,7 +628,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 EXPORT_SYMBOL(pneigh_lookup);
 
 
-int pneigh_delete(struct neigh_table *tbl, struct net *net, const void *pkey,
+int pneigh_delete(struct neigh_table *tbl, struct net_ctx *ctx, const void *pkey,
 		  struct net_device *dev)
 {
 	struct pneigh_entry *n, **np;
@@ -637,7 +639,7 @@ int pneigh_delete(struct neigh_table *tbl, struct net *net, const void *pkey,
 	for (np = &tbl->phash_buckets[hash_val]; (n = *np) != NULL;
 	     np = &n->next) {
 		if (!memcmp(n->key, pkey, key_len) && n->dev == dev &&
-		    net_eq(pneigh_net(n), net)) {
+		    pneigh_net_ctx_eq(n, ctx)) {
 			*np = n->next;
 			write_unlock_bh(&tbl->lock);
 			if (tbl->pdestructor)
@@ -1436,13 +1438,13 @@ void pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 EXPORT_SYMBOL(pneigh_enqueue);
 
 static inline struct neigh_parms *lookup_neigh_parms(struct neigh_table *tbl,
-						      struct net *net, int ifindex)
+						      struct net_ctx *ctx, int ifindex)
 {
 	struct neigh_parms *p;
 
 	list_for_each_entry(p, &tbl->parms_list, list) {
-		if ((p->dev && p->dev->ifindex == ifindex && net_eq(neigh_parms_net(p), net)) ||
-		    (!p->dev && !ifindex && net_eq(net, &init_net)))
+		if ((p->dev && p->dev->ifindex == ifindex && neigh_parms_net_ctx_eq((p), ctx)) ||
+		    (!p->dev && !ifindex && net_eq(ctx->net, &init_net)))
 			return p;
 	}
 
@@ -1453,7 +1455,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 				      struct neigh_table *tbl)
 {
 	struct neigh_parms *p;
-	struct net *net = dev_net(dev);
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 	const struct net_device_ops *ops = dev->netdev_ops;
 
 	p = kmemdup(&tbl->parms, sizeof(*p), GFP_KERNEL);
@@ -1464,11 +1466,11 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 				neigh_rand_reach_time(NEIGH_VAR(p, BASE_REACHABLE_TIME));
 		dev_hold(dev);
 		p->dev = dev;
-		write_pnet(&p->net_ctx.net, hold_net(net));
+		write_pnet(&p->net_ctx.net, hold_net(dev_ctx.net));
 		p->sysctl_table = NULL;
 
 		if (ops->ndo_neigh_setup && ops->ndo_neigh_setup(dev, p)) {
-			release_net(net);
+			release_net(dev_ctx.net);
 			dev_put(dev);
 			kfree(p);
 			return NULL;
@@ -1615,7 +1617,7 @@ static struct neigh_table *neigh_find_table(int family)
 
 static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx ctx = SKB_NET_CTX_SOCK(skb);
 	struct ndmsg *ndm;
 	struct nlattr *dst_attr;
 	struct neigh_table *tbl;
@@ -1633,7 +1635,7 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ndm = nlmsg_data(nlh);
 	if (ndm->ndm_ifindex) {
-		dev = __dev_get_by_index(net, ndm->ndm_ifindex);
+		dev = __dev_get_by_index_ctx(&ctx, ndm->ndm_ifindex);
 		if (dev == NULL) {
 			err = -ENODEV;
 			goto out;
@@ -1648,7 +1650,7 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto out;
 
 	if (ndm->ndm_flags & NTF_PROXY) {
-		err = pneigh_delete(tbl, net, nla_data(dst_attr), dev);
+		err = pneigh_delete(tbl, &ctx, nla_data(dst_attr), dev);
 		goto out;
 	}
 
@@ -1673,7 +1675,7 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int flags = NEIGH_UPDATE_F_ADMIN | NEIGH_UPDATE_F_OVERRIDE;
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx ctx = SKB_NET_CTX_SOCK(skb);
 	struct ndmsg *ndm;
 	struct nlattr *tb[NDA_MAX+1];
 	struct neigh_table *tbl;
@@ -1693,7 +1695,7 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ndm = nlmsg_data(nlh);
 	if (ndm->ndm_ifindex) {
-		dev = __dev_get_by_index(net, ndm->ndm_ifindex);
+		dev = __dev_get_by_index_ctx(&ctx, ndm->ndm_ifindex);
 		if (dev == NULL) {
 			err = -ENODEV;
 			goto out;
@@ -1716,7 +1718,7 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 		struct pneigh_entry *pn;
 
 		err = -ENOBUFS;
-		pn = pneigh_lookup(tbl, net, dst, dev, 1);
+		pn = pneigh_lookup(tbl, &ctx, dst, dev, 1);
 		if (pn) {
 			pn->flags = ndm->ndm_flags;
 			err = 0;
@@ -1953,7 +1955,7 @@ static const struct nla_policy nl_ntbl_parm_policy[NDTPA_MAX+1] = {
 
 static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx ctx = SKB_NET_CTX_SOCK(skb);
 	struct neigh_table *tbl;
 	struct ndtmsg *ndtmsg;
 	struct nlattr *tb[NDTA_MAX+1];
@@ -2006,7 +2008,7 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (tbp[NDTPA_IFINDEX])
 			ifindex = nla_get_u32(tbp[NDTPA_IFINDEX]);
 
-		p = lookup_neigh_parms(tbl, net, ifindex);
+		p = lookup_neigh_parms(tbl, &ctx, ifindex);
 		if (p == NULL) {
 			err = -ENOENT;
 			goto errout_tbl_lock;
@@ -2083,7 +2085,7 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 	err = -ENOENT;
 	if ((tb[NDTA_THRESH1] || tb[NDTA_THRESH2] ||
 	     tb[NDTA_THRESH3] || tb[NDTA_GC_INTERVAL]) &&
-	    !net_eq(net, &init_net))
+	    !net_eq(ctx.net, &init_net))
 		goto errout_tbl_lock;
 
 	if (tb[NDTA_THRESH1])
@@ -2108,7 +2110,7 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx ctx = SKB_NET_CTX_SOCK(skb);
 	int family, tidx, nidx = 0;
 	int tbl_skip = cb->args[0];
 	int neigh_skip = cb->args[1];
@@ -2134,7 +2136,7 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 		nidx = 0;
 		p = list_next_entry(&tbl->parms, list);
 		list_for_each_entry_from(p, &tbl->parms_list, list) {
-			if (!net_eq(neigh_parms_net(p), net))
+			if (!neigh_parms_net_ctx_eq(p, &ctx))
 				continue;
 
 			if (nidx < neigh_skip)
@@ -2252,7 +2254,7 @@ static void neigh_update_notify(struct neighbour *neigh)
 static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			    struct netlink_callback *cb)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx ctx = SKB_NET_CTX_SOCK(skb);
 	struct neighbour *n;
 	int rc, h, s_h = cb->args[1];
 	int idx, s_idx = idx = cb->args[2];
@@ -2267,7 +2269,7 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 		for (n = rcu_dereference_bh(nht->hash_buckets[h]), idx = 0;
 		     n != NULL;
 		     n = rcu_dereference_bh(n->next)) {
-			if (!net_eq(dev_net(n->dev), net))
+			if (!dev_net_ctx_eq(n->dev, &ctx))
 				continue;
 			if (idx < s_idx)
 				goto next;
@@ -2294,7 +2296,7 @@ static int pneigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			     struct netlink_callback *cb)
 {
 	struct pneigh_entry *n;
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx ctx = SKB_NET_CTX_SOCK(skb);
 	int rc, h, s_h = cb->args[3];
 	int idx, s_idx = idx = cb->args[4];
 
@@ -2304,7 +2306,7 @@ static int pneigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 		if (h > s_h)
 			s_idx = 0;
 		for (n = tbl->phash_buckets[h], idx = 0; n; n = n->next) {
-			if (dev_net(n->dev) != net)
+			if (!dev_net_ctx_eq(n->dev, &ctx))
 				continue;
 			if (idx < s_idx)
 				goto next;
@@ -2432,7 +2434,7 @@ EXPORT_SYMBOL(__neigh_for_each_release);
 static struct neighbour *neigh_get_first(struct seq_file *seq)
 {
 	struct neigh_seq_state *state = seq->private;
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 	struct neigh_hash_table *nht = state->nht;
 	struct neighbour *n = NULL;
 	int bucket = state->bucket;
@@ -2442,7 +2444,7 @@ static struct neighbour *neigh_get_first(struct seq_file *seq)
 		n = rcu_dereference_bh(nht->hash_buckets[bucket]);
 
 		while (n) {
-			if (!net_eq(dev_net(n->dev), net))
+			if (!dev_net_ctx_eq(n->dev, ctx))
 				goto next;
 			if (state->neigh_sub_iter) {
 				loff_t fakep = 0;
@@ -2473,7 +2475,7 @@ static struct neighbour *neigh_get_next(struct seq_file *seq,
 					loff_t *pos)
 {
 	struct neigh_seq_state *state = seq->private;
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 	struct neigh_hash_table *nht = state->nht;
 
 	if (state->neigh_sub_iter) {
@@ -2485,7 +2487,7 @@ static struct neighbour *neigh_get_next(struct seq_file *seq,
 
 	while (1) {
 		while (n) {
-			if (!net_eq(dev_net(n->dev), net))
+			if (!dev_net_ctx_eq(n->dev, ctx))
 				goto next;
 			if (state->neigh_sub_iter) {
 				void *v = state->neigh_sub_iter(state, n, pos);
@@ -2534,7 +2536,7 @@ static struct neighbour *neigh_get_idx(struct seq_file *seq, loff_t *pos)
 static struct pneigh_entry *pneigh_get_first(struct seq_file *seq)
 {
 	struct neigh_seq_state *state = seq->private;
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 	struct neigh_table *tbl = state->tbl;
 	struct pneigh_entry *pn = NULL;
 	int bucket = state->bucket;
@@ -2542,7 +2544,7 @@ static struct pneigh_entry *pneigh_get_first(struct seq_file *seq)
 	state->flags |= NEIGH_SEQ_IS_PNEIGH;
 	for (bucket = 0; bucket <= PNEIGH_HASHMASK; bucket++) {
 		pn = tbl->phash_buckets[bucket];
-		while (pn && !net_eq(pneigh_net(pn), net))
+		while (pn && !pneigh_net_ctx_eq(pn, ctx))
 			pn = pn->next;
 		if (pn)
 			break;
@@ -2557,18 +2559,18 @@ static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
 					    loff_t *pos)
 {
 	struct neigh_seq_state *state = seq->private;
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 	struct neigh_table *tbl = state->tbl;
 
 	do {
 		pn = pn->next;
-	} while (pn && !net_eq(pneigh_net(pn), net));
+	} while (pn && !pneigh_net_ctx_eq(pn, ctx));
 
 	while (!pn) {
 		if (++state->bucket > PNEIGH_HASHMASK)
 			break;
 		pn = tbl->phash_buckets[state->bucket];
-		while (pn && !net_eq(pneigh_net(pn), net))
+		while (pn && !pneigh_net_ctx_eq(pn, ctx))
 			pn = pn->next;
 		if (pn)
 			break;
@@ -2832,14 +2834,14 @@ static struct neigh_parms *neigh_get_dev_parms_rcu(struct net_device *dev,
 	return NULL;
 }
 
-static void neigh_copy_dflt_parms(struct net *net, struct neigh_parms *p,
+static void neigh_copy_dflt_parms(struct net_ctx *ctx, struct neigh_parms *p,
 				  int index)
 {
 	struct net_device *dev;
 	int family = neigh_parms_family(p);
 
 	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
+	for_each_netdev_rcu(ctx->net, dev) {
 		struct neigh_parms *dst_p =
 				neigh_get_dev_parms_rcu(dev, family);
 
@@ -2853,7 +2855,7 @@ static void neigh_proc_update(struct ctl_table *ctl, int write)
 {
 	struct net_device *dev = ctl->extra1;
 	struct neigh_parms *p = ctl->extra2;
-	struct net *net = neigh_parms_net(p);
+	struct net_ctx ctx = { .net = neigh_parms_net(p) };
 	int index = (int *) ctl->data - p->data;
 
 	if (!write)
@@ -2861,7 +2863,7 @@ static void neigh_proc_update(struct ctl_table *ctl, int write)
 
 	set_bit(index, p->data_state);
 	if (!dev) /* NULL dev means this is default value */
-		neigh_copy_dflt_parms(net, p, index);
+		neigh_copy_dflt_parms(&ctx, p, index);
 }
 
 static int neigh_proc_dointvec_zero_intmax(struct ctl_table *ctl, int write,
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index a44773c8346c..2627fff2b2d0 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -423,7 +423,8 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct sockaddr_in *addr = (struct sockaddr_in *)uaddr;
 	struct sock *sk = sock->sk;
 	struct inet_sock *inet = inet_sk(sk);
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
+	struct net *net = sk_ctx.net;
 	unsigned short snum;
 	int chk_addr_ret;
 	int err;
@@ -447,7 +448,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out;
 	}
 
-	chk_addr_ret = inet_addr_type(net, addr->sin_addr.s_addr);
+	chk_addr_ret = inet_addr_type(&sk_ctx, addr->sin_addr.s_addr);
 
 	/* Not specified by any standard per-se, however it breaks too
 	 * many applications when removed.  It is unfortunate since
@@ -838,7 +839,7 @@ int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
 	int err = 0;
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	switch (cmd) {
 	case SIOCGSTAMP:
@@ -850,12 +851,12 @@ int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	case SIOCADDRT:
 	case SIOCDELRT:
 	case SIOCRTMSG:
-		err = ip_rt_ioctl(net, cmd, (void __user *)arg);
+		err = ip_rt_ioctl(&sk_ctx, cmd, (void __user *)arg);
 		break;
 	case SIOCDARP:
 	case SIOCGARP:
 	case SIOCSARP:
-		err = arp_ioctl(net, cmd, (void __user *)arg);
+		err = arp_ioctl(&sk_ctx, cmd, (void __user *)arg);
 		break;
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
@@ -868,7 +869,7 @@ int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	case SIOCSIFPFLAGS:
 	case SIOCGIFPFLAGS:
 	case SIOCSIFFLAGS:
-		err = devinet_ioctl(net, cmd, (void __user *)arg);
+		err = devinet_ioctl(&sk_ctx, cmd, (void __user *)arg);
 		break;
 	default:
 		if (sk->sk_prot->ioctl)
@@ -1157,6 +1158,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 	struct ip_options_rcu *inet_opt;
 	struct flowi4 *fl4;
 	int err;
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	/* Route is OK, nothing to do. */
 	if (rt)
@@ -1170,7 +1172,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 		daddr = inet_opt->opt.faddr;
 	rcu_read_unlock();
 	fl4 = &inet->cork.fl.u.ip4;
-	rt = ip_route_output_ports(sock_net(sk), fl4, sk, daddr, inet->inet_saddr,
+	rt = ip_route_output_ports(&sk_ctx, fl4, sk, daddr, inet->inet_saddr,
 				   inet->inet_dport, inet->inet_sport,
 				   sk->sk_protocol, RT_CONN_FLAGS(sk),
 				   sk->sk_bound_dev_if);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 205e1472aa78..b24773b275a9 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -225,6 +225,7 @@ static int arp_constructor(struct neighbour *neigh)
 	struct net_device *dev = neigh->dev;
 	struct in_device *in_dev;
 	struct neigh_parms *parms;
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
@@ -233,7 +234,7 @@ static int arp_constructor(struct neighbour *neigh)
 		return -EINVAL;
 	}
 
-	neigh->type = inet_addr_type(dev_net(dev), addr);
+	neigh->type = inet_addr_type(&dev_ctx, addr);
 
 	parms = in_dev->arp_parms;
 	__neigh_parms_put(neigh->parms);
@@ -328,6 +329,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	__be32 target = *(__be32 *)neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
 	struct in_device *in_dev;
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
@@ -338,7 +340,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	switch (IN_DEV_ARP_ANNOUNCE(in_dev)) {
 	default:
 	case 0:		/* By default announce any local IP */
-		if (skb && inet_addr_type(dev_net(dev),
+		if (skb && inet_addr_type(&dev_ctx,
 					  ip_hdr(skb)->saddr) == RTN_LOCAL)
 			saddr = ip_hdr(skb)->saddr;
 		break;
@@ -346,7 +348,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 		if (!skb)
 			break;
 		saddr = ip_hdr(skb)->saddr;
-		if (inet_addr_type(dev_net(dev), saddr) == RTN_LOCAL) {
+		if (inet_addr_type(&dev_ctx, saddr) == RTN_LOCAL) {
 			/* saddr should be known to target */
 			if (inet_addr_onlink(in_dev, target, saddr))
 				break;
@@ -381,7 +383,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
 {
-	struct net *net = dev_net(in_dev->dev);
+	struct net_ctx dev_ctx = DEV_NET_CTX(in_dev->dev);
 	int scope;
 
 	switch (IN_DEV_ARP_IGNORE(in_dev)) {
@@ -412,7 +414,7 @@ static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
 	default:
 		return 0;
 	}
-	return !inet_confirm_addr(net, in_dev, sip, tip, scope);
+	return !inet_confirm_addr(&dev_ctx, in_dev, sip, tip, scope);
 }
 
 static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
@@ -420,9 +422,10 @@ static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
 	struct rtable *rt;
 	int flag = 0;
 	/*unsigned long now; */
-	struct net *net = dev_net(dev);
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
+	struct net *net = dev_ctx.net;
 
-	rt = ip_route_output(net, sip, tip, 0, 0);
+	rt = ip_route_output(&dev_ctx, sip, tip, 0, 0);
 	if (IS_ERR(rt))
 		return 1;
 	if (rt->dst.dev != dev) {
@@ -468,6 +471,7 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	__be32 paddr;
 	struct neighbour *n;
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 
 	if (!skb_dst(skb)) {
 		pr_debug("arp_find is called with dst==NULL\n");
@@ -476,7 +480,7 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
 	}
 
 	paddr = rt_nexthop(skb_rtable(skb), ip_hdr(skb)->daddr);
-	if (arp_set_predefined(inet_addr_type(dev_net(dev), paddr), haddr,
+	if (arp_set_predefined(inet_addr_type(&dev_ctx, paddr), haddr,
 			       paddr, dev))
 		return 0;
 
@@ -731,7 +735,7 @@ static int arp_process(struct sk_buff *skb)
 	u16 dev_type = dev->type;
 	int addr_type;
 	struct neighbour *n;
-	struct net *net = dev_net(dev);
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 	bool is_garp = false;
 
 	/* arp_rcv below verifies the ARP header and verifies the device
@@ -835,7 +839,7 @@ static int arp_process(struct sk_buff *skb)
 	/* Special case: IPv4 duplicate address detection packet (RFC2131) */
 	if (sip == 0) {
 		if (arp->ar_op == htons(ARPOP_REQUEST) &&
-		    inet_addr_type(net, tip) == RTN_LOCAL &&
+		    inet_addr_type(&dev_ctx, tip) == RTN_LOCAL &&
 		    !arp_ignore(in_dev, sip, tip))
 			arp_send(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha,
 				 dev->dev_addr, sha);
@@ -869,7 +873,7 @@ static int arp_process(struct sk_buff *skb)
 			    (arp_fwd_proxy(in_dev, dev, rt) ||
 			     arp_fwd_pvlan(in_dev, dev, rt, sip, tip) ||
 			     (rt->dst.dev != dev &&
-			      pneigh_lookup(&arp_tbl, net, &tip, dev, 0)))) {
+			      pneigh_lookup(&arp_tbl, &dev_ctx, &tip, dev, 0)))) {
 				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 				if (n)
 					neigh_release(n);
@@ -900,11 +904,11 @@ static int arp_process(struct sk_buff *skb)
 		   devices (strip is candidate)
 		 */
 		is_garp = arp->ar_op == htons(ARPOP_REQUEST) && tip == sip &&
-			  inet_addr_type(net, sip) == RTN_UNICAST;
+			  inet_addr_type(&dev_ctx, sip) == RTN_UNICAST;
 
 		if (n == NULL &&
 		    ((arp->ar_op == htons(ARPOP_REPLY)  &&
-		      inet_addr_type(net, sip) == RTN_UNICAST) || is_garp))
+		      inet_addr_type(&dev_ctx, sip) == RTN_UNICAST) || is_garp))
 			n = __neigh_lookup(&arp_tbl, &sip, dev, 1);
 	}
 
@@ -1005,9 +1009,10 @@ static int arp_req_set_proxy(struct net *net, struct net_device *dev, int on)
 	return -ENXIO;
 }
 
-static int arp_req_set_public(struct net *net, struct arpreq *r,
+static int arp_req_set_public(struct net_ctx *ctx, struct arpreq *r,
 		struct net_device *dev)
 {
+	struct net *net = ctx->net;
 	__be32 ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
 	__be32 mask = ((struct sockaddr_in *)&r->arp_netmask)->sin_addr.s_addr;
 
@@ -1020,15 +1025,15 @@ static int arp_req_set_public(struct net *net, struct arpreq *r,
 			return -ENODEV;
 	}
 	if (mask) {
-		if (pneigh_lookup(&arp_tbl, net, &ip, dev, 1) == NULL)
+		if (pneigh_lookup(&arp_tbl, ctx, &ip, dev, 1) == NULL)
 			return -ENOBUFS;
 		return 0;
 	}
 
-	return arp_req_set_proxy(net, dev, 1);
+	return arp_req_set_proxy(ctx->net, dev, 1);
 }
 
-static int arp_req_set(struct net *net, struct arpreq *r,
+static int arp_req_set(struct net_ctx *ctx, struct arpreq *r,
 		       struct net_device *dev)
 {
 	__be32 ip;
@@ -1036,13 +1041,13 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 	int err;
 
 	if (r->arp_flags & ATF_PUBL)
-		return arp_req_set_public(net, r, dev);
+		return arp_req_set_public(ctx, r, dev);
 
 	ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
 	if (r->arp_flags & ATF_PERM)
 		r->arp_flags |= ATF_COM;
 	if (dev == NULL) {
-		struct rtable *rt = ip_route_output(net, ip, 0, RTO_ONLINK, 0);
+		struct rtable *rt = ip_route_output(ctx, ip, 0, RTO_ONLINK, 0);
 
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
@@ -1137,32 +1142,31 @@ static int arp_invalidate(struct net_device *dev, __be32 ip)
 	return err;
 }
 
-static int arp_req_delete_public(struct net *net, struct arpreq *r,
+static int arp_req_delete_public(struct net_ctx *ctx, struct arpreq *r,
 		struct net_device *dev)
 {
 	__be32 ip = ((struct sockaddr_in *) &r->arp_pa)->sin_addr.s_addr;
 	__be32 mask = ((struct sockaddr_in *)&r->arp_netmask)->sin_addr.s_addr;
 
 	if (mask == htonl(0xFFFFFFFF))
-		return pneigh_delete(&arp_tbl, net, &ip, dev);
+		return pneigh_delete(&arp_tbl, ctx, &ip, dev);
 
 	if (mask)
 		return -EINVAL;
 
-	return arp_req_set_proxy(net, dev, 0);
+	return arp_req_set_proxy(ctx->net, dev, 0);
 }
 
-static int arp_req_delete(struct net *net, struct arpreq *r,
+static int arp_req_delete(struct net_ctx *ctx, struct arpreq *r,
 			  struct net_device *dev)
 {
 	__be32 ip;
 
 	if (r->arp_flags & ATF_PUBL)
-		return arp_req_delete_public(net, r, dev);
-
+		return arp_req_delete_public(ctx, r, dev);
 	ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
 	if (dev == NULL) {
-		struct rtable *rt = ip_route_output(net, ip, 0, RTO_ONLINK, 0);
+		struct rtable *rt = ip_route_output(ctx, ip, 0, RTO_ONLINK, 0);
 		if (IS_ERR(rt))
 			return PTR_ERR(rt);
 		dev = rt->dst.dev;
@@ -1177,8 +1181,9 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
  *	Handle an ARP layer I/O control request.
  */
 
-int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg)
+int arp_ioctl(struct net_ctx *ctx, unsigned int cmd, void __user *arg)
 {
+	struct net *net = ctx->net;
 	int err;
 	struct arpreq r;
 	struct net_device *dev = NULL;
@@ -1226,10 +1231,10 @@ int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 
 	switch (cmd) {
 	case SIOCDARP:
-		err = arp_req_delete(net, &r, dev);
+		err = arp_req_delete(ctx, &r, dev);
 		break;
 	case SIOCSARP:
-		err = arp_req_set(net, &r, dev);
+		err = arp_req_set(ctx, &r, dev);
 		break;
 	case SIOCGARP:
 		err = arp_req_get(&r, dev);
@@ -1247,11 +1252,12 @@ static int arp_netdev_event(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct netdev_notifier_change_info *change_info;
+	struct net *net = dev_net(dev);
 
 	switch (event) {
 	case NETDEV_CHANGEADDR:
 		neigh_changeaddr(&arp_tbl, dev);
-		rt_cache_flush(dev_net(dev));
+		rt_cache_flush(net);
 		break;
 	case NETDEV_CHANGE:
 		change_info = ptr;
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 90c0e8386116..7f93d6b92d0b 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -99,6 +99,7 @@ void ip4_datagram_release_cb(struct sock *sk)
 	struct dst_entry *dst;
 	struct flowi4 fl4;
 	struct rtable *rt;
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	rcu_read_lock();
 
@@ -110,7 +111,7 @@ void ip4_datagram_release_cb(struct sock *sk)
 	inet_opt = rcu_dereference(inet->inet_opt);
 	if (inet_opt && inet_opt->opt.srr)
 		daddr = inet_opt->opt.faddr;
-	rt = ip_route_output_ports(sock_net(sk), &fl4, sk, daddr,
+	rt = ip_route_output_ports(&sk_ctx, &fl4, sk, daddr,
 				   inet->inet_saddr, inet->inet_dport,
 				   inet->inet_sport, sk->sk_protocol,
 				   RT_CONN_FLAGS(sk), sk->sk_bound_dev_if);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index f0b4a31d7bd6..a0182f79f6bf 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -136,8 +136,9 @@ static void inet_hash_remove(struct in_ifaddr *ifa)
  *
  * If a caller uses devref=false, it should be protected by RCU, or RTNL
  */
-struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
+struct net_device *__ip_dev_find(struct net_ctx *ctx, __be32 addr, bool devref)
 {
+	struct net *net = ctx->net;
 	u32 hash = inet_addr_hash(net, addr);
 	struct net_device *result = NULL;
 	struct in_ifaddr *ifa;
@@ -147,7 +148,7 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 		if (ifa->ifa_local == addr) {
 			struct net_device *dev = ifa->ifa_dev->dev;
 
-			if (!net_eq(dev_net(dev), net))
+			if (!dev_net_ctx_eq(dev, ctx))
 				continue;
 			result = dev;
 			break;
@@ -520,13 +521,13 @@ static int inet_set_ifa(struct net_device *dev, struct in_ifaddr *ifa)
 /* Caller must hold RCU or RTNL :
  * We dont take a reference on found in_device
  */
-struct in_device *inetdev_by_index(struct net *net, int ifindex)
+struct in_device *inetdev_by_index(struct net_ctx *ctx, int ifindex)
 {
 	struct net_device *dev;
 	struct in_device *in_dev = NULL;
 
 	rcu_read_lock();
-	dev = dev_get_by_index_rcu(net, ifindex);
+	dev = dev_get_by_index_rcu_ctx(ctx, ifindex);
 	if (dev)
 		in_dev = rcu_dereference_rtnl(dev->ip_ptr);
 	rcu_read_unlock();
@@ -550,7 +551,7 @@ struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix,
 
 static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx ctx = SKB_NET_CTX_SOCK(skb);
 	struct nlattr *tb[IFA_MAX+1];
 	struct in_device *in_dev;
 	struct ifaddrmsg *ifm;
@@ -564,7 +565,7 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 
 	ifm = nlmsg_data(nlh);
-	in_dev = inetdev_by_index(net, ifm->ifa_index);
+	in_dev = inetdev_by_index(&ctx, ifm->ifa_index);
 	if (in_dev == NULL) {
 		err = -ENODEV;
 		goto errout;
@@ -717,7 +718,7 @@ static void set_ifa_lifetime(struct in_ifaddr *ifa, __u32 valid_lft,
 		ifa->ifa_cstamp = ifa->ifa_tstamp;
 }
 
-static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh,
+static struct in_ifaddr *rtm_to_ifaddr(struct net_ctx *ctx, struct nlmsghdr *nlh,
 				       __u32 *pvalid_lft, __u32 *pprefered_lft)
 {
 	struct nlattr *tb[IFA_MAX+1];
@@ -736,7 +737,7 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh,
 	if (ifm->ifa_prefixlen > 32 || tb[IFA_LOCAL] == NULL)
 		goto errout;
 
-	dev = __dev_get_by_index(net, ifm->ifa_index);
+	dev = __dev_get_by_index_ctx(ctx, ifm->ifa_index);
 	err = -ENODEV;
 	if (dev == NULL)
 		goto errout;
@@ -820,7 +821,7 @@ static struct in_ifaddr *find_matching_ifa(struct in_ifaddr *ifa)
 
 static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx ctx = SKB_NET_CTX_SOCK(skb);
 	struct in_ifaddr *ifa;
 	struct in_ifaddr *ifa_existing;
 	__u32 valid_lft = INFINITY_LIFE_TIME;
@@ -828,7 +829,7 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ASSERT_RTNL();
 
-	ifa = rtm_to_ifaddr(net, nlh, &valid_lft, &prefered_lft);
+	ifa = rtm_to_ifaddr(&ctx, nlh, &valid_lft, &prefered_lft);
 	if (IS_ERR(ifa))
 		return PTR_ERR(ifa);
 
@@ -881,8 +882,9 @@ static int inet_abc_len(__be32 addr)
 }
 
 
-int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
+int devinet_ioctl(struct net_ctx *net_ctx, unsigned int cmd, void __user *arg)
 {
+	struct net *net = net_ctx->net;
 	struct ifreq ifr;
 	struct sockaddr_in sin_orig;
 	struct sockaddr_in *sin = (struct sockaddr_in *)&ifr.ifr_addr;
@@ -1253,7 +1255,7 @@ static __be32 confirm_addr_indev(struct in_device *in_dev, __be32 dst,
  * - local: address, 0=autoselect the local address
  * - scope: maximum allowed scope value for the local address
  */
-__be32 inet_confirm_addr(struct net *net, struct in_device *in_dev,
+__be32 inet_confirm_addr(struct net_ctx *ctx, struct in_device *in_dev,
 			 __be32 dst, __be32 local, int scope)
 {
 	__be32 addr = 0;
@@ -1263,7 +1265,7 @@ __be32 inet_confirm_addr(struct net *net, struct in_device *in_dev,
 		return confirm_addr_indev(in_dev, dst, local, scope);
 
 	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
+	for_each_netdev_rcu(ctx->net, dev) {
 		in_dev = __in_dev_get_rcu(dev);
 		if (in_dev) {
 			addr = confirm_addr_indev(in_dev, dst, local, scope);
@@ -1532,7 +1534,8 @@ static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa,
 
 static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(skb->sk);
+	struct net *net = sk_ctx.net;
 	int h, s_h;
 	int idx, s_idx;
 	int ip_idx, s_ip_idx;
@@ -1854,7 +1857,8 @@ static int inet_netconf_get_devconf(struct sk_buff *in_skb,
 static int inet_netconf_dump_devconf(struct sk_buff *skb,
 				     struct netlink_callback *cb)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(skb->sk);
+	struct net *net = sk_ctx.net;
 	int h, s_h;
 	int idx, s_idx;
 	struct net_device *dev;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 57be71dd6a9e..b068ab996cc3 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -150,10 +150,11 @@ static void fib_flush(struct net *net)
  * Find address type as if only "dev" was present in the system. If
  * on_dev is NULL then all interfaces are taken into consideration.
  */
-static inline unsigned int __inet_dev_addr_type(struct net *net,
+static inline unsigned int __inet_dev_addr_type(struct net_ctx *ctx,
 						const struct net_device *dev,
 						__be32 addr)
 {
+	struct net *net = ctx->net;
 	struct flowi4		fl4 = { .daddr = addr };
 	struct fib_result	res;
 	unsigned int ret = RTN_BROADCAST;
@@ -179,16 +180,17 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 	return ret;
 }
 
-unsigned int inet_addr_type(struct net *net, __be32 addr)
+unsigned int inet_addr_type(struct net_ctx *ctx, __be32 addr)
 {
-	return __inet_dev_addr_type(net, NULL, addr);
+	return __inet_dev_addr_type(ctx, NULL, addr);
 }
 EXPORT_SYMBOL(inet_addr_type);
 
-unsigned int inet_dev_addr_type(struct net *net, const struct net_device *dev,
+unsigned int inet_dev_addr_type(struct net_ctx *ctx,
+				const struct net_device *dev,
 				__be32 addr)
 {
-	return __inet_dev_addr_type(net, dev, addr);
+	return __inet_dev_addr_type(ctx, dev, addr);
 }
 EXPORT_SYMBOL(inet_dev_addr_type);
 
@@ -199,7 +201,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 	struct fib_result res;
 	struct rtable *rt;
 	struct flowi4 fl4;
-	struct net *net;
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 	int scope;
 
 	rt = skb_rtable(skb);
@@ -210,8 +212,6 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 	in_dev = __in_dev_get_rcu(dev);
 	BUG_ON(!in_dev);
 
-	net = dev_net(dev);
-
 	scope = RT_SCOPE_UNIVERSE;
 	if (!ipv4_is_zeronet(ip_hdr(skb)->saddr)) {
 		fl4.flowi4_oif = 0;
@@ -221,8 +221,8 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 		fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 		fl4.flowi4_scope = scope;
 		fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
-		if (!fib_lookup(net, &fl4, &res))
-			return FIB_RES_PREFSRC(net, res);
+		if (!fib_lookup(&dev_ctx, &fl4, &res))
+			return FIB_RES_PREFSRC(&dev_ctx, res);
 	} else {
 		scope = RT_SCOPE_LINK;
 	}
@@ -245,7 +245,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	int ret, no_addr;
 	struct fib_result res;
 	struct flowi4 fl4;
-	struct net *net;
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 	bool dev_match;
 
 	fl4.flowi4_oif = 0;
@@ -259,8 +259,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 
 	fl4.flowi4_mark = IN_DEV_SRC_VMARK(idev) ? skb->mark : 0;
 
-	net = dev_net(dev);
-	if (fib_lookup(net, &fl4, &res))
+	if (fib_lookup(&dev_ctx, &fl4, &res))
 		goto last_resort;
 	if (res.type != RTN_UNICAST &&
 	    (res.type != RTN_LOCAL || !IN_DEV_ACCEPT_LOCAL(idev)))
@@ -295,7 +294,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	fl4.flowi4_oif = dev->ifindex;
 
 	ret = 0;
-	if (fib_lookup(net, &fl4, &res) == 0) {
+	if (fib_lookup(&dev_ctx, &fl4, &res) == 0) {
 		if (res.type == RTN_UNICAST)
 			ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
 	}
@@ -346,9 +345,10 @@ static int put_rtax(struct nlattr *mx, int len, int type, u32 value)
 	return len + nla_total_size(4);
 }
 
-static int rtentry_to_fib_config(struct net *net, int cmd, struct rtentry *rt,
-				 struct fib_config *cfg)
+static int rtentry_to_fib_config(struct net_ctx *ctx, int cmd,
+				 struct rtentry *rt, struct fib_config *cfg)
 {
+	struct net *net = ctx->net;
 	__be32 addr;
 	int plen;
 
@@ -437,7 +437,7 @@ static int rtentry_to_fib_config(struct net *net, int cmd, struct rtentry *rt,
 	if (rt->rt_gateway.sa_family == AF_INET && addr) {
 		cfg->fc_gw = addr;
 		if (rt->rt_flags & RTF_GATEWAY &&
-		    inet_addr_type(net, addr) == RTN_UNICAST)
+		    inet_addr_type(ctx, addr) == RTN_UNICAST)
 			cfg->fc_scope = RT_SCOPE_UNIVERSE;
 	}
 
@@ -478,8 +478,9 @@ static int rtentry_to_fib_config(struct net *net, int cmd, struct rtentry *rt,
  * Handle IP routing ioctl calls.
  * These are used to manipulate the routing tables
  */
-int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
+int ip_rt_ioctl(struct net_ctx *ctx, unsigned int cmd, void __user *arg)
 {
+	struct net *net = ctx->net;
 	struct fib_config cfg;
 	struct rtentry rt;
 	int err;
@@ -494,7 +495,7 @@ int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 			return -EFAULT;
 
 		rtnl_lock();
-		err = rtentry_to_fib_config(net, cmd, &rt, &cfg);
+		err = rtentry_to_fib_config(ctx, cmd, &rt, &cfg);
 		if (err == 0) {
 			struct fib_table *tb;
 
@@ -534,7 +535,7 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1] = {
 	[RTA_FLOW]		= { .type = NLA_U32 },
 };
 
-static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
+static int rtm_to_fib_config(struct net_ctx *ctx, struct sk_buff *skb,
 			     struct nlmsghdr *nlh, struct fib_config *cfg)
 {
 	struct nlattr *attr;
@@ -559,7 +560,7 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 
 	cfg->fc_nlinfo.portid = NETLINK_CB(skb).portid;
 	cfg->fc_nlinfo.nlh = nlh;
-	cfg->fc_nlinfo.nl_net = net;
+	cfg->fc_nlinfo.nl_net = ctx->net;
 
 	if (cfg->fc_type > RTN_MAX) {
 		err = -EINVAL;
@@ -607,12 +608,13 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 
 static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(skb->sk);
+	struct net *net = sk_ctx.net;
 	struct fib_config cfg;
 	struct fib_table *tb;
 	int err;
 
-	err = rtm_to_fib_config(net, skb, nlh, &cfg);
+	err = rtm_to_fib_config(&sk_ctx, skb, nlh, &cfg);
 	if (err < 0)
 		goto errout;
 
@@ -629,12 +631,13 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx sk_ctx = SKB_NET_CTX_SOCK(skb);
+	struct net *net = sk_ctx.net;
 	struct fib_config cfg;
 	struct fib_table *tb;
 	int err;
 
-	err = rtm_to_fib_config(net, skb, nlh, &cfg);
+	err = rtm_to_fib_config(&sk_ctx, skb, nlh, &cfg);
 	if (err < 0)
 		goto errout;
 
@@ -897,19 +900,21 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 			fib_magic(RTM_DELROUTE, RTN_BROADCAST, any, 32, prim);
 	}
 	if (!(ok & LOCAL_OK)) {
+		struct net_ctx dev_ctx = DEV_NET_CTX(dev);
+
 		fib_magic(RTM_DELROUTE, RTN_LOCAL, ifa->ifa_local, 32, prim);
 
 		/* Check, that this local address finally disappeared. */
 		if (gone &&
-		    inet_addr_type(dev_net(dev), ifa->ifa_local) != RTN_LOCAL) {
+		    inet_addr_type(&dev_ctx, ifa->ifa_local) != RTN_LOCAL) {
 			/* And the last, but not the least thing.
 			 * We must flush stray FIB entries.
 			 *
 			 * First of all, we scan fib_info list searching
 			 * for stray nexthop entries, then ignite fib_flush.
 			 */
-			if (fib_sync_down_addr(dev_net(dev), ifa->ifa_local))
-				fib_flush(dev_net(dev));
+			if (fib_sync_down_addr(&dev_ctx, ifa->ifa_local))
+				fib_flush(dev_ctx.net);
 		}
 	}
 #undef LOCAL_OK
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index d3db718be51d..60b14866661b 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -47,7 +47,7 @@ struct fib4_rule {
 #endif
 };
 
-int __fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res)
+int __fib_lookup(struct net_ctx *ctx, struct flowi4 *flp, struct fib_result *res)
 {
 	struct fib_lookup_arg arg = {
 		.result = res,
@@ -55,7 +55,8 @@ int __fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res)
 	};
 	int err;
 
-	err = fib_rules_lookup(net->ipv4.rules_ops, flowi4_to_flowi(flp), 0, &arg);
+	err = fib_rules_lookup(ctx->net->ipv4.rules_ops, flowi4_to_flowi(flp),
+			       0, &arg);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	if (arg.rule)
 		res->tclassid = ((struct fib4_rule *)arg.rule)->tclassid;
@@ -288,7 +289,7 @@ static size_t fib4_rule_nlmsg_payload(struct fib_rule *rule)
 
 static void fib4_rule_flush_cache(struct fib_rules_ops *ops)
 {
-	rt_cache_flush(ops->fro_net);
+	rt_cache_flush(ops->fro_net_ctx.net);
 }
 
 static const struct fib_rules_ops __net_initconst fib4_rules_ops_template = {
@@ -330,8 +331,9 @@ int __net_init fib4_rules_init(struct net *net)
 {
 	int err;
 	struct fib_rules_ops *ops;
+	struct net_ctx ctx = { .net = net };
 
-	ops = fib_rules_register(&fib4_rules_ops_template, net);
+	ops = fib_rules_register(&fib4_rules_ops_template, &ctx);
 	if (IS_ERR(ops))
 		return PTR_ERR(ops);
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 1e2090ea663e..99af28c2fb6d 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -303,12 +303,13 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
 	struct hlist_head *head;
 	struct fib_info *fi;
 	unsigned int hash;
+	const struct net_ctx *nfi_ctx = &nfi->fib_net_ctx;
 
 	hash = fib_info_hashfn(nfi);
 	head = &fib_info_hash[hash];
 
 	hlist_for_each_entry(fi, head, fib_hash) {
-		if (!net_eq(fi->fib_net, nfi->fib_net))
+		if (!fib_net_ctx_eq(fi, nfi_ctx))
 			continue;
 		if (fi->fib_nhs != nfi->fib_nhs)
 			continue;
@@ -587,10 +588,9 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			struct fib_nh *nh)
 {
 	int err;
-	struct net *net;
+	struct net_ctx *net_ctx = &cfg->fc_nlinfo.nl_net_ctx;
 	struct net_device *dev;
 
-	net = cfg->fc_nlinfo.nl_net;
 	if (nh->nh_gw) {
 		struct fib_result res;
 
@@ -598,9 +598,9 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 
 			if (cfg->fc_scope >= RT_SCOPE_LINK)
 				return -EINVAL;
-			if (inet_addr_type(net, nh->nh_gw) != RTN_UNICAST)
+			if (inet_addr_type(net_ctx, nh->nh_gw) != RTN_UNICAST)
 				return -EINVAL;
-			dev = __dev_get_by_index(net, nh->nh_oif);
+			dev = __dev_get_by_index_ctx(net_ctx, nh->nh_oif);
 			if (!dev)
 				return -ENODEV;
 			if (!(dev->flags & IFF_UP))
@@ -622,7 +622,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			/* It is not necessary, but requires a bit of thinking */
 			if (fl4.flowi4_scope < RT_SCOPE_LINK)
 				fl4.flowi4_scope = RT_SCOPE_LINK;
-			err = fib_lookup(net, &fl4, &res);
+			err = fib_lookup(net_ctx, &fl4, &res);
 			if (err) {
 				rcu_read_unlock();
 				return err;
@@ -646,7 +646,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 
 		rcu_read_lock();
 		err = -ENODEV;
-		in_dev = inetdev_by_index(net, nh->nh_oif);
+		in_dev = inetdev_by_index(net_ctx, nh->nh_oif);
 		if (in_dev == NULL)
 			goto out;
 		err = -ENETDOWN;
@@ -748,8 +748,10 @@ static void fib_info_hash_move(struct hlist_head *new_info_hash,
 	fib_info_hash_free(old_laddrhash, bytes);
 }
 
-__be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh)
+__be32 fib_info_update_nh_saddr(struct net_ctx *net_ctx, struct fib_nh *nh)
 {
+	struct net *net = net_ctx->net;
+
 	nh->nh_saddr = inet_select_addr(nh->nh_dev,
 					nh->nh_gw,
 					nh->nh_parent->fib_scope);
@@ -764,7 +766,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	struct fib_info *fi = NULL;
 	struct fib_info *ofi;
 	int nhs = 1;
-	struct net *net = cfg->fc_nlinfo.nl_net;
+	struct net_ctx *net_ctx = &cfg->fc_nlinfo.nl_net_ctx;
+	struct net *net = net_ctx->net;
 
 	if (cfg->fc_type > RTN_MAX)
 		goto err_inval;
@@ -935,12 +938,12 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	if (fi->fib_prefsrc) {
 		if (cfg->fc_type != RTN_LOCAL || !cfg->fc_dst ||
 		    fi->fib_prefsrc != cfg->fc_dst)
-			if (inet_addr_type(net, fi->fib_prefsrc) != RTN_LOCAL)
+			if (inet_addr_type(net_ctx, fi->fib_prefsrc) != RTN_LOCAL)
 				goto err_inval;
 	}
 
 	change_nexthops(fi) {
-		fib_info_update_nh_saddr(net, nexthop_nh);
+		fib_info_update_nh_saddr(net_ctx, nexthop_nh);
 	} endfor_nexthops(fi)
 
 link_it:
@@ -1087,7 +1090,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
  *   referring to it.
  * - device went down -> we must shutdown all nexthops going via it.
  */
-int fib_sync_down_addr(struct net *net, __be32 local)
+int fib_sync_down_addr(struct net_ctx *net_ctx, __be32 local)
 {
 	int ret = 0;
 	unsigned int hash = fib_laddr_hashfn(local);
@@ -1098,7 +1101,7 @@ int fib_sync_down_addr(struct net *net, __be32 local)
 		return 0;
 
 	hlist_for_each_entry(fi, head, fib_lhash) {
-		if (!net_eq(fi->fib_net, net))
+		if (!fib_net_ctx_eq(fi, net_ctx))
 			continue;
 		if (fi->fib_prefsrc == local) {
 			fi->fib_flags |= RTNH_F_DEAD;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5e564014a0b7..f64de76f55ef 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -389,6 +389,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	struct ipcm_cookie ipc;
 	struct rtable *rt = skb_rtable(skb);
 	struct net *net = dev_net(rt->dst.dev);
+	struct net_ctx dev_ctx = { .net = net };
 	struct flowi4 fl4;
 	struct sock *sk;
 	struct inet_sock *inet;
@@ -426,7 +427,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 	fl4.flowi4_proto = IPPROTO_ICMP;
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
-	rt = ip_route_output_key(net, &fl4);
+	rt = ip_route_output_key(&dev_ctx, &fl4);
 	if (IS_ERR(rt))
 		goto out_unlock;
 	if (icmpv4_xrlim_allow(net, rt, &fl4, icmp_param->data.icmph.type,
@@ -437,7 +438,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	icmp_xmit_unlock(sk);
 }
 
-static struct rtable *icmp_route_lookup(struct net *net,
+static struct rtable *icmp_route_lookup(struct net_ctx *ctx,
 					struct flowi4 *fl4,
 					struct sk_buff *skb_in,
 					const struct iphdr *iph,
@@ -459,14 +460,14 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->fl4_icmp_type = type;
 	fl4->fl4_icmp_code = code;
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
-	rt = __ip_route_output_key(net, fl4);
+	rt = __ip_route_output_key(ctx, fl4);
 	if (IS_ERR(rt))
 		return rt;
 
 	/* No need to clone since we're just using its address. */
 	rt2 = rt;
 
-	rt = (struct rtable *) xfrm_lookup(net, &rt->dst,
+	rt = (struct rtable *) xfrm_lookup(ctx, &rt->dst,
 					   flowi4_to_flowi(fl4), NULL, 0);
 	if (!IS_ERR(rt)) {
 		if (rt != rt2)
@@ -480,8 +481,8 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	if (err)
 		goto relookup_failed;
 
-	if (inet_addr_type(net, fl4_dec.saddr) == RTN_LOCAL) {
-		rt2 = __ip_route_output_key(net, &fl4_dec);
+	if (inet_addr_type(ctx, fl4_dec.saddr) == RTN_LOCAL) {
+		rt2 = __ip_route_output_key(ctx, &fl4_dec);
 		if (IS_ERR(rt2))
 			err = PTR_ERR(rt2);
 	} else {
@@ -489,7 +490,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 		unsigned long orefdst;
 
 		fl4_2.daddr = fl4_dec.saddr;
-		rt2 = ip_route_output_key(net, &fl4_2);
+		rt2 = ip_route_output_key(ctx, &fl4_2);
 		if (IS_ERR(rt2)) {
 			err = PTR_ERR(rt2);
 			goto relookup_failed;
@@ -507,7 +508,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	if (err)
 		goto relookup_failed;
 
-	rt2 = (struct rtable *) xfrm_lookup(net, &rt2->dst,
+	rt2 = (struct rtable *) xfrm_lookup(ctx, &rt2->dst,
 					    flowi4_to_flowi(&fl4_dec), NULL,
 					    XFRM_LOOKUP_ICMP);
 	if (!IS_ERR(rt2)) {
@@ -552,12 +553,14 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	__be32 saddr;
 	u8  tos;
 	u32 mark;
+	struct net_ctx dev_ctx;
 	struct net *net;
 	struct sock *sk;
 
 	if (!rt)
 		goto out;
 	net = dev_net(rt->dst.dev);
+	dev_ctx.net = net;
 
 	/*
 	 *	Find the original header. It is expected to be valid, of course.
@@ -641,7 +644,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		rcu_read_lock();
 		if (rt_is_input_route(rt) &&
 		    net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr)
-			dev = dev_get_by_index_rcu(net, inet_iif(skb_in));
+			dev = dev_get_by_index_rcu_ctx(&dev_ctx, inet_iif(skb_in));
 
 		if (dev)
 			saddr = inet_select_addr(dev, 0, RT_SCOPE_LINK);
@@ -677,7 +680,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	ipc.ttl = 0;
 	ipc.tos = -1;
 
-	rt = icmp_route_lookup(net, &fl4, skb_in, iph, saddr, tos, mark,
+	rt = icmp_route_lookup(&dev_ctx, &fl4, skb_in, iph, saddr, tos, mark,
 			       type, code, icmp_param);
 	if (IS_ERR(rt))
 		goto out_unlock;
@@ -750,11 +753,10 @@ static bool icmp_unreach(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
 	struct icmphdr *icmph;
-	struct net *net;
+	struct net_ctx dev_ctx = SKB_NET_CTX_DST(skb);
+	struct net *net = dev_ctx.net;
 	u32 info = 0;
 
-	net = dev_net(skb_dst(skb)->dev);
-
 	/*
 	 *	Incomplete header ?
 	 * 	Only checks for the IP header, there should be an
@@ -828,7 +830,7 @@ static bool icmp_unreach(struct sk_buff *skb)
 	 */
 
 	if (!net->ipv4.sysctl_icmp_ignore_bogus_error_responses &&
-	    inet_addr_type(net, iph->daddr) == RTN_BROADCAST) {
+	    inet_addr_type(&dev_ctx, iph->daddr) == RTN_BROADCAST) {
 		net_warn_ratelimited("%pI4 sent an invalid ICMP type %u, code %u error to a broadcast: %pI4 on %s\n",
 				     &ip_hdr(skb)->saddr,
 				     icmph->type, icmph->code,
@@ -1044,7 +1046,7 @@ void icmp_err(struct sk_buff *skb, u32 info)
 	struct icmphdr *icmph = (struct icmphdr *)(skb->data + offset);
 	int type = icmp_hdr(skb)->type;
 	int code = icmp_hdr(skb)->code;
-	struct net *net = dev_net(skb->dev);
+	struct net_ctx dev_ctx = SKB_NET_CTX_DEV(skb);
 
 	/*
 	 * Use ping_err to handle all icmp errors except those
@@ -1056,9 +1058,9 @@ void icmp_err(struct sk_buff *skb, u32 info)
 	}
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED)
-		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_ICMP, 0);
+		ipv4_update_pmtu(skb, &dev_ctx, info, 0, 0, IPPROTO_ICMP, 0);
 	else if (type == ICMP_REDIRECT)
-		ipv4_redirect(skb, net, 0, 0, IPPROTO_ICMP, 0);
+		ipv4_redirect(skb, &dev_ctx, 0, 0, IPPROTO_ICMP, 0);
 }
 
 /*
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 666cf364df86..86aa303a1cf7 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -324,7 +324,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, unsigned int mtu)
 	struct rtable *rt;
 	struct iphdr *pip;
 	struct igmpv3_report *pig;
-	struct net *net = dev_net(dev);
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 	struct flowi4 fl4;
 	int hlen = LL_RESERVED_SPACE(dev);
 	int tlen = dev->needed_tailroom;
@@ -341,7 +341,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, unsigned int mtu)
 	}
 	skb->priority = TC_PRIO_CONTROL;
 
-	rt = ip_route_output_ports(net, &fl4, NULL, IGMPV3_ALL_MCR, 0,
+	rt = ip_route_output_ports(&dev_ctx, &fl4, NULL, IGMPV3_ALL_MCR, 0,
 				   0, 0,
 				   IPPROTO_IGMP, 0, dev->ifindex);
 	if (IS_ERR(rt)) {
@@ -669,7 +669,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	struct igmphdr *ih;
 	struct rtable *rt;
 	struct net_device *dev = in_dev->dev;
-	struct net *net = dev_net(dev);
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 	__be32	group = pmc ? pmc->multiaddr : 0;
 	struct flowi4 fl4;
 	__be32	dst;
@@ -682,7 +682,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	else
 		dst = group;
 
-	rt = ip_route_output_ports(net, &fl4, NULL, dst, 0,
+	rt = ip_route_output_ports(&dev_ctx, &fl4, NULL, dst, 0,
 				   0, 0,
 				   IPPROTO_IGMP, 0, dev->ifindex);
 	if (IS_ERR(rt))
@@ -1503,23 +1503,23 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 }
 
 /* RTNL is locked */
-static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
+static struct in_device *ip_mc_find_dev(struct net_ctx *ctx, struct ip_mreqn *imr)
 {
 	struct net_device *dev = NULL;
 	struct in_device *idev = NULL;
 
 	if (imr->imr_ifindex) {
-		idev = inetdev_by_index(net, imr->imr_ifindex);
+		idev = inetdev_by_index(ctx, imr->imr_ifindex);
 		return idev;
 	}
 	if (imr->imr_address.s_addr) {
-		dev = __ip_dev_find(net, imr->imr_address.s_addr, false);
+		dev = __ip_dev_find(ctx, imr->imr_address.s_addr, false);
 		if (!dev)
 			return NULL;
 	}
 
 	if (!dev) {
-		struct rtable *rt = ip_route_output(net,
+		struct rtable *rt = ip_route_output(ctx,
 						    imr->imr_multiaddr.s_addr,
 						    0, 0, 0);
 		if (!IS_ERR(rt)) {
@@ -1860,7 +1860,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 	struct ip_mc_socklist *iml = NULL, *i;
 	struct in_device *in_dev;
 	struct inet_sock *inet = inet_sk(sk);
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 	int ifindex;
 	int count = 0;
 
@@ -1869,7 +1869,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 
 	rtnl_lock();
 
-	in_dev = ip_mc_find_dev(net, imr);
+	in_dev = ip_mc_find_dev(&sk_ctx, imr);
 
 	if (!in_dev) {
 		iml = NULL;
@@ -1935,13 +1935,13 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 	struct ip_mc_socklist *iml;
 	struct ip_mc_socklist __rcu **imlp;
 	struct in_device *in_dev;
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 	__be32 group = imr->imr_multiaddr.s_addr;
 	u32 ifindex;
 	int ret = -EADDRNOTAVAIL;
 
 	rtnl_lock();
-	in_dev = ip_mc_find_dev(net, imr);
+	in_dev = ip_mc_find_dev(&sk_ctx, imr);
 	if (!in_dev) {
 		ret = -ENODEV;
 		goto out;
@@ -1986,7 +1986,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	struct in_device *in_dev = NULL;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_sf_socklist *psl;
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 	int leavegroup = 0;
 	int i, j, rv;
 
@@ -1998,7 +1998,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	imr.imr_multiaddr.s_addr = mreqs->imr_multiaddr;
 	imr.imr_address.s_addr = mreqs->imr_interface;
 	imr.imr_ifindex = ifindex;
-	in_dev = ip_mc_find_dev(net, &imr);
+	in_dev = ip_mc_find_dev(&sk_ctx, &imr);
 
 	if (!in_dev) {
 		err = -ENODEV;
@@ -2122,7 +2122,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	struct in_device *in_dev;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_sf_socklist *newpsl, *psl;
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 	int leavegroup = 0;
 
 	if (!ipv4_is_multicast(addr))
@@ -2136,7 +2136,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	imr.imr_multiaddr.s_addr = msf->imsf_multiaddr;
 	imr.imr_address.s_addr = msf->imsf_interface;
 	imr.imr_ifindex = ifindex;
-	in_dev = ip_mc_find_dev(net, &imr);
+	in_dev = ip_mc_find_dev(&sk_ctx, &imr);
 
 	if (!in_dev) {
 		err = -ENODEV;
@@ -2209,7 +2209,7 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	struct in_device *in_dev;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_sf_socklist *psl;
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
@@ -2219,7 +2219,7 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	imr.imr_multiaddr.s_addr = msf->imsf_multiaddr;
 	imr.imr_address.s_addr = msf->imsf_interface;
 	imr.imr_ifindex = 0;
-	in_dev = ip_mc_find_dev(net, &imr);
+	in_dev = ip_mc_find_dev(&sk_ctx, &imr);
 
 	if (!in_dev) {
 		err = -ENODEV;
@@ -2366,7 +2366,7 @@ void ip_mc_drop_socket(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_mc_socklist *iml;
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	if (inet->mc_list == NULL)
 		return;
@@ -2376,7 +2376,7 @@ void ip_mc_drop_socket(struct sock *sk)
 		struct in_device *in_dev;
 
 		inet->mc_list = iml->next_rcu;
-		in_dev = inetdev_by_index(net, iml->multi.imr_ifindex);
+		in_dev = inetdev_by_index(&sk_ctx, iml->multi.imr_ifindex);
 		(void) ip_mc_leave_src(sk, iml, in_dev);
 		if (in_dev != NULL)
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
@@ -2442,7 +2442,8 @@ struct igmp_mc_iter_state {
 
 static inline struct ip_mc_list *igmp_mc_get_first(struct seq_file *seq)
 {
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
+	struct net *net = ctx->net;
 	struct ip_mc_list *im = NULL;
 	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
 
@@ -2585,7 +2586,8 @@ struct igmp_mcf_iter_state {
 
 static inline struct ip_sf_list *igmp_mcf_get_first(struct seq_file *seq)
 {
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
+	struct net *net = ctx->net;
 	struct ip_sf_list *psf = NULL;
 	struct ip_mc_list *im = NULL;
 	struct igmp_mcf_iter_state *state = igmp_mcf_seq_private(seq);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 14d02ea905b6..b3580594d08a 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -95,7 +95,8 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	struct inet_bind_hashbucket *head;
 	struct inet_bind_bucket *tb;
 	int ret, attempts = 5;
-	struct net *net = sock_net(sk);
+	struct net_ctx net_ctx = SOCK_NET_CTX(sk);
+	struct net *net = net_ctx.net;
 	int smallest_size = -1, smallest_rover;
 	kuid_t uid = sock_i_uid(sk);
 
@@ -116,7 +117,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 					hashinfo->bhash_size)];
 			spin_lock(&head->lock);
 			inet_bind_bucket_for_each(tb, &head->chain)
-				if (net_eq(ib_net(tb), net) && tb->port == rover) {
+				if (ib_net_ctx_eq(tb, &net_ctx) && tb->port == rover) {
 					if (((tb->fastreuse > 0 &&
 					      sk->sk_reuse &&
 					      sk->sk_state != TCP_LISTEN) ||
@@ -170,7 +171,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 				hashinfo->bhash_size)];
 		spin_lock(&head->lock);
 		inet_bind_bucket_for_each(tb, &head->chain)
-			if (net_eq(ib_net(tb), net) && tb->port == snum)
+			if (ib_net_ctx_eq(tb, &net_ctx) && tb->port == snum)
 				goto tb_found;
 	}
 	tb = NULL;
@@ -204,7 +205,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 tb_not_found:
 	ret = 1;
 	if (!tb && (tb = inet_bind_bucket_create(hashinfo->bind_bucket_cachep,
-					net, head, snum)) == NULL)
+					&net_ctx, head, snum)) == NULL)
 		goto fail_unlock;
 	if (hlist_empty(&tb->owners)) {
 		if (sk->sk_reuse && sk->sk_state != TCP_LISTEN)
@@ -403,6 +404,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct ip_options_rcu *opt = inet_rsk(req)->opt;
 	struct net *net = sock_net(sk);
+	struct net_ctx ctx = { .net = net };
 	int flags = inet_sk_flowi_flags(sk);
 
 	flowi4_init_output(fl4, sk->sk_bound_dev_if, ireq->ir_mark,
@@ -412,7 +414,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
 			   ireq->ir_loc_addr, ireq->ir_rmt_port, inet_sk(sk)->inet_sport);
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
-	rt = ip_route_output_flow(net, fl4, sk);
+	rt = ip_route_output_flow(&ctx, fl4, sk);
 	if (IS_ERR(rt))
 		goto no_route;
 	if (opt && opt->opt.is_strictroute && rt->rt_uses_gateway)
@@ -435,6 +437,7 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 	struct inet_sock *newinet = inet_sk(newsk);
 	struct ip_options_rcu *opt;
 	struct net *net = sock_net(sk);
+	struct net_ctx ctx = { .net = net };
 	struct flowi4 *fl4;
 	struct rtable *rt;
 
@@ -448,7 +451,7 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
 			   ireq->ir_loc_addr, ireq->ir_rmt_port, inet_sk(sk)->inet_sport);
 	security_req_classify_flow(req, flowi4_to_flowi(fl4));
-	rt = ip_route_output_flow(net, fl4, sk);
+	rt = ip_route_output_flow(&ctx, fl4, sk);
 	if (IS_ERR(rt))
 		goto no_route;
 	if (opt && opt->opt.is_strictroute && rt->rt_uses_gateway)
@@ -898,13 +901,14 @@ static struct dst_entry *inet_csk_rebuild_route(struct sock *sk, struct flowi *f
 	__be32 daddr = inet->inet_daddr;
 	struct flowi4 *fl4;
 	struct rtable *rt;
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	rcu_read_lock();
 	inet_opt = rcu_dereference(inet->inet_opt);
 	if (inet_opt && inet_opt->opt.srr)
 		daddr = inet_opt->opt.faddr;
 	fl4 = &fl->u.ip4;
-	rt = ip_route_output_ports(sock_net(sk), fl4, sk, daddr,
+	rt = ip_route_output_ports(&sk_ctx, fl4, sk, daddr,
 				   inet->inet_saddr, inet->inet_dport,
 				   inet->inet_sport, sk->sk_protocol,
 				   RT_CONN_FLAGS(sk), sk->sk_bound_dev_if);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 81751f12645f..c4691505014b 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -296,17 +296,18 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_s
 	int err;
 	struct sock *sk;
 	struct sk_buff *rep;
-	struct net *net = sock_net(in_skb->sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(in_skb->sk);
+	struct net *net = sk_ctx.net;
 
 	err = -EINVAL;
 	if (req->sdiag_family == AF_INET) {
-		sk = inet_lookup(net, hashinfo, req->id.idiag_dst[0],
+		sk = inet_lookup(&sk_ctx, hashinfo, req->id.idiag_dst[0],
 				 req->id.idiag_dport, req->id.idiag_src[0],
 				 req->id.idiag_sport, req->id.idiag_if);
 	}
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (req->sdiag_family == AF_INET6) {
-		sk = inet6_lookup(net, hashinfo,
+		sk = inet6_lookup(&sk_ctx, hashinfo,
 				  (struct in6_addr *)req->id.idiag_dst,
 				  req->id.idiag_dport,
 				  (struct in6_addr *)req->id.idiag_src,
@@ -842,7 +843,7 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 {
 	int i, num;
 	int s_i, s_num;
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx ctx = SOCK_NET_CTX(skb->sk);
 
 	s_i = cb->args[1];
 	s_num = num = cb->args[2];
@@ -862,7 +863,7 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 			sk_nulls_for_each(sk, node, &ilb->head) {
 				struct inet_sock *inet = inet_sk(sk);
 
-				if (!net_eq(sock_net(sk), net))
+				if (!sock_net_ctx_eq(sk, &ctx))
 					continue;
 
 				if (num < s_num) {
@@ -935,7 +936,7 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 			int res;
 			int state;
 
-			if (!net_eq(sock_net(sk), net))
+			if (!sock_net_ctx_eq(sk, &ctx))
 				continue;
 			if (num < s_num)
 				goto next_normal;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 1485dac0ead5..8b3d94ca634c 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -54,14 +54,14 @@ static unsigned int inet_sk_ehashfn(const struct sock *sk)
  * The bindhash mutex for snum's hash chain must be held here.
  */
 struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
-						 struct net *net,
+						 struct net_ctx *ctx,
 						 struct inet_bind_hashbucket *head,
 						 const unsigned short snum)
 {
 	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
 
 	if (tb != NULL) {
-		write_pnet(&tb->ib_net_ctx.net, hold_net(net));
+		write_pnet(&tb->ib_net_ctx.net, hold_net(ctx->net));
 		tb->port      = snum;
 		tb->fastreuse = 0;
 		tb->fastreuseport = 0;
@@ -136,6 +136,7 @@ int __inet_inherit_port(struct sock *sk, struct sock *child)
 			table->bhash_size);
 	struct inet_bind_hashbucket *head = &table->bhash[bhash];
 	struct inet_bind_bucket *tb;
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	spin_lock(&head->lock);
 	tb = inet_csk(sk)->icsk_bind_hash;
@@ -146,13 +147,13 @@ int __inet_inherit_port(struct sock *sk, struct sock *child)
 		 * as that of the child socket. We have to look up or
 		 * create a new bind bucket for the child here. */
 		inet_bind_bucket_for_each(tb, &head->chain) {
-			if (net_eq(ib_net(tb), sock_net(sk)) &&
+			if (ib_net_ctx_eq(tb, &sk_ctx) &&
 			    tb->port == port)
 				break;
 		}
 		if (!tb) {
 			tb = inet_bind_bucket_create(table->bind_bucket_cachep,
-						     sock_net(sk), head, port);
+						     &sk_ctx, head, port);
 			if (!tb) {
 				spin_unlock(&head->lock);
 				return -ENOMEM;
@@ -166,14 +167,14 @@ int __inet_inherit_port(struct sock *sk, struct sock *child)
 }
 EXPORT_SYMBOL_GPL(__inet_inherit_port);
 
-static inline int compute_score(struct sock *sk, struct net *net,
+static inline int compute_score(struct sock *sk, struct net_ctx *ctx,
 				const unsigned short hnum, const __be32 daddr,
 				const int dif)
 {
 	int score = -1;
 	struct inet_sock *inet = inet_sk(sk);
 
-	if (net_eq(sock_net(sk), net) && inet->inet_num == hnum &&
+	if (sock_net_ctx_eq(sk, ctx) && inet->inet_num == hnum &&
 			!ipv6_only_sock(sk)) {
 		__be32 rcv_saddr = inet->inet_rcv_saddr;
 		score = sk->sk_family == PF_INET ? 2 : 1;
@@ -199,12 +200,13 @@ static inline int compute_score(struct sock *sk, struct net *net,
  */
 
 
-struct sock *__inet_lookup_listener(struct net *net,
+struct sock *__inet_lookup_listener(struct net_ctx *ctx,
 				    struct inet_hashinfo *hashinfo,
 				    const __be32 saddr, __be16 sport,
 				    const __be32 daddr, const unsigned short hnum,
 				    const int dif)
 {
+	struct net *net = ctx->net;
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
 	unsigned int hash = inet_lhashfn(net, hnum);
@@ -217,7 +219,7 @@ struct sock *__inet_lookup_listener(struct net *net,
 	result = NULL;
 	hiscore = 0;
 	sk_nulls_for_each_rcu(sk, node, &ilb->head) {
-		score = compute_score(sk, net, hnum, daddr, dif);
+		score = compute_score(sk, ctx, hnum, daddr, dif);
 		if (score > hiscore) {
 			result = sk;
 			hiscore = score;
@@ -244,7 +246,7 @@ struct sock *__inet_lookup_listener(struct net *net,
 	if (result) {
 		if (unlikely(!atomic_inc_not_zero(&result->sk_refcnt)))
 			result = NULL;
-		else if (unlikely(compute_score(result, net, hnum, daddr,
+		else if (unlikely(compute_score(result, ctx, hnum, daddr,
 				  dif) < hiscore)) {
 			sock_put(result);
 			goto begin;
@@ -268,12 +270,13 @@ void sock_gen_put(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sock_gen_put);
 
-struct sock *__inet_lookup_established(struct net *net,
+struct sock *__inet_lookup_established(struct net_ctx *ctx,
 				  struct inet_hashinfo *hashinfo,
 				  const __be32 saddr, const __be16 sport,
 				  const __be32 daddr, const u16 hnum,
 				  const int dif)
 {
+	struct net *net = ctx->net;
 	INET_ADDR_COOKIE(acookie, saddr, daddr);
 	const __portpair ports = INET_COMBINED_PORTS(sport, hnum);
 	struct sock *sk;
@@ -290,11 +293,11 @@ struct sock *__inet_lookup_established(struct net *net,
 	sk_nulls_for_each_rcu(sk, node, &head->chain) {
 		if (sk->sk_hash != hash)
 			continue;
-		if (likely(INET_MATCH(sk, net, acookie,
+		if (likely(INET_MATCH(sk, ctx, acookie,
 				      saddr, daddr, ports, dif))) {
 			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
 				goto out;
-			if (unlikely(!INET_MATCH(sk, net, acookie,
+			if (unlikely(!INET_MATCH(sk, ctx, acookie,
 						 saddr, daddr, ports, dif))) {
 				sock_gen_put(sk);
 				goto begin;
@@ -329,7 +332,8 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 	int dif = sk->sk_bound_dev_if;
 	INET_ADDR_COOKIE(acookie, saddr, daddr);
 	const __portpair ports = INET_COMBINED_PORTS(inet->inet_dport, lport);
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
+	struct net *net = sk_ctx.net;
 	unsigned int hash = inet_ehashfn(net, daddr, lport,
 					 saddr, inet->inet_dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
@@ -345,7 +349,7 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 		if (sk2->sk_hash != hash)
 			continue;
 
-		if (likely(INET_MATCH(sk2, net, acookie,
+		if (likely(INET_MATCH(sk2, &sk_ctx, acookie,
 					 saddr, daddr, ports, dif))) {
 			if (sk2->sk_state == TCP_TIME_WAIT) {
 				tw = inet_twsk(sk2);
@@ -485,7 +489,8 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 	struct inet_bind_hashbucket *head;
 	struct inet_bind_bucket *tb;
 	int ret;
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
+	struct net *net = sk_ctx.net;
 	int twrefcnt = 1;
 
 	if (!snum) {
@@ -511,7 +516,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			 * unique enough.
 			 */
 			inet_bind_bucket_for_each(tb, &head->chain) {
-				if (net_eq(ib_net(tb), net) &&
+				if (ib_net_ctx_eq(tb, &sk_ctx) &&
 				    tb->port == port) {
 					if (tb->fastreuse >= 0 ||
 					    tb->fastreuseport >= 0)
@@ -525,7 +530,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			}
 
 			tb = inet_bind_bucket_create(hinfo->bind_bucket_cachep,
-					net, head, port);
+					&sk_ctx, head, port);
 			if (!tb) {
 				spin_unlock(&head->lock);
 				break;
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 3d4da2c16b6a..be5933f1f425 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -156,6 +156,7 @@ bool ip_call_ra_chain(struct sk_buff *skb)
 	u8 protocol = ip_hdr(skb)->protocol;
 	struct sock *last = NULL;
 	struct net_device *dev = skb->dev;
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 
 	for (ra = rcu_dereference(ip_ra_chain); ra; ra = rcu_dereference(ra->next)) {
 		struct sock *sk = ra->sk;
@@ -166,7 +167,7 @@ bool ip_call_ra_chain(struct sk_buff *skb)
 		if (sk && inet_sk(sk)->inet_num == protocol &&
 		    (!sk->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == dev->ifindex) &&
-		    net_eq(sock_net(sk), dev_net(dev))) {
+		    sock_net_ctx_eq(sk, &dev_ctx)) {
 			if (ip_is_fragment(ip_hdr(skb))) {
 				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN))
 					return true;
@@ -262,6 +263,7 @@ static inline bool ip_rcv_options(struct sk_buff *skb)
 	struct ip_options *opt;
 	const struct iphdr *iph;
 	struct net_device *dev = skb->dev;
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 
 	/* It looks as overkill, because not all
 	   IP options require packet mangling.
@@ -279,7 +281,7 @@ static inline bool ip_rcv_options(struct sk_buff *skb)
 	opt = &(IPCB(skb)->opt);
 	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
 
-	if (ip_options_compile(dev_net(dev), opt, skb)) {
+	if (ip_options_compile(&dev_ctx, opt, skb)) {
 		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
 		goto drop;
 	}
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 5b3d91be2db0..b5e2f5860544 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -139,9 +139,10 @@ int __ip_options_echo(struct ip_options *dopt, struct sk_buff *skb,
 
 					if (soffset + 7 <= optlen) {
 						__be32 addr;
+						struct net_ctx ctx = SKB_NET_CTX_DST(skb);
 
 						memcpy(&addr, dptr+soffset-1, 4);
-						if (inet_addr_type(dev_net(skb_dst(skb)->dev), addr) != RTN_UNICAST) {
+						if (inet_addr_type(&ctx, addr) != RTN_UNICAST) {
 							dopt->ts_needtime = 1;
 							soffset += 8;
 						}
@@ -254,9 +255,10 @@ static void spec_dst_fill(__be32 *spec_dst, struct sk_buff *skb)
  * If opt == NULL, then skb->data should point to IP header.
  */
 
-int ip_options_compile(struct net *net,
+int ip_options_compile(struct net_ctx *net_ctx,
 		       struct ip_options *opt, struct sk_buff *skb)
 {
+	struct net *net = net_ctx->net;
 	__be32 spec_dst = htonl(INADDR_ANY);
 	unsigned char *pp_ptr = NULL;
 	struct rtable *rt = NULL;
@@ -399,7 +401,7 @@ int ip_options_compile(struct net *net,
 					{
 						__be32 addr;
 						memcpy(&addr, &optptr[optptr[2]-1], 4);
-						if (inet_addr_type(net, addr) == RTN_UNICAST)
+						if (inet_addr_type(net_ctx, addr) == RTN_UNICAST)
 							break;
 						if (skb)
 							timeptr = &optptr[optptr[2]+3];
@@ -516,13 +518,13 @@ static struct ip_options_rcu *ip_options_get_alloc(const int optlen)
 		       GFP_KERNEL);
 }
 
-static int ip_options_get_finish(struct net *net, struct ip_options_rcu **optp,
+static int ip_options_get_finish(struct net_ctx *net_ctx, struct ip_options_rcu **optp,
 				 struct ip_options_rcu *opt, int optlen)
 {
 	while (optlen & 3)
 		opt->opt.__data[optlen++] = IPOPT_END;
 	opt->opt.optlen = optlen;
-	if (optlen && ip_options_compile(net, &opt->opt, NULL)) {
+	if (optlen && ip_options_compile(net_ctx, &opt->opt, NULL)) {
 		kfree(opt);
 		return -EINVAL;
 	}
@@ -531,7 +533,7 @@ static int ip_options_get_finish(struct net *net, struct ip_options_rcu **optp,
 	return 0;
 }
 
-int ip_options_get_from_user(struct net *net, struct ip_options_rcu **optp,
+int ip_options_get_from_user(struct net_ctx *net_ctx, struct ip_options_rcu **optp,
 			     unsigned char __user *data, int optlen)
 {
 	struct ip_options_rcu *opt = ip_options_get_alloc(optlen);
@@ -542,10 +544,10 @@ int ip_options_get_from_user(struct net *net, struct ip_options_rcu **optp,
 		kfree(opt);
 		return -EFAULT;
 	}
-	return ip_options_get_finish(net, optp, opt, optlen);
+	return ip_options_get_finish(net_ctx, optp, opt, optlen);
 }
 
-int ip_options_get(struct net *net, struct ip_options_rcu **optp,
+int ip_options_get(struct net_ctx *net_ctx, struct ip_options_rcu **optp,
 		   unsigned char *data, int optlen)
 {
 	struct ip_options_rcu *opt = ip_options_get_alloc(optlen);
@@ -554,7 +556,7 @@ int ip_options_get(struct net *net, struct ip_options_rcu **optp,
 		return -ENOMEM;
 	if (optlen)
 		memcpy(opt->opt.__data, data, optlen);
-	return ip_options_get_finish(net, optp, opt, optlen);
+	return ip_options_get_finish(net_ctx, optp, opt, optlen);
 }
 
 void ip_forward_options(struct sk_buff *skb)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index b50861b22b6b..855e003e43d8 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -383,6 +383,7 @@ int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
 	rt = (struct rtable *)__sk_dst_check(sk, 0);
 	if (rt == NULL) {
 		__be32 daddr;
+		struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 		/* Use correct destination address if we have options. */
 		daddr = inet->inet_daddr;
@@ -393,7 +394,7 @@ int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
 		 * keep trying until route appears or the connection times
 		 * itself out.
 		 */
-		rt = ip_route_output_ports(sock_net(sk), fl4, sk,
+		rt = ip_route_output_ports(&sk_ctx, fl4, sk,
 					   daddr, inet->inet_saddr,
 					   inet->inet_dport,
 					   inet->inet_sport,
@@ -1522,7 +1523,7 @@ static DEFINE_PER_CPU(struct inet_sock, unicast_sock) = {
 	.uc_ttl		= -1,
 };
 
-void ip_send_unicast_reply(struct net *net, struct sk_buff *skb,
+void ip_send_unicast_reply(struct net_ctx *ctx, struct sk_buff *skb,
 			   const struct ip_options *sopt,
 			   __be32 daddr, __be32 saddr,
 			   const struct ip_reply_arg *arg,
@@ -1554,14 +1555,14 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb,
 	}
 
 	flowi4_init_output(&fl4, arg->bound_dev_if,
-			   IP4_REPLY_MARK(net, skb->mark),
+			   IP4_REPLY_MARK(ctx->net, skb->mark),
 			   RT_TOS(arg->tos),
 			   RT_SCOPE_UNIVERSE, ip_hdr(skb)->protocol,
 			   ip_reply_arg_flowi_flags(arg),
 			   daddr, saddr,
 			   tcp_hdr(skb)->source, tcp_hdr(skb)->dest);
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
-	rt = ip_route_output_key(net, &fl4);
+	rt = ip_route_output_key(ctx, &fl4);
 	if (IS_ERR(rt))
 		return;
 
@@ -1572,7 +1573,7 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb,
 	sk->sk_priority = skb->priority;
 	sk->sk_protocol = ip_hdr(skb)->protocol;
 	sk->sk_bound_dev_if = arg->bound_dev_if;
-	sock_net_set(sk, net);
+	sock_net_set(sk, ctx->net);
 	__skb_queue_head_init(&sk->sk_write_queue);
 	sk->sk_sndbuf = sysctl_wmem_default;
 	err = ip_append_data(sk, &fl4, ip_reply_glue_bits, arg->iov->iov_base,
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 31d8c71986b4..8ab03f0431f5 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -219,7 +219,7 @@ void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(ip_cmsg_recv_offset);
 
-int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc,
+int ip_cmsg_send(struct net_ctx *ctx, struct msghdr *msg, struct ipcm_cookie *ipc,
 		 bool allow_ipv6)
 {
 	int err, val;
@@ -249,7 +249,7 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc,
 		switch (cmsg->cmsg_type) {
 		case IP_RETOPTS:
 			err = cmsg->cmsg_len - CMSG_ALIGN(sizeof(struct cmsghdr));
-			err = ip_options_get(net, &ipc->opt, CMSG_DATA(cmsg),
+			err = ip_options_get(ctx, &ipc->opt, CMSG_DATA(cmsg),
 					     err < 40 ? err : 40);
 			if (err)
 				return err;
@@ -529,6 +529,8 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 {
 	struct inet_sock *inet = inet_sk(sk);
 	int val = 0, err;
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
+	struct net *net = sk_ctx.net;
 
 	switch (optname) {
 	case IP_PKTINFO:
@@ -580,7 +582,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 
 		if (optlen > 40)
 			goto e_inval;
-		err = ip_options_get_from_user(sock_net(sk), &opt,
+		err = ip_options_get_from_user(&sk_ctx, &opt,
 					       optval, optlen);
 		if (err)
 			break;
@@ -736,7 +738,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			break;
 		}
 
-		dev = dev_get_by_index(sock_net(sk), ifindex);
+		dev = dev_get_by_index(net, ifindex);
 		err = -EADDRNOTAVAIL;
 		if (!dev)
 			break;
@@ -782,13 +784,15 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		}
 
 		if (!mreq.imr_ifindex) {
+			struct net_ctx net_ctx = SOCK_NET_CTX(sk);
+
 			if (mreq.imr_address.s_addr == htonl(INADDR_ANY)) {
 				inet->mc_index = 0;
 				inet->mc_addr  = 0;
 				err = 0;
 				break;
 			}
-			dev = ip_dev_find(sock_net(sk), mreq.imr_address.s_addr);
+			dev = ip_dev_find(&net_ctx, mreq.imr_address.s_addr);
 			if (dev)
 				mreq.imr_ifindex = dev->ifindex;
 		} else
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index b26376ef87f6..e25e3b67be76 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -329,11 +329,12 @@ set_sockaddr(struct sockaddr_in *sin, __be32 addr, __be16 port)
 
 static int __init ic_devinet_ioctl(unsigned int cmd, struct ifreq *arg)
 {
+	struct net_ctx ctx = { .net = &init_net };
 	int res;
 
 	mm_segment_t oldfs = get_fs();
 	set_fs(get_ds());
-	res = devinet_ioctl(&init_net, cmd, (struct ifreq __user *) arg);
+	res = devinet_ioctl(&ctx, cmd, (struct ifreq __user *) arg);
 	set_fs(oldfs);
 	return res;
 }
@@ -351,11 +352,12 @@ static int __init ic_dev_ioctl(unsigned int cmd, struct ifreq *arg)
 
 static int __init ic_route_ioctl(unsigned int cmd, struct rtentry *arg)
 {
+	struct net_ctx ctx = { .net = &init_net };
 	int res;
 
 	mm_segment_t oldfs = get_fs();
 	set_fs(get_ds());
-	res = ip_rt_ioctl(&init_net, cmd, (void __user *) arg);
+	res = ip_rt_ioctl(&ctx, cmd, (void __user *) arg);
 	set_fs(oldfs);
 	return res;
 }
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9d78427652d2..935f45f54862 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -127,7 +127,7 @@ static struct kmem_cache *mrt_cachep __read_mostly;
 static struct mr_table *ipmr_new_table(struct net *net, u32 id);
 static void ipmr_free_table(struct mr_table *mrt);
 
-static void ip_mr_forward(struct net *net, struct mr_table *mrt,
+static void ip_mr_forward(struct net_ctx *ctx, struct mr_table *mrt,
 			  struct sk_buff *skb, struct mfc_cache *cache,
 			  int local);
 static int ipmr_cache_report(struct mr_table *mrt,
@@ -244,11 +244,12 @@ static const struct fib_rules_ops __net_initconst ipmr_rules_ops_template = {
 
 static int __net_init ipmr_rules_init(struct net *net)
 {
+	struct net_ctx ctx = { .net = net };
 	struct fib_rules_ops *ops;
 	struct mr_table *mrt;
 	int err;
 
-	ops = fib_rules_register(&ipmr_rules_ops_template, net);
+	ops = fib_rules_register(&ipmr_rules_ops_template, &ctx);
 	if (IS_ERR(ops))
 		return PTR_ERR(ops);
 
@@ -710,9 +711,10 @@ static void ipmr_update_thresholds(struct mr_table *mrt, struct mfc_cache *cache
 	}
 }
 
-static int vif_add(struct net *net, struct mr_table *mrt,
+static int vif_add(struct net_ctx *ctx, struct mr_table *mrt,
 		   struct vifctl *vifc, int mrtsock)
 {
+	struct net *net = ctx->net;
 	int vifi = vifc->vifc_vifi;
 	struct vif_device *v = &mrt->vif_table[vifi];
 	struct net_device *dev;
@@ -764,7 +766,7 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 				return -EADDRNOTAVAIL;
 			}
 		} else {
-			dev = ip_dev_find(net, vifc->vifc_lcl_addr.s_addr);
+			dev = ip_dev_find(ctx, vifc->vifc_lcl_addr.s_addr);
 		}
 		if (!dev)
 			return -EADDRNOTAVAIL;
@@ -903,7 +905,7 @@ static struct mfc_cache *ipmr_cache_alloc_unres(void)
  *	A cache entry has gone into a resolved state from queued
  */
 
-static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
+static void ipmr_cache_resolve(struct net_ctx *ctx, struct mr_table *mrt,
 			       struct mfc_cache *uc, struct mfc_cache *c)
 {
 	struct sk_buff *skb;
@@ -927,9 +929,9 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 				memset(&e->msg, 0, sizeof(e->msg));
 			}
 
-			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
+			rtnl_unicast(skb, ctx->net, NETLINK_CB(skb).portid);
 		} else {
-			ip_mr_forward(net, mrt, skb, c, 0);
+			ip_mr_forward(ctx, mrt, skb, c, 0);
 		}
 	}
 }
@@ -1121,7 +1123,7 @@ static int ipmr_mfc_delete(struct mr_table *mrt, struct mfcctl *mfc, int parent)
 	return -ENOENT;
 }
 
-static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
+static int ipmr_mfc_add(struct net_ctx *ctx, struct mr_table *mrt,
 			struct mfcctl *mfc, int mrtsock, int parent)
 {
 	bool found = false;
@@ -1190,7 +1192,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 	spin_unlock_bh(&mfc_unres_lock);
 
 	if (found) {
-		ipmr_cache_resolve(net, mrt, uc, c);
+		ipmr_cache_resolve(ctx, mrt, uc, c);
 		ipmr_cache_free(uc);
 	}
 	mroute_netlink_event(mrt, c, RTM_NEWROUTE);
@@ -1272,7 +1274,8 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 	int ret, parent = 0;
 	struct vifctl vif;
 	struct mfcctl mfc;
-	struct net *net = sock_net(sk);
+	struct net_ctx ctx = SOCK_NET_CTX(sk);
+	struct net *net = ctx.net;
 	struct mr_table *mrt;
 
 	if (sk->sk_type != SOCK_RAW ||
@@ -1324,7 +1327,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 			return -ENFILE;
 		rtnl_lock();
 		if (optname == MRT_ADD_VIF) {
-			ret = vif_add(net, mrt, &vif,
+			ret = vif_add(&ctx, mrt, &vif,
 				      sk == rtnl_dereference(mrt->mroute_sk));
 		} else {
 			ret = vif_delete(mrt, vif.vifc_vifi, 0, NULL);
@@ -1351,7 +1354,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		if (optname == MRT_DEL_MFC || optname == MRT_DEL_MFC_PROXY)
 			ret = ipmr_mfc_delete(mrt, &mfc, parent);
 		else
-			ret = ipmr_mfc_add(net, mrt, &mfc,
+			ret = ipmr_mfc_add(&ctx, mrt, &mfc,
 					   sk == rtnl_dereference(mrt->mroute_sk),
 					   parent);
 		rtnl_unlock();
@@ -1687,7 +1690,7 @@ static inline int ipmr_forward_finish(struct sk_buff *skb)
  *	Processing handlers for ipmr_forward
  */
 
-static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
+static void ipmr_queue_xmit(struct net_ctx *ctx, struct mr_table *mrt,
 			    struct sk_buff *skb, struct mfc_cache *c, int vifi)
 {
 	const struct iphdr *iph = ip_hdr(skb);
@@ -1712,7 +1715,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 #endif
 
 	if (vif->flags & VIFF_TUNNEL) {
-		rt = ip_route_output_ports(net, &fl4, NULL,
+		rt = ip_route_output_ports(ctx, &fl4, NULL,
 					   vif->remote, vif->local,
 					   0, 0,
 					   IPPROTO_IPIP,
@@ -1721,7 +1724,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 			goto out_free;
 		encap = sizeof(struct iphdr);
 	} else {
-		rt = ip_route_output_ports(net, &fl4, NULL, iph->daddr, 0,
+		rt = ip_route_output_ports(ctx, &fl4, NULL, iph->daddr, 0,
 					   0, 0,
 					   IPPROTO_IPIP,
 					   RT_TOS(iph->tos), vif->link);
@@ -1800,7 +1803,7 @@ static int ipmr_find_vif(struct mr_table *mrt, struct net_device *dev)
 
 /* "local" means that we should preserve one skb (for local delivery) */
 
-static void ip_mr_forward(struct net *net, struct mr_table *mrt,
+static void ip_mr_forward(struct net_ctx *ctx, struct mr_table *mrt,
 			  struct sk_buff *skb, struct mfc_cache *cache,
 			  int local)
 {
@@ -1893,7 +1896,7 @@ static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
 				if (skb2)
-					ipmr_queue_xmit(net, mrt, skb2, cache,
+					ipmr_queue_xmit(ctx, mrt, skb2, cache,
 							psend);
 			}
 			psend = ct;
@@ -1905,9 +1908,9 @@ static void ip_mr_forward(struct net *net, struct mr_table *mrt,
 			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
 			if (skb2)
-				ipmr_queue_xmit(net, mrt, skb2, cache, psend);
+				ipmr_queue_xmit(ctx, mrt, skb2, cache, psend);
 		} else {
-			ipmr_queue_xmit(net, mrt, skb, cache, psend);
+			ipmr_queue_xmit(ctx, mrt, skb, cache, psend);
 			return;
 		}
 	}
@@ -1949,7 +1952,8 @@ static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
 int ip_mr_input(struct sk_buff *skb)
 {
 	struct mfc_cache *cache;
-	struct net *net = dev_net(skb->dev);
+	struct net_ctx dev_ctx = SKB_NET_CTX_DEV(skb);
+	struct net *net = dev_ctx.net;
 	int local = skb_rtable(skb)->rt_flags & RTCF_LOCAL;
 	struct mr_table *mrt;
 
@@ -2024,7 +2028,7 @@ int ip_mr_input(struct sk_buff *skb)
 	}
 
 	read_lock(&mrt_lock);
-	ip_mr_forward(net, mrt, skb, cache, local);
+	ip_mr_forward(&dev_ctx, mrt, skb, cache, local);
 	read_unlock(&mrt_lock);
 
 	if (local)
@@ -2046,6 +2050,7 @@ static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
 {
 	struct net_device *reg_dev = NULL;
 	struct iphdr *encap;
+	struct net_ctx dev_ctx;
 
 	encap = (struct iphdr *)(skb_transport_header(skb) + pimlen);
 	/*
@@ -2073,7 +2078,8 @@ static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
 	skb->protocol = htons(ETH_P_IP);
 	skb->ip_summed = CHECKSUM_NONE;
 
-	skb_tunnel_rx(skb, reg_dev, dev_net(reg_dev));
+	dev_ctx.net = dev_net(reg_dev);
+	skb_tunnel_rx(skb, reg_dev, &dev_ctx);
 
 	netif_rx(skb);
 
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 7ebd6e37875c..a10ab84b69d8 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -19,7 +19,7 @@
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
 int ip_route_me_harder(struct sk_buff *skb, unsigned int addr_type)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct net_ctx ctx = SKB_NET_CTX_DST(skb);
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 	struct flowi4 fl4 = {};
@@ -28,7 +28,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned int addr_type)
 	unsigned int hh_len;
 
 	if (addr_type == RTN_UNSPEC)
-		addr_type = inet_addr_type(net, saddr);
+		addr_type = inet_addr_type(&ctx, saddr);
 	if (addr_type == RTN_LOCAL || addr_type == RTN_UNICAST)
 		flags |= FLOWI_FLAG_ANYSRC;
 	else
@@ -43,7 +43,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned int addr_type)
 	fl4.flowi4_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
 	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_flags = flags;
-	rt = ip_route_output_key(net, &fl4);
+	rt = ip_route_output_key(&ctx, &fl4);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 
@@ -59,7 +59,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned int addr_type)
 	    xfrm_decode_session(skb, flowi4_to_flowi(&fl4), AF_INET) == 0) {
 		struct dst_entry *dst = skb_dst(skb);
 		skb_dst_set(skb, NULL);
-		dst = xfrm_lookup(net, dst, flowi4_to_flowi(&fl4), skb->sk, 0);
+		dst = xfrm_lookup(&ctx, dst, flowi4_to_flowi(&fl4), skb->sk, 0);
 		if (IS_ERR(dst))
 			return PTR_ERR(dst);
 		skb_dst_set(skb, dst);
@@ -173,10 +173,10 @@ static __sum16 nf_ip_checksum_partial(struct sk_buff *skb, unsigned int hook,
 	return csum;
 }
 
-static int nf_ip_route(struct net *net, struct dst_entry **dst,
+static int nf_ip_route(struct net_ctx *ctx, struct dst_entry **dst,
 		       struct flowi *fl, bool strict __always_unused)
 {
-	struct rtable *rt = ip_route_output_key(net, &fl->u.ip4);
+	struct rtable *rt = ip_route_output_key(ctx, &fl->u.ip4);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 	*dst = &rt->dst;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 2a3720fb5a5f..bca4f27502b0 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -167,9 +167,9 @@ void ping_unhash(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(ping_unhash);
 
-static struct sock *ping_lookup(struct net *net, struct sk_buff *skb, u16 ident)
+static struct sock *ping_lookup(struct net_ctx *ctx, struct sk_buff *skb, u16 ident)
 {
-	struct hlist_nulls_head *hslot = ping_hashslot(&ping_table, net, ident);
+	struct hlist_nulls_head *hslot = ping_hashslot(&ping_table, ctx->net, ident);
 	struct sock *sk = NULL;
 	struct inet_sock *isk;
 	struct hlist_nulls_node *hnode;
@@ -297,7 +297,7 @@ EXPORT_SYMBOL_GPL(ping_close);
 /* Checks the bind address and possibly modifies sk->sk_bound_dev_if. */
 static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
 				struct sockaddr *uaddr, int addr_len) {
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 	if (sk->sk_family == AF_INET) {
 		struct sockaddr_in *addr = (struct sockaddr_in *) uaddr;
 		int chk_addr_ret;
@@ -308,12 +308,12 @@ static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
 		pr_debug("ping_check_bind_addr(sk=%p,addr=%pI4,port=%d)\n",
 			 sk, &addr->sin_addr.s_addr, ntohs(addr->sin_port));
 
-		chk_addr_ret = inet_addr_type(net, addr->sin_addr.s_addr);
+		chk_addr_ret = inet_addr_type(&sk_ctx, addr->sin_addr.s_addr);
 
 		if (addr->sin_addr.s_addr == htonl(INADDR_ANY))
 			chk_addr_ret = RTN_LOCAL;
 
-		if ((net->ipv4.sysctl_ip_nonlocal_bind == 0 &&
+		if ((sk_ctx.net->ipv4.sysctl_ip_nonlocal_bind == 0 &&
 		    isk->freebind == 0 && isk->transparent == 0 &&
 		     chk_addr_ret != RTN_LOCAL) ||
 		    chk_addr_ret == RTN_MULTICAST ||
@@ -344,13 +344,13 @@ static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
 
 		rcu_read_lock();
 		if (addr->sin6_scope_id) {
-			dev = dev_get_by_index_rcu(net, addr->sin6_scope_id);
+			dev = dev_get_by_index_rcu_ctx(&sk_ctx, addr->sin6_scope_id);
 			if (!dev) {
 				rcu_read_unlock();
 				return -ENODEV;
 			}
 		}
-		has_addr = pingv6_ops.ipv6_chk_addr(net, &addr->sin6_addr, dev,
+		has_addr = pingv6_ops.ipv6_chk_addr(&sk_ctx, &addr->sin6_addr, dev,
 						    scoped);
 		rcu_read_unlock();
 
@@ -479,7 +479,7 @@ void ping_err(struct sk_buff *skb, int offset, u32 info)
 	struct inet_sock *inet_sock;
 	int type;
 	int code;
-	struct net *net = dev_net(skb->dev);
+	struct net_ctx dev_ctx = SKB_NET_CTX_DEV(skb);
 	struct sock *sk;
 	int harderr;
 	int err;
@@ -507,7 +507,7 @@ void ping_err(struct sk_buff *skb, int offset, u32 info)
 		 skb->protocol, type, code, ntohs(icmph->un.echo.id),
 		 ntohs(icmph->un.echo.sequence));
 
-	sk = ping_lookup(net, skb, ntohs(icmph->un.echo.id));
+	sk = ping_lookup(&dev_ctx, skb, ntohs(icmph->un.echo.id));
 	if (sk == NULL) {
 		pr_debug("no socket, dropping\n");
 		return;	/* No socket for error */
@@ -687,7 +687,8 @@ EXPORT_SYMBOL_GPL(ping_common_sendmsg);
 static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			   size_t len)
 {
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
+	struct net *net = sk_ctx.net;
 	struct flowi4 fl4;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipcm_cookie ipc;
@@ -736,7 +737,7 @@ static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	sock_tx_timestamp(sk, &ipc.tx_flags);
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sock_net(sk), msg, &ipc, false);
+		err = ip_cmsg_send(&sk_ctx, msg, &ipc, false);
 		if (err)
 			return err;
 		if (ipc.opt)
@@ -783,7 +784,7 @@ static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 			   inet_sk_flowi_flags(sk), faddr, saddr, 0, 0);
 
 	security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
-	rt = ip_route_output_flow(net, &fl4, sk);
+	rt = ip_route_output_flow(&sk_ctx, &fl4, sk);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		rt = NULL;
@@ -829,7 +830,7 @@ static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	if (free)
 		kfree(ipc.opt);
 	if (!err) {
-		icmp_out_count(sock_net(sk), user_icmph.type);
+		icmp_out_count(net, user_icmph.type);
 		return len;
 	}
 	return err;
@@ -953,7 +954,7 @@ EXPORT_SYMBOL_GPL(ping_queue_rcv_skb);
 bool ping_rcv(struct sk_buff *skb)
 {
 	struct sock *sk;
-	struct net *net = dev_net(skb->dev);
+	struct net_ctx dev_ctx = SKB_NET_CTX_DEV(skb);
 	struct icmphdr *icmph = icmp_hdr(skb);
 
 	/* We assume the packet has already been checked by icmp_rcv */
@@ -964,7 +965,7 @@ bool ping_rcv(struct sk_buff *skb)
 	/* Push ICMP header back */
 	skb_push(skb, skb->data - (u8 *)icmph);
 
-	sk = ping_lookup(net, skb, ntohs(icmph->un.echo.id));
+	sk = ping_lookup(&dev_ctx, skb, ntohs(icmph->un.echo.id));
 	if (sk != NULL) {
 		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
@@ -1007,7 +1008,7 @@ static struct sock *ping_get_first(struct seq_file *seq, int start)
 {
 	struct sock *sk;
 	struct ping_iter_state *state = seq->private;
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 
 	for (state->bucket = start; state->bucket < PING_HTABLE_SIZE;
 	     ++state->bucket) {
@@ -1020,7 +1021,7 @@ static struct sock *ping_get_first(struct seq_file *seq, int start)
 			continue;
 
 		sk_nulls_for_each(sk, node, hslot) {
-			if (net_eq(sock_net(sk), net) &&
+			if (sock_net_ctx_eq(sk, ctx) &&
 			    sk->sk_family == state->family)
 				goto found;
 		}
@@ -1033,11 +1034,11 @@ static struct sock *ping_get_first(struct seq_file *seq, int start)
 static struct sock *ping_get_next(struct seq_file *seq, struct sock *sk)
 {
 	struct ping_iter_state *state = seq->private;
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 
 	do {
 		sk = sk_nulls_next(sk);
-	} while (sk && (!net_eq(sock_net(sk), net)));
+	} while (sk && !sock_net_ctx_eq(sk, ctx));
 
 	if (!sk)
 		return ping_get_first(seq, state->bucket + 1);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 0bb68df5055d..c06dd58e538b 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -119,13 +119,13 @@ void raw_unhash_sk(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(raw_unhash_sk);
 
-static struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
+static struct sock *__raw_v4_lookup(struct net_ctx *ctx, struct sock *sk,
 		unsigned short num, __be32 raddr, __be32 laddr, int dif)
 {
 	sk_for_each_from(sk) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		if (net_eq(sock_net(sk), net) && inet->inet_num == num	&&
+		if (sock_net_ctx_eq(sk, ctx) && inet->inet_num == num &&
 		    !(inet->inet_daddr && inet->inet_daddr != raddr) 	&&
 		    !(inet->inet_rcv_saddr && inet->inet_rcv_saddr != laddr) &&
 		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
@@ -171,15 +171,14 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 	struct sock *sk;
 	struct hlist_head *head;
 	int delivered = 0;
-	struct net *net;
+	struct net_ctx ctx = SKB_NET_CTX_DEV(skb);
 
 	read_lock(&raw_v4_hashinfo.lock);
 	head = &raw_v4_hashinfo.ht[hash];
 	if (hlist_empty(head))
 		goto out;
 
-	net = dev_net(skb->dev);
-	sk = __raw_v4_lookup(net, __sk_head(head), iph->protocol,
+	sk = __raw_v4_lookup(&ctx, __sk_head(head), iph->protocol,
 			     iph->saddr, iph->daddr,
 			     skb->dev->ifindex);
 
@@ -194,7 +193,7 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 			if (clone)
 				raw_rcv(sk, clone);
 		}
-		sk = __raw_v4_lookup(net, sk_next(sk), iph->protocol,
+		sk = __raw_v4_lookup(&ctx, sk_next(sk), iph->protocol,
 				     iph->saddr, iph->daddr,
 				     skb->dev->ifindex);
 	}
@@ -287,7 +286,7 @@ void raw_icmp_error(struct sk_buff *skb, int protocol, u32 info)
 	int hash;
 	struct sock *raw_sk;
 	const struct iphdr *iph;
-	struct net *net;
+	struct net_ctx ctx = SKB_NET_CTX_DEV(skb);
 
 	hash = protocol & (RAW_HTABLE_SIZE - 1);
 
@@ -295,9 +294,8 @@ void raw_icmp_error(struct sk_buff *skb, int protocol, u32 info)
 	raw_sk = sk_head(&raw_v4_hashinfo.ht[hash]);
 	if (raw_sk != NULL) {
 		iph = (const struct iphdr *)skb->data;
-		net = dev_net(skb->dev);
 
-		while ((raw_sk = __raw_v4_lookup(net, raw_sk, protocol,
+		while ((raw_sk = __raw_v4_lookup(&ctx, raw_sk, protocol,
 						iph->daddr, iph->saddr,
 						skb->dev->ifindex)) != NULL) {
 			raw_err(raw_sk, skb, info);
@@ -494,6 +492,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	u8  tos;
 	int err;
 	struct ip_options_data opt_copy;
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 	struct raw_frag_vec rfv;
 
 	err = -EMSGSIZE;
@@ -544,7 +543,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sock_net(sk), msg, &ipc, false);
+		err = ip_cmsg_send(&sk_ctx, msg, &ipc, false);
 		if (err)
 			goto out;
 		if (ipc.opt)
@@ -609,7 +608,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	}
 
 	security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
-	rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
+	rt = ip_route_output_flow(&sk_ctx, &fl4, sk);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		rt = NULL;
@@ -689,10 +688,11 @@ static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	struct sockaddr_in *addr = (struct sockaddr_in *) uaddr;
 	int ret = -EINVAL;
 	int chk_addr_ret;
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	if (sk->sk_state != TCP_CLOSE || addr_len < sizeof(struct sockaddr_in))
 		goto out;
-	chk_addr_ret = inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);
+	chk_addr_ret = inet_addr_type(&sk_ctx, addr->sin_addr.s_addr);
 	ret = -EADDRNOTAVAIL;
 	if (addr->sin_addr.s_addr && chk_addr_ret != RTN_LOCAL &&
 	    chk_addr_ret != RTN_MULTICAST && chk_addr_ret != RTN_BROADCAST)
@@ -938,11 +938,12 @@ static struct sock *raw_get_first(struct seq_file *seq)
 {
 	struct sock *sk;
 	struct raw_iter_state *state = raw_seq_private(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 
 	for (state->bucket = 0; state->bucket < RAW_HTABLE_SIZE;
 			++state->bucket) {
 		sk_for_each(sk, &state->h->ht[state->bucket])
-			if (sock_net(sk) == seq_file_net(seq))
+			if (sock_net_ctx_eq(sk, ctx))
 				goto found;
 	}
 	sk = NULL;
@@ -953,12 +954,13 @@ static struct sock *raw_get_first(struct seq_file *seq)
 static struct sock *raw_get_next(struct seq_file *seq, struct sock *sk)
 {
 	struct raw_iter_state *state = raw_seq_private(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 
 	do {
 		sk = sk_next(sk);
 try_again:
 		;
-	} while (sk && sock_net(sk) != seq_file_net(seq));
+	} while (sk && !sock_net_ctx_eq(sk, ctx));
 
 	if (!sk && ++state->bucket < RAW_HTABLE_SIZE) {
 		sk = sk_head(&state->h->ht[state->bucket]);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0c63b2abd873..018e292ff145 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -428,7 +428,9 @@ static inline int ip_rt_proc_init(void)
 
 static inline bool rt_is_expired(const struct rtable *rth)
 {
-	return rth->rt_genid != rt_genid_ipv4(dev_net(rth->dst.dev));
+	struct net_ctx dev_ctx = DEV_NET_CTX(rth->dst.dev);
+
+	return rth->rt_genid != rt_genid_ipv4(&dev_ctx);
 }
 
 void rt_cache_flush(struct net *net)
@@ -625,6 +627,7 @@ static void update_or_create_fnhe(struct fib_nh *nh, __be32 daddr, __be32 gw,
 	unsigned int i;
 	int depth;
 	u32 hval = fnhe_hashfun(daddr);
+	struct net_ctx dev_ctx = DEV_NET_CTX(nh->nh_dev);
 
 	spin_lock_bh(&fnhe_lock);
 
@@ -671,7 +674,7 @@ static void update_or_create_fnhe(struct fib_nh *nh, __be32 daddr, __be32 gw,
 			fnhe->fnhe_next = hash->chain;
 			rcu_assign_pointer(hash->chain, fnhe);
 		}
-		fnhe->fnhe_genid = fnhe_genid(dev_net(nh->nh_dev));
+		fnhe->fnhe_genid = fnhe_genid(&dev_ctx);
 		fnhe->fnhe_daddr = daddr;
 		fnhe->fnhe_gw = gw;
 		fnhe->fnhe_pmtu = pmtu;
@@ -709,7 +712,7 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 	struct in_device *in_dev;
 	struct fib_result res;
 	struct neighbour *n;
-	struct net *net;
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 
 	switch (icmp_hdr(skb)->code & 7) {
 	case ICMP_REDIR_NET:
@@ -729,7 +732,6 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 	if (!in_dev)
 		return;
 
-	net = dev_net(dev);
 	if (new_gw == old_gw || !IN_DEV_RX_REDIRECTS(in_dev) ||
 	    ipv4_is_multicast(new_gw) || ipv4_is_lbcast(new_gw) ||
 	    ipv4_is_zeronet(new_gw))
@@ -741,7 +743,7 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 		if (IN_DEV_SEC_REDIRECTS(in_dev) && ip_fib_check_default(new_gw, dev))
 			goto reject_redirect;
 	} else {
-		if (inet_addr_type(net, new_gw) != RTN_UNICAST)
+		if (inet_addr_type(&dev_ctx, new_gw) != RTN_UNICAST)
 			goto reject_redirect;
 	}
 
@@ -750,7 +752,7 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 		if (!(n->nud_state & NUD_VALID)) {
 			neigh_event_send(n, NULL);
 		} else {
-			if (fib_lookup(net, fl4, &res) == 0) {
+			if (fib_lookup(&dev_ctx, fl4, &res) == 0) {
 				struct fib_nh *nh = &FIB_RES_NH(res);
 
 				update_or_create_fnhe(nh, fl4->daddr, new_gw,
@@ -959,6 +961,7 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 {
 	struct dst_entry *dst = &rt->dst;
 	struct fib_result res;
+	struct net_ctx dev_ctx = DEV_NET_CTX(dst->dev);
 
 	if (dst_metric_locked(dst, RTAX_MTU))
 		return;
@@ -974,7 +977,7 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 		return;
 
 	rcu_read_lock();
-	if (fib_lookup(dev_net(dst->dev), fl4, &res) == 0) {
+	if (fib_lookup(&dev_ctx, fl4, &res) == 0) {
 		struct fib_nh *nh = &FIB_RES_NH(res);
 
 		update_or_create_fnhe(nh, fl4->daddr, 0, mtu,
@@ -993,7 +996,7 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 	__ip_rt_update_pmtu(rt, &fl4, mtu);
 }
 
-void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
+void ipv4_update_pmtu(struct sk_buff *skb, struct net_ctx *ctx, u32 mtu,
 		      int oif, u32 mark, u8 protocol, int flow_flags)
 {
 	const struct iphdr *iph = (const struct iphdr *) skb->data;
@@ -1001,11 +1004,11 @@ void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
 	struct rtable *rt;
 
 	if (!mark)
-		mark = IP4_REPLY_MARK(net, skb->mark);
+		mark = IP4_REPLY_MARK(ctx->net, skb->mark);
 
 	__build_flow_key(&fl4, NULL, iph, oif,
 			 RT_TOS(iph->tos), protocol, mark, flow_flags);
-	rt = __ip_route_output_key(net, &fl4);
+	rt = __ip_route_output_key(ctx, &fl4);
 	if (!IS_ERR(rt)) {
 		__ip_rt_update_pmtu(rt, &fl4, mtu);
 		ip_rt_put(rt);
@@ -1018,13 +1021,14 @@ static void __ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	const struct iphdr *iph = (const struct iphdr *) skb->data;
 	struct flowi4 fl4;
 	struct rtable *rt;
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
 
 	if (!fl4.flowi4_mark)
-		fl4.flowi4_mark = IP4_REPLY_MARK(sock_net(sk), skb->mark);
+		fl4.flowi4_mark = IP4_REPLY_MARK(sk_ctx.net, skb->mark);
 
-	rt = __ip_route_output_key(sock_net(sk), &fl4);
+	rt = __ip_route_output_key(&sk_ctx, &fl4);
 	if (!IS_ERR(rt)) {
 		__ip_rt_update_pmtu(rt, &fl4, mtu);
 		ip_rt_put(rt);
@@ -1038,6 +1042,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	struct rtable *rt;
 	struct dst_entry *odst = NULL;
 	bool new = false;
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	bh_lock_sock(sk);
 
@@ -1055,7 +1060,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 
 	rt = (struct rtable *)odst;
 	if (odst->obsolete && odst->ops->check(odst, 0) == NULL) {
-		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
+		rt = ip_route_output_flow(&sk_ctx, &fl4, sk);
 		if (IS_ERR(rt))
 			goto out;
 
@@ -1068,7 +1073,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 		if (new)
 			dst_release(&rt->dst);
 
-		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
+		rt = ip_route_output_flow(&sk_ctx, &fl4, sk);
 		if (IS_ERR(rt))
 			goto out;
 
@@ -1084,7 +1089,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 }
 EXPORT_SYMBOL_GPL(ipv4_sk_update_pmtu);
 
-void ipv4_redirect(struct sk_buff *skb, struct net *net,
+void ipv4_redirect(struct sk_buff *skb, struct net_ctx *ctx,
 		   int oif, u32 mark, u8 protocol, int flow_flags)
 {
 	const struct iphdr *iph = (const struct iphdr *) skb->data;
@@ -1093,7 +1098,7 @@ void ipv4_redirect(struct sk_buff *skb, struct net *net,
 
 	__build_flow_key(&fl4, NULL, iph, oif,
 			 RT_TOS(iph->tos), protocol, mark, flow_flags);
-	rt = __ip_route_output_key(net, &fl4);
+	rt = __ip_route_output_key(ctx, &fl4);
 	if (!IS_ERR(rt)) {
 		__ip_do_redirect(rt, skb, &fl4, false);
 		ip_rt_put(rt);
@@ -1106,9 +1111,10 @@ void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk)
 	const struct iphdr *iph = (const struct iphdr *) skb->data;
 	struct flowi4 fl4;
 	struct rtable *rt;
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
-	rt = __ip_route_output_key(sock_net(sk), &fl4);
+	rt = __ip_route_output_key(&sk_ctx, &fl4);
 	if (!IS_ERR(rt)) {
 		__ip_do_redirect(rt, skb, &fl4, false);
 		ip_rt_put(rt);
@@ -1173,6 +1179,7 @@ void ip_rt_get_source(u8 *addr, struct sk_buff *skb, struct rtable *rt)
 		struct fib_result res;
 		struct flowi4 fl4;
 		struct iphdr *iph;
+		struct net_ctx dev_ctx = DEV_NET_CTX(rt->dst.dev);
 
 		iph = ip_hdr(skb);
 
@@ -1185,8 +1192,8 @@ void ip_rt_get_source(u8 *addr, struct sk_buff *skb, struct rtable *rt)
 		fl4.flowi4_mark = skb->mark;
 
 		rcu_read_lock();
-		if (fib_lookup(dev_net(rt->dst.dev), &fl4, &res) == 0)
-			src = FIB_RES_PREFSRC(dev_net(rt->dst.dev), res);
+		if (fib_lookup(&dev_ctx, &fl4, &res) == 0)
+			src = FIB_RES_PREFSRC(&dev_ctx, res);
 		else
 			src = inet_select_addr(rt->dst.dev,
 					       rt_nexthop(rt, iph->daddr),
@@ -1269,7 +1276,8 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 	if (daddr == fnhe->fnhe_daddr) {
 		struct rtable __rcu **porig;
 		struct rtable *orig;
-		int genid = fnhe_genid(dev_net(rt->dst.dev));
+		struct net_ctx dev_ctx = DEV_NET_CTX(rt->dst.dev);
+		int genid = fnhe_genid(&dev_ctx);
 
 		if (rt_is_input_route(rt))
 			porig = &fnhe->fnhe_rth_input;
@@ -1443,6 +1451,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 {
 	struct rtable *rth;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
 	u32 itag = 0;
 	int err;
 
@@ -1478,7 +1487,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 #endif
 	rth->dst.output = ip_rt_bug;
 
-	rth->rt_genid	= rt_genid_ipv4(dev_net(dev));
+	rth->rt_genid	= rt_genid_ipv4(&dev_ctx);
 	rth->rt_flags	= RTCF_MULTICAST;
 	rth->rt_type	= RTN_MULTICAST;
 	rth->rt_is_input= 1;
@@ -1548,6 +1557,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	unsigned int flags = 0;
 	bool do_cache;
 	u32 itag = 0;
+	struct net_ctx dev_ctx;
 
 	/* get a working reference to the output device */
 	out_dev = __in_dev_get_rcu(FIB_RES_DEV(*res));
@@ -1608,7 +1618,8 @@ static int __mkroute_input(struct sk_buff *skb,
 		goto cleanup;
 	}
 
-	rth->rt_genid = rt_genid_ipv4(dev_net(rth->dst.dev));
+	dev_ctx.net = dev_net(rth->dst.dev);
+	rth->rt_genid = rt_genid_ipv4(&dev_ctx);
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
 	rth->rt_is_input = 1;
@@ -1666,7 +1677,8 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	u32		itag = 0;
 	struct rtable	*rth;
 	int		err = -EINVAL;
-	struct net    *net = dev_net(dev);
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev);
+	struct net *net = dev_ctx.net;
 	bool do_cache;
 
 	/* IP on this device is disabled. */
@@ -1715,7 +1727,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
-	err = fib_lookup(net, &fl4, &res);
+	err = fib_lookup(&dev_ctx, &fl4, &res);
 	if (err != 0) {
 		if (!IN_DEV_FORWARD(in_dev))
 			err = -EHOSTUNREACH;
@@ -1782,7 +1794,7 @@ out:	return err;
 	rth->dst.tclassid = itag;
 #endif
 
-	rth->rt_genid = rt_genid_ipv4(net);
+	rth->rt_genid = rt_genid_ipv4(&dev_ctx);
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	rth->rt_type	= res.type;
 	rth->rt_is_input = 1;
@@ -1897,6 +1909,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	u16 type = res->type;
 	struct rtable *rth;
 	bool do_cache;
+	struct net_ctx dev_ctx = DEV_NET_CTX(dev_out);
 
 	in_dev = __in_dev_get_rcu(dev_out);
 	if (!in_dev)
@@ -1971,7 +1984,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	rth->dst.output = ip_output;
 
-	rth->rt_genid = rt_genid_ipv4(dev_net(dev_out));
+	rth->rt_genid = rt_genid_ipv4(&dev_ctx);
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
 	rth->rt_is_input = 0;
@@ -2011,8 +2024,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
  * Major route resolver routine.
  */
 
-struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
+struct rtable *__ip_route_output_key(struct net_ctx *ctx, struct flowi4 *fl4)
 {
+	struct net *net = ctx->net;
 	struct net_device *dev_out = NULL;
 	__u8 tos = RT_FL_TOS(fl4);
 	unsigned int flags = 0;
@@ -2051,7 +2065,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		    (ipv4_is_multicast(fl4->daddr) ||
 		     ipv4_is_lbcast(fl4->daddr))) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-			dev_out = __ip_dev_find(net, fl4->saddr, false);
+			dev_out = __ip_dev_find(ctx, fl4->saddr, false);
 			if (dev_out == NULL)
 				goto out;
 
@@ -2076,14 +2090,14 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 
 		if (!(fl4->flowi4_flags & FLOWI_FLAG_ANYSRC)) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-			if (!__ip_dev_find(net, fl4->saddr, false))
+			if (!__ip_dev_find(ctx, fl4->saddr, false))
 				goto out;
 		}
 	}
 
 
 	if (fl4->flowi4_oif) {
-		dev_out = dev_get_by_index_rcu(net, fl4->flowi4_oif);
+		dev_out = dev_get_by_index_rcu_ctx(ctx, fl4->flowi4_oif);
 		rth = ERR_PTR(-ENODEV);
 		if (dev_out == NULL)
 			goto out;
@@ -2121,7 +2135,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		goto make_route;
 	}
 
-	if (fib_lookup(net, fl4, &res)) {
+	if (fib_lookup(ctx, fl4, &res)) {
 		res.fi = NULL;
 		res.table = NULL;
 		if (fl4->flowi4_oif) {
@@ -2177,7 +2191,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		fib_select_default(&res);
 
 	if (!fl4->saddr)
-		fl4->saddr = FIB_RES_PREFSRC(net, res);
+		fl4->saddr = FIB_RES_PREFSRC(ctx, res);
 
 	dev_out = FIB_RES_DEV(res);
 	fl4->flowi4_oif = dev_out->ifindex;
@@ -2232,7 +2246,7 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 	.neigh_lookup		=	ipv4_neigh_lookup,
 };
 
-struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig)
+struct dst_entry *ipv4_blackhole_route(struct net_ctx *net_ctx, struct dst_entry *dst_orig)
 {
 	struct rtable *ort = (struct rtable *) dst_orig;
 	struct rtable *rt;
@@ -2253,7 +2267,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_pmtu = ort->rt_pmtu;
 
-		rt->rt_genid = rt_genid_ipv4(net);
+		rt->rt_genid = rt_genid_ipv4(net_ctx);
 		rt->rt_flags = ort->rt_flags;
 		rt->rt_type = ort->rt_type;
 		rt->rt_gateway = ort->rt_gateway;
@@ -2269,16 +2283,16 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 	return rt ? &rt->dst : ERR_PTR(-ENOMEM);
 }
 
-struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
+struct rtable *ip_route_output_flow(struct net_ctx *ctx, struct flowi4 *flp4,
 				    struct sock *sk)
 {
-	struct rtable *rt = __ip_route_output_key(net, flp4);
+	struct rtable *rt = __ip_route_output_key(ctx, flp4);
 
 	if (IS_ERR(rt))
 		return rt;
 
 	if (flp4->flowi4_proto)
-		rt = (struct rtable *)xfrm_lookup_route(net, &rt->dst,
+		rt = (struct rtable *)xfrm_lookup_route(ctx, &rt->dst,
 							flowi4_to_flowi(flp4),
 							sk, 0);
 
@@ -2286,7 +2300,7 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 }
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
-static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
+static int rt_fill_info(struct net_ctx *ctx,  __be32 dst, __be32 src,
 			struct flowi4 *fl4, struct sk_buff *skb, u32 portid,
 			u32 seq, int event, int nowait, unsigned int flags)
 {
@@ -2367,8 +2381,8 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 	if (rt_is_input_route(rt)) {
 #ifdef CONFIG_IP_MROUTE
 		if (ipv4_is_multicast(dst) && !ipv4_is_local_multicast(dst) &&
-		    IPV4_DEVCONF_ALL(net, MC_FORWARDING)) {
-			int err = ipmr_get_route(net, skb,
+		    IPV4_DEVCONF_ALL(ctx->net, MC_FORWARDING)) {
+			int err = ipmr_get_route(ctx->net, skb,
 						 fl4->saddr, fl4->daddr,
 						 r, nowait);
 			if (err <= 0) {
@@ -2401,7 +2415,7 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 
 static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 {
-	struct net *net = sock_net(in_skb->sk);
+	struct net_ctx sk_ctx = SKB_NET_CTX_SOCK(in_skb);
 	struct rtmsg *rtm;
 	struct nlattr *tb[RTA_MAX+1];
 	struct rtable *rt = NULL;
@@ -2450,7 +2464,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	if (iif) {
 		struct net_device *dev;
 
-		dev = __dev_get_by_index(net, iif);
+		dev = __dev_get_by_index_ctx(&sk_ctx, iif);
 		if (dev == NULL) {
 			err = -ENODEV;
 			goto errout_free;
@@ -2467,7 +2481,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		if (err == 0 && rt->dst.error)
 			err = -rt->dst.error;
 	} else {
-		rt = ip_route_output_key(net, &fl4);
+		rt = ip_route_output_key(&sk_ctx, &fl4);
 
 		err = 0;
 		if (IS_ERR(rt))
@@ -2481,13 +2495,13 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	err = rt_fill_info(net, dst, src, &fl4, skb,
+	err = rt_fill_info(&sk_ctx, dst, src, &fl4, skb,
 			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
 			   RTM_NEWROUTE, 0, 0);
 	if (err < 0)
 		goto errout_free;
 
-	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
+	err = rtnl_unicast(skb, sk_ctx.net, NETLINK_CB(in_skb).portid);
 errout:
 	return err;
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 45fe60c5238e..14b7a772c7a9 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -302,6 +302,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	struct rtable *rt;
 	__u8 rcv_wscale;
 	struct flowi4 fl4;
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
@@ -372,7 +373,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 			   opt->srr ? opt->faddr : ireq->ir_rmt_addr,
 			   ireq->ir_loc_addr, th->source, th->dest);
 	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
-	rt = ip_route_output_key(sock_net(sk), &fl4);
+	rt = ip_route_output_key(&sk_ctx, &fl4);
 	if (IS_ERR(rt)) {
 		reqsk_free(req);
 		goto out;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ad3e65bdd368..ceb5616a4273 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -341,9 +341,10 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	__u32 seq, snd_una;
 	__u32 remaining;
 	int err;
-	struct net *net = dev_net(icmp_skb->dev);
+	struct net_ctx dev_ctx = SKB_NET_CTX_DEV(icmp_skb);
+	struct net *net = dev_ctx.net;
 
-	sk = inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
+	sk = inet_lookup(&dev_ctx, &tcp_hashinfo, iph->daddr, th->dest,
 			iph->saddr, th->source, inet_iif(icmp_skb));
 	if (!sk) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
@@ -592,7 +593,8 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	int genhash;
 	struct sock *sk1 = NULL;
 #endif
-	struct net *net;
+	struct net_ctx ctx = SKB_NET_CTX_DST(skb);
+	struct net *net = ctx.net;
 
 	/* Never send a reset in response to a reset. */
 	if (th->rst)
@@ -634,7 +636,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 		 * Incoming packet is checked with md5 hash with finding key,
 		 * no RST generated if md5 hash doesn't match.
 		 */
-		sk1 = __inet_lookup_listener(net,
+		sk1 = __inet_lookup_listener(&ctx,
 					     &tcp_hashinfo, ip_hdr(skb)->saddr,
 					     th->source, ip_hdr(skb)->daddr,
 					     ntohs(th->source), inet_iif(skb));
@@ -683,7 +685,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 		arg.bound_dev_if = sk->sk_bound_dev_if;
 
 	arg.tos = ip_hdr(skb)->tos;
-	ip_send_unicast_reply(net, skb, &TCP_SKB_CB(skb)->header.h4.opt,
+	ip_send_unicast_reply(&ctx, skb, &TCP_SKB_CB(skb)->header.h4.opt,
 			      ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
 			      &arg, arg.iov[0].iov_len);
 
@@ -718,7 +720,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 			];
 	} rep;
 	struct ip_reply_arg arg;
-	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct net_ctx dev_ctx = SKB_NET_CTX_DST(skb);
 
 	memset(&rep.th, 0, sizeof(struct tcphdr));
 	memset(&arg, 0, sizeof(arg));
@@ -767,11 +769,11 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 	if (oif)
 		arg.bound_dev_if = oif;
 	arg.tos = tos;
-	ip_send_unicast_reply(net, skb, &TCP_SKB_CB(skb)->header.h4.opt,
+	ip_send_unicast_reply(&dev_ctx, skb, &TCP_SKB_CB(skb)->header.h4.opt,
 			      ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
 			      &arg, arg.iov[0].iov_len);
 
-	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
+	TCP_INC_STATS_BH(dev_ctx.net, TCP_MIB_OUTSEGS);
 }
 
 static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
@@ -1393,13 +1395,14 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct sock *nsk;
 	struct request_sock **prev;
+	struct net_ctx ctx = { .net = sock_net(sk) };
 	/* Find possible connection requests. */
 	struct request_sock *req = inet_csk_search_req(sk, &prev, th->source,
 						       iph->saddr, iph->daddr);
 	if (req)
 		return tcp_check_req(sk, skb, req, prev, false);
 
-	nsk = inet_lookup_established(sock_net(sk), &tcp_hashinfo, iph->saddr,
+	nsk = inet_lookup_established(&ctx, &tcp_hashinfo, iph->saddr,
 			th->source, iph->daddr, th->dest, inet_iif(skb));
 
 	if (nsk) {
@@ -1495,6 +1498,7 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 	const struct iphdr *iph;
 	const struct tcphdr *th;
 	struct sock *sk;
+	struct net_ctx dev_ctx = DEV_NET_CTX(skb->dev);
 
 	if (skb->pkt_type != PACKET_HOST)
 		return;
@@ -1508,7 +1512,7 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 	if (th->doff < sizeof(struct tcphdr) / 4)
 		return;
 
-	sk = __inet_lookup_established(dev_net(skb->dev), &tcp_hashinfo,
+	sk = __inet_lookup_established(&dev_ctx, &tcp_hashinfo,
 				       iph->saddr, th->source,
 				       iph->daddr, ntohs(th->dest),
 				       skb->skb_iif);
@@ -1592,7 +1596,8 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	const struct tcphdr *th;
 	struct sock *sk;
 	int ret;
-	struct net *net = dev_net(skb->dev);
+	struct net_ctx dev_ctx = SKB_NET_CTX_DEV(skb);
+	struct net *net = dev_ctx.net;
 
 	if (skb->pkt_type != PACKET_HOST)
 		goto discard_it;
@@ -1726,7 +1731,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	}
 	switch (tcp_timewait_state_process(inet_twsk(sk), skb, th)) {
 	case TCP_TW_SYN: {
-		struct sock *sk2 = inet_lookup_listener(dev_net(skb->dev),
+		struct sock *sk2 = inet_lookup_listener(&dev_ctx,
 							&tcp_hashinfo,
 							iph->saddr, th->source,
 							iph->daddr, th->dest,
@@ -1869,7 +1874,7 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 	struct sock *sk = cur;
 	struct inet_listen_hashbucket *ilb;
 	struct tcp_iter_state *st = seq->private;
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 
 	if (!sk) {
 		ilb = &tcp_hashinfo.listening_hash[st->bucket];
@@ -1913,7 +1918,7 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 	}
 get_sk:
 	sk_nulls_for_each_from(sk, node) {
-		if (!net_eq(sock_net(sk), net))
+		if (!sock_net_ctx_eq(sk, ctx))
 			continue;
 		if (sk->sk_family == st->family) {
 			cur = sk;
@@ -1972,7 +1977,7 @@ static inline bool empty_bucket(const struct tcp_iter_state *st)
 static void *established_get_first(struct seq_file *seq)
 {
 	struct tcp_iter_state *st = seq->private;
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 	void *rc = NULL;
 
 	st->offset = 0;
@@ -1988,7 +1993,7 @@ static void *established_get_first(struct seq_file *seq)
 		spin_lock_bh(lock);
 		sk_nulls_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
 			if (sk->sk_family != st->family ||
-			    !net_eq(sock_net(sk), net)) {
+			    !sock_net_ctx_eq(sk, ctx)) {
 				continue;
 			}
 			rc = sk;
@@ -2005,7 +2010,7 @@ static void *established_get_next(struct seq_file *seq, void *cur)
 	struct sock *sk = cur;
 	struct hlist_nulls_node *node;
 	struct tcp_iter_state *st = seq->private;
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 
 	++st->num;
 	++st->offset;
@@ -2013,7 +2018,7 @@ static void *established_get_next(struct seq_file *seq, void *cur)
 	sk = sk_nulls_next(sk);
 
 	sk_nulls_for_each_from(sk, node) {
-		if (sk->sk_family == st->family && net_eq(sock_net(sk), net))
+		if (sk->sk_family == st->family && sock_net_ctx_eq(sk, ctx))
 			return sk;
 	}
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 97ef1f8b7be8..1787dc8e5db3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -132,7 +132,7 @@ EXPORT_SYMBOL(udp_memory_allocated);
 #define MAX_UDP_PORTS 65536
 #define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
 
-static int udp_lib_lport_inuse(struct net *net, __u16 num,
+static int udp_lib_lport_inuse(struct net_ctx *ctx, __u16 num,
 			       const struct udp_hslot *hslot,
 			       unsigned long *bitmap,
 			       struct sock *sk,
@@ -145,7 +145,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 	kuid_t uid = sock_i_uid(sk);
 
 	sk_nulls_for_each(sk2, node, &hslot->head) {
-		if (net_eq(sock_net(sk2), net) &&
+		if (sock_net_ctx_eq(sk2, ctx) &&
 		    sk2 != sk &&
 		    (bitmap || udp_sk(sk2)->udp_port_hash == num) &&
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
@@ -166,7 +166,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
  * Note: we still hold spinlock of primary hash chain, so no other writer
  * can insert/delete a socket with local_port == num
  */
-static int udp_lib_lport_inuse2(struct net *net, __u16 num,
+static int udp_lib_lport_inuse2(struct net_ctx *ctx, __u16 num,
 				struct udp_hslot *hslot2,
 				struct sock *sk,
 				int (*saddr_comp)(const struct sock *sk1,
@@ -179,7 +179,7 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 
 	spin_lock(&hslot2->lock);
 	udp_portaddr_for_each_entry(sk2, node, &hslot2->head) {
-		if (net_eq(sock_net(sk2), net) &&
+		if (sock_net_ctx_eq(sk2, ctx) &&
 		    sk2 != sk &&
 		    (udp_sk(sk2)->udp_port_hash == num) &&
 		    (!sk2->sk_reuse || !sk->sk_reuse) &&
@@ -213,7 +213,8 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 	struct udp_hslot *hslot, *hslot2;
 	struct udp_table *udptable = sk->sk_prot->h.udp_table;
 	int    error = 1;
-	struct net *net = sock_net(sk);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
+	struct net *net = sk_ctx.net;
 
 	if (!snum) {
 		int low, high, remaining;
@@ -235,7 +236,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 			hslot = udp_hashslot(udptable, net, first);
 			bitmap_zero(bitmap, PORTS_PER_CHAIN);
 			spin_lock_bh(&hslot->lock);
-			udp_lib_lport_inuse(net, snum, hslot, bitmap, sk,
+			udp_lib_lport_inuse(&sk_ctx, snum, hslot, bitmap, sk,
 					    saddr_comp, udptable->log);
 
 			snum = first;
@@ -268,11 +269,11 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 			if (hslot->count < hslot2->count)
 				goto scan_primary_hash;
 
-			exist = udp_lib_lport_inuse2(net, snum, hslot2,
+			exist = udp_lib_lport_inuse2(&sk_ctx, snum, hslot2,
 						     sk, saddr_comp);
 			if (!exist && (hash2_nulladdr != slot2)) {
 				hslot2 = udp_hashslot2(udptable, hash2_nulladdr);
-				exist = udp_lib_lport_inuse2(net, snum, hslot2,
+				exist = udp_lib_lport_inuse2(&sk_ctx, snum, hslot2,
 							     sk, saddr_comp);
 			}
 			if (exist)
@@ -281,7 +282,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 				goto found;
 		}
 scan_primary_hash:
-		if (udp_lib_lport_inuse(net, snum, hslot, NULL, sk,
+		if (udp_lib_lport_inuse(&sk_ctx, snum, hslot, NULL, sk,
 					saddr_comp, 0))
 			goto fail_unlock;
 	}
@@ -336,14 +337,14 @@ int udp_v4_get_port(struct sock *sk, unsigned short snum)
 	return udp_lib_get_port(sk, snum, ipv4_rcv_saddr_equal, hash2_nulladdr);
 }
 
-static inline int compute_score(struct sock *sk, struct net *net,
+static inline int compute_score(struct sock *sk, struct net_ctx *ctx,
 				__be32 saddr, unsigned short hnum, __be16 sport,
 				__be32 daddr, __be16 dport, int dif)
 {
 	int score;
 	struct inet_sock *inet;
 
-	if (!net_eq(sock_net(sk), net) ||
+	if (!sock_net_ctx_eq(sk, ctx) ||
 	    udp_sk(sk)->udp_port_hash != hnum ||
 	    ipv6_only_sock(sk))
 		return -1;
@@ -381,14 +382,14 @@ static inline int compute_score(struct sock *sk, struct net *net,
 /*
  * In this second variant, we check (daddr, dport) matches (inet_rcv_sadd, inet_num)
  */
-static inline int compute_score2(struct sock *sk, struct net *net,
+static inline int compute_score2(struct sock *sk, struct net_ctx *ctx,
 				 __be32 saddr, __be16 sport,
 				 __be32 daddr, unsigned int hnum, int dif)
 {
 	int score;
 	struct inet_sock *inet;
 
-	if (!net_eq(sock_net(sk), net) ||
+	if (!sock_net_ctx_eq(sk, ctx) ||
 	    ipv6_only_sock(sk))
 		return -1;
 
@@ -435,11 +436,12 @@ static unsigned int udp_ehashfn(struct net *net, const __be32 laddr,
 
 
 /* called with read_rcu_lock() */
-static struct sock *udp4_lib_lookup2(struct net *net,
+static struct sock *udp4_lib_lookup2(struct net_ctx *ctx,
 		__be32 saddr, __be16 sport,
 		__be32 daddr, unsigned int hnum, int dif,
 		struct udp_hslot *hslot2, unsigned int slot2)
 {
+	struct net *net = ctx->net;
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
 	int score, badness, matches = 0, reuseport = 0;
@@ -449,7 +451,7 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 	result = NULL;
 	badness = 0;
 	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
-		score = compute_score2(sk, net, saddr, sport,
+		score = compute_score2(sk, ctx, saddr, sport,
 				      daddr, hnum, dif);
 		if (score > badness) {
 			result = sk;
@@ -477,7 +479,7 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 	if (result) {
 		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
-		else if (unlikely(compute_score2(result, net, saddr, sport,
+		else if (unlikely(compute_score2(result, ctx, saddr, sport,
 				  daddr, hnum, dif) < badness)) {
 			sock_put(result);
 			goto begin;
@@ -489,10 +491,11 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
  * harder than this. -DaveM
  */
-struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
+struct sock *__udp4_lib_lookup(struct net_ctx *ctx, __be32 saddr,
 		__be16 sport, __be32 daddr, __be16 dport,
 		int dif, struct udp_table *udptable)
 {
+	struct net *net = ctx->net;
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
 	unsigned short hnum = ntohs(dport);
@@ -509,7 +512,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 		if (hslot->count < hslot2->count)
 			goto begin;
 
-		result = udp4_lib_lookup2(net, saddr, sport,
+		result = udp4_lib_lookup2(ctx, saddr, sport,
 					  daddr, hnum, dif,
 					  hslot2, slot2);
 		if (!result) {
@@ -519,7 +522,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 			if (hslot->count < hslot2->count)
 				goto begin;
 
-			result = udp4_lib_lookup2(net, saddr, sport,
+			result = udp4_lib_lookup2(ctx, saddr, sport,
 						  htonl(INADDR_ANY), hnum, dif,
 						  hslot2, slot2);
 		}
@@ -530,7 +533,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	result = NULL;
 	badness = 0;
 	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
-		score = compute_score(sk, net, saddr, hnum, sport,
+		score = compute_score(sk, ctx, saddr, hnum, sport,
 				      daddr, dport, dif);
 		if (score > badness) {
 			result = sk;
@@ -559,7 +562,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	if (result) {
 		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
-		else if (unlikely(compute_score(result, net, saddr, hnum, sport,
+		else if (unlikely(compute_score(result, ctx, saddr, hnum, sport,
 				  daddr, dport, dif) < badness)) {
 			sock_put(result);
 			goto begin;
@@ -575,27 +578,28 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 						 struct udp_table *udptable)
 {
 	const struct iphdr *iph = ip_hdr(skb);
+	struct net_ctx dev_ctx = SKB_NET_CTX_DST(skb);
 
-	return __udp4_lib_lookup(dev_net(skb_dst(skb)->dev), iph->saddr, sport,
+	return __udp4_lib_lookup(&dev_ctx, iph->saddr, sport,
 				 iph->daddr, dport, inet_iif(skb),
 				 udptable);
 }
 
-struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
+struct sock *udp4_lib_lookup(struct net_ctx *ctx, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif)
 {
-	return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif, &udp_table);
+	return __udp4_lib_lookup(ctx, saddr, sport, daddr, dport, dif, &udp_table);
 }
 EXPORT_SYMBOL_GPL(udp4_lib_lookup);
 
-static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
+static inline bool __udp_is_mcast_sock(struct net_ctx *ctx, struct sock *sk,
 				       __be16 loc_port, __be32 loc_addr,
 				       __be16 rmt_port, __be32 rmt_addr,
 				       int dif, unsigned short hnum)
 {
 	struct inet_sock *inet = inet_sk(sk);
 
-	if (!net_eq(sock_net(sk), net) ||
+	if (!sock_net_ctx_eq(sk, ctx) ||
 	    udp_sk(sk)->udp_port_hash != hnum ||
 	    (inet->inet_daddr && inet->inet_daddr != rmt_addr) ||
 	    (inet->inet_dport != rmt_port && inet->inet_dport) ||
@@ -629,10 +633,12 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 	struct sock *sk;
 	int harderr;
 	int err;
-	struct net *net = dev_net(skb->dev);
+	struct net_ctx dev_ctx = SKB_NET_CTX_DEV(skb);
+	struct net *net = dev_ctx.net;
 
-	sk = __udp4_lib_lookup(net, iph->daddr, uh->dest,
+	sk = __udp4_lib_lookup(&dev_ctx, iph->daddr, uh->dest,
 			iph->saddr, uh->source, skb->dev->ifindex, udptable);
+
 	if (sk == NULL) {
 		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
 		return;	/* No socket for error */
@@ -893,6 +899,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
 	struct sk_buff *skb;
 	struct ip_options_data opt_copy;
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
 	if (len > 0xFFFF)
 		return -EMSGSIZE;
@@ -962,7 +969,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	sock_tx_timestamp(sk, &ipc.tx_flags);
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sock_net(sk), msg, &ipc,
+		err = ip_cmsg_send(&sk_ctx, msg, &ipc,
 				   sk->sk_family == AF_INET6);
 		if (err)
 			return err;
@@ -1013,7 +1020,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		rt = (struct rtable *)sk_dst_check(sk, 0);
 
 	if (rt == NULL) {
-		struct net *net = sock_net(sk);
+		struct net *net = sk_ctx.net;
 
 		fl4 = &fl4_stack;
 		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
@@ -1022,7 +1029,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				   faddr, saddr, dport, inet->inet_sport);
 
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
-		rt = ip_route_output_flow(net, fl4, sk);
+		rt = ip_route_output_flow(&sk_ctx, fl4, sk);
 		if (IS_ERR(rt)) {
 			err = PTR_ERR(rt);
 			rt = NULL;
@@ -1657,12 +1664,13 @@ static void udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
  *
  *	Note: called only from the BH handler context.
  */
-static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
+static int __udp4_lib_mcast_deliver(struct net_ctx *ctx, struct sk_buff *skb,
 				    struct udphdr  *uh,
 				    __be32 saddr, __be32 daddr,
 				    struct udp_table *udptable,
 				    int proto)
 {
+	struct net *net = ctx->net;
 	struct sock *sk, *stack[256 / sizeof(struct sock *)];
 	struct hlist_nulls_node *node;
 	unsigned short hnum = ntohs(uh->dest);
@@ -1683,7 +1691,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 
 	spin_lock(&hslot->lock);
 	sk_nulls_for_each_entry_offset(sk, node, &hslot->head, offset) {
-		if (__udp_is_mcast_sock(net, sk,
+		if (__udp_is_mcast_sock(ctx, sk,
 					uh->dest, daddr,
 					uh->source, saddr,
 					dif, hnum)) {
@@ -1754,7 +1762,8 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	unsigned short ulen;
 	struct rtable *rt = skb_rtable(skb);
 	__be32 saddr, daddr;
-	struct net *net = dev_net(skb->dev);
+	struct net_ctx dev_ctx = SKB_NET_CTX_DEV(skb);
+	struct net *net = dev_ctx.net;
 
 	/*
 	 *  Validate the packet.
@@ -1799,7 +1808,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	}
 
 	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
-		return __udp4_lib_mcast_deliver(net, skb, uh,
+		return __udp4_lib_mcast_deliver(&dev_ctx, skb, uh,
 						saddr, daddr, udptable, proto);
 
 	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
@@ -1866,7 +1875,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 /* We can only early demux multicast if there is a single matching socket.
  * If more than one socket found returns NULL
  */
-static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
+static struct sock *__udp4_lib_mcast_demux_lookup(struct net_ctx *ctx,
 						  __be16 loc_port, __be32 loc_addr,
 						  __be16 rmt_port, __be32 rmt_addr,
 						  int dif)
@@ -1874,7 +1883,7 @@ static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
 	unsigned short hnum = ntohs(loc_port);
-	unsigned int count, slot = udp_hashfn(net, hnum, udp_table.mask);
+	unsigned int count, slot = udp_hashfn(ctx->net, hnum, udp_table.mask);
 	struct udp_hslot *hslot = &udp_table.hash[slot];
 
 	/* Do not bother scanning a too big list */
@@ -1886,7 +1895,7 @@ static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
 	count = 0;
 	result = NULL;
 	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
-		if (__udp_is_mcast_sock(net, sk,
+		if (__udp_is_mcast_sock(ctx, sk,
 					loc_port, loc_addr,
 					rmt_port, rmt_addr,
 					dif, hnum)) {
@@ -1906,7 +1915,7 @@ static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
 		if (count != 1 ||
 		    unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
-		else if (unlikely(!__udp_is_mcast_sock(net, result,
+		else if (unlikely(!__udp_is_mcast_sock(ctx, result,
 						       loc_port, loc_addr,
 						       rmt_port, rmt_addr,
 						       dif, hnum))) {
@@ -1922,7 +1931,7 @@ static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
  * break forwarding setups.  The chains here can be long so only check
  * if the first socket is an exact match and if not move on.
  */
-static struct sock *__udp4_lib_demux_lookup(struct net *net,
+static struct sock *__udp4_lib_demux_lookup(struct net_ctx *ctx,
 					    __be16 loc_port, __be32 loc_addr,
 					    __be16 rmt_port, __be32 rmt_addr,
 					    int dif)
@@ -1930,7 +1939,7 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
 	unsigned short hnum = ntohs(loc_port);
-	unsigned int hash2 = udp4_portaddr_hash(net, loc_addr, hnum);
+	unsigned int hash2 = udp4_portaddr_hash(ctx->net, loc_addr, hnum);
 	unsigned int slot2 = hash2 & udp_table.mask;
 	struct udp_hslot *hslot2 = &udp_table.hash2[slot2];
 	INET_ADDR_COOKIE(acookie, rmt_addr, loc_addr);
@@ -1939,7 +1948,7 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
 	rcu_read_lock();
 	result = NULL;
 	udp_portaddr_for_each_entry_rcu(sk, node, &hslot2->head) {
-		if (INET_MATCH(sk, net, acookie,
+		if (INET_MATCH(sk, ctx, acookie,
 			       rmt_addr, loc_addr, ports, dif))
 			result = sk;
 		/* Only check first socket in chain */
@@ -1949,7 +1958,7 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
 	if (result) {
 		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
-		else if (unlikely(!INET_MATCH(sk, net, acookie,
+		else if (unlikely(!INET_MATCH(sk, ctx, acookie,
 					      rmt_addr, loc_addr,
 					      ports, dif))) {
 			sock_put(result);
@@ -1962,7 +1971,7 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
 
 void udp_v4_early_demux(struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb->dev);
+	struct net_ctx dev_ctx = DEV_NET_CTX(skb->dev);
 	const struct iphdr *iph;
 	const struct udphdr *uh;
 	struct sock *sk;
@@ -1978,10 +1987,10 @@ void udp_v4_early_demux(struct sk_buff *skb)
 
 	if (skb->pkt_type == PACKET_BROADCAST ||
 	    skb->pkt_type == PACKET_MULTICAST)
-		sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
+		sk = __udp4_lib_mcast_demux_lookup(&dev_ctx, uh->dest, iph->daddr,
 						   uh->source, iph->saddr, dif);
 	else if (skb->pkt_type == PACKET_HOST)
-		sk = __udp4_lib_demux_lookup(net, uh->dest, iph->daddr,
+		sk = __udp4_lib_demux_lookup(&dev_ctx, uh->dest, iph->daddr,
 					     uh->source, iph->saddr, dif);
 	else
 		return;
@@ -2275,7 +2284,7 @@ static struct sock *udp_get_first(struct seq_file *seq, int start)
 {
 	struct sock *sk;
 	struct udp_iter_state *state = seq->private;
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 
 	for (state->bucket = start; state->bucket <= state->udp_table->mask;
 	     ++state->bucket) {
@@ -2287,7 +2296,7 @@ static struct sock *udp_get_first(struct seq_file *seq, int start)
 
 		spin_lock_bh(&hslot->lock);
 		sk_nulls_for_each(sk, node, &hslot->head) {
-			if (!net_eq(sock_net(sk), net))
+			if (!sock_net_ctx_eq(sk, ctx))
 				continue;
 			if (sk->sk_family == state->family)
 				goto found;
@@ -2302,11 +2311,11 @@ static struct sock *udp_get_first(struct seq_file *seq, int start)
 static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
 {
 	struct udp_iter_state *state = seq->private;
-	struct net *net = seq_file_net(seq);
+	struct net_ctx *ctx = seq_file_net_ctx(seq);
 
 	do {
 		sk = sk_nulls_next(sk);
-	} while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family != state->family));
+	} while (sk && (!sock_net_ctx_eq(sk, ctx) || sk->sk_family != state->family));
 
 	if (!sk) {
 		if (state->bucket <= state->udp_table->mask)
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 4a000f1dd757..e702a04d2682 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -36,16 +36,17 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 	int err = -EINVAL;
 	struct sock *sk;
 	struct sk_buff *rep;
-	struct net *net = sock_net(in_skb->sk);
+	struct net_ctx sk_ctx = SKB_NET_CTX_SOCK(in_skb);
+	struct net *net = sk_ctx.net;
 
 	if (req->sdiag_family == AF_INET)
-		sk = __udp4_lib_lookup(net,
+		sk = __udp4_lib_lookup(&sk_ctx,
 				req->id.idiag_src[0], req->id.idiag_sport,
 				req->id.idiag_dst[0], req->id.idiag_dport,
 				req->id.idiag_if, tbl);
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (req->sdiag_family == AF_INET6)
-		sk = __udp6_lib_lookup(net,
+		sk = __udp6_lib_lookup(&sk_ctx,
 				(struct in6_addr *)req->id.idiag_src,
 				req->id.idiag_sport,
 				(struct in6_addr *)req->id.idiag_dst,
@@ -94,7 +95,7 @@ static void udp_dump(struct udp_table *table, struct sk_buff *skb, struct netlin
 		struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	int num, s_num, slot, s_slot;
-	struct net *net = sock_net(skb->sk);
+	struct net_ctx sk_ctx = SKB_NET_CTX_SOCK(skb);
 
 	s_slot = cb->args[0];
 	num = s_num = cb->args[1];
@@ -113,7 +114,7 @@ static void udp_dump(struct udp_table *table, struct sk_buff *skb, struct netlin
 		sk_nulls_for_each(sk, node, &hslot->head) {
 			struct inet_sock *inet = inet_sk(sk);
 
-			if (!net_eq(sock_net(sk), net))
+			if (!sock_net_ctx_eq(sk, &sk_ctx))
 				continue;
 			if (num < s_num)
 				goto next;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 6156f68a1e90..c892b6bb0383 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -18,7 +18,7 @@
 
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
 
-static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
+static struct dst_entry *__xfrm4_dst_lookup(struct net_ctx *ctx, struct flowi4 *fl4,
 					    int tos,
 					    const xfrm_address_t *saddr,
 					    const xfrm_address_t *daddr)
@@ -31,29 +31,29 @@ static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
 	if (saddr)
 		fl4->saddr = saddr->a4;
 
-	rt = __ip_route_output_key(net, fl4);
+	rt = __ip_route_output_key(ctx, fl4);
 	if (!IS_ERR(rt))
 		return &rt->dst;
 
 	return ERR_CAST(rt);
 }
 
-static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
+static struct dst_entry *xfrm4_dst_lookup(struct net_ctx *ctx, int tos,
 					  const xfrm_address_t *saddr,
 					  const xfrm_address_t *daddr)
 {
 	struct flowi4 fl4;
 
-	return __xfrm4_dst_lookup(net, &fl4, tos, saddr, daddr);
+	return __xfrm4_dst_lookup(ctx, &fl4, tos, saddr, daddr);
 }
 
-static int xfrm4_get_saddr(struct net *net,
+static int xfrm4_get_saddr(struct net_ctx *ctx,
 			   xfrm_address_t *saddr, xfrm_address_t *daddr)
 {
 	struct dst_entry *dst;
 	struct flowi4 fl4;
 
-	dst = __xfrm4_dst_lookup(net, &fl4, 0, NULL, daddr);
+	dst = __xfrm4_dst_lookup(ctx, &fl4, 0, NULL, daddr);
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 8f34b27d5775..d59affad3f01 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -359,8 +359,8 @@ static int sctp_v4_addr_valid(union sctp_addr *addr,
 /* Should this be available for binding?   */
 static int sctp_v4_available(union sctp_addr *addr, struct sctp_sock *sp)
 {
-	struct net *net = sock_net(&sp->inet.sk);
-	int ret = inet_addr_type(net, addr->v4.sin_addr.s_addr);
+	struct net_ctx sk_ctx = SOCK_NET_CTX(&sp->inet.sk);
+	int ret = inet_addr_type(&sk_ctx, addr->v4.sin_addr.s_addr);
 
 
 	if (addr->v4.sin_addr.s_addr != htonl(INADDR_ANY) &&
@@ -421,6 +421,7 @@ static sctp_scope_t sctp_v4_scope(union sctp_addr *addr)
 static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 				struct flowi *fl, struct sock *sk)
 {
+	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 	struct sctp_association *asoc = t->asoc;
 	struct rtable *rt;
 	struct flowi4 *fl4 = &fl->u.ip4;
@@ -447,7 +448,7 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	pr_debug("%s: dst:%pI4, src:%pI4 - ", __func__, &fl4->daddr,
 		 &fl4->saddr);
 
-	rt = ip_route_output_key(sock_net(sk), fl4);
+	rt = ip_route_output_key(&sk_ctx, fl4);
 	if (!IS_ERR(rt))
 		dst = &rt->dst;
 
@@ -498,7 +499,7 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 					     daddr->v4.sin_addr.s_addr,
 					     laddr->a.v4.sin_addr.s_addr);
 
-			rt = ip_route_output_key(sock_net(sk), fl4);
+			rt = ip_route_output_key(&sk_ctx, fl4);
 			if (!IS_ERR(rt)) {
 				dst = &rt->dst;
 				goto out_unlock;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index cee479bc655c..9984dc89f2e4 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2184,7 +2184,7 @@ static struct dst_entry *make_blackhole(struct net *net, u16 family,
  * At the moment we eat a raw IP route. Mostly to speed up lookups
  * on interfaces with disabled IPsec.
  */
-struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
+struct dst_entry *xfrm_lookup(struct net_ctx *ctx, struct dst_entry *dst_orig,
 			      const struct flowi *fl,
 			      struct sock *sk, int flags)
 {
@@ -2244,7 +2244,7 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 		    !net->xfrm.policy_count[XFRM_POLICY_OUT])
 			goto nopol;
 
-		flo = flow_cache_lookup(net, fl, family, dir,
+		flo = flow_cache_lookup(ctx, fl, family, dir,
 					xfrm_bundle_lookup, &xflo);
 		if (flo == NULL)
 			goto nopol;
@@ -2443,7 +2443,8 @@ static inline int secpath_has_nontransport(const struct sec_path *sp, int k, int
 int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 			unsigned short family)
 {
-	struct net *net = dev_net(skb->dev);
+	struct net_ctx dev_ctx = SKB_NET_CTX_DEV(skb);
+	struct net *net = dev_ctx.net;
 	struct xfrm_policy *pol;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	int npols = 0;
@@ -2490,7 +2491,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	if (!pol) {
 		struct flow_cache_object *flo;
 
-		flo = flow_cache_lookup(net, &fl, family, fl_dir,
+		flo = flow_cache_lookup(&dev_ctx, &fl, family, fl_dir,
 					xfrm_policy_lookup, NULL);
 		if (IS_ERR_OR_NULL(flo))
 			pol = ERR_CAST(flo);
-- 
1.9.3 (Apple Git-50)
