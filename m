From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/4] bonding: Do not call free_netdev for already registered device.
Date: Fri,  2 May 2008 17:49:37 -0700
Message-ID: <12097757822222-git-send-email-fubar@us.ibm.com>
References: <12097757801056-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:54322 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761213AbYECAtq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 20:49:46 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m430pqxV011289
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:51:52 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m430nhTW258828
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:43 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m430nhpV010480
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:43 -0400
In-Reply-To: <12097757801056-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>

If the call to bond_create_sysfs_entry in bond_create fails, the
proper rollback is to call unregister_netdevice, not free_netdev.
Otherwise - kernel BUG at net/core/dev.c:4057!

Checked with artificial failures injected into bond_create_sysfs_entry.

Pavel's original patch modified by Jay Vosburgh to move code around
for clarity (remove goto-hopping within the unwind block).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6e91b4b..7ffd819 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4939,7 +4939,9 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 	if (res < 0) {
 		rtnl_lock();
 		down_write(&bonding_rwsem);
-		goto out_bond;
+		bond_deinit(bond_dev);
+		unregister_netdevice(bond_dev);
+		goto out_rtnl;
 	}
 
 	return 0;
-- 
1.5.2.4

