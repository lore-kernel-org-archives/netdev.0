From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 1/2] rtnetlink: place link af dump into own helper
Date: Mon, 16 Oct 2017 15:44:35 +0200
Message-ID: <20171016134436.25282-2-fw@strlen.de>
References: <20171016134436.25282-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:35778 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752360AbdJPNoX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 09:44:23 -0400
In-Reply-To: <20171016134436.25282-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

next patch will rcu-ify rtnl af_ops, i.e. allow af_ops
lookup and function calls with rcu read lock held instead
of rtnl mutex.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 72 ++++++++++++++++++++++++++++++----------------------
 1 file changed, 42 insertions(+), 30 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 6a09f3d575af..a49cad25e577 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1382,6 +1382,47 @@ static int rtnl_fill_link_netnsid(struct sk_buff *skb,
 	return 0;
 }
 
+static int rtnl_fill_link_af(struct sk_buff *skb,
+			     const struct net_device *dev,
+			     u32 ext_filter_mask)
+{
+	const struct rtnl_af_ops *af_ops;
+	struct nlattr *af_spec;
+
+	af_spec = nla_nest_start(skb, IFLA_AF_SPEC);
+	if (!af_spec)
+		return -EMSGSIZE;
+
+	list_for_each_entry(af_ops, &rtnl_af_ops, list) {
+		struct nlattr *af;
+		int err;
+
+		if (!af_ops->fill_link_af)
+			continue;
+
+		af = nla_nest_start(skb, af_ops->family);
+		if (!af)
+			return -EMSGSIZE;
+
+		err = af_ops->fill_link_af(skb, dev, ext_filter_mask);
+		/*
+		 * Caller may return ENODATA to indicate that there
+		 * was no data to be dumped. This is not an error, it
+		 * means we should trim the attribute header and
+		 * continue.
+		 */
+		if (err == -ENODATA)
+			nla_nest_cancel(skb, af);
+		else if (err < 0)
+			return -EMSGSIZE;
+
+		nla_nest_end(skb, af);
+	}
+
+	nla_nest_end(skb, af_spec);
+	return 0;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask,
@@ -1389,8 +1430,6 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
-	struct nlattr *af_spec;
-	struct rtnl_af_ops *af_ops;
 
 	ASSERT_RTNL();
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
@@ -1477,36 +1516,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    nla_put_s32(skb, IFLA_NEW_NETNSID, *new_nsid) < 0)
 		goto nla_put_failure;
 
-	if (!(af_spec = nla_nest_start(skb, IFLA_AF_SPEC)))
+	if (rtnl_fill_link_af(skb, dev, ext_filter_mask))
 		goto nla_put_failure;
 
-	list_for_each_entry(af_ops, &rtnl_af_ops, list) {
-		if (af_ops->fill_link_af) {
-			struct nlattr *af;
-			int err;
-
-			if (!(af = nla_nest_start(skb, af_ops->family)))
-				goto nla_put_failure;
-
-			err = af_ops->fill_link_af(skb, dev, ext_filter_mask);
-
-			/*
-			 * Caller may return ENODATA to indicate that there
-			 * was no data to be dumped. This is not an error, it
-			 * means we should trim the attribute header and
-			 * continue.
-			 */
-			if (err == -ENODATA)
-				nla_nest_cancel(skb, af);
-			else if (err < 0)
-				goto nla_put_failure;
-
-			nla_nest_end(skb, af);
-		}
-	}
-
-	nla_nest_end(skb, af_spec);
-
 	nlmsg_end(skb, nlh);
 	return 0;
 
-- 
2.13.6
