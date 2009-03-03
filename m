From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH 1/3] be2net: header files
Date: Tue, 03 Mar 2009 19:03:30 +0530
Message-ID: <1236087210.6013.39.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jeff Garzik <jgarzik@pobox.com>, subbu <subbus@serverengines.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail96.messagelabs.com ([216.82.254.19]:27904 "EHLO
	mail96.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbZCCNdl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 08:33:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, This is a complete re-write of  BladeEngine (10Gb NIC) driver to
eliminate some of the remnants of a h/w abstraction layer in the earlier
design.  Comments received from the earlier rounds of review have been
incorporated.  Please review this and send us any additional comments.

The patches are against the Linus git tree.

Thanks,
-Sathya

P.S: Pls ignore the "company confidential" warning at the end of the
patch emails. 


Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be.h      |  327 ++++++++++++++++++++
 drivers/net/benet/be_cmds.h |  688 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_hw.h   |  211 +++++++++++++
 3 files changed, 1226 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/benet/be.h
 create mode 100644 drivers/net/benet/be_cmds.h
 create mode 100644 drivers/net/benet/be_hw.h

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
new file mode 100644
index 0000000..e99a4a1
--- /dev/null
+++ b/drivers/net/benet/be.h
@@ -0,0 +1,327 @@
+/*
+ * Copyright (C) 2005 - 2009 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+
+#ifndef BE_H
+#define BE_H
+
+#include <linux/pci.h>
+#include <linux/etherdevice.h>
+#include <linux/version.h>
+#include <linux/delay.h>
+#include <net/tcp.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <linux/if_vlan.h>
+#include <linux/workqueue.h>
+#include <linux/interrupt.h>
+#include <linux/inet_lro.h>
+
+#include "be_hw.h"
+
+#define DRV_VER		"2.0.348"
+#define DRV_NAME	"be2net"
+#define DRV_DESC 	"ServerEngines BladeEngine2 10Gbps Network Driver"
+
+/* Number of bytes of an RX frame that are copied to skb->data */
+#define BE_HDR_LEN 		64
+#define BE_MAX_JUMBO_FRAME_SIZE	9018
+#define BE_MIN_MTU		256
+
+#define BE_NUM_VLANS_SUPPORTED	64
+#define BE_MAX_EQD		96
+#define	BE_MAX_TX_FRAG_COUNT	30
+
+#define EVNT_Q_LEN		1024
+#define TX_Q_LEN		2048
+#define TX_CQ_LEN		1024
+#define RX_Q_LEN		1024	/* Does not support any other value */
+#define RX_CQ_LEN		1024
+#define MCC_Q_LEN		64	/* total size not to exceed 8 pages */
+#define MCC_CQ_LEN		256
+
+#define BE_NAPI_WEIGHT		128
+#define MAX_RX_POST 		BE_NAPI_WEIGHT /* Frags posted at a time */
+#define RX_FRAGS_REFILL_WM	(RX_Q_LEN - MAX_RX_POST)
+
+#define BE_MAX_LRO_DESCRIPTORS  16
+#define BE_MAX_FRAGS_PER_FRAME  16
+
+struct be_dma_mem {
+	void *va;
+	dma_addr_t dma;
+	u32 size;
+};
+
+struct be_queue_info {
+	struct be_dma_mem dma_mem;
+	u16 len;
+	u16 entry_size;	/* Size of an element in the queue */
+	u16 id;
+	u16 tail, head;
+	bool created;
+	atomic_t used;	/* Number of valid elements in the queue */
+};
+
+struct be_ctrl_info {
+	u8 __iomem *csr;
+	u8 __iomem *db;		/* Door Bell */
+	u8 __iomem *pcicfg;	/* PCI config space */
+	int pci_func;
+
+	/* Mbox used for cmd request/response */
+	spinlock_t cmd_lock;	/* For serializing cmds to BE card */
+	struct be_dma_mem mbox_mem;
+	/* Mbox mem is adjusted to align to 16 bytes. The allocated addr
+	 * is stored for freeing purpose */
+	struct be_dma_mem mbox_mem_alloced;
+};
+
+#include "be_cmds.h"
+
+struct be_drvr_stats {
+	u32 be_tx_reqs;		/* number of TX requests initiated */
+	u32 be_tx_stops;	/* number of times TX Q was stopped */
+	u32 be_fwd_reqs;	/* number of send reqs through forwarding i/f */
+	u32 be_tx_wrbs;		/* number of tx WRBs used */
+	u32 be_tx_events;	/* number of tx completion events  */
+	u32 be_tx_compl;	/* number of tx completion entries processed */
+	u64 be_tx_jiffies;
+	ulong be_tx_bytes;
+	ulong be_tx_bytes_prev;
+	u32 be_tx_rate;
+
+	u32 cache_barrier[16];
+
+	u32 be_ethrx_post_fail;/* number of ethrx buffer alloc failures */
+	u32 be_polls;		/* number of times NAPI called poll function */
+	u32 be_rx_events;	/* number of ucast rx completion events  */
+	u32 be_rx_compl;	/* number of rx completion entries processed */
+	u32 be_lro_hgram_data[8];	/* histogram of LRO data packets */
+	u32 be_lro_hgram_ack[8];	/* histogram of LRO ACKs */
+	u64 be_rx_jiffies;
+	ulong be_rx_bytes;
+	ulong be_rx_bytes_prev;
+	u32 be_rx_rate;
+	/* number of non ether type II frames dropped where
+	 * frame len > length field of Mac Hdr */
+	u32 be_802_3_dropped_frames;
+	/* number of non ether type II frames malformed where
+	 * in frame len < length field of Mac Hdr */
+	u32 be_802_3_malformed_frames;
+	u32 be_rxcp_err;	/* Num rx completion entries w/ err set. */
+	ulong rx_fps_jiffies;	/* jiffies at last FPS calc */
+	u32 be_rx_frags;
+	u32 be_prev_rx_frags;
+	u32 be_rx_fps;		/* Rx frags per second */
+};
+
+struct be_stats_obj {
+	struct be_drvr_stats drvr_stats;
+	struct net_device_stats net_stats;
+	struct be_dma_mem cmd;
+};
+
+struct be_eq_obj {
+	struct be_queue_info q;
+	char desc[32];
+
+	/* Adaptive interrupt coalescing (AIC) info */
+	bool enable_aic;
+	u16 min_eqd;		/* in usecs */
+	u16 max_eqd;		/* in usecs */
+	u16 cur_eqd;		/* in usecs */
+
+	struct napi_struct napi;
+};
+
+struct be_tx_obj {
+	struct be_queue_info q;
+	struct be_queue_info cq;
+	/* Remember the skbs that were transmitted */
+	struct sk_buff *sent_skb_list[TX_Q_LEN];
+};
+
+/* Struct to remember the pages posted for rx frags */
+struct be_rx_page_info {
+	struct page *page;
+	dma_addr_t bus;
+	u16 page_offset;
+	bool last_page_user;
+};
+
+struct be_rx_obj {
+	struct be_queue_info q;
+	struct be_queue_info cq;
+	struct be_rx_page_info page_info_tbl[RX_Q_LEN];
+	struct net_lro_mgr lro_mgr;
+	struct net_lro_desc lro_desc[BE_MAX_LRO_DESCRIPTORS];
+};
+
+#define BE_NUM_MSIX_VECTORS		2	/* 1 each for Tx and Rx */
+struct be_adapter {
+	struct pci_dev *pdev;
+	struct net_device *netdev;
+
+	/* Mbox, pci config, csr address information */
+	struct be_ctrl_info ctrl;
+
+	struct msix_entry msix_entries[BE_NUM_MSIX_VECTORS];
+	bool msix_enabled;
+	bool isr_registered;
+
+	/* TX Rings */
+	struct be_eq_obj tx_eq;
+	struct be_tx_obj tx_obj;
+
+	u32 cache_line_break[8];
+
+	/* Rx rings */
+	struct be_eq_obj rx_eq;
+	struct be_rx_obj rx_obj;
+	u32 big_page_size;	/* Compounded page size shared by rx wrbs */
+
+	u32 if_handle;		/* Used to configure filtering */
+	u32 pmac_id;		/* MAC addr handle used by BE card */
+
+	struct vlan_group *vlan_grp;
+	u32 num_vlans;
+	u16 vlan_tag[BE_NUM_VLANS_SUPPORTED];
+
+	struct be_stats_obj stats;
+	/* Work queue used to perform periodic tasks like getting statistics */
+	struct delayed_work work;
+
+	/* Ethtool knobs and info */
+	bool rx_csum; 		/* BE card must perform rx-checksumming */
+	u32 max_rx_coal;
+	char fw_ver[FW_VER_LEN];
+
+	struct be_link_info link;
+	int port_num;
+};
+
+extern struct ethtool_ops be_ethtool_ops;
+
+#define drvr_stats(adapter)		(&adapter->stats.drvr_stats)
+
+#define BE_SET_NETDEV_OPS(netdev, ops)	(netdev->netdev_ops = ops)
+
+static inline u32 MODULO(u16 val, u16 limit)
+{
+	BUG_ON(limit & (limit - 1));
+	return val & (limit - 1);
+}
+
+static inline void index_adv(u16 *index, u16 val, u16 limit)
+{
+	*index = MODULO((*index + val), limit);
+}
+
+static inline void index_inc(u16 *index, u16 limit)
+{
+	*index = MODULO((*index + 1), limit);
+}
+
+#define PAGE_SHIFT_4K		12
+#define PAGE_SIZE_4K		(1 << PAGE_SHIFT_4K)
+
+/* Returns number of pages spanned by the data starting at the given addr */
+#define PAGES_4K_SPANNED(_address, size) 				\
+		((u32)((((size_t)(_address) & (PAGE_SIZE_4K - 1)) + 	\
+			(size) + (PAGE_SIZE_4K - 1)) >> PAGE_SHIFT_4K))
+
+/* Byte offset into the page corresponding to given address */
+#define OFFSET_IN_PAGE(addr)						\
+		 ((size_t)(addr) & (PAGE_SIZE_4K-1))
+
+/* Returns bit offset within a DWORD of a bitfield */
+#define AMAP_BIT_OFFSET(_struct, field)  				\
+		(((size_t)&(((_struct *)0)->field))%32)
+
+/* Returns the bit mask of the field that is NOT shifted into location. */
+static inline u32 amap_mask(u32 bitsize)
+{
+	return (bitsize == 32 ? 0xFFFFFFFF : (1 << bitsize) - 1);
+}
+
+static inline void
+amap_set(void *ptr, u32 dw_offset, u32 mask, u32 offset, u32 value)
+{
+	u32 *dw = (u32 *) ptr + dw_offset;
+	*dw &= ~(mask << offset);
+	*dw |= (mask & value) << offset;
+}
+
+#define AMAP_SET_BITS(_struct, field, ptr, val)				\
+		amap_set(ptr,						\
+			offsetof(_struct, field)/32,			\
+			amap_mask(sizeof(((_struct *)0)->field)),	\
+			AMAP_BIT_OFFSET(_struct, field),		\
+			val)
+
+static inline u32 amap_get(void *ptr, u32 dw_offset, u32 mask, u32 offset)
+{
+	u32 *dw = (u32 *) ptr;
+	return mask & (*(dw + dw_offset) >> offset);
+}
+
+#define AMAP_GET_BITS(_struct, field, ptr)				\
+		amap_get(ptr,						\
+			offsetof(_struct, field)/32,			\
+			amap_mask(sizeof(((_struct *)0)->field)),	\
+			AMAP_BIT_OFFSET(_struct, field))
+
+#define be_dws_cpu_to_le(wrb, len)	swap_dws(wrb, len)
+#define be_dws_le_to_cpu(wrb, len)	swap_dws(wrb, len)
+static inline void swap_dws(void *wrb, int len)
+{
+#ifdef __BIG_ENDIAN
+	u32 *dw = wrb;
+	BUG_ON(len % 4);
+	do {
+		*dw = cpu_to_le32(*dw);
+		dw++;
+		len -= 4;
+	} while (len);
+#endif				/* __BIG_ENDIAN */
+}
+
+static inline u8 is_tcp_pkt(struct sk_buff *skb)
+{
+	u8 val = 0;
+
+	if (ip_hdr(skb)->version == 4)
+		val = (ip_hdr(skb)->protocol == IPPROTO_TCP);
+	else if (ip_hdr(skb)->version == 6)
+		val = (ipv6_hdr(skb)->nexthdr == NEXTHDR_TCP);
+
+	return val;
+}
+
+static inline u8 is_udp_pkt(struct sk_buff *skb)
+{
+	u8 val = 0;
+
+	if (ip_hdr(skb)->version == 4)
+		val = (ip_hdr(skb)->protocol == IPPROTO_UDP);
+	else if (ip_hdr(skb)->version == 6)
+		val = (ipv6_hdr(skb)->nexthdr == NEXTHDR_UDP);
+
+	return val;
+}
+
+#endif				/* BE_H */
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
new file mode 100644
index 0000000..e499e2d
--- /dev/null
+++ b/drivers/net/benet/be_cmds.h
@@ -0,0 +1,688 @@
+/*
+ * Copyright (C) 2005 - 2009 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+
+/*
+ * The driver sends configuration and managements command requests to the
+ * firmware in the BE. These requests are communicated to the processor
+ * using Work Request Blocks (WRBs) submitted to the MCC-WRB ring or via one
+ * WRB inside a MAILBOX.
+ * The commands are serviced by the ARM processor in the BladeEngine's MPU.
+ */
+
+struct be_sge {
+	u32 pa_lo;
+	u32 pa_hi;
+	u32 len;
+};
+
+#define MCC_WRB_EMBEDDED_MASK	1 	/* bit 0 of dword 0*/
+#define MCC_WRB_SGE_CNT_SHIFT	3	/* bits 3 - 7 of dword 0 */
+#define MCC_WRB_SGE_CNT_MASK	0x1F	/* bits 3 - 7 of dword 0 */
+struct be_mcc_wrb {
+	u32 embedded;		/* dword 0 */
+	u32 payload_length;	/* dword 1 */
+	u32 tag0;		/* dword 2 */
+	u32 tag1;		/* dword 3 */
+	u32 rsvd;		/* dword 4 */
+	union {
+		u8 embedded_payload[236]; /* used by embedded cmds */
+		struct be_sge sgl[19];    /* used by non-embedded cmds */
+	} payload;
+};
+
+#define CQE_FLAGS_VALID_MASK 		(1 << 31)
+#define CQE_FLAGS_ASYNC_MASK 		(1 << 30)
+#define CQE_FLAGS_COMPLETED_MASK 	(1 << 28)
+#define CQE_FLAGS_CONSUMED_MASK 	(1 << 27)
+
+/* Completion Status */
+enum {
+	MCC_STATUS_SUCCESS = 0x0,
+/* The client does not have sufficient privileges to execute the command */
+	MCC_STATUS_INSUFFICIENT_PRIVILEGES = 0x1,
+/* A parameter in the command was invalid. */
+	MCC_STATUS_INVALID_PARAMETER = 0x2,
+/* There are insufficient chip resources to execute the command */
+	MCC_STATUS_INSUFFICIENT_RESOURCES = 0x3,
+/* The command is completing because the queue was getting flushed */
+	MCC_STATUS_QUEUE_FLUSHING = 0x4,
+/* The command is completing with a DMA error */
+	MCC_STATUS_DMA_FAILED = 0x5
+};
+
+#define CQE_STATUS_COMPL_MASK		0xFFFF
+#define CQE_STATUS_COMPL_SHIFT		0	/* bits 0 - 15 */
+#define CQE_STATUS_EXTD_MASK		0xFFFF
+#define CQE_STATUS_EXTD_SHIFT		0	/* bits 0 - 15 */
+
+struct be_mcc_cq_entry {
+	u32 status;		/* dword 0 */
+	u32 tag0;		/* dword 1 */
+	u32 tag1;		/* dword 2 */
+	u32 flags;		/* dword 3 */
+};
+
+struct be_mcc_mailbox {
+	struct be_mcc_wrb wrb;
+	struct be_mcc_cq_entry cqe;
+};
+
+#define CMD_SUBSYSTEM_COMMON	0x1
+#define CMD_SUBSYSTEM_ETH 	0x3
+
+#define OPCODE_COMMON_NTWK_MAC_QUERY			1
+#define OPCODE_COMMON_NTWK_MAC_SET			2
+#define OPCODE_COMMON_NTWK_MULTICAST_SET		3
+#define OPCODE_COMMON_NTWK_VLAN_CONFIG  		4
+#define OPCODE_COMMON_NTWK_LINK_STATUS_QUERY		5
+#define OPCODE_COMMON_CQ_CREATE				12
+#define OPCODE_COMMON_EQ_CREATE				13
+#define OPCODE_COMMON_MCC_CREATE        		21
+#define OPCODE_COMMON_NTWK_RX_FILTER    		34
+#define OPCODE_COMMON_GET_FW_VERSION			35
+#define OPCODE_COMMON_SET_FLOW_CONTROL			36
+#define OPCODE_COMMON_GET_FLOW_CONTROL			37
+#define OPCODE_COMMON_SET_FRAME_SIZE			39
+#define OPCODE_COMMON_MODIFY_EQ_DELAY			41
+#define OPCODE_COMMON_FIRMWARE_CONFIG			42
+#define OPCODE_COMMON_NTWK_INTERFACE_CREATE 		50
+#define OPCODE_COMMON_NTWK_INTERFACE_DESTROY 		51
+#define OPCODE_COMMON_CQ_DESTROY        		54
+#define OPCODE_COMMON_EQ_DESTROY        		55
+#define OPCODE_COMMON_QUERY_FIRMWARE_CONFIG		58
+#define OPCODE_COMMON_NTWK_PMAC_ADD			59
+#define OPCODE_COMMON_NTWK_PMAC_DEL			60
+
+#define OPCODE_ETH_ACPI_CONFIG				2
+#define OPCODE_ETH_PROMISCUOUS				3
+#define OPCODE_ETH_GET_STATISTICS			4
+#define OPCODE_ETH_TX_CREATE				7
+#define OPCODE_ETH_RX_CREATE            		8
+#define OPCODE_ETH_TX_DESTROY           		9
+#define OPCODE_ETH_RX_DESTROY           		10
+
+struct be_cmd_req_hdr {
+	u8 opcode;		/* dword 0 */
+	u8 subsystem;		/* dword 0 */
+	u8 port_number;		/* dword 0 */
+	u8 domain;		/* dword 0 */
+	u32 timeout;		/* dword 1 */
+	u32 request_length;	/* dword 2 */
+	u32 rsvd;		/* dword 3 */
+};
+
+#define RESP_HDR_INFO_OPCODE_SHIFT	0	/* bits 0 - 7 */
+#define RESP_HDR_INFO_SUBSYS_SHIFT	8 	/* bits 8 - 15 */
+struct be_cmd_resp_hdr {
+	u32 info;		/* dword 0 */
+	u32 status;		/* dword 1 */
+	u32 response_length;	/* dword 2 */
+	u32 actual_resp_len;	/* dword 3 */
+};
+
+struct phys_addr {
+	u32 lo;
+	u32 hi;
+};
+
+/**************************
+ * BE Command definitions *
+ **************************/
+
+/* Pseudo amap definition in which each bit of the actual structure is defined
+ * as a byte: used to calculate offset/shift/mask of each field */
+struct amap_eq_context {
+	u8 cidx[13];		/* dword 0*/
+	u8 rsvd0[3];		/* dword 0*/
+	u8 epidx[13];		/* dword 0*/
+	u8 valid;		/* dword 0*/
+	u8 rsvd1;		/* dword 0*/
+	u8 size;		/* dword 0*/
+	u8 pidx[13];		/* dword 1*/
+	u8 rsvd2[3];		/* dword 1*/
+	u8 pd[10];		/* dword 1*/
+	u8 count[3];		/* dword 1*/
+	u8 solevent;		/* dword 1*/
+	u8 stalled;		/* dword 1*/
+	u8 armed;		/* dword 1*/
+	u8 rsvd3[4];		/* dword 2*/
+	u8 func[8];		/* dword 2*/
+	u8 rsvd4;		/* dword 2*/
+	u8 delaymult[10];	/* dword 2*/
+	u8 rsvd5[2];		/* dword 2*/
+	u8 phase[2];		/* dword 2*/
+	u8 nodelay;		/* dword 2*/
+	u8 rsvd6[4];		/* dword 2*/
+	u8 rsvd7[32];		/* dword 3*/
+} __packed;
+
+struct be_cmd_req_eq_create {
+	struct be_cmd_req_hdr hdr;
+	u16 num_pages;		/* sword */
+	u16 rsvd0;		/* sword */
+	u8 context[sizeof(struct amap_eq_context) / 8];
+	struct phys_addr pages[8];
+} __packed;
+
+struct be_cmd_resp_eq_create {
+	struct be_cmd_resp_hdr resp_hdr;
+	u16 eq_id;		/* sword */
+	u16 rsvd0;		/* sword */
+} __packed;
+
+/******************** Mac query ***************************/
+enum {
+	MAC_ADDRESS_TYPE_STORAGE = 0x0,
+	MAC_ADDRESS_TYPE_NETWORK = 0x1,
+	MAC_ADDRESS_TYPE_PD = 0x2,
+	MAC_ADDRESS_TYPE_MANAGEMENT = 0x3
+};
+
+struct mac_addr {
+	u16 size_of_struct;
+	u8 addr[ETH_ALEN];
+} __packed;
+
+struct be_cmd_req_mac_query {
+	struct be_cmd_req_hdr hdr;
+	u8 type;
+	u8 permanent;
+	u16 if_id;
+} __packed;
+
+struct be_cmd_resp_mac_query {
+	struct be_cmd_resp_hdr hdr;
+	struct mac_addr mac;
+};
+
+/******************** PMac Add ***************************/
+struct be_cmd_req_pmac_add {
+	struct be_cmd_req_hdr hdr;
+	u32 if_id;
+	u8 mac_address[ETH_ALEN];
+	u8 rsvd0[2];
+} __packed;
+
+struct be_cmd_resp_pmac_add {
+	struct be_cmd_resp_hdr hdr;
+	u32 pmac_id;
+};
+
+/******************** PMac Del ***************************/
+struct be_cmd_req_pmac_del {
+	struct be_cmd_req_hdr hdr;
+	u32 if_id;
+	u32 pmac_id;
+};
+
+/******************** Create CQ ***************************/
+/* Pseudo amap definition in which each bit of the actual structure is defined
+ * as a byte: used to calculate offset/shift/mask of each field */
+struct amap_cq_context {
+	u8 cidx[11];		/* dword 0*/
+	u8 rsvd0;		/* dword 0*/
+	u8 coalescwm[2];	/* dword 0*/
+	u8 nodelay;		/* dword 0*/
+	u8 epidx[11];		/* dword 0*/
+	u8 rsvd1;		/* dword 0*/
+	u8 count[2];		/* dword 0*/
+	u8 valid;		/* dword 0*/
+	u8 solevent;		/* dword 0*/
+	u8 eventable;		/* dword 0*/
+	u8 pidx[11];		/* dword 1*/
+	u8 rsvd2;		/* dword 1*/
+	u8 pd[10];		/* dword 1*/
+	u8 eqid[8];		/* dword 1*/
+	u8 stalled;		/* dword 1*/
+	u8 armed;		/* dword 1*/
+	u8 rsvd3[4];		/* dword 2*/
+	u8 func[8];		/* dword 2*/
+	u8 rsvd4[20];		/* dword 2*/
+	u8 rsvd5[32];		/* dword 3*/
+} __packed;
+
+struct be_cmd_req_cq_create {
+	struct be_cmd_req_hdr hdr;
+	u16 num_pages;
+	u16 rsvd0;
+	u8 context[sizeof(struct amap_cq_context) / 8];
+	struct phys_addr pages[8];
+} __packed;
+
+struct be_cmd_resp_cq_create {
+	struct be_cmd_resp_hdr hdr;
+	u16 cq_id;
+	u16 rsvd0;
+} __packed;
+
+/******************** Create TxQ ***************************/
+#define BE_ETH_TX_RING_TYPE_STANDARD    	2
+#define BE_ULP1_NUM				1
+
+/* Pseudo amap definition in which each bit of the actual structure is defined
+ * as a byte: used to calculate offset/shift/mask of each field */
+struct amap_tx_context {
+	u8 rsvd0[16];		/* dword 0 */
+	u8 tx_ring_size[4];	/* dword 0 */
+	u8 rsvd1[26];		/* dword 0 */
+	u8 pci_func_id[8];	/* dword 1 */
+	u8 rsvd2[9];		/* dword 1 */
+	u8 ctx_valid;		/* dword 1 */
+	u8 cq_id_send[16];	/* dword 2 */
+	u8 rsvd3[16];		/* dword 2 */
+	u8 rsvd4[32];		/* dword 3 */
+	u8 rsvd5[32];		/* dword 4 */
+	u8 rsvd6[32];		/* dword 5 */
+	u8 rsvd7[32];		/* dword 6 */
+	u8 rsvd8[32];		/* dword 7 */
+	u8 rsvd9[32];		/* dword 8 */
+	u8 rsvd10[32];		/* dword 9 */
+	u8 rsvd11[32];		/* dword 10 */
+	u8 rsvd12[32];		/* dword 11 */
+	u8 rsvd13[32];		/* dword 12 */
+	u8 rsvd14[32];		/* dword 13 */
+	u8 rsvd15[32];		/* dword 14 */
+	u8 rsvd16[32];		/* dword 15 */
+} __packed;
+
+struct be_cmd_req_eth_tx_create {
+	struct be_cmd_req_hdr hdr;
+	u8 num_pages;
+	u8 ulp_num;
+	u8 type;
+	u8 bound_port;
+	u8 context[sizeof(struct amap_tx_context) / 8];
+	struct phys_addr pages[8];
+} __packed;
+
+struct be_cmd_resp_eth_tx_create {
+	struct be_cmd_resp_hdr hdr;
+	u16 cid;
+	u16 rsvd0;
+} __packed;
+
+/******************** Create RxQ ***************************/
+struct be_cmd_req_eth_rx_create {
+	struct be_cmd_req_hdr hdr;
+	u16 cq_id;
+	u8 frag_size;
+	u8 num_pages;
+	struct phys_addr pages[2];
+	u32 interface_id;
+	u16 max_frame_size;
+	u16 rsvd0;
+	u32 rss_queue;
+} __packed;
+
+struct be_cmd_resp_eth_rx_create {
+	struct be_cmd_resp_hdr hdr;
+	u16 id;
+	u8 cpu_id;
+	u8 rsvd0;
+} __packed;
+
+/******************** Q Destroy  ***************************/
+/* Type of Queue to be destroyed */
+enum {
+	QTYPE_EQ = 1,
+	QTYPE_CQ,
+	QTYPE_TXQ,
+	QTYPE_RXQ
+};
+
+struct be_cmd_req_q_destroy {
+	struct be_cmd_req_hdr hdr;
+	u16 id;
+	u16 bypass_flush;	/* valid only for rx q destroy */
+} __packed;
+
+/************ I/f Create (it's actually I/f Config Create)**********/
+
+/* Capability flags for the i/f */
+enum be_if_flags {
+	BE_IF_FLAGS_RSS = 0x4,
+	BE_IF_FLAGS_PROMISCUOUS = 0x8,
+	BE_IF_FLAGS_BROADCAST = 0x10,
+	BE_IF_FLAGS_UNTAGGED = 0x20,
+	BE_IF_FLAGS_ULP = 0x40,
+	BE_IF_FLAGS_VLAN_PROMISCUOUS = 0x80,
+	BE_IF_FLAGS_VLAN = 0x100,
+	BE_IF_FLAGS_MCAST_PROMISCUOUS = 0x200,
+	BE_IF_FLAGS_PASS_L2_ERRORS = 0x400,
+	BE_IF_FLAGS_PASS_L3L4_ERRORS = 0x800
+};
+
+/* An RX interface is an object with one or more MAC addresses and
+ * filtering capabilities. */
+struct be_cmd_req_if_create {
+	struct be_cmd_req_hdr hdr;
+	u32 version;		/* ignore currntly */
+	u32 capability_flags;
+	u32 enable_flags;
+	u8 mac_addr[ETH_ALEN];
+	u8 rsvd0;
+	u8 pmac_invalid; /* if set, don't attach the mac addr to the i/f */
+	u32 vlan_tag;	 /* not used currently */
+} __packed;
+
+struct be_cmd_resp_if_create {
+	struct be_cmd_resp_hdr hdr;
+	u32 interface_id;
+	u32 pmac_id;
+};
+
+/****** I/f Destroy(it's actually I/f Config Destroy )**********/
+struct be_cmd_req_if_destroy {
+	struct be_cmd_req_hdr hdr;
+	u32 interface_id;
+};
+
+/*************** HW Stats Get **********************************/
+struct be_port_rxf_stats {
+	u32 rx_bytes_lsd;	/* dword 0*/
+	u32 rx_bytes_msd;	/* dword 1*/
+	u32 rx_total_frames;	/* dword 2*/
+	u32 rx_unicast_frames;	/* dword 3*/
+	u32 rx_multicast_frames;	/* dword 4*/
+	u32 rx_broadcast_frames;	/* dword 5*/
+	u32 rx_crc_errors;	/* dword 6*/
+	u32 rx_alignment_symbol_errors;	/* dword 7*/
+	u32 rx_pause_frames;	/* dword 8*/
+	u32 rx_control_frames;	/* dword 9*/
+	u32 rx_in_range_errors;	/* dword 10*/
+	u32 rx_out_range_errors;	/* dword 11*/
+	u32 rx_frame_too_long;	/* dword 12*/
+	u32 rx_address_match_errors;	/* dword 13*/
+	u32 rx_vlan_mismatch;	/* dword 14*/
+	u32 rx_dropped_too_small;	/* dword 15*/
+	u32 rx_dropped_too_short;	/* dword 16*/
+	u32 rx_dropped_header_too_small;	/* dword 17*/
+	u32 rx_dropped_tcp_length;	/* dword 18*/
+	u32 rx_dropped_runt;	/* dword 19*/
+	u32 rx_64_byte_packets;	/* dword 20*/
+	u32 rx_65_127_byte_packets;	/* dword 21*/
+	u32 rx_128_256_byte_packets;	/* dword 22*/
+	u32 rx_256_511_byte_packets;	/* dword 23*/
+	u32 rx_512_1023_byte_packets;	/* dword 24*/
+	u32 rx_1024_1518_byte_packets;	/* dword 25*/
+	u32 rx_1519_2047_byte_packets;	/* dword 26*/
+	u32 rx_2048_4095_byte_packets;	/* dword 27*/
+	u32 rx_4096_8191_byte_packets;	/* dword 28*/
+	u32 rx_8192_9216_byte_packets;	/* dword 29*/
+	u32 rx_ip_checksum_errs;	/* dword 30*/
+	u32 rx_tcp_checksum_errs;	/* dword 31*/
+	u32 rx_udp_checksum_errs;	/* dword 32*/
+	u32 rx_non_rss_packets;	/* dword 33*/
+	u32 rx_ipv4_packets;	/* dword 34*/
+	u32 rx_ipv6_packets;	/* dword 35*/
+	u32 rx_ipv4_bytes_lsd;	/* dword 36*/
+	u32 rx_ipv4_bytes_msd;	/* dword 37*/
+	u32 rx_ipv6_bytes_lsd;	/* dword 38*/
+	u32 rx_ipv6_bytes_msd;	/* dword 39*/
+	u32 rx_chute1_packets;	/* dword 40*/
+	u32 rx_chute2_packets;	/* dword 41*/
+	u32 rx_chute3_packets;	/* dword 42*/
+	u32 rx_management_packets;	/* dword 43*/
+	u32 rx_switched_unicast_packets;	/* dword 44*/
+	u32 rx_switched_multicast_packets;	/* dword 45*/
+	u32 rx_switched_broadcast_packets;	/* dword 46*/
+	u32 tx_bytes_lsd;	/* dword 47*/
+	u32 tx_bytes_msd;	/* dword 48*/
+	u32 tx_unicastframes;	/* dword 49*/
+	u32 tx_multicastframes;	/* dword 50*/
+	u32 tx_broadcastframes;	/* dword 51*/
+	u32 tx_pauseframes;	/* dword 52*/
+	u32 tx_controlframes;	/* dword 53*/
+	u32 tx_64_byte_packets;	/* dword 54*/
+	u32 tx_65_127_byte_packets;	/* dword 55*/
+	u32 tx_128_256_byte_packets;	/* dword 56*/
+	u32 tx_256_511_byte_packets;	/* dword 57*/
+	u32 tx_512_1023_byte_packets;	/* dword 58*/
+	u32 tx_1024_1518_byte_packets;	/* dword 59*/
+	u32 tx_1519_2047_byte_packets;	/* dword 60*/
+	u32 tx_2048_4095_byte_packets;	/* dword 61*/
+	u32 tx_4096_8191_byte_packets;	/* dword 62*/
+	u32 tx_8192_9216_byte_packets;	/* dword 63*/
+	u32 rx_fifo_overflow;	/* dword 64*/
+	u32 rx_input_fifo_overflow;	/* dword 65*/
+};
+
+struct be_rxf_stats {
+	struct be_port_rxf_stats port[2];
+	u32 rx_drops_no_pbuf;	/* dword 132*/
+	u32 rx_drops_no_txpb;	/* dword 133*/
+	u32 rx_drops_no_erx_descr;	/* dword 134*/
+	u32 rx_drops_no_tpre_descr;	/* dword 135*/
+	u32 management_rx_port_packets;	/* dword 136*/
+	u32 management_rx_port_bytes;	/* dword 137*/
+	u32 management_rx_port_pause_frames;	/* dword 138*/
+	u32 management_rx_port_errors;	/* dword 139*/
+	u32 management_tx_port_packets;	/* dword 140*/
+	u32 management_tx_port_bytes;	/* dword 141*/
+	u32 management_tx_port_pause;	/* dword 142*/
+	u32 management_rx_port_rxfifo_overflow;	/* dword 143*/
+	u32 rx_drops_too_many_frags;	/* dword 144*/
+	u32 rx_drops_invalid_ring;	/* dword 145*/
+	u32 forwarded_packets;	/* dword 146*/
+	u32 rx_drops_mtu;	/* dword 147*/
+	u32 rsvd0[15];
+};
+
+struct be_erx_stats {
+	u32 rx_drops_no_fragments[44];     /* dwordS 0 to 43*/
+	u32 debug_wdma_sent_hold;          /* dword 44*/
+	u32 debug_wdma_pbfree_sent_hold;   /* dword 45*/
+	u32 debug_wdma_zerobyte_pbfree_sent_hold; /* dword 46*/
+	u32 debug_pmem_pbuf_dealloc;       /* dword 47*/
+};
+
+struct be_hw_stats {
+	struct be_rxf_stats rxf;
+	u32 rsvd[48];
+	struct be_erx_stats erx;
+};
+
+struct be_cmd_req_get_stats {
+	struct be_cmd_req_hdr hdr;
+	u8 rsvd[sizeof(struct be_hw_stats)];
+};
+
+struct be_cmd_resp_get_stats {
+	struct be_cmd_resp_hdr hdr;
+	struct be_hw_stats hw_stats;
+};
+
+struct be_cmd_req_vlan_config {
+	struct be_cmd_req_hdr hdr;
+	u8 interface_id;
+	u8 promiscuous;
+	u8 untagged;
+	u8 num_vlan;
+	u16 normal_vlan[64];
+} __packed;
+
+struct be_cmd_req_promiscuous_config {
+	struct be_cmd_req_hdr hdr;
+	u8 port0_promiscuous;
+	u8 port1_promiscuous;
+	u16 rsvd0;
+} __packed;
+
+struct macaddr {
+	u8 byte[ETH_ALEN];
+};
+
+struct be_cmd_req_mcast_mac_config {
+	struct be_cmd_req_hdr hdr;
+	u16 num_mac;
+	u8 promiscuous;
+	u8 interface_id;
+	struct macaddr mac[32];
+} __packed;
+
+static inline struct be_hw_stats *
+hw_stats_from_cmd(struct be_cmd_resp_get_stats *cmd)
+{
+	return &cmd->hw_stats;
+}
+
+/******************** Link Status Query *******************/
+struct be_cmd_req_link_status {
+	struct be_cmd_req_hdr hdr;
+	u32 rsvd;
+};
+
+struct be_link_info {
+	u8 duplex;
+	u8 speed;
+	u8 fault;
+};
+
+enum {
+	PHY_LINK_DUPLEX_NONE = 0x0,
+	PHY_LINK_DUPLEX_HALF = 0x1,
+	PHY_LINK_DUPLEX_FULL = 0x2
+};
+
+enum {
+	PHY_LINK_SPEED_ZERO = 0x0, 	/* => No link */
+	PHY_LINK_SPEED_10MBPS = 0x1,
+	PHY_LINK_SPEED_100MBPS = 0x2,
+	PHY_LINK_SPEED_1GBPS = 0x3,
+	PHY_LINK_SPEED_10GBPS = 0x4
+};
+
+struct be_cmd_resp_link_status {
+	struct be_cmd_resp_hdr hdr;
+	u8 physical_port;
+	u8 mac_duplex;
+	u8 mac_speed;
+	u8 mac_fault;
+	u8 mgmt_mac_duplex;
+	u8 mgmt_mac_speed;
+	u16 rsvd0;
+} __packed;
+
+/******************** Get FW Version *******************/
+#define FW_VER_LEN			32
+struct be_cmd_req_get_fw_version {
+	struct be_cmd_req_hdr hdr;
+	u8 rsvd0[FW_VER_LEN];
+	u8 rsvd1[FW_VER_LEN];
+} __packed;
+
+struct be_cmd_resp_get_fw_version {
+	struct be_cmd_resp_hdr hdr;
+	u8 firmware_version_string[FW_VER_LEN];
+	u8 fw_on_flash_version_string[FW_VER_LEN];
+} __packed;
+
+/******************** Set Flow Contrl *******************/
+struct be_cmd_req_set_flow_control {
+	struct be_cmd_req_hdr hdr;
+	u16 tx_flow_control;
+	u16 rx_flow_control;
+} __packed;
+
+/******************** Get Flow Contrl *******************/
+struct be_cmd_req_get_flow_control {
+	struct be_cmd_req_hdr hdr;
+	u32 rsvd;
+};
+
+struct be_cmd_resp_get_flow_control {
+	struct be_cmd_resp_hdr hdr;
+	u16 tx_flow_control;
+	u16 rx_flow_control;
+} __packed;
+
+/******************** Modify EQ Delay *******************/
+struct be_cmd_req_modify_eq_delay {
+	struct be_cmd_req_hdr hdr;
+	u32 num_eq;
+	struct {
+		u32 eq_id;
+		u32 phase;
+		u32 delay_multiplier;
+	} delay[8];
+} __packed;
+
+struct be_cmd_resp_modify_eq_delay {
+	struct be_cmd_resp_hdr hdr;
+	u32 rsvd0;
+} __packed;
+
+/******************** Get FW Config *******************/
+struct be_cmd_req_query_fw_cfg {
+	struct be_cmd_req_hdr hdr;
+	u32 rsvd[30];
+};
+
+struct be_cmd_resp_query_fw_cfg {
+	struct be_cmd_resp_hdr hdr;
+	u32 be_config_number;
+	u32 asic_revision;
+	u32 phys_port;
+	u32 function_mode;
+	u32 rsvd[26];
+};
+
+extern int be_pci_fnum_get(struct be_ctrl_info *ctrl);
+extern int be_cmd_POST(struct be_ctrl_info *ctrl);
+extern int be_cmd_mac_addr_query(struct be_ctrl_info *ctrl, u8 *mac_addr,
+			u8 type, bool permanent, u32 if_handle);
+extern int be_cmd_pmac_add(struct be_ctrl_info *ctrl, u8 *mac_addr,
+			u32 if_id, u32 *pmac_id);
+extern int be_cmd_pmac_del(struct be_ctrl_info *ctrl, u32 if_id, u32 pmac_id);
+extern int be_cmd_if_create(struct be_ctrl_info *ctrl, u32 if_flags, u8 *mac,
+			bool pmac_invalid, u32 *if_handle, u32 *pmac_id);
+extern int be_cmd_if_destroy(struct be_ctrl_info *ctrl, u32 if_handle);
+extern int be_cmd_eq_create(struct be_ctrl_info *ctrl,
+			struct be_queue_info *eq, int eq_delay);
+extern int be_cmd_cq_create(struct be_ctrl_info *ctrl,
+			struct be_queue_info *cq, struct be_queue_info *eq,
+			bool sol_evts, bool no_delay,
+			int num_cqe_dma_coalesce);
+extern int be_cmd_txq_create(struct be_ctrl_info *ctrl,
+			struct be_queue_info *txq,
+			struct be_queue_info *cq);
+extern int be_cmd_rxq_create(struct be_ctrl_info *ctrl,
+			struct be_queue_info *rxq, u16 cq_id,
+			u16 frag_size, u16 max_frame_size, u32 if_id,
+			u32 rss);
+extern int be_cmd_q_destroy(struct be_ctrl_info *ctrl, struct be_queue_info *q,
+			int type);
+extern int be_cmd_link_status_query(struct be_ctrl_info *ctrl,
+			struct be_link_info *link);
+extern int be_cmd_reset(struct be_ctrl_info *ctrl);
+extern int be_cmd_get_stats(struct be_ctrl_info *ctrl,
+			struct be_dma_mem *nonemb_cmd);
+extern int be_cmd_get_fw_ver(struct be_ctrl_info *ctrl, char *fw_ver);
+
+extern int be_cmd_modify_eqd(struct be_ctrl_info *ctrl, u32 eq_id, u32 eqd);
+extern int be_cmd_vlan_config(struct be_ctrl_info *ctrl, u32 if_id,
+			u16 *vtag_array, u32 num, bool untagged,
+			bool promiscuous);
+extern int be_cmd_promiscuous_config(struct be_ctrl_info *ctrl,
+			u8 port_num, bool en);
+extern int be_cmd_mcast_mac_set(struct be_ctrl_info *ctrl, u32 if_id,
+			u8 *mac_table, u32 num, bool promiscuous);
+extern int be_cmd_set_flow_control(struct be_ctrl_info *ctrl,
+			u32 tx_fc, u32 rx_fc);
+extern int be_cmd_get_flow_control(struct be_ctrl_info *ctrl,
+			u32 *tx_fc, u32 *rx_fc);
+extern int be_cmd_query_fw_cfg(struct be_ctrl_info *ctrl, u32 *port_num);
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
new file mode 100644
index 0000000..b132aa4
--- /dev/null
+++ b/drivers/net/benet/be_hw.h
@@ -0,0 +1,211 @@
+/*
+ * Copyright (C) 2005 - 2009 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+
+/********* Mailbox door bell *************/
+/* Used for driver communication with the FW.
+ * The software must write this register twice to post any command. First,
+ * it writes the register with hi=1 and the upper bits of the physical address
+ * for the MAILBOX structure. Software must poll the ready bit until this
+ * is acknowledged. Then, sotware writes the register with hi=0 with the lower
+ * bits in the address. It must poll the ready bit until the command is
+ * complete. Upon completion, the MAILBOX will contain a valid completion
+ * queue entry.
+ */
+#define MPU_MAILBOX_DB_OFFSET	0x160
+#define MPU_MAILBOX_DB_RDY_MASK	0x1 	/* bit 0 */
+#define MPU_MAILBOX_DB_HI_MASK	0x2	/* bit 1 */
+
+#define MPU_EP_CONTROL 		0
+
+/********** MPU semphore ******************/
+#define MPU_EP_SEMAPHORE_OFFSET 	0xac
+#define EP_SEMAPHORE_POST_STAGE_MASK	0x0000FFFF
+#define EP_SEMAPHORE_POST_ERR_MASK	0x1
+#define EP_SEMAPHORE_POST_ERR_SHIFT	31
+/* MPU semphore POST stage values */
+#define POST_STAGE_AWAITING_HOST_RDY 	0x1 /* FW awaiting goahead from host */
+#define POST_STAGE_HOST_RDY 		0x2 /* Host has given go-ahed to FW */
+#define POST_STAGE_BE_RESET		0x3 /* Host wants to reset chip */
+#define POST_STAGE_ARMFW_RDY		0xc000	/* FW is done with POST */
+
+/********* Memory BAR register ************/
+#define PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET 	0xfc
+/* Host Interrupt Enable, if set interrupts are enabled although "PCI Interrupt
+ * Disable" may still globally block interrupts in addition to individual
+ * interrupt masks; a mechanism for the device driver to block all interrupts
+ * atomically without having to arbitrate for the PCI Interrupt Disable bit
+ * with the OS.
+ */
+#define MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK	(1 << 29) /* bit 29 */
+/* PCI physical function number */
+#define MEMBAR_CTRL_INT_CTRL_PFUNC_MASK  	0x7 	/* bits 26 - 28 */
+#define MEMBAR_CTRL_INT_CTRL_PFUNC_SHIFT	26
+
+/********* Event Q door bell *************/
+#define DB_EQ_OFFSET			DB_CQ_OFFSET
+#define DB_EQ_RING_ID_MASK		0x1FF	/* bits 0 - 8 */
+/* Clear the interrupt for this eq */
+#define DB_EQ_CLR_SHIFT			(9)	/* bit 9 */
+/* Must be 1 */
+#define DB_EQ_EVNT_SHIFT			(10)	/* bit 10 */
+/* Number of event entries processed */
+#define DB_EQ_NUM_POPPED_SHIFT		(16)	/* bits 16 - 28 */
+/* Rearm bit */
+#define DB_EQ_REARM_SHIFT		(29)	/* bit 29 */
+
+/********* Compl Q door bell *************/
+#define DB_CQ_OFFSET 			0x120
+#define DB_CQ_RING_ID_MASK		0x3FF	/* bits 0 - 9 */
+/* Number of event entries processed */
+#define DB_CQ_NUM_POPPED_SHIFT		(16) 	/* bits 16 - 28 */
+/* Rearm bit */
+#define DB_CQ_REARM_SHIFT		(29) 	/* bit 29 */
+
+/********** TX ULP door bell *************/
+#define DB_TXULP1_OFFSET		0x60
+#define DB_TXULP_RING_ID_MASK		0x7FF	/* bits 0 - 10 */
+/* Number of tx entries posted */
+#define DB_TXULP_NUM_POSTED_SHIFT	(16)	/* bits 16 - 29 */
+#define DB_TXULP_NUM_POSTED_MASK	0x3FFF	/* bits 16 - 29 */
+
+/********** RQ(erx) door bell ************/
+#define DB_RQ_OFFSET 			0x100
+#define DB_RQ_RING_ID_MASK		0x3FF	/* bits 0 - 9 */
+/* Number of rx frags posted */
+#define DB_RQ_NUM_POSTED_SHIFT		(24)	/* bits 24 - 31 */
+
+/*
+ * BE descriptors: host memory data structures whose formats
+ * are hardwired in BE silicon.
+ */
+/* Event Queue Descriptor */
+#define EQ_ENTRY_VALID_MASK 		0x1	/* bit 0 */
+#define EQ_ENTRY_RES_ID_MASK 		0xFFFF	/* bits 16 - 31 */
+#define EQ_ENTRY_RES_ID_SHIFT 		16
+struct be_eq_entry {
+	u32 evt;
+};
+
+/* TX Queue Descriptor */
+#define ETH_WRB_FRAG_LEN_MASK		0xFFFF
+struct be_eth_wrb {
+	u32 frag_pa_hi;		/* dword 0 */
+	u32 frag_pa_lo;		/* dword 1 */
+	u32 rsvd0;		/* dword 2 */
+	u32 frag_len;		/* dword 3: bits 0 - 15 */
+} __packed;
+
+/* Pseudo amap definition for eth_hdr_wrb in which each bit of the
+ * actual structure is defined as a byte : used to calculate
+ * offset/shift/mask of each field */
+struct amap_eth_hdr_wrb {
+	u8 rsvd0[32];		/* dword 0 */
+	u8 rsvd1[32];		/* dword 1 */
+	u8 complete;		/* dword 2 */
+	u8 event;
+	u8 crc;
+	u8 forward;
+	u8 ipsec;
+	u8 mgmt;
+	u8 ipcs;
+	u8 udpcs;
+	u8 tcpcs;
+	u8 lso;
+	u8 vlan;
+	u8 gso[2];
+	u8 num_wrb[5];
+	u8 lso_mss[14];
+	u8 len[16];		/* dword 3 */
+	u8 vlan_tag[16];
+} __packed;
+
+struct be_eth_hdr_wrb {
+	u32 dw[4];
+};
+
+/* TX Compl Queue Descriptor */
+
+/* Pseudo amap definition for eth_tx_compl in which each bit of the
+ * actual structure is defined as a byte: used to calculate
+ * offset/shift/mask of each field */
+struct amap_eth_tx_compl {
+	u8 wrb_index[16];	/* dword 0 */
+	u8 ct[2]; 		/* dword 0 */
+	u8 port[2];		/* dword 0 */
+	u8 rsvd0[8];		/* dword 0 */
+	u8 status[4];		/* dword 0 */
+	u8 user_bytes[16];	/* dword 1 */
+	u8 nwh_bytes[8];	/* dword 1 */
+	u8 lso;			/* dword 1 */
+	u8 cast_enc[2];		/* dword 1 */
+	u8 rsvd1[5];		/* dword 1 */
+	u8 rsvd2[32];		/* dword 2 */
+	u8 pkts[16];		/* dword 3 */
+	u8 ringid[11];		/* dword 3 */
+	u8 hash_val[4];		/* dword 3 */
+	u8 valid;		/* dword 3 */
+} __packed;
+
+struct be_eth_tx_compl {
+	u32 dw[4];
+};
+
+/* RX Queue Descriptor */
+struct be_eth_rx_d {
+	u32 fragpa_hi;
+	u32 fragpa_lo;
+};
+
+/* RX Compl Queue Descriptor */
+
+/* Pseudo amap definition for eth_rx_compl in which each bit of the
+ * actual structure is defined as a byte: used to calculate
+ * offset/shift/mask of each field */
+struct amap_eth_rx_compl {
+	u8 vlan_tag[16];	/* dword 0 */
+	u8 pktsize[14];		/* dword 0 */
+	u8 port;		/* dword 0 */
+	u8 ip_opt;		/* dword 0 */
+	u8 err;			/* dword 1 */
+	u8 rsshp;		/* dword 1 */
+	u8 ipf;			/* dword 1 */
+	u8 tcpf;		/* dword 1 */
+	u8 udpf;		/* dword 1 */
+	u8 ipcksm;		/* dword 1 */
+	u8 l4_cksm;		/* dword 1 */
+	u8 ip_version;		/* dword 1 */
+	u8 macdst[6];		/* dword 1 */
+	u8 vtp;			/* dword 1 */
+	u8 rsvd0;		/* dword 1 */
+	u8 fragndx[10];		/* dword 1 */
+	u8 ct[2];		/* dword 1 */
+	u8 sw;			/* dword 1 */
+	u8 numfrags[3];		/* dword 1 */
+	u8 rss_flush;		/* dword 2 */
+	u8 cast_enc[2];		/* dword 2 */
+	u8 qnq;			/* dword 2 */
+	u8 rss_bank;		/* dword 2 */
+	u8 rsvd1[23];		/* dword 2 */
+	u8 lro_pkt;		/* dword 2 */
+	u8 rsvd2[2];		/* dword 2 */
+	u8 valid;		/* dword 2 */
+	u8 rsshash[32];		/* dword 3 */
+} __packed;
+
+struct be_eth_rx_compl {
+	u32 dw[4];
+};
-- 
1.6.1.3





___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

