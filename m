From: Dexuan Cui <decui@microsoft.com>
Subject: [V2 3/7] Drivers: hv: vmbus: add APIs to send/recv hvsock packet and
 get the r/w-ability
Date: Tue, 14 Jul 2015 02:58:56 -0700
Message-ID: <1436867936-17765-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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

This will be used by the coming net/hvsock driver.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 drivers/hv/channel.c      | 131 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/hv/hyperv_vmbus.h |   4 ++
 drivers/hv/ring_buffer.c  |  14 +++++
 include/linux/hyperv.h    |  33 ++++++++++++
 4 files changed, 182 insertions(+)

diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
index b09d1b7..9c3727a 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -758,6 +758,53 @@ int vmbus_sendpacket_pagebuffer_ctl(struct vmbus_channel *channel,
 EXPORT_SYMBOL_GPL(vmbus_sendpacket_pagebuffer_ctl);
 
 /*
+ * vmbus_sendpacket_hvsock - Send the hvsock payload 'buf' into the vmbus
+ * ringbuffer
+ */
+int vmbus_sendpacket_hvsock(struct vmbus_channel *channel, void *buf, u32 len)
+{
+	struct vmpacket_descriptor desc;
+	struct vmpipe_proto_header pipe_hdr;
+	u32 packetlen;
+	u32 packetlen_aligned;
+	struct kvec bufferlist[4];
+	u64 aligned_data = 0;
+	int ret;
+	bool signal = false;
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
+EXPORT_SYMBOL(vmbus_sendpacket_hvsock);
+
+/*
  * vmbus_sendpacket_pagebuffer - Send a range of single-page buffer
  * packets using a GPADL Direct packet type.
  */
@@ -978,3 +1025,87 @@ int vmbus_recvpacket_raw(struct vmbus_channel *channel, void *buffer,
 	return ret;
 }
 EXPORT_SYMBOL_GPL(vmbus_recvpacket_raw);
+
+/*
+ * vmbus_recvpacket_hvsock - Receive the hvsock payload from the vmbus
+ * ringbuffer into the 'buffer'.
+ */
+int vmbus_recvpacket_hvsock(struct vmbus_channel *channel, void *buffer,
+				u32 bufferlen, u32 *buffer_actual_len)
+{
+	struct vmpacket_descriptor *desc;
+	struct vmpipe_proto_header *pipe_hdr;
+	u32 packet_len, payload_len;
+	int ret;
+	bool signal = false;
+
+	*buffer_actual_len = 0;
+
+	if (bufferlen < HVSOCK_HEADER_LEN)
+		return -ENOBUFS;
+
+	ret = hv_ringbuffer_peek(&channel->inbound, buffer,
+				 HVSOCK_HEADER_LEN);
+	if (ret != 0)
+		return 0;
+
+	desc = (struct vmpacket_descriptor *)buffer;
+	packet_len = desc->len8 << 3;
+	if (desc->type != VM_PKT_DATA_INBAND ||
+		desc->offset8 != (sizeof(*desc) / 8) ||
+		packet_len < HVSOCK_HEADER_LEN)
+		return -EIO;
+
+	pipe_hdr = (struct vmpipe_proto_header *)(desc + 1);
+	payload_len = pipe_hdr->data_size;
+
+	if (pipe_hdr->pkt_type != 1 || payload_len == 0)
+		return -EIO;
+
+	if (HVSOCK_PKT_LEN(payload_len) != packet_len + PREV_INDICES_LEN)
+		return -EIO;
+
+	if (bufferlen < packet_len - HVSOCK_HEADER_LEN)
+		return -ENOBUFS;
+
+	/* Copy over the hvsock payload to the user buffer */
+	ret = hv_ringbuffer_read(&channel->inbound, buffer,
+				 packet_len - HVSOCK_HEADER_LEN,
+				 HVSOCK_HEADER_LEN, &signal);
+	if (ret != 0)
+		return ret;
+
+	*buffer_actual_len = payload_len;
+
+	if (signal)
+		vmbus_setevent(channel);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(vmbus_recvpacket_hvsock);
+
+/*
+ * vmbus_get_hvsock_rw_status - can the ringbuffer be read/written?
+ */
+void vmbus_get_hvsock_rw_status(struct vmbus_channel *channel,
+			   bool *can_read, bool *can_write)
+{
+	u32 avl_read_bytes, avl_write_bytes, dummy;
+
+	if (can_read != NULL) {
+		hv_get_ringbuffer_space(&channel->inbound, &avl_read_bytes,
+					&dummy);
+		*can_read = avl_read_bytes >= HVSOCK_MIN_PKT_LEN;
+	}
+
+	/* We write into the ringbuffer only when we're able to write a
+	 * a payload of 4096 bytes (the actual written payload's length may be
+	 * less than 4096).
+	 */
+	if (can_write != NULL) {
+		hv_get_ringbuffer_space(&channel->outbound, &dummy,
+					&avl_write_bytes);
+		*can_write = avl_write_bytes > HVSOCK_PKT_LEN(PAGE_SIZE);
+	}
+}
+EXPORT_SYMBOL_GPL(vmbus_get_hvsock_rw_status);
diff --git a/drivers/hv/hyperv_vmbus.h b/drivers/hv/hyperv_vmbus.h
index cddc0c9..d1787d0 100644
--- a/drivers/hv/hyperv_vmbus.h
+++ b/drivers/hv/hyperv_vmbus.h
@@ -608,6 +608,10 @@ int hv_ringbuffer_write(struct hv_ring_buffer_info *ring_info,
 int hv_ringbuffer_peek(struct hv_ring_buffer_info *ring_info, void *buffer,
 		   u32 buflen);
 
+void hv_get_ringbuffer_space(struct hv_ring_buffer_info *inring_info,
+				u32 *bytes_avail_toread,
+				u32 *bytes_avail_towrite);
+
 int hv_ringbuffer_read(struct hv_ring_buffer_info *ring_info,
 		   void *buffer,
 		   u32 buflen,
diff --git a/drivers/hv/ring_buffer.c b/drivers/hv/ring_buffer.c
index 6361d12..250d4ab 100644
--- a/drivers/hv/ring_buffer.c
+++ b/drivers/hv/ring_buffer.c
@@ -501,6 +501,20 @@ int hv_ringbuffer_peek(struct hv_ring_buffer_info *Inring_info,
 	return 0;
 }
 
+void hv_get_ringbuffer_space(struct hv_ring_buffer_info *inring_info,
+				u32 *bytes_avail_toread,
+				u32 *bytes_avail_towrite)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&inring_info->ring_lock, flags);
+
+	hv_get_ringbuffer_availbytes(inring_info,
+				bytes_avail_toread,
+				bytes_avail_towrite);
+
+	spin_unlock_irqrestore(&inring_info->ring_lock, flags);
+}
 
 /*
  *
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index 8799948..1e4c58e 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -885,6 +885,9 @@ extern int vmbus_sendpacket_ctl(struct vmbus_channel *channel,
 				  u32 flags,
 				  bool kick_q);
 
+extern int vmbus_sendpacket_hvsock(struct vmbus_channel *channel,
+					void *buf, u32 len);
+
 extern int vmbus_sendpacket_pagebuffer(struct vmbus_channel *channel,
 					    struct hv_page_buffer pagebuffers[],
 					    u32 pagecount,
@@ -934,6 +937,11 @@ extern int vmbus_recvpacket_raw(struct vmbus_channel *channel,
 				     u32 *buffer_actual_len,
 				     u64 *requestid);
 
+extern int vmbus_recvpacket_hvsock(struct vmbus_channel *channel, void *buffer,
+				u32 bufferlen, u32 *buffer_actual_len);
+
+extern void vmbus_get_hvsock_rw_status(struct vmbus_channel *channel,
+			   bool *can_read, bool *can_write);
 
 extern void vmbus_ontimer(unsigned long data);
 
@@ -1261,4 +1269,29 @@ extern __u32 vmbus_proto_version;
 
 int vmbus_send_tl_connect_request(const uuid_le *shv_guest_servie_id,
 				const uuid_le *shv_host_servie_id);
+
+struct vmpipe_proto_header {
+	u32 pkt_type;
+
+	union {
+		u32 data_size;
+		struct {
+			u16 data_size;
+			u16 offset;
+		} partial;
+	};
+} __packed;
+
+/* see hv_ringbuffer_read() and hv_ringbuffer_write() */
+#define PREV_INDICES_LEN	(sizeof(u64))
+
+#define HVSOCK_HEADER_LEN	(sizeof(struct vmpacket_descriptor) + \
+				 sizeof(struct vmpipe_proto_header))
+
+#define HVSOCK_PKT_LEN(payload_len)	(HVSOCK_HEADER_LEN + \
+					ALIGN((payload_len), 8) + \
+					PREV_INDICES_LEN)
+
+#define HVSOCK_MIN_PKT_LEN	HVSOCK_PKT_LEN(1)
+
 #endif /* _HYPERV_H */
-- 
2.1.0
