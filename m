From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH] net: fix bridge notify hook to manage flags correctly
Date: Fri, 02 Nov 2012 19:32:36 -0700
Message-ID: <20121103023236.8177.63714.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:36202 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701Ab2KCCmf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2012 22:42:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridge notify hook rtnl_bridge_notify() was not handling the
case where the master flags was set or with both flags set. First
flags are not being passed correctly and second the logic to parse
them is broken.

This patch passes the original flags value and fixes the
logic.

Reported-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/rtnetlink.c |   26 ++++++++++++++++++--------
 1 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 51dc58f..7eae53b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2373,13 +2373,19 @@ static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
 		goto errout;
 	}
 
-	if (!flags && master && master->netdev_ops->ndo_bridge_getlink)
+	if ((!flags || (flags & BRIDGE_FLAGS_MASTER)) &&
+	    master && master->netdev_ops->ndo_bridge_getlink) {
 		err = master->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
-	else if (dev->netdev_ops->ndo_bridge_getlink)
-		err = dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
+		if (err < 0)
+			goto errout;
+	}
 
-	if (err < 0)
-		goto errout;
+	if ((flags & BRIDGE_FLAGS_SELF) &&
+	    dev->netdev_ops->ndo_bridge_getlink) {
+		err = dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
+		if (err < 0)
+			goto errout;
+	}
 
 	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
 	return 0;
@@ -2398,7 +2404,8 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net_device *dev;
 	struct nlattr *br_spec, *attr = NULL;
 	int rem, err = -EOPNOTSUPP;
-	u16 flags = 0;
+	u16 oflags, flags = 0;
+	bool have_flags = false;
 
 	if (nlmsg_len(nlh) < sizeof(*ifm))
 		return -EINVAL;
@@ -2417,12 +2424,15 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (br_spec) {
 		nla_for_each_nested(attr, br_spec, rem) {
 			if (nla_type(attr) == IFLA_BRIDGE_FLAGS) {
+				have_flags = true;
 				flags = nla_get_u16(attr);
 				break;
 			}
 		}
 	}
 
+	oflags = flags;
+
 	if (!flags || (flags & BRIDGE_FLAGS_MASTER)) {
 		if (!dev->master ||
 		    !dev->master->netdev_ops->ndo_bridge_setlink) {
@@ -2447,11 +2457,11 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 			flags &= ~BRIDGE_FLAGS_SELF;
 	}
 
-	if (attr && nla_type(attr) == IFLA_BRIDGE_FLAGS)
+	if (have_flags)
 		memcpy(nla_data(attr), &flags, sizeof(flags));
 	/* Generate event to notify upper layer of bridge change */
 	if (!err)
-		err = rtnl_bridge_notify(dev, flags);
+		err = rtnl_bridge_notify(dev, oflags);
 out:
 	return err;
 }
