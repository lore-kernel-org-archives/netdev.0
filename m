From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 2/2] NetXen: Updates for register access routines
Date: Wed, 2 May 2007 08:18:05 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0705020815260.3154@dut46>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netxenproj@linsyssoft.com, Jeff Garzik <jeff@garzik.org>,
	rob@netxen.com
To: netdev mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:26661 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S2993341AbXEBPSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 11:18:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Changes related to registers and their access routines
This patch updates the various access routines to access different 
control and status settings present in different register locations.
This will fix problems related to working of different ports in 
multi Port card.

Signed-off by: Milan Bag <mbag@netxen.com>
Signed-off by: Adhiraj Joshi <adhiraj@netxen.com>
Acked-by: Mithlesh Thukral <mithlesh@netxen.com>

---

  drivers/net/netxen/netxen_nic.h      |  100 ++++++++++---------------
  drivers/net/netxen/netxen_nic_hw.h   |   65 +++-------------
  drivers/net/netxen/netxen_nic_init.c |   17 ++--
  3 files changed, 67 insertions(+), 115 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index ad6688e..71edb5c 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -302,29 +302,28 @@ #define FLAGS_IPSEC_SA_ADD	0x04
  #define FLAGS_IPSEC_SA_DELETE	0x08
  #define FLAGS_VLAN_TAGGED	0x10

-#define netxen_set_cmd_desc_port(cmd_desc, var)	\
-	((cmd_desc)->port_ctxid |= ((var) & 0x0F))
-#define netxen_set_cmd_desc_ctxid(cmd_desc, var)	\
-	((cmd_desc)->port_ctxid |= ((var) & 0xF0))
-
-#define netxen_set_cmd_desc_flags(cmd_desc, val)	\
-	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x7f), \
-	(cmd_desc)->flags_opcode |= cpu_to_le16((val) & 0x7f))
+#define netxen_set_cmd_desc_port(cmd_desc, val)	\
+	((cmd_desc)->port_ctxid &= ~(0xf<<0),	\
+	(cmd_desc)->port_ctxid |= (val & 0xf) << 0)
+#define netxen_set_cmd_desc_ctxid(cmd_desc, val)	\
+	((cmd_desc)->port_ctxid &= ~(0xf<<4),		\
+	(cmd_desc)->port_ctxid |= (val & 0xf) << 4)
+
  #define netxen_set_cmd_desc_opcode(cmd_desc, val)	\
-	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x3f<<7), \
-	(cmd_desc)->flags_opcode |= cpu_to_le16(((val & 0x3f)<<7)))
+	((cmd_desc)->flags_opcode &= ~(0x3f<<7),        \
+	(cmd_desc)->flags_opcode |= (val & 0x3f)<<7)

-#define netxen_set_cmd_desc_num_of_buff(cmd_desc, val)	\
-	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xff), \
-	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32((val) & 0xff))
-#define netxen_set_cmd_desc_totallength(cmd_desc, val)	\
-	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xffffff00), \
-	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32(val << 8))
+#define netxen_set_cmd_desc_num_of_buff(cmd_desc, val)                 \
+	((cmd_desc)->num_of_buffers_total_length &= ~(0xff<<0),         \
+	(cmd_desc)->num_of_buffers_total_length |= (val & 0xff)<<0)
+#define netxen_set_cmd_desc_totallength(cmd_desc, val)                 \
+	((cmd_desc)->num_of_buffers_total_length &= ~(0xffffff<<8),     \
+	(cmd_desc)->num_of_buffers_total_length |= (val & 0xffffff) <<8)

  #define netxen_get_cmd_desc_opcode(cmd_desc)	\
-	((le16_to_cpu((cmd_desc)->flags_opcode) >> 7) & 0x003F)
+	(((cmd_desc)->flags_opcode >> 7) & 0x003F)
  #define netxen_get_cmd_desc_totallength(cmd_desc)	\
