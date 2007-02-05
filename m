From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 1/3] NetXen: Fixes for ppc architecture.
Date: Mon, 5 Feb 2007 07:33:35 -0800
Message-ID: <200702051533.l15FXZGU008550@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com, sanjeev@netxen.com, wendyx@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:27807 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932965AbXBEPdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 10:33:35 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fixes for ppc architecture.

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

---

 netxen_nic.h      |   98 ++++++++++++++++++++++++++++++++----------------------
 netxen_nic_hw.c   |   31 ++++++++---------
 netxen_nic_init.c |   16 ++++----
 netxen_nic_main.c |    7 ++-
 netxen_nic_niu.c  |    2 -
 5 files changed, 89 insertions(+), 65 deletions(-)
      
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 59324b1..d689476 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -246,6 +246,18 @@ #define _netxen_set_bits(config_word, st
 	(config_word) |= (((value) << (start)) & mask); \
 }
 
+static inline u32 netxen_set_32bits(u32 config_word, int start,
+				  int bits, u32 val)
+{
+	_netxen_set_bits(config_word, start, bits, val);
+	return config_word;
+}
+static inline u16 netxen_set_16bits(u16 config_word, int start,
+				  int bits, u16 val)
+{
+	_netxen_set_bits(config_word, start, bits, val);
+	return config_word;
+}
 #define netxen_set_msg_peg_id(config_word, val)	\
 	_netxen_set_bits(config_word, 0, 2, val)
 #define netxen_set_msg_privid(config_word)	\
@@ -305,69 +317,77 @@ #define netxen_set_cmd_desc_port(cmd_des
 	((cmd_desc)->port_ctxid |= ((var) & 0x0F))
 
 #define netxen_set_cmd_desc_flags(cmd_desc, val)	\
-	_netxen_set_bits((cmd_desc)->flags_opcode, 0, 7, val)
+	(cmd_desc)->flags_opcode = cpu_to_le16(	\
+	netxen_set_16bits(le16_to_cpu((cmd_desc)->flags_opcode), 0, 7, val))
+
 #define netxen_set_cmd_desc_opcode(cmd_desc, val)	\
-	_netxen_set_bits((cmd_desc)->flags_opcode, 7, 6, val)
+	(cmd_desc)->flags_opcode = cpu_to_le16( \
+	netxen_set_16bits(le16_to_cpu((cmd_desc)->flags_opcode), 7, 6, val))
 
 #define netxen_set_cmd_desc_num_of_buff(cmd_desc, val)	\
-	_netxen_set_bits((cmd_desc)->num_of_buffers_total_length, 0, 8, val);
+	(cmd_desc)->num_of_buffers_total_length = cpu_to_le32(	\
+	netxen_set_32bits(le32_to_cpu((cmd_desc)->num_of_buffers_total_length),	\
+			  0, 8, val))
+
 #define netxen_set_cmd_desc_totallength(cmd_desc, val)	\
-	_netxen_set_bits((cmd_desc)->num_of_buffers_total_length, 8, 24, val);
+	(cmd_desc)->num_of_buffers_total_length = cpu_to_le32(  \
+	netxen_set_32bits(le32_to_cpu((cmd_desc)->num_of_buffers_total_length),	\
+			  8, 24, val))
 
 #define netxen_get_cmd_desc_opcode(cmd_desc)	\
-	(((cmd_desc)->flags_opcode >> 7) & 0x003F)
+	((le16_to_cpu((cmd_desc)->flags_opcode) >> 7) & 0x003F)
 #define netxen_get_cmd_desc_totallength(cmd_desc)	\
