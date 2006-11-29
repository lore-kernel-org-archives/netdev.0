From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 4/4] NetXen: multiport firmware support
Date: Wed, 29 Nov 2006 09:03:31 -0800
Message-ID: <200611291703.kATH3VQY023244@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:17475 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S967479AbWK2RDc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 12:03:32 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: 1G/10G Ethernet Driver updates
	- Multiport and newer firmware support
	- ioctl interface for user level tools

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

 b/drivers/net/netxen/netxen_nic.h          |  325 +++++++++++++++-----
 b/drivers/net/netxen/netxen_nic_ethtool.c  |   20 -
 b/drivers/net/netxen/netxen_nic_hw.c       |  455 +++++++++++++++++++++++------
 b/drivers/net/netxen/netxen_nic_init.c     |  375 +++++++++++++++++++----
 b/drivers/net/netxen/netxen_nic_isr.c      |   34 --
 b/drivers/net/netxen/netxen_nic_main.c     |  275 ++++++++++-------
 b/drivers/net/netxen/netxen_nic_phan_reg.h |  228 +++++++++-----
 drivers/net/netxen/netxen_nic_ioctl.h      |    2 
 drivers/net/netxen/netxen_nic_niu.c        |    4 
 9 files changed, 1246 insertions(+), 472 deletions(-)


diff -u b/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
--- b/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -63,27 +63,49 @@
 
 #include "netxen_nic_hw.h"
 
-#define NETXEN_NIC_BUILD_NO     "5"
-#define _NETXEN_NIC_LINUX_MAJOR 2
+#define NETXEN_NIC_BUILD_NO     "1"
+#define _NETXEN_NIC_LINUX_MAJOR 3
 #define _NETXEN_NIC_LINUX_MINOR 3
-#define _NETXEN_NIC_LINUX_SUBVERSION 59
-#define NETXEN_NIC_LINUX_VERSIONID  "2.3.59" "-" NETXEN_NIC_BUILD_NO
-#define NETXEN_NIC_FW_VERSIONID "2.3.59"
+#define _NETXEN_NIC_LINUX_SUBVERSION 2
+#define NETXEN_NIC_LINUX_VERSIONID  "3.3.2" "-" NETXEN_NIC_BUILD_NO
+#define NETXEN_NIC_FW_VERSIONID "3.3.2"
 
 #define RCV_DESC_RINGSIZE	\
 	(sizeof(struct rcv_desc) * adapter->max_rx_desc_count)
 #define STATUS_DESC_RINGSIZE	\
 	(sizeof(struct status_desc)* adapter->max_rx_desc_count)
+#define LRO_DESC_RINGSIZE	\
+	(sizeof(rcvDesc_t) * adapter->max_lro_rx_desc_count)
 #define TX_RINGSIZE	\
 	(sizeof(struct netxen_cmd_buffer) * adapter->max_tx_desc_count)
 #define RCV_BUFFSIZE	\
 	(sizeof(struct netxen_rx_buffer) * rcv_desc->max_rx_desc_count)
 #define find_diff_among(a,b,range) ((a)<(b)?((b)-(a)):((b)+(range)-(a)))
 
-#define NETXEN_NETDEV_STATUS 0x1
+#define NETXEN_NETDEV_STATUS		0x1
+#define NETXEN_RCV_PRODUCER_OFFSET	0
+#define NETXEN_RCV_PEG_DB_ID		2
+#define NETXEN_HOST_DUMMY_DMA_SIZE 1024
 
 #define ADDR_IN_WINDOW1(off)	\
 	((off > NETXEN_CRB_PCIX_HOST2) && (off < NETXEN_CRB_MAX)) ? 1 : 0
+/*
+ * In netxen_nic_down(), we must wait for any pending callback requests into
+ * netxen_watchdog_task() to complete; eg otherwise the watchdog_timer could be
+ * reenabled right after it is deleted in netxen_nic_down(). FLUSH_SCHEDULED_WORK()
+ * does this synchronization.
+ *
+ * Normally, schedule_work()/flush_scheduled_work() could have worked, but
+ * netxen_nic_close() is invoked with kernel rtnl lock held. netif_carrier_off()
+ * call in netxen_nic_close() triggers a schedule_work(&linkwatch_work), and a
+ * subsequent call to flush_scheduled_work() in netxen_nic_down() would cause
+ * linkwatch_event() to be executed which also attempts to acquire the rtnl
+ * lock thus causing a deadlock.
+ */
+
+#define SCHEDULE_WORK(tp)	queue_work(netxen_workq, tp)
+#define FLUSH_SCHEDULED_WORK()	flush_workqueue(netxen_workq)
+extern struct workqueue_struct *netxen_workq;
 
 /* 
  * normalize a 64MB crb address to 32MB PCI window 
@@ -95,8 +117,17 @@
 #define NETXEN_CRB_NORMALIZE(adapter, reg) \
 	pci_base_offset(adapter, NETXEN_CRB_NORMAL(reg))
 
+#define DB_NORMALIZE(adapter, off) \
+	(adapter->ahw.db_base + (off))
+
+#define PCI_DMA_64BIT	0xffffffffffffffffULL
+#define PCI_DMA_32BIT	0x00000000ffffffffULL
+
+#define NX_P2_C0		0x24
+#define NX_P2_C1		0x25
+
 #define FIRST_PAGE_GROUP_START	0
-#define FIRST_PAGE_GROUP_END	0x400000
+#define FIRST_PAGE_GROUP_END	0x100000
 
 #define SECOND_PAGE_GROUP_START	0x4000000
 #define SECOND_PAGE_GROUP_END	0x66BC000
@@ -108,11 +139,13 @@
 #define SECOND_PAGE_GROUP_SIZE SECOND_PAGE_GROUP_END - SECOND_PAGE_GROUP_START
 #define THIRD_PAGE_GROUP_SIZE  THIRD_PAGE_GROUP_END - THIRD_PAGE_GROUP_START
 
-#define MAX_RX_BUFFER_LENGTH		2000
+#define MAX_RX_BUFFER_LENGTH		1760
 #define MAX_RX_JUMBO_BUFFER_LENGTH 	9046
-#define RX_DMA_MAP_LEN			(MAX_RX_BUFFER_LENGTH - NET_IP_ALIGN)
+#define MAX_RX_LRO_BUFFER_LENGTH	((48*1024)-512)
+#define RX_DMA_MAP_LEN			(MAX_RX_BUFFER_LENGTH - 2)
 #define RX_JUMBO_DMA_MAP_LEN	\
-	(MAX_RX_JUMBO_BUFFER_LENGTH - NET_IP_ALIGN)
+	(MAX_RX_JUMBO_BUFFER_LENGTH - 2)
+#define RX_LRO_DMA_MAP_LEN		(MAX_RX_LRO_BUFFER_LENGTH - 2)
 #define NETXEN_ROM_ROUNDUP		0x80000000ULL
 
 /*
@@ -151,30 +184,38 @@
 /* Host writes the following to notify that it has done the init-handshake */
 #define PHAN_INITIALIZE_ACK	0xf00f
 
-#define NUM_RCV_DESC_RINGS	2	/* No of Rcv Descriptor contexts */
+#define NUM_RCV_DESC_RINGS	3	/* No of Rcv Descriptor contexts */
 
 /* descriptor types */
 #define RCV_DESC_NORMAL		0x01
 #define RCV_DESC_JUMBO		0x02
+#define RCV_DESC_LRO		0x04
 #define RCV_DESC_NORMAL_CTXID	0
 #define RCV_DESC_JUMBO_CTXID	1
+#define RCV_DESC_LRO_CTXID	2
 
 #define RCV_DESC_TYPE(ID) \
-	((ID == RCV_DESC_JUMBO_CTXID) ? RCV_DESC_JUMBO : RCV_DESC_NORMAL)
+	((ID == RCV_DESC_JUMBO_CTXID)	\
+		? RCV_DESC_JUMBO	\
+		: ((ID == RCV_DESC_LRO_CTXID)	\
+			? RCV_DESC_LRO :	\
+			(RCV_DESC_NORMAL)))
 
 #define MAX_CMD_DESCRIPTORS		1024
 #define MAX_RCV_DESCRIPTORS		32768
 #define MAX_JUMBO_RCV_DESCRIPTORS	4096
+#define MAX_LRO_RCV_DESCRIPTORS		2048
 #define MAX_RCVSTATUS_DESCRIPTORS	MAX_RCV_DESCRIPTORS
 #define MAX_JUMBO_RCV_DESC	MAX_JUMBO_RCV_DESCRIPTORS
 #define MAX_RCV_DESC		MAX_RCV_DESCRIPTORS
 #define MAX_RCVSTATUS_DESC	MAX_RCV_DESCRIPTORS
-#define NUM_RCV_DESC		(MAX_RCV_DESC + MAX_JUMBO_RCV_DESCRIPTORS)
 #define MAX_EPG_DESCRIPTORS	(MAX_CMD_DESCRIPTORS * 8)
-
+#define NUM_RCV_DESC		(MAX_RCV_DESC + MAX_JUMBO_RCV_DESCRIPTORS + \
+				 MAX_LRO_RCV_DESCRIPTORS)
 #define MIN_TX_COUNT	4096
 #define MIN_RX_COUNT	4096
-
+#define NETXEN_CTX_SIGNATURE	0xdee0
+#define NETXEN_RCV_PRODUCER(ringid)	(ringid)
 #define MAX_FRAME_SIZE	0x10000	/* 64K MAX size for LSO */
 
 #define PHAN_PEG_RCV_INITIALIZED	0xff01
@@ -186,6 +227,69 @@
 #define get_index_range(index,length,count)	\
 	(((index) + (count)) & ((length) - 1))
 
