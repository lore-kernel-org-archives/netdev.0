From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 016/115] sysctl: remove .child from xpc/hb
Date: Mon,  9 May 2011 00:38:28 +0200
Message-ID: <1304894407-32201-17-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 drivers/misc/sgi-xp/xpc_main.c |   69 +++++++++++++++++++++++-----------------
 1 files changed, 40 insertions(+), 29 deletions(-)

diff --git a/drivers/misc/sgi-xp/xpc_main.c b/drivers/misc/sgi-xp/xpc_main.c
index 642efb1..414d68b 100644
--- a/drivers/misc/sgi-xp/xpc_main.c
+++ b/drivers/misc/sgi-xp/xpc_main.c
@@ -88,46 +88,52 @@ int xpc_disengage_timelimit = XPC_DISENGAGE_DEFAULT_TIMELIMIT;
 static int xpc_disengage_min_timelimit;	/* = 0 */
 static int xpc_disengage_max_timelimit = 120;
 
-static ctl_table xpc_sys_xpc_hb_dir[] = {
+static ctl_table xpc_hb_table[] = {
 	{
-	 .procname = "hb_interval",
-	 .data = &xpc_hb_interval,
-	 .maxlen = sizeof(int),
-	 .mode = 0644,
-	 .proc_handler = proc_dointvec_minmax,
-	 .extra1 = &xpc_hb_min_interval,
-	 .extra2 = &xpc_hb_max_interval},
+		.procname = "hb_interval",
+		.data = &xpc_hb_interval,
+		.maxlen = sizeof(int),
+		.mode = 0644,
+		.proc_handler = proc_dointvec_minmax,
+		.extra1 = &xpc_hb_min_interval,
+		.extra2 = &xpc_hb_max_interval
+	},
 	{
-	 .procname = "hb_check_interval",
-	 .data = &xpc_hb_check_interval,
-	 .maxlen = sizeof(int),
-	 .mode = 0644,
-	 .proc_handler = proc_dointvec_minmax,
-	 .extra1 = &xpc_hb_check_min_interval,
-	 .extra2 = &xpc_hb_check_max_interval},
-	{}
+		.procname = "hb_check_interval",
+		.data = &xpc_hb_check_interval,
+		.maxlen = sizeof(int),
+		.mode = 0644,
+		.proc_handler = proc_dointvec_minmax,
+		.extra1 = &xpc_hb_check_min_interval,
+		.extra2 = &xpc_hb_check_max_interval
+	},
+	{ }
 };
-static ctl_table xpc_sys_xpc_dir[] = {
-	{
-	 .procname = "hb",
-	 .mode = 0555,
-	 .child = xpc_sys_xpc_hb_dir},
+static ctl_table xpc_table[] = {
 	{
-	 .procname = "disengage_timelimit",
-	 .data = &xpc_disengage_timelimit,
-	 .maxlen = sizeof(int),
-	 .mode = 0644,
-	 .proc_handler = proc_dointvec_minmax,
-	 .extra1 = &xpc_disengage_min_timelimit,
-	 .extra2 = &xpc_disengage_max_timelimit},
-	{}
+		.procname = "disengage_timelimit",
+		.data = &xpc_disengage_timelimit,
+		.maxlen = sizeof(int),
+		.mode = 0644,
+		.proc_handler = proc_dointvec_minmax,
+		.extra1 = &xpc_disengage_min_timelimit,
+		.extra2 = &xpc_disengage_max_timelimit
+	},
+	{ }
 };
 static const __initdata struct ctl_path xpc_path[] = {
 	{ .procname = "xpc" },
 	{ }
 };
 
+static const __initdata struct ctl_path xpc_hb_path[] = {
+	{ .procname = "xpc" },
+	{ .procname = "hb" },
+	{ }
+};
+
 static struct ctl_table_header *xpc_sysctl;
+static struct ctl_table_header *xpc_hb_sysctl;
 
 /* non-zero if any remote partition disengage was timed out */
 int xpc_disengage_timedout;
@@ -1040,6 +1046,8 @@ xpc_do_exit(enum xp_retval reason)
 	/* clear the interface to XPC's functions */
 	xpc_clear_interface();
 
+	if (xpc_hb_sysctl)
+		unregister_sysctl_table(xpc_hb_sysctl);
 	if (xpc_sysctl)
 		unregister_sysctl_table(xpc_sysctl);
 
@@ -1235,6 +1243,7 @@ xpc_init(void)
 	}
 
 	xpc_sysctl = register_sysctl_paths(xpc_path, xpc_sys_xpc_dir);
+	xpc_hb_sysctl = register_sysctl_paths(xpc_hb_path, xpc_hb_table);
 
 	/*
 	 * Fill the partition reserved page with the information needed by
@@ -1299,6 +1308,8 @@ out_3:
 	(void)unregister_die_notifier(&xpc_die_notifier);
 	(void)unregister_reboot_notifier(&xpc_reboot_notifier);
 out_2:
+	if (xpc_hb_sysctl)
+		unregister_sysctl_table(xpc_hb_sysctl);
 	if (xpc_sysctl)
 		unregister_sysctl_table(xpc_sysctl);
 
-- 
1.7.5.134.g1c08b
