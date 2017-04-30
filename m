From: kys@exchange.microsoft.com
Subject: [PATCH 5/6] Drivers: hv: vmbus: Fix rescind handling
Date: Sun, 30 Apr 2017 16:21:18 -0700
Message-ID: <1493594479-25329-5-git-send-email-kys@exchange.microsoft.com>
References: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
Reply-To: kys@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, leann.ogasawara@canonical.comi,
 marcelo.cerri@canonical.com, sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
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

From: K. Y. Srinivasan <kys@microsoft.com>

Fix the rescind handling. This patch addresses the following rescind
scenario that is currently not handled correctly:

If a rescind were to be received while the offer is still being
peocessed, we will be blocked indefinitely since the rescind message
is handled on the same work element as the offer message. Fix this
issue.

I would like to thank Dexuan Cui <decui@microsoft.com> and
Long Li <longli@microsoft.com> for working with me on this patch.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/hv/channel.c      |    8 ++++-
 drivers/hv/channel_mgmt.c |   69 ++++++++++++++++++++++++++++++++++----------
 drivers/hv/connection.c   |    7 +++-
 drivers/hv/hyperv_vmbus.h |    7 ++++
 drivers/hv/vmbus_drv.c    |   29 ++++++++++++++++++-
 5 files changed, 99 insertions(+), 21 deletions(-)

diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
index 736ac76..e9bf0bb 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -630,9 +630,13 @@ void vmbus_close(struct vmbus_channel *channel)
 	 */
 	list_for_each_safe(cur, tmp, &channel->sc_list) {
 		cur_channel = list_entry(cur, struct vmbus_channel, sc_list);
-		if (cur_channel->state != CHANNEL_OPENED_STATE)
-			continue;
 		vmbus_close_internal(cur_channel);
+		if (cur_channel->rescind) {
+			mutex_lock(&vmbus_connection.channel_mutex);
+			hv_process_channel_removal(cur_channel,
+					   cur_channel->offermsg.child_relid);
+			mutex_unlock(&vmbus_connection.channel_mutex);
+		}
 	}
 	/*
 	 * Now close the primary.
diff --git a/drivers/hv/channel_mgmt.c b/drivers/hv/channel_mgmt.c
index eec616a..06529b3 100644
--- a/drivers/hv/channel_mgmt.c
+++ b/drivers/hv/channel_mgmt.c
@@ -428,7 +428,6 @@ void vmbus_free_channels(void)
 {
 	struct vmbus_channel *channel, *tmp;
 
-	mutex_lock(&vmbus_connection.channel_mutex);
 	list_for_each_entry_safe(channel, tmp, &vmbus_connection.chn_list,
 		listentry) {
 		/* hv_process_channel_removal() needs this */
@@ -436,7 +435,6 @@ void vmbus_free_channels(void)
 
 		vmbus_device_unregister(channel->device_obj);
 	}
-	mutex_unlock(&vmbus_connection.channel_mutex);
 }
 
 /*
@@ -483,8 +481,10 @@ static void vmbus_process_offer(struct vmbus_channel *newchannel)
 			list_add_tail(&newchannel->sc_list, &channel->sc_list);
 			channel->num_sc++;
 			spin_unlock_irqrestore(&channel->lock, flags);
-		} else
+		} else {
+			atomic_dec(&vmbus_connection.offer_in_progress);
 			goto err_free_chan;
+		}
 	}
 
 	dev_type = hv_get_dev_type(newchannel);
@@ -511,6 +511,7 @@ static void vmbus_process_offer(struct vmbus_channel *newchannel)
 	if (!fnew) {
 		if (channel->sc_creation_callback != NULL)
 			channel->sc_creation_callback(newchannel);
+		atomic_dec(&vmbus_connection.offer_in_progress);
 		return;
 	}
 
@@ -532,9 +533,7 @@ static void vmbus_process_offer(struct vmbus_channel *newchannel)
 	 * binding which eventually invokes the device driver's AddDevice()
 	 * method.
 	 */
