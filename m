From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] sysfs: Don't allow the creation of symlinks we can't remove
Date: Thu, 08 Jul 2010 09:31:24 -0700
Message-ID: <m1630q7x5v.fsf_-_@fess.ebiederm.org>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	<20100621150826.762ac9f2.akpm@linux-foundation.org>
	<m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:34234 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754873Ab0GHQbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 12:31:47 -0400
In-Reply-To: <20100622035631.GA3755@suse.de> (Greg KH's message of "Mon\, 21 Jun 2010 20\:56\:31 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Recently my tagged sysfs support revealed a flaw in the device core
that a few rare drivers are running into such that we don't always put
network devices in a class subdirectory named net/.

Since we are not creating the class directory the network devices wind
up in a non-tagged directory, but the symlinks to the network devices
from /sys/class/net are in a tagged directory.  All of which works
until we go to remove or rename the symlink.  When we remove or rename
a symlink we look in the namespace of the target of the symlink.
Since the target of the symlink is in a non-tagged sysfs directory we
don't have a namespace to look in, and we fail to remove the symlink.

Detect this problem up front and simply don't create symlinks we won't
be able to remove later.  This prevents symlink leakage and fails in
a much clearer and more understandable way.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/symlink.c |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index f71246b..44bca5f 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -28,6 +28,7 @@ static int sysfs_do_create_link(struct kobject *kobj, struct kobject *target,
 	struct sysfs_dirent *target_sd = NULL;
 	struct sysfs_dirent *sd = NULL;
 	struct sysfs_addrm_cxt acxt;
+	enum kobj_ns_type ns_type;
 	int error;
 
 	BUG_ON(!name);
@@ -58,16 +59,28 @@ static int sysfs_do_create_link(struct kobject *kobj, struct kobject *target,
 	if (!sd)
 		goto out_put;
 
-	if (sysfs_ns_type(parent_sd))
+	ns_type = sysfs_ns_type(parent_sd);
+	if (ns_type)
 		sd->s_ns = target->ktype->namespace(target);
 	sd->s_symlink.target_sd = target_sd;
 	target_sd = NULL;	/* reference is now owned by the symlink */
 
 	sysfs_addrm_start(&acxt, parent_sd);
-	if (warn)
-		error = sysfs_add_one(&acxt, sd);
-	else
-		error = __sysfs_add_one(&acxt, sd);
+	/* Symlinks must be between directories with the same ns_type */
+	if (ns_type == sysfs_ns_type(sd->s_symlink.target_sd->s_parent)) {
+		if (warn)
+			error = sysfs_add_one(&acxt, sd);
+		else
+			error = __sysfs_add_one(&acxt, sd);
+	} else {
+		error = -EINVAL;
+		WARN(1, KERN_WARNING
+			"sysfs: symlink across ns_types %s/%s -> %s/%s\n",
+			parent_sd->s_name,
+			sd->s_name,
+			sd->s_symlink.target_sd->s_parent->s_name,
+			sd->s_symlink.target_sd->s_name);
+	}
 	sysfs_addrm_finish(&acxt);
 
 	if (error)
-- 
1.6.5.2.143.g8cc62

