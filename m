From: dhananjay@netxen.com
Subject: [patch 7/7] netxen: fix byte-swapping in tx and rx
Date: Wed, 26 Dec 2007 10:23:59 -0800
Message-ID: <20071226182928.425988922@netxen.com>
References: <20071226182352.704678179@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:45040 "EHLO dut46.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750963AbXLZSZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Dec 2007 13:25:55 -0500
Content-Disposition: inline; filename=endian.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This cleans up some unnecessary byte-swapping while setting up tx and
interpreting rx desc. The 64 bit rx status data should be converted
to host endian format only once and the macros just need to extract
bitfields.

This saves a spate of interrupts on pseries blades caused by buggy 
(non) processing rx status ring.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Index: netdev-2.6/drivers/net/netxen/netxen_nic.h
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic.h
+++ netdev-2.6/drivers/net/netxen/netxen_nic.h
@@ -309,23 +309,23 @@ struct netxen_ring_ctx {
 	((cmd_desc)->port_ctxid |= ((var) & 0xF0))
 
 #define netxen_set_cmd_desc_flags(cmd_desc, val)	\
-	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x7f), \
-	(cmd_desc)->flags_opcode |= cpu_to_le16((val) & 0x7f))
+	((cmd_desc)->flags_opcode &= ~(0x7f), \
+	(cmd_desc)->flags_opcode |= (val) & 0x7f)
 #define netxen_set_cmd_desc_opcode(cmd_desc, val)	\
-	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x3f<<7), \
-	(cmd_desc)->flags_opcode |= cpu_to_le16(((val & 0x3f)<<7)))
+	((cmd_desc)->flags_opcode &= ~(0x3f<<7), \
+	(cmd_desc)->flags_opcode |= ((val) & 0x3f) << 7)
 
 #define netxen_set_cmd_desc_num_of_buff(cmd_desc, val)	\
-	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xff), \
-	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32((val) & 0xff))
+	((cmd_desc)->num_of_buffers_total_length &= ~(0xff), \
+	(cmd_desc)->num_of_buffers_total_length |= (val) & 0xff)
 #define netxen_set_cmd_desc_totallength(cmd_desc, val)	\
-	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xffffff00), \
-	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32(val << 8))
+	((cmd_desc)->num_of_buffers_total_length &= ~(0xffffff << 8), \
+	(cmd_desc)->num_of_buffers_total_length |= (val) << 8)
 
 #define netxen_get_cmd_desc_opcode(cmd_desc)	\
-	((le16_to_cpu((cmd_desc)->flags_opcode) >> 7) & 0x003F)
+	(((cmd_desc)->flags_opcode >> 7) & 0x003f)
 #define netxen_get_cmd_desc_totallength(cmd_desc)	\
