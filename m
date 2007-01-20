From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/4]: bonding: fix error check in sysfs creation
Date: Fri, 19 Jan 2007 18:15:38 -0800
Message-ID: <200701200215.l0K2Fc22021827@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Patrick McHardy <kaber@trash.net>,
	mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:47359 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932873AbXATCPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 21:15:42 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0K2FeLP027622
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:15:40 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0K2FetQ240050
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:15:40 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0K2Fdlm006178
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:15:40 -0500
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	The existing code did not correctly handle failures to create
the per-interface sysfs group for bonding.

	Modified code to notice errors, and correctly unwind.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 07b9d1f..d3801a0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4756,14 +4756,19 @@ int bond_create(char *name, struct bond_
 
 	rtnl_unlock(); /* allows sysfs registration of net device */
 	res = bond_create_sysfs_entry(bond_dev->priv);
-	goto done;
+	if (res < 0) {
+		rtnl_lock();
+		goto out_bond;
+	}
+
+	return 0;
+
 out_bond:
 	bond_deinit(bond_dev);
 out_netdev:
 	free_netdev(bond_dev);
 out_rtnl:
 	rtnl_unlock();
-done:
 	return res;
 }
 
