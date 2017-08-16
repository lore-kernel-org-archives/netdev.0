From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/3] vmbus: remove unused vmbus_sendpacket_ctl
Date: Wed, 16 Aug 2017 08:56:26 -0700
Message-ID: <20170816155626.16580-4-sthemmin@microsoft.com>
References: <20170816155626.16580-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36633 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751943AbdHPP4i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 11:56:38 -0400
Received: by mail-pg0-f47.google.com with SMTP id i12so24692968pgr.3
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 08:56:38 -0700 (PDT)
In-Reply-To: <20170816155626.16580-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only usage of vmbus_sendpacket_ctl was by vmbus_sendpacket.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/hv/channel.c        | 43 +++++++++++++++++--------------------------
 drivers/net/hyperv/netvsc.c |  9 ++++-----
 include/linux/hyperv.h      |  7 -------
 3 files changed, 21 insertions(+), 38 deletions(-)

diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
index 9223fe8823e0..d9e9676e2b40 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -647,9 +647,23 @@ void vmbus_close(struct vmbus_channel *channel)
 }
 EXPORT_SYMBOL_GPL(vmbus_close);
 
-int vmbus_sendpacket_ctl(struct vmbus_channel *channel, void *buffer,
-			 u32 bufferlen, u64 requestid,
-			 enum vmbus_packet_type type, u32 flags)
+/**
+ * vmbus_sendpacket() - Send the specified buffer on the given channel
+ * @channel: Pointer to vmbus_channel structure.
+ * @buffer: Pointer to the buffer you want to receive the data into.
+ * @bufferlen: Maximum size of what the the buffer will hold
+ * @requestid: Identifier of the request
+ * @type: Type of packet that is being send e.g. negotiate, time
+ * packet etc.
+ *
+ * Sends data in @buffer directly to hyper-v via the vmbus
+ * This will send the data unparsed to hyper-v.
+ *
+ * Mainly used by Hyper-V drivers.
+ */
+int vmbus_sendpacket(struct vmbus_channel *channel, void *buffer,
+			   u32 bufferlen, u64 requestid,
+			   enum vmbus_packet_type type, u32 flags)
 {
 	struct vmpacket_descriptor desc;
 	u32 packetlen = sizeof(struct vmpacket_descriptor) + bufferlen;
@@ -676,29 +690,6 @@ int vmbus_sendpacket_ctl(struct vmbus_channel *channel, void *buffer,
 
 	return hv_ringbuffer_write(channel, bufferlist, num_vecs);
 }
-EXPORT_SYMBOL(vmbus_sendpacket_ctl);
-
-/**
- * vmbus_sendpacket() - Send the specified buffer on the given channel
- * @channel: Pointer to vmbus_channel structure.
- * @buffer: Pointer to the buffer you want to receive the data into.
- * @bufferlen: Maximum size of what the the buffer will hold
- * @requestid: Identifier of the request
- * @type: Type of packet that is being send e.g. negotiate, time
- * packet etc.
- *
- * Sends data in @buffer directly to hyper-v via the vmbus
- * This will send the data unparsed to hyper-v.
- *
- * Mainly used by Hyper-V drivers.
- */
-int vmbus_sendpacket(struct vmbus_channel *channel, void *buffer,
-			   u32 bufferlen, u64 requestid,
-			   enum vmbus_packet_type type, u32 flags)
-{
-	return vmbus_sendpacket_ctl(channel, buffer, bufferlen, requestid,
-				    type, flags);
-}
 EXPORT_SYMBOL(vmbus_sendpacket);
 
 /*
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 6031102cbba3..0062b802676f 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -780,11 +780,10 @@ static inline int netvsc_send_pkt(
 						  &nvmsg, sizeof(nvmsg),
 						  req_id);
 	} else {
-		ret = vmbus_sendpacket_ctl(out_channel, &nvmsg,
-					   sizeof(struct nvsp_message),
-					   req_id,
-					   VM_PKT_DATA_INBAND,
-					   VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
+		ret = vmbus_sendpacket(out_channel,
+				       &nvmsg, sizeof(nvmsg),
+				       req_id, VM_PKT_DATA_INBAND,
+				       VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
 	}
 
 	if (ret == 0) {
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index 9692592d43a3..a5f961c4149e 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -1030,13 +1030,6 @@ extern int vmbus_sendpacket(struct vmbus_channel *channel,
 				  enum vmbus_packet_type type,
 				  u32 flags);
 
-extern int vmbus_sendpacket_ctl(struct vmbus_channel *channel,
-				  void *buffer,
-				  u32 bufferLen,
-				  u64 requestid,
-				  enum vmbus_packet_type type,
-				  u32 flags);
-
 extern int vmbus_sendpacket_pagebuffer(struct vmbus_channel *channel,
 					    struct hv_page_buffer pagebuffers[],
 					    u32 pagecount,
-- 
2.11.0
