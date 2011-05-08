From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 040/115] sysctl: remove .child from appldata/ (s390)
Date: Mon,  9 May 2011 00:38:52 +0200
Message-ID: <1304894407-32201-41-git-send-email-lucian.grijincu@gmail.com>
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
 arch/s390/appldata/appldata_base.c |   42 ++++++++++++++++++------------------
 1 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/arch/s390/appldata/appldata_base.c b/arch/s390/appldata/appldata_base.c
index 5c91995..0f336a8 100644
--- a/arch/s390/appldata/appldata_base.c
+++ b/arch/s390/appldata/appldata_base.c
@@ -49,7 +49,6 @@ static struct platform_device *appldata_pdev;
 /*
  * /proc entries (sysctl)
  */
-static const char appldata_proc_name[APPLDATA_PROC_NAME_LENGTH] = "appldata";
 static int appldata_timer_handler(ctl_table *ctl, int write,
 				  void __user *buffer, size_t *lenp, loff_t *ppos);
 static int appldata_interval_handler(ctl_table *ctl, int write,
@@ -71,14 +70,9 @@ static struct ctl_table appldata_table[] = {
 	{ },
 };
 
-static struct ctl_table appldata_dir_table[] = {
-	{
-		.procname	= appldata_proc_name,
-		.maxlen		= 0,
-		.mode		= S_IRUGO | S_IXUGO,
-		.child		= appldata_table,
-	},
-	{ },
+static const struct ctl_path appldata_path[] = {
+	{ .procname = "appldata" },
+	{ }
 };
 
 /*
@@ -424,6 +418,18 @@ out:
 
 
 /************************* module-ops management *****************************/
+
+static const struct ctl_table appldata_ops_template[2] = {
+	{
+		.procname = NULL, /* ops->name */
+		.data     = NULL, /* ops */
+		.maxlen   = 0,
+		.mode     = S_IRUGO | S_IWUSR,
+		.proc_handler = appldata_generic_handler,
+	},
+	{ }
+};
+
 /*
  * appldata_register_ops()
  *
@@ -434,7 +440,8 @@ int appldata_register_ops(struct appldata_ops *ops)
 	if (ops->size > APPLDATA_MAX_REC_SIZE)
 		return -EINVAL;
 
-	ops->ctl_table = kzalloc(4 * sizeof(struct ctl_table), GFP_KERNEL);
+	ops->ctl_table = kmemdup(&appldata_ops_template,
+				 sizeof(appldata_ops_template), GFP_KERNEL);
 	if (!ops->ctl_table)
 		return -ENOMEM;
 
@@ -442,17 +449,10 @@ int appldata_register_ops(struct appldata_ops *ops)
 	list_add(&ops->list, &appldata_ops_list);
 	mutex_unlock(&appldata_ops_mutex);
 
-	ops->ctl_table[0].procname = appldata_proc_name;
-	ops->ctl_table[0].maxlen   = 0;
-	ops->ctl_table[0].mode     = S_IRUGO | S_IXUGO;
-	ops->ctl_table[0].child    = &ops->ctl_table[2];
-
-	ops->ctl_table[2].procname = ops->name;
-	ops->ctl_table[2].mode     = S_IRUGO | S_IWUSR;
-	ops->ctl_table[2].proc_handler = appldata_generic_handler;
-	ops->ctl_table[2].data = ops;
+	ops->ctl_table[0].procname = ops->name;
+	ops->ctl_table[0].data = ops;
 
-	ops->sysctl_header = register_sysctl_table(ops->ctl_table);
+	ops->sysctl_header = register_sysctl_paths(appldata_path, ops->ctl_table);
 	if (!ops->sysctl_header)
 		goto out;
 	return 0;
@@ -649,7 +649,7 @@ static int __init appldata_init(void)
 	/* Register cpu hotplug notifier */
 	register_hotcpu_notifier(&appldata_nb);
 
-	appldata_sysctl_header = register_sysctl_table(appldata_dir_table);
+	appldata_sysctl_header = register_sysctl_paths(appldata_path, appldata_table);
 	return 0;
 
 out_device:
-- 
1.7.5.134.g1c08b
