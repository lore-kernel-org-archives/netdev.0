From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 08/29] sysctl: Create local copies of directory names used in paths
Date: Thu, 26 Jan 2012 20:51:44 -0800
Message-ID: <1327639925-12920-8-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Creating local copies of directory names is a good idea for
two reasons.
- The dynamic names used by callers must be copied into new
  strings by the callers today to ensure the strings do not
  change between register and unregister of the sysctl table.

- Sysctl directories have a potentially different lifetime
  than the time between register and unregister of any
  particular sysctl table.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 86d32a3..bcf60fb 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -943,10 +943,12 @@ struct ctl_table_header *__register_sysctl_paths(
 	struct ctl_table *new, **prevp;
 	unsigned int n, npath;
 	struct ctl_table_set *set;
+	size_t path_bytes = 0;
+	char *new_name;
 
 	/* Count the path components */
 	for (npath = 0; path[npath].procname; ++npath)
-		;
+		path_bytes += strlen(path[npath].procname) + 1;
 
 	/*
 	 * For each path component, allocate a 2-element ctl_table array.
@@ -956,24 +958,27 @@ struct ctl_table_header *__register_sysctl_paths(
 	 * We allocate everything in one go so that we don't have to
 	 * worry about freeing additional memory in unregister_sysctl_table.
 	 */
-	header = kzalloc(sizeof(struct ctl_table_header) +
+	header = kzalloc(sizeof(struct ctl_table_header) + path_bytes +
 			 (2 * npath * sizeof(struct ctl_table)), GFP_KERNEL);
 	if (!header)
 		return NULL;
 
 	new = (struct ctl_table *) (header + 1);
+	new_name = (char *)(new + (2 * npath));
 
 	/* Now connect the dots */
 	prevp = &header->ctl_table;
 	for (n = 0; n < npath; ++n, ++path) {
 		/* Copy the procname */
-		new->procname = path->procname;
+		strcpy(new_name, path->procname);
+		new->procname = new_name;
 		new->mode     = 0555;
 
 		*prevp = new;
 		prevp = &new->child;
 
 		new += 2;
+		new_name += strlen(new_name) + 1;
 	}
 	*prevp = table;
 	header->ctl_table_arg = table;
-- 
1.7.2.5

