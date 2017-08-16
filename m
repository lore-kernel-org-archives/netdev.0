From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/3] vmbus: remove unused vmbus_sendpacket_multipagebuffer
Date: Wed, 16 Aug 2017 08:56:24 -0700
Message-ID: <20170816155626.16580-2-sthemmin@microsoft.com>
References: <20170816155626.16580-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33893 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751943AbdHPP4f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 11:56:35 -0400
Received: by mail-pf0-f175.google.com with SMTP id o86so7829421pfj.1
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 08:56:35 -0700 (PDT)
In-Reply-To: <20170816155626.16580-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is not used anywhere in current code.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/hv/channel.c   | 56 --------------------------------------------------
 include/linux/hyperv.h |  6 ------
 2 files changed, 62 deletions(-)

diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
index e57cc40cb768..756a1e841142 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -814,62 +814,6 @@ int vmbus_sendpacket_mpb_desc(struct vmbus_channel *channel,
 }
 EXPORT_SYMBOL_GPL(vmbus_sendpacket_mpb_desc);
 
-/*
- * vmbus_sendpacket_multipagebuffer - Send a multi-page buffer packet
- * using a GPADL Direct packet type.
- */
-int vmbus_sendpacket_multipagebuffer(struct vmbus_channel *channel,
-				struct hv_multipage_buffer *multi_pagebuffer,
-				void *buffer, u32 bufferlen, u64 requestid)
-{
-	struct vmbus_channel_packet_multipage_buffer desc;
-	u32 descsize;
-	u32 packetlen;
-	u32 packetlen_aligned;
-	struct kvec bufferlist[3];
-	u64 aligned_data = 0;
-	u32 pfncount = NUM_PAGES_SPANNED(multi_pagebuffer->offset,
-					 multi_pagebuffer->len);
-
-	if (pfncount > MAX_MULTIPAGE_BUFFER_COUNT)
-		return -EINVAL;
-
-	/*
-	 * Adjust the size down since vmbus_channel_packet_multipage_buffer is
-	 * the largest size we support
-	 */
-	descsize = sizeof(struct vmbus_channel_packet_multipage_buffer) -
-			  ((MAX_MULTIPAGE_BUFFER_COUNT - pfncount) *
-			  sizeof(u64));
-	packetlen = descsize + bufferlen;
-	packetlen_aligned = ALIGN(packetlen, sizeof(u64));
-
-
-	/* Setup the descriptor */
-	desc.type = VM_PKT_DATA_USING_GPA_DIRECT;
-	desc.flags = VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED;
-	desc.dataoffset8 = descsize >> 3; /* in 8-bytes granularity */
-	desc.length8 = (u16)(packetlen_aligned >> 3);
-	desc.transactionid = requestid;
-	desc.rangecount = 1;
-
-	desc.range.len = multi_pagebuffer->len;
-	desc.range.offset = multi_pagebuffer->offset;
-
-	memcpy(desc.range.pfn_array, multi_pagebuffer->pfn_array,
-	       pfncount * sizeof(u64));
-
-	bufferlist[0].iov_base = &desc;
-	bufferlist[0].iov_len = descsize;
-	bufferlist[1].iov_base = buffer;
-	bufferlist[1].iov_len = bufferlen;
-	bufferlist[2].iov_base = &aligned_data;
-	bufferlist[2].iov_len = (packetlen_aligned - packetlen);
-
-	return hv_ringbuffer_write(channel, bufferlist, 3);
-}
-EXPORT_SYMBOL_GPL(vmbus_sendpacket_multipagebuffer);
-
 /**
  * vmbus_recvpacket() - Retrieve the user packet on the specified channel
  * @channel: Pointer to vmbus_channel structure.
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index b7d7bbec74e0..39a080ce17da 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -1052,12 +1052,6 @@ extern int vmbus_sendpacket_pagebuffer_ctl(struct vmbus_channel *channel,
 					   u64 requestid,
 					   u32 flags);
 
-extern int vmbus_sendpacket_multipagebuffer(struct vmbus_channel *channel,
-					struct hv_multipage_buffer *mpb,
-					void *buffer,
-					u32 bufferlen,
-					u64 requestid);
-
 extern int vmbus_sendpacket_mpb_desc(struct vmbus_channel *channel,
 				     struct vmbus_packet_mpb_array *mpb,
 				     u32 desc_size,
-- 
2.11.0
