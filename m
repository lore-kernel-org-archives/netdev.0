From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/5] bonding: Don't destroy bonding master when removing slave via sysfs
Date: Wed,  2 Jul 2008 18:21:59 -0700
Message-ID: <1215048125108-git-send-email-fubar@us.ibm.com>
References: <12150481222323-git-send-email-fubar@us.ibm.com>
 <12150481241992-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Moni Shoua <monis@voltaire.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:53273 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751741AbYGCBWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 21:22:07 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m631M7fJ011604
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:07 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m631M7IH191566
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:07 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m631M6rh004163
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:07 -0400
In-Reply-To: <12150481241992-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@voltaire.com>

It is wrong to destroy a bonding master from a context that uses the sysfs
of that bond. When last IPoIB slave is unenslaved from by writing to a
sysfs file (for bond0 this would be /sys/class/net/bond0/bonding/slaves)
the driver tries to destroy the bond. This is wrong and can lead to a
lockup or a crash.  This fix lets the bonding master stay and relies on
the user to destroy the bonding master if necessary (i.e. before module
ib_ipoib is unloaded)

This patch affects only bonds of IPoIB slaves. Ethernet slaves stay
unaffected.

Signed-off-by: Moni Shoua <monis@voltaire.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_sysfs.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 6caac0f..3bdb473 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -350,9 +350,6 @@ static ssize_t bonding_store_slaves(struct device *d,
 		if (dev) {
 			printk(KERN_INFO DRV_NAME ": %s: Removing slave %s\n",
 				bond->dev->name, dev->name);
-			if (bond->setup_by_slave)
-				res = bond_release_and_destroy(bond->dev, dev);
-			else
 				res = bond_release(bond->dev, dev);
 			if (res) {
 				ret = res;
-- 
1.5.2.4

