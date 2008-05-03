From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/4] bonding: fix error unwind in bonding_store_bonds
Date: Fri,  2 May 2008 17:49:38 -0700
Message-ID: <12097757832778-git-send-email-fubar@us.ibm.com>
References: <12097757801056-git-send-email-fubar@us.ibm.com>
 <12097757822222-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:37900 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761323AbYECAtq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 20:49:46 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m430niJH031670
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:44 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m430niuL257418
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:44 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m430niQ4010499
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:44 -0400
In-Reply-To: <12097757822222-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Fixed an error unwind in bonding_store_bonds that didn't release
the locks it held, and consolidated unwinds into a common block at the
end of the function.  Bug reported by Pavel Emelyanov <xemul@openvz.org>,
who provided a different fix.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_sysfs.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 979c2d0..68c41a0 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -146,29 +146,29 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 						": Unable remove bond %s due to open references.\n",
 						ifname);
 					res = -EPERM;
-					goto out;
+					goto out_unlock;
 				}
 				printk(KERN_INFO DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
 				bond_destroy(bond);
-				up_write(&bonding_rwsem);
-				rtnl_unlock();
-				goto out;
+				goto out_unlock;
 			}
 
 		printk(KERN_ERR DRV_NAME
 			": unable to delete non-existent bond %s\n", ifname);
 		res = -ENODEV;
-		up_write(&bonding_rwsem);
-		rtnl_unlock();
-		goto out;
+		goto out_unlock;
 	}
 
 err_no_cmd:
 	printk(KERN_ERR DRV_NAME
 		": no command found in bonding_masters. Use +ifname or -ifname.\n");
-	res = -EPERM;
+	return -EPERM;
+
+out_unlock:
+	up_write(&bonding_rwsem);
+	rtnl_unlock();
 
 	/* Always return either count or an error.  If you return 0, you'll
 	 * get called forever, which is bad.
-- 
1.5.2.4