-	(le32_to_cpu((cmd_desc)->num_of_buffers_total_length) >> 8)
+	(((cmd_desc)->num_of_buffers_total_length >> 8) & 0xffffff)
 
 struct cmd_desc_type0 {
 	u8 tcp_hdr_offset;	/* For LSO only */
@@ -412,29 +412,29 @@ struct rcv_desc {
 #define netxen_get_sts_desc_lro_last_frag(status_desc)	\
 	(((status_desc)->lro & 0x80) >> 7)
 
-#define netxen_get_sts_port(status_desc)	\
-	(le64_to_cpu((status_desc)->status_desc_data) & 0x0F)
-#define netxen_get_sts_status(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 4) & 0x0F)
-#define netxen_get_sts_type(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 8) & 0x0F)
-#define netxen_get_sts_totallength(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 12) & 0xFFFF)
-#define netxen_get_sts_refhandle(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 28) & 0xFFFF)
-#define netxen_get_sts_prot(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 44) & 0x0F)
-#define netxen_get_sts_owner(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 56) & 0x03)
-#define netxen_get_sts_opcode(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 58) & 0x03F)
-
-#define netxen_clear_sts_owner(status_desc)	\
-	((status_desc)->status_desc_data &=	\
-	~cpu_to_le64(((unsigned long long)3) << 56 ))
-#define netxen_set_sts_owner(status_desc, val)	\
-	((status_desc)->status_desc_data |=	\
-	cpu_to_le64(((unsigned long long)((val) & 0x3)) << 56 ))
+#define netxen_get_sts_port(sts_data)	\
+	((sts_data) & 0x0F)
+#define netxen_get_sts_status(sts_data)	\
+	(((sts_data) >> 4) & 0x0F)
+#define netxen_get_sts_type(sts_data)	\
+	(((sts_data) >> 8) & 0x0F)
+#define netxen_get_sts_totallength(sts_data)	\
+	(((sts_data) >> 12) & 0xFFFF)
+#define netxen_get_sts_refhandle(sts_data)	\
+	(((sts_data) >> 28) & 0xFFFF)
+#define netxen_get_sts_prot(sts_data)	\
+	(((sts_data) >> 44) & 0x0F)
+#define netxen_get_sts_owner(sts_data)	\
+	(((sts_data) >> 56) & 0x03)
+#define netxen_get_sts_opcode(sts_data)	\
+	(((sts_data) >> 58) & 0x03F)
+
+#define netxen_set_sts_owner(status_desc, val)	{ \
+	u64 value = le64_to_cpu((status_desc)->status_desc_data); \
+	value &= ~(0x3ULL << 56); \
+	value |= (u64)(((u64)(val) << 56) & (0x3ULL << 56)); \
+	(status_desc)->status_desc_data = cpu_to_le64(value); \
+}
 
 struct status_desc {
 	/* Bit pattern: 0-3 port, 4-7 status, 8-11 type, 12-27 total_length
Index: netdev-2.6/drivers/net/netxen/netxen_nic_init.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_init.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_init.c
@@ -1053,16 +1053,17 @@ static void netxen_process_rcv(struct ne
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct net_device *netdev = adapter->netdev;
-	int index = netxen_get_sts_refhandle(desc);
+	u64 sts_data = le64_to_cpu(desc->status_desc_data);
+	int index = netxen_get_sts_refhandle(sts_data);
 	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
 	struct netxen_rx_buffer *buffer;
 	struct sk_buff *skb;
-	u32 length = netxen_get_sts_totallength(desc);
+	u32 length = netxen_get_sts_totallength(sts_data);
 	u32 desc_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
 	int ret;
 
-	desc_ctx = netxen_get_sts_type(desc);
+	desc_ctx = netxen_get_sts_type(sts_data);
 	if (unlikely(desc_ctx >= NUM_RCV_DESC_RINGS)) {
 		printk("%s: %s Bad Rcv descriptor ring\n",
 		       netxen_nic_driver_name, netdev->name);
@@ -1102,7 +1103,7 @@ static void netxen_process_rcv(struct ne
 	skb = (struct sk_buff *)buffer->skb;
 
 	if (likely(adapter->rx_csum &&
-				netxen_get_sts_status(desc) == STATUS_CKSUM_OK)) {
+				netxen_get_sts_status(sts_data) == STATUS_CKSUM_OK)) {
 		adapter->stats.csummed++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else
@@ -1185,13 +1186,12 @@ u32 netxen_process_rcv_ring(struct netxe
 	 */
 	while (count < max) {
 		desc = &desc_head[consumer];
-		if (!(netxen_get_sts_owner(desc) & STATUS_OWNER_HOST)) {
+		if (!(netxen_get_sts_owner(le64_to_cpu(desc->status_desc_data)) & STATUS_OWNER_HOST)) {
 			DPRINTK(ERR, "desc %p ownedby %x\n", desc,
 				netxen_get_sts_owner(desc));
 			break;
 		}
 		netxen_process_rcv(adapter, ctxid, desc);
-		netxen_clear_sts_owner(desc);
 		netxen_set_sts_owner(desc, STATUS_OWNER_PHANTOM);
 		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
 		count++;

-- 
