From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/5] [NET] NETNS: Omit sock->sk_net without CONFIG_NET_NS.
Date: Wed, 26 Mar 2008 08:44:29 +0900 (JST)
Message-ID: <20080326.084429.84212986.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, dlezcano@fr.ibm.com, brian.haley@hp.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55043 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754883AbYCYXnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 19:43:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce per-sock inlines: sock_net(), sock_net_set()
and per-inet_timewait_sock inlines: twsk_net(), twsk_net_set().
Without CONFIG_NET_NS, no namespace other than &init_net exists.
Let's explicitly define them to help compiler optimizations.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/ipv6.h             |    4 ++--
 include/net/inet_hashtables.h    |    8 ++++----
 include/net/inet_timewait_sock.h |   18 ++++++++++++++++++
 include/net/route.h              |    4 ++--
 include/net/sock.h               |   24 ++++++++++++++++++++++--
 net/atm/svc.c                    |    2 +-
 net/ax25/af_ax25.c               |    2 +-
 net/bluetooth/l2cap.c            |    2 +-
 net/bluetooth/rfcomm/sock.c      |    2 +-
 net/bluetooth/sco.c              |    2 +-
 net/bridge/br_netlink.c          |    4 ++--
 net/core/fib_rules.c             |    6 +++---
 net/core/neighbour.c             |   10 +++++-----
 net/core/rtnetlink.c             |   12 ++++++------
 net/core/sock.c                  |   10 +++++-----
 net/decnet/af_decnet.c           |    2 +-
 net/decnet/dn_dev.c              |    6 +++---
 net/decnet/dn_fib.c              |    4 ++--
 net/decnet/dn_route.c            |    4 ++--
 net/decnet/dn_table.c            |    2 +-
 net/ipv4/af_inet.c               |    6 +++---
 net/ipv4/devinet.c               |    6 +++---
 net/ipv4/fib_frontend.c          |    8 ++++----
 net/ipv4/fib_rules.c             |    2 +-
 net/ipv4/igmp.c                  |   14 +++++++-------
 net/ipv4/inet_connection_sock.c  |    4 ++--
 net/ipv4/inet_hashtables.c       |    8 ++++----
 net/ipv4/inet_timewait_sock.c    |    2 +-
 net/ipv4/ip_input.c              |    2 +-
 net/ipv4/ip_output.c             |    4 ++--
 net/ipv4/ip_sockglue.c           |    6 +++---
 net/ipv4/ipmr.c                  |    4 ++--
 net/ipv4/netfilter/arp_tables.c  |   16 ++++++++--------
 net/ipv4/netfilter/ip_tables.c   |   16 ++++++++--------
 net/ipv4/raw.c                   |   12 ++++++------
 net/ipv4/route.c                 |    4 ++--
 net/ipv4/tcp_ipv4.c              |   14 +++++++-------
 net/ipv4/udp.c                   |   16 ++++++++--------
 net/ipv6/addrconf.c              |   10 +++++-----
 net/ipv6/addrlabel.c             |    6 +++---
 net/ipv6/af_inet6.c              |    4 ++--
 net/ipv6/fib6_rules.c            |    2 +-
 net/ipv6/icmp.c                  |    2 +-
 net/ipv6/inet6_hashtables.c      |    4 ++--
 net/ipv6/ip6_fib.c               |    2 +-
 net/ipv6/ip6_output.c            |    2 +-
 net/ipv6/ipv6_sockglue.c         |    2 +-
 net/ipv6/mcast.c                 |   12 ++++++------
 net/ipv6/netfilter/ip6_tables.c  |   16 ++++++++--------
 net/ipv6/raw.c                   |    6 +++---
 net/ipv6/route.c                 |    4 ++--
 net/ipv6/tcp_ipv6.c              |    2 +-
 net/ipv6/udp.c                   |    4 ++--
 net/irda/af_irda.c               |    2 +-
 net/llc/llc_conn.c               |    2 +-
 net/netfilter/nf_sockopt.c       |    2 +-
 net/netlink/af_netlink.c         |   30 +++++++++++++++---------------
 net/netrom/af_netrom.c           |    2 +-
 net/packet/af_packet.c           |   28 ++++++++++++++--------------
 net/rose/af_rose.c               |    2 +-
 net/sched/act_api.c              |    4 ++--
 net/sched/cls_api.c              |    4 ++--
 net/sched/sch_api.c              |   10 +++++-----
 net/sctp/ipv6.c                  |    2 +-
 net/sctp/protocol.c              |    2 +-
 net/socket.c                     |    4 ++--
 net/tipc/socket.c                |    2 +-
 net/unix/af_unix.c               |   20 ++++++++++----------
 net/x25/af_x25.c                 |    2 +-
 69 files changed, 253 insertions(+), 215 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index c9ba0da..b90d3d4 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -481,7 +481,7 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 #endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 
 #define INET6_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif)\
-	(((__sk)->sk_hash == (__hash)) && ((__sk)->sk_net == (__net))	&& \
+	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&& \
 	 ((*((__portpair *)&(inet_sk(__sk)->dport))) == (__ports))  	&& \
 	 ((__sk)->sk_family		== AF_INET6)		&& \
 	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))	&& \
@@ -489,7 +489,7 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 
 #define INET6_TW_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif) \
-	(((__sk)->sk_hash == (__hash)) && ((__sk)->sk_net == (__net))	&& \
+	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&& \
 	 (*((__portpair *)&(inet_twsk(__sk)->tw_dport)) == (__ports))	&& \
 	 ((__sk)->sk_family	       == PF_INET6)			&& \
 	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_daddr, (__saddr)))	&& \
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index d99c1ba..5525227 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -314,25 +314,25 @@ typedef __u64 __bitwise __addrpair;
 				   ((__force __u64)(__be32)(__saddr)));
 #endif /* __BIG_ENDIAN */
 #define INET_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)\
