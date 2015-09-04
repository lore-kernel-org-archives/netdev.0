From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v2 net 4/5] ipv6: Avoid double dst_free
Date: Fri, 4 Sep 2015 16:12:41 -0700
Message-ID: <1441408362-4177515-5-git-send-email-kafai@fb.com>
References: <1441408362-4177515-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:9407 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934123AbbIDXM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 19:12:58 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t84N8hbb014159
	for <netdev@vger.kernel.org>; Fri, 4 Sep 2015 16:12:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wqk22rb84-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 04 Sep 2015 16:12:57 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 79e0d194535a11e596bf0002c992ebde-a33f7240 for <netdev@vger.kernel.org>;	Fri,
 04 Sep 2015 16:12:56 -0700
In-Reply-To: <1441408362-4177515-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a prep work to get dst freeing from fib tree undergo
a rcu grace period.

The following is a common paradigm:
if (ip6_del_rt(rt))
	dst_free(rt)

which means, if rt cannot be deleted from the fib tree, dst_free(rt) now.
1. We don't know the ip6_del_rt(rt) failure is because it
   was not managed by fib tree (DST_NOCACHE) or it had already been
   removed from the fib tree.
2. If rt had been managed by the fib tree, ip6_del_rt(rt) failure means
   dst_free(rt) has already been called already.  A second
   dst_free(rt) is not always obviously safe.  The rt may have
   been destroyed already.
3. If rt is a DST_NOCACHE, dst_free(rt) should not be called.
4. It is a stopper to make dst freeing from fib tree undergo a
   rcu grace period.

This patch is to use a DST_NOCACHE flag to indicate a rt is
managed by the fib tree or not.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/addrconf.c |  7 +++----
 net/ipv6/ip6_fib.c  | 11 +++++++++--
 net/ipv6/route.c    |  7 +++++--
 3 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ba006d9..b6225aa 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4855,13 +4855,12 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 
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
index 6492115..346aa4a 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -897,6 +897,10 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 	int replace_required = 0;
 	int sernum = fib6_new_sernum(info->nl_net);
 
+	if (WARN_ON_ONCE((rt->dst.flags & DST_NOCACHE) &&
+			 !atomic_read(&rt->dst.__refcnt)))
+		return -EINVAL;
+
 	if (info->nlh) {
 		if (!(info->nlh->nlmsg_flags & NLM_F_CREATE))
 			allow_create = 0;
@@ -989,6 +993,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags & RTF_CACHE))
 			fib6_prune_clones(info->nl_net, pn);
+		rt->dst.flags &= ~DST_NOCACHE;
 	}
 
 out:
@@ -1013,7 +1018,8 @@ out:
 			atomic_inc(&pn->leaf->rt6i_ref);
 		}
 #endif
-		dst_free(&rt->dst);
+		if (!(rt->dst.flags & DST_NOCACHE))
+			dst_free(&rt->dst);
 	}
 	return err;
 
@@ -1024,7 +1030,8 @@ out:
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
index bc9ff77..ecc63eb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1313,8 +1313,7 @@ static void ip6_link_failure(struct sk_buff *skb)
 	if (rt) {
 		if (rt->rt6i_flags & RTF_CACHE) {
 			dst_hold(&rt->dst);
-			if (ip6_del_rt(rt))
-				dst_free(&rt->dst);
+			ip6_del_rt(rt);
 		} else if (rt->rt6i_node && (rt->rt6i_flags & RTF_DEFAULT)) {
 			rt->rt6i_node->fn_sernum = -1;
 		}
@@ -1962,6 +1961,9 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 	if (rt == net->ipv6.ip6_null_entry) {
 		err = -ENOENT;
 		goto out;
+	} else if (rt->dst.flags & DST_NOCACHE) {
+		err = -ENOENT;
+		goto out;
 	}
 
 	table = rt->rt6i_table;
@@ -2445,6 +2447,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->rt6i_dst.addr = *addr;
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_table = fib6_get_table(net, RT6_TABLE_LOCAL);
+	rt->dst.flags |= DST_NOCACHE;
 
 	atomic_set(&rt->dst.__refcnt, 1);
 
-- 
1.8.1
