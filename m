From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 07/10]: Return proper error codes in register_vlan_device
Date: Tue,  5 Jun 2007 16:37:01 +0200 (MEST)
Message-ID: <20070605143700.23717.47942.sendpatchset@localhost.localdomain>
References: <20070605143650.23717.91261.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64438 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932103AbXFEOhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:37:03 -0400
In-Reply-To: <20070605143650.23717.91261.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Return proper error codes in register_vlan_device

The returned device is unused, return proper error codes instead and avoid
having the ioctl handler guess the error.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f2eb0828c4cfaf4d4aed225b55ca65b052109657
tree 967dc78c7ed8931a62bdaaa0e57304e75bfe91b9
parent 312dc0ee04bed170ad8091f777fcc2108105ca2c
author Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 16:33:45 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 16:33:45 +0200

 net/8021q/vlan.c |   32 ++++++++++++++------------------
 1 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 0fa071d..03b67b9 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -498,14 +498,14 @@ out_free_group:
 }
 
 /*  Attach a VLAN device to a mac address (ie Ethernet Card).
- *  Returns the device that was created, or NULL if there was
- *  an error of some kind.
+ *  Returns 0 if the device was created or a negative error code otherwise.
  */
-static struct net_device *register_vlan_device(struct net_device *real_dev,
-					       unsigned short VLAN_ID)
+static int register_vlan_device(struct net_device *real_dev,
+				unsigned short VLAN_ID)
 {
 	struct net_device *new_dev;
 	char name[IFNAMSIZ];
+	int err;
 
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "%s: if_name -:%s:-	vid: %i\n",
@@ -513,10 +513,11 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 #endif
 
 	if (VLAN_ID > VLAN_VID_MASK)
-		goto out_ret_null;
+		return -ERANGE;
 
-	if (vlan_check_real_dev(real_dev, VLAN_ID) < 0)
-		goto out_ret_null;
+	err = vlan_check_real_dev(real_dev, VLAN_ID);
+	if (err < 0)
+		return err;
 
 	/* Gotta set up the fields for the device. */
 #ifdef VLAN_DEBUG
@@ -552,7 +553,7 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 			       vlan_setup);
 
 	if (new_dev == NULL)
-		goto out_ret_null;
+		return -ENOBUFS;
 
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "Allocated new name -:%s:-\n", new_dev->name);
@@ -566,7 +567,8 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 	VLAN_DEV_INFO(new_dev)->dent = NULL;
 	VLAN_DEV_INFO(new_dev)->flags = 1;
 
-	if (register_vlan_dev(new_dev) < 0)
+	err = register_vlan_dev(new_dev);
+	if (err < 0)
 		goto out_free_newdev;
 
 	/* Account for reference in struct vlan_dev_info */
@@ -574,13 +576,11 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "Allocated new device successfully, returning.\n");
 #endif
-	return new_dev;
+	return 0;
 
 out_free_newdev:
 	free_netdev(new_dev);
-
-out_ret_null:
-	return NULL;
+	return err;
 }
 
 static int vlan_device_event(struct notifier_block *unused, unsigned long event, void *ptr)
@@ -753,11 +753,7 @@ static int vlan_ioctl_handler(void __user *arg)
 		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			break;
-		if (register_vlan_device(dev, args.u.VID)) {
-			err = 0;
-		} else {
-			err = -EINVAL;
-		}
+		err = register_vlan_device(dev, args.u.VID);
 		break;
 
 	case DEL_VLAN_CMD:
