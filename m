From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V5 5/9] Drivers: hv: vmbus: add APIs to send/recv hvsock packets
Date: Thu, 24 Dec 2015 06:14:41 -0800
Message-ID: <1450966481-13208-1-git-send-email-decui@microsoft.com>
Cc: pebolle@tiscali.nl, stefanha@redhat.com, vkuznets@redhat.com,
	dan.carpenter@oracle.com
To: gregkh@linuxfoundation.org, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This will be used by the coming net/hvsock driver.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 drivers/hv/channel.c   | 59 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/hyperv.h |  9 ++++++++
 2 files changed, 68 insertions(+)

diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
index cc49966..ce1b885 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -924,6 +924,52 @@ int vmbus_sendpacket_multipagebuffer(struct vmbus_channel *channel,
 }
 EXPORT_SYMBOL_GPL(vmbus_sendpacket_multipagebuffer);
 
+/*
+ * vmbus_sendpacket_hvsock - Send the hvsock payload 'buf' of a length 'len'
+ */
+int vmbus_sendpacket_hvsock(struct vmbus_channel *channel, void *buf, u32 len)
+{
+	struct vmpipe_proto_header pipe_hdr;
+	struct vmpacket_descriptor desc;
+	struct kvec bufferlist[4];
+	u32 packetlen_aligned;
+	u32 packetlen;
+	u64 aligned_data = 0;
+	bool signal = false;
+	int ret;
+
+	packetlen = HVSOCK_HEADER_LEN + len;
+	packetlen_aligned = ALIGN(packetlen, sizeof(u64));
+
+	/* Setup the descriptor */
+	desc.type = VM_PKT_DATA_INBAND;
+	/* in 8-bytes granularity */
+	desc.offset8 = sizeof(struct vmpacket_descriptor) >> 3;
+	desc.len8 = (u16)(packetlen_aligned >> 3);
+	desc.flags = 0;
+	desc.trans_id = 0;
+
+	pipe_hdr.pkt_type = 1;
+	pipe_hdr.data_size = len;
+
+	bufferlist[0].iov_base = &desc;
+	bufferlist[0].iov_len  = sizeof(struct vmpacket_descriptor);
+	bufferlist[1].iov_base = &pipe_hdr;
+	bufferlist[1].iov_len  = sizeof(struct vmpipe_proto_header);
+	bufferlist[2].iov_base = buf;
+	bufferlist[2].iov_len  = len;
+	bufferlist[3].iov_base = &aligned_data;
+	bufferlist[3].iov_len  = packetlen_aligned - packetlen;
+
+	ret = hv_ringbuffer_write(&channel->outbound, bufferlist, 4, &signal);
+
+	if (ret == 0 && signal)
+		vmbus_setevent(channel);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(vmbus_sendpacket_hvsock);
+
 /**
  * vmbus_recvpacket() - Retrieve the user packet on the specified channel
  * @channel: Pointer to vmbus_channel structure.
@@ -976,3 +1022,16 @@ int vmbus_recvpacket_raw(struct vmbus_channel *channel, void *buffer,
 				  HV_RINGBUFFER_READ_FLAG_RAW);
 }
 EXPORT_SYMBOL_GPL(vmbus_recvpacket_raw);
+
+/*
+ * vmbus_recvpacket_hvsock - Receive the hvsock payload from the vmbus
+ * ringbuffer into the 'buffer'.
+ */
+int vmbus_recvpacket_hvsock(struct vmbus_channel *channel, void *buffer,
+			    u32 bufferlen, u32 *buffer_actual_len)
+{
+	return __vmbus_recvpacket(channel, buffer, bufferlen,
+				  buffer_actual_len, NULL,
+				  HV_RINGBUFFER_READ_FLAG_HVSOCK);
+}
+EXPORT_SYMBOL_GPL(vmbus_recvpacket_hvsock);
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index e005223..646c20d 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -908,6 +908,9 @@ extern int vmbus_sendpacket_ctl(struct vmbus_channel *channel,
 				  u32 flags,
 				  bool kick_q);
 
+extern int vmbus_sendpacket_hvsock(struct vmbus_channel *channel,
+				   void *buf, u32 len);
+
 extern int vmbus_sendpacket_pagebuffer(struct vmbus_channel *channel,
 					    struct hv_page_buffer pagebuffers[],
 					    u32 pagecount,
@@ -958,6 +961,9 @@ extern int vmbus_recvpacket_raw(struct vmbus_channel *channel,
 				     u64 *requestid);
 
 
+extern int vmbus_recvpacket_hvsock(struct vmbus_channel *channel, void *buffer,
+				   u32 bufferlen, u32 *buffer_actual_len);
+
 extern void vmbus_ontimer(unsigned long data);
 
 /* Base driver object */
@@ -1280,4 +1286,7 @@ struct vmpipe_proto_header {
 	};
 } __packed;
 
+#define HVSOCK_HEADER_LEN	(sizeof(struct vmpacket_descriptor) + \
+				 sizeof(struct vmpipe_proto_header))
+
 #endif /* _HYPERV_H */
-- 
2.1.4
