From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH retry] bluetooth : add conn add/del workqueues
	to avoid	connection fail
Date: Wed, 30 Jan 2008 10:23:54 +0800
Message-ID: <20080130022354.GA3132@darkstar.te-china.tietoenator.com>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bluez-devel@lists.sf.net, linux-kernel@vger.kernel.org
To: marcel@holtmann.org
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


The bluetooth hci_conn sysfs add/del executed in the default workqueue.
If the del_conn is executed after the new add_conn with same target,
add_conn will failed with warning of "same kobject name".

Here add btaddconn & btdelconn workqueues,
flush the btdelconn workqueue in the add_conn function to avoid the issue.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 

---
diff -upr a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
--- a/net/bluetooth/hci_sysfs.c	2008-01-30 10:14:27.000000000 +0800
+++ b/net/bluetooth/hci_sysfs.c	2008-01-30 10:14:14.000000000 +0800
@@ -12,6 +12,8 @@
 #undef  BT_DBG
 #define BT_DBG(D...)
 #endif
+static struct workqueue_struct *btaddconn;
+static struct workqueue_struct *btdelconn;
 
 static inline char *typetostr(int type)
 {
@@ -279,6 +281,7 @@ static void add_conn(struct work_struct 
 	struct hci_conn *conn = container_of(work, struct hci_conn, work);
 	int i;
 
+	flush_workqueue(btdelconn);
 	if (device_add(&conn->dev) < 0) {
 		BT_ERR("Failed to register connection device");
 		return;
@@ -313,6 +316,7 @@ void hci_conn_add_sysfs(struct hci_conn 
 
 	INIT_WORK(&conn->work, add_conn);
 
+	queue_work(btaddconn, &conn->work);
 	schedule_work(&conn->work);
 }
 
@@ -349,6 +353,7 @@ void hci_conn_del_sysfs(struct hci_conn 
 
 	INIT_WORK(&conn->work, del_conn);
 
+	queue_work(btdelconn, &conn->work);
 	schedule_work(&conn->work);
 }
 
@@ -398,31 +403,52 @@ int __init bt_sysfs_init(void)
 {
 	int err;
 
+	btaddconn = create_singlethread_workqueue("btaddconn");
+	if (!btaddconn) {
+		err = -ENOMEM;
+		goto out;
+	}
+	btdelconn = create_singlethread_workqueue("btdelconn");
+	if (!btdelconn) {
+		err = -ENOMEM;
+		goto out_del;
+	}
+
 	bt_platform = platform_device_register_simple("bluetooth", -1, NULL, 0);
-	if (IS_ERR(bt_platform))
-		return PTR_ERR(bt_platform);
+	if (IS_ERR(bt_platform)) {
+		err = PTR_ERR(bt_platform);
+		goto out_platform;
+	}
 
 	err = bus_register(&bt_bus);
-	if (err < 0) {
-		platform_device_unregister(bt_platform);
-		return err;
-	}
+	if (err < 0)
+		goto out_bus;
 
 	bt_class = class_create(THIS_MODULE, "bluetooth");
 	if (IS_ERR(bt_class)) {
-		bus_unregister(&bt_bus);
-		platform_device_unregister(bt_platform);
-		return PTR_ERR(bt_class);
+		err = PTR_ERR(bt_class);
+		goto out_class;
 	}
 
 	return 0;
+
+out_class:
+	bus_unregister(&bt_bus);
+out_bus:
+	platform_device_unregister(bt_platform);
+out_platform:
+	destroy_workqueue(btdelconn);
+out_del:
+	destroy_workqueue(btaddconn);
+out:
+	return err;
 }
 
 void bt_sysfs_cleanup(void)
 {
+	destroy_workqueue(btaddconn);
+	destroy_workqueue(btdelconn);
 	class_destroy(bt_class);
-
 	bus_unregister(&bt_bus);
-
 	platform_device_unregister(bt_platform);
 }

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
