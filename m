From: Greg KH <gregkh@linuxfoundation.org>
Subject: [RFC PATCH] bridge sysfs binary file simplification
Date: Thu, 22 Aug 2013 11:30:48 -0700
Message-ID: <20130822183048.GA6517@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:44816 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419Ab3HVSat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 14:30:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <gregkh@linuxfoundation.org>

Attribute groups now can handle binary sysfs files, so move the bridge
binary sysfs file to be part of the larger bridge group, saving code.

Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

-- 

Stephen, this moves the binary sysfs file to be within the bridge
subdirectory, a change from where it is today, right?  Was the file
created intentionally outside of the subdir, or was it meant to be
within it?

If tools can't handle this file moving, then never mind with this patch,
it is part of my larger "audit the sysfs binary files" work that I'm
currently doing.

Also note, the sysfs file size is currently set to be 0, is that
intentional?

 net/bridge/br_sysfs_br.c |   32 ++++++++++++--------------------
 1 file changed, 12 insertions(+), 20 deletions(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 394bb96b..0d5862ea 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -782,11 +782,6 @@ static struct attribute *bridge_attrs[] = {
 	NULL
 };
 
-static struct attribute_group bridge_group = {
-	.name = SYSFS_BRIDGE_ATTR,
-	.attrs = bridge_attrs,
-};
-
 /*
  * Export the forwarding information table as a binary file
  * The records are struct __fdb_entry.
@@ -815,10 +810,17 @@ static ssize_t brforward_read(struct file *filp, struct kobject *kobj,
 	return n;
 }
 
-static struct bin_attribute bridge_forward = {
-	.attr = { .name = SYSFS_BRIDGE_FDB,
-		  .mode = S_IRUGO, },
-	.read = brforward_read,
+static BIN_ATTR_RO(brforward, 0);
+
+static struct bin_attribute *bridge_bin_attrs[] = {
+	&bin_attr_brforward,
+	NULL,
+};
+
+static struct attribute_group bridge_group = {
+	.name = SYSFS_BRIDGE_ATTR,
+	.attrs = bridge_attrs,
+	.bin_attrs = bridge_bin_attrs,
 };
 
 /*
@@ -845,22 +847,13 @@ int br_sysfs_addbr(struct net_device *dev)
 		goto out1;
 	}
 
-	err = sysfs_create_bin_file(brobj, &bridge_forward);
-	if (err) {
-		pr_info("%s: can't create attribute file %s/%s\n",
-			__func__, dev->name, bridge_forward.attr.name);
-		goto out2;
-	}
-
 	br->ifobj = kobject_create_and_add(SYSFS_BRIDGE_PORT_SUBDIR, brobj);
 	if (!br->ifobj) {
 		pr_info("%s: can't add kobject (directory) %s/%s\n",
 			__func__, dev->name, SYSFS_BRIDGE_PORT_SUBDIR);
-		goto out3;
+		goto out2;
 	}
 	return 0;
- out3:
-	sysfs_remove_bin_file(&dev->dev.kobj, &bridge_forward);
  out2:
 	sysfs_remove_group(&dev->dev.kobj, &bridge_group);
  out1:
@@ -874,6 +867,5 @@ void br_sysfs_delbr(struct net_device *dev)
 	struct net_bridge *br = netdev_priv(dev);
 
 	kobject_put(br->ifobj);
-	sysfs_remove_bin_file(kobj, &bridge_forward);
 	sysfs_remove_group(kobj, &bridge_group);
 }
