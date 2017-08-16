From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/3] vmbus: remove unused vmubs_sendpacket_pagebuffer_ctl
Date: Wed, 16 Aug 2017 08:56:25 -0700
Message-ID: <20170816155626.16580-3-sthemmin@microsoft.com>
References: <20170816155626.16580-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:37508 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752467AbdHPP4h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 11:56:37 -0400
Received: by mail-pg0-f50.google.com with SMTP id y129so24633663pgy.4
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 08:56:36 -0700 (PDT)
In-Reply-To: <20170816155626.16580-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function vmbus_sendpacket_pagebuffer_ctl was never used directly.
Just have vmbus_send_pagebuffer

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/hv/channel.c        | 30 ++++++------------------------
 drivers/net/hyperv/netvsc.c | 10 ++++------
 include/linux/hyperv.h      |  8 --------
 3 files changed, 10 insertions(+), 38 deletions(-)

diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
index 756a1e841142..9223fe8823e0 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -702,16 +702,16 @@ int vmbus_sendpacket(struct vmbus_channel *channel, void *buffer,
 EXPORT_SYMBOL(vmbus_sendpacket);
 
 /*
- * vmbus_sendpacket_pagebuffer_ctl - Send a range of single-page buffer
+ * vmbus_sendpacket_pagebuffer - Send a range of single-page buffer
  * packets using a GPADL Direct packet type. This interface allows you
  * to control notifying the host. This will be useful for sending
  * batched data. Also the sender can control the send flags
  * explicitly.
  */
-int vmbus_sendpacket_pagebuffer_ctl(struct vmbus_channel *channel,
-				    struct hv_page_buffer pagebuffers[],
-				    u32 pagecount, void *buffer, u32 bufferlen,
-				    u64 requestid, u32 flags)
+int vmbus_sendpacket_pagebuffer(struct vmbus_channel *channel,
+				struct hv_page_buffer pagebuffers[],
+				u32 pagecount, void *buffer, u32 bufferlen,
+				u64 requestid)
 {
 	int i;
 	struct vmbus_channel_packet_page_buffer desc;
@@ -736,7 +736,7 @@ int vmbus_sendpacket_pagebuffer_ctl(struct vmbus_channel *channel,
 
 	/* Setup the descriptor */
 	desc.type = VM_PKT_DATA_USING_GPA_DIRECT;
-	desc.flags = flags;
+	desc.flags = VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED;
 	desc.dataoffset8 = descsize >> 3; /* in 8-bytes granularity */
 	desc.length8 = (u16)(packetlen_aligned >> 3);
 	desc.transactionid = requestid;
@@ -757,24 +757,6 @@ int vmbus_sendpacket_pagebuffer_ctl(struct vmbus_channel *channel,
 
 	return hv_ringbuffer_write(channel, bufferlist, 3);
 }
-EXPORT_SYMBOL_GPL(vmbus_sendpacket_pagebuffer_ctl);
-
-/*
- * vmbus_sendpacket_pagebuffer - Send a range of single-page buffer
- * packets using a GPADL Direct packet type.
- */
-int vmbus_sendpacket_pagebuffer(struct vmbus_channel *channel,
-				     struct hv_page_buffer pagebuffers[],
-				     u32 pagecount, void *buffer, u32 bufferlen,
-				     u64 requestid)
-{
-	u32 flags = VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED;
-
-	return vmbus_sendpacket_pagebuffer_ctl(channel, pagebuffers, pagecount,
-					       buffer, bufferlen,
-					       requestid, flags);
-
-}
 EXPORT_SYMBOL_GPL(vmbus_sendpacket_pagebuffer);
 
 /*
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 0530e7d729e1..6031102cbba3 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -775,12 +775,10 @@ static inline int netvsc_send_pkt(
 		if (packet->cp_partial)
 			pb += packet->rmsg_pgcnt;
 
-		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
-						      pb, packet->page_buf_cnt,
-						      &nvmsg,
-						      sizeof(struct nvsp_message),
-						      req_id,
-						      VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
+		ret = vmbus_sendpacket_pagebuffer(out_channel,
+						  pb, packet->page_buf_cnt,
+						  &nvmsg, sizeof(nvmsg),
+						  req_id);
 	} else {
 		ret = vmbus_sendpacket_ctl(out_channel, &nvmsg,
 					   sizeof(struct nvsp_message),
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index 39a080ce17da..9692592d43a3 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -1044,14 +1044,6 @@ extern int vmbus_sendpacket_pagebuffer(struct vmbus_channel *channel,
 					    u32 bufferlen,
 					    u64 requestid);
 
-extern int vmbus_sendpacket_pagebuffer_ctl(struct vmbus_channel *channel,
-					   struct hv_page_buffer pagebuffers[],
-					   u32 pagecount,
-					   void *buffer,
-					   u32 bufferlen,
-					   u64 requestid,
-					   u32 flags);
-
 extern int vmbus_sendpacket_mpb_desc(struct vmbus_channel *channel,
 				     struct vmbus_packet_mpb_array *mpb,
 				     u32 desc_size,
-- 
2.11.0