-	(((cmd_desc)->num_of_buffers_total_length >> 8) & 0x0FFFFFF)
+	((le32_to_cpu((cmd_desc)->num_of_buffers_total_length) >> 8) & 0x0FFFFFF)
 
 struct cmd_desc_type0 {
 	u8 tcp_hdr_offset;	/* For LSO only */
 	u8 ip_hdr_offset;	/* For LSO only */
 	/* Bit pattern: 0-6 flags, 7-12 opcode, 13-15 unused */
-	u16 flags_opcode;
+	__le16 flags_opcode;
 	/* Bit pattern: 0-7 total number of segments,
 	   8-31 Total size of the packet */
-	u32 num_of_buffers_total_length;
+	__le32 num_of_buffers_total_length;
 	union {
 		struct {
-			u32 addr_low_part2;
-			u32 addr_high_part2;
+			__le32 addr_low_part2;
+			__le32 addr_high_part2;
 		};
-		u64 addr_buffer2;
+		__le64 addr_buffer2;
 	};
 
-	u16 reference_handle;	/* changed to u16 to add mss */
-	u16 mss;		/* passed by NDIS_PACKET for LSO */
+	__le16 reference_handle;	/* changed to u16 to add mss */
+	__le16 mss;		/* passed by NDIS_PACKET for LSO */
 	/* Bit pattern 0-3 port, 0-3 ctx id */
 	u8 port_ctxid;
 	u8 total_hdr_length;	/* LSO only : MAC+IP+TCP Hdr size */
-	u16 conn_id;		/* IPSec offoad only */
+	__le16 conn_id;		/* IPSec offoad only */
 
 	union {
 		struct {
-			u32 addr_low_part3;
-			u32 addr_high_part3;
+			__le32 addr_low_part3;
+			__le32 addr_high_part3;
 		};
-		u64 addr_buffer3;
+		__le64 addr_buffer3;
 	};
 	union {
 		struct {
-			u32 addr_low_part1;
-			u32 addr_high_part1;
+			__le32 addr_low_part1;
+			__le32 addr_high_part1;
 		};
-		u64 addr_buffer1;
+		__le64 addr_buffer1;
 	};
 
-	u16 buffer1_length;
-	u16 buffer2_length;
-	u16 buffer3_length;
-	u16 buffer4_length;
+	__le16 buffer1_length;
+	__le16 buffer2_length;
+	__le16 buffer3_length;
+	__le16 buffer4_length;
 
 	union {
 		struct {
-			u32 addr_low_part4;
-			u32 addr_high_part4;
+			__le32 addr_low_part4;
+			__le32 addr_high_part4;
 		};
-		u64 addr_buffer4;
+		__le64 addr_buffer4;
 	};
 
 	u64 unused;
@@ -405,36 +425,36 @@ #define netxen_get_sts_desc_lro_last_fra
 	(((status_desc)->lro & 0x80) >> 7)
 
 #define netxen_get_sts_port(status_desc)	\
-	((status_desc)->status_desc_data & 0x0F)
+	(le64_to_cpu((status_desc)->status_desc_data) & 0x0F)
 #define netxen_get_sts_status(status_desc)	\
-	(((status_desc)->status_desc_data >> 4) & 0x0F)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 4) & 0x0F)
 #define netxen_get_sts_type(status_desc)	\
-	(((status_desc)->status_desc_data >> 8) & 0x0F)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 8) & 0x0F)
 #define netxen_get_sts_totallength(status_desc)	\
-	(((status_desc)->status_desc_data >> 12) & 0xFFFF)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 12) & 0xFFFF)
 #define netxen_get_sts_refhandle(status_desc)	\
-	(((status_desc)->status_desc_data >> 28) & 0xFFFF)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 28) & 0xFFFF)
 #define netxen_get_sts_prot(status_desc)	\
-	(((status_desc)->status_desc_data >> 44) & 0x0F)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 44) & 0x0F)
 #define netxen_get_sts_owner(status_desc)	\
-	(((status_desc)->status_desc_data >> 56) & 0x03)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 56) & 0x03)
 #define netxen_get_sts_opcode(status_desc)	\
