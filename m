From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: [PATCH 6/8] csiostor: Chelsio FCoE offload driver submission (headers part 1).
Date: Fri, 24 Aug 2012 03:57:51 +0530
Message-ID: <1345760873-12101-7-git-send-email-naresh@chelsio.com>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
Cc: netdev@vger.kernel.org, naresh@chelsio.com, chethan@chelsio.com
To: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the first set of the header files for csiostor driver.

Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
---
 drivers/scsi/csiostor/csio_defs.h       |  143 ++++++
 drivers/scsi/csiostor/csio_fcoe_proto.h |  843 +++++++++++++++++++++++++++++++
 drivers/scsi/csiostor/csio_hw.h         |  668 ++++++++++++++++++++++++
 drivers/scsi/csiostor/csio_init.h       |  158 ++++++
 4 files changed, 1812 insertions(+), 0 deletions(-)
 create mode 100644 drivers/scsi/csiostor/csio_defs.h
 create mode 100644 drivers/scsi/csiostor/csio_fcoe_proto.h
 create mode 100644 drivers/scsi/csiostor/csio_hw.h
 create mode 100644 drivers/scsi/csiostor/csio_init.h

diff --git a/drivers/scsi/csiostor/csio_defs.h b/drivers/scsi/csiostor/csio_defs.h
new file mode 100644
index 0000000..4f1c713
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_defs.h
@@ -0,0 +1,143 @@
+/*
+ * This file is part of the Chelsio FCoE driver for Linux.
+ *
+ * Copyright (c) 2008-2012 Chelsio Communications, Inc. All rights reserved.
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
+#ifndef __CSIO_DEFS_H__
+#define __CSIO_DEFS_H__
+
+#include <linux/kernel.h>
+#include <linux/timer.h>
+#include <linux/list.h>
+#include <linux/bug.h>
+#include <linux/pci.h>
+#include <linux/jiffies.h>
+
+/* Function returns */
+enum csio_retval {
+	CSIO_SUCCESS = 0,
+	CSIO_INVAL = 1,
+	CSIO_BUSY = 2,
+	CSIO_NOSUPP = 3,
+	CSIO_TIMEOUT = 4,
+	CSIO_NOMEM = 5,
+	CSIO_NOPERM = 6,
+	CSIO_RETRY = 7,
+	CSIO_EPROTO = 8,
+	CSIO_EIO = 9,
+	CSIO_CANCELLED = 10,
+};
+
+#define csio_retval_t enum csio_retval
+
+enum {
+	CSIO_FALSE = 0,
+	CSIO_TRUE = 1,
+};
+
+#define CSIO_ROUNDUP(__v, __r)		(((__v) + (__r) - 1) / (__r))
+#define CSIO_INVALID_IDX		0xFFFFFFFF
+#define csio_inc_stats(elem, val)	((elem)->stats.val++)
+#define csio_dec_stats(elem, val)	((elem)->stats.val--)
+#define csio_valid_wwn(__n)		((*__n >> 4) == 0x5 ? CSIO_TRUE : \
+						CSIO_FALSE)
+#define CSIO_WORD_TO_BYTE		4
+
+static inline int
+csio_list_deleted(struct list_head *list)
+{
+	return ((list->next == list) && (list->prev == list));
+}
+
+#define csio_list_next(elem)	(((struct list_head *)(elem))->next)
+#define csio_list_prev(elem)	(((struct list_head *)(elem))->prev)
+
+#define csio_deq_from_head(head, elem)					  \
+do {									  \
+	if (!list_empty(head)) {					  \
+		*((struct list_head **)(elem)) = csio_list_next((head));  \
+		csio_list_next((head)) =				  \
+				csio_list_next(csio_list_next((head)));   \
+		csio_list_prev(csio_list_next((head))) = (head);	  \
+		INIT_LIST_HEAD(*((struct list_head **)(elem)));	          \
+	} else								  \
+		*((struct list_head **)(elem)) = (struct list_head *)NULL;\
+} while (0)
+
+#define csio_deq_from_tail(head, elem)					  \
+do {									  \
+	if (!list_empty(head)) {					  \
+		*((struct list_head **)(elem)) = csio_list_prev((head));  \
+		csio_list_prev((head)) =				  \
+				csio_list_prev(csio_list_prev((head)));	  \
+		csio_list_next(csio_list_prev((head))) = (head);	  \
+		INIT_LIST_HEAD(*((struct list_head **)(elem)));		  \
+	} else								  \
+		*((struct list_head **)(elem)) = (struct list_head *)NULL;\
+} while (0)
+
+/* State machine */
+typedef void (*csio_sm_state_t)(void *, uint32_t);
+
+struct csio_sm {
+	struct list_head	sm_list;
+	csio_sm_state_t		sm_state;
+};
+
+#define csio_init_state(__smp, __state)					\
+	(((struct csio_sm *)(__smp))->sm_state = (csio_sm_state_t)(__state))
+
+#define	csio_set_state(__smp, __state)					\
+	(((struct csio_sm *)(__smp))->sm_state = (csio_sm_state_t)(__state))
+
+
+#define csio_post_event(__smp, __evt)					\
+	(((struct csio_sm *)(__smp))->sm_state((__smp), (uint32_t)(__evt)))
+
+#define	csio_get_state(__smp)	(((struct csio_sm *)(__smp))->sm_state)
+
+#define	csio_match_state(__smp, __state)				\
+	(csio_get_state((__smp)) == (csio_sm_state_t)(__state))
+
+#define	CSIO_ASSERT(cond)						\
+do {									\
+	if (unlikely(!((cond))))					\
+		BUG();                                                  \
+} while (0)
+
+#ifdef __CSIO_DEBUG__
+#define CSIO_DB_ASSERT(__c)		CSIO_ASSERT((__c))
+#else
+#define CSIO_DB_ASSERT(__c)
+#endif
+
+#endif /* ifndef __CSIO_DEFS_H__ */
diff --git a/drivers/scsi/csiostor/csio_fcoe_proto.h b/drivers/scsi/csiostor/csio_fcoe_proto.h
new file mode 100644
index 0000000..32e6f43
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_fcoe_proto.h
@@ -0,0 +1,843 @@
+/*
+ * This file is part of the Chelsio FCoE driver for Linux.
+ *
+ * Copyright (c) 2008-2012 Chelsio Communications, Inc. All rights reserved.
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
+#ifndef __CSIO_FCOE_PROTO_H__
+#define __CSIO_FCOE_PROTO_H__
+
+/* FC header type */
+#define FC_TYPE_ELS_DATA	0x1
+#define FC_TYPE_CT_DATA		0x20
+#define FC_TYPE_FCP_DATA	0x8
+
+/* FC header rctl */
+#define FC_RCTL_ELS_REQ		0x22
+#define FC_RCTL_ELS_RSP		0x23
+#define FC_RCTL_FCP_CMND	0x6
+
+/* Well known Fibre channel Address */
+#define FDMI_DID	0xFFFFFA	/* Management server */
+#define NS_DID		0xFFFFFC	/* Name server */
+#define FABCTL_DID	0xFFFFFD	/* Fabric Controller */
+#define FABRIC_DID	0xFFFFFE	/* Fabric Login */
+#define BCAST_DID	0xFFFFFF	/* Broadcast */
+#define UNKNOWN_DID	0x000000	/* Unknown DID */
+#define DID_MASK	0xFFFFFF	/* DID Mask */
+#define WK_DID_MASK	0xFFFFF0	/* Well known did mask */
+
+/* FC4 Device Data Frame - TYPE */
+#define FC4_FCP_TYPE	0x8		/* FCP */
+
+/* MAX FC Payload */
+#define MAX_FC_PAYLOAD	2112
+
+/*Service option: Shift & Mask bits defines */
+#define SP_CLASS_SUPPORT_EN	1	/* Class support enable */
+#define S_SP_CLASS_SUPPORT	7
+#define M_SP_CLASS_SUPPORT	1
+#define V_SP_CLASS_SUPPORT(x)	((x) << S_SP_CLASS_SUPPORT)
+#define G_SP_CLASS_SUPPORT(x)		\
+		(((x) >> S_SP_CLASS_SUPPORT) & M_SP_CLASS_SUPPORT)
+
+/* Class service parameters */
+struct csio_class_sp {
+	uint8_t		serv_option;		/* Service option */
+	uint8_t		rsvd1;
+	uint8_t		init_ctl_option;	/* initiator cntl option */
+	uint8_t		rsvd2;
+	uint8_t		rcv_ctl_option;		/* receiver cntl option */
+	uint8_t		rsvd3;
+	uint16_t	rcv_data_sz;		/* receive data size */
+	uint16_t	concurrent_seq;		/* Total concurent sequence */
+	uint16_t	ee_credit;		/* EE credit */
+	uint16_t	openseq_per_xchg;	/* Open sequence per exch */
+	uint16_t	rsvd4;
+};
+
+/* Common service parameters defines */
+
+/* FC Phy version */
+#define FC_PH_VER3			0x20
+
+/* WORD1 (31:16) flags: shift & mask bit defines */
+/* NPIV support */
+#define MULTIPLE_NPORT_ID_SUPPORT_EN	1
+#define S_MULTIPLE_NPORT_ID_SUPPORT	15
+#define M_MULTIPLE_NPORT_ID_SUPPORT	1
+#define V_MULTIPLE_NPORT_ID_SUPPORT(x)	((x) << S_MULTIPLE_NPORT_ID_SUPPORT)
+#define G_MULTIPLE_NPORT_ID_SUPPORT(x)	(((x) >> S_MULTIPLE_NPORT_ID_SUPPORT) \
+					 & M_MULTIPLE_NPORT_ID_SUPPORT)
+
+/* Continuously increasing relative offset */
+#define CONTI_INCR_OFFSET_SUPPORT_EN	1
+#define S_CONTI_INCR_OFFSET_SUPPORT	15
+#define M_CONTI_INCR_OFFSET_SUPPORT	1
+#define V_CONTI_INCR_OFFSET_SUPPORT(x)	((x) << S_CONTI_INCR_OFFSET_SUPPORT)
+#define G_CONTI_INCR_OFFSET_SUPPORT(x)	(((x) >> S_CONTI_INCR_OFFSET_SUPPORT) \
+					 & M_CONTI_INCR_OFFSET_SUPPORT)
+/* Continuously increasing relative offset */
+#define CLEAN_ADDR_EN		1
+#define S_CLEAN_ADDR		15
+#define M_CLEAN_ADDR		1
+#define V_CLEAN_ADDR(x)		((x) << S_CLEAN_ADDR)
+#define G_CLEAN_ADDR(x)		(((x) >> S_CLEAN_ADDR) & M_CLEAN_ADDR)
+
+/* NPIV supported by Fabric */
+#define NPIV_SUPPORTED_EN	1
+#define S_NPIV_SUPPORTED	13
+#define M_NPIV_SUPPORTED	1
+#define V_NPIV_SUPPORTED(x)	((x) << S_NPIV_SUPPORTED)
+#define G_NPIV_SUPPORTED(x)	(((x) >> S_NPIV_SUPPORTED) & M_NPIV_SUPPORTED)
+
+/* N_Port or F_Port */
+#define FABRIC_PORT			1
+#define S_FABRIC_PORT			12
+#define M_FABRIC_PORT			1
+#define V_FABRIC_PORT(x)		((x) << S_FABRIC_PORT)
+#define G_FABRIC_PORT(x)		(((x) >> S_FABRIC_PORT) & M_FABRIC_PORT)
+
+/* Alternate B2B credit management support */
+#define ALT_B2B_CREDIT_MGMT_SUPPORT_EN		1
+#define S_ALT_B2B_CREDIT_MGMT_SUPPORT		11
+#define M_ALT_B2B_CREDIT_MGMT_SUPPORT		1
+#define V_ALT_B2B_CREDIT_MGMT_SUPPORT(x)	\
+	((x) << S_ALT_B2B_CREDIT_MGMT_SUPPORT)
+#define G_ALT_B2B_CREDIT_MGMT_SUPPORT(x)	\
+	(((x) >> S_ALT_B2B_CREDIT_MGMT_SUPPORT) & M_ALT_B2B_CREDIT_MGMT_SUPPORT)
+
+
+/* WORD2 (31: 0) : shift and mask bit defines */
+#define S_MAX_SEQ_CNT		16
+#define M_MAX_SEQ_CNT		0xFFFF
+#define V_MAX_SEQ_CNT(x)	((x) << S_MAX_SEQ_CNT)
+#define G_MAX_SEQ_CNT(x)	(((x) >> S_MAX_SEQ_CNT) & M_MAX_SEQ_CNT)
+
+#define S_REL_OFFSET_BY_CATEGORY	0
+#define M_REL_OFFSET_BY_CATEGORY	0xFFFF
+#define V_REL_OFFSET_BY_CATEGORY(x)	((x) << S_REL_OFFSET_BY_CATEGORY)
+#define G_REL_OFFSET_BY_CATEGORY(x)	\
+	(((x) >> S_REL_OFFSET_BY_CATEGORY) & M_REL_OFFSET_BY_CATEGORY)
+
+/* Common service parameters */
+struct csio_cmn_sp {
+	uint8_t		hi_ver;		/* High PH version */
+	uint8_t		lo_ver;		/* low PH version */
+	uint16_t	bb_credit;	/* B2B credit */
+	uint16_t	word1_flags;	/* Word1 Flags (31:16)*/
+	uint16_t	rcv_sz;		/* Receive data size */
+	union {
+			uint32_t maxsq_reloff;	/* Max seq / Relative offset */
+			uint32_t r_a_tov;	/* R_A_TOV */
+	} un1;
+	uint32_t	e_d_tov;		/*E_D_TOV */
+};
+
+struct csio_service_parms {
+	struct csio_cmn_sp	csp;		/* Common service parms */
+	uint8_t			wwpn[8];	/* WWPN */
+	uint8_t			wwnn[8];	/* WWNN */
+	struct csio_class_sp	clsp[4];	/* Class service params */
+	uint8_t			vvl[16];	/* Vendor version level */
+};
+
+/* Common Transport (CT)  defines */
+#define CT_BASIC_IU_LEN		0x10
+#define CT_REVISION		0x1
+
+/* GS Types */
+#define CT_GS_MGMT_SERVICE		0xFA
+#define CT_GS_TIME_SERVICE		0xFB
+#define CT_GS_DIR_SERVICE		0xFC
+#define CT_GS_FABRIC_CNTL_SERVICE	0xFD
+
+/* Directory service Subtypes */
+#define CT_DIR_SERVICE_NAME_SERVER	0x02
+
+/* FDMI MGMT service Subtypes */
+#define CT_FDMI_HBA_MGMT_SERVER		0x10
+
+/* CT Response code */
+#define CT_RESPONSE_FS_RJT		0x8001
+#define CT_RESPONSE_FS_ACC		0x8002
+
+/* CT Reason code */
+#define  CT_NO_ADDITIONAL_EXPLANATION	0x00
+#define  CT_INVALID_COMMAND		0x01
+#define  CT_INVALID_VERSION_LEVEL	0x02
+#define  CT_LOGICAL_ERROR		0x03
+#define  CT_INVALID_IU_SIZE		0x04
+#define  CT_LOGICAL_BUSY		0x05
+#define  CT_PROTOCOL_ERROR		0x07
+#define  CT_UNABLE_TO_PERFORM_CMD_REQ	0x09
+#define  CT_CMD_NOT_SUPPORTED		0x0B
+#define  CT_VENDOR_UNIQUE		0xff
+
+/* Name Server explanation for Reason code CT_UNABLE_TO_PERFORM_CMD_REQ */
+#define  CT_NS_PORT_ID_NOT_REG			0x01
+#define  CT_NS_PORT_NAME_NOT_REG		0x02
+#define  CT_NS_NODE_NAME_NOT_REG		0x03
+#define  CT_NS_CLASS_OF_SERVICE_NOT_REG		0x04
+#define  CT_NS_IP_ADDRESS_NOT_REG		0x05
+#define  CT_NS_IPA_NOT_REG			0x06
+#define  CT_NS_FC4_TYPES_NOT_REG		0x07
+#define  CT_NS_SYMBOLIC_PORT_NAME_NOT_REG	0x08
+#define  CT_NS_SYMBOLIC_NODE_NAME_NOT_REG	0x09
+#define  CT_NS_PORT_TYPE_NOT_REG		0x0A
+#define  CT_NS_ACCESS_DENIED			0x10
+#define  CT_NS_INVALID_PORT_ID			0x11
+#define  CT_NS_DATABASE_EMPTY			0x12
+
+/* Name Server Command Codes */
+#define  CT_NS_GA_NXT	0x0100
+#define  CT_NS_GPN_ID	0x0112
+#define  CT_NS_GNN_ID	0x0113
+#define  CT_NS_GCS_ID	0x0114
+#define  CT_NS_GFT_ID	0x0117
+#define  CT_NS_GSPN_ID	0x0118
+#define  CT_NS_GPT_ID	0x011A
+#define  CT_NS_GFF_ID	0x011F
+#define  CT_NS_GID_PN	0x0121
+#define  CT_NS_GID_NN	0x0131
+#define  CT_NS_GIP_NN	0x0135
+#define  CT_NS_GIPA_NN	0x0136
+#define  CT_NS_GSNN_NN	0x0139
+#define  CT_NS_GNN_IP	0x0153
+#define  CT_NS_GIPA_IP	0x0156
+#define  CT_NS_GID_FT	0x0171
+#define  CT_NS_GPN_FT	0x0172
+#define  CT_NS_GID_PT	0x01A1
+#define  CT_NS_RPN_ID	0x0212
+#define  CT_NS_RNN_ID	0x0213
+#define  CT_NS_RCS_ID	0x0214
+#define  CT_NS_RFT_ID	0x0217
+#define  CT_NS_RSPN_ID	0x0218
+#define  CT_NS_RPT_ID	0x021A
+#define  CT_NS_RFF_ID	0x021F
+#define  CT_NS_RIP_NN	0x0235
+#define  CT_NS_RIPA_NN	0x0236
+#define  CT_NS_RSNN_NN	0x0239
+#define  CT_NS_DA_ID	0x0300
+
+/* FDMI HBA management Server Command Codes */
+#define  CT_FDMI_HBA_GRHL	0x100	/* Get registered HBA list */
+#define  CT_FDMI_HBA_GHAT	0x101	/* Get HBA attributes */
+#define  CT_FDMI_HBA_GRPL	0x102	/* Get registered Port list */
+#define  CT_FDMI_HBA_GPAT	0x110	/* Get Port attributes */
+#define  CT_FDMI_HBA_RHBA	0x200	/* Register HBA */
+#define  CT_FDMI_HBA_RHAT	0x201	/* Register HBA atttributes */
+#define  CT_FDMI_HBA_RPRT	0x210	/* Register Port */
+#define  CT_FDMI_HBA_RPA	0x211	/* Register Port attributes */
+#define  CT_FDMI_HBA_DHBA	0x300	/* De-register HBA */
+#define  CT_FDMI_HBA_DPRT	0x310	/* De-register Port */
+
+/* HBA Attribute Types */
+#define  NODE_NAME               0x1
+#define  MANUFACTURER            0x2
+#define  SERIAL_NUMBER           0x3
+#define  MODEL                   0x4
+#define  MODEL_DESCRIPTION       0x5
+#define  HARDWARE_VERSION        0x6
+#define  DRIVER_VERSION          0x7
+#define  OPTION_ROM_VERSION      0x8
+#define  FIRMWARE_VERSION        0x9
+#define  OS_NAME_VERSION         0xa
+#define  MAX_CT_PAYLOAD_LEN      0xb
+
+/* Port Attrubute Types */
+#define  SUPPORTED_FC4_TYPES     0x1
+#define  SUPPORTED_SPEED         0x2
+#define  PORT_SPEED              0x3
+#define  MAX_FRAME_LEN		 0x4
+#define  OS_DEVICE_NAME          0x5
+#define  HOST_NAME               0x6
+
+#define CSIO_HBA_PORTSPEED_1GBIT	0x0001  /* 1 GBit/sec */
+#define CSIO_HBA_PORTSPEED_2GBIT	0x0002  /* 2 GBit/sec */
+#define CSIO_HBA_PORTSPEED_4GBIT	0x0008  /* 4 GBit/sec */
+#define CSIO_HBA_PORTSPEED_10GBIT	0x0004  /* 10 GBit/sec */
+#define CSIO_HBA_PORTSPEED_8GBIT	0x0010  /* 8 GBit/sec */
+#define CSIO_HBA_PORTSPEED_16GBIT	0x0020  /* 16 GBit/sec */
+#define CSIO_HBA_PORTSPEED_UNKNOWN	0x0800  /* Unknown */
+
+/* Port Types */
+#define  CT_PORT_TYPE_N_PORT	0x01
+#define  CT_PORT_TYPE_NL_PORT	0x02
+#define  CT_PORT_TYPE_FNL_PORT	0x03
+#define  CT_PORT_TYPE_IP	0x04
+#define  CT_PORT_TYPE_FCP	0x08
+#define  CT_PORT_TYPE_NX_PORT	0x7F
+#define  CT_PORT_TYPE_F_PORT	0x81
+#define  CT_PORT_TYPE_FL_PORT	0x82
+#define  CT_PORT_TYPE_E_PORT	0x84
+
+/* FC4 Feature bit defination */
+#define FC4_FEATURE_TARGET_EN		1
+#define S_FC4_FEATURE_TARGET		0
+#define M_FC4_FEATURE_TARGET		1
+#define V_FC4_FEATURE_TARGET(x)		((x) << S_FC4_FEATURE_TARGET)
+#define G_FC4_FEATURE_TARGET(x)	\
+	(((x) >> S_FC4_FEATURE_TARGET) & M_FC4_FEATURE_TARGET)
+
+#define FC4_FEATURE_INITIATOR_EN	1
+#define S_FC4_FEATURE_INITIATOR		1
+#define M_FC4_FEATURE_INITIATOR		1
+#define V_FC4_FEATURE_INITIATOR(x)	((x) << S_FC4_FEATURE_INITIATOR)
+#define G_FC4_FEATURE_INITIATOR(x)	\
+	(((x) >> S_FC4_FEATURE_INITIATOR) & M_FC4_FEATURE_INITIATOR)
+
+/* GPN_FT ACC Control bit defination */
+#define GPN_FT_ACC_CONTROL_EN		1
+#define S_GPN_FT_ACC_CONTROL		31
+#define M_GPN_FT_ACC_CONTROL		1
+#define V_GPN_FT_ACC_CONTROL(x)		((x) << S_GPN_FT_ACC_CONTROL)
+#define G_GPN_FT_ACC_CONTROL(x)	\
+	(((x) >> S_GPN_FT_ACC_CONTROL) & M_GPN_FT_ACC_CONTROL)
+
+/* CT command */
+struct csio_ct_cmd {
+	uint8_t		rev;		/* Revision */
+	uint8_t		in_id[3];	/* Unused */
+	uint8_t		gs_type;	/* Type of service */
+	uint8_t		gs_subtype;	/* Sub type */
+	uint8_t		opt;		/* Options */
+	uint8_t		rsvd1;
+	uint16_t	op;		/* Command or response code */
+	uint16_t	size;		/* Maximum or Residual size */
+	uint8_t		rsvd2;
+	uint8_t		reason_code;	/* Reason code */
+	uint8_t		explanation;	/* Explanation code */
+	uint8_t		vendor_unique;	/* Vendor specific reason code */
+
+	union {
+		uint32_t port_id;	/* Port_id list for GID_FT ACC */
+
+		struct	gid_ft {
+			uint8_t port_type;	/* Port Type */
+			uint8_t	domain_scope;	/* Domain scope */
+			uint8_t	area_scope;	/* Area scope */
+			uint8_t	fc4_type;       /* FC4 Type = FCP(0x8) */
+		} gid_ft;
+
+		struct	gpn_ft {
+			uint8_t rsvd;
+			uint8_t	domain_scope;	/* Domain scope */
+			uint8_t	area_scope;	/* Area scope */
+			uint8_t	fc4_type;       /* FC4 Type = FCP(0x8) */
+		} gpn_ft;
+
+		/* Port_id & Port name list for GPN_FT ACC */
+		struct	gpn_ft_acc {
+			uint32_t port_id;	/* port id */
+			uint32_t rsvd;
+			uint8_t	 wwpn[8];	/* Port name */
+		} gpn_ft_acc;
+
+		struct	rft_id {
+			uint32_t port_id;	/* port id */
+			uint16_t rsvd1;
+			uint8_t	 fcp;		/* FCP Type */
+			uint8_t	 rsvd2;
+			uint8_t	 rsvd3[28];
+		} rft_id;
+
+		struct rnn_id {
+			uint32_t port_id;	/* Port id */
+			uint8_t	 wwnn[8];	/* Node name */
+		} rnn_id;
+
+		struct da_id {
+			uint32_t port_id;	/* Port id */
+		} da_id;
+
+		struct	rff_id {
+			uint32_t port_id;	/* Port id */
+			uint8_t  rsvd1[2];
+			uint8_t  fc4_fbits;	/* FC4 feature bits */
+			uint8_t  fc4_type;	/* FC4 Type = FCP(0x8) */
+		} rff_id;
+	} un;
+};
+
+#define csio_ct_rsp(cp)		(((struct csio_ct_cmd *) cp)->op)
+#define csio_ct_reason(cp)	(((struct csio_ct_cmd *) cp)->reason_code)
+#define csio_ct_expl(cp)	(((struct csio_ct_cmd *) cp)->explanation)
+#define csio_ct_get_pld(cp)	((void *)(((uint8_t *)cp) + CT_BASIC_IU_LEN))
+
+static inline void
+csio_fill_ct_iu(void *buf, uint8_t type, uint8_t sub_type,
+		uint16_t op)
+{
+	struct csio_ct_cmd *cmd = (struct csio_ct_cmd *) buf;
+	cmd->rev = CT_REVISION;
+	cmd->gs_type = type;
+	cmd->gs_subtype = sub_type;
+	cmd->op = op;
+}
+
+/* FDMI HBA cmd */
+
+/* Attribute entry */
+struct csio_attrib_entry {
+	uint16_t type;		/* Entry type */
+	uint16_t len;		/* Entry length */
+	union	{
+		uint8_t	string[256];	/* Attribute value in string */
+		uint32_t integer;	/* Attribute value in integer */
+	} val;
+};
+
+
+/* attribute block */
+struct csio_attrib_block {
+	uint32_t entry_count;		/* Entry count */
+	struct csio_attrib_entry entry; /* list of attributes */
+};
+
+/* HBA identifier */
+struct csio_hba_identifier {
+	uint8_t	 wwpn[8];	/* Port name */
+};
+
+/* Port entry */
+struct csio_port_entry {
+	uint8_t	 wwpn[8];	/* Port name */
+};
+
+/* register port list */
+struct csio_reg_port_list {
+	uint32_t entry_count;		/* Entry count */
+	struct csio_port_entry entry;	/* list of port entry */
+};
+
+/* register HBA */
+struct csio_reg_hba {
+	struct csio_hba_identifier id;		/* HBA identifier */
+	struct csio_reg_port_list port_list;	/* port entry list */
+};
+
+/* register HBA attributes */
+struct csio_reg_hba_attrib {
+	struct csio_hba_identifier id;		/* HBA identifier */
+	struct csio_attrib_block attrib_list;	/* Attribute list */
+};
+
+/* register Port attributes */
+struct csio_reg_port_attrib {
+	uint8_t	 wwpn[8];	/* Port name */
+	struct csio_attrib_block attrib_list; /* Attribute list */
+};
+
+/* Get register hba list(GRHL) accept payload */
+struct csio_grhl_acc_pld  {
+	uint32_t entry_count;		/* Entry count */
+	struct csio_hba_identifier id;	/* HBA identifier list */
+};
+
+/* Get register port list(GRPL) accept payload */
+struct csio_grpl_acc_pld  {
+	uint32_t entry_count;		/* Entry count */
+	struct csio_port_entry entry;	/* port entry list */
+};
+
+/* Get port attributes (GPAT) accept payload */
+struct csio_gpat_acc_pld  {
+	struct csio_attrib_block attrib_list; /* Attribute list */
+};
+
+/* ELS CMD HDR length */
+#define ELS_CMD_HDR_LEN		0x4
+
+/* ELS COMMAND CODES */
+#define ELS_CMD_CODE_MASK	0xff
+#define ELS_CMD_CODE_LS_RJT	0x01
+#define ELS_CMD_CODE_ACC	0x02
+#define ELS_CMD_CODE_PLOGI	0x03
+#define ELS_CMD_CODE_FLOGI	0x04
+#define ELS_CMD_CODE_LOGO	0x05
+#define ELS_CMD_CODE_RES	0x08
+#define ELS_CMD_CODE_RSS	0x09
+#define ELS_CMD_CODE_RSI	0x0A
+#define ELS_CMD_CODE_ESTS	0x0B
+#define ELS_CMD_CODE_ESTC	0x0C
+#define ELS_CMD_CODE_ADVC	0x0D
+#define ELS_CMD_CODE_RTV	0x0E
+#define ELS_CMD_CODE_RLS	0x0F
+#define ELS_CMD_CODE_ECHO	0x10
+#define ELS_CMD_CODE_TEST	0x11
+#define ELS_CMD_CODE_PRLI	0x20
+#define ELS_CMD_CODE_PRLO	0x21
+#define ELS_CMD_CODE_PDISC	0x50
+#define ELS_CMD_CODE_FDISC	0x51
+#define ELS_CMD_CODE_ADISC	0x52
+#define ELS_CMD_CODE_RPS	0x56
+#define ELS_CMD_CODE_RPL	0x57
+#define ELS_CMD_CODE_RSCN	0x61
+#define ELS_CMD_CODE_SCR	0x62
+#define ELS_CMD_CODE_RNID	0x78
+#define ELS_CMD_CODE_LIRR	0x7A
+
+/* LS_RJT reason codes */
+#define LS_RJT_INVALID_CMD     0x01
+#define LS_RJT_LOGICAL_ERR     0x03
+#define LS_RJT_LOGICAL_BSY     0x05
+#define LS_RJT_PROTOCOL_ERR    0x07
+#define LS_RJT_UNABLE_TPC      0x09
+#define LS_RJT_CMD_UNSUPPORTED 0x0B
+#define LS_RJT_VENDOR_UNIQUE   0xFF
+
+/* LS_RJT reason explanation */
+#define LS_RJT_EXPL_NONE	      0x00
+#define LS_RJT_EXPL_SPARM_OPTIONS     0x01
+#define LS_RJT_EXPL_SPARM_ICTL        0x03
+#define LS_RJT_EXPL_SPARM_RCTL        0x05
+#define LS_RJT_EXPL_SPARM_RCV_SIZE    0x07
+#define LS_RJT_EXPL_SPARM_CONCUR_SEQ  0x09
+#define LS_RJT_EXPL_SPARM_CREDIT      0x0B
+#define LS_RJT_EXPL_INVALID_PNAME     0x0D
+#define LS_RJT_EXPL_INVALID_NNAME     0x0E
+#define LS_RJT_EXPL_INVALID_CSP       0x0F
+#define LS_RJT_EXPL_INVALID_ASSOC_HDR 0x11
+#define LS_RJT_EXPL_ASSOC_HDR_REQ     0x13
+#define LS_RJT_EXPL_INVALID_O_SID     0x15
+#define LS_RJT_EXPL_INVALID_OX_RX     0x17
+#define LS_RJT_EXPL_CMD_IN_PROGRESS   0x19
+#define LS_RJT_EXPL_PORT_LOGIN_REQ    0x1E
+#define LS_RJT_EXPL_INVALID_NPORT_ID  0x1F
+#define LS_RJT_EXPL_INVALID_SEQ_ID    0x21
+#define LS_RJT_EXPL_INVALID_XCHG      0x23
+#define LS_RJT_EXPL_INACTIVE_XCHG     0x25
+#define LS_RJT_EXPL_RQ_REQUIRED       0x27
+#define LS_RJT_EXPL_OUT_OF_RESOURCE   0x29
+#define LS_RJT_EXPL_CANT_GIVE_DATA    0x2A
+#define LS_RJT_EXPL_REQ_UNSUPPORTED   0x2C
+
+/* PRLI Page and Payload length  */
+#define PRLI_PAGE_LEN		0x10
+#define PRLI_PAYLOAD_LEN	0x14
+
+/* PRLI/PRLO PROCESS FLAGS */
+/* Originator Proc Associator valid */
+#define PRLILO_ORG_PA_VALID		1
+#define S_PRLILO_ORG_PA_VALID		7
+#define M_PRLILO_ORG_PA_VALID		1
+#define V_PRLILO_ORG_PA_VALID(x)	((x) << S_PRLILO_ORG_PA_VALID)
+#define G_PRLILO_ORG_PA_VALID(x)	\
+	(((x) >> S_PRLILO_ORG_PA_VALID) & M_PRLILO_ORG_PA_VALID)
+
+/* Responder Proc Associator valid */
+#define PRLILO_RSP_PA_VALID		1
+#define S_PRLILO_RSP_PA_VALID		6
+#define M_PRLILO_RSP_PA_VALID		1
+#define V_PRLILO_RSP_PA_VALID(x)	((x) << S_PRLILO_RSP_PA_VALID)
+#define G_PRLILO_RSP_PA_VALID(x)	\
+	(((x) >> S_PRLILO_RSP_PA_VALID) & M_PRLILO_RSP_PA_VALID)
+
+/* Image pair established */
+#define PRLILO_IMG_PAIR_ESTB		1
+#define S_PRLILO_IMG_PAIR_ESTB		5
+#define M_PRLILO_IMG_PAIR_ESTB		1
+#define V_PRLILO_IMG_PAIR_ESTB(x)	((x) << S_PRLILO_IMG_PAIR_ESTB)
+#define G_PRLILO_IMG_PAIR_ESTB(x)	\
+	(((x) >> S_PRLILO_IMG_PAIR_ESTB) & M_PRLILO_IMG_PAIR_ESTB)
+
+/* PRLI Response code  */
+#define PRLI_RSP_CODE
+#define S_PRLI_RSP		0
+#define M_PRLI_RSP		0xf
+#define V_PRLI_RSP(x)	((x) << S_PRLI_RSP)
+#define G_PRLI_RSP(x)	\
+	(((x) >> S_PRLI_RSP) & M_PRLI_RSP)
+
+/* PRLI Service Parameter flags */
+/* FCP Write xfer ready disabled */
+#define PRLI_FCP_WRITE_XFER_RD_DIS	1
+#define S_PRLI_FCP_WRITE_XFER_RD_DIS	0
+#define M_PRLI_FCP_WRITE_XFER_RD_DIS	1
+#define V_PRLI_FCP_WRITE_XFER_RD_DIS(x)	((x) << S_PRLI_FCP_WRITE_XFER_RD_DIS)
+#define G_PRLI_FCP_WRITE_XFER_RD_DIS(x)	\
+	(((x) >> S_PRLI_FCP_WRITE_XFER_RD_DIS) & M_PRLI_FCP_WRITE_XFER_RD_DIS)
+
+/* FCP read xfer ready disabled */
+#define PRLI_FCP_READ_XFER_RD_DIS	1
+#define S_PRLI_FCP_READ_XFER_RD_DIS	1
+#define M_PRLI_FCP_READ_XFER_RD_DIS	1
+#define V_PRLI_FCP_READ_XFER_RD_DIS(x)	((x) << S_PRLI_FCP_READ_XFER_RD_DIS)
+#define G_PRLI_FCP_READ_XFER_RD_DIS(x)	\
+	(((x) >> S_PRLI_FCP_READ_XFER_RD_DIS) & M_PRLI_FCP_READ_XFER_RD_DIS)
+
+/* FCP data response mix disabled */
+#define PRLI_FCP_DATA_RSP_MIX_DIS	1
+#define S_PRLI_FCP_DATA_RSP_MIX_DIS	2
+#define M_PRLI_FCP_DATA_RSP_MIX_DIS	1
+#define V_PRLI_FCP_DATA_RSP_MIX_DIS(x)	((x) << S_PRLI_FCP_DATA_RSP_MIX_DIS)
+#define G_PRLI_FCP_DATA_RSP_MIX_DIS(x)	\
+	(((x) >> S_PRLI_FCP_DATA_RSP_MIX_DIS) & M_PRLI_FCP_DATA_RSP_MIX_DIS)
+
+/* FCP cmd data mix disabled */
+#define PRLI_FCP_CMD_DATA_MIX_DIS	1
+#define S_PRLI_FCP_CMD_DATA_MIX_DIS	3
+#define M_PRLI_FCP_CMD_DATA_MIX_DIS	1
+#define V_PRLI_FCP_CMD_DATA_MIX_DIS(x)	((x) << S_PRLI_FCP_CMD_DATA_MIX_DIS)
+#define G_PRLI_FCP_CMD_DATA_MIX_DIS(x)	\
+	(((x) >> S_PRLI_FCP_CMD_DATA_MIX_DIS) & M_PRLI_FCP_CMD_DATA_MIX_DIS)
+
+/* FCP Target function */
+#define PRLI_FCP_TARGET_FUNC		1
+#define S_PRLI_FCP_TARGET_FUNC		4
+#define M_PRLI_FCP_TARGET_FUNC		1
+#define V_PRLI_FCP_TARGET_FUNC(x)	((x) << S_PRLI_FCP_TARGET_FUNC)
+#define G_PRLI_FCP_TARGET_FUNC(x)	\
+	(((x) >> S_PRLI_FCP_TARGET_FUNC) & M_PRLI_FCP_TARGET_FUNC)
+
+/* FCP Initiator function */
+#define PRLI_FCP_INITIATOR_FUNC		1
+#define S_PRLI_FCP_INITIATOR_FUNC	5
+#define M_PRLI_FCP_INITIATOR_FUNC	1
+#define V_PRLI_FCP_INITIATOR_FUNC(x)	((x) << S_PRLI_FCP_INITIATOR_FUNC)
+#define G_PRLI_FCP_INITIATOR_FUNC(x)	\
+	(((x) >> S_PRLI_FCP_INITIATOR_FUNC) & M_PRLI_FCP_INITIATOR_FUNC)
+
+/* FCP Data overlay */
+#define PRLI_FCP_DATA_OVERLAY		1
+#define S_PRLI_FCP_DATA_OVERLAY		6
+#define M_PRLI_FCP_DATA_OVERLAY		1
+#define V_PRLI_FCP_DATA_OVERLAY(x)	((x) << S_PRLI_FCP_DATA_OVERLAY)
+#define G_PRLI_FCP_DATA_OVERLAY(x)	\
+	(((x) >> S_PRLI_FCP_DATA_OVERLAY) & M_PRLI_FCP_DATA_OVERLAY)
+
+/* FCP confirmed completion */
+#define PRLI_FCP_CONF_COMPL_ALLOWED	 1
+#define S_PRLI_FCP_CONF_COMPL_ALLOWED	 7
+#define M_PRLI_FCP_CONF_COMPL_ALLOWED	 1
+#define V_PRLI_FCP_CONF_COMPL_ALLOWED(x) ((x) << S_PRLI_FCP_CONF_COMPL_ALLOWED)
+#define G_PRLI_FCP_CONF_COMPL_ALLOWED(x)	\
+	(((x) >> S_PRLI_FCP_CONF_COMPL_ALLOWED) & M_PRLI_FCP_CONF_COMPL_ALLOWED)
+
+/* FCP retry */
+#define PRLI_FCP_RETRY		1
+#define S_PRLI_FCP_RETRY	8
+#define M_PRLI_FCP_RETRY	1
+#define V_PRLI_FCP_RETRY(x)	((x) << S_PRLI_FCP_RETRY)
+#define G_PRLI_FCP_RETRY(x)	(((x) >> S_PRLI_FCP_RETRY) & M_PRLI_FCP_RETRY)
+
+/* FCP Task retry id request */
+#define PRLI_FCP_TASK_ID_REQ		1
+#define S_PRLI_FCP_TASK_ID_REQ		9
+#define M_PRLI_FCP_TASK_ID_REQ		1
+#define V_PRLI_FCP_TASK_ID_REQ(x)	((x) << S_PRLI_FCP_TASK_ID_REQ)
+#define G_PRLI_FCP_TASK_ID_REQ(x)	\
+	(((x) >> S_PRLI_FCP_TASK_ID_REQ) & M_PRLI_FCP_TASK_ID_REQ)
+
+/* SCR Function */
+#define SCR_FUNCTION_FABRIC	0x01
+#define SCR_FUNCTION_NPORT	0x02
+#define SCR_FUNCTION_FULL	0x03
+#define SCR_FUNCTION_CLEAR	0xFF
+
+/* PRLI accept response code */
+#define PRLI_REQ_COMPLETED		0x1
+#define PRLI_RES_UNAVAIL		0x2
+#define PRLI_INIT_NOT_COMPLETE		0x3
+#define PRLI_RESP_PA_NO_FOUND		0x4
+#define PRLI_REQ_CONDITIONAL		0x5
+#define PRLI_RECP_PRECONFIG		0x6
+#define PRLI_MULTIPAGE_REQ_FAILED	0x7
+#define PRLI_INVALID_SP			0x8
+
+
+/* MAX RETIRES */
+#define MAX_ELS_RETRY		3
+#define ECM_MIN_TMO		1000	/* Minimum timeout value for req */
+
+/* ELS request */
+struct csio_els_cmd {
+	uint8_t	op;	/* ELS command code*/
+	uint8_t byte1;
+	uint8_t	byte2;
+	uint8_t	byte3;
+
+	union {
+		struct ls_rjt {
+			uint8_t	rsvd1;
+			uint8_t	reason_code;	/* Reason code */
+			uint8_t	reason_exp;	/* Explanation */
+			uint8_t vendor_unique;	/* Vendor unique code */
+		} ls_rjt;
+
+		struct ls_logi {
+			/* Service Parameters */
+			struct csio_service_parms sp;
+		} ls_logi;
+
+		struct logo {
+			uint32_t nport_id;	/* NPort Id */
+			uint8_t	 wwpn[8];	/* Port name */
+		} logo;
+
+		struct prli {
+			uint8_t	 type;		/* Type code */
+			uint8_t	 rsvd1;
+			uint8_t	 proc_flags;	/* Process Flags */
+			uint8_t  rsvd2;
+
+			/* Originator Process Associator */
+			uint32_t ori_proc_assoc;
+
+			/* Responder Process Associator */
+			uint32_t rsp_proc_assoc;
+
+			/* Service parameter flags */
+			uint32_t serv_parms_flags;
+		} prli;
+
+		struct prlo {
+			uint8_t	 type;		/* Type code */
+			uint8_t	 rsvd1;
+			uint8_t	 proc_flags;	/* Process flags */
+			uint8_t  rsvd2;
+
+			/* Originator Process Associator */
+			uint32_t ori_proc_assoc;
+
+			/* Responder Process Associator */
+			uint32_t rsp_proc_assoc;
+			uint32_t rsvd3;
+		} prlo;
+
+		struct adisc {
+			uint32_t hard_addr;	/* Hard address of originator */
+			uint8_t	 wwpn[8];	/* Port name */
+			uint8_t	 wwnn[8];	/* Node name */
+			uint32_t nport_id;	/* Nport id */
+		} adisc;
+
+		struct scr {
+			uint8_t	rsvd[3];
+			uint8_t	func;		/* SCR Function */
+		} scr;
+
+		struct rscn {
+			uint32_t nport_id;	/* Nport id list */
+		} rscn;
+	} un;
+};
+
+/* FCP defines */
+/*
+ * pri_ta.
+ */
+#define FCP_PTA_SIMPLE		0x0		/* simple queue tag */
+#define FCP_PTA_HEADQ		0x1		/* head of queue tag */
+#define FCP_PTA_ORDERED		0x2		/* ordered task attribute */
+#define FCP_PTA_ACA		0x4		/* auto. contigent allegiance */
+#define FCP_PTA_UNTAGGED	0x5
+
+#define FCP_PRI_SHIFT		3		/* priority field starts
+						 * in bit 3
+						 */
+#define FCP_PRI_RESVD_MASK	0x80		/* reserved bits in priority
+						 * field
+						 */
+
+/*
+ * tm_flags - task management flags field.
+ */
+#define FCP_TMF_ABT_TASK_SET    0x02		/* abort task set */
+#define FCP_TMF_CLR_TASK_SET    0x04		/* clear task set */
+#define FCP_TMF_BUS_RESET       0x08		/* bus reset */
+#define FCP_TMF_LUN_RESET       0x10		/* LUN reset */
+#define FCP_TMF_TGT_RESET       0x20		/* Target reset */
+#define FCP_TMF_CLR_ACA         0x40		/* clear ACA condition */
+#define FCP_TMF_TERM_TASK       0x80		/* Terminate task */
+
+/*
+ * flags.
+ * Bits 7:2 are the additional FCP_CDB length / 4.
+ */
+#define FCP_CFL_LEN_MASK        0xfc    /* mask for additional length */
+#define FCP_CFL_LEN_SHIFT       2       /* shift bits for additional length */
+#define FCP_CFL_RDDATA          0x02    /* read data */
+#define FCP_CFL_WRDATA          0x01    /* write data */
+
+struct csio_fcp_cmnd {
+	uint8_t		lun[8];			/* logical unit number */
+	uint8_t		cmdref;			/* commmand reference number */
+	uint8_t		pri_ta;			/* priority and task
+						 * attribute
+						 */
+	uint8_t		tm_flags;		/* task management flags */
+	uint8_t		flags;			/* additional len & flags */
+	uint8_t		cdb[16];		/* CDB */
+	uint32_t	dl;			/* data length */
+};
+
+/* Response Flags */
+#define FCP_BIDI_RSP		0x80		/* bidirectional read rsp */
+#define FCP_BIDI_READ_UNDER	0x40		/* bidi read underrun */
+#define FCP_BIDI_READ_OVER	0x20		/* bidi read overrun */
+#define FCP_CONF_REQ		0x10		/* confirmation requested */
+#define FCP_RESID_UNDER		0x08		/* transfer shorter than
+						 * expected
+						 */
+#define FCP_RESID_OVER		0x04		/* DL insufficient for
+						 * full transfer
+						 */
+#define FCP_SNS_LEN_VAL		0x02		/* SNS_LEN field is valid */
+#define FCP_RSP_LEN_VAL		0x01		/* RSP_LEN field is valid */
+
+/* Response codes */
+#define FCP_TMF_CMPL		0x00
+#define FCP_DATA_LEN_INVALID	0x01
+#define FCP_CMND_FIELDS_INVALID 0x02
+#define FCP_DATA_PARAM_MISMATCH	0x03
+#define FCP_TMF_REJECTED	0x04
+#define FCP_TMF_FAILED		0x05
+#define FCP_TMF_SUCCEEDED	0x05
+#define FCP_TMF_INVALID_LUN	0x09
+
+struct csio_fcp_resp {
+	uint8_t		rsvd0[8];
+	uint16_t	retry_delay;		/* retry delay timer */
+	uint8_t		flags;			/* flags */
+	uint8_t		scsi_status;		/* SCSI status code */
+	uint32_t	resid;			/* Residual bytes */
+	uint32_t	sns_len;		/* Length of sense data */
+	uint32_t	rsp_len;		/* Length of response */
+	uint8_t		rsvd1;
+	uint8_t		rsvd2;
+	uint8_t		rsvd3;
+	uint8_t		rsp_code;		/* Response code */
+	uint8_t		sns_data[128];
+};
+
+#endif /* __CSIO_FCOE_PROTO_H__ */
diff --git a/drivers/scsi/csiostor/csio_hw.h b/drivers/scsi/csiostor/csio_hw.h
new file mode 100644
index 0000000..00b78db
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_hw.h
@@ -0,0 +1,668 @@
+/*
+ * This file is part of the Chelsio FCoE driver for Linux.
+ *
+ * Copyright (c) 2008-2012 Chelsio Communications, Inc. All rights reserved.
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
+#ifndef __CSIO_HW_H__
+#define __CSIO_HW_H__
+
+#include <linux/kernel.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/workqueue.h>
+#include <linux/compiler.h>
+#include <linux/cdev.h>
+#include <linux/list.h>
+#include <linux/mempool.h>
+#include <linux/io.h>
+#include <linux/spinlock_types.h>
+#include <scsi/scsi_transport_fc.h>
+
+#include "csio_wr.h"
+#include "csio_mb.h"
+#include "csio_scsi.h"
+#include "csio_defs.h"
+#include "t4_regs.h"
+#include "t4_msg.h"
+
+/*
+ * An error value used by host. Should not clash with FW defined return values.
+ */
+#define	FW_HOSTERROR			255
+
+#define CSIO_FW_FNAME		"cxgb4/t4fw.bin"
+#define CSIO_CF_FNAME		"cxgb4/t4-config.txt"
+
+#define FW_VERSION_MAJOR	1
+#define FW_VERSION_MINOR	2
+#define FW_VERSION_MICRO	8
+
+#define CSIO_HW_NAME		"Chelsio FCoE Adapter"
+#define CSIO_MAX_PFN		8
+#define CSIO_MAX_PPORTS		4
+
+#define CSIO_MAX_LUN		0xFFFF
+#define CSIO_MAX_QUEUE		2048
+#define CSIO_MAX_CMD_PER_LUN	32
+#define CSIO_MAX_DDP_BUF_SIZE	(1024 * 1024)
+#define CSIO_MAX_SECTOR_SIZE	128
+
+/* Interrupts */
+#define CSIO_EXTRA_MSI_IQS	2	/* Extra iqs for INTX/MSI mode
+					 * (Forward intr iq + fw iq) */
+#define CSIO_EXTRA_VECS		2	/* non-data + FW evt */
+#define CSIO_MAX_SCSI_CPU	128
+#define CSIO_MAX_SCSI_QSETS	(CSIO_MAX_SCSI_CPU * CSIO_MAX_PPORTS)
+#define CSIO_MAX_MSIX_VECS	(CSIO_MAX_SCSI_QSETS + CSIO_EXTRA_VECS)
+
+/* Queues */
+enum {
+	CSIO_INTR_WRSIZE = 128,
+	CSIO_INTR_IQSIZE = ((CSIO_MAX_MSIX_VECS + 1) * CSIO_INTR_WRSIZE),
+	CSIO_FWEVT_WRSIZE = 128,
+	CSIO_FWEVT_IQLEN = 128,
+	CSIO_FWEVT_FLBUFS = 64,
+	CSIO_FWEVT_IQSIZE = (CSIO_FWEVT_WRSIZE * CSIO_FWEVT_IQLEN),
+	CSIO_HW_NIQ = 1,
+	CSIO_HW_NFLQ = 1,
+	CSIO_HW_NEQ = 1,
+	CSIO_HW_NINTXQ = 1,
+};
+
+struct csio_msix_entries {
+	unsigned short	vector;		/* Vector assigned by pci_enable_msix */
+	void		*dev_id;	/* Priv object associated w/ this msix*/
+	char		desc[24];	/* Description of this vector */
+};
+
+struct csio_scsi_qset {
+	int		iq_idx;		/* Ingress index */
+	int		eq_idx;		/* Egress index */
+	uint32_t	intr_idx;	/* MSIX Vector index */
+};
+
+struct csio_scsi_cpu_info {
+	int16_t	max_cpus;
+};
+
+extern int csio_dbg_level;
+extern int csio_force_master;
+extern unsigned int csio_port_mask;
+extern int csio_msi;
+
+#define CSIO_VENDOR_ID				0x1425
+#define CSIO_ASIC_DEVID_PROTO_MASK		0xFF00
+#define CSIO_ASIC_DEVID_TYPE_MASK		0x00FF
+#define CSIO_FPGA				0xA000
+#define CSIO_T4_FCOE_ASIC			0x4600
+
+#define CSIO_GLBL_INTR_MASK		(CIM | MPS | PL | PCIE | MC | EDC0 | \
+					 EDC1 | LE | TP | MA | PM_TX | PM_RX | \
+					 ULP_RX | CPL_SWITCH | SGE | \
+					 ULP_TX | SF)
+
+/*
+ * Hard parameters used to initialize the card in the absence of a
+ * configuration file.
+ */
+enum {
+	/* General */
+	CSIO_SGE_DBFIFO_INT_THRESH	= 10,
+
+	CSIO_SGE_RX_DMA_OFFSET		= 2,
+
+	CSIO_SGE_FLBUF_SIZE1		= 65536,
+	CSIO_SGE_FLBUF_SIZE2		= 1536,
+	CSIO_SGE_FLBUF_SIZE3		= 9024,
+	CSIO_SGE_FLBUF_SIZE4		= 9216,
+	CSIO_SGE_FLBUF_SIZE5		= 2048,
+	CSIO_SGE_FLBUF_SIZE6		= 128,
+	CSIO_SGE_FLBUF_SIZE7		= 8192,
+	CSIO_SGE_FLBUF_SIZE8		= 16384,
+
+	CSIO_SGE_TIMER_VAL_0		= 5,
+	CSIO_SGE_TIMER_VAL_1		= 10,
+	CSIO_SGE_TIMER_VAL_2		= 20,
+	CSIO_SGE_TIMER_VAL_3		= 50,
+	CSIO_SGE_TIMER_VAL_4		= 100,
+	CSIO_SGE_TIMER_VAL_5		= 200,
+
+	CSIO_SGE_INT_CNT_VAL_0		= 1,
+	CSIO_SGE_INT_CNT_VAL_1		= 4,
+	CSIO_SGE_INT_CNT_VAL_2		= 8,
+	CSIO_SGE_INT_CNT_VAL_3		= 16,
+
+	/* Storage specific - used by FW_PFVF_CMD */
+	CSIO_WX_CAPS			= FW_CMD_CAP_PF, /* w/x all */
+	CSIO_R_CAPS			= FW_CMD_CAP_PF, /* r all */
+	CSIO_NVI			= 4,
+	CSIO_NIQ_FLINT			= 34,
+	CSIO_NETH_CTRL			= 32,
+	CSIO_NEQ			= 66,
+	CSIO_NEXACTF			= 32,
+	CSIO_CMASK			= FW_PFVF_CMD_CMASK_MASK,
+	CSIO_PMASK			= FW_PFVF_CMD_PMASK_MASK,
+};
+
+/* Slowpath events */
+enum csio_evt {
+	CSIO_EVT_FW  = 0,	/* FW event */
+	CSIO_EVT_MBX,		/* MBX event */
+	CSIO_EVT_SCN,		/* State change notification */
+	CSIO_EVT_DEV_LOSS,	/* Device loss event */
+	CSIO_EVT_MAX,		/* Max supported event */
+};
+
+#define CSIO_EVT_MSG_SIZE	512
+#define CSIO_EVTQ_SIZE		512
+
+/* Event msg  */
+struct csio_evt_msg {
+	struct list_head	list;	/* evt queue*/
+	enum csio_evt		type;
+	uint8_t			data[CSIO_EVT_MSG_SIZE];
+};
+
+enum {
+	EEPROMVSIZE    = 32768, /* Serial EEPROM virtual address space size */
+	SERNUM_LEN     = 16,    /* Serial # length */
+	EC_LEN         = 16,    /* E/C length */
+	ID_LEN         = 16,    /* ID length */
+	TRACE_LEN      = 112,   /* length of trace data and mask */
+};
+
+enum {
+	SF_PAGE_SIZE = 256,           /* serial flash page size */
+	SF_SEC_SIZE = 64 * 1024,      /* serial flash sector size */
+	SF_SIZE = SF_SEC_SIZE * 16,   /* serial flash size */
+};
+
+enum { MEM_EDC0, MEM_EDC1, MEM_MC };
+
+enum {
+	MEMWIN0_APERTURE = 2048,
+	MEMWIN0_BASE     = 0x1b800,
+	MEMWIN1_APERTURE = 32768,
+	MEMWIN1_BASE     = 0x28000,
+	MEMWIN2_APERTURE = 65536,
+	MEMWIN2_BASE     = 0x30000,
+};
+
+/* serial flash and firmware constants */
+enum {
+	SF_ATTEMPTS = 10,             /* max retries for SF operations */
+
+	/* flash command opcodes */
+	SF_PROG_PAGE    = 2,          /* program page */
+	SF_WR_DISABLE   = 4,          /* disable writes */
+	SF_RD_STATUS    = 5,          /* read status register */
+	SF_WR_ENABLE    = 6,          /* enable writes */
+	SF_RD_DATA_FAST = 0xb,        /* read flash */
+	SF_RD_ID	= 0x9f,	      /* read ID */
+	SF_ERASE_SECTOR = 0xd8,       /* erase sector */
+
+	FW_START_SEC = 8,             /* first flash sector for FW */
+	FW_END_SEC = 15,              /* last flash sector for FW */
+	FW_IMG_START = FW_START_SEC * SF_SEC_SIZE,
+	FW_MAX_SIZE = (FW_END_SEC - FW_START_SEC + 1) * SF_SEC_SIZE,
+
+	FLASH_CFG_MAX_SIZE    = 0x10000 , /* max size of the flash config file*/
+	FLASH_CFG_OFFSET      = 0x1f0000,
+	FLASH_CFG_START_SEC   = FLASH_CFG_OFFSET / SF_SEC_SIZE,
+	FPGA_FLASH_CFG_OFFSET = 0xf0000 , /* if FPGA mode, then cfg file is
+					   * at 1MB - 64KB */
+	FPGA_FLASH_CFG_START_SEC  = FPGA_FLASH_CFG_OFFSET / SF_SEC_SIZE,
+};
+
+/*
+ * Flash layout.
+ */
+#define FLASH_START(start)	((start) * SF_SEC_SIZE)
+#define FLASH_MAX_SIZE(nsecs)	((nsecs) * SF_SEC_SIZE)
+
+enum {
+	/*
+	 * Location of firmware image in FLASH.
+	 */
+	FLASH_FW_START_SEC = 8,
+	FLASH_FW_NSECS = 8,
+	FLASH_FW_START = FLASH_START(FLASH_FW_START_SEC),
+	FLASH_FW_MAX_SIZE = FLASH_MAX_SIZE(FLASH_FW_NSECS),
+
+};
+
+#undef FLASH_START
+#undef FLASH_MAX_SIZE
+
+/* Management module */
+enum {
+	CSIO_MGMT_EQ_WRSIZE = 512,
+	CSIO_MGMT_IQ_WRSIZE = 128,
+	CSIO_MGMT_EQLEN = 64,
+	CSIO_MGMT_IQLEN = 64,
+};
+
+#define CSIO_MGMT_EQSIZE	(CSIO_MGMT_EQLEN * CSIO_MGMT_EQ_WRSIZE)
+#define CSIO_MGMT_IQSIZE	(CSIO_MGMT_IQLEN * CSIO_MGMT_IQ_WRSIZE)
+
+/* mgmt module stats */
+struct csio_mgmtm_stats {
+	uint32_t	n_abort_req;		/* Total abort request */
+	uint32_t	n_abort_rsp;		/* Total abort response */
+	uint32_t	n_close_req;		/* Total close request */
+	uint32_t	n_close_rsp;		/* Total close response */
+	uint32_t	n_err;			/* Total Errors */
+	uint32_t	n_drop;			/* Total request dropped */
+	uint32_t	n_active;		/* Count of active_q */
+	uint32_t	n_cbfn;			/* Count of cbfn_q */
+};
+
+/* MGMT module */
+struct csio_mgmtm {
+	struct	csio_hw		*hw;		/* Pointer to HW moduel */
+	int			eq_idx;		/* Egress queue index */
+	int			iq_idx;		/* Ingress queue index */
+	int			msi_vec;	/* MSI vector */
+	struct list_head	active_q;	/* Outstanding ELS/CT */
+	struct list_head	abort_q;	/* Outstanding abort req */
+	struct list_head	cbfn_q;		/* Completion queue */
+	struct list_head	mgmt_req_freelist; /* Free poll of reqs */
+						/* ELSCT request freelist*/
+	struct timer_list	mgmt_timer;	/* MGMT timer */
+	struct csio_mgmtm_stats stats;		/* ELS/CT stats */
+};
+
+struct csio_adap_desc {
+	char model_no[16];
+	char description[32];
+};
+
+struct pci_params {
+	uint16_t   vendor_id;
+	uint16_t   device_id;
+	uint32_t   vpd_cap_addr;
+	uint16_t   speed;
+	uint8_t    width;
+};
+
+/* User configurable hw parameters */
+struct csio_hw_params {
+	uint32_t		sf_size;		/* serial flash
+							 * size in bytes
+							 */
+	uint32_t		sf_nsec;		/* # of flash sectors */
+	struct pci_params	pci;
+	uint32_t		log_level;		/* Module-level for
+							 * debug log.
+							 */
+};
+
+struct csio_vpd {
+	uint32_t cclk;
+	uint8_t ec[EC_LEN + 1];
+	uint8_t sn[SERNUM_LEN + 1];
+	uint8_t id[ID_LEN + 1];
+};
+
+struct csio_pport {
+	uint16_t	pcap;
+	uint8_t		portid;
+	uint8_t		link_status;
+	uint16_t	link_speed;
+	uint8_t		mac[6];
+	uint8_t		mod_type;
+	uint8_t		rsvd1;
+	uint8_t		rsvd2;
+	uint8_t		rsvd3;
+};
+
+/* fcoe resource information */
+struct csio_fcoe_res_info {
+	uint16_t	e_d_tov;
+	uint16_t	r_a_tov_seq;
+	uint16_t	r_a_tov_els;
+	uint16_t	r_r_tov;
+	uint32_t	max_xchgs;
+	uint32_t	max_ssns;
+	uint32_t	used_xchgs;
+	uint32_t	used_ssns;
+	uint32_t	max_fcfs;
+	uint32_t	max_vnps;
+	uint32_t	used_fcfs;
+	uint32_t	used_vnps;
+};
+
+/* HW State machine Events */
+enum csio_hw_ev {
+	CSIO_HWE_CFG = (uint32_t)1, /* Starts off the State machine */
+	CSIO_HWE_INIT,	         /* Config done, start Init      */
+	CSIO_HWE_INIT_DONE,      /* Init Mailboxes sent, HW ready */
+	CSIO_HWE_FATAL,		 /* Fatal error during initialization */
+	CSIO_HWE_PCIERR_DETECTED,/* PCI error recovery detetced */
+	CSIO_HWE_PCIERR_SLOT_RESET, /* Slot reset after PCI recoviery */
+	CSIO_HWE_PCIERR_RESUME,  /* Resume after PCI error recovery */
+	CSIO_HWE_QUIESCED,	 /* HBA quiesced */
+	CSIO_HWE_HBA_RESET,      /* HBA reset requested */
+	CSIO_HWE_HBA_RESET_DONE, /* HBA reset completed */
+	CSIO_HWE_FW_DLOAD,       /* FW download requested */
+	CSIO_HWE_PCI_REMOVE,     /* PCI de-instantiation */
+	CSIO_HWE_SUSPEND,        /* HW suspend for Online(hot) replacement */
+	CSIO_HWE_RESUME,         /* HW resume for Online(hot) replacement */
+	CSIO_HWE_MAX,		 /* Max HW event */
+};
+
+/* hw stats */
+struct csio_hw_stats {
+	uint32_t	n_evt_activeq;	/* Number of event in active Q */
+	uint32_t	n_evt_freeq;	/* Number of event in free Q */
+	uint32_t	n_evt_drop;	/* Number of event droped */
+	uint32_t	n_evt_unexp;	/* Number of unexpected events */
+	uint32_t	n_pcich_offline;/* Number of pci channel offline */
+	uint32_t	n_lnlkup_miss;  /* Number of lnode lookup miss */
+	uint32_t	n_cpl_fw6_msg;	/* Number of cpl fw6 message*/
+	uint32_t	n_cpl_fw6_pld;	/* Number of cpl fw6 payload*/
+	uint32_t	n_cpl_unexp;	/* Number of unexpected cpl */
+	uint32_t	n_mbint_unexp;	/* Number of unexpected mbox */
+					/* interrupt */
+	uint32_t	n_plint_unexp;	/* Number of unexpected PL */
+					/* interrupt */
+	uint32_t	n_plint_cnt;	/* Number of PL interrupt */
+	uint32_t	n_int_stray;	/* Number of stray interrupt */
+	uint32_t	n_err;		/* Number of hw errors */
+	uint32_t	n_err_fatal;	/* Number of fatal errors */
+	uint32_t	n_err_nomem;	/* Number of memory alloc failure */
+	uint32_t	n_err_io;	/* Number of IO failure */
+	enum csio_hw_ev	n_evt_sm[CSIO_HWE_MAX];	/* Number of sm events */
+	uint64_t	n_reset_start;  /* Start time after the reset */
+	uint32_t	rsvd1;
+};
+
+/* Defines for hw->flags */
+#define CSIO_HWF_MASTER			0x00000001	/* This is the Master
+							 * function for the
+							 * card.
+							 */
+#define	CSIO_HWF_HW_INTR_ENABLED	0x00000002	/* Are HW Interrupt
+							 * enable bit set?
+							 */
+#define	CSIO_HWF_FWEVT_PENDING		0x00000004	/* FW events pending */
+#define	CSIO_HWF_Q_MEM_ALLOCED		0x00000008	/* Queues have been
+							 * allocated memory.
+							 */
+#define	CSIO_HWF_Q_FW_ALLOCED		0x00000010	/* Queues have been
+							 * allocated in FW.
+							 */
+#define CSIO_HWF_VPD_VALID		0x00000020	/* Valid VPD copied */
+#define CSIO_HWF_DEVID_CACHED		0X00000040	/* PCI vendor & device
+							 * id cached */
+#define	CSIO_HWF_FWEVT_STOP		0x00000080	/* Stop processing
+							 * FW events
+							 */
+#define CSIO_HWF_USING_SOFT_PARAMS	0x00000100      /* Using FW config
+							 * params
+							 */
+#define	CSIO_HWF_HOST_INTR_ENABLED	0x00000200	/* Are host interrupts
+							 * enabled?
+							 */
+
+#define csio_is_hw_intr_enabled(__hw)	\
+				((__hw)->flags & CSIO_HWF_HW_INTR_ENABLED)
+#define csio_is_host_intr_enabled(__hw)	\
+				((__hw)->flags & CSIO_HWF_HOST_INTR_ENABLED)
+#define csio_is_hw_master(__hw)		((__hw)->flags & CSIO_HWF_MASTER)
+#define csio_is_valid_vpd(__hw)		((__hw)->flags & CSIO_HWF_VPD_VALID)
+#define csio_is_dev_id_cached(__hw)	((__hw)->flags & CSIO_HWF_DEVID_CACHED)
+#define csio_valid_vpd_copied(__hw)	((__hw)->flags |= CSIO_HWF_VPD_VALID)
+#define csio_dev_id_cached(__hw)	((__hw)->flags |= CSIO_HWF_DEVID_CACHED)
+
+/* Defines for intr_mode */
+enum csio_intr_mode {
+	CSIO_IM_NONE = 0,
+	CSIO_IM_INTX = 1,
+	CSIO_IM_MSI  = 2,
+	CSIO_IM_MSIX = 3,
+};
+
+/* Master HW structure: One per function */
+struct csio_hw {
+	struct csio_sm		sm;			/* State machine: should
+							 * be the 1st member.
+							 */
+	spinlock_t		lock;			/* Lock for hw */
+
+	struct csio_scsim	scsim;			/* SCSI module*/
+	struct csio_wrm		wrm;			/* Work request module*/
+	struct pci_dev		*pdev;			/* PCI device */
+
+	void __iomem		*regstart;		/* Virtual address of
+							 * register map
+							 */
+	/* SCSI queue sets */
+	uint32_t		num_sqsets;		/* Number of SCSI
+							 * queue sets */
+	uint32_t		num_scsi_msix_cpus;	/* Number of CPUs that
+							 * will be used
+							 * for ingress
+							 * processing.
+							 */
+
+	struct csio_scsi_qset	sqset[CSIO_MAX_PPORTS][CSIO_MAX_SCSI_CPU];
+	struct csio_scsi_cpu_info scsi_cpu_info[CSIO_MAX_PPORTS];
+
+	uint32_t		evtflag;		/* Event flag  */
+	uint32_t		flags;			/* HW flags */
+
+	struct csio_mgmtm	mgmtm;			/* management module */
+	struct csio_mbm		mbm;			/* Mailbox module */
+
+	/* Lnodes */
+	uint32_t		num_lns;		/* Number of lnodes */
+	struct csio_lnode	*rln;			/* Root lnode */
+	struct list_head	sln_head;		/* Sibling node list
+							 * list
+							 */
+	int			intr_iq_idx;		/* Forward interrupt
+							 * queue.
+							 */
+	int			fwevt_iq_idx;		/* FW evt queue */
+	struct work_struct	evtq_work;		/* Worker thread for
+							 * HW events.
+							 */
+	struct list_head	evt_free_q;		/* freelist of evt
+							 * elements
+							 */
+	struct list_head	evt_active_q;		/* active evt queue*/
+
+	/* board related info */
+	char			name[32];
+	char			hw_ver[16];
+	char			model_desc[32];
+	char			drv_version[32];
+	char			fwrev_str[32];
+	uint32_t		optrom_ver;
+	uint32_t		fwrev;
+	uint32_t		tp_vers;
+	char			chip_ver;
+	uint32_t		cfg_finiver;
+	uint32_t		cfg_finicsum;
+	uint32_t		cfg_cfcsum;
+	uint8_t			cfg_csum_status;
+	uint8_t			cfg_store;
+	enum csio_dev_state	fw_state;
+	struct csio_vpd		vpd;
+
+	uint8_t			pfn;			/* Physical Function
+							 * number
+							 */
+	uint32_t		port_vec;		/* Port vector */
+	uint8_t			num_pports;		/* Number of physical
+							 * ports.
+							 */
+	uint8_t			rst_retries;		/* Reset retries */
+	uint8_t			cur_evt;		/* current s/m evt */
+	uint8_t			prev_evt;		/* Previous s/m evt */
+	uint32_t		dev_num;		/* device number */
+	struct csio_pport	pport[CSIO_MAX_PPORTS];	/* Ports (XGMACs) */
+	struct csio_hw_params	params;			/* Hw parameters */
+
+	struct pci_pool		*scsi_pci_pool;		/* PCI pool for SCSI */
+	mempool_t		*mb_mempool;		/* Mailbox memory pool*/
+	mempool_t		*rnode_mempool;		/* rnode memory pool */
+
+	/* Interrupt */
+	enum csio_intr_mode	intr_mode;		/* INTx, MSI, MSIX */
+	uint32_t		fwevt_intr_idx;		/* FW evt MSIX/interrupt
+							 * index
+							 */
+	uint32_t		nondata_intr_idx;	/* nondata MSIX/intr
+							 * idx
+							 */
+
+	uint8_t			cfg_neq;		/* FW configured no of
+							 * egress queues
+							 */
+	uint8_t			cfg_niq;		/* FW configured no of
+							 * iq queues.
+							 */
+
+	struct csio_fcoe_res_info  fres_info;		/* Fcoe resource info */
+
+	/* MSIX vectors */
+	struct csio_msix_entries msix_entries[CSIO_MAX_MSIX_VECS];
+
+	struct dentry		*debugfs_root;		/* Debug FS */
+	struct csio_hw_stats	stats;			/* Hw statistics */
+};
+
+/* Register access macros */
+#define csio_reg(_b, _r)		((_b) + (_r))
+
+#define	csio_rd_reg8(_h, _r)		readb(csio_reg((_h)->regstart, (_r)))
+#define	csio_rd_reg16(_h, _r)		readw(csio_reg((_h)->regstart, (_r)))
+#define	csio_rd_reg32(_h, _r)		readl(csio_reg((_h)->regstart, (_r)))
+#define	csio_rd_reg64(_h, _r)		readq(csio_reg((_h)->regstart, (_r)))
+
+#define	csio_wr_reg8(_h, _v, _r)	writeb((_v), \
+						csio_reg((_h)->regstart, (_r)))
+#define	csio_wr_reg16(_h, _v, _r)	writew((_v), \
+						csio_reg((_h)->regstart, (_r)))
+#define	csio_wr_reg32(_h, _v, _r)	writel((_v), \
+						csio_reg((_h)->regstart, (_r)))
+#define	csio_wr_reg64(_h, _v, _r)	writeq((_v), \
+						csio_reg((_h)->regstart, (_r)))
+
+void csio_set_reg_field(struct csio_hw *, uint32_t, uint32_t, uint32_t);
+
+/* Core clocks <==> uSecs */
+static inline uint32_t
+csio_core_ticks_to_us(struct csio_hw *hw, uint32_t ticks)
+{
+	/* add Core Clock / 2 to round ticks to nearest uS */
+	return (ticks * 1000 + hw->vpd.cclk/2) / hw->vpd.cclk;
+}
+
+static inline uint32_t
+csio_us_to_core_ticks(struct csio_hw *hw, uint32_t us)
+{
+	return (us * hw->vpd.cclk) / 1000;
+}
+
+/* Easy access macros */
+#define csio_hw_to_wrm(hw)		((struct csio_wrm *)(&(hw)->wrm))
+#define csio_hw_to_mbm(hw)		((struct csio_mbm *)(&(hw)->mbm))
+#define csio_hw_to_scsim(hw)		((struct csio_scsim *)(&(hw)->scsim))
+#define csio_hw_to_mgmtm(hw)		((struct csio_mgmtm *)(&(hw)->mgmtm))
+
+#define csio_md(hw, idx)		(&(hw)->mem_descs[(idx)])
+
+#define CSIO_PCI_BUS(hw)		((hw)->pdev->bus->number)
+#define CSIO_PCI_DEV(hw)		(PCI_SLOT((hw)->pdev->devfn))
+#define CSIO_PCI_FUNC(hw)		(PCI_FUNC((hw)->pdev->devfn))
+
+#define csio_set_fwevt_intr_idx(_h, _i)		((_h)->fwevt_intr_idx = (_i))
+#define csio_get_fwevt_intr_idx(_h)		((_h)->fwevt_intr_idx)
+#define csio_set_nondata_intr_idx(_h, _i)	((_h)->nondata_intr_idx = (_i))
+#define csio_get_nondata_intr_idx(_h)		((_h)->nondata_intr_idx)
+
+/* Printing/logging */
+#define CSIO_DEVID(__dev)		((__dev)->dev_num)
+#define CSIO_DEVID_LO(__dev)		(CSIO_DEVID((__dev)) & 0xFFFF)
+#define CSIO_DEVID_HI(__dev)		((CSIO_DEVID((__dev)) >> 16) & 0xFFFF)
+
+#define csio_info(__hw, __fmt, ...)					\
+			dev_info(&(__hw)->pdev->dev, __fmt, ##__VA_ARGS__)
+
+#define csio_fatal(__hw, __fmt, ...)					\
+			dev_crit(&(__hw)->pdev->dev, __fmt, ##__VA_ARGS__)
+
+#define csio_err(__hw, __fmt, ...)					\
+			dev_err(&(__hw)->pdev->dev, __fmt, ##__VA_ARGS__)
+
+#define csio_warn(__hw, __fmt, ...)					\
+			dev_warn(&(__hw)->pdev->dev, __fmt, ##__VA_ARGS__)
+
+#ifdef __CSIO_DEBUG__
+#define csio_dbg(__hw, __fmt, ...)					\
+			csio_info((__hw), __fmt, ##__VA_ARGS__);
+#else
+#define csio_dbg(__hw, __fmt, ...)
+#endif
+
+csio_retval_t csio_mgmt_req_lookup(struct csio_mgmtm *, struct csio_ioreq *);
+void csio_hw_intr_disable(struct csio_hw *);
+int csio_hw_slow_intr_handler(struct csio_hw *hw);
+csio_retval_t csio_hw_start(struct csio_hw *);
+csio_retval_t csio_hw_stop(struct csio_hw *);
+csio_retval_t csio_hw_reset(struct csio_hw *);
+int csio_is_hw_ready(struct csio_hw *);
+int csio_is_hw_removing(struct csio_hw *);
+
+csio_retval_t csio_fwevtq_handler(struct csio_hw *);
+void csio_evtq_worker(struct work_struct *);
+csio_retval_t csio_enqueue_evt(struct csio_hw *hw, enum csio_evt type,
+				void *evt_msg, uint16_t len);
+void csio_evtq_flush(struct csio_hw *hw);
+
+csio_retval_t csio_request_irqs(struct csio_hw *);
+void csio_intr_enable(struct csio_hw *);
+void csio_intr_disable(struct csio_hw *, bool);
+
+struct csio_lnode *csio_lnode_alloc(struct csio_hw *);
+csio_retval_t csio_config_queues(struct csio_hw *);
+
+csio_retval_t csio_hw_mc_read(struct csio_hw *, uint32_t,
+			      uint32_t *, uint64_t *);
+csio_retval_t csio_hw_edc_read(struct csio_hw *, int, uint32_t, uint32_t *,
+			       uint64_t *);
+csio_retval_t csio_hw_init(struct csio_hw *);
+void csio_hw_exit(struct csio_hw *);
+#endif /* ifndef __CSIO_HW_H__ */
diff --git a/drivers/scsi/csiostor/csio_init.h b/drivers/scsi/csiostor/csio_init.h
new file mode 100644
index 0000000..0838fd7
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_init.h
@@ -0,0 +1,158 @@
+/*
+ * This file is part of the Chelsio FCoE driver for Linux.
+ *
+ * Copyright (c) 2008-2012 Chelsio Communications, Inc. All rights reserved.
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
+#ifndef __CSIO_INIT_H__
+#define __CSIO_INIT_H__
+
+#include <linux/pci.h>
+#include <linux/if_ether.h>
+#include <scsi/scsi.h>
+#include <scsi/scsi_device.h>
+#include <scsi/scsi_host.h>
+#include <scsi/scsi_transport_fc.h>
+
+#include "csio_scsi.h"
+#include "csio_lnode.h"
+#include "csio_rnode.h"
+#include "csio_hw.h"
+
+#define CSIO_DRV_AUTHOR			"Chelsio Communications"
+#define CSIO_DRV_LICENSE		"Dual BSD/GPL"
+#define CSIO_DRV_DESC			"Chelsio FCoE driver"
+#define CSIO_DRV_VERSION		"1.0.0"
+
+#define CSIO_DEVICE(devid, idx)					\
+{ PCI_VENDOR_ID_CHELSIO, (devid), PCI_ANY_ID, PCI_ANY_ID, 0, 0, (idx) }
+
+#define CSIO_IS_T4_FPGA(_dev)		(((_dev) == CSIO_DEVID_PE10K) ||\
+					 ((_dev) == CSIO_DEVID_PE10K_PF1))
+
+/* FCoE device IDs */
+#define CSIO_DEVID_PE10K		0xA000
+#define CSIO_DEVID_PE10K_PF1		0xA001
+#define CSIO_DEVID_T440DBG_FCOE		0x4600
+#define CSIO_DEVID_T420CR_FCOE		0x4601
+#define CSIO_DEVID_T422CR_FCOE		0x4602
+#define CSIO_DEVID_T440CR_FCOE		0x4603
+#define CSIO_DEVID_T420BCH_FCOE		0x4604
+#define CSIO_DEVID_T440BCH_FCOE		0x4605
+#define CSIO_DEVID_T440CH_FCOE		0x4606
+#define CSIO_DEVID_T420SO_FCOE		0x4607
+#define CSIO_DEVID_T420CX_FCOE		0x4608
+#define CSIO_DEVID_T420BT_FCOE		0x4609
+#define CSIO_DEVID_T404BT_FCOE		0x460A
+#define CSIO_DEVID_B420_FCOE		0x460B
+#define CSIO_DEVID_B404_FCOE		0x460C
+#define CSIO_DEVID_T480CR_FCOE		0x460D
+#define CSIO_DEVID_T440LPCR_FCOE	0x460E
+
+extern struct fc_function_template csio_fc_transport_funcs;
+extern struct fc_function_template csio_fc_transport_vport_funcs;
+
+void csio_fchost_attr_init(struct csio_lnode *);
+
+/* INTx handlers */
+void csio_scsi_intx_handler(struct csio_hw *, void *, uint32_t,
+			       struct csio_fl_dma_buf *, void *);
+
+void csio_fwevt_intx_handler(struct csio_hw *, void *, uint32_t,
+				struct csio_fl_dma_buf *, void *);
+
+/* Common os lnode APIs */
+void csio_lnodes_block_request(struct csio_hw *);
+void csio_lnodes_unblock_request(struct csio_hw *);
+void csio_lnodes_block_by_port(struct csio_hw *, uint8_t);
+void csio_lnodes_unblock_by_port(struct csio_hw *, uint8_t);
+
+struct csio_lnode *csio_shost_init(struct csio_hw *, struct device *, bool,
+					struct csio_lnode *);
+void csio_shost_exit(struct csio_lnode *);
+void csio_lnodes_exit(struct csio_hw *, bool);
+
+static inline struct Scsi_Host *
+csio_ln_to_shost(struct csio_lnode *ln)
+{
+	return container_of((void *)ln, struct Scsi_Host, hostdata[0]);
+}
+
+/* SCSI -- locking version of get/put ioreqs  */
+static inline struct csio_ioreq *
+csio_get_scsi_ioreq_lock(struct csio_hw *hw, struct csio_scsim *scsim)
+{
+	struct csio_ioreq *ioreq;
+	unsigned long flags;
+
+	spin_lock_irqsave(&scsim->freelist_lock, flags);
+	ioreq = csio_get_scsi_ioreq(scsim);
+	spin_unlock_irqrestore(&scsim->freelist_lock, flags);
+
+	return ioreq;
+}
+
+static inline void
+csio_put_scsi_ioreq_lock(struct csio_hw *hw, struct csio_scsim *scsim,
+			 struct csio_ioreq *ioreq)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&scsim->freelist_lock, flags);
+	csio_put_scsi_ioreq(scsim, ioreq);
+	spin_unlock_irqrestore(&scsim->freelist_lock, flags);
+}
+
+/* Called in interrupt context */
+static inline void
+csio_put_scsi_ioreq_list_lock(struct csio_hw *hw, struct csio_scsim *scsim,
+			      struct list_head *reqlist, int n)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&scsim->freelist_lock, flags);
+	csio_put_scsi_ioreq_list(scsim, reqlist, n);
+	spin_unlock_irqrestore(&scsim->freelist_lock, flags);
+}
+
+/* Called in interrupt context */
+static inline void
+csio_put_scsi_ddp_list_lock(struct csio_hw *hw, struct csio_scsim *scsim,
+			      struct list_head *reqlist, int n)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&hw->lock, flags);
+	csio_put_scsi_ddp_list(scsim, reqlist, n);
+	spin_unlock_irqrestore(&hw->lock, flags);
+}
+
+#endif /* ifndef __CSIO_INIT_H__ */
-- 
1.7.1

