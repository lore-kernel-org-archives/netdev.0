From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v2] bridge: fix setlink/dellink notifications
Date: Wed, 14 Jan 2015 20:02:25 -0800
Message-ID: <1421294545-52467-1-git-send-email-roopa@cumulusnetworks.com>
Cc: shemminger@vyatta.com, vyasevic@redhat.com,
	john.fastabend@gmail.com, tgraf@suug.ch, jhs@mojatatu.com,
	sfeldma@gmail.com, jiri@resnulli.us, wkok@cumulusnetworks.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:38193 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbbAOECl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 23:02:41 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so13826553pdb.4
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 20:02:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

problems with bridge getlink/setlink notifications today:
        - bridge setlink generates two notifications to userspace
                - one from the bridge driver
                - one from rtnetlink.c (rtnl_bridge_notify)
        - dellink generates one notification from rtnetlink.c. Which
	means bridge setlink and dellink notifications are not
	consistent

        - Looking at the code it appears,
	If both BRIDGE_FLAGS_MASTER and BRIDGE_FLAGS_SELF were set,
        the size calculation in rtnl_bridge_notify can be wrong.
        Example: if you set both BRIDGE_FLAGS_MASTER and BRIDGE_FLAGS_SELF
        in a setlink request to rocker dev, rtnl_bridge_notify will
	allocate skb for one set of bridge attributes, but,
	both the bridge driver and rocker dev will try to add
	attributes resulting in twice the number of attributes
	being added to the skb.  (rocker dev calls ndo_dflt_bridge_getlink)

There are multiple options:
1) Generate one notification including all attributes from master and self:
   But, I don't think it will work, because both master and self may use
   the same attributes/policy. Cannot pack the same set of attributes in a
   single notification from both master and slave (duplicate attributes).

2) Generate one notification from master and the other notification from
   self (This seems to be ideal):
     For master: the master driver will send notification (bridge in this
	example)
     For self: the self driver will send notification (rocker in the above
	example. It can use helpers from rtnetlink.c to do so. Like the
	ndo_dflt_bridge_getlink api).

This patch implements 2) (leaving the 'rtnl_bridge_notify' around to be used
with 'self').

v1->v2 :
	- rtnl_bridge_notify is now called only for self,
	so, remove 'BRIDGE_FLAGS_SELF' check and cleanup a few things
	- rtnl_bridge_dellink used to always send a RTM_NEWLINK msg
	earlier. So, I have changed the notification from br_dellink to
	go as RTM_NEWLINK

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |    5 +++++
 net/core/rtnetlink.c    |   45 +++++++++++++++++++++------------------------
 2 files changed, 26 insertions(+), 24 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 9f5eb55..f996324 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -432,6 +432,11 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh)
 
 	err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
 			afspec, RTM_DELLINK);
+	if (err == 0)
+		/* Send RTM_NEWLINK because userspace
+		 * expects RTM_NEWLINK for vlan dels
+		 */
+		br_ifinfo_notify(RTM_NEWLINK, p);
 
 	return err;
 }
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d06107d..acefd60 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2863,32 +2863,24 @@ static inline size_t bridge_nlmsg_size(void)
 		+ nla_total_size(sizeof(u16));	/* IFLA_BRIDGE_MODE */
 }
 
-static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
+static int rtnl_bridge_notify(struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
-	struct net_device *br_dev = netdev_master_upper_dev_get(dev);
 	struct sk_buff *skb;
 	int err = -EOPNOTSUPP;
 
+	if (!dev->netdev_ops->ndo_bridge_getlink)
+		return 0;
+
 	skb = nlmsg_new(bridge_nlmsg_size(), GFP_ATOMIC);
 	if (!skb) {
 		err = -ENOMEM;
 		goto errout;
 	}
 
-	if ((!flags || (flags & BRIDGE_FLAGS_MASTER)) &&
-	    br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
-		err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
-		if (err < 0)
-			goto errout;
-	}
-
-	if ((flags & BRIDGE_FLAGS_SELF) &&
-	    dev->netdev_ops->ndo_bridge_getlink) {
-		err = dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
-		if (err < 0)
-			goto errout;
-	}
+	err = dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
+	if (err < 0)
+		goto errout;
 
 	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
 	return 0;
@@ -2958,16 +2950,18 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 			err = -EOPNOTSUPP;
 		else
 			err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
-
-		if (!err)
+		if (!err) {
 			flags &= ~BRIDGE_FLAGS_SELF;
+
+			/* Generate event to notify upper layer of bridge
+			 * change
+			 */
+			err = rtnl_bridge_notify(dev);
+		}
 	}
 
 	if (have_flags)
 		memcpy(nla_data(attr), &flags, sizeof(flags));
-	/* Generate event to notify upper layer of bridge change */
-	if (!err)
-		err = rtnl_bridge_notify(dev, oflags);
 out:
 	return err;
 }
@@ -3032,15 +3026,18 @@ static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		else
 			err = dev->netdev_ops->ndo_bridge_dellink(dev, nlh);
 
-		if (!err)
+		if (!err) {
 			flags &= ~BRIDGE_FLAGS_SELF;
+
+			/* Generate event to notify upper layer of bridge
+			 * change
+			 */
+			err = rtnl_bridge_notify(dev);
+		}
 	}
 
 	if (have_flags)
 		memcpy(nla_data(attr), &flags, sizeof(flags));
-	/* Generate event to notify upper layer of bridge change */
-	if (!err)
-		err = rtnl_bridge_notify(dev, oflags);
 out:
 	return err;
 }
-- 
1.7.10.4