-	(((status_desc)->status_desc_data >> 58) & 0x03F)
+	((le64_to_cpu((status_desc)->status_desc_data) >> 58) & 0x03F)
 
 #define netxen_clear_sts_owner(status_desc)	\
 	((status_desc)->status_desc_data &=	\
-	~(((unsigned long long)3) << 56 ))
+	~(cpu_to_le64(((unsigned long long)3) << 56 )))
 #define netxen_set_sts_owner(status_desc, val)	\
 	((status_desc)->status_desc_data |=	\
-	(((unsigned long long)((val) & 0x3)) << 56 ))
+	(cpu_to_le64(((unsigned long long)((val) & 0x3)) << 56 )))
 
 struct status_desc {
 	/* Bit pattern: 0-3 port, 4-7 status, 8-11 type, 12-27 total_length
 	   28-43 reference_handle, 44-47 protocol, 48-52 unused
 	   53-55 desc_cnt, 56-57 owner, 58-63 opcode
 	 */
-	u64 status_desc_data;
-	u32 hash_value;
+	__le64 status_desc_data;
+	__le32 hash_value;
 	u8 hash_type;
 	u8 msg_type;
 	u8 unused;
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 191e233..962fc49 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -236,8 +236,9 @@ int netxen_nic_hw_resources(struct netxe
 	}
 	memset(addr, 0, sizeof(struct netxen_ring_ctx));
 	adapter->ctx_desc = (struct netxen_ring_ctx *)addr;
-	adapter->ctx_desc->cmd_consumer_offset = adapter->ctx_desc_phys_addr
-	    + sizeof(struct netxen_ring_ctx);
+	adapter->ctx_desc->cmd_consumer_offset =
+	    cpu_to_le64(adapter->ctx_desc_phys_addr
+			+ sizeof(struct netxen_ring_ctx));
 	adapter->cmd_consumer = (uint32_t *) (((char *)addr) +
 					      sizeof(struct netxen_ring_ctx));
 
@@ -254,10 +255,11 @@ int netxen_nic_hw_resources(struct netxe
 	}
 
 	adapter->ctx_desc->cmd_ring_addr_lo =
-	    hw->cmd_desc_phys_addr & 0xffffffffUL;
+	    cpu_to_le32(hw->cmd_desc_phys_addr & 0xffffffffUL);
 	adapter->ctx_desc->cmd_ring_addr_hi =
-	    ((u64) hw->cmd_desc_phys_addr >> 32);
-	adapter->ctx_desc->cmd_ring_size = adapter->max_tx_desc_count;
+	    cpu_to_le32((u64) hw->cmd_desc_phys_addr >> 32);
+	adapter->ctx_desc->cmd_ring_size =
+	    cpu_to_le32(adapter->max_tx_desc_count);
 
 	hw->cmd_desc_head = (struct cmd_desc_type0 *)addr;
 
@@ -279,11 +281,11 @@ int netxen_nic_hw_resources(struct netxe
 			}
 			rcv_desc->desc_head = (struct rcv_desc *)addr;
 			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr_lo =
-			    rcv_desc->phys_addr & 0xffffffffUL;
+			    cpu_to_le32(rcv_desc->phys_addr & 0xffffffffUL);
 			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr_hi =
-			    ((u64) rcv_desc->phys_addr >> 32);
+			    cpu_to_le32((u64) rcv_desc->phys_addr >> 32);
 			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_size =
-			    rcv_desc->max_rx_desc_count;
+			    cpu_to_le32(rcv_desc->max_rx_desc_count);
 		}
 
 		addr = netxen_alloc(adapter->ahw.pdev, STATUS_DESC_RINGSIZE,
@@ -298,10 +300,11 @@ int netxen_nic_hw_resources(struct netxe
 		}
 		recv_ctx->rcv_status_desc_head = (struct status_desc *)addr;
 		adapter->ctx_desc->sts_ring_addr_lo =
-		    recv_ctx->rcv_status_desc_phys_addr & 0xffffffffUL;
+		    cpu_to_le32(recv_ctx->rcv_status_desc_phys_addr & 0xffffffffUL);
 		adapter->ctx_desc->sts_ring_addr_hi =
-		    ((u64) recv_ctx->rcv_status_desc_phys_addr >> 32);
-		adapter->ctx_desc->sts_ring_size = adapter->max_rx_desc_count;
+		    cpu_to_le32((u64) recv_ctx->rcv_status_desc_phys_addr >> 32);
+		adapter->ctx_desc->sts_ring_size =
+		    cpu_to_le32(adapter->max_rx_desc_count);
 
 	}
 	/* Window = 1 */
@@ -387,10 +390,6 @@ void netxen_tso_check(struct netxen_adap
 	}
 	adapter->stats.xmitcsummed++;
 	desc->tcp_hdr_offset = skb->h.raw - skb->data;
-	netxen_set_cmd_desc_totallength(desc,
-					cpu_to_le32
-					(netxen_get_cmd_desc_totallength
-					 (desc)));
 	desc->ip_hdr_offset = skb->nh.raw - skb->data;
 }
 
