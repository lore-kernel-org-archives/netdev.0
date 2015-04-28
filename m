From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 1/5] ipv6: Consider RTF_CACHE when searching the fib6 tree
Date: Tue, 28 Apr 2015 13:03:03 -0700
Message-ID: <1430251387-2942539-2-git-send-email-kafai@fb.com>
References: <1430251387-2942539-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Yang Yingliang <yangyingliang@huawei.com>,
	shengyong <shengyong1@huawei.com>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56306 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031040AbbD1UD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 16:03:27 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3SK16gm023335
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:03:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u2gpw01gd-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:03:27 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 a0e59060ede111e490310002c991e86a-6aff02c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 13:03:25 -0700
In-Reply-To: <1430251387-2942539-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a prep work for the later bug-fix patch which will stop /128 route
from disappearing after pmtu update.

The later bug-fix patch will allow a /128 route and its RTF_CACHE clone
both exist at the same fib6_node.  To do this, we need to prepare the
existing fib6 tree search to expect RTF_CACHE for /128 route.

Note that the fn->leaf is sorted by rt6i_metric.  Hence,
RTF_CACHE (if there is any) is always at the front.  This property
leads to the following:

1. When doing ip6_route_del(), it should honor the RTF_CACHE flag which
   the caller is used to ask for deleting clone or non-clone.
   The rtm_to_fib6_config() should also check the RTM_F_CLONED and
   then set RTF_CACHE accordingly so that:
   - 'ip -6 r del...' will make ip6_route_del() to delete a route
     and all its clones. Note that its clones is flushed by fib6_del()
   - 'ip -6 r flush table cache' will make ip6_route_del() to
      only delete clone(s).

2. Exclude RTF_CACHE from addrconf_get_prefix_route() which
   should not configure on a cloned route.

3. No change is need for rt6_device_match() since it currently could
   return a RTF_CACHE clone route, so the later bug-fix patch will not
   affect it.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/addrconf.c | 2 ++
 net/ipv6/route.c    | 6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 37b70e8..21c2c81 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2121,6 +2121,8 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 	fn = fib6_locate(&table->tb6_root, pfx, plen, NULL, 0);
 	if (!fn)
 		goto out;
+
+	noflags |= RTF_CACHE;
 	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
 		if (rt->dst.dev->ifindex != dev->ifindex)
 			continue;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5c48293..4774f13 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1785,6 +1785,9 @@ static int ip6_route_del(struct fib6_config *cfg)
 
 	if (fn) {
 		for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
+			if ((rt->rt6i_flags & RTF_CACHE) &&
+			    !(cfg->fc_flags & RTF_CACHE))
+				continue;
 			if (cfg->fc_ifindex &&
 			    (!rt->dst.dev ||
 			     rt->dst.dev->ifindex != cfg->fc_ifindex))
@@ -2433,6 +2436,9 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (rtm->rtm_type == RTN_LOCAL)
 		cfg->fc_flags |= RTF_LOCAL;
 
+	if (rtm->rtm_flags & RTM_F_CLONED)
+		cfg->fc_flags |= RTF_CACHE;
+
 	cfg->fc_nlinfo.portid = NETLINK_CB(skb).portid;
 	cfg->fc_nlinfo.nlh = nlh;
 	cfg->fc_nlinfo.nl_net = sock_net(skb->sk);
-- 
1.8.1