-	(((__sk)->sk_hash == (__hash)) && ((__sk)->sk_net == (__net))	&&	\
+	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&&	\
 	 ((*((__addrpair *)&(inet_sk(__sk)->daddr))) == (__cookie))	&&	\
 	 ((*((__portpair *)&(inet_sk(__sk)->dport))) == (__ports))	&&	\
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 #define INET_TW_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)\
-	(((__sk)->sk_hash == (__hash)) && ((__sk)->sk_net == (__net))	&&	\
+	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&&	\
 	 ((*((__addrpair *)&(inet_twsk(__sk)->tw_daddr))) == (__cookie)) &&	\
 	 ((*((__portpair *)&(inet_twsk(__sk)->tw_dport))) == (__ports)) &&	\
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 #else /* 32-bit arch */
 #define INET_ADDR_COOKIE(__name, __saddr, __daddr)
 #define INET_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)	\
-	(((__sk)->sk_hash == (__hash)) && ((__sk)->sk_net == (__net))	&&	\
+	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&&	\
 	 (inet_sk(__sk)->daddr		== (__saddr))		&&	\
 	 (inet_sk(__sk)->rcv_saddr	== (__daddr))		&&	\
 	 ((*((__portpair *)&(inet_sk(__sk)->dport))) == (__ports))	&&	\
 	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
 #define INET_TW_MATCH(__sk, __net, __hash,__cookie, __saddr, __daddr, __ports, __dif)	\
-	(((__sk)->sk_hash == (__hash)) && ((__sk)->sk_net == (__net))	&&	\
+	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&&	\
 	 (inet_twsk(__sk)->tw_daddr	== (__saddr))		&&	\
 	 (inet_twsk(__sk)->tw_rcv_saddr	== (__daddr))		&&	\
 	 ((*((__portpair *)&(inet_twsk(__sk)->tw_dport))) == (__ports)) &&	\
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 296547b..07fe0d1 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -207,4 +207,22 @@ extern void inet_twsk_schedule(struct inet_timewait_sock *tw,
 			       const int timeo, const int timewait_len);
 extern void inet_twsk_deschedule(struct inet_timewait_sock *tw,
 				 struct inet_timewait_death_row *twdr);
+
+static inline
+struct net *twsk_net(const struct inet_timewait_sock *twsk)
+{
+#ifdef CONFIG_NET_NS
+	return twsk->tw_net;
+#else
+	return &init_net;
+#endif
+}
+
+static inline
+void twsk_net_set(struct inet_timewait_sock *twsk, const struct net *net)
+{
+#ifdef CONFIG_NET_NS
+	twsk->tw_net = net;
+#endif
+}
 #endif	/* _INET_TIMEWAIT_SOCK_ */
diff --git a/include/net/route.h b/include/net/route.h
index 28dba92..c633880 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -160,7 +160,7 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 					 .dport = dport } } };
 
 	int err;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	if (!dst || !src) {
 		err = __ip_route_output_key(net, rp, &fl);
 		if (err)
@@ -188,7 +188,7 @@ static inline int ip_route_newports(struct rtable **rp, u8 protocol,
 		ip_rt_put(*rp);
 		*rp = NULL;
 		security_sk_classify_flow(sk, &fl);
-		return ip_route_output_flow(sk->sk_net, rp, &fl, sk, 0);
+		return ip_route_output_flow(sock_net(sk), rp, &fl, sk, 0);
 	}
 	return 0;
 }
diff --git a/include/net/sock.h b/include/net/sock.h
index b433b1e..7e0d4a0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -126,7 +126,9 @@ struct sock_common {
 	atomic_t		skc_refcnt;
 	unsigned int		skc_hash;
 	struct proto		*skc_prot;
+#ifdef CONFIG_NET_NS
 	struct net	 	*skc_net;
+#endif
 };
 
 /**
@@ -1345,6 +1347,24 @@ static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb, int copied_e
 }
 #endif
 
+static inline
+struct net *sock_net(const struct sock *sk)
+{
+#ifdef CONFIG_NET_NS
+	return sk->sk_net;
+#else
+	return &init_net;
+#endif
+}
+
+static inline
+void sock_net_set(struct sock *sk, const struct net *net)
+{
+#ifdef CONFIG_NET_NS
+	sk->sk_net = net;
+#endif
+}
+
 /*
  * Kernel sockets, f.e. rtnl or icmp_socket, are a part of a namespace.
  * They should not hold a referrence to a namespace in order to allow
@@ -1353,8 +1373,8 @@ static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb, int copied_e
  */
 static inline void sk_change_net(struct sock *sk, struct net *net)
 {
-	put_net(sk->sk_net);
-	sk->sk_net = net;
+	put_net(sock_net(sk));
+	sock_net_set(sk, net);
 }
 
 extern void sock_enable_timestamp(struct sock *sk);
diff --git a/net/atm/svc.c b/net/atm/svc.c
index daf9a48..de1e4f2 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -326,7 +326,7 @@ static int svc_accept(struct socket *sock,struct socket *newsock,int flags)
 
 	lock_sock(sk);
 
-	error = svc_create(sk->sk_net, newsock,0);
+	error = svc_create(sock_net(sk), newsock,0);
 	if (error)
 		goto out;
 
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index ee9dd83..2712544 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -869,7 +869,7 @@ struct sock *ax25_make_new(struct sock *osk, struct ax25_dev *ax25_dev)
 	struct sock *sk;
 	ax25_cb *ax25, *oax25;
 
-	sk = sk_alloc(osk->sk_net, PF_AX25, GFP_ATOMIC,	osk->sk_prot);
+	sk = sk_alloc(sock_net(osk), PF_AX25, GFP_ATOMIC,	osk->sk_prot);
 	if (sk == NULL)
 		return NULL;
 
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 34f8bf9..6b995ac 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1499,7 +1499,7 @@ static inline int l2cap_connect_req(struct l2cap_conn *conn, struct l2cap_cmd_hd
 		goto response;
 	}
 
-	sk = l2cap_sock_alloc(parent->sk_net, NULL, BTPROTO_L2CAP, GFP_ATOMIC);
+	sk = l2cap_sock_alloc(sock_net(parent), NULL, BTPROTO_L2CAP, GFP_ATOMIC);
 	if (!sk)
 		goto response;
 
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index c46d510..c103fa0 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -868,7 +868,7 @@ int rfcomm_connect_ind(struct rfcomm_session *s, u8 channel, struct rfcomm_dlc *
 		goto done;
 	}
 
-	sk = rfcomm_sock_alloc(parent->sk_net, NULL, BTPROTO_RFCOMM, GFP_ATOMIC);
+	sk = rfcomm_sock_alloc(sock_net(parent), NULL, BTPROTO_RFCOMM, GFP_ATOMIC);
 	if (!sk)
 		goto done;
 
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index b91d3c8..2a5953b 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -803,7 +803,7 @@ static void sco_conn_ready(struct sco_conn *conn)
 
 		bh_lock_sock(parent);
 
-		sk = sco_sock_alloc(parent->sk_net, NULL, BTPROTO_SCO, GFP_ATOMIC);
+		sk = sco_sock_alloc(sock_net(parent), NULL, BTPROTO_SCO, GFP_ATOMIC);
 		if (!sk) {
 			bh_unlock_sock(parent);
 			goto done;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index f5d6933..f155e6c 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -108,7 +108,7 @@ errout:
  */
 static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct net_device *dev;
 	int idx;
 
@@ -140,7 +140,7 @@ skip:
  */
 static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
 	struct nlattr *protinfo;
 	struct net_device *dev;
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 942be93..540c072 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -214,7 +214,7 @@ errout:
 
 static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
 	struct fib_rules_ops *ops = NULL;
 	struct fib_rule *rule, *r, *last = NULL;
@@ -352,7 +352,7 @@ errout:
 
 static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
 	struct fib_rules_ops *ops = NULL;
 	struct fib_rule *rule, *tmp;
@@ -534,7 +534,7 @@ skip:
 
 static int fib_nl_dumprule(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct fib_rules_ops *ops;
 	int idx = 0, family;
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index c978bd1..065fbac 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1478,7 +1478,7 @@ int neigh_table_clear(struct neigh_table *tbl)
 
 static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
 	struct nlattr *dst_attr;
 	struct neigh_table *tbl;
@@ -1544,7 +1544,7 @@ out:
 
 static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
 	struct nlattr *tb[NDA_MAX+1];
 	struct neigh_table *tbl;
@@ -1812,7 +1812,7 @@ static const struct nla_policy nl_ntbl_parm_policy[NDTPA_MAX+1] = {
 
 static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct neigh_table *tbl;
 	struct ndtmsg *ndtmsg;
 	struct nlattr *tb[NDTA_MAX+1];
@@ -1937,7 +1937,7 @@ errout:
 
 static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	int family, tidx, nidx = 0;
 	int tbl_skip = cb->args[0];
 	int neigh_skip = cb->args[1];
@@ -2037,7 +2037,7 @@ static void neigh_update_notify(struct neighbour *neigh)
 static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			    struct netlink_callback *cb)
 {
-	struct net * net = skb->sk->sk_net;
+	struct net * net = sock_net(skb->sk);
 	struct neighbour *n;
 	int rc, h, s_h = cb->args[1];
 	int idx, s_idx = idx = cb->args[2];
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 09250a0..da99ac0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -662,7 +662,7 @@ nla_put_failure:
 
 static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	int idx;
 	int s_idx = cb->args[0];
 	struct net_device *dev;
@@ -879,7 +879,7 @@ errout:
 
 static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
 	struct net_device *dev;
 	int err;
@@ -921,7 +921,7 @@ errout:
 
 static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	const struct rtnl_link_ops *ops;
 	struct net_device *dev;
 	struct ifinfomsg *ifm;
@@ -1000,7 +1000,7 @@ err:
 
 static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	const struct rtnl_link_ops *ops;
 	struct net_device *dev;
 	struct ifinfomsg *ifm;
@@ -1132,7 +1132,7 @@ replay:
 
 static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
 	struct nlattr *tb[IFLA_MAX+1];
 	struct net_device *dev = NULL;
@@ -1227,7 +1227,7 @@ static int rtattr_max;
 
 static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	rtnl_doit_func doit;
 	int sz_idx, kind;
 	int min_len;
diff --git a/net/core/sock.c b/net/core/sock.c
index b1a6ed4..3ee9506 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -372,7 +372,7 @@ static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
 {
 	int ret = -ENOPROTOOPT;
 #ifdef CONFIG_NETDEVICES
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	char devname[IFNAMSIZ];
 	int index;
 
@@ -958,7 +958,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		 */
 		sk->sk_prot = sk->sk_prot_creator = prot;
 		sock_lock_init(sk);
-		sk->sk_net = get_net(net);
+		sock_net_set(sk, get_net(net));
 	}
 
 	return sk;
@@ -983,7 +983,7 @@ void sk_free(struct sock *sk)
 		printk(KERN_DEBUG "%s: optmem leakage (%d bytes) detected.\n",
 		       __func__, atomic_read(&sk->sk_omem_alloc));
 
-	put_net(sk->sk_net);
+	put_net(sock_net(sk));
 	sk_prot_free(sk->sk_prot_creator, sk);
 }
 
@@ -1001,7 +1001,7 @@ void sk_release_kernel(struct sock *sk)
 
 	sock_hold(sk);
 	sock_release(sk->sk_socket);
-	sk->sk_net = get_net(&init_net);
+	sock_net_set(sk, get_net(&init_net));
 	sock_put(sk);
 }
 EXPORT_SYMBOL(sk_release_kernel);
@@ -1017,7 +1017,7 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 		sock_copy(newsk, sk);
 
 		/* SANITY */
-		get_net(newsk->sk_net);
+		get_net(sock_net(newsk));
 		sk_node_init(&newsk->sk_node);
 		sock_lock_init(newsk);
 		bh_lock_sock(newsk);
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 3554fb3..fc2efe8 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1094,7 +1094,7 @@ static int dn_accept(struct socket *sock, struct socket *newsock, int flags)
 
 	cb = DN_SKB_CB(skb);
 	sk->sk_ack_backlog--;
-	newsk = dn_alloc_sock(sk->sk_net, newsock, sk->sk_allocation);
+	newsk = dn_alloc_sock(sock_net(sk), newsock, sk->sk_allocation);
 	if (newsk == NULL) {
 		release_sock(sk);
 		kfree_skb(skb);
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 1bbfce5..2f0ac3c 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -625,7 +625,7 @@ static const struct nla_policy dn_ifa_policy[IFA_MAX+1] = {
 
 static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[IFA_MAX+1];
 	struct dn_dev *dn_db;
 	struct ifaddrmsg *ifm;
@@ -663,7 +663,7 @@ errout:
 
 static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[IFA_MAX+1];
 	struct net_device *dev;
 	struct dn_dev *dn_db;
@@ -779,7 +779,7 @@ errout:
 
 static int dn_nl_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	int idx, dn_idx = 0, skip_ndevs, skip_naddr;
 	struct net_device *dev;
 	struct dn_dev *dn_db;
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 4aa9a42..27ea2e9 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -504,7 +504,7 @@ static int dn_fib_check_attr(struct rtmsg *r, struct rtattr **rta)
 
 static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct dn_fib_table *tb;
 	struct rtattr **rta = arg;
 	struct rtmsg *r = NLMSG_DATA(nlh);
@@ -524,7 +524,7 @@ static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *
 
 static int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct dn_fib_table *tb;
 	struct rtattr **rta = arg;
 	struct rtmsg *r = NLMSG_DATA(nlh);
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 0a46b6c..2f665a5 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1512,7 +1512,7 @@ rtattr_failure:
  */
 static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = in_skb->sk->sk_net;
+	struct net *net = sock_net(in_skb->sk);
 	struct rtattr **rta = arg;
 	struct rtmsg *rtm = NLMSG_DATA(nlh);
 	struct dn_route *rt = NULL;
@@ -1601,7 +1601,7 @@ out_free:
  */
 int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct dn_route *rt;
 	int h, s_h;
 	int idx, s_idx;
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index e09d915..3a2830a 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -463,7 +463,7 @@ static int dn_fib_table_dump(struct dn_fib_table *tb, struct sk_buff *skb,
 
 int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	unsigned int h, s_h;
 	unsigned int e = 0, s_e;
 	struct dn_fib_table *tb;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 06cfb0b..5882a13 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -464,7 +464,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (addr_len < sizeof(struct sockaddr_in))
 		goto out;
 
-	chk_addr_ret = inet_addr_type(sk->sk_net, addr->sin_addr.s_addr);
+	chk_addr_ret = inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);
 
 	/* Not specified by any standard per-se, however it breaks too
 	 * many applications when removed.  It is unfortunate since
@@ -802,7 +802,7 @@ int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
 	int err = 0;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 
 	switch (cmd) {
 		case SIOCGSTAMP:
@@ -1132,7 +1132,7 @@ int inet_sk_rebuild_header(struct sock *sk)
 	};
 
 	security_sk_classify_flow(sk, &fl);
-	err = ip_route_output_flow(sk->sk_net, &rt, &fl, sk, 0);
+	err = ip_route_output_flow(sock_net(sk), &rt, &fl, sk, 0);
 }
 	if (!err)
 		sk_setup_caps(sk, &rt->u.dst);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 823c724..6848e47 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -437,7 +437,7 @@ struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix,
 
 static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[IFA_MAX+1];
 	struct in_device *in_dev;
 	struct ifaddrmsg *ifm;
@@ -552,7 +552,7 @@ errout:
 
 static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct in_ifaddr *ifa;
 
 	ASSERT_RTNL();
@@ -1158,7 +1158,7 @@ nla_put_failure:
 
 static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	int idx, ip_idx;
 	struct net_device *dev;
 	struct in_device *in_dev;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 0e4b34b..0f1557a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -583,7 +583,7 @@ errout:
 
 static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct fib_config cfg;
 	struct fib_table *tb;
 	int err;
@@ -605,7 +605,7 @@ errout:
 
 static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct fib_config cfg;
 	struct fib_table *tb;
 	int err;
@@ -627,7 +627,7 @@ errout:
 
 static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	unsigned int h, s_h;
 	unsigned int e = 0, s_e;
 	struct fib_table *tb;
@@ -857,7 +857,7 @@ static void nl_fib_input(struct sk_buff *skb)
 	struct fib_table *tb;
 	u32 pid;
 
-	net = skb->sk->sk_net;
+	net = sock_net(skb->sk);
 	nlh = nlmsg_hdr(skb);
 	if (skb->len < NLMSG_SPACE(0) || skb->len < nlh->nlmsg_len ||
 	    nlh->nlmsg_len < NLMSG_LENGTH(sizeof(*frn)))
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 19274d0..1fb5687 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -137,7 +137,7 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 			       struct nlmsghdr *nlh, struct fib_rule_hdr *frh,
 			       struct nlattr **tb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	int err = -EINVAL;
 	struct fib4_rule *rule4 = (struct fib4_rule *) rule;
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 682f632..6250f42 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1762,7 +1762,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	if (sk->sk_net != &init_net)
+	if (sock_net(sk) != &init_net)
 		return -EPROTONOSUPPORT;
 
 	rtnl_lock();
@@ -1833,7 +1833,7 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 	u32 ifindex;
 	int ret = -EADDRNOTAVAIL;
 
-	if (sk->sk_net != &init_net)
+	if (sock_net(sk) != &init_net)
 		return -EPROTONOSUPPORT;
 
 	rtnl_lock();
@@ -1881,7 +1881,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	if (sk->sk_net != &init_net)
+	if (sock_net(sk) != &init_net)
 		return -EPROTONOSUPPORT;
 
 	rtnl_lock();
@@ -2017,7 +2017,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	    msf->imsf_fmode != MCAST_EXCLUDE)
 		return -EINVAL;
 
-	if (sk->sk_net != &init_net)
+	if (sock_net(sk) != &init_net)
 		return -EPROTONOSUPPORT;
 
 	rtnl_lock();
@@ -2100,7 +2100,7 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	if (sk->sk_net != &init_net)
+	if (sock_net(sk) != &init_net)
 		return -EPROTONOSUPPORT;
 
 	rtnl_lock();
@@ -2165,7 +2165,7 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	if (sk->sk_net != &init_net)
+	if (sock_net(sk) != &init_net)
 		return -EPROTONOSUPPORT;
 
 	rtnl_lock();
@@ -2252,7 +2252,7 @@ void ip_mc_drop_socket(struct sock *sk)
 	if (inet->mc_list == NULL)
 		return;
 
-	if (sk->sk_net != &init_net)
+	if (sock_net(sk) != &init_net)
 		return;
 
 	rtnl_lock();
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index d13c5f1..a7fcaf2 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -85,7 +85,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	struct hlist_node *node;
 	struct inet_bind_bucket *tb;
 	int ret;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 
 	local_bh_disable();
 	if (!snum) {
@@ -333,7 +333,7 @@ struct dst_entry* inet_csk_route_req(struct sock *sk,
 					 .dport = ireq->rmt_port } } };
 
 	security_req_classify_flow(req, &fl);
-	if (ip_route_output_flow(sk->sk_net, &rt, &fl, sk, 0)) {
+	if (ip_route_output_flow(sock_net(sk), &rt, &fl, sk, 0)) {
 		IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
 	}
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 8cd1ad9..1064111 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -139,7 +139,7 @@ static struct sock *inet_lookup_listener_slow(struct net *net,
 	sk_for_each(sk, node, head) {
 		const struct inet_sock *inet = inet_sk(sk);
 
-		if (sk->sk_net == net && inet->num == hnum &&
+		if (sock_net(sk) == net && inet->num == hnum &&
 				!ipv6_only_sock(sk)) {
 			const __be32 rcv_saddr = inet->rcv_saddr;
 			int score = sk->sk_family == PF_INET ? 1 : 0;
@@ -182,7 +182,7 @@ struct sock *__inet_lookup_listener(struct net *net,
 		if (inet->num == hnum && !sk->sk_node.next &&
 		    (!inet->rcv_saddr || inet->rcv_saddr == daddr) &&
 		    (sk->sk_family == PF_INET || !ipv6_only_sock(sk)) &&
-		    !sk->sk_bound_dev_if && sk->sk_net == net)
+		    !sk->sk_bound_dev_if && sock_net(sk) == net)
 			goto sherry_cache;
 		sk = inet_lookup_listener_slow(net, head, daddr, hnum, dif);
 	}
@@ -254,7 +254,7 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 	struct sock *sk2;
 	const struct hlist_node *node;
 	struct inet_timewait_sock *tw;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 
 	prefetch(head->chain.first);
 	write_lock(lock);
@@ -406,7 +406,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 	struct inet_bind_hashbucket *head;
 	struct inet_bind_bucket *tb;
 	int ret;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 
 	if (!snum) {
 		int i, remaining, low, high, port;
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 717c411..f12bc24 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -124,7 +124,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
 		tw->tw_prot	    = sk->sk_prot_creator;
-		tw->tw_net          = sk->sk_net;
+		twsk_net_set(tw, sock_net(sk));
 		atomic_set(&tw->tw_refcnt, 1);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 26685c8..4be0095 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -172,7 +172,7 @@ int ip_call_ra_chain(struct sk_buff *skb)
 		if (sk && inet_sk(sk)->num == protocol &&
 		    (!sk->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == dev->ifindex) &&
-		    sk->sk_net == dev_net(dev)) {
+		    sock_net(sk) == dev_net(dev)) {
 			if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
 				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN)) {
 					read_unlock(&ip_ra_lock);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 913266c..0834926 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -351,7 +351,7 @@ int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 			 * itself out.
 			 */
 			security_sk_classify_flow(sk, &fl);
-			if (ip_route_output_flow(sk->sk_net, &rt, &fl, sk, 0))
+			if (ip_route_output_flow(sock_net(sk), &rt, &fl, sk, 0))
 				goto no_route;
 		}
 		sk_setup_caps(sk, &rt->u.dst);
@@ -1382,7 +1382,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 						 .dport = tcp_hdr(skb)->source } },
 				    .proto = sk->sk_protocol };
 		security_skb_classify_flow(skb, &fl);