@@ -427,6 +426,7 @@ static int netxen_get_flash_block(struct
 	for (i = 0; i < size / sizeof(u32); i++) {
 		if (netxen_rom_fast_read(adapter, addr, ptr32) == -1)
 			return -1;
+		*ptr32 = cpu_to_le32(*ptr32);
 		ptr32++;
 		addr += sizeof(u32);
 	}
@@ -435,6 +435,7 @@ static int netxen_get_flash_block(struct
 
 		if (netxen_rom_fast_read(adapter, addr, &local) == -1)
 			return -1;
+		local = cpu_to_le32(local);
 		memcpy(ptr32, &local, (char *)buf + size - (char *)ptr32);
 	}
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index c3e41f3..ec1c736 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -690,8 +690,7 @@ int netxen_nic_rx_has_work(struct netxen
 		desc_head = recv_ctx->rcv_status_desc_head;
 		desc = &desc_head[consumer];
 
-		if (((le16_to_cpu(netxen_get_sts_owner(desc)))
-		     & STATUS_OWNER_HOST))
+		if (netxen_get_sts_owner(desc) & STATUS_OWNER_HOST)
 			return 1;
 	}
 
@@ -787,11 +786,11 @@ netxen_process_rcv(struct netxen_adapter
 	struct netxen_port *port = adapter->port[netxen_get_sts_port(desc)];
 	struct pci_dev *pdev = port->pdev;
 	struct net_device *netdev = port->netdev;
-	int index = le16_to_cpu(netxen_get_sts_refhandle(desc));
+	int index = netxen_get_sts_refhandle(desc);
 	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
 	struct netxen_rx_buffer *buffer;
 	struct sk_buff *skb;
-	u32 length = le16_to_cpu(netxen_get_sts_totallength(desc));
+	u32 length = netxen_get_sts_totallength(desc);
 	u32 desc_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
 	int ret;
@@ -919,7 +918,7 @@ u32 netxen_process_rcv_ring(struct netxe
 	while (count < max) {
 		desc = &desc_head[consumer];
 		if (!
-		    (le16_to_cpu(netxen_get_sts_owner(desc)) &
+		    (netxen_get_sts_owner(desc) &
 		     STATUS_OWNER_HOST)) {
 			DPRINTK(ERR, "desc %p ownedby %x\n", desc,
 				netxen_get_sts_owner(desc));
@@ -927,7 +926,7 @@ u32 netxen_process_rcv_ring(struct netxe
 		}
 		netxen_process_rcv(adapter, ctxid, desc);
 		netxen_clear_sts_owner(desc);
-		netxen_set_sts_owner(desc, cpu_to_le16(STATUS_OWNER_PHANTOM));
+		netxen_set_sts_owner(desc, STATUS_OWNER_PHANTOM);
 		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
 		count++;
 	}
@@ -980,7 +979,7 @@ int netxen_process_cmd_ring(unsigned lon
 	 * the netdev which is associated with that device.
 	 */
 
-	consumer = *(adapter->cmd_consumer);
+	consumer = le32_to_cpu(*(adapter->cmd_consumer));
 	if (last_consumer == consumer) {	/* Ring is empty    */
 		DPRINTK(INFO, "last_consumer %d == consumer %d\n",
 			last_consumer, consumer);
@@ -1074,8 +1073,9 @@ int netxen_process_cmd_ring(unsigned lon
 	if (adapter->last_cmd_consumer == consumer &&
 	    (((adapter->cmd_producer + 1) %
 	      adapter->max_tx_desc_count) == adapter->last_cmd_consumer)) {
-		consumer = *(adapter->cmd_consumer);
+		consumer = le32_to_cpu(*(adapter->cmd_consumer));
 	}
+
 	done = (adapter->last_cmd_consumer == consumer);
 
 	spin_unlock(&adapter->tx_lock);
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 96e1bee..6c424d1 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -435,11 +435,13 @@ #endif
 		adapter->port[i] = port;
 	}
 
+#ifndef CONFIG_PPC64
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
 	netxen_pinit_from_rom(adapter, 0);
 	udelay(500);
 	netxen_load_firmware(adapter);
 	netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
+#endif
 	/*
 	 * delay a while to ensure that the Pegs are up & running.
 	 * Otherwise, we might see some flaky behaviour.
@@ -818,7 +820,7 @@ static int netxen_nic_xmit_frame(struct 
 	/* Take skb->data itself */
 	pbuf = &adapter->cmd_buf_arr[producer];
 	if ((netdev->features & NETIF_F_TSO) && skb_shinfo(skb)->gso_size > 0) {
-		pbuf->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
+		pbuf->mss = skb_shinfo(skb)->gso_size;
 		hwdesc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
 	} else {
 		pbuf->mss = 0;
@@ -882,7 +884,7 @@ static int netxen_nic_xmit_frame(struct 
 			hwdesc->addr_buffer3 = cpu_to_le64(temp_dma);
 			break;
 		case 3:
-			hwdesc->buffer4_length = temp_len;
+			hwdesc->buffer4_length = cpu_to_le16(temp_len);
 			hwdesc->addr_buffer4 = cpu_to_le64(temp_dma);
 			break;
 		}
@@ -935,6 +937,7 @@ static int netxen_nic_xmit_frame(struct 
 		u32 crb_producer = adapter->cmd_producer;
 		writel(crb_producer,
 		       NETXEN_CRB_NORMALIZE(adapter, CRB_CMD_PRODUCER_OFFSET));
+
 		wmb();
 		adapter->total_threads = 0;
 	}
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 4987dc7..e6defe6 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -458,7 +458,7 @@ int netxen_niu_gbe_init_port(struct netx
 
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 {
-	long reg = 0, ret = 0;
+	u32 reg = 0, ret = 0;
 
 	if (adapter->ahw.boardcfg.board_type == NETXEN_BRDTYPE_P2_SB31_10G_IMEZ) {
 		netxen_crb_writelit_adapter(adapter,
