From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V5 7/9] Drivers: hv: vmbus: add a mechanism to pass hvsock
 events to the hvsock driver
Date: Thu, 24 Dec 2015 06:14:51 -0800
Message-ID: <1450966491-13276-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pebolle@tiscali.nl, dan.carpenter@oracle.com, stefanha@redhat.com
To: gregkh@linuxfoundation.org, davem@davemloft.net,
 stephen@networkplumber.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, driverdev-devel@linuxdriverproject.org,
 olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

For now only 1 event is defined: HVSOCK_RESCIND_CHANNEL.
We'll have more events in the future.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 drivers/hv/channel_mgmt.c | 18 ++++++++++++++++++
 include/linux/hyperv.h    | 17 +++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/drivers/hv/channel_mgmt.c b/drivers/hv/channel_mgmt.c
index 4611b50..87fc7d2 100644
--- a/drivers/hv/channel_mgmt.c
+++ b/drivers/hv/channel_mgmt.c
@@ -608,6 +608,16 @@ static void vmbus_onoffer_rescind(struct vmbus_channel_message_header *hdr)
 	spin_unlock_irqrestore(&channel->lock, flags);
 
 	if (channel->device_obj) {
+		if (is_hvsock_channel(channel) &&
+		    channel->hvsock_event_callback) {
+			channel->hvsock_event_callback(channel,
+						       HVSOCK_RESCIND_CHANNEL);
+			/*
+			 * We can't invoke vmbus_device_unregister()
+			 * until the socket fd is closed.
+			 */
+			return;
+		}
 		/*
 		 * We will have to unregister this device from the
 		 * driver core.
@@ -977,3 +987,11 @@ bool vmbus_are_subchannels_present(struct vmbus_channel *primary)
 	return ret;
 }
 EXPORT_SYMBOL_GPL(vmbus_are_subchannels_present);
+
+void vmbus_set_hvsock_event_callback(struct vmbus_channel *channel,
+		void (*hvsock_event_callback)(struct vmbus_channel *,
+					      enum hvsock_event))
+{
+	channel->hvsock_event_callback = hvsock_event_callback;
+}
+EXPORT_SYMBOL_GPL(vmbus_set_hvsock_event_callback);
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index b4cc44c..7e507bb 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -645,6 +645,12 @@ enum hv_signal_policy {
 	HV_SIGNAL_POLICY_EXPLICIT,
 };
 
+/* hvsock related definitions */
+enum hvsock_event {
+	/* The host application is close()-ing the connection */
+	HVSOCK_RESCIND_CHANNEL,
+};
+
 struct vmbus_channel {
 	/* Unique channel id */
 	int id;
@@ -740,6 +746,13 @@ struct vmbus_channel {
 	void (*sc_creation_callback)(struct vmbus_channel *new_sc);
 
 	/*
+	 * hvsock event callback.
+	 * For now only 1 event is defined: HVSOCK_RESCIND_CHANNEL.
+	 */
+	void (*hvsock_event_callback)(struct vmbus_channel *channel,
+				      enum hvsock_event event);
+
+	/*
 	 * The spinlock to protect the structure. It is being used to protect
 	 * test-and-set access to various attributes of the structure as well
 	 * as all sc_list operations.
@@ -825,6 +838,10 @@ int vmbus_request_offers(void);
 void vmbus_set_sc_create_callback(struct vmbus_channel *primary_channel,
 			void (*sc_cr_cb)(struct vmbus_channel *new_sc));
 
+void vmbus_set_hvsock_event_callback(struct vmbus_channel *channel,
+		void (*hvsock_event_callback)(struct vmbus_channel *,
+					      enum hvsock_event));
+
 /*
  * Retrieve the (sub) channel on which to send an outgoing request.
  * When a primary channel has multiple sub-channels, we choose a
-- 
2.1.4
