From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 7/8] mpls: Multicast route table change notifications
Date: Wed, 25 Feb 2015 11:19:49 -0600
Message-ID: <87fv9tvrgq.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:52030 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576AbbBYRXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:23:17 -0500
In-Reply-To: <87pp8xx6ik.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 25 Feb 2015 11:09:23 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Unlike IPv4 this code notifies on all cases where mpls routes
are added or removed as that was the simplest to implement.

In particular routes being removed because a network interface
goes down or is removed are notified about.  Are there technical
arguments for handling this differently?  Userspace developers
don't particularly like the way IPv4 handles route removal
on ifdown.

For now reserved labels are handled automatically and userspace
is not notified.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/uapi/linux/rtnetlink.h |  2 ++
 net/mpls/af_mpls.c             | 60 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index da9889a4dec0..481d2516ccd0 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -625,6 +625,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_IPV6_NETCONF	RTNLGRP_IPV6_NETCONF
 	RTNLGRP_MDB,
 #define RTNLGRP_MDB		RTNLGRP_MDB
+	RTNLGRP_MPLS_ROUTE,
+#define RTNLGRP_MPLS_ROUTE	RTNLGRP_MPLS_ROUTE
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 5cf9aa68c32f..90e45461c8e2 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -34,6 +34,10 @@ struct mpls_route { /* next hop label forwarding entry */
 static int zero = 0;
 static int label_limit = (1 << 20) - 1;
 
+static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
+		       struct nlmsghdr *nlh, struct net *net, u32 portid,
+		       unsigned int nlm_flags);
+
 static struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index)
 {
 	struct mpls_route *rt = NULL;
@@ -237,6 +241,20 @@ static void mpls_rt_free(struct mpls_route *rt)
 		kfree_rcu(rt, rt_rcu);
 }
 
+static void mpls_notify_route(struct net *net, unsigned index,
+			      struct mpls_route *old, struct mpls_route *new,
+			      const struct nl_info *info)
+{
+	struct nlmsghdr *nlh = info ? info->nlh : NULL;
+	unsigned portid = info ? info->portid : 0;
+	int event = new ? RTM_NEWROUTE : RTM_DELROUTE;
+	struct mpls_route *rt = new ? new : old;
+	unsigned nlm_flags = (old && new) ? NLM_F_REPLACE : 0;
+	/* Ignore reserved labels for now */
+	if (rt && (index >= 16))
+		rtmsg_lfib(event, index, rt, nlh, net, portid, nlm_flags);
+}
+
 static void mpls_route_update(struct net *net, unsigned index,
 			      struct net_device *dev, struct mpls_route *new,
 			      const struct nl_info *info)
@@ -251,6 +269,8 @@ static void mpls_route_update(struct net *net, unsigned index,
 		old = rt;
 	}
 
+	mpls_notify_route(net, index, old, new, info);
+
 	/* If we removed a route free it now */
 	mpls_rt_free(old);
 }
@@ -643,6 +663,46 @@ static int mpls_dump_routes(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
+static inline size_t lfib_nlmsg_size(struct mpls_route *rt)
+{
+	size_t payload =
+		NLMSG_ALIGN(sizeof(struct rtmsg))
+		+ ((rt->rt_labels == 0) ? 0 :		/* RTA_NEWDST */
+		   nla_total_size(rt->rt_labels *4))
+		+ nla_total_size(rt->rt_dev->addr_len)	/* RTA_LLGATEWAY */
+		+ nla_total_size(4)			/* RTA_OIF */
+		+ nla_total_size(4);			/* RTA_DST */
+
+	return payload;
+}
+
+static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
+		       struct nlmsghdr *nlh, struct net *net, u32 portid,
+		       unsigned int nlm_flags)
+{
+	struct sk_buff *skb;
+	u32 seq = nlh ? nlh->nlmsg_seq : 0;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(lfib_nlmsg_size(rt), GFP_KERNEL);
+	if (skb == NULL)
+		goto errout;
+
+	err = mpls_dump_route(skb, portid, seq, event, label, rt, nlm_flags);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in lfib_nlmsg_size */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+	rtnl_notify(skb, net, portid, RTNLGRP_MPLS_ROUTE, nlh, GFP_KERNEL);
+
+	return;
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(net, RTNLGRP_MPLS_ROUTE, err);
+}
+
 static int resize_platform_label_table(struct net *net, size_t limit)
 {
 	size_t size = sizeof(struct mpls_route *) * limit;
-- 
2.2.1