+#define MPORT_SINGLE_FUNCTION_MODE 0x1111
+
+extern unsigned long long netxen_dma_mask;
+
+/*
+ * NetXen host-peg signal message structure
+ *
+ *	Bit 0-1		: peg_id => 0x2 for tx and 01 for rx
+ *	Bit 2		: priv_id => must be 1
+ *	Bit 3-17	: count => for doorbell
+ *	Bit 18-27	: ctx_id => Context id
+ *	Bit 28-31	: opcode
+ */
+
+typedef u32 netxen_ctx_msg;
+
+#define _netxen_set_bits(config_word, start, bits, val)	{\
+	unsigned long long mask = (((1ULL << (bits)) - 1) << (start));	\
+	unsigned long long value = (val);	\
+	(config_word) &= ~mask;	\
+	(config_word) |= (((value) << (start)) & mask); \
+}
+
+#define netxen_set_msg_peg_id(config_word, val)	\
+	_netxen_set_bits(config_word, 0, 2, val)
+#define netxen_set_msg_privid(config_word)	\
+	set_bit(2, (unsigned long*)&config_word)
+#define netxen_set_msg_count(config_word, val)	\
+	_netxen_set_bits(config_word, 3, 15, val)
+#define netxen_set_msg_ctxid(config_word, val)	\
+	_netxen_set_bits(config_word, 18, 10, val)
+#define netxen_set_msg_opcode(config_word, val)	\
+	_netxen_set_bits(config_word, 28, 4, val)
+
+struct netxen_rcv_context
+{
+	u32	 rcv_ring_addr_lo;
+	u32	 rcv_ring_addr_hi;
+	u32	 rcv_ring_size;
+	u32	 rsrvd;
+};
+
+struct netxen_ring_ctx
+{
+
+	/* one command ring */
+	u64	 cmd_consumer_offset;
+	u32	 cmd_ring_addr_lo;
+	u32	 cmd_ring_addr_hi;
+	u32	 cmd_ring_size;
+	u32	 rsrvd;
+
+	/* three receive rings */
+	struct netxen_rcv_context	 rcv_ctx[3];
+
+	/* one status ring */
+	u32	 sts_ring_addr_lo;
+	u32	 sts_ring_addr_hi;
+	u32	 sts_ring_size;
+
+	u32	 ctx_id;
+} __attribute__ ((aligned(64)));
+
 /*
  * Following data structures describe the descriptors that will be used.
  * Added fileds of tcpHdrSize and ipHdrSize, The driver needs to do it only when
@@ -203,22 +307,32 @@
 #define FLAGS_IPSEC_SA_DELETE	0x08
 #define FLAGS_VLAN_TAGGED	0x10
 
-#define CMD_DESC_TOTAL_LENGTH(cmd_desc)	\
-		((cmd_desc)->length_tcp_hdr & 0x00FFFFFF)
-#define CMD_DESC_TCP_HDR_OFFSET(cmd_desc)	\
-		(((cmd_desc)->length_tcp_hdr >> 24) & 0x0FF)
-#define CMD_DESC_PORT(cmd_desc)		((cmd_desc)->port_ctxid & 0x0F)
-#define CMD_DESC_CTX_ID(cmd_desc)	(((cmd_desc)->port_ctxid >> 4) & 0x0F)
-
-#define CMD_DESC_TOTAL_LENGTH_WRT(cmd_desc, var)	\
-		((cmd_desc)->length_tcp_hdr |= ((var) & 0x00FFFFFF))
-#define CMD_DESC_TCP_HDR_OFFSET_WRT(cmd_desc, var)	\
-		((cmd_desc)->length_tcp_hdr |= (((var) << 24) & 0xFF000000))
-#define CMD_DESC_PORT_WRT(cmd_desc, var)	\
-		((cmd_desc)->port_ctxid |= ((var) & 0x0F))
+#define netxen_set_cmd_desc_port(cmd_desc, var)	\
+	((cmd_desc)->port_ctxid |= ((var) & 0x0F))
+
+#define netxen_set_cmd_desc_flags(cmd_desc, val)	\
+	_netxen_set_bits((cmd_desc)->flags_opcode, 0, 7, val)
+#define netxen_set_cmd_desc_opcode(cmd_desc, val)	\
+	_netxen_set_bits((cmd_desc)->flags_opcode, 7, 6, val)
+
+#define netxen_set_cmd_desc_num_of_buff(cmd_desc, val)	\
+	_netxen_set_bits((cmd_desc)->num_of_buffers_total_length, 0, 8, val);
+#define netxen_set_cmd_desc_totallength(cmd_desc, val)	\
+	_netxen_set_bits((cmd_desc)->num_of_buffers_total_length, 8, 24, val);
+
+#define netxen_get_cmd_desc_opcode(cmd_desc)	\
+	(((cmd_desc)->flags_opcode >> 7) & 0x003F)
+#define netxen_get_cmd_desc_totallength(cmd_desc)	\
+	(((cmd_desc)->num_of_buffers_total_length >> 8) & 0x0FFFFFF)
 
 struct cmd_desc_type0 {
-	u64 netxen_next;	/* for fragments handled by Phantom */
+	u8 tcp_hdr_offset;	/* For LSO only */
+	u8 ip_hdr_offset;	/* For LSO only */
+	/* Bit pattern: 0-6 flags, 7-12 opcode, 13-15 unused */
+	u16 flags_opcode;
+	/* Bit pattern: 0-7 total number of segments,
+			8-31 Total size of the packet */
+	u32 num_of_buffers_total_length;
 	union {
 		struct {
 			u32 addr_low_part2;
@@ -227,13 +341,6 @@
 		u64 addr_buffer2;
 	};
 
-	/* Bit pattern: 0-23 total length, 24-32 tcp header offset */
-	u32 length_tcp_hdr;
-	u8 ip_hdr_offset;	/* For LSO only */
-	u8 num_of_buffers;	/* total number of segments */
-	u8 flags;		/* as defined above */
-	u8 opcode;
-
 	u16 reference_handle;	/* changed to u16 to add mss */
 	u16 mss;		/* passed by NDIS_PACKET for LSO */
 	/* Bit pattern 0-3 port, 0-3 ctx id */
@@ -241,6 +348,7 @@
 	u8 total_hdr_length;	/* LSO only : MAC+IP+TCP Hdr size */
 	u16 conn_id;		/* IPSec offoad only */
 
+
 	union {
 		struct {
 			u32 addr_low_part3;
@@ -248,7 +356,6 @@
 		};
 		u64 addr_buffer3;
 	};
-
 	union {
 		struct {
 			u32 addr_low_part1;
@@ -270,6 +377,8 @@
 		u64 addr_buffer4;
 	};
 
+	u64 unused;
+
 } __attribute__ ((aligned(64)));
 
 /* Note: sizeof(rcv_desc) should always be a mutliple of 2 */
@@ -296,22 +405,49 @@
 #define NETXEN_PROT_UNKNOWN	(0)
 
 /* Note: sizeof(status_desc) should always be a mutliple of 2 */
-#define STATUS_DESC_PORT(status_desc)	\
-		((status_desc)->port_status_type_op & 0x0F)
-#define STATUS_DESC_STATUS(status_desc)	\
-		(((status_desc)->port_status_type_op >> 4) & 0x0F)
-#define STATUS_DESC_TYPE(status_desc)	\
-		(((status_desc)->port_status_type_op >> 8) & 0x0F)
-#define STATUS_DESC_OPCODE(status_desc)	\
-		(((status_desc)->port_status_type_op >> 12) & 0x0F)
+
+#define netxen_get_sts_desc_lro_cnt(status_desc)	\
+	((status_desc)->lro & 0x7F)
+#define netxen_get_sts_desc_lro_last_frag(status_desc)	\
+	(((status_desc)->lro & 0x80) >> 7)
+
+#define netxen_get_sts_port(status_desc)	\
+	((status_desc)->status_desc_data & 0x0F)
+#define netxen_get_sts_status(status_desc)	\
+	(((status_desc)->status_desc_data >> 4) & 0x0F)
+#define netxen_get_sts_type(status_desc)	\
+	(((status_desc)->status_desc_data >> 8) & 0x0F)
+#define netxen_get_sts_totallength(status_desc)	\
+	(((status_desc)->status_desc_data >> 12) & 0xFFFF)
+#define netxen_get_sts_refhandle(status_desc)	\
+	(((status_desc)->status_desc_data >> 28) & 0xFFFF)
+#define netxen_get_sts_prot(status_desc)	\
+	(((status_desc)->status_desc_data >> 44) & 0x0F)
+#define netxen_get_sts_owner(status_desc)	\
+	(((status_desc)->status_desc_data >> 56) & 0x03)
+#define netxen_get_sts_opcode(status_desc)	\
+	(((status_desc)->status_desc_data >> 58) & 0x03F)
+
+#define netxen_clear_sts_owner(status_desc)	\
+	((status_desc)->status_desc_data &=	\
+	~(((unsigned long long)3) << 56 ))
+#define netxen_set_sts_owner(status_desc, val)	\
+	((status_desc)->status_desc_data |=	\
+	(((unsigned long long)((val) & 0x3)) << 56 ))
 
 struct status_desc {
-	/* Bit pattern: 0-3 port, 4-7 status, 8-11 type, 12-15 opcode */
-	u16 port_status_type_op;
-	u16 total_length;	/* NIC mode */
-	u16 reference_handle;	/* handle for the associated packet */
-	/* Bit pattern: 0-1 owner, 2-5 protocol */
-	u16 owner;		/* Owner of the descriptor */
+	/* Bit pattern: 0-3 port, 4-7 status, 8-11 type, 12-27 total_length
+			28-43 reference_handle, 44-47 protocol, 48-52 unused
+			53-55 desc_cnt, 56-57 owner, 58-63 opcode
+	 */
+	u64 status_desc_data;
+	u32 hash_value;
+	u8 hash_type;
+	u8 msg_type;
+	u8 unused;
+	/* Bit pattern: 0-6 lro_count indicates frag sequence,
+			7 last_frag indicates last frag */
+	u8 lro;
 } __attribute__ ((aligned(8)));
 
 enum {
@@ -560,11 +696,12 @@
 #define PRIMARY_START 		(BOOTLD_START)
 #define FLASH_CRBINIT_SIZE 	(0x4000)
 #define FLASH_BRDCFG_SIZE 	(sizeof(struct netxen_board_info))
-#define FLASH_USER_SIZE		(sizeof(netxen_user_info)/sizeof(u32))
+#define FLASH_USER_SIZE		(sizeof(struct netxen_user_info)/sizeof(u32))
 #define FLASH_SECONDARY_SIZE 	(USER_START-SECONDARY_START)
 #define NUM_PRIMARY_SECTORS	(0x20)
 #define NUM_CONFIG_SECTORS 	(1)
-#define PFX "netxen: "
+#define PFX "NetXen: "
+extern char netxen_nic_driver_name[];
 
 /* Note: Make sure to not call this before adapter->port is valid */
 #if !defined(NETXEN_DEBUG)
@@ -573,7 +710,7 @@
 #else
 #define DPRINTK(klevel, fmt, args...)	do { \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, __FUNCTION__,\
-		(adapter != NULL && adapter->port != NULL && \
+		(adapter != NULL && \
 		adapter->port[0] != NULL && \
 		adapter->port[0]->netdev != NULL) ? \
 		adapter->port[0]->netdev->name : NULL, \
@@ -620,7 +757,6 @@
 	u8 frag_count;
 	unsigned long time_stamp;
 	u32 state;
-	u32 no_of_descriptors;
 	u32 tx_bounce_buff;
 	struct bounce_index bnext;
 };
@@ -631,6 +767,9 @@
 	u64 dma;
 	u16 ref_handle;
 	u16 state;
+	u32 lro_expected_frags;
+	u32 lro_current_frags;
+	u32 lro_length;
 	u32 rx_bounce_buff;
 	struct bounce_index bnext;
 	char *bounce_ptr;
@@ -649,6 +788,8 @@
 	void __iomem *pci_base0;
 	void __iomem *pci_base1;
 	void __iomem *pci_base2;
+	void __iomem *db_base;
+	unsigned long db_len;
 
 	u8 revision_id;
 	u16 board_type;
@@ -658,14 +799,13 @@
 	u32 qg_linksup;
 	/* Address of cmd ring in Phantom */
 	struct cmd_desc_type0 *cmd_desc_head;
-	char *pauseaddr;
 	struct pci_dev *cmd_desc_pdev;
 	dma_addr_t cmd_desc_phys_addr;
-	dma_addr_t pause_physaddr;
-	struct pci_dev *pause_pdev;
 	struct netxen_adapter *adapter;
 };
 
+#define RCV_RING_LRO	RCV_DESC_LRO
+
 #define MINIMUM_ETHERNET_FRAME_SIZE	64	/* With FCS */
 #define ETHERNET_FCS_SIZE		4
 
@@ -719,8 +859,12 @@
 
 #define NETXEN_NIC_MSI_ENABLED 0x02
 #define NETXEN_DMA_MASK	0xfffffffe
+#define NETXEN_DB_MAPSIZE_BYTES    0x1000
 
-struct netxen_drvops;
+struct netxen_dummy_dma {
+	void *addr;
+	dma_addr_t phys_addr;
+};
 
 struct netxen_adapter {
 	struct netxen_hardware_context ahw;
@@ -730,18 +874,19 @@
 	spinlock_t tx_lock;
 	spinlock_t lock;
 	struct work_struct watchdog_task;
-	struct work_struct tx_timeout_task;
+	struct work_struct tx_timeout_task[NETXEN_MAX_PORTS];
 	struct timer_list watchdog_timer;
 
 	u32 curr_window;
 
 	u32 cmd_producer;
-	u32 cmd_consumer;
+	u32 *cmd_consumer;
 
 	u32 last_cmd_consumer;
 	u32 max_tx_desc_count;
 	u32 max_rx_desc_count;
 	u32 max_jumbo_rx_desc_count;
+	u32 max_lro_rx_desc_count;
 	/* Num of instances active on cmd buffer ring */
 	u32 proc_cmd_buf_counter;
 
@@ -763,8 +908,27 @@
 	struct netxen_recv_context recv_ctx[MAX_RCV_CTX];
 
 	int is_up;
-	int work_done;
-	struct netxen_drvops *ops;
+	int number;
+	struct netxen_dummy_dma dummy_dma;
+
+	/* Context interface shared between card and host */
+	struct netxen_ring_ctx *ctx_desc;
+	struct pci_dev *ctx_desc_pdev;
+	dma_addr_t ctx_desc_phys_addr;
+	int (*enable_phy_interrupts) (struct netxen_adapter *, int);
+	int (*disable_phy_interrupts) (struct netxen_adapter *, int);
+	void (*handle_phy_intr) (struct netxen_adapter *);
+	int (*macaddr_set) (struct netxen_port *, netxen_ethernet_macaddr_t);
+	int (*set_mtu) (struct netxen_port *, int);
+	int (*set_promisc) (struct netxen_adapter *, int,
+				netxen_niu_prom_mode_t);
+	int (*unset_promisc) (struct netxen_adapter *, int,
+				netxen_niu_prom_mode_t);
+	int (*phy_read) (struct netxen_adapter *, long phy, long reg, u32 *);
+	int (*phy_write) (struct netxen_adapter *, long phy, long reg, u32 val);
+	int (*init_port) (struct netxen_adapter *, int);
+	void (*init_niu) (struct netxen_adapter *);
+	int (*stop_port) (struct netxen_adapter *, int);
 };				/* netxen_adapter structure */
 
 /* Max number of xmit producer threads that can run simultaneously */
@@ -846,25 +1010,6 @@
 	return NULL;
 }
 
-struct netxen_drvops {
-	int (*enable_phy_interrupts) (struct netxen_adapter *, int);
-	int (*disable_phy_interrupts) (struct netxen_adapter *, int);
-	void (*handle_phy_intr) (struct netxen_adapter *);
-	int (*macaddr_set) (struct netxen_port *, netxen_ethernet_macaddr_t);
-	int (*set_mtu) (struct netxen_port *, int);
-	int (*set_promisc) (struct netxen_adapter *, int,
-			    netxen_niu_prom_mode_t);
-	int (*unset_promisc) (struct netxen_adapter *, int,
-			      netxen_niu_prom_mode_t);
-	int (*phy_read) (struct netxen_adapter *, long phy, long reg, u32 *);
-	int (*phy_write) (struct netxen_adapter *, long phy, long reg, u32 val);
-	int (*init_port) (struct netxen_adapter *, int);
-	void (*init_niu) (struct netxen_adapter *);
-	int (*stop_port) (struct netxen_adapter *, int);
-};
-
-extern char netxen_nic_driver_name[];
-
 int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter,
 					  int port);
 int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter,
@@ -903,10 +1048,20 @@
 			  int len);
 int netxen_nic_hw_write_wx(struct netxen_adapter *adapter, u64 off, void *data,
 			   int len);
+int netxen_nic_hw_read_ioctl(struct netxen_adapter *adapter, u64 off,
+			     void *data, int len);
+int netxen_nic_hw_write_ioctl(struct netxen_adapter *adapter, u64 off,
+			      void *data, int len);
+int netxen_nic_pci_mem_write_ioctl(struct netxen_adapter *adapter,
+				   u64 off, void *data, int size);
+int netxen_nic_pci_mem_read_ioctl(struct netxen_adapter *adapter,
+				  u64 off, void *data, int size);
 void netxen_crb_writelit_adapter(struct netxen_adapter *adapter,
 				 unsigned long off, int data);
 
 /* Functions from netxen_nic_init.c */
+void netxen_free_adapter_offload(struct netxen_adapter *adapter);
+int netxen_initialize_adapter_offload(struct netxen_adapter *adapter);
 void netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val);
 void netxen_load_firmware(struct netxen_adapter *adapter);
 int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose);
@@ -941,7 +1096,9 @@
 void netxen_watchdog_task(unsigned long v);
 void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx,
 			    u32 ringid);
-void netxen_process_cmd_ring(unsigned long data);
+void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, u32 ctx,
+				 u32 ringid);
+int netxen_process_cmd_ring(unsigned long data);
 u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctx, int max);
 void netxen_nic_set_multi(struct net_device *netdev);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
@@ -1050,6 +1207,8 @@
 		name = "Unknown";
 }
 
