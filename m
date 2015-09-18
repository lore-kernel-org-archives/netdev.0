From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 06/14] x_tables: Use par->net instead of computing from the passed net devices
Date: Fri, 18 Sep 2015 11:05:52 -0500
Message-ID: <1442592360-2575-6-git-send-email-ebiederm@xmission.com>
References: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/bridge/netfilter/ebt_log.c     |  2 +-
 net/bridge/netfilter/ebt_nflog.c   |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c  |  2 +-
 net/ipv4/netfilter/ipt_rpfilter.c  |  5 ++---
 net/ipv6/netfilter/ip6t_REJECT.c   |  2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c |  2 +-
 net/ipv6/netfilter/ip6t_rpfilter.c |  6 +++---
 net/netfilter/ipset/ip_set_core.c  |  9 +++------
 net/netfilter/xt_LOG.c             |  2 +-
 net/netfilter/xt_NFLOG.c           |  2 +-
 net/netfilter/xt_TCPMSS.c          |  2 +-
 net/netfilter/xt_TPROXY.c          | 24 ++++++++++++------------
 net/netfilter/xt_addrtype.c        |  4 ++--
 net/netfilter/xt_connlimit.c       |  2 +-
 net/netfilter/xt_osf.c             |  2 +-
 net/netfilter/xt_recent.c          |  2 +-
 net/netfilter/xt_socket.c          | 14 ++++++++------
 17 files changed, 41 insertions(+), 43 deletions(-)

diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 17f2e4bc2a29..0ad639a96142 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -180,7 +180,7 @@ ebt_log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_log_info *info = par->targinfo;
 	struct nf_loginfo li;
-	struct net *net = dev_net(par->in ? par->in : par->out);
+	struct net *net = par->net;
 
 	li.type = NF_LOG_TYPE_LOG;
 	li.u.log.level = info->loglevel;
diff --git a/net/bridge/netfilter/ebt_nflog.c b/net/bridge/netfilter/ebt_nflog.c
index 59ac7952010d..54816150608e 100644
--- a/net/bridge/netfilter/ebt_nflog.c
+++ b/net/bridge/netfilter/ebt_nflog.c
@@ -24,7 +24,7 @@ ebt_nflog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ebt_nflog_info *info = par->targinfo;
 	struct nf_loginfo li;
-	struct net *net = dev_net(par->in ? par->in : par->out);
+	struct net *net = par->net;
 
 	li.type = NF_LOG_TYPE_ULOG;
 	li.u.ulog.copy_len = info->len;
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index f471a0628c75..dfab314981e9 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -258,7 +258,7 @@ static unsigned int
 synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_synproxy_info *info = par->targinfo;
-	struct synproxy_net *snet = synproxy_pernet(dev_net(par->in));
+	struct synproxy_net *snet = synproxy_pernet(par->net);
 	struct synproxy_options opts = {};
 	struct tcphdr *th, _th;
 
diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
index 8618fd150c96..74dd6671b66d 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -32,12 +32,11 @@ static __be32 rpfilter_get_saddr(__be32 addr)
 	return addr;
 }
 
