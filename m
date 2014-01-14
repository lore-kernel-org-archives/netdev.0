From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next] bonding: handle slave's name change with primary_slave logic
Date: Tue, 14 Jan 2014 18:35:01 +0100
Message-ID: <1389720901-2298-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36717 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437AbaANRjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 12:39:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if a slave's name change, we just pass it by. However, if the
slave is a current primary_slave, then we end up with using a slave, whose
name != params.primary, for primary_slave. And vice-versa, if we don't have
a primary_slave but have params.primary set - we will not detected a new
primary_slave.

Fix this by catching the NETDEV_CHANGENAME event and setting primary_slave
accordingly. Also, if the primary_slave was changed, issue a reselection of
the active slave, cause the priorities have changed.

Reported-by: Ding Tianhong <dingtianhong@huawei.com>
CC: Ding Tianhong <dingtianhong@huawei.com>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v2->v3:
    Reword the info message, per Jay's comment.
    
    v1->v2:
    Proper patch

 drivers/net/bonding/bond_main.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e06c445..ea51661 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2860,9 +2860,26 @@ static int bond_slave_netdev_event(unsigned long event,
 		 */
 		break;
 	case NETDEV_CHANGENAME:
-		/*
-		 * TODO: handle changing the primary's name
-		 */
+		/* we don't care if we don't have primary set */
+		if (!USES_PRIMARY(bond->params.mode) ||
+		    !bond->params.primary[0])
+			break;
+
+		if (slave == bond->primary_slave) {
+			/* slave's name changed - he's no longer primary */
+			bond->primary_slave = NULL;
+		} else if (!strcmp(slave_dev->name, bond->params.primary)) {
+			/* we have a new primary slave */
+			bond->primary_slave = slave;
+		} else  /* we didn't change primary - exit */
+			break;
+
+		pr_info("%s: Primary slave changed to %s, reselecting active slave.\n",
+			bond->dev->name, bond->primary_slave ? slave_dev->name :
+							       "none");
+		write_lock_bh(&bond->curr_slave_lock);
+		bond_select_active_slave(bond);
+		write_unlock_bh(&bond->curr_slave_lock);
 		break;
 	case NETDEV_FEAT_CHANGE:
 		bond_compute_features(bond);
-- 
1.8.4
