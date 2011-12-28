From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: [PATCH RFC] IPv6: RTM_GETROUTE NLM_F_MATCH handled as stated in RFC
 3549
Date: Wed, 28 Dec 2011 16:01:55 +0200
Message-ID: <1325080915.26559.43.camel@hakki>
Reply-To: matti.vaittinen@nsn.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:13574 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246Ab1L1OLj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 09:11:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dee Ho!

RFC 3549 states:

Additional flag bits for GET requests on config information in
   the FEC.
          NLM_F_ROOT     Return the complete table instead of a
                         single entry.
          NLM_F_MATCH    Return all entries matching criteria passed in
                         message content.
          NLM_F_ATOMIC   Return an atomic snapshot of the table being
                         referenced.  This may require special
                         privileges because it has the potential to
                         interrupt service in the FE for a longer time.

   Convenience macros for flag bits:
          NLM_F_DUMP     This is NLM_F_ROOT or'ed with NLM_F_MATCH

However, currently requests with NLM_F_ROOT or NLM_F_MATCH or both 
(NLM_F_DUMP) specified will return all the (routing) entries.


To me it sounds that the NLM_F_MATCH was originally meant to
allow user to ask only entries (routes) fulfilling conditions given in 
request. This would further simplify userland applications which need 
to get only certain entries - and I believe that is often the case. 
I believe the current operation which differs from RFC makes netlink 
socket usage even more confusing. (There really is not too much 
up-to-date documentation telling how these requests+all the attributes
work).

This patch makes ipv6 module to return only routes which match 
attributes / filled fields in RTM_GETROUTE, if NLM_F_MATCH is 
specified and NLM_F_ROOT is not. This patch has not been tested, 
and is meant more to be for visualization of what I thought of doing.
If the NLM_F_MATCH support is considered to be good idea, then I 
will check this more thoroughly and send another patch.

I assume this would not break *many* existing userspace applications, 
since specifying NLM_F_MATCH (especially with no NLM_F_ROOT) sounds 
pretty stupid - if no entries should be filtered.

I checked iproute2, and it uses NLM_F_DUMP and does filtering entries 
in userspace - thus it is not affected. 

I guess this same idea could be brought in RTM_GETADDR and RTM_GETLINK 
too? Maybe also on IPv4 side? 

Any comments? 


















This patch demonstrates how RTM_GETROUTE request behaviour for IPv6 
could be changed to better match RFC 3549 when NLM_F_MATCH flag is 
specified.

"NLM_F_MATCH    Return all entries matching criteria passed in
                         message content."

Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>
---

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 2ad92ca..27313ad 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -139,12 +139,21 @@ extern void			rt6_pmtu_discovery(const struct in6_addr *daddr,
 struct netlink_callback;
 
 struct rt6_rtnl_dump_arg {
+	long maxtbl;
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
 	struct net *net;
 };
+struct rt6_rtnl_match_arg {
+	long maxtbl;
+	struct sk_buff *skb;
+	struct netlink_callback *cb;
+	struct net *net;
+	struct fib6_config *cfg;
+};
 
 extern int rt6_dump_route(struct rt6_info *rt, void *p_arg);
+extern int rt6_dump_route_if_match(struct rt6_info *rt, void *p_arg);
 extern void rt6_ifdown(struct net *net, struct net_device *dev);
 extern void rt6_mtu_change(struct net_device *dev, unsigned mtu);
 extern void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 2783631..13bea56 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -268,7 +268,26 @@ static void __net_init fib6_tables_init(struct net *net)
 }
 
 #endif