+void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ctx,
+			uint32_t ringid);
 int netxen_is_flash_supported(struct netxen_adapter *adapter);
 int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, u64 mac[]);
 int netxen_get_next_bounce_buffer(struct bounce_index *head,
diff -u b/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
--- b/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -226,16 +226,16 @@
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		/* autonegotiation */
-		if (adapter->ops->phy_write
-		    && adapter->ops->phy_write(adapter, port->portnum,
+		if (adapter->phy_write
+		    && adapter->phy_write(adapter, port->portnum,
 					       NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
 					       (__le32) ecmd->autoneg) != 0)
 			return -EIO;
 		else
 			port->link_autoneg = ecmd->autoneg;
 
-		if (adapter->ops->phy_read
-		    && adapter->ops->phy_read(adapter, port->portnum,
+		if (adapter->phy_read
+		    && adapter->phy_read(adapter, port->portnum,
 					      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					      &status) != 0)
 			return -EIO;
@@ -257,8 +257,8 @@
 			netxen_clear_phy_duplex(status);
 		if (ecmd->duplex == DUPLEX_FULL)
 			netxen_set_phy_duplex(status);
-		if (adapter->ops->phy_write
-		    && adapter->ops->phy_write(adapter, port->portnum,
+		if (adapter->phy_write
+		    && adapter->phy_write(adapter, port->portnum,
 					       NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					       *((int *)&status)) != 0)
 			return -EIO;
@@ -422,8 +422,8 @@
 
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
-		if (adapter->ops->phy_read
-		    && adapter->ops->phy_read(adapter, port->portnum,
+		if (adapter->phy_read
+		    && adapter->phy_read(adapter, port->portnum,
 					      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					      &status) != 0)
 			return -EIO;
@@ -528,8 +528,8 @@
 				    *(u32 *) (&val));
 		/* set autoneg */
 		autoneg = pause->autoneg;
-		if (adapter->ops->phy_write
-		    && adapter->ops->phy_write(adapter, port->portnum,
+		if (adapter->phy_write
+		    && adapter->phy_write(adapter, port->portnum,
 					       NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
 					       (__le32) autoneg) != 0)
 			return -EIO;
diff -u b/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
--- b/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -42,7 +42,7 @@
 
 #define NETXEN_FLASH_BASE	(BOOTLD_START)
 #define NETXEN_PHANTOM_MEM_BASE	(NETXEN_FLASH_BASE)
-#define NETXEN_MAX_MTU		8000
+#define NETXEN_MAX_MTU		8000 + NETXEN_ENET_HEADER_SIZE + NETXEN_ETH_FCS_SIZE
 #define NETXEN_MIN_MTU		64
 #define NETXEN_ETH_FCS_SIZE     4
 #define NETXEN_ENET_HEADER_SIZE 14
@@ -81,8 +81,8 @@
 	DPRINTK(INFO, "valid ether addr\n");
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
-	if (adapter->ops->macaddr_set)
-		adapter->ops->macaddr_set(port, addr->sa_data);
+	if (adapter->macaddr_set)
+		adapter->macaddr_set(port, addr->sa_data);
 
 	return 0;
 }
@@ -99,15 +99,15 @@
 
 	mc_ptr = netdev->mc_list;
 	if (netdev->flags & IFF_PROMISC) {
-		if (adapter->ops->set_promisc)
-			adapter->ops->set_promisc(adapter,
+		if (adapter->set_promisc)
+			adapter->set_promisc(adapter,
 						  port->portnum,
 						  NETXEN_NIU_PROMISC_MODE);
 	} else {
-		if (adapter->ops->unset_promisc &&
+		if (adapter->unset_promisc &&
 		    adapter->ahw.boardcfg.board_type
 		    != NETXEN_BRDTYPE_P2_SB31_10G_IMEZ)
-			adapter->ops->unset_promisc(adapter,
+			adapter->unset_promisc(adapter,
 						    port->portnum,
 						    NETXEN_NIU_NON_PROMISC_MODE);
 	}
@@ -160,8 +160,8 @@
 		return -EINVAL;
 	}
 
-	if (adapter->ops->set_mtu)
-		adapter->ops->set_mtu(port, mtu);
+	if (adapter->set_mtu)
+		adapter->set_mtu(port, mtu);
 	netdev->mtu = mtu;
 
 	return 0;
@@ -176,22 +176,18 @@
 	struct netxen_hardware_context *hw = &adapter->ahw;
 	u32 state = 0;
 	void *addr;
-	void *pause_addr;
 	int loops = 0, err = 0;
 	int ctx, ring;
 	u32 card_cmdring = 0;
-	struct netxen_rcv_desc_crb *rcv_desc_crb = NULL;
 	struct netxen_recv_context *recv_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
 
-	DPRINTK(INFO, "crb_base: %lx %lx", NETXEN_PCI_CRBSPACE,
+	DPRINTK(INFO, "crb_base: %lx %x", NETXEN_PCI_CRBSPACE,
 		PCI_OFFSET_SECOND_RANGE(adapter, NETXEN_PCI_CRBSPACE));
-	DPRINTK(INFO, "cam base: %lx %lx", NETXEN_CRB_CAM,
+	DPRINTK(INFO, "cam base: %lx %x", NETXEN_CRB_CAM,
 		pci_base_offset(adapter, NETXEN_CRB_CAM));
-	DPRINTK(INFO, "cam RAM: %lx %lx", NETXEN_CAM_RAM_BASE,
+	DPRINTK(INFO, "cam RAM: %lx %x", NETXEN_CAM_RAM_BASE,
 		pci_base_offset(adapter, NETXEN_CAM_RAM_BASE));
-	DPRINTK(INFO, "NIC base:%lx %lx\n", NIC_CRB_BASE_PORT1,
-		pci_base_offset(adapter, NIC_CRB_BASE_PORT1));
 
 	/* Window 1 call */
 	card_cmdring = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_CMDRING));
@@ -226,33 +222,40 @@
 	DPRINTK(INFO, "Recieve Peg ready too. starting stuff\n");
 
 	addr = netxen_alloc(adapter->ahw.pdev,
-			    sizeof(struct cmd_desc_type0) *
-			    adapter->max_tx_desc_count,
-			    &hw->cmd_desc_phys_addr, &hw->cmd_desc_pdev);
+				sizeof(struct netxen_ring_ctx) +
+				sizeof(uint32_t),
+                                (dma_addr_t *)&adapter->ctx_desc_phys_addr,
+				&adapter->ctx_desc_pdev);
+
+	printk("ctx_desc_phys_addr: 0x%llx\n", (u64)adapter->ctx_desc_phys_addr);
+        if (addr == NULL) {
+                DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
+                err = -ENOMEM;
+                return err;
+        }
+        memset(addr, 0, sizeof(struct netxen_ring_ctx));
+        adapter->ctx_desc = (struct netxen_ring_ctx *) addr;
+        adapter->ctx_desc->cmd_consumer_offset = adapter->ctx_desc_phys_addr
+                                                + sizeof(struct netxen_ring_ctx);
+        adapter->cmd_consumer = (uint32_t *)(((char *) addr) +
+				sizeof(struct netxen_ring_ctx));
+
+        addr = pci_alloc_consistent(adapter->ahw.pdev,
+                                    sizeof(struct cmd_desc_type0)*
+                                    adapter->max_tx_desc_count,
+                                    (dma_addr_t *)&hw->cmd_desc_phys_addr);
+        printk("cmdDesc_physAddr: 0x%llx\n", (u64)hw->cmd_desc_phys_addr);
+
 
 	if (addr == NULL) {
 		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
+		netxen_free_hw_resources(adapter);
 		return -ENOMEM;
 	}
 
-	pause_addr = netxen_alloc(adapter->ahw.pdev, 512,
-				  (dma_addr_t *) & hw->pause_physaddr,
-				  &hw->pause_pdev);
-	if (pause_addr == NULL) {
-		DPRINTK(1, ERR, "bad return from pci_alloc_consistent\n");
-		return -ENOMEM;
-	}
-
-	hw->pauseaddr = (char *)pause_addr;
-	{
-		u64 *ptr = (u64 *) pause_addr;
-		*ptr++ = NETXEN_NIC_ZERO_PAUSE_ADDR;
-		*ptr++ = NETXEN_NIC_ZERO_PAUSE_ADDR;
-		*ptr++ = NETXEN_NIC_UNIT_PAUSE_ADDR;
-		*ptr++ = NETXEN_NIC_ZERO_PAUSE_ADDR;
-		*ptr++ = NETXEN_NIC_EPG_PAUSE_ADDR1;
-		*ptr++ = NETXEN_NIC_EPG_PAUSE_ADDR2;
-	}
+        adapter->ctx_desc->cmd_ring_addr_lo = hw->cmd_desc_phys_addr & 0xffffffffUL;
+        adapter->ctx_desc->cmd_ring_addr_hi = ((u64)hw->cmd_desc_phys_addr >> 32);
+        adapter->ctx_desc->cmd_ring_size = adapter->max_tx_desc_count;
 
 	hw->cmd_desc_head = (struct cmd_desc_type0 *)addr;
 
@@ -273,6 +276,12 @@
 				return err;
 			}
 			rcv_desc->desc_head = (struct rcv_desc *)addr;
+                        adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr_lo =
+                                   rcv_desc->phys_addr & 0xffffffffUL;
+                        adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr_hi =
+                                   ((u64)rcv_desc->phys_addr>>32);
+                        adapter->ctx_desc->rcv_ctx[ring].rcv_ring_size =
+                                rcv_desc->max_rx_desc_count;
 		}
 
 		addr = netxen_alloc(adapter->ahw.pdev,
@@ -288,47 +297,21 @@
 			return err;
 		}
 		recv_ctx->rcv_status_desc_head = (struct status_desc *)addr;
-		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
-			rcv_desc = &recv_ctx->rcv_desc[ring];
-			rcv_desc_crb =
-			    &recv_crb_registers[ctx].rcv_desc_crb[ring];
-			DPRINTK(INFO, "ring #%d crb global ring reg 0x%x\n",
-				ring, rcv_desc_crb->crb_globalrcv_ring);
-			/* Window = 1 */
-			writel(lower32(rcv_desc->phys_addr),
-			       NETXEN_CRB_NORMALIZE(adapter,
-						    rcv_desc_crb->
-						    crb_globalrcv_ring));
-			DPRINTK(INFO, "GLOBAL_RCV_RING ctx %d, addr 0x%x"
-				" val 0x%llx,"
-				" virt %p\n", ctx,
-				rcv_desc_crb->crb_globalrcv_ring,
-				(unsigned long long)rcv_desc->phys_addr,
-				+rcv_desc->desc_head);
-		}
+                adapter->ctx_desc->sts_ring_addr_lo =
+                         recv_ctx->rcv_status_desc_phys_addr & 0xffffffffUL;
+                adapter->ctx_desc->sts_ring_addr_hi =
+                         ((u64)recv_ctx->rcv_status_desc_phys_addr>>32);
+                adapter->ctx_desc->sts_ring_size = adapter->max_rx_desc_count;
 
-		/* Window = 1 */
-		writel(lower32(recv_ctx->rcv_status_desc_phys_addr),
-		       NETXEN_CRB_NORMALIZE(adapter,
-					    recv_crb_registers[ctx].
-					    crb_rcvstatus_ring));
-		DPRINTK(INFO, "RCVSTATUS_RING, ctx %d, addr 0x%x,"
-			" val 0x%x,virt%p\n",
-			ctx,
-			recv_crb_registers[ctx].crb_rcvstatus_ring,
-			(unsigned long long)recv_ctx->rcv_status_desc_phys_addr,
-			recv_ctx->rcv_status_desc_head);
 	}
 	/* Window = 1 */
-	writel(lower32(hw->pause_physaddr),
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_PAUSE_ADDR_LO));
-	writel(upper32(hw->pause_physaddr),
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_PAUSE_ADDR_HI));
-
-	writel(lower32(hw->cmd_desc_phys_addr),
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_LO));
-	writel(upper32(hw->cmd_desc_phys_addr),
-	       NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_HI));
+
+	writel(lower32(adapter->ctx_desc_phys_addr),
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_ADDR_REG_LO));
+	writel(upper32(adapter->ctx_desc_phys_addr),
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_ADDR_REG_HI));
+	writel(NETXEN_CTX_SIGNATURE,
+		NETXEN_CRB_NORMALIZE(adapter, CRB_CTX_SIGNATURE_REG));
 	return err;
 }
 
@@ -338,6 +321,15 @@
 	struct netxen_rcv_desc_ctx *rcv_desc;
 	int ctx, ring;
 
+        if (adapter->ctx_desc != NULL) {
+                pci_free_consistent(adapter->ctx_desc_pdev,
+                                    sizeof(struct netxen_ring_ctx) +
+                                    sizeof(uint32_t),
+                                    adapter->ctx_desc,
+                                    adapter->ctx_desc_phys_addr);
+                adapter->ctx_desc = NULL;
+        }
+
 	if (adapter->ahw.cmd_desc_head != NULL) {
 		pci_free_consistent(adapter->ahw.cmd_desc_pdev,
 				    sizeof(struct cmd_desc_type0) *
@@ -346,12 +338,11 @@
 				    adapter->ahw.cmd_desc_phys_addr);
 		adapter->ahw.cmd_desc_head = NULL;
 	}
-	if (adapter->ahw.pauseaddr != NULL) {
-		pci_free_consistent(adapter->ahw.pause_pdev, 512,
-				    adapter->ahw.pauseaddr,
-				    adapter->ahw.pause_physaddr);
-		adapter->ahw.pauseaddr = NULL;
-	}
+        /* Special handling: there are 2 ports on this board */
+        if (adapter->ahw.boardcfg.board_type ==
+	    NETXEN_BRDTYPE_P2_SB31_10G_IMEZ) {
+                adapter->ahw.max_ports = 2;
+        }
 
 	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
 		recv_ctx = &adapter->recv_ctx[ctx];
@@ -385,19 +376,20 @@
 		desc->total_hdr_length = sizeof(struct ethhdr) +
 		    ((skb->nh.iph)->ihl * sizeof(u32)) +
 		    ((skb->h.th)->doff * sizeof(u32));
-		desc->opcode = TX_TCP_LSO;
+		netxen_set_cmd_desc_opcode(desc, TX_TCP_LSO);
 	} else if (skb->ip_summed == CHECKSUM_COMPLETE) {
 		if (skb->nh.iph->protocol == IPPROTO_TCP) {
-			desc->opcode = TX_TCP_PKT;
+			netxen_set_cmd_desc_opcode(desc, TX_TCP_PKT);
 		} else if (skb->nh.iph->protocol == IPPROTO_UDP) {
-			desc->opcode = TX_UDP_PKT;
+			netxen_set_cmd_desc_opcode(desc, TX_UDP_PKT);
 		} else {
 			return;
 		}
 	}
 	adapter->stats.xmitcsummed++;
-	CMD_DESC_TCP_HDR_OFFSET_WRT(desc, skb->h.raw - skb->data);
-	desc->length_tcp_hdr = cpu_to_le32(desc->length_tcp_hdr);
+	desc->tcp_hdr_offset = skb->h.raw - skb->data;
+	netxen_set_cmd_desc_totallength(desc,
+		cpu_to_le32(netxen_get_cmd_desc_totallength(desc)));
 	desc->ip_hdr_offset = skb->nh.raw - skb->data;
 }
 
@@ -850,8 +842,8 @@
 
 	for (port_nr = 0; port_nr < adapter->ahw.max_ports; port_nr++) {
 		port = adapter->port[port_nr];
-		if (adapter->ops->stop_port)
-			adapter->ops->stop_port(adapter, port->portnum);
+		if (adapter->stop_port)
+			adapter->stop_port(adapter, port->portnum);
 	}
 }
 
