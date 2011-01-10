From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH 3/3] netlink: support setting devgroup parameters
Date: Mon, 10 Jan 2011 13:38:44 +0200
Message-ID: <1294659524-22509-4-git-send-email-ddvlad@rosedu.org>
References: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:33746 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752359Ab1AJLi5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 06:38:57 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new type of message, IFLA_FILTERGROUP, which, if present in a
userspace request, specifies that parameters should be changed for all
devices in the group.

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 include/linux/if_link.h |    1 +
 net/core/rtnetlink.c    |   22 ++++++++++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f4a2e6b..1bbacf9 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -136,6 +136,7 @@ enum {
 	IFLA_PORT_SELF,
 	IFLA_AF_SPEC,
 	IFLA_GROUP,		/* Group the device belongs to */
+	IFLA_FILTERGROUP,	/* Set parameters for a specific device group */
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 012b0f0..8d7af8c 100644
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
@@ -1587,6 +1605,10 @@ replay:
 		dev = __dev_get_by_index(net, ifm->ifi_index);
 	else if (ifname[0])
 		dev = __dev_get_by_name(net, ifname);
+	else if (tb[IFLA_FILTERGROUP])
+		return rtnl_group_changelink(net,
+				nla_get_u32(tb[IFLA_FILTERGROUP]),
+				ifm, tb);
 	else
 		dev = NULL;
 
-- 
1.7.1

