From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH for-next 1/2] cxgb4: T6 adapter lld support for iw_cxgb4 driver
Date: Wed, 23 Sep 2015 17:19:26 +0530
Message-ID: <1443008967-8942-2-git-send-email-hariprasad@chelsio.com>
References: <1443008967-8942-1-git-send-email-hariprasad@chelsio.com>
Cc: dledford@redhat.com, davem@davemloft.net,
	swise@opengridcomputing.com, leedom@chelsio.com,
	nirranjan@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8533 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754304AbbIWLtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 07:49:12 -0400
In-Reply-To: <1443008967-8942-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h        | 41 +----------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c   | 22 ++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h    |  2 +
 drivers/net/ethernet/chelsio/cxgb4/t4_chip_type.h | 85 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h       | 48 +++++++++++++
 5 files changed, 158 insertions(+), 40 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/t4_chip_type.h

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index fa0c7b5..11045ec 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -48,6 +48,7 @@
 #include <linux/vmalloc.h>
 #include <linux/etherdevice.h>
 #include <asm/io.h>
+#include "t4_chip_type.h"
 #include "cxgb4_uld.h"
 
 #define CH_WARN(adap, fmt, ...) dev_warn(adap->pdev_dev, fmt, ## __VA_ARGS__)
@@ -290,31 +291,6 @@ struct pci_params {
 	unsigned char width;
 };
 
-#define CHELSIO_CHIP_CODE(version, revision) (((version) << 4) | (revision))
-#define CHELSIO_CHIP_FPGA          0x100
-#define CHELSIO_CHIP_VERSION(code) (((code) >> 4) & 0xf)
-#define CHELSIO_CHIP_RELEASE(code) ((code) & 0xf)
-
-#define CHELSIO_T4		0x4
-#define CHELSIO_T5		0x5
-#define CHELSIO_T6		0x6
-
-enum chip_type {
-	T4_A1 = CHELSIO_CHIP_CODE(CHELSIO_T4, 1),
-	T4_A2 = CHELSIO_CHIP_CODE(CHELSIO_T4, 2),
-	T4_FIRST_REV	= T4_A1,
-	T4_LAST_REV	= T4_A2,
-
-	T5_A0 = CHELSIO_CHIP_CODE(CHELSIO_T5, 0),
-	T5_A1 = CHELSIO_CHIP_CODE(CHELSIO_T5, 1),
-	T5_FIRST_REV	= T5_A0,
-	T5_LAST_REV	= T5_A1,
-
-	T6_A0 = CHELSIO_CHIP_CODE(CHELSIO_T6, 0),
-	T6_FIRST_REV    = T6_A0,
-	T6_LAST_REV     = T6_A0,
-};
-
 struct devlog_params {
 	u32 memtype;                    /* which memory (EDC0, EDC1, MC) */
 	u32 start;                      /* start of log in firmware memory */
@@ -905,21 +881,6 @@ static inline int is_offload(const struct adapter *adap)
 	return adap->params.offload;
 }
 