@@ -880,8 +872,8 @@
 
 	netxen_nic_read_w0(adapter, NETXEN_NIU_MODE, &mode);
 	if (netxen_get_niu_enable_ge(mode)) {	/* Gb 10/100/1000 Mbps mode */
-		if (adapter->ops->phy_read
-		    && adapter->ops->
+		if (adapter->phy_read
+		    && adapter->
 		    phy_read(adapter, port->portnum,
 			     NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 			     &status) == 0) {
@@ -911,8 +903,8 @@
 					port->link_duplex = -1;
 					break;
 				}
-				if (adapter->ops->phy_read
-				    && adapter->ops->
+				if (adapter->phy_read
+				    && adapter->
 				    phy_read(adapter, port->portnum,
 					     NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
 					     (__le32 *) & autoneg) != 0)
@@ -1012,0 +1005,279 @@
+
+int netxen_nic_hw_write_ioctl(struct netxen_adapter *adapter, u64 off, void *data, int len)
+{
+	void *addr;
+	u64 offset = off;
+	u8 *mem_ptr = NULL;
+	unsigned long mem_base;
+	unsigned long mem_page;
+
+	if(ADDR_IN_WINDOW1(off)) {
+		addr = NETXEN_CRB_NORMALIZE(adapter, off);
+		if(!addr) {
+			mem_base = pci_resource_start(adapter->ahw.pdev, 0);
+			offset = NETXEN_CRB_NORMAL(off);
+			mem_page = offset & PAGE_MASK;
+			if(mem_page != ((offset + len - 1) & PAGE_MASK))
+				mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE * 2);
+			else
+				mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE);
+			if(mem_ptr == 0UL) {
+				return 1;
+			}
+			addr = mem_ptr;
+			addr += offset & (PAGE_SIZE - 1);
+		}
+	} else {
+		addr = pci_base_offset(adapter, off);
+		if(!addr) {
+			mem_base = pci_resource_start(adapter->ahw.pdev, 0);
+			mem_page = off & PAGE_MASK;
+			if(mem_page != ((off + len - 1) & PAGE_MASK))
+				mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE * 2);
+			else
+				mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE);
+			if(mem_ptr == 0UL) {
+				return 1;
+			}
+			addr = mem_ptr;
+			addr += off & (PAGE_SIZE - 1);
+		}
+		netxen_nic_pci_change_crbwindow(adapter, 0);
+	}
+	switch (len) {
+	case 1:
+		writeb(*(u8 *) data, addr);
+		break;
+	case 2:
+		writew(*(u16 *) data, addr);
+		break;
+	case 4:
+		writel(*(u32 *) data, addr);
+		break;
+	case 8:
+		writeq(*(u64 *) data, addr);
+		break;
+	default:
+		DPRINTK(INFO,
+			"writing data %lx to offset %llx, num words=%d\n",
+			*(unsigned long *)data, off, (len >> 3));
+
+		netxen_nic_hw_block_write64((u64 __iomem *) data, addr,
+					    (len >> 3));
+		break;
+	}
+
+	if(!ADDR_IN_WINDOW1(off))
+		netxen_nic_pci_change_crbwindow(adapter, 1);
+	if(mem_ptr)
+		iounmap(mem_ptr);
+	return 0;
+}
+
+int netxen_nic_hw_read_ioctl (struct netxen_adapter *adapter, u64 off, void *data, int len)
+{
+	void *addr;
+	u64 offset;
+	u8 *mem_ptr = NULL;
+	unsigned long mem_base;
+	unsigned long mem_page;
+
+	if(ADDR_IN_WINDOW1(off)) {
+		addr = NETXEN_CRB_NORMALIZE(adapter, off);
+		if(!addr) {
+			mem_base = pci_resource_start(adapter->ahw.pdev, 0);
+			offset = NETXEN_CRB_NORMAL(off);
+			mem_page = offset & PAGE_MASK;
+			if(mem_page != ((offset + len - 1) & PAGE_MASK))
+				mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE * 2);
+			else
+				mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE);
+			if(mem_ptr == 0UL) {
+				*(u8  *)data = 0;
+				return 1;
+			}
+			addr = mem_ptr;
+			addr += offset & (PAGE_SIZE - 1);
+		}
+	} else {
+		addr = pci_base_offset(adapter, off);
+		if(!addr) {
+			mem_base = pci_resource_start(adapter->ahw.pdev, 0);
+			mem_page = off & PAGE_MASK;
+			if(mem_page != ((off + len - 1) & PAGE_MASK))
+				mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE * 2);
+			else
+				mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE);
+			if(mem_ptr == 0UL)
+				return 1;
+			addr = mem_ptr;
+			addr += off & (PAGE_SIZE - 1);
+		}
+		netxen_nic_pci_change_crbwindow(adapter, 0);
+	}
+	switch (len) {
+	case 1:
+		*(u8 *) data = readb(addr);
+		break;
+	case 2:
+		*(u16 *) data = readw(addr);
+		break;
+	case 4:
+		*(u32 *) data = readl(addr);
+		break;
+	case 8:
+		*(u64 *) data = readq(addr);
+		break;
+	default:
+		netxen_nic_hw_block_read64((u64 __iomem *) data, addr,
+					   (len >> 3));
+		break;
+	}
+	if(!ADDR_IN_WINDOW1(off))
+		netxen_nic_pci_change_crbwindow(adapter, 1);
+	if(mem_ptr)
+		iounmap(mem_ptr);
+	return 0;
+}
+
+int netxen_nic_pci_mem_write_ioctl(struct netxen_adapter *adapter, u64 off,
+			void *data, int size)
+{
+	void *addr;
+	int ret = 0;
+	u8 *mem_ptr = NULL;
+	unsigned long mem_base;
+	unsigned long mem_page;
+
+	if (data == NULL || off > (128*1024*1024)) {
+		printk(KERN_ERR "%s: data: %p off:%llx\n",
+				netxen_nic_driver_name, data, off);
+		return 1;
+	}
+	off = netxen_nic_pci_set_window(adapter, off);
+	/* Corner case : Malicious user tried to break the driver by reading
+	   last few bytes in ranges and tries to read further addresses.
+	 */
+	if(!pci_base(adapter, off + size - 1) && pci_base(adapter, off)) {
+		printk(KERN_ERR "%s: Invalid access to memory address range"
+			" 0x%llx - 0x%llx\n", netxen_nic_driver_name, off,
+			off + size);
+		return 1;
+	}
+	addr = pci_base_offset(adapter, off);
+	DPRINTK(INFO, "writing data %llx to offset %llx\n",
+			*(unsigned long long *)data, off);
+	if(!addr) {
+		mem_base = pci_resource_start(adapter->ahw.pdev, 0);
+		mem_page = off & PAGE_MASK;
+		/* Map two pages whenever user tries to access addresses in two
+		   consecutive pages.
+		 */
+		if(mem_page != ((off + size - 1) & PAGE_MASK))
+			mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE*2);
+		else
+			mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE);
+		if(mem_ptr == 0UL) {
+			return 1;
+		}
+		addr = mem_ptr;
+		addr += off & (PAGE_SIZE - 1);
+	}
+	switch (size) {
+	case 1:
+		writeb(*(u8 *) data, addr);
+		break;
+	case 2:
+		writew(*(u16 *) data, addr);
+		break;
+	case 4:
+		writel(*(u32 *) data, addr);
+		break;
+	case 8:
+		writeq(*(u64 *) data, addr);
+		break;
+	default:
+		DPRINTK(INFO,
+			"writing data %lx to offset %llx, num words=%d\n",
+			*(unsigned long *)data, off, (size >> 3));
+
+		netxen_nic_hw_block_write64((u64 __iomem *) data, addr,
+					    (size >> 3));
+		break;
+	}
+
+	if(mem_ptr)
+		iounmap(mem_ptr);
+	DPRINTK(INFO, "wrote %llx\n", *(unsigned long long*)data);
+
+	return ret;
+}
+
+int netxen_nic_pci_mem_read_ioctl(struct netxen_adapter *adapter,
+			u64 off, void *data, int size)
+{
+	void *addr;
+	int ret = 0;
+	u8 *mem_ptr = NULL;
+	unsigned long mem_base;
+	unsigned long mem_page;
+
+	if (data == NULL || off > (128*1024*1024)) {
+		printk(KERN_ERR "%s: data: %p off:%llx\n",
+				netxen_nic_driver_name,  data, off);
+		return 1;
+	}
+	off = netxen_nic_pci_set_window(adapter, off);
+	/* Corner case : Malicious user tried to break the driver by reading
+	   last few bytes in ranges and tries to read further addresses.
+	 */
+	if(!pci_base(adapter, off + size - 1) && pci_base(adapter, off)) {
+		printk(KERN_ERR "%s: Invalid access to memory address range"
+			" 0x%llx - 0x%llx\n", netxen_nic_driver_name,  off,
+			off + size);
+		return 1;
+	}
+	addr = pci_base_offset(adapter, off);
+	if(!addr) {
+		mem_base = pci_resource_start(adapter->ahw.pdev, 0);
+		mem_page = off & PAGE_MASK;
+		/* Map two pages whenever user tries to access addresses in two
+		   consecutive pages.
+		 */
+		if(mem_page != ((off + size - 1) & PAGE_MASK))
+			mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE * 2);
+		else
+			mem_ptr = ioremap(mem_base + mem_page, PAGE_SIZE);
+		if(mem_ptr == 0UL) {
+			*(u8  *)data = 0;
+			return 1;
+		}
+		addr = mem_ptr;
+		addr += off & (PAGE_SIZE - 1);
+	}
+	switch (size) {
+	case 1:
+		*(u8 *) data = readb(addr);
+		break;
+	case 2:
+		*(u16 *) data = readw(addr);
+		break;
+	case 4:
+		*(u32 *) data = readl(addr);
+		break;
+	case 8:
+		*(u64 *) data = readq(addr);
+		break;
+	default:
+		netxen_nic_hw_block_read64((u64 __iomem *) data, addr,
+					   (size >> 3));
+		break;
+	}
+
+	if(mem_ptr)
+		iounmap(mem_ptr);
+	DPRINTK(INFO, "read %llx\n", *(unsigned long long*)data);
+
+	return ret;
+}
+
diff -u b/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
--- b/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -6,12 +6,12 @@
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
@@ -53,7 +53,7 @@
 
 #define NETXEN_NIC_XDMA_RESET 0x8000ff
 
-extern char *rx_bounce_ptr;
+extern char *rx_bounce_ptr[];
 extern struct bounce_index tx_bounce_head, tx_bounce_tail,
     rx_bounce_head, rx_bounce_tail;
 extern spinlock_t rx_bounce_lock, tx_bounce_lock;
@@ -142,6 +142,8 @@
 		return err;
 	}
 	/* Window 1 call */
+	writel(MPORT_SINGLE_FUNCTION_MODE,
+	       NETXEN_CRB_NORMALIZE(adapter, CRB_MPORT_MODE));
 	writel(PHAN_INITIALIZE_ACK,
 	       NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
 
@@ -189,7 +191,6 @@
 			for (i = 0; i < num_rx_bufs; i++) {
 				rx_buf->ref_handle = i;
 				rx_buf->state = NETXEN_BUFFER_FREE;
-
 				DPRINTK(INFO, "Rx buf:ctx%d i(%d) rx_buf:"
 					"%p\n", ctxid, i, rx_buf);
 				rx_buf++;
@@ -215,37 +216,36 @@
 
 void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 {
-	struct netxen_drvops *ops = adapter->ops;
 	switch (adapter->ahw.board_type) {
 	case NETXEN_NIC_GBE:
-		ops->enable_phy_interrupts =
+		adapter->enable_phy_interrupts =
 		    netxen_niu_gbe_enable_phy_interrupts;
-		ops->disable_phy_interrupts =
+		adapter->disable_phy_interrupts =
 		    netxen_niu_gbe_disable_phy_interrupts;
-		ops->handle_phy_intr = netxen_nic_gbe_handle_phy_intr;
-		ops->macaddr_set = netxen_niu_macaddr_set;
-		ops->set_mtu = netxen_nic_set_mtu_gb;
-		ops->set_promisc = netxen_niu_set_promiscuous_mode;
-		ops->unset_promisc = netxen_niu_set_promiscuous_mode;
-		ops->phy_read = netxen_niu_gbe_phy_read;
-		ops->phy_write = netxen_niu_gbe_phy_write;
-		ops->init_port = netxen_niu_gbe_init_port;
-		ops->init_niu = netxen_nic_init_niu_gb;
-		ops->stop_port = netxen_niu_disable_gbe_port;
+		adapter->handle_phy_intr = netxen_nic_gbe_handle_phy_intr;
+		adapter->macaddr_set = netxen_niu_macaddr_set;
+		adapter->set_mtu = netxen_nic_set_mtu_gb;
+		adapter->set_promisc = netxen_niu_set_promiscuous_mode;
+		adapter->unset_promisc = netxen_niu_set_promiscuous_mode;
+		adapter->phy_read = netxen_niu_gbe_phy_read;
+		adapter->phy_write = netxen_niu_gbe_phy_write;
+		adapter->init_port = netxen_niu_gbe_init_port;
+		adapter->init_niu = netxen_nic_init_niu_gb;
+		adapter->stop_port = netxen_niu_disable_gbe_port;
 		break;
 
 	case NETXEN_NIC_XGBE:
-		ops->enable_phy_interrupts =
+		adapter->enable_phy_interrupts =
 		    netxen_niu_xgbe_enable_phy_interrupts;
-		ops->disable_phy_interrupts =
+		adapter->disable_phy_interrupts =
 		    netxen_niu_xgbe_disable_phy_interrupts;
-		ops->handle_phy_intr = netxen_nic_xgbe_handle_phy_intr;
-		ops->macaddr_set = netxen_niu_xg_macaddr_set;
-		ops->set_mtu = netxen_nic_set_mtu_xgb;
-		ops->init_port = netxen_niu_xg_init_port;
-		ops->set_promisc = netxen_niu_xg_set_promiscuous_mode;
-		ops->unset_promisc = netxen_niu_xg_set_promiscuous_mode;
-		ops->stop_port = netxen_niu_disable_xg_port;
+		adapter->handle_phy_intr = netxen_nic_xgbe_handle_phy_intr;
+		adapter->macaddr_set = netxen_niu_xg_macaddr_set;
+		adapter->set_mtu = netxen_nic_set_mtu_xgb;
+		adapter->init_port = netxen_niu_xg_init_port;
+		adapter->set_promisc = netxen_niu_xg_set_promiscuous_mode;
+		adapter->unset_promisc = netxen_niu_xg_set_promiscuous_mode;
+		adapter->stop_port = netxen_niu_disable_xg_port;
 		break;
 
 	default:
@@ -625,6 +625,44 @@
 	return 0;
 }
 
+int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
+{
+	uint64_t	addr;
+	uint32_t	hi;
+	uint32_t	lo;
+
+	adapter->dummy_dma.addr =
+		pci_alloc_consistent(adapter->ahw.pdev,
+				     NETXEN_HOST_DUMMY_DMA_SIZE,
+				     &adapter->dummy_dma.phys_addr);
+	if(adapter->dummy_dma.addr == NULL) {
+		printk("%s: ERROR: Could not allocate dummy DMA memory\n",
+		       __FUNCTION__);
+		return -ENOMEM;
+	}
+
+	addr = (uint64_t)adapter->dummy_dma.phys_addr;
+	hi = (addr >> 32) & 0xffffffff;
+	lo = addr & 0xffffffff;
+
+	writel(hi, NETXEN_CRB_NORMALIZE(adapter,
+					       CRB_HOST_DUMMY_BUF_ADDR_HI));
+	writel(lo, NETXEN_CRB_NORMALIZE(adapter,
+					       CRB_HOST_DUMMY_BUF_ADDR_LO));
+
+	return 0;
+}
+
+void netxen_free_adapter_offload(struct netxen_adapter *adapter)
+{
+	if (adapter->dummy_dma.addr) {
+		pci_free_consistent(adapter->ahw.pdev, NETXEN_HOST_DUMMY_DMA_SIZE,
+				    adapter->dummy_dma.addr,
+				    adapter->dummy_dma.phys_addr);
+		adapter->dummy_dma.addr = NULL;
+	}
+}
+
 void netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
 {
 	u32 val = 0;
@@ -659,7 +697,8 @@
 		desc_head = recv_ctx->rcv_status_desc_head;
 		desc = &desc_head[consumer];
 
-		if (((le16_to_cpu(desc->owner)) & STATUS_OWNER_HOST))
+		if (((le16_to_cpu(netxen_get_sts_owner(desc)))
+		    & STATUS_OWNER_HOST))
 			return 1;
 	}
 
@@ -737,8 +776,8 @@
 			netif_wake_queue(netdev);
 	}
 
-	if (adapter->ops->handle_phy_intr)
-		adapter->ops->handle_phy_intr(adapter);
+	if (adapter->handle_phy_intr)
+		adapter->handle_phy_intr(adapter);
 	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 }
 
@@ -751,19 +790,19 @@
 netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 		   struct status_desc *desc)
 {
-	struct netxen_port *port = adapter->port[STATUS_DESC_PORT(desc)];
+	struct netxen_port *port = adapter->port[netxen_get_sts_port(desc)];
 	struct pci_dev *pdev = port->pdev;
 	struct net_device *netdev = port->netdev;
-	int index = le16_to_cpu(desc->reference_handle);
+	int index = le16_to_cpu(netxen_get_sts_refhandle(desc));
 	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
 	struct netxen_rx_buffer *buffer;
 	struct sk_buff *skb;
-	u32 length = le16_to_cpu(desc->total_length);
+	u32 length = le16_to_cpu(netxen_get_sts_totallength(desc));
 	u32 desc_ctx;
 	struct netxen_rcv_desc_ctx *rcv_desc;
 	int ret;
 
-	desc_ctx = STATUS_DESC_TYPE(desc);
+	desc_ctx = netxen_get_sts_type(desc);
 	if (unlikely(desc_ctx >= NUM_RCV_DESC_RINGS)) {
 		printk("%s: %s Bad Rcv descriptor ring\n",
 		       netxen_nic_driver_name, netdev->name);
@@ -771,7 +810,31 @@
 	}
 
 	rcv_desc = &recv_ctx->rcv_desc[desc_ctx];
+	if (unlikely(index > rcv_desc->max_rx_desc_count)) {
+		DPRINTK(ERR, "Got a buffer index:%x Max is %x\n",
+			index, rcv_desc->max_rx_desc_count);
+		return;
+	}
 	buffer = &rcv_desc->rx_buf_arr[index];
+	if(desc_ctx == RCV_DESC_LRO_CTXID) {
+		buffer->lro_current_frags++;
+		if (netxen_get_sts_desc_lro_last_frag(desc)) {
+			buffer->lro_expected_frags =
+				netxen_get_sts_desc_lro_cnt(desc);
+			buffer->lro_length = length;
+		}
+		if(buffer->lro_current_frags != buffer->lro_expected_frags) {
+			if (buffer->lro_expected_frags != 0) {
+				printk("LRO: (refhandle:%x) recv frag."
+					"wait for last. flags: %x expected:%d"
+					"have:%d\n", index,
+					netxen_get_sts_desc_lro_last_frag(desc),
+					buffer->lro_expected_frags,
+					buffer->lro_current_frags);
+			}
+			return;
+		}
+	}
 
 	pci_unmap_single(pdev, buffer->dma, rcv_desc->dma_size,
 			 PCI_DMA_FROMDEVICE);
@@ -783,13 +846,18 @@
 		rx_bounce_tail = buffer->bnext;
 	}
 
-	if (likely(STATUS_DESC_STATUS(desc) == STATUS_CKSUM_OK)) {
+	if (likely(netxen_get_sts_status(desc) == STATUS_CKSUM_OK)) {
 		port->stats.csummed++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	} else
-		skb->ip_summed = CHECKSUM_NONE;
+	}
 	skb->dev = netdev;
-	skb_put(skb, length);
+	if(desc_ctx == RCV_DESC_LRO_CTXID) {
+		/* True length was only available on the last pkt */
+		skb_put(skb, buffer->lro_length);
+	} else {
+		skb_put(skb, length);
+	}
+
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	ret = netif_receive_skb(skb);
@@ -835,6 +903,8 @@
 	adapter->stats.post_called++;
 	buffer->skb = NULL;
 	buffer->state = NETXEN_BUFFER_FREE;
+	buffer->lro_current_frags  = 0;
+	buffer->lro_expected_frags = 0;
 
 	port->stats.no_rcv++;
 	port->stats.rxbytes += length;
@@ -847,6 +917,7 @@
 	struct status_desc *desc_head = recv_ctx->rcv_status_desc_head;
 	struct status_desc *desc;	/* used to read status desc here */
 	u32 consumer = recv_ctx->status_rx_consumer;
