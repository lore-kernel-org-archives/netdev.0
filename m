From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 2/2] ipv6: report NLM_F_CREATE and NLM_F_EXCL flags in
 RTM_NEWROUTE events
Date: Wed, 7 Sep 2016 17:21:40 +0200
Message-ID: <20160907152140.2hmms6rva6vw6dxz@alphalink.fr>
References: <20160907151850.g3mzjrkhtqddqzwg@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Milan Kocian <milon@wq.cz>,
        Michal =?utf-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:39921 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938482AbcIGPVo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 11:21:44 -0400
Content-Disposition: inline
In-Reply-To: <20160907151850.g3mzjrkhtqddqzwg@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 37a1d3611c12 ("ipv6: include NLM_F_REPLACE in route
replace notifications"), RTM_NEWROUTE notifications have their
NLM_F_REPLACE flag set if the new route replaced a preexisting one.
However, other flags aren't set.

This patch reports the missing NLM_F_CREATE and NLM_F_EXCL flag bits.

NLM_F_APPEND is not reported, because in ipv6 a NLM_F_CREATE request
is interpreted as an append request (contrary to ipv4, "prepend" is not
supported, so if NLM_F_EXCL is not set then NLM_F_APPEND is implicit).

As a result, the possible flag combination can now be reported
(iproute2's terminology into parentheses):

  * NLM_F_CREATE | NLM_F_EXCL: route didn't exist, exclusive creation
    ("add").
  * NLM_F_CREATE: route did already exist, new route added after
    preexisting ones ("append").
  * NLM_F_REPLACE: route did already exist, new route replaced the
    first preexisting one ("change").

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/ipv6/ip6_fib.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 771be1f..ef54852 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -743,6 +743,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		   (info->nlh->nlmsg_flags & NLM_F_CREATE));
 	int found = 0;
 	bool rt_can_ecmp = rt6_qualify_for_ecmp(rt);
+	u16 nlflags = NLM_F_EXCL;
 	int err;
 
 	ins = &fn->leaf;
@@ -759,6 +760,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			if (info->nlh &&
 			    (info->nlh->nlmsg_flags & NLM_F_EXCL))
 				return -EEXIST;
+
+			nlflags &= ~NLM_F_EXCL;
 			if (replace) {
 				if (rt_can_ecmp == rt6_qualify_for_ecmp(iter)) {
 					found++;
@@ -856,6 +859,7 @@ next_iter:
 			pr_warn("NLM_F_CREATE should be set when creating new route\n");
 
 add:
+		nlflags |= NLM_F_CREATE;
 		err = fib6_commit_metrics(&rt->dst, mxc);
 		if (err)
 			return err;
@@ -864,7 +868,7 @@ add:
 		*ins = rt;
 		rt->rt6i_node = fn;
 		atomic_inc(&rt->rt6i_ref);
-		inet6_rt_notify(RTM_NEWROUTE, rt, info, 0);
+		inet6_rt_notify(RTM_NEWROUTE, rt, info, nlflags);
 		info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
 
 		if (!(fn->fn_flags & RTN_RTINFO)) {
-- 
2.9.3
