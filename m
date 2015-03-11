From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 2/8] net: Introduce possible_net_t
Date: Wed, 11 Mar 2015 11:36:44 -0500
Message-ID: <87k2ynfq3n.fsf_-_@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com,
	Julian Anastasov <ja@ssi.bg>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40392 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbbCKQkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 12:40:25 -0400
In-Reply-To: <87vbi7fq92.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 11 Mar 2015 11:33:29 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Having to say
> #ifdef CONFIG_NET_NS
> 	struct net *net;
> #endif

in structures is a little bit wordy and a little bit error prone.

Instead it is possible to say:
> typedef struct {
> #ifdef CONFIG_NET_NS
>       struct net *net;
> #endif
> } possible_net_t;

And then in a header say:

> 	possible_net_t net;

Which is cleaner and easier to use and easier to test, as the
possible_net_t is always there no matter what the compile options.

Further this allows read_pnet and write_pnet to be functions in all
cases which is better at catching typos.

This change adds possible_net_t, updates the definitions of read_pnet
and write_pnet, updates optional struct net * variables that
write_pnet uses on to have the type possible_net_t, and finally fixes
up the b0rked users of read_pnet and write_pnet.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netdevice.h            |  8 ++------
 include/net/cfg80211.h               |  4 +---
 include/net/genetlink.h              |  4 +---
 include/net/inet_hashtables.h        |  4 +---
 include/net/ip_vs.h                  |  8 ++++----
 include/net/neighbour.h              |  8 ++------
 include/net/net_namespace.h          | 23 +++++++++++++----------
 include/net/netfilter/nf_conntrack.h |  5 ++---
 include/net/sock.h                   |  4 +---
 include/net/xfrm.h                   |  8 ++------
 net/9p/trans_fd.c                    |  4 ++--
 net/ipv4/ipmr.c                      |  4 +---
 net/ipv6/addrlabel.c                 |  8 ++------
 net/ipv6/ip6mr.c                     |  4 +---
 net/openvswitch/datapath.h           |  4 +---
 net/packet/internal.h                |  4 +---
 16 files changed, 37 insertions(+), 67 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b214ba2ebbce..d2a678f983c0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1720,9 +1720,7 @@ struct net_device {
 	struct netpoll_info __rcu	*npinfo;
 #endif
 
-#ifdef CONFIG_NET_NS
-	struct net		*nd_net;
-#endif
+	possible_net_t			nd_net;
 
 	/* mid-layer private */
 	union {
@@ -1862,9 +1860,7 @@ struct net *dev_net(const struct net_device *dev)
 static inline
 void dev_net_set(struct net_device *dev, struct net *net)
 {
-#ifdef CONFIG_NET_NS
-	dev->nd_net = net;
-#endif
+	write_pnet(&dev->nd_net, net);
 }
 
 static inline bool netdev_uses_dsa(struct net_device *dev)
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 64e09e1e8099..f977abec07f6 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -3183,10 +3183,8 @@ struct wiphy {
 	const struct ieee80211_ht_cap *ht_capa_mod_mask;
 	const struct ieee80211_vht_cap *vht_capa_mod_mask;
 
-#ifdef CONFIG_NET_NS
 	/* the network namespace this phy lives in currently */
-	struct net *_net;
-#endif
+	possible_net_t _net;
 
 #ifdef CONFIG_CFG80211_WEXT
 	const struct iw_handler_def *wext;
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 0574abd3db86..a9af1cc8c1bc 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -92,9 +92,7 @@ struct genl_info {
 	struct genlmsghdr *	genlhdr;
 	void *			userhdr;
 	struct nlattr **	attrs;
-#ifdef CONFIG_NET_NS
-	struct net *		_net;
-#endif
+	possible_net_t		_net;
 	void *			user_ptr[2];
 	struct sock *		dst_sk;
 };
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index dd1950a7e273..bcd64756e5fe 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -76,9 +76,7 @@ struct inet_ehash_bucket {
  * ports are created in O(1) time?  I thought so. ;-)	-DaveM
  */
 struct inet_bind_bucket {
-#ifdef CONFIG_NET_NS
-	struct net		*ib_net;
-#endif
+	possible_net_t		ib_net;
 	unsigned short		port;
 	signed char		fastreuse;
 	signed char		fastreuseport;
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 20fd23398537..4e3731ee4eac 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -47,13 +47,13 @@ static inline struct net *skb_net(const struct sk_buff *skb)
 	 * Start with the most likely hit
 	 * End with BUG
 	 */
-	if (likely(skb->dev && skb->dev->nd_net))
+	if (likely(skb->dev && dev_net(skb->dev)))
 		return dev_net(skb->dev);
 	if (skb_dst(skb) && skb_dst(skb)->dev)
 		return dev_net(skb_dst(skb)->dev);
 	WARN(skb->sk, "Maybe skb_sknet should be used in %s() at line:%d\n",
 		      __func__, __LINE__);
-	if (likely(skb->sk && skb->sk->sk_net))
+	if (likely(skb->sk && sock_net(skb->sk)))
 		return sock_net(skb->sk);
 	pr_err("There is no net ptr to find in the skb in %s() line:%d\n",
 		__func__, __LINE__);
@@ -71,11 +71,11 @@ static inline struct net *skb_sknet(const struct sk_buff *skb)
 #ifdef CONFIG_NET_NS
 #ifdef CONFIG_IP_VS_DEBUG
 	/* Start with the most likely hit */
-	if (likely(skb->sk && skb->sk->sk_net))
+	if (likely(skb->sk && sock_net(skb->sk)))
 		return sock_net(skb->sk);
 	WARN(skb->dev, "Maybe skb_net should be used instead in %s() line:%d\n",
 		       __func__, __LINE__);
-	if (likely(skb->dev && skb->dev->nd_net))
+	if (likely(skb->dev && dev_net(skb->dev)))
 		return dev_net(skb->dev);
 	pr_err("There is no net ptr to find in the skb in %s() line:%d\n",
 		__func__, __LINE__);
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index d48b8ec8b5f4..e7bdf5170802 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -65,9 +65,7 @@ enum {
 };
 
 struct neigh_parms {
-#ifdef CONFIG_NET_NS
-	struct net *net;
-#endif
+	possible_net_t net;
 	struct net_device *dev;
 	struct list_head list;
 	int	(*neigh_setup)(struct neighbour *);
@@ -167,9 +165,7 @@ struct neigh_ops {
 
 struct pneigh_entry {
 	struct pneigh_entry	*next;
-#ifdef CONFIG_NET_NS
-	struct net		*net;
-#endif
+	possible_net_t		net;
 	struct net_device	*dev;
 	u8			flags;
 	u8			key[0];
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 6fd76650d36f..c2bedcc3ab43 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -229,24 +229,27 @@ int net_eq(const struct net *net1, const struct net *net2)
 #endif
 
 
+typedef struct {
 #ifdef CONFIG_NET_NS
+	struct net *net;
+#endif
+} possible_net_t;
 
-static inline void write_pnet(struct net **pnet, struct net *net)
+static inline void write_pnet(possible_net_t *pnet, struct net *net)
 {
-	*pnet = net;
+#ifdef CONFIG_NET_NS
+	pnet->net = net;
+#endif
 }
 
-static inline struct net *read_pnet(struct net * const *pnet)
+static inline struct net *read_pnet(const possible_net_t *pnet)
 {
-	return *pnet;
-}
-
+#ifdef CONFIG_NET_NS
+	return pnet->net;
 #else
-
-#define write_pnet(pnet, net)	do { (void)(net);} while (0)
-#define read_pnet(pnet)		(&init_net)
-
+	return &init_net;
 #endif
+}
 
 #define for_each_net(VAR)				\
 	list_for_each_entry(VAR, &net_namespace_list, list)
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 74f271a172dd..095433b8a8b0 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -95,9 +95,8 @@ struct nf_conn {
 	/* Timer function; drops refcnt when it goes off. */
 	struct timer_list timeout;
 
-#ifdef CONFIG_NET_NS
-	struct net *ct_net;
-#endif
+	possible_net_t ct_net;
+
 	/* all members below initialized via memset */
 	u8 __nfct_init_offset[0];
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 40437e0a94a8..1d3bbd6bdc71 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -190,9 +190,7 @@ struct sock_common {
 		struct hlist_nulls_node skc_portaddr_node;
 	};
 	struct proto		*skc_prot;
-#ifdef CONFIG_NET_NS
-	struct net	 	*skc_net;
-#endif
+	possible_net_t		skc_net;
 
 #if IS_ENABLED(CONFIG_IPV6)
 	struct in6_addr		skc_v6_daddr;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index dc4865e90fe4..d0ac7d7be8a7 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -126,9 +126,7 @@ struct xfrm_state_walk {
 
 /* Full description of state of transformer. */
 struct xfrm_state {
-#ifdef CONFIG_NET_NS
-	struct net		*xs_net;
-#endif
+	possible_net_t		xs_net;
 	union {
 		struct hlist_node	gclist;
 		struct hlist_node	bydst;
@@ -522,9 +520,7 @@ struct xfrm_policy_queue {
 };
 
 struct xfrm_policy {
-#ifdef CONFIG_NET_NS
-	struct net		*xp_net;
-#endif
+	possible_net_t		xp_net;
 	struct hlist_node	bydst;
 	struct hlist_node	byidx;
 
diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index 80d08f6664cb..3e3d82d8ff70 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -940,7 +940,7 @@ p9_fd_create_tcp(struct p9_client *client, const char *addr, char *args)
 	sin_server.sin_family = AF_INET;
 	sin_server.sin_addr.s_addr = in_aton(addr);
 	sin_server.sin_port = htons(opts.port);
-	err = __sock_create(read_pnet(&current->nsproxy->net_ns), PF_INET,
+	err = __sock_create(current->nsproxy->net_ns, PF_INET,
 			    SOCK_STREAM, IPPROTO_TCP, &csocket, 1);
 	if (err) {
 		pr_err("%s (%d): problem creating socket\n",
@@ -988,7 +988,7 @@ p9_fd_create_unix(struct p9_client *client, const char *addr, char *args)
 
 	sun_server.sun_family = PF_UNIX;
 	strcpy(sun_server.sun_path, addr);
-	err = __sock_create(read_pnet(&current->nsproxy->net_ns), PF_UNIX,
+	err = __sock_create(current->nsproxy->net_ns, PF_UNIX,
 			    SOCK_STREAM, 0, &csocket, 1);
 	if (err < 0) {
 		pr_err("%s (%d): problem creating socket\n",
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 9d78427652d2..5b188832800f 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -73,9 +73,7 @@
 
 struct mr_table {
 	struct list_head	list;
-#ifdef CONFIG_NET_NS
-	struct net		*net;
-#endif
+	possible_net_t		net;
 	u32			id;
 	struct sock __rcu	*mroute_sk;
 	struct timer_list	ipmr_expire_timer;
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 59c793040498..3cc50e2d3bf5 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -29,9 +29,7 @@
  * Policy Table
  */
 struct ip6addrlbl_entry {
-#ifdef CONFIG_NET_NS
-	struct net *lbl_net;
-#endif
+	possible_net_t lbl_net;
 	struct in6_addr prefix;
 	int prefixlen;
 	int ifindex;
@@ -237,9 +235,7 @@ static struct ip6addrlbl_entry *ip6addrlbl_alloc(struct net *net,
 	newp->addrtype = addrtype;
 	newp->label = label;
 	INIT_HLIST_NODE(&newp->list);
-#ifdef CONFIG_NET_NS
-	newp->lbl_net = net;
-#endif
+	write_pnet(&newp->lbl_net, net);
 	atomic_set(&newp->refcnt, 1);
 	return newp;
 }
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 34b682617f50..4b9315aa273e 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -56,9 +56,7 @@
 
 struct mr6_table {
 	struct list_head	list;
-#ifdef CONFIG_NET_NS
-	struct net		*net;
-#endif
+	possible_net_t		net;
 	u32			id;
 	struct sock		*mroute6_sk;
 	struct timer_list	ipmr_expire_timer;
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 3ece94563079..4ec4a480b147 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -84,10 +84,8 @@ struct datapath {
 	/* Stats. */
 	struct dp_stats_percpu __percpu *stats_percpu;
 
-#ifdef CONFIG_NET_NS
 	/* Network namespace ref. */
-	struct net *net;
-#endif
+	possible_net_t net;
 
 	u32 user_features;
 };
diff --git a/net/packet/internal.h b/net/packet/internal.h
index cdddf6a30399..fe6e20caea1d 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -74,9 +74,7 @@ extern struct mutex fanout_mutex;
 #define PACKET_FANOUT_MAX	256
 
 struct packet_fanout {
-#ifdef CONFIG_NET_NS
-	struct net		*net;
-#endif
+	possible_net_t		net;
 	unsigned int		num_members;
 	u16			id;
 	u8			type;
-- 
2.2.1
