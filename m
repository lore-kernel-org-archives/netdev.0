From: Mazhar Rana <ranamazharp@gmail.com>
Subject: [PATCH] bonding: "primary_reselect" with "failure" is not working properly
Date: Thu,  2 Jul 2015 15:43:46 +0530
Message-ID: <1435832026-19918-1-git-send-email-ranamazharp@gmail.com>
Cc: Mazhar Rana <ranamazharp@gmail.com>, davem@davemloft.net,
	sanket.shah@cyberoam.com, mazhar.rana@cyberoam.com,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36349 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444AbbGBKOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 06:14:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When "primary_reselect" is set to "failure", primary interface should
not become active until current active slave is up. But if we set first
member of bond device as a "primary" interface and "primary_reselect"
is set to "failure" then whenever primary interface's link get back(up)
it become active slave even if current active slave is still up.

With this patch, "bond_find_best_slave" will not traverse members if
primary interface is not candidate for failover/reselection and current
active slave is still up.

Signed-off-by: Mazhar Rana <mazhar.rana@cyberoam.com>
Reviewed-by: Sanket Shah <sanket.shah@cyberoam.com>
---
 drivers/net/bonding/bond_main.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 19eb990..ac71261 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -715,7 +715,7 @@ static bool bond_should_change_active(struct bonding *bond)
  */
 static struct slave *bond_find_best_slave(struct bonding *bond)
 {
-	struct slave *slave, *bestslave = NULL, *primary;
+	struct slave *slave, *bestslave = NULL, *primary, *curr;
 	struct list_head *iter;
 	int mintime = bond->params.updelay;
 
@@ -724,6 +724,14 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
 	    bond_should_change_active(bond))
 		return primary;
 
+	/* We are here means primary interface is not candidate for
+	 * reslection/failover. If currenet active slave is still up
+	 * then there is no meaning to traverse  members.
+	 */
+	curr = rtnl_dereference(bond->curr_active_slave);
+	if (curr && curr->link == BOND_LINK_UP)
+		return bond->curr_active_slave;
+
 	bond_for_each_slave(bond, slave, iter) {
 		if (slave->link == BOND_LINK_UP)
 			return slave;
-- 
1.9.1
