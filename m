From: roopa@cumulusnetworks.com
Subject: [PATCH net-next] unregister_netdevice : move RTM_DELLINK to until after ndo_uninit
Date: Thu,  1 May 2014 11:40:30 -0700
Message-ID: <1398969630-4808-1-git-send-email-roopa@cumulusnetworks.com>
Cc: sfeldma@cumulusnetworks.com, jiri@resnulli.us, tgraf@suug.ch,
	j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net
To: davem@davemloft.net, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:32869 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbaEASka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 14:40:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>

This patch fixes ordering of rtnl notifications during unregister_netdevice
by moving RTM_DELLINK notification to until after ndo_uninit.

The problem was seen with unregistering bond netdevices.

bond ndo_uninit callback generates a few RTM_NEWLINK notifications for
NETDEV_CHANGEADDR and NETDEV_FEAT_CHANGE. This is seen mostly when the
bond is deleted with slaves still enslaved to the bond.

During unregister netdevice (rollback_registered_many to be specific)
bond ndo_uninit is called after RTM_DELLINK notification goes out.
This results in userspace seeing RTM_DELLINK followed by a couple of
RTM_NEWLINK's.

In userspace problem was seen with libnl. libnl cache deletes the bond
when it sees RTM_DELLINK and re-adds the bond with the following
RTM_NEWLINK. Resulting in a stale bond entry in libnl cache when the kernel
has already deleted the bond.

This patch has been tested for bond, bridges and vlan devices.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/core/dev.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 11d70e3..fe0b9cd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5606,10 +5606,6 @@ static void rollback_registered_many(struct list_head *head)
 		*/
 		call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 
-		if (!dev->rtnl_link_ops ||
-		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
-			rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
-
 		/*
 		 *	Flush the unicast and multicast chains
 		 */
@@ -5619,6 +5615,10 @@ static void rollback_registered_many(struct list_head *head)
 		if (dev->netdev_ops->ndo_uninit)
 			dev->netdev_ops->ndo_uninit(dev);
 
+		if (!dev->rtnl_link_ops ||
+		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
+			rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
+
 		/* Notifier chain MUST detach us all upper devices. */
 		WARN_ON(netdev_has_any_upper_dev(dev));
 
-- 
1.7.10.4
