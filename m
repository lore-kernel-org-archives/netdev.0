From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 001/115] sysctl: remove .child from dev/parport/default
Date: Mon,  9 May 2011 00:38:13 +0200
Message-ID: <1304894407-32201-2-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49055 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755455Ab1EHWk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:40:29 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch in a series that will end with a rewrite of sysctl. The
new implementation needs to get rid of the .child field of ctl_table.

Same functionality, but a little more clarity.

MAINTAINERS says parport is "Orphan" and I don't have a parallel
port. I minimally tested this patch, but I don't know who to resort to
for an ACK.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 drivers/parport/procfs.c |   96 +++++++++++++++++++---------------------------
 1 files changed, 40 insertions(+), 56 deletions(-)

diff --git a/drivers/parport/procfs.c b/drivers/parport/procfs.c
index 3f56bc0..89b8b71 100644
--- a/drivers/parport/procfs.c
+++ b/drivers/parport/procfs.c
@@ -419,56 +419,6 @@ parport_device_sysctl_template = {
 	}
 };
 
-struct parport_default_sysctl_table
-{
-	struct ctl_table_header *sysctl_header;
-	ctl_table vars[3];
-        ctl_table default_dir[2];
-	ctl_table parport_dir[2];
-	ctl_table dev_dir[2];
-};
-
-static struct parport_default_sysctl_table
-parport_default_sysctl_table = {
-	.sysctl_header	= NULL,
-	{
-		{
-			.procname	= "timeslice",
-			.data		= &parport_default_timeslice,
-			.maxlen		= sizeof(parport_default_timeslice),
-			.mode		= 0644,
-			.proc_handler	= proc_doulongvec_ms_jiffies_minmax,
-			.extra1		= (void*) &parport_min_timeslice_value,
-			.extra2		= (void*) &parport_max_timeslice_value
-		},
-		{
-			.procname	= "spintime",
-			.data		= &parport_default_spintime,
-			.maxlen		= sizeof(parport_default_spintime),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_minmax,
-			.extra1		= (void*) &parport_min_spintime_value,
-			.extra2		= (void*) &parport_max_spintime_value
-		},
-		{}
-	},
-	{
-		{
-			.procname	= "default",
-			.mode		= 0555,
-			.child		= parport_default_sysctl_table.vars
-		},
-		{}
-	},
-	{
-		PARPORT_PARPORT_DIR(parport_default_sysctl_table.default_dir),
-		{}
-	},
-	{
-		PARPORT_DEV_DIR(parport_default_sysctl_table.parport_dir),
-		{}
-	}
-};
 
 
 int parport_proc_register(struct parport *port)
@@ -558,19 +508,53 @@ int parport_device_proc_unregister(struct pardevice *device)
 	return 0;
 }
 
+
+static struct ctl_table_header *parport_default_sysctl_header;
+
+static struct ctl_table parport_default_sysctl_table[] = {
+	{
+		.procname	= "timeslice",
+		.data		= &parport_default_timeslice,
+		.maxlen		= sizeof(parport_default_timeslice),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_ms_jiffies_minmax,
+		.extra1		= (void*) &parport_min_timeslice_value,
+		.extra2		= (void*) &parport_max_timeslice_value
+	},
+	{
+		.procname	= "spintime",
+		.data		= &parport_default_spintime,
+		.maxlen		= sizeof(parport_default_spintime),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void*) &parport_min_spintime_value,
+		.extra2		= (void*) &parport_max_spintime_value
+	},
+	{ },
+};
+
+static const __initdata struct ctl_path parport_default_path[] = {
+	{ .procname = "dev" },
+	{ .procname = "parport" },
+	{ .procname = "default" },
+	{  },
+};
+
 static int __init parport_default_proc_register(void)
 {
-	parport_default_sysctl_table.sysctl_header =
-		register_sysctl_table(parport_default_sysctl_table.dev_dir);
+	parport_default_sysctl_header =
+		register_sysctl_paths(parport_default_path,
+				      parport_default_sysctl_table);
+	/* XXX: if this fails then we can't access the sysctl tables for
+	 * /proc/sys/dev/parport/default/. Should the module fail to load? */
 	return 0;
 }
 
 static void __exit parport_default_proc_unregister(void)
 {
-	if (parport_default_sysctl_table.sysctl_header) {
-		unregister_sysctl_table(parport_default_sysctl_table.
-					sysctl_header);
-		parport_default_sysctl_table.sysctl_header = NULL;
+	if (parport_default_sysctl_header) {
+		unregister_sysctl_table(parport_default_sysctl_header);
+		parport_default_sysctl_header = NULL;
 	}
 }
 
-- 
1.7.5.134.g1c08b

