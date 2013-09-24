From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 13/27] bonding: rework bond_find_best_slave() to use bond_for_each_slave()
Date: Tue, 24 Sep 2013 13:46:53 +0200
Message-ID: <1380023227-9576-14-git-send-email-vfalico@redhat.com>
References: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753361Ab3IXLrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 07:47:18 -0400
In-Reply-To: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_find_best_slave() does not have to be balanced - i.e. return the slave
that is *after* some other slave, but rather return the best slave that
suits, except of bond->primary_slave - in which case we just return it if
it's suitable.

After that we just look through all the slaves and return either first up
slave or the slave whose link came back earliest.

We also don't care about curr_active_slave lock cause we use it in
bond_should_change_active() only and there we take it right away - i.e. it
won't go away.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    New patch.

 drivers/net/bonding/bond_main.c | 43 ++++++++++++-----------------------------
 1 file changed, 12 insertions(+), 31 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 85e99ae..6abbfac 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -785,43 +785,24 @@ static bool bond_should_change_active(struct bonding *bond)
 /**
  * find_best_interface - select the best available slave to be the active one
  * @bond: our bonding struct
- *
- * Warning: Caller must hold curr_slave_lock for writing.
  */
 static struct slave *bond_find_best_slave(struct bonding *bond)
 {
-	struct slave *new_active, *old_active;
-	struct slave *bestslave = NULL;
+	struct slave *slave, *bestslave = NULL;
+	struct list_head *iter;
 	int mintime = bond->params.updelay;
-	int i;
 
-	new_active = bond->curr_active_slave;
-
-	if (!new_active) { /* there were no active slaves left */
-		new_active = bond_first_slave(bond);
-		if (!new_active)
-			return NULL; /* still no slave, return NULL */
-	}
+	if (bond->primary_slave && bond->primary_slave->link == BOND_LINK_UP &&
+	    bond_should_change_active(bond))
+		return bond->primary_slave;
 
-	if ((bond->primary_slave) &&
-	    bond->primary_slave->link == BOND_LINK_UP &&
-	    bond_should_change_active(bond)) {
-		new_active = bond->primary_slave;
-	}
-
-	/* remember where to stop iterating over the slaves */
-	old_active = new_active;
-
-	bond_for_each_slave_from(bond, new_active, i, old_active) {
-		if (new_active->link == BOND_LINK_UP) {
-			return new_active;
-		} else if (new_active->link == BOND_LINK_BACK &&
-			   IS_UP(new_active->dev)) {
-			/* link up, but waiting for stabilization */
-			if (new_active->delay < mintime) {
-				mintime = new_active->delay;
-				bestslave = new_active;
-			}
+	bond_for_each_slave(bond, slave, iter) {
+		if (slave->link == BOND_LINK_UP)
+			return slave;
+		if (slave->link == BOND_LINK_BACK && IS_UP(slave->dev) &&
+		    slave->delay < mintime) {
+			mintime = slave->delay;
+			bestslave = slave;
 		}
 	}
 
-- 
1.8.4