-		if (ip_route_output_key(sk->sk_net, &rt, &fl))
+		if (ip_route_output_key(sock_net(sk), &rt, &fl))
 			return;
 	}
 
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index b854431..d6e76f5 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -449,7 +449,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		struct ip_options * opt = NULL;
 		if (optlen > 40 || optlen < 0)
 			goto e_inval;
-		err = ip_options_get_from_user(sk->sk_net, &opt,
+		err = ip_options_get_from_user(sock_net(sk), &opt,
 					       optval, optlen);
 		if (err)
 			break;
@@ -590,13 +590,13 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 				err = 0;
 				break;
 			}
-			dev = ip_dev_find(sk->sk_net, mreq.imr_address.s_addr);
+			dev = ip_dev_find(sock_net(sk), mreq.imr_address.s_addr);
 			if (dev) {
 				mreq.imr_ifindex = dev->ifindex;
 				dev_put(dev);
 			}
 		} else
-			dev = __dev_get_by_index(sk->sk_net, mreq.imr_ifindex);
+			dev = __dev_get_by_index(sock_net(sk), mreq.imr_ifindex);
 
 
 		err = -EADDRNOTAVAIL;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index e54bc13..11700a4 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -849,7 +849,7 @@ static void mrtsock_destruct(struct sock *sk)
 {
 	rtnl_lock();
 	if (sk == mroute_socket) {
-		IPV4_DEVCONF_ALL(sk->sk_net, MC_FORWARDING)--;
+		IPV4_DEVCONF_ALL(sock_net(sk), MC_FORWARDING)--;
 
 		write_lock_bh(&mrt_lock);
 		mroute_socket=NULL;
@@ -898,7 +898,7 @@ int ip_mroute_setsockopt(struct sock *sk,int optname,char __user *optval,int opt
 			mroute_socket=sk;
 			write_unlock_bh(&mrt_lock);
 
-			IPV4_DEVCONF_ALL(sk->sk_net, MC_FORWARDING)++;
+			IPV4_DEVCONF_ALL(sock_net(sk), MC_FORWARDING)++;
 		}
 		rtnl_unlock();
 		return ret;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 756bc0e..1563f29 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1496,11 +1496,11 @@ static int compat_do_arpt_set_ctl(struct sock *sk, int cmd, void __user *user,
 
 	switch (cmd) {
 	case ARPT_SO_SET_REPLACE:
-		ret = compat_do_replace(sk->sk_net, user, len);
+		ret = compat_do_replace(sock_net(sk), user, len);
 		break;
 
 	case ARPT_SO_SET_ADD_COUNTERS:
-		ret = do_add_counters(sk->sk_net, user, len, 1);
+		ret = do_add_counters(sock_net(sk), user, len, 1);
 		break;
 
 	default:
@@ -1644,10 +1644,10 @@ static int compat_do_arpt_get_ctl(struct sock *sk, int cmd, void __user *user,
 
 	switch (cmd) {
 	case ARPT_SO_GET_INFO:
-		ret = get_info(sk->sk_net, user, len, 1);
+		ret = get_info(sock_net(sk), user, len, 1);
 		break;
 	case ARPT_SO_GET_ENTRIES:
-		ret = compat_get_entries(sk->sk_net, user, len);
+		ret = compat_get_entries(sock_net(sk), user, len);
 		break;
 	default:
 		ret = do_arpt_get_ctl(sk, cmd, user, len);
@@ -1665,11 +1665,11 @@ static int do_arpt_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned
 
 	switch (cmd) {
 	case ARPT_SO_SET_REPLACE:
-		ret = do_replace(sk->sk_net, user, len);
+		ret = do_replace(sock_net(sk), user, len);
 		break;
 
 	case ARPT_SO_SET_ADD_COUNTERS:
-		ret = do_add_counters(sk->sk_net, user, len, 0);
+		ret = do_add_counters(sock_net(sk), user, len, 0);
 		break;
 
 	default:
@@ -1689,11 +1689,11 @@ static int do_arpt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len
 
 	switch (cmd) {
 	case ARPT_SO_GET_INFO:
-		ret = get_info(sk->sk_net, user, len, 0);
+		ret = get_info(sock_net(sk), user, len, 0);
 		break;
 
 	case ARPT_SO_GET_ENTRIES:
-		ret = get_entries(sk->sk_net, user, len);
+		ret = get_entries(sock_net(sk), user, len);
 		break;
 
 	case ARPT_SO_GET_REVISION_TARGET: {
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 85a75e1..a819d19 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1852,11 +1852,11 @@ compat_do_ipt_set_ctl(struct sock *sk,	int cmd, void __user *user,
 
 	switch (cmd) {
 	case IPT_SO_SET_REPLACE:
-		ret = compat_do_replace(sk->sk_net, user, len);
+		ret = compat_do_replace(sock_net(sk), user, len);
 		break;
 
 	case IPT_SO_SET_ADD_COUNTERS:
-		ret = do_add_counters(sk->sk_net, user, len, 1);
+		ret = do_add_counters(sock_net(sk), user, len, 1);
 		break;
 
 	default:
@@ -1963,10 +1963,10 @@ compat_do_ipt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 
 	switch (cmd) {
 	case IPT_SO_GET_INFO:
-		ret = get_info(sk->sk_net, user, len, 1);
+		ret = get_info(sock_net(sk), user, len, 1);
 		break;
 	case IPT_SO_GET_ENTRIES:
-		ret = compat_get_entries(sk->sk_net, user, len);
+		ret = compat_get_entries(sock_net(sk), user, len);
 		break;
 	default:
 		ret = do_ipt_get_ctl(sk, cmd, user, len);
@@ -1985,11 +1985,11 @@ do_ipt_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	switch (cmd) {
 	case IPT_SO_SET_REPLACE:
-		ret = do_replace(sk->sk_net, user, len);
+		ret = do_replace(sock_net(sk), user, len);
 		break;
 
 	case IPT_SO_SET_ADD_COUNTERS:
-		ret = do_add_counters(sk->sk_net, user, len, 0);
+		ret = do_add_counters(sock_net(sk), user, len, 0);
 		break;
 
 	default:
@@ -2010,11 +2010,11 @@ do_ipt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 
 	switch (cmd) {
 	case IPT_SO_GET_INFO:
-		ret = get_info(sk->sk_net, user, len, 0);
+		ret = get_info(sock_net(sk), user, len, 0);
 		break;
 
 	case IPT_SO_GET_ENTRIES:
-		ret = get_entries(sk->sk_net, user, len);
+		ret = get_entries(sock_net(sk), user, len);
 		break;
 
 	case IPT_SO_GET_REVISION_MATCH:
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 8756d50..be19a40 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -117,7 +117,7 @@ static struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
 	sk_for_each_from(sk, node) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		if (sk->sk_net == net && inet->num == num 		&&
+		if (sock_net(sk) == net && inet->num == num 		&&
 		    !(inet->daddr && inet->daddr != raddr) 		&&
 		    !(inet->rcv_saddr && inet->rcv_saddr != laddr)	&&
 		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
@@ -499,7 +499,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sk->sk_net, msg, &ipc);
+		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
 		if (err)
 			goto out;
 		if (ipc.opt)
@@ -553,7 +553,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		}
 
 		security_sk_classify_flow(sk, &fl);
-		err = ip_route_output_flow(sk->sk_net, &rt, &fl, sk, 1);
+		err = ip_route_output_flow(sock_net(sk), &rt, &fl, sk, 1);
 	}
 	if (err)
 		goto done;
@@ -620,7 +620,7 @@ static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	if (sk->sk_state != TCP_CLOSE || addr_len < sizeof(struct sockaddr_in))
 		goto out;
-	chk_addr_ret = inet_addr_type(sk->sk_net, addr->sin_addr.s_addr);
+	chk_addr_ret = inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);
 	ret = -EADDRNOTAVAIL;
 	if (addr->sin_addr.s_addr && chk_addr_ret != RTN_LOCAL &&
 	    chk_addr_ret != RTN_MULTICAST && chk_addr_ret != RTN_BROADCAST)
@@ -856,7 +856,7 @@ static struct sock *raw_get_first(struct seq_file *seq)
 		struct hlist_node *node;
 
 		sk_for_each(sk, node, &state->h->ht[state->bucket])
-			if (sk->sk_net == state->p.net)
+			if (sock_net(sk) == state->p.net)
 				goto found;
 	}
 	sk = NULL;
@@ -872,7 +872,7 @@ static struct sock *raw_get_next(struct seq_file *seq, struct sock *sk)
 		sk = sk_next(sk);
 try_again:
 		;
-	} while (sk && sk->sk_net != state->p.net);
+	} while (sk && sock_net(sk) != state->p.net);
 
 	if (!sk && ++state->bucket < RAW_HTABLE_SIZE) {
 		sk = sk_head(&state->h->ht[state->bucket]);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7768d71..194f5cc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2689,7 +2689,7 @@ nla_put_failure:
 
 static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct net *net = in_skb->sk->sk_net;
+	struct net *net = sock_net(in_skb->sk);
 	struct rtmsg *rtm;
 	struct nlattr *tb[RTA_MAX+1];
 	struct rtable *rt = NULL;
@@ -2785,7 +2785,7 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 	int idx, s_idx;
 	struct net *net;
 
-	net = skb->sk->sk_net;
+	net = sock_net(skb->sk);
 
 	s_h = cb->args[0];
 	if (s_h < 0)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 28bece6..46847e6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1486,7 +1486,7 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	if (req)
 		return tcp_check_req(sk, skb, req, prev);
 
-	nsk = inet_lookup_established(sk->sk_net, &tcp_hashinfo, iph->saddr,
+	nsk = inet_lookup_established(sock_net(sk), &tcp_hashinfo, iph->saddr,
 			th->source, iph->daddr, th->dest, inet_iif(skb));
 
 	if (nsk) {
@@ -1974,7 +1974,7 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 		while (1) {
 			while (req) {
 				if (req->rsk_ops->family == st->family &&
-				    req->sk->sk_net == net) {
+				    sock_net(req->sk) == net) {
 					cur = req;
 					goto out;
 				}
@@ -1998,7 +1998,7 @@ get_req:
 	}
 get_sk:
 	sk_for_each_from(sk, node) {
-		if (sk->sk_family == st->family && sk->sk_net == net) {
+		if (sk->sk_family == st->family && sock_net(sk) == net) {
 			cur = sk;
 			goto out;
 		}
@@ -2049,7 +2049,7 @@ static void *established_get_first(struct seq_file *seq)
 		read_lock_bh(lock);
 		sk_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
 			if (sk->sk_family != st->family ||
-			    sk->sk_net != net) {
+			    sock_net(sk) != net) {
 				continue;
 			}
 			rc = sk;
@@ -2059,7 +2059,7 @@ static void *established_get_first(struct seq_file *seq)
 		inet_twsk_for_each(tw, node,
 				   &tcp_hashinfo.ehash[st->bucket].twchain) {
 			if (tw->tw_family != st->family ||
-			    tw->tw_net != net) {
+			    twsk_net(tw) != net) {
 				continue;
 			}
 			rc = tw;
@@ -2086,7 +2086,7 @@ static void *established_get_next(struct seq_file *seq, void *cur)
 		tw = cur;
 		tw = tw_next(tw);
 get_tw:
-		while (tw && (tw->tw_family != st->family || tw->tw_net != net)) {
+		while (tw && (tw->tw_family != st->family || twsk_net(tw) != net)) {
 			tw = tw_next(tw);
 		}
 		if (tw) {
@@ -2107,7 +2107,7 @@ get_tw:
 		sk = sk_next(sk);
 
 	sk_for_each_from(sk, node) {
-		if (sk->sk_family == st->family && sk->sk_net == net)
+		if (sk->sk_family == st->family && sock_net(sk) == net)
 			goto found;
 	}
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e2cd934..76d52d3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -137,7 +137,7 @@ static inline int __udp_lib_lport_inuse(struct net *net, __u16 num,
 	struct hlist_node *node;
 
 	sk_for_each(sk, node, &udptable[num & (UDP_HTABLE_SIZE - 1)])
-		if (sk->sk_net == net && sk->sk_hash == num)
+		if (sock_net(sk) == net && sk->sk_hash == num)
 			return 1;
 	return 0;
 }
@@ -158,7 +158,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 	struct hlist_head *head;
 	struct sock *sk2;
 	int    error = 1;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 
 	write_lock_bh(&udp_hash_lock);
 
@@ -218,7 +218,7 @@ gotit:
 		sk_for_each(sk2, node, head)
 			if (sk2->sk_hash == snum                             &&
 			    sk2 != sk                                        &&
-			    sk2->sk_net == net				     &&
+			    sock_net(sk2) == net				     &&
 			    (!sk2->sk_reuse        || !sk->sk_reuse)         &&
 			    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
 			     || sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
@@ -269,7 +269,7 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	sk_for_each(sk, node, &udptable[hnum & (UDP_HTABLE_SIZE - 1)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		if (sk->sk_net == net && sk->sk_hash == hnum &&
+		if (sock_net(sk) == net && sk->sk_hash == hnum &&
 				!ipv6_only_sock(sk)) {
 			int score = (sk->sk_family == PF_INET ? 1 : 0);
 			if (inet->rcv_saddr) {
@@ -607,7 +607,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	ipc.oif = sk->sk_bound_dev_if;
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sk->sk_net, msg, &ipc);
+		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
 		if (err)
 			return err;
 		if (ipc.opt)
@@ -656,7 +656,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 					       { .sport = inet->sport,
 						 .dport = dport } } };
 		security_sk_classify_flow(sk, &fl);
-		err = ip_route_output_flow(sk->sk_net, &rt, &fl, sk, 1);
+		err = ip_route_output_flow(sock_net(sk), &rt, &fl, sk, 1);
 		if (err) {
 			if (err == -ENETUNREACH)
 				IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
@@ -1511,7 +1511,7 @@ static struct sock *udp_get_first(struct seq_file *seq)
 	for (state->bucket = 0; state->bucket < UDP_HTABLE_SIZE; ++state->bucket) {
 		struct hlist_node *node;
 		sk_for_each(sk, node, state->hashtable + state->bucket) {
-			if (sk->sk_net != net)
+			if (sock_net(sk) != net)
 				continue;
 			if (sk->sk_family == state->family)
 				goto found;
@@ -1531,7 +1531,7 @@ static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
 		sk = sk_next(sk);
 try_again:
 		;
-	} while (sk && (sk->sk_net != net || sk->sk_family != state->family));
+	} while (sk && (sock_net(sk) != net || sk->sk_family != state->family));
 
 	if (!sk && ++state->bucket < UDP_HTABLE_SIZE) {
 		sk = sk_head(state->hashtable + state->bucket);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d1de9ec..f2c90f1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3054,7 +3054,7 @@ static const struct nla_policy ifa_ipv6_policy[IFA_MAX+1] = {
 static int
 inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct ifaddrmsg *ifm;
 	struct nlattr *tb[IFA_MAX+1];
 	struct in6_addr *pfx;
@@ -3112,7 +3112,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
 static int
 inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct ifaddrmsg *ifm;
 	struct nlattr *tb[IFA_MAX+1];
 	struct in6_addr *pfx;
@@ -3322,7 +3322,7 @@ static int inet6_dump_addr(struct sk_buff *skb, struct netlink_callback *cb,
 	struct inet6_ifaddr *ifa;
 	struct ifmcaddr6 *ifmca;
 	struct ifacaddr6 *ifaca;
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 
 	s_idx = cb->args[0];
 	s_ip_idx = ip_idx = cb->args[1];
@@ -3418,7 +3418,7 @@ static int inet6_dump_ifacaddr(struct sk_buff *skb, struct netlink_callback *cb)
 static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 			     void *arg)
 {
-	struct net *net = in_skb->sk->sk_net;
+	struct net *net = sock_net(in_skb->sk);
 	struct ifaddrmsg *ifm;
 	struct nlattr *tb[IFA_MAX+1];
 	struct in6_addr *addr = NULL;
@@ -3645,7 +3645,7 @@ nla_put_failure:
 
 static int inet6_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	int idx, err;
 	int s_idx = cb->args[0];
 	struct net_device *dev;
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index de371b5..9bfa884 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -364,7 +364,7 @@ static const struct nla_policy ifal_policy[IFAL_MAX+1] = {
 static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 			     void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct ifaddrlblmsg *ifal;
 	struct nlattr *tb[IFAL_MAX+1];
 	struct in6_addr *pfx;
@@ -452,7 +452,7 @@ static int ip6addrlbl_fill(struct sk_buff *skb,
 
 static int ip6addrlbl_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct ip6addrlbl_entry *p;
 	struct hlist_node *pos;
 	int idx = 0, s_idx = cb->args[0];
@@ -490,7 +490,7 @@ static inline int ip6addrlbl_msgsize(void)
 static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 			  void *arg)
 {
-	struct net *net = in_skb->sk->sk_net;
+	struct net *net = sock_net(in_skb->sk);
 	struct ifaddrlblmsg *ifal;
 	struct nlattr *tb[IFAL_MAX+1];
 	struct in6_addr *addr;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index f52bdae..12f04e9 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -245,7 +245,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct sock *sk = sock->sk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	__be32 v4addr = 0;
 	unsigned short snum;
 	int addr_type = 0;
@@ -438,7 +438,7 @@ EXPORT_SYMBOL(inet6_getname);
 int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 
 	switch(cmd)
 	{
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index e7a7fe2..cac5807 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -154,7 +154,7 @@ static int fib6_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 			       struct nlattr **tb)
 {
 	int err = -EINVAL;
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct fib6_rule *rule6 = (struct fib6_rule *) rule;
 
 	if (rule->action == FR_ACT_TO_TBL) {
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 5085766..63309d1 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -163,7 +163,7 @@ static inline int icmpv6_xrlim_allow(struct sock *sk, int type,
 				     struct flowi *fl)
 {
 	struct dst_entry *dst;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	int res = 0;
 
 	/* Informational messages are not limited. */
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index c0c8d2d..21c4676 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -105,7 +105,7 @@ struct sock *inet6_lookup_listener(struct net *net,
 
 	read_lock(&hashinfo->lhash_lock);
 	sk_for_each(sk, node, &hashinfo->listening_hash[inet_lhashfn(hnum)]) {
-		if (sk->sk_net == net && inet_sk(sk)->num == hnum &&
+		if (sock_net(sk) == net && inet_sk(sk)->num == hnum &&
 				sk->sk_family == PF_INET6) {
 			const struct ipv6_pinfo *np = inet6_sk(sk);
 
@@ -172,7 +172,7 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 	struct sock *sk2;
 	const struct hlist_node *node;
 	struct inet_timewait_sock *tw;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 
 	prefetch(head->chain.first);
 	write_lock(lock);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index b0814b0..b3f6e03 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -346,7 +346,7 @@ end:
 
 static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	unsigned int h, s_h;
 	unsigned int e = 0, s_e;
 	struct rt6_rtnl_dump_arg arg;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 556300f..a8b4da2 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -910,7 +910,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 			       struct dst_entry **dst, struct flowi *fl)
 {
 	int err;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 
 	if (*dst == NULL)
 		*dst = ip6_route_output(net, sk, fl);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index dc6695c..d3d93d7 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -107,7 +107,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		    char __user *optval, int optlen)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	int val, valbool;
 	int retv = -ENOPROTOOPT;
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 0357de8..20a3d8e 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -181,7 +181,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, struct in6_addr *addr)
 	struct net_device *dev = NULL;
 	struct ipv6_mc_socklist *mc_lst;
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	int err;
 
 	if (!ipv6_addr_is_multicast(addr))
@@ -255,7 +255,7 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, struct in6_addr *addr)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_mc_socklist *mc_lst, **lnk;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 
 	write_lock_bh(&ipv6_sk_mc_lock);
 	for (lnk = &np->ipv6_mc_list; (mc_lst = *lnk) !=NULL ; lnk = &mc_lst->next) {
@@ -327,7 +327,7 @@ void ipv6_sock_mc_close(struct sock *sk)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_mc_socklist *mc_lst;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 
 	write_lock_bh(&ipv6_sk_mc_lock);
 	while ((mc_lst = np->ipv6_mc_list) != NULL) {
@@ -365,7 +365,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 	struct inet6_dev *idev;
 	struct ipv6_pinfo *inet6 = inet6_sk(sk);
 	struct ip6_sf_socklist *psl;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	int i, j, rv;
 	int leavegroup = 0;
 	int pmclocked = 0;
@@ -505,7 +505,7 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 	struct inet6_dev *idev;
 	struct ipv6_pinfo *inet6 = inet6_sk(sk);
 	struct ip6_sf_socklist *newpsl, *psl;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	int leavegroup = 0;
 	int i, err;
 
@@ -598,7 +598,7 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	struct net_device *dev;
 	struct ipv6_pinfo *inet6 = inet6_sk(sk);
 	struct ip6_sf_socklist *psl;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 
 	group = &((struct sockaddr_in6 *)&gsf->gf_group)->sin6_addr;
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index af1ec7b..70ef0d2 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1879,11 +1879,11 @@ compat_do_ip6t_set_ctl(struct sock *sk, int cmd, void __user *user,
 
 	switch (cmd) {
 	case IP6T_SO_SET_REPLACE:
-		ret = compat_do_replace(sk->sk_net, user, len);
+		ret = compat_do_replace(sock_net(sk), user, len);
 		break;
 
 	case IP6T_SO_SET_ADD_COUNTERS:
-		ret = do_add_counters(sk->sk_net, user, len, 1);
+		ret = do_add_counters(sock_net(sk), user, len, 1);
 		break;
 
 	default:
@@ -1990,10 +1990,10 @@ compat_do_ip6t_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 
 	switch (cmd) {
 	case IP6T_SO_GET_INFO:
-		ret = get_info(sk->sk_net, user, len, 1);
+		ret = get_info(sock_net(sk), user, len, 1);
 		break;
 	case IP6T_SO_GET_ENTRIES:
-		ret = compat_get_entries(sk->sk_net, user, len);
+		ret = compat_get_entries(sock_net(sk), user, len);
 		break;
 	default:
 		ret = do_ip6t_get_ctl(sk, cmd, user, len);
@@ -2012,11 +2012,11 @@ do_ip6t_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 
 	switch (cmd) {
 	case IP6T_SO_SET_REPLACE:
-		ret = do_replace(sk->sk_net, user, len);
+		ret = do_replace(sock_net(sk), user, len);
 		break;
 
 	case IP6T_SO_SET_ADD_COUNTERS:
-		ret = do_add_counters(sk->sk_net, user, len, 0);
+		ret = do_add_counters(sock_net(sk), user, len, 0);
 		break;
 
 	default:
@@ -2037,11 +2037,11 @@ do_ip6t_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 
 	switch (cmd) {
 	case IP6T_SO_GET_INFO:
-		ret = get_info(sk->sk_net, user, len, 0);
+		ret = get_info(sock_net(sk), user, len, 0);
 		break;
 
 	case IP6T_SO_GET_ENTRIES:
-		ret = get_entries(sk->sk_net, user, len);
+		ret = get_entries(sock_net(sk), user, len);
 		break;
 
 	case IP6T_SO_GET_REVISION_MATCH:
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index efb0047..12c7a15 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -76,7 +76,7 @@ static struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
 		if (inet_sk(sk)->num == num) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 
-			if (sk->sk_net != net)
+			if (sock_net(sk) != net)
 				continue;
 
 			if (!ipv6_addr_any(&np->daddr) &&
@@ -280,7 +280,7 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 			if (!sk->sk_bound_dev_if)
 				goto out;
 
-			dev = dev_get_by_index(sk->sk_net, sk->sk_bound_dev_if);
+			dev = dev_get_by_index(sock_net(sk), sk->sk_bound_dev_if);
 			if (!dev) {
 				err = -ENODEV;
 				goto out;
@@ -293,7 +293,7 @@ static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		v4addr = LOOPBACK4_IPV6;
 		if (!(addr_type & IPV6_ADDR_MULTICAST))	{
 			err = -EADDRNOTAVAIL;
-			if (!ipv6_chk_addr(sk->sk_net, &addr->sin6_addr,
+			if (!ipv6_chk_addr(sock_net(sk), &addr->sin6_addr,
 					   dev, 0)) {
 				if (dev)
 					dev_put(dev);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 65053fb..ac44283 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2020,7 +2020,7 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	cfg->fc_nlinfo.pid = NETLINK_CB(skb).pid;
 	cfg->fc_nlinfo.nlh = nlh;
-	cfg->fc_nlinfo.nl_net = skb->sk->sk_net;
+	cfg->fc_nlinfo.nl_net = sock_net(skb->sk);
 
 	if (tb[RTA_GATEWAY]) {
 		nla_memcpy(&cfg->fc_gateway, tb[RTA_GATEWAY], 16);
@@ -2216,7 +2216,7 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 
 static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct net *net = in_skb->sk->sk_net;
+	struct net *net = sock_net(in_skb->sk);
 	struct nlattr *tb[RTA_MAX+1];
 	struct rt6_info *rt;
 	struct sk_buff *skb;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 086deff..323c7e0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1218,7 +1218,7 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
 	if (req)
 		return tcp_check_req(sk, skb, req, prev);
 
-	nsk = __inet6_lookup_established(sk->sk_net, &tcp_hashinfo,
+	nsk = __inet6_lookup_established(sock_net(sk), &tcp_hashinfo,
 			&ipv6_hdr(skb)->saddr, th->source,
 			&ipv6_hdr(skb)->daddr, ntohs(th->dest), inet6_iif(skb));
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 6683c04..db266ff 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -70,7 +70,7 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 	sk_for_each(sk, node, &udptable[hnum & (UDP_HTABLE_SIZE - 1)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		if (sk->sk_net == net && sk->sk_hash == hnum &&
+		if (sock_net(sk) == net && sk->sk_hash == hnum &&
 				sk->sk_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 			int score = 0;
@@ -323,7 +323,7 @@ static struct sock *udp_v6_mcast_next(struct sock *sk,
 	sk_for_each_from(s, node) {
 		struct inet_sock *inet = inet_sk(s);
 
-		if (s->sk_net != sk->sk_net)
+		if (sock_net(s) != sock_net(sk))
 			continue;
 
 		if (s->sk_hash == num && s->sk_family == PF_INET6) {
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 6f21a53..ae54b20 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -837,7 +837,7 @@ static int irda_accept(struct socket *sock, struct socket *newsock, int flags)
 
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
-	err = irda_create(sk->sk_net, newsock, sk->sk_protocol);
+	err = irda_create(sock_net(sk), newsock, sk->sk_protocol);
 	if (err)
 		return err;
 
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 5ebfd93..5c6d89c 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -700,7 +700,7 @@ static struct sock *llc_create_incoming_sock(struct sock *sk,
 					     struct llc_addr *saddr,
 					     struct llc_addr *daddr)
 {
-	struct sock *newsk = llc_sk_alloc(sk->sk_net, sk->sk_family, GFP_ATOMIC,
+	struct sock *newsk = llc_sk_alloc(sock_net(sk), sk->sk_family, GFP_ATOMIC,
 					  sk->sk_prot);
 	struct llc_sock *newllc, *llc = llc_sk(sk);
 
diff --git a/net/netfilter/nf_sockopt.c b/net/netfilter/nf_sockopt.c
index 3dd4b3c..69d699f 100644
--- a/net/netfilter/nf_sockopt.c
+++ b/net/netfilter/nf_sockopt.c
@@ -65,7 +65,7 @@ static struct nf_sockopt_ops *nf_sockopt_find(struct sock *sk, int pf,
 {
 	struct nf_sockopt_ops *ops;
 
-	if (sk->sk_net != &init_net)
+	if (sock_net(sk) != &init_net)
 		return ERR_PTR(-ENOPROTOOPT);
 
 	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 86bd866..712a7bf 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -228,7 +228,7 @@ static inline struct sock *netlink_lookup(struct net *net, int protocol,
 	read_lock(&nl_table_lock);
 	head = nl_pid_hashfn(hash, pid);
 	sk_for_each(sk, node, head) {
-		if ((sk->sk_net == net) && (nlk_sk(sk)->pid == pid)) {
+		if (sock_net(sk) == net && (nlk_sk(sk)->pid == pid)) {
 			sock_hold(sk);
 			goto found;
 		}
@@ -348,7 +348,7 @@ static int netlink_insert(struct sock *sk, struct net *net, u32 pid)
 	head = nl_pid_hashfn(hash, pid);
 	len = 0;
 	sk_for_each(osk, node, head) {
-		if ((osk->sk_net == net) && (nlk_sk(osk)->pid == pid))
+		if (sock_net(osk) == net && (nlk_sk(osk)->pid == pid))
 			break;
 		len++;
 	}
@@ -486,7 +486,7 @@ static int netlink_release(struct socket *sock)
 
 	if (nlk->pid && !nlk->subscriptions) {
 		struct netlink_notify n = {
-						.net = sk->sk_net,
+						.net = sock_net(sk),
 						.protocol = sk->sk_protocol,
 						.pid = nlk->pid,
 					  };
@@ -518,7 +518,7 @@ static int netlink_release(struct socket *sock)
 static int netlink_autobind(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	struct nl_pid_hash *hash = &nl_table[sk->sk_protocol].hash;
 	struct hlist_head *head;
 	struct sock *osk;
@@ -532,7 +532,7 @@ retry:
 	netlink_table_grab();
 	head = nl_pid_hashfn(hash, pid);
 	sk_for_each(osk, node, head) {
-		if ((osk->sk_net != net))
+		if (sock_net(osk) != net)
 			continue;
 		if (nlk_sk(osk)->pid == pid) {
 			/* Bind collision, search negative pid values. */
@@ -611,7 +611,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			int addr_len)
 {
 	struct sock *sk = sock->sk;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	struct netlink_sock *nlk = nlk_sk(sk);
 	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
 	int err;
@@ -720,7 +720,7 @@ static struct sock *netlink_getsockbypid(struct sock *ssk, u32 pid)
 	struct sock *sock;
 	struct netlink_sock *nlk;
 
-	sock = netlink_lookup(ssk->sk_net, ssk->sk_protocol, pid);
+	sock = netlink_lookup(sock_net(ssk), ssk->sk_protocol, pid);
 	if (!sock)
 		return ERR_PTR(-ECONNREFUSED);
 
@@ -962,7 +962,7 @@ static inline int do_one_broadcast(struct sock *sk,
 	    !test_bit(p->group - 1, nlk->groups))
 		goto out;
 
-	if ((sk->sk_net != p->net))
+	if (sock_net(sk) != p->net)
 		goto out;
 
 	if (p->failure) {
@@ -1006,7 +1006,7 @@ out:
 int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
 		      u32 group, gfp_t allocation)
 {
-	struct net *net = ssk->sk_net;
+	struct net *net = sock_net(ssk);
 	struct netlink_broadcast_data info;
 	struct hlist_node *node;
 	struct sock *sk;
@@ -1064,7 +1064,7 @@ static inline int do_one_set_err(struct sock *sk,
 	if (sk == p->exclude_sk)
 		goto out;
 
-	if (sk->sk_net != p->exclude_sk->sk_net)
+	if (sock_net(sk) != sock_net(p->exclude_sk))
 		goto out;
 
 	if (nlk->pid == p->pid || p->group - 1 >= nlk->ngroups ||
@@ -1601,7 +1601,7 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	atomic_inc(&skb->users);
 	cb->skb = skb;
 
-	sk = netlink_lookup(ssk->sk_net, ssk->sk_protocol, NETLINK_CB(skb).pid);
+	sk = netlink_lookup(sock_net(ssk), ssk->sk_protocol, NETLINK_CB(skb).pid);
 	if (sk == NULL) {
 		netlink_destroy_callback(cb);
 		return -ECONNREFUSED;
@@ -1643,7 +1643,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	if (!skb) {
 		struct sock *sk;
 
-		sk = netlink_lookup(in_skb->sk->sk_net,
+		sk = netlink_lookup(sock_net(in_skb->sk),
 				    in_skb->sk->sk_protocol,
 				    NETLINK_CB(in_skb).pid);
 		if (sk) {
@@ -1758,7 +1758,7 @@ static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
 
 		for (j = 0; j <= hash->mask; j++) {
 			sk_for_each(s, node, &hash->table[j]) {
-				if (iter->p.net != s->sk_net)
+				if (sock_net(s) != iter->p.net)
 					continue;
 				if (off == pos) {
 					iter->link = i;
@@ -1794,7 +1794,7 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	s = v;
 	do {
 		s = sk_next(s);
-	} while (s && (iter->p.net != s->sk_net));
+	} while (s && (sock_net(s) != iter->p.net));
 	if (s)
 		return s;
 
@@ -1806,7 +1806,7 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 		for (; j <= hash->mask; j++) {
 			s = sk_head(&hash->table[j]);
-			while (s && (iter->p.net != s->sk_net))
+			while (s && sock_net(s) != iter->p.net)
 				s = sk_next(s);
 			if (s) {
 				iter->link = i;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index a270ebf..4bae8b9 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -466,7 +466,7 @@ static struct sock *nr_make_new(struct sock *osk)
 	if (osk->sk_type != SOCK_SEQPACKET)
 		return NULL;
 
-	sk = sk_alloc(osk->sk_net, PF_NETROM, GFP_ATOMIC, osk->sk_prot);
+	sk = sk_alloc(sock_net(osk), PF_NETROM, GFP_ATOMIC, osk->sk_prot);
 	if (sk == NULL)
 		return NULL;
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index baa290d..2507024 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -263,7 +263,7 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,  struct
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto out;
 
-	if (dev_net(dev) != sk->sk_net)
+	if (dev_net(dev) != sock_net(sk))
 		goto out;
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
@@ -337,7 +337,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	 */
 
 	saddr->spkt_device[13] = 0;
-	dev = dev_get_by_name(sk->sk_net, saddr->spkt_device);
+	dev = dev_get_by_name(sock_net(sk), saddr->spkt_device);
 	err = -ENODEV;
 	if (dev == NULL)
 		goto out_unlock;
@@ -451,7 +451,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	sk = pt->af_packet_priv;
 	po = pkt_sk(sk);
 
-	if (dev_net(dev) != sk->sk_net)
+	if (dev_net(dev) != sock_net(sk))
 		goto drop;
 
 	skb->dev = dev;
@@ -568,7 +568,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 	sk = pt->af_packet_priv;
 	po = pkt_sk(sk);
 
-	if (dev_net(dev) != sk->sk_net)
+	if (dev_net(dev) != sock_net(sk))
 		goto drop;
 
 	if (dev->header_ops) {
@@ -728,7 +728,7 @@ static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 
-	dev = dev_get_by_index(sk->sk_net, ifindex);
+	dev = dev_get_by_index(sock_net(sk), ifindex);
 	err = -ENXIO;
 	if (dev == NULL)
 		goto out_unlock;
@@ -800,7 +800,7 @@ static int packet_release(struct socket *sock)
 	if (!sk)
 		return 0;
 
-	net = sk->sk_net;
+	net = sock_net(sk);
 	po = pkt_sk(sk);
 
 	write_lock_bh(&net->packet.sklist_lock);
@@ -914,7 +914,7 @@ static int packet_bind_spkt(struct socket *sock, struct sockaddr *uaddr, int add
 		return -EINVAL;
 	strlcpy(name,uaddr->sa_data,sizeof(name));
 
-	dev = dev_get_by_name(sk->sk_net, name);
+	dev = dev_get_by_name(sock_net(sk), name);
 	if (dev) {
 		err = packet_do_bind(sk, dev, pkt_sk(sk)->num);
 		dev_put(dev);
@@ -941,7 +941,7 @@ static int packet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len
 
 	if (sll->sll_ifindex) {
 		err = -ENODEV;
-		dev = dev_get_by_index(sk->sk_net, sll->sll_ifindex);
+		dev = dev_get_by_index(sock_net(sk), sll->sll_ifindex);
 		if (dev == NULL)
 			goto out;
 	}
@@ -1135,7 +1135,7 @@ static int packet_getname_spkt(struct socket *sock, struct sockaddr *uaddr,
 		return -EOPNOTSUPP;
 
 	uaddr->sa_family = AF_PACKET;
-	dev = dev_get_by_index(sk->sk_net, pkt_sk(sk)->ifindex);
+	dev = dev_get_by_index(sock_net(sk), pkt_sk(sk)->ifindex);
 	if (dev) {
 		strlcpy(uaddr->sa_data, dev->name, 15);
 		dev_put(dev);
@@ -1160,7 +1160,7 @@ static int packet_getname(struct socket *sock, struct sockaddr *uaddr,
 	sll->sll_family = AF_PACKET;
 	sll->sll_ifindex = po->ifindex;
 	sll->sll_protocol = po->num;
-	dev = dev_get_by_index(sk->sk_net, po->ifindex);
+	dev = dev_get_by_index(sock_net(sk), po->ifindex);
 	if (dev) {
 		sll->sll_hatype = dev->type;
 		sll->sll_halen = dev->addr_len;
@@ -1212,7 +1212,7 @@ static int packet_mc_add(struct sock *sk, struct packet_mreq_max *mreq)
 	rtnl_lock();
 
 	err = -ENODEV;
-	dev = __dev_get_by_index(sk->sk_net, mreq->mr_ifindex);
+	dev = __dev_get_by_index(sock_net(sk), mreq->mr_ifindex);
 	if (!dev)
 		goto done;
 
@@ -1266,7 +1266,7 @@ static int packet_mc_drop(struct sock *sk, struct packet_mreq_max *mreq)
 			if (--ml->count == 0) {
 				struct net_device *dev;
 				*mlp = ml->next;
-				dev = dev_get_by_index(sk->sk_net, ml->ifindex);
+				dev = dev_get_by_index(sock_net(sk), ml->ifindex);
 				if (dev) {
 					packet_dev_mc(dev, ml, -1);
 					dev_put(dev);
@@ -1294,7 +1294,7 @@ static void packet_flush_mclist(struct sock *sk)
 		struct net_device *dev;
 
 		po->mclist = ml->next;
-		if ((dev = dev_get_by_index(sk->sk_net, ml->ifindex)) != NULL) {
+		if ((dev = dev_get_by_index(sock_net(sk), ml->ifindex)) != NULL) {
 			packet_dev_mc(dev, ml, -1);
 			dev_put(dev);
 		}
@@ -1540,7 +1540,7 @@ static int packet_ioctl(struct socket *sock, unsigned int cmd,
 		case SIOCGIFDSTADDR:
 		case SIOCSIFDSTADDR:
 		case SIOCSIFFLAGS:
-			if (sk->sk_net != &init_net)
+			if (sock_net(sk) != &init_net)
 				return -ENOIOCTLCMD;
 			return inet_dgram_ops.ioctl(sock, cmd, arg);
 #endif
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 1a7f143..92d85c3 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -551,7 +551,7 @@ static struct sock *rose_make_new(struct sock *osk)
 	if (osk->sk_type != SOCK_SEQPACKET)
 		return NULL;
 
-	sk = sk_alloc(osk->sk_net, PF_ROSE, GFP_ATOMIC, &rose_proto);
+	sk = sk_alloc(sock_net(osk), PF_ROSE, GFP_ATOMIC, &rose_proto);
 	if (sk == NULL)
 		return NULL;
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 0b8eb23..74e662c 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -951,7 +951,7 @@ done:
 
 static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct nlattr *tca[TCA_ACT_MAX + 1];
 	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
 	int ret = 0, ovr = 0;
@@ -1029,7 +1029,7 @@ find_dump_kind(struct nlmsghdr *n)
 static int
 tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct nlmsghdr *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0fbedca..1086df7 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -118,7 +118,7 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 
 static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct nlattr *tca[TCA_MAX + 1];
 	struct tcmsg *t;
 	u32 protocol;
@@ -389,7 +389,7 @@ static int tcf_node_dump(struct tcf_proto *tp, unsigned long n,
 
 static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	int t;
 	int s_t;
 	struct net_device *dev;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 7e3c048..15b91a9 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -605,7 +605,7 @@ check_loop_fn(struct Qdisc *q, unsigned long cl, struct qdisc_walker *w)
 
 static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct tcmsg *tcm = NLMSG_DATA(n);
 	struct nlattr *tca[TCA_MAX + 1];
 	struct net_device *dev;
@@ -674,7 +674,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 
 static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct tcmsg *tcm;
 	struct nlattr *tca[TCA_MAX + 1];
 	struct net_device *dev;
@@ -893,7 +893,7 @@ err_out:
 
 static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	int idx, q_idx;
 	int s_idx, s_q_idx;
 	struct net_device *dev;
@@ -945,7 +945,7 @@ done:
 
 static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	struct tcmsg *tcm = NLMSG_DATA(n);
 	struct nlattr *tca[TCA_MAX + 1];
 	struct net_device *dev;
@@ -1139,7 +1139,7 @@ static int qdisc_class_dump(struct Qdisc *q, unsigned long cl, struct qdisc_walk
 
 static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
+	struct net *net = sock_net(skb->sk);
 	int t;
 	int s_t;
 	struct net_device *dev;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index dc71d0d..036bfcc 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -636,7 +636,7 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct sctp6_sock *newsctp6sk;
 
-	newsk = sk_alloc(sk->sk_net, PF_INET6, GFP_KERNEL, sk->sk_prot);
+	newsk = sk_alloc(sock_net(sk), PF_INET6, GFP_KERNEL, sk->sk_prot);
 	if (!newsk)
 		goto out;
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 2faa0d8..5aea911 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -554,7 +554,7 @@ static struct sock *sctp_v4_create_accept_sk(struct sock *sk,
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct inet_sock *newinet;
-	struct sock *newsk = sk_alloc(sk->sk_net, PF_INET, GFP_KERNEL,
+	struct sock *newsk = sk_alloc(sock_net(sk), PF_INET, GFP_KERNEL,
 			sk->sk_prot);
 
 	if (!newsk)
diff --git a/net/socket.c b/net/socket.c
index 9d3fbfb..79e5382 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -857,7 +857,7 @@ static long sock_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 
 	sock = file->private_data;
 	sk = sock->sk;
-	net = sk->sk_net;
+	net = sock_net(sk);
 	if (cmd >= SIOCDEVPRIVATE && cmd <= (SIOCDEVPRIVATE + 15)) {
 		err = dev_ioctl(net, cmd, argp);
 	} else
@@ -1375,7 +1375,7 @@ asmlinkage long sys_listen(int fd, int backlog)
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (sock) {
-		somaxconn = sock->sk->sk_net->sysctl_somaxconn;
+		somaxconn = sock_net(sock->sk)->sysctl_somaxconn;
 		if ((unsigned)backlog > somaxconn)
 			backlog = somaxconn;
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3220d5c..ae45df0 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1375,7 +1375,7 @@ static int accept(struct socket *sock, struct socket *newsock, int flags)
 	}
 	buf = skb_peek(&sock->sk->sk_receive_queue);
 
-	res = tipc_create(sock->sk->sk_net, newsock, 0);
+	res = tipc_create(sock_net(sock->sk), newsock, 0);
 	if (!res) {
 		struct tipc_sock *new_tsock = tipc_sk(newsock->sk);
 		struct tipc_portid id;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index ae58435..cb9d0cb 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -252,7 +252,7 @@ static struct sock *__unix_find_socket_byname(struct net *net,
 	sk_for_each(s, node, &unix_socket_table[hash ^ type]) {
 		struct unix_sock *u = unix_sk(s);
 
-		if (s->sk_net != net)
+		if (sock_net(s) != net)
 			continue;
 
 		if (u->addr->len == len &&
@@ -289,7 +289,7 @@ static struct sock *unix_find_socket_byinode(struct net *net, struct inode *i)
 		    &unix_socket_table[i->i_ino & (UNIX_HASH_SIZE - 1)]) {
 		struct dentry *dentry = unix_sk(s)->dentry;
 
-		if (s->sk_net != net)
+		if (sock_net(s) != net)
 			continue;
 
 		if(dentry && dentry->d_inode == i)
@@ -654,7 +654,7 @@ static int unix_release(struct socket *sock)
 static int unix_autobind(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk);
 	static u32 ordernum = 1;
 	struct unix_address * addr;
@@ -758,7 +758,7 @@ fail:
 static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
 	struct sock *sk = sock->sk;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk);
 	struct sockaddr_un *sunaddr=(struct sockaddr_un *)uaddr;
 	struct dentry * dentry = NULL;
@@ -899,7 +899,7 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 			      int alen, int flags)
 {
 	struct sock *sk = sock->sk;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	struct sockaddr_un *sunaddr=(struct sockaddr_un*)addr;
 	struct sock *other;
 	unsigned hash;
@@ -996,7 +996,7 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 {
 	struct sockaddr_un *sunaddr=(struct sockaddr_un *)uaddr;
 	struct sock *sk = sock->sk;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk), *newu, *otheru;
 	struct sock *newsk = NULL;
 	struct sock *other = NULL;
@@ -1025,7 +1025,7 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 	err = -ENOMEM;
 
 	/* create new sock for complete connection */
-	newsk = unix_create1(sk->sk_net, NULL);
+	newsk = unix_create1(sock_net(sk), NULL);
 	if (newsk == NULL)
 		goto out;
 
@@ -1312,7 +1312,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
-	struct net *net = sk->sk_net;
+	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk);
 	struct sockaddr_un *sunaddr=msg->msg_name;
 	struct sock *other = NULL;
@@ -2022,7 +2022,7 @@ static struct sock *unix_seq_idx(struct unix_iter_state *iter, loff_t pos)
 	struct sock *s;
 
 	for (s = first_unix_socket(&iter->i); s; s = next_unix_socket(&iter->i, s)) {
-		if (s->sk_net != iter->p.net)
+		if (sock_net(s) != iter->p.net)
 			continue;
 		if (off == pos)
 			return s;
@@ -2050,7 +2050,7 @@ static void *unix_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		sk = first_unix_socket(&iter->i);
 	else
 		sk = next_unix_socket(&iter->i, sk);
-	while (sk && (sk->sk_net != iter->p.net))
+	while (sk && (sock_net(sk) != iter->p.net))
 		sk = next_unix_socket(&iter->i, sk);
 	return sk;
 }
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 7a46ea7..6ba67c5 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -549,7 +549,7 @@ static struct sock *x25_make_new(struct sock *osk)
 	if (osk->sk_type != SOCK_SEQPACKET)
 		goto out;
 
-	if ((sk = x25_alloc_socket(osk->sk_net)) == NULL)
+	if ((sk = x25_alloc_socket(sock_net(osk))) == NULL)
 		goto out;
 
 	x25 = x25_sk(sk);
-- 
1.4.4.4

