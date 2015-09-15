From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v4 net 4/5] ipv6: Avoid double dst_free
Date: Tue, 15 Sep 2015 14:30:08 -0700
Message-ID: <1442352609-1476011-5-git-send-email-kafai@fb.com>
References: <1442352609-1476011-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37162 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751904AbbIOVak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 17:30:40 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t8FLU8a6017899
	for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 14:30:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wxt3p8ck0-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 14:30:39 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 01c50cd05bf111e598480002c95209d8-d81fc240 for <netdev@vger.kernel.org>;	Tue,
 15 Sep 2015 14:30:38 -0700
In-Reply-To: <1442352609-1476011-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a prep work to get dst freeing from fib tree undergo
a rcu grace period.

The following is a common paradigm:
if (ip6_del_rt(rt))
	dst_free(rt)

which means, if rt cannot be deleted from the fib tree, dst_free(rt) now.
1. We don't know the ip6_del_rt(rt) failure is because it
   was not managed by fib tree (e.g. DST_NOCACHE) or it had already been
   removed from the fib tree.
2. If rt had been managed by the fib tree, ip6_del_rt(rt) failure means
   dst_free(rt) has been called already.  A second
   dst_free(rt) is not always obviously safe.  The rt may have
   been destroyed already.
3. If rt is a DST_NOCACHE, dst_free(rt) should not be called.
4. It is a stopper to make dst freeing from fib tree undergo a
   rcu grace period.

This patch is to use a DST_NOCACHE flag to indicate a rt is
not managed by the fib tree.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/addrconf.c |  7 +++----
 net/ipv6/ip6_fib.c  | 11 +++++++++--
 net/ipv6/route.c    |  7 ++++---
 3 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 030fefd..9001133 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5127,13 +5127,12 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 
 			rt = addrconf_get_prefix_route(&ifp->peer_addr, 128,
 						       ifp->idev->dev, 0, 0);
-			if (rt && ip6_del_rt(rt))
-				dst_free(&rt->dst);
+			if (rt)
+				ip6_del_rt(rt);
 		}
 		dst_hold(&ifp->rt->dst);
 
-		if (ip6_del_rt(ifp->rt))
-			dst_free(&ifp->rt->dst);
+		ip6_del_rt(ifp->rt);
 
 		rt_genid_bump_ipv6(net);
 		break;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 418d982..e68350b 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -933,6 +933,10 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 	int replace_required = 0;
 	int sernum = fib6_new_sernum(info->nl_net);
 
+	if (WARN_ON_ONCE((rt->dst.flags & DST_NOCACHE) &&
+			 !atomic_read(&rt->dst.__refcnt)))
+		return -EINVAL;
+
 	if (info->nlh) {
 		if (!(info->nlh->nlmsg_flags & NLM_F_CREATE))
 			allow_create = 0;
@@ -1025,6 +1029,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags & RTF_CACHE))
 			fib6_prune_clones(info->nl_net, pn);
+		rt->dst.flags &= ~DST_NOCACHE;
 	}
 
 out:
@@ -1049,7 +1054,8 @@ out:
 			atomic_inc(&pn->leaf->rt6i_ref);
 		}
 #endif
-		dst_free(&rt->dst);
+		if (!(rt->dst.flags & DST_NOCACHE))
+			dst_free(&rt->dst);
 	}
 	return err;
 
@@ -1060,7 +1066,8 @@ out:
 st_failure:
 	if (fn && !(fn->fn_flags & (RTN_RTINFO|RTN_ROOT)))
 		fib6_repair_tree(info->nl_net, fn);
-	dst_free(&rt->dst);
+	if (!(rt->dst.flags & DST_NOCACHE))
+		dst_free(&rt->dst);
 	return err;
 #endif
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 53617d7..3d3c1b2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1322,8 +1322,7 @@ static void ip6_link_failure(struct sk_buff *skb)
 	if (rt) {
 		if (rt->rt6i_flags & RTF_CACHE) {
 			dst_hold(&rt->dst);
-			if (ip6_del_rt(rt))
-				dst_free(&rt->dst);
+			ip6_del_rt(rt);
 		} else if (rt->rt6i_node && (rt->rt6i_flags & RTF_DEFAULT)) {
 			rt->rt6i_node->fn_sernum = -1;
 		}
@@ -2028,7 +2027,8 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 	struct fib6_table *table;
 	struct net *net = dev_net(rt->dst.dev);
 
-	if (rt == net->ipv6.ip6_null_entry) {
+	if (rt == net->ipv6.ip6_null_entry ||
+	    rt->dst.flags & DST_NOCACHE) {
 		err = -ENOENT;
 		goto out;
 	}
@@ -2515,6 +2515,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->rt6i_dst.addr = *addr;
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_table = fib6_get_table(net, RT6_TABLE_LOCAL);
+	rt->dst.flags |= DST_NOCACHE;
 
 	atomic_set(&rt->dst.__refcnt, 1);
 
-- 
2.5.1