+static int fib6_dump_node_if_match(struct fib6_walker_t *w)
+{
+	int res;
+	struct rt6_info *rt;
+
+	for (rt = w->leaf; rt; rt = rt->dst.rt6_next) {
+		res = rt6_dump_route_if_match(rt, w->args);
+		if (res < 0) {
+			/* Frame is full or request was not parsed correctly.
+			 * Anyways, suspend walking
+			 */
+			w->leaf = rt;
+			return 1;
+		}
+		WARN_ON(res == 0);
+	}
+	w->leaf = NULL;
+	return 0;
 
+}
 static int fib6_dump_node(struct fib6_walker_t *w)
 {
 	int res;
@@ -292,11 +311,14 @@ static void fib6_dump_end(struct netlink_callback *cb)
 	struct fib6_walker_t *w = (void*)cb->args[2];
 
 	if (w) {
+		if (w->func == fib6_dump_node_if_match)
+			kfree(((struct rt6_rtnl_match_arg *)w->args)->cfg);
 		if (cb->args[4]) {
 			cb->args[4] = 0;
 			fib6_walker_unlink(w);
 		}
 		cb->args[2] = 0;
+		kfree(w->args);
 		kfree(w);
 	}
 	cb->done = (void*)cb->args[3];
@@ -356,16 +378,13 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net *net = sock_net(skb->sk);
 	unsigned int h, s_h;
 	unsigned int e = 0, s_e;
-	struct rt6_rtnl_dump_arg arg;
+	struct rt6_rtnl_dump_arg *arg;
 	struct fib6_walker_t *w;
 	struct fib6_table *tb;
 	struct hlist_node *node;
 	struct hlist_head *head;
 	int res = 0;
 
-	s_h = cb->args[0];
-	s_e = cb->args[1];
-
 	w = (void *)cb->args[2];
 	if (!w) {
 		/* New dump:
@@ -381,17 +400,57 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 		w = kzalloc(sizeof(*w), GFP_ATOMIC);
 		if (!w)
 			return -ENOMEM;
-		w->func = fib6_dump_node;
+		if (cb->nlh && (cb->nlh->nlmsg_flags & NLM_F_MATCH) &&
+		    !(cb->nlh->nlmsg_flags & NLM_F_ROOT) &&
+		    nlmsg_len(cb->nlh) >= sizeof(struct rtmsg)) {
+
+			struct rtmsg *rtm = nlmsg_data(cb->nlh);
+
+			cb->done = fib6_dump_done;
+			w->args = kzalloc(sizeof(struct rt6_rtnl_match_arg), GFP_ATOMIC);
+			if (!w->args) {
+				kfree(w);
+				return -ENOMEM;
+			}
+			((struct rt6_rtnl_match_arg *)w->args)->cfg =
+			    kzalloc(sizeof(struct fib6_config), GFP_ATOMIC);
+
+			if (!((struct rt6_rtnl_match_arg *)w->args)->cfg) {
+				kfree(w->args);
+				kfree(w);
+				return -ENOMEM;
+			}
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+			if (rtm->rtm_table <= FIB6_TABLE_HASHSZ) {
+				cb->args[0] = rtm->rtm_table;
+				((struct rt6_rtnl_match_arg *)w->args)->maxtbl =
+				    (rtm->rtm_table) ? rtm->rtm_table+1 : FIB6_TABLE_HASHSZ;
+			}
+#endif
+
+			((struct rt6_rtnl_match_arg *)w->args)->cfg->fc_table = 0xFFFFFFFF;
+			w->func = fib6_dump_node_if_match;
+		} else {
+			w->func = fib6_dump_node;
+			w->args = kzalloc(sizeof(struct rt6_rtnl_dump_arg), GFP_ATOMIC);
+			if (!w->args) {
+				kfree(w);
+				return -ENOMEM;
+			}
+			((struct rt6_rtnl_dump_arg *)w->args)->maxtbl = FIB6_TABLE_HASHSZ;
+		}
 		cb->args[2] = (long)w;
 	}
+	arg = (struct rt6_rtnl_dump_arg *)w->args;
 
-	arg.skb = skb;
-	arg.cb = cb;
-	arg.net = net;
-	w->args = &arg;
+	s_h = cb->args[0];
+	s_e = cb->args[1];
+	arg->skb = skb;
+	arg->cb = cb;
+	arg->net = net;
 
 	rcu_read_lock();
-	for (h = s_h; h < FIB6_TABLE_HASHSZ; h++, s_e = 0) {
+	for (h = s_h; h < arg->maxtbl; h++, s_e = 0) {
 		e = 0;
 		head = &net->ipv6.fib_table_hash[h];
 		hlist_for_each_entry_rcu(tb, node, head, tb6_hlist) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 35b07cc..a71d44d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2350,7 +2350,154 @@ static inline size_t rt6_nlmsg_size(void)
 	       + RTAX_MAX * nla_total_size(4) /* RTA_METRICS */
 	       + nla_total_size(sizeof(struct rta_cacheinfo));
 }
+static int rt6_cmp_fill_node(struct net *net,
+		     struct sk_buff *skb, struct rt6_info *rt,
+		     u32 pid,
+		     int prefix, struct fib6_config *cfg)
+{
+	struct rtmsg *rtm;
+	struct nlmsghdr *nlh;
+	long expires;
+	u32 table;
+	struct neighbour *n = NULL;
+	u32 seq;
+	struct in6_addr gwaddr;
+
+
+	if (prefix) {	/* user wants prefix routes only */
+		if (!(rt->rt6i_flags & RTF_PREFIX_RT)) {
+			/* success since this is not a prefix route */
+			return 1;
+		}
+	}
+	if (cfg->fc_dst_len && cfg->fc_dst_len != rt->rt6i_dst.plen)
+		return 1;
+
+	if (cfg->fc_src_len && cfg->fc_src_len != rt->rt6i_src.plen)
+		return 1;
+	cfg->fc_flags = ((~RTF_UP)&cfg->fc_flags);
+	if (cfg->fc_flags && cfg->fc_flags != rt->rt6i_flags)
+		return 1;
+
+	if (cfg->fc_protocol && cfg->fc_protocol != rt->rt6i_protocol)
+		return 1;
+
+	if (cfg->fc_flags & RTF_GATEWAY) {
+		rcu_read_lock();
+		n = dst_get_neighbour_noref(&rt->dst);
+		if (!n) {
+			rcu_read_unlock();
+			return 1;
+		}
+		gwaddr = *(struct in6_addr *)&(n->primary_key);
+		rcu_read_unlock();
+		if (memcmp(&gwaddr, &cfg->fc_gateway, 16))
+			return 1;
+	}
+
+	if (cfg->fc_metric && cfg->fc_metric != rt->rt6i_metric)
+		return 1;
+
+	if (cfg->fc_ifindex)
+	   if (!rt->dst.dev || rt->rt6i_dev->ifindex != cfg->fc_ifindex)
+			return 1;
+
+	if (memcmp(&in6addr_any, &cfg->fc_dst, sizeof(struct in6_addr)))
+		if (memcmp(&cfg->fc_dst, &rt->rt6i_dst.addr, sizeof(struct in6_addr)))
+			return 1;
+
+#ifdef CONFIG_IPV6_SUBTREES
+	if (memcmp(&in6addr_any, &cfg->fc_src, sizeof(struct in6_addr)))
+		if (memcmp(&cfg->fc_src, &rt->rt6i_src.addr, sizeof(struct in6_addr)))
+			return 1;
+#endif
+	if (memcmp(&in6addr_any, &cfg->fc_prefsrc, sizeof(struct in6_addr)))
+		if (!rt->rt6i_prefsrc.plen ||
+		    memcmp(&rt->rt6i_prefsrc.addr, &cfg->fc_prefsrc, sizeof(struct in6_addr)))
+			return 1;
+	/* All values checked, now allocate and fill NLMSG */
+	seq = cfg->fc_nlinfo.nlh->nlmsg_seq;
+
+	nlh = nlmsg_put(skb, pid, seq, RTM_NEWROUTE, sizeof(*rtm), NLM_F_MULTI);
+	if (nlh == NULL)
+		return -EMSGSIZE;
+
+	rtm = nlmsg_data(nlh);
+	rtm->rtm_family = AF_INET6;
+	rtm->rtm_dst_len = rt->rt6i_dst.plen;
+	rtm->rtm_src_len = rt->rt6i_src.plen;
+	rtm->rtm_tos = 0;
+	if (rt->rt6i_table)
+		table = rt->rt6i_table->tb6_id;
+	else
+		table = RT6_TABLE_UNSPEC;
+	rtm->rtm_table = table;
+	NLA_PUT_U32(skb, RTA_TABLE, table);
+	if (rt->rt6i_flags&RTF_REJECT)
+		rtm->rtm_type = RTN_UNREACHABLE;
+	else if (rt->rt6i_flags&RTF_LOCAL)
+		rtm->rtm_type = RTN_LOCAL;
+	else if (rt->rt6i_dev && (rt->rt6i_dev->flags&IFF_LOOPBACK))
+		rtm->rtm_type = RTN_LOCAL;
+	else
+		rtm->rtm_type = RTN_UNICAST;
+	rtm->rtm_flags = 0;
+	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
+	rtm->rtm_protocol = rt->rt6i_protocol;
+	if (rt->rt6i_flags&RTF_DYNAMIC)
+		rtm->rtm_protocol = RTPROT_REDIRECT;
+	else if (rt->rt6i_flags & RTF_ADDRCONF)
+		rtm->rtm_protocol = RTPROT_KERNEL;
+	else if (rt->rt6i_flags&RTF_DEFAULT)
+		rtm->rtm_protocol = RTPROT_RA;
+
+	if (rt->rt6i_flags&RTF_CACHE)
+		rtm->rtm_flags |= RTM_F_CLONED;
+
+	if (rtm->rtm_dst_len)
+		NLA_PUT(skb, RTA_DST, 16, &rt->rt6i_dst.addr);
+#ifdef CONFIG_IPV6_SUBTREES
+	if (rtm->rtm_src_len)
+		NLA_PUT(skb, RTA_SRC, 16, &rt->rt6i_src.addr);
+#endif
+	if (rt->rt6i_prefsrc.plen) {
+		struct in6_addr saddr_buf;
+		saddr_buf = rt->rt6i_prefsrc.addr;
+		NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
+	}
 
+	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
+		goto nla_put_failure;
+
+	rcu_read_lock();
+	n = dst_get_neighbour_noref(&rt->dst);
+	if (n)
+		NLA_PUT(skb, RTA_GATEWAY, 16, &n->primary_key);
+	rcu_read_unlock();
+
+	if (rt->dst.dev)
+		NLA_PUT_U32(skb, RTA_OIF, rt->rt6i_dev->ifindex);
+
+	NLA_PUT_U32(skb, RTA_PRIORITY, rt->rt6i_metric);
+
+	if (!(rt->rt6i_flags & RTF_EXPIRES))
+		expires = 0;
+	else if (rt->rt6i_expires - jiffies < INT_MAX)
+		expires = rt->rt6i_expires - jiffies;
+	else
+		expires = INT_MAX;
+
+	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, 0, 0,
+			       expires, rt->dst.error) < 0)
+		goto nla_put_failure;
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+
+}
 static int rt6_fill_node(struct net *net,
 			 struct sk_buff *skb, struct rt6_info *rt,
 			 struct in6_addr *dst, struct in6_addr *src,
@@ -2478,7 +2625,34 @@ nla_put_failure:
 	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
 }
