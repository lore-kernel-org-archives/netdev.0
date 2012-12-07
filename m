From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] bonding: Fix check for ethtool get_link operation
 support
Date: Fri, 7 Dec 2012 16:15:32 +0000
Message-ID: <1354896932.2707.5.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8498 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932789Ab2LGQPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 11:15:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 2c60db037034 ('net: provide a default dev->ethtool_ops')
all devices have a non-null ethtool_ops.  Test only
dev->ethtool_ops->get_link in both places where we care.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Compile-tested only.

Ben.

 drivers/net/bonding/bond_main.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c8bff3e..800a897 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -615,15 +615,9 @@ static int bond_check_dev_link(struct bonding *bond,
 		return netif_carrier_ok(slave_dev) ? BMSR_LSTATUS : 0;
 
 	/* Try to get link status using Ethtool first. */
-	if (slave_dev->ethtool_ops) {
-		if (slave_dev->ethtool_ops->get_link) {
-			u32 link;
-
-			link = slave_dev->ethtool_ops->get_link(slave_dev);
-
-			return link ? BMSR_LSTATUS : 0;
-		}
-	}
+	if (slave_dev->ethtool_ops->get_link)
+		return slave_dev->ethtool_ops->get_link(slave_dev) ?
+			BMSR_LSTATUS : 0;
 
 	/* Ethtool can't be used, fallback to MII ioctls. */
 	ioctl = slave_ops->ndo_do_ioctl;
@@ -1510,8 +1504,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	int link_reporting;
 	int res = 0;
 
-	if (!bond->params.use_carrier && slave_dev->ethtool_ops == NULL &&
-		slave_ops->ndo_do_ioctl == NULL) {
+	if (!bond->params.use_carrier &&
+	    slave_dev->ethtool_ops->get_link == NULL &&
+	    slave_ops->ndo_do_ioctl == NULL) {
 		pr_warning("%s: Warning: no link monitoring support for %s\n",
 			   bond_dev->name, slave_dev->name);
 	}
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
