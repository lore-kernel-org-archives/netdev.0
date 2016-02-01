From: <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] bond: relocate rcu_read_lock and rcu_read_unlock
Date: Mon, 1 Feb 2016 11:31:12 +0800
Message-ID: <1454297472-24261-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <j.vosburgh@gmail.com>, <vfalico@gmail.com>,
	<gospo@cumulusnetworks.com>, <netdev@vger.kernel.org>,
	<zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:42482 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbcBAD3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 22:29:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

rcu_read_lock and rcu_read_unlock are to protect the function
bond_miimon_inspect. As such, moving rcu_read_lock and rcu_read_unlock
to the function bond_miimon_inspect to make the source code compact.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/bonding/bond_main.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 56b5605..4043181 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2022,6 +2022,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 	struct slave *slave;
 	bool ignore_updelay;
 
+	rcu_read_lock();
 	ignore_updelay = !rcu_dereference(bond->curr_active_slave);
 
 	bond_for_each_slave_rcu(bond, slave, iter) {
@@ -2113,6 +2114,8 @@ static int bond_miimon_inspect(struct bonding *bond)
 		}
 	}
 
+	rcu_read_unlock();
+
 	return commit;
 }
 
@@ -2231,12 +2234,9 @@ static void bond_mii_monitor(struct work_struct *work)
 	if (!bond_has_slaves(bond))
 		goto re_arm;
 
-	rcu_read_lock();
-
 	should_notify_peers = bond_should_notify_peers(bond);
 
 	if (bond_miimon_inspect(bond)) {
-		rcu_read_unlock();
 
 		/* Race avoidance with bond_close cancel of workqueue */
 		if (!rtnl_trylock()) {
@@ -2248,8 +2248,7 @@ static void bond_mii_monitor(struct work_struct *work)
 		bond_miimon_commit(bond);
 
 		rtnl_unlock();	/* might sleep, hold no other locks */
-	} else
-		rcu_read_unlock();
+	}
 
 re_arm:
 	if (bond->params.miimon)
-- 
1.9.1
