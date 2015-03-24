From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH 1/3] cxgb4: add cxgb4_fcoe.h and macro definitions for FCoE
Date: Tue, 24 Mar 2015 19:14:45 +0530
Message-ID: <53b7c0b7beb85b5f20755d50293f4818476a8659.1427199268.git.varun@chelsio.com>
References: <cover.1427199268.git.varun@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, leedom@chelsio.com,
	anish@chelsio.com, hariprasad@chelsio.com, praveenm@chelsio.com,
	varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <cover.1427199268.git.varun@chelsio.com>
In-Reply-To: <cover.1427199268.git.varun@chelsio.com>
References: <cover.1427199268.git.varun@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds new header file cxgb4_fcoe.h and defines new
macros for FCoE support in cxgb4 driver.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    7 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h |   57 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |   25 ++++++++++
 3 files changed, 89 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 4555634..bf46ca9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -387,6 +387,10 @@ struct sge_rspq;
 
 #include "cxgb4_dcb.h"
 
+#ifdef CONFIG_CHELSIO_T4_FCOE
+#include "cxgb4_fcoe.h"
+#endif /* CONFIG_CHELSIO_T4_FCOE */
+
 struct port_info {
 	struct adapter *adapter;
 	u16    viid;
@@ -406,6 +410,9 @@ struct port_info {
 #ifdef CONFIG_CHELSIO_T4_DCB
 	struct port_dcb_info dcb;     /* Data Center Bridging support */
 #endif
+#ifdef CONFIG_CHELSIO_T4_FCOE
+	struct cxgb_fcoe fcoe;
+#endif /* CONFIG_CHELSIO_T4_FCOE */
 };
 
 struct dentry;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h
new file mode 100644
index 0000000..bf9258a
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h
@@ -0,0 +1,57 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2015 Chelsio Communications, Inc. All rights reserved.
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
+#ifndef __CXGB4_FCOE_H__
+#define __CXGB4_FCOE_H__
+
+#ifdef CONFIG_CHELSIO_T4_FCOE
+
+#define CXGB_FCOE_TXPKT_CSUM_START	28
+#define CXGB_FCOE_TXPKT_CSUM_END	8
+
+/* fcoe flags */
+enum {
+	CXGB_FCOE_ENABLED     = (1 << 0),
+};
+
+struct cxgb_fcoe {
+	u8	flags;
+};
+
+int cxgb_fcoe_enable(struct net_device *);
+int cxgb_fcoe_disable(struct net_device *);
+bool cxgb_fcoe_sof_eof_supported(struct adapter *, struct sk_buff *);
+
+#endif /* CONFIG_CHELSIO_T4_FCOE */
+#endif /* __CXGB4_FCOE_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 0fb975e..30a2f56 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -794,6 +794,14 @@ struct cpl_rx_pkt {
 	__be16 err_vec;
 };
 
+#define RXF_PSH_S    20
+#define RXF_PSH_V(x) ((x) << RXF_PSH_S)
+#define RXF_PSH_F    RXF_PSH_V(1U)
+
+#define RXF_SYN_S    21
+#define RXF_SYN_V(x) ((x) << RXF_SYN_S)
+#define RXF_SYN_F    RXF_SYN_V(1U)
+
 #define RXF_UDP_S    22
 #define RXF_UDP_V(x) ((x) << RXF_UDP_S)
 #define RXF_UDP_F    RXF_UDP_V(1U)
@@ -810,6 +818,18 @@ struct cpl_rx_pkt {
 #define RXF_IP6_V(x) ((x) << RXF_IP6_S)
 #define RXF_IP6_F    RXF_IP6_V(1U)
 
+#define RXF_SYN_COOKIE_S    26
+#define RXF_SYN_COOKIE_V(x) ((x) << RXF_SYN_COOKIE_S)
+#define RXF_SYN_COOKIE_F    RXF_SYN_COOKIE_V(1U)
+
+#define RXF_FCOE_S    26
+#define RXF_FCOE_V(x) ((x) << RXF_FCOE_S)
+#define RXF_FCOE_F    RXF_FCOE_V(1U)
+
+#define RXF_LRO_S    27
+#define RXF_LRO_V(x) ((x) << RXF_LRO_S)
+#define RXF_LRO_F    RXF_LRO_V(1U)
+
 /* rx_pkt.l2info fields */
 #define RX_ETHHDR_LEN_S    0
 #define RX_ETHHDR_LEN_M    0x1F
@@ -846,6 +866,11 @@ struct cpl_rx_pkt {
 #define RX_IPHDR_LEN_V(x) ((x) << RX_IPHDR_LEN_S)
 #define RX_IPHDR_LEN_G(x) (((x) >> RX_IPHDR_LEN_S) & RX_IPHDR_LEN_M)
 
+/* rx_pkt.err_vec fields */
+#define RXERR_CSUM_S    13
+#define RXERR_CSUM_V(x) ((x) << RXERR_CSUM_S)
+#define RXERR_CSUM_F    RXERR_CSUM_V(1U)
+
 struct cpl_trace_pkt {
 	u8 opcode;
 	u8 intf;
-- 
1.7.1

