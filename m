From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 10/29] sysctl: Add ctl_table chains into cstring paths
Date: Thu, 26 Jan 2012 20:49:51 -0800
Message-ID: <1327639810-12760-10-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For any component of table passed to __register_sysctl_paths
that actually serves as a path, add that to the cstring path
that is passed to __register_sysctl_table.

The result is that for most calls to __register_sysctl_paths
we only pass a table to __register_sysctl_table that contains
no child directories.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 5704ff0..9b91dee 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -1076,6 +1076,7 @@ struct ctl_table_header *__register_sysctl_paths(
 	struct nsproxy *namespaces,
 	const struct ctl_path *path, struct ctl_table *table)
 {
+	struct ctl_table *ctl_table_arg = table;
 	struct ctl_table_header *header = NULL;
 	const struct ctl_path *component;
 	char *new_path, *pos;
@@ -1090,7 +1091,15 @@ struct ctl_table_header *__register_sysctl_paths(
 		if (!pos)
 			goto out;
 	}
+	while (table->procname && table->child && !table[1].procname) {
+		pos = append_path(new_path, pos, table->procname);
+		if (!pos)
+			goto out;
+		table = table->child;
+	}
 	header = __register_sysctl_table(root, namespaces, new_path, table);
+	if (header)
+		header->ctl_table_arg = ctl_table_arg;
 out:
 	kfree(new_path);
 	return header;
-- 
1.7.2.5