-	mutex_lock(&vmbus_connection.channel_mutex);
 	ret = vmbus_device_register(newchannel->device_obj);
-	mutex_unlock(&vmbus_connection.channel_mutex);
 
 	if (ret != 0) {
 		pr_err("unable to add child device object (relid %d)\n",
@@ -542,6 +541,8 @@ static void vmbus_process_offer(struct vmbus_channel *newchannel)
 		kfree(newchannel->device_obj);
 		goto err_deq_chan;
 	}
+
+	atomic_dec(&vmbus_connection.offer_in_progress);
 	return;
 
 err_deq_chan:
@@ -799,6 +800,7 @@ static void vmbus_onoffer(struct vmbus_channel_message_header *hdr)
 	newchannel = alloc_channel();
 	if (!newchannel) {
 		vmbus_release_relid(offer->child_relid);
+		atomic_dec(&vmbus_connection.offer_in_progress);
 		pr_err("Unable to allocate channel object\n");
 		return;
 	}
@@ -845,16 +847,38 @@ static void vmbus_onoffer_rescind(struct vmbus_channel_message_header *hdr)
 
 	rescind = (struct vmbus_channel_rescind_offer *)hdr;
 
+	/*
+	 * The offer msg and the corresponding rescind msg
+	 * from the host are guranteed to be ordered -
+	 * offer comes in first and then the rescind.
+	 * Since we process these events in work elements,
+	 * and with preemption, we may end up processing
+	 * the events out of order. Given that we handle these
+	 * work elements on the same CPU, this is possible only
+	 * in the case of preemption. In any case wait here
+	 * until the offer processing has moved beyond the
+	 * point where the channel is discoverable.
+	 */
+
+	while (atomic_read(&vmbus_connection.offer_in_progress) != 0) {
+		/*
+		 * We wait here until any channel offer is currently
+		 * being processed.
+		 */
+		msleep(1);
+	}
+
 	mutex_lock(&vmbus_connection.channel_mutex);
 	channel = relid2channel(rescind->child_relid);
+	mutex_unlock(&vmbus_connection.channel_mutex);
 
 	if (channel == NULL) {
 		/*
-		 * This is very impossible, because in
-		 * vmbus_process_offer(), we have already invoked
-		 * vmbus_release_relid() on error.
+		 * We failed in processing the offer message;
+		 * we would have cleaned up the relid in that
+		 * failure path.
 		 */
-		goto out;
+		return;
 	}
 
 	spin_lock_irqsave(&channel->lock, flags);
@@ -866,7 +890,7 @@ static void vmbus_onoffer_rescind(struct vmbus_channel_message_header *hdr)
 	if (channel->device_obj) {
 		if (channel->chn_rescind_callback) {
 			channel->chn_rescind_callback(channel);
-			goto out;
+			return;
 		}
 		/*
 		 * We will have to unregister this device from the
@@ -877,13 +901,26 @@ static void vmbus_onoffer_rescind(struct vmbus_channel_message_header *hdr)
 			vmbus_device_unregister(channel->device_obj);
 			put_device(dev);
 		}
-	} else {
-		hv_process_channel_removal(channel,
-			channel->offermsg.child_relid);
 	}
-
-out:
-	mutex_unlock(&vmbus_connection.channel_mutex);
+	if (channel->primary_channel != NULL) {
+		/*
+		 * Sub-channel is being rescinded. Following is the channel
+		 * close sequence when initiated from the driveri (refer to
+		 * vmbus_close() for details):
+		 * 1. Close all sub-channels first
+		 * 2. Then close the primary channel.
+		 */
+		if (channel->state == CHANNEL_OPEN_STATE) {
+			/*
+			 * The channel is currently not open;
+			 * it is safe for us to cleanup the channel.
+			 */
+			mutex_lock(&vmbus_connection.channel_mutex);
+			hv_process_channel_removal(channel,
+						channel->offermsg.child_relid);
+			mutex_unlock(&vmbus_connection.channel_mutex);
+		}
+	}
 }
 
 void vmbus_hvsock_device_unregister(struct vmbus_channel *channel)
