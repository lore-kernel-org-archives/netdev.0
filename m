From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [patch 7/7] netxen: fix byte-swapping in tx and rx
Date: Mon, 31 Dec 2007 10:08:57 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0712310958240.18021@dut46.unminc.com>
References: <20071226182352.704678179@netxen.com> <20071226182928.425988922@netxen.com>
 <20071226223803.GE27894@ZenIV.linux.org.uk> <Pine.LNX.4.64.0712261525490.23059@dut46.unminc.com>
 <20071226235334.GF27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Al Viro <viro@ZenIV.linux.org.uk>, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:49541 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750935AbXLaSEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 13:04:32 -0500
In-Reply-To: <20071226235334.GF27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's the reworked patch.

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
@@ -309,23 +309,26 @@ struct netxen_ring_ctx {
 	((cmd_desc)->port_ctxid |= ((var) & 0xF0))
 
 #define netxen_set_cmd_desc_flags(cmd_desc, val)	\
-	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x7f), \
-	(cmd_desc)->flags_opcode |= cpu_to_le16((val) & 0x7f))
+	(cmd_desc)->flags_opcode = ((cmd_desc)->flags_opcode & \
+		~cpu_to_le16(0x7f)) | cpu_to_le16((val) & 0x7f)
 #define netxen_set_cmd_desc_opcode(cmd_desc, val)	\
-	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x3f<<7), \
-	(cmd_desc)->flags_opcode |= cpu_to_le16(((val & 0x3f)<<7)))
+	(cmd_desc)->flags_opcode = ((cmd_desc)->flags_opcode & \
+		~cpu_to_le16((u16)0x3f << 7)) | cpu_to_le16(((val) & 0x3f) << 7)
 
 #define netxen_set_cmd_desc_num_of_buff(cmd_desc, val)	\
-	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xff), \
-	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32((val) & 0xff))
+	(cmd_desc)->num_of_buffers_total_length = \
+		((cmd_desc)->num_of_buffers_total_length & \
+		~cpu_to_le32(0xff)) | cpu_to_le32((val) & 0xff)
 #define netxen_set_cmd_desc_totallength(cmd_desc, val)	\
-	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xffffff00), \
-	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32(val << 8))
+	(cmd_desc)->num_of_buffers_total_length = \
+		((cmd_desc)->num_of_buffers_total_length & \
+		~cpu_to_le32((u32)0xffffff << 8)) | \
+		cpu_to_le32(((val) & 0xffffff) << 8)
 
 #define netxen_get_cmd_desc_opcode(cmd_desc)	\
-	((le16_to_cpu((cmd_desc)->flags_opcode) >> 7) & 0x003F)
+	((le16_to_cpu((cmd_desc)->flags_opcode) >> 7) & 0x003f)
 #define netxen_get_cmd_desc_totallength(cmd_desc)	\
-	(le32_to_cpu((cmd_desc)->num_of_buffers_total_length) >> 8)
+	((le32_to_cpu((cmd_desc)->num_of_buffers_total_length) >> 8) & 0xffffff)
 
 struct cmd_desc_type0 {
 	u8 tcp_hdr_offset;	/* For LSO only */
@@ -412,29 +415,29 @@ struct rcv_desc {
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
+#define netxen_get_sts_opcode(sts_data)	\
+	(((sts_data) >> 58) & 0x03F)
+
 #define netxen_get_sts_owner(status_desc)	\
 	((le64_to_cpu((status_desc)->status_desc_data) >> 56) & 0x03)
-#define netxen_get_sts_opcode(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 58) & 0x03F)
-
-#define netxen_clear_sts_owner(status_desc)	\
-	((status_desc)->status_desc_data &=	\
-	~cpu_to_le64(((unsigned long long)3) << 56 ))
-#define netxen_set_sts_owner(status_desc, val)	\
-	((status_desc)->status_desc_data |=	\
-	cpu_to_le64(((unsigned long long)((val) & 0x3)) << 56 ))
+#define netxen_set_sts_owner(status_desc, val)	{ \
+	(status_desc)->status_desc_data = \
+		((status_desc)->status_desc_data & \
+		~cpu_to_le64(0x3ULL << 56)) | \
+		cpu_to_le64((u64)((val) & 0x3) << 56); \
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
@@ -1191,7 +1192,6 @@ u32 netxen_process_rcv_ring(struct netxe
 			break;
 		}
 		netxen_process_rcv(adapter, ctxid, desc);
-		netxen_clear_sts_owner(desc);
 		netxen_set_sts_owner(desc, STATUS_OWNER_PHANTOM);
 		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
 		count++;
Index: netdev-2.6/drivers/net/netxen/netxen_nic_main.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_main.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c
@@ -1144,16 +1144,8 @@ static int netxen_nic_xmit_frame(struct 
 		}
 	}
 
-	i = netxen_get_cmd_desc_totallength(&hw->cmd_desc_head[saved_producer]);
-
-	hw->cmd_desc_head[saved_producer].flags_opcode =
-		cpu_to_le16(hw->cmd_desc_head[saved_producer].flags_opcode);
-	hw->cmd_desc_head[saved_producer].num_of_buffers_total_length =
-	  cpu_to_le32(hw->cmd_desc_head[saved_producer].
-			  num_of_buffers_total_length);
-
 	spin_lock_bh(&adapter->tx_lock);
-	adapter->stats.txbytes += i;
+	adapter->stats.txbytes += skb->len;
 
 	/* Code to update the adapter considering how many producer threads
 	   are currently working */
