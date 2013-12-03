From: Kevin Wallace <kevin@pentabarf.net>
Subject: [PATCH] macvlan: Support creating macvtaps from macvlans
Date: Mon,  2 Dec 2013 20:13:11 -0800
Message-ID: <1386043991-4372-1-git-send-email-kevin@pentabarf.net>
Cc: Kevin Wallace <kevin@pentabarf.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:63234 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383Ab3LCENW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 23:13:22 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so19331965pdj.40
        for <netdev@vger.kernel.org>; Mon, 02 Dec 2013 20:13:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running in a network namespace whose only link to the outside
world is a macvlan device, not being able to create a macvtap off of
it is a real pain.

So modify macvtap creation to automatically forward a creation of a
macvtap on a macvlan to become a creation of a macvtap on the
underlying network device, just like is currently done with
macvlan-on-macvlan devices.

Signed-off-by: Kevin Wallace <kevin@pentabarf.net>
---
 drivers/net/macvlan.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 16b43bf..3fa86cb 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -757,6 +757,8 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static struct rtnl_link_ops macvlan_link_ops;
+
 int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[],
 			   int (*receive)(struct sk_buff *skb),
@@ -775,10 +777,10 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	if (lowerdev == NULL)
 		return -ENODEV;
 
-	/* When creating macvlans on top of other macvlans - use
+	/* When creating macvlans or macvtaps on top of other macvlans - use
 	 * the real device as the lowerdev.
 	 */
-	if (lowerdev->rtnl_link_ops == dev->rtnl_link_ops) {
+	if (lowerdev->rtnl_link_ops == &macvlan_link_ops) {
 		struct macvlan_dev *lowervlan = netdev_priv(lowerdev);
 		lowerdev = lowervlan->lowerdev;
 	}
-- 
1.8.3.2
