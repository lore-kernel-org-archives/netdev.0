From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/4] bonding: modify sysfs support to permit multiple loads
Date: Fri, 19 Jan 2007 18:15:47 -0800
Message-ID: <200701200215.l0K2Fl22021913@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Patrick McHardy <kaber@trash.net>,
	mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:36124 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932877AbXATCQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 21:16:50 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0K2GnLj012294
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:16:49 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0K2Fno3247210
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:15:49 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0K2FmB8030908
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:15:48 -0500
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	The existing code would blindly attempt to create the
bonding_masters file (in /sys/class/net) every time the module was
loaded.  When the module is loaded multiple times (which is the
historical method used by initscripts and sysconfig to create multiple
bonding interfaces), this caused load failure of the second module load
attempt, as the creation request would fail.

	This changes the code to note the failure, arrange to not remove
the bonding_masters file upon module exit, and then return success.

	Bonding interfaces created by the second or subsequent loads of
the module will not exist in bonding_masters.  This is not a significant
change, as previously only the interfaces from the most recent load of
the module would be listed.  Both situations are less than optimal, but
this case permits compatibility with existing distro configuration
scripts, and is consistent.

	Note that previously, the sysfs create request would overwrite
the exsting bonding_masters file and succeed, allowing multiple loads of
the module.  The sysfs code has recently changed to return an error if
the file being created already exists.

	Patrick McHardy <kaber@trash.net>, who reported this problem,
observed crashes on the old kernel (before sysfs checked for
duplicates).  I did not experience such crashes, but this change should
resolve them.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>



diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ced9ed8..8e317e1 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1372,6 +1372,21 @@ int bond_create_sysfs(void)
 		return -ENODEV;
 
 	ret = class_create_file(netdev_class, &class_attr_bonding_masters);
+	/*
+	 * Permit multiple loads of the module by ignoring failures to
+	 * create the bonding_masters sysfs file.  Bonding devices
+	 * created by second or subsequent loads of the module will
+	 * not be listed in, or controllable by, bonding_masters, but
+	 * will have the usual "bonding" sysfs directory.
+	 *
+	 * This is done to preserve backwards compatibility for
+	 * initscripts/sysconfig, which load bonding multiple times to
+	 * configure multiple bonding devices.
+	 */
+	if (ret == -EEXIST) {
+		netdev_class = NULL;
+		return 0;
+	}
 
 	return ret;
 
