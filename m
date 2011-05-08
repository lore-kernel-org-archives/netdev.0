From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 003/115] sysctl: remove .child from dev/parport/PORT/devices/DEVICE
Date: Mon,  9 May 2011 00:38:15 +0200
Message-ID: <1304894407-32201-4-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MAINTAINERS says parport is "Orphan" and I don't have a parallel
port => I cannot test that this patch works.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 drivers/parport/procfs.c |   56 ++++++++++------------------------------------
 1 files changed, 12 insertions(+), 44 deletions(-)

diff --git a/drivers/parport/procfs.c b/drivers/parport/procfs.c
index edeb012..350233e 100644
--- a/drivers/parport/procfs.c
+++ b/drivers/parport/procfs.c
@@ -370,17 +370,11 @@ struct parport_device_sysctl_table
 {
 	struct ctl_table_header *sysctl_header;
 	ctl_table vars[2];
-	ctl_table device_dir[2];
-	ctl_table devices_root_dir[2];
-	ctl_table port_dir[2];
-	ctl_table parport_dir[2];
-	ctl_table dev_dir[2];
 };
 
 static const struct parport_device_sysctl_table
 parport_device_sysctl_template = {
-	.sysctl_header = NULL,
-	{
+	.vars = {
 		{
 			.procname 	= "timeslice",
 			.data		= NULL,
@@ -391,32 +385,6 @@ parport_device_sysctl_template = {
 			.extra2		= (void*) &parport_max_timeslice_value
 		},
 	},
-	{
-		{
-			.procname	= NULL,
-			.data		= NULL,
-			.maxlen		= 0,
-			.mode		= 0555,
-			.child		= NULL
-		},
-		{}
-	},
-	{
-		PARPORT_DEVICES_ROOT_DIR,
-		{}
-	},
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
 
 
@@ -473,24 +441,24 @@ int parport_device_proc_register(struct pardevice *device)
 {
 	struct parport_device_sysctl_table *t;
 	struct parport * port = device->port;
-	
+	struct ctl_path parport_devices_port_path[] = {
+		{ .procname = "dev" },
+		{ .procname = "parport" },
+		{ .procname = port->name },
+		{ .procname = "devices" },
+		{ .procname = device->name },
+		{  },
+	};
+
 	t = kmalloc(sizeof(*t), GFP_KERNEL);
 	if (t == NULL)
 		return -ENOMEM;
 	memcpy(t, &parport_device_sysctl_template, sizeof(*t));
 
-	t->port_dir[0].procname = port->name;
-	t->device_dir[0].procname = device->name;
-
-	t->dev_dir[0].child = t->parport_dir;
-	t->parport_dir[0].child = t->port_dir;
-	t->port_dir[0].child = t->devices_root_dir;
-	t->devices_root_dir[0].child = t->device_dir;
-	t->device_dir[0].child = t->vars;
-
 	t->vars[0].data = &device->timeslice;
 
-	t->sysctl_header = register_sysctl_table(t->dev_dir);
+	t->sysctl_header = register_sysctl_paths(parport_devices_port_path,
+						 t->vars);
 	if (t->sysctl_header == NULL) {
 		kfree(t);
 		t = NULL;
-- 
1.7.5.134.g1c08b