+	u32 producer = 0;
 	int count = 0, ring;
 
 	DPRINTK(INFO, "procesing receive\n");
@@ -858,18 +929,20 @@
 	 */
 	while (count < max) {
 		desc = &desc_head[consumer];
-		if (!((le16_to_cpu(desc->owner)) & STATUS_OWNER_HOST)) {
-			DPRINTK(ERR, "desc %p ownedby %x\n", desc, desc->owner);
+		if (!(le16_to_cpu(netxen_get_sts_owner(desc)) & STATUS_OWNER_HOST)) {
+			DPRINTK(ERR, "desc %p ownedby %x\n", desc,
+				netxen_get_sts_owner(desc));
 			break;
 		}
 		netxen_process_rcv(adapter, ctxid, desc);
-		desc->owner = STATUS_OWNER_PHANTOM;
+		netxen_clear_sts_owner(desc);
+		netxen_set_sts_owner(desc, STATUS_OWNER_PHANTOM);
 		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
 		count++;
 	}
-	if (count) {
+	if(count) {
 		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
-			netxen_post_rx_buffers(adapter, ctxid, ring);
+			netxen_post_rx_buffers_nodb(adapter,ctxid, ring);
 		}
 	}
 
@@ -877,6 +950,7 @@
 	if (count) {
 		adapter->stats.process_rcv++;
 		recv_ctx->status_rx_consumer = consumer;
+		recv_ctx->status_rx_producer = producer;
 
 		/* Window = 1 */
 		writel(consumer,
@@ -889,12 +963,13 @@
 }
 
 /* Process Command status ring */
-void netxen_process_cmd_ring(unsigned long data)
+int netxen_process_cmd_ring(unsigned long data)
 {
 	u32 last_consumer;
 	u32 consumer;
 	struct netxen_adapter *adapter = (struct netxen_adapter *)data;
-	int count = 0;
+	int count1 = 0;
+	int count2 = 0;
 	struct netxen_cmd_buffer *buffer;
 	struct netxen_port *port;	/* port #1 */
 	struct netxen_port *nport;
@@ -903,6 +978,7 @@
 	u32 i;
 	struct sk_buff *skb = NULL;
 	int p;
+	int done;
 
 	spin_lock(&adapter->tx_lock);
 	last_consumer = adapter->last_cmd_consumer;
@@ -912,14 +988,13 @@
 	 * number as part of the descriptor. This way we will be able to get
 	 * the netdev which is associated with that device.
 	 */
-	consumer =
-	    readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMD_CONSUMER_OFFSET));
 
+	consumer = *(adapter->cmd_consumer);
 	if (last_consumer == consumer) {	/* Ring is empty    */
 		DPRINTK(INFO, "last_consumer %d == consumer %d\n",
 			last_consumer, consumer);
 		spin_unlock(&adapter->tx_lock);
-		return;
+		return 1;
 	}
 
 	adapter->proc_cmd_buf_counter++;
@@ -930,7 +1005,7 @@
 	 */
 	spin_unlock(&adapter->tx_lock);
 
-	while ((last_consumer != consumer) && (count < MAX_STATUS_HANDLE)) {
+	while ((last_consumer != consumer) && (count1 < MAX_STATUS_HANDLE)) {
 		buffer = &adapter->cmd_buf_arr[last_consumer];
 		port = adapter->port[buffer->port];
 		pdev = port->pdev;
@@ -960,24 +1035,25 @@
 			     && netif_carrier_ok(port->netdev))
 		    && ((jiffies - port->netdev->trans_start) >
 			port->netdev->watchdog_timeo)) {
-			schedule_work(&port->adapter->tx_timeout_task);
+			SCHEDULE_WORK(port->adapter->tx_timeout_task
+					+ port->portnum);
 		}
 
 		last_consumer = get_next_index(last_consumer,
 					       adapter->max_tx_desc_count);
-		count++;
+		count1++;
 	}
-	adapter->stats.noxmitdone += count;
+	adapter->stats.noxmitdone += count1;
 
-	count = 0;
+	count2 = 0;
 	spin_lock(&adapter->tx_lock);
 	if ((--adapter->proc_cmd_buf_counter) == 0) {
 		adapter->last_cmd_consumer = last_consumer;
 		while ((adapter->last_cmd_consumer != consumer)
-		       && (count < MAX_STATUS_HANDLE)) {
+		       && (count2 < MAX_STATUS_HANDLE)) {
 			buffer =
 			    &adapter->cmd_buf_arr[adapter->last_cmd_consumer];
-			count++;
+			count2++;
 			if (buffer->skb)
 				break;
 			else
@@ -986,7 +1062,7 @@
 						   adapter->max_tx_desc_count);
 		}
 	}
-	if (count) {
+	if (count1 || count2) {
 		for (p = 0; p < adapter->ahw.max_ports; p++) {
 			nport = adapter->port[p];
 			if (netif_queue_stopped(nport->netdev)
@@ -996,10 +1072,31 @@
 			}
 		}
 	}
+	/*
+	 * If everything is freed up to consumer then check if the ring is full
+	 * If the ring is full then check if more needs to be freed and
+	 * schedule the call back again.
+	 *
+	 * This happens when there are 2 CPUs. One could be freeing and the
+	 * other filling it. If the ring is full when we get out of here and
+	 * the card has already interrupted the host then the host can miss the
+	 * interrupt.
+	 *
+	 * There is still a possible race condition and the host could miss an
+	 * interrupt. The card has to take care of this.
+	 */
+	if (adapter->last_cmd_consumer == consumer &&
+	    (((adapter->cmd_producer + 1) %
+	      adapter->max_tx_desc_count) == adapter->last_cmd_consumer)) {
+		consumer = *(adapter->cmd_consumer);
+	}
+	done = (adapter->last_cmd_consumer == consumer);
+
 
 	spin_unlock(&adapter->tx_lock);
 	DPRINTK(INFO, "last consumer is %d in %s\n", last_consumer,
 		__FUNCTION__);
+	return (done);
 }
 
 /*
@@ -1007,12 +1104,132 @@
  */
 void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 {
+	struct pci_dev	   *pdev = adapter->ahw.pdev;
+	struct sk_buff	   *skb;
+	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctx]);
+	struct netxen_rcv_desc_ctx       *rcv_desc = NULL;
+	uint		      producer;
+	struct rcv_desc	  *pdesc;
+	struct netxen_rx_buffer  *buffer;
+	int		       count = 0;
+	int		       index = 0;
+	netxen_ctx_msg	    msg = 0;
+	dma_addr_t	    dma;
+	unsigned long	 bounce_flags;
+	struct bounce_index   tmpbi;
+
+	adapter->stats.post_called++;
+	rcv_desc     = &recv_ctx->rcv_desc[ringid];
+
+	producer = rcv_desc->producer;
+	index = rcv_desc->begin_alloc;
+	buffer   = &rcv_desc->rx_buf_arr[index];
+	/* We can start writing rx descriptors into the phantom memory. */
+	while (buffer->state == NETXEN_BUFFER_FREE) {
+		skb = dev_alloc_skb(rcv_desc->skb_size);
+		if(unlikely(!skb)) {
+		/*
+		 * TODO
+		 * We need to schedule the posting of buffers to the pegs.
+		 */
+			rcv_desc->begin_alloc = index;
+			DPRINTK(ERR, "netxen_post_rx_buffers: "
+					" allocated only %d buffers\n", count);
+			break;
+		}
+
+		count++ ;    /* now there should be no failure */
+		pdesc = &rcv_desc->desc_head[producer];
+
+#if defined(XGB_DEBUG)
+		*(unsigned long *)(skb->head) = 0xc0debabe;
+		if (skb_is_nonlinear(skb)) {
+			printk("Allocated SKB @%p is nonlinear\n");
+		}
+#endif
+		skb_reserve(skb, 2);
+		buffer->rx_bounce_buff = 0;
+		/* This will be setup when we receive the
+		 * buffer after it has been filled  FSL  TBD TBD
+		 * skb->dev = netdev;
+		 */
+		dma = pci_map_single(pdev, skb->data, rcv_desc->dma_size,
+				     PCI_DMA_FROMDEVICE);
+		if (dma + rcv_desc->dma_size > netxen_dma_mask) {
+			pci_unmap_single(pdev, dma, rcv_desc->dma_size,
+					 PCI_DMA_FROMDEVICE);
+			spin_lock_irqsave(&rx_bounce_lock, bounce_flags);
+			if (netxen_get_next_bounce_buffer(&rx_bounce_head, &rx_bounce_tail,
+				&tmpbi, rcv_desc->dma_size)) {
+
+				spin_unlock_irqrestore(&rx_bounce_lock, bounce_flags);
+				dev_kfree_skb_any(skb);
+				skb = NULL;
+				buffer->skb = NULL;
+				buffer->state  = NETXEN_BUFFER_FREE;
+				count--;
+				break;
+			}
+			spin_unlock_irqrestore(&rx_bounce_lock, bounce_flags);
+
+			buffer->rx_bounce_buff = IS_BOUNCE;
+			buffer->bnext = rx_bounce_head;
+			buffer->bounce_ptr  = rx_bounce_ptr[tmpbi.buffer_index] +
+						tmpbi.buffer_offset;
+			dma = pci_map_single(pdev, buffer->bounce_ptr,
+				rcv_desc->dma_size, PCI_DMA_FROMDEVICE);
+
+		}
+		pdesc->addr_buffer      = dma;
+		buffer->skb = skb;
+		buffer->state  = NETXEN_BUFFER_BUSY;
+		buffer->dma = dma;
+		/* make a rcv descriptor  */
+		pdesc->reference_handle = buffer->ref_handle;
+		pdesc->buffer_length    = rcv_desc->dma_size;
+		DPRINTK(INFO, "done writing descripter\n");
+		producer = get_next_index(producer, rcv_desc->max_rx_desc_count);
+		index = get_next_index(index, rcv_desc->max_rx_desc_count);
+		buffer   = &rcv_desc->rx_buf_arr[index];
+	}
+	/* if we did allocate buffers, then write the count to Phantom */
+	if (count) {
+		rcv_desc->begin_alloc = index;
+		rcv_desc->rcv_pending    += count;
+		adapter->stats.lastposted = count;
+		adapter->stats.posted    += count;
+		rcv_desc->producer	= producer;
+		if (rcv_desc->rcv_free >= 32) {
+			rcv_desc->rcv_free	= 0;
+			/* Window = 1 */
+			writel((producer-1)&
+				(rcv_desc->max_rx_desc_count-1),
+				NETXEN_CRB_NORMALIZE(adapter,
+						     recv_crb_registers[0].
+						     rcv_desc_crb[ringid].
+						     crb_rcv_producer_offset));
+			/*
+			 * Write a doorbell msg to tell phanmon of change in
+			 * receive ring producer
+			 */
+			netxen_set_msg_peg_id(msg, NETXEN_RCV_PEG_DB_ID);
+			netxen_set_msg_privid(msg);
+			netxen_set_msg_count(msg, ((producer-1) & (rcv_desc->max_rx_desc_count-1)));
+			netxen_set_msg_ctxid(msg, 0);
+			netxen_set_msg_opcode(msg, NETXEN_RCV_PRODUCER(ringid));
+			writel(msg,
+				DB_NORMALIZE(adapter, NETXEN_RCV_PRODUCER_OFFSET));
+		}
+	}
+}
+
+void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ctx,
+                        uint32_t ringid)
+{
 	struct pci_dev *pdev = adapter->ahw.pdev;
 	struct sk_buff *skb;
 	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctx]);
 	struct netxen_rcv_desc_ctx *rcv_desc = NULL;
-	struct netxen_recv_crb *crbarea = &recv_crb_registers[ctx];
-	struct netxen_rcv_desc_crb *rcv_desc_crb = NULL;
 	u32 producer;
 	struct rcv_desc *pdesc;
 	struct netxen_rx_buffer *buffer;
@@ -1023,26 +1240,25 @@
 
 	adapter->stats.post_called++;
 	rcv_desc = &recv_ctx->rcv_desc[ringid];
-	rcv_desc_crb = &crbarea->rcv_desc_crb[ringid];
 
 	producer = rcv_desc->producer;
 	index = rcv_desc->begin_alloc;
 	buffer = &rcv_desc->rx_buf_arr[index];
 	/* We can start writing rx descriptors into the phantom memory. */
