From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70] sysfs cleanup and bugfix
Date: Thu, 29 May 2003 10:30:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529103011.3f038db7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A couple of bugs in netdev_unregister_sysfs; still working on the harder
refcount issues.
	- if driver sets get_stats after register then unregister 
	  will attempt to delete kobject that has not be initialized.
	- unregister should call kobject_unregister not kobject_del.

cleanup's:
	- use strlcpy instead of snprintf
	- don't need to memset the stats kobject

diff -Nru a/net/core/net-sysfs.c b/net/core/net-sysfs.c
--- a/net/core/net-sysfs.c	Thu May 29 10:25:04 2003
+++ b/net/core/net-sysfs.c	Thu May 29 10:25:04 2003
@@ -294,7 +294,7 @@
 	class_dev->class = &net_class;
 	class_dev->class_data = net;
 
-	snprintf(class_dev->class_id, BUS_ID_SIZE, net->name);
+	strlcpy(class_dev->class_id, net->name, BUS_ID_SIZE);
 	if ((ret = class_device_register(class_dev)))
 		goto out;
 
@@ -303,17 +303,18 @@
 		    goto out_unreg;
 	}
 
+	
+	net->stats_kobj.parent = NULL;
 	if (net->get_stats) {
 		struct kobject *k = &net->stats_kobj;
 
-		memset(k, 0, sizeof(*k));
 		k->parent = kobject_get(&class_dev->kobj);
 		if (!k->parent) {
 			ret = -EBUSY;
 			goto out_unreg;
 		}
 
-		snprintf(k->name, KOBJ_NAME_LEN, "%s", "statistics");
+		strlcpy(k->name, "statistics", KOBJ_NAME_LEN);
 		k->ktype = &netstat_ktype;
 
 		if((ret = kobject_register(k))) 
@@ -331,8 +332,9 @@
 
 void netdev_unregister_sysfs(struct net_device *net)
 {
-	if (net->get_stats)
-		kobject_del(&net->stats_kobj);
+	if (net->stats_kobj.parent) 
+		kobject_unregister(&net->stats_kobj);
+
 	class_device_unregister(&net->class_dev);
 }
 
