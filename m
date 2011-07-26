From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next v2] bonding: fix string comparison errors
Date: Tue, 26 Jul 2011 17:07:59 -0400
Message-ID: <1311714479-9260-1-git-send-email-andy@greyhouse.net>
Cc: Vitalii Demianets <vitas@nppfactor.kiev.ua>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Takuma Umeya <tumeya@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751503Ab1GZVFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2011 17:05:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a bond contains a device where one name is the subset of another
(eth1 and eth10, for example), one cannot properly set the primary
device or the currently active device.

This was reported and based on work by Takuma Umeya.  I also verified
the problem and tested that this fix resolves it.

V2: A few did not like the the current code or my changes, so I
re-factored bonding_store_primary and bonding_store_active_slave to be a
bit cleaner, dropped the use of strnicmp since we did not really need
the comparison to be case insensitive, and formatted the input string
from sysfs so a comparison to IFNAMSIZ could be used.

I also discovered an error in bonding_store_active_slave that would
modify bond->primary_slave rather than bond->curr_active_slave before
forcing the bonding driver to choose a new active slave.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Reported-by: Takuma Umeya <tumeya@redhat.com>

---
 drivers/net/bonding/bond_sysfs.c |  130 ++++++++++++++++++++------------------
 1 files changed, 68 insertions(+), 62 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index b60835f..c178b1e 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1025,6 +1025,7 @@ static ssize_t bonding_store_primary(struct device *d,
 	int i;
 	struct slave *slave;
 	struct bonding *bond = to_bond(d);
+	char ifname[IFNAMSIZ];
 
 	if (!rtnl_trylock())
 		return restart_syscall();
@@ -1035,32 +1036,33 @@ static ssize_t bonding_store_primary(struct device *d,
 	if (!USES_PRIMARY(bond->params.mode)) {
 		pr_info("%s: Unable to set primary slave; %s is in mode %d\n",
 			bond->dev->name, bond->dev->name, bond->params.mode);
-	} else {
-		bond_for_each_slave(bond, slave, i) {
-			if (strnicmp
-			    (slave->dev->name, buf,
-			     strlen(slave->dev->name)) == 0) {
-				pr_info("%s: Setting %s as primary slave.\n",
-					bond->dev->name, slave->dev->name);
-				bond->primary_slave = slave;
-				strcpy(bond->params.primary, slave->dev->name);
-				bond_select_active_slave(bond);
-				goto out;
-			}
-		}
+		goto out;
+	}
 
-		/* if we got here, then we didn't match the name of any slave */
+	sscanf(buf, "%16s", ifname); /* IFNAMSIZ */
 
-		if (strlen(buf) == 0 || buf[0] == '\n') {
-			pr_info("%s: Setting primary slave to None.\n",
-				bond->dev->name);
-			bond->primary_slave = NULL;
-				bond_select_active_slave(bond);
-		} else {
-			pr_info("%s: Unable to set %.*s as primary slave as it is not a slave.\n",
-				bond->dev->name, (int)strlen(buf) - 1, buf);
+	/* check to see if we are clearing primary */
+	if (!strlen(ifname) || buf[0] == '\n') {
+		pr_info("%s: Setting primary slave to None.\n",
+			bond->dev->name);
+		bond->primary_slave = NULL;
+		bond_select_active_slave(bond);
+		goto out;
+	}
+
+	bond_for_each_slave(bond, slave, i) {
+		if (strncmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
+			pr_info("%s: Setting %s as primary slave.\n",
+				bond->dev->name, slave->dev->name);
+			bond->primary_slave = slave;
+			strcpy(bond->params.primary, slave->dev->name);
+			bond_select_active_slave(bond);
+			goto out;
 		}
 	}
+
+	pr_info("%s: Unable to set %.*s as primary slave.\n",
+		bond->dev->name, (int)strlen(buf) - 1, buf);
 out:
 	write_unlock_bh(&bond->curr_slave_lock);
 	read_unlock(&bond->lock);
@@ -1195,6 +1197,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 	struct slave *old_active = NULL;
 	struct slave *new_active = NULL;
 	struct bonding *bond = to_bond(d);
+	char ifname[IFNAMSIZ];
 
 	if (!rtnl_trylock())
 		return restart_syscall();
@@ -1203,56 +1206,59 @@ static ssize_t bonding_store_active_slave(struct device *d,
 	read_lock(&bond->lock);
 	write_lock_bh(&bond->curr_slave_lock);
 
-	if (!USES_PRIMARY(bond->params.mode))
+	if (!USES_PRIMARY(bond->params.mode)) {
 		pr_info("%s: Unable to change active slave; %s is in mode %d\n",
 			bond->dev->name, bond->dev->name, bond->params.mode);
-	else {
-		bond_for_each_slave(bond, slave, i) {
-			if (strnicmp
-			    (slave->dev->name, buf,
-			     strlen(slave->dev->name)) == 0) {
-        			old_active = bond->curr_active_slave;
-        			new_active = slave;
-        			if (new_active == old_active) {
-					/* do nothing */
-					pr_info("%s: %s is already the current active slave.\n",
+		goto out;
+	}
+
+	sscanf(buf, "%16s", ifname); /* IFNAMSIZ */
+
+	/* check to see if we are clearing primary */
+	if (!strlen(ifname) || buf[0] == '\n') {
+		pr_info("%s: Cannot clear primary slave.\n", bond->dev->name);
+		goto out;
+	}
+
+	bond_for_each_slave(bond, slave, i) {
+		if (strncmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
+			old_active = bond->curr_active_slave;
+			new_active = slave;
+			if (new_active == old_active) {
+				/* do nothing */
+				pr_info("%s: %s is already the current"
+					" active slave.\n",
+					bond->dev->name,
+					slave->dev->name);
+				goto out;
+			}
+			else {
+				if ((new_active) &&
+				    (old_active) &&
+				    (new_active->link == BOND_LINK_UP) &&
+				    IS_UP(new_active->dev)) {
+					pr_info("%s: Setting %s as active"
+						" slave.\n",
 						bond->dev->name,
 						slave->dev->name);
-					goto out;
+					bond_change_active_slave(bond,
+								 new_active);
 				}
 				else {
-        				if ((new_active) &&
-            				    (old_active) &&
-				            (new_active->link == BOND_LINK_UP) &&
-				            IS_UP(new_active->dev)) {
-						pr_info("%s: Setting %s as active slave.\n",
-							bond->dev->name,
-							slave->dev->name);
-							bond_change_active_slave(bond, new_active);
-        				}
-					else {
-						pr_info("%s: Could not set %s as active slave; either %s is down or the link is down.\n",
-							bond->dev->name,
-							slave->dev->name,
-							slave->dev->name);
-					}
-					goto out;
+					pr_info("%s: Could not set %s as"
+						" active slave; either %s is"
+						" down or the link is down.\n",
+						bond->dev->name,
+						slave->dev->name,
+						slave->dev->name);
 				}
+				goto out;
 			}
 		}
-
-		/* if we got here, then we didn't match the name of any slave */
-
-		if (strlen(buf) == 0 || buf[0] == '\n') {
-			pr_info("%s: Setting active slave to None.\n",
-				bond->dev->name);
-			bond->primary_slave = NULL;
-			bond_select_active_slave(bond);
-		} else {
-			pr_info("%s: Unable to set %.*s as active slave as it is not a slave.\n",
-				bond->dev->name, (int)strlen(buf) - 1, buf);
-		}
 	}
+
+	pr_info("%s: Unable to set %.*s as active slave.\n",
+		bond->dev->name, (int)strlen(buf) - 1, buf);
  out:
 	write_unlock_bh(&bond->curr_slave_lock);
 	read_unlock(&bond->lock);
-- 
1.7.4.4

