From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH v2] bonding: fix race condition in bonding_store_slaves_active
Date: Thu, 29 Nov 2012 12:37:59 +0100
Message-ID: <1354189079-15754-1-git-send-email-nikolay@redhat.com>
References: <1353759595-30452-1-git-send-email-nikolay@redhat.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12993 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692Ab2K2MSC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 07:18:02 -0500
In-Reply-To: <1353759595-30452-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Race between bonding_store_slaves_active() and slave manipulation 
 functions. The bond_for_each_slave use in bonding_store_slaves_active()
 is not protected by any synchronization mechanism.
 NULL pointer dereference is easy to reach.
 Fixed by acquiring the bond->lock for the slave walk.

 v2: Make description text < 75 columns

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
