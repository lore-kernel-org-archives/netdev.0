From: Peter Christensen <pch@ordbogen.com>
Subject: [PATCH] macvlan: Don't propagate IFF_ALLMULTI changes on down interfaces.
Date: Thu,  8 May 2014 11:15:37 +0200
Message-ID: <1399540537-19262-1-git-send-email-pch@ordbogen.com>
Cc: netdev@vger.kernel.org, Peter Christensen <pch@ordbogen.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([86.58.170.13]:52004 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752850AbaEHJYh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2014 05:24:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clearing the IFF_ALLMULTI flag on a down interface could cause an allmulti
overflow on the underlying interface.

Attempting the set IFF_ALLMULTI on the underlying interface would cause an
error and the log message:

"allmulti touches root, set allmulti failed."

Signed-off-by: Peter Christensen <pch@ordbogen.com>
---
 drivers/net/macvlan.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index b0e2865..c5fb9cf 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -458,8 +458,10 @@ static void macvlan_change_rx_flags(struct net_device *dev, int change)
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
-	if (change & IFF_ALLMULTI)
-		dev_set_allmulti(lowerdev, dev->flags & IFF_ALLMULTI ? 1 : -1);
+	if (dev->flags & IFF_UP) {
+		if (change & IFF_ALLMULTI)
+			dev_set_allmulti(lowerdev, dev->flags & IFF_ALLMULTI ? 1 : -1);
+	}
 }
 
 static void macvlan_set_mac_lists(struct net_device *dev)
-- 
1.7.10.4
