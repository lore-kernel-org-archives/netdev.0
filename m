From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 005/115] sysctl: remove .child from dev/parport/PORT/devices/
Date: Mon,  9 May 2011 00:38:17 +0200
Message-ID: <1304894407-32201-6-git-send-email-lucian.grijincu@gmail.com>
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
 drivers/parport/procfs.c |   42 ++++++++++++++++++++++++++++--------------
 1 files changed, 28 insertions(+), 14 deletions(-)

diff --git a/drivers/parport/procfs.c b/drivers/parport/procfs.c
index e55b9b6..3bb5bed 100644
--- a/drivers/parport/procfs.c
+++ b/drivers/parport/procfs.c
@@ -248,6 +248,7 @@ PARPORT_MAX_SPINTIME_VALUE;
 
 struct parport_sysctl_table {
 	struct ctl_table_header *sysctl_header;
+	struct ctl_table_header *devices_sysctl_header;
 	ctl_table vars[12];
 	ctl_table device_dir[2];
 };
@@ -291,11 +292,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 			.mode		= 0444,
 			.proc_handler	= do_hardware_modes
 		},
-		{
-			.procname = "devices",
-			.mode = 0555,
-			.child = NULL, /* child will point to .device_dir */
-		},
 #ifdef CONFIG_PARPORT_1284
 		{
 			.procname	= "autoprobe",
@@ -378,6 +374,14 @@ int parport_proc_register(struct parport *port)
 		{ .procname = port->name },
 		{  },
 	};
+	struct ctl_path parport_port_devices_path[] = {
+		{ .procname = "dev" },
+		{ .procname = "parport" },
+		{ .procname = port->name },
+		{ .procname = "devices" },
+		{  },
+	};
+
 	struct parport_sysctl_table *t;
 	int i;
 
@@ -392,20 +396,29 @@ int parport_proc_register(struct parport *port)
 		t->vars[i].extra1 = port;
 
 	t->vars[0].data = &port->spintime;
-	
-	for (i = 0; i < 5; i++)
-		t->vars[6 + i].extra2 = &port->probe_info[i];
 
-	t->vars[5].child = t->device_dir;
-	/* vars[5].procname is the 'devices' dir entry */
+#ifdef CONFIG_PARPORT_1284
+	for (i = 0; i < 5; i++)
+		t->vars[5 + i].extra2 = &port->probe_info[i];
+#endif /* CONFIG_PARPORT_1284 */
 
 	t->sysctl_header = register_sysctl_paths(parport_port_path, t->vars);
-	if (t->sysctl_header == NULL) {
-		kfree(t);
-		t = NULL;
-	}
+	if (t->sysctl_header == NULL)
+		goto fail_register_port;
+
+	t->devices_sysctl_header = register_sysctl_paths(parport_port_devices_path,
+							 t->device_dir);
+	if (t->devices_sysctl_header == NULL)
+		goto fail_register_devices;
 	port->sysctl_table = t;
 	return 0;
+
+fail_register_devices:
+	unregister_sysctl_table(t->sysctl_header);
+fail_register_port:
+	kfree(t);
+
+	return -ENOMEM;
 }
 
 int parport_proc_unregister(struct parport *port)
@@ -413,6 +426,7 @@ int parport_proc_unregister(struct parport *port)
 	if (port->sysctl_table) {
 		struct parport_sysctl_table *t = port->sysctl_table;
 		port->sysctl_table = NULL;
+		unregister_sysctl_table(t->devices_sysctl_header);
 		unregister_sysctl_table(t->sysctl_header);
 		kfree(t);
 	}
-- 
1.7.5.134.g1c08b
