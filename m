From: <gregkh@suse.de>
Subject: patch sysfs-add-support-for-tagged-directories-with-untagged-members.patch added to gregkh-2.6 tree
Date: Thu, 29 Apr 2010 13:29:04 -0700
Message-ID: <1272572944250@kroah.org>
References: <1269973889-25260-4-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
To: ebiederm@xmission.com, bcrl@lhnet.ca, cornelia.huck@de.ibm.com,
	ebiederm@aristanetworks.com, ebiederm@maxwell.aristanetworks.com,
	eric.dumazet@gmail.com, gregkh@suse.de, kay.sievers@vr
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:58701 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932707Ab0D3RIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 13:08:36 -0400
In-Reply-To: <1269973889-25260-4-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    Subject: sysfs: Add support for tagged directories with untagged members.

to my gregkh-2.6 tree.  Its filename is

    sysfs-add-support-for-tagged-directories-with-untagged-members.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


>From ebiederm@xmission.com  Thu Apr 29 12:47:00 2010
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Tue, 30 Mar 2010 11:31:27 -0700
Subject: sysfs: Add support for tagged directories with untagged members.
To: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Cornelia Huck <cornelia.huck@de.ibm.com>, linux-fsdevel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Benjamin LaHaise <bcrl@lhnet.ca>, Serge Hallyn <serue@us.ibm.com>, <netdev@vger.kernel.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
Message-ID: <1269973889-25260-4-git-send-email-ebiederm@xmission.com>


From: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>

I had hopped to avoid this but the bonding driver adds a file
to /sys/class/net/  and the easiest way to handle that file is
to make it untagged and to register it only once.

So relax the rules on tagged directories, and make bonding work.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 fs/sysfs/dir.c   |   12 +++---------
 fs/sysfs/inode.c |    2 ++
 2 files changed, 5 insertions(+), 9 deletions(-)

--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -383,12 +383,6 @@ int __sysfs_add_one(struct sysfs_addrm_c
 	if (sysfs_find_dirent(acxt->parent_sd, sd->s_ns, sd->s_name))
 		return -EEXIST;
 
-	if (sysfs_ns_type(acxt->parent_sd) && !sd->s_ns) {
-		WARN(1, KERN_WARNING "sysfs: ns required in '%s' for '%s'\n",
-			acxt->parent_sd->s_name, sd->s_name);
-		return -EINVAL;
-	}
-
 	sd->s_parent = sysfs_get(acxt->parent_sd);
 
 	sysfs_link_sibling(sd);
@@ -545,7 +539,7 @@ struct sysfs_dirent *sysfs_find_dirent(s
 	struct sysfs_dirent *sd;
 
 	for (sd = parent_sd->s_dir.children; sd; sd = sd->s_sibling) {
-		if (sd->s_ns != ns)
+		if (ns && sd->s_ns && (sd->s_ns != ns))
 			continue;
 		if (!strcmp(sd->s_name, name))
 			return sd;
@@ -879,7 +873,7 @@ static struct sysfs_dirent *sysfs_dir_po
 		while (pos && (ino > pos->s_ino))
 			pos = pos->s_sibling;
 	}
-	while (pos && pos->s_ns != ns)
+	while (pos && pos->s_ns && pos->s_ns != ns)
 		pos = pos->s_sibling;
 	return pos;
 }
@@ -890,7 +884,7 @@ static struct sysfs_dirent *sysfs_dir_ne
 	pos = sysfs_dir_pos(ns, parent_sd, ino, pos);
 	if (pos)
 		pos = pos->s_sibling;
-	while (pos && pos->s_ns != ns)
+	while (pos && pos->s_ns && pos->s_ns != ns)
 		pos = pos->s_sibling;
 	return pos;
 }
--- a/fs/sysfs/inode.c
+++ b/fs/sysfs/inode.c
@@ -335,6 +335,8 @@ int sysfs_hash_and_remove(struct sysfs_d
 	sysfs_addrm_start(&acxt, dir_sd);
 
 	sd = sysfs_find_dirent(dir_sd, ns, name);
+	if (sd && (sd->s_ns != ns))
+		sd = NULL;
 	if (sd)
 		sysfs_remove_one(&acxt, sd);
 

