From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v3 for-next 01/13] IB/core: Use SRCU when reading client_list or device_list
Date: Sun, 10 May 2015 13:26:32 +0300
Message-ID: <1431253604-9214-2-git-send-email-haggaie@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:49304 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752199AbbEJK1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 06:27:13 -0400
In-Reply-To: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the RDMA subsystem's device list and client list are protected by
a single mutex. This prevents adding user-facing APIs that iterate these
lists, since using them may cause a deadlock. The patch attempts to solve
this problem by adding an SRCU to protect the lists. Readers now don't need
the mutex, and are safe just by using srcu_read_lock/unlock.

The ib_register_device, ib_register_client, and ib_unregister_client
functions are modified to only lock the device_mutex during their
respective list modification, and use the SRCU for iteration on the other
list. In ib_unregister_device, the client list iteration remains in the
mutex critical section as it is done in reverse order.

This patch attempts to solve a similar need [1] that was seen in the RoCE
v2 patch series.

[1] http://www.spinics.net/lists/linux-rdma/msg24733.html

Cc: Matan Barak <matanb@mellanox.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 drivers/infiniband/core/device.c | 75 ++++++++++++++++++++++++++++++----------
 1 file changed, 56 insertions(+), 19 deletions(-)

diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index b360350a0b20..7d90b2ca2eba 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -58,12 +58,11 @@ EXPORT_SYMBOL_GPL(ib_wq);
 static LIST_HEAD(device_list);
 static LIST_HEAD(client_list);
 
+/* device_srcu protects access to both device_list and client_list. */
+static struct srcu_struct device_srcu;
+
 /*
- * device_mutex protects access to both device_list and client_list.
- * There's no real point to using multiple locks or something fancier
- * like an rwsem: we always access both lists, and we're always
- * modifying one list or the other list.  In any case this is not a
- * hot path so there's no point in trying to optimize.
+ * device_mutex protects writer access to both device_list and client_list.
  */
 static DEFINE_MUTEX(device_mutex);
 
@@ -276,6 +275,7 @@ int ib_register_device(struct ib_device *device,
 					    u8, struct kobject *))
 {
 	int ret;
+	int id;
 
 	mutex_lock(&device_mutex);
 
@@ -315,13 +315,19 @@ int ib_register_device(struct ib_device *device,
 
 	device->reg_state = IB_DEV_REGISTERED;
 
+	mutex_unlock(&device_mutex);
+
+	id = srcu_read_lock(&device_srcu);
 	{
 		struct ib_client *client;
 
-		list_for_each_entry(client, &client_list, list)
+		list_for_each_entry_rcu(client, &client_list, list)
 			if (client->add && !add_client_context(device, client))
 				client->add(device);
 	}
+	srcu_read_unlock(&device_srcu, id);
+
+	return 0;
 
  out:
 	mutex_unlock(&device_mutex);
@@ -338,6 +344,7 @@ EXPORT_SYMBOL(ib_register_device);
 void ib_unregister_device(struct ib_device *device)
 {
 	struct ib_client *client;
+	LIST_HEAD(contexts);
 	struct ib_client_data *context, *tmp;
 	unsigned long flags;
 
@@ -347,21 +354,26 @@ void ib_unregister_device(struct ib_device *device)
 		if (client->remove)
 			client->remove(device);
 
-	list_del(&device->core_list);
+	list_del_rcu(&device->core_list);
+
+	mutex_unlock(&device_mutex);
+
+	synchronize_srcu(&device_srcu);
 
 	kfree(device->gid_tbl_len);
 	kfree(device->pkey_tbl_len);
 
-	mutex_unlock(&device_mutex);
-
 	ib_device_unregister_sysfs(device);
 
 	spin_lock_irqsave(&device->client_data_lock, flags);
-	list_for_each_entry_safe(context, tmp, &device->client_data_list, list)
-		kfree(context);
+	list_cut_position(&contexts, &device->client_data_list,
+			  device->client_data_list.prev);
 	spin_unlock_irqrestore(&device->client_data_lock, flags);
 
 	device->reg_state = IB_DEV_UNREGISTERED;
+
+	list_for_each_entry_safe(context, tmp, &contexts, list)
+		kfree(context);
 }
 EXPORT_SYMBOL(ib_unregister_device);
 
@@ -381,15 +393,19 @@ EXPORT_SYMBOL(ib_unregister_device);
 int ib_register_client(struct ib_client *client)
 {
 	struct ib_device *device;
+	int id;
 
 	mutex_lock(&device_mutex);
+	list_add_tail_rcu(&client->list, &client_list);
+	mutex_unlock(&device_mutex);
 
-	list_add_tail(&client->list, &client_list);
-	list_for_each_entry(device, &device_list, core_list)
+	id = srcu_read_lock(&device_srcu);
+
+	list_for_each_entry_rcu(device, &device_list, core_list)
 		if (client->add && !add_client_context(device, client))
 			client->add(device);
 
-	mutex_unlock(&device_mutex);
+	srcu_read_unlock(&device_srcu, id);
 
 	return 0;
 }
@@ -407,11 +423,13 @@ void ib_unregister_client(struct ib_client *client)
 {
 	struct ib_client_data *context, *tmp;
 	struct ib_device *device;
+	LIST_HEAD(contexts);
 	unsigned long flags;
+	int id;
 
-	mutex_lock(&device_mutex);
+	id = srcu_read_lock(&device_srcu);
 
-	list_for_each_entry(device, &device_list, core_list) {
+	list_for_each_entry_rcu(device, &device_list, core_list) {
 		if (client->remove)
 			client->remove(device);
 
@@ -419,13 +437,21 @@ void ib_unregister_client(struct ib_client *client)
 		list_for_each_entry_safe(context, tmp, &device->client_data_list, list)
 			if (context->client == client) {
 				list_del(&context->list);
-				kfree(context);
+				list_add(&context->list, &contexts);
 			}
 		spin_unlock_irqrestore(&device->client_data_lock, flags);
 	}
-	list_del(&client->list);
 
+	srcu_read_unlock(&device_srcu, id);
+
+	mutex_lock(&device_mutex);
+	list_del_rcu(&client->list);
 	mutex_unlock(&device_mutex);
+
+	synchronize_srcu(&device_srcu);
+
+	list_for_each_entry_safe(context, tmp, &contexts, list)
+		kfree(context);
 }
 EXPORT_SYMBOL(ib_unregister_client);
 
@@ -738,9 +764,15 @@ static int __init ib_core_init(void)
 {
 	int ret;
 
+	ret = init_srcu_struct(&device_srcu);
+	if (ret) {
+		pr_warn("Couldn't initialize SRCU\n");
+		return ret;
+	}
+
 	ib_wq = alloc_workqueue("infiniband", 0, 0);
 	if (!ib_wq)
-		return -ENOMEM;
+		goto err_srcu;
 
 	ret = ib_sysfs_setup();
 	if (ret) {
@@ -770,6 +802,9 @@ err_sysfs:
 
 err:
 	destroy_workqueue(ib_wq);
+err_srcu:
+	cleanup_srcu_struct(&device_srcu);
+
 	return ret;
 }
 
@@ -780,6 +815,8 @@ static void __exit ib_core_cleanup(void)
 	ib_sysfs_cleanup();
 	/* Make sure that any pending umem accounting work is done. */
 	destroy_workqueue(ib_wq);
+	srcu_barrier(&device_srcu);
+	cleanup_srcu_struct(&device_srcu);
 }
 
 module_init(ib_core_init);
-- 
1.7.11.2