-static bool rpfilter_lookup_reverse(struct flowi4 *fl4,
+static bool rpfilter_lookup_reverse(struct net *net, struct flowi4 *fl4,
 				const struct net_device *dev, u8 flags)
 {
 	struct fib_result res;
 	bool dev_match;
-	struct net *net = dev_net(dev);
 	int ret __maybe_unused;
 
 	if (fib_lookup(net, fl4, &res, FIB_LOOKUP_IGNORE_LINKSTATE))
@@ -98,7 +97,7 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	flow.flowi4_tos = RT_TOS(iph->tos);
 	flow.flowi4_scope = RT_SCOPE_UNIVERSE;
 
-	return rpfilter_lookup_reverse(&flow, par->in, info->flags) ^ invert;
+	return rpfilter_lookup_reverse(par->net, &flow, par->in, info->flags) ^ invert;
 }
 
 static int rpfilter_check(const struct xt_mtchk_param *par)
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 0ed841a3fa33..db29bbf41b59 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -39,7 +39,7 @@ static unsigned int
 reject_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ip6t_reject_info *reject = par->targinfo;
-	struct net *net = dev_net((par->in != NULL) ? par->in : par->out);
+	struct net *net = par->net;
 
 	switch (reject->with) {
 	case IP6T_ICMP6_NO_ROUTE:
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 4c9f3e79d75f..41451809b37c 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -275,7 +275,7 @@ static unsigned int
 synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_synproxy_info *info = par->targinfo;
-	struct synproxy_net *snet = synproxy_pernet(dev_net(par->in));
+	struct synproxy_net *snet = synproxy_pernet(par->net);
 	struct synproxy_options opts = {};
 	struct tcphdr *th, _th;
 
diff --git a/net/ipv6/netfilter/ip6t_rpfilter.c b/net/ipv6/netfilter/ip6t_rpfilter.c
index 790e0c6b19e1..1ee1b25df096 100644
--- a/net/ipv6/netfilter/ip6t_rpfilter.c
+++ b/net/ipv6/netfilter/ip6t_rpfilter.c
@@ -26,7 +26,7 @@ static bool rpfilter_addr_unicast(const struct in6_addr *addr)
 	return addr_type & IPV6_ADDR_UNICAST;
 }
 
-static bool rpfilter_lookup_reverse6(const struct sk_buff *skb,
+static bool rpfilter_lookup_reverse6(struct net *net, const struct sk_buff *skb,
 				     const struct net_device *dev, u8 flags)
 {
 	struct rt6_info *rt;
@@ -53,7 +53,7 @@ static bool rpfilter_lookup_reverse6(const struct sk_buff *skb,
 		lookup_flags |= RT6_LOOKUP_F_IFACE;
 	}
 
-	rt = (void *) ip6_route_lookup(dev_net(dev), &fl6, lookup_flags);
+	rt = (void *) ip6_route_lookup(net, &fl6, lookup_flags);
 	if (rt->dst.error)
 		goto out;
 
@@ -93,7 +93,7 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (unlikely(saddrtype == IPV6_ADDR_ANY))
 		return true ^ invert; /* not routable: forward path will drop it */
 
-	return rpfilter_lookup_reverse6(skb, par->in, info->flags) ^ invert;
+	return rpfilter_lookup_reverse6(par->net, skb, par->in, info->flags) ^ invert;
 }
 
 static int rpfilter_check(const struct xt_mtchk_param *par)
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 338b4047776f..69ab9c2634e1 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -519,8 +519,7 @@ int
 ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
 	    const struct xt_action_param *par, struct ip_set_adt_opt *opt)
 {
-	struct ip_set *set = ip_set_rcu_get(
-			dev_net(par->in ? par->in : par->out), index);
+	struct ip_set *set = ip_set_rcu_get(par->net, index);
 	int ret = 0;
 
 	BUG_ON(!set);
@@ -558,8 +557,7 @@ int
 ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
 	   const struct xt_action_param *par, struct ip_set_adt_opt *opt)
 {
-	struct ip_set *set = ip_set_rcu_get(
-			dev_net(par->in ? par->in : par->out), index);
+	struct ip_set *set = ip_set_rcu_get(par->net, index);
 	int ret;
 
 	BUG_ON(!set);
@@ -581,8 +579,7 @@ int
 ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
 	   const struct xt_action_param *par, struct ip_set_adt_opt *opt)
 {
-	struct ip_set *set = ip_set_rcu_get(
-			dev_net(par->in ? par->in : par->out), index);
+	struct ip_set *set = ip_set_rcu_get(par->net, index);
 	int ret = 0;
 
 	BUG_ON(!set);
diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index c13b79440ede..1763ab82bcd7 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -33,7 +33,7 @@ log_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_log_info *loginfo = par->targinfo;
 	struct nf_loginfo li;
-	struct net *net = dev_net(par->in ? par->in : par->out);
+	struct net *net = par->net;
 
 	li.type = NF_LOG_TYPE_LOG;
 	li.u.log.level = loginfo->level;
diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
index fb7497c928a0..a1fa2c800cb9 100644
--- a/net/netfilter/xt_NFLOG.c
+++ b/net/netfilter/xt_NFLOG.c
@@ -26,7 +26,7 @@ nflog_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_nflog_info *info = par->targinfo;
 	struct nf_loginfo li;
-	struct net *net = dev_net(par->in ? par->in : par->out);
+	struct net *net = par->net;
 
 	li.type		     = NF_LOG_TYPE_ULOG;
 	li.u.ulog.copy_len   = info->len;
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 8c02501a530f..b7c43def0dc6 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -108,7 +108,7 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 		return -1;
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
-		struct net *net = dev_net(par->in ? par->in : par->out);
+		struct net *net = par->net;
 		unsigned int in_mtu = tcpmss_reverse_mtu(net, skb, family);
 
 		if (dst_mtu(skb_dst(skb)) <= minlen) {
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index d0c96c5ae29a..3ab591e73ec0 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -250,8 +250,8 @@ nf_tproxy_get_sock_v6(struct net *net, const u8 protocol,
  * no such listener is found, or NULL if the TCP header is incomplete.
  */
 static struct sock *
-tproxy_handle_time_wait4(struct sk_buff *skb, __be32 laddr, __be16 lport,
-			struct sock *sk)
+tproxy_handle_time_wait4(struct net *net, struct sk_buff *skb,
+			 __be32 laddr, __be16 lport, struct sock *sk)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr _hdr, *hp;
@@ -267,7 +267,7 @@ tproxy_handle_time_wait4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 		 * to a listener socket if there's one */
 		struct sock *sk2;
 
-		sk2 = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
+		sk2 = nf_tproxy_get_sock_v4(net, iph->protocol,
 					    iph->saddr, laddr ? laddr : iph->daddr,
 					    hp->source, lport ? lport : hp->dest,
 					    skb->dev, NFT_LOOKUP_LISTENER);
@@ -290,7 +290,7 @@ nf_tproxy_assign_sock(struct sk_buff *skb, struct sock *sk)
 }
 
 static unsigned int
-tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport,
+tproxy_tg4(struct net *net, struct sk_buff *skb, __be32 laddr, __be16 lport,
 	   u_int32_t mark_mask, u_int32_t mark_value)
 {
 	const struct iphdr *iph = ip_hdr(skb);
@@ -305,7 +305,7 @@ tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 	 * addresses, this happens if the redirect already happened
 	 * and the current packet belongs to an already established
 	 * connection */
-	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
+	sk = nf_tproxy_get_sock_v4(net, iph->protocol,
 				   iph->saddr, iph->daddr,
 				   hp->source, hp->dest,
 				   skb->dev, NFT_LOOKUP_ESTABLISHED);
@@ -317,11 +317,11 @@ tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 	/* UDP has no TCP_TIME_WAIT state, so we never enter here */
 	if (sk && sk->sk_state == TCP_TIME_WAIT)
 		/* reopening a TIME_WAIT connection needs special handling */
-		sk = tproxy_handle_time_wait4(skb, laddr, lport, sk);
+		sk = tproxy_handle_time_wait4(net, skb, laddr, lport, sk);
 	else if (!sk)
 		/* no, there's no established connection, check if
 		 * there's a listener on the redirected addr/port */
-		sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
+		sk = nf_tproxy_get_sock_v4(net, iph->protocol,
 					   iph->saddr, laddr,
 					   hp->source, lport,
 					   skb->dev, NFT_LOOKUP_LISTENER);
@@ -351,7 +351,7 @@ tproxy_tg4_v0(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tproxy_target_info *tgi = par->targinfo;
 
-	return tproxy_tg4(skb, tgi->laddr, tgi->lport, tgi->mark_mask, tgi->mark_value);
+	return tproxy_tg4(par->net, skb, tgi->laddr, tgi->lport, tgi->mark_mask, tgi->mark_value);
 }
 
 static unsigned int
@@ -359,7 +359,7 @@ tproxy_tg4_v1(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tproxy_target_info_v1 *tgi = par->targinfo;
 
-	return tproxy_tg4(skb, tgi->laddr.ip, tgi->lport, tgi->mark_mask, tgi->mark_value);
+	return tproxy_tg4(par->net, skb, tgi->laddr.ip, tgi->lport, tgi->mark_mask, tgi->mark_value);
 }
 
 #ifdef XT_TPROXY_HAVE_IPV6
@@ -429,7 +429,7 @@ tproxy_handle_time_wait6(struct sk_buff *skb, int tproto, int thoff,
 		 * to a listener socket if there's one */
 		struct sock *sk2;
 
-		sk2 = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+		sk2 = nf_tproxy_get_sock_v6(par->net, tproto,
 					    &iph->saddr,
 					    tproxy_laddr6(skb, &tgi->laddr.in6, &iph->daddr),
 					    hp->source,
@@ -472,7 +472,7 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 	 * addresses, this happens if the redirect already happened
 	 * and the current packet belongs to an already established
 	 * connection */
-	sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+	sk = nf_tproxy_get_sock_v6(par->net, tproto,
 				   &iph->saddr, &iph->daddr,
 				   hp->source, hp->dest,
 				   par->in, NFT_LOOKUP_ESTABLISHED);
@@ -487,7 +487,7 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 	else if (!sk)
 		/* no there's no established connection, check if
 		 * there's a listener on the redirected addr/port */
-		sk = nf_tproxy_get_sock_v6(dev_net(skb->dev), tproto,
+		sk = nf_tproxy_get_sock_v6(par->net, tproto,
 					   &iph->saddr, laddr,
 					   hp->source, lport,
 					   par->in, NFT_LOOKUP_LISTENER);
diff --git a/net/netfilter/xt_addrtype.c b/net/netfilter/xt_addrtype.c
index 5b4743cc0436..11d6091991a4 100644
--- a/net/netfilter/xt_addrtype.c
+++ b/net/netfilter/xt_addrtype.c
@@ -125,7 +125,7 @@ static inline bool match_type(struct net *net, const struct net_device *dev,
 static bool
 addrtype_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	struct net *net = dev_net(par->in ? par->in : par->out);
+	struct net *net = par->net;
 	const struct xt_addrtype_info *info = par->matchinfo;
 	const struct iphdr *iph = ip_hdr(skb);
 	bool ret = true;
@@ -143,7 +143,7 @@ addrtype_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
 static bool
 addrtype_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	struct net *net = dev_net(par->in ? par->in : par->out);
+	struct net *net = par->net;
 	const struct xt_addrtype_info_v1 *info = par->matchinfo;
 	const struct iphdr *iph;
 	const struct net_device *dev = NULL;
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 075d89d94d28..213db252e5be 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -317,7 +317,7 @@ static int count_them(struct net *net,
 static bool
 connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	struct net *net = dev_net(par->in ? par->in : par->out);
+	struct net *net = par->net;
 	const struct xt_connlimit_info *info = par->matchinfo;
 	union nf_inet_addr addr;
 	struct nf_conntrack_tuple tuple;
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 0778855ea5e7..df8801e02a32 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -200,7 +200,7 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 	unsigned char opts[MAX_IPOPTLEN];
 	const struct xt_osf_finger *kf;
 	const struct xt_osf_user_finger *f;
-	struct net *net = dev_net(p->in ? p->in : p->out);
+	struct net *net = p->net;
 
 	if (!info)
 		return false;
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 45e1b30e4fb2..d725a27743a1 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -237,7 +237,7 @@ static void recent_table_flush(struct recent_table *t)
 static bool
 recent_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	struct net *net = dev_net(par->in ? par->in : par->out);
+	struct net *net = par->net;
 	struct recent_net *recent_net = recent_pernet(net);
 	const struct xt_recent_mtinfo_v1 *info = par->matchinfo;
 	struct recent_table *t;
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 43e26c881100..2ec08f04b816 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -143,7 +143,8 @@ static bool xt_socket_sk_is_transparent(struct sock *sk)
 	}
 }
 
-static struct sock *xt_socket_lookup_slow_v4(const struct sk_buff *skb,
+static struct sock *xt_socket_lookup_slow_v4(struct net *net,
+					     const struct sk_buff *skb,
 					     const struct net_device *indev)
 {
 	const struct iphdr *iph = ip_hdr(skb);
@@ -197,7 +198,7 @@ static struct sock *xt_socket_lookup_slow_v4(const struct sk_buff *skb,
 	}
 #endif
 
-	return xt_socket_get_sock_v4(dev_net(skb->dev), protocol, saddr, daddr,
+	return xt_socket_get_sock_v4(net, protocol, saddr, daddr,
 				     sport, dport, indev);
 }
 
@@ -209,7 +210,7 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 	struct sock *sk = skb->sk;
 
 	if (!sk)
-		sk = xt_socket_lookup_slow_v4(skb, par->in);
+		sk = xt_socket_lookup_slow_v4(par->net, skb, par->in);
 	if (sk) {
 		bool wildcard;
 		bool transparent = true;
@@ -335,7 +336,8 @@ xt_socket_get_sock_v6(struct net *net, const u8 protocol,
 	return NULL;
 }
 
-static struct sock *xt_socket_lookup_slow_v6(const struct sk_buff *skb,
+static struct sock *xt_socket_lookup_slow_v6(struct net *net,
+					     const struct sk_buff *skb,
 					     const struct net_device *indev)
 {
 	__be16 uninitialized_var(dport), uninitialized_var(sport);
@@ -371,7 +373,7 @@ static struct sock *xt_socket_lookup_slow_v6(const struct sk_buff *skb,
 		return NULL;
 	}
 
-	return xt_socket_get_sock_v6(dev_net(skb->dev), tproto, saddr, daddr,
+	return xt_socket_get_sock_v6(net, tproto, saddr, daddr,
 				     sport, dport, indev);
 }
 
@@ -383,7 +385,7 @@ socket_mt6_v1_v2_v3(const struct sk_buff *skb, struct xt_action_param *par)
 	struct sock *sk = skb->sk;
 
 	if (!sk)
-		sk = xt_socket_lookup_slow_v6(skb, par->in);
+		sk = xt_socket_lookup_slow_v6(par->net, skb, par->in);
 	if (sk) {
 		bool wildcard;
 		bool transparent = true;
-- 
2.2.1

