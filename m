From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] macvlan: Support creating macvlans from macvlans
Date: Thu, 05 Mar 2009 15:12:56 -0800
Message-ID: <m1ocwfsgw7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45997 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754458AbZCEXNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 18:13:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When running in a network namespace whose only link to
the outside world is a macvlan device, not being
able to create another macvlan is a real pain.

So modify macvlan creation to allow automatically forward
a creation of a macvlan on a macvlan to become a creation
of a macvlan on the underlying network device.

Signed-off-by: Eric Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/macvlan.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 7e24b50..b5241fc 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -461,12 +461,13 @@ static int macvlan_newlink(struct net_device *dev,
 	if (lowerdev == NULL)
 		return -ENODEV;
 
-	/* Don't allow macvlans on top of other macvlans - its not really
-	 * wrong, but lockdep can't handle it and its not useful for anything
-	 * you couldn't do directly on top of the real device.
+	/* When creating macvlans on top of other macvlans - use
+	 * the real device as the lowerdev.
 	 */
-	if (lowerdev->rtnl_link_ops == dev->rtnl_link_ops)
-		return -ENODEV;
+	if (lowerdev->rtnl_link_ops == dev->rtnl_link_ops) {
+		struct macvlan_dev *lowervlan = netdev_priv(lowerdev);
+		lowerdev = lowervlan->lowerdev;
+	}
 
 	if (!tb[IFLA_MTU])
 		dev->mtu = lowerdev->mtu;
-- 
1.6.1.2.350.g88cc

