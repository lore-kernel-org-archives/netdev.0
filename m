From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/2] net: core: rcu-ify rtnl af_ops
Date: Mon, 16 Oct 2017 15:44:36 +0200
Message-ID: <20171016134436.25282-3-fw@strlen.de>
References: <20171016134436.25282-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:35784 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752437AbdJPNo1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 09:44:27 -0400
In-Reply-To: <20171016134436.25282-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnl af_ops currently rely on rtnl mutex: unregister (called from module
exit functions) takes the rtnl mutex and all users that do af_ops lookup
also take the rtnl mutex. IOW, parallel rmmod will block until doit()
callback is done.

As none of the af_ops implementation sleep we can use rcu instead.

doit functions that need the af_ops can now use rcu instead of the
rtnl mutex provided the mutex isn't needed for other reasons.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 62 ++++++++++++++++++++++++++++++++++++++--------------
 net/ipv4/devinet.c   |  4 ++--
 2 files changed, 48 insertions(+), 18 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a49cad25e577..20b550d07fe3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -453,7 +453,7 @@ static const struct rtnl_af_ops *rtnl_af_lookup(const int family)
 {
 	const struct rtnl_af_ops *ops;
 
-	list_for_each_entry(ops, &rtnl_af_ops, list) {
+	list_for_each_entry_rcu(ops, &rtnl_af_ops, list) {
 		if (ops->family == family)
 			return ops;
 	}
@@ -470,7 +470,7 @@ static const struct rtnl_af_ops *rtnl_af_lookup(const int family)
 void rtnl_af_register(struct rtnl_af_ops *ops)
 {
 	rtnl_lock();
-	list_add_tail(&ops->list, &rtnl_af_ops);
+	list_add_tail_rcu(&ops->list, &rtnl_af_ops);
 	rtnl_unlock();
 }
 EXPORT_SYMBOL_GPL(rtnl_af_register);
@@ -482,8 +482,10 @@ EXPORT_SYMBOL_GPL(rtnl_af_register);
 void rtnl_af_unregister(struct rtnl_af_ops *ops)
 {
 	rtnl_lock();
-	list_del(&ops->list);
+	list_del_rcu(&ops->list);
 	rtnl_unlock();
+
+	synchronize_rcu();
 }
 EXPORT_SYMBOL_GPL(rtnl_af_unregister);
 
@@ -496,13 +498,15 @@ static size_t rtnl_link_get_af_size(const struct net_device *dev,
 	/* IFLA_AF_SPEC */
 	size = nla_total_size(sizeof(struct nlattr));
 
-	list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(af_ops, &rtnl_af_ops, list) {
 		if (af_ops->get_link_af_size) {
 			/* AF_* + nested data */
 			size += nla_total_size(sizeof(struct nlattr)) +
 				af_ops->get_link_af_size(dev, ext_filter_mask);
 		}
 	}
+	rcu_read_unlock();
 
 	return size;
 }
@@ -1393,7 +1397,7 @@ static int rtnl_fill_link_af(struct sk_buff *skb,
 	if (!af_spec)
 		return -EMSGSIZE;
 
-	list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+	list_for_each_entry_rcu(af_ops, &rtnl_af_ops, list) {
 		struct nlattr *af;
 		int err;
 
@@ -1516,12 +1520,16 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    nla_put_s32(skb, IFLA_NEW_NETNSID, *new_nsid) < 0)
 		goto nla_put_failure;
 
+	rcu_read_lock();
 	if (rtnl_fill_link_af(skb, dev, ext_filter_mask))
-		goto nla_put_failure;
+		goto nla_put_failure_rcu;
+	rcu_read_unlock();
 
 	nlmsg_end(skb, nlh);
 	return 0;
 
+nla_put_failure_rcu:
+	rcu_read_unlock();
 nla_put_failure:
 	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
@@ -1783,17 +1791,27 @@ static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
 		nla_for_each_nested(af, tb[IFLA_AF_SPEC], rem) {
 			const struct rtnl_af_ops *af_ops;
 
-			if (!(af_ops = rtnl_af_lookup(nla_type(af))))
+			rcu_read_lock();
+			af_ops = rtnl_af_lookup(nla_type(af));
+			if (!af_ops) {
+				rcu_read_unlock();
 				return -EAFNOSUPPORT;
+			}
 
-			if (!af_ops->set_link_af)
+			if (!af_ops->set_link_af) {
+				rcu_read_unlock();
 				return -EOPNOTSUPP;
+			}
 
 			if (af_ops->validate_link_af) {
 				err = af_ops->validate_link_af(dev, af);
-				if (err < 0)
+				if (err < 0) {
+					rcu_read_unlock();
 					return err;
+				}
 			}
+
+			rcu_read_unlock();
 		}
 	}
 
@@ -2251,13 +2269,18 @@ static int do_setlink(const struct sk_buff *skb,
 		nla_for_each_nested(af, tb[IFLA_AF_SPEC], rem) {
 			const struct rtnl_af_ops *af_ops;
 
+			rcu_read_lock();
+
 			if (!(af_ops = rtnl_af_lookup(nla_type(af))))
 				BUG();
 
 			err = af_ops->set_link_af(dev, af);
-			if (err < 0)
+			if (err < 0) {
+				rcu_read_unlock();
 				goto errout;
+			}
 
+			rcu_read_unlock();
 			status |= DO_SETLINK_NOTIFY;
 		}
 	}
@@ -4004,25 +4027,30 @@ static int rtnl_fill_statsinfo(struct sk_buff *skb, struct net_device *dev,
 		if (!attr)
 			goto nla_put_failure;
 
-		list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+		rcu_read_lock();
+		list_for_each_entry_rcu(af_ops, &rtnl_af_ops, list) {
 			if (af_ops->fill_stats_af) {
 				struct nlattr *af;
 				int err;
 
 				af = nla_nest_start(skb, af_ops->family);
-				if (!af)
+				if (!af) {
+					rcu_read_unlock();
 					goto nla_put_failure;
-
+				}
 				err = af_ops->fill_stats_af(skb, dev);
 
-				if (err == -ENODATA)
+				if (err == -ENODATA) {
 					nla_nest_cancel(skb, af);
-				else if (err < 0)
+				} else if (err < 0) {
+					rcu_read_unlock();
 					goto nla_put_failure;
+				}
 
 				nla_nest_end(skb, af);
 			}
 		}
+		rcu_read_unlock();
 
 		nla_nest_end(skb, attr);
 
@@ -4091,7 +4119,8 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 		/* for IFLA_STATS_AF_SPEC */
 		size += nla_total_size(0);
 
-		list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+		rcu_read_lock();
+		list_for_each_entry_rcu(af_ops, &rtnl_af_ops, list) {
 			if (af_ops->get_stats_af_size) {
 				size += nla_total_size(
 					af_ops->get_stats_af_size(dev));
@@ -4100,6 +4129,7 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 				size += nla_total_size(0);
 			}
 		}
+		rcu_read_unlock();
 	}
 
 	return size;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7ce22a2c07ce..6d9b072d903b 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1757,7 +1757,7 @@ static int inet_validate_link_af(const struct net_device *dev,
 	struct nlattr *a, *tb[IFLA_INET_MAX+1];
 	int err, rem;
 
-	if (dev && !__in_dev_get_rtnl(dev))
+	if (dev && !__in_dev_get_rcu(dev))
 		return -EAFNOSUPPORT;
 
 	err = nla_parse_nested(tb, IFLA_INET_MAX, nla, inet_af_policy, NULL);
@@ -1781,7 +1781,7 @@ static int inet_validate_link_af(const struct net_device *dev,
 
 static int inet_set_link_af(struct net_device *dev, const struct nlattr *nla)
 {
-	struct in_device *in_dev = __in_dev_get_rtnl(dev);
+	struct in_device *in_dev = __in_dev_get_rcu(dev);
 	struct nlattr *a, *tb[IFLA_INET_MAX+1];
 	int rem;
 
-- 
2.13.6
