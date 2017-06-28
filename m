From: Donald Sharp <sharpd@cumulusnetworks.com>
Subject: [PATCH] net: ipmr: Add ipmr_rtm_getroute
Date: Wed, 28 Jun 2017 13:58:57 -0400
Message-ID: <20170628175857.20447-1-sharpd@cumulusnetworks.com>
To: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:34609 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbdF1R7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 13:59:04 -0400
Received: by mail-qk0-f176.google.com with SMTP id d78so57254983qkb.1
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 10:59:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add to RTNL_FAMILY_IPMR, RTM_GETROUTE the ability
to retrieve one S,G mroute from a specified table.

*,G will return mroute information for just that
particular mroute if it exists.  This is because
it is entirely possible to have more S's then
can fit in one skb to return to the requesting
process.

Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 62 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a1d521b..bb909f1 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2406,6 +2406,67 @@ static void igmpmsg_netlink_event(struct mr_table *mrt, struct sk_buff *pkt)
 	rtnl_set_sk_err(net, RTNLGRP_IPV4_MROUTE_R, -ENOBUFS);
 }
 
+static int ipmr_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
+{
+	struct net *net = sock_net(in_skb->sk);
+	struct nlattr *tb[RTA_MAX + 1];
+	struct sk_buff *skb = NULL;
+	struct mfc_cache *cache;
+	struct mr_table *mrt;
+	struct rtmsg *rtm;
+	__be32 src, grp;
+	u32 tableid;
+	int err;
+
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX,
+			  rtm_ipv4_policy, extack);
+	if (err < 0)
+		goto errout;
+
+	rtm = nlmsg_data(nlh);
+
+	src = tb[RTA_SRC] ? nla_get_in_addr(tb[RTA_SRC]) : 0;
+	grp = tb[RTA_DST] ? nla_get_in_addr(tb[RTA_DST]) : 0;
+	tableid = tb[RTA_TABLE] ? nla_get_u32(tb[RTA_TABLE]) : 0;
+
+	mrt = ipmr_get_table(net, tableid ? tableid : RT_TABLE_DEFAULT);
+	if (IS_ERR(mrt)) {
+		err = PTR_ERR(mrt);
+		goto errout_free;
+	}
+
+	/* entries are added/deleted only under RTNL */
+	rcu_read_lock();
+	cache = ipmr_cache_find(mrt, src, grp);
+	rcu_read_unlock();
+	if (!cache) {
+		err = -ENOENT;
+		goto errout_free;
+	}
+
+	skb = nlmsg_new(mroute_msgsize(false, mrt->maxvif), GFP_KERNEL);
+	if (!skb) {
+		err = -ENOBUFS;
+		goto errout_free;
+	}
+
+	err = ipmr_fill_mroute(mrt, skb, NETLINK_CB(in_skb).portid,
+			       nlh->nlmsg_seq, cache,
+			       RTM_NEWROUTE, 0);
+	if (err < 0)
+		goto errout_free;
+
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
+
+errout:
+	return err;
+
+errout_free:
+	kfree_skb(skb);
+	goto errout;
+}
+
 static int ipmr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
@@ -3053,7 +3114,7 @@ int __init ip_mr_init(void)
 	}
 #endif
 	rtnl_register(RTNL_FAMILY_IPMR, RTM_GETROUTE,
-		      NULL, ipmr_rtm_dumproute, NULL);
+		      ipmr_rtm_getroute, ipmr_rtm_dumproute, NULL);
 	rtnl_register(RTNL_FAMILY_IPMR, RTM_NEWROUTE,
 		      ipmr_rtm_route, NULL, NULL);
 	rtnl_register(RTNL_FAMILY_IPMR, RTM_DELROUTE,
-- 
2.9.4
