From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2 net-next 4/5] ipv6: make fib6 serial number per namespace
Date: Mon,  6 Oct 2014 19:58:37 +0200
Message-ID: <b2c0c19b283fc492705a9d24e7720f8ae658cd76.1412618014.git.hannes@stressinduktion.org>
References: <cover.1412618014.git.hannes@stressinduktion.org>
Cc: hideaki@yoshifuji.org, kafai@fb.com, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:47220 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753065AbaJFR6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 13:58:55 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by gateway2.nyi.internal (Postfix) with ESMTP id 575302099A
	for <netdev@vger.kernel.org>; Mon,  6 Oct 2014 13:58:55 -0400 (EDT)
In-Reply-To: <cover.1412618014.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1412618014.git.hannes@stressinduktion.org>
References: <cover.1412618014.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Try to reduce number of possible fn_sernum mutation by constraining them
to their namespace.

Also remove rt_genid which I forgot to remove in 705f1c869d577c ("ipv6:
remove rt6i_genid").

Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/netns/ipv6.h |  2 +-
 net/ipv6/af_inet6.c      |  2 +-
 net/ipv6/ip6_fib.c       | 13 ++++++-------
 3 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index eade27a..69ae41f 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -76,7 +76,7 @@ struct netns_ipv6 {
 #endif
 #endif
 	atomic_t		dev_addr_genid;
-	atomic_t		rt_genid;
+	atomic_t		fib6_sernum;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 34f726f..e8c4400 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -766,7 +766,7 @@ static int __net_init inet6_net_init(struct net *net)
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 	net->ipv6.sysctl.flowlabel_consistency = 1;
 	net->ipv6.sysctl.auto_flowlabels = 0;
-	atomic_set(&net->ipv6.rt_genid, 0);
+	atomic_set(&net->ipv6.fib6_sernum, 1);
 
 	err = ipv6_init_mibs(net);
 	if (err)
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index be9cb09..6f9beb1 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -74,8 +74,6 @@ static int fib6_walk_continue(struct fib6_walker *w);
  *	result of redirects, path MTU changes, etc.
  */
 
-static atomic_t rt_sernum = ATOMIC_INIT(1);
-
 static void fib6_gc_timer_cb(unsigned long arg);
 
 static LIST_HEAD(fib6_walkers);
@@ -95,14 +93,15 @@ static void fib6_walker_unlink(struct fib6_walker *w)
 	write_unlock_bh(&fib6_walker_lock);
 }
 
-static int fib6_new_sernum(void)
+static int fib6_new_sernum(struct net *net)
 {
 	int new, old;
 
 	do {
-		old = atomic_read(&rt_sernum);
+		old = atomic_read(&net->ipv6.fib6_sernum);
 		new = old < INT_MAX ? old + 1 : 1;
-	} while (atomic_cmpxchg(&rt_sernum, old, new) != old);
+	} while (atomic_cmpxchg(&net->ipv6.fib6_sernum,
+				old, new) != old);
 	return new;
 }
 
@@ -841,7 +840,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	int err = -ENOMEM;
 	int allow_create = 1;
 	int replace_required = 0;
-	int sernum = fib6_new_sernum();
+	int sernum = fib6_new_sernum(info->nl_net);
 
 	if (info->nlh) {
 		if (!(info->nlh->nlmsg_flags & NLM_F_CREATE))
@@ -1612,7 +1611,7 @@ static int fib6_update_sernum(struct rt6_info *rt, void *arg)
 
 static void fib6_flush_trees(struct net *net)
 {
-	int new_sernum = fib6_new_sernum();
+	int new_sernum = fib6_new_sernum(net);
 
 	fib6_clean_all(net, fib6_update_sernum, &new_sernum);
 }
-- 
1.9.3