diff --git a/drivers/hv/connection.c b/drivers/hv/connection.c
index a938fcf..c2d74ee 100644
--- a/drivers/hv/connection.c
+++ b/drivers/hv/connection.c
@@ -93,10 +93,13 @@ static int vmbus_negotiate_version(struct vmbus_channel_msginfo *msginfo,
 	 * all the CPUs. This is needed for kexec to work correctly where
 	 * the CPU attempting to connect may not be CPU 0.
 	 */
-	if (version >= VERSION_WIN8_1)
+	if (version >= VERSION_WIN8_1) {
 		msg->target_vcpu = hv_context.vp_index[smp_processor_id()];
-	else
+		vmbus_connection.connect_cpu = smp_processor_id();
+	} else {
 		msg->target_vcpu = 0;
+		vmbus_connection.connect_cpu = 0;
+	}
 
 	/*
 	 * Add to list before we send the request since we may
diff --git a/drivers/hv/hyperv_vmbus.h b/drivers/hv/hyperv_vmbus.h
index fa514be..1b6a5e0 100644
--- a/drivers/hv/hyperv_vmbus.h
+++ b/drivers/hv/hyperv_vmbus.h
@@ -303,6 +303,13 @@ enum vmbus_connect_state {
 #define MAX_SIZE_CHANNEL_MESSAGE	HV_MESSAGE_PAYLOAD_BYTE_COUNT
 
 struct vmbus_connection {
+	/*
+	 * CPU on which the initial host contact was made.
+	 */
+	int connect_cpu;
+
+	atomic_t offer_in_progress;
+
 	enum vmbus_connect_state conn_state;
 
 	atomic_t next_gpadl_handle;
diff --git a/drivers/hv/vmbus_drv.c b/drivers/hv/vmbus_drv.c
index 0087b49..59bb3ef 100644
--- a/drivers/hv/vmbus_drv.c
+++ b/drivers/hv/vmbus_drv.c
@@ -798,8 +798,10 @@ static void vmbus_device_release(struct device *device)
 	struct hv_device *hv_dev = device_to_hv_device(device);
 	struct vmbus_channel *channel = hv_dev->channel;
 
+	mutex_lock(&vmbus_connection.channel_mutex);
 	hv_process_channel_removal(channel,
 				   channel->offermsg.child_relid);
+	mutex_unlock(&vmbus_connection.channel_mutex);
 	kfree(hv_dev);
 
 }
@@ -877,7 +879,32 @@ void vmbus_on_msg_dpc(unsigned long data)
 		INIT_WORK(&ctx->work, vmbus_onmessage_work);
 		memcpy(&ctx->msg, msg, sizeof(*msg));
 
-		queue_work(vmbus_connection.work_queue, &ctx->work);
+		/*
+		 * The host can generate a rescind message while we
+		 * may still be handling the original offer. We deal with
+		 * this condition by ensuring the processing is done on the
+		 * same CPU.
+		 */
+		switch (hdr->msgtype) {
+		case CHANNELMSG_RESCIND_CHANNELOFFER:
+			/*
+			 * If we are handling the rescind message;
+			 * schedule the work on the global work queue.
+			 */
+			schedule_work_on(vmbus_connection.connect_cpu,
+					 &ctx->work);
+			break;
+
+		case CHANNELMSG_OFFERCHANNEL:
+			atomic_inc(&vmbus_connection.offer_in_progress);
+			queue_work_on(vmbus_connection.connect_cpu,
+				      vmbus_connection.work_queue,
+				      &ctx->work);
+			break;
+
+		default:
+			queue_work(vmbus_connection.work_queue, &ctx->work);
+		}
 	} else
 		entry->message_handler(hdr);
 
-- 
1.7.1
