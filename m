From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 2/2] bonding: lock RTNL when setting (in)active slave flags
Date: Thu, 23 Jan 2014 12:16:04 +0100
Message-ID: <1390475764-7675-3-git-send-email-vfalico@redhat.com>
References: <1390475764-7675-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21334 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752752AbaAWLU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 06:20:28 -0500
In-Reply-To: <1390475764-7675-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, on (in)active slave flag change, we notify the stack via
rtmsg_ifinfo(), which implies that we should hold the RTNL lock.

However, in bond_ab_arp_probe(), in case we don't have curr_active_slave -
we don't hold it, which issues a warning and might race with other slave
flags modifications.

Fix this by wrapping the changing in RTNL lock - it's not a hot path (runs
every arp_interval) - so no speed issues should arrive.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 22d8b69..50cddb9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2631,9 +2631,11 @@ static void bond_ab_arp_probe(struct bonding *bond)
 			return;
 	}
 
+	rtnl_lock();
+
 	bond_set_slave_inactive_flags(curr_arp_slave);
 
-	bond_for_each_slave_rcu(bond, slave, iter) {
+	bond_for_each_slave(bond, slave, iter) {
 		if (!found && !before && IS_UP(slave->dev))
 			before = slave;
 
@@ -2660,6 +2662,8 @@ static void bond_ab_arp_probe(struct bonding *bond)
 			found = true;
 	}
 
+	rtnl_unlock();
+
 	if (!new_slave && before)
 		new_slave = before;
 
-- 
1.8.4
