From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/4] bonding: fix device name allocation error
Date: Fri, 19 Jan 2007 18:15:31 -0800
Message-ID: <200701200215.l0K2FV22021761@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Patrick McHardy <kaber@trash.net>,
	mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:47329 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932872AbXATCPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 21:15:34 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0K2FXKv027528
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:15:33 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0K2FX22277962
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:15:33 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0K2FWWO006073
	for <netdev@vger.kernel.org>; Fri, 19 Jan 2007 21:15:33 -0500
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	The code to select names for the bonding interfaces was, for the
non-sysfs creation case, always using a hard-coded set of bond0, bond1,
etc, up to max_bonds.  This caused conflicts for the second or
subsequent loads of the module.

	Changed the code to obtain device names from dev_alloc_name().

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6482aed..07b9d1f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4704,6 +4704,7 @@ static int bond_check_params(struct bond
 static struct lock_class_key bonding_netdev_xmit_lock_key;
 
 /* Create a new bond based on the specified name and bonding parameters.
+ * If name is NULL, obtain a suitable "bond%d" name for us.
  * Caller must NOT hold rtnl_lock; we need to release it here before we
  * set up our sysfs entries.
  */
@@ -4713,7 +4714,8 @@ int bond_create(char *name, struct bond_
 	int res;
 
 	rtnl_lock();
-	bond_dev = alloc_netdev(sizeof(struct bonding), name, ether_setup);
+	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
+				ether_setup);
 	if (!bond_dev) {
 		printk(KERN_ERR DRV_NAME
 		       ": %s: eek! can't alloc netdev!\n",
@@ -4722,6 +4724,12 @@ int bond_create(char *name, struct bond_
 		goto out_rtnl;
 	}
 
+	if (!name) {
+		res = dev_alloc_name(bond_dev, "bond%d");
+		if (res < 0)
+			goto out_netdev;
+	}
+
 	/* bond_init() must be called after dev_alloc_name() (for the
 	 * /proc files), but before register_netdevice(), because we
 	 * need to set function pointers.
@@ -4763,7 +4771,6 @@ static int __init bonding_init(void)
 {
 	int i;
 	int res;
-	char new_bond_name[8];  /* Enough room for 999 bonds at init. */
 
 	printk(KERN_INFO "%s", version);
 
@@ -4776,8 +4783,7 @@ #ifdef CONFIG_PROC_FS
 	bond_create_proc_dir();
 #endif
 	for (i = 0; i < max_bonds; i++) {
-		sprintf(new_bond_name, "bond%d",i);
-		res = bond_create(new_bond_name,&bonding_defaults, NULL);
+		res = bond_create(NULL, &bonding_defaults, NULL);
 		if (res)
 			goto err;
 	}
