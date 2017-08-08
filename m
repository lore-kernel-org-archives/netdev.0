From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 6/7] rtnetlink: add and use RTNL_FLAG_DOIT_UNLOCKED
Date: Tue,  8 Aug 2017 18:02:35 +0200
Message-ID: <20170808160236.28562-7-fw@strlen.de>
References: <20170808160236.28562-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:35542 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752840AbdHHQCj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 12:02:39 -0400
In-Reply-To: <20170808160236.28562-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow callers to tell rtnetlink core that its doit callback
should be invoked without holding rtnl mutex.

Make ipv6 the first user.

Signed-off-by: Florian Westphal <fw@strlen.de>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/rtnetlink.h |  4 ++++
 net/core/rtnetlink.c    | 15 +++++++++++++++
 net/ipv6/route.c        |  7 ++++---
 3 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index ac32460a0adb..21837ca68ecc 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -8,6 +8,10 @@ typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *,
 			      struct netlink_ext_ack *);
 typedef int (*rtnl_dumpit_func)(struct sk_buff *, struct netlink_callback *);
 
+enum rtnl_link_flags {
+	RTNL_FLAG_DOIT_UNLOCKED = 1,
+};
+
 int __rtnl_register(int protocol, int msgtype,
 		    rtnl_doit_func, rtnl_dumpit_func, unsigned int flags);
 void rtnl_register(int protocol, int msgtype,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d45946177bc8..dd4e50dfa248 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -62,6 +62,7 @@
 struct rtnl_link {
 	rtnl_doit_func		doit;
 	rtnl_dumpit_func	dumpit;
+	unsigned int		flags;
 };
 
 static DEFINE_MUTEX(rtnl_mutex);
@@ -184,6 +185,7 @@ int __rtnl_register(int protocol, int msgtype,
 		tab[msgindex].doit = doit;
 	if (dumpit)
 		tab[msgindex].dumpit = dumpit;
+	tab[msgindex].flags |= flags;
 
 	return 0;
 }
@@ -233,6 +235,7 @@ int rtnl_unregister(int protocol, int msgtype)
 
 	handlers[msgindex].doit = NULL;
 	handlers[msgindex].dumpit = NULL;
+	handlers[msgindex].flags = 0;
 	rtnl_unlock();
 
 	return 0;
@@ -4143,6 +4146,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct rtnl_link *handlers;
 	int err = -EOPNOTSUPP;
 	rtnl_doit_func doit;
+	unsigned int flags;
 	int kind;
 	int family;
 	int type;
@@ -4209,6 +4213,17 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return err;
 	}
 
+	flags = READ_ONCE(handlers[type].flags);
+	if (flags & RTNL_FLAG_DOIT_UNLOCKED) {
+		refcount_inc(&rtnl_msg_handlers_ref[family]);
+		doit = READ_ONCE(handlers[type].doit);
+		rcu_read_unlock();
+		if (doit)
+			err = doit(skb, nlh, extack);
+		refcount_dec(&rtnl_msg_handlers_ref[family]);
+		return err;
+	}
+
 	rcu_read_unlock();
 
 	rtnl_lock();
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 317872aefce8..2a361e42f241 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -4068,6 +4068,7 @@ void __init ip6_route_init_special_entries(void)
 
 int __init ip6_route_init(void)
 {
+	unsigned int flag = RTNL_FLAG_DOIT_UNLOCKED;
 	int ret;
 	int cpu;
 
@@ -4109,9 +4110,9 @@ int __init ip6_route_init(void)
 		goto fib6_rules_init;
 
 	ret = -ENOBUFS;
-	if (__rtnl_register(PF_INET6, RTM_NEWROUTE, inet6_rtm_newroute, NULL, 0) ||
-	    __rtnl_register(PF_INET6, RTM_DELROUTE, inet6_rtm_delroute, NULL, 0) ||
-	    __rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL, 0))
+	if (__rtnl_register(PF_INET6, RTM_NEWROUTE, inet6_rtm_newroute, NULL, flag) ||
+	    __rtnl_register(PF_INET6, RTM_DELROUTE, inet6_rtm_delroute, NULL, flag) ||
+	    __rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL, flag))
 		goto out_register_late_subsys;
 
 	ret = register_netdevice_notifier(&ip6_route_dev_notifier);
-- 
2.13.0
