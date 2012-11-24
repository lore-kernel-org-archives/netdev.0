From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH] bonding: fix race condition in bonding_store_slaves_active
Date: Sat, 24 Nov 2012 13:19:55 +0100
Message-ID: <1353759595-30452-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28657 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951Ab2KXMWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Nov 2012 07:22:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Race between bonding_store_slaves_active() and slave manipulation functions
 The bond_for_each_slave use in bonding_store_slaves_active() is not protected
 by any synchronization mechanism. NULL pointer dereference is easy to reach.
 Fixed by acquiring the bond->lock for the slave walk.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ef8d2a0..ba4f95b 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1582,6 +1582,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 		goto out;
 	}
 
+	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, i) {
 		if (!bond_is_active_slave(slave)) {
 			if (new_value)
@@ -1590,6 +1591,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 				slave->inactive = 1;
 		}
 	}
+	read_unlock(&bond->lock);
 out:
 	return ret;
 }
-- 
1.7.11.7
