From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V6 6/8] Drivers: hv: vmbus: add a per-channel rescind callback
Date: Tue, 26 Jan 2016 01:45:01 -0800
Message-ID: <1453801501-3431-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pebolle@tiscali.nl, dan.carpenter@oracle.com, stefanha@redhat.com
To: gregkh@linuxfoundation.org, davem@davemloft.net,
 stephen@networkplumber.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, driverdev-devel@linuxdriverproject.org,
 olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
 vkuznets@redhat.com
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

This will be used by the coming hv_sock driver.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 drivers/hv/channel_mgmt.c | 11 +++++++++++
 include/linux/hyperv.h    |  9 +++++++++
 2 files changed, 20 insertions(+)

diff --git a/drivers/hv/channel_mgmt.c b/drivers/hv/channel_mgmt.c
index 4611b50..b782944 100644
--- a/drivers/hv/channel_mgmt.c
+++ b/drivers/hv/channel_mgmt.c
@@ -608,6 +608,10 @@ static void vmbus_onoffer_rescind(struct vmbus_channel_message_header *hdr)
 	spin_unlock_irqrestore(&channel->lock, flags);
 
 	if (channel->device_obj) {
+		if (channel->chn_rescind_callback) {
+			channel->chn_rescind_callback(channel);
+			return;
+		}
 		/*
 		 * We will have to unregister this device from the
 		 * driver core.
@@ -977,3 +981,10 @@ bool vmbus_are_subchannels_present(struct vmbus_channel *primary)
 	return ret;
 }
 EXPORT_SYMBOL_GPL(vmbus_are_subchannels_present);
+
+void vmbus_set_chn_rescind_callback(struct vmbus_channel *channel,
+		void (*chn_rescind_cb)(struct vmbus_channel *))
+{
+	channel->chn_rescind_callback = chn_rescind_cb;
+}
+EXPORT_SYMBOL_GPL(vmbus_set_chn_rescind_callback);
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index 5587711..ff89d4c 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -740,6 +740,12 @@ struct vmbus_channel {
 	void (*sc_creation_callback)(struct vmbus_channel *new_sc);
 
 	/*
+	 * Channel rescind callback. Some channels (the hvsock ones), need to
+	 * register a callback which is invoked in vmbus_onoffer_rescind().
+	 */
+	void (*chn_rescind_callback)(struct vmbus_channel *channel);
+
+	/*
 	 * The spinlock to protect the structure. It is being used to protect
 	 * test-and-set access to various attributes of the structure as well
 	 * as all sc_list operations.
@@ -825,6 +831,9 @@ int vmbus_request_offers(void);
 void vmbus_set_sc_create_callback(struct vmbus_channel *primary_channel,
 			void (*sc_cr_cb)(struct vmbus_channel *new_sc));
 
+void vmbus_set_chn_rescind_callback(struct vmbus_channel *channel,
+		void (*chn_rescind_cb)(struct vmbus_channel *));
+
 /*
  * Retrieve the (sub) channel on which to send an outgoing request.
  * When a primary channel has multiple sub-channels, we choose a
-- 
2.1.0
