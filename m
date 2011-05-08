From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 079/115] sysctl: single subheader path: optimisation for paths used only once
Date: Mon,  9 May 2011 00:39:31 +0200
Message-ID: <1304894407-32201-80-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an optimisation for registering paths that you know will be
used to register a single table. Because such directories will be used
only once, sysctl will always create an entry for it when it sees it.

When sysctl registers a table, for each directory that may be used
while registering other tables we do a linear search to see if it's
already added, and, if not, add it ourselves.

For example: each netdevice will register a single table under
    	  /proc/sys/net/ipv4/conf/DEVNAME/.

The 'DEVNAME' component of the path is not used to register other
headers, and we can optimise adding that directory: we don't have to
check if it's already registered.

This will have a positive performance impact when registering many
such directories because we're doing a O(nr of sibling directories)
search. With @has_just_one_subheader=1 set we skip that search and add
the directory directly because we know no other sibling directory with
the same name was registered.

NOTE: in this example setting @has_just_one_subheader=1 for the 'conf'
ctl_path would be wrong because it's used when registering other
subheaders too (e.g. subheaders for other netdevices).

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/linux/sysctl.h |   31 +++++++++++++++++++++++++++++++
 kernel/sysctl.c        |   12 +++++++-----
 2 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 22b6eb8..bdc8c97 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1083,6 +1083,37 @@ struct ctl_table_header {
 /* struct ctl_path describes where in the hierarchy a table is added */
 struct ctl_path {
 	const char *procname;
+
+
+	/* This is an optimisation for registering paths that you know
+	 * will be used to register a single table. Because such
+	 * directories will be used only once, sysctl will always
+	 * create an entry for it when it sees it.
+	 *
+	 * When sysctl registers a table, for each directory that may
+	 * be used while registering other tables we do a linear
+	 * search to see if it's already added, and, if not, add it
+	 * ourselves.
+	 *
+	 * For example: each netdevice will register a single table
+	 * under /proc/sys/net/ipv4/conf/DEVNAME/.
+	 *
+	 * The 'DEVNAME' component of the path is not used to register
+	 * other headers, and we can optimise adding that directory:
+	 * we don't have to check if it's already registered.
+	 *
+	 * This will have a positive performance impact when
+	 * registering many such directories because we're doing a
+	 * O(nr of sibling directories) search. With
+	 * @has_just_one_subheader=1 set we skip that search and add
+	 * the directory directly because we know no other sibling
+	 * directory with the same name was registered.
+	 *
+	 * NOTE: in this example setting @has_just_one_subheader=1 for
+	 * the 'conf' ctl_path would be wrong because it's used when
+	 * registering other subheaders too (e.g. subheaders for other
+	 * netdevices). */
+	int has_just_one_subheader;
 };
 
 extern struct ctl_table_header *__register_sysctl_paths(struct ctl_table_group *g,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c207c19..9b2c05a 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1906,11 +1906,13 @@ static struct ctl_table_header *sysctl_mkdirs(struct ctl_table_header *parent,
 	retry:
 		sysctl_write_lock_head(parent);
 
-		h = mkdir_existing_dir(parent, dirs[i]->ctl_dirname);
-		if (h != NULL) {
-			sysctl_write_unlock_head(parent);
-			parent = h;
-			continue;
+		if (!path[i].has_just_one_subheader) {
+			h = mkdir_existing_dir(parent, dirs[i]->ctl_dirname);
+			if (h != NULL) {
+				sysctl_write_unlock_head(parent);
+				parent = h;
+				continue;
+			}
 		}
 
 		if (likely(!create_first_netns_corresp)) {
-- 
1.7.5.134.g1c08b