-	while (buffer->state == NETXEN_BUFFER_FREE) {
+        while (buffer->state == NETXEN_BUFFER_FREE) {
 		skb = dev_alloc_skb(rcv_desc->skb_size);
 		if (unlikely(!skb)) {
 			/*
 			 * We need to schedule the posting of buffers to the pegs.
 			 */
 			rcv_desc->begin_alloc = index;
-			DPRINTK(ERR, "netxen_post_rx_buffers: "
+			DPRINTK(ERR, "netxen_post_rx_buffers_nodb: "
 				" allocated only %d buffers\n", count);
 			break;
 		}
 		count++;	/* now there should be no failure */
 		pdesc = &rcv_desc->desc_head[producer];
-		skb_reserve(skb, NET_IP_ALIGN);
+		skb_reserve(skb, 2);
 		buffer->rx_bounce_buff = 0;
 		/* 
 		 * This will be setup when we receive the
@@ -1106,8 +1322,7 @@
 			writel((producer - 1) &
 			       (rcv_desc->max_rx_desc_count - 1),
 			       NETXEN_CRB_NORMALIZE(adapter,
-						    rcv_desc_crb->
-						    crb_rcv_producer_offset));
+						    recv_crb_registers[0].rcv_desc_crb[ringid].crb_rcv_producer_offset));
 			wmb();
 		}
 	}
@@ -1239,7 +1454,7 @@
 
 	switch (data.cmd) {
 	case netxen_nic_cmd_pci_read:
-		if ((retval = netxen_nic_hw_read_wx(adapter, data.off,
+		if ((retval = netxen_nic_hw_read_ioctl(adapter, data.off,
 						    &(data.u), data.size)))
 			goto error_out;
 		if (copy_to_user
@@ -1253,8 +1468,34 @@
 		break;
 
 	case netxen_nic_cmd_pci_write:
-		data.rv = netxen_nic_hw_write_wx(adapter, data.off, &(data.u),
-						 data.size);
+		if((retval = netxen_nic_hw_write_ioctl(adapter, data.off,
+						    &(data.u), data.size)))
+			goto error_out;
+		data.rv = 0;
+		break;
+
+	case netxen_nic_cmd_pci_mem_read:
+		if(netxen_nic_pci_mem_read_ioctl(adapter, data.off, &(data.u),
+		   data.size)) {
+			DPRINTK(ERR, "Failed to read the data.\n");
+			retval = -EFAULT;
+			goto error_out;
+		}
+		if (copy_to_user
+		    ((void __user *)&(up_data->u), &(data.u), data.size)) {
+			DPRINTK(ERR, "bad copy to userland: %d\n",
+				(int)sizeof(data));
+			retval = -EFAULT;
+			goto error_out;
+		}
+		data.rv = 0;
+		break;
+
+	case netxen_nic_cmd_pci_mem_write:
+		if((retval = netxen_nic_pci_mem_write_ioctl(adapter, data.off,
+							 &(data.u), data.size)))
+			goto error_out;
+		data.rv = 0;
 		break;
 
 	case netxen_nic_cmd_pci_config_read:
@@ -1339,7 +1580,7 @@
 		retval = -EOPNOTSUPP;
 		goto error_out;
 	}
-	put_user(data.rv, (u16 __user *) (&(up_data->rv)));
+	put_user(data.rv, (&(up_data->rv)));
 	DPRINTK(INFO, "done ioctl for %p well.\n", adapter);
 
       error_out:
diff -u b/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
--- b/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -83,44 +83,39 @@
 	struct netxen_port *port;
 
 	/*  This should clear the interrupt source */
-	if (adapter->ops->phy_read)
-		adapter->ops->phy_read(adapter, portno,
+	if (adapter->phy_read)
+		adapter->phy_read(adapter, portno,
 				       NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
 				       &int_src);
 	if (int_src == 0) {
 		DPRINTK(INFO, "No phy interrupts for port #%d\n", portno);
 		return;
 	}
-	if (adapter->ops->disable_phy_interrupts)
-		adapter->ops->disable_phy_interrupts(adapter, portno);
+	if (adapter->disable_phy_interrupts)
+		adapter->disable_phy_interrupts(adapter, portno);
 
 	port = adapter->port[portno];
 
 	if (netxen_get_phy_int_jabber(int_src))
-		DPRINTK(INFO, "NetXen: %s Jabber interrupt \n",
-			port->netdev->name);
+		DPRINTK(INFO, "Jabber interrupt \n");
 
 	if (netxen_get_phy_int_polarity_changed(int_src))
-		DPRINTK(INFO, "NetXen: %s POLARITY CHANGED int \n",
-			port->netdev->name);
+		DPRINTK(INFO, "POLARITY CHANGED int \n");
 
 	if (netxen_get_phy_int_energy_detect(int_src))
-		DPRINTK(INFO, "NetXen: %s ENERGY DETECT INT \n",
-			port->netdev->name);
+		DPRINTK(INFO, "ENERGY DETECT INT \n");
 
 	if (netxen_get_phy_int_downshift(int_src))
-		DPRINTK(INFO, "NetXen: %s DOWNSHIFT INT \n",
-			port->netdev->name);
+		DPRINTK(INFO, "DOWNSHIFT INT \n");
 	/* write it down later.. */
 	if ((netxen_get_phy_int_speed_changed(int_src))
 	    || (netxen_get_phy_int_link_status_changed(int_src))) {
 		__le32 status;
 
-		DPRINTK(INFO, "NetXen: %s SPEED CHANGED OR"
-			" LINK STATUS CHANGED \n", port->netdev->name);
+		DPRINTK(INFO, "SPEED CHANGED OR LINK STATUS CHANGED \n");
 
-		if (adapter->ops->phy_read
-		    && adapter->ops->phy_read(adapter, portno,
+		if (adapter->phy_read
+		    && adapter->phy_read(adapter, portno,
 					      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					      &status) == 0) {
 			if (netxen_get_phy_int_link_status_changed(int_src)) {
@@ -142,8 +137,8 @@
 			}
 		}
 	}
-	if (adapter->ops->enable_phy_interrupts)
-		adapter->ops->enable_phy_interrupts(adapter, portno);
+	if (adapter->enable_phy_interrupts)
+		adapter->enable_phy_interrupts(adapter, portno);
 }
 
 void netxen_nic_isr_other(struct netxen_adapter *adapter)
@@ -158,8 +153,7 @@
 
 	qg_linksup = adapter->ahw.qg_linksup;
 	adapter->ahw.qg_linksup = val;
-	DPRINTK(1, INFO, "%s: link update 0x%08x\n", netxen_nic_driver_name,
-		val);
+	DPRINTK(INFO, "link update 0x%08x\n", val);
 	for (portno = 0; portno < NETXEN_NIU_MAX_GBE_PORTS; portno++) {
 		linkup = val & 1;
 		if (linkup != (qg_linksup & 1)) {
diff -u b/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
--- b/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -6,12 +6,12 @@
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
  * of the License, or (at your option) any later version.
- *                            
+ *
  * This program is distributed in the hope that it will be useful, but
  * WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
- *                                   
+ *
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
@@ -32,6 +32,7 @@
  */
 
 #include <linux/vmalloc.h>
+#include <linux/highmem.h>
 #include "netxen_nic_hw.h"
 
 #include "netxen_nic.h"
@@ -52,6 +53,8 @@
 static char netxen_nic_driver_string[] = "NetXen Network Driver version "
     NETXEN_NIC_LINUX_VERSIONID;
 
+struct netxen_adapter* g_adapter = NULL;
+
 #define NETXEN_NETDEV_WEIGHT 120
 #define NETXEN_ADAPTER_UP_MAGIC 777
 #define NETXEN_NIC_PEG_TUNE 0
@@ -60,11 +63,16 @@
 #define NUM_BOUNCE 256
 char *tx_bounce_ptr[NUM_BOUNCE];
 char *rx_bounce_ptr[NUM_BOUNCE];
+u8 nx_p2_id = NX_P2_C0;
+
+#define DMA_32BIT_MASK	0x00000000ffffffffULL
+#define DMA_35BIT_MASK	0x00000007ffffffffULL
 
 struct bounce_index tx_bounce_head, tx_bounce_tail,
     rx_bounce_head, rx_bounce_tail;
 
 spinlock_t rx_bounce_lock, tx_bounce_lock;
+unsigned long long netxen_dma_mask = DMA_35BIT_MASK;
 
 #define BOUNCE_BUFFER_ORDER 2
 #define BOUNCE_BUFFER_SIZE (PAGE_SIZE << BOUNCE_BUFFER_ORDER)
@@ -100,6 +108,9 @@
 
 MODULE_DEVICE_TABLE(pci, netxen_pci_tbl);
 
+struct workqueue_struct *netxen_workq;
+static void   netxen_watchdog(unsigned long);
+
 /*
  * Whenever we cross the 16K boundary of bounce buffer, we use the next
  * 16K buffer and wrap up if its the last buffer.
@@ -230,16 +241,24 @@
 	void __iomem *mem_ptr1 = NULL;
 	void __iomem *mem_ptr2 = NULL;
 
-	unsigned long mem_base, mem_len;
+	u8 *db_ptr  = NULL;
+	unsigned long mem_base, mem_len, db_base, db_len;
 	int pci_using_dac, i, err;
 	int ring;
 	struct netxen_recv_context *recv_ctx = NULL;
 	struct netxen_rcv_desc_ctx *rcv_desc = NULL;
 	struct netxen_cmd_buffer *cmd_buf_arr = NULL;
 	u64 mac_addr[FLASH_NUM_PORTS + 1];
-	int valid_mac;
+	int valid_mac = 0;
+	static int netxen_cards_found = 0;
 
 	printk(KERN_INFO "%s \n", netxen_nic_driver_string);
+	/* In current scheme, we use only PCI function 0 */
+	if (PCI_FUNC(pdev->devfn) != 0) {
+		DPRINTK(ERR, "NetXen function %d will not be enabled.\n",
+			PCI_FUNC(pdev->devfn) );
+		return -ENODEV;
+	}
 	if ((err = pci_enable_device(pdev)))
 		return err;
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
@@ -251,15 +270,19 @@
 		goto err_out_disable_pdev;
 
 	pci_set_master(pdev);
-	if ((pci_set_dma_mask(pdev, DMA_64BIT_MASK) == 0) &&
-	    (pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK) == 0))
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &nx_p2_id);
+	if (nx_p2_id == NX_P2_C1 &&
+	    (pci_set_dma_mask(pdev, PCI_DMA_64BIT) == 0) &&
+	    (pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK) == 0)) {
 		pci_using_dac = 1;
-	else {
+		netxen_dma_mask = DMA_35BIT_MASK;
+	} else {
 		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) ||
 		    (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)))
 			goto err_out_free_res;
 
 		pci_using_dac = 0;
+		netxen_dma_mask = DMA_32BIT_MASK;
 	}
 
 	/* remap phys address */
@@ -274,21 +297,34 @@
 	    ioremap(mem_base + THIRD_PAGE_GROUP_START, THIRD_PAGE_GROUP_SIZE);
 
 	if ((mem_ptr0 == 0UL) || (mem_ptr1 == 0UL) || (mem_ptr2 == 0UL)) {
-		DPRINTK(1, ERR,
+		DPRINTK(ERR,
 			"Cannot remap adapter memory aborting.:"
 			"0 -> %p, 1 -> %p, 2 -> %p\n",
 			mem_ptr0, mem_ptr1, mem_ptr2);
 
 		err = -EIO;
-		if (mem_ptr0)
-			iounmap(mem_ptr0);
-		if (mem_ptr1)
-			iounmap(mem_ptr1);
-		if (mem_ptr2)
-			iounmap(mem_ptr2);
+		goto err_out_free_res;
+	}
+	db_base = pci_resource_start(pdev, 4);  /* doorbell is on bar 4 */
+	db_len  = pci_resource_len(pdev, 4);
 
+	if (db_len == 0) {
+		printk(KERN_ERR"%s: doorbell is disabled\n",
+			netxen_nic_driver_name);
+		err = -EIO;
 		goto err_out_free_res;
 	}
+	DPRINTK(INFO, "doorbell ioremap from %lx a size of %lx\n", db_base,
+		db_len);
+
+	db_ptr = ioremap(db_base, NETXEN_DB_MAPSIZE_BYTES);
+	if (db_ptr == 0UL) {
+		printk(KERN_ERR"%s: Failed to allocate doorbell map.",
+			netxen_nic_driver_name);
+		err = -EIO;
+		goto err_out_free_res;
+	}
+	DPRINTK(INFO, "doorbell ioremaped at %p\n", db_ptr);
 
 /*
  *      Allocate a adapter structure which will manage all the initialization
@@ -307,14 +343,20 @@
 		goto err_out_iounmap;
 	}
 
+	 if (netxen_cards_found == 0) {
+		g_adapter = adapter;
+	}
 	adapter->max_tx_desc_count = MAX_CMD_DESCRIPTORS;
 	adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS;
 	adapter->max_jumbo_rx_desc_count = MAX_JUMBO_RCV_DESCRIPTORS;
+	adapter->max_lro_rx_desc_count   = MAX_LRO_RCV_DESCRIPTORS;
 
 	pci_set_drvdata(pdev, adapter);
 
 	cmd_buf_arr = (struct netxen_cmd_buffer *)vmalloc(TX_RINGSIZE);
 	if (cmd_buf_arr == NULL) {
+		printk(KERN_ERR "%s: Could not allocate cmd_buf_arr memory:%d\n",
+			netxen_nic_driver_name, (int)TX_RINGSIZE);
 		err = -ENOMEM;
 		goto err_out_free_adapter;
 	}
@@ -348,11 +390,24 @@
 				rcv_desc->skb_size = MAX_RX_JUMBO_BUFFER_LENGTH;
 				break;
 
+			case RCV_RING_LRO:
+				rcv_desc->max_rx_desc_count =
+					adapter->max_lro_rx_desc_count;
+				rcv_desc->flags = RCV_DESC_LRO;
+				rcv_desc->dma_size = RX_LRO_DMA_MAP_LEN;
+				rcv_desc->skb_size =
+					MAX_RX_LRO_BUFFER_LENGTH;
+				break;
+
 			}
 			rcv_desc->rx_buf_arr = (struct netxen_rx_buffer *)
-			    vmalloc(RCV_BUFFSIZE);
+						vmalloc(RCV_BUFFSIZE);
 
 			if (rcv_desc->rx_buf_arr == NULL) {
+				printk(KERN_ERR "%s: Could not allocate"
+					"rcv_desc->rx_buf_arr memory:%d\n",
+					netxen_nic_driver_name,
+					(int)RCV_BUFFSIZE);
 				err = -ENOMEM;
 				goto err_out_free_rx_buffer;
 			}
@@ -361,30 +416,21 @@
 
 	}
 
-	adapter->ops = kzalloc(sizeof(struct netxen_drvops), GFP_KERNEL);
-	if (adapter->ops == NULL) {
-		printk(KERN_ERR
-		       "%s: Could not allocate memory for adapter->ops:%d\n",
-		       netxen_nic_driver_name,
-		       (int)sizeof(struct netxen_adapter));
-		err = -ENOMEM;
-		goto err_out_free_rx_buffer;
-	}
-
 	adapter->cmd_buf_arr = cmd_buf_arr;
 	adapter->ahw.pci_base0 = mem_ptr0;
 	adapter->ahw.pci_base1 = mem_ptr1;
 	adapter->ahw.pci_base2 = mem_ptr2;
+	adapter->ahw.db_base   = db_ptr;
+	adapter->ahw.db_len    = db_len;
 	spin_lock_init(&adapter->tx_lock);
 	spin_lock_init(&adapter->lock);
+	netxen_initialize_adapter_sw(adapter); /* initialize the buffers in adapter */
 #ifdef CONFIG_IA64
 	netxen_pinit_from_rom(adapter, 0);
 	udelay(500);
 	netxen_load_firmware(adapter);
 #endif
 
-	/* initialize the buffers in adapter */
-	netxen_initialize_adapter_sw(adapter);
 	/*
 	 * Set the CRB window to invalid. If any register in window 0 is
 	 * accessed it should set the window to 0 and then reset it to 1.
@@ -406,7 +452,7 @@
 		  (void (*)(void *))netxen_watchdog_task, adapter);
 	adapter->ahw.pdev = pdev;
 	adapter->proc_cmd_buf_counter = 0;
-	pci_read_config_byte(pdev, PCI_REVISION_ID, &adapter->ahw.revision_id);
+	adapter->ahw.revision_id = nx_p2_id;
 
 	if (pci_enable_msi(pdev)) {
 		adapter->flags &= ~NETXEN_NIC_MSI_ENABLED;
@@ -428,6 +474,12 @@
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMD_CONSUMER_OFFSET));
 	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_LO));
 
+	/* do this before waking up pegs so that we have valid dummy dma addr*/
+	err = netxen_initialize_adapter_offload(adapter);
+	if (err) {
+		goto err_out_free_dev;
+	}
+
 	/* Unlock the HW, prompting the boot sequence */
 	writel(1,
 	       NETXEN_CRB_NORMALIZE(adapter, NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
@@ -502,13 +554,13 @@
 				       netdev->dev_addr[4],
 				       netdev->dev_addr[5]);
 			} else {
-				if (adapter->ops->macaddr_set)
-					adapter->ops->macaddr_set(port,
+				if (adapter->macaddr_set)
+					adapter->macaddr_set(port,
 								  netdev->
 								  dev_addr);
 			}
 		}
-		INIT_WORK(&adapter->tx_timeout_task,
+		INIT_WORK(adapter->tx_timeout_task + i,
 			  (void (*)(void *))netxen_tx_timeout_task, netdev);
 		netif_carrier_off(netdev);
 		netif_stop_queue(netdev);
@@ -541,6 +593,7 @@
 		break;
 	}
 
+	adapter->number = netxen_cards_found;
 	adapter->driver_mismatch = 0;
 
 	return 0;
@@ -555,7 +608,8 @@
 			free_netdev(port->netdev);
 		}
 	}
-	kfree(adapter->ops);
+
+	netxen_free_adapter_offload(adapter);
 
       err_out_free_rx_buffer:
 	for (i = 0; i < MAX_RCV_CTX; ++i) {
@@ -577,11 +631,16 @@
 	kfree(adapter);
 
       err_out_iounmap:
-	iounmap(mem_ptr0);
-	iounmap(mem_ptr1);
-	iounmap(mem_ptr2);
+	iounmap(db_ptr);
 
       err_out_free_res:
+	if (mem_ptr0)
+		iounmap(mem_ptr0);
+	if (mem_ptr1)
+		iounmap(mem_ptr1);
+	if (mem_ptr2)
+		iounmap(mem_ptr2);
+
 	pci_release_regions(pdev);
       err_out_disable_pdev:
 	pci_disable_device(pdev);
@@ -605,12 +664,8 @@
 
 	netxen_nic_stop_all_ports(adapter);
 	/* leave the hw in the same state as reboot */
-	netxen_pinit_from_rom(adapter, 0);
-	udelay(500);
 	netxen_load_firmware(adapter);
-
-	if ((adapter->flags & NETXEN_NIC_MSI_ENABLED))
-		netxen_nic_disable_int(adapter);
+	netxen_free_adapter_offload(adapter);
 
 	udelay(500);		/* Delay for a while to drain the DMA engines */
 	for (i = 0; i < adapter->port_count; i++) {
@@ -627,6 +682,7 @@
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC)
 		netxen_free_hw_resources(adapter);
 
+	iounmap(adapter->ahw.db_base);
 	iounmap(adapter->ahw.pci_base0);
 	iounmap(adapter->ahw.pci_base1);
 	iounmap(adapter->ahw.pci_base2);
@@ -653,7 +709,6 @@
 	}
 
 	vfree(adapter->cmd_buf_arr);
-	kfree(adapter->ops);
 	kfree(adapter);
 }
 
