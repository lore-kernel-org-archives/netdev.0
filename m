From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 2/4] net/mlx5_core: Use hardware registers description header file
Date: Tue, 30 Sep 2014 16:02:13 +0300
Message-ID: <1412082135-30229-4-git-send-email-eli@mellanox.com>
References: <1412082135-30229-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:48169 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbaI3NCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 09:02:38 -0400
Received: by mail-we0-f176.google.com with SMTP id p10so3420212wes.35
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 06:02:35 -0700 (PDT)
In-Reply-To: <1412082135-30229-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an auto generated header file that describes hardware registers along with
set of macros that set/get values. The macros do static checks to avoid
overflow, handle endianess, and overall provide a clean way to code commands.

A few commands were removed since they are not supported currently and will be
added when support is available.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c |   36 -
 drivers/net/ethernet/mellanox/mlx5/core/qp.c  |    3 -
 include/linux/mlx5/device.h                   |   74 +
 include/linux/mlx5/driver.h                   |   76 +-
 include/linux/mlx5/mlx5_ifc.h                 | 4464 +++++++++++++++++++++++++
 5 files changed, 4539 insertions(+), 114 deletions(-)
 create mode 100644 include/linux/mlx5/mlx5_ifc.h

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 6eb0f85cf872..3ecef1310bae 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -357,60 +357,24 @@ const char *mlx5_command_str(int command)
 	case MLX5_CMD_OP_2ERR_QP:
 		return "2ERR_QP";
 
-	case MLX5_CMD_OP_RTS2SQD_QP:
-		return "RTS2SQD_QP";
-
-	case MLX5_CMD_OP_SQD2RTS_QP:
-		return "SQD2RTS_QP";
-
 	case MLX5_CMD_OP_2RST_QP:
 		return "2RST_QP";
 
 	case MLX5_CMD_OP_QUERY_QP:
 		return "QUERY_QP";
 
-	case MLX5_CMD_OP_CONF_SQP:
-		return "CONF_SQP";
-
 	case MLX5_CMD_OP_MAD_IFC:
 		return "MAD_IFC";
 
 	case MLX5_CMD_OP_INIT2INIT_QP:
 		return "INIT2INIT_QP";
 
-	case MLX5_CMD_OP_SUSPEND_QP:
-		return "SUSPEND_QP";
-
-	case MLX5_CMD_OP_UNSUSPEND_QP:
-		return "UNSUSPEND_QP";
-
-	case MLX5_CMD_OP_SQD2SQD_QP:
-		return "SQD2SQD_QP";
-
-	case MLX5_CMD_OP_ALLOC_QP_COUNTER_SET:
-		return "ALLOC_QP_COUNTER_SET";
-
-	case MLX5_CMD_OP_DEALLOC_QP_COUNTER_SET:
-		return "DEALLOC_QP_COUNTER_SET";
-
-	case MLX5_CMD_OP_QUERY_QP_COUNTER_SET:
-		return "QUERY_QP_COUNTER_SET";
-
 	case MLX5_CMD_OP_CREATE_PSV:
 		return "CREATE_PSV";
 
 	case MLX5_CMD_OP_DESTROY_PSV:
 		return "DESTROY_PSV";
 