-static inline int is_t6(enum chip_type chip)
-{
-	return CHELSIO_CHIP_VERSION(chip) == CHELSIO_T6;
-}
-
-static inline int is_t5(enum chip_type chip)
-{
-	return CHELSIO_CHIP_VERSION(chip) == CHELSIO_T5;
-}
-
-static inline int is_t4(enum chip_type chip)
-{
-	return CHELSIO_CHIP_VERSION(chip) == CHELSIO_T4;
-}
-
 static inline u32 t4_read_reg(struct adapter *adap, u32 reg_addr)
 {
 	return readl(adap->regs + reg_addr);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f5dcde2..aeeb21f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1936,6 +1936,28 @@ unsigned int cxgb4_best_aligned_mtu(const unsigned short *mtus,
 EXPORT_SYMBOL(cxgb4_best_aligned_mtu);
 
 /**
+ *	cxgb4_tp_smt_idx - Get the Source Mac Table index for this VI
+ *	@chip: chip type
+ *	@viid: VI id of the given port
+ *
+ *	Return the SMT index for this VI.
+ */
+unsigned int cxgb4_tp_smt_idx(enum chip_type chip, unsigned int viid)
+{
+	/* In T4/T5, SMT contains 256 SMAC entries organized in
+	 * 128 rows of 2 entries each.
+	 * In T6, SMT contains 256 SMAC entries in 256 rows.
+	 * TODO: The below code needs to be updated when we add support
+	 * for 256 VFs.
+	 */
+	if (CHELSIO_CHIP_VERSION(chip) <= CHELSIO_T5)
+		return ((viid & 0x7f) << 1);
+	else
+		return (viid & 0x7f);
+}
+EXPORT_SYMBOL(cxgb4_tp_smt_idx);
+
+/**
  *	cxgb4_port_chan - get the HW channel of a port
  *	@dev: the net device for the port
  *
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index c3a8be5..cf711d5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -40,6 +40,7 @@
 #include <linux/skbuff.h>
 #include <linux/inetdevice.h>
 #include <linux/atomic.h>
+#include "cxgb4.h"
 
 /* CPL message priority levels */
 enum {
@@ -290,6 +291,7 @@ int cxgb4_ofld_send(struct net_device *dev, struct sk_buff *skb);
 unsigned int cxgb4_dbfifo_count(const struct net_device *dev, int lpfifo);
 unsigned int cxgb4_port_chan(const struct net_device *dev);
 unsigned int cxgb4_port_viid(const struct net_device *dev);
+unsigned int cxgb4_tp_smt_idx(enum chip_type chip, unsigned int viid);
 unsigned int cxgb4_port_idx(const struct net_device *dev);
 unsigned int cxgb4_best_mtu(const unsigned short *mtus, unsigned short mtu,
 			    unsigned int *idx);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_chip_type.h b/drivers/net/ethernet/chelsio/cxgb4/t4_chip_type.h
new file mode 100644
index 0000000..54b7181
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_chip_type.h
@@ -0,0 +1,85 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2015 Chelsio Communications, Inc. All rights reserved.
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
+#ifndef __T4_CHIP_TYPE_H__
+#define __T4_CHIP_TYPE_H__
+
+#define CHELSIO_T4		0x4
+#define CHELSIO_T5		0x5
+#define CHELSIO_T6		0x6
+
+/* We code the Chelsio T4 Family "Chip Code" as a tuple:
+ *
+ *     (Chip Version, Chip Revision)
+ *
+ * where:
+ *
+ *     Chip Version: is T4, T5, etc.
+ *     Chip Revision: is the FAB "spin" of the Chip Version.
+ */
+#define CHELSIO_CHIP_CODE(version, revision) (((version) << 4) | (revision))
+#define CHELSIO_CHIP_VERSION(code) (((code) >> 4) & 0xf)
+#define CHELSIO_CHIP_RELEASE(code) ((code) & 0xf)
+
+enum chip_type {
+	T4_A1 = CHELSIO_CHIP_CODE(CHELSIO_T4, 1),
+	T4_A2 = CHELSIO_CHIP_CODE(CHELSIO_T4, 2),
+	T4_FIRST_REV	= T4_A1,
+	T4_LAST_REV	= T4_A2,
+
+	T5_A0 = CHELSIO_CHIP_CODE(CHELSIO_T5, 0),
+	T5_A1 = CHELSIO_CHIP_CODE(CHELSIO_T5, 1),
+	T5_FIRST_REV	= T5_A0,
+	T5_LAST_REV	= T5_A1,
+
+	T6_A0 = CHELSIO_CHIP_CODE(CHELSIO_T6, 0),
+	T6_FIRST_REV	= T6_A0,
+	T6_LAST_REV	= T6_A0,
+};
+
+static inline int is_t4(enum chip_type chip)
+{
+	return (CHELSIO_CHIP_VERSION(chip) == CHELSIO_T4);
+}
+
+static inline int is_t5(enum chip_type chip)
+{
+	return (CHELSIO_CHIP_VERSION(chip) == CHELSIO_T5);
+}
+
+static inline int is_t6(enum chip_type chip)
+{
+	return (CHELSIO_CHIP_VERSION(chip) == CHELSIO_T6);
+}
+
+#endif /* __T4_CHIP_TYPE_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index b99144a..a072d34 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -417,6 +417,21 @@ struct cpl_t5_act_open_req {
 	__be64 params;
 };
 
+struct cpl_t6_act_open_req {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 local_port;
+	__be16 peer_port;
+	__be32 local_ip;
+	__be32 peer_ip;
+	__be64 opt0;
+	__be32 rsvd;
+	__be32 opt2;
+	__be64 params;
+	__be32 rsvd2;
+	__be32 opt3;
+};
+
 struct cpl_act_open_req6 {
 	WR_HDR;
 	union opcode_tid ot;
@@ -446,6 +461,23 @@ struct cpl_t5_act_open_req6 {
 	__be64 params;
 };
 
+struct cpl_t6_act_open_req6 {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 local_port;
+	__be16 peer_port;
+	__be64 local_ip_hi;
+	__be64 local_ip_lo;
+	__be64 peer_ip_hi;
+	__be64 peer_ip_lo;
+	__be64 opt0;
+	__be32 rsvd;
+	__be32 opt2;
+	__be64 params;
+	__be32 rsvd2;
+	__be32 opt3;
+};
+
 struct cpl_act_open_rpl {
 	union opcode_tid ot;
 	__be32 atid_status;
@@ -504,6 +536,19 @@ struct cpl_pass_establish {
 #define TCPOPT_MSS_M	0xF
 #define TCPOPT_MSS_G(x)	(((x) >> TCPOPT_MSS_S) & TCPOPT_MSS_M)
 
+#define T6_TCP_HDR_LEN_S   8
+#define T6_TCP_HDR_LEN_V(x) ((x) << T6_TCP_HDR_LEN_S)
+#define T6_TCP_HDR_LEN_G(x) (((x) >> T6_TCP_HDR_LEN_S) & TCP_HDR_LEN_M)
+
+#define T6_IP_HDR_LEN_S    14
+#define T6_IP_HDR_LEN_V(x) ((x) << T6_IP_HDR_LEN_S)
+#define T6_IP_HDR_LEN_G(x) (((x) >> T6_IP_HDR_LEN_S) & IP_HDR_LEN_M)
+
+#define T6_ETH_HDR_LEN_S    24
+#define T6_ETH_HDR_LEN_M    0xFF
+#define T6_ETH_HDR_LEN_V(x) ((x) << T6_ETH_HDR_LEN_S)
+#define T6_ETH_HDR_LEN_G(x) (((x) >> T6_ETH_HDR_LEN_S) & T6_ETH_HDR_LEN_M)
+
 struct cpl_act_establish {
 	union opcode_tid ot;
 	__be32 rsvd;
@@ -833,6 +878,9 @@ struct cpl_rx_pkt {
 	__be16 err_vec;
 };
 
+#define RX_T6_ETHHDR_LEN_M    0xFF
+#define RX_T6_ETHHDR_LEN_G(x) (((x) >> RX_ETHHDR_LEN_S) & RX_T6_ETHHDR_LEN_M)
+
 #define RXF_PSH_S    20
 #define RXF_PSH_V(x) ((x) << RXF_PSH_S)
 #define RXF_PSH_F    RXF_PSH_V(1U)
-- 
2.3.4
