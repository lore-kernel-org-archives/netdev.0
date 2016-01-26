From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V6 7/8] Drivers: hv: vmbus: add an API vmbus_hvsock_device_unregister()
Date: Tue, 26 Jan 2016 01:45:08 -0800
Message-ID: <1453801508-3468-1-git-send-email-decui@microsoft.com>
Cc: pebolle@tiscali.nl, stefanha@redhat.com, dan.carpenter@oracle.com
To: gregkh@linuxfoundation.org, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
	vkuznets@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hvsock driver needs this API to release all the resources related
to the channel.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 drivers/hv/channel_mgmt.c | 33 ++++++++++++++++++++++++++++-----
 drivers/hv/connection.c   |  4 ++--
 include/linux/hyperv.h    |  2 ++
 3 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/drivers/hv/channel_mgmt.c b/drivers/hv/channel_mgmt.c
index b782944..68607d8 100644
--- a/drivers/hv/channel_mgmt.c
+++ b/drivers/hv/channel_mgmt.c
@@ -195,6 +195,7 @@ void hv_process_channel_removal(struct vmbus_channel *channel, u32 relid)
 	vmbus_release_relid(relid);
 
 	BUG_ON(!channel->rescind);
+	BUG_ON(!mutex_is_locked(&vmbus_connection.channel_mutex));
 
 	if (channel->target_cpu != get_cpu()) {
 		put_cpu();
@@ -206,9 +207,7 @@ void hv_process_channel_removal(struct vmbus_channel *channel, u32 relid)
 	}
 
 	if (channel->primary_channel == NULL) {
-		mutex_lock(&vmbus_connection.channel_mutex);
 		list_del(&channel->listentry);
-		mutex_unlock(&vmbus_connection.channel_mutex);
 
 		primary_channel = channel;
 	} else {
@@ -251,6 +250,7 @@ static void vmbus_process_offer(struct vmbus_channel *newchannel)
 	struct vmbus_channel *channel;
 	bool fnew = true;
 	unsigned long flags;
+	int ret;
 
 	/* Make sure this is a new offer */
 	mutex_lock(&vmbus_connection.channel_mutex);
@@ -330,7 +330,11 @@ static void vmbus_process_offer(struct vmbus_channel *newchannel)
 	 * binding which eventually invokes the device driver's AddDevice()
 	 * method.
 	 */
-	if (vmbus_device_register(newchannel->device_obj) != 0) {
+	mutex_lock(&vmbus_connection.channel_mutex);
+	ret = vmbus_device_register(newchannel->device_obj);
+	mutex_unlock(&vmbus_connection.channel_mutex);
+
+	if (ret != 0) {
 		pr_err("unable to add child device object (relid %d)\n",
 			newchannel->offermsg.child_relid);
 		kfree(newchannel->device_obj);
@@ -592,6 +596,8 @@ static void vmbus_onoffer_rescind(struct vmbus_channel_message_header *hdr)
 	struct device *dev;
 
 	rescind = (struct vmbus_channel_rescind_offer *)hdr;
+
+	mutex_lock(&vmbus_connection.channel_mutex);
 	channel = relid2channel(rescind->child_relid);
 
 	if (channel == NULL) {
@@ -600,7 +606,7 @@ static void vmbus_onoffer_rescind(struct vmbus_channel_message_header *hdr)
 		 * vmbus_process_offer(), we have already invoked
 		 * vmbus_release_relid() on error.
 		 */
-		return;
+		goto out;
 	}
 
 	spin_lock_irqsave(&channel->lock, flags);
@@ -610,7 +616,7 @@ static void vmbus_onoffer_rescind(struct vmbus_channel_message_header *hdr)
 	if (channel->device_obj) {
 		if (channel->chn_rescind_callback) {
 			channel->chn_rescind_callback(channel);
-			return;
+			goto out;
 		}
 		/*
 		 * We will have to unregister this device from the
@@ -625,7 +631,24 @@ static void vmbus_onoffer_rescind(struct vmbus_channel_message_header *hdr)
 		hv_process_channel_removal(channel,
 			channel->offermsg.child_relid);
 	}
+
+out:
+	mutex_unlock(&vmbus_connection.channel_mutex);
+}
+
+
+void vmbus_hvsock_device_unregister(struct vmbus_channel *channel)
+{
+	mutex_lock(&vmbus_connection.channel_mutex);
+
+	BUG_ON(!is_hvsock_channel(channel));
+
+	channel->rescind = true;
+	vmbus_device_unregister(channel->device_obj);
+
+	mutex_unlock(&vmbus_connection.channel_mutex);
 }
+EXPORT_SYMBOL_GPL(vmbus_hvsock_device_unregister);
 
 /*
  * vmbus_onoffers_delivered -
diff --git a/drivers/hv/connection.c b/drivers/hv/connection.c
index 3dc5a9c..deb48e6 100644
--- a/drivers/hv/connection.c
+++ b/drivers/hv/connection.c
@@ -288,7 +288,8 @@ struct vmbus_channel *relid2channel(u32 relid)
 	struct list_head *cur, *tmp;
 	struct vmbus_channel *cur_sc;
 
-	mutex_lock(&vmbus_connection.channel_mutex);
+	BUG_ON(!mutex_is_locked(&vmbus_connection.channel_mutex));
+
 	list_for_each_entry(channel, &vmbus_connection.chn_list, listentry) {
 		if (channel->offermsg.child_relid == relid) {
 			found_channel = channel;
@@ -307,7 +308,6 @@ struct vmbus_channel *relid2channel(u32 relid)
 			}
 		}
 	}
-	mutex_unlock(&vmbus_connection.channel_mutex);
 
 	return found_channel;
 }
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index ff89d4c..acbbcb1 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -1041,6 +1041,8 @@ int __must_check __vmbus_driver_register(struct hv_driver *hv_driver,
 					 const char *mod_name);
 void vmbus_driver_unregister(struct hv_driver *hv_driver);
 
+void vmbus_hvsock_device_unregister(struct vmbus_channel *channel);
+
 int vmbus_allocate_mmio(struct resource **new, struct hv_device *device_obj,
 			resource_size_t min, resource_size_t max,
 			resource_size_t size, resource_size_t align,
-- 
2.1.0