@@ -675,6 +730,8 @@
 			return -EIO;
 		}
 		netxen_nic_flash_print(adapter);
+		if (adapter->init_niu)
+			adapter->init_niu(adapter);
 
 		/* setup all the resources for the Phantom... */
 		/* this include the descriptors for rcv, tx, and status */
@@ -685,32 +742,31 @@
 			       err);
 			return err;
 		}
-		if (adapter->ops->init_port
-		    && adapter->ops->init_port(adapter, port->portnum) != 0) {
+		if (adapter->init_port
+		    && adapter->init_port(adapter, port->portnum) != 0) {
 			printk(KERN_ERR "%s: Failed to initialize port %d\n",
 			       netxen_nic_driver_name, port->portnum);
 			netxen_free_hw_resources(adapter);
 			return -EIO;
 		}
-		if (adapter->ops->init_niu)
-			adapter->ops->init_niu(adapter);
 		for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
 			for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++)
 				netxen_post_rx_buffers(adapter, ctx, ring);
 		}
-		adapter->is_up = NETXEN_ADAPTER_UP_MAGIC;
-	}
-	adapter->active_ports++;
-	if (adapter->active_ports == 1) {
+		adapter->irq = adapter->ahw.pdev->irq;
 		err = request_irq(adapter->ahw.pdev->irq, &netxen_intr,
 				  SA_SHIRQ | SA_SAMPLE_RANDOM, netdev->name,
 				  adapter);
 		if (err) {
 			printk(KERN_ERR "request_irq failed with: %d\n", err);
-			adapter->active_ports--;
+			netxen_free_hw_resources(adapter);
 			return err;
 		}
-		adapter->irq = adapter->ahw.pdev->irq;
+
+		adapter->is_up = NETXEN_ADAPTER_UP_MAGIC;
+	}
+	adapter->active_ports++;
+	if (adapter->active_ports == 1) {
 		if (!adapter->driver_mismatch)
 			mod_timer(&adapter->watchdog_timer, jiffies);
 
@@ -719,13 +775,13 @@
 
 	/* Done here again so that even if phantom sw overwrote it,
 	 * we set it */
-	if (adapter->ops->macaddr_set)
-		adapter->ops->macaddr_set(port, netdev->dev_addr);
+	if (adapter->macaddr_set)
+		adapter->macaddr_set(port, netdev->dev_addr);
 	netxen_nic_set_link_parameters(port);
 
 	netxen_nic_set_multi(netdev);
-	if (adapter->ops->set_mtu)
-		adapter->ops->set_mtu(port, netdev->mtu);
+	if (adapter->set_mtu)
+		adapter->set_mtu(port, netdev->mtu);
 
 	if (!adapter->driver_mismatch)
 		netif_start_queue(netdev);
@@ -779,6 +835,7 @@
 			}
 			cmd_buff++;
 		}
+		FLUSH_SCHEDULED_WORK();
 		del_timer_sync(&adapter->watchdog_timer);
 	}
 
@@ -799,7 +856,6 @@
 	struct cmd_desc_type0 *hwdesc;
 	int k;
 	struct netxen_cmd_buffer *pbuf = NULL;
-	unsigned int tries = 0;
 	static int dropped_packet = 0;
 	int frag_count;
 	u32 local_producer = 0;
@@ -864,7 +920,7 @@
 			if (((skb->nh.iph)->ihl * sizeof(u32)) +
 			    ((skb->h.th)->doff * sizeof(u32)) +
 			    sizeof(struct ethhdr) >
-			    (sizeof(struct cmd_desc_type0) - NET_IP_ALIGN)) {
+			    (sizeof(struct cmd_desc_type0) - 2)) {
 				no_of_desc++;
 			}
 		}
@@ -875,27 +931,17 @@
 	if ((k + no_of_desc) >=
 	    ((last_cmd_consumer <= k) ? last_cmd_consumer + max_tx_desc_count :
 	     last_cmd_consumer)) {
-		spin_unlock_bh(&adapter->tx_lock);
-		if (tries == 0) {
-			local_bh_disable();
-			netxen_process_cmd_ring((unsigned long)adapter);
-			local_bh_enable();
-			++tries;
-			goto retry_getting_window;
-		} else {
-			port->stats.nocmddescriptor++;
-			DPRINTK(ERR, "No command descriptors available,"
-				" producer = %d, consumer = %d count=%llu,"
-				" dropping packet\n", producer,
-				adapter->last_cmd_consumer,
-				port->stats.nocmddescriptor);
+		port->stats.nocmddescriptor++;
+		DPRINTK(ERR, "No command descriptors available,"
+			" producer = %d, consumer = %d count=%llu,"
+			" dropping packet\n", producer,
+			adapter->last_cmd_consumer,
+			port->stats.nocmddescriptor);
 
-			spin_lock_bh(&adapter->tx_lock);
 			netif_stop_queue(netdev);
 			port->flags |= NETXEN_NETDEV_STATUS;
 			spin_unlock_bh(&adapter->tx_lock);
 			return NETDEV_TX_BUSY;
-		}
 	}
 	k = get_index_range(k, max_tx_desc_count, no_of_desc);
 	adapter->cmd_producer = k;
@@ -917,7 +963,6 @@
 		pbuf->mss = 0;
 		hwdesc->mss = 0;
 	}
-	pbuf->no_of_descriptors = no_of_desc;
 	pbuf->total_length = skb->len;
 	pbuf->skb = skb;
 	pbuf->cmd = TX_ETHER_PKT;
@@ -928,11 +973,11 @@
 				      PCI_DMA_TODEVICE);
 	pbuf->tx_bounce_buff = 0;
 	buffrag->length = first_seg_len;
-	CMD_DESC_TOTAL_LENGTH_WRT(hwdesc, skb->len);
-	hwdesc->num_of_buffers = frag_count;
-	hwdesc->opcode = TX_ETHER_PKT;
+	netxen_set_cmd_desc_totallength(hwdesc, skb->len);
+	netxen_set_cmd_desc_num_of_buff(hwdesc, frag_count);
+	netxen_set_cmd_desc_opcode(hwdesc, TX_ETHER_PKT);
 
-	CMD_DESC_PORT_WRT(hwdesc, port->portnum);
+	netxen_set_cmd_desc_port(hwdesc, port->portnum);
 	hwdesc->buffer1_length = cpu_to_le16(first_seg_len);
 	hwdesc->addr_buffer1 = cpu_to_le64(buffrag->dma);
 
@@ -1007,8 +1052,10 @@
 						bounce_page_offset, len,
 						PCI_DMA_TODEVICE);
 			buffrag->dma = temp_dma;
-			memcpy(bounce_data, page_address(frag->page) + offset,
-			       len);
+			memcpy(bounce_data, kmap_atomic(frag->page,
+							KM_SKB_DATA_SOFTIRQ)
+							+ offset, len);
+			kunmap(frag->page);
 			pbuf->bnext = tx_bounce_head;
 		}
 
@@ -1041,12 +1088,13 @@
 	/* For LSO, we need to copy the MAC/IP/TCP headers into
 	 * the descriptor ring
 	 */