+int rt6_dump_route_if_match(struct rt6_info *rt, void *p_arg)
+{
+	struct rt6_rtnl_match_arg *arg = (struct rt6_rtnl_match_arg *) p_arg;
+	int prefix;
+	int err;
 
+	if (nlmsg_len(arg->cb->nlh) >= sizeof(struct rtmsg)) {
+		struct rtmsg *rtm = nlmsg_data(arg->cb->nlh);
+		prefix = (rtm->rtm_flags & RTM_F_PREFIX) != 0;
+	} else
+		prefix = 0;
+	/* this is a bit of a hack. But we do not want to
+	 * evaluate config struct for same nlmsg
+	 * for each route we fetch from fib.
+	 * It's enough to do it once.
+	 */
+	if (0xFFFFFFFF == arg->cfg->fc_table) {
+		arg->cfg->fc_table = 0;
+		err = rtm_to_fib6_config(arg->cb->skb,
+		    (struct nlmsghdr *)arg->cb->nlh, arg->cfg);
+		if (err)
+			return err;
+	}
+	return rt6_cmp_fill_node(arg->net,
+		     arg->skb, rt,
+		     NETLINK_CB(arg->cb->skb).pid,
+		     prefix, arg->cfg);
+}
 int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 {
 	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) p_arg;
@@ -2489,7 +2663,6 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 		prefix = (rtm->rtm_flags & RTM_F_PREFIX) != 0;
 	} else
 		prefix = 0;
-
 	return rt6_fill_node(arg->net,
 		     arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
 		     NETLINK_CB(arg->cb->skb).pid, arg->cb->nlh->nlmsg_seq,