-	(le32_to_cpu((cmd_desc)->num_of_buffers_total_length) >> 8)
+	(((cmd_desc)->num_of_buffers_total_length >> 8) & 0x0FFFFFF)

  struct cmd_desc_type0 {
  	u8 tcp_hdr_offset;	/* For LSO only */
@@ -344,7 +343,7 @@ struct cmd_desc_type0 {

  	__le16 reference_handle;	/* changed to u16 to add mss */
  	__le16 mss;		/* passed by NDIS_PACKET for LSO */
-	/* Bit pattern 0-3 port, 0-3 ctx id */
+	/* Bit pattern 0-3 port, 4-7 ctx id */
  	u8 port_ctxid;
  	u8 total_hdr_length;	/* LSO only : MAC+IP+TCP Hdr size */
  	__le16 conn_id;		/* IPSec offoad only */
@@ -406,34 +405,31 @@ #define NETXEN_PROT_UNKNOWN	(0)

  /* Note: sizeof(status_desc) should always be a mutliple of 2 */

-#define netxen_get_sts_desc_lro_cnt(status_desc)	\
-	((status_desc)->lro & 0x7F)
-#define netxen_get_sts_desc_lro_last_frag(status_desc)	\
-	(((status_desc)->lro & 0x80) >> 7)
-
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
+#define netxen_get_sts_desc_lro_cnt(status_desc)        \
+	(((status_desc)->lro) & 0x7F)
+#define netxen_get_sts_desc_lro_last_frag(status_desc)  \
+	((((status_desc)->lro) >> 7) & 0x1)
+
+#define netxen_get_sts_status(status_desc)      \
+	(((status_desc) >> 4) & 0x0F)
+#define netxen_get_sts_type(status_desc)        \
+	(((status_desc) >> 8) & 0x0F)
+#define netxen_get_sts_totallength(status_desc) \
+	(((status_desc) >> 12) & 0xFFFF)
+#define netxen_get_sts_refhandle(status_desc)   \
+	(((status_desc) >> 28) & 0xFFFF)
+
  #define netxen_get_sts_prot(status_desc)	\
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
+(((status_desc) >> 44) & 0x0F)
+#define netxen_get_sts_owner(status_desc)       \
+(((status_desc) >> 56) & 0x03)
+
+#define netxen_set_sts_owner(status_desc, val) {        \
+	u64 value = le64_to_cpu((status_desc)->status_desc_data);      \
+	value &= ~(0x3ULL << 56);                                       \
+	value |= (u64)(((u64)(val) << 56) & (0x3ULL << 56));            \
+	(status_desc)->status_desc_data = cpu_to_le64(value);          \
+}

  struct status_desc {
  	/* Bit pattern: 0-3 port, 4-7 status, 8-11 type, 12-27 total_length
@@ -726,18 +722,6 @@ struct netxen_skb_frag {
  	u32 length;
  };

-#define _netxen_set_bits(config_word, start, bits, val)	{\
-	unsigned long long __tmask = (((1ULL << (bits)) - 1) << (start));\
-	unsigned long long __tvalue = (val);    \
-	(config_word) &= ~__tmask;      \
-	(config_word) |= (((__tvalue) << (start)) & __tmask); \
-}
- 
-#define _netxen_clear_bits(config_word, start, bits) {\
-	unsigned long long __tmask = (((1ULL << (bits)) - 1) << (start));  \
-	(config_word) &= ~__tmask; \
-} 
-
  /*    Following defines are for the state of the buffers    */
  #define	NETXEN_BUFFER_FREE	0
  #define	NETXEN_BUFFER_BUSY	1
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 245bf13..6fd9329 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -181,9 +181,9 @@ #define netxen_gb_set_checklength(config
  #define netxen_gb_set_hugeframes(config_word)	\
  		((config_word) |= 1 << 5)
  #define netxen_gb_set_preamblelen(config_word, val)	\
-		((config_word) |= ((val) << 12) & 0xF000)
+		((config_word) &= ~(0xf<<12), (config_word) |= (val & 0xf)<< 12)
  #define netxen_gb_set_intfmode(config_word, val)		\
-		((config_word) |= ((val) << 8) & 0x300)
+		((config_word) &= ~(0xf<<8), (config_word) |= (val & 0x3) << 8)

  #define netxen_gb_get_stationaddress_low(config_word) ((config_word) >> 16)

@@ -191,8 +191,6 @@ #define netxen_gb_set_mii_mgmt_clocksele
  		((config_word) |= ((val) & 0x07))
  #define netxen_gb_mii_mgmt_reset(config_word)	\
  		((config_word) |= 1 << 31)
-#define netxen_gb_mii_mgmt_unset(config_word)	\
-		((config_word) &= ~(1 << 31))

  /*
   * NIU GB MII Mgmt Command Register (applies to GB0, GB1, GB2, GB3)
@@ -203,9 +201,9 @@ #define netxen_gb_mii_mgmt_unset(config_
  #define netxen_gb_mii_mgmt_set_read_cycle(config_word)	\
  		((config_word) |= 1 << 0)
  #define netxen_gb_mii_mgmt_reg_addr(config_word, val)	\
-		((config_word) |= ((val) & 0x1F))
+		((config_word) &= ~(0x1f<<0), (config_word) |= (val & 0x1f)<< 0)
  #define netxen_gb_mii_mgmt_phy_addr(config_word, val)	\
-		((config_word) |= (((val) & 0x1F) << 8))
+		((config_word) &= ~(0x1f<<8), (config_word) |= (val & 0x1f)<< 8)

  /*
   * NIU GB MII Mgmt Indicators Register (applies to GB0, GB1, GB2, GB3)
@@ -247,15 +245,18 @@ #define netxen_xg_unset_xg1_mask(config_
  	((config_word) &= ~(1 << 3))

  /*
- * NIU XG Pause Ctl Register
+ * NIU GBe Pause Ctl Register
   *
- *      Bit 0       : xg0_mask => 1:disable tx pause frames
- *      Bit 1       : xg0_request => 1:request single pause frame
- *      Bit 2       : xg0_on_off => 1:request is pause on, 0:off
- *      Bit 3       : xg1_mask => 1:disable tx pause frames
- *      Bit 4       : xg1_request => 1:request single pause frame
- *      Bit 5       : xg1_on_off => 1:request is pause on, 0:off
+ *      Bit 0       : gb0_mask => 1:disable tx pause frames
+ *      Bit 1       : gb0_pause_req => 1:send pause on, 0:send pause off
+ *      Bit 2       : gb1_mask => 1:disable tx pause frames
+ *      Bit 3       : gb1_pause_req:1 => 1:send pause on, 0:send pause off
+ *      Bit 4       : gb2_mask => 1:disable tx pause frames
+ *      Bit 5       : gb2_pause_req => 1:send pause on, 0:send pause off
+ *      Bit 6       : gb3_mask => 1:disable tx pause frames
+ *      Bit 7       : gb3_pause_req => 1:send pause on, 0:send pause off
   */
+
  #define netxen_gb_set_gb0_mask(config_word)    \
  	((config_word) |= 1 << 0)
  #define netxen_gb_set_gb1_mask(config_word)    \
@@ -335,7 +336,7 @@ #define netxen_get_phy_cablelen(config_w
  #define netxen_get_phy_speed(config_word) (((config_word) >> 14) & 0x03)

  #define netxen_set_phy_speed(config_word, val)	\
-		((config_word) |= ((val & 0x03) << 14))
+		((config_word) &= ~(0x3<<14), (config_word) |= (val & 0x3)<< 14)
  #define netxen_set_phy_duplex(config_word)	\
  		((config_word) |= 1 << 13)
  #define netxen_clear_phy_duplex(config_word)	\
@@ -478,42 +479,6 @@ #define netxen_clear_gb_drop_gb3(config_
  #define netxen_xg_soft_reset(config_word)	\
  		((config_word) |= 1 << 4)

-/*
- * MAC Control Register
- * 
- * Bit 0-1   : id_pool0
- * Bit 2     : enable_xtnd0
- * Bit 4-5   : id_pool1
- * Bit 6     : enable_xtnd1
- * Bit 8-9   : id_pool2
- * Bit 10    : enable_xtnd2
- * Bit 12-13 : id_pool3
- * Bit 14    : enable_xtnd3
- * Bit 24-25 : mode_select
- * Bit 28-31 : enable_pool
- */
-
-#define netxen_nic_mcr_set_id_pool0(config, val)	\
-		((config) |= ((val) &0x03))
-#define netxen_nic_mcr_set_enable_xtnd0(config)	\
-		((config) |= 1 << 3)
-#define netxen_nic_mcr_set_id_pool1(config, val)	\
-		((config) |= (((val) & 0x03) << 4))
-#define netxen_nic_mcr_set_enable_xtnd1(config)	\
-		((config) |= 1 << 6)
-#define netxen_nic_mcr_set_id_pool2(config, val)	\
-		((config) |= (((val) & 0x03) << 8))
-#define netxen_nic_mcr_set_enable_xtnd2(config)	\
-		((config) |= 1 << 10)
-#define netxen_nic_mcr_set_id_pool3(config, val)	\
-		((config) |= (((val) & 0x03) << 12))
-#define netxen_nic_mcr_set_enable_xtnd3(config)	\
-		((config) |= 1 << 14)
-#define netxen_nic_mcr_set_mode_select(config, val)	\
-		((config) |= (((val) & 0x03) << 24))
-#define netxen_nic_mcr_set_enable_pool(config, val)	\
-		((config) |= (((val) & 0x0f) << 28))
-
  /* Set promiscuous mode for a GbE interface */
  int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
  				    netxen_niu_prom_mode_t mode);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index a368924..2a6d225 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -980,7 +980,8 @@ int netxen_nic_rx_has_work(struct netxen
  		desc_head = recv_ctx->rcv_status_desc_head;
  		desc = &desc_head[consumer];

-		if (netxen_get_sts_owner(desc) & STATUS_OWNER_HOST)
+		if ((netxen_get_sts_owner(le64_to_cpu(desc->status_desc_data)))
+				& STATUS_OWNER_HOST)
  			return 1;
  	}

@@ -1060,18 +1061,19 @@ void
  netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
  		   struct status_desc *desc)
  {
+	u64 status_desc = le64_to_cpu(desc->status_desc_data);
  	struct pci_dev *pdev = adapter->pdev;
  	struct net_device *netdev = adapter->netdev;
-	int index = netxen_get_sts_refhandle(desc);
+	int index = netxen_get_sts_refhandle(status_desc);
  	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
  	struct netxen_rx_buffer *buffer;
  	struct sk_buff *skb;
-	u32 length = netxen_get_sts_totallength(desc);
+	u32 length = netxen_get_sts_totallength(status_desc);
  	u32 desc_ctx;
  	struct netxen_rcv_desc_ctx *rcv_desc;
  	int ret;

-	desc_ctx = netxen_get_sts_type(desc);
+	desc_ctx = netxen_get_sts_type(status_desc);
  	if (unlikely(desc_ctx >= NUM_RCV_DESC_RINGS)) {
  		printk("%s: %s Bad Rcv descriptor ring\n",
  		       netxen_nic_driver_name, netdev->name);
@@ -1110,7 +1112,7 @@ netxen_process_rcv(struct netxen_adapter

  	skb = (struct sk_buff *)buffer->skb;

-	if (likely(netxen_get_sts_status(desc) == STATUS_CKSUM_OK)) {
+	if (likely(netxen_get_sts_status(status_desc) == STATUS_CKSUM_OK)) {
  		adapter->stats.csummed++;
  		skb->ip_summed = CHECKSUM_UNNECESSARY;
  	}
@@ -1191,13 +1193,14 @@ u32 netxen_process_rcv_ring(struct netxe
  	 */
  	while (count < max) {
  		desc = &desc_head[consumer];
-		if (!(netxen_get_sts_owner(desc) & STATUS_OWNER_HOST)) {
+		if (!
+		   ((netxen_get_sts_owner(le64_to_cpu(desc->status_desc_data)))
+			   & STATUS_OWNER_HOST)) {
  			DPRINTK(ERR, "desc %p ownedby %x\n", desc,
  				netxen_get_sts_owner(desc));
  			break;
  		}
  		netxen_process_rcv(adapter, ctxid, desc);
-		netxen_clear_sts_owner(desc);
  		netxen_set_sts_owner(desc, STATUS_OWNER_PHANTOM);
  		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
  		count++;
