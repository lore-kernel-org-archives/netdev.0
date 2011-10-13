From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 4/5] sysfs: Remove support for tagged directories with untagged members.
Date: Thu, 13 Oct 2011 01:01:34 -0700
Message-ID: <m1ehyh9v6p.fsf_-_@fess.ebiederm.org>
References: <m1hb3dbae5.fsf@fess.ebiederm.org>
	<m1wrc99vjx.fsf@fess.ebiederm.org>
	<m1sjmx9vhf.fsf_-_@fess.ebiederm.org>
	<m1mxd59vfa.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Tejun Heo <htejun@gmail.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Greg Kroah-Hartman <gregkh@suse.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1mxd59vfa.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 13 Oct 2011 00:56:25 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Now that /sys/class/net/bonding_masters is implemented as a tagged sysfs
file we can remove support for untagged files in tagged directories.

This change removes any ambiguity of what a NULL namespace value
means.  A NULL namespace parameter after this patch means
that we are talking about an untagged sysfs dirent.

This makes the sysfs code much less prone to mistakes when during
maintenance.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/dir.c   |    6 +++---
 fs/sysfs/inode.c |    2 --
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index ea9120a..352d26d 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -543,7 +543,7 @@ struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
 	struct sysfs_dirent *sd;
 
 	for (sd = parent_sd->s_dir.children; sd; sd = sd->s_sibling) {
-		if (ns && sd->s_ns && (sd->s_ns != ns))
+		if (sd->s_ns != ns)
 			continue;
 		if (!strcmp(sd->s_name, name))
 			return sd;
@@ -885,7 +885,7 @@ static struct sysfs_dirent *sysfs_dir_pos(const void *ns,
 		while (pos && (ino > pos->s_ino))
 			pos = pos->s_sibling;
 	}
-	while (pos && pos->s_ns && pos->s_ns != ns)
+	while (pos && pos->s_ns != ns)
 		pos = pos->s_sibling;
 	return pos;
 }
@@ -896,7 +896,7 @@ static struct sysfs_dirent *sysfs_dir_next_pos(const void *ns,
 	pos = sysfs_dir_pos(ns, parent_sd, ino, pos);
 	if (pos)
 		pos = pos->s_sibling;
-	while (pos && pos->s_ns && pos->s_ns != ns)
+	while (pos && pos->s_ns != ns)
 		pos = pos->s_sibling;
 	return pos;
 }
diff --git a/fs/sysfs/inode.c b/fs/sysfs/inode.c
index e3f091a..527f0cc 100644
--- a/fs/sysfs/inode.c
+++ b/fs/sysfs/inode.c
@@ -336,8 +336,6 @@ int sysfs_hash_and_remove(struct sysfs_dirent *dir_sd, const void *ns, const cha
 	sysfs_addrm_start(&acxt, dir_sd);
 
 	sd = sysfs_find_dirent(dir_sd, ns, name);
-	if (sd && (sd->s_ns != ns))
-		sd = NULL;
 	if (sd)
 		sysfs_remove_one(&acxt, sd);
 
-- 
1.7.2.5