-	case MLX5_CMD_OP_QUERY_PSV:
-		return "QUERY_PSV";
-
-	case MLX5_CMD_OP_QUERY_SIG_RULE_TABLE:
-		return "QUERY_SIG_RULE_TABLE";
-
-	case MLX5_CMD_OP_QUERY_BLOCK_SIZE_TABLE:
-		return "QUERY_BLOCK_SIZE_TABLE";
-
 	case MLX5_CMD_OP_CREATE_SRQ:
 		return "CREATE_SRQ";
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/qp.c b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
index 8145b4668229..415b67ce379e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
@@ -184,13 +184,10 @@ int mlx5_core_qp_modify(struct mlx5_core_dev *dev, enum mlx5_qp_state cur_state,
 			[MLX5_QP_STATE_RST]	= MLX5_CMD_OP_2RST_QP,
 			[MLX5_QP_STATE_ERR]	= MLX5_CMD_OP_2ERR_QP,
 			[MLX5_QP_STATE_RTS]	= MLX5_CMD_OP_RTS2RTS_QP,
-			[MLX5_QP_STATE_SQD]	= MLX5_CMD_OP_RTS2SQD_QP,
 		},
 		[MLX5_QP_STATE_SQD] = {
 			[MLX5_QP_STATE_RST]	= MLX5_CMD_OP_2RST_QP,
 			[MLX5_QP_STATE_ERR]	= MLX5_CMD_OP_2ERR_QP,
-			[MLX5_QP_STATE_RTS]	= MLX5_CMD_OP_SQD2RTS_QP,
-			[MLX5_QP_STATE_SQD]	= MLX5_CMD_OP_SQD2SQD_QP,
 		},
 		[MLX5_QP_STATE_SQER] = {
 			[MLX5_QP_STATE_RST]	= MLX5_CMD_OP_2RST_QP,
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index dce01fd854a8..3db2d4d82ad3 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -44,6 +44,80 @@
 #error Host endianness not defined
 #endif
 
+/* helper macros */
+#define __mlx5_nullp(typ) ((struct mlx5_ifc_##typ##_bits *)0)
+#define __mlx5_bit_sz(typ, fld) sizeof(__mlx5_nullp(typ)->fld)
+#define __mlx5_bit_off(typ, fld) ((unsigned)(unsigned long)(&(__mlx5_nullp(typ)->fld)))
+#define __mlx5_dw_off(typ, fld) (__mlx5_bit_off(typ, fld) / 32)
+#define __mlx5_64_off(typ, fld) (__mlx5_bit_off(typ, fld) / 64)
+#define __mlx5_dw_bit_off(typ, fld) (32 - __mlx5_bit_sz(typ, fld) - (__mlx5_bit_off(typ, fld) & 0x1f))
+#define __mlx5_mask(typ, fld) ((u32)((1ull << __mlx5_bit_sz(typ, fld)) - 1))
+#define __mlx5_dw_mask(typ, fld) (__mlx5_mask(typ, fld) << __mlx5_dw_bit_off(typ, fld))
+#define __mlx5_st_sz_bits(typ) sizeof(struct mlx5_ifc_##typ##_bits)
+
+#define MLX5_FLD_SZ_BYTES(typ, fld) (__mlx5_bit_sz(typ, fld) / 8)
+#define MLX5_ST_SZ_BYTES(typ) (sizeof(struct mlx5_ifc_##typ##_bits) / 8)
+#define MLX5_ST_SZ_DW(typ) (sizeof(struct mlx5_ifc_##typ##_bits) / 32)
+#define MLX5_BYTE_OFF(typ, fld) (__mlx5_bit_off(typ, fld) / 8)
+#define MLX5_ADDR_OF(typ, p, fld) ((char *)(p) + MLX5_BYTE_OFF(typ, fld))
+
+static inline void non_existent_function(void)
+{
+	pr_info("%s\n", __func__);
+}
+
+static inline void non_existent_function_sz_align32(void)
+{
+	pr_info("%s\n", __func__);
+}
+
+static inline void non_existent_function_const_overflow(void)
+{
+	pr_info("%s\n", __func__);
+}
+
+static inline void memcpy_cpu_to_be32(void *dst, void *src, int len)
+{
+	u32 *dst_u32 = (u32 *)dst;
+	int i;
+
+	memcpy(dst, src, len);
+
+	for (i = 0; i < (len >> 2); i++)
+		dst_u32[i] = cpu_to_be32(dst_u32[i]);
+}
+
+/* insert a value to a struct */
+#define MLX5_SET(typ, p, fld, v) do { \
+	if (__mlx5_st_sz_bits(typ) % 32) \
+		non_existent_function_sz_align32();             \
+	*((__be32 *)(p) + __mlx5_dw_off(typ, fld)) = \
+	cpu_to_be32((be32_to_cpu(*((__be32 *)(p) + __mlx5_dw_off(typ, fld))) & \
+		     (~__mlx5_dw_mask(typ, fld))) | (((v) & __mlx5_mask(typ, fld)) \
+		     << __mlx5_dw_bit_off(typ, fld))); \
+} while (0)
+
+#define MLX5_GET(typ, p, fld) ((be32_to_cpu(*((__be32 *)(p) +\
+__mlx5_dw_off(typ, fld))) >> __mlx5_dw_bit_off(typ, fld)) & \
+__mlx5_mask(typ, fld))
+
+#define MLX5_GET_PR(typ, p, fld) ({ \
+	u32 ___t = MLX5_GET(typ, p, fld); \
+	pr_debug(#fld " = 0x%x\n", ___t); \
+	___t; \
+})
+
+#define MLX5_SET64(typ, p, fld, v) do { \
+	if (__mlx5_bit_sz(typ, fld) != 64) \
+		non_existent_function(); \
+	else if (__mlx5_bit_off(typ, fld) % 64) \
+		non_existent_function(); \
+	else \
+		*((__be64 *)(p) + __mlx5_64_off(typ, fld)) = cpu_to_be64(v); \
+} while (0)
+
+#define MLX5_GET64(typ, p, fld) be64_to_cpu(*((__be64 *)(p) + __mlx5_64_off(typ, fld)))
+
 enum {
 	MLX5_MAX_COMMANDS		= 32,
 	MLX5_CMD_DATA_BLOCK_SIZE	= 512,
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 45a2add747e0..6f48dc793b9f 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -44,6 +44,7 @@
 
 #include <linux/mlx5/device.h>
 #include <linux/mlx5/doorbell.h>
+#include <linux/mlx5/mlx5_ifc.h>
 
 enum {
 	MLX5_BOARD_ID_LEN = 64,
@@ -99,81 +100,6 @@ enum {
 };
 
 enum {
-	MLX5_CMD_OP_QUERY_HCA_CAP		= 0x100,
-	MLX5_CMD_OP_QUERY_ADAPTER		= 0x101,
-	MLX5_CMD_OP_INIT_HCA			= 0x102,
-	MLX5_CMD_OP_TEARDOWN_HCA		= 0x103,
-	MLX5_CMD_OP_ENABLE_HCA			= 0x104,
-	MLX5_CMD_OP_DISABLE_HCA			= 0x105,
-	MLX5_CMD_OP_QUERY_PAGES			= 0x107,
-	MLX5_CMD_OP_MANAGE_PAGES		= 0x108,
-	MLX5_CMD_OP_SET_HCA_CAP			= 0x109,
-
-	MLX5_CMD_OP_CREATE_MKEY			= 0x200,
-	MLX5_CMD_OP_QUERY_MKEY			= 0x201,
-	MLX5_CMD_OP_DESTROY_MKEY		= 0x202,
-	MLX5_CMD_OP_QUERY_SPECIAL_CONTEXTS	= 0x203,
-
-	MLX5_CMD_OP_CREATE_EQ			= 0x301,
-	MLX5_CMD_OP_DESTROY_EQ			= 0x302,
-	MLX5_CMD_OP_QUERY_EQ			= 0x303,
-
-	MLX5_CMD_OP_CREATE_CQ			= 0x400,
-	MLX5_CMD_OP_DESTROY_CQ			= 0x401,
-	MLX5_CMD_OP_QUERY_CQ			= 0x402,
-	MLX5_CMD_OP_MODIFY_CQ			= 0x403,
-
-	MLX5_CMD_OP_CREATE_QP			= 0x500,
-	MLX5_CMD_OP_DESTROY_QP			= 0x501,
-	MLX5_CMD_OP_RST2INIT_QP			= 0x502,
-	MLX5_CMD_OP_INIT2RTR_QP			= 0x503,
-	MLX5_CMD_OP_RTR2RTS_QP			= 0x504,
-	MLX5_CMD_OP_RTS2RTS_QP			= 0x505,
-	MLX5_CMD_OP_SQERR2RTS_QP		= 0x506,
-	MLX5_CMD_OP_2ERR_QP			= 0x507,
-	MLX5_CMD_OP_RTS2SQD_QP			= 0x508,
-	MLX5_CMD_OP_SQD2RTS_QP			= 0x509,
-	MLX5_CMD_OP_2RST_QP			= 0x50a,
-	MLX5_CMD_OP_QUERY_QP			= 0x50b,
-	MLX5_CMD_OP_CONF_SQP			= 0x50c,
-	MLX5_CMD_OP_MAD_IFC			= 0x50d,
-	MLX5_CMD_OP_INIT2INIT_QP		= 0x50e,
-	MLX5_CMD_OP_SUSPEND_QP			= 0x50f,
-	MLX5_CMD_OP_UNSUSPEND_QP		= 0x510,
-	MLX5_CMD_OP_SQD2SQD_QP			= 0x511,
-	MLX5_CMD_OP_ALLOC_QP_COUNTER_SET	= 0x512,
-	MLX5_CMD_OP_DEALLOC_QP_COUNTER_SET	= 0x513,
-	MLX5_CMD_OP_QUERY_QP_COUNTER_SET	= 0x514,
-
-	MLX5_CMD_OP_CREATE_PSV			= 0x600,
-	MLX5_CMD_OP_DESTROY_PSV			= 0x601,
-	MLX5_CMD_OP_QUERY_PSV			= 0x602,
-	MLX5_CMD_OP_QUERY_SIG_RULE_TABLE	= 0x603,
-	MLX5_CMD_OP_QUERY_BLOCK_SIZE_TABLE	= 0x604,
-
-	MLX5_CMD_OP_CREATE_SRQ			= 0x700,
-	MLX5_CMD_OP_DESTROY_SRQ			= 0x701,
-	MLX5_CMD_OP_QUERY_SRQ			= 0x702,
-	MLX5_CMD_OP_ARM_RQ			= 0x703,
-	MLX5_CMD_OP_RESIZE_SRQ			= 0x704,
-
-	MLX5_CMD_OP_ALLOC_PD			= 0x800,
-	MLX5_CMD_OP_DEALLOC_PD			= 0x801,
-	MLX5_CMD_OP_ALLOC_UAR			= 0x802,
-	MLX5_CMD_OP_DEALLOC_UAR			= 0x803,
-
-	MLX5_CMD_OP_ATTACH_TO_MCG		= 0x806,
-	MLX5_CMD_OP_DETACH_FROM_MCG		= 0x807,
-
-
-	MLX5_CMD_OP_ALLOC_XRCD			= 0x80e,
-	MLX5_CMD_OP_DEALLOC_XRCD		= 0x80f,
-
-	MLX5_CMD_OP_ACCESS_REG			= 0x805,
-	MLX5_CMD_OP_MAX				= 0x810,
-};
-
-enum {
 	MLX5_REG_PCAP		 = 0x5001,
 	MLX5_REG_PMTU		 = 0x5003,
 	MLX5_REG_PTYS		 = 0x5004,
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
new file mode 100644
index 000000000000..763ab31f54f6
--- /dev/null
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -0,0 +1,4464 @@
+/*
+ * Copyright (c) 2014, Mellanox Technologies inc.  All rights reserved.
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
+/*
+
+   Autogenerated file.
+   Date: 2014-09-30 06:30
+   Source Document Name: Mellanox <Doc Name>
+   Source Document Version: 0.20
+   Generated by adb_to_c.py (EAT.ME Version: 1.0.62)
+*/
+#ifndef MLX5_IFC_H
+#define MLX5_IFC_H
+
+enum {
+	MLX5_EVENT_TYPE_CODING_COMPLETION_EVENTS                   = 0x0,
+	MLX5_EVENT_TYPE_CODING_PATH_MIGRATED_SUCCEEDED             = 0x1,
+	MLX5_EVENT_TYPE_CODING_COMMUNICATION_ESTABLISHED           = 0x2,
+	MLX5_EVENT_TYPE_CODING_SEND_QUEUE_DRAINED                  = 0x3,
+	MLX5_EVENT_TYPE_CODING_SRQ_LAST_WQE_REACHED                = 0x13,
+	MLX5_EVENT_TYPE_CODING_SRQ_LIMIT                           = 0x14,
+	MLX5_EVENT_TYPE_CODING_DCT_ALL_CONNECTIONS_CLOSED          = 0x1c,
+	MLX5_EVENT_TYPE_CODING_DCT_ACCESS_KEY_VIOLATION            = 0x1d,
+	MLX5_EVENT_TYPE_CODING_CQ_ERROR                            = 0x4,
+	MLX5_EVENT_TYPE_CODING_LOCAL_WQ_CATASTROPHIC_ERROR         = 0x5,
+	MLX5_EVENT_TYPE_CODING_PATH_MIGRATION_FAILED               = 0x7,
+	MLX5_EVENT_TYPE_CODING_PAGE_FAULT_EVENT                    = 0xc,
+	MLX5_EVENT_TYPE_CODING_INVALID_REQUEST_LOCAL_WQ_ERROR      = 0x10,
+	MLX5_EVENT_TYPE_CODING_LOCAL_ACCESS_VIOLATION_WQ_ERROR     = 0x11,
+	MLX5_EVENT_TYPE_CODING_LOCAL_SRQ_CATASTROPHIC_ERROR        = 0x12,
+	MLX5_EVENT_TYPE_CODING_INTERNAL_ERROR                      = 0x8,
+	MLX5_EVENT_TYPE_CODING_PORT_STATE_CHANGE                   = 0x9,
+	MLX5_EVENT_TYPE_CODING_GPIO_EVENT                          = 0x15,
+	MLX5_EVENT_TYPE_CODING_REMOTE_CONFIGURATION_PROTOCOL_EVENT = 0x19,
+	MLX5_EVENT_TYPE_CODING_DOORBELL_BLUEFLAME_CONGESTION_EVENT = 0x1a,
+	MLX5_EVENT_TYPE_CODING_STALL_VL_EVENT                      = 0x1b,
+	MLX5_EVENT_TYPE_CODING_DROPPED_PACKET_LOGGED_EVENT         = 0x1f,
+	MLX5_EVENT_TYPE_CODING_COMMAND_INTERFACE_COMPLETION        = 0xa,
+	MLX5_EVENT_TYPE_CODING_PAGE_REQUEST                        = 0xb
+};
+
+enum {
+	MLX5_CMD_OP_QUERY_HCA_CAP                 = 0x100,
+	MLX5_CMD_OP_QUERY_ADAPTER                 = 0x101,
+	MLX5_CMD_OP_INIT_HCA                      = 0x102,
+	MLX5_CMD_OP_TEARDOWN_HCA                  = 0x103,
+	MLX5_CMD_OP_ENABLE_HCA                    = 0x104,
+	MLX5_CMD_OP_DISABLE_HCA                   = 0x105,
+	MLX5_CMD_OP_QUERY_PAGES                   = 0x107,
+	MLX5_CMD_OP_MANAGE_PAGES                  = 0x108,
+	MLX5_CMD_OP_SET_HCA_CAP                   = 0x109,
+	MLX5_CMD_OP_CREATE_MKEY                   = 0x200,
+	MLX5_CMD_OP_QUERY_MKEY                    = 0x201,
+	MLX5_CMD_OP_DESTROY_MKEY                  = 0x202,
+	MLX5_CMD_OP_QUERY_SPECIAL_CONTEXTS        = 0x203,
+	MLX5_CMD_OP_PAGE_FAULT_RESUME             = 0x204,
+	MLX5_CMD_OP_CREATE_EQ                     = 0x301,
+	MLX5_CMD_OP_DESTROY_EQ                    = 0x302,
+	MLX5_CMD_OP_QUERY_EQ                      = 0x303,
+	MLX5_CMD_OP_GEN_EQE                       = 0x304,
+	MLX5_CMD_OP_CREATE_CQ                     = 0x400,
+	MLX5_CMD_OP_DESTROY_CQ                    = 0x401,
+	MLX5_CMD_OP_QUERY_CQ                      = 0x402,
+	MLX5_CMD_OP_MODIFY_CQ                     = 0x403,
+	MLX5_CMD_OP_CREATE_QP                     = 0x500,
+	MLX5_CMD_OP_DESTROY_QP                    = 0x501,
+	MLX5_CMD_OP_RST2INIT_QP                   = 0x502,
+	MLX5_CMD_OP_INIT2RTR_QP                   = 0x503,
+	MLX5_CMD_OP_RTR2RTS_QP                    = 0x504,
+	MLX5_CMD_OP_RTS2RTS_QP                    = 0x505,
+	MLX5_CMD_OP_SQERR2RTS_QP                  = 0x506,
+	MLX5_CMD_OP_2ERR_QP                       = 0x507,
+	MLX5_CMD_OP_2RST_QP                       = 0x50a,
+	MLX5_CMD_OP_QUERY_QP                      = 0x50b,
+	MLX5_CMD_OP_INIT2INIT_QP                  = 0x50e,
+	MLX5_CMD_OP_CREATE_PSV                    = 0x600,
+	MLX5_CMD_OP_DESTROY_PSV                   = 0x601,
+	MLX5_CMD_OP_CREATE_SRQ                    = 0x700,
+	MLX5_CMD_OP_DESTROY_SRQ                   = 0x701,
+	MLX5_CMD_OP_QUERY_SRQ                     = 0x702,
+	MLX5_CMD_OP_ARM_RQ                        = 0x703,
+	MLX5_CMD_OP_RESIZE_SRQ                    = 0x704,
+	MLX5_CMD_OP_CREATE_DCT                    = 0x710,
+	MLX5_CMD_OP_DESTROY_DCT                   = 0x711,
+	MLX5_CMD_OP_DRAIN_DCT                     = 0x712,
+	MLX5_CMD_OP_QUERY_DCT                     = 0x713,
+	MLX5_CMD_OP_ARM_DCT_FOR_KEY_VIOLATION     = 0x714,
+	MLX5_CMD_OP_QUERY_VPORT_STATE             = 0x750,
+	MLX5_CMD_OP_MODIFY_VPORT_STATE            = 0x751,
+	MLX5_CMD_OP_QUERY_ESW_VPORT_CONTEXT       = 0x752,
+	MLX5_CMD_OP_MODIFY_ESW_VPORT_CONTEXT      = 0x753,
+	MLX5_CMD_OP_QUERY_NIC_VPORT_CONTEXT       = 0x754,
+	MLX5_CMD_OP_MODIFY_NIC_VPORT_CONTEXT      = 0x755,
+	MLX5_CMD_OP_QUERY_RCOE_ADDRESS            = 0x760,
+	MLX5_CMD_OP_SET_ROCE_ADDRESS              = 0x761,
+	MLX5_CMD_OP_QUERY_VPORT_COUNTER           = 0x770,
+	MLX5_CMD_OP_ALLOC_Q_COUNTER               = 0x771,
+	MLX5_CMD_OP_DEALLOC_Q_COUNTER             = 0x772,
+	MLX5_CMD_OP_QUERY_Q_COUNTER               = 0x773,
+	MLX5_CMD_OP_ALLOC_PD                      = 0x800,
+	MLX5_CMD_OP_DEALLOC_PD                    = 0x801,
+	MLX5_CMD_OP_ALLOC_UAR                     = 0x802,
+	MLX5_CMD_OP_DEALLOC_UAR                   = 0x803,
+	MLX5_CMD_OP_CONFIG_INT_MODERATION         = 0x804,
+	MLX5_CMD_OP_ACCESS_REG                    = 0x805,
+	MLX5_CMD_OP_ATTACH_TO_MCG                 = 0x806,
+	MLX5_CMD_OP_DETACH_FROM_MCG               = 0x807,
+	MLX5_CMD_OP_GET_DROPPED_PACKET_LOG        = 0x80a,
+	MLX5_CMD_OP_MAD_IFC                       = 0x50d,
+	MLX5_CMD_OP_QUERY_MAD_DEMUX               = 0x80b,
+	MLX5_CMD_OP_SET_MAD_DEMUX                 = 0x80c,
+	MLX5_CMD_OP_NOP                           = 0x80d,
+	MLX5_CMD_OP_ALLOC_XRCD                    = 0x80e,
+	MLX5_CMD_OP_DEALLOC_XRCD                  = 0x80f,
+	MLX5_CMD_OP_SET_BURST_SIZE                = 0x812,
+	MLX5_CMD_OP_QUERY_BURST_SZIE              = 0x813,
+	MLX5_CMD_OP_ACTIVATE_TRACER               = 0x814,
+	MLX5_CMD_OP_DEACTIVATE_TRACER             = 0x815,
+	MLX5_CMD_OP_CREATE_SNIFFER_RULE           = 0x820,
+	MLX5_CMD_OP_DESTROY_SNIFFER_RULE          = 0x821,
+	MLX5_CMD_OP_QUERY_CONG_PARAMS             = 0x822,
+	MLX5_CMD_OP_MODIFY_CONG_PARAMS            = 0x823,
+	MLX5_CMD_OP_QUERY_CONG_STATISTICS         = 0x824,
+	MLX5_CMD_OP_CREATE_TIR                    = 0x900,
+	MLX5_CMD_OP_MODIFY_TIR                    = 0x901,
+	MLX5_CMD_OP_DESTROY_TIR                   = 0x902,
+	MLX5_CMD_OP_QUERY_TIR                     = 0x903,
+	MLX5_CMD_OP_CREATE_TIS                    = 0x912,
+	MLX5_CMD_OP_MODIFY_TIS                    = 0x913,
+	MLX5_CMD_OP_DESTROY_TIS                   = 0x914,
+	MLX5_CMD_OP_QUERY_TIS                     = 0x915,
+	MLX5_CMD_OP_CREATE_SQ                     = 0x904,
+	MLX5_CMD_OP_MODIFY_SQ                     = 0x905,
+	MLX5_CMD_OP_DESTROY_SQ                    = 0x906,
+	MLX5_CMD_OP_QUERY_SQ                      = 0x907,
+	MLX5_CMD_OP_CREATE_RQ                     = 0x908,
+	MLX5_CMD_OP_MODIFY_RQ                     = 0x909,
+	MLX5_CMD_OP_DESTROY_RQ                    = 0x90a,
+	MLX5_CMD_OP_QUERY_RQ                      = 0x90b,
+	MLX5_CMD_OP_CREATE_RMP                    = 0x90c,
+	MLX5_CMD_OP_MODIFY_RMP                    = 0x90d,
+	MLX5_CMD_OP_DESTROY_RMP                   = 0x90e,
+	MLX5_CMD_OP_QUERY_RMP                     = 0x90f,
+	MLX5_CMD_OP_SET_FLOW_TABLE_ENTRY          = 0x910,
+	MLX5_CMD_OP_QUERY_FLOW_TABLE_ENTRY        = 0x911,
+	MLX5_CMD_OP_MAX				  = 0x911
+};
+
+struct mlx5_ifc_cmd_pas_bits {
+	u8         pa_h[0x20];
+
+	u8         pa_l[0x17];
+	u8         reserved_0[0x9];
+};
+
+struct mlx5_ifc_uint64_bits {
+	u8         hi[0x20];
+
+	u8         lo[0x20];
+};
+
+struct mlx5_ifc_ads_bits {
+	u8         fl[0x1];
+	u8         free_ar[0x1];
+	u8         reserved_0[0xe];
+	u8         pkey_index[0x10];
+
+	u8         reserved_1[0x8];
+	u8         grh[0x1];
+	u8         mlid[0x7];
+	u8         rlid[0x10];
+
+	u8         ack_timeout[0x5];
+	u8         reserved_2[0x3];
+	u8         src_addr_index[0x8];
+	u8         reserved_3[0x4];
+	u8         stat_rate[0x4];
+	u8         hop_limit[0x8];
+
+	u8         reserved_4[0x4];
+	u8         tclass[0x8];
+	u8         flow_label[0x14];
+
+	u8         rgid_rip[16][0x8];
+
+	u8         reserved_5[0x4];
+	u8         f_dscp[0x1];
+	u8         f_ecn[0x1];
+	u8         reserved_6[0x1];
+	u8         f_eth_prio[0x1];
+	u8         ecn[0x2];
+	u8         dscp[0x6];
+	u8         udp_sport[0x10];
+
+	u8         dei_cfi[0x1];
+	u8         eth_prio[0x3];
+	u8         sl[0x4];
+	u8         port[0x8];
+	u8         rmac[6][0x8];
+};
+
+struct mlx5_ifc_rq_num_bits {
+	u8         reserved_0[0x8];
+	u8         rq_num[0x18];
+};
+
+enum {
+	MLX5_RSS_HASH_SELECTOR_IP_HASH_SIP  = 0x1,
+	MLX5_RSS_HASH_SELECTOR_IP_HASH_DIP  = 0x2,
+};
+
+enum {
+	MLX5_RSS_HASH_SELECTOR_TCP_IP_HASH_SIP       = 0x1,
+	MLX5_RSS_HASH_SELECTOR_TCP_IP_HASH_DIP       = 0x2,
+	MLX5_RSS_HASH_SELECTOR_TCP_IP_HASH_L4_SPORT  = 0x8,
+	MLX5_RSS_HASH_SELECTOR_TCP_IP_HASH_L4_DPORT  = 0x10,
+};
+
+enum {
+	MLX5_RSS_HASH_SELECTOR_UDP_IP_HASH_SIP       = 0x1,
+	MLX5_RSS_HASH_SELECTOR_UDP_IP_HASH_DIP       = 0x2,
+	MLX5_RSS_HASH_SELECTOR_UDP_IP_HASH_L4_SPORT  = 0x8,
+	MLX5_RSS_HASH_SELECTOR_UDP_IP_HASH_L4_DPORT  = 0x10,
+};
+
+enum {
+	MLX5_RSS_HASH_SELECTOR_IPSEC_HASH_SIP    = 0x1,
+	MLX5_RSS_HASH_SELECTOR_IPSEC_HASH_DIP    = 0x2,
+	MLX5_RSS_HASH_SELECTOR_IPSEC_HASH_IPSEC  = 0x4,
+};
+
+struct mlx5_ifc_rss_hash_selector_bits {
+	u8         ip[0x10];
+	u8         tcp_ip[0x10];
+
+	u8         udp_ip[0x10];
+	u8         ipsec[0x10];
+};
+
+enum {
+	MLX5_WQ_TYPE_LINKED_LIST        = 0x0,
+	MLX5_WQ_TYPE_CYCLIC             = 0x1,
+	MLX5_WQ_TYPE_STRQ               = 0x2,
+};
+
+enum {
+	MLX5_WQ_END_PAD_MODE_NONE               = 0x0,
+	MLX5_WQ_END_PAD_MODE_ALIGN              = 0x1,
+};
+
+struct mlx5_ifc_wq_bits {
+	u8         wq_type[0x4];
+	u8         wq_signature[0x1];
+	u8         end_padding_mode[0x2];
+	u8         cd_slave[0x1];
+	u8         reserved_0[0x3];
+	u8         log_wq_pg_sz[0x5];
+	u8         reserved_1[0x4];
+	u8         log_wq_stride[0x4];
+	u8         reserved_2[0x3];
+	u8         log_wq_size[0x5];
+
+	u8         hds_skip_first_sge[0x1];
+	u8         log2_hds_buf_size[0x3];
+	u8         reserved_3[0x7];
+	u8         page_offset[0x5];
+	u8         lwm[0x10];
+
+	u8         reserved_4[0x8];
+	u8         pd[0x18];
+
+	u8         reserved_5[0x8];
+	u8         uar_page[0x18];
+
+	u8         dbr_addr[8][0x8];
+
+	u8         hw_counter[0x20];
+
+	u8         sw_counter[0x20];
+
+	u8         reserved_6[0x80];
+
+	struct mlx5_ifc_cmd_pas_bits pas[0];
+};
+
+struct mlx5_ifc_allowed_address_context_bits {
+	u8         reserved_0[0x4];
+	u8         vlan[0xc];
+	u8         mac_addr[6][0x8];
+
+	u8         reserved_1[0x4];
+	u8         vlan_mask[0xc];
+	u8         mac_addr_mask[6][0x8];
+};
+
+struct mlx5_ifc_qpc_bits {
+	u8         state[0x4];
+	u8         reserved_0[0x4];
+	u8         st[0x8];
+	u8         reserved_1[0x3];
+	u8         pm_state[0x2];
+	u8         reserved_2[0x7];
+	u8         end_padding_mode[0x2];
+	u8         reserved_3[0x2];
+
+	u8         wq_signature[0x1];
+	u8         block_lb_mc[0x1];
+	u8         atomic_like_write_en[0x1];
+	u8         latency_sensitive[0x1];
+	u8         reserved_4[0x4];
+	u8         pd[0x18];
+
+	u8         mtu[0x3];
+	u8         log_msg_max[0x5];
+	u8         reserved_5[0x1];
+	u8         log_rq_size[0x4];
+	u8         log_rq_stride[0x3];
+	u8         no_sq[0x1];
+	u8         log_sq_size[0x4];
+	u8         reserved_6[0x1];
+	u8         log_strq_size[0x5];
+	u8         rlky[0x1];
+	u8         reserved_7[0x4];
+
+	u8         counter_set_id[0x8];
+	u8         uar_page[0x18];
+
+	u8         reserved_8[0x20];
+
+	u8         reserved_9[0x3];
+	u8         log_page_size[0x5];
+	u8         remote_qpn[0x18];
+
+	struct mlx5_ifc_ads_bits primary_address_path;
+
+	struct mlx5_ifc_ads_bits secondary_address_path;
+
+	u8         log_ack_req_freq[0x4];
+	u8         reserved_10[0x4];
+	u8         log_sra_max[0x3];
+	u8         reserved_11[0x2];
+	u8         retry_count[0x3];
+	u8         rnr_retry[0x3];
+	u8         reserved_12[0x1];
+	u8         fre[0x1];
+	u8         cur_rnr_retry[0x3];
+	u8         cur_retry_count[0x3];
+	u8         reserved_13[0x5];
+
+	u8         reserved_14[0x20];
+
+	u8         reserved_15[0x8];
+	u8         next_send_psn[0x18];
+
+	u8         reserved_16[0x8];
+	u8         cqn_snd[0x18];
+
+	u8         reserved_17[0x40];
+
+	u8         reserved_18[0x8];
+	u8         last_acked_psn[0x18];
+
+	u8         reserved_19[0x8];
+	u8         ssn[0x18];
+
+	u8         reserved_20[0x8];
+	u8         log_rra_max[0x3];
+	u8         reserved_21[0x1];
+	u8         atomic_mode[0x4];
+	u8         rre[0x1];
+	u8         rwe[0x1];
+	u8         rae[0x1];
+	u8         reserved_22[0x1];
+	u8         page_offset[0x6];
+	u8         reserved_23[0x3];
+	u8         cd_slave_receive[0x1];
+	u8         cd_slave_send[0x1];
+	u8         cd_master[0x1];
+
+	u8         reserved_24[0x3];
+	u8         min_rnr_nak[0x5];
+	u8         next_rcv_psn[0x18];
+
+	u8         reserved_25[0x8];
+	u8         xrcd[0x18];
+
+	u8         reserved_26[0x8];
+	u8         cqn_rcv[0x18];
+
+	u8         dbr_adr[0x40];
+
+	u8         q_key[0x20];
+
+	u8         reserved_27[0x5];
+	u8         rq_type[0x3];
+	u8         srqn[0x18];
+
+	u8         reserved_28[0x8];
+	u8         rmsn[0x18];
+
+	u8         hw_sq_wqebb_counter[0x10];
+	u8         sw_sq_wqebb_counter[0x10];
+
+	u8         hw_rcyclic_byte_counter[2][0x8];
+	u8         hw_rq_counter_hw_rcyclic_byte_counter[2][0x8];
+
+	u8         sw_rcyclic_byte_counter[2][0x8];
+	u8         sw_rq_counter_sw_rcyclic_byte_counter[2][0x8];
+
+	u8         reserved_29[0x20];
+
+	u8         reserved_30[0xf];
+	u8         cgs[0x1];
+	u8         cs_req[0x8];
+	u8         cs_res[0x8];
+
+	u8         dc_access_key[0x40];
+
+	u8         reserved_31[0xc0];
+};
+
+struct mlx5_ifc_roce_addr_layout_bits {
+	u8         source_l3_address[16][0x8];
+
+	u8         reserved_0[0x3];
+	u8         vlan_valid[0x1];
+	u8         vlan_id[0xc];
+	u8         source_mac[6][0x8];
+
+	u8         reserved_1[0x14];
+	u8         roce_l3_type[0x4];
+	u8         roce_version[0x8];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_cmd_hca_cap_bits {
+	u8         reserved_0[0x80];
+
+	u8         log_max_srq_sz[0x8];
+	u8         log_max_qp_sz[0x8];
+	u8         reserved_1[0xb];
+	u8         log_max_qp[0x5];
+
+	u8         log_max_strq_sz[0x8];
+	u8         reserved_2[0x3];
+	u8         log_max_srqs[0x5];
+	u8         reserved_3[0x10];
+
+	u8         reserved_4[0x8];
+	u8         log_max_cq_sz[0x8];
+	u8         reserved_5[0xb];
+	u8         log_max_cq[0x5];
+
+	u8         log_max_eq_sz[0x8];
+	u8         reserved_6[0x2];
+	u8         log_max_mkey[0x6];
+	u8         reserved_7[0xc];
+	u8         log_max_eq[0x4];
+
+	u8         max_indirection[0x8];
+	u8         reserved_8[0x1];
+	u8         log_max_mrw_sz[0x7];
+	u8         reserved_9[0x2];
+	u8         log_max_bsf_list_size[0x6];
+	u8         reserved_10[0x2];
+	u8         log_max_klm_list_size[0x6];
+
+	u8         reserved_11[0xa];
+	u8         log_max_ra_req_dc[0x6];
+	u8         reserved_12[0xa];
+	u8         log_max_ra_res_dc[0x6];
+
+	u8         reserved_13[0xa];
+	u8         log_max_ra_req_qp[0x6];
+	u8         reserved_14[0xa];
+	u8         log_max_ra_res_qp[0x6];
+
+	u8         pad_cap[0x1];
+	u8         cc_query_allowed[0x1];
+	u8         cc_modify_allowed[0x1];
+	u8         reserved_15[0x1d];
+
+	u8         reserved_16[0x6];
+	u8         max_qp_cnt[0xa];
+	u8         pkey_table_size[0x10];
+
+	u8         eswitch_owner[0x1];
+	u8         reserved_17[0xa];
+	u8         local_ca_ack_delay[0x5];
+	u8         reserved_18[0x8];
+	u8         num_ports[0x8];
+
+	u8         reserved_19[0x3];
+	u8         log_max_msg[0x5];
+	u8         reserved_20[0x18];
+
+	u8         stat_rate_support[0x10];
+	u8         reserved_21[0x10];
+
+	u8         reserved_22[0x10];
+	u8         cmdif_checksum[0x2];
+	u8         sigerr_cqe[0x1];
+	u8         reserved_23[0x1];
+	u8         wq_signature[0x1];
+	u8         sctr_data_cqe[0x1];
+	u8         reserved_24[0x1];
+	u8         sho[0x1];
+	u8         tph[0x1];
+	u8         rf[0x1];
+	u8         dc[0x1];
+	u8         reserved_25[0x2];
+	u8         roce[0x1];
+	u8         atomic[0x1];
+	u8         rsz_srq[0x1];
+
+	u8         cq_oi[0x1];
+	u8         cq_resize[0x1];
+	u8         cq_moderation[0x1];
+	u8         sniffer_rule_flow[0x1];
+	u8         sniffer_rule_vport[0x1];
+	u8         sniffer_rule_phy[0x1];
+	u8         reserved_26[0x1];
+	u8         pg[0x1];
+	u8         block_lb_mc[0x1];
+	u8         reserved_27[0x3];
+	u8         cd[0x1];
+	u8         reserved_28[0x1];
+	u8         apm[0x1];
+	u8         reserved_29[0x7];
+	u8         qkv[0x1];
+	u8         pkv[0x1];
+	u8         reserved_30[0x4];
+	u8         xrc[0x1];
+	u8         ud[0x1];
+	u8         uc[0x1];
+	u8         rc[0x1];
+
+	u8         reserved_31[0xa];
+	u8         uar_sz[0x6];
+	u8         reserved_32[0x8];
+	u8         log_pg_sz[0x8];
+
+	u8         bf[0x1];
+	u8         reserved_33[0xa];
+	u8         log_bf_reg_size[0x5];
+	u8         reserved_34[0x10];
+
+	u8         reserved_35[0x10];
+	u8         max_wqe_sz_sq[0x10];
+
+	u8         reserved_36[0x10];
+	u8         max_wqe_sz_rq[0x10];
+
+	u8         reserved_37[0x10];
+	u8         max_wqe_sz_sq_dc[0x10];
+
+	u8         reserved_38[0x7];
+	u8         max_qp_mcg[0x19];
+
+	u8         reserved_39[0x18];
+	u8         log_max_mcg[0x8];
+
+	u8         reserved_40[0xb];
+	u8         log_max_pd[0x5];
+	u8         reserved_41[0xb];
+	u8         log_max_xrcd[0x5];
+
+	u8         reserved_42[0x20];
+
+	u8         reserved_43[0x3];
+	u8         log_max_rq[0x5];
+	u8         reserved_44[0x3];
+	u8         log_max_sq[0x5];
+	u8         reserved_45[0x3];
+	u8         log_max_tir[0x5];
+	u8         reserved_46[0x3];
+	u8         log_max_tis[0x5];
+
+	u8         reserved_47[0x13];
+	u8         log_max_rq_per_tir[0x5];
+	u8         reserved_48[0x3];
+	u8         log_max_tis_per_sq[0x5];
+
+	u8         reserved_49[0xe0];
+
+	u8         reserved_50[0x10];
+	u8         log_uar_page_sz[0x10];
+
+	u8         reserved_51[0x100];
+
+	u8         reserved_52[0x1f];
+	u8         cqe_zip[0x1];
+
+	u8         cqe_zip_timeout[0x10];
+	u8         cqe_zip_max_num[0x10];
+
+	u8         reserved_53[0x220];
+};
+
+enum {
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_OUTER_SEC_PRIO_PRESENT         = 0x1b,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_OUTER_SEC_CFI_PRESENT          = 0x1a,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_OUTER_SEC_VID_PRESENT          = 0x19,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_INNER_SEC_PRIO_PRESENT         = 0x18,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_INNER_SEC_CFI_PRESENT          = 0x17,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_INNER_SEC_VID_PRESENT          = 0x16,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_OUTER_SEC_VLAN_PRESENT         = 0x15,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_INNER_SEC_VLAN_PRESENT         = 0x14,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_GRE_PROTO_PRESENT              = 0x10,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_GRE_KEY_H_PRESENT              = 0xf,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_GRE_KEY_L_PRESENT              = 0xe,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_VXLAN_VNI_PRESENT              = 0xd,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_OUTER_IPV6_FLOW_LABEL_PRESENT  = 0x8,
+	MLX5_FLOW_TABLE_ENTRY_SET_MISC_FIELDS_VALID_BITS_INNER_IPV6_FLOW_LABEL_PRESENT  = 0x7,
+};
+
+struct mlx5_ifc_flow_table_entry_set_misc_fields_bits {
+	u8         valid_bits[0x20];
+
+	u8         reserved_0[0x20];
+
+	u8         outer_second_prio[0x3];
+	u8         outer_second_cfi[0x1];
+	u8         outer_second_vid[0xc];
+	u8         inner_second_prio[0x3];
+	u8         inner_second_cfi[0x1];
+	u8         inner_second_vid[0xc];
+
+	u8         outer_second_vlan_tag[0x1];
+	u8         inner_second_vlan_tag[0x1];
+	u8         reserved_1[0xe];
+	u8         gre_protcol[0x10];
+
+	u8         gre_key_h[0x18];
+	u8         gre_key_l[0x8];
+
+	u8         vxlan_vni[0x18];
+	u8         reserved_2[0x8];
+
+	u8         reserved_3[0x20];
+
+	u8         reserved_4[0xc];
+	u8         outer_ipv6_flow_label[0x14];
+
+	u8         reserved_5[0xc];
+	u8         inner_ipv6_flow_label[0x14];
+
+	u8         reserved_6[0xe0];
+};
+
+enum {
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_SMAC_PRESENT           = 0x18,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_ETHER_TYPE_PRESENT     = 0x17,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_DMAC_PRESENT           = 0x16,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_FIRST_PRIO_PRESENT     = 0x15,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_FIRST_CFI_PRESENT      = 0x14,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_FIRST_VID_PRESENT      = 0x13,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_IP_PROROTOCOL_PRESENT  = 0x12,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_TCLASS_PRESENT         = 0x11,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_VLAN_TAG_PRESENT       = 0x10,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_MCAST_PRESENT          = 0xf,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_FRAG_PRESENT           = 0xe,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_TCP_FLAGS_8_PRESENT    = 0xc,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_TCP_FLAGS_7_PRESENT    = 0xb,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_TCP_FLAGS_6_PRESENT    = 0xa,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_TCP_FLAGS_5_PRESENT    = 0x9,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_TCP_FLAGS_4_PRESENT    = 0x8,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_TCP_FLAGS_3_PRESENT    = 0x7,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_TCP_FLAGS_2_PRESENT    = 0x6,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_TCP_FLAGS_1_PRESENT    = 0x5,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_TCP_FLAGS_0_PRESENT    = 0x4,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_L4_SPORT_PRESENT       = 0x3,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_L4_DPORT_PRESENT       = 0x2,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_SRC_IP_PRESENT         = 0x1,
+	MLX5_FLOW_TABLE_ENTRY_SET_BASE_LAYER2_4_VALID_BITS_DST_IP_PRESENT         = 0x0,
+};
+
+struct mlx5_ifc_flow_table_entry_set_base_layer2_4_bits {
+	u8         valid_bits[0x20];
+
+	u8         reserved_0[0x20];
+
+	u8         smac[6][0x8];
+
+	u8         ether_type[0x10];
+
+	u8         dmac[6][0x8];
+
+	u8         first_prio[0x3];
+	u8         first_cfi[0x1];
+	u8         first_vid[0xc];
+
+	u8         ip_protocol[0x8];
+	u8         tclass[0x8];
+	u8         vlan_tag[0x1];
+	u8         mcast[0x1];
+	u8         frag[0x1];
+	u8         reserved_1[0x4];
+	u8         tcp_flags[0x9];
+
+	u8         l4_sport[0x10];
+	u8         l4_dport[0x10];
+
+	u8         src_ip[16][0x8];
+
+	u8         dst_ip[16][0x8];
+};
+
+struct mlx5_ifc_traffic_counter_bits {
+	u8         packets[8][0x8];
+
+	u8         octets[8][0x8];
+};
+
+enum {
+	MLX5_TISC_STATE_RDY  = 0x1,
+	MLX5_TISC_STATE_TSD  = 0x2,
+};
+
+struct mlx5_ifc_tisc_bits {
+	u8         reserved_0[0x8];
+	u8         state[0x4];
+	u8         prio[0x4];
+	u8         reserved_1[0x10];
+
+	u8         reserved_2[0x4e0];
+};
+
+enum {
+	MLX5_TIRC_DISP_TYPE_TIR_RCV_DISP_ALL     = 0x0,
+	MLX5_TIRC_DISP_TYPE_TIR_RCV_DISP_SINGLE  = 0x1,
+};
+
+enum {
+	MLX5_TIRC_LRO_ENABLE_MASK_IPV4_LRO  = 0x1,
+	MLX5_TIRC_LRO_ENABLE_MASK_IPV6_LRO  = 0x2,
+};
+
+enum {
+	MLX5_TIRC_RX_HASH_FN_HASH_NONE      = 0x0,
+	MLX5_TIRC_RX_HASH_FN_HASH_XOR       = 0x1,
+	MLX5_TIRC_RX_HASH_FN_HASH_TOEPLITZ  = 0x2,
+};
+
+struct mlx5_ifc_tirc_bits {
+	u8         reserved_0[0x20];
+
+	u8         disp_type[0x4];
+	u8         reserved_1[0x1c];
+
+	u8         reserved_2[0x40];
+
+	u8         lro_timeout_period_usecs[0x4];
+	u8         lro_enable_mask[0x4];
+	u8         reserved_3[0x10];
+	u8         lro_max_ip_payload_size[0x8];
+
+	u8         reserved_4[0x20];
+
+	u8         reserved_5[0x10];
+	u8         rq_lst_sz[0x10];
+
+	u8         reserved_6[0x20];
+
+	u8         rx_hash_symmetric[0x1];
+	u8         rx_hash_inner[0x1];
+	u8         reserved_7[0x6];
+	u8         rx_hash_default_rqn[0x18];
+
+	u8         rx_hash_fn[0x4];
+	u8         reserved_8[0x1c];
+
+	u8         rx_hash_toeplitz_key[40][0x8];
+
+	struct mlx5_ifc_rss_hash_selector_bits rx_hash_field_selector_ipv4;
+
+	struct mlx5_ifc_rss_hash_selector_bits rx_hash_field_selector_ipv6;
+
+	u8         reserved_9[0x480];
+
+	struct mlx5_ifc_rq_num_bits rq_num[0];
+};
+
+struct mlx5_ifc_srqc_bits {
+	u8         state[0x4];
+	u8         log_srq_size[0x4];
+	u8         reserved_0[0x18];
+
+	u8         wq_signature[0x1];
+	u8         cont_srq[0x1];
+	u8         reserved_1[0x1];
+	u8         rlky[0x1];
+	u8         reserved_2[0x1];
+	u8         log_rq_stride[0x3];
+	u8         xrcd[0x18];
+
+	u8         page_offset[0x6];
+	u8         reserved_3[0x2];
+	u8         cqn[0x18];
+
+	u8         reserved_4[0x20];
+
+	u8         reserved_5[0x2];
+	u8         log_page_size[0x6];
+	u8         reserved_6[0x18];
+
+	u8         reserved_7[0x20];
+
+	u8         reserved_8[0x8];
+	u8         pd[0x18];
+
+	u8         lwm[0x10];
+	u8         wqe_cnt[0x10];
+
+	u8         reserved_9[0x40];
+
+	u8         db_record_addr_h[0x20];
+
+	u8         db_record_addr_l[0x1e];
+	u8         reserved_10[0x2];
+
+	u8         reserved_11[0x80];
+};
+
+enum {
+	MLX5_SQC_STATE_RDY  = 0x1,
+	MLX5_SQC_STATE_ERR  = 0x3,
+};
+
+struct mlx5_ifc_sqc_bits {
+	u8         rlky[0x1];
+	u8         cd_master[0x1];
+	u8         fre[0x1];
+	u8         reserved_0[0x5];
+	u8         state[0x4];
+	u8         reserved_1[0x14];
+
+	u8         reserved_2[0x8];
+	u8         sq_index[0x18];
+
+	u8         reserved_3[0x8];
+	u8         cqn[0x18];
+
+	u8         reserved_4[0xa0];
+
+	u8         tis_lst_sz[0x10];
+	u8         reserved_5[0x10];
+
+	u8         reserved_6[0x40];
+
+	u8         reserved_7[0x8];
+	u8         tis_num_0[0x18];
+
+	struct mlx5_ifc_wq_bits wq;
+};
+
+enum {
+	MLX5_RQC_CS_CS_DISABLE  = 0x0,
+	MLX5_RQC_CS_CS_32B      = 0x1,
+	MLX5_RQC_CS_CS_64B      = 0x2,
+};
+
+enum {
+	MLX5_RQ_TYPE_DIRECT          = 0x0,
+	MLX5_RQ_TYPE_RMP             = 0x1,
+	MLX5_RQ_TYPE_OVERLAY         = 0x2,
+};
+
+enum {
+	MLX5_RQC_STATE_RDY  = 0x1,
+	MLX5_RQC_STATE_ERR  = 0x3,
+};
+
+struct mlx5_ifc_rqc_bits {
+	u8         rlky[0x1];
+	u8         cs[0x2];
+	u8         vsd[0x1];
+	u8         rq_type[0x4];
+	u8         state[0x4];
+	u8         reserved_0[0x14];
+
+	u8         reserved_1[0x8];
+	u8         rq_index[0x18];
+
+	u8         reserved_2[0x8];
+	u8         cqn[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         reserved_4[0x8];
+	u8         rmpn[0x18];
+
+	u8         reserved_5[0xe0];
+
+	struct mlx5_ifc_wq_bits wq;
+};
+
+enum {
+	MLX5_RMPC_STATE_RDY  = 0x1,
+	MLX5_RMPC_STATE_ERR  = 0x3,
+};
+
+struct mlx5_ifc_rmpc_bits {
+	u8         reserved_0[0x8];
+	u8         state[0x4];
+	u8         reserved_1[0x14];
+
+	u8         reserved_2[0xe0];
+
+	struct mlx5_ifc_wq_bits wq;
+};
+
+struct mlx5_ifc_nic_vport_context_bits {
+	u8         permanent_addresses_perm[0x1];
+	u8         reserved_0[0x1e];
+	u8         roce_en[0x1];
+
+	u8         reserved_1[0x760];
+
+	u8         reserved_2[0x14];
+	u8         num_of_permanent_addresses[0xc];
+
+	u8         reserved_3[0x60];
+
+	u8         permanent_address[0][0x40];
+};
+
+struct mlx5_ifc_mkc_bits {
+	u8         reserved_0[0x1];
+	u8         free[0x1];
+	u8         reserved_1[0xd];
+	u8         small_fence_on_rdma_read_response[0x1];
+	u8         umr_en[0x1];
+	u8         a[0x1];
+	u8         rw[0x1];
+	u8         rr[0x1];
+	u8         lw[0x1];
+	u8         lr[0x1];
+	u8         access_mode[0x2];
+	u8         reserved_2[0x8];
+
+	u8         qpn[0x18];
+	u8         mkey[0x8];
+
+	u8         reserved_3[0x20];
+
+	u8         length64[0x1];
+	u8         bsf_en[0x1];
+	u8         sync_umr[0x1];
+	u8         reserved_4[0x2];
+	u8         expected_sigerr_count[0x1];
+	u8         reserved_5[0x1];
+	u8         en_rinval[0x1];
+	u8         pd[0x18];
+
+	u8         start_addr[0x40];
+
+	u8         len[0x40];
+
+	u8         bsf_octword_size[0x20];
+
+	u8         reserved_6[0x80];
+
+	u8         translations_octword_size[0x20];
+
+	u8         reserved_7[0x1b];
+	u8         log_page_size[0x5];
+
+	u8         reserved_8[0x20];
+};
+
+struct mlx5_ifc_esw_vport_context_bits {
+	u8         reserved_0[0x780];
+
+	u8         reserved_1[0x14];
+	u8         num_of_allowed_forwarding_addresses[0xc];
+
+	u8         reserved_2[0x60];
+
+	struct mlx5_ifc_allowed_address_context_bits allowed_forwarding_address[0];
+};
+
+struct mlx5_ifc_eqc_bits {
+	u8         status[0x4];
+	u8         reserved_0[0x9];
+	u8         ec[0x1];
+	u8         oi[0x1];
+	u8         reserved_1[0x5];
+	u8         st[0x4];
+	u8         reserved_2[0x8];
+
+	u8         reserved_3[0x20];
+
+	u8         reserved_4[0x14];
+	u8         page_offset[0x6];
+	u8         reserved_5[0x6];
+
+	u8         reserved_6[0x3];
+	u8         log_eq_size[0x5];
+	u8         uar[0x18];
+
+	u8         reserved_7[0x20];
+
+	u8         reserved_8[0x18];
+	u8         intr[0x8];
+
+	u8         reserved_9[0x3];
+	u8         log_page_size[0x5];
+	u8         reserved_10[0x18];
+
+	u8         reserved_11[0x60];
+
+	u8         reserved_12[0x8];
+	u8         consumer_counter[0x18];
+
+	u8         reserved_13[0x8];
+	u8         producer_counter[0x18];
+
+	u8         reserved_14[0x80];
+};
+
+struct mlx5_ifc_dctc_bits {
+	u8         reserved_0[0x4];
+	u8         state[0x4];
+	u8         reserved_1[0x18];
+
+	u8         reserved_2[0x8];
+	u8         sw_context[0x18];
+
+	u8         reserved_3[0x8];
+	u8         cqn[0x18];
+
+	u8         counter_set_id[0x8];
+	u8         atomic_mode[0x4];
+	u8         rre[0x1];
+	u8         rwe[0x1];
+	u8         rae[0x1];
+	u8         atomic_like_write_en[0x1];
+	u8         latency_sensitive[0x1];
+	u8         rlky[0x1];
+	u8         free_ar[0x1];
+	u8         reserved_4[0xd];
+
+	u8         reserved_5[0x8];
+	u8         cs_res[0x8];
+	u8         reserved_6[0x3];
+	u8         min_rnr_nak[0x5];
+	u8         reserved_7[0x8];
+
+	u8         reserved_8[0x8];
+	u8         srqn[0x18];
+
+	u8         reserved_9[0x8];
+	u8         pd[0x18];
+
+	u8         tclass[0x8];
+	u8         reserved_10[0x4];
+	u8         flow_label[0x14];
+
+	u8         dc_access_key[0x40];
+
+	u8         reserved_11[0x5];
+	u8         mtu[0x3];
+	u8         port[0x8];
+	u8         pkey_index[0x10];
+
+	u8         reserved_12[0x8];
+	u8         my_addr_index[0x8];
+	u8         reserved_13[0x8];
+	u8         hop_limit[0x8];
+
+	u8         dc_access_key_violation_count[0x20];
+
+	u8         reserved_14[0x14];
+	u8         dei_cfi[0x1];
+	u8         eth_prio[0x3];
+	u8         ecn[0x2];
+	u8         dscp[0x6];
+
+	u8         reserved_15[0x40];
+};
+
+struct mlx5_ifc_cqc_bits {
+	u8         status[0x4];
+	u8         reserved_0[0x4];
+	u8         cqe_sz[0x3];
+	u8         cc[0x1];
+	u8         reserved_1[0x2];
+	u8         oi[0x1];
+	u8         reserved_2[0x2];
+	u8         cqe_zip_en[0x1];
+	u8         mini_cqe_res_format[0x2];
+	u8         st[0x4];
+	u8         reserved_3[0x8];
+
+	u8         reserved_4[0x20];
+
+	u8         reserved_5[0x14];
+	u8         page_offset[0x6];
+	u8         reserved_6[0x6];
+
+	u8         reserved_7[0x3];
+	u8         log_cq_size[0x5];
+	u8         uar_page[0x18];
+
+	u8         reserved_8[0x4];
+	u8         cq_period[0xc];
+	u8         cq_max_count[0x10];
+
+	u8         reserved_9[0x18];
+	u8         c_eqn[0x8];
+
+	u8         reserved_10[0x3];
+	u8         log_page_size[0x5];
+	u8         reserved_11[0x18];
+
+	u8         reserved_12[0x20];
+
+	u8         reserved_13[0x8];
+	u8         last_notified_index[0x18];
+
+	u8         reserved_14[0x8];
+	u8         last_solicit_index[0x18];
+
+	u8         reserved_15[0x8];
+	u8         consumer_counter[0x18];
+
+	u8         reserved_16[0x8];
+	u8         producer_counter[0x18];
+
+	u8         reserved_17[0x40];
+
+	u8         dbr_addr[0x40];
+};
+
+struct mlx5_ifc_query_adapter_param_block_bits {
+	u8         reserved_0[0x80];
+
+	u8         intapin[0x8];
+	u8         reserved_1[0x18];
+
+	u8         reserved_2[0x40];
+
+	u8         reserved_3[0x10];
+	u8         vsd_vendor_id[0x10];
+
+	u8         vsd[208][0x8];
+
+	u8         vsd_contd_psid[16][0x8];
+};
+
+struct mlx5_ifc_flow_table_field_bitmask_bits {
+	u8         outer_dmac[0x1];
+	u8         outer_smac[0x1];
+	u8         outer_ether_type[0x1];
+	u8         reserved_0[0x1];
+	u8         outer_first_prio[0x1];
+	u8         outer_first_cfi[0x1];
+	u8         outer_first_vid[0x1];
+	u8         reserved_1[0x1];
+	u8         outer_second_prio[0x1];
+	u8         outer_second_cfi[0x1];
+	u8         outer_second_vid[0x1];
+	u8         reserved_2[0x1];
+	u8         outer_sip[0x1];
+	u8         outer_dip[0x1];
+	u8         outer_frag[0x1];
+	u8         outer_ip_protocol[0x1];
+	u8         reserved_3[0x4];
+	u8         outer_l4_sport[0x1];
+	u8         outer_l4_dport[0x1];
+	u8         outer_tcp_flags[0x1];
+	u8         outer_gre_protcol[0x1];
+	u8         outer_gre_key[0x1];
+	u8         outer_vxlan_vni[0x1];
+	u8         reserved_4[0x6];
+
+	u8         inner_dmac[0x1];
+	u8         inner_smac[0x1];
+	u8         inner_ether_type[0x1];
+	u8         reserved_5[0x1];
+	u8         inner_first_prio[0x1];
+	u8         inner_first_cfi[0x1];
+	u8         inner_first_vid[0x1];
+	u8         reserved_6[0x1];
+	u8         inner_second_prio[0x1];
+	u8         inner_second_cfi[0x1];
+	u8         inner_second_vid[0x1];
+	u8         reserved_7[0x1];
+	u8         inner_sip[0x1];
+	u8         inner_dip[0x1];
+	u8         inner_frag[0x1];
+	u8         inner_ip_protocol[0x1];
+	u8         reserved_8[0x4];
+	u8         inner_l4_sport[0x1];
+	u8         inner_l4_dport[0x1];
+	u8         inner_tcp_flags[0x1];
+	u8         reserved_9[0x9];
+
+	u8         reserved_10[0x40];
+};
+
+struct mlx5_ifc_odp_per_transport_service_cap_bits {
+	u8         send[0x1];
+	u8         receive[0x1];
+	u8         write[0x1];
+	u8         reserved_0[0x1d];
+};
+
+struct mlx5_ifc_register_loopback_control_bits {
+	u8         no_lb[0x1];
+	u8         reserved_0[0x7];
+	u8         port[0x8];
+	u8         reserved_1[0x10];
+
+	u8         reserved_2[0x60];
+};
+
+struct mlx5_ifc_teardown_hca_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+enum {
+	MLX5_TEARDOWN_HCA_IN_OPCODE_GRACEFUL_CLOSE  = 0x0,
+	MLX5_TEARDOWN_HCA_IN_OPCODE_PANIC_CLOSE     = 0x1,
+};
+
+struct mlx5_ifc_teardown_hca_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x10];
+	u8         profile[0x10];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_sqerr2rts_qp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_sqerr2rts_qp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         opt_param_mask[0x20];
+
+	u8         reserved_4[0x20];
+
+	struct mlx5_ifc_qpc_bits qpc;
+
+	u8         reserved_5[0x80];
+};
+
+struct mlx5_ifc_set_roce_address_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_set_roce_address_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         roce_address_index[0x10];
+	u8         reserved_2[0x10];
+
+	u8         reserved_3[0x20];
+
+	struct mlx5_ifc_roce_addr_layout_bits roce_address;
+};
+
+struct mlx5_ifc_set_mad_demux_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+enum {
+	MLX5_SET_MAD_DEMUX_IN_DEMUX_MODE_PASS_ALL   = 0x0,
+	MLX5_SET_MAD_DEMUX_IN_DEMUX_MODE_SELECTIVE  = 0x2,
+};
+
+struct mlx5_ifc_set_mad_demux_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x20];
+
+	u8         reserved_3[0x6];
+	u8         demux_mode[0x2];
+	u8         reserved_4[0x18];
+};
+
+struct mlx5_ifc_set_hca_cap_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_set_hca_cap_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+
+	struct mlx5_ifc_cmd_hca_cap_bits hca_capability_struct;
+};
+
+struct mlx5_ifc_set_flow_table_entry_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+enum {
+	MLX5_SET_FLOW_TABLE_ENTRY_IN_DESTINATION_TYPE_TIR  = 0x1,
+};
+
+struct mlx5_ifc_set_flow_table_entry_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x20];
+
+	u8         flow_index[0x20];
+
+	u8         destination_type[0x8];
+	u8         destination_id[0x18];
+
+	u8         reserved_3[0x8];
+	u8         table_id[0x18];
+
+	u8         valid[0x1];
+	u8         reserved_4[0x19];
+	u8         miscellaneous_headers_masks_valid[0x1];
+	u8         inner_packet_headers_masks_valid[0x1];
+	u8         outer_packet_headers_masks_valid[0x1];
+	u8         miscellaneous_headers_valid[0x1];
+	u8         inner_packet_headers_valid[0x1];
+	u8         outer_packet_headers_valid[0x1];
+
+	u8         reserved_5[0x20];
+
+	struct mlx5_ifc_flow_table_entry_set_base_layer2_4_bits outer_packet_headers;
+
+	struct mlx5_ifc_flow_table_entry_set_base_layer2_4_bits inner_packet_headers;
+
+	struct mlx5_ifc_flow_table_entry_set_misc_fields_bits miscellaneous_headers;
+
+	struct mlx5_ifc_flow_table_entry_set_base_layer2_4_bits outer_packet_headers_masks;
+
+	struct mlx5_ifc_flow_table_entry_set_base_layer2_4_bits inner_packet_headers_masks;
+
+	struct mlx5_ifc_flow_table_entry_set_misc_fields_bits miscellaneous_headers_masks;
+
+	u8         reserved_6[0x800];
+};
+
+struct mlx5_ifc_set_burst_size_out_bits {
+	u8         status[0x10];
+	u8         reserved_0[0x10];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_set_burst_size_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x20];
+
+	u8         reserved_3[0x9];
+	u8         device_burst_size[0x17];
+};
+
+struct mlx5_ifc_rts2rts_qp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_rts2rts_qp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         opt_param_mask[0x20];
+
+	u8         reserved_4[0x20];
+
+	struct mlx5_ifc_qpc_bits qpc;
+
+	u8         reserved_5[0x80];
+};
+
+struct mlx5_ifc_rtr2rts_qp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_rtr2rts_qp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         opt_param_mask[0x20];
+
+	u8         reserved_4[0x20];
+
+	struct mlx5_ifc_qpc_bits qpc;
+
+	u8         reserved_5[0x80];
+};
+
+struct mlx5_ifc_rst2init_qp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_rst2init_qp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         opt_param_mask[0x20];
+
+	u8         reserved_4[0x20];
+
+	struct mlx5_ifc_qpc_bits qpc;
+
+	u8         reserved_5[0x80];
+};
+
+struct mlx5_ifc_roce_cap_bits {
+	u8         reserved_0[0x80];
+
+	u8         reserved_1[0xc];
+	u8         l3_type[0x4];
+	u8         reserved_2[0x8];
+	u8         roce_version[0x8];
+
+	u8         reserved_3[0x10];
+	u8         r_roce_dest_udp_port[0x10];
+
+	u8         r_roce_max_src_udp_port[0x10];
+	u8         r_roce_min_src_udp_port[0x10];
+
+	u8         reserved_4[0x10];
+	u8         roce_address_table_size[0x10];
+
+	u8         reserved_5[0x700];
+};
+
+struct mlx5_ifc_resize_field_select_bits {
+	u8         resize_field_select[0x20];
+};
+
+enum {
+	MLX5_QUERY_VPORT_STATE_OUT_STATE_DOWN  = 0x0,
+	MLX5_QUERY_VPORT_STATE_OUT_STATE_UP    = 0x1,
+};
+
+struct mlx5_ifc_query_vport_state_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x20];
+
+	u8         reserved_2[0x1c];
+	u8         state[0x4];
+};
+
+enum {
+	MLX5_QUERY_VPORT_STATE_IN_OP_MOD_VNIC_VPORT  = 0x0,
+	MLX5_QUERY_VPORT_STATE_IN_OP_MOD_ESW_VPORT   = 0x1,
+	MLX5_QUERY_VPORT_STATE_IN_OP_MOD_UPLINK      = 0x2,
+};
+
+struct mlx5_ifc_query_vport_state_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         other_vport[0x1];
+	u8         reserved_2[0xf];
+	u8         vport_number[0x10];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_vport_counter_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_traffic_counter_bits received_errors;
+
+	struct mlx5_ifc_traffic_counter_bits transmit_errors;
+
+	struct mlx5_ifc_traffic_counter_bits received_unicast;
+
+	struct mlx5_ifc_traffic_counter_bits transmitted_unicast;
+
+	struct mlx5_ifc_traffic_counter_bits received_multicast;
+
+	struct mlx5_ifc_traffic_counter_bits transmitted_multicast;
+
+	struct mlx5_ifc_traffic_counter_bits received_broadcast;
+
+	struct mlx5_ifc_traffic_counter_bits transmitted_broadcast;
+
+	u8         reserved_2[0x400];
+};
+
+struct mlx5_ifc_query_vport_counter_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         other_vport[0x1];
+	u8         reserved_2[0xf];
+	u8         vport_number[0x10];
+
+	u8         reserved_3[0x60];
+
+	u8         clear[0x1];
+	u8         reserved_4[0x1f];
+
+	u8         reserved_5[0x20];
+};
+
+struct mlx5_ifc_query_tis_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_tisc_bits tis_context;
+};
+
+struct mlx5_ifc_query_tis_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         tis_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_tir_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0xc0];
+
+	struct mlx5_ifc_tirc_bits tir_context;
+};
+
+struct mlx5_ifc_query_tir_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         tir_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_srq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_srqc_bits srq_context_entry;
+
+	u8         reserved_2[0x600];
+
+	u8         pas[0][0x40];
+};
+
+struct mlx5_ifc_query_srq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         srqn[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_sq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_sqc_bits sq_context;
+};
+
+struct mlx5_ifc_query_sq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         sq_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_special_contexts_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x20];
+
+	u8         resd_lkey[0x20];
+};
+
+struct mlx5_ifc_query_special_contexts_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+};
+
+struct mlx5_ifc_query_rq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_rqc_bits rq_context;
+};
+
+struct mlx5_ifc_query_rq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         rq_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_roce_address_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_roce_addr_layout_bits roce_address;
+};
+
+struct mlx5_ifc_query_roce_address_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         roce_address_index[0x10];
+	u8         reserved_2[0x10];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_rmp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_rmpc_bits rmp_context;
+};
+
+struct mlx5_ifc_query_rmp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         rmp_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_qp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	u8         opt_param_mask[0x20];
+
+	u8         reserved_2[0x20];
+
+	struct mlx5_ifc_qpc_bits qpc;
+
+	u8         reserved_3[0x80];
+
+	u8         pas[0][0x40];
+};
+
+struct mlx5_ifc_query_qp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_q_counter_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	u8         rx_write_requests[0x20];
+
+	u8         reserved_2[0x20];
+
+	u8         rx_read_requests[0x20];
+
+	u8         reserved_3[0x20];
+
+	u8         rx_atomic_requests[0x20];
+
+	u8         reserved_4[0x20];
+
+	u8         rx_dct_connect[0x20];
+
+	u8         reserved_5[0x20];
+
+	u8         out_of_buffer[0x20];
+
+	u8         reserved_6[0x660];
+};
+
+struct mlx5_ifc_query_q_counter_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x80];
+
+	u8         clear[0x1];
+	u8         reserved_3[0x1f];
+
+	u8         reserved_4[0x18];
+	u8         counter_set_id[0x8];
+};
+
+struct mlx5_ifc_query_pages_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x10];
+	u8         function_id[0x10];
+
+	u8         num_pages[0x20];
+};
+
+enum {
+	MLX5_QUERY_PAGES_IN_OP_MOD_BOOT_PAGES     = 0x1,
+	MLX5_QUERY_PAGES_IN_OP_MOD_INIT_PAGES     = 0x2,
+	MLX5_QUERY_PAGES_IN_OP_MOD_REGULAR_PAGES  = 0x3,
+};
+
+struct mlx5_ifc_query_pages_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+};
+
+struct mlx5_ifc_query_nic_vport_context_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_nic_vport_context_bits nic_vport_context;
+};
+
+struct mlx5_ifc_query_nic_vport_context_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         other_vport[0x1];
+	u8         reserved_2[0xf];
+	u8         vport_number[0x10];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_mkey_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_mkc_bits memory_key_mkey_entry;
+
+	u8         reserved_2[0x600];
+
+	u8         bsf0_klm0_pas_mtt0_1[16][0x8];
+
+	u8         bsf1_klm1_pas_mtt2_3[16][0x8];
+};
+
+struct mlx5_ifc_query_mkey_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         mkey_index[0x18];
+
+	u8         pg_access[0x1];
+	u8         reserved_3[0x1f];
+};
+
+struct mlx5_ifc_query_mad_demux_out_bits {
+	u8         status[0x10];
+	u8         reserved_0[0x10];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	u8         mad_dumux_parameters_block[0x20];
+};
+
+struct mlx5_ifc_query_mad_demux_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+};
+
+struct mlx5_ifc_query_hca_cap_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	u8         capability_struct[256][0x8];
+};
+
+struct mlx5_ifc_query_hca_cap_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+};
+
+struct mlx5_ifc_query_flow_table_entry_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x80];
+
+	u8         valid[0x1];
+	u8         reserved_2[0x19];
+	u8         miscellaneous_headers_masks_valid[0x1];
+	u8         inner_packet_headers_masks_valid[0x1];
+	u8         outer_packet_headers_masks_valid[0x1];
+	u8         miscellaneous_headers_valid[0x1];
+	u8         inner_packet_headers_valid[0x1];
+	u8         outer_packet_headers_valid[0x1];
+
+	u8         reserved_3[0x20];
+
+	struct mlx5_ifc_flow_table_entry_set_base_layer2_4_bits outer_packet_headers;
+
+	struct mlx5_ifc_flow_table_entry_set_base_layer2_4_bits inner_packet_headers;
+
+	struct mlx5_ifc_flow_table_entry_set_misc_fields_bits miscellaneous_headers;
+
+	struct mlx5_ifc_flow_table_entry_set_base_layer2_4_bits outer_packet_headers_masks;
+
+	struct mlx5_ifc_flow_table_entry_set_base_layer2_4_bits inner_packet_headers_masks;
+
+	struct mlx5_ifc_flow_table_entry_set_misc_fields_bits miscellaneous_headers_masks;
+
+	u8         reserved_4[0x800];
+};
+
+struct mlx5_ifc_query_flow_table_entry_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x20];
+
+	u8         flow_index[0x20];
+
+	u8         reserved_3[0x20];
+
+	u8         reserved_4[0x8];
+	u8         table_id[0x18];
+
+	u8         reserved_5[0x40];
+};
+
+struct mlx5_ifc_query_esw_vport_context_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_esw_vport_context_bits esw_vport_context;
+};
+
+struct mlx5_ifc_query_esw_vport_context_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         other_vport[0x1];
+	u8         reserved_2[0xf];
+	u8         vport_number[0x10];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_eq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_eqc_bits eq_context_entry;
+
+	u8         reserved_2[0x40];
+
+	u8         event_bitmask[0x40];
+
+	u8         reserved_3[0x580];
+
+	u8         pas[0][0x40];
+};
+
+struct mlx5_ifc_query_eq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x18];
+	u8         eq_number[0x8];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_dct_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_dctc_bits dct_context_entry;
+
+	u8         reserved_2[0x180];
+};
+
+struct mlx5_ifc_query_dct_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         dct_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_cq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_cqc_bits cq_context;
+
+	u8         reserved_2[0x600];
+
+	u8         pas[0][0x40];
+};
+
+struct mlx5_ifc_query_cq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         cqn[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_cong_statistics_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	u8         cur_flows[0x20];
+
+	u8         sum_flows[0x20];
+
+	u8         cnp_ignored_high[0x20];
+
+	u8         cnp_ignored_low[0x20];
+
+	u8         cnp_handled_high[0x20];
+
+	u8         cnp_handled_low[0x20];
+
+	u8         cur_total_rate_high[0x20];
+
+	u8         cur_total_rate_low[0x20];
+
+	u8         sum_total_rate_high[0x20];
+
+	u8         sum_total_rate_low[0x20];
+
+	u8         min_total_rate_high[0x20];
+
+	u8         min_total_rate_low[0x20];
+
+	u8         max_total_rate_high[0x20];
+
+	u8         max_total_rate_low[0x20];
+
+	u8         time_stamp_high[0x20];
+
+	u8         time_stamp_low[0x20];
+
+	u8         accumulators_period[0x20];
+
+	u8         ecn_marked_roce_packets_high[0x20];
+
+	u8         ecn_marked_roce_packets_low[0x20];
+
+	u8         cnps_sent_high[0x20];
+
+	u8         cnps_sent_low[0x20];
+
+	u8         reserved_2[0x560];
+};
+
+struct mlx5_ifc_query_cong_statistics_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         clear[0x1];
+	u8         reserved_2[0x1f];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_cong_params_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	u8         congestion_parameters802_1qau_rp_r_roce_ecn_rp_r_roce_ecn_np[256][0x8];
+};
+
+struct mlx5_ifc_query_cong_params_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x1c];
+	u8         cong_protocol[0x4];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_query_burst_size_out_bits {
+	u8         status[0x10];
+	u8         reserved_0[0x10];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x20];
+
+	u8         reserved_2[0x9];
+	u8         device_burst_size[0x17];
+};
+
+struct mlx5_ifc_query_burst_size_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+};
+
+struct mlx5_ifc_query_adapter_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	struct mlx5_ifc_query_adapter_param_block_bits query_adapter_struct;
+};
+
+struct mlx5_ifc_query_adapter_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+};
+
+struct mlx5_ifc_per_protocol_networking_offload_caps_bits {
+	u8         csum_cap[0x1];
+	u8         vlan_cap[0x1];
+	u8         lro_cap[0x1];
+	u8         lro_psh_flag[0x1];
+	u8         lro_time_stamp[0x1];
+	u8         reserved_0[0x6];
+	u8         max_lso_cap[0x5];
+	u8         reserved_1[0x4];
+	u8         rss_ind_tbl_cap[0x4];
+	u8         reserved_2[0x8];
+
+	u8         reserved_3[0x2];
+	u8         log_flow_table_sz[0x6];
+	u8         reserved_4[0x18];
+
+	u8         reserved_5[0x10];
+	u8         lro_min_mss_size[0x10];
+
+	u8         reserved_6[0x20];
+
+	struct mlx5_ifc_flow_table_field_bitmask_bits flow_table_field_support;
+
+	struct mlx5_ifc_flow_table_field_bitmask_bits flow_table_field_bitmask_support;
+
+	u8         lro_timer_supported_periods[4][0x20];
+
+	u8         reserved_7[0x80];
+};
+
+struct mlx5_ifc_page_fault_resume_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_page_fault_resume_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         error[0x1];
+	u8         reserved_2[0x4];
+	u8         rdma[0x1];
+	u8         read_write[0x1];
+	u8         requestor[0x1];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_odp_cap_bits {
+	u8         reserved_0[0x40];
+
+	u8         sig[0x1];
+	u8         reserved_1[0x1f];
+
+	u8         reserved_2[0x20];
+
+	struct mlx5_ifc_odp_per_transport_service_cap_bits rc_odp_caps;
+
+	struct mlx5_ifc_odp_per_transport_service_cap_bits uc_odp_caps;
+
+	struct mlx5_ifc_odp_per_transport_service_cap_bits ud_odp_caps;
+
+	u8         reserved_3[0x720];
+};
+
+struct mlx5_ifc_modify_vport_state_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_modify_vport_state_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         other_vport[0x1];
+	u8         reserved_2[0xf];
+	u8         vport_number[0x10];
+
+	u8         reserved_3[0x1c];
+	u8         state[0x4];
+};
+
+struct mlx5_ifc_modify_tis_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_modify_tis_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         tis_state[0x4];
+	u8         reserved_2[0x4];
+	u8         tis_number[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         modify_bitmask[8][0x8];
+
+	u8         reserved_4[0x40];
+
+	struct mlx5_ifc_tisc_bits ctx;
+};
+
+struct mlx5_ifc_modify_tir_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_modify_tir_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         tir_number[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         modify_bitmask[8][0x8];
+
+	u8         reserved_4[0x40];
+
+	struct mlx5_ifc_tirc_bits ctx;
+};
+
+struct mlx5_ifc_modify_sq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_modify_sq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         sq_state[0x4];
+	u8         reserved_2[0x4];
+	u8         sq_number[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         modify_bitmask[8][0x8];
+
+	u8         reserved_4[0x40];
+
+	struct mlx5_ifc_sqc_bits ctx;
+};
+
+struct mlx5_ifc_modify_rq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_modify_rq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         rq_state[0x4];
+	u8         reserved_2[0x4];
+	u8         rq_number[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         modify_bitmask[8][0x8];
+
+	u8         reserved_4[0x40];
+
+	struct mlx5_ifc_rqc_bits ctx;
+};
+
+struct mlx5_ifc_modify_rmp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_modify_rmp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         rmp_state[0x4];
+	u8         reserved_2[0x4];
+	u8         rmp_number[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         modify_bitmask[8][0x8];
+
+	struct mlx5_ifc_rmpc_bits ctx;
+};
+
+struct mlx5_ifc_modify_nic_vport_context_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_modify_nic_vport_context_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         other_vport[0x1];
+	u8         reserved_2[0xf];
+	u8         vport_number[0x10];
+
+	u8         field_select[0x20];
+
+	u8         reserved_3[0x780];
+
+	struct mlx5_ifc_nic_vport_context_bits nic_vport_context;
+};
+
+struct mlx5_ifc_modify_field_select_bits {
+	u8         modify_field_select[0x20];
+};
+
+struct mlx5_ifc_modify_esw_vport_context_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_modify_esw_vport_context_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         other_vport[0x1];
+	u8         reserved_2[0xf];
+	u8         vport_number[0x10];
+
+	u8         field_select[0x20];
+
+	u8         reserved_3[0x780];
+
+	struct mlx5_ifc_esw_vport_context_bits esw_vport_context;
+};
+
+struct mlx5_ifc_modify_cq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_modify_cq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         cqn[0x18];
+
+	u8         modify_field_select_resize_field_select[0x20];
+
+	struct mlx5_ifc_cqc_bits cq_context;
+
+	u8         reserved_3[0x600];
+
+	u8         pas[0][0x40];
+};
+
+struct mlx5_ifc_modify_cong_params_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_modify_cong_params_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x1c];
+	u8         cong_protocol[0x4];
+
+	u8         field_select_8021qaurp_field_select_r_roce_rp_field_select_r_r[0x20];
+
+	u8         reserved_3[0x80];
+
+	u8         congestion_parameters802_1qau_rp_r_roce_ecn_rp_r_roce_ecn_np[272][0x8];
+};
+
+struct mlx5_ifc_manage_pages_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         output_num_entries[0x20];
+
+	u8         reserved_1[0x20];
+
+	u8         pas[0][0x40];
+};
+
+enum {
+	MLX5_MANAGE_PAGES_IN_OP_MOD_ALLOCATION_FAIL     = 0x0,
+	MLX5_MANAGE_PAGES_IN_OP_MOD_ALLOCATION_SUCCESS  = 0x1,
+	MLX5_MANAGE_PAGES_IN_OP_MOD_HCA_RETURN_PAGES    = 0x2,
+};
+
+struct mlx5_ifc_manage_pages_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x10];
+	u8         function_id[0x10];
+
+	u8         input_num_entries[0x20];
+
+	u8         pas[0][0x40];
+};
+
+struct mlx5_ifc_mad_ifc_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	u8         response_mad_packet[256][0x8];
+};
+
+struct mlx5_ifc_mad_ifc_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         remote_lid[0x10];
+	u8         reserved_2[0x8];
+	u8         port[0x8];
+
+	u8         reserved_3[0x20];
+
+	u8         request_mad_packet[256][0x8];
+};
+
+struct mlx5_ifc_init_hca_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_init_hca_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x10];
+	u8         profile[0x10];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_init2rtr_qp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_init2rtr_qp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         opt_param_mask[0x20];
+
+	u8         reserved_4[0x20];
+
+	struct mlx5_ifc_qpc_bits qpc;
+
+	u8         reserved_5[0x80];
+};
+
+struct mlx5_ifc_init2init_qp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_init2init_qp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         opt_param_mask[0x20];
+
+	u8         reserved_4[0x20];
+
+	struct mlx5_ifc_qpc_bits qpc;
+
+	u8         reserved_5[0x80];
+};
+
+struct mlx5_ifc_get_dropped_packet_log_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	u8         packet_headers_log[128][0x8];
+
+	u8         packet_syndrome[64][0x8];
+};
+
+struct mlx5_ifc_gen_eqe_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x18];
+	u8         eq_number[0x8];
+
+	u8         reserved_3[0x20];
+
+	u8         eqe[64][0x8];
+};
+
+struct mlx5_ifc_gen_eq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_filed_select_r_roce_rp_bits {
+	u8         field_select_r_roce_rp[0x20];
+};
+
+struct mlx5_ifc_filed_select_r_roce_np_bits {
+	u8         field_select_r_roce_np[0x20];
+};
+
+struct mlx5_ifc_filed_select_802_1qau_rp_bits {
+	u8         field_select_8021qaurp[0x20];
+};
+
+struct mlx5_ifc_enable_hca_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x20];
+};
+
+struct mlx5_ifc_enable_hca_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+};
+
+struct mlx5_ifc_drain_dct_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_drain_dct_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         dct_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_disable_hca_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x20];
+};
+
+struct mlx5_ifc_disable_hca_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+};
+
+struct mlx5_ifc_detach_from_sniffer_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_detach_from_sniffer_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x10];
+	u8         sniffer_rule_id[0x10];
+
+	u8         reserved_3[0xa0];
+};
+
+struct mlx5_ifc_detach_from_mcg_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_detach_from_mcg_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         multicast_gid[16][0x8];
+};
+
+struct mlx5_ifc_destroy_tis_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_destroy_tis_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         tis_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_destroy_tir_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_destroy_tir_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         tir_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_destroy_srq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_destroy_srq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         srqn[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_destroy_sq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_destroy_sq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         sq_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_destroy_rq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_destroy_rq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         rq_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_destroy_rmp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_destroy_rmp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         rmp_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_destroy_qp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_destroy_qp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_destroy_psv_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_destroy_psv_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         psv_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_destroy_mkey_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_destroy_mkey_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         mkey[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_destroy_eq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_destroy_eq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x18];
+	u8         eq_number[0x8];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_destroy_dct_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_destroy_dct_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         dct_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_destroy_cq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_destroy_cq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         cqn[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_dealloc_xrcd_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_dealloc_xrcd_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         xrcd[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_dealloc_uar_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_dealloc_uar_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         uar[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_dealloc_q_counter_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_dealloc_q_counter_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x18];
+	u8         counter_set_id[0x8];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_dealloc_pd_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_dealloc_pd_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         pd[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_deactivate_tracer_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_deactivate_tracer_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         mkey[0x20];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_create_tis_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         tis_number[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_create_tis_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0xc0];
+
+	struct mlx5_ifc_tisc_bits ctx;
+};
+
+struct mlx5_ifc_create_tir_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         tir_number[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_create_tir_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0xc0];
+
+	struct mlx5_ifc_tirc_bits ctx;
+};
+
+struct mlx5_ifc_create_srq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         srqn[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_create_srq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+
+	struct mlx5_ifc_srqc_bits srq_context_entry;
+
+	u8         reserved_3[0x600];
+
+	u8         pas[0][0x40];
+};
+
+struct mlx5_ifc_create_sq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         sq_number[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_create_sq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0xc0];
+
+	struct mlx5_ifc_sqc_bits ctx;
+};
+
+struct mlx5_ifc_create_rq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         rq_number[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_create_rq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0xc0];
+
+	struct mlx5_ifc_rqc_bits ctx;
+};
+
+struct mlx5_ifc_create_rmp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         rmp_number[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_create_rmp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+
+	struct mlx5_ifc_rmpc_bits ctx;
+};
+
+struct mlx5_ifc_create_qp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_create_qp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+
+	u8         opt_param_mask[0x20];
+
+	u8         reserved_3[0x20];
+
+	struct mlx5_ifc_qpc_bits qpc;
+
+	u8         reserved_4[0x80];
+
+	u8         pas[0][0x40];
+};
+
+struct mlx5_ifc_create_psv_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	u8         reserved_2[0x8];
+	u8         psv0_index[0x18];
+
+	u8         reserved_3[0x8];
+	u8         psv1_index[0x18];
+
+	u8         reserved_4[0x8];
+	u8         psv2_index[0x18];
+
+	u8         reserved_5[0x8];
+	u8         psv3_index[0x18];
+};
+
+struct mlx5_ifc_create_psv_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         num_psv[0x4];
+	u8         reserved_2[0x4];
+	u8         pd[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_create_mkey_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         mkey_index[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_create_mkey_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x20];
+
+	u8         pg_access[0x1];
+	u8         reserved_3[0x1f];
+
+	struct mlx5_ifc_mkc_bits memory_key_mkey_entry;
+
+	u8         reserved_4[0x80];
+
+	u8         translations_octword_actual_size[0x20];
+
+	u8         reserved_5[0x560];
+
+	u8         klm_pas_mtt[0][0x20];
+};
+
+struct mlx5_ifc_create_eq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x18];
+	u8         eq_number[0x8];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_create_eq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+
+	struct mlx5_ifc_eqc_bits eq_context_entry;
+
+	u8         reserved_3[0x40];
+
+	u8         event_bitmask[0x40];
+
+	u8         reserved_4[0x580];
+
+	u8         pas[0][0x40];
+};
+
+struct mlx5_ifc_create_dct_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         dct_number[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_create_dct_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+
+	struct mlx5_ifc_dctc_bits dct_context_entry;
+
+	u8         reserved_3[0x180];
+};
+
+struct mlx5_ifc_create_cq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         cqn[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_create_cq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+
+	struct mlx5_ifc_cqc_bits cq_context;
+
+	u8         reserved_3[0x600];
+
+	u8         pas[0][0x40];
+};
+
+struct mlx5_ifc_cong_control_r_roce_ecn_rp_bits {
+	u8         reserved_0[0x60];
+
+	u8         cnp_receive_enable[0x1];
+	u8         reserved_1[0x3];
+	u8         clamp_tgt_rate[0x1];
+	u8         reserved_2[0x3];
+	u8         clamp_tgt_rate_after_time_inc[0x1];
+	u8         reserved_3[0x17];
+
+	u8         reserved_4[0x20];
+
+	u8         rpg_time_reset[0x20];
+
+	u8         rpg_byte_reset[0x20];
+
+	u8         rpg_threshold[0x20];
+
+	u8         rpg_max_rate[0x20];
+
+	u8         rpg_ai_rate[0x20];
+
+	u8         rpg_hai_rate[0x20];
+
+	u8         reserved_5[0x20];
+
+	u8         rpg_min_dec_fac[0x20];
+
+	u8         rpg_min_rate[0x20];
+
+	u8         reserved_6[0xe0];
+
+	u8         rate_to_set_on_first_cnp[0x20];
+
+	u8         dce_tcp_g[0x20];
+
+	u8         dce_tcp_rtt[0x20];
+
+	u8         rate_reduce_monitor_period[0x20];
+
+	u8         reserved_7[0x20];
+
+	u8         initial_alpha_value[0x20];
+
+	u8         reserved_8[0x4a0];
+};
+
+struct mlx5_ifc_cong_control_r_roce_ecn_np_bits {
+	u8         reserved_0[0x60];
+
+	u8         ecn_receive_enable[0x1];
+	u8         reserved_1[0x1f];
+
+	u8         reserved_2[0x20];
+
+	u8         min_time_between_cnps[0x20];
+
+	u8         reserved_3[0x12];
+	u8         cnp_dscp[0x6];
+	u8         reserved_4[0x5];
+	u8         cnp_802p_prio[0x3];
+
+	u8         reserved_5[0x720];
+};
+
+struct mlx5_ifc_cong_control_802_1qau_rp_bits {
+	u8         reserved_0[0x60];
+
+	u8         rpg_enable[0x1];
+	u8         tag_enable[0x1];
+	u8         reserved_1[0x1e];
+
+	u8         rppp_max_rps[0x20];
+
+	u8         rpg_time_reset[0x20];
+
+	u8         rpg_byte_reset[0x20];
+
+	u8         rpg_threshold[0x20];
+
+	u8         rpg_max_rate[0x20];
+
+	u8         rpg_ai_rate[0x20];
+
+	u8         rpg_hai_rate[0x20];
+
+	u8         rpg_gd[0x20];
+
+	u8         rpg_min_dec_fac[0x20];
+
+	u8         rpg_min_rate[0x20];
+
+	u8         reserved_2[0x640];
+};
+
+struct mlx5_ifc_config_int_moderation_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x4];
+	u8         min_delay[0xc];
+	u8         int_vector[0x10];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_config_int_moderation_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x4];
+	u8         min_delay[0xc];
+	u8         int_vector[0x10];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_attach_to_sniffer_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x10];
+	u8         sniffer_rule_id[0x10];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_attach_to_sniffer_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         other_vport[0x1];
+	u8         reserved_2[0xf];
+	u8         port_num[0x10];
+
+	u8         sx[0x1];
+	u8         rx[0x1];
+	u8         reserved_3[0x6];
+	u8         tirn[0x18];
+
+	u8         reserved_4[0x1480];
+};
+
+struct mlx5_ifc_attach_to_mcg_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_attach_to_mcg_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+
+	u8         multicast_gid[16][0x8];
+};
+
+struct mlx5_ifc_atomic_cap_bits {
+	u8         reserved_0[0x40];
+
+	u8         atomic_req_endianess[0x1];
+	u8         reserved_1[0x1f];
+
+	u8         reserved_2[0x20];
+
+	u8         reserved_3[0x10];
+	u8         atomic_operations[0x10];
+
+	u8         reserved_4[0x10];
+	u8         atomic_size_qp[0x10];
+
+	u8         reserved_5[0x10];
+	u8         atomic_size_dc[0x10];
+
+	u8         reserved_6[0x720];
+};
+
+struct mlx5_ifc_arm_rq_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_arm_rq_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         srq_number[0x18];
+
+	u8         reserved_3[0x10];
+	u8         lwm[0x10];
+};
+
+struct mlx5_ifc_arm_dct_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_arm_dct_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         dct_number[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_alloc_xrcd_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         xrcd[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_alloc_xrcd_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+};
+
+struct mlx5_ifc_alloc_uar_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         uar[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_alloc_uar_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+};
+
+struct mlx5_ifc_alloc_q_counter_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x18];
+	u8         counter_set_id[0x8];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_alloc_q_counter_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+};
+
+struct mlx5_ifc_alloc_pd_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x8];
+	u8         pd[0x18];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_alloc_pd_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x40];
+};
+
+struct mlx5_ifc_activate_tracer_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_activate_tracer_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         mkey[0x20];
+
+	u8         reserved_2[0x20];
+};
+
+struct mlx5_ifc_access_register_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+
+	u8         register_data[0][0x20];
+};
+
+struct mlx5_ifc_access_register_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x10];
+	u8         register_id[0x10];
+
+	u8         argument[0x20];
+
+	u8         register_data[0][0x20];
+};
+
+struct mlx5_ifc__2rst_qp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc__2rst_qp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc__2err_qp_out_bits {
+	u8         status[0x8];
+	u8         reserved_0[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc__2err_qp_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_2[0x8];
+	u8         qpn[0x18];
+
+	u8         reserved_3[0x20];
+};
+
+struct mlx5_ifc_register_power_settings_bits {
+	u8         reserved_0[0x18];
+	u8         power_settings_level[0x8];
+
+	u8         reserved_1[0x60];
+};
+
+struct mlx5_ifc_register_host_endianess_bits {
+	u8         he[0x1];
+	u8         reserved_0[0x1f];
+
+	u8         reserved_1[0x60];
+};
+
+struct mlx5_ifc_pplr_bits {
+	u8         reserved_0[0x8];
+	u8         local_port[0x8];
+	u8         reserved_1[0x10];
+
+	u8         reserved_2[0x1d];
+	u8         exl[0x1];
+	u8         el[0x1];
+	u8         il[0x1];
+};
+
+struct mlx5_ifc_initial_seg_bits {
+	u8         fw_rev_minor[0x10];
+	u8         fw_rev_major[0x10];
+
+	u8         cmd_interface_rev[0x10];
+	u8         fw_rev_subminor[0x10];
+
+	u8         reserved_0[0x40];
+
+	u8         cmdq_phy_addr[4][0x8];
+
+	u8         cmdq_phy_addr_31_12[0x14];
+	u8         reserved_1[0x4];
+	u8         log_cmdq_size[0x4];
+	u8         log_cmdq_stride[0x4];
+
+	u8         command_doorbell_vector[0x20];
+
+	u8         reserved_2[0xf00];
+
+	u8         initializing[0x1];
+	u8         reserved_3[0x1f];
+
+	u8         health_buffer[64][0x8];
+
+	u8         reserved_4[0x6e80];
+
+	u8         health_syndrome[0x8];
+	u8         health_counter[0x18];
+
+	u8         reserved_5[0x7fc0];
+
+	u8         reserved_6[0x1c];
+	u8         clear_intx[0x4];
+
+	u8         reserved_7[0xffe0];
+};
+
+struct mlx5_ifc_wqe_associated_page_fault_event_bits {
+	u8         bytes_commited[0x20];
+
+	u8         reserved_0[0x10];
+	u8         wqe_index[0x10];
+
+	u8         reserved_1[0x10];
+	u8         packet_len[0x10];
+
+	u8         reserved_2[0x60];
+
+	u8         reserved_3[0x5];
+	u8         rdma[0x1];
+	u8         write[0x1];
+	u8         requestor[0x1];
+	u8         qp_number[0x18];
+};
+
+struct mlx5_ifc_ud_adrs_vector_bits {
+	u8         dc_key[8][0x8];
+
+	u8         _1[0x1];
+	u8         reserved_0[0x7];
+	u8         destination_qp_dct[0x18];
+
+	u8         static_rate[0x4];
+	u8         sl_eth_prio[0x4];
+	u8         fl[0x1];
+	u8         mlid[0x7];
+	u8         rlid_udp_sport[0x10];
+
+	u8         reserved_1[0x20];
+
+	u8         rmac[6][0x8];
+
+	u8         tclass[0x8];
+	u8         hop_limit[0x8];
+
+	u8         reserved_2[0x1];
+	u8         grh[0x1];
+	u8         reserved_3[0x2];
+	u8         src_addr_index[0x8];
+	u8         flow_label[0x14];
+
+	u8         rgid_rip[16][0x8];
+};
+
+struct mlx5_ifc_stall_vl_event_bits {
+	u8         reserved_0[0x18];
+	u8         port_num[0x1];
+	u8         reserved_1[0x3];
+	u8         vl[0x4];
+
+	u8         reserved_2[0xa0];
+};
+
+struct mlx5_ifc_res_mini_cqe_rx_hash_layout_bits {
+	u8         rx_hash_result[0x20];
+
+	u8         byte_count[0x20];
+};
+
+struct mlx5_ifc_res_mini_cqe_checksum_layout_bits {
+	u8         checksum[0x20];
+
+	u8         byte_count[0x20];
+};
+
+struct mlx5_ifc_req_mini_cqe_layout_bits {
+	u8         wqe_counter[0x10];
+	u8         s_wqe_opcode[0x8];
+	u8         reserved_0[0x8];
+
+	u8         byte_count[0x20];
+};
+
+struct mlx5_ifc_rdma_page_fault_event_bits {
+	u8         bytes_commited[0x20];
+
+	u8         r_key[0x20];
+
+	u8         reserved_0[0x10];
+	u8         packet_len[0x10];
+
+	u8         rdma_op_len[0x20];
+
+	u8         rdma_va[8][0x8];
+
+	u8         reserved_1[0x5];
+	u8         rdma[0x1];
+	u8         write[0x1];
+	u8         requestor[0x1];
+	u8         qp_number[0x18];
+};
+
+struct mlx5_ifc_qp_events_bits {
+	u8         reserved_0[0xc0];
+
+	u8         reserved_1[0x8];
+	u8         qp_number[0x18];
+};
+
+struct mlx5_ifc_port_state_change_event_bits {
+	u8         reserved_0[0x40];
+
+	u8         port[0x4];
+	u8         reserved_1[0x1c];
+
+	u8         reserved_2[0x80];
+};
+
+struct mlx5_ifc_pages_req_event_bits {
+	u8         reserved_0[0x10];
+	u8         function_id[0x10];
+
+	u8         num_pages[0x20];
+
+	u8         reserved_1[0xa0];
+};
+
+struct mlx5_ifc_gpio_event_bits {
+	u8         reserved_0[0x60];
+
+	u8         gpio_event_hi[0x20];
+
+	u8         gpio_event_lo[0x20];
+
+	u8         reserved_1[0x40];
+};
+
+struct mlx5_ifc_eqe_bits {
+	u8         reserved_0[0x8];
+	u8         event_type[0x8];
+	u8         reserved_1[0x8];
+	u8         event_sub_type[0x8];
+
+	u8         reserved_2[0xe0];
+
+	u8         event_data[28][0x8];
+
+	u8         reserved_3[0x10];
+	u8         signature[0x8];
+	u8         reserved_4[0x7];
+	u8         owner[0x1];
+};
+
+struct mlx5_ifc_dropped_packet_logged_bits {
+	u8         reserved_0[0xe0];
+};
+
+struct mlx5_ifc_dct_events_bits {
+	u8         reserved_0[0xc0];
+
+	u8         reserved_1[0x8];
+	u8         dct_number[0x18];
+};
+
+struct mlx5_ifc_db_bf_congestion_event_bits {
+	u8         event_subtype[0x8];
+	u8         reserved_0[0x8];
+	u8         congestion_level[0x8];
+	u8         reserved_1[0x8];
+
+	u8         reserved_2[0xa0];
+};
+
+struct mlx5_ifc_cq_error_bits {
+	u8         reserved_0[0x8];
+	u8         cqn[0x18];
+
+	u8         reserved_1[0x20];
+
+	u8         reserved_2[0x18];
+	u8         syndrome[0x8];
+
+	u8         reserved_3[0x80];
+};
+
+struct mlx5_ifc_comp_event_bits {
+	u8         reserved_0[0xc0];
+
+	u8         reserved_1[0x8];
+	u8         cq_number[0x18];
+};
+
+struct mlx5_ifc_cmd_queue_entry_bits {
+	u8         type_7[0x8];
+	u8         reserved_0[0x18];
+
+	u8         input_length[0x20];
+
+	u8         input_mailbox_pointer[4][0x8];
+
+	u8         input_mailbox_pointer_31_9[0x17];
+	u8         reserved_1[0x9];
+
+	u8         command_input_inline_data[16][0x8];
+
+	u8         command_output_inline_data[16][0x8];
+
+	u8         output_mailbox_pointer[4][0x8];
+
+	u8         output_mailbox_pointer_31_9[0x17];
+	u8         reserved_2[0x9];
+
+	u8         output_length[0x20];
+
+	u8         token[0x8];
+	u8         signature[0x8];
+	u8         reserved_3[0x8];
+	u8         status[0x7];
+	u8         ownership[0x1];
+};
+
+struct mlx5_ifc_cmd_out_bits {
+	u8         status[0x10];
+	u8         reserved_0[0x10];
+
+	u8         syndrome[0x20];
+
+	u8         command_output[0x20];
+};
+
+struct mlx5_ifc_cmd_inter_comp_event_bits {
+	u8         command_completion_vector[0x20];
+
+	u8         reserved_0[0xc0];
+};
+
+struct mlx5_ifc_cmd_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_0[0x10];
+
+	u8         reserved_1[0x10];
+	u8         op_mod[0x10];
+
+	u8         command[0][0x20];
+};
+
+struct mlx5_ifc_cmd_if_box_bits {
+	u8         mailbox_data[512][0x8];
+
+	u8         reserved_0[0x180];
+
+	u8         next_pointer[4][0x8];
+
+	u8         next_pointer_31_10[0x16];
+	u8         reserved_1[0xa];
+
+	u8         block_number[0x20];
+
+	u8         reserved_2[0x8];
+	u8         token[0x8];
+	u8         ctrl_signature[0x8];
+	u8         signature[0x8];
+};
+
+struct mlx5_ifc_address_context_bits {
+	u8         reserved_0[0x10];
+	u8         mac_addr[6][0x8];
+};
+
+struct mlx5_ifc_mtt_bits {
+	u8         ptag[7][0x8];
+
+	u8         reserved_0[0x6];
+	u8         wr_en[0x1];
+	u8         rd_en[0x1];
+};
+
+union mlx5_ifc_initialization_and_teardown_document_bits {
+	struct mlx5_ifc_initial_seg_bits initial_seg;
+	u8         reserved_0[0x20060];
+};
+
+#endif /* MLX5_IFC_H */
-- 
2.1.1
