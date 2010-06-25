From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 5/9] cxgb4vf: Add core T4 PCI-E SR-IOV Virtual Function hardware definitions and device communication code
Date: Fri, 25 Jun 2010 15:12:54 -0700
Message-ID: <201006251512.54462.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27979 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175Ab0FYWMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 18:12:55 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5PMCtA6019411
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 15:12:55 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add core T4 PCI-E SR-IOV Virtual Function hardware definitions and device
communication code.

Signed-off-by: Casey Leedom
---
 drivers/net/cxgb4vf/t4vf_common.h |  273 ++++++++
 drivers/net/cxgb4vf/t4vf_defs.h   |  121 ++++
 drivers/net/cxgb4vf/t4vf_hw.c     | 1333 +++++++++++++++++++++++++++++++++++++
 3 files changed, 1727 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4vf/t4vf_common.h 
b/drivers/net/cxgb4vf/t4vf_common.h
new file mode 100644
index 0000000..5c7bde7
--- /dev/null
+++ b/drivers/net/cxgb4vf/t4vf_common.h
@@ -0,0 +1,273 @@
+/*
+ * This file is part of the Chelsio T4 PCI-E SR-IOV Virtual Function Ethernet
+ * driver for Linux.
+ *
+ * Copyright (c) 2009-2010 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __T4VF_COMMON_H__
+#define __T4VF_COMMON_H__
+
+#include "../cxgb4/t4fw_api.h"
+
+/*
+ * The "len16" field of a Firmware Command Structure ...
+ */
+#define FW_LEN16(fw_struct) FW_CMD_LEN16(sizeof(fw_struct) / 16)
+
+/*
+ * Per-VF statistics.
+ */
+struct t4vf_port_stats {
+	/*
+	 * TX statistics.
+	 */
+	u64 tx_bcast_bytes;		/* broadcast */
+	u64 tx_bcast_frames;
+	u64 tx_mcast_bytes;		/* multicast */
+	u64 tx_mcast_frames;
+	u64 tx_ucast_bytes;		/* unicast */
+	u64 tx_ucast_frames;
+	u64 tx_drop_frames;		/* TX dropped frames */
+	u64 tx_offload_bytes;		/* offload */
+	u64 tx_offload_frames;
+
+	/*
+	 * RX statistics.
+	 */
+	u64 rx_bcast_bytes;		/* broadcast */
+	u64 rx_bcast_frames;
+	u64 rx_mcast_bytes;		/* multicast */
+	u64 rx_mcast_frames;
+	u64 rx_ucast_bytes;
+	u64 rx_ucast_frames;		/* unicast */
+
+	u64 rx_err_frames;		/* RX error frames */
+};
+
+/*
+ * Per-"port" (Virtual Interface) link configuration ...
+ */
+struct link_config {
+	unsigned int   supported;        /* link capabilities */
+	unsigned int   advertising;      /* advertised capabilities */
+	unsigned short requested_speed;  /* speed user has requested */
+	unsigned short speed;            /* actual link speed */
+	unsigned char  requested_fc;     /* flow control user has requested */
+	unsigned char  fc;               /* actual link flow control */
+	unsigned char  autoneg;          /* autonegotiating? */
+	unsigned char  link_ok;          /* link up? */
+};
+
+enum {
+	PAUSE_RX      = 1 << 0,
+	PAUSE_TX      = 1 << 1,
+	PAUSE_AUTONEG = 1 << 2
+};
+
+/*
+ * General device parameters ...
+ */
+struct dev_params {
+	u32 fwrev;			/* firmware version */
+	u32 tprev;			/* TP Microcode Version */
+};
+
+/*
+ * Scatter Gather Engine parameters.  These are almost all determined by the
+ * Physical Function Driver.  We just need to grab them to see within which
+ * environment we're playing ...
+ */
+struct sge_params {
+	u32 sge_control;		/* padding, boundaries, lengths, etc. */
+	u32 sge_host_page_size;		/* RDMA page sizes */
+	u32 sge_queues_per_page;	/* RDMA queues/page */
+	u32 sge_user_mode_limits;	/* limits for BAR2 user mode accesses */
+	u32 sge_fl_buffer_size[16];	/* free list buffer sizes */
+	u32 sge_ingress_rx_threshold;	/* RX counter interrupt threshold[4] */
+	u32 sge_timer_value_0_and_1;	/* interrupt coalescing timer values */
+	u32 sge_timer_value_2_and_3;
+	u32 sge_timer_value_4_and_5;
+};
+
+/*
+ * Vital Product Data parameters.
+ */
+struct vpd_params {
+	u32 cclk;			/* Core Clock (KHz) */
+};
+
+/*
+ * Global Receive Side Scaling (RSS) parameters in host-native format.
+ */
+struct rss_params {
+	unsigned int mode;		/* RSS mode */
+	union {
+	    struct {
+		int synmapen:1;		/* SYN Map Enable */
+		int syn4tupenipv6:1;	/* enable hashing 4-tuple IPv6 SYNs */
+		int syn2tupenipv6:1;	/* enable hashing 2-tuple IPv6 SYNs */
+		int syn4tupenipv4:1;	/* enable hashing 4-tuple IPv4 SYNs */
+		int syn2tupenipv4:1;	/* enable hashing 2-tuple IPv4 SYNs */
+		int ofdmapen:1;		/* Offload Map Enable */
+		int tnlmapen:1;		/* Tunnel Map Enable */
+		int tnlalllookup:1;	/* Tunnel All Lookup */
+		int hashtoeplitz:1;	/* use Toeplitz hash */
+	    } basicvirtual;
+	} u;
+};
+
+/*
+ * Virtual Interface RSS Configuration in host-native format.
+ */
+union rss_vi_config {
+    struct {
+	u16 defaultq;			/* Ingress Queue ID for !tnlalllookup */
+	int ip6fourtupen:1;		/* hash 4-tuple IPv6 ingress packets */
+	int ip6twotupen:1;		/* hash 2-tuple IPv6 ingress packets */
+	int ip4fourtupen:1;		/* hash 4-tuple IPv4 ingress packets */
+	int ip4twotupen:1;		/* hash 2-tuple IPv4 ingress packets */
+	int udpen;			/* hash 4-tuple UDP ingress packets */
+    } basicvirtual;
+};
+
+/*
+ * Maximum resources provisioned for a PCI VF.
+ */
+struct vf_resources {
+	unsigned int nvi;		/* N virtual interfaces */
+	unsigned int neq;		/* N egress Qs */
+	unsigned int nethctrl;		/* N egress ETH or CTRL Qs */
+	unsigned int niqflint;		/* N ingress Qs/w free list(s) & intr */
+	unsigned int niq;		/* N ingress Qs */
+	unsigned int tc;		/* PCI-E traffic class */
+	unsigned int pmask;		/* port access rights mask */
+	unsigned int nexactf;		/* N exact MPS filters */
+	unsigned int r_caps;		/* read capabilities */
+	unsigned int wx_caps;		/* write/execute capabilities */
+};
+
+/*
+ * Per-"adapter" (Virtual Function) parameters.
+ */
+struct adapter_params {
+	struct dev_params dev;		/* general device parameters */
+	struct sge_params sge;		/* Scatter Gather Engine */
+	struct vpd_params vpd;		/* Vital Product Data */
+	struct rss_params rss;		/* Receive Side Scaling */
+	struct vf_resources vfres;	/* Virtual Function Resource limits */
+	u8 nports;			/* # of Ethernet "ports" */
+};
+
+#include "adapter.h"
+
+#ifndef PCI_VENDOR_ID_CHELSIO
+# define PCI_VENDOR_ID_CHELSIO 0x1425
+#endif
+
+#define for_each_port(adapter, iter) \
+	for (iter = 0; iter < (adapter)->params.nports; iter++)
+
+static inline bool is_10g_port(const struct link_config *lc)
+{
+	return (lc->supported & SUPPORTED_10000baseT_Full) != 0;
+}
+
+static inline unsigned int core_ticks_per_usec(const struct adapter *adapter)
+{
+	return adapter->params.vpd.cclk / 1000;
+}
+
+static inline unsigned int us_to_core_ticks(const struct adapter *adapter,
+					    unsigned int us)
+{
+	return (us * adapter->params.vpd.cclk) / 1000;
+}
+
+static inline unsigned int core_ticks_to_us(const struct adapter *adapter,
+					    unsigned int ticks)
+{
+	return (ticks * 1000) / adapter->params.vpd.cclk;
+}
+
+int t4vf_wr_mbox_core(struct adapter *, const void *, int, void *, bool);
+
+static inline int t4vf_wr_mbox(struct adapter *adapter, const void *cmd,
+			       int size, void *rpl)
+{
+	return t4vf_wr_mbox_core(adapter, cmd, size, rpl, true);
+}
+
+static inline int t4vf_wr_mbox_ns(struct adapter *adapter, const void *cmd,
+				  int size, void *rpl)
+{
+	return t4vf_wr_mbox_core(adapter, cmd, size, rpl, false);
+}
+
+int __devinit t4vf_wait_dev_ready(struct adapter *);
+int __devinit t4vf_port_init(struct adapter *, int);
+
+int t4vf_query_params(struct adapter *, unsigned int, const u32 *, u32 *);
+int t4vf_set_params(struct adapter *, unsigned int, const u32 *, const u32 *);
+
+int t4vf_get_sge_params(struct adapter *);
+int t4vf_get_vpd_params(struct adapter *);
+int t4vf_get_dev_params(struct adapter *);
+int t4vf_get_rss_glb_config(struct adapter *);
+int t4vf_get_vfres(struct adapter *);
+
+int t4vf_read_rss_vi_config(struct adapter *, unsigned int,
+			    union rss_vi_config *);
+int t4vf_write_rss_vi_config(struct adapter *, unsigned int,
+			     union rss_vi_config *);
+int t4vf_config_rss_range(struct adapter *, unsigned int, int, int,
+			  const u16 *, int);
+
+int t4vf_alloc_vi(struct adapter *, int);
+int t4vf_free_vi(struct adapter *, int);
+int t4vf_enable_vi(struct adapter *, unsigned int, bool, bool);
+int t4vf_identify_port(struct adapter *, unsigned int, unsigned int);
+
+int t4vf_set_rxmode(struct adapter *, unsigned int, int, int, int, int, int,
+		    bool);
+int t4vf_alloc_mac_filt(struct adapter *, unsigned int, bool, unsigned int,
+			const u8 **, u16 *, u64 *, bool);
+int t4vf_change_mac(struct adapter *, unsigned int, int, const u8 *, bool);
+int t4vf_set_addr_hash(struct adapter *, unsigned int, bool, u64, bool);
+int t4vf_get_port_stats(struct adapter *, int, struct t4vf_port_stats *);
+
+int t4vf_iq_free(struct adapter *, unsigned int, unsigned int, unsigned int,
+		 unsigned int);
+int t4vf_eth_eq_free(struct adapter *, unsigned int);
+
+int t4vf_handle_fw_rpl(struct adapter *, const __be64 *);
+
+#endif /* __T4VF_COMMON_H__ */
diff --git a/drivers/net/cxgb4vf/t4vf_defs.h b/drivers/net/cxgb4vf/t4vf_defs.h
new file mode 100644
index 0000000..c7b127d
--- /dev/null
+++ b/drivers/net/cxgb4vf/t4vf_defs.h
@@ -0,0 +1,121 @@
+/*
+ * This file is part of the Chelsio T4 PCI-E SR-IOV Virtual Function Ethernet
+ * driver for Linux.
+ *
+ * Copyright (c) 2009-2010 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __T4VF_DEFS_H__
+#define __T4VF_DEFS_H__
+
+#include "../cxgb4/t4_regs.h"
+
+/*
+ * The VF Register Map.
+ *
+ * The Scatter Gather Engine (SGE), Multiport Support module (MPS), PIO Local
+ * bus module (PL) and CPU Interface Module (CIM) components are mapped via
+ * the Slice to Module Map Table (see below) in the Physical Function Register
+ * Map.  The Mail Box Data (MBDATA) range is mapped via the PCI-E Mailbox Base
+ * and Offset registers in the PF Register Map.  The MBDATA base address is
+ * quite constrained as it determines the Mailbox Data addresses for both PFs
+ * and VFs, and therefore must fit in both the VF and PF Register Maps without
+ * overlapping other registers.
+ */
+#define T4VF_SGE_BASE_ADDR	0x0000
+#define T4VF_MPS_BASE_ADDR	0x0100
+#define T4VF_PL_BASE_ADDR	0x0200
+#define T4VF_MBDATA_BASE_ADDR	0x0240
+#define T4VF_CIM_BASE_ADDR	0x0300
+
+#define T4VF_REGMAP_START	0x0000
+#define T4VF_REGMAP_SIZE	0x0400
+
+/*
+ * There's no hardware limitation which requires that the addresses of the
+ * Mailbox Data in the fixed CIM PF map and the programmable VF map must
+ * match.  However, it's a useful convention ...
+ */
+#if T4VF_MBDATA_BASE_ADDR != CIM_PF_MAILBOX_DATA
+#error T4VF_MBDATA_BASE_ADDR must match CIM_PF_MAILBOX_DATA!
+#endif
+
+/*
+ * Virtual Function "Slice to Module Map Table" definitions.
+ *
+ * This table allows us to map subsets of the various module register sets
+ * into the T4VF Register Map.  Each table entry identifies the index of the
+ * module whose registers are being mapped, the offset within the module's
+ * register set that the mapping should start at, the limit of the mapping,
+ * and the offset within the T4VF Register Map to which the module's registers
+ * are being mapped.  All addresses and qualtities are in terms of 32-bit
+ * words.  The "limit" value is also in terms of 32-bit words and is equal to
+ * the last address mapped in the T4VF Register Map 1 (i.e. it's a "<="
+ * relation rather than a "<").
+ */
+#define T4VF_MOD_MAP(module, index, first, last) \
+	T4VF_MOD_MAP_##module##_INDEX  = (index), \
+	T4VF_MOD_MAP_##module##_FIRST  = (first), \
+	T4VF_MOD_MAP_##module##_LAST   = (last), \
+	T4VF_MOD_MAP_##module##_OFFSET = ((first)/4), \
+	T4VF_MOD_MAP_##module##_BASE = \
+		(T4VF_##module##_BASE_ADDR/4 + (first)/4), \
+	T4VF_MOD_MAP_##module##_LIMIT = \
+		(T4VF_##module##_BASE_ADDR/4 + (last)/4),
+
+#define SGE_VF_KDOORBELL 0x0
+#define SGE_VF_GTS 0x4
+#define MPS_VF_CTL 0x0
+#define MPS_VF_STAT_RX_VF_ERR_FRAMES_H 0xfc
+#define PL_VF_WHOAMI 0x0
+#define CIM_VF_EXT_MAILBOX_CTRL 0x0
+#define CIM_VF_EXT_MAILBOX_STATUS 0x4
+
+enum {
+    T4VF_MOD_MAP(SGE, 2, SGE_VF_KDOORBELL, SGE_VF_GTS)
+    T4VF_MOD_MAP(MPS, 0, MPS_VF_CTL, MPS_VF_STAT_RX_VF_ERR_FRAMES_H)
+    T4VF_MOD_MAP(PL,  3, PL_VF_WHOAMI, PL_VF_WHOAMI)
+    T4VF_MOD_MAP(CIM, 1, CIM_VF_EXT_MAILBOX_CTRL, CIM_VF_EXT_MAILBOX_STATUS)
+};
+
+/*
+ * There isn't a Slice to Module Map Table entry for the Mailbox Data
+ * registers, but it's convenient to use similar names as above.  There are 8
+ * little-endian 64-bit Mailbox Data registers.  Note that the "instances"
+ * value below is in terms of 32-bit words which matches the "word" addressing
+ * space we use above for the Slice to Module Map Space.
+ */
+#define NUM_CIM_VF_MAILBOX_DATA_INSTANCES 16
+
+#define T4VF_MBDATA_FIRST	0
+#define T4VF_MBDATA_LAST	((NUM_CIM_VF_MAILBOX_DATA_INSTANCES-1)*4)
+
+#endif /* __T4T4VF_DEFS_H__ */
diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/cxgb4vf/t4vf_hw.c
new file mode 100644
index 0000000..1ef2528
--- /dev/null
+++ b/drivers/net/cxgb4vf/t4vf_hw.c
@@ -0,0 +1,1333 @@
+/*
+ * This file is part of the Chelsio T4 PCI-E SR-IOV Virtual Function Ethernet
+ * driver for Linux.
+ *
+ * Copyright (c) 2009-2010 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/version.h>
+#include <linux/pci.h>
+
+#include "t4vf_common.h"
+#include "t4vf_defs.h"
+
+#include "../cxgb4/t4_regs.h"
+#include "../cxgb4/t4fw_api.h"
+
+/*
+ * Wait for the device to become ready (signified by our "who am I" register
+ * returning a value other than all 1's).  Return an error if it doesn't
+ * become ready ...
+ */
+int __devinit t4vf_wait_dev_ready(struct adapter *adapter)
+{
+	const u32 whoami = T4VF_PL_BASE_ADDR + PL_VF_WHOAMI;
+	const u32 notready1 = 0xffffffff;
+	const u32 notready2 = 0xeeeeeeee;
+	u32 val;
+
+	val = t4_read_reg(adapter, whoami);
+	if (val != notready1 && val != notready2)
+		return 0;
+	msleep(500);
+	val = t4_read_reg(adapter, whoami);
+	if (val != notready1 && val != notready2)
+		return 0;
+	else
+		return -EIO;
+}
+
+/*
+ * Get the reply to a mailbox command and store it in @rpl in big-endian order
+ * (since the firmware data structures are specified in a big-endian layout).
+ */
+static void get_mbox_rpl(struct adapter *adapter, __be64 *rpl, int size,
+			 u32 mbox_data)
+{
+	for ( ; size; size -= 8, mbox_data += 8)
+		*rpl++ = cpu_to_be64(t4_read_reg64(adapter, mbox_data));
+}
+
+/*
+ * Dump contents of mailbox with a leading tag.
+ */
+static void dump_mbox(struct adapter *adapter, const char *tag, u32 mbox_data)
+{
+	dev_err(adapter->pdev_dev,
+		"mbox %s: %llx %llx %llx %llx %llx %llx %llx %llx\n", tag,
+		(unsigned long long)t4_read_reg64(adapter, mbox_data +  0),
+		(unsigned long long)t4_read_reg64(adapter, mbox_data +  8),
+		(unsigned long long)t4_read_reg64(adapter, mbox_data + 16),
+		(unsigned long long)t4_read_reg64(adapter, mbox_data + 24),
+		(unsigned long long)t4_read_reg64(adapter, mbox_data + 32),
+		(unsigned long long)t4_read_reg64(adapter, mbox_data + 40),
+		(unsigned long long)t4_read_reg64(adapter, mbox_data + 48),
+		(unsigned long long)t4_read_reg64(adapter, mbox_data + 56));
+}
+
+/**
+ *	t4vf_wr_mbox_core - send a command to FW through the mailbox
+ *	@adapter: the adapter
+ *	@cmd: the command to write
+ *	@size: command length in bytes
+ *	@rpl: where to optionally store the reply
+ *	@sleep_ok: if true we may sleep while awaiting command completion
+ *
+ *	Sends the given command to FW through the mailbox and waits for the
+ *	FW to execute the command.  If @rpl is not %NULL it is used to store
+ *	the FW's reply to the command.  The command and its optional reply
+ *	are of the same length.  FW can take up to 500 ms to respond.
+ *	@sleep_ok determines whether we may sleep while awaiting the response.
+ *	If sleeping is allowed we use progressive backoff otherwise we spin.
+ *
+ *	The return value is 0 on success or a negative errno on failure.  A
+ *	failure can happen either because we are not able to execute the
+ *	command or FW executes it but signals an error.  In the latter case
+ *	the return value is the error code indicated by FW (negated).
+ */
+int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
+		      void *rpl, bool sleep_ok)
+{
+	static int delay[] = {
+		1, 1, 3, 5, 10, 10, 20, 50, 100
+	};
+
+	u32 v;
+	int i, ms, delay_idx;
+	const __be64 *p;
+	u32 mbox_data = T4VF_MBDATA_BASE_ADDR;
+	u32 mbox_ctl = T4VF_CIM_BASE_ADDR + CIM_VF_EXT_MAILBOX_CTRL;
+
+	/*
+	 * Commands must be multiples of 16 bytes in length and may not be
+	 * larger than the size of the Mailbox Data register array.
+	 */
+	if ((size % 16) != 0 ||
+	    size > NUM_CIM_VF_MAILBOX_DATA_INSTANCES * 4)
+		return -EINVAL;
+
+	/*
+	 * Loop trying to get ownership of the mailbox.  Return an error
+	 * if we can't gain ownership.
+	 */
+	v = MBOWNER_GET(t4_read_reg(adapter, mbox_ctl));
+	for (i = 0; v == MBOX_OWNER_NONE && i < 3; i++)
+		v = MBOWNER_GET(t4_read_reg(adapter, mbox_ctl));
+	if (v != MBOX_OWNER_DRV)
+		return v == MBOX_OWNER_FW ? -EBUSY : -ETIMEDOUT;
+
+	/*
+	 * Write the command array into the Mailbox Data register array and
+	 * transfer ownership of the mailbox to the firmware.
+	 */
+	for (i = 0, p = cmd; i < size; i += 8)
+		t4_write_reg64(adapter, mbox_data + i, be64_to_cpu(*p++));
+	t4_write_reg(adapter, mbox_ctl,
+		     MBMSGVALID | MBOWNER(MBOX_OWNER_FW));
+	t4_read_reg(adapter, mbox_ctl);          /* flush write */
+
+	/*
+	 * Spin waiting for firmware to acknowledge processing our command.
+	 */
+	delay_idx = 0;
+	ms = delay[0];
+
+	for (i = 0; i < 500; i += ms) {
+		if (sleep_ok) {
+			ms = delay[delay_idx];
+			if (delay_idx < ARRAY_SIZE(delay))
+				delay_idx++;
+			msleep(ms);
+		} else
+			mdelay(ms);
+
+		/*
+		 * If we're the owner, see if this is the reply we wanted.
+		 */
+		v = t4_read_reg(adapter, mbox_ctl);
+		if (MBOWNER_GET(v) == MBOX_OWNER_DRV) {
+			/*
+			 * If the Message Valid bit isn't on, revoke ownership
+			 * of the mailbox and continue waiting for our reply.
+			 */
+			if ((v & MBMSGVALID) == 0) {
+				t4_write_reg(adapter, mbox_ctl,
+					     MBOWNER(MBOX_OWNER_NONE));
+				continue;
+			}
+
+			/*
+			 * We now have our reply.  Extract the command return
+			 * value, copy the reply back to our caller's buffer
+			 * (if specified) and revoke ownership of the mailbox.
+			 * We return the (negated) firmware command return
+			 * code (this depends on FW_SUCCESS == 0).
+			 */
+
+			/* return value in low-order little-endian word */
+			v = t4_read_reg(adapter, mbox_data);
+			if (FW_CMD_RETVAL_GET(v))
+				dump_mbox(adapter, "FW Error", mbox_data);
+
+			if (rpl) {
+				/* request bit in high-order BE word */
+				WARN_ON((be32_to_cpu(*(const u32 *)cmd)
+					 & FW_CMD_REQUEST) == 0);
+				get_mbox_rpl(adapter, rpl, size, mbox_data);
+				WARN_ON((be32_to_cpu(*(u32 *)rpl)
+					 & FW_CMD_REQUEST) != 0);
+			}
+			t4_write_reg(adapter, mbox_ctl,
+				     MBOWNER(MBOX_OWNER_NONE));
+			return -FW_CMD_RETVAL_GET(v);
+		}
+	}
+
+	/*
+	 * We timed out.  Return the error ...
+	 */
+	dump_mbox(adapter, "FW Timeout", mbox_data);
+	return -ETIMEDOUT;
+}
+
+/**
+ *	hash_mac_addr - return the hash value of a MAC address
+ *	@addr: the 48-bit Ethernet MAC address
+ *
+ *	Hashes a MAC address according to the hash function used by hardware
+ *	inexact (hash) address matching.
+ */
+static int hash_mac_addr(const u8 *addr)
+{
+	u32 a = ((u32)addr[0] << 16) | ((u32)addr[1] << 8) | addr[2];
+	u32 b = ((u32)addr[3] << 16) | ((u32)addr[4] << 8) | addr[5];
+	a ^= b;
+	a ^= (a >> 12);
+	a ^= (a >> 6);
+	return a & 0x3f;
+}
+
+/**
+ *	init_link_config - initialize a link's SW state
+ *	@lc: structure holding the link state
+ *	@caps: link capabilities
+ *
+ *	Initializes the SW state maintained for each link, including the link's
+ *	capabilities and default speed/flow-control/autonegotiation settings.
+ */
+static void __devinit init_link_config(struct link_config *lc,
+				       unsigned int caps)
+{
+	lc->supported = caps;
+	lc->requested_speed = 0;
+	lc->speed = 0;
+	lc->requested_fc = lc->fc = PAUSE_RX | PAUSE_TX;
+	if (lc->supported & SUPPORTED_Autoneg) {
+		lc->advertising = lc->supported;
+		lc->autoneg = AUTONEG_ENABLE;
+		lc->requested_fc |= PAUSE_AUTONEG;
+	} else {
+		lc->advertising = 0;
+		lc->autoneg = AUTONEG_DISABLE;
+	}
+}
+
+/**
+ *	t4vf_port_init - initialize port hardware/software state
+ *	@adapter: the adapter
+ *	@pidx: the adapter port index
+ */
+int __devinit t4vf_port_init(struct adapter *adapter, int pidx)
+{
+	struct port_info *pi = adap2pinfo(adapter, pidx);
+	struct fw_vi_cmd vi_cmd, vi_rpl;
+	struct fw_port_cmd port_cmd, port_rpl;
+	int v;
+	u32 word;
+
+	/*
+	 * Execute a VI Read command to get our Virtual Interface information
+	 * like MAC address, etc.
+	 */
+	memset(&vi_cmd, 0, sizeof(vi_cmd));
+	vi_cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_VI_CMD) |
+				       FW_CMD_REQUEST |
+				       FW_CMD_READ);
+	vi_cmd.alloc_to_len16 = cpu_to_be32(FW_LEN16(vi_cmd));
+	vi_cmd.type_viid = cpu_to_be16(FW_VI_CMD_VIID(pi->viid));
+	v = t4vf_wr_mbox(adapter, &vi_cmd, sizeof(vi_cmd), &vi_rpl);
+	if (v)
+		return v;
+
+	BUG_ON(pi->port_id != FW_VI_CMD_PORTID_GET(vi_rpl.portid_pkd));
+	pi->rss_size = FW_VI_CMD_RSSSIZE_GET(be16_to_cpu(vi_rpl.rsssize_pkd));
+	t4_os_set_hw_addr(adapter, pidx, vi_rpl.mac);
+
+	/*
+	 * If we don't have read access to our port information, we're done
+	 * now.  Otherwise, execute a PORT Read command to get it ...
+	 */
+	if (!(adapter->params.vfres.r_caps & FW_CMD_CAP_PORT))
+		return 0;
+
+	memset(&port_cmd, 0, sizeof(port_cmd));
+	port_cmd.op_to_portid = cpu_to_be32(FW_CMD_OP(FW_PORT_CMD) |
+					    FW_CMD_REQUEST |
+					    FW_CMD_READ |
+					    FW_PORT_CMD_PORTID(pi->port_id));
+	port_cmd.action_to_len16 =
+		cpu_to_be32(FW_PORT_CMD_ACTION(FW_PORT_ACTION_GET_PORT_INFO) |
+			    FW_LEN16(port_cmd));
+	v = t4vf_wr_mbox(adapter, &port_cmd, sizeof(port_cmd), &port_rpl);
+	if (v)
+		return v;
+
+	v = 0;
+	word = be16_to_cpu(port_rpl.u.info.pcap);
+	if (word & FW_PORT_CAP_SPEED_100M)
+		v |= SUPPORTED_100baseT_Full;
+	if (word & FW_PORT_CAP_SPEED_1G)
+		v |= SUPPORTED_1000baseT_Full;
+	if (word & FW_PORT_CAP_SPEED_10G)
+		v |= SUPPORTED_10000baseT_Full;
+	if (word & FW_PORT_CAP_ANEG)
+		v |= SUPPORTED_Autoneg;
+	init_link_config(&pi->link_cfg, v);
+
+	return 0;
+}
+
+/**
+ *	t4vf_query_params - query FW or device parameters
+ *	@adapter: the adapter
+ *	@nparams: the number of parameters
+ *	@params: the parameter names
+ *	@vals: the parameter values
+ *
+ *	Reads the values of firmware or device parameters.  Up to 7 parameters
+ *	can be queried at once.
+ */
+int t4vf_query_params(struct adapter *adapter, unsigned int nparams,
+		      const u32 *params, u32 *vals)
+{
+	int i, ret;
+	struct fw_params_cmd cmd, rpl;
+	struct fw_params_param *p;
+	size_t len16;
+
+	if (nparams > 7)
+		return -EINVAL;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_PARAMS_CMD) |
+				    FW_CMD_REQUEST |
+				    FW_CMD_READ);
+	len16 = DIV_ROUND_UP(offsetof(struct fw_params_cmd,
+				      param[nparams].mnem), 16);
+	cmd.retval_len16 = cpu_to_be32(FW_CMD_LEN16(len16));
+	for (i = 0, p = &cmd.param[0]; i < nparams; i++, p++)
+		p->mnem = htonl(*params++);
+
+	ret = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &rpl);
+	if (ret == 0)
+		for (i = 0, p = &rpl.param[0]; i < nparams; i++, p++)
+			*vals++ = be32_to_cpu(p->val);
+	return ret;
+}
+
+/**
+ *	t4vf_set_params - sets FW or device parameters
+ *	@adapter: the adapter
+ *	@nparams: the number of parameters
+ *	@params: the parameter names
+ *	@vals: the parameter values
+ *
+ *	Sets the values of firmware or device parameters.  Up to 7 parameters
+ *	can be specified at once.
+ */
+int t4vf_set_params(struct adapter *adapter, unsigned int nparams,
+		    const u32 *params, const u32 *vals)
+{
+	int i;
+	struct fw_params_cmd cmd;
+	struct fw_params_param *p;
+	size_t len16;
+
+	if (nparams > 7)
+		return -EINVAL;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_PARAMS_CMD) |
+				    FW_CMD_REQUEST |
+				    FW_CMD_WRITE);
+	len16 = DIV_ROUND_UP(offsetof(struct fw_params_cmd,
+				      param[nparams]), 16);
+	cmd.retval_len16 = cpu_to_be32(FW_CMD_LEN16(len16));
+	for (i = 0, p = &cmd.param[0]; i < nparams; i++, p++) {
+		p->mnem = cpu_to_be32(*params++);
+		p->val = cpu_to_be32(*vals++);
+	}
+
+	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
+}
+
+/**
+ *	t4vf_get_sge_params - retrieve adapter Scatter gather Engine parameters
+ *	@adapter: the adapter
+ *
+ *	Retrieves various core SGE parameters in the form of hardware SGE
+ *	register values.  The caller is responsible for decoding these as
+ *	needed.  The SGE parameters are stored in @adapter->params.sge.
+ */
+int t4vf_get_sge_params(struct adapter *adapter)
+{
+	struct sge_params *sge_params = &adapter->params.sge;
+	u32 params[7], vals[7];
+	int v;
+
+	params[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ(SGE_CONTROL));
+	params[1] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ(SGE_HOST_PAGE_SIZE));
+	params[2] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ(SGE_FL_BUFFER_SIZE0));
+	params[3] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ(SGE_FL_BUFFER_SIZE1));
+	params[4] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ(SGE_TIMER_VALUE_0_AND_1));
+	params[5] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ(SGE_TIMER_VALUE_2_AND_3));
+	params[6] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ(SGE_TIMER_VALUE_4_AND_5));
+	v = t4vf_query_params(adapter, 7, params, vals);
+	if (v)
+		return v;
+	sge_params->sge_control = vals[0];
+	sge_params->sge_host_page_size = vals[1];
+	sge_params->sge_fl_buffer_size[0] = vals[2];
+	sge_params->sge_fl_buffer_size[1] = vals[3];
+	sge_params->sge_timer_value_0_and_1 = vals[4];
+	sge_params->sge_timer_value_2_and_3 = vals[5];
+	sge_params->sge_timer_value_4_and_5 = vals[6];
+
+	params[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ(SGE_INGRESS_RX_THRESHOLD));
+	v = t4vf_query_params(adapter, 1, params, vals);
+	if (v)
+		return v;
+	sge_params->sge_ingress_rx_threshold = vals[0];
+
+	return 0;
+}
+
+/**
+ *	t4vf_get_vpd_params - retrieve device VPD paremeters
+ *	@adapter: the adapter
+ *
+ *	Retrives various device Vital Product Data parameters.  The parameters
+ *	are stored in @adapter->params.vpd.
+ */
+int t4vf_get_vpd_params(struct adapter *adapter)
+{
+	struct vpd_params *vpd_params = &adapter->params.vpd;
+	u32 params[7], vals[7];
+	int v;
+
+	params[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) |
+		     FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_CCLK));
+	v = t4vf_query_params(adapter, 1, params, vals);
+	if (v)
+		return v;
+	vpd_params->cclk = vals[0];
+
+	return 0;
+}
+
+/**
+ *	t4vf_get_dev_params - retrieve device paremeters
+ *	@adapter: the adapter
+ *
+ *	Retrives various device parameters.  The parameters are stored in
+ *	@adapter->params.dev.
+ */
+int t4vf_get_dev_params(struct adapter *adapter)
+{
+	struct dev_params *dev_params = &adapter->params.dev;
+	u32 params[7], vals[7];
+	int v;
+
+	params[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) |
+		     FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_FWREV));
+	params[1] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) |
+		     FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_TPREV));
+	v = t4vf_query_params(adapter, 2, params, vals);
+	if (v)
+		return v;
+	dev_params->fwrev = vals[0];
+	dev_params->tprev = vals[1];
+
+	return 0;
+}
+
+/**
+ *	t4vf_get_rss_glb_config - retrieve adapter RSS Global Configuration
+ *	@adapter: the adapter
+ *
+ *	Retrieves global RSS mode and parameters with which we have to live
+ *	and stores them in the @adapter's RSS parameters.
+ */
+int t4vf_get_rss_glb_config(struct adapter *adapter)
+{
+	struct rss_params *rss = &adapter->params.rss;
+	struct fw_rss_glb_config_cmd cmd, rpl;
+	int v;
+
+	/*
+	 * Execute an RSS Global Configuration read command to retrieve
+	 * our RSS configuration.
+	 */
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_write = cpu_to_be32(FW_CMD_OP(FW_RSS_GLB_CONFIG_CMD) |
+				      FW_CMD_REQUEST |
+				      FW_CMD_READ);
+	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
+	v = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &rpl);
+	if (v)
+		return v;
+
+	/*
+	 * Transate the big-endian RSS Global Configuration into our
+	 * cpu-endian format based on the RSS mode.  We also do first level
+	 * filtering at this point to weed out modes which don't support
+	 * VF Drivers ...
+	 */
+	rss->mode = FW_RSS_GLB_CONFIG_CMD_MODE_GET(
+			be32_to_cpu(rpl.u.manual.mode_pkd));
+	switch (rss->mode) {
+	case FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL: {
+		u32 word = be32_to_cpu(
+				rpl.u.basicvirtual.synmapen_to_hashtoeplitz);
+
+		rss->u.basicvirtual.synmapen =
+			((word & FW_RSS_GLB_CONFIG_CMD_SYNMAPEN) != 0);
+		rss->u.basicvirtual.syn4tupenipv6 =
+			((word & FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV6) != 0);
+		rss->u.basicvirtual.syn2tupenipv6 =
+			((word & FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV6) != 0);
+		rss->u.basicvirtual.syn4tupenipv4 =
+			((word & FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV4) != 0);
+		rss->u.basicvirtual.syn2tupenipv4 =
+			((word & FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV4) != 0);
+
+		rss->u.basicvirtual.ofdmapen =
+			((word & FW_RSS_GLB_CONFIG_CMD_OFDMAPEN) != 0);
+
+		rss->u.basicvirtual.tnlmapen =
+			((word & FW_RSS_GLB_CONFIG_CMD_TNLMAPEN) != 0);
+		rss->u.basicvirtual.tnlalllookup =
+			((word  & FW_RSS_GLB_CONFIG_CMD_TNLALLLKP) != 0);
+
+		rss->u.basicvirtual.hashtoeplitz =
+			((word & FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ) != 0);
+
+		/* we need at least Tunnel Map Enable to be set */
+		if (!rss->u.basicvirtual.tnlmapen)
+			return -EINVAL;
+		break;
+	}
+
+	default:
+		/* all unknown/unsupported RSS modes result in an error */
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/**
+ *	t4vf_get_vfres - retrieve VF resource limits
+ *	@adapter: the adapter
+ *
+ *	Retrieves configured resource limits and capabilities for a virtual
+ *	function.  The results are stored in @adapter->vfres.
+ */
+int t4vf_get_vfres(struct adapter *adapter)
+{
+	struct vf_resources *vfres = &adapter->params.vfres;
+	struct fw_pfvf_cmd cmd, rpl;
+	int v;
+	u32 word;
+
+	/*
+	 * Execute PFVF Read command to get VF resource limits; bail out early
+	 * with error on command failure.
+	 */
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_PFVF_CMD) |
+				    FW_CMD_REQUEST |
+				    FW_CMD_READ);
+	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
+	v = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &rpl);
+	if (v)
+		return v;
+
+	/*
+	 * Extract VF resource limits and return success.
+	 */
+	word = be32_to_cpu(rpl.niqflint_niq);
+	vfres->niqflint = FW_PFVF_CMD_NIQFLINT_GET(word);
+	vfres->niq = FW_PFVF_CMD_NIQ_GET(word);
+
+	word = be32_to_cpu(rpl.type_to_neq);
+	vfres->neq = FW_PFVF_CMD_NEQ_GET(word);
+	vfres->pmask = FW_PFVF_CMD_PMASK_GET(word);
+
+	word = be32_to_cpu(rpl.tc_to_nexactf);
+	vfres->tc = FW_PFVF_CMD_TC_GET(word);
+	vfres->nvi = FW_PFVF_CMD_NVI_GET(word);
+	vfres->nexactf = FW_PFVF_CMD_NEXACTF_GET(word);
+
+	word = be32_to_cpu(rpl.r_caps_to_nethctrl);
+	vfres->r_caps = FW_PFVF_CMD_R_CAPS_GET(word);
+	vfres->wx_caps = FW_PFVF_CMD_WX_CAPS_GET(word);
+	vfres->nethctrl = FW_PFVF_CMD_NETHCTRL_GET(word);
+
+	return 0;
+}
+
+/**
+ *	t4vf_read_rss_vi_config - read a VI's RSS configuration
+ *	@adapter: the adapter
+ *	@viid: Virtual Interface ID
+ *	@config: pointer to host-native VI RSS Configuration buffer
+ *
+ *	Reads the Virtual Interface's RSS configuration information and
+ *	translates it into CPU-native format.
+ */
+int t4vf_read_rss_vi_config(struct adapter *adapter, unsigned int viid,
+			    union rss_vi_config *config)
+{
+	struct fw_rss_vi_config_cmd cmd, rpl;
+	int v;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_RSS_VI_CONFIG_CMD) |
+				     FW_CMD_REQUEST |
+				     FW_CMD_READ |
+				     FW_RSS_VI_CONFIG_CMD_VIID(viid));
+	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
+	v = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &rpl);
+	if (v)
+		return v;
+
+	switch (adapter->params.rss.mode) {
+	case FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL: {
+		u32 word = be32_to_cpu(rpl.u.basicvirtual.defaultq_to_udpen);
+
+		config->basicvirtual.ip6fourtupen =
+			((word & FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN) != 0);
+		config->basicvirtual.ip6twotupen =
+			((word & FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN) != 0);
+		config->basicvirtual.ip4fourtupen =
+			((word & FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN) != 0);
+		config->basicvirtual.ip4twotupen =
+			((word & FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN) != 0);
+		config->basicvirtual.udpen =
+			((word & FW_RSS_VI_CONFIG_CMD_UDPEN) != 0);
+		config->basicvirtual.defaultq =
+			FW_RSS_VI_CONFIG_CMD_DEFAULTQ_GET(word);
+		break;
+	}
+
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/**
+ *	t4vf_write_rss_vi_config - write a VI's RSS configuration
+ *	@adapter: the adapter
+ *	@viid: Virtual Interface ID
+ *	@config: pointer to host-native VI RSS Configuration buffer
+ *
+ *	Write the Virtual Interface's RSS configuration information
+ *	(translating it into firmware-native format before writing).
+ */
+int t4vf_write_rss_vi_config(struct adapter *adapter, unsigned int viid,
+			     union rss_vi_config *config)
+{
+	struct fw_rss_vi_config_cmd cmd, rpl;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_RSS_VI_CONFIG_CMD) |
+				     FW_CMD_REQUEST |
+				     FW_CMD_WRITE |
+				     FW_RSS_VI_CONFIG_CMD_VIID(viid));
+	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
+	switch (adapter->params.rss.mode) {
+	case FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL: {
+		u32 word = 0;
+
+		if (config->basicvirtual.ip6fourtupen)
+			word |= FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN;
+		if (config->basicvirtual.ip6twotupen)
+			word |= FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN;
+		if (config->basicvirtual.ip4fourtupen)
+			word |= FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN;
+		if (config->basicvirtual.ip4twotupen)
+			word |= FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN;
+		if (config->basicvirtual.udpen)
+			word |= FW_RSS_VI_CONFIG_CMD_UDPEN;
+		word |= FW_RSS_VI_CONFIG_CMD_DEFAULTQ(
+				config->basicvirtual.defaultq);
+		cmd.u.basicvirtual.defaultq_to_udpen = cpu_to_be32(word);
+		break;
+	}
+
+	default:
+		return -EINVAL;
+	}
+
+	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &rpl);
+}
+
+/**
+ *	t4vf_config_rss_range - configure a portion of the RSS mapping table
+ *	@adapter: the adapter
+ *	@viid: Virtual Interface of RSS Table Slice
+ *	@start: starting entry in the table to write
+ *	@n: how many table entries to write
+ *	@rspq: values for the "Response Queue" (Ingress Queue) lookup table
+ *	@nrspq: number of values in @rspq
+ *
+ *	Programs the selected part of the VI's RSS mapping table with the
+ *	provided values.  If @nrspq < @n the supplied values are used repeatedly
+ *	until the full table range is populated.
+ *
+ *	The caller must ensure the values in @rspq are in the range 0..1023.
+ */
+int t4vf_config_rss_range(struct adapter *adapter, unsigned int viid,
+			  int start, int n, const u16 *rspq, int nrspq)
+{
+	const u16 *rsp = rspq;
+	const u16 *rsp_end = rspq+nrspq;
+	struct fw_rss_ind_tbl_cmd cmd;
+
+	/*
+	 * Initialize firmware command template to write the RSS table.
+	 */
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_RSS_IND_TBL_CMD) |
+				     FW_CMD_REQUEST |
+				     FW_CMD_WRITE |
+				     FW_RSS_IND_TBL_CMD_VIID(viid));
+	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
+
+	/*
+	 * Each firmware RSS command can accommodate up to 32 RSS Ingress
+	 * Queue Identifiers.  These Ingress Queue IDs are packed three to
+	 * a 32-bit word as 10-bit values with the upper remaining 2 bits
+	 * reserved.
+	 */
+	while (n > 0) {
+		__be32 *qp = &cmd.iq0_to_iq2;
+		int nq = min(n, 32);
+		int ret;
+
+		/*
+		 * Set up the firmware RSS command header to send the next
+		 * "nq" Ingress Queue IDs to the firmware.
+		 */
+		cmd.niqid = cpu_to_be16(nq);
+		cmd.startidx = cpu_to_be16(start);
+
+		/*
+		 * "nq" more done for the start of the next loop.
+		 */
+		start += nq;
+		n -= nq;
+
+		/*
+		 * While there are still Ingress Queue IDs to stuff into the
+		 * current firmware RSS command, retrieve them from the
+		 * Ingress Queue ID array and insert them into the command.
+		 */
+		while (nq > 0) {
+			/*
+			 * Grab up to the next 3 Ingress Queue IDs (wrapping
+			 * around the Ingress Queue ID array if necessary) and
+			 * insert them into the firmware RSS command at the
+			 * current 3-tuple position within the commad.
+			 */
+			u16 qbuf[3];
+			u16 *qbp = qbuf;
+			int nqbuf = min(3, nq);
+
+			nq -= nqbuf;
+			qbuf[0] = qbuf[1] = qbuf[2] = 0;
+			while (nqbuf) {
+				nqbuf--;
+				*qbp++ = *rsp++;
+				if (rsp >= rsp_end)
+					rsp = rspq;
+			}
+			*qp++ = cpu_to_be32(FW_RSS_IND_TBL_CMD_IQ0(qbuf[0]) |
+					    FW_RSS_IND_TBL_CMD_IQ1(qbuf[1]) |
+					    FW_RSS_IND_TBL_CMD_IQ2(qbuf[2]));
+		}
+
+		/*
+		 * Send this portion of the RRS table update to the firmware;
+		 * bail out on any errors.
+		 */
+		ret = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
+		if (ret)
+			return ret;
+	}
+	return 0;
+}
+
+/**
+ *	t4vf_alloc_vi - allocate a virtual interface on a port
+ *	@adapter: the adapter
+ *	@port_id: physical port associated with the VI
+ *
+ *	Allocate a new Virtual Interface and bind it to the indicated
+ *	physical port.  Return the new Virtual Interface Identifier on
+ *	success, or a [negative] error number on failure.
+ */
+int t4vf_alloc_vi(struct adapter *adapter, int port_id)
+{
+	struct fw_vi_cmd cmd, rpl;
+	int v;
+
+	/*
+	 * Execute a VI command to allocate Virtual Interface and return its
+	 * VIID.
+	 */
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_VI_CMD) |
+				    FW_CMD_REQUEST |
+				    FW_CMD_WRITE |
+				    FW_CMD_EXEC);
+	cmd.alloc_to_len16 = cpu_to_be32(FW_LEN16(cmd) |
+					 FW_VI_CMD_ALLOC);
+	cmd.portid_pkd = FW_VI_CMD_PORTID(port_id);
+	v = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &rpl);
+	if (v)
+		return v;
+
+	return FW_VI_CMD_VIID_GET(be16_to_cpu(rpl.type_viid));
+}
+
+/**
+ *	t4vf_free_vi -- free a virtual interface
+ *	@adapter: the adapter
+ *	@viid: the virtual interface identifier
+ *
+ *	Free a previously allocated Virtual Interface.  Return an error on
+ *	failure.
+ */
+int t4vf_free_vi(struct adapter *adapter, int viid)
+{
+	struct fw_vi_cmd cmd;
+
+	/*
+	 * Execute a VI command to free the Virtual Interface.
+	 */
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_VI_CMD) |
+				    FW_CMD_REQUEST |
+				    FW_CMD_EXEC);
+	cmd.alloc_to_len16 = cpu_to_be32(FW_LEN16(cmd) |
+					 FW_VI_CMD_FREE);
+	cmd.type_viid = cpu_to_be16(FW_VI_CMD_VIID(viid));
+	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
+}
+
+/**
+ *	t4vf_enable_vi - enable/disable a virtual interface
+ *	@adapter: the adapter
+ *	@viid: the Virtual Interface ID
+ *	@rx_en: 1=enable Rx, 0=disable Rx
+ *	@tx_en: 1=enable Tx, 0=disable Tx
+ *
+ *	Enables/disables a virtual interface.
+ */
+int t4vf_enable_vi(struct adapter *adapter, unsigned int viid,
+		   bool rx_en, bool tx_en)
+{
+	struct fw_vi_enable_cmd cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_ENABLE_CMD) |
+				     FW_CMD_REQUEST |
+				     FW_CMD_EXEC |
+				     FW_VI_ENABLE_CMD_VIID(viid));
+	cmd.ien_to_len16 = cpu_to_be32(FW_VI_ENABLE_CMD_IEN(rx_en) |
+				       FW_VI_ENABLE_CMD_EEN(tx_en) |
+				       FW_LEN16(cmd));
+	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
+}
+
+/**
+ *	t4vf_identify_port - identify a VI's port by blinking its LED
+ *	@adapter: the adapter
+ *	@viid: the Virtual Interface ID
+ *	@nblinks: how many times to blink LED at 2.5 Hz
+ *
+ *	Identifies a VI's port by blinking its LED.
+ */
+int t4vf_identify_port(struct adapter *adapter, unsigned int viid,
+		       unsigned int nblinks)
+{
+	struct fw_vi_enable_cmd cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_ENABLE_CMD) |
+				     FW_CMD_REQUEST |
+				     FW_CMD_EXEC |
+				     FW_VI_ENABLE_CMD_VIID(viid));
+	cmd.ien_to_len16 = cpu_to_be32(FW_VI_ENABLE_CMD_LED |
+				       FW_LEN16(cmd));
+	cmd.blinkdur = cpu_to_be16(nblinks);
+	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
+}
+
+/**
+ *	t4vf_set_rxmode - set Rx properties of a virtual interface
+ *	@adapter: the adapter
+ *	@viid: the VI id
+ *	@mtu: the new MTU or -1 for no change
+ *	@promisc: 1 to enable promiscuous mode, 0 to disable it, -1 no change
+ *	@all_multi: 1 to enable all-multi mode, 0 to disable it, -1 no change
+ *	@bcast: 1 to enable broadcast Rx, 0 to disable it, -1 no change
+ *	@vlanex: 1 to enable hardware VLAN Tag extraction, 0 to disable it,
+ *		-1 no change
+ *
+ *	Sets Rx properties of a virtual interface.
+ */
+int t4vf_set_rxmode(struct adapter *adapter, unsigned int viid,
+		    int mtu, int promisc, int all_multi, int bcast, int vlanex,
+		    bool sleep_ok)
+{
+	struct fw_vi_rxmode_cmd cmd;
+
+	/* convert to FW values */
+	if (mtu < 0)
+		mtu = FW_VI_RXMODE_CMD_MTU_MASK;
+	if (promisc < 0)
+		promisc = FW_VI_RXMODE_CMD_PROMISCEN_MASK;
+	if (all_multi < 0)
+		all_multi = FW_VI_RXMODE_CMD_ALLMULTIEN_MASK;
+	if (bcast < 0)
+		bcast = FW_VI_RXMODE_CMD_BROADCASTEN_MASK;
+	if (vlanex < 0)
+		vlanex = FW_VI_RXMODE_CMD_VLANEXEN_MASK;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_RXMODE_CMD) |
+				     FW_CMD_REQUEST |
+				     FW_CMD_WRITE |
+				     FW_VI_RXMODE_CMD_VIID(viid));
+	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
+	cmd.mtu_to_vlanexen =
+		cpu_to_be32(FW_VI_RXMODE_CMD_MTU(mtu) |
+			    FW_VI_RXMODE_CMD_PROMISCEN(promisc) |
+			    FW_VI_RXMODE_CMD_ALLMULTIEN(all_multi) |
+			    FW_VI_RXMODE_CMD_BROADCASTEN(bcast) |
+			    FW_VI_RXMODE_CMD_VLANEXEN(vlanex));
+	return t4vf_wr_mbox_core(adapter, &cmd, sizeof(cmd), NULL, sleep_ok);
+}
+
+/**
+ *	t4vf_alloc_mac_filt - allocates exact-match filters for MAC addresses
+ *	@adapter: the adapter
+ *	@viid: the Virtual Interface Identifier
+ *	@free: if true any existing filters for this VI id are first removed
+ *	@naddr: the number of MAC addresses to allocate filters for (up to 7)
+ *	@addr: the MAC address(es)
+ *	@idx: where to store the index of each allocated filter
+ *	@hash: pointer to hash address filter bitmap
+ *	@sleep_ok: call is allowed to sleep
+ *
+ *	Allocates an exact-match filter for each of the supplied addresses and
+ *	sets it to the corresponding address.  If @idx is not %NULL it should
+ *	have at least @naddr entries, each of which will be set to the index of
+ *	the filter allocated for the corresponding MAC address.  If a filter
+ *	could not be allocated for an address its index is set to 0xffff.
+ *	If @hash is not %NULL addresses that fail to allocate an exact filter
+ *	are hashed and update the hash filter bitmap pointed at by @hash.
+ *
+ *	Returns a negative error number or the number of filters allocated.
+ */
+int t4vf_alloc_mac_filt(struct adapter *adapter, unsigned int viid, bool free,
+			unsigned int naddr, const u8 **addr, u16 *idx,
+			u64 *hash, bool sleep_ok)
+{
+	int i, ret;
+	struct fw_vi_mac_cmd cmd, rpl;
+	struct fw_vi_mac_exact *p;
+	size_t len16;
+
+	if (naddr > ARRAY_SIZE(cmd.u.exact))
+		return -EINVAL;
+	len16 = DIV_ROUND_UP(offsetof(struct fw_vi_mac_cmd,
+				      u.exact[naddr]), 16);
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_MAC_CMD) |
+				     FW_CMD_REQUEST |
+				     FW_CMD_WRITE |
+				     (free ? FW_CMD_EXEC : 0) |
+				     FW_VI_MAC_CMD_VIID(viid));
+	cmd.freemacs_to_len16 = cpu_to_be32(FW_VI_MAC_CMD_FREEMACS(free) |
+					    FW_CMD_LEN16(len16));
+
+	for (i = 0, p = cmd.u.exact; i < naddr; i++, p++) {
+		p->valid_to_idx =
+			cpu_to_be16(FW_VI_MAC_CMD_VALID |
+				    FW_VI_MAC_CMD_IDX(FW_VI_MAC_ADD_MAC));
+		memcpy(p->macaddr, addr[i], sizeof(p->macaddr));
+	}
+
+	ret = t4vf_wr_mbox_core(adapter, &cmd, sizeof(cmd), &rpl, sleep_ok);
+	if (ret)
+		return ret;
+
+	for (i = 0, p = rpl.u.exact; i < naddr; i++, p++) {
+		u16 index = FW_VI_MAC_CMD_IDX_GET(be16_to_cpu(p->valid_to_idx));
+
+		if (idx)
+			idx[i] = (index >= FW_CLS_TCAM_NUM_ENTRIES
+				  ? 0xffff
+				  : index);
+		if (index < FW_CLS_TCAM_NUM_ENTRIES)
+			ret++;
+		else if (hash)
+			*hash |= (1 << hash_mac_addr(addr[i]));
+	}
+	return ret;
+}
+
+/**
+ *	t4vf_change_mac - modifies the exact-match filter for a MAC address
+ *	@adapter: the adapter
+ *	@viid: the Virtual Interface ID
+ *	@idx: index of existing filter for old value of MAC address, or -1
+ *	@addr: the new MAC address value
+ *	@persist: if idx < 0, the new MAC allocation should be persistent
+ *
+ *	Modifies an exact-match filter and sets it to the new MAC address.
+ *	Note that in general it is not possible to modify the value of a given
+ *	filter so the generic way to modify an address filter is to free the
+ *	one being used by the old address value and allocate a new filter for
+ *	the new address value.  @idx can be -1 if the address is a new
+ *	addition.
+ *
+ *	Returns a negative error number or the index of the filter with the new
+ *	MAC value.
+ */
+int t4vf_change_mac(struct adapter *adapter, unsigned int viid,
+		    int idx, const u8 *addr, bool persist)
+{
+	int ret;
+	struct fw_vi_mac_cmd cmd, rpl;
+	struct fw_vi_mac_exact *p = &cmd.u.exact[0];
+	size_t len16 = DIV_ROUND_UP(offsetof(struct fw_vi_mac_cmd,
+					     u.exact[1]), 16);
+
+	/*
+	 * If this is a new allocation, determine whether it should be
+	 * persistent (across a "freemacs" operation) or not.
+	 */
+	if (idx < 0)
+		idx = persist ? FW_VI_MAC_ADD_PERSIST_MAC : FW_VI_MAC_ADD_MAC;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_MAC_CMD) |
+				     FW_CMD_REQUEST |
+				     FW_CMD_WRITE |
+				     FW_VI_MAC_CMD_VIID(viid));
+	cmd.freemacs_to_len16 = cpu_to_be32(FW_CMD_LEN16(len16));
+	p->valid_to_idx = cpu_to_be16(FW_VI_MAC_CMD_VALID |
+				      FW_VI_MAC_CMD_IDX(idx));
+	memcpy(p->macaddr, addr, sizeof(p->macaddr));
+
+	ret = t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), &rpl);
+	if (ret == 0) {
+		p = &rpl.u.exact[0];
+		ret = FW_VI_MAC_CMD_IDX_GET(be16_to_cpu(p->valid_to_idx));
+		if (ret >= FW_CLS_TCAM_NUM_ENTRIES)
+			ret = -ENOMEM;
+	}
+	return ret;
+}
+
+/**
+ *	t4vf_set_addr_hash - program the MAC inexact-match hash filter
+ *	@adapter: the adapter
+ *	@viid: the Virtual Interface Identifier
+ *	@ucast: whether the hash filter should also match unicast addresses
+ *	@vec: the value to be written to the hash filter
+ *	@sleep_ok: call is allowed to sleep
+ *
+ *	Sets the 64-bit inexact-match hash filter for a virtual interface.
+ */
+int t4vf_set_addr_hash(struct adapter *adapter, unsigned int viid,
+		       bool ucast, u64 vec, bool sleep_ok)
+{
+	struct fw_vi_mac_cmd cmd;
+	size_t len16 = DIV_ROUND_UP(offsetof(struct fw_vi_mac_cmd,
+					     u.exact[0]), 16);
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_MAC_CMD) |
+				     FW_CMD_REQUEST |
+				     FW_CMD_WRITE |
+				     FW_VI_ENABLE_CMD_VIID(viid));
+	cmd.freemacs_to_len16 = cpu_to_be32(FW_VI_MAC_CMD_HASHVECEN |
+					    FW_VI_MAC_CMD_HASHUNIEN(ucast) |
+					    FW_CMD_LEN16(len16));
+	cmd.u.hash.hashvec = cpu_to_be64(vec);
+	return t4vf_wr_mbox_core(adapter, &cmd, sizeof(cmd), NULL, sleep_ok);
+}
+
+/**
+ *	t4vf_get_port_stats - collect "port" statistics
+ *	@adapter: the adapter
+ *	@pidx: the port index
+ *	@s: the stats structure to fill
+ *
+ *	Collect statistics for the "port"'s Virtual Interface.
+ */
+int t4vf_get_port_stats(struct adapter *adapter, int pidx,
+			struct t4vf_port_stats *s)
+{
+	struct port_info *pi = adap2pinfo(adapter, pidx);
+	struct fw_vi_stats_vf fwstats;
+	unsigned int rem = VI_VF_NUM_STATS;
+	__be64 *fwsp = (__be64 *)&fwstats;
+
+	/*
+	 * Grab the Virtual Interface statistics a chunk at a time via mailbox
+	 * commands.  We could use a Work Request and get all of them at once
+	 * but that's an asynchronous interface which is awkward to use.
+	 */
+	while (rem) {
+		unsigned int ix = VI_VF_NUM_STATS - rem;
+		unsigned int nstats = min(6U, rem);
+		struct fw_vi_stats_cmd cmd, rpl;
+		size_t len = (offsetof(struct fw_vi_stats_cmd, u) +
+			      sizeof(struct fw_vi_stats_ctl));
+		size_t len16 = DIV_ROUND_UP(len, 16);
+		int ret;
+
+		memset(&cmd, 0, sizeof(cmd));
+		cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_STATS_CMD) |
+					     FW_VI_STATS_CMD_VIID(pi->viid) |
+					     FW_CMD_REQUEST |
+					     FW_CMD_READ);
+		cmd.retval_len16 = cpu_to_be32(FW_CMD_LEN16(len16));
+		cmd.u.ctl.nstats_ix =
+			cpu_to_be16(FW_VI_STATS_CMD_IX(ix) |
+				    FW_VI_STATS_CMD_NSTATS(nstats));
+		ret = t4vf_wr_mbox_ns(adapter, &cmd, len, &rpl);
+		if (ret)
+			return ret;
+
+		memcpy(fwsp, &rpl.u.ctl.stat0, sizeof(__be64) * nstats);
+
+		rem -= nstats;
+		fwsp += nstats;
+	}
+
+	/*
+	 * Translate firmware statistics into host native statistics.
+	 */
+	s->tx_bcast_bytes = be64_to_cpu(fwstats.tx_bcast_bytes);
+	s->tx_bcast_frames = be64_to_cpu(fwstats.tx_bcast_frames);
+	s->tx_mcast_bytes = be64_to_cpu(fwstats.tx_mcast_bytes);
+	s->tx_mcast_frames = be64_to_cpu(fwstats.tx_mcast_frames);
+	s->tx_ucast_bytes = be64_to_cpu(fwstats.tx_ucast_bytes);
+	s->tx_ucast_frames = be64_to_cpu(fwstats.tx_ucast_frames);
+	s->tx_drop_frames = be64_to_cpu(fwstats.tx_drop_frames);
+	s->tx_offload_bytes = be64_to_cpu(fwstats.tx_offload_bytes);
+	s->tx_offload_frames = be64_to_cpu(fwstats.tx_offload_frames);
+
+	s->rx_bcast_bytes = be64_to_cpu(fwstats.rx_bcast_bytes);
+	s->rx_bcast_frames = be64_to_cpu(fwstats.rx_bcast_frames);
+	s->rx_mcast_bytes = be64_to_cpu(fwstats.rx_mcast_bytes);
+	s->rx_mcast_frames = be64_to_cpu(fwstats.rx_mcast_frames);
+	s->rx_ucast_bytes = be64_to_cpu(fwstats.rx_ucast_bytes);
+	s->rx_ucast_frames = be64_to_cpu(fwstats.rx_ucast_frames);
+
+	s->rx_err_frames = be64_to_cpu(fwstats.rx_err_frames);
+
+	return 0;
+}
+
+/**
+ *	t4vf_iq_free - free an ingress queue and its free lists
+ *	@adapter: the adapter
+ *	@iqtype: the ingress queue type (FW_IQ_TYPE_FL_INT_CAP, etc.)
+ *	@iqid: ingress queue ID
+ *	@fl0id: FL0 queue ID or 0xffff if no attached FL0
+ *	@fl1id: FL1 queue ID or 0xffff if no attached FL1
+ *
+ *	Frees an ingress queue and its associated free lists, if any.
+ */
+int t4vf_iq_free(struct adapter *adapter, unsigned int iqtype,
+		 unsigned int iqid, unsigned int fl0id, unsigned int fl1id)
+{
+	struct fw_iq_cmd cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_IQ_CMD) |
+				    FW_CMD_REQUEST |
+				    FW_CMD_EXEC);
+	cmd.alloc_to_len16 = cpu_to_be32(FW_IQ_CMD_FREE |
+					 FW_LEN16(cmd));
+	cmd.type_to_iqandstindex =
+		cpu_to_be32(FW_IQ_CMD_TYPE(iqtype));
+
+	cmd.iqid = cpu_to_be16(iqid);
+	cmd.fl0id = cpu_to_be16(fl0id);
+	cmd.fl1id = cpu_to_be16(fl1id);
+	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
+}
+
+/**
+ *	t4vf_eth_eq_free - free an Ethernet egress queue
+ *	@adapter: the adapter
+ *	@eqid: egress queue ID
+ *
+ *	Frees an Ethernet egress queue.
+ */
+int t4vf_eth_eq_free(struct adapter *adapter, unsigned int eqid)
+{
+	struct fw_eq_eth_cmd cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP(FW_EQ_ETH_CMD) |
+				    FW_CMD_REQUEST |
+				    FW_CMD_EXEC);
+	cmd.alloc_to_len16 = cpu_to_be32(FW_EQ_ETH_CMD_FREE |
+					 FW_LEN16(cmd));
+	cmd.eqid_pkd = cpu_to_be32(FW_EQ_ETH_CMD_EQID(eqid));
+	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
+}
+
+/**
+ *	t4vf_handle_fw_rpl - process a firmware reply message
+ *	@adapter: the adapter
+ *	@rpl: start of the firmware message
+ *
+ *	Processes a firmware message, such as link state change messages.
+ */
+int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
+{
+	struct fw_cmd_hdr *cmd_hdr = (struct fw_cmd_hdr *)rpl;
+	u8 opcode = FW_CMD_OP_GET(be32_to_cpu(cmd_hdr->hi));
+
+	switch (opcode) {
+	case FW_PORT_CMD: {
+		/*
+		 * Link/module state change message.
+		 */
+		const struct fw_port_cmd *port_cmd = (void *)rpl;
+		u32 word;
+		int action, port_id, link_ok, speed, fc, pidx;
+
+		/*
+		 * Extract various fields from port status change message.
+		 */
+		action = FW_PORT_CMD_ACTION_GET(
+			be32_to_cpu(port_cmd->action_to_len16));
+		if (action != FW_PORT_ACTION_GET_PORT_INFO) {
+			dev_err(adapter->pdev_dev,
+				"Unknown firmware PORT reply action %x\n",
+				action);
+			break;
+		}
+
+		port_id = FW_PORT_CMD_PORTID_GET(
+			be32_to_cpu(port_cmd->op_to_portid));
+
+		word = be32_to_cpu(port_cmd->u.info.lstatus_to_modtype);
+		link_ok = (word & FW_PORT_CMD_LSTATUS) != 0;
+		speed = 0;
+		fc = 0;
+		if (word & FW_PORT_CMD_RXPAUSE)
+			fc |= PAUSE_RX;
+		if (word & FW_PORT_CMD_TXPAUSE)
+			fc |= PAUSE_TX;
+		if (word & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_100M))
+			speed = SPEED_100;
+		else if (word & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_1G))
+			speed = SPEED_1000;
+		else if (word & FW_PORT_CMD_LSPEED(FW_PORT_CAP_SPEED_10G))
+			speed = SPEED_10000;
+
+		/*
+		 * Scan all of our "ports" (Virtual Interfaces) looking for
+		 * those bound to the physical port which has changed.  If
+		 * our recorded state doesn't match the current state,
+		 * signal that change to the OS code.
+		 */
+		for_each_port(adapter, pidx) {
+			struct port_info *pi = adap2pinfo(adapter, pidx);
+			struct link_config *lc;
+
+			if (pi->port_id != port_id)
+				continue;
+
+			lc = &pi->link_cfg;
+			if (link_ok != lc->link_ok || speed != lc->speed ||
+			    fc != lc->fc) {
+				/* something changed */
+				lc->link_ok = link_ok;
+				lc->speed = speed;
+				lc->fc = fc;
+				t4vf_os_link_changed(adapter, pidx, link_ok);
+			}
+		}
+		break;
+	}
+
+	default:
+		dev_err(adapter->pdev_dev, "Unknown firmware reply %X\n",
+			opcode);
+	}
+	return 0;
+}
