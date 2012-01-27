From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 26/29] sysctl: Move sysctl_check_dups into insert_header
Date: Thu, 26 Jan 2012 20:50:07 -0800
Message-ID: <1327639810-12760-26-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify the callers of insert_header by removing explicit calls to check
for duplicates and instead have insert_header do the work.

This makes the code slightly more maintainable by enabling changes to
data structures where the insertion of new entries without duplicate
suppression is not possible.

There is not always a convenient path string where insert_header
is called so modify sysctl_check_dups to use sysctl_print_dir
when printing the full path when a duplicate is discovered.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index e0d3e7e..160d578 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -52,6 +52,7 @@ static int sysctl_follow_link(struct ctl_table_header **phead,
 	struct ctl_table **pentry, struct nsproxy *namespaces);
 static int insert_links(struct ctl_table_header *head);
 static void put_links(struct ctl_table_header *header);
+static int sysctl_check_dups(struct ctl_dir *dir, struct ctl_table *table);
 
 static void sysctl_print_dir(struct ctl_dir *dir)
 {
@@ -123,6 +124,10 @@ static int insert_header(struct ctl_dir *dir, struct ctl_table_header *header)
 {
 	int err;
 
+	err = sysctl_check_dups(dir, header->ctl_table);
+	if (err)
+		return err;
+
 	dir->header.nreg++;
 	header->parent = dir;
 	err = insert_links(header);
@@ -891,7 +896,7 @@ static int sysctl_follow_link(struct ctl_table_header **phead,
 	return ret;
 }
 
-static int sysctl_check_table_dups(const char *path, struct ctl_table *old,
+static int sysctl_check_table_dups(struct ctl_dir *dir, struct ctl_table *old,
 	struct ctl_table *table)
 {
 	struct ctl_table *entry, *test;
@@ -900,8 +905,9 @@ static int sysctl_check_table_dups(const char *path, struct ctl_table *old,
 	for (entry = old; entry->procname; entry++) {
 		for (test = table; test->procname; test++) {
 			if (strcmp(entry->procname, test->procname) == 0) {
-				printk(KERN_ERR "sysctl duplicate entry: %s/%s\n",
-					path, test->procname);
+				printk(KERN_ERR "sysctl duplicate entry: ");
+				sysctl_print_dir(dir);
+				printk(KERN_CONT "/%s\n", test->procname);
 				error = -EEXIST;
 			}
 		}
@@ -909,8 +915,7 @@ static int sysctl_check_table_dups(const char *path, struct ctl_table *old,
 	return error;
 }
 
-static int sysctl_check_dups(struct ctl_dir *dir,
-	const char *path, struct ctl_table *table)
+static int sysctl_check_dups(struct ctl_dir *dir, struct ctl_table *table)
 {
 	struct ctl_table_set *set;
 	struct ctl_table_header *head;
@@ -922,7 +927,7 @@ static int sysctl_check_dups(struct ctl_dir *dir,
 			continue;
 		if (head->parent != dir)
 			continue;
-		error = sysctl_check_table_dups(path, head->ctl_table, table);
+		error = sysctl_check_table_dups(dir, head->ctl_table, table);
 	}
 	return error;
 }
@@ -1166,9 +1171,6 @@ struct ctl_table_header *__register_sysctl_table(
 	}
 
 	spin_lock(&sysctl_lock);
-	if (sysctl_check_dups(dir, path, table))
-		goto fail_put_dir_locked;
-
 	if (insert_header(dir, header))
 		goto fail_put_dir_locked;
 
-- 
1.7.2.5
