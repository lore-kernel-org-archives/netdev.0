From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 2/3] sysfs: remove error messages for -EEXIST case
Date: Thu, 15 May 2008 11:31:31 +0200
Message-ID: <20080515113131.2cea2bce@gondolin.boeblingen.de.ibm.com>
References: <20080514181257.74fbb5aa@extreme>
	<20080514181603.411e834f@extreme>
	<20080515095246.3b6a0d1d@gondolin.boeblingen.de.ibm.com>
	<20080515.010139.219194657.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, greg@kroah.com, fubar@us.ibm.com,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:52734 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbYEOJcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 05:32:33 -0400
In-Reply-To: <20080515.010139.219194657.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2008 01:01:39 -0700 (PDT),
David Miller <davem@davemloft.net> wrote:

> From: Cornelia Huck <cornelia.huck@de.ibm.com>
> Date: Thu, 15 May 2008 09:52:46 +0200
> 
> > >  int sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd)
> > >  {
> > > -	if (sysfs_find_dirent(acxt->parent_sd, sd->s_name)) {
> > > -		printk(KERN_WARNING "sysfs: duplicate filename '%s' "
> > > -		       "can not be created\n", sd->s_name);
> > > -		WARN_ON(1);
> > > +	if (sysfs_find_dirent(acxt->parent_sd, sd->s_name))
> > >  		return -EEXIST;
> > > -	}
> > > 
> > >  	sd->s_parent = sysfs_get(acxt->parent_sd);
> > 
> > ...but this will cause many useful warnings to disappear.
> > 
> > What to do here?
> 
> Make a __sysfs_add_one() that doesn't warn.   Make
> sysfs_add_one() be a wrapper around __sysfs_add_one()
> that warns.
> 
> Change networking to call __sysfs_add_one().

Like this (not even compile tested)? This depends on being able to
properly isolate the functions called though, or we need to get the
nowarn flag one level further up.

diff --git a/drivers/base/core.c b/drivers/base/core.c
index be288b5..a9058f4 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1209,8 +1209,8 @@ #ifdef CONFIG_SYSFS_DEPRECATED
 	if (old_class_name) {
 		new_class_name = make_class_name(dev->class->name, &dev->kobj);
 		if (new_class_name) {
-			error = sysfs_create_link(&dev->parent->kobj,
-						  &dev->kobj, new_class_name);
+			error = __sysfs_create_link(&dev->parent->kobj,
+						  &dev->kobj, new_class_name, 1);
 			if (error)
 				goto out;
 			sysfs_remove_link(&dev->parent->kobj, old_class_name);
@@ -1219,8 +1219,8 @@ #ifdef CONFIG_SYSFS_DEPRECATED
 #else
 	if (dev->class) {
 		sysfs_remove_link(&dev->class->subsys.kobj, old_device_name);
-		error = sysfs_create_link(&dev->class->subsys.kobj, &dev->kobj,
-					  dev->bus_id);
+		error = __sysfs_create_link(&dev->class->subsys.kobj, &dev->kobj,
+					  dev->bus_id, 1);
 		if (error) {
 			dev_err(dev, "%s: sysfs_create_symlink failed (%d)\n",
 				__func__, error);
diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index a1c3a1f..b7914a0 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -397,6 +397,23 @@ void sysfs_addrm_start(struct sysfs_addr
 		iput(inode);
 }
 
+int __sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd)
+{
+	if (sysfs_find_dirent(acxt->parent_sd, sd->s_name))
+		return -EEXIST;
+
+	sd->s_parent = sysfs_get(acxt->parent_sd);
+
+	if (sysfs_type(sd) == SYSFS_DIR && acxt->parent_inode)
+		inc_nlink(acxt->parent_inode);
+
+	acxt->cnt++;
+
+	sysfs_link_sibling(sd);
+
+	return 0;
+}
+
 /**
  *	sysfs_add_one - add sysfs_dirent to parent
  *	@acxt: addrm context to use
@@ -419,23 +436,14 @@ void sysfs_addrm_start(struct sysfs_addr
  */
 int sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd)
 {
-	if (sysfs_find_dirent(acxt->parent_sd, sd->s_name)) {
+	int err = __sysfs_add_one(acxt, sd);
+
+	if (err == -EEXIST) {
 		printk(KERN_WARNING "sysfs: duplicate filename '%s' "
 		       "can not be created\n", sd->s_name);
 		WARN_ON(1);
-		return -EEXIST;
 	}
-
-	sd->s_parent = sysfs_get(acxt->parent_sd);
-
-	if (sysfs_type(sd) == SYSFS_DIR && acxt->parent_inode)
-		inc_nlink(acxt->parent_inode);
-
-	acxt->cnt++;
-
-	sysfs_link_sibling(sd);
-
-	return 0;
+	return err;
 }
 
 /**
diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index 817f596..c08184d 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -25,7 +25,8 @@ #include "sysfs.h"
  *	@target:	object we're pointing to.
  *	@name:		name of the symlink.
  */
-int sysfs_create_link(struct kobject * kobj, struct kobject * target, const char * name)
+int __sysfs_create_link(struct kobject * kobj, struct kobject * target,
+			const char * name, int nowarn)
 {
 	struct sysfs_dirent *parent_sd = NULL;
 	struct sysfs_dirent *target_sd = NULL;
@@ -65,7 +66,10 @@ int sysfs_create_link(struct kobject * k
 	target_sd = NULL;	/* reference is now owned by the symlink */
 
 	sysfs_addrm_start(&acxt, parent_sd);
-	error = sysfs_add_one(&acxt, sd);
+	if (nowarn)
+		error = __sysfs_add_one(&acxt, sd);
+	else
+		error = sysfs_add_one(&acxt, sd);
 	sysfs_addrm_finish(&acxt);
 
 	if (error)
@@ -79,6 +83,12 @@ int sysfs_create_link(struct kobject * k
 	return error;
 }
 
+int sysfs_create_link(struct kobject * kobj, struct kobject * target,
+		      const char * name)
+{
+	return sysfs_create_link(kobj, target, name, 0);
+}
+
 /**
  *	sysfs_remove_link - remove symlink in object's directory.
  *	@kobj:	object we're acting for.
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index ce4e15f..1d459f5 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -108,6 +108,7 @@ void sysfs_put_active_two(struct sysfs_d
 void sysfs_addrm_start(struct sysfs_addrm_cxt *acxt,
 		       struct sysfs_dirent *parent_sd);
 int sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd);
+int __sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd);
 void sysfs_remove_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd);
 void sysfs_addrm_finish(struct sysfs_addrm_cxt *acxt);
 
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index 7858eac..3ef8ae7 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -101,6 +101,8 @@ void sysfs_remove_bin_file(struct kobjec
 
 int __must_check sysfs_create_link(struct kobject *kobj, struct kobject *target,
 				   const char *name);
+int __sysfs_create_link(struct kobject *kobj, struct kobject *target,
+			const char *name, int nowarn);
 void sysfs_remove_link(struct kobject *kobj, const char *name);
 
 int __must_check sysfs_create_group(struct kobject *kobj,
