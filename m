From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 004/115] sysctl: remove .child from dev/parport/PORT/
Date: Mon,  9 May 2011 00:38:16 +0200
Message-ID: <1304894407-32201-5-git-send-email-lucian.grijincu@gmail.com>
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
 drivers/parport/procfs.c |   48 ++++++++++++++-------------------------------
 1 files changed, 15 insertions(+), 33 deletions(-)

diff --git a/drivers/parport/procfs.c b/drivers/parport/procfs.c
index 350233e..e55b9b6 100644
--- a/drivers/parport/procfs.c
+++ b/drivers/parport/procfs.c
@@ -233,13 +233,6 @@ static int do_hardware_modes (ctl_table *table, int write,
 	return copy_to_user(result, buffer, len) ? -EFAULT : 0;
 }
 
-#define PARPORT_PORT_DIR(CHILD) { .procname = NULL, .mode = 0555, .child = CHILD }
-#define PARPORT_PARPORT_DIR(CHILD) { .procname = "parport", \
-                                     .mode = 0555, .child = CHILD }
-#define PARPORT_DEV_DIR(CHILD) { .procname = "dev", .mode = 0555, .child = CHILD }
-#define PARPORT_DEVICES_ROOT_DIR  {  .procname = "devices", \
-                                    .mode = 0555, .child = NULL }
-
 static const unsigned long parport_min_timeslice_value =
 PARPORT_MIN_TIMESLICE_VALUE;
 
@@ -257,14 +250,10 @@ struct parport_sysctl_table {
 	struct ctl_table_header *sysctl_header;
 	ctl_table vars[12];
 	ctl_table device_dir[2];
-	ctl_table port_dir[2];
-	ctl_table parport_dir[2];
-	ctl_table dev_dir[2];
 };
 
 static const struct parport_sysctl_table parport_sysctl_template = {
-	.sysctl_header = NULL,
-        {
+        .vars = {
 		{
 			.procname	= "spintime",
 			.data		= NULL,
@@ -302,7 +291,11 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 			.mode		= 0444,
 			.proc_handler	= do_hardware_modes
 		},
-		PARPORT_DEVICES_ROOT_DIR,
+		{
+			.procname = "devices",
+			.mode = 0555,
+			.child = NULL, /* child will point to .device_dir */
+		},
 #ifdef CONFIG_PARPORT_1284
 		{
 			.procname	= "autoprobe",
@@ -342,7 +335,7 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 #endif /* IEEE 1284 support */
 		{}
 	},
-	{
+	.device_dir = {
 		{
 			.procname	= "active",
 			.data		= NULL,
@@ -352,18 +345,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 		},
 		{}
 	},
-	{
-		PARPORT_PORT_DIR(NULL),
-		{}
-	},
-	{
-		PARPORT_PARPORT_DIR(NULL),
-		{}
-	},
-	{
-		PARPORT_DEV_DIR(NULL),
-		{}
-	}
 };
 
 struct parport_device_sysctl_table
@@ -391,6 +372,12 @@ parport_device_sysctl_template = {
 
 int parport_proc_register(struct parport *port)
 {
+	struct ctl_path parport_port_path[] = {
+		{ .procname = "dev" },
+		{ .procname = "parport" },
+		{ .procname = port->name },
+		{  },
+	};
 	struct parport_sysctl_table *t;
 	int i;
 
@@ -409,15 +396,10 @@ int parport_proc_register(struct parport *port)
 	for (i = 0; i < 5; i++)
 		t->vars[6 + i].extra2 = &port->probe_info[i];
 
-	t->port_dir[0].procname = port->name;
-
-	t->dev_dir[0].child = t->parport_dir;
-	t->parport_dir[0].child = t->port_dir;
-	t->port_dir[0].child = t->vars;
 	t->vars[5].child = t->device_dir;
-	/* vars[5] = PARPORT_DEVICES_ROOT_DIR => .procname = 'devices' */
+	/* vars[5].procname is the 'devices' dir entry */
 
-	t->sysctl_header = register_sysctl_table(t->dev_dir);
+	t->sysctl_header = register_sysctl_paths(parport_port_path, t->vars);
 	if (t->sysctl_header == NULL) {
 		kfree(t);
 		t = NULL;
-- 
1.7.5.134.g1c08b