-	if (hw->cmd_desc_head[saved_producer].opcode == TX_TCP_LSO) {
+	if (netxen_get_cmd_desc_opcode(&hw->cmd_desc_head[saved_producer])
+					== TX_TCP_LSO) {
 		int hdr_len, first_hdr_len, more_hdr;
 		hdr_len = hw->cmd_desc_head[saved_producer].total_hdr_length;
-		if (hdr_len > (sizeof(struct cmd_desc_type0) - NET_IP_ALIGN)) {
+		if (hdr_len > (sizeof(struct cmd_desc_type0) - 2)) {
 			first_hdr_len =
-			    sizeof(struct cmd_desc_type0) - NET_IP_ALIGN;
+			    sizeof(struct cmd_desc_type0) - 2;
 			more_hdr = 1;
 		} else {
 			first_hdr_len = hdr_len;
@@ -1056,7 +1104,7 @@
 		hwdesc = &hw->cmd_desc_head[producer];
 
 		/* copy the first 64 bytes */
-		memcpy(((void *)hwdesc) + NET_IP_ALIGN,
+		memcpy(((void *)hwdesc) + 2,
 		       (void *)(skb->data), first_hdr_len);
 		producer = get_next_index(producer, max_tx_desc_count);
 
@@ -1072,7 +1120,8 @@
 	}
 	spin_lock_bh(&adapter->tx_lock);
 	port->stats.txbytes +=
-	    CMD_DESC_TOTAL_LENGTH(&hw->cmd_desc_head[saved_producer]);
+		netxen_get_cmd_desc_totallength(&hw->cmd_desc_head[
+							saved_producer]);
 	/* Code to update the adapter considering how many producer threads
 	   are currently working */
 	if ((--adapter->num_threads) == 0) {
@@ -1082,20 +1131,6 @@
 		       NETXEN_CRB_NORMALIZE(adapter, CRB_CMD_PRODUCER_OFFSET));
 		wmb();
 		adapter->total_threads = 0;
-	} else {
-		u32 crb_producer = 0;
-		crb_producer =
-		    readl(NETXEN_CRB_NORMALIZE
-			  (adapter, CRB_CMD_PRODUCER_OFFSET));
-		if (crb_producer == local_producer) {
-			crb_producer = get_index_range(crb_producer,
-						       max_tx_desc_count,
-						       no_of_desc);
-			writel(crb_producer,
-			       NETXEN_CRB_NORMALIZE(adapter,
-						    CRB_CMD_PRODUCER_OFFSET));
-			wmb();
-		}
 	}
 
 	port->stats.xmitfinished++;
@@ -1112,15 +1147,20 @@
 static void netxen_watchdog(unsigned long v)
 {
 	struct netxen_adapter *adapter = (struct netxen_adapter *)v;
-	schedule_work(&adapter->watchdog_task);
+       if (adapter != g_adapter) {
+		printk("%s: ***BUG*** adapter[%p] != g_adapter[%p]\n",
+			__FUNCTION__, adapter, g_adapter);
+		return;
+       }
+
+       SCHEDULE_WORK(&adapter->watchdog_task);
 }
 
 static void netxen_tx_timeout(struct net_device *netdev)
 {
 	struct netxen_port *port = (struct netxen_port *)netdev_priv(netdev);
-	struct netxen_adapter *adapter = port->adapter;
 
-	schedule_work(&adapter->tx_timeout_task);
+	SCHEDULE_WORK(port->adapter->tx_timeout_task + port->portnum);
 }
 
 static void netxen_tx_timeout_task(struct net_device *netdev)
@@ -1151,6 +1191,11 @@
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		int count = 0;
 		u32 mask;
+		mask = readl(pci_base_offset(adapter, ISR_INT_VECTOR));
+		if ((mask & 0x80) == 0) {
+			/* not our interrupt */
+			return ret;
+		}
 		netxen_nic_disable_int(adapter);
 		/* Window = 0 or 1 */
 		do {
@@ -1212,7 +1257,10 @@
 		netdev = port->netdev;
 
 		/* process our status queue (for all 4 ports) */
-		netxen_handle_int(adapter, netdev);
+		if(netif_running(netdev)) {
+			netxen_handle_int(adapter, netdev);
+			break;
+		}
 	}
 
 	return IRQ_HANDLED;
@@ -1226,11 +1274,12 @@
 	int done = 1;
 	int ctx;
 	int this_work_done;
+	int work_done = 0;
 
 	DPRINTK(INFO, "polling for %d descriptors\n", *budget);
 	port->stats.polled++;
 
-	adapter->work_done = 0;
+	work_done = 0;
 	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
 		/*
 		 * Fairness issue. This will give undue weight to the
@@ -1247,20 +1296,21 @@
 		this_work_done = netxen_process_rcv_ring(adapter, ctx,
 							 work_to_do /
 							 MAX_RCV_CTX);
-		adapter->work_done += this_work_done;
+		work_done += this_work_done;
 	}
 
-	netdev->quota -= adapter->work_done;
-	*budget -= adapter->work_done;
+	netdev->quota -= work_done;
+	*budget -= work_done;
 
-	if (adapter->work_done >= work_to_do
+	if (work_done >= work_to_do
 	    && netxen_nic_rx_has_work(adapter) != 0)
 		done = 0;
 
-	netxen_process_cmd_ring((unsigned long)adapter);
+	if(netxen_process_cmd_ring((unsigned long)adapter) == 0)
+		done = 0;
 
 	DPRINTK(INFO, "new work_done: %d work_to_do: %d\n",
-		adapter->work_done, work_to_do);
+		work_done, work_to_do);
 	if (done) {
 		netif_rx_complete(netdev);
 		netxen_nic_enable_int(adapter);
@@ -1332,6 +1382,9 @@
 
 static int __init netxen_init_module(void)
 {
+	if((netxen_workq = create_singlethread_workqueue("netxen")) == 0)
+		return -ENOMEM;
+
 	return pci_module_init(&netxen_driver);
 }
 
@@ -1342,7 +1395,7 @@
 	/*
 	 * Wait for some time to allow the dma to drain, if any.
 	 */
-	mdelay(5);
+	destroy_workqueue(netxen_workq);
 	pci_unregister_driver(&netxen_driver);
 }
 
diff -u b/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
--- b/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -33,15 +33,74 @@
 /* 
  * CRB Registers or queue message done only at initialization time.
  */
+#define NIC_CRB_BASE               NETXEN_CAM_RAM(0x200)
+#define NETXEN_NIC_REG(X)             (NIC_CRB_BASE+(X))
 
-/*
- * The following 2 are the base adresses for the CRB registers and their
- * offsets will be added to get addresses for the index addresses.
- */
-#define NIC_CRB_BASE_PORT1	NETXEN_CAM_RAM(0x200)
-#define NIC_CRB_BASE_PORT2	NETXEN_CAM_RAM(0x250)
-
-#define NETXEN_NIC_REG(X)	(NIC_CRB_BASE_PORT1+(X))
+#define CRB_PHAN_CNTRL_LO_OFFSET    NETXEN_NIC_REG(0x00)
+#define CRB_PHAN_CNTRL_HI_OFFSET    NETXEN_NIC_REG(0x04)
+#define CRB_CMD_PRODUCER_OFFSET     NETXEN_NIC_REG(0x08)
+#define CRB_CMD_CONSUMER_OFFSET     NETXEN_NIC_REG(0x0c)
+#define CRB_PAUSE_ADDR_LO           NETXEN_NIC_REG(0x10) /* C0 EPG BUG  */
+#define CRB_PAUSE_ADDR_HI           NETXEN_NIC_REG(0x14)
+#define CRB_HOST_CMD_ADDR_HI        NETXEN_NIC_REG(0x18) /* host add:cmd ring */
+#define CRB_HOST_CMD_ADDR_LO        NETXEN_NIC_REG(0x1c)
+#define CRB_CMD_INTR_LOOP           NETXEN_NIC_REG(0x20) /* 4 regs for perf */
+#define CRB_CMD_DMA_LOOP            NETXEN_NIC_REG(0x24)
+#define CRB_RCV_INTR_LOOP           NETXEN_NIC_REG(0x28)
+#define CRB_RCV_DMA_LOOP            NETXEN_NIC_REG(0x2c)
+#define CRB_ENABLE_TX_INTR          NETXEN_NIC_REG(0x30) /* phantom init status */
+#define CRB_MMAP_ADDR_3             NETXEN_NIC_REG(0x34)
+#define CRB_CMDPEG_CMDRING          NETXEN_NIC_REG(0x38)
+#define CRB_HOST_DUMMY_BUF_ADDR_HI  NETXEN_NIC_REG(0x3c)
+#define CRB_HOST_DUMMY_BUF_ADDR_LO  NETXEN_NIC_REG(0x40)
+#define CRB_MMAP_ADDR_0             NETXEN_NIC_REG(0x44)
+#define CRB_MMAP_ADDR_1             NETXEN_NIC_REG(0x48)
+#define CRB_MMAP_ADDR_2             NETXEN_NIC_REG(0x4c)
+#define CRB_CMDPEG_STATE            NETXEN_NIC_REG(0x50)
+#define CRB_MMAP_SIZE_0             NETXEN_NIC_REG(0x54)
+#define CRB_MMAP_SIZE_1             NETXEN_NIC_REG(0x58)
+#define CRB_MMAP_SIZE_2             NETXEN_NIC_REG(0x5c)
+#define CRB_MMAP_SIZE_3             NETXEN_NIC_REG(0x60)
+#define CRB_GLOBAL_INT_COAL         NETXEN_NIC_REG(0x64) /* interrupt coalescing */
+#define CRB_INT_COAL_MODE           NETXEN_NIC_REG(0x68)
+#define CRB_MAX_RCV_BUFS            NETXEN_NIC_REG(0x6c)
+#define CRB_TX_INT_THRESHOLD        NETXEN_NIC_REG(0x70)
+#define CRB_RX_PKT_TIMER            NETXEN_NIC_REG(0x74)
+#define CRB_TX_PKT_TIMER            NETXEN_NIC_REG(0x78)
+#define CRB_RX_PKT_CNT              NETXEN_NIC_REG(0x7c)
+#define CRB_RX_TMR_CNT              NETXEN_NIC_REG(0x80)
+#define CRB_RX_LRO_TIMER            NETXEN_NIC_REG(0x84)
+#define CRB_RX_LRO_MID_TIMER        NETXEN_NIC_REG(0x88)
+#define CRB_DMA_MAX_RCV_BUFS        NETXEN_NIC_REG(0x8c)
+#define CRB_MAX_DMA_ENTRIES         NETXEN_NIC_REG(0x90)
+#define CRB_XG_STATE                NETXEN_NIC_REG(0x94) /* XG Link status */
+#define CRB_AGENT_GO                NETXEN_NIC_REG(0x98) /* NIC pkt gen agent */
+#define CRB_AGENT_TX_SIZE           NETXEN_NIC_REG(0x9c)
+#define CRB_AGENT_TX_TYPE           NETXEN_NIC_REG(0xa0)
+#define CRB_AGENT_TX_ADDR           NETXEN_NIC_REG(0xa4)
+#define CRB_AGENT_TX_MSS            NETXEN_NIC_REG(0xa8)
+#define CRB_TX_STATE                NETXEN_NIC_REG(0xac) /* Debug -performance */
+#define CRB_TX_COUNT                NETXEN_NIC_REG(0xb0)
+#define CRB_RX_STATE                NETXEN_NIC_REG(0xb4)
+#define CRB_RX_PERF_DEBUG_1         NETXEN_NIC_REG(0xb8)
+#define CRB_RX_LRO_CONTROL          NETXEN_NIC_REG(0xbc) /* LRO On/OFF */
+#define CRB_RX_LRO_START_NUM        NETXEN_NIC_REG(0xc0)
+#define CRB_MPORT_MODE              NETXEN_NIC_REG(0xc4) /* Multiport Mode */
+#define CRB_CMD_RING_SIZE           NETXEN_NIC_REG(0xc8)
+#define CRB_INT_VECTOR              NETXEN_NIC_REG(0xd4)
+#define CRB_CTX_RESET               NETXEN_NIC_REG(0xd8)
+#define CRB_HOST_STS_PROD           NETXEN_NIC_REG(0xdc)
+#define CRB_HOST_STS_CONS           NETXEN_NIC_REG(0xe0)
+#define CRB_PEG_CMD_PROD            NETXEN_NIC_REG(0xe4)
+#define CRB_PEG_CMD_CONS            NETXEN_NIC_REG(0xe8)
+#define CRB_HOST_BUFFER_PROD        NETXEN_NIC_REG(0xec)
+#define CRB_HOST_BUFFER_CONS        NETXEN_NIC_REG(0xf0)
+#define CRB_JUMBO_BUFFER_PROD       NETXEN_NIC_REG(0xf4)
+#define CRB_JUMBO_BUFFER_CONS       NETXEN_NIC_REG(0xf8)
+
+#define CRB_CMD_PRODUCER_OFFSET_1   NETXEN_NIC_REG(0x1ac)
+#define CRB_CMD_CONSUMER_OFFSET_1   NETXEN_NIC_REG(0x1b0)
+#define CRB_TEMP_STATE              NETXEN_NIC_REG(0x1b4)
 
 /*
  * CrbPortPhanCntrHi/Lo is used to pass the address of HostPhantomIndex address
@@ -51,74 +110,20 @@
  * on the Phantom.
  */
 
-#define CRB_PHAN_CNTRL_LO_OFFSET	NETXEN_NIC_REG(0x00)
-#define CRB_PHAN_CNTRL_HI_OFFSET	NETXEN_NIC_REG(0x04)
-
-/* point to the indexes */
-#define CRB_CMD_PRODUCER_OFFSET		NETXEN_NIC_REG(0x08)
-#define CRB_CMD_CONSUMER_OFFSET		NETXEN_NIC_REG(0x0c)
-
-#define CRB_PAUSE_ADDR_LO		NETXEN_NIC_REG(0x10)
-#define CRB_PAUSE_ADDR_HI		NETXEN_NIC_REG(0x14)
-
-/* address of command descriptors in the host memory */
-#define CRB_HOST_CMD_ADDR_HI		NETXEN_NIC_REG(0x30)
-#define CRB_HOST_CMD_ADDR_LO		NETXEN_NIC_REG(0x34)
-
-/* The following 4 CRB registers are for doing performance coal */
-#define CRB_CMD_INTR_LOOP		NETXEN_NIC_REG(0x38)
-#define CRB_CMD_DMA_LOOP		NETXEN_NIC_REG(0x3c)
-#define CRB_RCV_INTR_LOOP		NETXEN_NIC_REG(0x40)
-#define CRB_RCV_DMA_LOOP		NETXEN_NIC_REG(0x44)
-
-/* Needed by the host to find out the state of Phantom's initialization */
-#define CRB_ENABLE_TX_INTR		NETXEN_NIC_REG(0x4c)
-#define CRB_CMDPEG_STATE		NETXEN_NIC_REG(0x50)
-#define CRB_CMDPEG_CMDRING		NETXEN_NIC_REG(0x54)
-
-/* Interrupt coalescing parameters */
-#define CRB_GLOBAL_INT_COAL		NETXEN_NIC_REG(0x80)
-#define CRB_INT_COAL_MODE		NETXEN_NIC_REG(0x84)
-#define CRB_MAX_RCV_BUFS		NETXEN_NIC_REG(0x88)
-#define CRB_TX_INT_THRESHOLD		NETXEN_NIC_REG(0x8c)
-#define CRB_RX_PKT_TIMER		NETXEN_NIC_REG(0x90)
-#define CRB_TX_PKT_TIMER		NETXEN_NIC_REG(0x94)
-#define CRB_RX_PKT_CNT			NETXEN_NIC_REG(0x98)
-#define CRB_RX_TMR_CNT			NETXEN_NIC_REG(0x9c)
-#define CRB_INT_THRESH			NETXEN_NIC_REG(0xa4)
-
-/* Register for communicating XG link status */
-#define CRB_XG_STATE			NETXEN_NIC_REG(0xa0)
-
-/* Register for communicating card temperature */
-/* Upper 16 bits are temperature value. Lower 16 bits are the state */
-#define CRB_TEMP_STATE			NETXEN_NIC_REG(0xa8)
 #define nx_get_temp_val(x)		((x) >> 16)
 #define nx_get_temp_state(x)		((x) & 0xffff)
 #define nx_encode_temp(val, state)	(((val) << 16) | (state))
 
-/* Debug registers for controlling NIC pkt gen agent */
-#define CRB_AGENT_GO			NETXEN_NIC_REG(0xb0)
-#define CRB_AGENT_TX_SIZE		NETXEN_NIC_REG(0xb4)
-#define CRB_AGENT_TX_TYPE		NETXEN_NIC_REG(0xb8)
-#define CRB_AGENT_TX_ADDR		NETXEN_NIC_REG(0xbc)
-#define CRB_AGENT_TX_MSS		NETXEN_NIC_REG(0xc0)
-
-/* Debug registers for observing NIC performance */
-#define CRB_TX_STATE			NETXEN_NIC_REG(0xd0)
-#define CRB_TX_COUNT			NETXEN_NIC_REG(0xd4)
-#define CRB_RX_STATE			NETXEN_NIC_REG(0xd8)
-
 /* CRB registers per Rcv Descriptor ring */
 struct netxen_rcv_desc_crb {
 	u32 crb_rcv_producer_offset __attribute__ ((aligned(512)));
 	u32 crb_rcv_consumer_offset;
 	u32 crb_globalrcv_ring;
+	u32 crb_rcv_ring_size;
 };
 
 /*
- * CRB registers used by the receive peg logic. One instance of these
- * needs to be instantiated per instance of the receive peg.
+ * CRB registers used by the receive peg logic.
  */
 
 struct netxen_recv_crb {
@@ -127,6 +132,7 @@
 	u32 crb_rcv_status_producer;
 	u32 crb_rcv_status_consumer;
 	u32 crb_rcvpeg_state;
+	u32 crb_status_ring_size;
 };
 
 #if defined(DEFINE_GLOBAL_RECV_CRB)
@@ -139,30 +145,48 @@
 	 {
 	  {
 	   /* crb_rcv_producer_offset: */
-	   NETXEN_NIC_REG(0x18),
+	   NETXEN_NIC_REG(0x100),
 	   /* crb_rcv_consumer_offset: */
-	   NETXEN_NIC_REG(0x1c),
+	   NETXEN_NIC_REG(0x104),
 	   /* crb_gloablrcv_ring: */
-	   NETXEN_NIC_REG(0x20),
+	   NETXEN_NIC_REG(0x108),
+           /* crb_rcv_ring_size */
+	   NETXEN_NIC_REG(0x10c),
+
 	   },
 	  /* Jumbo frames */
 	  {
 	   /* crb_rcv_producer_offset: */
-	   NETXEN_NIC_REG(0x100),
+	   NETXEN_NIC_REG(0x110),
 	   /* crb_rcv_consumer_offset: */
-	   NETXEN_NIC_REG(0x104),
+	   NETXEN_NIC_REG(0x114),
 	   /* crb_gloablrcv_ring: */
-	   NETXEN_NIC_REG(0x108),
-	   }
+	   NETXEN_NIC_REG(0x118),
+	   /* crb_rcv_ring_size */
+           NETXEN_NIC_REG(0x11c),
+	   },
+            /* LRO */
+           {
+	   /* crb_rcv_producer_offset: */
+            NETXEN_NIC_REG(0x120),
+           /* crb_rcv_consumer_offset: */
+            NETXEN_NIC_REG(0x124),
+           /* crb_gloablrcv_ring: */
+            NETXEN_NIC_REG(0x128),
+           /* crb_rcv_ring_size */
+            NETXEN_NIC_REG(0x12c),
+           }
 	  },
 	 /* crb_rcvstatus_ring: */
-	 NETXEN_NIC_REG(0x24),
+	 NETXEN_NIC_REG(0x130),
 	 /* crb_rcv_status_producer: */
-	 NETXEN_NIC_REG(0x28),
+	 NETXEN_NIC_REG(0x134),
 	 /* crb_rcv_status_consumer: */
-	 NETXEN_NIC_REG(0x2c),
+	 NETXEN_NIC_REG(0x138),
 	 /* crb_rcvpeg_state: */
-	 NETXEN_NIC_REG(0x48),
+	 NETXEN_NIC_REG(0x13c),
+         /* crb_status_ring_size */
+         NETXEN_NIC_REG(0x140),
 
 	 },
 	/*
@@ -173,34 +197,66 @@
 	 {
 	  {
 	   /* crb_rcv_producer_offset: */
-	   NETXEN_NIC_REG(0x80),
+	   NETXEN_NIC_REG(0x144),
 	   /* crb_rcv_consumer_offset: */
-	   NETXEN_NIC_REG(0x84),
+	   NETXEN_NIC_REG(0x148),
 	   /* crb_globalrcv_ring: */
-	   NETXEN_NIC_REG(0x88),
+	   NETXEN_NIC_REG(0x14c),
+           /* crb_rcv_ring_size */
+           NETXEN_NIC_REG(0x150),
+
 	   },
 	  /* Jumbo frames */
 	  {
 	   /* crb_rcv_producer_offset: */
-	   NETXEN_NIC_REG(0x10C),
+	   NETXEN_NIC_REG(0x154),
 	   /* crb_rcv_consumer_offset: */
-	   NETXEN_NIC_REG(0x110),
+	   NETXEN_NIC_REG(0x158),
 	   /* crb_globalrcv_ring: */
-	   NETXEN_NIC_REG(0x114),
-	   }
+	   NETXEN_NIC_REG(0x15c),
+           /* crb_rcv_ring_size */
+           NETXEN_NIC_REG(0x160),
+	   },
+            /* LRO */
+          {
+            /* crb_rcv_producer_offset: */
+            NETXEN_NIC_REG(0x164),
+            /* crb_rcv_consumer_offset: */
+            NETXEN_NIC_REG(0x168),
+            /* crb_globalrcv_ring: */
+            NETXEN_NIC_REG(0x16c),
+            /* crb_rcv_ring_size */
+            NETXEN_NIC_REG(0x170),
+           }
+
 	  },
 	 /* crb_rcvstatus_ring: */
-	 NETXEN_NIC_REG(0x8c),
+	 NETXEN_NIC_REG(0x174),
 	 /* crb_rcv_status_producer: */
-	 NETXEN_NIC_REG(0x90),
+	 NETXEN_NIC_REG(0x178),
 	 /* crb_rcv_status_consumer: */
-	 NETXEN_NIC_REG(0x94),
+	 NETXEN_NIC_REG(0x17c),
 	 /* crb_rcvpeg_state: */
-	 NETXEN_NIC_REG(0x98),
+	 NETXEN_NIC_REG(0x180),
+         /* crb_status_ring_size */
+         NETXEN_NIC_REG(0x184),
+
 	 },
 };
+
+u64 ctx_addr_sig_regs[][3] = {
+    {NETXEN_NIC_REG(0x188), NETXEN_NIC_REG(0x18c), NETXEN_NIC_REG(0x1c0)},
+    {NETXEN_NIC_REG(0x190), NETXEN_NIC_REG(0x194), NETXEN_NIC_REG(0x1c4)},
+    {NETXEN_NIC_REG(0x198), NETXEN_NIC_REG(0x19c), NETXEN_NIC_REG(0x1c8)},
+    {NETXEN_NIC_REG(0x1a0), NETXEN_NIC_REG(0x1a4), NETXEN_NIC_REG(0x1cc)}
+};
+
 #else
 extern struct netxen_recv_crb recv_crb_registers[];
+extern u64 ctx_addr_sig_regs[][3];
+#define CRB_CTX_ADDR_REG_LO            (ctx_addr_sig_regs[0][0])
+#define CRB_CTX_ADDR_REG_HI            (ctx_addr_sig_regs[0][2])
+#define CRB_CTX_SIGNATURE_REG       (ctx_addr_sig_regs[0][1])
 #endif				/* DEFINE_GLOBAL_RECEIVE_CRB */
 
 /*
only in patch2:
unchanged:
--- a/drivers/net/netxen/netxen_nic_ioctl.h
+++ b/drivers/net/netxen/netxen_nic_ioctl.h
@@ -36,7 +36,7 @@
 #define NETXEN_NIC_CMD		(NETXEN_CMD_START + 1)
 #define NETXEN_NIC_NAME		(NETXEN_CMD_START + 2)
 #define NETXEN_NIC_NAME_LEN	16
-#define NETXEN_NIC_NAME_RSP	"NETXEN"
+#define NETXEN_NIC_NAME_RSP	"NETXEN-UNM"
 
 typedef enum {
 	netxen_nic_cmd_none = 0,
only in patch2:
unchanged:
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -399,8 +399,8 @@ int netxen_niu_gbe_init_port(struct netx
 {
 	int result = 0;
 	__le32 status;
-	if (adapter->ops->disable_phy_interrupts)
-		adapter->ops->disable_phy_interrupts(adapter, port);
+	if (adapter->disable_phy_interrupts)
+		adapter->disable_phy_interrupts(adapter, port);
 	mdelay(2);
 
 	if (0 ==
