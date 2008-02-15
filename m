From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] qeth: new qeth device driver
Date: Fri, 15 Feb 2008 09:19:42 +0100
Message-ID: <20080215082018.607314000@de.ibm.com>
References: <20080215081941.450161000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:20518 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320AbYBOIU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 03:20:29 -0500
Content-Disposition: inline; filename=new_qeth.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

List of major changes and improvements:
 no manipulation of the global ARP constructor
 clean code split into core, layer 2 and layer 3 functionality
 better exploitation of the ethtool interface
 better representation of the various hardware capabilities
 fix packet socket support (tcpdump), no fake_ll required
 osasnmpd notification via udev events
 coding style and beautification

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 arch/s390/defconfig               |    8 
 drivers/s390/net/Kconfig          |   31 
 drivers/s390/net/Makefile         |    7 
 drivers/s390/net/qeth_core.h      |  916 +++++++
 drivers/s390/net/qeth_core_main.c | 4540 ++++++++++++++++++++++++++++++++++++++
 drivers/s390/net/qeth_core_mpc.c  |  266 ++
 drivers/s390/net/qeth_core_mpc.h  |  566 ++++
 drivers/s390/net/qeth_core_offl.c |  701 +++++
 drivers/s390/net/qeth_core_offl.h |   76 
 drivers/s390/net/qeth_core_sys.c  |  651 +++++
 drivers/s390/net/qeth_l2_main.c   | 1242 ++++++++++
 drivers/s390/net/qeth_l3.h        |   76 
 drivers/s390/net/qeth_l3_main.c   | 3388 ++++++++++++++++++++++++++++
 drivers/s390/net/qeth_l3_sys.c    | 1051 ++++++++
 14 files changed, 13498 insertions(+), 21 deletions(-)

Index: my_git/arch/s390/defconfig
===================================================================
--- my_git.orig/arch/s390/defconfig	2008-02-14 13:15:07.000000000 +0100
+++ my_git/arch/s390/defconfig	2008-02-14 13:27:00.000000000 +0100
@@ -530,11 +530,9 @@
 # CONFIG_SMSGIUCV is not set
 # CONFIG_CLAW is not set
 CONFIG_QETH=y
-
-#
-# Gigabit Ethernet default settings
-#
-# CONFIG_QETH_IPV6 is not set
+CONFIG_QETH_L2=y
+CONFIG_QETH_L3=y
+CONFIG_QETH_IPV6=y
 CONFIG_CCWGROUP=y
 # CONFIG_PPP is not set
 # CONFIG_SLIP is not set
Index: my_git/drivers/s390/net/Kconfig
===================================================================
--- my_git.orig/drivers/s390/net/Kconfig	2008-02-14 13:22:16.000000000 +0100
+++ my_git/drivers/s390/net/Kconfig	2008-02-14 13:36:43.000000000 +0100
@@ -67,23 +67,26 @@
 	  To compile this driver as a module, choose M.
 	  The module name is qeth.ko.
 
+config QETH_L2
+        tristate "qeth layer 2 device support"
+        depends on QETH
+        help
+          Select this option to be able to run qeth devices in layer 2 mode.
+          To compile as a module, choose M. The module name is qeth_l2.ko.
+          If unsure, choose y.
 
-comment "Gigabit Ethernet default settings"
-	depends on QETH
+config QETH_L3
+        tristate "qeth layer 3 device support"
+        depends on QETH
+        help
+          Select this option to be able to run qeth devices in layer 3 mode.
+          To compile as a module choose M. The module name is qeth_l3.ko.
+          If unsure, choose Y.
 
 config QETH_IPV6
-	bool "IPv6 support for gigabit ethernet"
-	depends on (QETH = IPV6) || (QETH && IPV6 = 'y')
-	help
-	  If CONFIG_QETH is switched on, this option will include IPv6
-	  support in the qeth device driver.
-	
-config QETH_VLAN
-	bool "VLAN support for gigabit ethernet"
-	depends on (QETH = VLAN_8021Q) || (QETH && VLAN_8021Q = 'y')
-	help
-	  If CONFIG_QETH is switched on, this option will include IEEE
-	  802.1q VLAN support in the qeth device driver.
+        bool
+        depends on (QETH_L3 = IPV6) || (QETH_L3 && IPV6 = 'y')
+        default y
 
 config CCWGROUP
 	tristate
Index: my_git/drivers/s390/net/Makefile
===================================================================
--- my_git.orig/drivers/s390/net/Makefile	2008-02-14 13:22:16.000000000 +0100
+++ my_git/drivers/s390/net/Makefile	2008-02-14 13:49:28.000000000 +0100
@@ -8,6 +8,9 @@
 obj-$(CONFIG_SMSGIUCV) += smsgiucv.o
 obj-$(CONFIG_LCS) += lcs.o cu3088.o
 obj-$(CONFIG_CLAW) += claw.o cu3088.o
-qeth-y := qeth_main.o qeth_mpc.o qeth_sys.o qeth_eddp.o 
-qeth-$(CONFIG_PROC_FS) += qeth_proc.o
+qeth-y += qeth_core_sys.o qeth_core_main.o qeth_core_mpc.o qeth_core_offl.o
 obj-$(CONFIG_QETH) += qeth.o
+qeth_l2-y += qeth_l2_main.o
+obj-$(CONFIG_QETH_L2) += qeth_l2.o
+qeth_l3-y += qeth_l3_main.o qeth_l3_sys.o
+obj-$(CONFIG_QETH_L3) += qeth_l3.o
Index: my_git/drivers/s390/net/qeth_core.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ my_git/drivers/s390/net/qeth_core.h	2008-02-14 13:53:48.000000000 +0100
@@ -0,0 +1,916 @@
+/*
+ *  drivers/s390/net/qeth_core.h
+ *
+ *    Copyright IBM Corp. 2007
+ *    Author(s): Utz Bacher <utz.bacher@de.ibm.com>,
+ *		 Frank Pavlic <fpavlic@de.ibm.com>,
+ *		 Thomas Spatzier <tspat@de.ibm.com>,
+ *		 Frank Blaschka <frank.blaschka@de.ibm.com>
+ */
+
+#ifndef __QETH_CORE_H__
+#define __QETH_CORE_H__
+
+#include <linux/if.h>
+#include <linux/if_arp.h>
+#include <linux/if_tr.h>
+#include <linux/trdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
+#include <linux/ctype.h>
+#include <linux/in6.h>
+#include <linux/bitops.h>
+#include <linux/seq_file.h>
+#include <linux/ethtool.h>
+
+#include <net/ipv6.h>
+#include <net/if_inet6.h>
+#include <net/addrconf.h>
+
+#include <asm/debug.h>
+#include <asm/qdio.h>
+#include <asm/ccwdev.h>
+#include <asm/ccwgroup.h>
+
+#include "qeth_core_mpc.h"
+
+/**
+ * Debug Facility stuff
+ */
+#define QETH_DBF_SETUP_NAME "qeth_setup"
+#define QETH_DBF_SETUP_LEN 8
+#define QETH_DBF_SETUP_PAGES 8
+#define QETH_DBF_SETUP_NR_AREAS 1
+#define QETH_DBF_SETUP_LEVEL 5
+
+#define QETH_DBF_MISC_NAME "qeth_misc"
+#define QETH_DBF_MISC_LEN 128
+#define QETH_DBF_MISC_PAGES 2
+#define QETH_DBF_MISC_NR_AREAS 1
+#define QETH_DBF_MISC_LEVEL 2
+
+#define QETH_DBF_DATA_NAME "qeth_data"
+#define QETH_DBF_DATA_LEN 96
+#define QETH_DBF_DATA_PAGES 8
+#define QETH_DBF_DATA_NR_AREAS 1
+#define QETH_DBF_DATA_LEVEL 2
+
+#define QETH_DBF_CONTROL_NAME "qeth_control"
+#define QETH_DBF_CONTROL_LEN 256
+#define QETH_DBF_CONTROL_PAGES 8
+#define QETH_DBF_CONTROL_NR_AREAS 1
+#define QETH_DBF_CONTROL_LEVEL 5
+
+#define QETH_DBF_TRACE_NAME "qeth_trace"
+#define QETH_DBF_TRACE_LEN 8
+#define QETH_DBF_TRACE_PAGES 4
+#define QETH_DBF_TRACE_NR_AREAS 1
+#define QETH_DBF_TRACE_LEVEL 3
+
+#define QETH_DBF_SENSE_NAME "qeth_sense"
+#define QETH_DBF_SENSE_LEN 64
+#define QETH_DBF_SENSE_PAGES 2
+#define QETH_DBF_SENSE_NR_AREAS 1
+#define QETH_DBF_SENSE_LEVEL 2
+
+#define QETH_DBF_QERR_NAME "qeth_qerr"
+#define QETH_DBF_QERR_LEN 8
+#define QETH_DBF_QERR_PAGES 2
+#define QETH_DBF_QERR_NR_AREAS 1
+#define QETH_DBF_QERR_LEVEL 2
+
+#define QETH_DBF_TEXT(name, level, text) \
+	do { \
+		debug_text_event(qeth_dbf_##name, level, text); \
+	} while (0)
+
+#define QETH_DBF_HEX(name, level, addr, len) \
+	do { \
+		debug_event(qeth_dbf_##name, level, (void *)(addr), len); \
+	} while (0)
+
+/* Allow to sort out low debug levels early to avoid wasted sprints */
+static inline int qeth_dbf_passes(debug_info_t *dbf_grp, int level)
+{
+	return (level <= dbf_grp->level);
+}
+
+/**
+ * some more debug stuff
+ */
+#define PRINTK_HEADER	"qeth: "
+
+#define SENSE_COMMAND_REJECT_BYTE 0
+#define SENSE_COMMAND_REJECT_FLAG 0x80
+#define SENSE_RESETTING_EVENT_BYTE 1
+#define SENSE_RESETTING_EVENT_FLAG 0x80
+
+/*
+ * Common IO related definitions
+ */
+#define CARD_RDEV(card) card->read.ccwdev
+#define CARD_WDEV(card) card->write.ccwdev
+#define CARD_DDEV(card) card->data.ccwdev
+#define CARD_BUS_ID(card) card->gdev->dev.bus_id
+#define CARD_RDEV_ID(card) card->read.ccwdev->dev.bus_id
+#define CARD_WDEV_ID(card) card->write.ccwdev->dev.bus_id
+#define CARD_DDEV_ID(card) card->data.ccwdev->dev.bus_id
+#define CHANNEL_ID(channel) channel->ccwdev->dev.bus_id
+
+/**
+ * card stuff
+ */
+struct qeth_perf_stats {
+	unsigned int bufs_rec;
+	unsigned int bufs_sent;
+
+	unsigned int skbs_sent_pack;
+	unsigned int bufs_sent_pack;
+
+	unsigned int sc_dp_p;
+	unsigned int sc_p_dp;
+	/* qdio_input_handler: number of times called, time spent in */
+	__u64 inbound_start_time;
+	unsigned int inbound_cnt;
+	unsigned int inbound_time;
+	/* qeth_send_packet: number of times called, time spent in */
+	__u64 outbound_start_time;
+	unsigned int outbound_cnt;
+	unsigned int outbound_time;
+	/* qdio_output_handler: number of times called, time spent in */
+	__u64 outbound_handler_start_time;
+	unsigned int outbound_handler_cnt;
+	unsigned int outbound_handler_time;
+	/* number of calls to and time spent in do_QDIO for inbound queue */
+	__u64 inbound_do_qdio_start_time;
+	unsigned int inbound_do_qdio_cnt;
+	unsigned int inbound_do_qdio_time;
+	/* number of calls to and time spent in do_QDIO for outbound queues */
+	__u64 outbound_do_qdio_start_time;
+	unsigned int outbound_do_qdio_cnt;
+	unsigned int outbound_do_qdio_time;
+	/* eddp data */
+	unsigned int large_send_bytes;
+	unsigned int large_send_cnt;
+	unsigned int sg_skbs_sent;
+	unsigned int sg_frags_sent;
+	/* initial values when measuring starts */
+	unsigned long initial_rx_packets;
+	unsigned long initial_tx_packets;
+	/* inbound scatter gather data */
+	unsigned int sg_skbs_rx;
+	unsigned int sg_frags_rx;
+	unsigned int sg_alloc_page_rx;
+};
+
+/* Routing stuff */
+struct qeth_routing_info {
+	enum qeth_routing_types type;
+};
+
+/* IPA stuff */
+struct qeth_ipa_info {
+	__u32 supported_funcs;
+	__u32 enabled_funcs;
+};
+
+static inline int qeth_is_ipa_supported(struct qeth_ipa_info *ipa,
+		enum qeth_ipa_funcs func)
+{
+	return (ipa->supported_funcs & func);
+}
+
+static inline int qeth_is_ipa_enabled(struct qeth_ipa_info *ipa,
+		enum qeth_ipa_funcs func)
+{
+	return (ipa->supported_funcs & ipa->enabled_funcs & func);
+}
+
+#define qeth_adp_supported(c, f) \
+	qeth_is_ipa_supported(&c->options.adp, f)
+#define qeth_adp_enabled(c, f) \
+	qeth_is_ipa_enabled(&c->options.adp, f)
+#define qeth_is_supported(c, f) \
+	qeth_is_ipa_supported(&c->options.ipa4, f)
+#define qeth_is_enabled(c, f) \
+	qeth_is_ipa_enabled(&c->options.ipa4, f)
+#define qeth_is_supported6(c, f) \
+	qeth_is_ipa_supported(&c->options.ipa6, f)
+#define qeth_is_enabled6(c, f) \
+	qeth_is_ipa_enabled(&c->options.ipa6, f)
+#define qeth_is_ipafunc_supported(c, prot, f) \
+	 ((prot == QETH_PROT_IPV6) ? \
+		qeth_is_supported6(c, f) : qeth_is_supported(c, f))
+#define qeth_is_ipafunc_enabled(c, prot, f) \
+	 ((prot == QETH_PROT_IPV6) ? \
+		qeth_is_enabled6(c, f) : qeth_is_enabled(c, f))
+
+#define QETH_IDX_FUNC_LEVEL_OSAE_ENA_IPAT 0x0101
+#define QETH_IDX_FUNC_LEVEL_OSAE_DIS_IPAT 0x0101
+#define QETH_IDX_FUNC_LEVEL_IQD_ENA_IPAT 0x4108
+#define QETH_IDX_FUNC_LEVEL_IQD_DIS_IPAT 0x5108
+
+#define QETH_MODELLIST_ARRAY \
+	{{0x1731, 0x01, 0x1732, 0x01, QETH_CARD_TYPE_OSAE, 1, \
+	QETH_IDX_FUNC_LEVEL_OSAE_ENA_IPAT, \
+	QETH_IDX_FUNC_LEVEL_OSAE_DIS_IPAT, \
+	QETH_MAX_QUEUES, 0}, \
+	{0x1731, 0x05, 0x1732, 0x05, QETH_CARD_TYPE_IQD, 0, \
+	QETH_IDX_FUNC_LEVEL_IQD_ENA_IPAT, \
+	QETH_IDX_FUNC_LEVEL_IQD_DIS_IPAT, \
+	QETH_MAX_QUEUES, 0x103}, \
+	{0x1731, 0x06, 0x1732, 0x06, QETH_CARD_TYPE_OSN, 0, \
+	QETH_IDX_FUNC_LEVEL_OSAE_ENA_IPAT, \
+	QETH_IDX_FUNC_LEVEL_OSAE_DIS_IPAT, \
+	QETH_MAX_QUEUES, 0}, \
+	{0, 0, 0, 0, 0, 0, 0, 0, 0} }
+
+#define QETH_REAL_CARD		1
+#define QETH_VLAN_CARD		2
+#define QETH_BUFSIZE		4096
+
+/**
+ * some more defs
+ */
+#define QETH_TX_TIMEOUT		100 * HZ
+#define QETH_RCD_TIMEOUT	60 * HZ
+#define QETH_HEADER_SIZE	32
+#define QETH_MAX_PORTNO		15
+
+/*IPv6 address autoconfiguration stuff*/
+#define UNIQUE_ID_IF_CREATE_ADDR_FAILED 0xfffe
+#define UNIQUE_ID_NOT_BY_CARD		0x10000
+
+/*****************************************************************************/
+/* QDIO queue and buffer handling                                            */
+/*****************************************************************************/
+#define QETH_MAX_QUEUES 4
+#define QETH_IN_BUF_SIZE_DEFAULT 65536
+#define QETH_IN_BUF_COUNT_DEFAULT 16
+#define QETH_IN_BUF_COUNT_MIN 8
+#define QETH_IN_BUF_COUNT_MAX 128
+#define QETH_MAX_BUFFER_ELEMENTS(card) ((card)->qdio.in_buf_size >> 12)
+#define QETH_IN_BUF_REQUEUE_THRESHOLD(card) \
+		((card)->qdio.in_buf_pool.buf_count / 2)
+
+/* buffers we have to be behind before we get a PCI */
+#define QETH_PCI_THRESHOLD_A(card) ((card)->qdio.in_buf_pool.buf_count+1)
+/*enqueued free buffers left before we get a PCI*/
+#define QETH_PCI_THRESHOLD_B(card) 0
+/*not used unless the microcode gets patched*/
+#define QETH_PCI_TIMER_VALUE(card) 3
+
+#define QETH_MIN_INPUT_THRESHOLD 1
+#define QETH_MAX_INPUT_THRESHOLD 500
+#define QETH_MIN_OUTPUT_THRESHOLD 1
+#define QETH_MAX_OUTPUT_THRESHOLD 300
+
+/* priority queing */
+#define QETH_PRIOQ_DEFAULT QETH_NO_PRIO_QUEUEING
+#define QETH_DEFAULT_QUEUE    2
+#define QETH_NO_PRIO_QUEUEING 0
+#define QETH_PRIO_Q_ING_PREC  1
+#define QETH_PRIO_Q_ING_TOS   2
+#define IP_TOS_LOWDELAY 0x10
+#define IP_TOS_HIGHTHROUGHPUT 0x08
+#define IP_TOS_HIGHRELIABILITY 0x04
+#define IP_TOS_NOTIMPORTANT 0x02
+
+/* Packing */
+#define QETH_LOW_WATERMARK_PACK  2
+#define QETH_HIGH_WATERMARK_PACK 5
+#define QETH_WATERMARK_PACK_FUZZ 1
+
+#define QETH_IP_HEADER_SIZE 40
+
+/* large receive scatter gather copy break */
+#define QETH_RX_SG_CB (PAGE_SIZE >> 1)
+
+struct qeth_hdr_layer3 {
+	__u8  id;
+	__u8  flags;
+	__u16 inbound_checksum; /*TSO:__u16 seqno */
+	__u32 token;		/*TSO: __u32 reserved */
+	__u16 length;
+	__u8  vlan_prio;
+	__u8  ext_flags;
+	__u16 vlan_id;
+	__u16 frame_offset;
+	__u8  dest_addr[16];
+} __attribute__ ((packed));
+
+struct qeth_hdr_layer2 {
+	__u8 id;
+	__u8 flags[3];
+	__u8 port_no;
+	__u8 hdr_length;
+	__u16 pkt_length;
+	__u16 seq_no;
+	__u16 vlan_id;
+	__u32 reserved;
+	__u8 reserved2[16];
+} __attribute__ ((packed));
+
+struct qeth_hdr_osn {
+	__u8 id;
+	__u8 reserved;
+	__u16 seq_no;
+	__u16 reserved2;
+	__u16 control_flags;
+	__u16 pdu_length;
+	__u8 reserved3[18];
+	__u32 ccid;
+} __attribute__ ((packed));
+
+struct qeth_hdr {
+	union {
+		struct qeth_hdr_layer2 l2;
+		struct qeth_hdr_layer3 l3;
+		struct qeth_hdr_osn    osn;
+	} hdr;
+} __attribute__ ((packed));
+
+/*TCP Segmentation Offload header*/
+struct qeth_hdr_ext_tso {
+	__u16 hdr_tot_len;
+	__u8  imb_hdr_no;
+	__u8  reserved;
+	__u8  hdr_type;
+	__u8  hdr_version;
+	__u16 hdr_len;
+	__u32 payload_len;
+	__u16 mss;
+	__u16 dg_hdr_len;
+	__u8  padding[16];
+} __attribute__ ((packed));
+
+struct qeth_hdr_tso {
+	struct qeth_hdr hdr;	/*hdr->hdr.l3.xxx*/
+	struct qeth_hdr_ext_tso ext;
+} __attribute__ ((packed));
+
+
+/* flags for qeth_hdr.flags */
+#define QETH_HDR_PASSTHRU 0x10
+#define QETH_HDR_IPV6     0x80
+#define QETH_HDR_CAST_MASK 0x07
+enum qeth_cast_flags {
+	QETH_CAST_UNICAST   = 0x06,
+	QETH_CAST_MULTICAST = 0x04,
+	QETH_CAST_BROADCAST = 0x05,
+	QETH_CAST_ANYCAST   = 0x07,
+	QETH_CAST_NOCAST    = 0x00,
+};
+
+enum qeth_layer2_frame_flags {
+	QETH_LAYER2_FLAG_MULTICAST = 0x01,
+	QETH_LAYER2_FLAG_BROADCAST = 0x02,
+	QETH_LAYER2_FLAG_UNICAST   = 0x04,
+	QETH_LAYER2_FLAG_VLAN      = 0x10,
+};
+
+enum qeth_header_ids {
+	QETH_HEADER_TYPE_LAYER3 = 0x01,
+	QETH_HEADER_TYPE_LAYER2 = 0x02,
+	QETH_HEADER_TYPE_TSO	= 0x03,
+	QETH_HEADER_TYPE_OSN    = 0x04,
+};
+/* flags for qeth_hdr.ext_flags */
+#define QETH_HDR_EXT_VLAN_FRAME       0x01
+#define QETH_HDR_EXT_TOKEN_ID         0x02
+#define QETH_HDR_EXT_INCLUDE_VLAN_TAG 0x04
+#define QETH_HDR_EXT_SRC_MAC_ADDR     0x08
+#define QETH_HDR_EXT_CSUM_HDR_REQ     0x10
+#define QETH_HDR_EXT_CSUM_TRANSP_REQ  0x20
+#define QETH_HDR_EXT_UDP_TSO          0x40 /*bit off for TCP*/
+
+static inline int qeth_is_last_sbale(struct qdio_buffer_element *sbale)
+{
+	return (sbale->flags & SBAL_FLAGS_LAST_ENTRY);
+}
+
+enum qeth_qdio_buffer_states {
+	/*
+	 * inbound: read out by driver; owned by hardware in order to be filled
+	 * outbound: owned by driver in order to be filled
+	 */
+	QETH_QDIO_BUF_EMPTY,
+	/*
+	 * inbound: filled by hardware; owned by driver in order to be read out
+	 * outbound: filled by driver; owned by hardware in order to be sent
+	 */
+	QETH_QDIO_BUF_PRIMED,
+};
+
+enum qeth_qdio_info_states {
+	QETH_QDIO_UNINITIALIZED,
+	QETH_QDIO_ALLOCATED,
+	QETH_QDIO_ESTABLISHED,
+	QETH_QDIO_CLEANING
+};
+
+struct qeth_buffer_pool_entry {
+	struct list_head list;
+	struct list_head init_list;
+	void *elements[QDIO_MAX_ELEMENTS_PER_BUFFER];
+};
+
+struct qeth_qdio_buffer_pool {
+	struct list_head entry_list;
+	int buf_count;
+};
+
+struct qeth_qdio_buffer {
+	struct qdio_buffer *buffer;
+	/* the buffer pool entry currently associated to this buffer */
+	struct qeth_buffer_pool_entry *pool_entry;
+};
+
+struct qeth_qdio_q {
+	struct qdio_buffer qdio_bufs[QDIO_MAX_BUFFERS_PER_Q];
+	struct qeth_qdio_buffer bufs[QDIO_MAX_BUFFERS_PER_Q];
+	int next_buf_to_init;
+} __attribute__ ((aligned(256)));
+
+/* possible types of qeth large_send support */
+enum qeth_large_send_types {
+	QETH_LARGE_SEND_NO,
+	QETH_LARGE_SEND_EDDP,
+	QETH_LARGE_SEND_TSO,
+};
+
+struct qeth_qdio_out_buffer {
+	struct qdio_buffer *buffer;
+	atomic_t state;
+	int next_element_to_fill;
+	struct sk_buff_head skb_list;
+	struct list_head ctx_list;
+};
+
+struct qeth_card;
+
+enum qeth_out_q_states {
+       QETH_OUT_Q_UNLOCKED,
+       QETH_OUT_Q_LOCKED,
+       QETH_OUT_Q_LOCKED_FLUSH,
+};
+
+struct qeth_qdio_out_q {
+	struct qdio_buffer qdio_bufs[QDIO_MAX_BUFFERS_PER_Q];
+	struct qeth_qdio_out_buffer bufs[QDIO_MAX_BUFFERS_PER_Q];
+	int queue_no;
+	struct qeth_card *card;
+	atomic_t state;
+	int do_pack;
+	/*
+	 * index of buffer to be filled by driver; state EMPTY or PACKING
+	 */
+	int next_buf_to_fill;
+	/*
+	 * number of buffers that are currently filled (PRIMED)
+	 * -> these buffers are hardware-owned
+	 */
+	atomic_t used_buffers;
+	/* indicates whether PCI flag must be set (or if one is outstanding) */
+	atomic_t set_pci_flags_count;
+} __attribute__ ((aligned(256)));
+
+struct qeth_qdio_info {
+	atomic_t state;
+	/* input */
+	struct qeth_qdio_q *in_q;
+	struct qeth_qdio_buffer_pool in_buf_pool;
+	struct qeth_qdio_buffer_pool init_pool;
+	int in_buf_size;
+
+	/* output */
+	int no_out_queues;
+	struct qeth_qdio_out_q **out_qs;
+
+	/* priority queueing */
+	int do_prio_queueing;
+	int default_out_queue;
+};
+
+enum qeth_send_errors {
+	QETH_SEND_ERROR_NONE,
+	QETH_SEND_ERROR_LINK_FAILURE,
+	QETH_SEND_ERROR_RETRY,
+	QETH_SEND_ERROR_KICK_IT,
+};
+
+#define QETH_ETH_MAC_V4      0x0100 /* like v4 */
+#define QETH_ETH_MAC_V6      0x3333 /* like v6 */
+/* tr mc mac is longer, but that will be enough to detect mc frames */
+#define QETH_TR_MAC_NC       0xc000 /* non-canonical */
+#define QETH_TR_MAC_C        0x0300 /* canonical */
+
+#define DEFAULT_ADD_HHLEN 0
+#define MAX_ADD_HHLEN 1024
+
+/**
+ * buffer stuff for read channel
+ */
+#define QETH_CMD_BUFFER_NO	8
+
+/**
+ *  channel state machine
+ */
+enum qeth_channel_states {
+	CH_STATE_UP,
+	CH_STATE_DOWN,
+	CH_STATE_ACTIVATING,
+	CH_STATE_HALTED,
+	CH_STATE_STOPPED,
+	CH_STATE_RCD,
+	CH_STATE_RCD_DONE,
+};
+/**
+ * card state machine
+ */
+enum qeth_card_states {
+	CARD_STATE_DOWN,
+	CARD_STATE_HARDSETUP,
+	CARD_STATE_SOFTSETUP,
+	CARD_STATE_UP,
+	CARD_STATE_RECOVER,
+};
+
+/**
+ * Protocol versions
+ */
+enum qeth_prot_versions {
+	QETH_PROT_IPV4 = 0x0004,
+	QETH_PROT_IPV6 = 0x0006,
+};
+
+enum qeth_ip_types {
+	QETH_IP_TYPE_NORMAL,
+	QETH_IP_TYPE_VIPA,
+	QETH_IP_TYPE_RXIP,
+	QETH_IP_TYPE_DEL_ALL_MC,
+};
+
+enum qeth_cmd_buffer_state {
+	BUF_STATE_FREE,
+	BUF_STATE_LOCKED,
+	BUF_STATE_PROCESSED,
+};
+
+struct qeth_ipato {
+	int enabled;
+	int invert4;
+	int invert6;
+	struct list_head entries;
+};
+
+struct qeth_channel;
+
+struct qeth_cmd_buffer {
+	enum qeth_cmd_buffer_state state;
+	struct qeth_channel *channel;
+	unsigned char *data;
+	int rc;
+	void (*callback) (struct qeth_channel *, struct qeth_cmd_buffer *);
+};
+
+/**
+ * definition of a qeth channel, used for read and write
+ */
+struct qeth_channel {
+	enum qeth_channel_states state;
+	struct ccw1 ccw;
+	spinlock_t iob_lock;
+	wait_queue_head_t wait_q;
+	struct tasklet_struct irq_tasklet;
+	struct ccw_device *ccwdev;
+/*command buffer for control data*/
+	struct qeth_cmd_buffer iob[QETH_CMD_BUFFER_NO];
+	atomic_t irq_pending;
+	int io_buf_no;
+	int buf_no;
+};
+
+/**
+ *  OSA card related definitions
+ */
+struct qeth_token {
+	__u32 issuer_rm_w;
+	__u32 issuer_rm_r;
+	__u32 cm_filter_w;
+	__u32 cm_filter_r;
+	__u32 cm_connection_w;
+	__u32 cm_connection_r;
+	__u32 ulp_filter_w;
+	__u32 ulp_filter_r;
+	__u32 ulp_connection_w;
+	__u32 ulp_connection_r;
+};
+
+struct qeth_seqno {
+	__u32 trans_hdr;
+	__u32 pdu_hdr;
+	__u32 pdu_hdr_ack;
+	__u16 ipa;
+	__u32 pkt_seqno;
+};
+
+struct qeth_reply {
+	struct list_head list;
+	wait_queue_head_t wait_q;
+	int (*callback)(struct qeth_card *, struct qeth_reply *,
+		unsigned long);
+	u32 seqno;
+	unsigned long offset;
+	atomic_t received;
+	int rc;
+	void *param;
+	struct qeth_card *card;
+	atomic_t refcnt;
+};
+
+
+struct qeth_card_blkt {
+	int time_total;
+	int inter_packet;
+	int inter_packet_jumbo;
+};
+
+#define QETH_BROADCAST_WITH_ECHO    0x01
+#define QETH_BROADCAST_WITHOUT_ECHO 0x02
+#define QETH_LAYER2_MAC_READ	    0x01
+#define QETH_LAYER2_MAC_REGISTERED  0x02
+struct qeth_card_info {
+	unsigned short unit_addr2;
+	unsigned short cula;
+	unsigned short chpid;
+	__u16 func_level;
+	char mcl_level[QETH_MCL_LENGTH + 1];
+	int guestlan;
+	int mac_bits;
+	int portname_required;
+	int portno;
+	char portname[9];
+	enum qeth_card_types type;
+	enum qeth_link_types link_type;
+	int is_multicast_different;
+	int initial_mtu;
+	int max_mtu;
+	int broadcast_capable;
+	int unique_id;
+	struct qeth_card_blkt blkt;
+	__u32 csum_mask;
+	enum qeth_ipa_promisc_modes promisc_mode;
+};
+
+struct qeth_card_options {
+	struct qeth_routing_info route4;
+	struct qeth_ipa_info ipa4;
+	struct qeth_ipa_info adp; /*Adapter parameters*/
+	struct qeth_routing_info route6;
+	struct qeth_ipa_info ipa6;
+	enum qeth_checksum_types checksum_type;
+	int broadcast_mode;
+	int macaddr_mode;
+	int fake_broadcast;
+	int add_hhlen;
+	int fake_ll;
+	int layer2;
+	enum qeth_large_send_types large_send;
+	int performance_stats;
+	int rx_sg_cb;
+};
+
+/*
+ * thread bits for qeth_card thread masks
+ */
+enum qeth_threads {
+	QETH_RECOVER_THREAD = 1,
+};
+
+struct qeth_osn_info {
+	int (*assist_cb)(struct net_device *dev, void *data);
+	int (*data_cb)(struct sk_buff *skb);
+};
+
+enum qeth_discipline_id {
+	QETH_DISCIPLINE_LAYER3 = 0,
+	QETH_DISCIPLINE_LAYER2 = 1,
+};
+
+struct qeth_discipline {
+	qdio_handler_t *input_handler;
+	qdio_handler_t *output_handler;
+	int (*recover)(void *ptr);
+	struct ccwgroup_driver *ccwgdriver;
+};
+
+struct qeth_vlan_vid {
+	struct list_head list;
+	unsigned short vid;
+};
+
+struct qeth_mc_mac {
+	struct list_head list;
+	__u8 mc_addr[MAX_ADDR_LEN];
+	unsigned char mc_addrlen;
+};
+
+struct qeth_card {
+	struct list_head list;
+	enum qeth_card_states state;
+	int lan_online;
+	spinlock_t lock;
+	struct ccwgroup_device *gdev;
+	struct qeth_channel read;
+	struct qeth_channel write;
+	struct qeth_channel data;
+
+	struct net_device *dev;
+	struct net_device_stats stats;
+
+	struct qeth_card_info info;
+	struct qeth_token token;
+	struct qeth_seqno seqno;
+	struct qeth_card_options options;
+
+	wait_queue_head_t wait_q;
+	spinlock_t vlanlock;
+	spinlock_t mclock;
+	struct vlan_group *vlangrp;
+	struct list_head vid_list;
+	struct list_head mc_list;
+	struct work_struct kernel_thread_starter;
+	spinlock_t thread_mask_lock;
+	unsigned long thread_start_mask;
+	unsigned long thread_allowed_mask;
+	unsigned long thread_running_mask;
+	spinlock_t ip_lock;
+	struct list_head ip_list;
+	struct list_head *ip_tbd_list;
+	struct qeth_ipato ipato;
+	struct list_head cmd_waiter_list;
+	/* QDIO buffer handling */
+	struct qeth_qdio_info qdio;
+	struct qeth_perf_stats perf_stats;
+	int use_hard_stop;
+	struct qeth_osn_info osn_info;
+	struct qeth_discipline discipline;
+	atomic_t force_alloc_skb;
+};
+
+struct qeth_card_list_struct {
+	struct list_head list;
+	rwlock_t rwlock;
+};
+
+/*some helper functions*/
+#define QETH_CARD_IFNAME(card) (((card)->dev)? (card)->dev->name : "")
+
+static inline struct qeth_card *CARD_FROM_CDEV(struct ccw_device *cdev)
+{
+	struct qeth_card *card = dev_get_drvdata(&((struct ccwgroup_device *)
+		dev_get_drvdata(&cdev->dev))->dev);
+	return card;
+}
+
+static inline int qeth_get_micros(void)
+{
+	return (int) (get_clock() >> 12);
+}
+
+static inline void *qeth_push_skb(struct qeth_card *card, struct sk_buff *skb,
+		int size)
+{
+	void *hdr;
+
+	hdr = (void *) skb_push(skb, size);
+	/*
+	 * sanity check, the Linux memory allocation scheme should
+	 * never present us cases like this one (the qdio header size plus
+	 * the first 40 bytes of the paket cross a 4k boundary)
+	 */
+	if ((((unsigned long) hdr) & (~(PAGE_SIZE - 1))) !=
+	    (((unsigned long) hdr + size +
+	    QETH_IP_HEADER_SIZE) & (~(PAGE_SIZE - 1)))) {
+		PRINT_ERR("Misaligned packet on interface %s. Discarded.",
+			QETH_CARD_IFNAME(card));
+		return NULL;
+	}
+	return hdr;
+}
+
+static inline int qeth_get_ip_version(struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case ETH_P_IPV6:
+		return 6;
+	case ETH_P_IP:
+		return 4;
+	default:
+		return 0;
+	}
+}
+
+struct qeth_eddp_context;
+extern struct ccwgroup_driver qeth_l2_ccwgroup_driver;
+extern struct ccwgroup_driver qeth_l3_ccwgroup_driver;
+const char *qeth_get_cardname_short(struct qeth_card *);
+int qeth_realloc_buffer_pool(struct qeth_card *, int);
+int qeth_core_load_discipline(struct qeth_card *, enum qeth_discipline_id);
+void qeth_core_free_discipline(struct qeth_card *);
+int qeth_core_create_device_attributes(struct device *);
+void qeth_core_remove_device_attributes(struct device *);
+int qeth_core_create_osn_attributes(struct device *);
+void qeth_core_remove_osn_attributes(struct device *);
+
+/* exports for qeth discipline device drivers */
+extern struct qeth_card_list_struct qeth_core_card_list;
+extern debug_info_t *qeth_dbf_setup;
+extern debug_info_t *qeth_dbf_data;
+extern debug_info_t *qeth_dbf_misc;
+extern debug_info_t *qeth_dbf_control;
+extern debug_info_t *qeth_dbf_trace;
+extern debug_info_t *qeth_dbf_sense;
+extern debug_info_t *qeth_dbf_qerr;
+
+void qeth_set_allowed_threads(struct qeth_card *, unsigned long , int);
+int qeth_threads_running(struct qeth_card *, unsigned long);
+int qeth_wait_for_threads(struct qeth_card *, unsigned long);
+int qeth_do_run_thread(struct qeth_card *, unsigned long);
+void qeth_clear_thread_start_bit(struct qeth_card *, unsigned long);
+void qeth_clear_thread_running_bit(struct qeth_card *, unsigned long);
+int qeth_core_hardsetup_card(struct qeth_card *);
+void qeth_print_status_message(struct qeth_card *);
+int qeth_init_qdio_queues(struct qeth_card *);
+int qeth_send_startlan(struct qeth_card *);
+int qeth_send_stoplan(struct qeth_card *);
+int qeth_send_ipa_cmd(struct qeth_card *, struct qeth_cmd_buffer *,
+		  int (*reply_cb)
+		  (struct qeth_card *, struct qeth_reply *, unsigned long),
+		  void *);
+struct qeth_cmd_buffer *qeth_get_ipacmd_buffer(struct qeth_card *,
+			enum qeth_ipa_cmds, enum qeth_prot_versions);
+int qeth_query_setadapterparms(struct qeth_card *);
+int qeth_check_qdio_errors(struct qdio_buffer *, unsigned int,
+		       unsigned int, const char *);
+void qeth_put_buffer_pool_entry(struct qeth_card *,
+			   struct qeth_buffer_pool_entry *);
+void qeth_queue_input_buffer(struct qeth_card *, int);
+struct sk_buff *qeth_core_get_next_skb(struct qeth_card *,
+		struct qdio_buffer *, struct qdio_buffer_element **, int *,
+		struct qeth_hdr **);
+void qeth_schedule_recovery(struct qeth_card *);
+void qeth_qdio_output_handler(struct ccw_device *, unsigned int,
+			unsigned int, unsigned int,
+			unsigned int, int, int,
+			unsigned long);
+void qeth_clear_ipacmd_list(struct qeth_card *);
+int qeth_qdio_clear_card(struct qeth_card *, int);
+void qeth_clear_working_pool_list(struct qeth_card *);
+void qeth_clear_cmd_buffers(struct qeth_channel *);
+void qeth_clear_qdio_buffers(struct qeth_card *);
+void qeth_setadp_promisc_mode(struct qeth_card *);
+struct net_device_stats *qeth_get_stats(struct net_device *);
+int qeth_change_mtu(struct net_device *, int);
+int qeth_setadpparms_change_macaddr(struct qeth_card *);
+void qeth_tx_timeout(struct net_device *);
+void qeth_prepare_control_data(struct qeth_card *, int,
+				struct qeth_cmd_buffer *);
+void qeth_release_buffer(struct qeth_channel *, struct qeth_cmd_buffer *);
+void qeth_prepare_ipa_cmd(struct qeth_card *, struct qeth_cmd_buffer *, char);
+struct qeth_cmd_buffer *qeth_wait_for_buffer(struct qeth_channel *);
+int qeth_mdio_read(struct net_device *, int, int);
+int qeth_snmp_command(struct qeth_card *, char __user *);
+int qeth_set_large_send(struct qeth_card *, enum qeth_large_send_types);
+struct qeth_cmd_buffer *qeth_get_adapter_cmd(struct qeth_card *, __u32, __u32);
+int qeth_default_setadapterparms_cb(struct qeth_card *, struct qeth_reply *,
+					unsigned long);
+int qeth_send_control_data(struct qeth_card *, int, struct qeth_cmd_buffer *,
+	int (*reply_cb)(struct qeth_card *, struct qeth_reply*, unsigned long),
+	void *reply_param);
+int qeth_get_cast_type(struct qeth_card *, struct sk_buff *);
+int qeth_get_priority_queue(struct qeth_card *, struct sk_buff *, int, int);
+struct sk_buff *qeth_prepare_skb(struct qeth_card *, struct sk_buff *,
+		 struct qeth_hdr **);
+int qeth_get_elements_no(struct qeth_card *, void *, struct sk_buff *, int);
+int qeth_do_send_packet_fast(struct qeth_card *, struct qeth_qdio_out_q *,
+			struct sk_buff *, struct qeth_hdr *, int,
+			struct qeth_eddp_context *);
+int qeth_do_send_packet(struct qeth_card *, struct qeth_qdio_out_q *,
+		    struct sk_buff *, struct qeth_hdr *,
+		    int, struct qeth_eddp_context *);
+int qeth_core_get_stats_count(struct net_device *);
+void qeth_core_get_ethtool_stats(struct net_device *,
+				struct ethtool_stats *, u64 *);
+void qeth_core_get_strings(struct net_device *, u32, u8 *);
+void qeth_core_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
+
+/* exports for OSN */
+int qeth_osn_assist(struct net_device *, void *, int);
+int qeth_osn_register(unsigned char *read_dev_no, struct net_device **,
+		int (*assist_cb)(struct net_device *, void *),
+		int (*data_cb)(struct sk_buff *));
+void qeth_osn_deregister(struct net_device *);
+
+#endif /* __QETH_CORE_H__ */
Index: my_git/drivers/s390/net/qeth_core_main.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ my_git/drivers/s390/net/qeth_core_main.c	2008-02-14 14:03:13.000000000 +0100
@@ -0,0 +1,4540 @@
+/*
+ *  drivers/s390/net/qeth_core_main.c
+ *
+ *    Copyright IBM Corp. 2007
+ *    Author(s): Utz Bacher <utz.bacher@de.ibm.com>,
+ *		 Frank Pavlic <fpavlic@de.ibm.com>,
+ *		 Thomas Spatzier <tspat@de.ibm.com>,
+ *		 Frank Blaschka <frank.blaschka@de.ibm.com>
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/tcp.h>
+#include <linux/mii.h>
+#include <linux/kthread.h>
+
+#include <asm-s390/ebcdic.h>
+#include <asm-s390/io.h>
+#include <asm/s390_rdev.h>
+
+#include "qeth_core.h"
+#include "qeth_core_offl.h"
+
+#define QETH_DBF_TEXT_(name, level, text...) \
+	do { \
+		if (qeth_dbf_passes(qeth_dbf_##name, level)) { \
+			char *dbf_txt_buf = \
+				get_cpu_var(qeth_core_dbf_txt_buf); \
+			sprintf(dbf_txt_buf, text); \
+			debug_text_event(qeth_dbf_##name, level, dbf_txt_buf); \
+			put_cpu_var(qeth_core_dbf_txt_buf); \
+		} \
+	} while (0)
+
+struct qeth_card_list_struct qeth_core_card_list;
+EXPORT_SYMBOL_GPL(qeth_core_card_list);
+debug_info_t *qeth_dbf_setup;
+EXPORT_SYMBOL_GPL(qeth_dbf_setup);
+debug_info_t *qeth_dbf_data;
+EXPORT_SYMBOL_GPL(qeth_dbf_data);
+debug_info_t *qeth_dbf_misc;
+EXPORT_SYMBOL_GPL(qeth_dbf_misc);
+debug_info_t *qeth_dbf_control;
+EXPORT_SYMBOL_GPL(qeth_dbf_control);
+debug_info_t *qeth_dbf_trace;
+EXPORT_SYMBOL_GPL(qeth_dbf_trace);
+debug_info_t *qeth_dbf_sense;
+EXPORT_SYMBOL_GPL(qeth_dbf_sense);
+debug_info_t *qeth_dbf_qerr;
+EXPORT_SYMBOL_GPL(qeth_dbf_qerr);
+
+static struct device *qeth_core_root_dev;
+static unsigned int known_devices[][10] = QETH_MODELLIST_ARRAY;
+static struct lock_class_key qdio_out_skb_queue_key;
+static DEFINE_PER_CPU(char[256], qeth_core_dbf_txt_buf);
+
+static void qeth_send_control_data_cb(struct qeth_channel *,
+			struct qeth_cmd_buffer *);
+static int qeth_issue_next_read(struct qeth_card *);
+static struct qeth_cmd_buffer *qeth_get_buffer(struct qeth_channel *);
+static void qeth_setup_ccw(struct qeth_channel *, unsigned char *, __u32);
+static void qeth_free_buffer_pool(struct qeth_card *);
+static int qeth_qdio_establish(struct qeth_card *);
+
+
+static inline void __qeth_fill_buffer_frag(struct sk_buff *skb,
+		struct qdio_buffer *buffer, int is_tso,
+		int *next_element_to_fill)
+{
+	struct skb_frag_struct *frag;
+	int fragno;
+	unsigned long addr;
+	int element, cnt, dlen;
+
+	fragno = skb_shinfo(skb)->nr_frags;
+	element = *next_element_to_fill;
+	dlen = 0;
+
+	if (is_tso)
+		buffer->element[element].flags =
+			SBAL_FLAGS_MIDDLE_FRAG;
+	else
+		buffer->element[element].flags =
+			SBAL_FLAGS_FIRST_FRAG;
+	dlen = skb->len - skb->data_len;
+	if (dlen) {
+		buffer->element[element].addr = skb->data;
+		buffer->element[element].length = dlen;
+		element++;
+	}
+	for (cnt = 0; cnt < fragno; cnt++) {
+		frag = &skb_shinfo(skb)->frags[cnt];
+		addr = (page_to_pfn(frag->page) << PAGE_SHIFT) +
+			frag->page_offset;
+		buffer->element[element].addr = (char *)addr;
+		buffer->element[element].length = frag->size;
+		if (cnt < (fragno - 1))
+			buffer->element[element].flags =
+				SBAL_FLAGS_MIDDLE_FRAG;
+		else
+			buffer->element[element].flags =
+				SBAL_FLAGS_LAST_FRAG;
+		element++;
+	}
+	*next_element_to_fill = element;
+}
+
+static inline const char *qeth_get_cardname(struct qeth_card *card)
+{
+	if (card->info.guestlan) {
+		switch (card->info.type) {
+		case QETH_CARD_TYPE_OSAE:
+			return " Guest LAN QDIO";
+		case QETH_CARD_TYPE_IQD:
+			return " Guest LAN Hiper";
+		default:
+			return " unknown";
+		}
+	} else {
+		switch (card->info.type) {
+		case QETH_CARD_TYPE_OSAE:
+			return " OSD Express";
+		case QETH_CARD_TYPE_IQD:
+			return " HiperSockets";
+		case QETH_CARD_TYPE_OSN:
+			return " OSN QDIO";
+		default:
+			return " unknown";
+		}
+	}
+	return " n/a";
+}
+
+/* max length to be returned: 14 */
+const char *qeth_get_cardname_short(struct qeth_card *card)
+{
+	if (card->info.guestlan) {
+		switch (card->info.type) {
+		case QETH_CARD_TYPE_OSAE:
+			return "GuestLAN QDIO";
+		case QETH_CARD_TYPE_IQD:
+			return "GuestLAN Hiper";
+		default:
+			return "unknown";
+		}
+	} else {
+		switch (card->info.type) {
+		case QETH_CARD_TYPE_OSAE:
+			switch (card->info.link_type) {
+			case QETH_LINK_TYPE_FAST_ETH:
+				return "OSD_100";
+			case QETH_LINK_TYPE_HSTR:
+				return "HSTR";
+			case QETH_LINK_TYPE_GBIT_ETH:
+				return "OSD_1000";
+			case QETH_LINK_TYPE_10GBIT_ETH:
+				return "OSD_10GIG";
+			case QETH_LINK_TYPE_LANE_ETH100:
+				return "OSD_FE_LANE";
+			case QETH_LINK_TYPE_LANE_TR:
+				return "OSD_TR_LANE";
+			case QETH_LINK_TYPE_LANE_ETH1000:
+				return "OSD_GbE_LANE";
+			case QETH_LINK_TYPE_LANE:
+				return "OSD_ATM_LANE";
+			default:
+				return "OSD_Express";
+			}
+		case QETH_CARD_TYPE_IQD:
+			return "HiperSockets";
+		case QETH_CARD_TYPE_OSN:
+			return "OSN";
+		default:
+			return "unknown";
+		}
+	}
+	return "n/a";
+}
+
+void qeth_set_allowed_threads(struct qeth_card *card, unsigned long threads,
+			 int clear_start_mask)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&card->thread_mask_lock, flags);
+	card->thread_allowed_mask = threads;
+	if (clear_start_mask)
+		card->thread_start_mask &= threads;
+	spin_unlock_irqrestore(&card->thread_mask_lock, flags);
+	wake_up(&card->wait_q);
+}
+EXPORT_SYMBOL_GPL(qeth_set_allowed_threads);
+
+int qeth_threads_running(struct qeth_card *card, unsigned long threads)
+{
+	unsigned long flags;
+	int rc = 0;
+
+	spin_lock_irqsave(&card->thread_mask_lock, flags);
+	rc = (card->thread_running_mask & threads);
+	spin_unlock_irqrestore(&card->thread_mask_lock, flags);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_threads_running);
+
+int qeth_wait_for_threads(struct qeth_card *card, unsigned long threads)
+{
+	return wait_event_interruptible(card->wait_q,
+			qeth_threads_running(card, threads) == 0);
+}
+EXPORT_SYMBOL_GPL(qeth_wait_for_threads);
+
+void qeth_clear_working_pool_list(struct qeth_card *card)
+{
+	struct qeth_buffer_pool_entry *pool_entry, *tmp;
+
+	QETH_DBF_TEXT(trace, 5, "clwrklst");
+	list_for_each_entry_safe(pool_entry, tmp,
+			    &card->qdio.in_buf_pool.entry_list, list){
+			list_del(&pool_entry->list);
+	}
+}
+EXPORT_SYMBOL_GPL(qeth_clear_working_pool_list);
+
+static int qeth_alloc_buffer_pool(struct qeth_card *card)
+{
+	struct qeth_buffer_pool_entry *pool_entry;
+	void *ptr;
+	int i, j;
+
+	QETH_DBF_TEXT(trace, 5, "alocpool");
+	for (i = 0; i < card->qdio.init_pool.buf_count; ++i) {
+		pool_entry = kmalloc(sizeof(*pool_entry), GFP_KERNEL);
+		if (!pool_entry) {
+			qeth_free_buffer_pool(card);
+			return -ENOMEM;
+		}
+		for (j = 0; j < QETH_MAX_BUFFER_ELEMENTS(card); ++j) {
+			ptr = (void *) __get_free_page(GFP_KERNEL|GFP_DMA);
+			if (!ptr) {
+				while (j > 0)
+					free_page((unsigned long)
+						  pool_entry->elements[--j]);
+				kfree(pool_entry);
+				qeth_free_buffer_pool(card);
+				return -ENOMEM;
+			}
+			pool_entry->elements[j] = ptr;
+		}
+		list_add(&pool_entry->init_list,
+			 &card->qdio.init_pool.entry_list);
+	}
+	return 0;
+}
+
+int qeth_realloc_buffer_pool(struct qeth_card *card, int bufcnt)
+{
+	QETH_DBF_TEXT(trace, 2, "realcbp");
+
+	if ((card->state != CARD_STATE_DOWN) &&
+	    (card->state != CARD_STATE_RECOVER))
+		return -EPERM;
+
+	/* TODO: steel/add buffers from/to a running card's buffer pool (?) */
+	qeth_clear_working_pool_list(card);
+	qeth_free_buffer_pool(card);
+	card->qdio.in_buf_pool.buf_count = bufcnt;
+	card->qdio.init_pool.buf_count = bufcnt;
+	return qeth_alloc_buffer_pool(card);
+}
+
+int qeth_set_large_send(struct qeth_card *card,
+		enum qeth_large_send_types type)
+{
+	int rc = 0;
+
+	if (card->dev == NULL) {
+		card->options.large_send = type;
+		return 0;
+	}
+	if (card->state == CARD_STATE_UP)
+		netif_tx_disable(card->dev);
+	card->options.large_send = type;
+	switch (card->options.large_send) {
+	case QETH_LARGE_SEND_EDDP:
+		card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
+					NETIF_F_HW_CSUM;
+		break;
+	case QETH_LARGE_SEND_TSO:
+		if (qeth_is_supported(card, IPA_OUTBOUND_TSO)) {
+			card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
+						NETIF_F_HW_CSUM;
+		} else {
+			PRINT_WARN("TSO not supported on %s. "
+				   "large_send set to 'no'.\n",
+				   card->dev->name);
+			card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
+						NETIF_F_HW_CSUM);
+			card->options.large_send = QETH_LARGE_SEND_NO;
+			rc = -EOPNOTSUPP;
+		}
+		break;
+	default: /* includes QETH_LARGE_SEND_NO */
+		card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
+					NETIF_F_HW_CSUM);
+		break;
+	}
+	if (card->state == CARD_STATE_UP)
+		netif_wake_queue(card->dev);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_set_large_send);
+
+static int qeth_issue_next_read(struct qeth_card *card)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(trace, 5, "issnxrd");
+	if (card->read.state != CH_STATE_UP)
+		return -EIO;
+	iob = qeth_get_buffer(&card->read);
+	if (!iob) {
+		PRINT_WARN("issue_next_read failed: no iob available!\n");
+		return -ENOMEM;
+	}
+	qeth_setup_ccw(&card->read, iob->data, QETH_BUFSIZE);
+	QETH_DBF_TEXT(trace, 6, "noirqpnd");
+	rc = ccw_device_start(card->read.ccwdev, &card->read.ccw,
+			      (addr_t) iob, 0, 0);
+	if (rc) {
+		PRINT_ERR("Error in starting next read ccw! rc=%i\n", rc);
+		atomic_set(&card->read.irq_pending, 0);
+		qeth_schedule_recovery(card);
+		wake_up(&card->wait_q);
+	}
+	return rc;
+}
+
+static struct qeth_reply *qeth_alloc_reply(struct qeth_card *card)
+{
+	struct qeth_reply *reply;
+
+	reply = kzalloc(sizeof(struct qeth_reply), GFP_ATOMIC);
+	if (reply) {
+		atomic_set(&reply->refcnt, 1);
+		atomic_set(&reply->received, 0);
+		reply->card = card;
+	};
+	return reply;
+}
+
+static void qeth_get_reply(struct qeth_reply *reply)
+{
+	WARN_ON(atomic_read(&reply->refcnt) <= 0);
+	atomic_inc(&reply->refcnt);
+}
+
+static void qeth_put_reply(struct qeth_reply *reply)
+{
+	WARN_ON(atomic_read(&reply->refcnt) <= 0);
+	if (atomic_dec_and_test(&reply->refcnt))
+		kfree(reply);
+}
+
+static void qeth_issue_ipa_msg(struct qeth_ipa_cmd *cmd,
+		struct qeth_card *card)
+{
+	int rc;
+	int com;
+	char *ipa_name;
+
+	com = cmd->hdr.command;
+	rc  = cmd->hdr.return_code;
+	ipa_name = qeth_get_ipa_cmd_name(com);
+
+	PRINT_ERR("%s(x%X) for %s returned x%X \"%s\"\n", ipa_name, com,
+		   QETH_CARD_IFNAME(card), rc, qeth_get_ipa_msg(rc));
+}
+
+static struct qeth_ipa_cmd *qeth_check_ipa_data(struct qeth_card *card,
+		struct qeth_cmd_buffer *iob)
+{
+	struct qeth_ipa_cmd *cmd = NULL;
+
+	QETH_DBF_TEXT(trace, 5, "chkipad");
+	if (IS_IPA(iob->data)) {
+		cmd = (struct qeth_ipa_cmd *) PDU_ENCAPSULATION(iob->data);
+		if (IS_IPA_REPLY(cmd)) {
+			if (cmd->hdr.return_code &&
+			    (cmd->hdr.command < IPA_CMD_SETCCID ||
+			     cmd->hdr.command > IPA_CMD_MODCCID))
+				qeth_issue_ipa_msg(cmd, card);
+			return cmd;
+		} else {
+			switch (cmd->hdr.command) {
+			case IPA_CMD_STOPLAN:
+				PRINT_WARN("Link failure on %s (CHPID 0x%X) - "
+					   "there is a network problem or "
+					   "someone pulled the cable or "
+					   "disabled the port.\n",
+					   QETH_CARD_IFNAME(card),
+					   card->info.chpid);
+				card->lan_online = 0;
+				if (card->dev && netif_carrier_ok(card->dev))
+					netif_carrier_off(card->dev);
+				return NULL;
+			case IPA_CMD_STARTLAN:
+				PRINT_INFO("Link reestablished on %s "
+					   "(CHPID 0x%X). Scheduling "
+					   "IP address reset.\n",
+					   QETH_CARD_IFNAME(card),
+					   card->info.chpid);
+				netif_carrier_on(card->dev);
+				qeth_schedule_recovery(card);
+				return NULL;
+			case IPA_CMD_MODCCID:
+				return cmd;
+			case IPA_CMD_REGISTER_LOCAL_ADDR:
+				QETH_DBF_TEXT(trace, 3, "irla");
+				break;
+			case IPA_CMD_UNREGISTER_LOCAL_ADDR:
+				QETH_DBF_TEXT(trace, 3, "urla");
+				break;
+			default:
+				PRINT_WARN("Received data is IPA "
+					   "but not a reply!\n");
+				break;
+			}
+		}
+	}
+	return cmd;
+}
+
+void qeth_clear_ipacmd_list(struct qeth_card *card)
+{
+	struct qeth_reply *reply, *r;
+	unsigned long flags;
+
+	QETH_DBF_TEXT(trace, 4, "clipalst");
+
+	spin_lock_irqsave(&card->lock, flags);
+	list_for_each_entry_safe(reply, r, &card->cmd_waiter_list, list) {
+		qeth_get_reply(reply);
+		reply->rc = -EIO;
+		atomic_inc(&reply->received);
+		list_del_init(&reply->list);
+		wake_up(&reply->wait_q);
+		qeth_put_reply(reply);
+	}
+	spin_unlock_irqrestore(&card->lock, flags);
+}
+EXPORT_SYMBOL_GPL(qeth_clear_ipacmd_list);
+
+static int qeth_check_idx_response(unsigned char *buffer)
+{
+	if (!buffer)
+		return 0;
+
+	QETH_DBF_HEX(control, 2, buffer, QETH_DBF_CONTROL_LEN);
+	if ((buffer[2] & 0xc0) == 0xc0) {
+		PRINT_WARN("received an IDX TERMINATE "
+			   "with cause code 0x%02x%s\n",
+			   buffer[4],
+			   ((buffer[4] == 0x22) ?
+			    " -- try another portname" : ""));
+		QETH_DBF_TEXT(trace, 2, "ckidxres");
+		QETH_DBF_TEXT(trace, 2, " idxterm");
+		QETH_DBF_TEXT_(trace, 2, "  rc%d", -EIO);
+		return -EIO;
+	}
+	return 0;
+}
+
+static void qeth_setup_ccw(struct qeth_channel *channel, unsigned char *iob,
+		__u32 len)
+{
+	struct qeth_card *card;
+
+	QETH_DBF_TEXT(trace, 4, "setupccw");
+	card = CARD_FROM_CDEV(channel->ccwdev);
+	if (channel == &card->read)
+		memcpy(&channel->ccw, READ_CCW, sizeof(struct ccw1));
+	else
+		memcpy(&channel->ccw, WRITE_CCW, sizeof(struct ccw1));
+	channel->ccw.count = len;
+	channel->ccw.cda = (__u32) __pa(iob);
+}
+
+static struct qeth_cmd_buffer *__qeth_get_buffer(struct qeth_channel *channel)
+{
+	__u8 index;
+
+	QETH_DBF_TEXT(trace, 6, "getbuff");
+	index = channel->io_buf_no;
+	do {
+		if (channel->iob[index].state == BUF_STATE_FREE) {
+			channel->iob[index].state = BUF_STATE_LOCKED;
+			channel->io_buf_no = (channel->io_buf_no + 1) %
+				QETH_CMD_BUFFER_NO;
+			memset(channel->iob[index].data, 0, QETH_BUFSIZE);
+			return channel->iob + index;
+		}
+		index = (index + 1) % QETH_CMD_BUFFER_NO;
+	} while (index != channel->io_buf_no);
+
+	return NULL;
+}
+
+void qeth_release_buffer(struct qeth_channel *channel,
+		struct qeth_cmd_buffer *iob)
+{
+	unsigned long flags;
+
+	QETH_DBF_TEXT(trace, 6, "relbuff");
+	spin_lock_irqsave(&channel->iob_lock, flags);
+	memset(iob->data, 0, QETH_BUFSIZE);
+	iob->state = BUF_STATE_FREE;
+	iob->callback = qeth_send_control_data_cb;
+	iob->rc = 0;
+	spin_unlock_irqrestore(&channel->iob_lock, flags);
+}
+EXPORT_SYMBOL_GPL(qeth_release_buffer);
+
+static struct qeth_cmd_buffer *qeth_get_buffer(struct qeth_channel *channel)
+{
+	struct qeth_cmd_buffer *buffer = NULL;
+	unsigned long flags;
+
+	spin_lock_irqsave(&channel->iob_lock, flags);
+	buffer = __qeth_get_buffer(channel);
+	spin_unlock_irqrestore(&channel->iob_lock, flags);
+	return buffer;
+}
+
+struct qeth_cmd_buffer *qeth_wait_for_buffer(struct qeth_channel *channel)
+{
+	struct qeth_cmd_buffer *buffer;
+	wait_event(channel->wait_q,
+		   ((buffer = qeth_get_buffer(channel)) != NULL));
+	return buffer;
+}
+EXPORT_SYMBOL_GPL(qeth_wait_for_buffer);
+
+void qeth_clear_cmd_buffers(struct qeth_channel *channel)
+{
+	int cnt;
+
+	for (cnt = 0; cnt < QETH_CMD_BUFFER_NO; cnt++)
+		qeth_release_buffer(channel, &channel->iob[cnt]);
+	channel->buf_no = 0;
+	channel->io_buf_no = 0;
+}
+EXPORT_SYMBOL_GPL(qeth_clear_cmd_buffers);
+
+static void qeth_send_control_data_cb(struct qeth_channel *channel,
+		  struct qeth_cmd_buffer *iob)
+{
+	struct qeth_card *card;
+	struct qeth_reply *reply, *r;
+	struct qeth_ipa_cmd *cmd;
+	unsigned long flags;
+	int keep_reply;
+
+	QETH_DBF_TEXT(trace, 4, "sndctlcb");
+
+	card = CARD_FROM_CDEV(channel->ccwdev);
+	if (qeth_check_idx_response(iob->data)) {
+		qeth_clear_ipacmd_list(card);
+		qeth_schedule_recovery(card);
+		goto out;
+	}
+
+	cmd = qeth_check_ipa_data(card, iob);
+	if ((cmd == NULL) && (card->state != CARD_STATE_DOWN))
+		goto out;
+	/*in case of OSN : check if cmd is set */
+	if (card->info.type == QETH_CARD_TYPE_OSN &&
+	    cmd &&
+	    cmd->hdr.command != IPA_CMD_STARTLAN &&
+	    card->osn_info.assist_cb != NULL) {
+		card->osn_info.assist_cb(card->dev, cmd);
+		goto out;
+	}
+
+	spin_lock_irqsave(&card->lock, flags);
+	list_for_each_entry_safe(reply, r, &card->cmd_waiter_list, list) {
+		if ((reply->seqno == QETH_IDX_COMMAND_SEQNO) ||
+		    ((cmd) && (reply->seqno == cmd->hdr.seqno))) {
+			qeth_get_reply(reply);
+			list_del_init(&reply->list);
+			spin_unlock_irqrestore(&card->lock, flags);
+			keep_reply = 0;
+			if (reply->callback != NULL) {
+				if (cmd) {
+					reply->offset = (__u16)((char *)cmd -
+							(char *)iob->data);
+					keep_reply = reply->callback(card,
+							reply,
+							(unsigned long)cmd);
+				} else
+					keep_reply = reply->callback(card,
+							reply,
+							(unsigned long)iob);
+			}
+			if (cmd)
+				reply->rc = (u16) cmd->hdr.return_code;
+			else if (iob->rc)
+				reply->rc = iob->rc;
+			if (keep_reply) {
+				spin_lock_irqsave(&card->lock, flags);
+				list_add_tail(&reply->list,
+					      &card->cmd_waiter_list);
+				spin_unlock_irqrestore(&card->lock, flags);
+			} else {
+				atomic_inc(&reply->received);
+				wake_up(&reply->wait_q);
+			}
+			qeth_put_reply(reply);
+			goto out;
+		}
+	}
+	spin_unlock_irqrestore(&card->lock, flags);
+out:
+	memcpy(&card->seqno.pdu_hdr_ack,
+		QETH_PDU_HEADER_SEQ_NO(iob->data),
+		QETH_SEQ_NO_LENGTH);
+	qeth_release_buffer(channel, iob);
+}
+
+static int qeth_setup_channel(struct qeth_channel *channel)
+{
+	int cnt;
+
+	QETH_DBF_TEXT(setup, 2, "setupch");
+	for (cnt = 0; cnt < QETH_CMD_BUFFER_NO; cnt++) {
+		channel->iob[cnt].data = (char *)
+			kmalloc(QETH_BUFSIZE, GFP_DMA|GFP_KERNEL);
+		if (channel->iob[cnt].data == NULL)
+			break;
+		channel->iob[cnt].state = BUF_STATE_FREE;
+		channel->iob[cnt].channel = channel;
+		channel->iob[cnt].callback = qeth_send_control_data_cb;
+		channel->iob[cnt].rc = 0;
+	}
+	if (cnt < QETH_CMD_BUFFER_NO) {
+		while (cnt-- > 0)
+			kfree(channel->iob[cnt].data);
+		return -ENOMEM;
+	}
+	channel->buf_no = 0;
+	channel->io_buf_no = 0;
+	atomic_set(&channel->irq_pending, 0);
+	spin_lock_init(&channel->iob_lock);
+
+	init_waitqueue_head(&channel->wait_q);
+	return 0;
+}
+
+static int qeth_set_thread_start_bit(struct qeth_card *card,
+		unsigned long thread)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&card->thread_mask_lock, flags);
+	if (!(card->thread_allowed_mask & thread) ||
+	      (card->thread_start_mask & thread)) {
+		spin_unlock_irqrestore(&card->thread_mask_lock, flags);
+		return -EPERM;
+	}
+	card->thread_start_mask |= thread;
+	spin_unlock_irqrestore(&card->thread_mask_lock, flags);
+	return 0;
+}
+
+void qeth_clear_thread_start_bit(struct qeth_card *card, unsigned long thread)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&card->thread_mask_lock, flags);
+	card->thread_start_mask &= ~thread;
+	spin_unlock_irqrestore(&card->thread_mask_lock, flags);
+	wake_up(&card->wait_q);
+}
+EXPORT_SYMBOL_GPL(qeth_clear_thread_start_bit);
+
+void qeth_clear_thread_running_bit(struct qeth_card *card, unsigned long thread)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&card->thread_mask_lock, flags);
+	card->thread_running_mask &= ~thread;
+	spin_unlock_irqrestore(&card->thread_mask_lock, flags);
+	wake_up(&card->wait_q);
+}
+EXPORT_SYMBOL_GPL(qeth_clear_thread_running_bit);
+
+static int __qeth_do_run_thread(struct qeth_card *card, unsigned long thread)
+{
+	unsigned long flags;
+	int rc = 0;
+
+	spin_lock_irqsave(&card->thread_mask_lock, flags);
+	if (card->thread_start_mask & thread) {
+		if ((card->thread_allowed_mask & thread) &&
+		    !(card->thread_running_mask & thread)) {
+			rc = 1;
+			card->thread_start_mask &= ~thread;
+			card->thread_running_mask |= thread;
+		} else
+			rc = -EPERM;
+	}
+	spin_unlock_irqrestore(&card->thread_mask_lock, flags);
+	return rc;
+}
+
+int qeth_do_run_thread(struct qeth_card *card, unsigned long thread)
+{
+	int rc = 0;
+
+	wait_event(card->wait_q,
+		   (rc = __qeth_do_run_thread(card, thread)) >= 0);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_do_run_thread);
+
+void qeth_schedule_recovery(struct qeth_card *card)
+{
+	QETH_DBF_TEXT(trace, 2, "startrec");
+	if (qeth_set_thread_start_bit(card, QETH_RECOVER_THREAD) == 0)
+		schedule_work(&card->kernel_thread_starter);
+}
+EXPORT_SYMBOL_GPL(qeth_schedule_recovery);
+
+static int qeth_get_problem(struct ccw_device *cdev, struct irb *irb)
+{
+	int dstat, cstat;
+	char *sense;
+
+	sense = (char *) irb->ecw;
+	cstat = irb->scsw.cstat;
+	dstat = irb->scsw.dstat;
+
+	if (cstat & (SCHN_STAT_CHN_CTRL_CHK | SCHN_STAT_INTF_CTRL_CHK |
+		     SCHN_STAT_CHN_DATA_CHK | SCHN_STAT_CHAIN_CHECK |
+		     SCHN_STAT_PROT_CHECK | SCHN_STAT_PROG_CHECK)) {
+		QETH_DBF_TEXT(trace, 2, "CGENCHK");
+		PRINT_WARN("check on device %s, dstat=x%x, cstat=x%x ",
+			   cdev->dev.bus_id, dstat, cstat);
+		print_hex_dump(KERN_WARNING, "qeth: irb ", DUMP_PREFIX_OFFSET,
+				16, 1, irb, 64, 1);
+		return 1;
+	}
+
+	if (dstat & DEV_STAT_UNIT_CHECK) {
+		if (sense[SENSE_RESETTING_EVENT_BYTE] &
+		    SENSE_RESETTING_EVENT_FLAG) {
+			QETH_DBF_TEXT(trace, 2, "REVIND");
+			return 1;
+		}
+		if (sense[SENSE_COMMAND_REJECT_BYTE] &
+		    SENSE_COMMAND_REJECT_FLAG) {
+			QETH_DBF_TEXT(trace, 2, "CMDREJi");
+			return 0;
+		}
+		if ((sense[2] == 0xaf) && (sense[3] == 0xfe)) {
+			QETH_DBF_TEXT(trace, 2, "AFFE");
+			return 1;
+		}
+		if ((!sense[0]) && (!sense[1]) && (!sense[2]) && (!sense[3])) {
+			QETH_DBF_TEXT(trace, 2, "ZEROSEN");
+			return 0;
+		}
+		QETH_DBF_TEXT(trace, 2, "DGENCHK");
+			return 1;
+	}
+	return 0;
+}
+
+static long __qeth_check_irb_error(struct ccw_device *cdev,
+		unsigned long intparm, struct irb *irb)
+{
+	if (!IS_ERR(irb))
+		return 0;
+
+	switch (PTR_ERR(irb)) {
+	case -EIO:
+		PRINT_WARN("i/o-error on device %s\n", cdev->dev.bus_id);
+		QETH_DBF_TEXT(trace, 2, "ckirberr");
+		QETH_DBF_TEXT_(trace, 2, "  rc%d", -EIO);
+		break;
+	case -ETIMEDOUT:
+		PRINT_WARN("timeout on device %s\n", cdev->dev.bus_id);
+		QETH_DBF_TEXT(trace, 2, "ckirberr");
+		QETH_DBF_TEXT_(trace, 2, "  rc%d", -ETIMEDOUT);
+		if (intparm == QETH_RCD_PARM) {
+			struct qeth_card *card = CARD_FROM_CDEV(cdev);
+
+			if (card && (card->data.ccwdev == cdev)) {
+				card->data.state = CH_STATE_DOWN;
+				wake_up(&card->wait_q);
+			}
+		}
+		break;
+	default:
+		PRINT_WARN("unknown error %ld on device %s\n", PTR_ERR(irb),
+			   cdev->dev.bus_id);
+		QETH_DBF_TEXT(trace, 2, "ckirberr");
+		QETH_DBF_TEXT(trace, 2, "  rc???");
+	}
+	return PTR_ERR(irb);
+}
+
+static void qeth_irq(struct ccw_device *cdev, unsigned long intparm,
+		struct irb *irb)
+{
+	int rc;
+	int cstat, dstat;
+	struct qeth_cmd_buffer *buffer;
+	struct qeth_channel *channel;
+	struct qeth_card *card;
+	struct qeth_cmd_buffer *iob;
+	__u8 index;
+
+	QETH_DBF_TEXT(trace, 5, "irq");
+
+	if (__qeth_check_irb_error(cdev, intparm, irb))
+		return;
+	cstat = irb->scsw.cstat;
+	dstat = irb->scsw.dstat;
+
+	card = CARD_FROM_CDEV(cdev);
+	if (!card)
+		return;
+
+	if (card->read.ccwdev == cdev) {
+		channel = &card->read;
+		QETH_DBF_TEXT(trace, 5, "read");
+	} else if (card->write.ccwdev == cdev) {
+		channel = &card->write;
+		QETH_DBF_TEXT(trace, 5, "write");
+	} else {
+		channel = &card->data;
+		QETH_DBF_TEXT(trace, 5, "data");
+	}
+	atomic_set(&channel->irq_pending, 0);
+
+	if (irb->scsw.fctl & (SCSW_FCTL_CLEAR_FUNC))
+		channel->state = CH_STATE_STOPPED;
+
+	if (irb->scsw.fctl & (SCSW_FCTL_HALT_FUNC))
+		channel->state = CH_STATE_HALTED;
+
+	/*let's wake up immediately on data channel*/
+	if ((channel == &card->data) && (intparm != 0) &&
+	    (intparm != QETH_RCD_PARM))
+		goto out;
+
+	if (intparm == QETH_CLEAR_CHANNEL_PARM) {
+		QETH_DBF_TEXT(trace, 6, "clrchpar");
+		/* we don't have to handle this further */
+		intparm = 0;
+	}
+	if (intparm == QETH_HALT_CHANNEL_PARM) {
+		QETH_DBF_TEXT(trace, 6, "hltchpar");
+		/* we don't have to handle this further */
+		intparm = 0;
+	}
+	if ((dstat & DEV_STAT_UNIT_EXCEP) ||
+	    (dstat & DEV_STAT_UNIT_CHECK) ||
+	    (cstat)) {
+		if (irb->esw.esw0.erw.cons) {
+			/* TODO: we should make this s390dbf */
+			PRINT_WARN("sense data available on channel %s.\n",
+				   CHANNEL_ID(channel));
+			PRINT_WARN(" cstat 0x%X\n dstat 0x%X\n", cstat, dstat);
+			print_hex_dump(KERN_WARNING, "qeth: irb ",
+				DUMP_PREFIX_OFFSET, 16, 1, irb, 32, 1);
+			print_hex_dump(KERN_WARNING, "qeth: sense data ",
+				DUMP_PREFIX_OFFSET, 16, 1, irb->ecw, 32, 1);
+		}
+		if (intparm == QETH_RCD_PARM) {
+			channel->state = CH_STATE_DOWN;
+			goto out;
+		}
+		rc = qeth_get_problem(cdev, irb);
+		if (rc) {
+			qeth_schedule_recovery(card);
+			goto out;
+		}
+	}
+
+	if (intparm == QETH_RCD_PARM) {
+		channel->state = CH_STATE_RCD_DONE;
+		goto out;
+	}
+	if (intparm) {
+		buffer = (struct qeth_cmd_buffer *) __va((addr_t)intparm);
+		buffer->state = BUF_STATE_PROCESSED;
+	}
+	if (channel == &card->data)
+		return;
+	if (channel == &card->read &&
+	    channel->state == CH_STATE_UP)
+		qeth_issue_next_read(card);
+
+	iob = channel->iob;
+	index = channel->buf_no;
+	while (iob[index].state == BUF_STATE_PROCESSED) {
+		if (iob[index].callback != NULL)
+			iob[index].callback(channel, iob + index);
+
+		index = (index + 1) % QETH_CMD_BUFFER_NO;
+	}
+	channel->buf_no = index;
+out:
+	wake_up(&card->wait_q);
+	return;
+}
+
+static void qeth_clear_output_buffer(struct qeth_qdio_out_q *queue,
+		 struct qeth_qdio_out_buffer *buf)
+{
+	int i;
+	struct sk_buff *skb;
+
+	/* is PCI flag set on buffer? */
+	if (buf->buffer->element[0].flags & 0x40)
+		atomic_dec(&queue->set_pci_flags_count);
+
+	skb = skb_dequeue(&buf->skb_list);
+	while (skb) {
+		atomic_dec(&skb->users);
+		dev_kfree_skb_any(skb);
+		skb = skb_dequeue(&buf->skb_list);
+	}
+	qeth_eddp_buf_release_contexts(buf);
+	for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(queue->card); ++i) {
+		buf->buffer->element[i].length = 0;
+		buf->buffer->element[i].addr = NULL;
+		buf->buffer->element[i].flags = 0;
+	}
+	buf->next_element_to_fill = 0;
+	atomic_set(&buf->state, QETH_QDIO_BUF_EMPTY);
+}
+
+void qeth_clear_qdio_buffers(struct qeth_card *card)
+{
+	int i, j;
+
+	QETH_DBF_TEXT(trace, 2, "clearqdbf");
+	/* clear outbound buffers to free skbs */
+	for (i = 0; i < card->qdio.no_out_queues; ++i)
+		if (card->qdio.out_qs[i]) {
+			for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j)
+				qeth_clear_output_buffer(card->qdio.out_qs[i],
+						&card->qdio.out_qs[i]->bufs[j]);
+		}
+}
+EXPORT_SYMBOL_GPL(qeth_clear_qdio_buffers);
+
+static void qeth_free_buffer_pool(struct qeth_card *card)
+{
+	struct qeth_buffer_pool_entry *pool_entry, *tmp;
+	int i = 0;
+	QETH_DBF_TEXT(trace, 5, "freepool");
+	list_for_each_entry_safe(pool_entry, tmp,
+				 &card->qdio.init_pool.entry_list, init_list){
+		for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(card); ++i)
+			free_page((unsigned long)pool_entry->elements[i]);
+		list_del(&pool_entry->init_list);
+		kfree(pool_entry);
+	}
+}
+
+static void qeth_free_qdio_buffers(struct qeth_card *card)
+{
+	int i, j;
+
+	QETH_DBF_TEXT(trace, 2, "freeqdbf");
+	if (atomic_xchg(&card->qdio.state, QETH_QDIO_UNINITIALIZED) ==
+		QETH_QDIO_UNINITIALIZED)
+		return;
+	kfree(card->qdio.in_q);
+	card->qdio.in_q = NULL;
+	/* inbound buffer pool */
+	qeth_free_buffer_pool(card);
+	/* free outbound qdio_qs */
+	if (card->qdio.out_qs) {
+		for (i = 0; i < card->qdio.no_out_queues; ++i) {
+			for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j)
+				qeth_clear_output_buffer(card->qdio.out_qs[i],
+						&card->qdio.out_qs[i]->bufs[j]);
+			kfree(card->qdio.out_qs[i]);
+		}
+		kfree(card->qdio.out_qs);
+		card->qdio.out_qs = NULL;
+	}
+}
+
+static void qeth_clean_channel(struct qeth_channel *channel)
+{
+	int cnt;
+
+	QETH_DBF_TEXT(setup, 2, "freech");
+	for (cnt = 0; cnt < QETH_CMD_BUFFER_NO; cnt++)
+		kfree(channel->iob[cnt].data);
+}
+
+static int qeth_is_1920_device(struct qeth_card *card)
+{
+	int single_queue = 0;
+	struct ccw_device *ccwdev;
+	struct channelPath_dsc {
+		u8 flags;
+		u8 lsn;
+		u8 desc;
+		u8 chpid;
+		u8 swla;
+		u8 zeroes;
+		u8 chla;
+		u8 chpp;
+	} *chp_dsc;
+
+	QETH_DBF_TEXT(setup, 2, "chk_1920");
+
+	ccwdev = card->data.ccwdev;
+	chp_dsc = (struct channelPath_dsc *)ccw_device_get_chp_desc(ccwdev, 0);
+	if (chp_dsc != NULL) {
+		/* CHPP field bit 6 == 1 -> single queue */
+		single_queue = ((chp_dsc->chpp & 0x02) == 0x02);
+		kfree(chp_dsc);
+	}
+	QETH_DBF_TEXT_(setup, 2, "rc:%x", single_queue);
+	return single_queue;
+}
+
+static void qeth_init_qdio_info(struct qeth_card *card)
+{
+	QETH_DBF_TEXT(setup, 4, "intqdinf");
+	atomic_set(&card->qdio.state, QETH_QDIO_UNINITIALIZED);
+	/* inbound */
+	card->qdio.in_buf_size = QETH_IN_BUF_SIZE_DEFAULT;
+	card->qdio.init_pool.buf_count = QETH_IN_BUF_COUNT_DEFAULT;
+	card->qdio.in_buf_pool.buf_count = card->qdio.init_pool.buf_count;
+	INIT_LIST_HEAD(&card->qdio.in_buf_pool.entry_list);
+	INIT_LIST_HEAD(&card->qdio.init_pool.entry_list);
+}
+
+static void qeth_set_intial_options(struct qeth_card *card)
+{
+	card->options.route4.type = NO_ROUTER;
+	card->options.route6.type = NO_ROUTER;
+	card->options.checksum_type = QETH_CHECKSUM_DEFAULT;
+	card->options.broadcast_mode = QETH_TR_BROADCAST_ALLRINGS;
+	card->options.macaddr_mode = QETH_TR_MACADDR_NONCANONICAL;
+	card->options.fake_broadcast = 0;
+	card->options.add_hhlen = DEFAULT_ADD_HHLEN;
+	card->options.fake_ll = 0;
+	card->options.performance_stats = 0;
+	card->options.rx_sg_cb = QETH_RX_SG_CB;
+}
+
+static int qeth_do_start_thread(struct qeth_card *card, unsigned long thread)
+{
+	unsigned long flags;
+	int rc = 0;
+
+	spin_lock_irqsave(&card->thread_mask_lock, flags);
+	QETH_DBF_TEXT_(trace, 4, "  %02x%02x%02x",
+			(u8) card->thread_start_mask,
+			(u8) card->thread_allowed_mask,
+			(u8) card->thread_running_mask);
+	rc = (card->thread_start_mask & thread);
+	spin_unlock_irqrestore(&card->thread_mask_lock, flags);
+	return rc;
+}
+
+static void qeth_start_kernel_thread(struct work_struct *work)
+{
+	struct qeth_card *card = container_of(work, struct qeth_card,
+					kernel_thread_starter);
+	QETH_DBF_TEXT(trace , 2, "strthrd");
+
+	if (card->read.state != CH_STATE_UP &&
+	    card->write.state != CH_STATE_UP)
+		return;
+	if (qeth_do_start_thread(card, QETH_RECOVER_THREAD))
+		kthread_run(card->discipline.recover, (void *) card,
+				"qeth_recover");
+}
+
+static int qeth_setup_card(struct qeth_card *card)
+{
+
+	QETH_DBF_TEXT(setup, 2, "setupcrd");
+	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+
+	card->read.state  = CH_STATE_DOWN;
+	card->write.state = CH_STATE_DOWN;
+	card->data.state  = CH_STATE_DOWN;
+	card->state = CARD_STATE_DOWN;
+	card->lan_online = 0;
+	card->use_hard_stop = 0;
+	card->dev = NULL;
+	spin_lock_init(&card->vlanlock);
+	spin_lock_init(&card->mclock);
+	card->vlangrp = NULL;
+	spin_lock_init(&card->lock);
+	spin_lock_init(&card->ip_lock);
+	spin_lock_init(&card->thread_mask_lock);
+	card->thread_start_mask = 0;
+	card->thread_allowed_mask = 0;
+	card->thread_running_mask = 0;
+	INIT_WORK(&card->kernel_thread_starter, qeth_start_kernel_thread);
+	INIT_LIST_HEAD(&card->ip_list);
+	card->ip_tbd_list = kmalloc(sizeof(struct list_head), GFP_KERNEL);
+	if (!card->ip_tbd_list) {
+		QETH_DBF_TEXT(setup, 0, "iptbdnom");
+		return -ENOMEM;
+	}
+	INIT_LIST_HEAD(card->ip_tbd_list);
+	INIT_LIST_HEAD(&card->cmd_waiter_list);
+	init_waitqueue_head(&card->wait_q);
+	/* intial options */
+	qeth_set_intial_options(card);
+	/* IP address takeover */
+	INIT_LIST_HEAD(&card->ipato.entries);
+	card->ipato.enabled = 0;
+	card->ipato.invert4 = 0;
+	card->ipato.invert6 = 0;
+	/* init QDIO stuff */
+	qeth_init_qdio_info(card);
+	return 0;
+}
+
+static struct qeth_card *qeth_alloc_card(void)
+{
+	struct qeth_card *card;
+
+	QETH_DBF_TEXT(setup, 2, "alloccrd");
+	card = kzalloc(sizeof(struct qeth_card), GFP_DMA|GFP_KERNEL);
+	if (!card)
+		return NULL;
+	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+	if (qeth_setup_channel(&card->read)) {
+		kfree(card);
+		return NULL;
+	}
+	if (qeth_setup_channel(&card->write)) {
+		qeth_clean_channel(&card->read);
+		kfree(card);
+		return NULL;
+	}
+	card->options.layer2 = -1;
+	return card;
+}
+
+static int qeth_determine_card_type(struct qeth_card *card)
+{
+	int i = 0;
+
+	QETH_DBF_TEXT(setup, 2, "detcdtyp");
+
+	card->qdio.do_prio_queueing = QETH_PRIOQ_DEFAULT;
+	card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
+	while (known_devices[i][4]) {
+		if ((CARD_RDEV(card)->id.dev_type == known_devices[i][2]) &&
+		    (CARD_RDEV(card)->id.dev_model == known_devices[i][3])) {
+			card->info.type = known_devices[i][4];
+			card->qdio.no_out_queues = known_devices[i][8];
+			card->info.is_multicast_different = known_devices[i][9];
+			if (qeth_is_1920_device(card)) {
+				PRINT_INFO("Priority Queueing not able "
+					   "due to hardware limitations!\n");
+				card->qdio.no_out_queues = 1;
+				card->qdio.default_out_queue = 0;
+			}
+			return 0;
+		}
+		i++;
+	}
+	card->info.type = QETH_CARD_TYPE_UNKNOWN;
+	PRINT_ERR("unknown card type on device %s\n", CARD_BUS_ID(card));
+	return -ENOENT;
+}
+
+static int qeth_clear_channel(struct qeth_channel *channel)
+{
+	unsigned long flags;
+	struct qeth_card *card;
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "clearch");
+	card = CARD_FROM_CDEV(channel->ccwdev);
+	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
+	rc = ccw_device_clear(channel->ccwdev, QETH_CLEAR_CHANNEL_PARM);
+	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
+
+	if (rc)
+		return rc;
+	rc = wait_event_interruptible_timeout(card->wait_q,
+			channel->state == CH_STATE_STOPPED, QETH_TIMEOUT);
+	if (rc == -ERESTARTSYS)
+		return rc;
+	if (channel->state != CH_STATE_STOPPED)
+		return -ETIME;
+	channel->state = CH_STATE_DOWN;
+	return 0;
+}
+
+static int qeth_halt_channel(struct qeth_channel *channel)
+{
+	unsigned long flags;
+	struct qeth_card *card;
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "haltch");
+	card = CARD_FROM_CDEV(channel->ccwdev);
+	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
+	rc = ccw_device_halt(channel->ccwdev, QETH_HALT_CHANNEL_PARM);
+	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
+
+	if (rc)
+		return rc;
+	rc = wait_event_interruptible_timeout(card->wait_q,
+			channel->state == CH_STATE_HALTED, QETH_TIMEOUT);
+	if (rc == -ERESTARTSYS)
+		return rc;
+	if (channel->state != CH_STATE_HALTED)
+		return -ETIME;
+	return 0;
+}
+
+static int qeth_halt_channels(struct qeth_card *card)
+{
+	int rc1 = 0, rc2 = 0, rc3 = 0;
+
+	QETH_DBF_TEXT(trace, 3, "haltchs");
+	rc1 = qeth_halt_channel(&card->read);
+	rc2 = qeth_halt_channel(&card->write);
+	rc3 = qeth_halt_channel(&card->data);
+	if (rc1)
+		return rc1;
+	if (rc2)
+		return rc2;
+	return rc3;
+}
+
+static int qeth_clear_channels(struct qeth_card *card)
+{
+	int rc1 = 0, rc2 = 0, rc3 = 0;
+
+	QETH_DBF_TEXT(trace, 3, "clearchs");
+	rc1 = qeth_clear_channel(&card->read);
+	rc2 = qeth_clear_channel(&card->write);
+	rc3 = qeth_clear_channel(&card->data);
+	if (rc1)
+		return rc1;
+	if (rc2)
+		return rc2;
+	return rc3;
+}
+
+static int qeth_clear_halt_card(struct qeth_card *card, int halt)
+{
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 3, "clhacrd");
+	QETH_DBF_HEX(trace, 3, &card, sizeof(void *));
+
+	if (halt)
+		rc = qeth_halt_channels(card);
+	if (rc)
+		return rc;
+	return qeth_clear_channels(card);
+}
+
+int qeth_qdio_clear_card(struct qeth_card *card, int use_halt)
+{
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 3, "qdioclr");
+	switch (atomic_cmpxchg(&card->qdio.state, QETH_QDIO_ESTABLISHED,
+		QETH_QDIO_CLEANING)) {
+	case QETH_QDIO_ESTABLISHED:
+		if (card->info.type == QETH_CARD_TYPE_IQD)
+			rc = qdio_cleanup(CARD_DDEV(card),
+				QDIO_FLAG_CLEANUP_USING_HALT);
+		else
+			rc = qdio_cleanup(CARD_DDEV(card),
+				QDIO_FLAG_CLEANUP_USING_CLEAR);
+		if (rc)
+			QETH_DBF_TEXT_(trace, 3, "1err%d", rc);
+		atomic_set(&card->qdio.state, QETH_QDIO_ALLOCATED);
+		break;
+	case QETH_QDIO_CLEANING:
+		return rc;
+	default:
+		break;
+	}
+	rc = qeth_clear_halt_card(card, use_halt);
+	if (rc)
+		QETH_DBF_TEXT_(trace, 3, "2err%d", rc);
+	card->state = CARD_STATE_DOWN;
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_qdio_clear_card);
+
+static int qeth_read_conf_data(struct qeth_card *card, void **buffer,
+			       int *length)
+{
+	struct ciw *ciw;
+	char *rcd_buf;
+	int ret;
+	struct qeth_channel *channel = &card->data;
+	unsigned long flags;
+
+	/*
+	 * scan for RCD command in extended SenseID data
+	 */
+	ciw = ccw_device_get_ciw(channel->ccwdev, CIW_TYPE_RCD);
+	if (!ciw || ciw->cmd == 0)
+		return -EOPNOTSUPP;
+	rcd_buf = kzalloc(ciw->count, GFP_KERNEL | GFP_DMA);
+	if (!rcd_buf)
+		return -ENOMEM;
+
+	channel->ccw.cmd_code = ciw->cmd;
+	channel->ccw.cda = (__u32) __pa(rcd_buf);
+	channel->ccw.count = ciw->count;
+	channel->ccw.flags = CCW_FLAG_SLI;
+	channel->state = CH_STATE_RCD;
+	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
+	ret = ccw_device_start_timeout(channel->ccwdev, &channel->ccw,
+				       QETH_RCD_PARM, LPM_ANYPATH, 0,
+				       QETH_RCD_TIMEOUT);
+	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
+	if (!ret)
+		wait_event(card->wait_q,
+			   (channel->state == CH_STATE_RCD_DONE ||
+			    channel->state == CH_STATE_DOWN));
+	if (channel->state == CH_STATE_DOWN)
+		ret = -EIO;
+	else
+		channel->state = CH_STATE_DOWN;
+	if (ret) {
+		kfree(rcd_buf);
+		*buffer = NULL;
+		*length = 0;
+	} else {
+		*length = ciw->count;
+		*buffer = rcd_buf;
+	}
+	return ret;
+}
+
+static int qeth_get_unitaddr(struct qeth_card *card)
+{
+	int length;
+	char *prcd;
+	int rc;
+
+	QETH_DBF_TEXT(setup, 2, "getunit");
+	rc = qeth_read_conf_data(card, (void **) &prcd, &length);
+	if (rc) {
+		PRINT_ERR("qeth_read_conf_data for device %s returned %i\n",
+			CARD_DDEV_ID(card), rc);
+		return rc;
+	}
+	card->info.chpid = prcd[30];
+	card->info.unit_addr2 = prcd[31];
+	card->info.cula = prcd[63];
+	card->info.guestlan = ((prcd[0x10] == _ascebc['V']) &&
+			       (prcd[0x11] == _ascebc['M']));
+	kfree(prcd);
+	return 0;
+}
+
+static void qeth_init_tokens(struct qeth_card *card)
+{
+	card->token.issuer_rm_w = 0x00010103UL;
+	card->token.cm_filter_w = 0x00010108UL;
+	card->token.cm_connection_w = 0x0001010aUL;
+	card->token.ulp_filter_w = 0x0001010bUL;
+	card->token.ulp_connection_w = 0x0001010dUL;
+}
+
+static void qeth_init_func_level(struct qeth_card *card)
+{
+	if (card->ipato.enabled) {
+		if (card->info.type == QETH_CARD_TYPE_IQD)
+				card->info.func_level =
+					QETH_IDX_FUNC_LEVEL_IQD_ENA_IPAT;
+		else
+				card->info.func_level =
+					QETH_IDX_FUNC_LEVEL_OSAE_ENA_IPAT;
+	} else {
+		if (card->info.type == QETH_CARD_TYPE_IQD)
+		/*FIXME:why do we have same values for  dis and ena for
+		  osae??? */
+			card->info.func_level =
+				QETH_IDX_FUNC_LEVEL_IQD_DIS_IPAT;
+		else
+			card->info.func_level =
+				QETH_IDX_FUNC_LEVEL_OSAE_DIS_IPAT;
+	}
+}
+
+static inline __u16 qeth_raw_devno_from_bus_id(char *id)
+{
+	id += (strlen(id) - 4);
+	return (__u16) simple_strtoul(id, &id, 16);
+}
+
+static int qeth_idx_activate_get_answer(struct qeth_channel *channel,
+		void (*idx_reply_cb)(struct qeth_channel *,
+			struct qeth_cmd_buffer *))
+{
+	struct qeth_cmd_buffer *iob;
+	unsigned long flags;
+	int rc;
+	struct qeth_card *card;
+
+	QETH_DBF_TEXT(setup, 2, "idxanswr");
+	card = CARD_FROM_CDEV(channel->ccwdev);
+	iob = qeth_get_buffer(channel);
+	iob->callback = idx_reply_cb;
+	memcpy(&channel->ccw, READ_CCW, sizeof(struct ccw1));
+	channel->ccw.count = QETH_BUFSIZE;
+	channel->ccw.cda = (__u32) __pa(iob->data);
+
+	wait_event(card->wait_q,
+		   atomic_cmpxchg(&channel->irq_pending, 0, 1) == 0);
+	QETH_DBF_TEXT(setup, 6, "noirqpnd");
+	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
+	rc = ccw_device_start(channel->ccwdev,
+			      &channel->ccw, (addr_t) iob, 0, 0);
+	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
+
+	if (rc) {
+		PRINT_ERR("Error2 in activating channel rc=%d\n", rc);
+		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		atomic_set(&channel->irq_pending, 0);
+		wake_up(&card->wait_q);
+		return rc;
+	}
+	rc = wait_event_interruptible_timeout(card->wait_q,
+			 channel->state == CH_STATE_UP, QETH_TIMEOUT);
+	if (rc == -ERESTARTSYS)
+		return rc;
+	if (channel->state != CH_STATE_UP) {
+		rc = -ETIME;
+		QETH_DBF_TEXT_(setup, 2, "3err%d", rc);
+		qeth_clear_cmd_buffers(channel);
+	} else
+		rc = 0;
+	return rc;
+}
+
+static int qeth_idx_activate_channel(struct qeth_channel *channel,
+		void (*idx_reply_cb)(struct qeth_channel *,
+			struct qeth_cmd_buffer *))
+{
+	struct qeth_card *card;
+	struct qeth_cmd_buffer *iob;
+	unsigned long flags;
+	__u16 temp;
+	__u8 tmp;
+	int rc;
+
+	card = CARD_FROM_CDEV(channel->ccwdev);
+
+	QETH_DBF_TEXT(setup, 2, "idxactch");
+
+	iob = qeth_get_buffer(channel);
+	iob->callback = idx_reply_cb;
+	memcpy(&channel->ccw, WRITE_CCW, sizeof(struct ccw1));
+	channel->ccw.count = IDX_ACTIVATE_SIZE;
+	channel->ccw.cda = (__u32) __pa(iob->data);
+	if (channel == &card->write) {
+		memcpy(iob->data, IDX_ACTIVATE_WRITE, IDX_ACTIVATE_SIZE);
+		memcpy(QETH_TRANSPORT_HEADER_SEQ_NO(iob->data),
+		       &card->seqno.trans_hdr, QETH_SEQ_NO_LENGTH);
+		card->seqno.trans_hdr++;
+	} else {
+		memcpy(iob->data, IDX_ACTIVATE_READ, IDX_ACTIVATE_SIZE);
+		memcpy(QETH_TRANSPORT_HEADER_SEQ_NO(iob->data),
+		       &card->seqno.trans_hdr, QETH_SEQ_NO_LENGTH);
+	}
+	tmp = ((__u8)card->info.portno) | 0x80;
+	memcpy(QETH_IDX_ACT_PNO(iob->data), &tmp, 1);
+	memcpy(QETH_IDX_ACT_ISSUER_RM_TOKEN(iob->data),
+	       &card->token.issuer_rm_w, QETH_MPC_TOKEN_LENGTH);
+	memcpy(QETH_IDX_ACT_FUNC_LEVEL(iob->data),
+	       &card->info.func_level, sizeof(__u16));
+	temp = qeth_raw_devno_from_bus_id(CARD_DDEV_ID(card));
+	memcpy(QETH_IDX_ACT_QDIO_DEV_CUA(iob->data), &temp, 2);
+	temp = (card->info.cula << 8) + card->info.unit_addr2;
+	memcpy(QETH_IDX_ACT_QDIO_DEV_REALADDR(iob->data), &temp, 2);
+
+	wait_event(card->wait_q,
+		   atomic_cmpxchg(&channel->irq_pending, 0, 1) == 0);
+	QETH_DBF_TEXT(setup, 6, "noirqpnd");
+	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
+	rc = ccw_device_start(channel->ccwdev,
+			      &channel->ccw, (addr_t) iob, 0, 0);
+	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
+
+	if (rc) {
+		PRINT_ERR("Error1 in activating channel. rc=%d\n", rc);
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		atomic_set(&channel->irq_pending, 0);
+		wake_up(&card->wait_q);
+		return rc;
+	}
+	rc = wait_event_interruptible_timeout(card->wait_q,
+			channel->state == CH_STATE_ACTIVATING, QETH_TIMEOUT);
+	if (rc == -ERESTARTSYS)
+		return rc;
+	if (channel->state != CH_STATE_ACTIVATING) {
+		PRINT_WARN("IDX activate timed out!\n");
+		QETH_DBF_TEXT_(setup, 2, "2err%d", -ETIME);
+		qeth_clear_cmd_buffers(channel);
+		return -ETIME;
+	}
+	return qeth_idx_activate_get_answer(channel, idx_reply_cb);
+}
+
+static int qeth_peer_func_level(int level)
+{
+	if ((level & 0xff) == 8)
+		return (level & 0xff) + 0x400;
+	if (((level >> 8) & 3) == 1)
+		return (level & 0xff) + 0x200;
+	return level;
+}
+
+static void qeth_idx_write_cb(struct qeth_channel *channel,
+		struct qeth_cmd_buffer *iob)
+{
+	struct qeth_card *card;
+	__u16 temp;
+
+	QETH_DBF_TEXT(setup , 2, "idxwrcb");
+
+	if (channel->state == CH_STATE_DOWN) {
+		channel->state = CH_STATE_ACTIVATING;
+		goto out;
+	}
+	card = CARD_FROM_CDEV(channel->ccwdev);
+
+	if (!(QETH_IS_IDX_ACT_POS_REPLY(iob->data))) {
+		if (QETH_IDX_ACT_CAUSE_CODE(iob->data) == 0x19)
+			PRINT_ERR("IDX_ACTIVATE on write channel device %s: "
+				"adapter exclusively used by another host\n",
+			CARD_WDEV_ID(card));
+		else
+			PRINT_ERR("IDX_ACTIVATE on write channel device %s: "
+				"negative reply\n", CARD_WDEV_ID(card));
+		goto out;
+	}
+	memcpy(&temp, QETH_IDX_ACT_FUNC_LEVEL(iob->data), 2);
+	if ((temp & ~0x0100) != qeth_peer_func_level(card->info.func_level)) {
+		PRINT_WARN("IDX_ACTIVATE on write channel device %s: "
+			   "function level mismatch "
+			   "(sent: 0x%x, received: 0x%x)\n",
+			   CARD_WDEV_ID(card), card->info.func_level, temp);
+		goto out;
+	}
+	channel->state = CH_STATE_UP;
+out:
+	qeth_release_buffer(channel, iob);
+}
+
+static void qeth_idx_read_cb(struct qeth_channel *channel,
+		struct qeth_cmd_buffer *iob)
+{
+	struct qeth_card *card;
+	__u16 temp;
+
+	QETH_DBF_TEXT(setup , 2, "idxrdcb");
+	if (channel->state == CH_STATE_DOWN) {
+		channel->state = CH_STATE_ACTIVATING;
+		goto out;
+	}
+
+	card = CARD_FROM_CDEV(channel->ccwdev);
+	if (qeth_check_idx_response(iob->data))
+			goto out;
+
+	if (!(QETH_IS_IDX_ACT_POS_REPLY(iob->data))) {
+		if (QETH_IDX_ACT_CAUSE_CODE(iob->data) == 0x19)
+			PRINT_ERR("IDX_ACTIVATE on read channel device %s: "
+				"adapter exclusively used by another host\n",
+				CARD_RDEV_ID(card));
+		else
+			PRINT_ERR("IDX_ACTIVATE on read channel device %s: "
+				"negative reply\n", CARD_RDEV_ID(card));
+		goto out;
+	}
+
+/**
+ * temporary fix for microcode bug
+ * to revert it,replace OR by AND
+ */
+	if ((!QETH_IDX_NO_PORTNAME_REQUIRED(iob->data)) ||
+	     (card->info.type == QETH_CARD_TYPE_OSAE))
+		card->info.portname_required = 1;
+
+	memcpy(&temp, QETH_IDX_ACT_FUNC_LEVEL(iob->data), 2);
+	if (temp != qeth_peer_func_level(card->info.func_level)) {
+		PRINT_WARN("IDX_ACTIVATE on read channel device %s: function "
+			   "level mismatch (sent: 0x%x, received: 0x%x)\n",
+			   CARD_RDEV_ID(card), card->info.func_level, temp);
+		goto out;
+	}
+	memcpy(&card->token.issuer_rm_r,
+	       QETH_IDX_ACT_ISSUER_RM_TOKEN(iob->data),
+	       QETH_MPC_TOKEN_LENGTH);
+	memcpy(&card->info.mcl_level[0],
+	       QETH_IDX_REPLY_LEVEL(iob->data), QETH_MCL_LENGTH);
+	channel->state = CH_STATE_UP;
+out:
+	qeth_release_buffer(channel, iob);
+}
+
+void qeth_prepare_control_data(struct qeth_card *card, int len,
+		struct qeth_cmd_buffer *iob)
+{
+	qeth_setup_ccw(&card->write, iob->data, len);
+	iob->callback = qeth_release_buffer;
+
+	memcpy(QETH_TRANSPORT_HEADER_SEQ_NO(iob->data),
+	       &card->seqno.trans_hdr, QETH_SEQ_NO_LENGTH);
+	card->seqno.trans_hdr++;
+	memcpy(QETH_PDU_HEADER_SEQ_NO(iob->data),
+	       &card->seqno.pdu_hdr, QETH_SEQ_NO_LENGTH);
+	card->seqno.pdu_hdr++;
+	memcpy(QETH_PDU_HEADER_ACK_SEQ_NO(iob->data),
+	       &card->seqno.pdu_hdr_ack, QETH_SEQ_NO_LENGTH);
+	QETH_DBF_HEX(control, 2, iob->data, QETH_DBF_CONTROL_LEN);
+}
+EXPORT_SYMBOL_GPL(qeth_prepare_control_data);
+
+int qeth_send_control_data(struct qeth_card *card, int len,
+		struct qeth_cmd_buffer *iob,
+		int (*reply_cb)(struct qeth_card *, struct qeth_reply *,
+			unsigned long),
+		void *reply_param)
+{
+	int rc;
+	unsigned long flags;
+	struct qeth_reply *reply = NULL;
+	unsigned long timeout;
+
+	QETH_DBF_TEXT(trace, 2, "sendctl");
+
+	reply = qeth_alloc_reply(card);
+	if (!reply) {
+		PRINT_WARN("Could no alloc qeth_reply!\n");
+		return -ENOMEM;
+	}
+	reply->callback = reply_cb;
+	reply->param = reply_param;
+	if (card->state == CARD_STATE_DOWN)
+		reply->seqno = QETH_IDX_COMMAND_SEQNO;
+	else
+		reply->seqno = card->seqno.ipa++;
+	init_waitqueue_head(&reply->wait_q);
+	spin_lock_irqsave(&card->lock, flags);
+	list_add_tail(&reply->list, &card->cmd_waiter_list);
+	spin_unlock_irqrestore(&card->lock, flags);
+	QETH_DBF_HEX(control, 2, iob->data, QETH_DBF_CONTROL_LEN);
+
+	while (atomic_cmpxchg(&card->write.irq_pending, 0, 1)) ;
+	qeth_prepare_control_data(card, len, iob);
+
+	if (IS_IPA(iob->data))
+		timeout = jiffies + QETH_IPA_TIMEOUT;
+	else
+		timeout = jiffies + QETH_TIMEOUT;
+
+	QETH_DBF_TEXT(trace, 6, "noirqpnd");
+	spin_lock_irqsave(get_ccwdev_lock(card->write.ccwdev), flags);
+	rc = ccw_device_start(card->write.ccwdev, &card->write.ccw,
+			      (addr_t) iob, 0, 0);
+	spin_unlock_irqrestore(get_ccwdev_lock(card->write.ccwdev), flags);
+	if (rc) {
+		PRINT_WARN("qeth_send_control_data: "
+			   "ccw_device_start rc = %i\n", rc);
+		QETH_DBF_TEXT_(trace, 2, " err%d", rc);
+		spin_lock_irqsave(&card->lock, flags);
+		list_del_init(&reply->list);
+		qeth_put_reply(reply);
+		spin_unlock_irqrestore(&card->lock, flags);
+		qeth_release_buffer(iob->channel, iob);
+		atomic_set(&card->write.irq_pending, 0);
+		wake_up(&card->wait_q);
+		return rc;
+	}
+	while (!atomic_read(&reply->received)) {
+		if (time_after(jiffies, timeout)) {
+			spin_lock_irqsave(&reply->card->lock, flags);
+			list_del_init(&reply->list);
+			spin_unlock_irqrestore(&reply->card->lock, flags);
+			reply->rc = -ETIME;
+			atomic_inc(&reply->received);
+			wake_up(&reply->wait_q);
+		}
+		cpu_relax();
+	};
+	rc = reply->rc;
+	qeth_put_reply(reply);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_send_control_data);
+
+static int qeth_cm_enable_cb(struct qeth_card *card, struct qeth_reply *reply,
+		unsigned long data)
+{
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(setup, 2, "cmenblcb");
+
+	iob = (struct qeth_cmd_buffer *) data;
+	memcpy(&card->token.cm_filter_r,
+	       QETH_CM_ENABLE_RESP_FILTER_TOKEN(iob->data),
+	       QETH_MPC_TOKEN_LENGTH);
+	QETH_DBF_TEXT_(setup, 2, "  rc%d", iob->rc);
+	return 0;
+}
+
+static int qeth_cm_enable(struct qeth_card *card)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(setup, 2, "cmenable");
+
+	iob = qeth_wait_for_buffer(&card->write);
+	memcpy(iob->data, CM_ENABLE, CM_ENABLE_SIZE);
+	memcpy(QETH_CM_ENABLE_ISSUER_RM_TOKEN(iob->data),
+	       &card->token.issuer_rm_r, QETH_MPC_TOKEN_LENGTH);
+	memcpy(QETH_CM_ENABLE_FILTER_TOKEN(iob->data),
+	       &card->token.cm_filter_w, QETH_MPC_TOKEN_LENGTH);
+
+	rc = qeth_send_control_data(card, CM_ENABLE_SIZE, iob,
+				    qeth_cm_enable_cb, NULL);
+	return rc;
+}
+
+static int qeth_cm_setup_cb(struct qeth_card *card, struct qeth_reply *reply,
+		unsigned long data)
+{
+
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(setup, 2, "cmsetpcb");
+
+	iob = (struct qeth_cmd_buffer *) data;
+	memcpy(&card->token.cm_connection_r,
+	       QETH_CM_SETUP_RESP_DEST_ADDR(iob->data),
+	       QETH_MPC_TOKEN_LENGTH);
+	QETH_DBF_TEXT_(setup, 2, "  rc%d", iob->rc);
+	return 0;
+}
+
+static int qeth_cm_setup(struct qeth_card *card)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(setup, 2, "cmsetup");
+
+	iob = qeth_wait_for_buffer(&card->write);
+	memcpy(iob->data, CM_SETUP, CM_SETUP_SIZE);
+	memcpy(QETH_CM_SETUP_DEST_ADDR(iob->data),
+	       &card->token.issuer_rm_r, QETH_MPC_TOKEN_LENGTH);
+	memcpy(QETH_CM_SETUP_CONNECTION_TOKEN(iob->data),
+	       &card->token.cm_connection_w, QETH_MPC_TOKEN_LENGTH);
+	memcpy(QETH_CM_SETUP_FILTER_TOKEN(iob->data),
+	       &card->token.cm_filter_r, QETH_MPC_TOKEN_LENGTH);
+	rc = qeth_send_control_data(card, CM_SETUP_SIZE, iob,
+				    qeth_cm_setup_cb, NULL);
+	return rc;
+
+}
+
+static inline int qeth_get_initial_mtu_for_card(struct qeth_card *card)
+{
+	switch (card->info.type) {
+	case QETH_CARD_TYPE_UNKNOWN:
+		return 1500;
+	case QETH_CARD_TYPE_IQD:
+		return card->info.max_mtu;
+	case QETH_CARD_TYPE_OSAE:
+		switch (card->info.link_type) {
+		case QETH_LINK_TYPE_HSTR:
+		case QETH_LINK_TYPE_LANE_TR:
+			return 2000;
+		default:
+			return 1492;
+		}
+	default:
+		return 1500;
+	}
+}
+
+static inline int qeth_get_max_mtu_for_card(int cardtype)
+{
+	switch (cardtype) {
+
+	case QETH_CARD_TYPE_UNKNOWN:
+	case QETH_CARD_TYPE_OSAE:
+	case QETH_CARD_TYPE_OSN:
+		return 61440;
+	case QETH_CARD_TYPE_IQD:
+		return 57344;
+	default:
+		return 1500;
+	}
+}
+
+static inline int qeth_get_mtu_out_of_mpc(int cardtype)
+{
+	switch (cardtype) {
+	case QETH_CARD_TYPE_IQD:
+		return 1;
+	default:
+		return 0;
+	}
+}
+
+static inline int qeth_get_mtu_outof_framesize(int framesize)
+{
+	switch (framesize) {
+	case 0x4000:
+		return 8192;
+	case 0x6000:
+		return 16384;
+	case 0xa000:
+		return 32768;
+	case 0xffff:
+		return 57344;
+	default:
+		return 0;
+	}
+}
+
+static inline int qeth_mtu_is_valid(struct qeth_card *card, int mtu)
+{
+	switch (card->info.type) {
+	case QETH_CARD_TYPE_OSAE:
+		return ((mtu >= 576) && (mtu <= 61440));
+	case QETH_CARD_TYPE_IQD:
+		return ((mtu >= 576) &&
+			(mtu <= card->info.max_mtu + 4096 - 32));
+	case QETH_CARD_TYPE_OSN:
+	case QETH_CARD_TYPE_UNKNOWN:
+	default:
+		return 1;
+	}
+}
+
+static int qeth_ulp_enable_cb(struct qeth_card *card, struct qeth_reply *reply,
+		unsigned long data)
+{
+
+	__u16 mtu, framesize;
+	__u16 len;
+	__u8 link_type;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(setup, 2, "ulpenacb");
+
+	iob = (struct qeth_cmd_buffer *) data;
+	memcpy(&card->token.ulp_filter_r,
+	       QETH_ULP_ENABLE_RESP_FILTER_TOKEN(iob->data),
+	       QETH_MPC_TOKEN_LENGTH);
+	if (qeth_get_mtu_out_of_mpc(card->info.type)) {
+		memcpy(&framesize, QETH_ULP_ENABLE_RESP_MAX_MTU(iob->data), 2);
+		mtu = qeth_get_mtu_outof_framesize(framesize);
+		if (!mtu) {
+			iob->rc = -EINVAL;
+			QETH_DBF_TEXT_(setup, 2, "  rc%d", iob->rc);
+			return 0;
+		}
+		card->info.max_mtu = mtu;
+		card->info.initial_mtu = mtu;
+		card->qdio.in_buf_size = mtu + 2 * PAGE_SIZE;
+	} else {
+		card->info.initial_mtu = qeth_get_initial_mtu_for_card(card);
+		card->info.max_mtu = qeth_get_max_mtu_for_card(card->info.type);
+		card->qdio.in_buf_size = QETH_IN_BUF_SIZE_DEFAULT;
+	}
+
+	memcpy(&len, QETH_ULP_ENABLE_RESP_DIFINFO_LEN(iob->data), 2);
+	if (len >= QETH_MPC_DIFINFO_LEN_INDICATES_LINK_TYPE) {
+		memcpy(&link_type,
+		       QETH_ULP_ENABLE_RESP_LINK_TYPE(iob->data), 1);
+		card->info.link_type = link_type;
+	} else
+		card->info.link_type = 0;
+	QETH_DBF_TEXT_(setup, 2, "  rc%d", iob->rc);
+	return 0;
+}
+
+static int qeth_ulp_enable(struct qeth_card *card)
+{
+	int rc;
+	char prot_type;
+	struct qeth_cmd_buffer *iob;
+
+	/*FIXME: trace view callbacks*/
+	QETH_DBF_TEXT(setup, 2, "ulpenabl");
+
+	iob = qeth_wait_for_buffer(&card->write);
+	memcpy(iob->data, ULP_ENABLE, ULP_ENABLE_SIZE);
+
+	*(QETH_ULP_ENABLE_LINKNUM(iob->data)) =
+		(__u8) card->info.portno;
+	if (card->options.layer2)
+		if (card->info.type == QETH_CARD_TYPE_OSN)
+			prot_type = QETH_PROT_OSN2;
+		else
+			prot_type = QETH_PROT_LAYER2;
+	else
+		prot_type = QETH_PROT_TCPIP;
+
+	memcpy(QETH_ULP_ENABLE_PROT_TYPE(iob->data), &prot_type, 1);
+	memcpy(QETH_ULP_ENABLE_DEST_ADDR(iob->data),
+	       &card->token.cm_connection_r, QETH_MPC_TOKEN_LENGTH);
+	memcpy(QETH_ULP_ENABLE_FILTER_TOKEN(iob->data),
+	       &card->token.ulp_filter_w, QETH_MPC_TOKEN_LENGTH);
+	memcpy(QETH_ULP_ENABLE_PORTNAME_AND_LL(iob->data),
+	       card->info.portname, 9);
+	rc = qeth_send_control_data(card, ULP_ENABLE_SIZE, iob,
+				    qeth_ulp_enable_cb, NULL);
+	return rc;
+
+}
+
+static int qeth_ulp_setup_cb(struct qeth_card *card, struct qeth_reply *reply,
+		unsigned long data)
+{
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(setup, 2, "ulpstpcb");
+
+	iob = (struct qeth_cmd_buffer *) data;
+	memcpy(&card->token.ulp_connection_r,
+	       QETH_ULP_SETUP_RESP_CONNECTION_TOKEN(iob->data),
+	       QETH_MPC_TOKEN_LENGTH);
+	QETH_DBF_TEXT_(setup, 2, "  rc%d", iob->rc);
+	return 0;
+}
+
+static int qeth_ulp_setup(struct qeth_card *card)
+{
+	int rc;
+	__u16 temp;
+	struct qeth_cmd_buffer *iob;
+	struct ccw_dev_id dev_id;
+
+	QETH_DBF_TEXT(setup, 2, "ulpsetup");
+
+	iob = qeth_wait_for_buffer(&card->write);
+	memcpy(iob->data, ULP_SETUP, ULP_SETUP_SIZE);
+
+	memcpy(QETH_ULP_SETUP_DEST_ADDR(iob->data),
+	       &card->token.cm_connection_r, QETH_MPC_TOKEN_LENGTH);
+	memcpy(QETH_ULP_SETUP_CONNECTION_TOKEN(iob->data),
+	       &card->token.ulp_connection_w, QETH_MPC_TOKEN_LENGTH);
+	memcpy(QETH_ULP_SETUP_FILTER_TOKEN(iob->data),
+	       &card->token.ulp_filter_r, QETH_MPC_TOKEN_LENGTH);
+
+	ccw_device_get_id(CARD_DDEV(card), &dev_id);
+	memcpy(QETH_ULP_SETUP_CUA(iob->data), &dev_id.devno, 2);
+	temp = (card->info.cula << 8) + card->info.unit_addr2;
+	memcpy(QETH_ULP_SETUP_REAL_DEVADDR(iob->data), &temp, 2);
+	rc = qeth_send_control_data(card, ULP_SETUP_SIZE, iob,
+				    qeth_ulp_setup_cb, NULL);
+	return rc;
+}
+
+static int qeth_alloc_qdio_buffers(struct qeth_card *card)
+{
+	int i, j;
+
+	QETH_DBF_TEXT(setup, 2, "allcqdbf");
+
+	if (atomic_cmpxchg(&card->qdio.state, QETH_QDIO_UNINITIALIZED,
+		QETH_QDIO_ALLOCATED) != QETH_QDIO_UNINITIALIZED)
+		return 0;
+
+	card->qdio.in_q = kmalloc(sizeof(struct qeth_qdio_q),
+				  GFP_KERNEL|GFP_DMA);
+	if (!card->qdio.in_q)
+		goto out_nomem;
+	QETH_DBF_TEXT(setup, 2, "inq");
+	QETH_DBF_HEX(setup, 2, &card->qdio.in_q, sizeof(void *));
+	memset(card->qdio.in_q, 0, sizeof(struct qeth_qdio_q));
+	/* give inbound qeth_qdio_buffers their qdio_buffers */
+	for (i = 0; i < QDIO_MAX_BUFFERS_PER_Q; ++i)
+		card->qdio.in_q->bufs[i].buffer =
+			&card->qdio.in_q->qdio_bufs[i];
+	/* inbound buffer pool */
+	if (qeth_alloc_buffer_pool(card))
+		goto out_freeinq;
+	/* outbound */
+	card->qdio.out_qs =
+		kmalloc(card->qdio.no_out_queues *
+			sizeof(struct qeth_qdio_out_q *), GFP_KERNEL);
+	if (!card->qdio.out_qs)
+		goto out_freepool;
+	for (i = 0; i < card->qdio.no_out_queues; ++i) {
+		card->qdio.out_qs[i] = kmalloc(sizeof(struct qeth_qdio_out_q),
+					       GFP_KERNEL|GFP_DMA);
+		if (!card->qdio.out_qs[i])
+			goto out_freeoutq;
+		QETH_DBF_TEXT_(setup, 2, "outq %i", i);
+		QETH_DBF_HEX(setup, 2, &card->qdio.out_qs[i], sizeof(void *));
+		memset(card->qdio.out_qs[i], 0, sizeof(struct qeth_qdio_out_q));
+		card->qdio.out_qs[i]->queue_no = i;
+		/* give outbound qeth_qdio_buffers their qdio_buffers */
+		for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j) {
+			card->qdio.out_qs[i]->bufs[j].buffer =
+				&card->qdio.out_qs[i]->qdio_bufs[j];
+			skb_queue_head_init(&card->qdio.out_qs[i]->bufs[j].
+					    skb_list);
+			lockdep_set_class(
+				&card->qdio.out_qs[i]->bufs[j].skb_list.lock,
+				&qdio_out_skb_queue_key);
+			INIT_LIST_HEAD(&card->qdio.out_qs[i]->bufs[j].ctx_list);
+		}
+	}
+	return 0;
+
+out_freeoutq:
+	while (i > 0)
+		kfree(card->qdio.out_qs[--i]);
+	kfree(card->qdio.out_qs);
+	card->qdio.out_qs = NULL;
+out_freepool:
+	qeth_free_buffer_pool(card);
+out_freeinq:
+	kfree(card->qdio.in_q);
+	card->qdio.in_q = NULL;
+out_nomem:
+	atomic_set(&card->qdio.state, QETH_QDIO_UNINITIALIZED);
+	return -ENOMEM;
+}
+
+static void qeth_create_qib_param_field(struct qeth_card *card,
+		char *param_field)
+{
+
+	param_field[0] = _ascebc['P'];
+	param_field[1] = _ascebc['C'];
+	param_field[2] = _ascebc['I'];
+	param_field[3] = _ascebc['T'];
+	*((unsigned int *) (&param_field[4])) = QETH_PCI_THRESHOLD_A(card);
+	*((unsigned int *) (&param_field[8])) = QETH_PCI_THRESHOLD_B(card);
+	*((unsigned int *) (&param_field[12])) = QETH_PCI_TIMER_VALUE(card);
+}
+
+static void qeth_create_qib_param_field_blkt(struct qeth_card *card,
+		char *param_field)
+{
+	param_field[16] = _ascebc['B'];
+	param_field[17] = _ascebc['L'];
+	param_field[18] = _ascebc['K'];
+	param_field[19] = _ascebc['T'];
+	*((unsigned int *) (&param_field[20])) = card->info.blkt.time_total;
+	*((unsigned int *) (&param_field[24])) = card->info.blkt.inter_packet;
+	*((unsigned int *) (&param_field[28])) =
+		card->info.blkt.inter_packet_jumbo;
+}
+
+static int qeth_qdio_activate(struct qeth_card *card)
+{
+	QETH_DBF_TEXT(setup, 3, "qdioact");
+	return qdio_activate(CARD_DDEV(card), 0);
+}
+
+static int qeth_dm_act(struct qeth_card *card)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(setup, 2, "dmact");
+
+	iob = qeth_wait_for_buffer(&card->write);
+	memcpy(iob->data, DM_ACT, DM_ACT_SIZE);
+
+	memcpy(QETH_DM_ACT_DEST_ADDR(iob->data),
+	       &card->token.cm_connection_r, QETH_MPC_TOKEN_LENGTH);
+	memcpy(QETH_DM_ACT_CONNECTION_TOKEN(iob->data),
+	       &card->token.ulp_connection_r, QETH_MPC_TOKEN_LENGTH);
+	rc = qeth_send_control_data(card, DM_ACT_SIZE, iob, NULL, NULL);
+	return rc;
+}
+
+static int qeth_mpc_initialize(struct qeth_card *card)
+{
+	int rc;
+
+	QETH_DBF_TEXT(setup, 2, "mpcinit");
+
+	rc = qeth_issue_next_read(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		return rc;
+	}
+	rc = qeth_cm_enable(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		goto out_qdio;
+	}
+	rc = qeth_cm_setup(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "3err%d", rc);
+		goto out_qdio;
+	}
+	rc = qeth_ulp_enable(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "4err%d", rc);
+		goto out_qdio;
+	}
+	rc = qeth_ulp_setup(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "5err%d", rc);
+		goto out_qdio;
+	}
+	rc = qeth_alloc_qdio_buffers(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "5err%d", rc);
+		goto out_qdio;
+	}
+	rc = qeth_qdio_establish(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "6err%d", rc);
+		qeth_free_qdio_buffers(card);
+		goto out_qdio;
+	}
+	rc = qeth_qdio_activate(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "7err%d", rc);
+		goto out_qdio;
+	}
+	rc = qeth_dm_act(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "8err%d", rc);
+		goto out_qdio;
+	}
+
+	return 0;
+out_qdio:
+	qeth_qdio_clear_card(card, card->info.type != QETH_CARD_TYPE_IQD);
+	return rc;
+}
+
+static void qeth_print_status_with_portname(struct qeth_card *card)
+{
+	char dbf_text[15];
+	int i;
+
+	sprintf(dbf_text, "%s", card->info.portname + 1);
+	for (i = 0; i < 8; i++)
+		dbf_text[i] =
+			(char) _ebcasc[(__u8) dbf_text[i]];
+	dbf_text[8] = 0;
+	PRINT_INFO("Device %s/%s/%s is a%s card%s%s%s\n"
+	       "with link type %s (portname: %s)\n",
+	       CARD_RDEV_ID(card),
+	       CARD_WDEV_ID(card),
+	       CARD_DDEV_ID(card),
+	       qeth_get_cardname(card),
+	       (card->info.mcl_level[0]) ? " (level: " : "",
+	       (card->info.mcl_level[0]) ? card->info.mcl_level : "",
+	       (card->info.mcl_level[0]) ? ")" : "",
+	       qeth_get_cardname_short(card),
+	       dbf_text);
+
+}
+
+static void qeth_print_status_no_portname(struct qeth_card *card)
+{
+	if (card->info.portname[0])
+		PRINT_INFO("Device %s/%s/%s is a%s "
+		       "card%s%s%s\nwith link type %s "
+		       "(no portname needed by interface).\n",
+		       CARD_RDEV_ID(card),
+		       CARD_WDEV_ID(card),
+		       CARD_DDEV_ID(card),
+		       qeth_get_cardname(card),
+		       (card->info.mcl_level[0]) ? " (level: " : "",
+		       (card->info.mcl_level[0]) ? card->info.mcl_level : "",
+		       (card->info.mcl_level[0]) ? ")" : "",
+		       qeth_get_cardname_short(card));
+	else
+		PRINT_INFO("Device %s/%s/%s is a%s "
+		       "card%s%s%s\nwith link type %s.\n",
+		       CARD_RDEV_ID(card),
+		       CARD_WDEV_ID(card),
+		       CARD_DDEV_ID(card),
+		       qeth_get_cardname(card),
+		       (card->info.mcl_level[0]) ? " (level: " : "",
+		       (card->info.mcl_level[0]) ? card->info.mcl_level : "",
+		       (card->info.mcl_level[0]) ? ")" : "",
+		       qeth_get_cardname_short(card));
+}
+
+void qeth_print_status_message(struct qeth_card *card)
+{
+	switch (card->info.type) {
+	case QETH_CARD_TYPE_OSAE:
+		/* VM will use a non-zero first character
+		 * to indicate a HiperSockets like reporting
+		 * of the level OSA sets the first character to zero
+		 * */
+		if (!card->info.mcl_level[0]) {
+			sprintf(card->info.mcl_level, "%02x%02x",
+				card->info.mcl_level[2],
+				card->info.mcl_level[3]);
+
+			card->info.mcl_level[QETH_MCL_LENGTH] = 0;
+			break;
+		}
+		/* fallthrough */
+	case QETH_CARD_TYPE_IQD:
+		if (card->info.guestlan) {
+			card->info.mcl_level[0] = (char) _ebcasc[(__u8)
+				card->info.mcl_level[0]];
+			card->info.mcl_level[1] = (char) _ebcasc[(__u8)
+				card->info.mcl_level[1]];
+			card->info.mcl_level[2] = (char) _ebcasc[(__u8)
+				card->info.mcl_level[2]];
+			card->info.mcl_level[3] = (char) _ebcasc[(__u8)
+				card->info.mcl_level[3]];
+			card->info.mcl_level[QETH_MCL_LENGTH] = 0;
+		}
+		break;
+	default:
+		memset(&card->info.mcl_level[0], 0, QETH_MCL_LENGTH + 1);
+	}
+	if (card->info.portname_required)
+		qeth_print_status_with_portname(card);
+	else
+		qeth_print_status_no_portname(card);
+}
+EXPORT_SYMBOL_GPL(qeth_print_status_message);
+
+void qeth_put_buffer_pool_entry(struct qeth_card *card,
+		struct qeth_buffer_pool_entry *entry)
+{
+	QETH_DBF_TEXT(trace, 6, "ptbfplen");
+	list_add_tail(&entry->list, &card->qdio.in_buf_pool.entry_list);
+}
+EXPORT_SYMBOL_GPL(qeth_put_buffer_pool_entry);
+
+static void qeth_initialize_working_pool_list(struct qeth_card *card)
+{
+	struct qeth_buffer_pool_entry *entry;
+
+	QETH_DBF_TEXT(trace, 5, "inwrklst");
+
+	list_for_each_entry(entry,
+			    &card->qdio.init_pool.entry_list, init_list) {
+		qeth_put_buffer_pool_entry(card, entry);
+	}
+}
+
+static inline struct qeth_buffer_pool_entry *qeth_find_free_buffer_pool_entry(
+		struct qeth_card *card)
+{
+	struct list_head *plh;
+	struct qeth_buffer_pool_entry *entry;
+	int i, free;
+	struct page *page;
+
+	if (list_empty(&card->qdio.in_buf_pool.entry_list))
+		return NULL;
+
+	list_for_each(plh, &card->qdio.in_buf_pool.entry_list) {
+		entry = list_entry(plh, struct qeth_buffer_pool_entry, list);
+		free = 1;
+		for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(card); ++i) {
+			if (page_count(virt_to_page(entry->elements[i])) > 1) {
+				free = 0;
+				break;
+			}
+		}
+		if (free) {
+			list_del_init(&entry->list);
+			return entry;
+		}
+	}
+
+	/* no free buffer in pool so take first one and swap pages */
+	entry = list_entry(card->qdio.in_buf_pool.entry_list.next,
+			struct qeth_buffer_pool_entry, list);
+	for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(card); ++i) {
+		if (page_count(virt_to_page(entry->elements[i])) > 1) {
+			page = alloc_page(GFP_ATOMIC|GFP_DMA);
+			if (!page) {
+				return NULL;
+			} else {
+				free_page((unsigned long)entry->elements[i]);
+				entry->elements[i] = page_address(page);
+				if (card->options.performance_stats)
+					card->perf_stats.sg_alloc_page_rx++;
+			}
+		}
+	}
+	list_del_init(&entry->list);
+	return entry;
+}
+
+static int qeth_init_input_buffer(struct qeth_card *card,
+		struct qeth_qdio_buffer *buf)
+{
+	struct qeth_buffer_pool_entry *pool_entry;
+	int i;
+
+	pool_entry = qeth_find_free_buffer_pool_entry(card);
+	if (!pool_entry)
+		return 1;
+
+	/*
+	 * since the buffer is accessed only from the input_tasklet
+	 * there shouldn't be a need to synchronize; also, since we use
+	 * the QETH_IN_BUF_REQUEUE_THRESHOLD we should never run  out off
+	 * buffers
+	 */
+	BUG_ON(!pool_entry);
+
+	buf->pool_entry = pool_entry;
+	for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(card); ++i) {
+		buf->buffer->element[i].length = PAGE_SIZE;
+		buf->buffer->element[i].addr =  pool_entry->elements[i];
+		if (i == QETH_MAX_BUFFER_ELEMENTS(card) - 1)
+			buf->buffer->element[i].flags = SBAL_FLAGS_LAST_ENTRY;
+		else
+			buf->buffer->element[i].flags = 0;
+	}
+	return 0;
+}
+
+int qeth_init_qdio_queues(struct qeth_card *card)
+{
+	int i, j;
+	int rc;
+
+	QETH_DBF_TEXT(setup, 2, "initqdqs");
+
+	/* inbound queue */
+	memset(card->qdio.in_q->qdio_bufs, 0,
+	       QDIO_MAX_BUFFERS_PER_Q * sizeof(struct qdio_buffer));
+	qeth_initialize_working_pool_list(card);
+	/*give only as many buffers to hardware as we have buffer pool entries*/
+	for (i = 0; i < card->qdio.in_buf_pool.buf_count - 1; ++i)
+		qeth_init_input_buffer(card, &card->qdio.in_q->bufs[i]);
+	card->qdio.in_q->next_buf_to_init =
+		card->qdio.in_buf_pool.buf_count - 1;
+	rc = do_QDIO(CARD_DDEV(card), QDIO_FLAG_SYNC_INPUT, 0, 0,
+		     card->qdio.in_buf_pool.buf_count - 1, NULL);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		return rc;
+	}
+	rc = qdio_synchronize(CARD_DDEV(card), QDIO_FLAG_SYNC_INPUT, 0);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		return rc;
+	}
+	/* outbound queue */
+	for (i = 0; i < card->qdio.no_out_queues; ++i) {
+		memset(card->qdio.out_qs[i]->qdio_bufs, 0,
+		       QDIO_MAX_BUFFERS_PER_Q * sizeof(struct qdio_buffer));
+		for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j) {
+			qeth_clear_output_buffer(card->qdio.out_qs[i],
+					&card->qdio.out_qs[i]->bufs[j]);
+		}
+		card->qdio.out_qs[i]->card = card;
+		card->qdio.out_qs[i]->next_buf_to_fill = 0;
+		card->qdio.out_qs[i]->do_pack = 0;
+		atomic_set(&card->qdio.out_qs[i]->used_buffers, 0);
+		atomic_set(&card->qdio.out_qs[i]->set_pci_flags_count, 0);
+		atomic_set(&card->qdio.out_qs[i]->state,
+			   QETH_OUT_Q_UNLOCKED);
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(qeth_init_qdio_queues);
+
+static inline __u8 qeth_get_ipa_adp_type(enum qeth_link_types link_type)
+{
+	switch (link_type) {
+	case QETH_LINK_TYPE_HSTR:
+		return 2;
+	default:
+		return 1;
+	}
+}
+
+static void qeth_fill_ipacmd_header(struct qeth_card *card,
+		struct qeth_ipa_cmd *cmd, __u8 command,
+		enum qeth_prot_versions prot)
+{
+	memset(cmd, 0, sizeof(struct qeth_ipa_cmd));
+	cmd->hdr.command = command;
+	cmd->hdr.initiator = IPA_CMD_INITIATOR_HOST;
+	cmd->hdr.seqno = card->seqno.ipa;
+	cmd->hdr.adapter_type = qeth_get_ipa_adp_type(card->info.link_type);
+	cmd->hdr.rel_adapter_no = (__u8) card->info.portno;
+	if (card->options.layer2)
+		cmd->hdr.prim_version_no = 2;
+	else
+		cmd->hdr.prim_version_no = 1;
+	cmd->hdr.param_count = 1;
+	cmd->hdr.prot_version = prot;
+	cmd->hdr.ipa_supported = 0;
+	cmd->hdr.ipa_enabled = 0;
+}
+
+struct qeth_cmd_buffer *qeth_get_ipacmd_buffer(struct qeth_card *card,
+		enum qeth_ipa_cmds ipacmd, enum qeth_prot_versions prot)
+{
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	iob = qeth_wait_for_buffer(&card->write);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	qeth_fill_ipacmd_header(card, cmd, ipacmd, prot);
+
+	return iob;
+}
+EXPORT_SYMBOL_GPL(qeth_get_ipacmd_buffer);
+
+void qeth_prepare_ipa_cmd(struct qeth_card *card, struct qeth_cmd_buffer *iob,
+		char prot_type)
+{
+	memcpy(iob->data, IPA_PDU_HEADER, IPA_PDU_HEADER_SIZE);
+	memcpy(QETH_IPA_CMD_PROT_TYPE(iob->data), &prot_type, 1);
+	memcpy(QETH_IPA_CMD_DEST_ADDR(iob->data),
+	       &card->token.ulp_connection_r, QETH_MPC_TOKEN_LENGTH);
+}
+EXPORT_SYMBOL_GPL(qeth_prepare_ipa_cmd);
+
+int qeth_send_ipa_cmd(struct qeth_card *card, struct qeth_cmd_buffer *iob,
+		int (*reply_cb)(struct qeth_card *, struct qeth_reply*,
+			unsigned long),
+		void *reply_param)
+{
+	int rc;
+	char prot_type;
+	int cmd;
+	cmd = ((struct qeth_ipa_cmd *)
+		(iob->data+IPA_PDU_HEADER_SIZE))->hdr.command;
+
+	QETH_DBF_TEXT(trace, 4, "sendipa");
+
+	if (card->options.layer2)
+		if (card->info.type == QETH_CARD_TYPE_OSN)
+			prot_type = QETH_PROT_OSN2;
+		else
+			prot_type = QETH_PROT_LAYER2;
+	else
+		prot_type = QETH_PROT_TCPIP;
+	qeth_prepare_ipa_cmd(card, iob, prot_type);
+	rc = qeth_send_control_data(card, IPA_CMD_LENGTH, iob,
+				    reply_cb, reply_param);
+	if (rc != 0) {
+		char *ipa_cmd_name;
+		ipa_cmd_name = qeth_get_ipa_cmd_name(cmd);
+		PRINT_ERR("%s %s(%x) returned %s(%x)\n", __FUNCTION__,
+			ipa_cmd_name, cmd, qeth_get_ipa_msg(rc), rc);
+	}
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_send_ipa_cmd);
+
+static int qeth_send_startstoplan(struct qeth_card *card,
+		enum qeth_ipa_cmds ipacmd, enum qeth_prot_versions prot)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+
+	iob = qeth_get_ipacmd_buffer(card, ipacmd, prot);
+	rc = qeth_send_ipa_cmd(card, iob, NULL, NULL);
+
+	return rc;
+}
+
+int qeth_send_startlan(struct qeth_card *card)
+{
+	int rc;
+
+	QETH_DBF_TEXT(setup, 2, "strtlan");
+
+	rc = qeth_send_startstoplan(card, IPA_CMD_STARTLAN, 0);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_send_startlan);
+
+int qeth_send_stoplan(struct qeth_card *card)
+{
+	int rc = 0;
+
+	/*
+	 * TODO: according to the IPA format document page 14,
+	 * TCP/IP (we!) never issue a STOPLAN
+	 * is this right ?!?
+	 */
+	QETH_DBF_TEXT(setup, 2, "stoplan");
+
+	rc = qeth_send_startstoplan(card, IPA_CMD_STOPLAN, 0);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_send_stoplan);
+
+int qeth_default_setadapterparms_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 4, "defadpcb");
+
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (cmd->hdr.return_code == 0)
+		cmd->hdr.return_code =
+			cmd->data.setadapterparms.hdr.return_code;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(qeth_default_setadapterparms_cb);
+
+static int qeth_query_setadapterparms_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 3, "quyadpcb");
+
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (cmd->data.setadapterparms.data.query_cmds_supp.lan_type & 0x7f)
+		card->info.link_type =
+		      cmd->data.setadapterparms.data.query_cmds_supp.lan_type;
+	card->options.adp.supported_funcs =
+		cmd->data.setadapterparms.data.query_cmds_supp.supported_cmds;
+	return qeth_default_setadapterparms_cb(card, reply, (unsigned long)cmd);
+}
+
+struct qeth_cmd_buffer *qeth_get_adapter_cmd(struct qeth_card *card,
+		__u32 command, __u32 cmdlen)
+{
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETADAPTERPARMS,
+				     QETH_PROT_IPV4);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	cmd->data.setadapterparms.hdr.cmdlength = cmdlen;
+	cmd->data.setadapterparms.hdr.command_code = command;
+	cmd->data.setadapterparms.hdr.used_total = 1;
+	cmd->data.setadapterparms.hdr.seq_no = 1;
+
+	return iob;
+}
+EXPORT_SYMBOL_GPL(qeth_get_adapter_cmd);
+
+int qeth_query_setadapterparms(struct qeth_card *card)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(trace, 3, "queryadp");
+	iob = qeth_get_adapter_cmd(card, IPA_SETADP_QUERY_COMMANDS_SUPPORTED,
+				   sizeof(struct qeth_ipacmd_setadpparms));
+	rc = qeth_send_ipa_cmd(card, iob, qeth_query_setadapterparms_cb, NULL);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_query_setadapterparms);
+
+int qeth_check_qdio_errors(struct qdio_buffer *buf, unsigned int qdio_error,
+		unsigned int siga_error, const char *dbftext)
+{
+	if (qdio_error || siga_error) {
+		QETH_DBF_TEXT(trace, 2, dbftext);
+		QETH_DBF_TEXT(qerr, 2, dbftext);
+		QETH_DBF_TEXT_(qerr, 2, " F15=%02X",
+			       buf->element[15].flags & 0xff);
+		QETH_DBF_TEXT_(qerr, 2, " F14=%02X",
+			       buf->element[14].flags & 0xff);
+		QETH_DBF_TEXT_(qerr, 2, " qerr=%X", qdio_error);
+		QETH_DBF_TEXT_(qerr, 2, " serr=%X", siga_error);
+		return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(qeth_check_qdio_errors);
+
+void qeth_queue_input_buffer(struct qeth_card *card, int index)
+{
+	struct qeth_qdio_q *queue = card->qdio.in_q;
+	int count;
+	int i;
+	int rc;
+	int newcount = 0;
+
+	QETH_DBF_TEXT(trace, 6, "queinbuf");
+	count = (index < queue->next_buf_to_init)?
+		card->qdio.in_buf_pool.buf_count -
+		(queue->next_buf_to_init - index) :
+		card->qdio.in_buf_pool.buf_count -
+		(queue->next_buf_to_init + QDIO_MAX_BUFFERS_PER_Q - index);
+	/* only requeue at a certain threshold to avoid SIGAs */
+	if (count >= QETH_IN_BUF_REQUEUE_THRESHOLD(card)) {
+		for (i = queue->next_buf_to_init;
+		     i < queue->next_buf_to_init + count; ++i) {
+			if (qeth_init_input_buffer(card,
+				&queue->bufs[i % QDIO_MAX_BUFFERS_PER_Q])) {
+				break;
+			} else {
+				newcount++;
+			}
+		}
+
+		if (newcount < count) {
+			/* we are in memory shortage so we switch back to
+			   traditional skb allocation and drop packages */
+			if (!atomic_read(&card->force_alloc_skb) &&
+			    net_ratelimit())
+				PRINT_WARN("Switch to alloc skb\n");
+			atomic_set(&card->force_alloc_skb, 3);
+			count = newcount;
+		} else {
+			if ((atomic_read(&card->force_alloc_skb) == 1) &&
+			    net_ratelimit())
+				PRINT_WARN("Switch to sg\n");
+			atomic_add_unless(&card->force_alloc_skb, -1, 0);
+		}
+
+		/*
+		 * according to old code it should be avoided to requeue all
+		 * 128 buffers in order to benefit from PCI avoidance.
+		 * this function keeps at least one buffer (the buffer at
+		 * 'index') un-requeued -> this buffer is the first buffer that
+		 * will be requeued the next time
+		 */
+		if (card->options.performance_stats) {
+			card->perf_stats.inbound_do_qdio_cnt++;
+			card->perf_stats.inbound_do_qdio_start_time =
+				qeth_get_micros();
+		}
+		rc = do_QDIO(CARD_DDEV(card),
+			     QDIO_FLAG_SYNC_INPUT | QDIO_FLAG_UNDER_INTERRUPT,
+			     0, queue->next_buf_to_init, count, NULL);
+		if (card->options.performance_stats)
+			card->perf_stats.inbound_do_qdio_time +=
+				qeth_get_micros() -
+				card->perf_stats.inbound_do_qdio_start_time;
+		if (rc) {
+			PRINT_WARN("qeth_queue_input_buffer's do_QDIO "
+				   "return %i (device %s).\n",
+				   rc, CARD_DDEV_ID(card));
+			QETH_DBF_TEXT(trace, 2, "qinberr");
+			QETH_DBF_TEXT_(trace, 2, "%s", CARD_BUS_ID(card));
+		}
+		queue->next_buf_to_init = (queue->next_buf_to_init + count) %
+					  QDIO_MAX_BUFFERS_PER_Q;
+	}
+}
+EXPORT_SYMBOL_GPL(qeth_queue_input_buffer);
+
+static int qeth_handle_send_error(struct qeth_card *card,
+		struct qeth_qdio_out_buffer *buffer, unsigned int qdio_err,
+		unsigned int siga_err)
+{
+	int sbalf15 = buffer->buffer->element[15].flags & 0xff;
+	int cc = siga_err & 3;
+
+	QETH_DBF_TEXT(trace, 6, "hdsnderr");
+	qeth_check_qdio_errors(buffer->buffer, qdio_err, siga_err, "qouterr");
+	switch (cc) {
+	case 0:
+		if (qdio_err) {
+			QETH_DBF_TEXT(trace, 1, "lnkfail");
+			QETH_DBF_TEXT_(trace, 1, "%s", CARD_BUS_ID(card));
+			QETH_DBF_TEXT_(trace, 1, "%04x %02x",
+				       (u16)qdio_err, (u8)sbalf15);
+			return QETH_SEND_ERROR_LINK_FAILURE;
+		}
+		return QETH_SEND_ERROR_NONE;
+	case 2:
+		if (siga_err & QDIO_SIGA_ERROR_B_BIT_SET) {
+			QETH_DBF_TEXT(trace, 1, "SIGAcc2B");
+			QETH_DBF_TEXT_(trace, 1, "%s", CARD_BUS_ID(card));
+			return QETH_SEND_ERROR_KICK_IT;
+		}
+		if ((sbalf15 >= 15) && (sbalf15 <= 31))
+			return QETH_SEND_ERROR_RETRY;
+		return QETH_SEND_ERROR_LINK_FAILURE;
+		/* look at qdio_error and sbalf 15 */
+	case 1:
+		QETH_DBF_TEXT(trace, 1, "SIGAcc1");
+		QETH_DBF_TEXT_(trace, 1, "%s", CARD_BUS_ID(card));
+		return QETH_SEND_ERROR_LINK_FAILURE;
+	case 3:
+	default:
+		QETH_DBF_TEXT(trace, 1, "SIGAcc3");
+		QETH_DBF_TEXT_(trace, 1, "%s", CARD_BUS_ID(card));
+		return QETH_SEND_ERROR_KICK_IT;
+	}
+}
+
+/*
+ * Switched to packing state if the number of used buffers on a queue
+ * reaches a certain limit.
+ */
+static void qeth_switch_to_packing_if_needed(struct qeth_qdio_out_q *queue)
+{
+	if (!queue->do_pack) {
+		if (atomic_read(&queue->used_buffers)
+		    >= QETH_HIGH_WATERMARK_PACK){
+			/* switch non-PACKING -> PACKING */
+			QETH_DBF_TEXT(trace, 6, "np->pack");
+			if (queue->card->options.performance_stats)
+				queue->card->perf_stats.sc_dp_p++;
+			queue->do_pack = 1;
+		}
+	}
+}
+
+/*
+ * Switches from packing to non-packing mode. If there is a packing
+ * buffer on the queue this buffer will be prepared to be flushed.
+ * In that case 1 is returned to inform the caller. If no buffer
+ * has to be flushed, zero is returned.
+ */
+static int qeth_switch_to_nonpacking_if_needed(struct qeth_qdio_out_q *queue)
+{
+	struct qeth_qdio_out_buffer *buffer;
+	int flush_count = 0;
+
+	if (queue->do_pack) {
+		if (atomic_read(&queue->used_buffers)
+		    <= QETH_LOW_WATERMARK_PACK) {
+			/* switch PACKING -> non-PACKING */
+			QETH_DBF_TEXT(trace, 6, "pack->np");
+			if (queue->card->options.performance_stats)
+				queue->card->perf_stats.sc_p_dp++;
+			queue->do_pack = 0;
+			/* flush packing buffers */
+			buffer = &queue->bufs[queue->next_buf_to_fill];
+			if ((atomic_read(&buffer->state) ==
+						QETH_QDIO_BUF_EMPTY) &&
+			    (buffer->next_element_to_fill > 0)) {
+				atomic_set(&buffer->state,
+						QETH_QDIO_BUF_PRIMED);
+				flush_count++;
+				queue->next_buf_to_fill =
+					(queue->next_buf_to_fill + 1) %
+					QDIO_MAX_BUFFERS_PER_Q;
+			}
+		}
+	}
+	return flush_count;
+}
+
+/*
+ * Called to flush a packing buffer if no more pci flags are on the queue.
+ * Checks if there is a packing buffer and prepares it to be flushed.
+ * In that case returns 1, otherwise zero.
+ */
+static int qeth_flush_buffers_on_no_pci(struct qeth_qdio_out_q *queue)
+{
+	struct qeth_qdio_out_buffer *buffer;
+
+	buffer = &queue->bufs[queue->next_buf_to_fill];
+	if ((atomic_read(&buffer->state) == QETH_QDIO_BUF_EMPTY) &&
+	   (buffer->next_element_to_fill > 0)) {
+		/* it's a packing buffer */
+		atomic_set(&buffer->state, QETH_QDIO_BUF_PRIMED);
+		queue->next_buf_to_fill =
+			(queue->next_buf_to_fill + 1) % QDIO_MAX_BUFFERS_PER_Q;
+		return 1;
+	}
+	return 0;
+}
+
+static void qeth_flush_buffers(struct qeth_qdio_out_q *queue, int under_int,
+		int index, int count)
+{
+	struct qeth_qdio_out_buffer *buf;
+	int rc;
+	int i;
+	unsigned int qdio_flags;
+
+	QETH_DBF_TEXT(trace, 6, "flushbuf");
+
+	for (i = index; i < index + count; ++i) {
+		buf = &queue->bufs[i % QDIO_MAX_BUFFERS_PER_Q];
+		buf->buffer->element[buf->next_element_to_fill - 1].flags |=
+				SBAL_FLAGS_LAST_ENTRY;
+
+		if (queue->card->info.type == QETH_CARD_TYPE_IQD)
+			continue;
+
+		if (!queue->do_pack) {
+			if ((atomic_read(&queue->used_buffers) >=
+				(QETH_HIGH_WATERMARK_PACK -
+				 QETH_WATERMARK_PACK_FUZZ)) &&
+			    !atomic_read(&queue->set_pci_flags_count)) {
+				/* it's likely that we'll go to packing
+				 * mode soon */
+				atomic_inc(&queue->set_pci_flags_count);
+				buf->buffer->element[0].flags |= 0x40;
+			}
+		} else {
+			if (!atomic_read(&queue->set_pci_flags_count)) {
+				/*
+				 * there's no outstanding PCI any more, so we
+				 * have to request a PCI to be sure the the PCI
+				 * will wake at some time in the future then we
+				 * can flush packed buffers that might still be
+				 * hanging around, which can happen if no
+				 * further send was requested by the stack
+				 */
+				atomic_inc(&queue->set_pci_flags_count);
+				buf->buffer->element[0].flags |= 0x40;
+			}
+		}
+	}
+
+	queue->card->dev->trans_start = jiffies;
+	if (queue->card->options.performance_stats) {
+		queue->card->perf_stats.outbound_do_qdio_cnt++;
+		queue->card->perf_stats.outbound_do_qdio_start_time =
+			qeth_get_micros();
+	}
+	qdio_flags = QDIO_FLAG_SYNC_OUTPUT;
+	if (under_int)
+		qdio_flags |= QDIO_FLAG_UNDER_INTERRUPT;
+	if (atomic_read(&queue->set_pci_flags_count))
+		qdio_flags |= QDIO_FLAG_PCI_OUT;
+	rc = do_QDIO(CARD_DDEV(queue->card), qdio_flags,
+		     queue->queue_no, index, count, NULL);
+	if (queue->card->options.performance_stats)
+		queue->card->perf_stats.outbound_do_qdio_time +=
+			qeth_get_micros() -
+			queue->card->perf_stats.outbound_do_qdio_start_time;
+	if (rc) {
+		QETH_DBF_TEXT(trace, 2, "flushbuf");
+		QETH_DBF_TEXT_(trace, 2, " err%d", rc);
+		QETH_DBF_TEXT_(trace, 2, "%s", CARD_DDEV_ID(queue->card));
+		queue->card->stats.tx_errors += count;
+		/* this must not happen under normal circumstances. if it
+		 * happens something is really wrong -> recover */
+		qeth_schedule_recovery(queue->card);
+		return;
+	}
+	atomic_add(count, &queue->used_buffers);
+	if (queue->card->options.performance_stats)
+		queue->card->perf_stats.bufs_sent += count;
+}
+
+static void qeth_check_outbound_queue(struct qeth_qdio_out_q *queue)
+{
+	int index;
+	int flush_cnt = 0;
+	int q_was_packing = 0;
+
+	/*
+	 * check if weed have to switch to non-packing mode or if
+	 * we have to get a pci flag out on the queue
+	 */
+	if ((atomic_read(&queue->used_buffers) <= QETH_LOW_WATERMARK_PACK) ||
+	    !atomic_read(&queue->set_pci_flags_count)) {
+		if (atomic_xchg(&queue->state, QETH_OUT_Q_LOCKED_FLUSH) ==
+				QETH_OUT_Q_UNLOCKED) {
+			/*
+			 * If we get in here, there was no action in
+			 * do_send_packet. So, we check if there is a
+			 * packing buffer to be flushed here.
+			 */
+			netif_stop_queue(queue->card->dev);
+			index = queue->next_buf_to_fill;
+			q_was_packing = queue->do_pack;
+			/* queue->do_pack may change */
+			barrier();
+			flush_cnt += qeth_switch_to_nonpacking_if_needed(queue);
+			if (!flush_cnt &&
+			    !atomic_read(&queue->set_pci_flags_count))
+				flush_cnt +=
+					qeth_flush_buffers_on_no_pci(queue);
+			if (queue->card->options.performance_stats &&
+			    q_was_packing)
+				queue->card->perf_stats.bufs_sent_pack +=
+					flush_cnt;
+			if (flush_cnt)
+				qeth_flush_buffers(queue, 1, index, flush_cnt);
+			atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
+		}
+	}
+}
+
+void qeth_qdio_output_handler(struct ccw_device *ccwdev, unsigned int status,
+		unsigned int qdio_error, unsigned int siga_error,
+		unsigned int __queue, int first_element, int count,
+		unsigned long card_ptr)
+{
+	struct qeth_card *card        = (struct qeth_card *) card_ptr;
+	struct qeth_qdio_out_q *queue = card->qdio.out_qs[__queue];
+	struct qeth_qdio_out_buffer *buffer;
+	int i;
+
+	QETH_DBF_TEXT(trace, 6, "qdouhdl");
+	if (status & QDIO_STATUS_LOOK_FOR_ERROR) {
+		if (status & QDIO_STATUS_ACTIVATE_CHECK_CONDITION) {
+			QETH_DBF_TEXT(trace, 2, "achkcond");
+			QETH_DBF_TEXT_(trace, 2, "%s", CARD_BUS_ID(card));
+			QETH_DBF_TEXT_(trace, 2, "%08x", status);
+			netif_stop_queue(card->dev);
+			qeth_schedule_recovery(card);
+			return;
+		}
+	}
+	if (card->options.performance_stats) {
+		card->perf_stats.outbound_handler_cnt++;
+		card->perf_stats.outbound_handler_start_time =
+			qeth_get_micros();
+	}
+	for (i = first_element; i < (first_element + count); ++i) {
+		buffer = &queue->bufs[i % QDIO_MAX_BUFFERS_PER_Q];
+		/*we only handle the KICK_IT error by doing a recovery */
+		if (qeth_handle_send_error(card, buffer,
+					   qdio_error, siga_error)
+				== QETH_SEND_ERROR_KICK_IT){
+			netif_stop_queue(card->dev);
+			qeth_schedule_recovery(card);
+			return;
+		}
+		qeth_clear_output_buffer(queue, buffer);
+	}
+	atomic_sub(count, &queue->used_buffers);
+	/* check if we need to do something on this outbound queue */
+	if (card->info.type != QETH_CARD_TYPE_IQD)
+		qeth_check_outbound_queue(queue);
+
+	netif_wake_queue(queue->card->dev);
+	if (card->options.performance_stats)
+		card->perf_stats.outbound_handler_time += qeth_get_micros() -
+			card->perf_stats.outbound_handler_start_time;
+}
+EXPORT_SYMBOL_GPL(qeth_qdio_output_handler);
+
+int qeth_get_cast_type(struct qeth_card *card, struct sk_buff *skb)
+{
+	int cast_type = RTN_UNSPEC;
+
+	if (card->info.type == QETH_CARD_TYPE_OSN)
+		return cast_type;
+
+	if (skb->dst && skb->dst->neighbour) {
+		cast_type = skb->dst->neighbour->type;
+		if ((cast_type == RTN_BROADCAST) ||
+		    (cast_type == RTN_MULTICAST) ||
+		    (cast_type == RTN_ANYCAST))
+			return cast_type;
+		else
+			return RTN_UNSPEC;
+	}
+	/* try something else */
+	if (skb->protocol == ETH_P_IPV6)
+		return (skb_network_header(skb)[24] == 0xff) ?
+				RTN_MULTICAST : 0;
+	else if (skb->protocol == ETH_P_IP)
+		return ((skb_network_header(skb)[16] & 0xf0) == 0xe0) ?
+				RTN_MULTICAST : 0;
+	/* ... */
+	if (!memcmp(skb->data, skb->dev->broadcast, 6))
+		return RTN_BROADCAST;
+	else {
+		u16 hdr_mac;
+
+		hdr_mac = *((u16 *)skb->data);
+		/* tr multicast? */
+		switch (card->info.link_type) {
+		case QETH_LINK_TYPE_HSTR:
+		case QETH_LINK_TYPE_LANE_TR:
+			if ((hdr_mac == QETH_TR_MAC_NC) ||
+			    (hdr_mac == QETH_TR_MAC_C))
+				return RTN_MULTICAST;
+			break;
+		/* eth or so multicast? */
+		default:
+		if ((hdr_mac == QETH_ETH_MAC_V4) ||
+			    (hdr_mac == QETH_ETH_MAC_V6))
+				return RTN_MULTICAST;
+		}
+	}
+	return cast_type;
+}
+EXPORT_SYMBOL_GPL(qeth_get_cast_type);
+
+int qeth_get_priority_queue(struct qeth_card *card, struct sk_buff *skb,
+			int ipv, int cast_type)
+{
+	if (!ipv && (card->info.type == QETH_CARD_TYPE_OSAE))
+		return card->qdio.default_out_queue;
+	switch (card->qdio.no_out_queues) {
+	case 4:
+		if (cast_type && card->info.is_multicast_different)
+			return card->info.is_multicast_different &
+				(card->qdio.no_out_queues - 1);
+		if (card->qdio.do_prio_queueing && (ipv == 4)) {
+			const u8 tos = ip_hdr(skb)->tos;
+
+			if (card->qdio.do_prio_queueing ==
+				QETH_PRIO_Q_ING_TOS) {
+				if (tos & IP_TOS_NOTIMPORTANT)
+					return 3;
+				if (tos & IP_TOS_HIGHRELIABILITY)
+					return 2;
+				if (tos & IP_TOS_HIGHTHROUGHPUT)
+					return 1;
+				if (tos & IP_TOS_LOWDELAY)
+					return 0;
+			}
+			if (card->qdio.do_prio_queueing ==
+				QETH_PRIO_Q_ING_PREC)
+				return 3 - (tos >> 6);
+		} else if (card->qdio.do_prio_queueing && (ipv == 6)) {
+			/* TODO: IPv6!!! */
+		}
+		return card->qdio.default_out_queue;
+	case 1: /* fallthrough for single-out-queue 1920-device */
+	default:
+		return card->qdio.default_out_queue;
+	}
+}
+EXPORT_SYMBOL_GPL(qeth_get_priority_queue);
+
+static void __qeth_free_new_skb(struct sk_buff *orig_skb,
+		struct sk_buff *new_skb)
+{
+	if (orig_skb != new_skb)
+		dev_kfree_skb_any(new_skb);
+}
+
+static inline struct sk_buff *qeth_realloc_headroom(struct qeth_card *card,
+		struct sk_buff *skb, int size)
+{
+	struct sk_buff *new_skb = skb;
+
+	if (skb_headroom(skb) >= size)
+		return skb;
+	new_skb = skb_realloc_headroom(skb, size);
+	if (!new_skb)
+		PRINT_ERR("Could not realloc headroom for qeth_hdr "
+			  "on interface %s", QETH_CARD_IFNAME(card));
+	return new_skb;
+}
+
+struct sk_buff *qeth_prepare_skb(struct qeth_card *card, struct sk_buff *skb,
+		 struct qeth_hdr **hdr)
+{
+	struct sk_buff *new_skb;
+
+	QETH_DBF_TEXT(trace, 6, "prepskb");
+
+	new_skb = qeth_realloc_headroom(card, skb,
+			sizeof(struct qeth_hdr));
+	if (!new_skb)
+		return NULL;
+
+	*hdr = ((struct qeth_hdr *)qeth_push_skb(card, new_skb,
+			sizeof(struct qeth_hdr)));
+	if (*hdr == NULL) {
+		__qeth_free_new_skb(skb, new_skb);
+		return NULL;
+	}
+	return new_skb;
+}
+EXPORT_SYMBOL_GPL(qeth_prepare_skb);
+
+int qeth_get_elements_no(struct qeth_card *card, void *hdr,
+		     struct sk_buff *skb, int elems)
+{
+	int elements_needed = 0;
+
+	if (skb_shinfo(skb)->nr_frags > 0)
+		elements_needed = (skb_shinfo(skb)->nr_frags + 1);
+	if (elements_needed == 0)
+		elements_needed = 1 + (((((unsigned long) hdr) % PAGE_SIZE)
+			+ skb->len) >> PAGE_SHIFT);
+	if ((elements_needed + elems) > QETH_MAX_BUFFER_ELEMENTS(card)) {
+		PRINT_ERR("Invalid size of IP packet "
+			"(Number=%d / Length=%d). Discarded.\n",
+			(elements_needed+elems), skb->len);
+		return 0;
+	}
+	return elements_needed;
+}
+EXPORT_SYMBOL_GPL(qeth_get_elements_no);
+
+static void __qeth_fill_buffer(struct sk_buff *skb, struct qdio_buffer *buffer,
+		int is_tso, int *next_element_to_fill)
+{
+	int length = skb->len;
+	int length_here;
+	int element;
+	char *data;
+	int first_lap ;
+
+	element = *next_element_to_fill;
+	data = skb->data;
+	first_lap = (is_tso == 0 ? 1 : 0);
+
+	while (length > 0) {
+		/* length_here is the remaining amount of data in this page */
+		length_here = PAGE_SIZE - ((unsigned long) data % PAGE_SIZE);
+		if (length < length_here)
+			length_here = length;
+
+		buffer->element[element].addr = data;
+		buffer->element[element].length = length_here;
+		length -= length_here;
+		if (!length) {
+			if (first_lap)
+				buffer->element[element].flags = 0;
+			else
+				buffer->element[element].flags =
+				    SBAL_FLAGS_LAST_FRAG;
+		} else {
+			if (first_lap)
+				buffer->element[element].flags =
+				    SBAL_FLAGS_FIRST_FRAG;
+			else
+				buffer->element[element].flags =
+				    SBAL_FLAGS_MIDDLE_FRAG;
+		}
+		data += length_here;
+		element++;
+		first_lap = 0;
+	}
+	*next_element_to_fill = element;
+}
+
+static int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
+		struct qeth_qdio_out_buffer *buf, struct sk_buff *skb)
+{
+	struct qdio_buffer *buffer;
+	struct qeth_hdr_tso *hdr;
+	int flush_cnt = 0, hdr_len, large_send = 0;
+
+	QETH_DBF_TEXT(trace, 6, "qdfillbf");
+
+	buffer = buf->buffer;
+	atomic_inc(&skb->users);
+	skb_queue_tail(&buf->skb_list, skb);
+
+	hdr  = (struct qeth_hdr_tso *) skb->data;
+	/*check first on TSO ....*/
+	if (hdr->hdr.hdr.l3.id == QETH_HEADER_TYPE_TSO) {
+		int element = buf->next_element_to_fill;
+
+		hdr_len = sizeof(struct qeth_hdr_tso) + hdr->ext.dg_hdr_len;
+		/*fill first buffer entry only with header information */
+		buffer->element[element].addr = skb->data;
+		buffer->element[element].length = hdr_len;
+		buffer->element[element].flags = SBAL_FLAGS_FIRST_FRAG;
+		buf->next_element_to_fill++;
+		skb->data += hdr_len;
+		skb->len  -= hdr_len;
+		large_send = 1;
+	}
+	if (skb_shinfo(skb)->nr_frags == 0)
+		__qeth_fill_buffer(skb, buffer, large_send,
+				   (int *)&buf->next_element_to_fill);
+	else
+		__qeth_fill_buffer_frag(skb, buffer, large_send,
+					(int *)&buf->next_element_to_fill);
+
+	if (!queue->do_pack) {
+		QETH_DBF_TEXT(trace, 6, "fillbfnp");
+		/* set state to PRIMED -> will be flushed */
+		atomic_set(&buf->state, QETH_QDIO_BUF_PRIMED);
+		flush_cnt = 1;
+	} else {
+		QETH_DBF_TEXT(trace, 6, "fillbfpa");
+		if (queue->card->options.performance_stats)
+			queue->card->perf_stats.skbs_sent_pack++;
+		if (buf->next_element_to_fill >=
+				QETH_MAX_BUFFER_ELEMENTS(queue->card)) {
+			/*
+			 * packed buffer if full -> set state PRIMED
+			 * -> will be flushed
+			 */
+			atomic_set(&buf->state, QETH_QDIO_BUF_PRIMED);
+			flush_cnt = 1;
+		}
+	}
+	return flush_cnt;
+}
+
+int qeth_do_send_packet_fast(struct qeth_card *card,
+		struct qeth_qdio_out_q *queue, struct sk_buff *skb,
+		struct qeth_hdr *hdr, int elements_needed,
+		struct qeth_eddp_context *ctx)
+{
+	struct qeth_qdio_out_buffer *buffer;
+	int buffers_needed = 0;
+	int flush_cnt = 0;
+	int index;
+
+	QETH_DBF_TEXT(trace, 6, "dosndpfa");
+
+	/* spin until we get the queue ... */
+	while (atomic_cmpxchg(&queue->state, QETH_OUT_Q_UNLOCKED,
+			      QETH_OUT_Q_LOCKED) != QETH_OUT_Q_UNLOCKED);
+	/* ... now we've got the queue */
+	index = queue->next_buf_to_fill;
+	buffer = &queue->bufs[queue->next_buf_to_fill];
+	/*
+	 * check if buffer is empty to make sure that we do not 'overtake'
+	 * ourselves and try to fill a buffer that is already primed
+	 */
+	if (atomic_read(&buffer->state) != QETH_QDIO_BUF_EMPTY)
+		goto out;
+	if (ctx == NULL)
+		queue->next_buf_to_fill = (queue->next_buf_to_fill + 1) %
+					  QDIO_MAX_BUFFERS_PER_Q;
+	else {
+		buffers_needed = qeth_eddp_check_buffers_for_context(queue,
+									ctx);
+		if (buffers_needed < 0)
+			goto out;
+		queue->next_buf_to_fill =
+			(queue->next_buf_to_fill + buffers_needed) %
+			QDIO_MAX_BUFFERS_PER_Q;
+	}
+	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
+	if (ctx == NULL) {
+		qeth_fill_buffer(queue, buffer, skb);
+		qeth_flush_buffers(queue, 0, index, 1);
+	} else {
+		flush_cnt = qeth_eddp_fill_buffer(queue, ctx, index);
+		WARN_ON(buffers_needed != flush_cnt);
+		qeth_flush_buffers(queue, 0, index, flush_cnt);
+	}
+	return 0;
+out:
+	atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
+	return -EBUSY;
+}
+EXPORT_SYMBOL_GPL(qeth_do_send_packet_fast);
+
+int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
+		struct sk_buff *skb, struct qeth_hdr *hdr,
+		int elements_needed, struct qeth_eddp_context *ctx)
+{
+	struct qeth_qdio_out_buffer *buffer;
+	int start_index;
+	int flush_count = 0;
+	int do_pack = 0;
+	int tmp;
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 6, "dosndpkt");
+
+	/* spin until we get the queue ... */
+	while (atomic_cmpxchg(&queue->state, QETH_OUT_Q_UNLOCKED,
+			      QETH_OUT_Q_LOCKED) != QETH_OUT_Q_UNLOCKED);
+	start_index = queue->next_buf_to_fill;
+	buffer = &queue->bufs[queue->next_buf_to_fill];
+	/*
+	 * check if buffer is empty to make sure that we do not 'overtake'
+	 * ourselves and try to fill a buffer that is already primed
+	 */
+	if (atomic_read(&buffer->state) != QETH_QDIO_BUF_EMPTY) {
+		atomic_set(&queue->state, QETH_OUT_Q_UNLOCKED);
+		return -EBUSY;
+	}
+	/* check if we need to switch packing state of this queue */
+	qeth_switch_to_packing_if_needed(queue);
+	if (queue->do_pack) {
+		do_pack = 1;
+		if (ctx == NULL) {
+			/* does packet fit in current buffer? */
+			if ((QETH_MAX_BUFFER_ELEMENTS(card) -
+			    buffer->next_element_to_fill) < elements_needed) {
+				/* ... no -> set state PRIMED */
+				atomic_set(&buffer->state,
+					QETH_QDIO_BUF_PRIMED);
+				flush_count++;
+				queue->next_buf_to_fill =
+					(queue->next_buf_to_fill + 1) %
+					QDIO_MAX_BUFFERS_PER_Q;
+				buffer = &queue->bufs[queue->next_buf_to_fill];
+				/* we did a step forward, so check buffer state
+				 * again */
+				if (atomic_read(&buffer->state) !=
+						QETH_QDIO_BUF_EMPTY){
+					qeth_flush_buffers(queue, 0,
+						start_index, flush_count);
+					atomic_set(&queue->state,
+						QETH_OUT_Q_UNLOCKED);
+					return -EBUSY;
+				}
+			}
+		} else {
+			/* check if we have enough elements (including following
+			 * free buffers) to handle eddp context */
+			if (qeth_eddp_check_buffers_for_context(queue, ctx)
+				< 0) {
+				if (net_ratelimit())
+					PRINT_WARN("eddp tx_dropped 1\n");
+				rc = -EBUSY;
+				goto out;
+			}
+		}
+	}
+	if (ctx == NULL)
+		tmp = qeth_fill_buffer(queue, buffer, skb);
+	else {
+		tmp = qeth_eddp_fill_buffer(queue, ctx,
+						queue->next_buf_to_fill);
+		if (tmp < 0) {
+			PRINT_ERR("eddp tx_dropped 2\n");
+			rc = -EBUSY;
+			goto out;
+		}
+	}
+	queue->next_buf_to_fill = (queue->next_buf_to_fill + tmp) %
+				  QDIO_MAX_BUFFERS_PER_Q;
+	flush_count += tmp;
+out:
+	if (flush_count)
+		qeth_flush_buffers(queue, 0, start_index, flush_count);
+	else if (!atomic_read(&queue->set_pci_flags_count))
+		atomic_xchg(&queue->state, QETH_OUT_Q_LOCKED_FLUSH);
+	/*
+	 * queue->state will go from LOCKED -> UNLOCKED or from
+	 * LOCKED_FLUSH -> LOCKED if output_handler wanted to 'notify' us
+	 * (switch packing state or flush buffer to get another pci flag out).
+	 * In that case we will enter this loop
+	 */
+	while (atomic_dec_return(&queue->state)) {
+		flush_count = 0;
+		start_index = queue->next_buf_to_fill;
+		/* check if we can go back to non-packing state */
+		flush_count += qeth_switch_to_nonpacking_if_needed(queue);
+		/*
+		 * check if we need to flush a packing buffer to get a pci
+		 * flag out on the queue
+		 */
+		if (!flush_count && !atomic_read(&queue->set_pci_flags_count))
+			flush_count += qeth_flush_buffers_on_no_pci(queue);
+		if (flush_count)
+			qeth_flush_buffers(queue, 0, start_index, flush_count);
+	}
+	/* at this point the queue is UNLOCKED again */
+	if (queue->card->options.performance_stats && do_pack)
+		queue->card->perf_stats.bufs_sent_pack += flush_count;
+
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_do_send_packet);
+
+static int qeth_setadp_promisc_mode_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+	struct qeth_ipacmd_setadpparms *setparms;
+
+	QETH_DBF_TEXT(trace, 4, "prmadpcb");
+
+	cmd = (struct qeth_ipa_cmd *) data;
+	setparms = &(cmd->data.setadapterparms);
+
+	qeth_default_setadapterparms_cb(card, reply, (unsigned long)cmd);
+	if (cmd->hdr.return_code) {
+		QETH_DBF_TEXT_(trace, 4, "prmrc%2.2x", cmd->hdr.return_code);
+		setparms->data.mode = SET_PROMISC_MODE_OFF;
+	}
+	card->info.promisc_mode = setparms->data.mode;
+	return 0;
+}
+
+void qeth_setadp_promisc_mode(struct qeth_card *card)
+{
+	enum qeth_ipa_promisc_modes mode;
+	struct net_device *dev = card->dev;
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 4, "setprom");
+
+	if (((dev->flags & IFF_PROMISC) &&
+	     (card->info.promisc_mode == SET_PROMISC_MODE_ON)) ||
+	    (!(dev->flags & IFF_PROMISC) &&
+	     (card->info.promisc_mode == SET_PROMISC_MODE_OFF)))
+		return;
+	mode = SET_PROMISC_MODE_OFF;
+	if (dev->flags & IFF_PROMISC)
+		mode = SET_PROMISC_MODE_ON;
+	QETH_DBF_TEXT_(trace, 4, "mode:%x", mode);
+
+	iob = qeth_get_adapter_cmd(card, IPA_SETADP_SET_PROMISC_MODE,
+			sizeof(struct qeth_ipacmd_setadpparms));
+	cmd = (struct qeth_ipa_cmd *)(iob->data + IPA_PDU_HEADER_SIZE);
+	cmd->data.setadapterparms.data.mode = mode;
+	qeth_send_ipa_cmd(card, iob, qeth_setadp_promisc_mode_cb, NULL);
+}
+EXPORT_SYMBOL_GPL(qeth_setadp_promisc_mode);
+
+int qeth_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct qeth_card *card;
+	char dbf_text[15];
+
+	card = netdev_priv(dev);
+
+	QETH_DBF_TEXT(trace, 4, "chgmtu");
+	sprintf(dbf_text, "%8x", new_mtu);
+	QETH_DBF_TEXT(trace, 4, dbf_text);
+
+	if (new_mtu < 64)
+		return -EINVAL;
+	if (new_mtu > 65535)
+		return -EINVAL;
+	if ((!qeth_is_supported(card, IPA_IP_FRAGMENTATION)) &&
+	    (!qeth_mtu_is_valid(card, new_mtu)))
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(qeth_change_mtu);
+
+struct net_device_stats *qeth_get_stats(struct net_device *dev)
+{
+	struct qeth_card *card;
+
+	card = netdev_priv(dev);
+
+	QETH_DBF_TEXT(trace, 5, "getstat");
+
+	return &card->stats;
+}
+EXPORT_SYMBOL_GPL(qeth_get_stats);
+
+static int qeth_setadpparms_change_macaddr_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 4, "chgmaccb");
+
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (!card->options.layer2 ||
+	    !(card->info.mac_bits & QETH_LAYER2_MAC_READ)) {
+		memcpy(card->dev->dev_addr,
+		       &cmd->data.setadapterparms.data.change_addr.addr,
+		       OSA_ADDR_LEN);
+		card->info.mac_bits |= QETH_LAYER2_MAC_READ;
+	}
+	qeth_default_setadapterparms_cb(card, reply, (unsigned long) cmd);
+	return 0;
+}
+
+int qeth_setadpparms_change_macaddr(struct qeth_card *card)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 4, "chgmac");
+
+	iob = qeth_get_adapter_cmd(card, IPA_SETADP_ALTER_MAC_ADDRESS,
+				   sizeof(struct qeth_ipacmd_setadpparms));
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	cmd->data.setadapterparms.data.change_addr.cmd = CHANGE_ADDR_READ_MAC;
+	cmd->data.setadapterparms.data.change_addr.addr_size = OSA_ADDR_LEN;
+	memcpy(&cmd->data.setadapterparms.data.change_addr.addr,
+	       card->dev->dev_addr, OSA_ADDR_LEN);
+	rc = qeth_send_ipa_cmd(card, iob, qeth_setadpparms_change_macaddr_cb,
+			       NULL);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_setadpparms_change_macaddr);
+
+void qeth_tx_timeout(struct net_device *dev)
+{
+	struct qeth_card *card;
+
+	card = netdev_priv(dev);
+	card->stats.tx_errors++;
+	qeth_schedule_recovery(card);
+}
+EXPORT_SYMBOL_GPL(qeth_tx_timeout);
+
+int qeth_mdio_read(struct net_device *dev, int phy_id, int regnum)
+{
+	struct qeth_card *card = netdev_priv(dev);
+	int rc = 0;
+
+	switch (regnum) {
+	case MII_BMCR: /* Basic mode control register */
+		rc = BMCR_FULLDPLX;
+		if ((card->info.link_type != QETH_LINK_TYPE_GBIT_ETH) &&
+		    (card->info.link_type != QETH_LINK_TYPE_OSN) &&
+		    (card->info.link_type != QETH_LINK_TYPE_10GBIT_ETH))
+			rc |= BMCR_SPEED100;
+		break;
+	case MII_BMSR: /* Basic mode status register */
+		rc = BMSR_ERCAP | BMSR_ANEGCOMPLETE | BMSR_LSTATUS |
+		     BMSR_10HALF | BMSR_10FULL | BMSR_100HALF | BMSR_100FULL |
+		     BMSR_100BASE4;
+		break;
+	case MII_PHYSID1: /* PHYS ID 1 */
+		rc = (dev->dev_addr[0] << 16) | (dev->dev_addr[1] << 8) |
+		     dev->dev_addr[2];
+		rc = (rc >> 5) & 0xFFFF;
+		break;
+	case MII_PHYSID2: /* PHYS ID 2 */
+		rc = (dev->dev_addr[2] << 10) & 0xFFFF;
+		break;
+	case MII_ADVERTISE: /* Advertisement control reg */
+		rc = ADVERTISE_ALL;
+		break;
+	case MII_LPA: /* Link partner ability reg */
+		rc = LPA_10HALF | LPA_10FULL | LPA_100HALF | LPA_100FULL |
+		     LPA_100BASE4 | LPA_LPACK;
+		break;
+	case MII_EXPANSION: /* Expansion register */
+		break;
+	case MII_DCOUNTER: /* disconnect counter */
+		break;
+	case MII_FCSCOUNTER: /* false carrier counter */
+		break;
+	case MII_NWAYTEST: /* N-way auto-neg test register */
+		break;
+	case MII_RERRCOUNTER: /* rx error counter */
+		rc = card->stats.rx_errors;
+		break;
+	case MII_SREVISION: /* silicon revision */
+		break;
+	case MII_RESV1: /* reserved 1 */
+		break;
+	case MII_LBRERROR: /* loopback, rx, bypass error */
+		break;
+	case MII_PHYADDR: /* physical address */
+		break;
+	case MII_RESV2: /* reserved 2 */
+		break;
+	case MII_TPISTATUS: /* TPI status for 10mbps */
+		break;
+	case MII_NCONFIG: /* network interface config */
+		break;
+	default:
+		break;
+	}
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_mdio_read);
+
+static int qeth_send_ipa_snmp_cmd(struct qeth_card *card,
+		struct qeth_cmd_buffer *iob, int len,
+		int (*reply_cb)(struct qeth_card *, struct qeth_reply *,
+			unsigned long),
+		void *reply_param)
+{
+	u16 s1, s2;
+
+	QETH_DBF_TEXT(trace, 4, "sendsnmp");
+
+	memcpy(iob->data, IPA_PDU_HEADER, IPA_PDU_HEADER_SIZE);
+	memcpy(QETH_IPA_CMD_DEST_ADDR(iob->data),
+	       &card->token.ulp_connection_r, QETH_MPC_TOKEN_LENGTH);
+	/* adjust PDU length fields in IPA_PDU_HEADER */
+	s1 = (u32) IPA_PDU_HEADER_SIZE + len;
+	s2 = (u32) len;
+	memcpy(QETH_IPA_PDU_LEN_TOTAL(iob->data), &s1, 2);
+	memcpy(QETH_IPA_PDU_LEN_PDU1(iob->data), &s2, 2);
+	memcpy(QETH_IPA_PDU_LEN_PDU2(iob->data), &s2, 2);
+	memcpy(QETH_IPA_PDU_LEN_PDU3(iob->data), &s2, 2);
+	return qeth_send_control_data(card, IPA_PDU_HEADER_SIZE + len, iob,
+				      reply_cb, reply_param);
+}
+
+static int qeth_snmp_command_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long sdata)
+{
+	struct qeth_ipa_cmd *cmd;
+	struct qeth_arp_query_info *qinfo;
+	struct qeth_snmp_cmd *snmp;
+	unsigned char *data;
+	__u16 data_len;
+
+	QETH_DBF_TEXT(trace, 3, "snpcmdcb");
+
+	cmd = (struct qeth_ipa_cmd *) sdata;
+	data = (unsigned char *)((char *)cmd - reply->offset);
+	qinfo = (struct qeth_arp_query_info *) reply->param;
+	snmp = &cmd->data.setadapterparms.data.snmp;
+
+	if (cmd->hdr.return_code) {
+		QETH_DBF_TEXT_(trace, 4, "scer1%i", cmd->hdr.return_code);
+		return 0;
+	}
+	if (cmd->data.setadapterparms.hdr.return_code) {
+		cmd->hdr.return_code =
+			cmd->data.setadapterparms.hdr.return_code;
+		QETH_DBF_TEXT_(trace, 4, "scer2%i", cmd->hdr.return_code);
+		return 0;
+	}
+	data_len = *((__u16 *)QETH_IPA_PDU_LEN_PDU1(data));
+	if (cmd->data.setadapterparms.hdr.seq_no == 1)
+		data_len -= (__u16)((char *)&snmp->data - (char *)cmd);
+	else
+		data_len -= (__u16)((char *)&snmp->request - (char *)cmd);
+
+	/* check if there is enough room in userspace */
+	if ((qinfo->udata_len - qinfo->udata_offset) < data_len) {
+		QETH_DBF_TEXT_(trace, 4, "scer3%i", -ENOMEM);
+		cmd->hdr.return_code = -ENOMEM;
+		return 0;
+	}
+	QETH_DBF_TEXT_(trace, 4, "snore%i",
+		       cmd->data.setadapterparms.hdr.used_total);
+	QETH_DBF_TEXT_(trace, 4, "sseqn%i",
+		cmd->data.setadapterparms.hdr.seq_no);
+	/*copy entries to user buffer*/
+	if (cmd->data.setadapterparms.hdr.seq_no == 1) {
+		memcpy(qinfo->udata + qinfo->udata_offset,
+		       (char *)snmp,
+		       data_len + offsetof(struct qeth_snmp_cmd, data));
+		qinfo->udata_offset += offsetof(struct qeth_snmp_cmd, data);
+	} else {
+		memcpy(qinfo->udata + qinfo->udata_offset,
+		       (char *)&snmp->request, data_len);
+	}
+	qinfo->udata_offset += data_len;
+	/* check if all replies received ... */
+		QETH_DBF_TEXT_(trace, 4, "srtot%i",
+			       cmd->data.setadapterparms.hdr.used_total);
+		QETH_DBF_TEXT_(trace, 4, "srseq%i",
+			       cmd->data.setadapterparms.hdr.seq_no);
+	if (cmd->data.setadapterparms.hdr.seq_no <
+	    cmd->data.setadapterparms.hdr.used_total)
+		return 1;
+	return 0;
+}
+
+int qeth_snmp_command(struct qeth_card *card, char __user *udata)
+{
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+	struct qeth_snmp_ureq *ureq;
+	int req_len;
+	struct qeth_arp_query_info qinfo = {0, };
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 3, "snmpcmd");
+
+	if (card->info.guestlan)
+		return -EOPNOTSUPP;
+
+	if ((!qeth_adp_supported(card, IPA_SETADP_SET_SNMP_CONTROL)) &&
+	    (!card->options.layer2)) {
+		PRINT_WARN("SNMP Query MIBS not supported "
+			   "on %s!\n", QETH_CARD_IFNAME(card));
+		return -EOPNOTSUPP;
+	}
+	/* skip 4 bytes (data_len struct member) to get req_len */
+	if (copy_from_user(&req_len, udata + sizeof(int), sizeof(int)))
+		return -EFAULT;
+	ureq = kmalloc(req_len+sizeof(struct qeth_snmp_ureq_hdr), GFP_KERNEL);
+	if (!ureq) {
+		QETH_DBF_TEXT(trace, 2, "snmpnome");
+		return -ENOMEM;
+	}
+	if (copy_from_user(ureq, udata,
+			req_len + sizeof(struct qeth_snmp_ureq_hdr))) {
+		kfree(ureq);
+		return -EFAULT;
+	}
+	qinfo.udata_len = ureq->hdr.data_len;
+	qinfo.udata = kzalloc(qinfo.udata_len, GFP_KERNEL);
+	if (!qinfo.udata) {
+		kfree(ureq);
+		return -ENOMEM;
+	}
+	qinfo.udata_offset = sizeof(struct qeth_snmp_ureq_hdr);
+
+	iob = qeth_get_adapter_cmd(card, IPA_SETADP_SET_SNMP_CONTROL,
+				   QETH_SNMP_SETADP_CMDLENGTH + req_len);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	memcpy(&cmd->data.setadapterparms.data.snmp, &ureq->cmd, req_len);
+	rc = qeth_send_ipa_snmp_cmd(card, iob, QETH_SETADP_BASE_LEN + req_len,
+				    qeth_snmp_command_cb, (void *)&qinfo);
+	if (rc)
+		PRINT_WARN("SNMP command failed on %s: (0x%x)\n",
+			   QETH_CARD_IFNAME(card), rc);
+	else {
+		if (copy_to_user(udata, qinfo.udata, qinfo.udata_len))
+			rc = -EFAULT;
+	}
+
+	kfree(ureq);
+	kfree(qinfo.udata);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_snmp_command);
+
+static inline int qeth_get_qdio_q_format(struct qeth_card *card)
+{
+	switch (card->info.type) {
+	case QETH_CARD_TYPE_IQD:
+		return 2;
+	default:
+		return 0;
+	}
+}
+
+static int qeth_qdio_establish(struct qeth_card *card)
+{
+	struct qdio_initialize init_data;
+	char *qib_param_field;
+	struct qdio_buffer **in_sbal_ptrs;
+	struct qdio_buffer **out_sbal_ptrs;
+	int i, j, k;
+	int rc = 0;
+
+	QETH_DBF_TEXT(setup, 2, "qdioest");
+
+	qib_param_field = kzalloc(QDIO_MAX_BUFFERS_PER_Q * sizeof(char),
+			      GFP_KERNEL);
+	if (!qib_param_field)
+		return -ENOMEM;
+
+	qeth_create_qib_param_field(card, qib_param_field);
+	qeth_create_qib_param_field_blkt(card, qib_param_field);
+
+	in_sbal_ptrs = kmalloc(QDIO_MAX_BUFFERS_PER_Q * sizeof(void *),
+			       GFP_KERNEL);
+	if (!in_sbal_ptrs) {
+		kfree(qib_param_field);
+		return -ENOMEM;
+	}
+	for (i = 0; i < QDIO_MAX_BUFFERS_PER_Q; ++i)
+		in_sbal_ptrs[i] = (struct qdio_buffer *)
+			virt_to_phys(card->qdio.in_q->bufs[i].buffer);
+
+	out_sbal_ptrs =
+		kmalloc(card->qdio.no_out_queues * QDIO_MAX_BUFFERS_PER_Q *
+			sizeof(void *), GFP_KERNEL);
+	if (!out_sbal_ptrs) {
+		kfree(in_sbal_ptrs);
+		kfree(qib_param_field);
+		return -ENOMEM;
+	}
+	for (i = 0, k = 0; i < card->qdio.no_out_queues; ++i)
+		for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j, ++k) {
+			out_sbal_ptrs[k] = (struct qdio_buffer *)virt_to_phys(
+				card->qdio.out_qs[i]->bufs[j].buffer);
+		}
+
+	memset(&init_data, 0, sizeof(struct qdio_initialize));
+	init_data.cdev                   = CARD_DDEV(card);
+	init_data.q_format               = qeth_get_qdio_q_format(card);
+	init_data.qib_param_field_format = 0;
+	init_data.qib_param_field        = qib_param_field;
+	init_data.min_input_threshold    = QETH_MIN_INPUT_THRESHOLD;
+	init_data.max_input_threshold    = QETH_MAX_INPUT_THRESHOLD;
+	init_data.min_output_threshold   = QETH_MIN_OUTPUT_THRESHOLD;
+	init_data.max_output_threshold   = QETH_MAX_OUTPUT_THRESHOLD;
+	init_data.no_input_qs            = 1;
+	init_data.no_output_qs           = card->qdio.no_out_queues;
+	init_data.input_handler          = card->discipline.input_handler;
+	init_data.output_handler         = card->discipline.output_handler;
+	init_data.int_parm               = (unsigned long) card;
+	init_data.flags                  = QDIO_INBOUND_0COPY_SBALS |
+					   QDIO_OUTBOUND_0COPY_SBALS |
+					   QDIO_USE_OUTBOUND_PCIS;
+	init_data.input_sbal_addr_array  = (void **) in_sbal_ptrs;
+	init_data.output_sbal_addr_array = (void **) out_sbal_ptrs;
+
+	if (atomic_cmpxchg(&card->qdio.state, QETH_QDIO_ALLOCATED,
+		QETH_QDIO_ESTABLISHED) == QETH_QDIO_ALLOCATED) {
+		rc = qdio_initialize(&init_data);
+		if (rc)
+			atomic_set(&card->qdio.state, QETH_QDIO_ALLOCATED);
+	}
+	kfree(out_sbal_ptrs);
+	kfree(in_sbal_ptrs);
+	kfree(qib_param_field);
+	return rc;
+}
+
+static void qeth_core_free_card(struct qeth_card *card)
+{
+
+	QETH_DBF_TEXT(setup, 2, "freecrd");
+	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+	qeth_clean_channel(&card->read);
+	qeth_clean_channel(&card->write);
+	if (card->dev)
+		free_netdev(card->dev);
+	kfree(card->ip_tbd_list);
+	qeth_free_qdio_buffers(card);
+	kfree(card);
+}
+
+static struct ccw_device_id qeth_ids[] = {
+	{CCW_DEVICE(0x1731, 0x01), .driver_info = QETH_CARD_TYPE_OSAE},
+	{CCW_DEVICE(0x1731, 0x05), .driver_info = QETH_CARD_TYPE_IQD},
+	{CCW_DEVICE(0x1731, 0x06), .driver_info = QETH_CARD_TYPE_OSN},
+	{},
+};
+MODULE_DEVICE_TABLE(ccw, qeth_ids);
+
+static struct ccw_driver qeth_ccw_driver = {
+	.name = "qeth",
+	.ids = qeth_ids,
+	.probe = ccwgroup_probe_ccwdev,
+	.remove = ccwgroup_remove_ccwdev,
+};
+
+static int qeth_core_driver_group(const char *buf, struct device *root_dev,
+				unsigned long driver_id)
+{
+	const char *start, *end;
+	char bus_ids[3][BUS_ID_SIZE], *argv[3];
+	int i;
+
+	start = buf;
+	for (i = 0; i < 3; i++) {
+		static const char delim[] = { ',', ',', '\n' };
+		int len;
+
+		end = strchr(start, delim[i]);
+		if (!end)
+			return -EINVAL;
+		len = min_t(ptrdiff_t, BUS_ID_SIZE, end - start);
+		strncpy(bus_ids[i], start, len);
+		bus_ids[i][len] = '\0';
+		start = end + 1;
+		argv[i] = bus_ids[i];
+	}
+
+	return (ccwgroup_create(root_dev, driver_id,
+				&qeth_ccw_driver, 3, argv));
+}
+
+int qeth_core_hardsetup_card(struct qeth_card *card)
+{
+	int retries = 3;
+	int mpno;
+	int rc;
+
+	QETH_DBF_TEXT(setup, 2, "hrdsetup");
+	atomic_set(&card->force_alloc_skb, 0);
+retry:
+	if (retries < 3) {
+		PRINT_WARN("Retrying to do IDX activates.\n");
+		ccw_device_set_offline(CARD_DDEV(card));
+		ccw_device_set_offline(CARD_WDEV(card));
+		ccw_device_set_offline(CARD_RDEV(card));
+		ccw_device_set_online(CARD_RDEV(card));
+		ccw_device_set_online(CARD_WDEV(card));
+		ccw_device_set_online(CARD_DDEV(card));
+	}
+	rc = qeth_qdio_clear_card(card, card->info.type != QETH_CARD_TYPE_IQD);
+	if (rc == -ERESTARTSYS) {
+		QETH_DBF_TEXT(setup, 2, "break1");
+		return rc;
+	} else if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		if (--retries < 0)
+			goto out;
+		else
+			goto retry;
+	}
+
+	rc = qeth_get_unitaddr(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		return rc;
+	}
+
+	mpno = QETH_MAX_PORTNO;
+	if (card->info.portno > mpno) {
+		PRINT_ERR("Device %s does not offer port number %d \n.",
+			CARD_BUS_ID(card), card->info.portno);
+		rc = -ENODEV;
+		goto out;
+	}
+	qeth_init_tokens(card);
+	qeth_init_func_level(card);
+	rc = qeth_idx_activate_channel(&card->read, qeth_idx_read_cb);
+	if (rc == -ERESTARTSYS) {
+		QETH_DBF_TEXT(setup, 2, "break2");
+		return rc;
+	} else if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "3err%d", rc);
+		if (--retries < 0)
+			goto out;
+		else
+			goto retry;
+	}
+	rc = qeth_idx_activate_channel(&card->write, qeth_idx_write_cb);
+	if (rc == -ERESTARTSYS) {
+		QETH_DBF_TEXT(setup, 2, "break3");
+		return rc;
+	} else if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "4err%d", rc);
+		if (--retries < 0)
+			goto out;
+		else
+			goto retry;
+	}
+	rc = qeth_mpc_initialize(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "5err%d", rc);
+		goto out;
+	}
+	return 0;
+out:
+	PRINT_ERR("Initialization in hardsetup failed! rc=%d\n", rc);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_core_hardsetup_card);
+
+static inline int qeth_create_skb_frag(struct qdio_buffer_element *element,
+		struct sk_buff **pskb, int offset, int *pfrag, int data_len)
+{
+	struct page *page = virt_to_page(element->addr);
+	if (*pskb == NULL) {
+		/* the upper protocol layers assume that there is data in the
+		 * skb itself. Copy a small amount (64 bytes) to make them
+		 * happy. */
+		*pskb = dev_alloc_skb(64 + ETH_HLEN);
+		if (!(*pskb))
+			return -ENOMEM;
+		skb_reserve(*pskb, ETH_HLEN);
+		if (data_len <= 64) {
+			memcpy(skb_put(*pskb, data_len), element->addr + offset,
+				data_len);
+		} else {
+			get_page(page);
+			memcpy(skb_put(*pskb, 64), element->addr + offset, 64);
+			skb_fill_page_desc(*pskb, *pfrag, page, offset + 64,
+				data_len - 64);
+			(*pskb)->data_len += data_len - 64;
+			(*pskb)->len      += data_len - 64;
+			(*pskb)->truesize += data_len - 64;
+			(*pfrag)++;
+		}
+	} else {
+		get_page(page);
+		skb_fill_page_desc(*pskb, *pfrag, page, offset, data_len);
+		(*pskb)->data_len += data_len;
+		(*pskb)->len      += data_len;
+		(*pskb)->truesize += data_len;
+		(*pfrag)++;
+	}
+	return 0;
+}
+
+struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
+		struct qdio_buffer *buffer,
+		struct qdio_buffer_element **__element, int *__offset,
+		struct qeth_hdr **hdr)
+{
+	struct qdio_buffer_element *element = *__element;
+	int offset = *__offset;
+	struct sk_buff *skb = NULL;
+	int skb_len;
+	void *data_ptr;
+	int data_len;
+	int headroom = 0;
+	int use_rx_sg = 0;
+	int frag = 0;
+
+	QETH_DBF_TEXT(trace, 6, "nextskb");
+	/* qeth_hdr must not cross element boundaries */
+	if (element->length < offset + sizeof(struct qeth_hdr)) {
+		if (qeth_is_last_sbale(element))
+			return NULL;
+		element++;
+		offset = 0;
+		if (element->length < sizeof(struct qeth_hdr))
+			return NULL;
+	}
+	*hdr = element->addr + offset;
+
+	offset += sizeof(struct qeth_hdr);
+	if (card->options.layer2) {
+		if (card->info.type == QETH_CARD_TYPE_OSN) {
+			skb_len = (*hdr)->hdr.osn.pdu_length;
+			headroom = sizeof(struct qeth_hdr);
+		} else {
+			skb_len = (*hdr)->hdr.l2.pkt_length;
+		}
+	} else {
+		skb_len = (*hdr)->hdr.l3.length;
+		headroom = max((int)ETH_HLEN, (int)TR_HLEN);
+	}
+
+	if (!skb_len)
+		return NULL;
+
+	if ((skb_len >= card->options.rx_sg_cb) &&
+	    (!(card->info.type == QETH_CARD_TYPE_OSN)) &&
+	    (!atomic_read(&card->force_alloc_skb))) {
+		use_rx_sg = 1;
+	} else {
+		skb = dev_alloc_skb(skb_len + headroom);
+		if (!skb)
+			goto no_mem;
+		if (headroom)
+			skb_reserve(skb, headroom);
+	}
+
+	data_ptr = element->addr + offset;
+	while (skb_len) {
+		data_len = min(skb_len, (int)(element->length - offset));
+		if (data_len) {
+			if (use_rx_sg) {
+				if (qeth_create_skb_frag(element, &skb, offset,
+				    &frag, data_len))
+					goto no_mem;
+			} else {
+				memcpy(skb_put(skb, data_len), data_ptr,
+					data_len);
+			}
+		}
+		skb_len -= data_len;
+		if (skb_len) {
+			if (qeth_is_last_sbale(element)) {
+				QETH_DBF_TEXT(trace, 4, "unexeob");
+				QETH_DBF_TEXT_(trace, 4, "%s",
+					CARD_BUS_ID(card));
+				QETH_DBF_TEXT(qerr, 2, "unexeob");
+				QETH_DBF_TEXT_(qerr, 2, "%s",
+					CARD_BUS_ID(card));
+				QETH_DBF_HEX(misc, 4, buffer, sizeof(*buffer));
+				dev_kfree_skb_any(skb);
+				card->stats.rx_errors++;
+				return NULL;
+			}
+			element++;
+			offset = 0;
+			data_ptr = element->addr;
+		} else {
+			offset += data_len;
+		}
+	}
+	*__element = element;
+	*__offset = offset;
+	if (use_rx_sg && card->options.performance_stats) {
+		card->perf_stats.sg_skbs_rx++;
+		card->perf_stats.sg_frags_rx += skb_shinfo(skb)->nr_frags;
+	}
+	return skb;
+no_mem:
+	if (net_ratelimit()) {
+		PRINT_WARN("No memory for packet received on %s.\n",
+			   QETH_CARD_IFNAME(card));
+		QETH_DBF_TEXT(trace, 2, "noskbmem");
+		QETH_DBF_TEXT_(trace, 2, "%s", CARD_BUS_ID(card));
+	}
+	card->stats.rx_dropped++;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(qeth_core_get_next_skb);
+
+static void qeth_unregister_dbf_views(void)
+{
+	if (qeth_dbf_setup)
+		debug_unregister(qeth_dbf_setup);
+	if (qeth_dbf_qerr)
+		debug_unregister(qeth_dbf_qerr);
+	if (qeth_dbf_sense)
+		debug_unregister(qeth_dbf_sense);
+	if (qeth_dbf_misc)
+		debug_unregister(qeth_dbf_misc);
+	if (qeth_dbf_data)
+		debug_unregister(qeth_dbf_data);
+	if (qeth_dbf_control)
+		debug_unregister(qeth_dbf_control);
+	if (qeth_dbf_trace)
+		debug_unregister(qeth_dbf_trace);
+}
+
+static int qeth_register_dbf_views(void)
+{
+	qeth_dbf_setup = debug_register(QETH_DBF_SETUP_NAME,
+					QETH_DBF_SETUP_PAGES,
+					QETH_DBF_SETUP_NR_AREAS,
+					QETH_DBF_SETUP_LEN);
+	qeth_dbf_misc = debug_register(QETH_DBF_MISC_NAME,
+				       QETH_DBF_MISC_PAGES,
+				       QETH_DBF_MISC_NR_AREAS,
+				       QETH_DBF_MISC_LEN);
+	qeth_dbf_data = debug_register(QETH_DBF_DATA_NAME,
+				       QETH_DBF_DATA_PAGES,
+				       QETH_DBF_DATA_NR_AREAS,
+				       QETH_DBF_DATA_LEN);
+	qeth_dbf_control = debug_register(QETH_DBF_CONTROL_NAME,
+					  QETH_DBF_CONTROL_PAGES,
+					  QETH_DBF_CONTROL_NR_AREAS,
+					  QETH_DBF_CONTROL_LEN);
+	qeth_dbf_sense = debug_register(QETH_DBF_SENSE_NAME,
+					QETH_DBF_SENSE_PAGES,
+					QETH_DBF_SENSE_NR_AREAS,
+					QETH_DBF_SENSE_LEN);
+	qeth_dbf_qerr = debug_register(QETH_DBF_QERR_NAME,
+				       QETH_DBF_QERR_PAGES,
+				       QETH_DBF_QERR_NR_AREAS,
+				       QETH_DBF_QERR_LEN);
+	qeth_dbf_trace = debug_register(QETH_DBF_TRACE_NAME,
+					QETH_DBF_TRACE_PAGES,
+					QETH_DBF_TRACE_NR_AREAS,
+					QETH_DBF_TRACE_LEN);
+
+	if ((qeth_dbf_setup == NULL) || (qeth_dbf_misc == NULL)    ||
+	    (qeth_dbf_data == NULL)  || (qeth_dbf_control == NULL) ||
+	    (qeth_dbf_sense == NULL) || (qeth_dbf_qerr == NULL)    ||
+	    (qeth_dbf_trace == NULL)) {
+		qeth_unregister_dbf_views();
+		return -ENOMEM;
+	}
+	debug_register_view(qeth_dbf_setup, &debug_hex_ascii_view);
+	debug_set_level(qeth_dbf_setup, QETH_DBF_SETUP_LEVEL);
+
+	debug_register_view(qeth_dbf_misc, &debug_hex_ascii_view);
+	debug_set_level(qeth_dbf_misc, QETH_DBF_MISC_LEVEL);
+
+	debug_register_view(qeth_dbf_data, &debug_hex_ascii_view);
+	debug_set_level(qeth_dbf_data, QETH_DBF_DATA_LEVEL);
+
+	debug_register_view(qeth_dbf_control, &debug_hex_ascii_view);
+	debug_set_level(qeth_dbf_control, QETH_DBF_CONTROL_LEVEL);
+
+	debug_register_view(qeth_dbf_sense, &debug_hex_ascii_view);
+	debug_set_level(qeth_dbf_sense, QETH_DBF_SENSE_LEVEL);
+
+	debug_register_view(qeth_dbf_qerr, &debug_hex_ascii_view);
+	debug_set_level(qeth_dbf_qerr, QETH_DBF_QERR_LEVEL);
+
+	debug_register_view(qeth_dbf_trace, &debug_hex_ascii_view);
+	debug_set_level(qeth_dbf_trace, QETH_DBF_TRACE_LEVEL);
+
+	return 0;
+}
+
+int qeth_core_load_discipline(struct qeth_card *card,
+		enum qeth_discipline_id discipline)
+{
+	int rc = 0;
+	switch (discipline) {
+	case QETH_DISCIPLINE_LAYER3:
+		card->discipline.ccwgdriver = try_then_request_module(
+			symbol_get(qeth_l3_ccwgroup_driver),
+			"qeth_l3");
+		break;
+	case QETH_DISCIPLINE_LAYER2:
+		card->discipline.ccwgdriver = try_then_request_module(
+			symbol_get(qeth_l2_ccwgroup_driver),
+			"qeth_l2");
+		break;
+	}
+	if (!card->discipline.ccwgdriver) {
+		PRINT_ERR("Support for discipline %d not present\n",
+				discipline);
+		rc = -EINVAL;
+	}
+	return rc;
+}
+
+void qeth_core_free_discipline(struct qeth_card *card)
+{
+	if (card->options.layer2)
+		symbol_put(qeth_l2_ccwgroup_driver);
+	else
+		symbol_put(qeth_l3_ccwgroup_driver);
+	card->discipline.ccwgdriver = NULL;
+}
+
+static int qeth_core_probe_device(struct ccwgroup_device *gdev)
+{
+	struct qeth_card *card;
+	struct device *dev;
+	int rc;
+	unsigned long flags;
+
+	QETH_DBF_TEXT(setup, 2, "probedev");
+
+	dev = &gdev->dev;
+	if (!get_device(dev))
+		return -ENODEV;
+
+	QETH_DBF_TEXT_(setup, 2, "%s", gdev->dev.bus_id);
+
+	card = qeth_alloc_card();
+	if (!card) {
+		QETH_DBF_TEXT_(setup, 2, "1err%d", -ENOMEM);
+		rc = -ENOMEM;
+		goto err_dev;
+	}
+	card->read.ccwdev  = gdev->cdev[0];
+	card->write.ccwdev = gdev->cdev[1];
+	card->data.ccwdev  = gdev->cdev[2];
+	dev_set_drvdata(&gdev->dev, card);
+	card->gdev = gdev;
+	gdev->cdev[0]->handler = qeth_irq;
+	gdev->cdev[1]->handler = qeth_irq;
+	gdev->cdev[2]->handler = qeth_irq;
+
+	rc = qeth_determine_card_type(card);
+	if (rc) {
+		PRINT_WARN("%s: not a valid card type\n", __func__);
+		QETH_DBF_TEXT_(setup, 2, "3err%d", rc);
+		goto err_card;
+	}
+	rc = qeth_setup_card(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		goto err_card;
+	}
+
+	if (card->info.type == QETH_CARD_TYPE_OSN) {
+		rc = qeth_core_create_osn_attributes(dev);
+		if (rc)
+			goto err_card;
+		rc = qeth_core_load_discipline(card, QETH_DISCIPLINE_LAYER2);
+		if (rc) {
+			qeth_core_remove_osn_attributes(dev);
+			goto err_card;
+		}
+		rc = card->discipline.ccwgdriver->probe(card->gdev);
+		if (rc) {
+			qeth_core_free_discipline(card);
+			qeth_core_remove_osn_attributes(dev);
+			goto err_card;
+		}
+	} else {
+		rc = qeth_core_create_device_attributes(dev);
+		if (rc)
+			goto err_card;
+	}
+
+	write_lock_irqsave(&qeth_core_card_list.rwlock, flags);
+	list_add_tail(&card->list, &qeth_core_card_list.list);
+	write_unlock_irqrestore(&qeth_core_card_list.rwlock, flags);
+	return 0;
+
+err_card:
+	qeth_core_free_card(card);
+err_dev:
+	put_device(dev);
+	return rc;
+}
+
+static void qeth_core_remove_device(struct ccwgroup_device *gdev)
+{
+	unsigned long flags;
+	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+
+	if (card->discipline.ccwgdriver) {
+		card->discipline.ccwgdriver->remove(gdev);
+		qeth_core_free_discipline(card);
+	}
+
+	if (card->info.type == QETH_CARD_TYPE_OSN) {
+		qeth_core_remove_osn_attributes(&gdev->dev);
+	} else {
+		qeth_core_remove_device_attributes(&gdev->dev);
+	}
+	write_lock_irqsave(&qeth_core_card_list.rwlock, flags);
+	list_del(&card->list);
+	write_unlock_irqrestore(&qeth_core_card_list.rwlock, flags);
+	qeth_core_free_card(card);
+	dev_set_drvdata(&gdev->dev, NULL);
+	put_device(&gdev->dev);
+	return;
+}
+
+static int qeth_core_set_online(struct ccwgroup_device *gdev)
+{
+	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+	int rc = 0;
+	int def_discipline;
+
+	if (!card->discipline.ccwgdriver) {
+		if (card->info.type == QETH_CARD_TYPE_IQD)
+			def_discipline = QETH_DISCIPLINE_LAYER3;
+		else
+			def_discipline = QETH_DISCIPLINE_LAYER2;
+		rc = qeth_core_load_discipline(card, def_discipline);
+		if (rc)
+			goto err;
+		rc = card->discipline.ccwgdriver->probe(card->gdev);
+		if (rc)
+			goto err;
+	}
+	rc = card->discipline.ccwgdriver->set_online(gdev);
+err:
+	return rc;
+}
+
+static int qeth_core_set_offline(struct ccwgroup_device *gdev)
+{
+	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+	return card->discipline.ccwgdriver->set_offline(gdev);
+}
+
+static void qeth_core_shutdown(struct ccwgroup_device *gdev)
+{
+	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+	if (card->discipline.ccwgdriver &&
+	    card->discipline.ccwgdriver->shutdown)
+		card->discipline.ccwgdriver->shutdown(gdev);
+}
+
+static struct ccwgroup_driver qeth_core_ccwgroup_driver = {
+	.owner = THIS_MODULE,
+	.name = "qeth",
+	.driver_id = 0xD8C5E3C8,
+	.probe = qeth_core_probe_device,
+	.remove = qeth_core_remove_device,
+	.set_online = qeth_core_set_online,
+	.set_offline = qeth_core_set_offline,
+	.shutdown = qeth_core_shutdown,
+};
+
+static ssize_t
+qeth_core_driver_group_store(struct device_driver *ddrv, const char *buf,
+			   size_t count)
+{
+	int err;
+	err = qeth_core_driver_group(buf, qeth_core_root_dev,
+					qeth_core_ccwgroup_driver.driver_id);
+	if (err)
+		return err;
+	else
+		return count;
+}
+
+static DRIVER_ATTR(group, 0200, NULL, qeth_core_driver_group_store);
+
+static struct {
+	const char str[ETH_GSTRING_LEN];
+} qeth_ethtool_stats_keys[] = {
+/*  0 */{"rx skbs"},
+	{"rx buffers"},
+	{"tx skbs"},
+	{"tx buffers"},
+	{"tx skbs no packing"},
+	{"tx buffers no packing"},
+	{"tx skbs packing"},
+	{"tx buffers packing"},
+	{"tx sg skbs"},
+	{"tx sg frags"},
+/* 10 */{"rx sg skbs"},
+	{"rx sg frags"},
+	{"rx sg page allocs"},
+	{"tx large kbytes"},
+	{"tx large count"},
+	{"tx pk state ch n->p"},
+	{"tx pk state ch p->n"},
+	{"tx pk watermark low"},
+	{"tx pk watermark high"},
+	{"queue 0 buffer usage"},
+/* 20 */{"queue 1 buffer usage"},
+	{"queue 2 buffer usage"},
+	{"queue 3 buffer usage"},
+	{"rx handler time"},
+	{"rx handler count"},
+	{"rx do_QDIO time"},
+	{"rx do_QDIO count"},
+	{"tx handler time"},
+	{"tx handler count"},
+	{"tx time"},
+/* 30 */{"tx count"},
+	{"tx do_QDIO time"},
+	{"tx do_QDIO count"},
+};
+
+int qeth_core_get_stats_count(struct net_device *dev)
+{
+	return (sizeof(qeth_ethtool_stats_keys) / ETH_GSTRING_LEN);
+}
+EXPORT_SYMBOL_GPL(qeth_core_get_stats_count);
+
+void qeth_core_get_ethtool_stats(struct net_device *dev,
+		struct ethtool_stats *stats, u64 *data)
+{
+	struct qeth_card *card = netdev_priv(dev);
+	data[0] = card->stats.rx_packets -
+				card->perf_stats.initial_rx_packets;
+	data[1] = card->perf_stats.bufs_rec;
+	data[2] = card->stats.tx_packets -
+				card->perf_stats.initial_tx_packets;
+	data[3] = card->perf_stats.bufs_sent;
+	data[4] = card->stats.tx_packets - card->perf_stats.initial_tx_packets
+			- card->perf_stats.skbs_sent_pack;
+	data[5] = card->perf_stats.bufs_sent - card->perf_stats.bufs_sent_pack;
+	data[6] = card->perf_stats.skbs_sent_pack;
+	data[7] = card->perf_stats.bufs_sent_pack;
+	data[8] = card->perf_stats.sg_skbs_sent;
+	data[9] = card->perf_stats.sg_frags_sent;
+	data[10] = card->perf_stats.sg_skbs_rx;
+	data[11] = card->perf_stats.sg_frags_rx;
+	data[12] = card->perf_stats.sg_alloc_page_rx;
+	data[13] = (card->perf_stats.large_send_bytes >> 10);
+	data[14] = card->perf_stats.large_send_cnt;
+	data[15] = card->perf_stats.sc_dp_p;
+	data[16] = card->perf_stats.sc_p_dp;
+	data[17] = QETH_LOW_WATERMARK_PACK;
+	data[18] = QETH_HIGH_WATERMARK_PACK;
+	data[19] = atomic_read(&card->qdio.out_qs[0]->used_buffers);
+	data[20] = (card->qdio.no_out_queues > 1) ?
+			atomic_read(&card->qdio.out_qs[1]->used_buffers) : 0;
+	data[21] = (card->qdio.no_out_queues > 2) ?
+			atomic_read(&card->qdio.out_qs[2]->used_buffers) : 0;
+	data[22] = (card->qdio.no_out_queues > 3) ?
+			atomic_read(&card->qdio.out_qs[3]->used_buffers) : 0;
+	data[23] = card->perf_stats.inbound_time;
+	data[24] = card->perf_stats.inbound_cnt;
+	data[25] = card->perf_stats.inbound_do_qdio_time;
+	data[26] = card->perf_stats.inbound_do_qdio_cnt;
+	data[27] = card->perf_stats.outbound_handler_time;
+	data[28] = card->perf_stats.outbound_handler_cnt;
+	data[29] = card->perf_stats.outbound_time;
+	data[30] = card->perf_stats.outbound_cnt;
+	data[31] = card->perf_stats.outbound_do_qdio_time;
+	data[32] = card->perf_stats.outbound_do_qdio_cnt;
+}
+EXPORT_SYMBOL_GPL(qeth_core_get_ethtool_stats);
+
+void qeth_core_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, &qeth_ethtool_stats_keys,
+			sizeof(qeth_ethtool_stats_keys));
+		break;
+	default:
+		WARN_ON(1);
+		break;
+	}
+}
+EXPORT_SYMBOL_GPL(qeth_core_get_strings);
+
+void qeth_core_get_drvinfo(struct net_device *dev,
+		struct ethtool_drvinfo *info)
+{
+	struct qeth_card *card = netdev_priv(dev);
+	if (card->options.layer2)
+		strcpy(info->driver, "qeth_l2");
+	else
+		strcpy(info->driver, "qeth_l3");
+
+	strcpy(info->version, "1.0");
+	strcpy(info->fw_version, card->info.mcl_level);
+	sprintf(info->bus_info, "%s/%s/%s",
+			CARD_RDEV_ID(card),
+			CARD_WDEV_ID(card),
+			CARD_DDEV_ID(card));
+}
+EXPORT_SYMBOL_GPL(qeth_core_get_drvinfo);
+
+static int __init qeth_core_init(void)
+{
+	int rc;
+
+	PRINT_INFO("loading core functions\n");
+	INIT_LIST_HEAD(&qeth_core_card_list.list);
+	rwlock_init(&qeth_core_card_list.rwlock);
+
+	rc = qeth_register_dbf_views();
+	if (rc)
+		goto out_err;
+	rc = ccw_driver_register(&qeth_ccw_driver);
+	if (rc)
+		goto ccw_err;
+	rc = ccwgroup_driver_register(&qeth_core_ccwgroup_driver);
+	if (rc)
+		goto ccwgroup_err;
+	rc = driver_create_file(&qeth_core_ccwgroup_driver.driver,
+				&driver_attr_group);
+	if (rc)
+		goto driver_err;
+	qeth_core_root_dev = s390_root_dev_register("qeth");
+	rc = IS_ERR(qeth_core_root_dev) ? PTR_ERR(qeth_core_root_dev) : 0;
+	if (rc)
+		goto register_err;
+	return 0;
+
+register_err:
+	driver_remove_file(&qeth_core_ccwgroup_driver.driver,
+			   &driver_attr_group);
+driver_err:
+	ccwgroup_driver_unregister(&qeth_core_ccwgroup_driver);
+ccwgroup_err:
+	ccw_driver_unregister(&qeth_ccw_driver);
+ccw_err:
+	qeth_unregister_dbf_views();
+out_err:
+	PRINT_ERR("Initialization failed with code %d\n", rc);
+	return rc;
+}
+
+static void __exit qeth_core_exit(void)
+{
+	s390_root_dev_unregister(qeth_core_root_dev);
+	driver_remove_file(&qeth_core_ccwgroup_driver.driver,
+			   &driver_attr_group);
+	ccwgroup_driver_unregister(&qeth_core_ccwgroup_driver);
+	ccw_driver_unregister(&qeth_ccw_driver);
+	qeth_unregister_dbf_views();
+	PRINT_INFO("core functions removed\n");
+}
+
+module_init(qeth_core_init);
+module_exit(qeth_core_exit);
+MODULE_AUTHOR("Frank Blaschka <frank.blaschka@de.ibm.com>");
+MODULE_DESCRIPTION("qeth core functions");
+MODULE_LICENSE("GPL");
Index: my_git/drivers/s390/net/qeth_core_mpc.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ my_git/drivers/s390/net/qeth_core_mpc.c	2008-02-14 13:23:52.000000000 +0100
@@ -0,0 +1,266 @@
+/*
+ *  drivers/s390/net/qeth_core_mpc.c
+ *
+ *    Copyright IBM Corp. 2007
+ *    Author(s): Frank Pavlic <fpavlic@de.ibm.com>,
+ *		 Thomas Spatzier <tspat@de.ibm.com>,
+ *		 Frank Blaschka <frank.blaschka@de.ibm.com>
+ */
+
+#include <linux/module.h>
+#include <asm/cio.h>
+#include "qeth_core_mpc.h"
+
+unsigned char IDX_ACTIVATE_READ[] = {
+	0x00, 0x00, 0x80, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x19, 0x01, 0x01, 0x80,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0xc8, 0xc1,
+	0xd3, 0xd3, 0xd6, 0xd3,  0xc5, 0x40, 0x00, 0x00,
+	0x00, 0x00
+};
+
+unsigned char IDX_ACTIVATE_WRITE[] = {
+	0x00, 0x00, 0x80, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x15, 0x01, 0x01, 0x80,  0x00, 0x00, 0x00, 0x00,
+	0xff, 0xff, 0x00, 0x00,  0x00, 0x00, 0xc8, 0xc1,
+	0xd3, 0xd3, 0xd6, 0xd3,  0xc5, 0x40, 0x00, 0x00,
+	0x00, 0x00
+};
+
+unsigned char CM_ENABLE[] = {
+	0x00, 0xe0, 0x00, 0x00,  0x00, 0x00, 0x00, 0x01,
+	0x00, 0x00, 0x00, 0x14,  0x00, 0x00, 0x00, 0x63,
+	0x10, 0x00, 0x00, 0x01,
+	0x00, 0x00, 0x00, 0x00,
+	0x81, 0x7e, 0x00, 0x01,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x24, 0x00, 0x23,
+	0x00, 0x00, 0x23, 0x05,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x01, 0x00, 0x00, 0x23,  0x00, 0x00, 0x00, 0x40,
+	0x00, 0x0c, 0x41, 0x02,  0x00, 0x17, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,
+	0x00, 0x0b, 0x04, 0x01,
+	0x7e, 0x04, 0x05, 0x00,  0x01, 0x01, 0x0f,
+	0x00,
+	0x0c, 0x04, 0x02, 0xff,  0xff, 0xff, 0xff, 0xff,
+	0xff, 0xff, 0xff
+};
+
+unsigned char CM_SETUP[] = {
+	0x00, 0xe0, 0x00, 0x00,  0x00, 0x00, 0x00, 0x02,
+	0x00, 0x00, 0x00, 0x14,  0x00, 0x00, 0x00, 0x64,
+	0x10, 0x00, 0x00, 0x01,
+	0x00, 0x00, 0x00, 0x00,
+	0x81, 0x7e, 0x00, 0x01,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x24, 0x00, 0x24,
+	0x00, 0x00, 0x24, 0x05,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x01, 0x00, 0x00, 0x24,  0x00, 0x00, 0x00, 0x40,
+	0x00, 0x0c, 0x41, 0x04,  0x00, 0x18, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,
+	0x00, 0x09, 0x04, 0x04,
+	0x05, 0x00, 0x01, 0x01,  0x11,
+	0x00, 0x09, 0x04,
+	0x05, 0x05, 0x00, 0x00,  0x00, 0x00,
+	0x00, 0x06,
+	0x04, 0x06, 0xc8, 0x00
+};
+
+unsigned char ULP_ENABLE[] = {
+	0x00, 0xe0, 0x00, 0x00,  0x00, 0x00, 0x00, 0x03,
+	0x00, 0x00, 0x00, 0x14,  0x00, 0x00, 0x00, 0x6b,
+	0x10, 0x00, 0x00, 0x01,
+	0x00, 0x00, 0x00, 0x00,
+	0x41, 0x7e, 0x00, 0x01,  0x00, 0x00, 0x00, 0x01,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x24, 0x00, 0x2b,
+	0x00, 0x00, 0x2b, 0x05,  0x20, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x01, 0x00, 0x00, 0x2b,  0x00, 0x00, 0x00, 0x40,
+	0x00, 0x0c, 0x41, 0x02,  0x00, 0x1f, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,
+	0x00, 0x0b, 0x04, 0x01,
+	0x03, 0x04, 0x05, 0x00,  0x01, 0x01, 0x12,
+	0x00,
+	0x14, 0x04, 0x0a, 0x00,  0x20, 0x00, 0x00, 0xff,
+	0xff, 0x00, 0x08, 0xc8,  0xe8, 0xc4, 0xf1, 0xc7,
+	0xf1, 0x00, 0x00
+};
+
+unsigned char ULP_SETUP[] = {
+	0x00, 0xe0, 0x00, 0x00,  0x00, 0x00, 0x00, 0x04,
+	0x00, 0x00, 0x00, 0x14,  0x00, 0x00, 0x00, 0x6c,
+	0x10, 0x00, 0x00, 0x01,
+	0x00, 0x00, 0x00, 0x00,
+	0x41, 0x7e, 0x00, 0x01,  0x00, 0x00, 0x00, 0x02,
+	0x00, 0x00, 0x00, 0x01,  0x00, 0x24, 0x00, 0x2c,
+	0x00, 0x00, 0x2c, 0x05,  0x20, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x01, 0x00, 0x00, 0x2c,  0x00, 0x00, 0x00, 0x40,
+	0x00, 0x0c, 0x41, 0x04,  0x00, 0x20, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,
+	0x00, 0x09, 0x04, 0x04,
+	0x05, 0x00, 0x01, 0x01,  0x14,
+	0x00, 0x09, 0x04,
+	0x05, 0x05, 0x30, 0x01,  0x00, 0x00,
+	0x00, 0x06,
+	0x04, 0x06, 0x40, 0x00,
+	0x00, 0x08, 0x04, 0x0b,
+	0x00, 0x00, 0x00, 0x00
+};
+
+unsigned char DM_ACT[] = {
+	0x00, 0xe0, 0x00, 0x00,  0x00, 0x00, 0x00, 0x05,
+	0x00, 0x00, 0x00, 0x14,  0x00, 0x00, 0x00, 0x55,
+	0x10, 0x00, 0x00, 0x01,
+	0x00, 0x00, 0x00, 0x00,
+	0x41, 0x7e, 0x00, 0x01,  0x00, 0x00, 0x00, 0x03,
+	0x00, 0x00, 0x00, 0x02,  0x00, 0x24, 0x00, 0x15,
+	0x00, 0x00, 0x2c, 0x05,  0x20, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x01, 0x00, 0x00, 0x15,  0x00, 0x00, 0x00, 0x40,
+	0x00, 0x0c, 0x43, 0x60,  0x00, 0x09, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,
+	0x00, 0x09, 0x04, 0x04,
+	0x05, 0x40, 0x01, 0x01,  0x00
+};
+
+unsigned char IPA_PDU_HEADER[] = {
+	0x00, 0xe0, 0x00, 0x00,  0x77, 0x77, 0x77, 0x77,
+	0x00, 0x00, 0x00, 0x14,  0x00, 0x00,
+		(IPA_PDU_HEADER_SIZE+sizeof(struct qeth_ipa_cmd)) / 256,
+		(IPA_PDU_HEADER_SIZE+sizeof(struct qeth_ipa_cmd)) % 256,
+	0x10, 0x00, 0x00, 0x01,  0x00, 0x00, 0x00, 0x00,
+	0xc1, 0x03, 0x00, 0x01,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x24,
+		sizeof(struct qeth_ipa_cmd) / 256,
+		sizeof(struct qeth_ipa_cmd) % 256,
+	0x00,
+		sizeof(struct qeth_ipa_cmd) / 256,
+		sizeof(struct qeth_ipa_cmd) % 256,
+	0x05,
+	0x77, 0x77, 0x77, 0x77,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x01, 0x00,
+		sizeof(struct qeth_ipa_cmd) / 256,
+		sizeof(struct qeth_ipa_cmd) % 256,
+	0x00, 0x00, 0x00, 0x40,
+};
+EXPORT_SYMBOL_GPL(IPA_PDU_HEADER);
+
+unsigned char WRITE_CCW[] = {
+	0x01, CCW_FLAG_SLI, 0, 0,
+	0, 0, 0, 0
+};
+
+unsigned char READ_CCW[] = {
+	0x02, CCW_FLAG_SLI, 0, 0,
+	0, 0, 0, 0
+};
+
+
+struct ipa_rc_msg {
+	enum qeth_ipa_return_codes rc;
+	char *msg;
+};
+
+static struct ipa_rc_msg qeth_ipa_rc_msg[] = {
+	{IPA_RC_SUCCESS,		"success"},
+	{IPA_RC_NOTSUPP,		"Command not supported"},
+	{IPA_RC_IP_TABLE_FULL,		"Add Addr IP Table Full - ipv6"},
+	{IPA_RC_UNKNOWN_ERROR,		"IPA command failed - reason unknown"},
+	{IPA_RC_UNSUPPORTED_COMMAND,	"Command not supported"},
+	{IPA_RC_DUP_IPV6_REMOTE, "ipv6 address already registered remote"},
+	{IPA_RC_DUP_IPV6_HOME,		"ipv6 address already registered"},
+	{IPA_RC_UNREGISTERED_ADDR,	"Address not registered"},
+	{IPA_RC_NO_ID_AVAILABLE,	"No identifiers available"},
+	{IPA_RC_ID_NOT_FOUND,		"Identifier not found"},
+	{IPA_RC_INVALID_IP_VERSION,	"IP version incorrect"},
+	{IPA_RC_LAN_FRAME_MISMATCH,	"LAN and frame mismatch"},
+	{IPA_RC_L2_UNSUPPORTED_CMD,	"Unsupported layer 2 command"},
+	{IPA_RC_L2_DUP_MAC,		"Duplicate MAC address"},
+	{IPA_RC_L2_ADDR_TABLE_FULL,	"Layer2 address table full"},
+	{IPA_RC_L2_DUP_LAYER3_MAC,	"Duplicate with layer 3 MAC"},
+	{IPA_RC_L2_GMAC_NOT_FOUND,	"GMAC not found"},
+	{IPA_RC_L2_MAC_NOT_FOUND,	"L2 mac address not found"},
+	{IPA_RC_L2_INVALID_VLAN_ID,	"L2 invalid vlan id"},
+	{IPA_RC_L2_DUP_VLAN_ID,		"L2 duplicate vlan id"},
+	{IPA_RC_L2_VLAN_ID_NOT_FOUND,	"L2 vlan id not found"},
+	{IPA_RC_DATA_MISMATCH,		"Data field mismatch (v4/v6 mixed)"},
+	{IPA_RC_INVALID_MTU_SIZE,	"Invalid MTU size"},
+	{IPA_RC_INVALID_LANTYPE,	"Invalid LAN type"},
+	{IPA_RC_INVALID_LANNUM,		"Invalid LAN num"},
+	{IPA_RC_DUPLICATE_IP_ADDRESS,	"Address already registered"},
+	{IPA_RC_IP_ADDR_TABLE_FULL,	"IP address table full"},
+	{IPA_RC_LAN_PORT_STATE_ERROR,	"LAN port state error"},
+	{IPA_RC_SETIP_NO_STARTLAN,	"Setip no startlan received"},
+	{IPA_RC_SETIP_ALREADY_RECEIVED,	"Setip already received"},
+	{IPA_RC_IP_ADDR_ALREADY_USED,	"IP address already in use on LAN"},
+	{IPA_RC_MULTICAST_FULL,		"No task available, multicast full"},
+	{IPA_RC_SETIP_INVALID_VERSION,	"SETIP invalid IP version"},
+	{IPA_RC_UNSUPPORTED_SUBCMD,	"Unsupported assist subcommand"},
+	{IPA_RC_ARP_ASSIST_NO_ENABLE,	"Only partial success, no enable"},
+	{IPA_RC_PRIMARY_ALREADY_DEFINED, "Primary already defined"},
+	{IPA_RC_SECOND_ALREADY_DEFINED,	"Secondary already defined"},
+	{IPA_RC_INVALID_SETRTG_INDICATOR, "Invalid SETRTG indicator"},
+	{IPA_RC_MC_ADDR_ALREADY_DEFINED, "Multicast address already defined"},
+	{IPA_RC_LAN_OFFLINE,		"STRTLAN_LAN_DISABLED - LAN offline"},
+	{IPA_RC_INVALID_IP_VERSION2,	"Invalid IP version"},
+	{IPA_RC_FFFF,			"Unknown Error"}
+};
+
+
+
+char *qeth_get_ipa_msg(enum qeth_ipa_return_codes rc)
+{
+	int x = 0;
+	qeth_ipa_rc_msg[sizeof(qeth_ipa_rc_msg) /
+			sizeof(struct ipa_rc_msg) - 1].rc = rc;
+	while (qeth_ipa_rc_msg[x].rc != rc)
+		x++;
+	return qeth_ipa_rc_msg[x].msg;
+}
+
+
+struct ipa_cmd_names {
+	enum qeth_ipa_cmds cmd;
+	char *name;
+};
+
+static struct ipa_cmd_names qeth_ipa_cmd_names[] = {
+	{IPA_CMD_STARTLAN,	"startlan"},
+	{IPA_CMD_STOPLAN,	"stoplan"},
+	{IPA_CMD_SETVMAC,	"setvmac"},
+	{IPA_CMD_DELVMAC,	"delvmca"},
+	{IPA_CMD_SETGMAC,	"setgmac"},
+	{IPA_CMD_DELGMAC,	"delgmac"},
+	{IPA_CMD_SETVLAN,	"setvlan"},
+	{IPA_CMD_DELVLAN,	"delvlan"},
+	{IPA_CMD_SETCCID,	"setccid"},
+	{IPA_CMD_DELCCID,	"delccid"},
+	{IPA_CMD_MODCCID,	"modccid"},
+	{IPA_CMD_SETIP,		"setip"},
+	{IPA_CMD_QIPASSIST,	"qipassist"},
+	{IPA_CMD_SETASSPARMS,	"setassparms"},
+	{IPA_CMD_SETIPM,	"setipm"},
+	{IPA_CMD_DELIPM,	"delipm"},
+	{IPA_CMD_SETRTG,	"setrtg"},
+	{IPA_CMD_DELIP,		"delip"},
+	{IPA_CMD_SETADAPTERPARMS, "setadapterparms"},
+	{IPA_CMD_SET_DIAG_ASS,	"set_diag_ass"},
+	{IPA_CMD_CREATE_ADDR,	"create_addr"},
+	{IPA_CMD_DESTROY_ADDR,	"destroy_addr"},
+	{IPA_CMD_REGISTER_LOCAL_ADDR,	"register_local_addr"},
+	{IPA_CMD_UNREGISTER_LOCAL_ADDR,	"unregister_local_addr"},
+	{IPA_CMD_UNKNOWN,	"unknown"},
+};
+
+char *qeth_get_ipa_cmd_name(enum qeth_ipa_cmds cmd)
+{
+	int x = 0;
+	qeth_ipa_cmd_names[
+		sizeof(qeth_ipa_cmd_names) /
+			sizeof(struct ipa_cmd_names)-1].cmd = cmd;
+	while (qeth_ipa_cmd_names[x].cmd != cmd)
+		x++;
+	return qeth_ipa_cmd_names[x].name;
+}
Index: my_git/drivers/s390/net/qeth_core_mpc.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ my_git/drivers/s390/net/qeth_core_mpc.h	2008-02-14 13:23:52.000000000 +0100
@@ -0,0 +1,566 @@
+/*
+ *  drivers/s390/net/qeth_core_mpc.h
+ *
+ *    Copyright IBM Corp. 2007
+ *    Author(s): Frank Pavlic <fpavlic@de.ibm.com>,
+ *		 Thomas Spatzier <tspat@de.ibm.com>,
+ *		 Frank Blaschka <frank.blaschka@de.ibm.com>
+ */
+
+#ifndef __QETH_CORE_MPC_H__
+#define __QETH_CORE_MPC_H__
+
+#include <asm/qeth.h>
+
+#define IPA_PDU_HEADER_SIZE	0x40
+#define QETH_IPA_PDU_LEN_TOTAL(buffer) (buffer + 0x0e)
+#define QETH_IPA_PDU_LEN_PDU1(buffer) (buffer + 0x26)
+#define QETH_IPA_PDU_LEN_PDU2(buffer) (buffer + 0x29)
+#define QETH_IPA_PDU_LEN_PDU3(buffer) (buffer + 0x3a)
+
+extern unsigned char IPA_PDU_HEADER[];
+#define QETH_IPA_CMD_DEST_ADDR(buffer) (buffer + 0x2c)
+
+#define IPA_CMD_LENGTH	(IPA_PDU_HEADER_SIZE + sizeof(struct qeth_ipa_cmd))
+
+#define QETH_SEQ_NO_LENGTH	4
+#define QETH_MPC_TOKEN_LENGTH	4
+#define QETH_MCL_LENGTH		4
+#define OSA_ADDR_LEN		6
+
+#define QETH_TIMEOUT		(10 * HZ)
+#define QETH_IPA_TIMEOUT	(45 * HZ)
+#define QETH_IDX_COMMAND_SEQNO	0xffff0000
+#define SR_INFO_LEN		16
+
+#define QETH_CLEAR_CHANNEL_PARM	-10
+#define QETH_HALT_CHANNEL_PARM	-11
+#define QETH_RCD_PARM -12
+
+/*****************************************************************************/
+/* IP Assist related definitions                                             */
+/*****************************************************************************/
+#define IPA_CMD_INITIATOR_HOST  0x00
+#define IPA_CMD_INITIATOR_OSA   0x01
+#define IPA_CMD_INITIATOR_HOST_REPLY  0x80
+#define IPA_CMD_INITIATOR_OSA_REPLY   0x81
+#define IPA_CMD_PRIM_VERSION_NO 0x01
+
+enum qeth_card_types {
+	QETH_CARD_TYPE_UNKNOWN = 0,
+	QETH_CARD_TYPE_OSAE    = 10,
+	QETH_CARD_TYPE_IQD     = 1234,
+	QETH_CARD_TYPE_OSN     = 11,
+};
+
+#define QETH_MPC_DIFINFO_LEN_INDICATES_LINK_TYPE 0x18
+/* only the first two bytes are looked at in qeth_get_cardname_short */
+enum qeth_link_types {
+	QETH_LINK_TYPE_FAST_ETH     = 0x01,
+	QETH_LINK_TYPE_HSTR         = 0x02,
+	QETH_LINK_TYPE_GBIT_ETH     = 0x03,
+	QETH_LINK_TYPE_OSN          = 0x04,
+	QETH_LINK_TYPE_10GBIT_ETH   = 0x10,
+	QETH_LINK_TYPE_LANE_ETH100  = 0x81,
+	QETH_LINK_TYPE_LANE_TR      = 0x82,
+	QETH_LINK_TYPE_LANE_ETH1000 = 0x83,
+	QETH_LINK_TYPE_LANE         = 0x88,
+	QETH_LINK_TYPE_ATM_NATIVE   = 0x90,
+};
+
+enum qeth_tr_macaddr_modes {
+	QETH_TR_MACADDR_NONCANONICAL = 0,
+	QETH_TR_MACADDR_CANONICAL    = 1,
+};
+
+enum qeth_tr_broadcast_modes {
+	QETH_TR_BROADCAST_ALLRINGS = 0,
+	QETH_TR_BROADCAST_LOCAL    = 1,
+};
+
+/* these values match CHECKSUM_* in include/linux/skbuff.h */
+enum qeth_checksum_types {
+	SW_CHECKSUMMING = 0, /* TODO: set to bit flag used in IPA Command */
+	HW_CHECKSUMMING = 1,
+	NO_CHECKSUMMING = 2,
+};
+#define QETH_CHECKSUM_DEFAULT SW_CHECKSUMMING
+
+/*
+ * Routing stuff
+ */
+#define RESET_ROUTING_FLAG 0x10 /* indicate that routing type shall be set */
+enum qeth_routing_types {
+	/* TODO: set to bit flag used in IPA Command */
+	NO_ROUTER		= 0,
+	PRIMARY_ROUTER		= 1,
+	SECONDARY_ROUTER	= 2,
+	MULTICAST_ROUTER	= 3,
+	PRIMARY_CONNECTOR	= 4,
+	SECONDARY_CONNECTOR	= 5,
+};
+
+/* IPA Commands */
+enum qeth_ipa_cmds {
+	IPA_CMD_STARTLAN		= 0x01,
+	IPA_CMD_STOPLAN			= 0x02,
+	IPA_CMD_SETVMAC			= 0x21,
+	IPA_CMD_DELVMAC			= 0x22,
+	IPA_CMD_SETGMAC			= 0x23,
+	IPA_CMD_DELGMAC			= 0x24,
+	IPA_CMD_SETVLAN			= 0x25,
+	IPA_CMD_DELVLAN			= 0x26,
+	IPA_CMD_SETCCID			= 0x41,
+	IPA_CMD_DELCCID			= 0x42,
+	IPA_CMD_MODCCID			= 0x43,
+	IPA_CMD_SETIP			= 0xb1,
+	IPA_CMD_QIPASSIST		= 0xb2,
+	IPA_CMD_SETASSPARMS		= 0xb3,
+	IPA_CMD_SETIPM			= 0xb4,
+	IPA_CMD_DELIPM			= 0xb5,
+	IPA_CMD_SETRTG			= 0xb6,
+	IPA_CMD_DELIP			= 0xb7,
+	IPA_CMD_SETADAPTERPARMS		= 0xb8,
+	IPA_CMD_SET_DIAG_ASS		= 0xb9,
+	IPA_CMD_CREATE_ADDR		= 0xc3,
+	IPA_CMD_DESTROY_ADDR		= 0xc4,
+	IPA_CMD_REGISTER_LOCAL_ADDR	= 0xd1,
+	IPA_CMD_UNREGISTER_LOCAL_ADDR	= 0xd2,
+	IPA_CMD_UNKNOWN			= 0x00
+};
+
+enum qeth_ip_ass_cmds {
+	IPA_CMD_ASS_START	= 0x0001,
+	IPA_CMD_ASS_STOP	= 0x0002,
+	IPA_CMD_ASS_CONFIGURE	= 0x0003,
+	IPA_CMD_ASS_ENABLE	= 0x0004,
+};
+
+enum qeth_arp_process_subcmds {
+	IPA_CMD_ASS_ARP_SET_NO_ENTRIES	= 0x0003,
+	IPA_CMD_ASS_ARP_QUERY_CACHE	= 0x0004,
+	IPA_CMD_ASS_ARP_ADD_ENTRY	= 0x0005,
+	IPA_CMD_ASS_ARP_REMOVE_ENTRY	= 0x0006,
+	IPA_CMD_ASS_ARP_FLUSH_CACHE	= 0x0007,
+	IPA_CMD_ASS_ARP_QUERY_INFO	= 0x0104,
+	IPA_CMD_ASS_ARP_QUERY_STATS	= 0x0204,
+};
+
+
+/* Return Codes for IPA Commands
+ * according to OSA card Specs */
+
+enum qeth_ipa_return_codes {
+	IPA_RC_SUCCESS			= 0x0000,
+	IPA_RC_NOTSUPP			= 0x0001,
+	IPA_RC_IP_TABLE_FULL		= 0x0002,
+	IPA_RC_UNKNOWN_ERROR		= 0x0003,
+	IPA_RC_UNSUPPORTED_COMMAND	= 0x0004,
+	IPA_RC_DUP_IPV6_REMOTE		= 0x0008,
+	IPA_RC_DUP_IPV6_HOME		= 0x0010,
+	IPA_RC_UNREGISTERED_ADDR	= 0x0011,
+	IPA_RC_NO_ID_AVAILABLE		= 0x0012,
+	IPA_RC_ID_NOT_FOUND		= 0x0013,
+	IPA_RC_INVALID_IP_VERSION	= 0x0020,
+	IPA_RC_LAN_FRAME_MISMATCH	= 0x0040,
+	IPA_RC_L2_UNSUPPORTED_CMD	= 0x2003,
+	IPA_RC_L2_DUP_MAC		= 0x2005,
+	IPA_RC_L2_ADDR_TABLE_FULL	= 0x2006,
+	IPA_RC_L2_DUP_LAYER3_MAC	= 0x200a,
+	IPA_RC_L2_GMAC_NOT_FOUND	= 0x200b,
+	IPA_RC_L2_MAC_NOT_FOUND		= 0x2010,
+	IPA_RC_L2_INVALID_VLAN_ID	= 0x2015,
+	IPA_RC_L2_DUP_VLAN_ID		= 0x2016,
+	IPA_RC_L2_VLAN_ID_NOT_FOUND	= 0x2017,
+	IPA_RC_DATA_MISMATCH		= 0xe001,
+	IPA_RC_INVALID_MTU_SIZE		= 0xe002,
+	IPA_RC_INVALID_LANTYPE		= 0xe003,
+	IPA_RC_INVALID_LANNUM		= 0xe004,
+	IPA_RC_DUPLICATE_IP_ADDRESS	= 0xe005,
+	IPA_RC_IP_ADDR_TABLE_FULL	= 0xe006,
+	IPA_RC_LAN_PORT_STATE_ERROR	= 0xe007,
+	IPA_RC_SETIP_NO_STARTLAN	= 0xe008,
+	IPA_RC_SETIP_ALREADY_RECEIVED	= 0xe009,
+	IPA_RC_IP_ADDR_ALREADY_USED	= 0xe00a,
+	IPA_RC_MULTICAST_FULL		= 0xe00b,
+	IPA_RC_SETIP_INVALID_VERSION	= 0xe00d,
+	IPA_RC_UNSUPPORTED_SUBCMD	= 0xe00e,
+	IPA_RC_ARP_ASSIST_NO_ENABLE	= 0xe00f,
+	IPA_RC_PRIMARY_ALREADY_DEFINED	= 0xe010,
+	IPA_RC_SECOND_ALREADY_DEFINED	= 0xe011,
+	IPA_RC_INVALID_SETRTG_INDICATOR	= 0xe012,
+	IPA_RC_MC_ADDR_ALREADY_DEFINED	= 0xe013,
+	IPA_RC_LAN_OFFLINE		= 0xe080,
+	IPA_RC_INVALID_IP_VERSION2	= 0xf001,
+	IPA_RC_FFFF			= 0xffff
+};
+
+/* IPA function flags; each flag marks availability of respective function */
+enum qeth_ipa_funcs {
+	IPA_ARP_PROCESSING      = 0x00000001L,
+	IPA_INBOUND_CHECKSUM    = 0x00000002L,
+	IPA_OUTBOUND_CHECKSUM   = 0x00000004L,
+	IPA_IP_FRAGMENTATION    = 0x00000008L,
+	IPA_FILTERING           = 0x00000010L,
+	IPA_IPV6                = 0x00000020L,
+	IPA_MULTICASTING        = 0x00000040L,
+	IPA_IP_REASSEMBLY       = 0x00000080L,
+	IPA_QUERY_ARP_COUNTERS  = 0x00000100L,
+	IPA_QUERY_ARP_ADDR_INFO = 0x00000200L,
+	IPA_SETADAPTERPARMS     = 0x00000400L,
+	IPA_VLAN_PRIO           = 0x00000800L,
+	IPA_PASSTHRU            = 0x00001000L,
+	IPA_FLUSH_ARP_SUPPORT   = 0x00002000L,
+	IPA_FULL_VLAN           = 0x00004000L,
+	IPA_INBOUND_PASSTHRU    = 0x00008000L,
+	IPA_SOURCE_MAC          = 0x00010000L,
+	IPA_OSA_MC_ROUTER       = 0x00020000L,
+	IPA_QUERY_ARP_ASSIST	= 0x00040000L,
+	IPA_INBOUND_TSO         = 0x00080000L,
+	IPA_OUTBOUND_TSO        = 0x00100000L,
+};
+
+/* SETIP/DELIP IPA Command: ***************************************************/
+enum qeth_ipa_setdelip_flags {
+	QETH_IPA_SETDELIP_DEFAULT          = 0x00L, /* default */
+	QETH_IPA_SETIP_VIPA_FLAG           = 0x01L, /* no grat. ARP */
+	QETH_IPA_SETIP_TAKEOVER_FLAG       = 0x02L, /* nofail on grat. ARP */
+	QETH_IPA_DELIP_ADDR_2_B_TAKEN_OVER = 0x20L,
+	QETH_IPA_DELIP_VIPA_FLAG           = 0x40L,
+	QETH_IPA_DELIP_ADDR_NEEDS_SETIP    = 0x80L,
+};
+
+/* SETADAPTER IPA Command: ****************************************************/
+enum qeth_ipa_setadp_cmd {
+	IPA_SETADP_QUERY_COMMANDS_SUPPORTED	= 0x0001,
+	IPA_SETADP_ALTER_MAC_ADDRESS		= 0x0002,
+	IPA_SETADP_ADD_DELETE_GROUP_ADDRESS	= 0x0004,
+	IPA_SETADP_ADD_DELETE_FUNCTIONAL_ADDR	= 0x0008,
+	IPA_SETADP_SET_ADDRESSING_MODE		= 0x0010,
+	IPA_SETADP_SET_CONFIG_PARMS		= 0x0020,
+	IPA_SETADP_SET_CONFIG_PARMS_EXTENDED	= 0x0040,
+	IPA_SETADP_SET_BROADCAST_MODE		= 0x0080,
+	IPA_SETADP_SEND_OSA_MESSAGE		= 0x0100,
+	IPA_SETADP_SET_SNMP_CONTROL		= 0x0200,
+	IPA_SETADP_QUERY_CARD_INFO		= 0x0400,
+	IPA_SETADP_SET_PROMISC_MODE		= 0x0800,
+};
+enum qeth_ipa_mac_ops {
+	CHANGE_ADDR_READ_MAC		= 0,
+	CHANGE_ADDR_REPLACE_MAC		= 1,
+	CHANGE_ADDR_ADD_MAC		= 2,
+	CHANGE_ADDR_DEL_MAC		= 4,
+	CHANGE_ADDR_RESET_MAC		= 8,
+};
+enum qeth_ipa_addr_ops {
+	CHANGE_ADDR_READ_ADDR		= 0,
+	CHANGE_ADDR_ADD_ADDR		= 1,
+	CHANGE_ADDR_DEL_ADDR		= 2,
+	CHANGE_ADDR_FLUSH_ADDR_TABLE	= 4,
+};
+enum qeth_ipa_promisc_modes {
+	SET_PROMISC_MODE_OFF		= 0,
+	SET_PROMISC_MODE_ON		= 1,
+};
+
+/* (SET)DELIP(M) IPA stuff ***************************************************/
+struct qeth_ipacmd_setdelip4 {
+	__u8   ip_addr[4];
+	__u8   mask[4];
+	__u32  flags;
+} __attribute__ ((packed));
+
+struct qeth_ipacmd_setdelip6 {
+	__u8   ip_addr[16];
+	__u8   mask[16];
+	__u32  flags;
+} __attribute__ ((packed));
+
+struct qeth_ipacmd_setdelipm {
+	__u8 mac[6];
+	__u8 padding[2];
+	__u8 ip6[12];
+	__u8 ip4[4];
+} __attribute__ ((packed));
+
+struct qeth_ipacmd_layer2setdelmac {
+	__u32 mac_length;
+	__u8 mac[6];
+} __attribute__ ((packed));
+
+struct qeth_ipacmd_layer2setdelvlan {
+	__u16 vlan_id;
+} __attribute__ ((packed));
+
+
+struct qeth_ipacmd_setassparms_hdr {
+	__u32 assist_no;
+	__u16 length;
+	__u16 command_code;
+	__u16 return_code;
+	__u8 number_of_replies;
+	__u8 seq_no;
+} __attribute__((packed));
+
+struct qeth_arp_query_data {
+	__u16 request_bits;
+	__u16 reply_bits;
+	__u32 no_entries;
+	char data;
+} __attribute__((packed));
+
+/* used as parameter for arp_query reply */
+struct qeth_arp_query_info {
+	__u32 udata_len;
+	__u16 mask_bits;
+	__u32 udata_offset;
+	__u32 no_entries;
+	char *udata;
+};
+
+/* SETASSPARMS IPA Command: */
+struct qeth_ipacmd_setassparms {
+	struct qeth_ipacmd_setassparms_hdr hdr;
+	union {
+		__u32 flags_32bit;
+		struct qeth_arp_cache_entry add_arp_entry;
+		struct qeth_arp_query_data query_arp;
+		__u8 ip[16];
+	} data;
+} __attribute__ ((packed));
+
+
+/* SETRTG IPA Command:    ****************************************************/
+struct qeth_set_routing {
+	__u8 type;
+};
+
+/* SETADAPTERPARMS IPA Command:    *******************************************/
+struct qeth_query_cmds_supp {
+	__u32 no_lantypes_supp;
+	__u8 lan_type;
+	__u8 reserved1[3];
+	__u32 supported_cmds;
+	__u8 reserved2[8];
+} __attribute__ ((packed));
+
+struct qeth_change_addr {
+	__u32 cmd;
+	__u32 addr_size;
+	__u32 no_macs;
+	__u8 addr[OSA_ADDR_LEN];
+} __attribute__ ((packed));
+
+
+struct qeth_snmp_cmd {
+	__u8  token[16];
+	__u32 request;
+	__u32 interface;
+	__u32 returncode;
+	__u32 firmwarelevel;
+	__u32 seqno;
+	__u8  data;
+} __attribute__ ((packed));
+
+struct qeth_snmp_ureq_hdr {
+	__u32   data_len;
+	__u32   req_len;
+	__u32   reserved1;
+	__u32   reserved2;
+} __attribute__ ((packed));
+
+struct qeth_snmp_ureq {
+	struct qeth_snmp_ureq_hdr hdr;
+	struct qeth_snmp_cmd cmd;
+} __attribute__((packed));
+
+struct qeth_ipacmd_setadpparms_hdr {
+	__u32 supp_hw_cmds;
+	__u32 reserved1;
+	__u16 cmdlength;
+	__u16 reserved2;
+	__u32 command_code;
+	__u16 return_code;
+	__u8  used_total;
+	__u8  seq_no;
+	__u32 reserved3;
+} __attribute__ ((packed));
+
+struct qeth_ipacmd_setadpparms {
+	struct qeth_ipacmd_setadpparms_hdr hdr;
+	union {
+		struct qeth_query_cmds_supp query_cmds_supp;
+		struct qeth_change_addr change_addr;
+		struct qeth_snmp_cmd snmp;
+		__u32 mode;
+	} data;
+} __attribute__ ((packed));
+
+/* CREATE_ADDR IPA Command:    ***********************************************/
+struct qeth_create_destroy_address {
+	__u8 unique_id[8];
+} __attribute__ ((packed));
+
+/* Header for each IPA command */
+struct qeth_ipacmd_hdr {
+	__u8   command;
+	__u8   initiator;
+	__u16  seqno;
+	__u16  return_code;
+	__u8   adapter_type;
+	__u8   rel_adapter_no;
+	__u8   prim_version_no;
+	__u8   param_count;
+	__u16  prot_version;
+	__u32  ipa_supported;
+	__u32  ipa_enabled;
+} __attribute__ ((packed));
+
+/* The IPA command itself */
+struct qeth_ipa_cmd {
+	struct qeth_ipacmd_hdr hdr;
+	union {
+		struct qeth_ipacmd_setdelip4		setdelip4;
+		struct qeth_ipacmd_setdelip6		setdelip6;
+		struct qeth_ipacmd_setdelipm		setdelipm;
+		struct qeth_ipacmd_setassparms		setassparms;
+		struct qeth_ipacmd_layer2setdelmac	setdelmac;
+		struct qeth_ipacmd_layer2setdelvlan	setdelvlan;
+		struct qeth_create_destroy_address	create_destroy_addr;
+		struct qeth_ipacmd_setadpparms		setadapterparms;
+		struct qeth_set_routing			setrtg;
+	} data;
+} __attribute__ ((packed));
+
+/*
+ * special command for ARP processing.
+ * this is not included in setassparms command before, because we get
+ * problem with the size of struct qeth_ipacmd_setassparms otherwise
+ */
+enum qeth_ipa_arp_return_codes {
+	QETH_IPA_ARP_RC_SUCCESS      = 0x0000,
+	QETH_IPA_ARP_RC_FAILED       = 0x0001,
+	QETH_IPA_ARP_RC_NOTSUPP      = 0x0002,
+	QETH_IPA_ARP_RC_OUT_OF_RANGE = 0x0003,
+	QETH_IPA_ARP_RC_Q_NOTSUPP    = 0x0004,
+	QETH_IPA_ARP_RC_Q_NO_DATA    = 0x0008,
+};
+
+
+extern char *qeth_get_ipa_msg(enum qeth_ipa_return_codes rc);
+extern char *qeth_get_ipa_cmd_name(enum qeth_ipa_cmds cmd);
+
+#define QETH_SETASS_BASE_LEN (sizeof(struct qeth_ipacmd_hdr) + \
+			       sizeof(struct qeth_ipacmd_setassparms_hdr))
+#define QETH_IPA_ARP_DATA_POS(buffer) (buffer + IPA_PDU_HEADER_SIZE + \
+				       QETH_SETASS_BASE_LEN)
+#define QETH_SETADP_BASE_LEN (sizeof(struct qeth_ipacmd_hdr) + \
+			      sizeof(struct qeth_ipacmd_setadpparms_hdr))
+#define QETH_SNMP_SETADP_CMDLENGTH 16
+
+#define QETH_ARP_DATA_SIZE 3968
+#define QETH_ARP_CMD_LEN (QETH_ARP_DATA_SIZE + 8)
+/* Helper functions */
+#define IS_IPA_REPLY(cmd) ((cmd->hdr.initiator == IPA_CMD_INITIATOR_HOST) || \
+			   (cmd->hdr.initiator == IPA_CMD_INITIATOR_OSA_REPLY))
+
+/*****************************************************************************/
+/* END OF   IP Assist related definitions                                    */
+/*****************************************************************************/
+
+
+extern unsigned char WRITE_CCW[];
+extern unsigned char READ_CCW[];
+
+extern unsigned char CM_ENABLE[];
+#define CM_ENABLE_SIZE 0x63
+#define QETH_CM_ENABLE_ISSUER_RM_TOKEN(buffer) (buffer + 0x2c)
+#define QETH_CM_ENABLE_FILTER_TOKEN(buffer) (buffer + 0x53)
+#define QETH_CM_ENABLE_USER_DATA(buffer) (buffer + 0x5b)
+
+#define QETH_CM_ENABLE_RESP_FILTER_TOKEN(buffer) \
+		(PDU_ENCAPSULATION(buffer) + 0x13)
+
+
+extern unsigned char CM_SETUP[];
+#define CM_SETUP_SIZE 0x64
+#define QETH_CM_SETUP_DEST_ADDR(buffer) (buffer + 0x2c)
+#define QETH_CM_SETUP_CONNECTION_TOKEN(buffer) (buffer + 0x51)
+#define QETH_CM_SETUP_FILTER_TOKEN(buffer) (buffer + 0x5a)
+
+#define QETH_CM_SETUP_RESP_DEST_ADDR(buffer) \
+		(PDU_ENCAPSULATION(buffer) + 0x1a)
+
+extern unsigned char ULP_ENABLE[];
+#define ULP_ENABLE_SIZE 0x6b
+#define QETH_ULP_ENABLE_LINKNUM(buffer) (buffer + 0x61)
+#define QETH_ULP_ENABLE_DEST_ADDR(buffer) (buffer + 0x2c)
+#define QETH_ULP_ENABLE_FILTER_TOKEN(buffer) (buffer + 0x53)
+#define QETH_ULP_ENABLE_PORTNAME_AND_LL(buffer) (buffer + 0x62)
+#define QETH_ULP_ENABLE_RESP_FILTER_TOKEN(buffer) \
+		(PDU_ENCAPSULATION(buffer) + 0x13)
+#define QETH_ULP_ENABLE_RESP_MAX_MTU(buffer) \
+		(PDU_ENCAPSULATION(buffer) + 0x1f)
+#define QETH_ULP_ENABLE_RESP_DIFINFO_LEN(buffer) \
+		(PDU_ENCAPSULATION(buffer) + 0x17)
+#define QETH_ULP_ENABLE_RESP_LINK_TYPE(buffer) \
+		(PDU_ENCAPSULATION(buffer) + 0x2b)
+/* Layer 2 defintions */
+#define QETH_PROT_LAYER2 0x08
+#define QETH_PROT_TCPIP  0x03
+#define QETH_PROT_OSN2   0x0a
+#define QETH_ULP_ENABLE_PROT_TYPE(buffer) (buffer + 0x50)
+#define QETH_IPA_CMD_PROT_TYPE(buffer) (buffer + 0x19)
+
+extern unsigned char ULP_SETUP[];
+#define ULP_SETUP_SIZE 0x6c
+#define QETH_ULP_SETUP_DEST_ADDR(buffer) (buffer + 0x2c)
+#define QETH_ULP_SETUP_CONNECTION_TOKEN(buffer) (buffer + 0x51)
+#define QETH_ULP_SETUP_FILTER_TOKEN(buffer) (buffer + 0x5a)
+#define QETH_ULP_SETUP_CUA(buffer) (buffer + 0x68)
+#define QETH_ULP_SETUP_REAL_DEVADDR(buffer) (buffer + 0x6a)
+
+#define QETH_ULP_SETUP_RESP_CONNECTION_TOKEN(buffer) \
+		(PDU_ENCAPSULATION(buffer) + 0x1a)
+
+
+extern unsigned char DM_ACT[];
+#define DM_ACT_SIZE 0x55
+#define QETH_DM_ACT_DEST_ADDR(buffer) (buffer + 0x2c)
+#define QETH_DM_ACT_CONNECTION_TOKEN(buffer) (buffer + 0x51)
+
+
+
+#define QETH_TRANSPORT_HEADER_SEQ_NO(buffer) (buffer + 4)
+#define QETH_PDU_HEADER_SEQ_NO(buffer) (buffer + 0x1c)
+#define QETH_PDU_HEADER_ACK_SEQ_NO(buffer) (buffer + 0x20)
+
+extern unsigned char IDX_ACTIVATE_READ[];
+extern unsigned char IDX_ACTIVATE_WRITE[];
+
+#define IDX_ACTIVATE_SIZE	0x22
+#define QETH_IDX_ACT_PNO(buffer) (buffer+0x0b)
+#define QETH_IDX_ACT_ISSUER_RM_TOKEN(buffer) (buffer + 0x0c)
+#define QETH_IDX_NO_PORTNAME_REQUIRED(buffer) ((buffer)[0x0b] & 0x80)
+#define QETH_IDX_ACT_FUNC_LEVEL(buffer) (buffer + 0x10)
+#define QETH_IDX_ACT_DATASET_NAME(buffer) (buffer + 0x16)
+#define QETH_IDX_ACT_QDIO_DEV_CUA(buffer) (buffer + 0x1e)
+#define QETH_IDX_ACT_QDIO_DEV_REALADDR(buffer) (buffer + 0x20)
+#define QETH_IS_IDX_ACT_POS_REPLY(buffer) (((buffer)[0x08] & 3) == 2)
+#define QETH_IDX_REPLY_LEVEL(buffer) (buffer + 0x12)
+#define QETH_IDX_ACT_CAUSE_CODE(buffer) (buffer)[0x09]
+
+#define PDU_ENCAPSULATION(buffer) \
+	(buffer + *(buffer + (*(buffer + 0x0b)) + \
+	 *(buffer + *(buffer + 0x0b) + 0x11) + 0x07))
+
+#define IS_IPA(buffer) \
+	((buffer) && \
+	 (*(buffer + ((*(buffer + 0x0b)) + 4)) == 0xc1))
+
+#define ADDR_FRAME_TYPE_DIX 1
+#define ADDR_FRAME_TYPE_802_3 2
+#define ADDR_FRAME_TYPE_TR_WITHOUT_SR 0x10
+#define ADDR_FRAME_TYPE_TR_WITH_SR 0x20
+
+#endif
Index: my_git/drivers/s390/net/qeth_core_offl.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ my_git/drivers/s390/net/qeth_core_offl.c	2008-02-14 13:23:52.000000000 +0100
@@ -0,0 +1,701 @@
+/*
+ *  drivers/s390/net/qeth_core_offl.c
+ *
+ *    Copyright IBM Corp. 2007
+ *    Author(s): Thomas Spatzier <tspat@de.ibm.com>,
+ *		 Frank Blaschka <frank.blaschka@de.ibm.com>
+ */
+
+#include <linux/errno.h>
+#include <linux/ip.h>
+#include <linux/inetdevice.h>
+#include <linux/netdevice.h>
+#include <linux/kernel.h>
+#include <linux/tcp.h>
+#include <net/tcp.h>
+#include <linux/skbuff.h>
+
+#include <net/ip.h>
+#include <net/ip6_checksum.h>
+
+#include "qeth_core.h"
+#include "qeth_core_mpc.h"
+#include "qeth_core_offl.h"
+
+int qeth_eddp_check_buffers_for_context(struct qeth_qdio_out_q *queue,
+		struct qeth_eddp_context *ctx)
+{
+	int index = queue->next_buf_to_fill;
+	int elements_needed = ctx->num_elements;
+	int elements_in_buffer;
+	int skbs_in_buffer;
+	int buffers_needed = 0;
+
+	QETH_DBF_TEXT(trace, 5, "eddpcbfc");
+	while (elements_needed > 0) {
+		buffers_needed++;
+		if (atomic_read(&queue->bufs[index].state) !=
+				QETH_QDIO_BUF_EMPTY)
+			return -EBUSY;
+
+		elements_in_buffer = QETH_MAX_BUFFER_ELEMENTS(queue->card) -
+				     queue->bufs[index].next_element_to_fill;
+		skbs_in_buffer = elements_in_buffer / ctx->elements_per_skb;
+		elements_needed -= skbs_in_buffer * ctx->elements_per_skb;
+		index = (index + 1) % QDIO_MAX_BUFFERS_PER_Q;
+	}
+	return buffers_needed;
+}
+
+static void qeth_eddp_free_context(struct qeth_eddp_context *ctx)
+{
+	int i;
+
+	QETH_DBF_TEXT(trace, 5, "eddpfctx");
+	for (i = 0; i < ctx->num_pages; ++i)
+		free_page((unsigned long)ctx->pages[i]);
+	kfree(ctx->pages);
+	kfree(ctx->elements);
+	kfree(ctx);
+}
+
+
+static void qeth_eddp_get_context(struct qeth_eddp_context *ctx)
+{
+	atomic_inc(&ctx->refcnt);
+}
+
+void qeth_eddp_put_context(struct qeth_eddp_context *ctx)
+{
+	if (atomic_dec_return(&ctx->refcnt) == 0)
+		qeth_eddp_free_context(ctx);
+}
+EXPORT_SYMBOL_GPL(qeth_eddp_put_context);
+
+void qeth_eddp_buf_release_contexts(struct qeth_qdio_out_buffer *buf)
+{
+	struct qeth_eddp_context_reference *ref;
+
+	QETH_DBF_TEXT(trace, 6, "eddprctx");
+	while (!list_empty(&buf->ctx_list)) {
+		ref = list_entry(buf->ctx_list.next,
+				 struct qeth_eddp_context_reference, list);
+		qeth_eddp_put_context(ref->ctx);
+		list_del(&ref->list);
+		kfree(ref);
+	}
+}
+
+static int qeth_eddp_buf_ref_context(struct qeth_qdio_out_buffer *buf,
+		struct qeth_eddp_context *ctx)
+{
+	struct qeth_eddp_context_reference *ref;
+
+	QETH_DBF_TEXT(trace, 6, "eddprfcx");
+	ref = kmalloc(sizeof(struct qeth_eddp_context_reference), GFP_ATOMIC);
+	if (ref == NULL)
+		return -ENOMEM;
+	qeth_eddp_get_context(ctx);
+	ref->ctx = ctx;
+	list_add_tail(&ref->list, &buf->ctx_list);
+	return 0;
+}
+
+int qeth_eddp_fill_buffer(struct qeth_qdio_out_q *queue,
+		struct qeth_eddp_context *ctx, int index)
+{
+	struct qeth_qdio_out_buffer *buf = NULL;
+	struct qdio_buffer *buffer;
+	int elements = ctx->num_elements;
+	int element = 0;
+	int flush_cnt = 0;
+	int must_refcnt = 1;
+	int i;
+
+	QETH_DBF_TEXT(trace, 5, "eddpfibu");
+	while (elements > 0) {
+		buf = &queue->bufs[index];
+		if (atomic_read(&buf->state) != QETH_QDIO_BUF_EMPTY) {
+			/* normally this should not happen since we checked for
+			 * available elements in qeth_check_elements_for_context
+			 */
+			if (element == 0)
+				return -EBUSY;
+			else {
+				PRINT_WARN("could only partially fill eddp "
+					   "buffer!\n");
+				goto out;
+			}
+		}
+		/* check if the whole next skb fits into current buffer */
+		if ((QETH_MAX_BUFFER_ELEMENTS(queue->card) -
+					buf->next_element_to_fill)
+				< ctx->elements_per_skb){
+			/* no -> go to next buffer */
+			atomic_set(&buf->state, QETH_QDIO_BUF_PRIMED);
+			index = (index + 1) % QDIO_MAX_BUFFERS_PER_Q;
+			flush_cnt++;
+			/* new buffer, so we have to add ctx to buffer'ctx_list
+			 * and increment ctx's refcnt */
+			must_refcnt = 1;
+			continue;
+		}
+		if (must_refcnt) {
+			must_refcnt = 0;
+			if (qeth_eddp_buf_ref_context(buf, ctx)) {
+				PRINT_WARN("no memory to create eddp context "
+					   "reference\n");
+				goto out_check;
+			}
+		}
+		buffer = buf->buffer;
+		/* fill one skb into buffer */
+		for (i = 0; i < ctx->elements_per_skb; ++i) {
+			if (ctx->elements[element].length != 0) {
+				buffer->element[buf->next_element_to_fill].
+				addr = ctx->elements[element].addr;
+				buffer->element[buf->next_element_to_fill].
+				length = ctx->elements[element].length;
+				buffer->element[buf->next_element_to_fill].
+				flags = ctx->elements[element].flags;
+				buf->next_element_to_fill++;
+			}
+			element++;
+			elements--;
+		}
+	}
+out_check:
+	if (!queue->do_pack) {
+		QETH_DBF_TEXT(trace, 6, "fillbfnp");
+		/* set state to PRIMED -> will be flushed */
+		if (buf->next_element_to_fill > 0) {
+			atomic_set(&buf->state, QETH_QDIO_BUF_PRIMED);
+			flush_cnt++;
+		}
+	} else {
+		if (queue->card->options.performance_stats)
+			queue->card->perf_stats.skbs_sent_pack++;
+		QETH_DBF_TEXT(trace, 6, "fillbfpa");
+		if (buf->next_element_to_fill >=
+				QETH_MAX_BUFFER_ELEMENTS(queue->card)) {
+			/*
+			 * packed buffer if full -> set state PRIMED
+			 * -> will be flushed
+			 */
+			atomic_set(&buf->state, QETH_QDIO_BUF_PRIMED);
+			flush_cnt++;
+		}
+	}
+out:
+	return flush_cnt;
+}
+
+static void qeth_eddp_create_segment_hdrs(struct qeth_eddp_context *ctx,
+		struct qeth_eddp_data *eddp, int data_len)
+{
+	u8 *page;
+	int page_remainder;
+	int page_offset;
+	int pkt_len;
+	struct qeth_eddp_element *element;
+
+	QETH_DBF_TEXT(trace, 5, "eddpcrsh");
+	page = ctx->pages[ctx->offset >> PAGE_SHIFT];
+	page_offset = ctx->offset % PAGE_SIZE;
+	element = &ctx->elements[ctx->num_elements];
+	pkt_len = eddp->nhl + eddp->thl + data_len;
+	/* FIXME: layer2 and VLAN !!! */
+	if (eddp->qh.hdr.l2.id == QETH_HEADER_TYPE_LAYER2)
+		pkt_len += ETH_HLEN;
+	if (eddp->mac.h_proto == __constant_htons(ETH_P_8021Q))
+		pkt_len += VLAN_HLEN;
+	/* does complete packet fit in current page ? */
+	page_remainder = PAGE_SIZE - page_offset;
+	if (page_remainder < (sizeof(struct qeth_hdr) + pkt_len)) {
+		/* no -> go to start of next page */
+		ctx->offset += page_remainder;
+		page = ctx->pages[ctx->offset >> PAGE_SHIFT];
+		page_offset = 0;
+	}
+	memcpy(page + page_offset, &eddp->qh, sizeof(struct qeth_hdr));
+	element->addr = page + page_offset;
+	element->length = sizeof(struct qeth_hdr);
+	ctx->offset += sizeof(struct qeth_hdr);
+	page_offset += sizeof(struct qeth_hdr);
+	/* add mac header (?) */
+	if (eddp->qh.hdr.l2.id == QETH_HEADER_TYPE_LAYER2) {
+		memcpy(page + page_offset, &eddp->mac, ETH_HLEN);
+		element->length += ETH_HLEN;
+		ctx->offset += ETH_HLEN;
+		page_offset += ETH_HLEN;
+	}
+	/* add VLAN tag */
+	if (eddp->mac.h_proto == __constant_htons(ETH_P_8021Q)) {
+		memcpy(page + page_offset, &eddp->vlan, VLAN_HLEN);
+		element->length += VLAN_HLEN;
+		ctx->offset += VLAN_HLEN;
+		page_offset += VLAN_HLEN;
+	}
+	/* add network header */
+	memcpy(page + page_offset, (u8 *)&eddp->nh, eddp->nhl);
+	element->length += eddp->nhl;
+	eddp->nh_in_ctx = page + page_offset;
+	ctx->offset += eddp->nhl;
+	page_offset += eddp->nhl;
+	/* add transport header */
+	memcpy(page + page_offset, (u8 *)&eddp->th, eddp->thl);
+	element->length += eddp->thl;
+	eddp->th_in_ctx = page + page_offset;
+	ctx->offset += eddp->thl;
+}
+
+static void qeth_eddp_copy_data_tcp(char *dst, struct qeth_eddp_data *eddp,
+		int len, __wsum *hcsum)
+{
+	struct skb_frag_struct *frag;
+	int left_in_frag;
+	int copy_len;
+	u8 *src;
+
+	QETH_DBF_TEXT(trace, 5, "eddpcdtc");
+	if (skb_shinfo(eddp->skb)->nr_frags == 0) {
+		skb_copy_from_linear_data_offset(eddp->skb, eddp->skb_offset,
+						 dst, len);
+		*hcsum = csum_partial(eddp->skb->data + eddp->skb_offset, len,
+				      *hcsum);
+		eddp->skb_offset += len;
+	} else {
+		while (len > 0) {
+			if (eddp->frag < 0) {
+				/* we're in skb->data */
+				left_in_frag = (eddp->skb->len -
+						eddp->skb->data_len)
+						- eddp->skb_offset;
+				src = eddp->skb->data + eddp->skb_offset;
+			} else {
+				frag = &skb_shinfo(eddp->skb)->frags[
+					eddp->frag];
+				left_in_frag = frag->size - eddp->frag_offset;
+				src = (u8 *)((page_to_pfn(frag->page) <<
+					PAGE_SHIFT) + frag->page_offset +
+					eddp->frag_offset);
+			}
+			if (left_in_frag <= 0) {
+				eddp->frag++;
+				eddp->frag_offset = 0;
+				continue;
+			}
+			copy_len = min(left_in_frag, len);
+			memcpy(dst, src, copy_len);
+			*hcsum = csum_partial(src, copy_len, *hcsum);
+			dst += copy_len;
+			eddp->frag_offset += copy_len;
+			eddp->skb_offset += copy_len;
+			len -= copy_len;
+		}
+	}
+}
+
+static void qeth_eddp_create_segment_data_tcp(struct qeth_eddp_context *ctx,
+		struct qeth_eddp_data *eddp, int data_len, __wsum hcsum)
+{
+	u8 *page;
+	int page_remainder;
+	int page_offset;
+	struct qeth_eddp_element *element;
+	int first_lap = 1;
+
+	QETH_DBF_TEXT(trace, 5, "eddpcsdt");
+	page = ctx->pages[ctx->offset >> PAGE_SHIFT];
+	page_offset = ctx->offset % PAGE_SIZE;
+	element = &ctx->elements[ctx->num_elements];
+	while (data_len) {
+		page_remainder = PAGE_SIZE - page_offset;
+		if (page_remainder < data_len) {
+			qeth_eddp_copy_data_tcp(page + page_offset, eddp,
+						page_remainder, &hcsum);
+			element->length += page_remainder;
+			if (first_lap)
+				element->flags = SBAL_FLAGS_FIRST_FRAG;
+			else
+				element->flags = SBAL_FLAGS_MIDDLE_FRAG;
+			ctx->num_elements++;
+			element++;
+			data_len -= page_remainder;
+			ctx->offset += page_remainder;
+			page = ctx->pages[ctx->offset >> PAGE_SHIFT];
+			page_offset = 0;
+			element->addr = page + page_offset;
+		} else {
+			qeth_eddp_copy_data_tcp(page + page_offset, eddp,
+						data_len, &hcsum);
+			element->length += data_len;
+			if (!first_lap)
+				element->flags = SBAL_FLAGS_LAST_FRAG;
+			ctx->num_elements++;
+			ctx->offset += data_len;
+			data_len = 0;
+		}
+		first_lap = 0;
+	}
+	((struct tcphdr *)eddp->th_in_ctx)->check = csum_fold(hcsum);
+}
+
+static __wsum qeth_eddp_check_tcp4_hdr(struct qeth_eddp_data *eddp,
+		int data_len)
+{
+	__wsum phcsum; /* pseudo header checksum */
+
+	QETH_DBF_TEXT(trace, 5, "eddpckt4");
+	eddp->th.tcp.h.check = 0;
+	/* compute pseudo header checksum */
+	phcsum = csum_tcpudp_nofold(eddp->nh.ip4.h.saddr, eddp->nh.ip4.h.daddr,
+				    eddp->thl + data_len, IPPROTO_TCP, 0);
+	/* compute checksum of tcp header */
+	return csum_partial((u8 *)&eddp->th, eddp->thl, phcsum);
+}
+
+static __wsum qeth_eddp_check_tcp6_hdr(struct qeth_eddp_data *eddp,
+		int data_len)
+{
+	__be32 proto;
+	__wsum phcsum; /* pseudo header checksum */
+
+	QETH_DBF_TEXT(trace, 5, "eddpckt6");
+	eddp->th.tcp.h.check = 0;
+	/* compute pseudo header checksum */
+	phcsum = csum_partial((u8 *)&eddp->nh.ip6.h.saddr,
+			      sizeof(struct in6_addr), 0);
+	phcsum = csum_partial((u8 *)&eddp->nh.ip6.h.daddr,
+			      sizeof(struct in6_addr), phcsum);
+	proto = htonl(IPPROTO_TCP);
+	phcsum = csum_partial((u8 *)&proto, sizeof(u32), phcsum);
+	return phcsum;
+}
+
+static struct qeth_eddp_data *qeth_eddp_create_eddp_data(struct qeth_hdr *qh,
+		u8 *nh, u8 nhl, u8 *th, u8 thl)
+{
+	struct qeth_eddp_data *eddp;
+
+	QETH_DBF_TEXT(trace, 5, "eddpcrda");
+	eddp = kzalloc(sizeof(struct qeth_eddp_data), GFP_ATOMIC);
+	if (eddp) {
+		eddp->nhl = nhl;
+		eddp->thl = thl;
+		memcpy(&eddp->qh, qh, sizeof(struct qeth_hdr));
+		memcpy(&eddp->nh, nh, nhl);
+		memcpy(&eddp->th, th, thl);
+		eddp->frag = -1; /* initially we're in skb->data */
+	}
+	return eddp;
+}
+
+static void __qeth_eddp_fill_context_tcp(struct qeth_eddp_context *ctx,
+		struct qeth_eddp_data *eddp)
+{
+	struct tcphdr *tcph;
+	int data_len;
+	__wsum hcsum;
+
+	QETH_DBF_TEXT(trace, 5, "eddpftcp");
+	eddp->skb_offset = sizeof(struct qeth_hdr) + eddp->nhl + eddp->thl;
+	if (eddp->qh.hdr.l2.id == QETH_HEADER_TYPE_LAYER2) {
+		eddp->skb_offset += sizeof(struct ethhdr);
+		if (eddp->mac.h_proto == __constant_htons(ETH_P_8021Q))
+			eddp->skb_offset += VLAN_HLEN;
+	}
+	tcph = tcp_hdr(eddp->skb);
+	while (eddp->skb_offset < eddp->skb->len) {
+		data_len = min((int)skb_shinfo(eddp->skb)->gso_size,
+			       (int)(eddp->skb->len - eddp->skb_offset));
+		/* prepare qdio hdr */
+		if (eddp->qh.hdr.l2.id == QETH_HEADER_TYPE_LAYER2) {
+			eddp->qh.hdr.l2.pkt_length = data_len + ETH_HLEN +
+						     eddp->nhl + eddp->thl;
+			if (eddp->mac.h_proto == __constant_htons(ETH_P_8021Q))
+				eddp->qh.hdr.l2.pkt_length += VLAN_HLEN;
+		} else
+			eddp->qh.hdr.l3.length = data_len + eddp->nhl +
+						 eddp->thl;
+		/* prepare ip hdr */
+		if (eddp->skb->protocol == htons(ETH_P_IP)) {
+			eddp->nh.ip4.h.tot_len = htons(data_len + eddp->nhl +
+						 eddp->thl);
+			eddp->nh.ip4.h.check = 0;
+			eddp->nh.ip4.h.check =
+				ip_fast_csum((u8 *)&eddp->nh.ip4.h,
+						eddp->nh.ip4.h.ihl);
+		} else
+			eddp->nh.ip6.h.payload_len = htons(data_len +
+								eddp->thl);
+		/* prepare tcp hdr */
+		if (data_len == (eddp->skb->len - eddp->skb_offset)) {
+			/* last segment -> set FIN and PSH flags */
+			eddp->th.tcp.h.fin = tcph->fin;
+			eddp->th.tcp.h.psh = tcph->psh;
+		}
+		if (eddp->skb->protocol == htons(ETH_P_IP))
+			hcsum = qeth_eddp_check_tcp4_hdr(eddp, data_len);
+		else
+			hcsum = qeth_eddp_check_tcp6_hdr(eddp, data_len);
+		/* fill the next segment into the context */
+		qeth_eddp_create_segment_hdrs(ctx, eddp, data_len);
+		qeth_eddp_create_segment_data_tcp(ctx, eddp, data_len, hcsum);
+		if (eddp->skb_offset >= eddp->skb->len)
+			break;
+		/* prepare headers for next round */
+		if (eddp->skb->protocol == htons(ETH_P_IP))
+			eddp->nh.ip4.h.id = htons(ntohs(eddp->nh.ip4.h.id) + 1);
+		eddp->th.tcp.h.seq = htonl(ntohl(eddp->th.tcp.h.seq) +
+			data_len);
+	}
+}
+
+static int qeth_eddp_fill_context_tcp(struct qeth_eddp_context *ctx,
+		struct sk_buff *skb, struct qeth_hdr *qhdr)
+{
+	struct qeth_eddp_data *eddp = NULL;
+
+	QETH_DBF_TEXT(trace, 5, "eddpficx");
+	/* create our segmentation headers and copy original headers */
+	if (skb->protocol == htons(ETH_P_IP))
+		eddp = qeth_eddp_create_eddp_data(qhdr,
+						  skb_network_header(skb),
+						  ip_hdrlen(skb),
+						  skb_transport_header(skb),
+						  tcp_hdrlen(skb));
+	else
+		eddp = qeth_eddp_create_eddp_data(qhdr,
+						  skb_network_header(skb),
+						  sizeof(struct ipv6hdr),
+						  skb_transport_header(skb),
+						  tcp_hdrlen(skb));
+
+	if (eddp == NULL) {
+		QETH_DBF_TEXT(trace, 2, "eddpfcnm");
+		return -ENOMEM;
+	}
+	if (qhdr->hdr.l2.id == QETH_HEADER_TYPE_LAYER2) {
+		skb_set_mac_header(skb, sizeof(struct qeth_hdr));
+		memcpy(&eddp->mac, eth_hdr(skb), ETH_HLEN);
+		if (eddp->mac.h_proto == __constant_htons(ETH_P_8021Q)) {
+			eddp->vlan[0] = skb->protocol;
+			eddp->vlan[1] = htons(vlan_tx_tag_get(skb));
+		}
+	}
+	/* the next flags will only be set on the last segment */
+	eddp->th.tcp.h.fin = 0;
+	eddp->th.tcp.h.psh = 0;
+	eddp->skb = skb;
+	/* begin segmentation and fill context */
+	__qeth_eddp_fill_context_tcp(ctx, eddp);
+	kfree(eddp);
+	return 0;
+}
+
+static void qeth_eddp_calc_num_pages(struct qeth_eddp_context *ctx,
+		struct sk_buff *skb, int hdr_len)
+{
+	int skbs_per_page;
+
+	QETH_DBF_TEXT(trace, 5, "eddpcanp");
+	/* can we put multiple skbs in one page? */
+	skbs_per_page = PAGE_SIZE / (skb_shinfo(skb)->gso_size + hdr_len);
+	if (skbs_per_page > 1) {
+		ctx->num_pages = (skb_shinfo(skb)->gso_segs + 1) /
+				 skbs_per_page + 1;
+		ctx->elements_per_skb = 1;
+	} else {
+		/* no -> how many elements per skb? */
+		ctx->elements_per_skb = (skb_shinfo(skb)->gso_size + hdr_len +
+				     PAGE_SIZE) >> PAGE_SHIFT;
+		ctx->num_pages = ctx->elements_per_skb *
+				 (skb_shinfo(skb)->gso_segs + 1);
+	}
+	ctx->num_elements = ctx->elements_per_skb *
+			    (skb_shinfo(skb)->gso_segs + 1);
+}
+
+static struct qeth_eddp_context *qeth_eddp_create_context_generic(
+		struct qeth_card *card, struct sk_buff *skb, int hdr_len)
+{
+	struct qeth_eddp_context *ctx = NULL;
+	u8 *addr;
+	int i;
+
+	QETH_DBF_TEXT(trace, 5, "creddpcg");
+	/* create the context and allocate pages */
+	ctx = kzalloc(sizeof(struct qeth_eddp_context), GFP_ATOMIC);
+	if (ctx == NULL) {
+		QETH_DBF_TEXT(trace, 2, "ceddpcn1");
+		return NULL;
+	}
+	ctx->type = QETH_LARGE_SEND_EDDP;
+	qeth_eddp_calc_num_pages(ctx, skb, hdr_len);
+	if (ctx->elements_per_skb > QETH_MAX_BUFFER_ELEMENTS(card)) {
+		QETH_DBF_TEXT(trace, 2, "ceddpcis");
+		kfree(ctx);
+		return NULL;
+	}
+	ctx->pages = kcalloc(ctx->num_pages, sizeof(u8 *), GFP_ATOMIC);
+	if (ctx->pages == NULL) {
+		QETH_DBF_TEXT(trace, 2, "ceddpcn2");
+		kfree(ctx);
+		return NULL;
+	}
+	for (i = 0; i < ctx->num_pages; ++i) {
+		addr = (u8 *)get_zeroed_page(GFP_ATOMIC);
+		if (addr == NULL) {
+			QETH_DBF_TEXT(trace, 2, "ceddpcn3");
+			ctx->num_pages = i;
+			qeth_eddp_free_context(ctx);
+			return NULL;
+		}
+		ctx->pages[i] = addr;
+	}
+	ctx->elements = kcalloc(ctx->num_elements,
+				sizeof(struct qeth_eddp_element), GFP_ATOMIC);
+	if (ctx->elements == NULL) {
+		QETH_DBF_TEXT(trace, 2, "ceddpcn4");
+		qeth_eddp_free_context(ctx);
+		return NULL;
+	}
+	/* reset num_elements; will be incremented again in fill_buffer to
+	 * reflect number of actually used elements */
+	ctx->num_elements = 0;
+	return ctx;
+}
+
+static struct qeth_eddp_context *qeth_eddp_create_context_tcp(
+		struct qeth_card *card, struct sk_buff *skb,
+		struct qeth_hdr *qhdr)
+{
+	struct qeth_eddp_context *ctx = NULL;
+
+	QETH_DBF_TEXT(trace, 5, "creddpct");
+	if (skb->protocol == htons(ETH_P_IP))
+		ctx = qeth_eddp_create_context_generic(card, skb,
+						(sizeof(struct qeth_hdr) +
+						ip_hdrlen(skb) +
+						tcp_hdrlen(skb)));
+	else if (skb->protocol == htons(ETH_P_IPV6))
+		ctx = qeth_eddp_create_context_generic(card, skb,
+			sizeof(struct qeth_hdr) + sizeof(struct ipv6hdr) +
+			tcp_hdrlen(skb));
+	else
+		QETH_DBF_TEXT(trace, 2, "cetcpinv");
+
+	if (ctx == NULL) {
+		QETH_DBF_TEXT(trace, 2, "creddpnl");
+		return NULL;
+	}
+	if (qeth_eddp_fill_context_tcp(ctx, skb, qhdr)) {
+		QETH_DBF_TEXT(trace, 2, "ceddptfe");
+		qeth_eddp_free_context(ctx);
+		return NULL;
+	}
+	atomic_set(&ctx->refcnt, 1);
+	return ctx;
+}
+
+struct qeth_eddp_context *qeth_eddp_create_context(struct qeth_card *card,
+		struct sk_buff *skb, struct qeth_hdr *qhdr,
+		unsigned char sk_protocol)
+{
+	QETH_DBF_TEXT(trace, 5, "creddpc");
+	switch (sk_protocol) {
+	case IPPROTO_TCP:
+		return qeth_eddp_create_context_tcp(card, skb, qhdr);
+	default:
+		QETH_DBF_TEXT(trace, 2, "eddpinvp");
+	}
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(qeth_eddp_create_context);
+
+void qeth_tso_fill_header(struct qeth_card *card, struct qeth_hdr *qhdr,
+		struct sk_buff *skb)
+{
+	struct qeth_hdr_tso *hdr = (struct qeth_hdr_tso *)qhdr;
+	struct tcphdr *tcph = tcp_hdr(skb);
+	struct iphdr *iph = ip_hdr(skb);
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+
+	QETH_DBF_TEXT(trace, 5, "tsofhdr");
+
+	/*fix header to TSO values ...*/
+	hdr->hdr.hdr.l3.id = QETH_HEADER_TYPE_TSO;
+	/*set values which are fix for the first approach ...*/
+	hdr->ext.hdr_tot_len = (__u16) sizeof(struct qeth_hdr_ext_tso);
+	hdr->ext.imb_hdr_no  = 1;
+	hdr->ext.hdr_type    = 1;
+	hdr->ext.hdr_version = 1;
+	hdr->ext.hdr_len     = 28;
+	/*insert non-fix values */
+	hdr->ext.mss = skb_shinfo(skb)->gso_size;
+	hdr->ext.dg_hdr_len = (__u16)(iph->ihl*4 + tcph->doff*4);
+	hdr->ext.payload_len = (__u16)(skb->len - hdr->ext.dg_hdr_len -
+				       sizeof(struct qeth_hdr_tso));
+	tcph->check = 0;
+	if (skb->protocol == ETH_P_IPV6) {
+		ip6h->payload_len = 0;
+		tcph->check = ~csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
+					       0, IPPROTO_TCP, 0);
+	} else {
+		/*OSA want us to set these values ...*/
+		tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+					 0, IPPROTO_TCP, 0);
+		iph->tot_len = 0;
+		iph->check = 0;
+	}
+}
+EXPORT_SYMBOL_GPL(qeth_tso_fill_header);
+
+void qeth_tx_csum(struct sk_buff *skb)
+{
+	int tlen;
+	if (skb->protocol == htons(ETH_P_IP)) {
+		tlen = ntohs(ip_hdr(skb)->tot_len) - (ip_hdr(skb)->ihl << 2);
+		switch (ip_hdr(skb)->protocol) {
+		case IPPROTO_TCP:
+			tcp_hdr(skb)->check = 0;
+			tcp_hdr(skb)->check = csum_tcpudp_magic(
+				ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
+				tlen, ip_hdr(skb)->protocol,
+				skb_checksum(skb, skb_transport_offset(skb),
+					tlen, 0));
+			break;
+		case IPPROTO_UDP:
+			udp_hdr(skb)->check = 0;
+			udp_hdr(skb)->check = csum_tcpudp_magic(
+				ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
+				tlen, ip_hdr(skb)->protocol,
+				skb_checksum(skb, skb_transport_offset(skb),
+					tlen, 0));
+			break;
+		}
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		switch (ipv6_hdr(skb)->nexthdr) {
+		case IPPROTO_TCP:
+			tcp_hdr(skb)->check = 0;
+			tcp_hdr(skb)->check = csum_ipv6_magic(
+				&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
+				ipv6_hdr(skb)->payload_len,
+				ipv6_hdr(skb)->nexthdr,
+				skb_checksum(skb, skb_transport_offset(skb),
+					ipv6_hdr(skb)->payload_len, 0));
+			break;
+		case IPPROTO_UDP:
+			udp_hdr(skb)->check = 0;
+			udp_hdr(skb)->check = csum_ipv6_magic(
+				&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
+				ipv6_hdr(skb)->payload_len,
+				ipv6_hdr(skb)->nexthdr,
+				skb_checksum(skb, skb_transport_offset(skb),
+					ipv6_hdr(skb)->payload_len, 0));
+			break;
+		}
+	}
+}
+EXPORT_SYMBOL_GPL(qeth_tx_csum);
Index: my_git/drivers/s390/net/qeth_core_offl.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ my_git/drivers/s390/net/qeth_core_offl.h	2008-02-14 13:23:52.000000000 +0100
@@ -0,0 +1,76 @@
+/*
+ *  drivers/s390/net/qeth_core_offl.h
+ *
+ *    Copyright IBM Corp. 2007
+ *    Author(s): Thomas Spatzier <tspat@de.ibm.com>,
+ *		 Frank Blaschka <frank.blaschka@de.ibm.com>
+ */
+
+#ifndef __QETH_CORE_OFFL_H__
+#define __QETH_CORE_OFFL_H__
+
+struct qeth_eddp_element {
+	u32 flags;
+	u32 length;
+	void *addr;
+};
+
+struct qeth_eddp_context {
+	atomic_t refcnt;
+	enum qeth_large_send_types type;
+	int num_pages;			    /* # of allocated pages */
+	u8 **pages;			    /* pointers to pages */
+	int offset;			    /* offset in ctx during creation */
+	int num_elements;		    /* # of required 'SBALEs' */
+	struct qeth_eddp_element *elements; /* array of 'SBALEs' */
+	int elements_per_skb;		    /* # of 'SBALEs' per skb **/
+};
+
+struct qeth_eddp_context_reference {
+	struct list_head list;
+	struct qeth_eddp_context *ctx;
+};
+
+struct qeth_eddp_data {
+	struct qeth_hdr qh;
+	struct ethhdr mac;
+	__be16 vlan[2];
+	union {
+		struct {
+			struct iphdr h;
+			u8 options[40];
+		} ip4;
+		struct {
+			struct ipv6hdr h;
+		} ip6;
+	} nh;
+	u8 nhl;
+	void *nh_in_ctx;	/* address of nh within the ctx */
+	union {
+		struct {
+			struct tcphdr h;
+			u8 options[40];
+		} tcp;
+	} th;
+	u8 thl;
+	void *th_in_ctx;	/* address of th within the ctx */
+	struct sk_buff *skb;
+	int skb_offset;
+	int frag;
+	int frag_offset;
+} __attribute__ ((packed));
+
+extern struct qeth_eddp_context *qeth_eddp_create_context(struct qeth_card *,
+		 struct sk_buff *, struct qeth_hdr *, unsigned char);
+extern void qeth_eddp_put_context(struct qeth_eddp_context *);
+extern int qeth_eddp_fill_buffer(struct qeth_qdio_out_q *,
+		struct qeth_eddp_context *, int);
+extern void qeth_eddp_buf_release_contexts(struct qeth_qdio_out_buffer *);
+extern int qeth_eddp_check_buffers_for_context(struct qeth_qdio_out_q *,
+		struct qeth_eddp_context *);
+
+void qeth_tso_fill_header(struct qeth_card *, struct qeth_hdr *,
+		struct sk_buff *);
+void qeth_tx_csum(struct sk_buff *skb);
+
+#endif /* __QETH_CORE_EDDP_H__ */
Index: my_git/drivers/s390/net/qeth_core_sys.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ my_git/drivers/s390/net/qeth_core_sys.c	2008-02-14 13:23:52.000000000 +0100
@@ -0,0 +1,651 @@
+/*
+ *  drivers/s390/net/qeth_core_sys.c
+ *
+ *    Copyright IBM Corp. 2007
+ *    Author(s): Utz Bacher <utz.bacher@de.ibm.com>,
+ *		 Frank Pavlic <fpavlic@de.ibm.com>,
+ *		 Thomas Spatzier <tspat@de.ibm.com>,
+ *		 Frank Blaschka <frank.blaschka@de.ibm.com>
+ */
+
+#include <linux/list.h>
+#include <linux/rwsem.h>
+#include <asm/ebcdic.h>
+
+#include "qeth_core.h"
+
+static ssize_t qeth_dev_state_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	if (!card)
+		return -EINVAL;
+
+	switch (card->state) {
+	case CARD_STATE_DOWN:
+		return sprintf(buf, "DOWN\n");
+	case CARD_STATE_HARDSETUP:
+		return sprintf(buf, "HARDSETUP\n");
+	case CARD_STATE_SOFTSETUP:
+		return sprintf(buf, "SOFTSETUP\n");
+	case CARD_STATE_UP:
+		if (card->lan_online)
+		return sprintf(buf, "UP (LAN ONLINE)\n");
+		else
+			return sprintf(buf, "UP (LAN OFFLINE)\n");
+	case CARD_STATE_RECOVER:
+		return sprintf(buf, "RECOVER\n");
+	default:
+		return sprintf(buf, "UNKNOWN\n");
+	}
+}
+
+static DEVICE_ATTR(state, 0444, qeth_dev_state_show, NULL);
+
+static ssize_t qeth_dev_chpid_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%02X\n", card->info.chpid);
+}
+
+static DEVICE_ATTR(chpid, 0444, qeth_dev_chpid_show, NULL);
+
+static ssize_t qeth_dev_if_name_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	if (!card)
+		return -EINVAL;
+	return sprintf(buf, "%s\n", QETH_CARD_IFNAME(card));
+}
+
+static DEVICE_ATTR(if_name, 0444, qeth_dev_if_name_show, NULL);
+
+static ssize_t qeth_dev_card_type_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%s\n", qeth_get_cardname_short(card));
+}
+
+static DEVICE_ATTR(card_type, 0444, qeth_dev_card_type_show, NULL);
+
+static inline const char *qeth_get_bufsize_str(struct qeth_card *card)
+{
+	if (card->qdio.in_buf_size == 16384)
+		return "16k";
+	else if (card->qdio.in_buf_size == 24576)
+		return "24k";
+	else if (card->qdio.in_buf_size == 32768)
+		return "32k";
+	else if (card->qdio.in_buf_size == 40960)
+		return "40k";
+	else
+		return "64k";
+}
+
+static ssize_t qeth_dev_inbuf_size_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%s\n", qeth_get_bufsize_str(card));
+}
+
+static DEVICE_ATTR(inbuf_size, 0444, qeth_dev_inbuf_size_show, NULL);
+
+static ssize_t qeth_dev_portno_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%i\n", card->info.portno);
+}
+
+static ssize_t qeth_dev_portno_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+	unsigned int portno;
+
+	if (!card)
+		return -EINVAL;
+
+	if ((card->state != CARD_STATE_DOWN) &&
+	    (card->state != CARD_STATE_RECOVER))
+		return -EPERM;
+
+	portno = simple_strtoul(buf, &tmp, 16);
+	if (portno > QETH_MAX_PORTNO) {
+		PRINT_WARN("portno 0x%X is out of range\n", portno);
+		return -EINVAL;
+	}
+
+	card->info.portno = portno;
+	return count;
+}
+
+static DEVICE_ATTR(portno, 0644, qeth_dev_portno_show, qeth_dev_portno_store);
+
+static ssize_t qeth_dev_portname_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char portname[9] = {0, };
+
+	if (!card)
+		return -EINVAL;
+
+	if (card->info.portname_required) {
+		memcpy(portname, card->info.portname + 1, 8);
+		EBCASC(portname, 8);
+		return sprintf(buf, "%s\n", portname);
+	} else
+		return sprintf(buf, "no portname required\n");
+}
+
+static ssize_t qeth_dev_portname_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+	int i;
+
+	if (!card)
+		return -EINVAL;
+
+	if ((card->state != CARD_STATE_DOWN) &&
+	    (card->state != CARD_STATE_RECOVER))
+		return -EPERM;
+
+	tmp = strsep((char **) &buf, "\n");
+	if ((strlen(tmp) > 8) || (strlen(tmp) == 0))
+		return -EINVAL;
+
+	card->info.portname[0] = strlen(tmp);
+	/* for beauty reasons */
+	for (i = 1; i < 9; i++)
+		card->info.portname[i] = ' ';
+	strcpy(card->info.portname + 1, tmp);
+	ASCEBC(card->info.portname + 1, 8);
+
+	return count;
+}
+
+static DEVICE_ATTR(portname, 0644, qeth_dev_portname_show,
+		qeth_dev_portname_store);
+
+static ssize_t qeth_dev_prioqing_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	switch (card->qdio.do_prio_queueing) {
+	case QETH_PRIO_Q_ING_PREC:
+		return sprintf(buf, "%s\n", "by precedence");
+	case QETH_PRIO_Q_ING_TOS:
+		return sprintf(buf, "%s\n", "by type of service");
+	default:
+		return sprintf(buf, "always queue %i\n",
+			       card->qdio.default_out_queue);
+	}
+}
+
+static ssize_t qeth_dev_prioqing_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+
+	if (!card)
+		return -EINVAL;
+
+	if ((card->state != CARD_STATE_DOWN) &&
+	    (card->state != CARD_STATE_RECOVER))
+		return -EPERM;
+
+	/* check if 1920 devices are supported ,
+	 * if though we have to permit priority queueing
+	 */
+	if (card->qdio.no_out_queues == 1) {
+		PRINT_WARN("Priority queueing disabled due "
+			   "to hardware limitations!\n");
+		card->qdio.do_prio_queueing = QETH_PRIOQ_DEFAULT;
+		return -EPERM;
+	}
+
+	tmp = strsep((char **) &buf, "\n");
+	if (!strcmp(tmp, "prio_queueing_prec"))
+		card->qdio.do_prio_queueing = QETH_PRIO_Q_ING_PREC;
+	else if (!strcmp(tmp, "prio_queueing_tos"))
+		card->qdio.do_prio_queueing = QETH_PRIO_Q_ING_TOS;
+	else if (!strcmp(tmp, "no_prio_queueing:0")) {
+		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
+		card->qdio.default_out_queue = 0;
+	} else if (!strcmp(tmp, "no_prio_queueing:1")) {
+		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
+		card->qdio.default_out_queue = 1;
+	} else if (!strcmp(tmp, "no_prio_queueing:2")) {
+		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
+		card->qdio.default_out_queue = 2;
+	} else if (!strcmp(tmp, "no_prio_queueing:3")) {
+		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
+		card->qdio.default_out_queue = 3;
+	} else if (!strcmp(tmp, "no_prio_queueing")) {
+		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
+		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
+	} else {
+		PRINT_WARN("Unknown queueing type '%s'\n", tmp);
+		return -EINVAL;
+	}
+	return count;
+}
+
+static DEVICE_ATTR(priority_queueing, 0644, qeth_dev_prioqing_show,
+		qeth_dev_prioqing_store);
+
+static ssize_t qeth_dev_bufcnt_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%i\n", card->qdio.in_buf_pool.buf_count);
+}
+
+static ssize_t qeth_dev_bufcnt_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+	int cnt, old_cnt;
+	int rc;
+
+	if (!card)
+		return -EINVAL;
+
+	if ((card->state != CARD_STATE_DOWN) &&
+	    (card->state != CARD_STATE_RECOVER))
+		return -EPERM;
+
+	old_cnt = card->qdio.in_buf_pool.buf_count;
+	cnt = simple_strtoul(buf, &tmp, 10);
+	cnt = (cnt < QETH_IN_BUF_COUNT_MIN) ? QETH_IN_BUF_COUNT_MIN :
+		((cnt > QETH_IN_BUF_COUNT_MAX) ? QETH_IN_BUF_COUNT_MAX : cnt);
+	if (old_cnt != cnt) {
+		rc = qeth_realloc_buffer_pool(card, cnt);
+		if (rc)
+			PRINT_WARN("Error (%d) while setting "
+				   "buffer count.\n", rc);
+	}
+	return count;
+}
+
+static DEVICE_ATTR(buffer_count, 0644, qeth_dev_bufcnt_show,
+		qeth_dev_bufcnt_store);
+
+static ssize_t qeth_dev_recover_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+	int i;
+
+	if (!card)
+		return -EINVAL;
+
+	if (card->state != CARD_STATE_UP)
+		return -EPERM;
+
+	i = simple_strtoul(buf, &tmp, 16);
+	if (i == 1)
+		qeth_schedule_recovery(card);
+
+	return count;
+}
+
+static DEVICE_ATTR(recover, 0200, NULL, qeth_dev_recover_store);
+
+static ssize_t qeth_dev_performance_stats_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%i\n", card->options.performance_stats ? 1:0);
+}
+
+static ssize_t qeth_dev_performance_stats_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+	int i;
+
+	if (!card)
+		return -EINVAL;
+
+	i = simple_strtoul(buf, &tmp, 16);
+	if ((i == 0) || (i == 1)) {
+		if (i == card->options.performance_stats)
+			return count;
+		card->options.performance_stats = i;
+		if (i == 0)
+			memset(&card->perf_stats, 0,
+				sizeof(struct qeth_perf_stats));
+		card->perf_stats.initial_rx_packets = card->stats.rx_packets;
+		card->perf_stats.initial_tx_packets = card->stats.tx_packets;
+	} else {
+		PRINT_WARN("performance_stats: write 0 or 1 to this file!\n");
+		return -EINVAL;
+	}
+	return count;
+}
+
+static DEVICE_ATTR(performance_stats, 0644, qeth_dev_performance_stats_show,
+		   qeth_dev_performance_stats_store);
+
+static ssize_t qeth_dev_layer2_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%i\n", card->options.layer2 ? 1:0);
+}
+
+static ssize_t qeth_dev_layer2_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+	int i, rc;
+	enum qeth_discipline_id newdis;
+
+	if (!card)
+		return -EINVAL;
+
+	if (((card->state != CARD_STATE_DOWN) &&
+	     (card->state != CARD_STATE_RECOVER)))
+		return -EPERM;
+
+	i = simple_strtoul(buf, &tmp, 16);
+	switch (i) {
+	case 0:
+		newdis = QETH_DISCIPLINE_LAYER3;
+		break;
+	case 1:
+		newdis = QETH_DISCIPLINE_LAYER2;
+		break;
+	default:
+		PRINT_WARN("layer2: write 0 or 1 to this file!\n");
+		return -EINVAL;
+	}
+
+	if (card->options.layer2 == newdis) {
+		return count;
+	} else {
+		if (card->discipline.ccwgdriver) {
+			card->discipline.ccwgdriver->remove(card->gdev);
+			qeth_core_free_discipline(card);
+		}
+	}
+
+	rc = qeth_core_load_discipline(card, newdis);
+	if (rc)
+		return rc;
+
+	rc = card->discipline.ccwgdriver->probe(card->gdev);
+	if (rc)
+		return rc;
+	return count;
+}
+
+static DEVICE_ATTR(layer2, 0644, qeth_dev_layer2_show,
+		   qeth_dev_layer2_store);
+
+static ssize_t qeth_dev_large_send_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	switch (card->options.large_send) {
+	case QETH_LARGE_SEND_NO:
+		return sprintf(buf, "%s\n", "no");
+	case QETH_LARGE_SEND_EDDP:
+		return sprintf(buf, "%s\n", "EDDP");
+	case QETH_LARGE_SEND_TSO:
+		return sprintf(buf, "%s\n", "TSO");
+	default:
+		return sprintf(buf, "%s\n", "N/A");
+	}
+}
+
+static ssize_t qeth_dev_large_send_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	enum qeth_large_send_types type;
+	int rc = 0;
+	char *tmp;
+
+	if (!card)
+		return -EINVAL;
+	tmp = strsep((char **) &buf, "\n");
+	if (!strcmp(tmp, "no")) {
+		type = QETH_LARGE_SEND_NO;
+	} else if (!strcmp(tmp, "EDDP")) {
+		type = QETH_LARGE_SEND_EDDP;
+	} else if (!strcmp(tmp, "TSO")) {
+		type = QETH_LARGE_SEND_TSO;
+	} else {
+		PRINT_WARN("large_send: invalid mode %s!\n", tmp);
+		return -EINVAL;
+	}
+	if (card->options.large_send == type)
+		return count;
+	rc = qeth_set_large_send(card, type);
+	if (rc)
+		return rc;
+	return count;
+}
+
+static DEVICE_ATTR(large_send, 0644, qeth_dev_large_send_show,
+		   qeth_dev_large_send_store);
+
+static ssize_t qeth_dev_blkt_show(char *buf, struct qeth_card *card, int value)
+{
+
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%i\n", value);
+}
+
+static ssize_t qeth_dev_blkt_store(struct qeth_card *card,
+		const char *buf, size_t count, int *value, int max_value)
+{
+	char *tmp;
+	int i;
+
+	if (!card)
+		return -EINVAL;
+
+	if ((card->state != CARD_STATE_DOWN) &&
+	    (card->state != CARD_STATE_RECOVER))
+		return -EPERM;
+
+	i = simple_strtoul(buf, &tmp, 10);
+	if (i <= max_value) {
+		*value = i;
+	} else {
+		PRINT_WARN("blkt total time: write values between"
+			   " 0 and %d to this file!\n", max_value);
+		return -EINVAL;
+	}
+	return count;
+}
+
+static ssize_t qeth_dev_blkt_total_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	return qeth_dev_blkt_show(buf, card, card->info.blkt.time_total);
+}
+
+static ssize_t qeth_dev_blkt_total_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	return qeth_dev_blkt_store(card, buf, count,
+				   &card->info.blkt.time_total, 1000);
+}
+
+
+
+static DEVICE_ATTR(total, 0644, qeth_dev_blkt_total_show,
+		   qeth_dev_blkt_total_store);
+
+static ssize_t qeth_dev_blkt_inter_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	return qeth_dev_blkt_show(buf, card, card->info.blkt.inter_packet);
+}
+
+static ssize_t qeth_dev_blkt_inter_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	return qeth_dev_blkt_store(card, buf, count,
+				   &card->info.blkt.inter_packet, 100);
+}
+
+static DEVICE_ATTR(inter, 0644, qeth_dev_blkt_inter_show,
+		   qeth_dev_blkt_inter_store);
+
+static ssize_t qeth_dev_blkt_inter_jumbo_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	return qeth_dev_blkt_show(buf, card,
+				  card->info.blkt.inter_packet_jumbo);
+}
+
+static ssize_t qeth_dev_blkt_inter_jumbo_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	return qeth_dev_blkt_store(card, buf, count,
+				   &card->info.blkt.inter_packet_jumbo, 100);
+}
+
+static DEVICE_ATTR(inter_jumbo, 0644, qeth_dev_blkt_inter_jumbo_show,
+		   qeth_dev_blkt_inter_jumbo_store);
+
+static struct attribute *qeth_blkt_device_attrs[] = {
+	&dev_attr_total.attr,
+	&dev_attr_inter.attr,
+	&dev_attr_inter_jumbo.attr,
+	NULL,
+};
+
+static struct attribute_group qeth_device_blkt_group = {
+	.name = "blkt",
+	.attrs = qeth_blkt_device_attrs,
+};
+
+static struct attribute *qeth_device_attrs[] = {
+	&dev_attr_state.attr,
+	&dev_attr_chpid.attr,
+	&dev_attr_if_name.attr,
+	&dev_attr_card_type.attr,
+	&dev_attr_inbuf_size.attr,
+	&dev_attr_portno.attr,
+	&dev_attr_portname.attr,
+	&dev_attr_priority_queueing.attr,
+	&dev_attr_buffer_count.attr,
+	&dev_attr_recover.attr,
+	&dev_attr_performance_stats.attr,
+	&dev_attr_layer2.attr,
+	&dev_attr_large_send.attr,
+	NULL,
+};
+
+static struct attribute_group qeth_device_attr_group = {
+	.attrs = qeth_device_attrs,
+};
+
+static struct attribute *qeth_osn_device_attrs[] = {
+	&dev_attr_state.attr,
+	&dev_attr_chpid.attr,
+	&dev_attr_if_name.attr,
+	&dev_attr_card_type.attr,
+	&dev_attr_buffer_count.attr,
+	&dev_attr_recover.attr,
+	NULL,
+};
+
+static struct attribute_group qeth_osn_device_attr_group = {
+	.attrs = qeth_osn_device_attrs,
+};
+
+int qeth_core_create_device_attributes(struct device *dev)
+{
+	int ret;
+	ret = sysfs_create_group(&dev->kobj, &qeth_device_attr_group);
+	if (ret)
+		return ret;
+	ret = sysfs_create_group(&dev->kobj, &qeth_device_blkt_group);
+	if (ret)
+		sysfs_remove_group(&dev->kobj, &qeth_device_attr_group);
+
+	return 0;
+}
+
+void qeth_core_remove_device_attributes(struct device *dev)
+{
+	sysfs_remove_group(&dev->kobj, &qeth_device_attr_group);
+	sysfs_remove_group(&dev->kobj, &qeth_device_blkt_group);
+}
+
+int qeth_core_create_osn_attributes(struct device *dev)
+{
+	return sysfs_create_group(&dev->kobj, &qeth_osn_device_attr_group);
+}
+
+void qeth_core_remove_osn_attributes(struct device *dev)
+{
+	sysfs_remove_group(&dev->kobj, &qeth_osn_device_attr_group);
+	return;
+}
Index: my_git/drivers/s390/net/qeth_l2_main.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ my_git/drivers/s390/net/qeth_l2_main.c	2008-02-14 13:23:52.000000000 +0100
@@ -0,0 +1,1242 @@
+/*
+ *  drivers/s390/net/qeth_l2_main.c
+ *
+ *    Copyright IBM Corp. 2007
+ *    Author(s): Utz Bacher <utz.bacher@de.ibm.com>,
+ *		 Frank Pavlic <fpavlic@de.ibm.com>,
+ *		 Thomas Spatzier <tspat@de.ibm.com>,
+ *		 Frank Blaschka <frank.blaschka@de.ibm.com>
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/etherdevice.h>
+#include <linux/mii.h>
+#include <linux/ip.h>
+
+#include <asm/s390_rdev.h>
+
+#include "qeth_core.h"
+#include "qeth_core_offl.h"
+
+#define QETH_DBF_TEXT_(name, level, text...) \
+	do { \
+		if (qeth_dbf_passes(qeth_dbf_##name, level)) { \
+			char *dbf_txt_buf = get_cpu_var(qeth_l2_dbf_txt_buf); \
+			sprintf(dbf_txt_buf, text); \
+			debug_text_event(qeth_dbf_##name, level, dbf_txt_buf); \
+			put_cpu_var(qeth_l2_dbf_txt_buf); \
+		} \
+	} while (0)
+
+static DEFINE_PER_CPU(char[256], qeth_l2_dbf_txt_buf);
+
+static int qeth_l2_set_offline(struct ccwgroup_device *);
+static int qeth_l2_stop(struct net_device *);
+static int qeth_l2_send_delmac(struct qeth_card *, __u8 *);
+static int qeth_l2_send_setdelmac(struct qeth_card *, __u8 *,
+			   enum qeth_ipa_cmds,
+			   int (*reply_cb) (struct qeth_card *,
+					    struct qeth_reply*,
+					    unsigned long));
+static void qeth_l2_set_multicast_list(struct net_device *);
+static int qeth_l2_recover(void *);
+
+static int qeth_l2_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct qeth_card *card = netdev_priv(dev);
+	struct mii_ioctl_data *mii_data;
+	int rc = 0;
+
+	if (!card)
+		return -ENODEV;
+
+	if ((card->state != CARD_STATE_UP) &&
+		(card->state != CARD_STATE_SOFTSETUP))
+		return -ENODEV;
+
+	if (card->info.type == QETH_CARD_TYPE_OSN)
+		return -EPERM;
+
+	switch (cmd) {
+	case SIOC_QETH_ADP_SET_SNMP_CONTROL:
+		rc = qeth_snmp_command(card, rq->ifr_ifru.ifru_data);
+		break;
+	case SIOC_QETH_GET_CARD_TYPE:
+		if ((card->info.type == QETH_CARD_TYPE_OSAE) &&
+		    !card->info.guestlan)
+			return 1;
+		return 0;
+		break;
+	case SIOCGMIIPHY:
+		mii_data = if_mii(rq);
+		mii_data->phy_id = 0;
+		break;
+	case SIOCGMIIREG:
+		mii_data = if_mii(rq);
+		if (mii_data->phy_id != 0)
+			rc = -EINVAL;
+		else
+			mii_data->val_out = qeth_mdio_read(dev,
+				mii_data->phy_id, mii_data->reg_num);
+		break;
+	default:
+		rc = -EOPNOTSUPP;
+	}
+	if (rc)
+		QETH_DBF_TEXT_(trace, 2, "ioce%d", rc);
+	return rc;
+}
+
+static int qeth_l2_verify_dev(struct net_device *dev)
+{
+	struct qeth_card *card;
+	unsigned long flags;
+	int rc = 0;
+
+	read_lock_irqsave(&qeth_core_card_list.rwlock, flags);
+	list_for_each_entry(card, &qeth_core_card_list.list, list) {
+		if (card->dev == dev) {
+			rc = QETH_REAL_CARD;
+			break;
+		}
+	}
+	read_unlock_irqrestore(&qeth_core_card_list.rwlock, flags);
+
+	return rc;
+}
+
+static struct net_device *qeth_l2_netdev_by_devno(unsigned char *read_dev_no)
+{
+	struct qeth_card *card;
+	struct net_device *ndev;
+	unsigned char *readno;
+	__u16 temp_dev_no, card_dev_no;
+	char *endp;
+	unsigned long flags;
+
+	ndev = NULL;
+	memcpy(&temp_dev_no, read_dev_no, 2);
+	read_lock_irqsave(&qeth_core_card_list.rwlock, flags);
+	list_for_each_entry(card, &qeth_core_card_list.list, list) {
+		readno = CARD_RDEV_ID(card);
+		readno += (strlen(readno) - 4);
+		card_dev_no = simple_strtoul(readno, &endp, 16);
+		if (card_dev_no == temp_dev_no) {
+			ndev = card->dev;
+			break;
+		}
+	}
+	read_unlock_irqrestore(&qeth_core_card_list.rwlock, flags);
+	return ndev;
+}
+
+static int qeth_l2_send_setgroupmac_cb(struct qeth_card *card,
+				struct qeth_reply *reply,
+				unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+	__u8 *mac;
+
+	QETH_DBF_TEXT(trace, 2, "L2Sgmacb");
+	cmd = (struct qeth_ipa_cmd *) data;
+	mac = &cmd->data.setdelmac.mac[0];
+	/* MAC already registered, needed in couple/uncouple case */
+	if (cmd->hdr.return_code == 0x2005) {
+		PRINT_WARN("Group MAC %02x:%02x:%02x:%02x:%02x:%02x " \
+			  "already existing on %s \n",
+			  mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
+			  QETH_CARD_IFNAME(card));
+		cmd->hdr.return_code = 0;
+	}
+	if (cmd->hdr.return_code)
+		PRINT_ERR("Could not set group MAC " \
+			  "%02x:%02x:%02x:%02x:%02x:%02x on %s: %x\n",
+			  mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
+			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
+	return 0;
+}
+
+static int qeth_l2_send_setgroupmac(struct qeth_card *card, __u8 *mac)
+{
+	QETH_DBF_TEXT(trace, 2, "L2Sgmac");
+	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETGMAC,
+					  qeth_l2_send_setgroupmac_cb);
+}
+
+static int qeth_l2_send_delgroupmac_cb(struct qeth_card *card,
+				struct qeth_reply *reply,
+				unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+	__u8 *mac;
+
+	QETH_DBF_TEXT(trace, 2, "L2Dgmacb");
+	cmd = (struct qeth_ipa_cmd *) data;
+	mac = &cmd->data.setdelmac.mac[0];
+	if (cmd->hdr.return_code)
+		PRINT_ERR("Could not delete group MAC " \
+			  "%02x:%02x:%02x:%02x:%02x:%02x on %s: %x\n",
+			  mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
+			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
+	return 0;
+}
+
+static int qeth_l2_send_delgroupmac(struct qeth_card *card, __u8 *mac)
+{
+	QETH_DBF_TEXT(trace, 2, "L2Dgmac");
+	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELGMAC,
+					  qeth_l2_send_delgroupmac_cb);
+}
+
+static void qeth_l2_add_mc(struct qeth_card *card, __u8 *mac)
+{
+	struct qeth_mc_mac *mc;
+
+	mc = kmalloc(sizeof(struct qeth_mc_mac), GFP_ATOMIC);
+
+	if (!mc) {
+		PRINT_ERR("no mem vor mc mac address\n");
+		return;
+	}
+
+	memcpy(mc->mc_addr, mac, OSA_ADDR_LEN);
+	mc->mc_addrlen = OSA_ADDR_LEN;
+
+	if (!qeth_l2_send_setgroupmac(card, mac))
+		list_add_tail(&mc->list, &card->mc_list);
+	else
+		kfree(mc);
+}
+
+static void qeth_l2_del_all_mc(struct qeth_card *card)
+{
+	struct qeth_mc_mac *mc, *tmp;
+
+	spin_lock_bh(&card->mclock);
+	list_for_each_entry_safe(mc, tmp, &card->mc_list, list) {
+		qeth_l2_send_delgroupmac(card, mc->mc_addr);
+		list_del(&mc->list);
+		kfree(mc);
+	}
+	spin_unlock_bh(&card->mclock);
+}
+
+static void qeth_l2_get_packet_type(struct qeth_card *card,
+			struct qeth_hdr *hdr, struct sk_buff *skb)
+{
+	__u16 hdr_mac;
+
+	if (!memcmp(skb->data + QETH_HEADER_SIZE,
+		    skb->dev->broadcast, 6)) {
+		/* broadcast? */
+		hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_BROADCAST;
+		return;
+	}
+	hdr_mac = *((__u16 *)skb->data);
+	/* tr multicast? */
+	switch (card->info.link_type) {
+	case QETH_LINK_TYPE_HSTR:
+	case QETH_LINK_TYPE_LANE_TR:
+		if ((hdr_mac == QETH_TR_MAC_NC) ||
+		    (hdr_mac == QETH_TR_MAC_C))
+			hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_MULTICAST;
+		else
+			hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_UNICAST;
+		break;
+		/* eth or so multicast? */
+	default:
+		if ((hdr_mac == QETH_ETH_MAC_V4) ||
+		     (hdr_mac == QETH_ETH_MAC_V6))
+			hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_MULTICAST;
+		else
+			hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_UNICAST;
+	}
+}
+
+static void qeth_l2_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
+			struct sk_buff *skb, int ipv, int cast_type)
+{
+	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)((skb->data) +
+					QETH_HEADER_SIZE);
+
+	memset(hdr, 0, sizeof(struct qeth_hdr));
+	hdr->hdr.l2.id = QETH_HEADER_TYPE_LAYER2;
+
+	/* set byte byte 3 to casting flags */
+	if (cast_type == RTN_MULTICAST)
+		hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_MULTICAST;
+	else if (cast_type == RTN_BROADCAST)
+		hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_BROADCAST;
+	else
+		qeth_l2_get_packet_type(card, hdr, skb);
+
+	hdr->hdr.l2.pkt_length = skb->len-QETH_HEADER_SIZE;
+	/* VSWITCH relies on the VLAN
+	 * information to be present in
+	 * the QDIO header */
+	if (veth->h_vlan_proto == __constant_htons(ETH_P_8021Q)) {
+		hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_VLAN;
+		hdr->hdr.l2.vlan_id = ntohs(veth->h_vlan_TCI);
+	}
+}
+
+static int qeth_l2_send_setdelvlan_cb(struct qeth_card *card,
+			struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 2, "L2sdvcb");
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (cmd->hdr.return_code) {
+		PRINT_ERR("Error in processing VLAN %i on %s: 0x%x. "
+			  "Continuing\n", cmd->data.setdelvlan.vlan_id,
+			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
+		QETH_DBF_TEXT_(trace, 2, "L2VL%4x", cmd->hdr.command);
+		QETH_DBF_TEXT_(trace, 2, "L2%s", CARD_BUS_ID(card));
+		QETH_DBF_TEXT_(trace, 2, "err%d", cmd->hdr.return_code);
+	}
+	return 0;
+}
+
+static int qeth_l2_send_setdelvlan(struct qeth_card *card, __u16 i,
+				enum qeth_ipa_cmds ipacmd)
+{
+	struct qeth_ipa_cmd *cmd;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT_(trace, 4, "L2sdv%x", ipacmd);
+	iob = qeth_get_ipacmd_buffer(card, ipacmd, QETH_PROT_IPV4);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	cmd->data.setdelvlan.vlan_id = i;
+	return qeth_send_ipa_cmd(card, iob,
+				 qeth_l2_send_setdelvlan_cb, NULL);
+}
+
+static void qeth_l2_process_vlans(struct qeth_card *card, int clear)
+{
+	struct qeth_vlan_vid *id;
+	QETH_DBF_TEXT(trace, 3, "L2prcvln");
+	spin_lock_bh(&card->vlanlock);
+	list_for_each_entry(id, &card->vid_list, list) {
+		if (clear)
+			qeth_l2_send_setdelvlan(card, id->vid,
+				IPA_CMD_DELVLAN);
+		else
+			qeth_l2_send_setdelvlan(card, id->vid,
+				IPA_CMD_SETVLAN);
+	}
+	spin_unlock_bh(&card->vlanlock);
+}
+
+static void qeth_l2_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+{
+	struct qeth_card *card = netdev_priv(dev);
+	struct qeth_vlan_vid *id;
+
+	QETH_DBF_TEXT_(trace, 4, "aid:%d", vid);
+	id = kmalloc(sizeof(struct qeth_vlan_vid), GFP_ATOMIC);
+	if (id) {
+		id->vid = vid;
+		qeth_l2_send_setdelvlan(card, vid, IPA_CMD_SETVLAN);
+		spin_lock_bh(&card->vlanlock);
+		list_add_tail(&id->list, &card->vid_list);
+		spin_unlock_bh(&card->vlanlock);
+	} else {
+		PRINT_ERR("no memory for vid\n");
+	}
+}
+
+static void qeth_l2_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+{
+	struct qeth_vlan_vid *id, *tmpid = NULL;
+	struct qeth_card *card = netdev_priv(dev);
+
+	QETH_DBF_TEXT_(trace, 4, "kid:%d", vid);
+	spin_lock_bh(&card->vlanlock);
+	list_for_each_entry(id, &card->vid_list, list) {
+		if (id->vid == vid) {
+			list_del(&id->list);
+			tmpid = id;
+			break;
+		}
+	}
+	spin_unlock_bh(&card->vlanlock);
+	if (tmpid) {
+		qeth_l2_send_setdelvlan(card, vid, IPA_CMD_DELVLAN);
+		kfree(tmpid);
+	}
+	qeth_l2_set_multicast_list(card->dev);
+}
+
+static int qeth_l2_stop_card(struct qeth_card *card, int recovery_mode)
+{
+	int rc = 0;
+
+	QETH_DBF_TEXT(setup , 2, "stopcard");
+	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+
+	qeth_set_allowed_threads(card, 0, 1);
+	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD))
+		return -ERESTARTSYS;
+	if (card->read.state == CH_STATE_UP &&
+	    card->write.state == CH_STATE_UP &&
+	    (card->state == CARD_STATE_UP)) {
+		if (recovery_mode &&
+		    card->info.type != QETH_CARD_TYPE_OSN) {
+			qeth_l2_stop(card->dev);
+		} else {
+			rtnl_lock();
+			dev_close(card->dev);
+			rtnl_unlock();
+		}
+		if (!card->use_hard_stop) {
+			__u8 *mac = &card->dev->dev_addr[0];
+			rc = qeth_l2_send_delmac(card, mac);
+			QETH_DBF_TEXT_(setup, 2, "Lerr%d", rc);
+		}
+		card->state = CARD_STATE_SOFTSETUP;
+	}
+	if (card->state == CARD_STATE_SOFTSETUP) {
+		qeth_l2_process_vlans(card, 1);
+		qeth_l2_del_all_mc(card);
+		qeth_clear_ipacmd_list(card);
+		card->state = CARD_STATE_HARDSETUP;
+	}
+	if (card->state == CARD_STATE_HARDSETUP) {
+		qeth_qdio_clear_card(card, 0);
+		qeth_clear_qdio_buffers(card);
+		qeth_clear_working_pool_list(card);
+		card->state = CARD_STATE_DOWN;
+	}
+	if (card->state == CARD_STATE_DOWN) {
+		qeth_clear_cmd_buffers(&card->read);
+		qeth_clear_cmd_buffers(&card->write);
+	}
+	card->use_hard_stop = 0;
+	return rc;
+}
+
+static void qeth_l2_process_inbound_buffer(struct qeth_card *card,
+			    struct qeth_qdio_buffer *buf, int index)
+{
+	struct qdio_buffer_element *element;
+	struct sk_buff *skb;
+	struct qeth_hdr *hdr;
+	int offset;
+	unsigned int len;
+
+	/* get first element of current buffer */
+	element = (struct qdio_buffer_element *)&buf->buffer->element[0];
+	offset = 0;
+	if (card->options.performance_stats)
+		card->perf_stats.bufs_rec++;
+	while ((skb = qeth_core_get_next_skb(card, buf->buffer, &element,
+				       &offset, &hdr))) {
+		skb->dev = card->dev;
+		/* is device UP ? */
+		if (!(card->dev->flags & IFF_UP)) {
+			dev_kfree_skb_any(skb);
+			continue;
+		}
+
+		switch (hdr->hdr.l2.id) {
+		case QETH_HEADER_TYPE_LAYER2:
+			skb->pkt_type = PACKET_HOST;
+			skb->protocol = eth_type_trans(skb, skb->dev);
+			if (card->options.checksum_type == NO_CHECKSUMMING)
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+			else
+				skb->ip_summed = CHECKSUM_NONE;
+			*((__u32 *)skb->cb) = ++card->seqno.pkt_seqno;
+			len = skb->len;
+			netif_rx(skb);
+			break;
+		case QETH_HEADER_TYPE_OSN:
+			skb_push(skb, sizeof(struct qeth_hdr));
+			skb_copy_to_linear_data(skb, hdr,
+						sizeof(struct qeth_hdr));
+			len = skb->len;
+			card->osn_info.data_cb(skb);
+			break;
+		default:
+			dev_kfree_skb_any(skb);
+			QETH_DBF_TEXT(trace, 3, "inbunkno");
+			QETH_DBF_HEX(control, 3, hdr, QETH_DBF_CONTROL_LEN);
+			continue;
+		}
+		card->dev->last_rx = jiffies;
+		card->stats.rx_packets++;
+		card->stats.rx_bytes += len;
+	}
+}
+
+static int qeth_l2_send_setdelmac(struct qeth_card *card, __u8 *mac,
+			   enum qeth_ipa_cmds ipacmd,
+			   int (*reply_cb) (struct qeth_card *,
+					    struct qeth_reply*,
+					    unsigned long))
+{
+	struct qeth_ipa_cmd *cmd;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(trace, 2, "L2sdmac");
+	iob = qeth_get_ipacmd_buffer(card, ipacmd, QETH_PROT_IPV4);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	cmd->data.setdelmac.mac_length = OSA_ADDR_LEN;
+	memcpy(&cmd->data.setdelmac.mac, mac, OSA_ADDR_LEN);
+	return qeth_send_ipa_cmd(card, iob, reply_cb, NULL);
+}
+
+static int qeth_l2_send_setmac_cb(struct qeth_card *card,
+			   struct qeth_reply *reply,
+			   unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 2, "L2Smaccb");
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (cmd->hdr.return_code) {
+		QETH_DBF_TEXT_(trace, 2, "L2er%x", cmd->hdr.return_code);
+		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
+		cmd->hdr.return_code = -EIO;
+	} else {
+		card->info.mac_bits |= QETH_LAYER2_MAC_REGISTERED;
+		memcpy(card->dev->dev_addr, cmd->data.setdelmac.mac,
+		       OSA_ADDR_LEN);
+		PRINT_INFO("MAC address %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x "
+			   "successfully registered on device %s\n",
+			   card->dev->dev_addr[0], card->dev->dev_addr[1],
+			   card->dev->dev_addr[2], card->dev->dev_addr[3],
+			   card->dev->dev_addr[4], card->dev->dev_addr[5],
+			   card->dev->name);
+	}
+	return 0;
+}
+
+static int qeth_l2_send_setmac(struct qeth_card *card, __u8 *mac)
+{
+	QETH_DBF_TEXT(trace, 2, "L2Setmac");
+	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETVMAC,
+					  qeth_l2_send_setmac_cb);
+}
+
+static int qeth_l2_send_delmac_cb(struct qeth_card *card,
+			   struct qeth_reply *reply,
+			   unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 2, "L2Dmaccb");
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (cmd->hdr.return_code) {
+		QETH_DBF_TEXT_(trace, 2, "err%d", cmd->hdr.return_code);
+		cmd->hdr.return_code = -EIO;
+		return 0;
+	}
+	card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
+
+	return 0;
+}
+
+static int qeth_l2_send_delmac(struct qeth_card *card, __u8 *mac)
+{
+	QETH_DBF_TEXT(trace, 2, "L2Delmac");
+	if (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED))
+		return 0;
+	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELVMAC,
+					  qeth_l2_send_delmac_cb);
+}
+
+static int qeth_l2_request_initial_mac(struct qeth_card *card)
+{
+	int rc = 0;
+	char vendor_pre[] = {0x02, 0x00, 0x00};
+
+	QETH_DBF_TEXT(setup, 2, "doL2init");
+	QETH_DBF_TEXT_(setup, 2, "doL2%s", CARD_BUS_ID(card));
+
+	rc = qeth_query_setadapterparms(card);
+	if (rc) {
+		PRINT_WARN("could not query adapter parameters on device %s: "
+			   "x%x\n", CARD_BUS_ID(card), rc);
+	}
+
+	if (card->info.guestlan) {
+		rc = qeth_setadpparms_change_macaddr(card);
+		if (rc) {
+			PRINT_WARN("couldn't get MAC address on "
+			   "device %s: x%x\n",
+			   CARD_BUS_ID(card), rc);
+			QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+			return rc;
+		}
+		QETH_DBF_HEX(setup, 2, card->dev->dev_addr, OSA_ADDR_LEN);
+	} else {
+		random_ether_addr(card->dev->dev_addr);
+		memcpy(card->dev->dev_addr, vendor_pre, 3);
+	}
+	return 0;
+}
+
+static int qeth_l2_set_mac_address(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+	struct qeth_card *card = netdev_priv(dev);
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 3, "setmac");
+
+	if (qeth_l2_verify_dev(dev) != QETH_REAL_CARD) {
+		QETH_DBF_TEXT(trace, 3, "setmcINV");
+		return -EOPNOTSUPP;
+	}
+
+	if (card->info.type == QETH_CARD_TYPE_OSN) {
+		PRINT_WARN("Setting MAC address on %s is not supported.\n",
+			   dev->name);
+		QETH_DBF_TEXT(trace, 3, "setmcOSN");
+		return -EOPNOTSUPP;
+	}
+	QETH_DBF_TEXT_(trace, 3, "%s", CARD_BUS_ID(card));
+	QETH_DBF_HEX(trace, 3, addr->sa_data, OSA_ADDR_LEN);
+	rc = qeth_l2_send_delmac(card, &card->dev->dev_addr[0]);
+	if (!rc)
+		rc = qeth_l2_send_setmac(card, addr->sa_data);
+	return rc;
+}
+
+static void qeth_l2_set_multicast_list(struct net_device *dev)
+{
+	struct qeth_card *card = netdev_priv(dev);
+	struct dev_mc_list *dm;
+
+	if (card->info.type == QETH_CARD_TYPE_OSN)
+		return ;
+
+	QETH_DBF_TEXT(trace, 3, "setmulti");
+	qeth_l2_del_all_mc(card);
+	spin_lock_bh(&card->mclock);
+	for (dm = dev->mc_list; dm; dm = dm->next)
+		qeth_l2_add_mc(card, dm->dmi_addr);
+	spin_unlock_bh(&card->mclock);
+	if (!qeth_adp_supported(card, IPA_SETADP_SET_PROMISC_MODE))
+		return;
+	qeth_setadp_promisc_mode(card);
+}
+
+static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int rc;
+	struct qeth_hdr *hdr = NULL;
+	int elements = 0;
+	struct qeth_card *card = netdev_priv(dev);
+	struct sk_buff *new_skb = skb;
+	int ipv = qeth_get_ip_version(skb);
+	int cast_type = qeth_get_cast_type(card, skb);
+	struct qeth_qdio_out_q *queue = card->qdio.out_qs
+		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
+	int tx_bytes = skb->len;
+	enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
+	struct qeth_eddp_context *ctx = NULL;
+
+	QETH_DBF_TEXT(trace, 6, "l2xmit");
+
+	if ((card->state != CARD_STATE_UP) || !card->lan_online) {
+		card->stats.tx_carrier_errors++;
+		goto tx_drop;
+	}
+
+	if ((card->info.type == QETH_CARD_TYPE_OSN) &&
+	    (skb->protocol == htons(ETH_P_IPV6)))
+		goto tx_drop;
+
+	if (card->options.performance_stats) {
+		card->perf_stats.outbound_cnt++;
+		card->perf_stats.outbound_start_time = qeth_get_micros();
+	}
+	netif_stop_queue(dev);
+
+	if (skb_is_gso(skb))
+		large_send = QETH_LARGE_SEND_EDDP;
+
+	if (card->info.type == QETH_CARD_TYPE_OSN)
+		hdr = (struct qeth_hdr *)skb->data;
+	else {
+		new_skb = qeth_prepare_skb(card, skb, &hdr);
+		if (!new_skb)
+			goto tx_drop;
+		qeth_l2_fill_header(card, hdr, new_skb, ipv, cast_type);
+	}
+
+	if (large_send == QETH_LARGE_SEND_EDDP) {
+		ctx = qeth_eddp_create_context(card, new_skb, hdr,
+						skb->sk->sk_protocol);
+		if (ctx == NULL) {
+			PRINT_WARN("could not create eddp context\n");
+			goto tx_drop;
+		}
+	} else {
+		elements = qeth_get_elements_no(card, (void *)hdr, new_skb, 0);
+		if (!elements)
+			goto tx_drop;
+	}
+
+	if ((large_send == QETH_LARGE_SEND_NO) &&
+	    (skb->ip_summed == CHECKSUM_PARTIAL))
+		qeth_tx_csum(new_skb);
+
+	if (card->info.type != QETH_CARD_TYPE_IQD)
+		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
+					 elements, ctx);
+	else
+		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
+					      elements, ctx);
+	if (!rc) {
+		card->stats.tx_packets++;
+		card->stats.tx_bytes += tx_bytes;
+		if (new_skb != skb)
+			dev_kfree_skb_any(skb);
+		if (card->options.performance_stats) {
+			if (large_send != QETH_LARGE_SEND_NO) {
+				card->perf_stats.large_send_bytes += tx_bytes;
+				card->perf_stats.large_send_cnt++;
+			}
+			if (skb_shinfo(new_skb)->nr_frags > 0) {
+				card->perf_stats.sg_skbs_sent++;
+				/* nr_frags + skb->data */
+				card->perf_stats.sg_frags_sent +=
+					skb_shinfo(new_skb)->nr_frags + 1;
+			}
+		}
+
+		if (ctx != NULL) {
+			qeth_eddp_put_context(ctx);
+			dev_kfree_skb_any(new_skb);
+		}
+	} else {
+		if (ctx != NULL)
+			qeth_eddp_put_context(ctx);
+
+		if (rc == -EBUSY) {
+			if (new_skb != skb)
+				dev_kfree_skb_any(new_skb);
+			return NETDEV_TX_BUSY;
+		} else
+			goto tx_drop;
+	}
+
+	netif_wake_queue(dev);
+	if (card->options.performance_stats)
+		card->perf_stats.outbound_time += qeth_get_micros() -
+			card->perf_stats.outbound_start_time;
+	return rc;
+
+tx_drop:
+	card->stats.tx_dropped++;
+	card->stats.tx_errors++;
+	if ((new_skb != skb) && new_skb)
+		dev_kfree_skb_any(new_skb);
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
+}
+
+static void qeth_l2_qdio_input_handler(struct ccw_device *ccwdev,
+			unsigned int status, unsigned int qdio_err,
+			unsigned int siga_err, unsigned int queue,
+			int first_element, int count, unsigned long card_ptr)
+{
+	struct net_device *net_dev;
+	struct qeth_card *card;
+	struct qeth_qdio_buffer *buffer;
+	int index;
+	int i;
+
+	QETH_DBF_TEXT(trace, 6, "qdinput");
+	card = (struct qeth_card *) card_ptr;
+	net_dev = card->dev;
+	if (card->options.performance_stats) {
+		card->perf_stats.inbound_cnt++;
+		card->perf_stats.inbound_start_time = qeth_get_micros();
+	}
+	if (status & QDIO_STATUS_LOOK_FOR_ERROR) {
+		if (status & QDIO_STATUS_ACTIVATE_CHECK_CONDITION) {
+			QETH_DBF_TEXT(trace, 1, "qdinchk");
+			QETH_DBF_TEXT_(trace, 1, "%s", CARD_BUS_ID(card));
+			QETH_DBF_TEXT_(trace, 1, "%04X%04X", first_element,
+					count);
+			QETH_DBF_TEXT_(trace, 1, "%04X%04X", queue, status);
+			qeth_schedule_recovery(card);
+			return;
+		}
+	}
+	for (i = first_element; i < (first_element + count); ++i) {
+		index = i % QDIO_MAX_BUFFERS_PER_Q;
+		buffer = &card->qdio.in_q->bufs[index];
+		if (!((status & QDIO_STATUS_LOOK_FOR_ERROR) &&
+		      qeth_check_qdio_errors(buffer->buffer,
+					     qdio_err, siga_err, "qinerr")))
+			qeth_l2_process_inbound_buffer(card, buffer, index);
+		/* clear buffer and give back to hardware */
+		qeth_put_buffer_pool_entry(card, buffer->pool_entry);
+		qeth_queue_input_buffer(card, index);
+	}
+	if (card->options.performance_stats)
+		card->perf_stats.inbound_time += qeth_get_micros() -
+			card->perf_stats.inbound_start_time;
+}
+
+static int qeth_l2_open(struct net_device *dev)
+{
+	struct qeth_card *card = netdev_priv(dev);
+
+	QETH_DBF_TEXT(trace, 4, "qethopen");
+	if (card->state != CARD_STATE_SOFTSETUP)
+		return -ENODEV;
+
+	if ((card->info.type != QETH_CARD_TYPE_OSN) &&
+	     (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED))) {
+		QETH_DBF_TEXT(trace, 4, "nomacadr");
+		return -EPERM;
+	}
+	card->data.state = CH_STATE_UP;
+	card->state = CARD_STATE_UP;
+	card->dev->flags |= IFF_UP;
+	netif_start_queue(dev);
+
+	if (!card->lan_online && netif_carrier_ok(dev))
+		netif_carrier_off(dev);
+	return 0;
+}
+
+
+static int qeth_l2_stop(struct net_device *dev)
+{
+	struct qeth_card *card = netdev_priv(dev);
+
+	QETH_DBF_TEXT(trace, 4, "qethstop");
+	netif_tx_disable(dev);
+	card->dev->flags &= ~IFF_UP;
+	if (card->state == CARD_STATE_UP)
+		card->state = CARD_STATE_SOFTSETUP;
+	return 0;
+}
+
+static int qeth_l2_probe_device(struct ccwgroup_device *gdev)
+{
+	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+
+	INIT_LIST_HEAD(&card->vid_list);
+	INIT_LIST_HEAD(&card->mc_list);
+	card->options.layer2 = 1;
+	card->discipline.input_handler = (qdio_handler_t *)
+		qeth_l2_qdio_input_handler;
+	card->discipline.output_handler = (qdio_handler_t *)
+		qeth_qdio_output_handler;
+	card->discipline.recover = qeth_l2_recover;
+	return 0;
+}
+
+static void qeth_l2_remove_device(struct ccwgroup_device *cgdev)
+{
+	struct qeth_card *card = dev_get_drvdata(&cgdev->dev);
+
+	wait_event(card->wait_q, qeth_threads_running(card, 0xffffffff) == 0);
+
+	if (cgdev->state == CCWGROUP_ONLINE) {
+		card->use_hard_stop = 1;
+		qeth_l2_set_offline(cgdev);
+	}
+
+	if (card->dev) {
+		unregister_netdev(card->dev);
+		card->dev = NULL;
+	}
+
+	qeth_l2_del_all_mc(card);
+	return;
+}
+
+static struct ethtool_ops qeth_l2_ethtool_ops = {
+	.get_link = ethtool_op_get_link,
+	.get_tx_csum = ethtool_op_get_tx_csum,
+	.set_tx_csum = ethtool_op_set_tx_hw_csum,
+	.get_sg = ethtool_op_get_sg,
+	.set_sg = ethtool_op_set_sg,
+	.get_tso = ethtool_op_get_tso,
+	.set_tso = ethtool_op_set_tso,
+	.get_strings = qeth_core_get_strings,
+	.get_ethtool_stats = qeth_core_get_ethtool_stats,
+	.get_stats_count = qeth_core_get_stats_count,
+	.get_drvinfo = qeth_core_get_drvinfo,
+};
+
+static struct ethtool_ops qeth_l2_osn_ops = {
+	.get_strings = qeth_core_get_strings,
+	.get_ethtool_stats = qeth_core_get_ethtool_stats,
+	.get_stats_count = qeth_core_get_stats_count,
+	.get_drvinfo = qeth_core_get_drvinfo,
+};
+
+static int qeth_l2_setup_netdev(struct qeth_card *card)
+{
+	switch (card->info.type) {
+	case QETH_CARD_TYPE_OSAE:
+		card->dev = alloc_etherdev(0);
+		break;
+	case QETH_CARD_TYPE_IQD:
+		card->dev = alloc_netdev(0, "hsi%d", ether_setup);
+		break;
+	case QETH_CARD_TYPE_OSN:
+		card->dev = alloc_netdev(0, "osn%d", ether_setup);
+		card->dev->flags |= IFF_NOARP;
+		break;
+	default:
+		card->dev = alloc_etherdev(0);
+	}
+
+	if (!card->dev)
+		return -ENODEV;
+
+	card->dev->priv = card;
+	card->dev->tx_timeout = &qeth_tx_timeout;
+	card->dev->watchdog_timeo = QETH_TX_TIMEOUT;
+	card->dev->open = qeth_l2_open;
+	card->dev->stop = qeth_l2_stop;
+	card->dev->hard_start_xmit = qeth_l2_hard_start_xmit;
+	card->dev->do_ioctl = qeth_l2_do_ioctl;
+	card->dev->get_stats = qeth_get_stats;
+	card->dev->change_mtu = qeth_change_mtu;
+	card->dev->set_multicast_list = qeth_l2_set_multicast_list;
+	card->dev->vlan_rx_kill_vid = qeth_l2_vlan_rx_kill_vid;
+	card->dev->vlan_rx_add_vid = qeth_l2_vlan_rx_add_vid;
+	card->dev->set_mac_address = qeth_l2_set_mac_address;
+	card->dev->mtu = card->info.initial_mtu;
+	if (card->info.type != QETH_CARD_TYPE_OSN)
+		SET_ETHTOOL_OPS(card->dev, &qeth_l2_ethtool_ops);
+	else
+		SET_ETHTOOL_OPS(card->dev, &qeth_l2_osn_ops);
+	card->dev->features |= NETIF_F_HW_VLAN_FILTER;
+	card->info.broadcast_capable = 1;
+	qeth_l2_request_initial_mac(card);
+	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
+	return register_netdev(card->dev);
+}
+
+static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
+{
+	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+	int rc = 0;
+	enum qeth_card_states recover_flag;
+
+	BUG_ON(!card);
+	QETH_DBF_TEXT(setup, 2, "setonlin");
+	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+
+	qeth_set_allowed_threads(card, QETH_RECOVER_THREAD, 1);
+	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD)) {
+		PRINT_WARN("set_online of card %s interrupted by user!\n",
+			   CARD_BUS_ID(card));
+		return -ERESTARTSYS;
+	}
+
+	recover_flag = card->state;
+	rc = ccw_device_set_online(CARD_RDEV(card));
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		return -EIO;
+	}
+	rc = ccw_device_set_online(CARD_WDEV(card));
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		return -EIO;
+	}
+	rc = ccw_device_set_online(CARD_DDEV(card));
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		return -EIO;
+	}
+
+	rc = qeth_core_hardsetup_card(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		goto out_remove;
+	}
+
+	if (!card->dev && qeth_l2_setup_netdev(card))
+		goto out_remove;
+
+	if (card->info.type != QETH_CARD_TYPE_OSN)
+		qeth_l2_send_setmac(card, &card->dev->dev_addr[0]);
+
+	card->state = CARD_STATE_HARDSETUP;
+	qeth_print_status_message(card);
+
+	/* softsetup */
+	QETH_DBF_TEXT(setup, 2, "softsetp");
+
+	rc = qeth_send_startlan(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		if (rc == 0xe080) {
+			PRINT_WARN("LAN on card %s if offline! "
+				   "Waiting for STARTLAN from card.\n",
+				   CARD_BUS_ID(card));
+			card->lan_online = 0;
+		}
+		return rc;
+	} else
+		card->lan_online = 1;
+
+	if (card->info.type != QETH_CARD_TYPE_OSN) {
+		qeth_set_large_send(card, card->options.large_send);
+		qeth_l2_process_vlans(card, 0);
+	}
+
+	netif_tx_disable(card->dev);
+
+	rc = qeth_init_qdio_queues(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "6err%d", rc);
+		goto out_remove;
+	}
+	card->state = CARD_STATE_SOFTSETUP;
+	netif_carrier_on(card->dev);
+
+	qeth_set_allowed_threads(card, 0xffffffff, 0);
+	if (recover_flag == CARD_STATE_RECOVER) {
+		if (recovery_mode &&
+		    card->info.type != QETH_CARD_TYPE_OSN) {
+			qeth_l2_open(card->dev);
+		} else {
+			rtnl_lock();
+			dev_open(card->dev);
+			rtnl_unlock();
+		}
+		/* this also sets saved unicast addresses */
+		qeth_l2_set_multicast_list(card->dev);
+	}
+	/* let user_space know that device is online */
+	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
+	return 0;
+out_remove:
+	card->use_hard_stop = 1;
+	qeth_l2_stop_card(card, 0);
+	ccw_device_set_offline(CARD_DDEV(card));
+	ccw_device_set_offline(CARD_WDEV(card));
+	ccw_device_set_offline(CARD_RDEV(card));
+	if (recover_flag == CARD_STATE_RECOVER)
+		card->state = CARD_STATE_RECOVER;
+	else
+		card->state = CARD_STATE_DOWN;
+	return -ENODEV;
+}
+
+static int qeth_l2_set_online(struct ccwgroup_device *gdev)
+{
+	return __qeth_l2_set_online(gdev, 0);
+}
+
+static int __qeth_l2_set_offline(struct ccwgroup_device *cgdev,
+					int recovery_mode)
+{
+	struct qeth_card *card = dev_get_drvdata(&cgdev->dev);
+	int rc = 0, rc2 = 0, rc3 = 0;
+	enum qeth_card_states recover_flag;
+
+	QETH_DBF_TEXT(setup, 3, "setoffl");
+	QETH_DBF_HEX(setup, 3, &card, sizeof(void *));
+
+	if (card->dev && netif_carrier_ok(card->dev))
+		netif_carrier_off(card->dev);
+	recover_flag = card->state;
+	if (qeth_l2_stop_card(card, recovery_mode) == -ERESTARTSYS) {
+		PRINT_WARN("Stopping card %s interrupted by user!\n",
+			   CARD_BUS_ID(card));
+		return -ERESTARTSYS;
+	}
+	rc  = ccw_device_set_offline(CARD_DDEV(card));
+	rc2 = ccw_device_set_offline(CARD_WDEV(card));
+	rc3 = ccw_device_set_offline(CARD_RDEV(card));
+	if (!rc)
+		rc = (rc2) ? rc2 : rc3;
+	if (rc)
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+	if (recover_flag == CARD_STATE_UP)
+		card->state = CARD_STATE_RECOVER;
+	/* let user_space know that device is offline */
+	kobject_uevent(&cgdev->dev.kobj, KOBJ_CHANGE);
+	return 0;
+}
+
+static int qeth_l2_set_offline(struct ccwgroup_device *cgdev)
+{
+	return __qeth_l2_set_offline(cgdev, 0);
+}
+
+static int qeth_l2_recover(void *ptr)
+{
+	struct qeth_card *card;
+	int rc = 0;
+
+	card = (struct qeth_card *) ptr;
+	QETH_DBF_TEXT(trace, 2, "recover1");
+	QETH_DBF_HEX(trace, 2, &card, sizeof(void *));
+	if (!qeth_do_run_thread(card, QETH_RECOVER_THREAD))
+		return 0;
+	QETH_DBF_TEXT(trace, 2, "recover2");
+	PRINT_WARN("Recovery of device %s started ...\n",
+		   CARD_BUS_ID(card));
+	card->use_hard_stop = 1;
+	__qeth_l2_set_offline(card->gdev, 1);
+	rc = __qeth_l2_set_online(card->gdev, 1);
+	/* don't run another scheduled recovery */
+	qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
+	qeth_clear_thread_running_bit(card, QETH_RECOVER_THREAD);
+	if (!rc)
+		PRINT_INFO("Device %s successfully recovered!\n",
+			   CARD_BUS_ID(card));
+	else
+		PRINT_INFO("Device %s could not be recovered!\n",
+			   CARD_BUS_ID(card));
+	return 0;
+}
+
+static int __init qeth_l2_init(void)
+{
+	PRINT_INFO("register layer 2 discipline\n");
+	return 0;
+}
+
+static void __exit qeth_l2_exit(void)
+{
+	PRINT_INFO("unregister layer 2 discipline\n");
+}
+
+static void qeth_l2_shutdown(struct ccwgroup_device *gdev)
+{
+	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+	qeth_qdio_clear_card(card, 0);
+	qeth_clear_qdio_buffers(card);
+}
+
+struct ccwgroup_driver qeth_l2_ccwgroup_driver = {
+	.probe = qeth_l2_probe_device,
+	.remove = qeth_l2_remove_device,
+	.set_online = qeth_l2_set_online,
+	.set_offline = qeth_l2_set_offline,
+	.shutdown = qeth_l2_shutdown,
+};
+EXPORT_SYMBOL_GPL(qeth_l2_ccwgroup_driver);
+
+static int qeth_osn_send_control_data(struct qeth_card *card, int len,
+			   struct qeth_cmd_buffer *iob)
+{
+	unsigned long flags;
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 5, "osndctrd");
+
+	wait_event(card->wait_q,
+		   atomic_cmpxchg(&card->write.irq_pending, 0, 1) == 0);
+	qeth_prepare_control_data(card, len, iob);
+	QETH_DBF_TEXT(trace, 6, "osnoirqp");
+	spin_lock_irqsave(get_ccwdev_lock(card->write.ccwdev), flags);
+	rc = ccw_device_start(card->write.ccwdev, &card->write.ccw,
+			      (addr_t) iob, 0, 0);
+	spin_unlock_irqrestore(get_ccwdev_lock(card->write.ccwdev), flags);
+	if (rc) {
+		PRINT_WARN("qeth_osn_send_control_data: "
+			   "ccw_device_start rc = %i\n", rc);
+		QETH_DBF_TEXT_(trace, 2, " err%d", rc);
+		qeth_release_buffer(iob->channel, iob);
+		atomic_set(&card->write.irq_pending, 0);
+		wake_up(&card->wait_q);
+	}
+	return rc;
+}
+
+static int qeth_osn_send_ipa_cmd(struct qeth_card *card,
+			struct qeth_cmd_buffer *iob, int data_len)
+{
+	u16 s1, s2;
+
+	QETH_DBF_TEXT(trace, 4, "osndipa");
+
+	qeth_prepare_ipa_cmd(card, iob, QETH_PROT_OSN2);
+	s1 = (u16)(IPA_PDU_HEADER_SIZE + data_len);
+	s2 = (u16)data_len;
+	memcpy(QETH_IPA_PDU_LEN_TOTAL(iob->data), &s1, 2);
+	memcpy(QETH_IPA_PDU_LEN_PDU1(iob->data), &s2, 2);
+	memcpy(QETH_IPA_PDU_LEN_PDU2(iob->data), &s2, 2);
+	memcpy(QETH_IPA_PDU_LEN_PDU3(iob->data), &s2, 2);
+	return qeth_osn_send_control_data(card, s1, iob);
+}
+
+int qeth_osn_assist(struct net_device *dev, void *data, int data_len)
+{
+	struct qeth_cmd_buffer *iob;
+	struct qeth_card *card;
+	int rc;
+
+	QETH_DBF_TEXT(trace, 2, "osnsdmc");
+	if (!dev)
+		return -ENODEV;
+	card = netdev_priv(dev);
+	if (!card)
+		return -ENODEV;
+	if ((card->state != CARD_STATE_UP) &&
+	    (card->state != CARD_STATE_SOFTSETUP))
+		return -ENODEV;
+	iob = qeth_wait_for_buffer(&card->write);
+	memcpy(iob->data+IPA_PDU_HEADER_SIZE, data, data_len);
+	rc = qeth_osn_send_ipa_cmd(card, iob, data_len);
+	return rc;
+}
+EXPORT_SYMBOL(qeth_osn_assist);
+
+int qeth_osn_register(unsigned char *read_dev_no, struct net_device **dev,
+		  int (*assist_cb)(struct net_device *, void *),
+		  int (*data_cb)(struct sk_buff *))
+{
+	struct qeth_card *card;
+
+	QETH_DBF_TEXT(trace, 2, "osnreg");
+	*dev = qeth_l2_netdev_by_devno(read_dev_no);
+	if (*dev == NULL)
+		return -ENODEV;
+	card = netdev_priv(*dev);
+	if (!card)
+		return -ENODEV;
+	if ((assist_cb == NULL) || (data_cb == NULL))
+		return -EINVAL;
+	card->osn_info.assist_cb = assist_cb;
+	card->osn_info.data_cb = data_cb;
+	return 0;
+}
+EXPORT_SYMBOL(qeth_osn_register);
+
+void qeth_osn_deregister(struct net_device *dev)
+{
+	struct qeth_card *card;
+
+	QETH_DBF_TEXT(trace, 2, "osndereg");
+	if (!dev)
+		return;
+	card = netdev_priv(dev);
+	if (!card)
+		return;
+	card->osn_info.assist_cb = NULL;
+	card->osn_info.data_cb = NULL;
+	return;
+}
+EXPORT_SYMBOL(qeth_osn_deregister);
+
+module_init(qeth_l2_init);
+module_exit(qeth_l2_exit);
+MODULE_AUTHOR("Frank Blaschka <frank.blaschka@de.ibm.com>");
+MODULE_DESCRIPTION("qeth layer 2 discipline");
+MODULE_LICENSE("GPL");
Index: my_git/drivers/s390/net/qeth_l3.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ my_git/drivers/s390/net/qeth_l3.h	2008-02-14 13:23:52.000000000 +0100
@@ -0,0 +1,76 @@
+/*
+ *  drivers/s390/net/qeth_l3.h
+ *
+ *    Copyright IBM Corp. 2007
+ *    Author(s): Utz Bacher <utz.bacher@de.ibm.com>,
+ *		 Frank Pavlic <fpavlic@de.ibm.com>,
+ *		 Thomas Spatzier <tspat@de.ibm.com>,
+ *		 Frank Blaschka <frank.blaschka@de.ibm.com>
+ */
+
+#ifndef __QETH_L3_H__
+#define __QETH_L3_H__
+
+#include "qeth_core.h"
+
+#define QETH_DBF_TEXT_(name, level, text...) \
+	do { \
+		if (qeth_dbf_passes(qeth_dbf_##name, level)) { \
+			char *dbf_txt_buf = get_cpu_var(qeth_l3_dbf_txt_buf); \
+			sprintf(dbf_txt_buf, text); \
+			debug_text_event(qeth_dbf_##name, level, dbf_txt_buf); \
+			put_cpu_var(qeth_l3_dbf_txt_buf); \
+		} \
+	} while (0)
+
+DECLARE_PER_CPU(char[256], qeth_l3_dbf_txt_buf);
+
+struct qeth_ipaddr {
+	struct list_head entry;
+	enum qeth_ip_types type;
+	enum qeth_ipa_setdelip_flags set_flags;
+	enum qeth_ipa_setdelip_flags del_flags;
+	int is_multicast;
+	int users;
+	enum qeth_prot_versions proto;
+	unsigned char mac[OSA_ADDR_LEN];
+	union {
+		struct {
+			unsigned int addr;
+			unsigned int mask;
+		} a4;
+		struct {
+			struct in6_addr addr;
+			unsigned int pfxlen;
+		} a6;
+	} u;
+};
+
+struct qeth_ipato_entry {
+	struct list_head entry;
+	enum qeth_prot_versions proto;
+	char addr[16];
+	int mask_bits;
+};
+
+
+void qeth_l3_ipaddr4_to_string(const __u8 *, char *);
+int qeth_l3_string_to_ipaddr4(const char *, __u8 *);
+void qeth_l3_ipaddr6_to_string(const __u8 *, char *);
+int qeth_l3_string_to_ipaddr6(const char *, __u8 *);
+void qeth_l3_ipaddr_to_string(enum qeth_prot_versions, const __u8 *, char *);
+int qeth_l3_string_to_ipaddr(const char *, enum qeth_prot_versions, __u8 *);
+int qeth_l3_create_device_attributes(struct device *);
+void qeth_l3_remove_device_attributes(struct device *);
+int qeth_l3_setrouting_v4(struct qeth_card *);
+int qeth_l3_setrouting_v6(struct qeth_card *);
+int qeth_l3_add_ipato_entry(struct qeth_card *, struct qeth_ipato_entry *);
+void qeth_l3_del_ipato_entry(struct qeth_card *, enum qeth_prot_versions,
+			u8 *, int);
+int qeth_l3_add_vipa(struct qeth_card *, enum qeth_prot_versions, const u8 *);
+void qeth_l3_del_vipa(struct qeth_card *, enum qeth_prot_versions, const u8 *);
+int qeth_l3_add_rxip(struct qeth_card *, enum qeth_prot_versions, const u8 *);
+void qeth_l3_del_rxip(struct qeth_card *card, enum qeth_prot_versions,
+			const u8 *);
+
+#endif /* __QETH_L3_H__ */
Index: my_git/drivers/s390/net/qeth_l3_main.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ my_git/drivers/s390/net/qeth_l3_main.c	2008-02-14 16:33:32.000000000 +0100
@@ -0,0 +1,3388 @@
+/*
+ *  drivers/s390/net/qeth_l3_main.c
+ *
+ *    Copyright IBM Corp. 2007
+ *    Author(s): Utz Bacher <utz.bacher@de.ibm.com>,
+ *		 Frank Pavlic <fpavlic@de.ibm.com>,
+ *		 Thomas Spatzier <tspat@de.ibm.com>,
+ *		 Frank Blaschka <frank.blaschka@de.ibm.com>
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/kernel.h>
+#include <linux/etherdevice.h>
+#include <linux/mii.h>
+#include <linux/ip.h>
+#include <linux/reboot.h>
+#include <linux/inetdevice.h>
+#include <linux/igmp.h>
+
+#include <net/ip.h>
+#include <net/arp.h>
+
+#include <asm/s390_rdev.h>
+
+#include "qeth_l3.h"
+#include "qeth_core_offl.h"
+
+DEFINE_PER_CPU(char[256], qeth_l3_dbf_txt_buf);
+
+static int qeth_l3_set_offline(struct ccwgroup_device *);
+static int qeth_l3_recover(void *);
+static int qeth_l3_stop(struct net_device *);
+static void qeth_l3_set_multicast_list(struct net_device *);
+static int qeth_l3_neigh_setup(struct net_device *, struct neigh_parms *);
+static int qeth_l3_register_addr_entry(struct qeth_card *,
+		struct qeth_ipaddr *);
+static int qeth_l3_deregister_addr_entry(struct qeth_card *,
+		struct qeth_ipaddr *);
+static int __qeth_l3_set_online(struct ccwgroup_device *, int);
+static int __qeth_l3_set_offline(struct ccwgroup_device *, int);
+
+
+static int qeth_l3_isxdigit(char *buf)
+{
+	while (*buf) {
+		if (!isxdigit(*buf++))
+			return 0;
+	}
+	return 1;
+}
+
+void qeth_l3_ipaddr4_to_string(const __u8 *addr, char *buf)
+{
+	sprintf(buf, "%i.%i.%i.%i", addr[0], addr[1], addr[2], addr[3]);
+}
+
+int qeth_l3_string_to_ipaddr4(const char *buf, __u8 *addr)
+{
+	int count = 0, rc = 0;
+	int in[4];
+	char c;
+
+	rc = sscanf(buf, "%u.%u.%u.%u%c",
+		    &in[0], &in[1], &in[2], &in[3], &c);
+	if (rc != 4 && (rc != 5 || c != '\n'))
+		return -EINVAL;
+	for (count = 0; count < 4; count++) {
+		if (in[count] > 255)
+			return -EINVAL;
+		addr[count] = in[count];
+	}
+	return 0;
+}
+
+void qeth_l3_ipaddr6_to_string(const __u8 *addr, char *buf)
+{
+	sprintf(buf, "%02x%02x:%02x%02x:%02x%02x:%02x%02x"
+		     ":%02x%02x:%02x%02x:%02x%02x:%02x%02x",
+		     addr[0], addr[1], addr[2], addr[3],
+		     addr[4], addr[5], addr[6], addr[7],
+		     addr[8], addr[9], addr[10], addr[11],
+		     addr[12], addr[13], addr[14], addr[15]);
+}
+
+int qeth_l3_string_to_ipaddr6(const char *buf, __u8 *addr)
+{
+	const char *end, *end_tmp, *start;
+	__u16 *in;
+	char num[5];
+	int num2, cnt, out, found, save_cnt;
+	unsigned short in_tmp[8] = {0, };
+
+	cnt = out = found = save_cnt = num2 = 0;
+	end = start = buf;
+	in = (__u16 *) addr;
+	memset(in, 0, 16);
+	while (*end) {
+		end = strchr(start, ':');
+		if (end == NULL) {
+			end = buf + strlen(buf);
+			end_tmp = strchr(start, '\n');
+			if (end_tmp != NULL)
+				end = end_tmp;
+			out = 1;
+		}
+		if ((end - start)) {
+			memset(num, 0, 5);
+			if ((end - start) > 4)
+				return -EINVAL;
+			memcpy(num, start, end - start);
+			if (!qeth_l3_isxdigit(num))
+				return -EINVAL;
+			sscanf(start, "%x", &num2);
+			if (found)
+				in_tmp[save_cnt++] = num2;
+			else
+				in[cnt++] = num2;
+			if (out)
+				break;
+		} else {
+			if (found)
+				return -EINVAL;
+			found = 1;
+		}
+		start = ++end;
+	}
+	if (cnt + save_cnt > 8)
+		return -EINVAL;
+	cnt = 7;
+	while (save_cnt)
+		in[cnt--] = in_tmp[--save_cnt];
+	return 0;
+}
+
+void qeth_l3_ipaddr_to_string(enum qeth_prot_versions proto, const __u8 *addr,
+				char *buf)
+{
+	if (proto == QETH_PROT_IPV4)
+		qeth_l3_ipaddr4_to_string(addr, buf);
+	else if (proto == QETH_PROT_IPV6)
+		qeth_l3_ipaddr6_to_string(addr, buf);
+}
+
+int qeth_l3_string_to_ipaddr(const char *buf, enum qeth_prot_versions proto,
+				__u8 *addr)
+{
+	if (proto == QETH_PROT_IPV4)
+		return qeth_l3_string_to_ipaddr4(buf, addr);
+	else if (proto == QETH_PROT_IPV6)
+		return qeth_l3_string_to_ipaddr6(buf, addr);
+	else
+		return -EINVAL;
+}
+
+static void qeth_l3_convert_addr_to_bits(u8 *addr, u8 *bits, int len)
+{
+	int i, j;
+	u8 octet;
+
+	for (i = 0; i < len; ++i) {
+		octet = addr[i];
+		for (j = 7; j >= 0; --j) {
+			bits[i*8 + j] = octet & 1;
+			octet >>= 1;
+		}
+	}
+}
+
+static int qeth_l3_is_addr_covered_by_ipato(struct qeth_card *card,
+						struct qeth_ipaddr *addr)
+{
+	struct qeth_ipato_entry *ipatoe;
+	u8 addr_bits[128] = {0, };
+	u8 ipatoe_bits[128] = {0, };
+	int rc = 0;
+
+	if (!card->ipato.enabled)
+		return 0;
+
+	qeth_l3_convert_addr_to_bits((u8 *) &addr->u, addr_bits,
+				  (addr->proto == QETH_PROT_IPV4)? 4:16);
+	list_for_each_entry(ipatoe, &card->ipato.entries, entry) {
+		if (addr->proto != ipatoe->proto)
+			continue;
+		qeth_l3_convert_addr_to_bits(ipatoe->addr, ipatoe_bits,
+					  (ipatoe->proto == QETH_PROT_IPV4) ?
+					  4 : 16);
+		if (addr->proto == QETH_PROT_IPV4)
+			rc = !memcmp(addr_bits, ipatoe_bits,
+				     min(32, ipatoe->mask_bits));
+		else
+			rc = !memcmp(addr_bits, ipatoe_bits,
+				     min(128, ipatoe->mask_bits));
+		if (rc)
+			break;
+	}
+	/* invert? */
+	if ((addr->proto == QETH_PROT_IPV4) && card->ipato.invert4)
+		rc = !rc;
+	else if ((addr->proto == QETH_PROT_IPV6) && card->ipato.invert6)
+		rc = !rc;
+
+	return rc;
+}
+
+/*
+ * Add IP to be added to todo list. If there is already an "add todo"
+ * in this list we just incremenent the reference count.
+ * Returns 0 if we  just incremented reference count.
+ */
+static int __qeth_l3_insert_ip_todo(struct qeth_card *card,
+					struct qeth_ipaddr *addr, int add)
+{
+	struct qeth_ipaddr *tmp, *t;
+	int found = 0;
+
+	list_for_each_entry_safe(tmp, t, card->ip_tbd_list, entry) {
+		if ((addr->type == QETH_IP_TYPE_DEL_ALL_MC) &&
+		    (tmp->type == QETH_IP_TYPE_DEL_ALL_MC))
+			return 0;
+		if ((tmp->proto        == QETH_PROT_IPV4)     &&
+		    (addr->proto       == QETH_PROT_IPV4)     &&
+		    (tmp->type         == addr->type)         &&
+		    (tmp->is_multicast == addr->is_multicast) &&
+		    (tmp->u.a4.addr    == addr->u.a4.addr)    &&
+		    (tmp->u.a4.mask    == addr->u.a4.mask)) {
+			found = 1;
+			break;
+		}
+		if ((tmp->proto        == QETH_PROT_IPV6)      &&
+		    (addr->proto       == QETH_PROT_IPV6)      &&
+		    (tmp->type         == addr->type)          &&
+		    (tmp->is_multicast == addr->is_multicast)  &&
+		    (tmp->u.a6.pfxlen  == addr->u.a6.pfxlen)   &&
+		    (memcmp(&tmp->u.a6.addr, &addr->u.a6.addr,
+			    sizeof(struct in6_addr)) == 0)) {
+			found = 1;
+			break;
+		}
+	}
+	if (found) {
+		if (addr->users != 0)
+			tmp->users += addr->users;
+		else
+			tmp->users += add ? 1 : -1;
+		if (tmp->users == 0) {
+			list_del(&tmp->entry);
+			kfree(tmp);
+		}
+		return 0;
+	} else {
+		if (addr->type == QETH_IP_TYPE_DEL_ALL_MC)
+			list_add(&addr->entry, card->ip_tbd_list);
+		else {
+			if (addr->users == 0)
+				addr->users += add ? 1 : -1;
+			if (add && (addr->type == QETH_IP_TYPE_NORMAL) &&
+			    qeth_l3_is_addr_covered_by_ipato(card, addr)) {
+				QETH_DBF_TEXT(trace, 2, "tkovaddr");
+				addr->set_flags |= QETH_IPA_SETIP_TAKEOVER_FLAG;
+			}
+			list_add_tail(&addr->entry, card->ip_tbd_list);
+		}
+		return 1;
+	}
+}
+
+static int qeth_l3_delete_ip(struct qeth_card *card, struct qeth_ipaddr *addr)
+{
+	unsigned long flags;
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 4, "delip");
+
+	if (addr->proto == QETH_PROT_IPV4)
+		QETH_DBF_HEX(trace, 4, &addr->u.a4.addr, 4);
+	else {
+		QETH_DBF_HEX(trace, 4, &addr->u.a6.addr, 8);
+		QETH_DBF_HEX(trace, 4, ((char *)&addr->u.a6.addr) + 8, 8);
+	}
+	spin_lock_irqsave(&card->ip_lock, flags);
+	rc = __qeth_l3_insert_ip_todo(card, addr, 0);
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+	return rc;
+}
+
+static int qeth_l3_add_ip(struct qeth_card *card, struct qeth_ipaddr *addr)
+{
+	unsigned long flags;
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 4, "addip");
+	if (addr->proto == QETH_PROT_IPV4)
+		QETH_DBF_HEX(trace, 4, &addr->u.a4.addr, 4);
+	else {
+		QETH_DBF_HEX(trace, 4, &addr->u.a6.addr, 8);
+		QETH_DBF_HEX(trace, 4, ((char *)&addr->u.a6.addr) + 8, 8);
+	}
+	spin_lock_irqsave(&card->ip_lock, flags);
+	rc = __qeth_l3_insert_ip_todo(card, addr, 1);
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+	return rc;
+}
+
+
+static struct qeth_ipaddr *qeth_l3_get_addr_buffer(
+				enum qeth_prot_versions prot)
+{
+	struct qeth_ipaddr *addr;
+
+	addr = kzalloc(sizeof(struct qeth_ipaddr), GFP_ATOMIC);
+	if (addr == NULL) {
+		PRINT_WARN("Not enough memory to add address\n");
+		return NULL;
+	}
+	addr->type = QETH_IP_TYPE_NORMAL;
+	addr->proto = prot;
+	return addr;
+}
+
+static void qeth_l3_delete_mc_addresses(struct qeth_card *card)
+{
+	struct qeth_ipaddr *iptodo;
+	unsigned long flags;
+
+	QETH_DBF_TEXT(trace, 4, "delmc");
+	iptodo = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
+	if (!iptodo) {
+		QETH_DBF_TEXT(trace, 2, "dmcnomem");
+		return;
+	}
+	iptodo->type = QETH_IP_TYPE_DEL_ALL_MC;
+	spin_lock_irqsave(&card->ip_lock, flags);
+	if (!__qeth_l3_insert_ip_todo(card, iptodo, 0))
+		kfree(iptodo);
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+}
+
+/*
+ * Add/remove address to/from card's ip list, i.e. try to add or remove
+ * reference to/from an IP address that is already registered on the card.
+ * Returns:
+ *	0  address was on card and its reference count has been adjusted,
+ *	   but is still > 0, so nothing has to be done
+ *	   also returns 0 if card was not on card and the todo was to delete
+ *	   the address -> there is also nothing to be done
+ *	1  address was not on card and the todo is to add it to the card's ip
+ *	   list
+ *	-1 address was on card and its reference count has been decremented
+ *	   to <= 0 by the todo -> address must be removed from card
+ */
+static int __qeth_l3_ref_ip_on_card(struct qeth_card *card,
+		struct qeth_ipaddr *todo, struct qeth_ipaddr **__addr)
+{
+	struct qeth_ipaddr *addr;
+	int found = 0;
+
+	list_for_each_entry(addr, &card->ip_list, entry) {
+		if ((addr->proto == QETH_PROT_IPV4) &&
+		    (todo->proto == QETH_PROT_IPV4) &&
+		    (addr->type == todo->type) &&
+		    (addr->u.a4.addr == todo->u.a4.addr) &&
+		    (addr->u.a4.mask == todo->u.a4.mask)) {
+			found = 1;
+			break;
+		}
+		if ((addr->proto == QETH_PROT_IPV6) &&
+		    (todo->proto == QETH_PROT_IPV6) &&
+		    (addr->type == todo->type) &&
+		    (addr->u.a6.pfxlen == todo->u.a6.pfxlen) &&
+		    (memcmp(&addr->u.a6.addr, &todo->u.a6.addr,
+			    sizeof(struct in6_addr)) == 0)) {
+			found = 1;
+			break;
+		}
+	}
+	if (found) {
+		addr->users += todo->users;
+		if (addr->users <= 0) {
+			*__addr = addr;
+			return -1;
+		} else {
+			/* for VIPA and RXIP limit refcount to 1 */
+			if (addr->type != QETH_IP_TYPE_NORMAL)
+				addr->users = 1;
+			return 0;
+		}
+	}
+	if (todo->users > 0) {
+		/* for VIPA and RXIP limit refcount to 1 */
+		if (todo->type != QETH_IP_TYPE_NORMAL)
+			todo->users = 1;
+		return 1;
+	} else
+		return 0;
+}
+
+static void __qeth_l3_delete_all_mc(struct qeth_card *card,
+					unsigned long *flags)
+{
+	struct qeth_ipaddr *addr, *tmp;
+	int rc;
+again:
+	list_for_each_entry_safe(addr, tmp, &card->ip_list, entry) {
+		if (addr->is_multicast) {
+			list_del(&addr->entry);
+			spin_unlock_irqrestore(&card->ip_lock, *flags);
+			rc = qeth_l3_deregister_addr_entry(card, addr);
+			spin_lock_irqsave(&card->ip_lock, *flags);
+			if (!rc) {
+				kfree(addr);
+				goto again;
+			} else
+				list_add(&addr->entry, &card->ip_list);
+		}
+	}
+}
+
+static void qeth_l3_set_ip_addr_list(struct qeth_card *card)
+{
+	struct list_head *tbd_list;
+	struct qeth_ipaddr *todo, *addr;
+	unsigned long flags;
+	int rc;
+
+	QETH_DBF_TEXT(trace, 2, "sdiplist");
+	QETH_DBF_HEX(trace, 2, &card, sizeof(void *));
+
+	spin_lock_irqsave(&card->ip_lock, flags);
+	tbd_list = card->ip_tbd_list;
+	card->ip_tbd_list = kmalloc(sizeof(struct list_head), GFP_ATOMIC);
+	if (!card->ip_tbd_list) {
+		QETH_DBF_TEXT(trace, 0, "silnomem");
+		card->ip_tbd_list = tbd_list;
+		spin_unlock_irqrestore(&card->ip_lock, flags);
+		return;
+	} else
+		INIT_LIST_HEAD(card->ip_tbd_list);
+
+	while (!list_empty(tbd_list)) {
+		todo = list_entry(tbd_list->next, struct qeth_ipaddr, entry);
+		list_del(&todo->entry);
+		if (todo->type == QETH_IP_TYPE_DEL_ALL_MC) {
+			__qeth_l3_delete_all_mc(card, &flags);
+			kfree(todo);
+			continue;
+		}
+		rc = __qeth_l3_ref_ip_on_card(card, todo, &addr);
+		if (rc == 0) {
+			/* nothing to be done; only adjusted refcount */
+			kfree(todo);
+		} else if (rc == 1) {
+			/* new entry to be added to on-card list */
+			spin_unlock_irqrestore(&card->ip_lock, flags);
+			rc = qeth_l3_register_addr_entry(card, todo);
+			spin_lock_irqsave(&card->ip_lock, flags);
+			if (!rc)
+				list_add_tail(&todo->entry, &card->ip_list);
+			else
+				kfree(todo);
+		} else if (rc == -1) {
+			/* on-card entry to be removed */
+			list_del_init(&addr->entry);
+			spin_unlock_irqrestore(&card->ip_lock, flags);
+			rc = qeth_l3_deregister_addr_entry(card, addr);
+			spin_lock_irqsave(&card->ip_lock, flags);
+			if (!rc)
+				kfree(addr);
+			else
+				list_add_tail(&addr->entry, &card->ip_list);
+			kfree(todo);
+		}
+	}
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+	kfree(tbd_list);
+}
+
+static void qeth_l3_clear_ip_list(struct qeth_card *card, int clean,
+					int recover)
+{
+	struct qeth_ipaddr *addr, *tmp;
+	unsigned long flags;
+
+	QETH_DBF_TEXT(trace, 4, "clearip");
+	spin_lock_irqsave(&card->ip_lock, flags);
+	/* clear todo list */
+	list_for_each_entry_safe(addr, tmp, card->ip_tbd_list, entry) {
+		list_del(&addr->entry);
+		kfree(addr);
+	}
+
+	while (!list_empty(&card->ip_list)) {
+		addr = list_entry(card->ip_list.next,
+				  struct qeth_ipaddr, entry);
+		list_del_init(&addr->entry);
+		if (clean) {
+			spin_unlock_irqrestore(&card->ip_lock, flags);
+			qeth_l3_deregister_addr_entry(card, addr);
+			spin_lock_irqsave(&card->ip_lock, flags);
+		}
+		if (!recover || addr->is_multicast) {
+			kfree(addr);
+			continue;
+		}
+		list_add_tail(&addr->entry, card->ip_tbd_list);
+	}
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+}
+
+static int qeth_l3_address_exists_in_list(struct list_head *list,
+		struct qeth_ipaddr *addr, int same_type)
+{
+	struct qeth_ipaddr *tmp;
+
+	list_for_each_entry(tmp, list, entry) {
+		if ((tmp->proto == QETH_PROT_IPV4) &&
+		    (addr->proto == QETH_PROT_IPV4) &&
+		    ((same_type && (tmp->type == addr->type)) ||
+		    (!same_type && (tmp->type != addr->type))) &&
+		    (tmp->u.a4.addr == addr->u.a4.addr))
+			return 1;
+
+		if ((tmp->proto == QETH_PROT_IPV6) &&
+		    (addr->proto == QETH_PROT_IPV6) &&
+		    ((same_type && (tmp->type == addr->type)) ||
+		    (!same_type && (tmp->type != addr->type))) &&
+		    (memcmp(&tmp->u.a6.addr, &addr->u.a6.addr,
+			    sizeof(struct in6_addr)) == 0))
+			return 1;
+
+	}
+	return 0;
+}
+
+static int qeth_l3_send_setdelmc(struct qeth_card *card,
+			struct qeth_ipaddr *addr, int ipacmd)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 4, "setdelmc");
+
+	iob = qeth_get_ipacmd_buffer(card, ipacmd, addr->proto);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	memcpy(&cmd->data.setdelipm.mac, addr->mac, OSA_ADDR_LEN);
+	if (addr->proto == QETH_PROT_IPV6)
+		memcpy(cmd->data.setdelipm.ip6, &addr->u.a6.addr,
+		       sizeof(struct in6_addr));
+	else
+		memcpy(&cmd->data.setdelipm.ip4, &addr->u.a4.addr, 4);
+
+	rc = qeth_send_ipa_cmd(card, iob, NULL, NULL);
+
+	return rc;
+}
+
+static void qeth_l3_fill_netmask(u8 *netmask, unsigned int len)
+{
+	int i, j;
+	for (i = 0; i < 16; i++) {
+		j = (len) - (i * 8);
+		if (j >= 8)
+			netmask[i] = 0xff;
+		else if (j > 0)
+			netmask[i] = (u8)(0xFF00 >> j);
+		else
+			netmask[i] = 0;
+	}
+}
+
+static int qeth_l3_send_setdelip(struct qeth_card *card,
+		struct qeth_ipaddr *addr, int ipacmd, unsigned int flags)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+	__u8 netmask[16];
+
+	QETH_DBF_TEXT(trace, 4, "setdelip");
+	QETH_DBF_TEXT_(trace, 4, "flags%02X", flags);
+
+	iob = qeth_get_ipacmd_buffer(card, ipacmd, addr->proto);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	if (addr->proto == QETH_PROT_IPV6) {
+		memcpy(cmd->data.setdelip6.ip_addr, &addr->u.a6.addr,
+		       sizeof(struct in6_addr));
+		qeth_l3_fill_netmask(netmask, addr->u.a6.pfxlen);
+		memcpy(cmd->data.setdelip6.mask, netmask,
+		       sizeof(struct in6_addr));
+		cmd->data.setdelip6.flags = flags;
+	} else {
+		memcpy(cmd->data.setdelip4.ip_addr, &addr->u.a4.addr, 4);
+		memcpy(cmd->data.setdelip4.mask, &addr->u.a4.mask, 4);
+		cmd->data.setdelip4.flags = flags;
+	}
+
+	rc = qeth_send_ipa_cmd(card, iob, NULL, NULL);
+
+	return rc;
+}
+
+static int qeth_l3_send_setrouting(struct qeth_card *card,
+	enum qeth_routing_types type, enum qeth_prot_versions prot)
+{
+	int rc;
+	struct qeth_ipa_cmd *cmd;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(trace, 4, "setroutg");
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETRTG, prot);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	cmd->data.setrtg.type = (type);
+	rc = qeth_send_ipa_cmd(card, iob, NULL, NULL);
+
+	return rc;
+}
+
+static void qeth_l3_correct_routing_type(struct qeth_card *card,
+		enum qeth_routing_types *type, enum qeth_prot_versions prot)
+{
+	if (card->info.type == QETH_CARD_TYPE_IQD) {
+		switch (*type) {
+		case NO_ROUTER:
+		case PRIMARY_CONNECTOR:
+		case SECONDARY_CONNECTOR:
+		case MULTICAST_ROUTER:
+			return;
+		default:
+			goto out_inval;
+		}
+	} else {
+		switch (*type) {
+		case NO_ROUTER:
+		case PRIMARY_ROUTER:
+		case SECONDARY_ROUTER:
+			return;
+		case MULTICAST_ROUTER:
+			if (qeth_is_ipafunc_supported(card, prot,
+						      IPA_OSA_MC_ROUTER))
+				return;
+		default:
+			goto out_inval;
+		}
+	}
+out_inval:
+	PRINT_WARN("Routing type '%s' not supported for interface %s.\n"
+		   "Router status set to 'no router'.\n",
+		   ((*type == PRIMARY_ROUTER)? "primary router" :
+		    (*type == SECONDARY_ROUTER)? "secondary router" :
+		    (*type == PRIMARY_CONNECTOR)? "primary connector" :
+		    (*type == SECONDARY_CONNECTOR)? "secondary connector" :
+		    (*type == MULTICAST_ROUTER)? "multicast router" :
+		    "unknown"),
+		   card->dev->name);
+	*type = NO_ROUTER;
+}
+
+int qeth_l3_setrouting_v4(struct qeth_card *card)
+{
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "setrtg4");
+
+	qeth_l3_correct_routing_type(card, &card->options.route4.type,
+				  QETH_PROT_IPV4);
+
+	rc = qeth_l3_send_setrouting(card, card->options.route4.type,
+				  QETH_PROT_IPV4);
+	if (rc) {
+		card->options.route4.type = NO_ROUTER;
+		PRINT_WARN("Error (0x%04x) while setting routing type on %s. "
+			   "Type set to 'no router'.\n",
+			   rc, QETH_CARD_IFNAME(card));
+	}
+	return rc;
+}
+
+int qeth_l3_setrouting_v6(struct qeth_card *card)
+{
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 3, "setrtg6");
+#ifdef CONFIG_QETH_IPV6
+
+	if (!qeth_is_supported(card, IPA_IPV6))
+		return 0;
+	qeth_l3_correct_routing_type(card, &card->options.route6.type,
+				  QETH_PROT_IPV6);
+
+	rc = qeth_l3_send_setrouting(card, card->options.route6.type,
+				  QETH_PROT_IPV6);
+	if (rc) {
+		card->options.route6.type = NO_ROUTER;
+		PRINT_WARN("Error (0x%04x) while setting routing type on %s. "
+			   "Type set to 'no router'.\n",
+			   rc, QETH_CARD_IFNAME(card));
+	}
+#endif
+	return rc;
+}
+
+/*
+ * IP address takeover related functions
+ */
+static void qeth_l3_clear_ipato_list(struct qeth_card *card)
+{
+
+	struct qeth_ipato_entry *ipatoe, *tmp;
+	unsigned long flags;
+
+	spin_lock_irqsave(&card->ip_lock, flags);
+	list_for_each_entry_safe(ipatoe, tmp, &card->ipato.entries, entry) {
+		list_del(&ipatoe->entry);
+		kfree(ipatoe);
+	}
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+}
+
+int qeth_l3_add_ipato_entry(struct qeth_card *card,
+				struct qeth_ipato_entry *new)
+{
+	struct qeth_ipato_entry *ipatoe;
+	unsigned long flags;
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 2, "addipato");
+	spin_lock_irqsave(&card->ip_lock, flags);
+	list_for_each_entry(ipatoe, &card->ipato.entries, entry) {
+		if (ipatoe->proto != new->proto)
+			continue;
+		if (!memcmp(ipatoe->addr, new->addr,
+			    (ipatoe->proto == QETH_PROT_IPV4)? 4:16) &&
+		    (ipatoe->mask_bits == new->mask_bits)) {
+			PRINT_WARN("ipato entry already exists!\n");
+			rc = -EEXIST;
+			break;
+		}
+	}
+	if (!rc)
+		list_add_tail(&new->entry, &card->ipato.entries);
+
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+	return rc;
+}
+
+void qeth_l3_del_ipato_entry(struct qeth_card *card,
+		enum qeth_prot_versions proto, u8 *addr, int mask_bits)
+{
+	struct qeth_ipato_entry *ipatoe, *tmp;
+	unsigned long flags;
+
+	QETH_DBF_TEXT(trace, 2, "delipato");
+	spin_lock_irqsave(&card->ip_lock, flags);
+	list_for_each_entry_safe(ipatoe, tmp, &card->ipato.entries, entry) {
+		if (ipatoe->proto != proto)
+			continue;
+		if (!memcmp(ipatoe->addr, addr,
+			    (proto == QETH_PROT_IPV4)? 4:16) &&
+		    (ipatoe->mask_bits == mask_bits)) {
+			list_del(&ipatoe->entry);
+			kfree(ipatoe);
+		}
+	}
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+}
+
+/*
+ * VIPA related functions
+ */
+int qeth_l3_add_vipa(struct qeth_card *card, enum qeth_prot_versions proto,
+	      const u8 *addr)
+{
+	struct qeth_ipaddr *ipaddr;
+	unsigned long flags;
+	int rc = 0;
+
+	ipaddr = qeth_l3_get_addr_buffer(proto);
+	if (ipaddr) {
+		if (proto == QETH_PROT_IPV4) {
+			QETH_DBF_TEXT(trace, 2, "addvipa4");
+			memcpy(&ipaddr->u.a4.addr, addr, 4);
+			ipaddr->u.a4.mask = 0;
+		} else if (proto == QETH_PROT_IPV6) {
+			QETH_DBF_TEXT(trace, 2, "addvipa6");
+			memcpy(&ipaddr->u.a6.addr, addr, 16);
+			ipaddr->u.a6.pfxlen = 0;
+		}
+		ipaddr->type = QETH_IP_TYPE_VIPA;
+		ipaddr->set_flags = QETH_IPA_SETIP_VIPA_FLAG;
+		ipaddr->del_flags = QETH_IPA_DELIP_VIPA_FLAG;
+	} else
+		return -ENOMEM;
+	spin_lock_irqsave(&card->ip_lock, flags);
+	if (qeth_l3_address_exists_in_list(&card->ip_list, ipaddr, 0) ||
+	    qeth_l3_address_exists_in_list(card->ip_tbd_list, ipaddr, 0))
+		rc = -EEXIST;
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+	if (rc) {
+		PRINT_WARN("Cannot add VIPA. Address already exists!\n");
+		return rc;
+	}
+	if (!qeth_l3_add_ip(card, ipaddr))
+		kfree(ipaddr);
+	qeth_l3_set_ip_addr_list(card);
+	return rc;
+}
+
+void qeth_l3_del_vipa(struct qeth_card *card, enum qeth_prot_versions proto,
+	      const u8 *addr)
+{
+	struct qeth_ipaddr *ipaddr;
+
+	ipaddr = qeth_l3_get_addr_buffer(proto);
+	if (ipaddr) {
+		if (proto == QETH_PROT_IPV4) {
+			QETH_DBF_TEXT(trace, 2, "delvipa4");
+			memcpy(&ipaddr->u.a4.addr, addr, 4);
+			ipaddr->u.a4.mask = 0;
+		} else if (proto == QETH_PROT_IPV6) {
+			QETH_DBF_TEXT(trace, 2, "delvipa6");
+			memcpy(&ipaddr->u.a6.addr, addr, 16);
+			ipaddr->u.a6.pfxlen = 0;
+		}
+		ipaddr->type = QETH_IP_TYPE_VIPA;
+	} else
+		return;
+	if (!qeth_l3_delete_ip(card, ipaddr))
+		kfree(ipaddr);
+	qeth_l3_set_ip_addr_list(card);
+}
+
+/*
+ * proxy ARP related functions
+ */
+int qeth_l3_add_rxip(struct qeth_card *card, enum qeth_prot_versions proto,
+	      const u8 *addr)
+{
+	struct qeth_ipaddr *ipaddr;
+	unsigned long flags;
+	int rc = 0;
+
+	ipaddr = qeth_l3_get_addr_buffer(proto);
+	if (ipaddr) {
+		if (proto == QETH_PROT_IPV4) {
+			QETH_DBF_TEXT(trace, 2, "addrxip4");
+			memcpy(&ipaddr->u.a4.addr, addr, 4);
+			ipaddr->u.a4.mask = 0;
+		} else if (proto == QETH_PROT_IPV6) {
+			QETH_DBF_TEXT(trace, 2, "addrxip6");
+			memcpy(&ipaddr->u.a6.addr, addr, 16);
+			ipaddr->u.a6.pfxlen = 0;
+		}
+		ipaddr->type = QETH_IP_TYPE_RXIP;
+		ipaddr->set_flags = QETH_IPA_SETIP_TAKEOVER_FLAG;
+		ipaddr->del_flags = 0;
+	} else
+		return -ENOMEM;
+	spin_lock_irqsave(&card->ip_lock, flags);
+	if (qeth_l3_address_exists_in_list(&card->ip_list, ipaddr, 0) ||
+	    qeth_l3_address_exists_in_list(card->ip_tbd_list, ipaddr, 0))
+		rc = -EEXIST;
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+	if (rc) {
+		PRINT_WARN("Cannot add RXIP. Address already exists!\n");
+		return rc;
+	}
+	if (!qeth_l3_add_ip(card, ipaddr))
+		kfree(ipaddr);
+	qeth_l3_set_ip_addr_list(card);
+	return 0;
+}
+
+void qeth_l3_del_rxip(struct qeth_card *card, enum qeth_prot_versions proto,
+			const u8 *addr)
+{
+	struct qeth_ipaddr *ipaddr;
+
+	ipaddr = qeth_l3_get_addr_buffer(proto);
+	if (ipaddr) {
+		if (proto == QETH_PROT_IPV4) {
+			QETH_DBF_TEXT(trace, 2, "addrxip4");
+			memcpy(&ipaddr->u.a4.addr, addr, 4);
+			ipaddr->u.a4.mask = 0;
+		} else if (proto == QETH_PROT_IPV6) {
+			QETH_DBF_TEXT(trace, 2, "addrxip6");
+			memcpy(&ipaddr->u.a6.addr, addr, 16);
+			ipaddr->u.a6.pfxlen = 0;
+		}
+		ipaddr->type = QETH_IP_TYPE_RXIP;
+	} else
+		return;
+	if (!qeth_l3_delete_ip(card, ipaddr))
+		kfree(ipaddr);
+	qeth_l3_set_ip_addr_list(card);
+}
+
+static int qeth_l3_register_addr_entry(struct qeth_card *card,
+				struct qeth_ipaddr *addr)
+{
+	char buf[50];
+	int rc = 0;
+	int cnt = 3;
+
+	if (addr->proto == QETH_PROT_IPV4) {
+		QETH_DBF_TEXT(trace, 2, "setaddr4");
+		QETH_DBF_HEX(trace, 3, &addr->u.a4.addr, sizeof(int));
+	} else if (addr->proto == QETH_PROT_IPV6) {
+		QETH_DBF_TEXT(trace, 2, "setaddr6");
+		QETH_DBF_HEX(trace, 3, &addr->u.a6.addr, 8);
+		QETH_DBF_HEX(trace, 3, ((char *)&addr->u.a6.addr) + 8, 8);
+	} else {
+		QETH_DBF_TEXT(trace, 2, "setaddr?");
+		QETH_DBF_HEX(trace, 3, addr, sizeof(struct qeth_ipaddr));
+	}
+	do {
+		if (addr->is_multicast)
+			rc =  qeth_l3_send_setdelmc(card, addr, IPA_CMD_SETIPM);
+		else
+			rc = qeth_l3_send_setdelip(card, addr, IPA_CMD_SETIP,
+					addr->set_flags);
+		if (rc)
+			QETH_DBF_TEXT(trace, 2, "failed");
+	} while ((--cnt > 0) && rc);
+	if (rc) {
+		QETH_DBF_TEXT(trace, 2, "FAILED");
+		qeth_l3_ipaddr_to_string(addr->proto, (u8 *)&addr->u, buf);
+		PRINT_WARN("Could not register IP address %s (rc=0x%x/%d)\n",
+			   buf, rc, rc);
+	}
+	return rc;
+}
+
+static int qeth_l3_deregister_addr_entry(struct qeth_card *card,
+						struct qeth_ipaddr *addr)
+{
+	int rc = 0;
+
+	if (addr->proto == QETH_PROT_IPV4) {
+		QETH_DBF_TEXT(trace, 2, "deladdr4");
+		QETH_DBF_HEX(trace, 3, &addr->u.a4.addr, sizeof(int));
+	} else if (addr->proto == QETH_PROT_IPV6) {
+		QETH_DBF_TEXT(trace, 2, "deladdr6");
+		QETH_DBF_HEX(trace, 3, &addr->u.a6.addr, 8);
+		QETH_DBF_HEX(trace, 3, ((char *)&addr->u.a6.addr) + 8, 8);
+	} else {
+		QETH_DBF_TEXT(trace, 2, "deladdr?");
+		QETH_DBF_HEX(trace, 3, addr, sizeof(struct qeth_ipaddr));
+	}
+	if (addr->is_multicast)
+		rc = qeth_l3_send_setdelmc(card, addr, IPA_CMD_DELIPM);
+	else
+		rc = qeth_l3_send_setdelip(card, addr, IPA_CMD_DELIP,
+					addr->del_flags);
+	if (rc) {
+		QETH_DBF_TEXT(trace, 2, "failed");
+		/* TODO: re-activate this warning as soon as we have a
+		 * clean mirco code
+		qeth_ipaddr_to_string(addr->proto, (u8 *)&addr->u, buf);
+		PRINT_WARN("Could not deregister IP address %s (rc=%x)\n",
+			   buf, rc);
+		*/
+	}
+
+	return rc;
+}
+
+static inline u8 qeth_l3_get_qeth_hdr_flags4(int cast_type)
+{
+	if (cast_type == RTN_MULTICAST)
+		return QETH_CAST_MULTICAST;
+	if (cast_type == RTN_BROADCAST)
+		return QETH_CAST_BROADCAST;
+	return QETH_CAST_UNICAST;
+}
+
+static inline u8 qeth_l3_get_qeth_hdr_flags6(int cast_type)
+{
+	u8 ct = QETH_HDR_PASSTHRU | QETH_HDR_IPV6;
+	if (cast_type == RTN_MULTICAST)
+		return ct | QETH_CAST_MULTICAST;
+	if (cast_type == RTN_ANYCAST)
+		return ct | QETH_CAST_ANYCAST;
+	if (cast_type == RTN_BROADCAST)
+		return ct | QETH_CAST_BROADCAST;
+	return ct | QETH_CAST_UNICAST;
+}
+
+static int qeth_l3_send_setadp_mode(struct qeth_card *card, __u32 command,
+					__u32 mode)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 4, "adpmode");
+
+	iob = qeth_get_adapter_cmd(card, command,
+				   sizeof(struct qeth_ipacmd_setadpparms));
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	cmd->data.setadapterparms.data.mode = mode;
+	rc = qeth_send_ipa_cmd(card, iob, qeth_default_setadapterparms_cb,
+			       NULL);
+	return rc;
+}
+
+static int qeth_l3_setadapter_hstr(struct qeth_card *card)
+{
+	int rc;
+
+	QETH_DBF_TEXT(trace, 4, "adphstr");
+
+	if (qeth_adp_supported(card, IPA_SETADP_SET_BROADCAST_MODE)) {
+		rc = qeth_l3_send_setadp_mode(card,
+					IPA_SETADP_SET_BROADCAST_MODE,
+					card->options.broadcast_mode);
+		if (rc)
+			PRINT_WARN("couldn't set broadcast mode on "
+				   "device %s: x%x\n",
+				   CARD_BUS_ID(card), rc);
+		rc = qeth_l3_send_setadp_mode(card,
+					IPA_SETADP_ALTER_MAC_ADDRESS,
+					card->options.macaddr_mode);
+		if (rc)
+			PRINT_WARN("couldn't set macaddr mode on "
+				   "device %s: x%x\n", CARD_BUS_ID(card), rc);
+		return rc;
+	}
+	if (card->options.broadcast_mode == QETH_TR_BROADCAST_LOCAL)
+		PRINT_WARN("set adapter parameters not available "
+			   "to set broadcast mode, using ALLRINGS "
+			   "on device %s:\n", CARD_BUS_ID(card));
+	if (card->options.macaddr_mode == QETH_TR_MACADDR_CANONICAL)
+		PRINT_WARN("set adapter parameters not available "
+			   "to set macaddr mode, using NONCANONICAL "
+			   "on device %s:\n", CARD_BUS_ID(card));
+	return 0;
+}
+
+static int qeth_l3_setadapter_parms(struct qeth_card *card)
+{
+	int rc;
+
+	QETH_DBF_TEXT(setup, 2, "setadprm");
+
+	if (!qeth_is_supported(card, IPA_SETADAPTERPARMS)) {
+		PRINT_WARN("set adapter parameters not supported "
+			   "on device %s.\n",
+			   CARD_BUS_ID(card));
+		QETH_DBF_TEXT(setup, 2, " notsupp");
+		return 0;
+	}
+	rc = qeth_query_setadapterparms(card);
+	if (rc) {
+		PRINT_WARN("couldn't set adapter parameters on device %s: "
+			   "x%x\n", CARD_BUS_ID(card), rc);
+		return rc;
+	}
+	if (qeth_adp_supported(card, IPA_SETADP_ALTER_MAC_ADDRESS)) {
+		rc = qeth_setadpparms_change_macaddr(card);
+		if (rc)
+			PRINT_WARN("couldn't get MAC address on "
+				   "device %s: x%x\n",
+				   CARD_BUS_ID(card), rc);
+	}
+
+	if ((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
+	    (card->info.link_type == QETH_LINK_TYPE_LANE_TR))
+		rc = qeth_l3_setadapter_hstr(card);
+
+	return rc;
+}
+
+static int qeth_l3_default_setassparms_cb(struct qeth_card *card,
+			struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 4, "defadpcb");
+
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (cmd->hdr.return_code == 0) {
+		cmd->hdr.return_code = cmd->data.setassparms.hdr.return_code;
+		if (cmd->hdr.prot_version == QETH_PROT_IPV4)
+			card->options.ipa4.enabled_funcs = cmd->hdr.ipa_enabled;
+		if (cmd->hdr.prot_version == QETH_PROT_IPV6)
+			card->options.ipa6.enabled_funcs = cmd->hdr.ipa_enabled;
+	}
+	if (cmd->data.setassparms.hdr.assist_no == IPA_INBOUND_CHECKSUM &&
+	    cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_START) {
+		card->info.csum_mask = cmd->data.setassparms.data.flags_32bit;
+		QETH_DBF_TEXT_(trace, 3, "csum:%d", card->info.csum_mask);
+	}
+	return 0;
+}
+
+static struct qeth_cmd_buffer *qeth_l3_get_setassparms_cmd(
+	struct qeth_card *card, enum qeth_ipa_funcs ipa_func, __u16 cmd_code,
+	__u16 len, enum qeth_prot_versions prot)
+{
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 4, "getasscm");
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETASSPARMS, prot);
+
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	cmd->data.setassparms.hdr.assist_no = ipa_func;
+	cmd->data.setassparms.hdr.length = 8 + len;
+	cmd->data.setassparms.hdr.command_code = cmd_code;
+	cmd->data.setassparms.hdr.return_code = 0;
+	cmd->data.setassparms.hdr.seq_no = 0;
+
+	return iob;
+}
+
+static int qeth_l3_send_setassparms(struct qeth_card *card,
+	struct qeth_cmd_buffer *iob, __u16 len, long data,
+	int (*reply_cb)(struct qeth_card *, struct qeth_reply *,
+		unsigned long),
+	void *reply_param)
+{
+	int rc;
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 4, "sendassp");
+
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	if (len <= sizeof(__u32))
+		cmd->data.setassparms.data.flags_32bit = (__u32) data;
+	else   /* (len > sizeof(__u32)) */
+		memcpy(&cmd->data.setassparms.data, (void *) data, len);
+
+	rc = qeth_send_ipa_cmd(card, iob, reply_cb, reply_param);
+	return rc;
+}
+
+#ifdef CONFIG_QETH_IPV6
+static int qeth_l3_send_simple_setassparms_ipv6(struct qeth_card *card,
+		enum qeth_ipa_funcs ipa_func, __u16 cmd_code)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(trace, 4, "simassp6");
+	iob = qeth_l3_get_setassparms_cmd(card, ipa_func, cmd_code,
+				       0, QETH_PROT_IPV6);
+	rc = qeth_l3_send_setassparms(card, iob, 0, 0,
+				   qeth_l3_default_setassparms_cb, NULL);
+	return rc;
+}
+#endif
+
+static int qeth_l3_send_simple_setassparms(struct qeth_card *card,
+		enum qeth_ipa_funcs ipa_func, __u16 cmd_code, long data)
+{
+	int rc;
+	int length = 0;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT(trace, 4, "simassp4");
+	if (data)
+		length = sizeof(__u32);
+	iob = qeth_l3_get_setassparms_cmd(card, ipa_func, cmd_code,
+				       length, QETH_PROT_IPV4);
+	rc = qeth_l3_send_setassparms(card, iob, length, data,
+				   qeth_l3_default_setassparms_cb, NULL);
+	return rc;
+}
+
+static int qeth_l3_start_ipa_arp_processing(struct qeth_card *card)
+{
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "ipaarp");
+
+	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
+		PRINT_WARN("ARP processing not supported "
+			   "on %s!\n", QETH_CARD_IFNAME(card));
+		return 0;
+	}
+	rc = qeth_l3_send_simple_setassparms(card, IPA_ARP_PROCESSING,
+					IPA_CMD_ASS_START, 0);
+	if (rc) {
+		PRINT_WARN("Could not start ARP processing "
+			   "assist on %s: 0x%x\n",
+			   QETH_CARD_IFNAME(card), rc);
+	}
+	return rc;
+}
+
+static int qeth_l3_start_ipa_ip_fragmentation(struct qeth_card *card)
+{
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "ipaipfrg");
+
+	if (!qeth_is_supported(card, IPA_IP_FRAGMENTATION)) {
+		PRINT_INFO("Hardware IP fragmentation not supported on %s\n",
+			   QETH_CARD_IFNAME(card));
+		return  -EOPNOTSUPP;
+	}
+
+	rc = qeth_l3_send_simple_setassparms(card, IPA_IP_FRAGMENTATION,
+					  IPA_CMD_ASS_START, 0);
+	if (rc) {
+		PRINT_WARN("Could not start Hardware IP fragmentation "
+			   "assist on %s: 0x%x\n",
+			   QETH_CARD_IFNAME(card), rc);
+	} else
+		PRINT_INFO("Hardware IP fragmentation enabled \n");
+	return rc;
+}
+
+static int qeth_l3_start_ipa_source_mac(struct qeth_card *card)
+{
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "stsrcmac");
+
+	if (!card->options.fake_ll)
+		return -EOPNOTSUPP;
+
+	if (!qeth_is_supported(card, IPA_SOURCE_MAC)) {
+		PRINT_INFO("Inbound source address not "
+			   "supported on %s\n", QETH_CARD_IFNAME(card));
+		return -EOPNOTSUPP;
+	}
+
+	rc = qeth_l3_send_simple_setassparms(card, IPA_SOURCE_MAC,
+					  IPA_CMD_ASS_START, 0);
+	if (rc)
+		PRINT_WARN("Could not start inbound source "
+			   "assist on %s: 0x%x\n",
+			   QETH_CARD_IFNAME(card), rc);
+	return rc;
+}
+
+static int qeth_l3_start_ipa_vlan(struct qeth_card *card)
+{
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 3, "strtvlan");
+
+	if (!qeth_is_supported(card, IPA_FULL_VLAN)) {
+		PRINT_WARN("VLAN not supported on %s\n",
+				QETH_CARD_IFNAME(card));
+		return -EOPNOTSUPP;
+	}
+
+	rc = qeth_l3_send_simple_setassparms(card, IPA_VLAN_PRIO,
+					  IPA_CMD_ASS_START, 0);
+	if (rc) {
+		PRINT_WARN("Could not start vlan "
+			   "assist on %s: 0x%x\n",
+			   QETH_CARD_IFNAME(card), rc);
+	} else {
+		PRINT_INFO("VLAN enabled \n");
+	}
+	return rc;
+}
+
+static int qeth_l3_start_ipa_multicast(struct qeth_card *card)
+{
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "stmcast");
+
+	if (!qeth_is_supported(card, IPA_MULTICASTING)) {
+		PRINT_WARN("Multicast not supported on %s\n",
+			   QETH_CARD_IFNAME(card));
+		return -EOPNOTSUPP;
+	}
+
+	rc = qeth_l3_send_simple_setassparms(card, IPA_MULTICASTING,
+					  IPA_CMD_ASS_START, 0);
+	if (rc) {
+		PRINT_WARN("Could not start multicast "
+			   "assist on %s: rc=%i\n",
+			   QETH_CARD_IFNAME(card), rc);
+	} else {
+		PRINT_INFO("Multicast enabled\n");
+		card->dev->flags |= IFF_MULTICAST;
+	}
+	return rc;
+}
+
+static int qeth_l3_query_ipassists_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(setup, 2, "qipasscb");
+
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (cmd->hdr.prot_version == QETH_PROT_IPV4) {
+		card->options.ipa4.supported_funcs = cmd->hdr.ipa_supported;
+		card->options.ipa4.enabled_funcs = cmd->hdr.ipa_enabled;
+	} else {
+		card->options.ipa6.supported_funcs = cmd->hdr.ipa_supported;
+		card->options.ipa6.enabled_funcs = cmd->hdr.ipa_enabled;
+	}
+	QETH_DBF_TEXT(setup, 2, "suppenbl");
+	QETH_DBF_TEXT_(setup, 2, "%x", cmd->hdr.ipa_supported);
+	QETH_DBF_TEXT_(setup, 2, "%x", cmd->hdr.ipa_enabled);
+	return 0;
+}
+
+static int qeth_l3_query_ipassists(struct qeth_card *card,
+				enum qeth_prot_versions prot)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT_(setup, 2, "qipassi%i", prot);
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_QIPASSIST, prot);
+	rc = qeth_send_ipa_cmd(card, iob, qeth_l3_query_ipassists_cb, NULL);
+	return rc;
+}
+
+#ifdef CONFIG_QETH_IPV6
+static int qeth_l3_softsetup_ipv6(struct qeth_card *card)
+{
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "softipv6");
+
+	if (card->info.type == QETH_CARD_TYPE_IQD)
+		goto out;
+
+	rc = qeth_l3_query_ipassists(card, QETH_PROT_IPV6);
+	if (rc) {
+		PRINT_ERR("IPv6 query ipassist failed on %s\n",
+			  QETH_CARD_IFNAME(card));
+		return rc;
+	}
+	rc = qeth_l3_send_simple_setassparms(card, IPA_IPV6,
+					  IPA_CMD_ASS_START, 3);
+	if (rc) {
+		PRINT_WARN("IPv6 start assist (version 4) failed "
+			   "on %s: 0x%x\n",
+			   QETH_CARD_IFNAME(card), rc);
+		return rc;
+	}
+	rc = qeth_l3_send_simple_setassparms_ipv6(card, IPA_IPV6,
+					       IPA_CMD_ASS_START);
+	if (rc) {
+		PRINT_WARN("IPV6 start assist (version 6) failed  "
+			   "on %s: 0x%x\n",
+			   QETH_CARD_IFNAME(card), rc);
+		return rc;
+	}
+	rc = qeth_l3_send_simple_setassparms_ipv6(card, IPA_PASSTHRU,
+					       IPA_CMD_ASS_START);
+	if (rc) {
+		PRINT_WARN("Could not enable passthrough "
+			   "on %s: 0x%x\n",
+			   QETH_CARD_IFNAME(card), rc);
+		return rc;
+	}
+out:
+	PRINT_INFO("IPV6 enabled \n");
+	return 0;
+}
+#endif
+
+static int qeth_l3_start_ipa_ipv6(struct qeth_card *card)
+{
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 3, "strtipv6");
+
+	if (!qeth_is_supported(card, IPA_IPV6)) {
+		PRINT_WARN("IPv6 not supported on %s\n",
+			   QETH_CARD_IFNAME(card));
+		return 0;
+	}
+#ifdef CONFIG_QETH_IPV6
+	rc = qeth_l3_softsetup_ipv6(card);
+#endif
+	return rc ;
+}
+
+static int qeth_l3_start_ipa_broadcast(struct qeth_card *card)
+{
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "stbrdcst");
+	card->info.broadcast_capable = 0;
+	if (!qeth_is_supported(card, IPA_FILTERING)) {
+		PRINT_WARN("Broadcast not supported on %s\n",
+			   QETH_CARD_IFNAME(card));
+		rc = -EOPNOTSUPP;
+		goto out;
+	}
+	rc = qeth_l3_send_simple_setassparms(card, IPA_FILTERING,
+					  IPA_CMD_ASS_START, 0);
+	if (rc) {
+		PRINT_WARN("Could not enable broadcasting filtering "
+			   "on %s: 0x%x\n",
+			   QETH_CARD_IFNAME(card), rc);
+		goto out;
+	}
+
+	rc = qeth_l3_send_simple_setassparms(card, IPA_FILTERING,
+					  IPA_CMD_ASS_CONFIGURE, 1);
+	if (rc) {
+		PRINT_WARN("Could not set up broadcast filtering on %s: 0x%x\n",
+			   QETH_CARD_IFNAME(card), rc);
+		goto out;
+	}
+	card->info.broadcast_capable = QETH_BROADCAST_WITH_ECHO;
+	PRINT_INFO("Broadcast enabled \n");
+	rc = qeth_l3_send_simple_setassparms(card, IPA_FILTERING,
+					  IPA_CMD_ASS_ENABLE, 1);
+	if (rc) {
+		PRINT_WARN("Could not set up broadcast echo filtering on "
+			   "%s: 0x%x\n", QETH_CARD_IFNAME(card), rc);
+		goto out;
+	}
+	card->info.broadcast_capable = QETH_BROADCAST_WITHOUT_ECHO;
+out:
+	if (card->info.broadcast_capable)
+		card->dev->flags |= IFF_BROADCAST;
+	else
+		card->dev->flags &= ~IFF_BROADCAST;
+	return rc;
+}
+
+static int qeth_l3_send_checksum_command(struct qeth_card *card)
+{
+	int rc;
+
+	rc = qeth_l3_send_simple_setassparms(card, IPA_INBOUND_CHECKSUM,
+					  IPA_CMD_ASS_START, 0);
+	if (rc) {
+		PRINT_WARN("Starting Inbound HW Checksumming failed on %s: "
+			   "0x%x,\ncontinuing using Inbound SW Checksumming\n",
+			   QETH_CARD_IFNAME(card), rc);
+		return rc;
+	}
+	rc = qeth_l3_send_simple_setassparms(card, IPA_INBOUND_CHECKSUM,
+					  IPA_CMD_ASS_ENABLE,
+					  card->info.csum_mask);
+	if (rc) {
+		PRINT_WARN("Enabling Inbound HW Checksumming failed on %s: "
+			   "0x%x,\ncontinuing using Inbound SW Checksumming\n",
+			   QETH_CARD_IFNAME(card), rc);
+		return rc;
+	}
+	return 0;
+}
+
+static int qeth_l3_start_ipa_checksum(struct qeth_card *card)
+{
+	int rc = 0;
+
+	QETH_DBF_TEXT(trace, 3, "strtcsum");
+
+	if (card->options.checksum_type == NO_CHECKSUMMING) {
+		PRINT_WARN("Using no checksumming on %s.\n",
+			   QETH_CARD_IFNAME(card));
+		return 0;
+	}
+	if (card->options.checksum_type == SW_CHECKSUMMING) {
+		PRINT_WARN("Using SW checksumming on %s.\n",
+			   QETH_CARD_IFNAME(card));
+		return 0;
+	}
+	if (!qeth_is_supported(card, IPA_INBOUND_CHECKSUM)) {
+		PRINT_WARN("Inbound HW Checksumming not "
+			   "supported on %s,\ncontinuing "
+			   "using Inbound SW Checksumming\n",
+			   QETH_CARD_IFNAME(card));
+		card->options.checksum_type = SW_CHECKSUMMING;
+		return 0;
+	}
+	rc = qeth_l3_send_checksum_command(card);
+	if (!rc)
+		PRINT_INFO("HW Checksumming (inbound) enabled \n");
+
+	return rc;
+}
+
+static int qeth_l3_start_ipa_tso(struct qeth_card *card)
+{
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "sttso");
+
+	if (!qeth_is_supported(card, IPA_OUTBOUND_TSO)) {
+		PRINT_WARN("Outbound TSO not supported on %s\n",
+			   QETH_CARD_IFNAME(card));
+		rc = -EOPNOTSUPP;
+	} else {
+		rc = qeth_l3_send_simple_setassparms(card, IPA_OUTBOUND_TSO,
+						IPA_CMD_ASS_START, 0);
+		if (rc)
+			PRINT_WARN("Could not start outbound TSO "
+				   "assist on %s: rc=%i\n",
+				   QETH_CARD_IFNAME(card), rc);
+		else
+			PRINT_INFO("Outbound TSO enabled\n");
+	}
+	if (rc && (card->options.large_send == QETH_LARGE_SEND_TSO)) {
+		card->options.large_send = QETH_LARGE_SEND_NO;
+		card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG);
+	}
+	return rc;
+}
+
+static int qeth_l3_start_ipassists(struct qeth_card *card)
+{
+	QETH_DBF_TEXT(trace, 3, "strtipas");
+	qeth_l3_start_ipa_arp_processing(card);	/* go on*/
+	qeth_l3_start_ipa_ip_fragmentation(card);	/* go on*/
+	qeth_l3_start_ipa_source_mac(card);	/* go on*/
+	qeth_l3_start_ipa_vlan(card);		/* go on*/
+	qeth_l3_start_ipa_multicast(card);		/* go on*/
+	qeth_l3_start_ipa_ipv6(card);		/* go on*/
+	qeth_l3_start_ipa_broadcast(card);		/* go on*/
+	qeth_l3_start_ipa_checksum(card);		/* go on*/
+	qeth_l3_start_ipa_tso(card);		/* go on*/
+	return 0;
+}
+
+static int qeth_l3_put_unique_id(struct qeth_card *card)
+{
+
+	int rc = 0;
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(trace, 2, "puniqeid");
+
+	if ((card->info.unique_id & UNIQUE_ID_NOT_BY_CARD) ==
+		UNIQUE_ID_NOT_BY_CARD)
+		return -1;
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_DESTROY_ADDR,
+				     QETH_PROT_IPV6);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	*((__u16 *) &cmd->data.create_destroy_addr.unique_id[6]) =
+				card->info.unique_id;
+	memcpy(&cmd->data.create_destroy_addr.unique_id[0],
+	       card->dev->dev_addr, OSA_ADDR_LEN);
+	rc = qeth_send_ipa_cmd(card, iob, NULL, NULL);
+	return rc;
+}
+
+static int qeth_l3_iqd_read_initial_mac_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (cmd->hdr.return_code == 0)
+		memcpy(card->dev->dev_addr,
+			cmd->data.create_destroy_addr.unique_id, ETH_ALEN);
+	else
+		random_ether_addr(card->dev->dev_addr);
+
+	return 0;
+}
+
+static int qeth_l3_iqd_read_initial_mac(struct qeth_card *card)
+{
+	int rc = 0;
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(setup, 2, "hsrmac");
+
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_CREATE_ADDR,
+				     QETH_PROT_IPV6);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	*((__u16 *) &cmd->data.create_destroy_addr.unique_id[6]) =
+			card->info.unique_id;
+
+	rc = qeth_send_ipa_cmd(card, iob, qeth_l3_iqd_read_initial_mac_cb,
+				NULL);
+	return rc;
+}
+
+static int qeth_l3_get_unique_id_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (cmd->hdr.return_code == 0)
+		card->info.unique_id = *((__u16 *)
+				&cmd->data.create_destroy_addr.unique_id[6]);
+	else {
+		card->info.unique_id =  UNIQUE_ID_IF_CREATE_ADDR_FAILED |
+					UNIQUE_ID_NOT_BY_CARD;
+		PRINT_WARN("couldn't get a unique id from the card on device "
+			   "%s (result=x%x), using default id. ipv6 "
+			   "autoconfig on other lpars may lead to duplicate "
+			   "ip addresses. please use manually "
+			   "configured ones.\n",
+			   CARD_BUS_ID(card), cmd->hdr.return_code);
+	}
+	return 0;
+}
+
+static int qeth_l3_get_unique_id(struct qeth_card *card)
+{
+	int rc = 0;
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(setup, 2, "guniqeid");
+
+	if (!qeth_is_supported(card, IPA_IPV6)) {
+		card->info.unique_id =  UNIQUE_ID_IF_CREATE_ADDR_FAILED |
+					UNIQUE_ID_NOT_BY_CARD;
+		return 0;
+	}
+
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_CREATE_ADDR,
+				     QETH_PROT_IPV6);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	*((__u16 *) &cmd->data.create_destroy_addr.unique_id[6]) =
+			card->info.unique_id;
+
+	rc = qeth_send_ipa_cmd(card, iob, qeth_l3_get_unique_id_cb, NULL);
+	return rc;
+}
+
+static void qeth_l3_get_mac_for_ipm(__u32 ipm, char *mac,
+				struct net_device *dev)
+{
+	if (dev->type == ARPHRD_IEEE802_TR)
+		ip_tr_mc_map(ipm, mac);
+	else
+		ip_eth_mc_map(ipm, mac);
+}
+
+static void qeth_l3_add_mc(struct qeth_card *card, struct in_device *in4_dev)
+{
+	struct qeth_ipaddr *ipm;
+	struct ip_mc_list *im4;
+	char buf[MAX_ADDR_LEN];
+
+	QETH_DBF_TEXT(trace, 4, "addmc");
+	for (im4 = in4_dev->mc_list; im4; im4 = im4->next) {
+		qeth_l3_get_mac_for_ipm(im4->multiaddr, buf, in4_dev->dev);
+		ipm = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
+		if (!ipm)
+			continue;
+		ipm->u.a4.addr = im4->multiaddr;
+		memcpy(ipm->mac, buf, OSA_ADDR_LEN);
+		ipm->is_multicast = 1;
+		if (!qeth_l3_add_ip(card, ipm))
+			kfree(ipm);
+	}
+}
+
+static void qeth_l3_add_vlan_mc(struct qeth_card *card)
+{
+	struct in_device *in_dev;
+	struct vlan_group *vg;
+	int i;
+
+	QETH_DBF_TEXT(trace, 4, "addmcvl");
+	if (!qeth_is_supported(card, IPA_FULL_VLAN) || (card->vlangrp == NULL))
+		return;
+
+	vg = card->vlangrp;
+	for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+		struct net_device *netdev = vlan_group_get_device(vg, i);
+		if (netdev == NULL ||
+		    !(netdev->flags & IFF_UP))
+			continue;
+		in_dev = in_dev_get(netdev);
+		if (!in_dev)
+			continue;
+		read_lock(&in_dev->mc_list_lock);
+		qeth_l3_add_mc(card, in_dev);
+		read_unlock(&in_dev->mc_list_lock);
+		in_dev_put(in_dev);
+	}
+}
+
+static void qeth_l3_add_multicast_ipv4(struct qeth_card *card)
+{
+	struct in_device *in4_dev;
+
+	QETH_DBF_TEXT(trace, 4, "chkmcv4");
+	in4_dev = in_dev_get(card->dev);
+	if (in4_dev == NULL)
+		return;
+	read_lock(&in4_dev->mc_list_lock);
+	qeth_l3_add_mc(card, in4_dev);
+	qeth_l3_add_vlan_mc(card);
+	read_unlock(&in4_dev->mc_list_lock);
+	in_dev_put(in4_dev);
+}
+
+#ifdef CONFIG_QETH_IPV6
+static void qeth_l3_add_mc6(struct qeth_card *card, struct inet6_dev *in6_dev)
+{
+	struct qeth_ipaddr *ipm;
+	struct ifmcaddr6 *im6;
+	char buf[MAX_ADDR_LEN];
+
+	QETH_DBF_TEXT(trace, 4, "addmc6");
+	for (im6 = in6_dev->mc_list; im6 != NULL; im6 = im6->next) {
+		ndisc_mc_map(&im6->mca_addr, buf, in6_dev->dev, 0);
+		ipm = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
+		if (!ipm)
+			continue;
+		ipm->is_multicast = 1;
+		memcpy(ipm->mac, buf, OSA_ADDR_LEN);
+		memcpy(&ipm->u.a6.addr, &im6->mca_addr.s6_addr,
+		       sizeof(struct in6_addr));
+		if (!qeth_l3_add_ip(card, ipm))
+			kfree(ipm);
+	}
+}
+
+static void qeth_l3_add_vlan_mc6(struct qeth_card *card)
+{
+	struct inet6_dev *in_dev;
+	struct vlan_group *vg;
+	int i;
+
+	QETH_DBF_TEXT(trace, 4, "admc6vl");
+	if (!qeth_is_supported(card, IPA_FULL_VLAN) || (card->vlangrp == NULL))
+		return;
+
+	vg = card->vlangrp;
+	for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+		struct net_device *netdev = vlan_group_get_device(vg, i);
+		if (netdev == NULL ||
+		    !(netdev->flags & IFF_UP))
+			continue;
+		in_dev = in6_dev_get(netdev);
+		if (!in_dev)
+			continue;
+		read_lock_bh(&in_dev->lock);
+		qeth_l3_add_mc6(card, in_dev);
+		read_unlock_bh(&in_dev->lock);
+		in6_dev_put(in_dev);
+	}
+}
+
+static void qeth_l3_add_multicast_ipv6(struct qeth_card *card)
+{
+	struct inet6_dev *in6_dev;
+
+	QETH_DBF_TEXT(trace, 4, "chkmcv6");
+	if (!qeth_is_supported(card, IPA_IPV6))
+		return ;
+	in6_dev = in6_dev_get(card->dev);
+	if (in6_dev == NULL)
+		return;
+	read_lock_bh(&in6_dev->lock);
+	qeth_l3_add_mc6(card, in6_dev);
+	qeth_l3_add_vlan_mc6(card);
+	read_unlock_bh(&in6_dev->lock);
+	in6_dev_put(in6_dev);
+}
+#endif /* CONFIG_QETH_IPV6 */
+
+static void qeth_l3_free_vlan_addresses4(struct qeth_card *card,
+			unsigned short vid)
+{
+	struct in_device *in_dev;
+	struct in_ifaddr *ifa;
+	struct qeth_ipaddr *addr;
+
+	QETH_DBF_TEXT(trace, 4, "frvaddr4");
+
+	in_dev = in_dev_get(vlan_group_get_device(card->vlangrp, vid));
+	if (!in_dev)
+		return;
+	for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
+		addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
+		if (addr) {
+			addr->u.a4.addr = ifa->ifa_address;
+			addr->u.a4.mask = ifa->ifa_mask;
+			addr->type = QETH_IP_TYPE_NORMAL;
+			if (!qeth_l3_delete_ip(card, addr))
+				kfree(addr);
+		}
+	}
+	in_dev_put(in_dev);
+}
+
+static void qeth_l3_free_vlan_addresses6(struct qeth_card *card,
+			unsigned short vid)
+{
+#ifdef CONFIG_QETH_IPV6
+	struct inet6_dev *in6_dev;
+	struct inet6_ifaddr *ifa;
+	struct qeth_ipaddr *addr;
+
+	QETH_DBF_TEXT(trace, 4, "frvaddr6");
+
+	in6_dev = in6_dev_get(vlan_group_get_device(card->vlangrp, vid));
+	if (!in6_dev)
+		return;
+	for (ifa = in6_dev->addr_list; ifa; ifa = ifa->lst_next) {
+		addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
+		if (addr) {
+			memcpy(&addr->u.a6.addr, &ifa->addr,
+			       sizeof(struct in6_addr));
+			addr->u.a6.pfxlen = ifa->prefix_len;
+			addr->type = QETH_IP_TYPE_NORMAL;
+			if (!qeth_l3_delete_ip(card, addr))
+				kfree(addr);
+		}
+	}
+	in6_dev_put(in6_dev);
+#endif /* CONFIG_QETH_IPV6 */
+}
+
+static void qeth_l3_free_vlan_addresses(struct qeth_card *card,
+			unsigned short vid)
+{
+	if (!card->vlangrp)
+		return;
+	qeth_l3_free_vlan_addresses4(card, vid);
+	qeth_l3_free_vlan_addresses6(card, vid);
+}
+
+static void qeth_l3_vlan_rx_register(struct net_device *dev,
+			struct vlan_group *grp)
+{
+	struct qeth_card *card = netdev_priv(dev);
+	unsigned long flags;
+
+	QETH_DBF_TEXT(trace, 4, "vlanreg");
+	spin_lock_irqsave(&card->vlanlock, flags);
+	card->vlangrp = grp;
+	spin_unlock_irqrestore(&card->vlanlock, flags);
+}
+
+static void qeth_l3_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+{
+	struct net_device *vlandev;
+	struct qeth_card *card = (struct qeth_card *) dev->priv;
+	struct in_device *in_dev;
+
+	if (card->info.type == QETH_CARD_TYPE_IQD)
+		return;
+
+	vlandev = vlan_group_get_device(card->vlangrp, vid);
+	vlandev->neigh_setup = qeth_l3_neigh_setup;
+
+	in_dev = in_dev_get(vlandev);
+#ifdef CONFIG_SYSCTL
+	neigh_sysctl_unregister(in_dev->arp_parms);
+#endif
+	neigh_parms_release(&arp_tbl, in_dev->arp_parms);
+
+	in_dev->arp_parms = neigh_parms_alloc(vlandev, &arp_tbl);
+#ifdef CONFIG_SYSCTL
+	neigh_sysctl_register(vlandev, in_dev->arp_parms, NET_IPV4,
+			      NET_IPV4_NEIGH, "ipv4", NULL, NULL);
+#endif
+	in_dev_put(in_dev);
+	return;
+}
+
+static void qeth_l3_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+{
+	struct qeth_card *card = netdev_priv(dev);
+	unsigned long flags;
+
+	QETH_DBF_TEXT_(trace, 4, "kid:%d", vid);
+	spin_lock_irqsave(&card->vlanlock, flags);
+	/* unregister IP addresses of vlan device */
+	qeth_l3_free_vlan_addresses(card, vid);
+	vlan_group_set_device(card->vlangrp, vid, NULL);
+	spin_unlock_irqrestore(&card->vlanlock, flags);
+	qeth_l3_set_multicast_list(card->dev);
+}
+
+static inline __u16 qeth_l3_rebuild_skb(struct qeth_card *card,
+			struct sk_buff *skb, struct qeth_hdr *hdr)
+{
+	unsigned short vlan_id = 0;
+	__be16 prot;
+	struct iphdr *ip_hdr;
+	unsigned char tg_addr[MAX_ADDR_LEN];
+
+	if (!(hdr->hdr.l3.flags & QETH_HDR_PASSTHRU)) {
+		prot = htons((hdr->hdr.l3.flags & QETH_HDR_IPV6)? ETH_P_IPV6 :
+			      ETH_P_IP);
+		switch (hdr->hdr.l3.flags & QETH_HDR_CAST_MASK) {
+		case QETH_CAST_MULTICAST:
+			switch (prot) {
+#ifdef CONFIG_QETH_IPV6
+			case __constant_htons(ETH_P_IPV6):
+				ndisc_mc_map((struct in6_addr *)
+				     skb->data + 24,
+				     tg_addr, card->dev, 0);
+				break;
+#endif
+			case __constant_htons(ETH_P_IP):
+				ip_hdr = (struct iphdr *)skb->data;
+				(card->dev->type == ARPHRD_IEEE802_TR) ?
+				ip_tr_mc_map(ip_hdr->daddr, tg_addr):
+				ip_eth_mc_map(ip_hdr->daddr, tg_addr);
+				break;
+			default:
+				memcpy(tg_addr, card->dev->broadcast,
+					card->dev->addr_len);
+			}
+			card->stats.multicast++;
+			skb->pkt_type = PACKET_MULTICAST;
+			break;
+		case QETH_CAST_BROADCAST:
+			memcpy(tg_addr, card->dev->broadcast,
+				card->dev->addr_len);
+			card->stats.multicast++;
+			skb->pkt_type = PACKET_BROADCAST;
+			break;
+		case QETH_CAST_UNICAST:
+		case QETH_CAST_ANYCAST:
+		case QETH_CAST_NOCAST:
+		default:
+			skb->pkt_type = PACKET_HOST;
+			memcpy(tg_addr, card->dev->dev_addr,
+				card->dev->addr_len);
+		}
+		card->dev->header_ops->create(skb, card->dev, prot, tg_addr,
+					      "FAKELL", card->dev->addr_len);
+	}
+
+#ifdef CONFIG_TR
+	if (card->dev->type == ARPHRD_IEEE802_TR)
+		skb->protocol = tr_type_trans(skb, card->dev);
+	else
+#endif
+		skb->protocol = eth_type_trans(skb, card->dev);
+
+	if (hdr->hdr.l3.ext_flags &
+	    (QETH_HDR_EXT_VLAN_FRAME | QETH_HDR_EXT_INCLUDE_VLAN_TAG)) {
+		vlan_id = (hdr->hdr.l3.ext_flags & QETH_HDR_EXT_VLAN_FRAME)?
+		 hdr->hdr.l3.vlan_id : *((u16 *)&hdr->hdr.l3.dest_addr[12]);
+	}
+
+	skb->ip_summed = card->options.checksum_type;
+	if (card->options.checksum_type == HW_CHECKSUMMING) {
+		if ((hdr->hdr.l3.ext_flags &
+		      (QETH_HDR_EXT_CSUM_HDR_REQ |
+		       QETH_HDR_EXT_CSUM_TRANSP_REQ)) ==
+		     (QETH_HDR_EXT_CSUM_HDR_REQ |
+		      QETH_HDR_EXT_CSUM_TRANSP_REQ))
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		else
+			skb->ip_summed = SW_CHECKSUMMING;
+	}
+
+	return vlan_id;
+}
+
+static void qeth_l3_process_inbound_buffer(struct qeth_card *card,
+			    struct qeth_qdio_buffer *buf, int index)
+{
+	struct qdio_buffer_element *element;
+	struct sk_buff *skb;
+	struct qeth_hdr *hdr;
+	int offset;
+	__u16 vlan_tag = 0;
+	unsigned int len;
+
+	/* get first element of current buffer */
+	element = (struct qdio_buffer_element *)&buf->buffer->element[0];
+	offset = 0;
+	if (card->options.performance_stats)
+		card->perf_stats.bufs_rec++;
+	while ((skb = qeth_core_get_next_skb(card, buf->buffer, &element,
+				       &offset, &hdr))) {
+		skb->dev = card->dev;
+		/* is device UP ? */
+		if (!(card->dev->flags & IFF_UP)) {
+			dev_kfree_skb_any(skb);
+			continue;
+		}
+
+		switch (hdr->hdr.l3.id) {
+		case QETH_HEADER_TYPE_LAYER3:
+			vlan_tag = qeth_l3_rebuild_skb(card, skb, hdr);
+			len = skb->len;
+			if (vlan_tag)
+				if (card->vlangrp)
+					vlan_hwaccel_rx(skb, card->vlangrp,
+						vlan_tag);
+				else {
+					dev_kfree_skb_any(skb);
+					continue;
+				}
+			else
+				netif_rx(skb);
+			break;
+		default:
+			dev_kfree_skb_any(skb);
+			QETH_DBF_TEXT(trace, 3, "inbunkno");
+			QETH_DBF_HEX(control, 3, hdr, QETH_DBF_CONTROL_LEN);
+			continue;
+		}
+
+		card->dev->last_rx = jiffies;
+		card->stats.rx_packets++;
+		card->stats.rx_bytes += len;
+	}
+}
+
+static int qeth_l3_verify_vlan_dev(struct net_device *dev,
+			struct qeth_card *card)
+{
+	int rc = 0;
+	struct vlan_group *vg;
+	int i;
+
+	vg = card->vlangrp;
+	if (!vg)
+		return rc;
+
+	for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+		if (vlan_group_get_device(vg, i) == dev) {
+			rc = QETH_VLAN_CARD;
+			break;
+		}
+	}
+
+	if (rc && !(netdev_priv(vlan_dev_info(dev)->real_dev) == (void *)card))
+		return 0;
+
+	return rc;
+}
+
+static int qeth_l3_verify_dev(struct net_device *dev)
+{
+	struct qeth_card *card;
+	unsigned long flags;
+	int rc = 0;
+
+	read_lock_irqsave(&qeth_core_card_list.rwlock, flags);
+	list_for_each_entry(card, &qeth_core_card_list.list, list) {
+		if (card->dev == dev) {
+			rc = QETH_REAL_CARD;
+			break;
+		}
+		rc = qeth_l3_verify_vlan_dev(dev, card);
+		if (rc)
+			break;
+	}
+	read_unlock_irqrestore(&qeth_core_card_list.rwlock, flags);
+
+	return rc;
+}
+
+static struct qeth_card *qeth_l3_get_card_from_dev(struct net_device *dev)
+{
+	struct qeth_card *card = NULL;
+	int rc;
+
+	rc = qeth_l3_verify_dev(dev);
+	if (rc == QETH_REAL_CARD)
+		card = netdev_priv(dev);
+	else if (rc == QETH_VLAN_CARD)
+		card = netdev_priv(vlan_dev_info(dev)->real_dev);
+	if (card->options.layer2)
+		card = NULL;
+	QETH_DBF_TEXT_(trace, 4, "%d", rc);
+	return card ;
+}
+
+static int qeth_l3_stop_card(struct qeth_card *card, int recovery_mode)
+{
+	int rc = 0;
+
+	QETH_DBF_TEXT(setup, 2, "stopcard");
+	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+
+	qeth_set_allowed_threads(card, 0, 1);
+	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD))
+		return -ERESTARTSYS;
+	if (card->read.state == CH_STATE_UP &&
+	    card->write.state == CH_STATE_UP &&
+	    (card->state == CARD_STATE_UP)) {
+		if (recovery_mode)
+			qeth_l3_stop(card->dev);
+		if (!card->use_hard_stop) {
+			rc = qeth_send_stoplan(card);
+			if (rc)
+				QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		}
+		card->state = CARD_STATE_SOFTSETUP;
+	}
+	if (card->state == CARD_STATE_SOFTSETUP) {
+		qeth_l3_clear_ip_list(card, !card->use_hard_stop, 1);
+		qeth_clear_ipacmd_list(card);
+		card->state = CARD_STATE_HARDSETUP;
+	}
+	if (card->state == CARD_STATE_HARDSETUP) {
+		if (!card->use_hard_stop &&
+		    (card->info.type != QETH_CARD_TYPE_IQD)) {
+			rc = qeth_l3_put_unique_id(card);
+			if (rc)
+				QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		}
+		qeth_qdio_clear_card(card, 0);
+		qeth_clear_qdio_buffers(card);
+		qeth_clear_working_pool_list(card);
+		card->state = CARD_STATE_DOWN;
+	}
+	if (card->state == CARD_STATE_DOWN) {
+		qeth_clear_cmd_buffers(&card->read);
+		qeth_clear_cmd_buffers(&card->write);
+	}
+	card->use_hard_stop = 0;
+	return rc;
+}
+
+static void qeth_l3_set_multicast_list(struct net_device *dev)
+{
+	struct qeth_card *card = netdev_priv(dev);
+
+	QETH_DBF_TEXT(trace, 3, "setmulti");
+	qeth_l3_delete_mc_addresses(card);
+	qeth_l3_add_multicast_ipv4(card);
+#ifdef CONFIG_QETH_IPV6
+	qeth_l3_add_multicast_ipv6(card);
+#endif
+	qeth_l3_set_ip_addr_list(card);
+	if (!qeth_adp_supported(card, IPA_SETADP_SET_PROMISC_MODE))
+		return;
+	qeth_setadp_promisc_mode(card);
+}
+
+static const char *qeth_l3_arp_get_error_cause(int *rc)
+{
+	switch (*rc) {
+	case QETH_IPA_ARP_RC_FAILED:
+		*rc = -EIO;
+		return "operation failed";
+	case QETH_IPA_ARP_RC_NOTSUPP:
+		*rc = -EOPNOTSUPP;
+		return "operation not supported";
+	case QETH_IPA_ARP_RC_OUT_OF_RANGE:
+		*rc = -EINVAL;
+		return "argument out of range";
+	case QETH_IPA_ARP_RC_Q_NOTSUPP:
+		*rc = -EOPNOTSUPP;
+		return "query operation not supported";
+	case QETH_IPA_ARP_RC_Q_NO_DATA:
+		*rc = -ENOENT;
+		return "no query data available";
+	default:
+		return "unknown error";
+	}
+}
+
+static int qeth_l3_arp_set_no_entries(struct qeth_card *card, int no_entries)
+{
+	int tmp;
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "arpstnoe");
+
+	/*
+	 * currently GuestLAN only supports the ARP assist function
+	 * IPA_CMD_ASS_ARP_QUERY_INFO, but not IPA_CMD_ASS_ARP_SET_NO_ENTRIES;
+	 * thus we say EOPNOTSUPP for this ARP function
+	 */
+	if (card->info.guestlan)
+		return -EOPNOTSUPP;
+	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
+		PRINT_WARN("ARP processing not supported "
+			   "on %s!\n", QETH_CARD_IFNAME(card));
+		return -EOPNOTSUPP;
+	}
+	rc = qeth_l3_send_simple_setassparms(card, IPA_ARP_PROCESSING,
+					  IPA_CMD_ASS_ARP_SET_NO_ENTRIES,
+					  no_entries);
+	if (rc) {
+		tmp = rc;
+		PRINT_WARN("Could not set number of ARP entries on %s: "
+			"%s (0x%x/%d)\n", QETH_CARD_IFNAME(card),
+			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
+	}
+	return rc;
+}
+
+static void qeth_l3_copy_arp_entries_stripped(struct qeth_arp_query_info *qinfo,
+		struct qeth_arp_query_data *qdata, int entry_size,
+		int uentry_size)
+{
+	char *entry_ptr;
+	char *uentry_ptr;
+	int i;
+
+	entry_ptr = (char *)&qdata->data;
+	uentry_ptr = (char *)(qinfo->udata + qinfo->udata_offset);
+	for (i = 0; i < qdata->no_entries; ++i) {
+		/* strip off 32 bytes "media specific information" */
+		memcpy(uentry_ptr, (entry_ptr + 32), entry_size - 32);
+		entry_ptr += entry_size;
+		uentry_ptr += uentry_size;
+	}
+}
+
+static int qeth_l3_arp_query_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+	struct qeth_arp_query_data *qdata;
+	struct qeth_arp_query_info *qinfo;
+	int entry_size;
+	int uentry_size;
+	int i;
+
+	QETH_DBF_TEXT(trace, 4, "arpquecb");
+
+	qinfo = (struct qeth_arp_query_info *) reply->param;
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (cmd->hdr.return_code) {
+		QETH_DBF_TEXT_(trace, 4, "qaer1%i", cmd->hdr.return_code);
+		return 0;
+	}
+	if (cmd->data.setassparms.hdr.return_code) {
+		cmd->hdr.return_code = cmd->data.setassparms.hdr.return_code;
+		QETH_DBF_TEXT_(trace, 4, "qaer2%i", cmd->hdr.return_code);
+		return 0;
+	}
+	qdata = &cmd->data.setassparms.data.query_arp;
+	switch (qdata->reply_bits) {
+	case 5:
+		uentry_size = entry_size = sizeof(struct qeth_arp_qi_entry5);
+		if (qinfo->mask_bits & QETH_QARP_STRIP_ENTRIES)
+			uentry_size = sizeof(struct qeth_arp_qi_entry5_short);
+		break;
+	case 7:
+		/* fall through to default */
+	default:
+		/* tr is the same as eth -> entry7 */
+		uentry_size = entry_size = sizeof(struct qeth_arp_qi_entry7);
+		if (qinfo->mask_bits & QETH_QARP_STRIP_ENTRIES)
+			uentry_size = sizeof(struct qeth_arp_qi_entry7_short);
+		break;
+	}
+	/* check if there is enough room in userspace */
+	if ((qinfo->udata_len - qinfo->udata_offset) <
+			qdata->no_entries * uentry_size){
+		QETH_DBF_TEXT_(trace, 4, "qaer3%i", -ENOMEM);
+		cmd->hdr.return_code = -ENOMEM;
+		PRINT_WARN("query ARP user space buffer is too small for "
+			   "the returned number of ARP entries. "
+			   "Aborting query!\n");
+		goto out_error;
+	}
+	QETH_DBF_TEXT_(trace, 4, "anore%i",
+		       cmd->data.setassparms.hdr.number_of_replies);
+	QETH_DBF_TEXT_(trace, 4, "aseqn%i", cmd->data.setassparms.hdr.seq_no);
+	QETH_DBF_TEXT_(trace, 4, "anoen%i", qdata->no_entries);
+
+	if (qinfo->mask_bits & QETH_QARP_STRIP_ENTRIES) {
+		/* strip off "media specific information" */
+		qeth_l3_copy_arp_entries_stripped(qinfo, qdata, entry_size,
+					       uentry_size);
+	} else
+		/*copy entries to user buffer*/
+		memcpy(qinfo->udata + qinfo->udata_offset,
+		       (char *)&qdata->data, qdata->no_entries*uentry_size);
+
+	qinfo->no_entries += qdata->no_entries;
+	qinfo->udata_offset += (qdata->no_entries*uentry_size);
+	/* check if all replies received ... */
+	if (cmd->data.setassparms.hdr.seq_no <
+	    cmd->data.setassparms.hdr.number_of_replies)
+		return 1;
+	memcpy(qinfo->udata, &qinfo->no_entries, 4);
+	/* keep STRIP_ENTRIES flag so the user program can distinguish
+	 * stripped entries from normal ones */
+	if (qinfo->mask_bits & QETH_QARP_STRIP_ENTRIES)
+		qdata->reply_bits |= QETH_QARP_STRIP_ENTRIES;
+	memcpy(qinfo->udata + QETH_QARP_MASK_OFFSET, &qdata->reply_bits, 2);
+	return 0;
+out_error:
+	i = 0;
+	memcpy(qinfo->udata, &i, 4);
+	return 0;
+}
+
+static int qeth_l3_send_ipa_arp_cmd(struct qeth_card *card,
+		struct qeth_cmd_buffer *iob, int len,
+		int (*reply_cb)(struct qeth_card *, struct qeth_reply *,
+			unsigned long),
+		void *reply_param)
+{
+	QETH_DBF_TEXT(trace, 4, "sendarp");
+
+	memcpy(iob->data, IPA_PDU_HEADER, IPA_PDU_HEADER_SIZE);
+	memcpy(QETH_IPA_CMD_DEST_ADDR(iob->data),
+	       &card->token.ulp_connection_r, QETH_MPC_TOKEN_LENGTH);
+	return qeth_send_control_data(card, IPA_PDU_HEADER_SIZE + len, iob,
+				      reply_cb, reply_param);
+}
+
+static int qeth_l3_arp_query(struct qeth_card *card, char __user *udata)
+{
+	struct qeth_cmd_buffer *iob;
+	struct qeth_arp_query_info qinfo = {0, };
+	int tmp;
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "arpquery");
+
+	if (!qeth_is_supported(card,/*IPA_QUERY_ARP_ADDR_INFO*/
+			       IPA_ARP_PROCESSING)) {
+		PRINT_WARN("ARP processing not supported "
+			   "on %s!\n", QETH_CARD_IFNAME(card));
+		return -EOPNOTSUPP;
+	}
+	/* get size of userspace buffer and mask_bits -> 6 bytes */
+	if (copy_from_user(&qinfo, udata, 6))
+		return -EFAULT;
+	qinfo.udata = kzalloc(qinfo.udata_len, GFP_KERNEL);
+	if (!qinfo.udata)
+		return -ENOMEM;
+	qinfo.udata_offset = QETH_QARP_ENTRIES_OFFSET;
+	iob = qeth_l3_get_setassparms_cmd(card, IPA_ARP_PROCESSING,
+				       IPA_CMD_ASS_ARP_QUERY_INFO,
+				       sizeof(int), QETH_PROT_IPV4);
+
+	rc = qeth_l3_send_ipa_arp_cmd(card, iob,
+				   QETH_SETASS_BASE_LEN+QETH_ARP_CMD_LEN,
+				   qeth_l3_arp_query_cb, (void *)&qinfo);
+	if (rc) {
+		tmp = rc;
+		PRINT_WARN("Error while querying ARP cache on %s: %s "
+			"(0x%x/%d)\n", QETH_CARD_IFNAME(card),
+			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
+		if (copy_to_user(udata, qinfo.udata, 4))
+			rc = -EFAULT;
+	} else {
+		if (copy_to_user(udata, qinfo.udata, qinfo.udata_len))
+			rc = -EFAULT;
+	}
+	kfree(qinfo.udata);
+	return rc;
+}
+
+static int qeth_l3_arp_add_entry(struct qeth_card *card,
+				struct qeth_arp_cache_entry *entry)
+{
+	struct qeth_cmd_buffer *iob;
+	char buf[16];
+	int tmp;
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "arpadent");
+
+	/*
+	 * currently GuestLAN only supports the ARP assist function
+	 * IPA_CMD_ASS_ARP_QUERY_INFO, but not IPA_CMD_ASS_ARP_ADD_ENTRY;
+	 * thus we say EOPNOTSUPP for this ARP function
+	 */
+	if (card->info.guestlan)
+		return -EOPNOTSUPP;
+	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
+		PRINT_WARN("ARP processing not supported "
+			   "on %s!\n", QETH_CARD_IFNAME(card));
+		return -EOPNOTSUPP;
+	}
+
+	iob = qeth_l3_get_setassparms_cmd(card, IPA_ARP_PROCESSING,
+				       IPA_CMD_ASS_ARP_ADD_ENTRY,
+				       sizeof(struct qeth_arp_cache_entry),
+				       QETH_PROT_IPV4);
+	rc = qeth_l3_send_setassparms(card, iob,
+				   sizeof(struct qeth_arp_cache_entry),
+				   (unsigned long) entry,
+				   qeth_l3_default_setassparms_cb, NULL);
+	if (rc) {
+		tmp = rc;
+		qeth_l3_ipaddr4_to_string((u8 *)entry->ipaddr, buf);
+		PRINT_WARN("Could not add ARP entry for address %s on %s: "
+			   "%s (0x%x/%d)\n",
+			   buf, QETH_CARD_IFNAME(card),
+			   qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
+	}
+	return rc;
+}
+
+static int qeth_l3_arp_remove_entry(struct qeth_card *card,
+				struct qeth_arp_cache_entry *entry)
+{
+	struct qeth_cmd_buffer *iob;
+	char buf[16] = {0, };
+	int tmp;
+	int rc;
+
+	QETH_DBF_TEXT(trace, 3, "arprment");
+
+	/*
+	 * currently GuestLAN only supports the ARP assist function
+	 * IPA_CMD_ASS_ARP_QUERY_INFO, but not IPA_CMD_ASS_ARP_REMOVE_ENTRY;
+	 * thus we say EOPNOTSUPP for this ARP function
+	 */
+	if (card->info.guestlan)
+		return -EOPNOTSUPP;
+	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
+		PRINT_WARN("ARP processing not supported "
+			   "on %s!\n", QETH_CARD_IFNAME(card));
+		return -EOPNOTSUPP;
+	}
+	memcpy(buf, entry, 12);
+	iob = qeth_l3_get_setassparms_cmd(card, IPA_ARP_PROCESSING,
+				       IPA_CMD_ASS_ARP_REMOVE_ENTRY,
+				       12,
+				       QETH_PROT_IPV4);
+	rc = qeth_l3_send_setassparms(card, iob,
+				   12, (unsigned long)buf,
+				   qeth_l3_default_setassparms_cb, NULL);
+	if (rc) {
+		tmp = rc;
+		memset(buf, 0, 16);
+		qeth_l3_ipaddr4_to_string((u8 *)entry->ipaddr, buf);
+		PRINT_WARN("Could not delete ARP entry for address %s on %s: "
+			   "%s (0x%x/%d)\n",
+			   buf, QETH_CARD_IFNAME(card),
+			   qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
+	}
+	return rc;
+}
+
+static int qeth_l3_arp_flush_cache(struct qeth_card *card)
+{
+	int rc;
+	int tmp;
+
+	QETH_DBF_TEXT(trace, 3, "arpflush");
+
+	/*
+	 * currently GuestLAN only supports the ARP assist function
+	 * IPA_CMD_ASS_ARP_QUERY_INFO, but not IPA_CMD_ASS_ARP_FLUSH_CACHE;
+	 * thus we say EOPNOTSUPP for this ARP function
+	*/
+	if (card->info.guestlan || (card->info.type == QETH_CARD_TYPE_IQD))
+		return -EOPNOTSUPP;
+	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
+		PRINT_WARN("ARP processing not supported "
+			   "on %s!\n", QETH_CARD_IFNAME(card));
+		return -EOPNOTSUPP;
+	}
+	rc = qeth_l3_send_simple_setassparms(card, IPA_ARP_PROCESSING,
+					  IPA_CMD_ASS_ARP_FLUSH_CACHE, 0);
+	if (rc) {
+		tmp = rc;
+		PRINT_WARN("Could not flush ARP cache on %s: %s (0x%x/%d)\n",
+			QETH_CARD_IFNAME(card),
+			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
+	}
+	return rc;
+}
+
+static int qeth_l3_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct qeth_card *card = netdev_priv(dev);
+	struct qeth_arp_cache_entry arp_entry;
+	struct mii_ioctl_data *mii_data;
+	int rc = 0;
+
+	if (!card)
+		return -ENODEV;
+
+	if ((card->state != CARD_STATE_UP) &&
+		(card->state != CARD_STATE_SOFTSETUP))
+		return -ENODEV;
+
+	switch (cmd) {
+	case SIOC_QETH_ARP_SET_NO_ENTRIES:
+		if (!capable(CAP_NET_ADMIN)) {
+			rc = -EPERM;
+			break;
+		}
+		rc = qeth_l3_arp_set_no_entries(card, rq->ifr_ifru.ifru_ivalue);
+		break;
+	case SIOC_QETH_ARP_QUERY_INFO:
+		if (!capable(CAP_NET_ADMIN)) {
+			rc = -EPERM;
+			break;
+		}
+		rc = qeth_l3_arp_query(card, rq->ifr_ifru.ifru_data);
+		break;
+	case SIOC_QETH_ARP_ADD_ENTRY:
+		if (!capable(CAP_NET_ADMIN)) {
+			rc = -EPERM;
+			break;
+		}
+		if (copy_from_user(&arp_entry, rq->ifr_ifru.ifru_data,
+				   sizeof(struct qeth_arp_cache_entry)))
+			rc = -EFAULT;
+		else
+			rc = qeth_l3_arp_add_entry(card, &arp_entry);
+		break;
+	case SIOC_QETH_ARP_REMOVE_ENTRY:
+		if (!capable(CAP_NET_ADMIN)) {
+			rc = -EPERM;
+			break;
+		}
+		if (copy_from_user(&arp_entry, rq->ifr_ifru.ifru_data,
+				   sizeof(struct qeth_arp_cache_entry)))
+			rc = -EFAULT;
+		else
+			rc = qeth_l3_arp_remove_entry(card, &arp_entry);
+		break;
+	case SIOC_QETH_ARP_FLUSH_CACHE:
+		if (!capable(CAP_NET_ADMIN)) {
+			rc = -EPERM;
+			break;
+		}
+		rc = qeth_l3_arp_flush_cache(card);
+		break;
+	case SIOC_QETH_ADP_SET_SNMP_CONTROL:
+		rc = qeth_snmp_command(card, rq->ifr_ifru.ifru_data);
+		break;
+	case SIOC_QETH_GET_CARD_TYPE:
+		if ((card->info.type == QETH_CARD_TYPE_OSAE) &&
+		    !card->info.guestlan)
+			return 1;
+		return 0;
+		break;
+	case SIOCGMIIPHY:
+		mii_data = if_mii(rq);
+		mii_data->phy_id = 0;
+		break;
+	case SIOCGMIIREG:
+		mii_data = if_mii(rq);
+		if (mii_data->phy_id != 0)
+			rc = -EINVAL;
+		else
+			mii_data->val_out = qeth_mdio_read(dev,
+							mii_data->phy_id,
+							mii_data->reg_num);
+		break;
+	default:
+		rc = -EOPNOTSUPP;
+	}
+	if (rc)
+		QETH_DBF_TEXT_(trace, 2, "ioce%d", rc);
+	return rc;
+}
+
+static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
+		struct sk_buff *skb, int ipv, int cast_type)
+{
+	QETH_DBF_TEXT(trace, 6, "fillhdr");
+
+	memset(hdr, 0, sizeof(struct qeth_hdr));
+	hdr->hdr.l3.id = QETH_HEADER_TYPE_LAYER3;
+	hdr->hdr.l3.ext_flags = 0;
+
+	/*
+	 * before we're going to overwrite this location with next hop ip.
+	 * v6 uses passthrough, v4 sets the tag in the QDIO header.
+	 */
+	if (card->vlangrp && vlan_tx_tag_present(skb)) {
+		hdr->hdr.l3.ext_flags = (ipv == 4) ?
+			QETH_HDR_EXT_VLAN_FRAME :
+			QETH_HDR_EXT_INCLUDE_VLAN_TAG;
+		hdr->hdr.l3.vlan_id = vlan_tx_tag_get(skb);
+	}
+
+	hdr->hdr.l3.length = skb->len - sizeof(struct qeth_hdr);
+	if (ipv == 4) {
+		/* IPv4 */
+		hdr->hdr.l3.flags = qeth_l3_get_qeth_hdr_flags4(cast_type);
+		memset(hdr->hdr.l3.dest_addr, 0, 12);
+		if ((skb->dst) && (skb->dst->neighbour)) {
+			*((u32 *) (&hdr->hdr.l3.dest_addr[12])) =
+			    *((u32 *) skb->dst->neighbour->primary_key);
+		} else {
+			/* fill in destination address used in ip header */
+			*((u32 *) (&hdr->hdr.l3.dest_addr[12])) =
+							ip_hdr(skb)->daddr;
+		}
+	} else if (ipv == 6) {
+		/* IPv6 */
+		hdr->hdr.l3.flags = qeth_l3_get_qeth_hdr_flags6(cast_type);
+		if (card->info.type == QETH_CARD_TYPE_IQD)
+			hdr->hdr.l3.flags &= ~QETH_HDR_PASSTHRU;
+		if ((skb->dst) && (skb->dst->neighbour)) {
+			memcpy(hdr->hdr.l3.dest_addr,
+			       skb->dst->neighbour->primary_key, 16);
+		} else {
+			/* fill in destination address used in ip header */
+			memcpy(hdr->hdr.l3.dest_addr,
+			       &ipv6_hdr(skb)->daddr, 16);
+		}
+	} else {
+		/* passthrough */
+		if ((skb->dev->type == ARPHRD_IEEE802_TR) &&
+			!memcmp(skb->data + sizeof(struct qeth_hdr) +
+			sizeof(__u16), skb->dev->broadcast, 6)) {
+			hdr->hdr.l3.flags = QETH_CAST_BROADCAST |
+						QETH_HDR_PASSTHRU;
+		} else if (!memcmp(skb->data + sizeof(struct qeth_hdr),
+			    skb->dev->broadcast, 6)) {
+			/* broadcast? */
+			hdr->hdr.l3.flags = QETH_CAST_BROADCAST |
+						QETH_HDR_PASSTHRU;
+		} else {
+			hdr->hdr.l3.flags = (cast_type == RTN_MULTICAST) ?
+				QETH_CAST_MULTICAST | QETH_HDR_PASSTHRU :
+				QETH_CAST_UNICAST | QETH_HDR_PASSTHRU;
+		}
+	}
+}
+
+static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int rc;
+	u16 *tag;
+	struct qeth_hdr *hdr = NULL;
+	int elements_needed = 0;
+	struct qeth_card *card = netdev_priv(dev);
+	struct sk_buff *new_skb = NULL;
+	int ipv = qeth_get_ip_version(skb);
+	int cast_type = qeth_get_cast_type(card, skb);
+	struct qeth_qdio_out_q *queue = card->qdio.out_qs
+		[qeth_get_priority_queue(card, skb, ipv, cast_type)];
+	int tx_bytes = skb->len;
+	enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
+	struct qeth_eddp_context *ctx = NULL;
+
+	QETH_DBF_TEXT(trace, 6, "l3xmit");
+
+	if ((card->info.type == QETH_CARD_TYPE_IQD) &&
+	    (skb->protocol != htons(ETH_P_IPV6)) &&
+	    (skb->protocol != htons(ETH_P_IP)))
+			goto tx_drop;
+
+	if ((card->state != CARD_STATE_UP) || !card->lan_online) {
+		card->stats.tx_carrier_errors++;
+		goto tx_drop;
+	}
+
+	if ((cast_type == RTN_BROADCAST) &&
+	    (card->info.broadcast_capable == 0))
+		goto tx_drop;
+
+	if (card->options.performance_stats) {
+		card->perf_stats.outbound_cnt++;
+		card->perf_stats.outbound_start_time = qeth_get_micros();
+	}
+
+	/* create a clone with writeable headroom */
+	new_skb = skb_realloc_headroom(skb, sizeof(struct qeth_hdr_tso) +
+					VLAN_HLEN);
+	if (!new_skb)
+		goto tx_drop;
+
+	if (card->info.type == QETH_CARD_TYPE_IQD) {
+		skb_pull(new_skb, ETH_HLEN);
+	} else {
+		if (new_skb->protocol == htons(ETH_P_IP)) {
+			if (card->dev->type == ARPHRD_IEEE802_TR)
+				skb_pull(new_skb, TR_HLEN);
+			else
+				skb_pull(new_skb, ETH_HLEN);
+		}
+
+		if (new_skb->protocol == ETH_P_IPV6 && card->vlangrp &&
+				vlan_tx_tag_present(new_skb)) {
+			skb_push(new_skb, VLAN_HLEN);
+			skb_copy_to_linear_data(new_skb, new_skb->data + 4, 4);
+			skb_copy_to_linear_data_offset(new_skb, 4,
+				new_skb->data + 8, 4);
+			skb_copy_to_linear_data_offset(new_skb, 8,
+				new_skb->data + 12, 4);
+			tag = (u16 *)(new_skb->data + 12);
+			*tag = __constant_htons(ETH_P_8021Q);
+			*(tag + 1) = htons(vlan_tx_tag_get(new_skb));
+			VLAN_TX_SKB_CB(new_skb)->magic = 0;
+		}
+	}
+
+	netif_stop_queue(dev);
+
+	if (skb_is_gso(new_skb))
+		large_send = card->options.large_send;
+
+	/* fix hardware limitation: as long as we do not have sbal
+	 * chaining we can not send long frag lists so we temporary
+	 * switch to EDDP
+	 */
+	if ((large_send == QETH_LARGE_SEND_TSO) &&
+		((skb_shinfo(new_skb)->nr_frags + 2) > 16))
+		large_send = QETH_LARGE_SEND_EDDP;
+
+	if ((large_send == QETH_LARGE_SEND_TSO) &&
+	    (cast_type == RTN_UNSPEC)) {
+		hdr = (struct qeth_hdr *)skb_push(new_skb,
+						sizeof(struct qeth_hdr_tso));
+		memset(hdr, 0, sizeof(struct qeth_hdr_tso));
+		qeth_l3_fill_header(card, hdr, new_skb, ipv, cast_type);
+		qeth_tso_fill_header(card, hdr, new_skb);
+		elements_needed++;
+	} else {
+		hdr = (struct qeth_hdr *)skb_push(new_skb,
+						sizeof(struct qeth_hdr));
+		qeth_l3_fill_header(card, hdr, new_skb, ipv, cast_type);
+	}
+
+	if (large_send == QETH_LARGE_SEND_EDDP) {
+		/* new_skb is not owned by a socket so we use skb to get
+		 * the protocol
+		 */
+		ctx = qeth_eddp_create_context(card, new_skb, hdr,
+						skb->sk->sk_protocol);
+		if (ctx == NULL) {
+			PRINT_WARN("could not create eddp context\n");
+			goto tx_drop;
+		}
+	} else {
+		int elems = qeth_get_elements_no(card, (void *)hdr, new_skb,
+						 elements_needed);
+		if (!elems)
+			goto tx_drop;
+		elements_needed += elems;
+	}
+
+	if ((large_send == QETH_LARGE_SEND_NO) &&
+	    (new_skb->ip_summed == CHECKSUM_PARTIAL))
+		qeth_tx_csum(new_skb);
+
+	if (card->info.type != QETH_CARD_TYPE_IQD)
+		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
+					 elements_needed, ctx);
+	else
+		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
+					      elements_needed, ctx);
+
+	if (!rc) {
+		card->stats.tx_packets++;
+		card->stats.tx_bytes += tx_bytes;
+		if (new_skb != skb)
+			dev_kfree_skb_any(skb);
+		if (card->options.performance_stats) {
+			if (large_send != QETH_LARGE_SEND_NO) {
+				card->perf_stats.large_send_bytes += tx_bytes;
+				card->perf_stats.large_send_cnt++;
+			}
+			if (skb_shinfo(new_skb)->nr_frags > 0) {
+				card->perf_stats.sg_skbs_sent++;
+				/* nr_frags + skb->data */
+				card->perf_stats.sg_frags_sent +=
+					skb_shinfo(new_skb)->nr_frags + 1;
+			}
+		}
+
+		if (ctx != NULL) {
+			qeth_eddp_put_context(ctx);
+			dev_kfree_skb_any(new_skb);
+		}
+	} else {
+		if (ctx != NULL)
+			qeth_eddp_put_context(ctx);
+
+		if (rc == -EBUSY) {
+			if (new_skb != skb)
+				dev_kfree_skb_any(new_skb);
+			return NETDEV_TX_BUSY;
+		} else
+			goto tx_drop;
+	}
+
+	netif_wake_queue(dev);
+	if (card->options.performance_stats)
+		card->perf_stats.outbound_time += qeth_get_micros() -
+			card->perf_stats.outbound_start_time;
+	return rc;
+
+tx_drop:
+	card->stats.tx_dropped++;
+	card->stats.tx_errors++;
+	if ((new_skb != skb) && new_skb)
+		dev_kfree_skb_any(new_skb);
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
+}
+
+static int qeth_l3_open(struct net_device *dev)
+{
+	struct qeth_card *card = netdev_priv(dev);
+
+	QETH_DBF_TEXT(trace, 4, "qethopen");
+	if (card->state != CARD_STATE_SOFTSETUP)
+		return -ENODEV;
+	card->data.state = CH_STATE_UP;
+	card->state = CARD_STATE_UP;
+	card->dev->flags |= IFF_UP;
+	netif_start_queue(dev);
+
+	if (!card->lan_online && netif_carrier_ok(dev))
+		netif_carrier_off(dev);
+	return 0;
+}
+
+static int qeth_l3_stop(struct net_device *dev)
+{
+	struct qeth_card *card = netdev_priv(dev);
+
+	QETH_DBF_TEXT(trace, 4, "qethstop");
+	netif_tx_disable(dev);
+	card->dev->flags &= ~IFF_UP;
+	if (card->state == CARD_STATE_UP)
+		card->state = CARD_STATE_SOFTSETUP;
+	return 0;
+}
+
+static u32 qeth_l3_ethtool_get_rx_csum(struct net_device *dev)
+{
+	struct qeth_card *card = netdev_priv(dev);
+
+	return (card->options.checksum_type == HW_CHECKSUMMING);
+}
+
+static int qeth_l3_ethtool_set_rx_csum(struct net_device *dev, u32 data)
+{
+	struct qeth_card *card = netdev_priv(dev);
+	enum qeth_card_states old_state;
+	enum qeth_checksum_types csum_type;
+
+	if ((card->state != CARD_STATE_UP) &&
+	    (card->state != CARD_STATE_DOWN))
+		return -EPERM;
+
+	if (data)
+		csum_type = HW_CHECKSUMMING;
+	else
+		csum_type = SW_CHECKSUMMING;
+
+	if (card->options.checksum_type != csum_type) {
+		old_state = card->state;
+		if (card->state == CARD_STATE_UP)
+			__qeth_l3_set_offline(card->gdev, 1);
+		card->options.checksum_type = csum_type;
+		if (old_state == CARD_STATE_UP)
+			__qeth_l3_set_online(card->gdev, 1);
+	}
+	return 0;
+}
+
+static int qeth_l3_ethtool_set_tso(struct net_device *dev, u32 data)
+{
+	struct qeth_card *card = netdev_priv(dev);
+
+	if (data) {
+		if (card->options.large_send == QETH_LARGE_SEND_NO) {
+			if (card->info.type == QETH_CARD_TYPE_IQD)
+				card->options.large_send = QETH_LARGE_SEND_EDDP;
+			else
+				card->options.large_send = QETH_LARGE_SEND_TSO;
+			dev->features |= NETIF_F_TSO;
+		}
+	} else {
+		dev->features &= ~NETIF_F_TSO;
+		card->options.large_send = QETH_LARGE_SEND_NO;
+	}
+	return 0;
+}
+
+static struct ethtool_ops qeth_l3_ethtool_ops = {
+	.get_link = ethtool_op_get_link,
+	.get_tx_csum = ethtool_op_get_tx_csum,
+	.set_tx_csum = ethtool_op_set_tx_hw_csum,
+	.get_rx_csum = qeth_l3_ethtool_get_rx_csum,
+	.set_rx_csum = qeth_l3_ethtool_set_rx_csum,
+	.get_sg      = ethtool_op_get_sg,
+	.set_sg      = ethtool_op_set_sg,
+	.get_tso     = ethtool_op_get_tso,
+	.set_tso     = qeth_l3_ethtool_set_tso,
+	.get_strings = qeth_core_get_strings,
+	.get_ethtool_stats = qeth_core_get_ethtool_stats,
+	.get_stats_count = qeth_core_get_stats_count,
+	.get_drvinfo = qeth_core_get_drvinfo,
+};
+
+/*
+ * we need NOARP for IPv4 but we want neighbor solicitation for IPv6. Setting
+ * NOARP on the netdevice is no option because it also turns off neighbor
+ * solicitation. For IPv4 we install a neighbor_setup function. We don't want
+ * arp resolution but we want the hard header (packet socket will work
+ * e.g. tcpdump)
+ */
+static int qeth_l3_neigh_setup_noarp(struct neighbour *n)
+{
+	n->nud_state = NUD_NOARP;
+	memcpy(n->ha, "FAKELL", 6);
+	n->output = n->ops->connected_output;
+	return 0;
+}
+
+static int
+qeth_l3_neigh_setup(struct net_device *dev, struct neigh_parms *np)
+{
+	if (np->tbl->family == AF_INET)
+		np->neigh_setup = qeth_l3_neigh_setup_noarp;
+
+	return 0;
+}
+
+static int qeth_l3_setup_netdev(struct qeth_card *card)
+{
+	if (card->info.type == QETH_CARD_TYPE_OSAE) {
+		if ((card->info.link_type == QETH_LINK_TYPE_LANE_TR) ||
+		    (card->info.link_type == QETH_LINK_TYPE_HSTR)) {
+#ifdef CONFIG_TR
+			card->dev = alloc_trdev(0);
+#endif
+			if (!card->dev)
+				return -ENODEV;
+		} else {
+			card->dev = alloc_etherdev(0);
+			if (!card->dev)
+				return -ENODEV;
+			card->dev->neigh_setup = qeth_l3_neigh_setup;
+
+			/*IPv6 address autoconfiguration stuff*/
+			qeth_l3_get_unique_id(card);
+			if (!(card->info.unique_id & UNIQUE_ID_NOT_BY_CARD))
+				card->dev->dev_id = card->info.unique_id &
+							 0xffff;
+		}
+	} else if (card->info.type == QETH_CARD_TYPE_IQD) {
+		card->dev = alloc_netdev(0, "hsi%d", ether_setup);
+		if (!card->dev)
+			return -ENODEV;
+		card->dev->flags |= IFF_NOARP;
+		qeth_l3_iqd_read_initial_mac(card);
+	} else
+		return -ENODEV;
+
+	card->dev->hard_start_xmit = qeth_l3_hard_start_xmit;
+	card->dev->priv = card;
+	card->dev->tx_timeout = &qeth_tx_timeout;
+	card->dev->watchdog_timeo = QETH_TX_TIMEOUT;
+	card->dev->open = qeth_l3_open;
+	card->dev->stop = qeth_l3_stop;
+	card->dev->do_ioctl = qeth_l3_do_ioctl;
+	card->dev->get_stats = qeth_get_stats;
+	card->dev->change_mtu = qeth_change_mtu;
+	card->dev->set_multicast_list = qeth_l3_set_multicast_list;
+	card->dev->vlan_rx_register = qeth_l3_vlan_rx_register;
+	card->dev->vlan_rx_add_vid = qeth_l3_vlan_rx_add_vid;
+	card->dev->vlan_rx_kill_vid = qeth_l3_vlan_rx_kill_vid;
+	card->dev->mtu = card->info.initial_mtu;
+	SET_ETHTOOL_OPS(card->dev, &qeth_l3_ethtool_ops);
+	card->dev->features |=	NETIF_F_HW_VLAN_TX |
+				NETIF_F_HW_VLAN_RX |
+				NETIF_F_HW_VLAN_FILTER;
+
+	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
+	return register_netdev(card->dev);
+}
+
+static void qeth_l3_qdio_input_handler(struct ccw_device *ccwdev,
+		unsigned int status, unsigned int qdio_err,
+		unsigned int siga_err, unsigned int queue, int first_element,
+		int count, unsigned long card_ptr)
+{
+	struct net_device *net_dev;
+	struct qeth_card *card;
+	struct qeth_qdio_buffer *buffer;
+	int index;
+	int i;
+
+	QETH_DBF_TEXT(trace, 6, "qdinput");
+	card = (struct qeth_card *) card_ptr;
+	net_dev = card->dev;
+	if (card->options.performance_stats) {
+		card->perf_stats.inbound_cnt++;
+		card->perf_stats.inbound_start_time = qeth_get_micros();
+	}
+	if (status & QDIO_STATUS_LOOK_FOR_ERROR) {
+		if (status & QDIO_STATUS_ACTIVATE_CHECK_CONDITION) {
+			QETH_DBF_TEXT(trace, 1, "qdinchk");
+			QETH_DBF_TEXT_(trace, 1, "%s", CARD_BUS_ID(card));
+			QETH_DBF_TEXT_(trace, 1, "%04X%04X",
+					first_element, count);
+			QETH_DBF_TEXT_(trace, 1, "%04X%04X", queue, status);
+			qeth_schedule_recovery(card);
+			return;
+		}
+	}
+	for (i = first_element; i < (first_element + count); ++i) {
+		index = i % QDIO_MAX_BUFFERS_PER_Q;
+		buffer = &card->qdio.in_q->bufs[index];
+		if (!((status & QDIO_STATUS_LOOK_FOR_ERROR) &&
+		      qeth_check_qdio_errors(buffer->buffer,
+					     qdio_err, siga_err, "qinerr")))
+			qeth_l3_process_inbound_buffer(card, buffer, index);
+		/* clear buffer and give back to hardware */
+		qeth_put_buffer_pool_entry(card, buffer->pool_entry);
+		qeth_queue_input_buffer(card, index);
+	}
+	if (card->options.performance_stats)
+		card->perf_stats.inbound_time += qeth_get_micros() -
+			card->perf_stats.inbound_start_time;
+}
+
+static int qeth_l3_probe_device(struct ccwgroup_device *gdev)
+{
+	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+
+	qeth_l3_create_device_attributes(&gdev->dev);
+	card->options.layer2 = 0;
+	card->discipline.input_handler = (qdio_handler_t *)
+		qeth_l3_qdio_input_handler;
+	card->discipline.output_handler = (qdio_handler_t *)
+		qeth_qdio_output_handler;
+	card->discipline.recover = qeth_l3_recover;
+	return 0;
+}
+
+static void qeth_l3_remove_device(struct ccwgroup_device *cgdev)
+{
+	struct qeth_card *card = dev_get_drvdata(&cgdev->dev);
+
+	wait_event(card->wait_q, qeth_threads_running(card, 0xffffffff) == 0);
+
+	if (cgdev->state == CCWGROUP_ONLINE) {
+		card->use_hard_stop = 1;
+		qeth_l3_set_offline(cgdev);
+	}
+
+	if (card->dev) {
+		unregister_netdev(card->dev);
+		card->dev = NULL;
+	}
+
+	qeth_l3_remove_device_attributes(&cgdev->dev);
+	qeth_l3_clear_ip_list(card, 0, 0);
+	qeth_l3_clear_ipato_list(card);
+	return;
+}
+
+static int __qeth_l3_set_online(struct ccwgroup_device *gdev, int recovery_mode)
+{
+	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+	int rc = 0;
+	enum qeth_card_states recover_flag;
+
+	BUG_ON(!card);
+	QETH_DBF_TEXT(setup, 2, "setonlin");
+	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+
+	qeth_set_allowed_threads(card, QETH_RECOVER_THREAD, 1);
+	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD)) {
+		PRINT_WARN("set_online of card %s interrupted by user!\n",
+			   CARD_BUS_ID(card));
+		return -ERESTARTSYS;
+	}
+
+	recover_flag = card->state;
+	rc = ccw_device_set_online(CARD_RDEV(card));
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		return -EIO;
+	}
+	rc = ccw_device_set_online(CARD_WDEV(card));
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		return -EIO;
+	}
+	rc = ccw_device_set_online(CARD_DDEV(card));
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		return -EIO;
+	}
+
+	rc = qeth_core_hardsetup_card(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		goto out_remove;
+	}
+
+	qeth_l3_query_ipassists(card, QETH_PROT_IPV4);
+
+	if (!card->dev && qeth_l3_setup_netdev(card))
+		goto out_remove;
+
+	card->state = CARD_STATE_HARDSETUP;
+	qeth_print_status_message(card);
+
+	/* softsetup */
+	QETH_DBF_TEXT(setup, 2, "softsetp");
+
+	rc = qeth_send_startlan(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		if (rc == 0xe080) {
+			PRINT_WARN("LAN on card %s if offline! "
+				   "Waiting for STARTLAN from card.\n",
+				   CARD_BUS_ID(card));
+			card->lan_online = 0;
+		}
+		return rc;
+	} else
+		card->lan_online = 1;
+	qeth_set_large_send(card, card->options.large_send);
+
+	rc = qeth_l3_setadapter_parms(card);
+	if (rc)
+		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+	rc = qeth_l3_start_ipassists(card);
+	if (rc)
+		QETH_DBF_TEXT_(setup, 2, "3err%d", rc);
+	rc = qeth_l3_setrouting_v4(card);
+	if (rc)
+		QETH_DBF_TEXT_(setup, 2, "4err%d", rc);
+	rc = qeth_l3_setrouting_v6(card);
+	if (rc)
+		QETH_DBF_TEXT_(setup, 2, "5err%d", rc);
+	netif_tx_disable(card->dev);
+
+	rc = qeth_init_qdio_queues(card);
+	if (rc) {
+		QETH_DBF_TEXT_(setup, 2, "6err%d", rc);
+		goto out_remove;
+	}
+	card->state = CARD_STATE_SOFTSETUP;
+	netif_carrier_on(card->dev);
+
+	qeth_set_allowed_threads(card, 0xffffffff, 0);
+	if ((recover_flag == CARD_STATE_RECOVER) && recovery_mode) {
+			qeth_l3_open(card->dev);
+			qeth_l3_set_multicast_list(card->dev);
+	}
+	/* let user_space know that device is online */
+	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
+	return 0;
+out_remove:
+	card->use_hard_stop = 1;
+	qeth_l3_stop_card(card, 0);
+	ccw_device_set_offline(CARD_DDEV(card));
+	ccw_device_set_offline(CARD_WDEV(card));
+	ccw_device_set_offline(CARD_RDEV(card));
+	if (recover_flag == CARD_STATE_RECOVER)
+		card->state = CARD_STATE_RECOVER;
+	else
+		card->state = CARD_STATE_DOWN;
+	return -ENODEV;
+}
+
+static int qeth_l3_set_online(struct ccwgroup_device *gdev)
+{
+	return __qeth_l3_set_online(gdev, 0);
+}
+
+static int __qeth_l3_set_offline(struct ccwgroup_device *cgdev,
+			int recovery_mode)
+{
+	struct qeth_card *card = dev_get_drvdata(&cgdev->dev);
+	int rc = 0, rc2 = 0, rc3 = 0;
+	enum qeth_card_states recover_flag;
+
+	QETH_DBF_TEXT(setup, 3, "setoffl");
+	QETH_DBF_HEX(setup, 3, &card, sizeof(void *));
+
+	if (card->dev && netif_carrier_ok(card->dev))
+		netif_carrier_off(card->dev);
+	recover_flag = card->state;
+	if (qeth_l3_stop_card(card, recovery_mode) == -ERESTARTSYS) {
+		PRINT_WARN("Stopping card %s interrupted by user!\n",
+			   CARD_BUS_ID(card));
+		return -ERESTARTSYS;
+	}
+	rc  = ccw_device_set_offline(CARD_DDEV(card));
+	rc2 = ccw_device_set_offline(CARD_WDEV(card));
+	rc3 = ccw_device_set_offline(CARD_RDEV(card));
+	if (!rc)
+		rc = (rc2) ? rc2 : rc3;
+	if (rc)
+		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+	if (recover_flag == CARD_STATE_UP)
+		card->state = CARD_STATE_RECOVER;
+	/* let user_space know that device is offline */
+	kobject_uevent(&cgdev->dev.kobj, KOBJ_CHANGE);
+	return 0;
+}
+
+static int qeth_l3_set_offline(struct ccwgroup_device *cgdev)
+{
+	return __qeth_l3_set_offline(cgdev, 0);
+}
+
+static int qeth_l3_recover(void *ptr)
+{
+	struct qeth_card *card;
+	int rc = 0;
+
+	card = (struct qeth_card *) ptr;
+	QETH_DBF_TEXT(trace, 2, "recover1");
+	QETH_DBF_HEX(trace, 2, &card, sizeof(void *));
+	if (!qeth_do_run_thread(card, QETH_RECOVER_THREAD))
+		return 0;
+	QETH_DBF_TEXT(trace, 2, "recover2");
+	PRINT_WARN("Recovery of device %s started ...\n",
+		   CARD_BUS_ID(card));
+	card->use_hard_stop = 1;
+	__qeth_l3_set_offline(card->gdev, 1);
+	rc = __qeth_l3_set_online(card->gdev, 1);
+	/* don't run another scheduled recovery */
+	qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
+	qeth_clear_thread_running_bit(card, QETH_RECOVER_THREAD);
+	if (!rc)
+		PRINT_INFO("Device %s successfully recovered!\n",
+			   CARD_BUS_ID(card));
+	else
+		PRINT_INFO("Device %s could not be recovered!\n",
+			   CARD_BUS_ID(card));
+	return 0;
+}
+
+static void qeth_l3_shutdown(struct ccwgroup_device *gdev)
+{
+	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+	qeth_l3_clear_ip_list(card, 0, 0);
+	qeth_qdio_clear_card(card, 0);
+	qeth_clear_qdio_buffers(card);
+}
+
+struct ccwgroup_driver qeth_l3_ccwgroup_driver = {
+	.probe = qeth_l3_probe_device,
+	.remove = qeth_l3_remove_device,
+	.set_online = qeth_l3_set_online,
+	.set_offline = qeth_l3_set_offline,
+	.shutdown = qeth_l3_shutdown,
+};
+EXPORT_SYMBOL_GPL(qeth_l3_ccwgroup_driver);
+
+static int qeth_l3_ip_event(struct notifier_block *this,
+				unsigned long event, void *ptr)
+{
+	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
+	struct net_device *dev = (struct net_device *)ifa->ifa_dev->dev;
+	struct qeth_ipaddr *addr;
+	struct qeth_card *card;
+
+	QETH_DBF_TEXT(trace, 3, "ipevent");
+	card = qeth_l3_get_card_from_dev(dev);
+	if (!card)
+		return NOTIFY_DONE;
+
+	addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
+	if (addr != NULL) {
+		addr->u.a4.addr = ifa->ifa_address;
+		addr->u.a4.mask = ifa->ifa_mask;
+		addr->type = QETH_IP_TYPE_NORMAL;
+	} else
+		goto out;
+
+	switch (event) {
+	case NETDEV_UP:
+		if (!qeth_l3_add_ip(card, addr))
+			kfree(addr);
+		break;
+	case NETDEV_DOWN:
+		if (!qeth_l3_delete_ip(card, addr))
+			kfree(addr);
+		break;
+	default:
+		break;
+	}
+	qeth_l3_set_ip_addr_list(card);
+out:
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block qeth_l3_ip_notifier = {
+	qeth_l3_ip_event,
+	NULL,
+};
+
+#ifdef CONFIG_QETH_IPV6
+/**
+ * IPv6 event handler
+ */
+static int qeth_l3_ip6_event(struct notifier_block *this,
+				unsigned long event, void *ptr)
+{
+	struct inet6_ifaddr *ifa = (struct inet6_ifaddr *)ptr;
+	struct net_device *dev = (struct net_device *)ifa->idev->dev;
+	struct qeth_ipaddr *addr;
+	struct qeth_card *card;
+
+	QETH_DBF_TEXT(trace, 3, "ip6event");
+
+	card = qeth_l3_get_card_from_dev(dev);
+	if (!card)
+		return NOTIFY_DONE;
+	if (!qeth_is_supported(card, IPA_IPV6))
+		return NOTIFY_DONE;
+
+	addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
+	if (addr != NULL) {
+		memcpy(&addr->u.a6.addr, &ifa->addr, sizeof(struct in6_addr));
+		addr->u.a6.pfxlen = ifa->prefix_len;
+		addr->type = QETH_IP_TYPE_NORMAL;
+	} else
+		goto out;
+
+	switch (event) {
+	case NETDEV_UP:
+		if (!qeth_l3_add_ip(card, addr))
+			kfree(addr);
+		break;
+	case NETDEV_DOWN:
+		if (!qeth_l3_delete_ip(card, addr))
+			kfree(addr);
+		break;
+	default:
+		break;
+	}
+	qeth_l3_set_ip_addr_list(card);
+out:
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block qeth_l3_ip6_notifier = {
+	qeth_l3_ip6_event,
+	NULL,
+};
+#endif
+
+static int qeth_l3_register_notifiers(void)
+{
+	int rc;
+
+	QETH_DBF_TEXT(trace, 5, "regnotif");
+	rc = register_inetaddr_notifier(&qeth_l3_ip_notifier);
+	if (rc)
+		return rc;
+#ifdef CONFIG_QETH_IPV6
+	rc = register_inet6addr_notifier(&qeth_l3_ip6_notifier);
+	if (rc) {
+		unregister_inetaddr_notifier(&qeth_l3_ip_notifier);
+		return rc;
+	}
+#else
+	PRINT_WARN("layer 3 discipline no IPv6 support\n");
+#endif
+	return 0;
+}
+
+static void qeth_l3_unregister_notifiers(void)
+{
+
+	QETH_DBF_TEXT(trace, 5, "unregnot");
+	BUG_ON(unregister_inetaddr_notifier(&qeth_l3_ip_notifier));
+#ifdef CONFIG_QETH_IPV6
+	BUG_ON(unregister_inet6addr_notifier(&qeth_l3_ip6_notifier));
+#endif /* QETH_IPV6 */
+}
+
+static int __init qeth_l3_init(void)
+{
+	int rc = 0;
+
+	PRINT_INFO("register layer 3 discipline\n");
+	rc = qeth_l3_register_notifiers();
+	return rc;
+}
+
+static void __exit qeth_l3_exit(void)
+{
+	qeth_l3_unregister_notifiers();
+	PRINT_INFO("unregister layer 3 discipline\n");
+}
+
+module_init(qeth_l3_init);
+module_exit(qeth_l3_exit);
+MODULE_AUTHOR("Frank Blaschka <frank.blaschka@de.ibm.com>");
+MODULE_DESCRIPTION("qeth layer 3 discipline");
+MODULE_LICENSE("GPL");
Index: my_git/drivers/s390/net/qeth_l3_sys.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ my_git/drivers/s390/net/qeth_l3_sys.c	2008-02-14 13:23:52.000000000 +0100
@@ -0,0 +1,1051 @@
+/*
+ *  drivers/s390/net/qeth_l3_sys.c
+ *
+ *    Copyright IBM Corp. 2007
+ *    Author(s): Utz Bacher <utz.bacher@de.ibm.com>,
+ *		 Frank Pavlic <fpavlic@de.ibm.com>,
+ *		 Thomas Spatzier <tspat@de.ibm.com>,
+ *		 Frank Blaschka <frank.blaschka@de.ibm.com>
+ */
+
+#include "qeth_l3.h"
+
+#define QETH_DEVICE_ATTR(_id, _name, _mode, _show, _store) \
+struct device_attribute dev_attr_##_id = __ATTR(_name, _mode, _show, _store)
+
+static const char *qeth_l3_get_checksum_str(struct qeth_card *card)
+{
+	if (card->options.checksum_type == SW_CHECKSUMMING)
+		return "sw";
+	else if (card->options.checksum_type == HW_CHECKSUMMING)
+		return "hw";
+	else
+		return "no";
+}
+
+static ssize_t qeth_l3_dev_route_show(struct qeth_card *card,
+			struct qeth_routing_info *route, char *buf)
+{
+	switch (route->type) {
+	case PRIMARY_ROUTER:
+		return sprintf(buf, "%s\n", "primary router");
+	case SECONDARY_ROUTER:
+		return sprintf(buf, "%s\n", "secondary router");
+	case MULTICAST_ROUTER:
+		if (card->info.broadcast_capable == QETH_BROADCAST_WITHOUT_ECHO)
+			return sprintf(buf, "%s\n", "multicast router+");
+		else
+			return sprintf(buf, "%s\n", "multicast router");
+	case PRIMARY_CONNECTOR:
+		if (card->info.broadcast_capable == QETH_BROADCAST_WITHOUT_ECHO)
+			return sprintf(buf, "%s\n", "primary connector+");
+		else
+			return sprintf(buf, "%s\n", "primary connector");
+	case SECONDARY_CONNECTOR:
+		if (card->info.broadcast_capable == QETH_BROADCAST_WITHOUT_ECHO)
+			return sprintf(buf, "%s\n", "secondary connector+");
+		else
+			return sprintf(buf, "%s\n", "secondary connector");
+	default:
+		return sprintf(buf, "%s\n", "no");
+	}
+}
+
+static ssize_t qeth_l3_dev_route4_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_route_show(card, &card->options.route4, buf);
+}
+
+static ssize_t qeth_l3_dev_route_store(struct qeth_card *card,
+		struct qeth_routing_info *route, enum qeth_prot_versions prot,
+		const char *buf, size_t count)
+{
+	enum qeth_routing_types old_route_type = route->type;
+	char *tmp;
+	int rc;
+
+	tmp = strsep((char **) &buf, "\n");
+
+	if (!strcmp(tmp, "no_router")) {
+		route->type = NO_ROUTER;
+	} else if (!strcmp(tmp, "primary_connector")) {
+		route->type = PRIMARY_CONNECTOR;
+	} else if (!strcmp(tmp, "secondary_connector")) {
+		route->type = SECONDARY_CONNECTOR;
+	} else if (!strcmp(tmp, "primary_router")) {
+		route->type = PRIMARY_ROUTER;
+	} else if (!strcmp(tmp, "secondary_router")) {
+		route->type = SECONDARY_ROUTER;
+	} else if (!strcmp(tmp, "multicast_router")) {
+		route->type = MULTICAST_ROUTER;
+	} else {
+		PRINT_WARN("Invalid routing type '%s'.\n", tmp);
+		return -EINVAL;
+	}
+	if (((card->state == CARD_STATE_SOFTSETUP) ||
+	     (card->state == CARD_STATE_UP)) &&
+	    (old_route_type != route->type)) {
+		if (prot == QETH_PROT_IPV4)
+			rc = qeth_l3_setrouting_v4(card);
+		else if (prot == QETH_PROT_IPV6)
+			rc = qeth_l3_setrouting_v6(card);
+	}
+	return count;
+}
+
+static ssize_t qeth_l3_dev_route4_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_route_store(card, &card->options.route4,
+				QETH_PROT_IPV4, buf, count);
+}
+
+static DEVICE_ATTR(route4, 0644, qeth_l3_dev_route4_show,
+			qeth_l3_dev_route4_store);
+
+static ssize_t qeth_l3_dev_route6_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	if (!qeth_is_supported(card, IPA_IPV6))
+		return sprintf(buf, "%s\n", "n/a");
+
+	return qeth_l3_dev_route_show(card, &card->options.route6, buf);
+}
+
+static ssize_t qeth_l3_dev_route6_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	if (!qeth_is_supported(card, IPA_IPV6)) {
+		PRINT_WARN("IPv6 not supported for interface %s.\n"
+			   "Routing status no changed.\n",
+			   QETH_CARD_IFNAME(card));
+		return -ENOTSUPP;
+	}
+
+	return qeth_l3_dev_route_store(card, &card->options.route6,
+				QETH_PROT_IPV6, buf, count);
+}
+
+static DEVICE_ATTR(route6, 0644, qeth_l3_dev_route6_show,
+			qeth_l3_dev_route6_store);
+
+static ssize_t qeth_l3_dev_fake_broadcast_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%i\n", card->options.fake_broadcast? 1:0);
+}
+
+static ssize_t qeth_l3_dev_fake_broadcast_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+	int i;
+
+	if (!card)
+		return -EINVAL;
+
+	if ((card->state != CARD_STATE_DOWN) &&
+	    (card->state != CARD_STATE_RECOVER))
+		return -EPERM;
+
+	i = simple_strtoul(buf, &tmp, 16);
+	if ((i == 0) || (i == 1))
+		card->options.fake_broadcast = i;
+	else {
+		PRINT_WARN("fake_broadcast: write 0 or 1 to this file!\n");
+		return -EINVAL;
+	}
+	return count;
+}
+
+static DEVICE_ATTR(fake_broadcast, 0644, qeth_l3_dev_fake_broadcast_show,
+		   qeth_l3_dev_fake_broadcast_store);
+
+static ssize_t qeth_l3_dev_broadcast_mode_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
+	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR)))
+		return sprintf(buf, "n/a\n");
+
+	return sprintf(buf, "%s\n", (card->options.broadcast_mode ==
+				     QETH_TR_BROADCAST_ALLRINGS)?
+		       "all rings":"local");
+}
+
+static ssize_t qeth_l3_dev_broadcast_mode_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+
+	if (!card)
+		return -EINVAL;
+
+	if ((card->state != CARD_STATE_DOWN) &&
+	    (card->state != CARD_STATE_RECOVER))
+		return -EPERM;
+
+	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
+	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR))) {
+		PRINT_WARN("Device is not a tokenring device!\n");
+		return -EINVAL;
+	}
+
+	tmp = strsep((char **) &buf, "\n");
+
+	if (!strcmp(tmp, "local")) {
+		card->options.broadcast_mode = QETH_TR_BROADCAST_LOCAL;
+		return count;
+	} else if (!strcmp(tmp, "all_rings")) {
+		card->options.broadcast_mode = QETH_TR_BROADCAST_ALLRINGS;
+		return count;
+	} else {
+		PRINT_WARN("broadcast_mode: invalid mode %s!\n",
+			   tmp);
+		return -EINVAL;
+	}
+	return count;
+}
+
+static DEVICE_ATTR(broadcast_mode, 0644, qeth_l3_dev_broadcast_mode_show,
+		   qeth_l3_dev_broadcast_mode_store);
+
+static ssize_t qeth_l3_dev_canonical_macaddr_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
+	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR)))
+		return sprintf(buf, "n/a\n");
+
+	return sprintf(buf, "%i\n", (card->options.macaddr_mode ==
+				     QETH_TR_MACADDR_CANONICAL)? 1:0);
+}
+
+static ssize_t qeth_l3_dev_canonical_macaddr_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+	int i;
+
+	if (!card)
+		return -EINVAL;
+
+	if ((card->state != CARD_STATE_DOWN) &&
+	    (card->state != CARD_STATE_RECOVER))
+		return -EPERM;
+
+	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
+	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR))) {
+		PRINT_WARN("Device is not a tokenring device!\n");
+		return -EINVAL;
+	}
+
+	i = simple_strtoul(buf, &tmp, 16);
+	if ((i == 0) || (i == 1))
+		card->options.macaddr_mode = i?
+			QETH_TR_MACADDR_CANONICAL :
+			QETH_TR_MACADDR_NONCANONICAL;
+	else {
+		PRINT_WARN("canonical_macaddr: write 0 or 1 to this file!\n");
+		return -EINVAL;
+	}
+	return count;
+}
+
+static DEVICE_ATTR(canonical_macaddr, 0644, qeth_l3_dev_canonical_macaddr_show,
+		   qeth_l3_dev_canonical_macaddr_store);
+
+static ssize_t qeth_l3_dev_checksum_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%s checksumming\n",
+			qeth_l3_get_checksum_str(card));
+}
+
+static ssize_t qeth_l3_dev_checksum_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+
+	if (!card)
+		return -EINVAL;
+
+	if ((card->state != CARD_STATE_DOWN) &&
+	    (card->state != CARD_STATE_RECOVER))
+		return -EPERM;
+
+	tmp = strsep((char **) &buf, "\n");
+	if (!strcmp(tmp, "sw_checksumming"))
+		card->options.checksum_type = SW_CHECKSUMMING;
+	else if (!strcmp(tmp, "hw_checksumming"))
+		card->options.checksum_type = HW_CHECKSUMMING;
+	else if (!strcmp(tmp, "no_checksumming"))
+		card->options.checksum_type = NO_CHECKSUMMING;
+	else {
+		PRINT_WARN("Unknown checksumming type '%s'\n", tmp);
+		return -EINVAL;
+	}
+	return count;
+}
+
+static DEVICE_ATTR(checksumming, 0644, qeth_l3_dev_checksum_show,
+		qeth_l3_dev_checksum_store);
+
+static struct attribute *qeth_l3_device_attrs[] = {
+	&dev_attr_route4.attr,
+	&dev_attr_route6.attr,
+	&dev_attr_fake_broadcast.attr,
+	&dev_attr_broadcast_mode.attr,
+	&dev_attr_canonical_macaddr.attr,
+	&dev_attr_checksumming.attr,
+	NULL,
+};
+
+static struct attribute_group qeth_l3_device_attr_group = {
+	.attrs = qeth_l3_device_attrs,
+};
+
+static ssize_t qeth_l3_dev_ipato_enable_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%i\n", card->ipato.enabled? 1:0);
+}
+
+static ssize_t qeth_l3_dev_ipato_enable_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+
+	if (!card)
+		return -EINVAL;
+
+	if ((card->state != CARD_STATE_DOWN) &&
+	    (card->state != CARD_STATE_RECOVER))
+		return -EPERM;
+
+	tmp = strsep((char **) &buf, "\n");
+	if (!strcmp(tmp, "toggle")) {
+		card->ipato.enabled = (card->ipato.enabled)? 0 : 1;
+	} else if (!strcmp(tmp, "1")) {
+		card->ipato.enabled = 1;
+	} else if (!strcmp(tmp, "0")) {
+		card->ipato.enabled = 0;
+	} else {
+		PRINT_WARN("ipato_enable: write 0, 1 or 'toggle' to "
+			   "this file\n");
+		return -EINVAL;
+	}
+	return count;
+}
+
+static QETH_DEVICE_ATTR(ipato_enable, enable, 0644,
+			qeth_l3_dev_ipato_enable_show,
+			qeth_l3_dev_ipato_enable_store);
+
+static ssize_t qeth_l3_dev_ipato_invert4_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%i\n", card->ipato.invert4? 1:0);
+}
+
+static ssize_t qeth_l3_dev_ipato_invert4_store(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+
+	if (!card)
+		return -EINVAL;
+
+	tmp = strsep((char **) &buf, "\n");
+	if (!strcmp(tmp, "toggle")) {
+		card->ipato.invert4 = (card->ipato.invert4)? 0 : 1;
+	} else if (!strcmp(tmp, "1")) {
+		card->ipato.invert4 = 1;
+	} else if (!strcmp(tmp, "0")) {
+		card->ipato.invert4 = 0;
+	} else {
+		PRINT_WARN("ipato_invert4: write 0, 1 or 'toggle' to "
+			   "this file\n");
+		return -EINVAL;
+	}
+	return count;
+}
+
+static QETH_DEVICE_ATTR(ipato_invert4, invert4, 0644,
+			qeth_l3_dev_ipato_invert4_show,
+			qeth_l3_dev_ipato_invert4_store);
+
+static ssize_t qeth_l3_dev_ipato_add_show(char *buf, struct qeth_card *card,
+			enum qeth_prot_versions proto)
+{
+	struct qeth_ipato_entry *ipatoe;
+	unsigned long flags;
+	char addr_str[40];
+	int entry_len; /* length of 1 entry string, differs between v4 and v6 */
+	int i = 0;
+
+	entry_len = (proto == QETH_PROT_IPV4)? 12 : 40;
+	/* add strlen for "/<mask>\n" */
+	entry_len += (proto == QETH_PROT_IPV4)? 5 : 6;
+	spin_lock_irqsave(&card->ip_lock, flags);
+	list_for_each_entry(ipatoe, &card->ipato.entries, entry) {
+		if (ipatoe->proto != proto)
+			continue;
+		/* String must not be longer than PAGE_SIZE. So we check if
+		 * string length gets near PAGE_SIZE. Then we can savely display
+		 * the next IPv6 address (worst case, compared to IPv4) */
+		if ((PAGE_SIZE - i) <= entry_len)
+			break;
+		qeth_l3_ipaddr_to_string(proto, ipatoe->addr, addr_str);
+		i += snprintf(buf + i, PAGE_SIZE - i,
+			      "%s/%i\n", addr_str, ipatoe->mask_bits);
+	}
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+	i += snprintf(buf + i, PAGE_SIZE - i, "\n");
+
+	return i;
+}
+
+static ssize_t qeth_l3_dev_ipato_add4_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_ipato_add_show(buf, card, QETH_PROT_IPV4);
+}
+
+static int qeth_l3_parse_ipatoe(const char *buf, enum qeth_prot_versions proto,
+		  u8 *addr, int *mask_bits)
+{
+	const char *start, *end;
+	char *tmp;
+	char buffer[40] = {0, };
+
+	start = buf;
+	/* get address string */
+	end = strchr(start, '/');
+	if (!end || (end - start >= 40)) {
+		PRINT_WARN("Invalid format for ipato_addx/delx. "
+			   "Use <ip addr>/<mask bits>\n");
+		return -EINVAL;
+	}
+	strncpy(buffer, start, end - start);
+	if (qeth_l3_string_to_ipaddr(buffer, proto, addr)) {
+		PRINT_WARN("Invalid IP address format!\n");
+		return -EINVAL;
+	}
+	start = end + 1;
+	*mask_bits = simple_strtoul(start, &tmp, 10);
+	if (!strlen(start) ||
+	    (tmp == start) ||
+	    (*mask_bits > ((proto == QETH_PROT_IPV4) ? 32 : 128))) {
+		PRINT_WARN("Invalid mask bits for ipato_addx/delx !\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static ssize_t qeth_l3_dev_ipato_add_store(const char *buf, size_t count,
+			 struct qeth_card *card, enum qeth_prot_versions proto)
+{
+	struct qeth_ipato_entry *ipatoe;
+	u8 addr[16];
+	int mask_bits;
+	int rc;
+
+	rc = qeth_l3_parse_ipatoe(buf, proto, addr, &mask_bits);
+	if (rc)
+		return rc;
+
+	ipatoe = kzalloc(sizeof(struct qeth_ipato_entry), GFP_KERNEL);
+	if (!ipatoe) {
+		PRINT_WARN("No memory to allocate ipato entry\n");
+		return -ENOMEM;
+	}
+	ipatoe->proto = proto;
+	memcpy(ipatoe->addr, addr, (proto == QETH_PROT_IPV4)? 4:16);
+	ipatoe->mask_bits = mask_bits;
+
+	rc = qeth_l3_add_ipato_entry(card, ipatoe);
+	if (rc) {
+		kfree(ipatoe);
+		return rc;
+	}
+
+	return count;
+}
+
+static ssize_t qeth_l3_dev_ipato_add4_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_ipato_add_store(buf, count, card, QETH_PROT_IPV4);
+}
+
+static QETH_DEVICE_ATTR(ipato_add4, add4, 0644,
+			qeth_l3_dev_ipato_add4_show,
+			qeth_l3_dev_ipato_add4_store);
+
+static ssize_t qeth_l3_dev_ipato_del_store(const char *buf, size_t count,
+			 struct qeth_card *card, enum qeth_prot_versions proto)
+{
+	u8 addr[16];
+	int mask_bits;
+	int rc;
+
+	rc = qeth_l3_parse_ipatoe(buf, proto, addr, &mask_bits);
+	if (rc)
+		return rc;
+
+	qeth_l3_del_ipato_entry(card, proto, addr, mask_bits);
+
+	return count;
+}
+
+static ssize_t qeth_l3_dev_ipato_del4_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_ipato_del_store(buf, count, card, QETH_PROT_IPV4);
+}
+
+static QETH_DEVICE_ATTR(ipato_del4, del4, 0200, NULL,
+			qeth_l3_dev_ipato_del4_store);
+
+static ssize_t qeth_l3_dev_ipato_invert6_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return sprintf(buf, "%i\n", card->ipato.invert6? 1:0);
+}
+
+static ssize_t qeth_l3_dev_ipato_invert6_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	char *tmp;
+
+	if (!card)
+		return -EINVAL;
+
+	tmp = strsep((char **) &buf, "\n");
+	if (!strcmp(tmp, "toggle")) {
+		card->ipato.invert6 = (card->ipato.invert6)? 0 : 1;
+	} else if (!strcmp(tmp, "1")) {
+		card->ipato.invert6 = 1;
+	} else if (!strcmp(tmp, "0")) {
+		card->ipato.invert6 = 0;
+	} else {
+		PRINT_WARN("ipato_invert6: write 0, 1 or 'toggle' to "
+			   "this file\n");
+		return -EINVAL;
+	}
+	return count;
+}
+
+static QETH_DEVICE_ATTR(ipato_invert6, invert6, 0644,
+			qeth_l3_dev_ipato_invert6_show,
+			qeth_l3_dev_ipato_invert6_store);
+
+
+static ssize_t qeth_l3_dev_ipato_add6_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_ipato_add_show(buf, card, QETH_PROT_IPV6);
+}
+
+static ssize_t qeth_l3_dev_ipato_add6_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_ipato_add_store(buf, count, card, QETH_PROT_IPV6);
+}
+
+static QETH_DEVICE_ATTR(ipato_add6, add6, 0644,
+			qeth_l3_dev_ipato_add6_show,
+			qeth_l3_dev_ipato_add6_store);
+
+static ssize_t qeth_l3_dev_ipato_del6_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_ipato_del_store(buf, count, card, QETH_PROT_IPV6);
+}
+
+static QETH_DEVICE_ATTR(ipato_del6, del6, 0200, NULL,
+			qeth_l3_dev_ipato_del6_store);
+
+static struct attribute *qeth_ipato_device_attrs[] = {
+	&dev_attr_ipato_enable.attr,
+	&dev_attr_ipato_invert4.attr,
+	&dev_attr_ipato_add4.attr,
+	&dev_attr_ipato_del4.attr,
+	&dev_attr_ipato_invert6.attr,
+	&dev_attr_ipato_add6.attr,
+	&dev_attr_ipato_del6.attr,
+	NULL,
+};
+
+static struct attribute_group qeth_device_ipato_group = {
+	.name = "ipa_takeover",
+	.attrs = qeth_ipato_device_attrs,
+};
+
+static ssize_t qeth_l3_dev_vipa_add_show(char *buf, struct qeth_card *card,
+			enum qeth_prot_versions proto)
+{
+	struct qeth_ipaddr *ipaddr;
+	char addr_str[40];
+	int entry_len; /* length of 1 entry string, differs between v4 and v6 */
+	unsigned long flags;
+	int i = 0;
+
+	entry_len = (proto == QETH_PROT_IPV4)? 12 : 40;
+	entry_len += 2; /* \n + terminator */
+	spin_lock_irqsave(&card->ip_lock, flags);
+	list_for_each_entry(ipaddr, &card->ip_list, entry) {
+		if (ipaddr->proto != proto)
+			continue;
+		if (ipaddr->type != QETH_IP_TYPE_VIPA)
+			continue;
+		/* String must not be longer than PAGE_SIZE. So we check if
+		 * string length gets near PAGE_SIZE. Then we can savely display
+		 * the next IPv6 address (worst case, compared to IPv4) */
+		if ((PAGE_SIZE - i) <= entry_len)
+			break;
+		qeth_l3_ipaddr_to_string(proto, (const u8 *)&ipaddr->u,
+			addr_str);
+		i += snprintf(buf + i, PAGE_SIZE - i, "%s\n", addr_str);
+	}
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+	i += snprintf(buf + i, PAGE_SIZE - i, "\n");
+
+	return i;
+}
+
+static ssize_t qeth_l3_dev_vipa_add4_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_vipa_add_show(buf, card, QETH_PROT_IPV4);
+}
+
+static int qeth_l3_parse_vipae(const char *buf, enum qeth_prot_versions proto,
+		 u8 *addr)
+{
+	if (qeth_l3_string_to_ipaddr(buf, proto, addr)) {
+		PRINT_WARN("Invalid IP address format!\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static ssize_t qeth_l3_dev_vipa_add_store(const char *buf, size_t count,
+			struct qeth_card *card, enum qeth_prot_versions proto)
+{
+	u8 addr[16] = {0, };
+	int rc;
+
+	rc = qeth_l3_parse_vipae(buf, proto, addr);
+	if (rc)
+		return rc;
+
+	rc = qeth_l3_add_vipa(card, proto, addr);
+	if (rc)
+		return rc;
+
+	return count;
+}
+
+static ssize_t qeth_l3_dev_vipa_add4_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_vipa_add_store(buf, count, card, QETH_PROT_IPV4);
+}
+
+static QETH_DEVICE_ATTR(vipa_add4, add4, 0644,
+			qeth_l3_dev_vipa_add4_show,
+			qeth_l3_dev_vipa_add4_store);
+
+static ssize_t qeth_l3_dev_vipa_del_store(const char *buf, size_t count,
+			 struct qeth_card *card, enum qeth_prot_versions proto)
+{
+	u8 addr[16];
+	int rc;
+
+	rc = qeth_l3_parse_vipae(buf, proto, addr);
+	if (rc)
+		return rc;
+
+	qeth_l3_del_vipa(card, proto, addr);
+
+	return count;
+}
+
+static ssize_t qeth_l3_dev_vipa_del4_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_vipa_del_store(buf, count, card, QETH_PROT_IPV4);
+}
+
+static QETH_DEVICE_ATTR(vipa_del4, del4, 0200, NULL,
+			qeth_l3_dev_vipa_del4_store);
+
+static ssize_t qeth_l3_dev_vipa_add6_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_vipa_add_show(buf, card, QETH_PROT_IPV6);
+}
+
+static ssize_t qeth_l3_dev_vipa_add6_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_vipa_add_store(buf, count, card, QETH_PROT_IPV6);
+}
+
+static QETH_DEVICE_ATTR(vipa_add6, add6, 0644,
+			qeth_l3_dev_vipa_add6_show,
+			qeth_l3_dev_vipa_add6_store);
+
+static ssize_t qeth_l3_dev_vipa_del6_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_vipa_del_store(buf, count, card, QETH_PROT_IPV6);
+}
+
+static QETH_DEVICE_ATTR(vipa_del6, del6, 0200, NULL,
+			qeth_l3_dev_vipa_del6_store);
+
+static struct attribute *qeth_vipa_device_attrs[] = {
+	&dev_attr_vipa_add4.attr,
+	&dev_attr_vipa_del4.attr,
+	&dev_attr_vipa_add6.attr,
+	&dev_attr_vipa_del6.attr,
+	NULL,
+};
+
+static struct attribute_group qeth_device_vipa_group = {
+	.name = "vipa",
+	.attrs = qeth_vipa_device_attrs,
+};
+
+static ssize_t qeth_l3_dev_rxip_add_show(char *buf, struct qeth_card *card,
+		       enum qeth_prot_versions proto)
+{
+	struct qeth_ipaddr *ipaddr;
+	char addr_str[40];
+	int entry_len; /* length of 1 entry string, differs between v4 and v6 */
+	unsigned long flags;
+	int i = 0;
+
+	entry_len = (proto == QETH_PROT_IPV4)? 12 : 40;
+	entry_len += 2; /* \n + terminator */
+	spin_lock_irqsave(&card->ip_lock, flags);
+	list_for_each_entry(ipaddr, &card->ip_list, entry) {
+		if (ipaddr->proto != proto)
+			continue;
+		if (ipaddr->type != QETH_IP_TYPE_RXIP)
+			continue;
+		/* String must not be longer than PAGE_SIZE. So we check if
+		 * string length gets near PAGE_SIZE. Then we can savely display
+		 * the next IPv6 address (worst case, compared to IPv4) */
+		if ((PAGE_SIZE - i) <= entry_len)
+			break;
+		qeth_l3_ipaddr_to_string(proto, (const u8 *)&ipaddr->u,
+			addr_str);
+		i += snprintf(buf + i, PAGE_SIZE - i, "%s\n", addr_str);
+	}
+	spin_unlock_irqrestore(&card->ip_lock, flags);
+	i += snprintf(buf + i, PAGE_SIZE - i, "\n");
+
+	return i;
+}
+
+static ssize_t qeth_l3_dev_rxip_add4_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_rxip_add_show(buf, card, QETH_PROT_IPV4);
+}
+
+static int qeth_l3_parse_rxipe(const char *buf, enum qeth_prot_versions proto,
+		 u8 *addr)
+{
+	if (qeth_l3_string_to_ipaddr(buf, proto, addr)) {
+		PRINT_WARN("Invalid IP address format!\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static ssize_t qeth_l3_dev_rxip_add_store(const char *buf, size_t count,
+			struct qeth_card *card, enum qeth_prot_versions proto)
+{
+	u8 addr[16] = {0, };
+	int rc;
+
+	rc = qeth_l3_parse_rxipe(buf, proto, addr);
+	if (rc)
+		return rc;
+
+	rc = qeth_l3_add_rxip(card, proto, addr);
+	if (rc)
+		return rc;
+
+	return count;
+}
+
+static ssize_t qeth_l3_dev_rxip_add4_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_rxip_add_store(buf, count, card, QETH_PROT_IPV4);
+}
+
+static QETH_DEVICE_ATTR(rxip_add4, add4, 0644,
+			qeth_l3_dev_rxip_add4_show,
+			qeth_l3_dev_rxip_add4_store);
+
+static ssize_t qeth_l3_dev_rxip_del_store(const char *buf, size_t count,
+			struct qeth_card *card, enum qeth_prot_versions proto)
+{
+	u8 addr[16];
+	int rc;
+
+	rc = qeth_l3_parse_rxipe(buf, proto, addr);
+	if (rc)
+		return rc;
+
+	qeth_l3_del_rxip(card, proto, addr);
+
+	return count;
+}
+
+static ssize_t qeth_l3_dev_rxip_del4_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_rxip_del_store(buf, count, card, QETH_PROT_IPV4);
+}
+
+static QETH_DEVICE_ATTR(rxip_del4, del4, 0200, NULL,
+			qeth_l3_dev_rxip_del4_store);
+
+static ssize_t qeth_l3_dev_rxip_add6_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_rxip_add_show(buf, card, QETH_PROT_IPV6);
+}
+
+static ssize_t qeth_l3_dev_rxip_add6_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_rxip_add_store(buf, count, card, QETH_PROT_IPV6);
+}
+
+static QETH_DEVICE_ATTR(rxip_add6, add6, 0644,
+			qeth_l3_dev_rxip_add6_show,
+			qeth_l3_dev_rxip_add6_store);
+
+static ssize_t qeth_l3_dev_rxip_del6_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+
+	return qeth_l3_dev_rxip_del_store(buf, count, card, QETH_PROT_IPV6);
+}
+
+static QETH_DEVICE_ATTR(rxip_del6, del6, 0200, NULL,
+			qeth_l3_dev_rxip_del6_store);
+
+static struct attribute *qeth_rxip_device_attrs[] = {
+	&dev_attr_rxip_add4.attr,
+	&dev_attr_rxip_del4.attr,
+	&dev_attr_rxip_add6.attr,
+	&dev_attr_rxip_del6.attr,
+	NULL,
+};
+
+static struct attribute_group qeth_device_rxip_group = {
+	.name = "rxip",
+	.attrs = qeth_rxip_device_attrs,
+};
+
+int qeth_l3_create_device_attributes(struct device *dev)
+{
+	int ret;
+
+	ret = sysfs_create_group(&dev->kobj, &qeth_l3_device_attr_group);
+	if (ret)
+		return ret;
+
+	ret = sysfs_create_group(&dev->kobj, &qeth_device_ipato_group);
+	if (ret) {
+		sysfs_remove_group(&dev->kobj, &qeth_l3_device_attr_group);
+		return ret;
+	}
+
+	ret = sysfs_create_group(&dev->kobj, &qeth_device_vipa_group);
+	if (ret) {
+		sysfs_remove_group(&dev->kobj, &qeth_l3_device_attr_group);
+		sysfs_remove_group(&dev->kobj, &qeth_device_ipato_group);
+		return ret;
+	}
+
+	ret = sysfs_create_group(&dev->kobj, &qeth_device_rxip_group);
+	if (ret) {
+		sysfs_remove_group(&dev->kobj, &qeth_l3_device_attr_group);
+		sysfs_remove_group(&dev->kobj, &qeth_device_ipato_group);
+		sysfs_remove_group(&dev->kobj, &qeth_device_vipa_group);
+		return ret;
+	}
+	return 0;
+}
+
+void qeth_l3_remove_device_attributes(struct device *dev)
+{
+	sysfs_remove_group(&dev->kobj, &qeth_l3_device_attr_group);
+	sysfs_remove_group(&dev->kobj, &qeth_device_ipato_group);
+	sysfs_remove_group(&dev->kobj, &qeth_device_vipa_group);
+	sysfs_remove_group(&dev->kobj, &qeth_device_rxip_group);
+}

-- 
