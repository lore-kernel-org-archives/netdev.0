From: Kevin Wallace <kevin@pentabarf.net>
Subject: [PATCH v2] macvlan: Support creating macvtaps from macvlans
Date: Tue,  3 Dec 2013 02:55:22 -0800
Message-ID: <1386068122-12039-1-git-send-email-kevin@pentabarf.net>
References: <1386043991-4372-1-git-send-email-kevin@pentabarf.net>
Cc: Michal Kubecek <mkubecek@suse.cz>,
	Kevin Wallace <kevin@pentabarf.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:44446 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372Ab3LCK4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 05:56:21 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so20644970pbb.23
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 02:56:21 -0800 (PST)
In-Reply-To: <1386043991-4372-1-git-send-email-kevin@pentabarf.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running in a network namespace whose only link to the outside
world is a macvlan device, not being able to create a macvtap off of
it is a real pain.

So modify macvtap creation to automatically forward a creation of a
macvtap on a macvlan to become a creation of a macvtap on the
underlying network device, just like is currently done with
macvlan-on-macvlan devices.

v2: Use netif_is_macvlan and macvlan_dev_real_dev helpers to make it
    more clear what we're doing.

Signed-off-by: Kevin Wallace <kevin@pentabarf.net>
---
 drivers/net/macvlan.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index acf9379..cfb9157 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -820,13 +820,11 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	if (lowerdev == NULL)
 		return -ENODEV;
 
-	/* When creating macvlans on top of other macvlans - use
+	/* When creating macvlans or macvtaps on top of other macvlans - use
 	 * the real device as the lowerdev.
 	 */
-	if (lowerdev->rtnl_link_ops == dev->rtnl_link_ops) {
-		struct macvlan_dev *lowervlan = netdev_priv(lowerdev);
-		lowerdev = lowervlan->lowerdev;
-	}
+	if (netif_is_macvlan(lowerdev))
+		lowerdev = macvlan_dev_real_dev(lowerdev);
 
 	if (!tb[IFLA_MTU])
 		dev->mtu = lowerdev->mtu;
-- 
1.8.3.2
