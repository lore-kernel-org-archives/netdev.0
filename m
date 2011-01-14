From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v3 2/2] netlink: support setting devgroup parameters
Date: Fri, 14 Jan 2011 11:38:31 +0200
Message-ID: <1294997911-13866-3-git-send-email-ddvlad@rosedu.org>
References: <1294997911-13866-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:39250 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751984Ab1ANJii (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 04:38:38 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1294997911-13866-1-git-send-email-ddvlad@rosedu.org>
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a rtnetlink request specifies a negative or zero ifindex and has no
interface name attribute, but has a group attribute, then the chenges
are made to all the interfaces belonging to the specified group.

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 net/core/rtnetlink.c |   32 ++++++++++++++++++++++++++++----
 1 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 012b0f0..f208397 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1558,6 +1558,24 @@ err:
 }
 EXPORT_SYMBOL(rtnl_create_link);
 
+static int rtnl_group_changelink(struct net *net, int group,
+		struct ifinfomsg *ifm,
+		struct nlattr **tb)
+{
+	struct net_device *dev;
+	int err;
+
+	for_each_netdev(net, dev) {
+		if (dev->group == group) {
+			err = do_setlink(dev, ifm, tb, NULL, 0);
+			if (err < 0)
+				return err;
+		}
+	}
+
+	return 0;
+}
+
 static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -1585,10 +1603,16 @@ replay:
 	ifm = nlmsg_data(nlh);
 	if (ifm->ifi_index > 0)
 		dev = __dev_get_by_index(net, ifm->ifi_index);
-	else if (ifname[0])
-		dev = __dev_get_by_name(net, ifname);
-	else
-		dev = NULL;
+	else {
+		if (ifname[0])
+			dev = __dev_get_by_name(net, ifname);
+		else if (tb[IFLA_GROUP])
+			return rtnl_group_changelink(net,
+					nla_get_u32(tb[IFLA_GROUP]),
+					ifm, tb);
+		else
+			dev = NULL;
+	}
 
 	err = validate_linkmsg(dev, tb);
 	if (err < 0)
-- 
1.7.1

