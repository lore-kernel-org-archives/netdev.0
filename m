From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net] ipv6: include NLM_F_REPLACE in route replace notifications
Date: Sun, 13 Sep 2015 10:18:33 -0700
Message-ID: <1442164713-54206-1-git-send-email-roopa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, mkubecek@suse.cz,
	Mazziesaccount@gmail.com, hannes@stressinduktion.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34320 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236AbbIMRSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Sep 2015 13:18:39 -0400
Received: by padhy16 with SMTP id hy16so120350021pad.1
        for <netdev@vger.kernel.org>; Sun, 13 Sep 2015 10:18:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds NLM_F_REPLACE flag to ipv6 route replace notifications.
This makes nlm_flags in ipv6 replace notifications consistent
with ipv4.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
Submitting this to net since it complements the other ipv6 replace fixes
in net

 include/net/ip6_fib.h | 3 ++-
 net/ipv6/ip6_fib.c    | 6 +++---
 net/ipv6/route.c      | 5 +++--
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 063d304..aaf9700 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -275,7 +275,8 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 	     struct nl_info *info, struct mx6_config *mxc);
 int fib6_del(struct rt6_info *rt, struct nl_info *info);
 
-void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info);
+void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info,
+		     unsigned int flags);
 
 void fib6_run_gc(unsigned long expires, struct net *net, bool force);
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 418d982..90ff99b 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -846,7 +846,7 @@ add:
 		*ins = rt;
 		rt->rt6i_node = fn;
 		atomic_inc(&rt->rt6i_ref);
-		inet6_rt_notify(RTM_NEWROUTE, rt, info);
+		inet6_rt_notify(RTM_NEWROUTE, rt, info, 0);
 		info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
 
 		if (!(fn->fn_flags & RTN_RTINFO)) {
@@ -872,7 +872,7 @@ add:
 		rt->rt6i_node = fn;
 		rt->dst.rt6_next = iter->dst.rt6_next;
 		atomic_inc(&rt->rt6i_ref);
-		inet6_rt_notify(RTM_NEWROUTE, rt, info);
+		inet6_rt_notify(RTM_NEWROUTE, rt, info, NLM_F_REPLACE);
 		if (!(fn->fn_flags & RTN_RTINFO)) {
 			info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
 			fn->fn_flags |= RTN_RTINFO;
@@ -1410,7 +1410,7 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 
 	fib6_purge_rt(rt, fn, net);
 
-	inet6_rt_notify(RTM_DELROUTE, rt, info);
+	inet6_rt_notify(RTM_DELROUTE, rt, info, 0);
 	rt6_release(rt);
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 53617d7..783d416 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3303,7 +3303,8 @@ errout:
 	return err;
 }
 
-void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info)
+void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info,
+		     unsigned int nlm_flags)
 {
 	struct sk_buff *skb;
 	struct net *net = info->nl_net;
@@ -3318,7 +3319,7 @@ void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info)
 		goto errout;
 
 	err = rt6_fill_node(net, skb, rt, NULL, NULL, 0,
-				event, info->portid, seq, 0, 0, 0);
+				event, info->portid, seq, 0, 0, nlm_flags);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in rt6_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
-- 
1.9.1
