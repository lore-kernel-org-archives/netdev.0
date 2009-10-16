From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 5/6] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 16 Oct 2009 11:24:56 -0700
Message-ID: <200910161824.n9GIOuZB010148@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amathur@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:36259 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007AbZJPSaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 14:30:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 5/6 which contains linux driver source for
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.

We wish this patch to be considered for inclusion in 2.6.32

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 bfa_callback_priv.h               |   64 +++
 bfa_fwimg_priv.h                  |   38 ++
 include/bfi/bfi.h                 |  181 +++++++++++
 include/bfi/bfi_boot.h            |   41 ++
 include/bfi/bfi_cee.h             |  119 +++++++
 include/bfi/bfi_ctreg.h           |  611 ++++++++++++++++++++++++++++++++++++++
 include/bfi/bfi_ioc.h             |  209 ++++++++++++
 include/bfi/bfi_ll.h              |  443 +++++++++++++++++++++++++++
 include/cee/bfa_cee.h             |   82 +++++
 include/cna/pstats/ethport_defs.h |   43 ++
 include/cna/pstats/phyport_defs.h |  225 +++++++++++++
 include/cs/bfa_debug.h            |   51 +++
 include/cs/bfa_q.h                |   88 +++++
 include/cs/bfa_sm.h               |   76 ++++
 include/cs/bfa_trc.h              |   67 ++++
 include/defs/bfa_defs_adapter.h   |   89 +++++
 include/defs/bfa_defs_cee.h       |  165 ++++++++++
 include/defs/bfa_defs_ioc.h       |  158 +++++++++
 include/defs/bfa_defs_mfg.h       |   65 ++++
 include/defs/bfa_defs_pci.h       |   48 ++
 include/defs/bfa_defs_status.h    |  262 ++++++++++++++++
 include/defs/bfa_defs_types.h     |   37 ++
 include/defs/bfa_defs_version.h   |   29 +
 include/protocol/types.h          |   49 +++
 24 files changed, 3240 insertions(+)

diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bfa_callback_priv.h linux-2.6.32-rc4-mod/drivers/net/bna/bfa_callback_priv.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bfa_callback_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bfa_callback_priv.h	2009-10-16 10:30:54.139395000 -0700
@@ -0,0 +1,64 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFA_CALLBACK_PRIV_H__
+#define __BFA_CALLBACK_PRIV_H__
+
+#include <cs/bfa_q.h>
+
+typedef void    (*bfa_cb_cbfn_t) (void *cbarg, bfa_boolean_t complete);
+
+/**
+ * Generic BFA callback element.
+ */
+struct bfa_cb_qe_s {
+	struct list_head         qe;
+	bfa_cb_cbfn_t  cbfn;
+	bfa_boolean_t   once;
+	u32		rsvd;
+	void           *cbarg;
+};
+
+#define bfa_cb_queue(__bfa, __hcb_qe, __cbfn, __cbarg) do {		\
+	(__hcb_qe)->cbfn  = (__cbfn);      \
+	(__hcb_qe)->cbarg = (__cbarg);      \
+	list_add_tail(&(__hcb_qe)->qe, &(__bfa)->comp_q);      \
+} while (0)
+
+#define bfa_cb_dequeue(__hcb_qe)	list_del(&(__hcb_qe)->qe)
+
+#define bfa_cb_queue_once(__bfa, __hcb_qe, __cbfn, __cbarg) do {	\
+	(__hcb_qe)->cbfn  = (__cbfn);      \
+	(__hcb_qe)->cbarg = (__cbarg);      \
+	if (!(__hcb_qe)->once) {      \
+		list_add_tail((__hcb_qe), &(__bfa)->comp_q);      \
+		(__hcb_qe)->once = BFA_TRUE;				\
+	}								\
+} while (0)
+
+#define bfa_cb_queue_done(__hcb_qe) do {				\
+	(__hcb_qe)->once = BFA_FALSE;					\
+} while (0)
+
+#endif /* __BFA_CALLBACK_PRIV_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bfa_fwimg_priv.h linux-2.6.32-rc4-mod/drivers/net/bna/bfa_fwimg_priv.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bfa_fwimg_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bfa_fwimg_priv.h	2009-10-16 10:30:54.154383000 -0700
@@ -0,0 +1,38 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFA_FWIMG_PRIV_H__
+#define __BFA_FWIMG_PRIV_H__
+
+#define	BFI_FLASH_CHUNK_SZ		256	/*  Flash chunk size */
+#define	BFI_FLASH_CHUNK_SZ_WORDS	(BFI_FLASH_CHUNK_SZ/sizeof(u32))
+
+extern u32 *bfi_image_ct_get_chunk(u32 off);
+extern u32 bfi_image_ct_size;
+extern u32 *bfi_image_cb_get_chunk(u32 off);
+extern u32 bfi_image_cb_size;
+extern u32 *bfi_image_cb;
+extern u32 *bfi_image_ct;
+
+#endif /* __BFA_FWIMG_PRIV_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/bfi/bfi_boot.h linux-2.6.32-rc4-mod/drivers/net/bna/include/bfi/bfi_boot.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/bfi/bfi_boot.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/bfi/bfi_boot.h	2009-10-16 10:30:54.209379000 -0700
@@ -0,0 +1,41 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+/*
+ * bfi_boot.h
+ */
+
+#ifndef __BFI_BOOT_H__
+#define __BFI_BOOT_H__
+
+#define BFI_BOOT_TYPE_OFF		8
+#define BFI_BOOT_PARAM_OFF		12
+
+#define BFI_BOOT_TYPE_NORMAL 		0	/* param is device id */
+#define	BFI_BOOT_TYPE_FLASH		1
+#define	BFI_BOOT_TYPE_MEMTEST		2
+
+#define BFI_BOOT_MEMTEST_RES_ADDR   0x900
+#define BFI_BOOT_MEMTEST_RES_SIG    0xA0A1A2A3
+
+#endif
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/bfi/bfi_cee.h linux-2.6.32-rc4-mod/drivers/net/bna/include/bfi/bfi_cee.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/bfi/bfi_cee.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/bfi/bfi_cee.h	2009-10-16 10:30:54.240367000 -0700
@@ -0,0 +1,119 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/**
+ *  Copyright (c) 2006-2009 Brocade Communications Systems, Inc.
+ *  All rights reserved.
+ *
+ *  bfi_dcbx.h BFI Interface (Mailbox commands and related structures)
+ * between host driver and DCBX/LLDP firmware module.
+ *
+**/
+
+#ifndef __BFI_CEE_H__
+#define __BFI_CEE_H__
+
+#include <bfi/bfi.h>
+
+#pragma pack(1)
+
+
+enum bfi_cee_h2i_msgs_e {
+	BFI_CEE_H2I_GET_CFG_REQ = 1,
+	BFI_CEE_H2I_RESET_STATS = 2,
+	BFI_CEE_H2I_GET_STATS_REQ = 3,
+};
+
+
+enum bfi_cee_i2h_msgs_e {
+	BFI_CEE_I2H_GET_CFG_RSP = BFA_I2HM(1),
+	BFI_CEE_I2H_RESET_STATS_RSP = BFA_I2HM(2),
+	BFI_CEE_I2H_GET_STATS_RSP = BFA_I2HM(3),
+};
+
+
+/* Data structures */
+
+/*
+ * BFI_CEE_H2I_RESET_STATS
+ */
+struct bfi_lldp_reset_stats_s {
+	struct bfi_mhdr_s  mh;
+};
+
+/*
+ * BFI_CEE_H2I_RESET_STATS
+ */
+struct bfi_cee_reset_stats_s {
+	struct bfi_mhdr_s  mh;
+};
+
+/*
+ * BFI_CEE_H2I_GET_CFG_REQ
+ */
+struct bfi_cee_get_req_s {
+	struct bfi_mhdr_s  mh;
+	union bfi_addr_u   dma_addr;
+};
+
+
+/*
+ * BFI_CEE_I2H_GET_CFG_RSP
+ */
+struct bfi_cee_get_rsp_s {
+	struct bfi_mhdr_s  mh;
+	u8            cmd_status;
+	u8            rsvd[3];
+};
+
+/*
+ * BFI_CEE_H2I_GET_STATS_REQ
+ */
+struct bfi_cee_stats_req_s {
+	struct bfi_mhdr_s  mh;
+	union bfi_addr_u   dma_addr;
+};
+
+
+/*
+ * BFI_CEE_I2H_GET_STATS_RSP
+ */
+struct bfi_cee_stats_rsp_s {
+	struct bfi_mhdr_s  mh;
+	u8 		   cmd_status;
+	u8 		   rsvd[3];
+};
+
+
+
+union bfi_cee_h2i_msg_u {
+	struct bfi_mhdr_s           mh;
+	struct bfi_cee_get_req_s   get_req;
+	struct bfi_cee_stats_req_s stats_req;
+};
+
+
+union bfi_cee_i2h_msg_u {
+	struct bfi_mhdr_s         mh;
+	struct bfi_cee_get_rsp_s  get_rsp;
+	struct bfi_cee_stats_rsp_s stats_rsp;
+};
+
+#pragma pack()
+
+
+#endif /* __BFI_CEE_H__ */
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/bfi/bfi_ctreg.h linux-2.6.32-rc4-mod/drivers/net/bna/include/bfi/bfi_ctreg.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/bfi/bfi_ctreg.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/bfi/bfi_ctreg.h	2009-10-16 10:30:54.257377000 -0700
@@ -0,0 +1,611 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+/*
+ * bfi_ctreg.h catapult host block register definitions
+ *
+ * !!! Do not edit. Auto generated. !!!
+ */
+
+#ifndef __BFI_CTREG_H__
+#define __BFI_CTREG_H__
+
+
+#define HOSTFN0_LPU_MBOX0_0              0x00019200
+#define HOSTFN1_LPU_MBOX0_8              0x00019260
+#define LPU_HOSTFN0_MBOX0_0              0x00019280
+#define LPU_HOSTFN1_MBOX0_8              0x000192e0
+#define HOSTFN2_LPU_MBOX0_0              0x00019400
+#define HOSTFN3_LPU_MBOX0_8              0x00019460
+#define LPU_HOSTFN2_MBOX0_0              0x00019480
+#define LPU_HOSTFN3_MBOX0_8              0x000194e0
+#define HOSTFN0_INT_STATUS               0x00014000
+#define __HOSTFN0_HALT_OCCURRED          0x01000000
+#define __HOSTFN0_INT_STATUS_LVL_MK      0x00f00000
+#define __HOSTFN0_INT_STATUS_LVL_SH      20
+#define __HOSTFN0_INT_STATUS_LVL(_v)     ((_v) << __HOSTFN0_INT_STATUS_LVL_SH)
+#define __HOSTFN0_INT_STATUS_P_MK        0x000f0000
+#define __HOSTFN0_INT_STATUS_P_SH        16
+#define __HOSTFN0_INT_STATUS_P(_v)       ((_v) << __HOSTFN0_INT_STATUS_P_SH)
+#define __HOSTFN0_INT_STATUS_F           0x0000ffff
+#define HOSTFN0_INT_MSK                  0x00014004
+#define HOST_PAGE_NUM_FN0                0x00014008
+#define __HOST_PAGE_NUM_FN               0x000001ff
+#define HOST_MSIX_ERR_INDEX_FN0          0x0001400c
+#define __MSIX_ERR_INDEX_FN              0x000001ff
+#define HOSTFN1_INT_STATUS               0x00014100
+#define __HOSTFN1_HALT_OCCURRED          0x01000000
+#define __HOSTFN1_INT_STATUS_LVL_MK      0x00f00000
+#define __HOSTFN1_INT_STATUS_LVL_SH      20
+#define __HOSTFN1_INT_STATUS_LVL(_v)     ((_v) << __HOSTFN1_INT_STATUS_LVL_SH)
+#define __HOSTFN1_INT_STATUS_P_MK        0x000f0000
+#define __HOSTFN1_INT_STATUS_P_SH        16
+#define __HOSTFN1_INT_STATUS_P(_v)       ((_v) << __HOSTFN1_INT_STATUS_P_SH)
+#define __HOSTFN1_INT_STATUS_F           0x0000ffff
+#define HOSTFN1_INT_MSK                  0x00014104
+#define HOST_PAGE_NUM_FN1                0x00014108
+#define HOST_MSIX_ERR_INDEX_FN1          0x0001410c
+#define APP_PLL_425_CTL_REG              0x00014204
+#define __P_425_PLL_LOCK                 0x80000000
+#define __APP_PLL_425_SRAM_USE_100MHZ    0x00100000
+#define __APP_PLL_425_RESET_TIMER_MK     0x000e0000
+#define __APP_PLL_425_RESET_TIMER_SH     17
+#define __APP_PLL_425_RESET_TIMER(_v)    ((_v) << __APP_PLL_425_RESET_TIMER_SH)
+#define __APP_PLL_425_LOGIC_SOFT_RESET   0x00010000
+#define __APP_PLL_425_CNTLMT0_1_MK       0x0000c000
+#define __APP_PLL_425_CNTLMT0_1_SH       14
+#define __APP_PLL_425_CNTLMT0_1(_v)      ((_v) << __APP_PLL_425_CNTLMT0_1_SH)
+#define __APP_PLL_425_JITLMT0_1_MK       0x00003000
+#define __APP_PLL_425_JITLMT0_1_SH       12
+#define __APP_PLL_425_JITLMT0_1(_v)      ((_v) << __APP_PLL_425_JITLMT0_1_SH)
+#define __APP_PLL_425_HREF               0x00000800
+#define __APP_PLL_425_HDIV               0x00000400
+#define __APP_PLL_425_P0_1_MK            0x00000300
+#define __APP_PLL_425_P0_1_SH            8
+#define __APP_PLL_425_P0_1(_v)           ((_v) << __APP_PLL_425_P0_1_SH)
+#define __APP_PLL_425_Z0_2_MK            0x000000e0
+#define __APP_PLL_425_Z0_2_SH            5
+#define __APP_PLL_425_Z0_2(_v)           ((_v) << __APP_PLL_425_Z0_2_SH)
+#define __APP_PLL_425_RSEL200500         0x00000010
+#define __APP_PLL_425_ENARST             0x00000008
+#define __APP_PLL_425_BYPASS             0x00000004
+#define __APP_PLL_425_LRESETN            0x00000002
+#define __APP_PLL_425_ENABLE             0x00000001
+#define APP_PLL_312_CTL_REG              0x00014208
+#define __P_312_PLL_LOCK                 0x80000000
+#define __ENABLE_MAC_AHB_1               0x00800000
+#define __ENABLE_MAC_AHB_0               0x00400000
+#define __ENABLE_MAC_1                   0x00200000
+#define __ENABLE_MAC_0                   0x00100000
+#define __APP_PLL_312_RESET_TIMER_MK     0x000e0000
+#define __APP_PLL_312_RESET_TIMER_SH     17
+#define __APP_PLL_312_RESET_TIMER(_v)    ((_v) << __APP_PLL_312_RESET_TIMER_SH)
+#define __APP_PLL_312_LOGIC_SOFT_RESET   0x00010000
+#define __APP_PLL_312_CNTLMT0_1_MK       0x0000c000
+#define __APP_PLL_312_CNTLMT0_1_SH       14
+#define __APP_PLL_312_CNTLMT0_1(_v)      ((_v) << __APP_PLL_312_CNTLMT0_1_SH)
+#define __APP_PLL_312_JITLMT0_1_MK       0x00003000
+#define __APP_PLL_312_JITLMT0_1_SH       12
+#define __APP_PLL_312_JITLMT0_1(_v)      ((_v) << __APP_PLL_312_JITLMT0_1_SH)
+#define __APP_PLL_312_HREF               0x00000800
+#define __APP_PLL_312_HDIV               0x00000400
+#define __APP_PLL_312_P0_1_MK            0x00000300
+#define __APP_PLL_312_P0_1_SH            8
+#define __APP_PLL_312_P0_1(_v)           ((_v) << __APP_PLL_312_P0_1_SH)
+#define __APP_PLL_312_Z0_2_MK            0x000000e0
+#define __APP_PLL_312_Z0_2_SH            5
+#define __APP_PLL_312_Z0_2(_v)           ((_v) << __APP_PLL_312_Z0_2_SH)
+#define __APP_PLL_312_RSEL200500         0x00000010
+#define __APP_PLL_312_ENARST             0x00000008
+#define __APP_PLL_312_BYPASS             0x00000004
+#define __APP_PLL_312_LRESETN            0x00000002
+#define __APP_PLL_312_ENABLE             0x00000001
+#define MBIST_CTL_REG                    0x00014220
+#define __EDRAM_BISTR_START              0x00000004
+#define __MBIST_RESET                    0x00000002
+#define __MBIST_START                    0x00000001
+#define MBIST_STAT_REG                   0x00014224
+#define __EDRAM_BISTR_STATUS             0x00000008
+#define __EDRAM_BISTR_DONE               0x00000004
+#define __MEM_BIT_STATUS                 0x00000002
+#define __MBIST_DONE                     0x00000001
+#define HOST_SEM0_REG                    0x00014230
+#define __HOST_SEMAPHORE                 0x00000001
+#define HOST_SEM1_REG                    0x00014234
+#define HOST_SEM2_REG                    0x00014238
+#define HOST_SEM3_REG                    0x0001423c
+#define HOST_SEM0_INFO_REG               0x00014240
+#define HOST_SEM1_INFO_REG               0x00014244
+#define HOST_SEM2_INFO_REG               0x00014248
+#define HOST_SEM3_INFO_REG               0x0001424c
+#define ETH_MAC_SER_REG                  0x00014288
+#define __APP_EMS_CKBUFAMPIN             0x00000020
+#define __APP_EMS_REFCLKSEL              0x00000010
+#define __APP_EMS_CMLCKSEL               0x00000008
+#define __APP_EMS_REFCKBUFEN2            0x00000004
+#define __APP_EMS_REFCKBUFEN1            0x00000002
+#define __APP_EMS_CHANNEL_SEL            0x00000001
+#define HOSTFN2_INT_STATUS               0x00014300
+#define __HOSTFN2_HALT_OCCURRED          0x01000000
+#define __HOSTFN2_INT_STATUS_LVL_MK      0x00f00000
+#define __HOSTFN2_INT_STATUS_LVL_SH      20
+#define __HOSTFN2_INT_STATUS_LVL(_v)     ((_v) << __HOSTFN2_INT_STATUS_LVL_SH)
+#define __HOSTFN2_INT_STATUS_P_MK        0x000f0000
+#define __HOSTFN2_INT_STATUS_P_SH        16
+#define __HOSTFN2_INT_STATUS_P(_v)       ((_v) << __HOSTFN2_INT_STATUS_P_SH)
+#define __HOSTFN2_INT_STATUS_F           0x0000ffff
+#define HOSTFN2_INT_MSK                  0x00014304
+#define HOST_PAGE_NUM_FN2                0x00014308
+#define HOST_MSIX_ERR_INDEX_FN2          0x0001430c
+#define HOSTFN3_INT_STATUS               0x00014400
+#define __HALT_OCCURRED                  0x01000000
+#define __HOSTFN3_INT_STATUS_LVL_MK      0x00f00000
+#define __HOSTFN3_INT_STATUS_LVL_SH      20
+#define __HOSTFN3_INT_STATUS_LVL(_v)     ((_v) << __HOSTFN3_INT_STATUS_LVL_SH)
+#define __HOSTFN3_INT_STATUS_P_MK        0x000f0000
+#define __HOSTFN3_INT_STATUS_P_SH        16
+#define __HOSTFN3_INT_STATUS_P(_v)       ((_v) << __HOSTFN3_INT_STATUS_P_SH)
+#define __HOSTFN3_INT_STATUS_F           0x0000ffff
+#define HOSTFN3_INT_MSK                  0x00014404
+#define HOST_PAGE_NUM_FN3                0x00014408
+#define HOST_MSIX_ERR_INDEX_FN3          0x0001440c
+#define FNC_ID_REG                       0x00014600
+#define __FUNCTION_NUMBER                0x00000007
+#define FNC_PERS_REG                     0x00014604
+#define __F3_FUNCTION_ACTIVE             0x80000000
+#define __F3_FUNCTION_MODE               0x40000000
+#define __F3_PORT_MAP_MK                 0x30000000
+#define __F3_PORT_MAP_SH                 28
+#define __F3_PORT_MAP(_v)                ((_v) << __F3_PORT_MAP_SH)
+#define __F3_VM_MODE                     0x08000000
+#define __F3_INTX_STATUS_MK              0x07000000
+#define __F3_INTX_STATUS_SH              24
+#define __F3_INTX_STATUS(_v)             ((_v) << __F3_INTX_STATUS_SH)
+#define __F2_FUNCTION_ACTIVE             0x00800000
+#define __F2_FUNCTION_MODE               0x00400000
+#define __F2_PORT_MAP_MK                 0x00300000
+#define __F2_PORT_MAP_SH                 20
+#define __F2_PORT_MAP(_v)                ((_v) << __F2_PORT_MAP_SH)
+#define __F2_VM_MODE                     0x00080000
+#define __F2_INTX_STATUS_MK              0x00070000
+#define __F2_INTX_STATUS_SH              16
+#define __F2_INTX_STATUS(_v)             ((_v) << __F2_INTX_STATUS_SH)
+#define __F1_FUNCTION_ACTIVE             0x00008000
+#define __F1_FUNCTION_MODE               0x00004000
+#define __F1_PORT_MAP_MK                 0x00003000
+#define __F1_PORT_MAP_SH                 12
+#define __F1_PORT_MAP(_v)                ((_v) << __F1_PORT_MAP_SH)
+#define __F1_VM_MODE                     0x00000800
+#define __F1_INTX_STATUS_MK              0x00000700
+#define __F1_INTX_STATUS_SH              8
+#define __F1_INTX_STATUS(_v)             ((_v) << __F1_INTX_STATUS_SH)
+#define __F0_FUNCTION_ACTIVE             0x00000080
+#define __F0_FUNCTION_MODE               0x00000040
+#define __F0_PORT_MAP_MK                 0x00000030
+#define __F0_PORT_MAP_SH                 4
+#define __F0_PORT_MAP(_v)                ((_v) << __F0_PORT_MAP_SH)
+#define __F0_VM_MODE                     0x00000008
+#define __F0_INTX_STATUS                 0x00000007
+enum {
+    __F0_INTX_STATUS_MSIX            = 0x0,
+    __F0_INTX_STATUS_INTA            = 0x1,
+    __F0_INTX_STATUS_INTB            = 0x2,
+    __F0_INTX_STATUS_INTC            = 0x3,
+    __F0_INTX_STATUS_INTD            = 0x4,
+};
+#define OP_MODE                          0x0001460c
+#define __APP_ETH_CLK_LOWSPEED           0x00000004
+#define __GLOBAL_CORECLK_HALFSPEED       0x00000002
+#define __GLOBAL_FCOE_MODE               0x00000001
+#define HOST_SEM4_REG                    0x00014610
+#define HOST_SEM5_REG                    0x00014614
+#define HOST_SEM6_REG                    0x00014618
+#define HOST_SEM7_REG                    0x0001461c
+#define HOST_SEM4_INFO_REG               0x00014620
+#define HOST_SEM5_INFO_REG               0x00014624
+#define HOST_SEM6_INFO_REG               0x00014628
+#define HOST_SEM7_INFO_REG               0x0001462c
+#define HOSTFN0_LPU0_MBOX0_CMD_STAT      0x00019000
+#define __HOSTFN0_LPU0_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN0_LPU0_MBOX0_INFO_SH     1
+#define __HOSTFN0_LPU0_MBOX0_INFO(_v)    ((_v) << __HOSTFN0_LPU0_MBOX0_INFO_SH)
+#define __HOSTFN0_LPU0_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN0_LPU1_MBOX0_CMD_STAT      0x00019004
+#define __HOSTFN0_LPU1_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN0_LPU1_MBOX0_INFO_SH     1
+#define __HOSTFN0_LPU1_MBOX0_INFO(_v)    ((_v) << __HOSTFN0_LPU1_MBOX0_INFO_SH)
+#define __HOSTFN0_LPU1_MBOX0_CMD_STATUS  0x00000001
+#define LPU0_HOSTFN0_MBOX0_CMD_STAT      0x00019008
+#define __LPU0_HOSTFN0_MBOX0_INFO_MK     0xfffffffe
+#define __LPU0_HOSTFN0_MBOX0_INFO_SH     1
+#define __LPU0_HOSTFN0_MBOX0_INFO(_v)    ((_v) << __LPU0_HOSTFN0_MBOX0_INFO_SH)
+#define __LPU0_HOSTFN0_MBOX0_CMD_STATUS  0x00000001
+#define LPU1_HOSTFN0_MBOX0_CMD_STAT      0x0001900c
+#define __LPU1_HOSTFN0_MBOX0_INFO_MK     0xfffffffe
+#define __LPU1_HOSTFN0_MBOX0_INFO_SH     1
+#define __LPU1_HOSTFN0_MBOX0_INFO(_v)    ((_v) << __LPU1_HOSTFN0_MBOX0_INFO_SH)
+#define __LPU1_HOSTFN0_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN1_LPU0_MBOX0_CMD_STAT      0x00019010
+#define __HOSTFN1_LPU0_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN1_LPU0_MBOX0_INFO_SH     1
+#define __HOSTFN1_LPU0_MBOX0_INFO(_v)    ((_v) << __HOSTFN1_LPU0_MBOX0_INFO_SH)
+#define __HOSTFN1_LPU0_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN1_LPU1_MBOX0_CMD_STAT      0x00019014
+#define __HOSTFN1_LPU1_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN1_LPU1_MBOX0_INFO_SH     1
+#define __HOSTFN1_LPU1_MBOX0_INFO(_v)    ((_v) << __HOSTFN1_LPU1_MBOX0_INFO_SH)
+#define __HOSTFN1_LPU1_MBOX0_CMD_STATUS  0x00000001
+#define LPU0_HOSTFN1_MBOX0_CMD_STAT      0x00019018
+#define __LPU0_HOSTFN1_MBOX0_INFO_MK     0xfffffffe
+#define __LPU0_HOSTFN1_MBOX0_INFO_SH     1
+#define __LPU0_HOSTFN1_MBOX0_INFO(_v)    ((_v) << __LPU0_HOSTFN1_MBOX0_INFO_SH)
+#define __LPU0_HOSTFN1_MBOX0_CMD_STATUS  0x00000001
+#define LPU1_HOSTFN1_MBOX0_CMD_STAT      0x0001901c
+#define __LPU1_HOSTFN1_MBOX0_INFO_MK     0xfffffffe
+#define __LPU1_HOSTFN1_MBOX0_INFO_SH     1
+#define __LPU1_HOSTFN1_MBOX0_INFO(_v)    ((_v) << __LPU1_HOSTFN1_MBOX0_INFO_SH)
+#define __LPU1_HOSTFN1_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN2_LPU0_MBOX0_CMD_STAT      0x00019150
+#define __HOSTFN2_LPU0_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN2_LPU0_MBOX0_INFO_SH     1
+#define __HOSTFN2_LPU0_MBOX0_INFO(_v)    ((_v) << __HOSTFN2_LPU0_MBOX0_INFO_SH)
+#define __HOSTFN2_LPU0_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN2_LPU1_MBOX0_CMD_STAT      0x00019154
+#define __HOSTFN2_LPU1_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN2_LPU1_MBOX0_INFO_SH     1
+#define __HOSTFN2_LPU1_MBOX0_INFO(_v)    ((_v) << __HOSTFN2_LPU1_MBOX0_INFO_SH)
+#define __HOSTFN2_LPU1_MBOX0BOX0_CMD_STATUS 0x00000001
+#define LPU0_HOSTFN2_MBOX0_CMD_STAT      0x00019158
+#define __LPU0_HOSTFN2_MBOX0_INFO_MK     0xfffffffe
+#define __LPU0_HOSTFN2_MBOX0_INFO_SH     1
+#define __LPU0_HOSTFN2_MBOX0_INFO(_v)    ((_v) << __LPU0_HOSTFN2_MBOX0_INFO_SH)
+#define __LPU0_HOSTFN2_MBOX0_CMD_STATUS  0x00000001
+#define LPU1_HOSTFN2_MBOX0_CMD_STAT      0x0001915c
+#define __LPU1_HOSTFN2_MBOX0_INFO_MK     0xfffffffe
+#define __LPU1_HOSTFN2_MBOX0_INFO_SH     1
+#define __LPU1_HOSTFN2_MBOX0_INFO(_v)    ((_v) << __LPU1_HOSTFN2_MBOX0_INFO_SH)
+#define __LPU1_HOSTFN2_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN3_LPU0_MBOX0_CMD_STAT      0x00019160
+#define __HOSTFN3_LPU0_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN3_LPU0_MBOX0_INFO_SH     1
+#define __HOSTFN3_LPU0_MBOX0_INFO(_v)    ((_v) << __HOSTFN3_LPU0_MBOX0_INFO_SH)
+#define __HOSTFN3_LPU0_MBOX0_CMD_STATUS  0x00000001
+#define HOSTFN3_LPU1_MBOX0_CMD_STAT      0x00019164
+#define __HOSTFN3_LPU1_MBOX0_INFO_MK     0xfffffffe
+#define __HOSTFN3_LPU1_MBOX0_INFO_SH     1
+#define __HOSTFN3_LPU1_MBOX0_INFO(_v)    ((_v) << __HOSTFN3_LPU1_MBOX0_INFO_SH)
+#define __HOSTFN3_LPU1_MBOX0_CMD_STATUS  0x00000001
+#define LPU0_HOSTFN3_MBOX0_CMD_STAT      0x00019168
+#define __LPU0_HOSTFN3_MBOX0_INFO_MK     0xfffffffe
+#define __LPU0_HOSTFN3_MBOX0_INFO_SH     1
+#define __LPU0_HOSTFN3_MBOX0_INFO(_v)    ((_v) << __LPU0_HOSTFN3_MBOX0_INFO_SH)
+#define __LPU0_HOSTFN3_MBOX0_CMD_STATUS  0x00000001
+#define LPU1_HOSTFN3_MBOX0_CMD_STAT      0x0001916c
+#define __LPU1_HOSTFN3_MBOX0_INFO_MK     0xfffffffe
+#define __LPU1_HOSTFN3_MBOX0_INFO_SH     1
+#define __LPU1_HOSTFN3_MBOX0_INFO(_v)    ((_v) << __LPU1_HOSTFN3_MBOX0_INFO_SH)
+#define __LPU1_HOSTFN3_MBOX0_CMD_STATUS  0x00000001
+#define FW_INIT_HALT_P0                  0x000191ac
+#define __FW_INIT_HALT_P                 0x00000001
+#define FW_INIT_HALT_P1                  0x000191bc
+#define CPE_PI_PTR_Q0                    0x00038000
+#define __CPE_PI_UNUSED_MK               0xffff0000
+#define __CPE_PI_UNUSED_SH               16
+#define __CPE_PI_UNUSED(_v)              ((_v) << __CPE_PI_UNUSED_SH)
+#define __CPE_PI_PTR                     0x0000ffff
+#define CPE_PI_PTR_Q1                    0x00038040
+#define CPE_CI_PTR_Q0                    0x00038004
+#define __CPE_CI_UNUSED_MK               0xffff0000
+#define __CPE_CI_UNUSED_SH               16
+#define __CPE_CI_UNUSED(_v)              ((_v) << __CPE_CI_UNUSED_SH)
+#define __CPE_CI_PTR                     0x0000ffff
+#define CPE_CI_PTR_Q1                    0x00038044
+#define CPE_DEPTH_Q0                     0x00038008
+#define __CPE_DEPTH_UNUSED_MK            0xf8000000
+#define __CPE_DEPTH_UNUSED_SH            27
+#define __CPE_DEPTH_UNUSED(_v)           ((_v) << __CPE_DEPTH_UNUSED_SH)
+#define __CPE_MSIX_VEC_INDEX_MK          0x07ff0000
+#define __CPE_MSIX_VEC_INDEX_SH          16
+#define __CPE_MSIX_VEC_INDEX(_v)         ((_v) << __CPE_MSIX_VEC_INDEX_SH)
+#define __CPE_DEPTH                      0x0000ffff
+#define CPE_DEPTH_Q1                     0x00038048
+#define CPE_QCTRL_Q0                     0x0003800c
+#define __CPE_CTRL_UNUSED30_MK           0xfc000000
+#define __CPE_CTRL_UNUSED30_SH           26
+#define __CPE_CTRL_UNUSED30(_v)          ((_v) << __CPE_CTRL_UNUSED30_SH)
+#define __CPE_FUNC_INT_CTRL_MK           0x03000000
+#define __CPE_FUNC_INT_CTRL_SH           24
+#define __CPE_FUNC_INT_CTRL(_v)          ((_v) << __CPE_FUNC_INT_CTRL_SH)
+enum {
+    __CPE_FUNC_INT_CTRL_DISABLE      = 0x0,
+    __CPE_FUNC_INT_CTRL_F2NF         = 0x1,
+    __CPE_FUNC_INT_CTRL_3QUART       = 0x2,
+    __CPE_FUNC_INT_CTRL_HALF         = 0x3,
+};
+#define __CPE_CTRL_UNUSED20_MK           0x00f00000
+#define __CPE_CTRL_UNUSED20_SH           20
+#define __CPE_CTRL_UNUSED20(_v)          ((_v) << __CPE_CTRL_UNUSED20_SH)
+#define __CPE_SCI_TH_MK                  0x000f0000
+#define __CPE_SCI_TH_SH                  16
+#define __CPE_SCI_TH(_v)                 ((_v) << __CPE_SCI_TH_SH)
+#define __CPE_CTRL_UNUSED10_MK           0x0000c000
+#define __CPE_CTRL_UNUSED10_SH           14
+#define __CPE_CTRL_UNUSED10(_v)          ((_v) << __CPE_CTRL_UNUSED10_SH)
+#define __CPE_ACK_PENDING                0x00002000
+#define __CPE_CTRL_UNUSED40_MK           0x00001c00
+#define __CPE_CTRL_UNUSED40_SH           10
+#define __CPE_CTRL_UNUSED40(_v)          ((_v) << __CPE_CTRL_UNUSED40_SH)
+#define __CPE_PCIEID_MK                  0x00000300
+#define __CPE_PCIEID_SH                  8
+#define __CPE_PCIEID(_v)                 ((_v) << __CPE_PCIEID_SH)
+#define __CPE_CTRL_UNUSED00_MK           0x000000fe
+#define __CPE_CTRL_UNUSED00_SH           1
+#define __CPE_CTRL_UNUSED00(_v)          ((_v) << __CPE_CTRL_UNUSED00_SH)
+#define __CPE_ESIZE                      0x00000001
+#define CPE_QCTRL_Q1                     0x0003804c
+#define __CPE_CTRL_UNUSED31_MK           0xfc000000
+#define __CPE_CTRL_UNUSED31_SH           26
+#define __CPE_CTRL_UNUSED31(_v)          ((_v) << __CPE_CTRL_UNUSED31_SH)
+#define __CPE_CTRL_UNUSED21_MK           0x00f00000
+#define __CPE_CTRL_UNUSED21_SH           20
+#define __CPE_CTRL_UNUSED21(_v)          ((_v) << __CPE_CTRL_UNUSED21_SH)
+#define __CPE_CTRL_UNUSED11_MK           0x0000c000
+#define __CPE_CTRL_UNUSED11_SH           14
+#define __CPE_CTRL_UNUSED11(_v)          ((_v) << __CPE_CTRL_UNUSED11_SH)
+#define __CPE_CTRL_UNUSED41_MK           0x00001c00
+#define __CPE_CTRL_UNUSED41_SH           10
+#define __CPE_CTRL_UNUSED41(_v)          ((_v) << __CPE_CTRL_UNUSED41_SH)
+#define __CPE_CTRL_UNUSED01_MK           0x000000fe
+#define __CPE_CTRL_UNUSED01_SH           1
+#define __CPE_CTRL_UNUSED01(_v)          ((_v) << __CPE_CTRL_UNUSED01_SH)
+#define RME_PI_PTR_Q0                    0x00038020
+#define __LATENCY_TIME_STAMP_MK          0xffff0000
+#define __LATENCY_TIME_STAMP_SH          16
+#define __LATENCY_TIME_STAMP(_v)         ((_v) << __LATENCY_TIME_STAMP_SH)
+#define __RME_PI_PTR                     0x0000ffff
+#define RME_PI_PTR_Q1                    0x00038060
+#define RME_CI_PTR_Q0                    0x00038024
+#define __DELAY_TIME_STAMP_MK            0xffff0000
+#define __DELAY_TIME_STAMP_SH            16
+#define __DELAY_TIME_STAMP(_v)           ((_v) << __DELAY_TIME_STAMP_SH)
+#define __RME_CI_PTR                     0x0000ffff
+#define RME_CI_PTR_Q1                    0x00038064
+#define RME_DEPTH_Q0                     0x00038028
+#define __RME_DEPTH_UNUSED_MK            0xf8000000
+#define __RME_DEPTH_UNUSED_SH            27
+#define __RME_DEPTH_UNUSED(_v)           ((_v) << __RME_DEPTH_UNUSED_SH)
+#define __RME_MSIX_VEC_INDEX_MK          0x07ff0000
+#define __RME_MSIX_VEC_INDEX_SH          16
+#define __RME_MSIX_VEC_INDEX(_v)         ((_v) << __RME_MSIX_VEC_INDEX_SH)
+#define __RME_DEPTH                      0x0000ffff
+#define RME_DEPTH_Q1                     0x00038068
+#define RME_QCTRL_Q0                     0x0003802c
+#define __RME_INT_LATENCY_TIMER_MK       0xff000000
+#define __RME_INT_LATENCY_TIMER_SH       24
+#define __RME_INT_LATENCY_TIMER(_v)      ((_v) << __RME_INT_LATENCY_TIMER_SH)
+#define __RME_INT_DELAY_TIMER_MK         0x00ff0000
+#define __RME_INT_DELAY_TIMER_SH         16
+#define __RME_INT_DELAY_TIMER(_v)        ((_v) << __RME_INT_DELAY_TIMER_SH)
+#define __RME_INT_DELAY_DISABLE          0x00008000
+#define __RME_DLY_DELAY_DISABLE          0x00004000
+#define __RME_ACK_PENDING                0x00002000
+#define __RME_FULL_INTERRUPT_DISABLE     0x00001000
+#define __RME_CTRL_UNUSED10_MK           0x00000c00
+#define __RME_CTRL_UNUSED10_SH           10
+#define __RME_CTRL_UNUSED10(_v)          ((_v) << __RME_CTRL_UNUSED10_SH)
+#define __RME_PCIEID_MK                  0x00000300
+#define __RME_PCIEID_SH                  8
+#define __RME_PCIEID(_v)                 ((_v) << __RME_PCIEID_SH)
+#define __RME_CTRL_UNUSED00_MK           0x000000fe
+#define __RME_CTRL_UNUSED00_SH           1
+#define __RME_CTRL_UNUSED00(_v)          ((_v) << __RME_CTRL_UNUSED00_SH)
+#define __RME_ESIZE                      0x00000001
+#define RME_QCTRL_Q1                     0x0003806c
+#define __RME_CTRL_UNUSED11_MK           0x00000c00
+#define __RME_CTRL_UNUSED11_SH           10
+#define __RME_CTRL_UNUSED11(_v)          ((_v) << __RME_CTRL_UNUSED11_SH)
+#define __RME_CTRL_UNUSED01_MK           0x000000fe
+#define __RME_CTRL_UNUSED01_SH           1
+#define __RME_CTRL_UNUSED01(_v)          ((_v) << __RME_CTRL_UNUSED01_SH)
+#define PSS_CTL_REG                      0x00018800
+#define __PSS_I2C_CLK_DIV_MK             0x007f0000
+#define __PSS_I2C_CLK_DIV_SH             16
+#define __PSS_I2C_CLK_DIV(_v)            ((_v) << __PSS_I2C_CLK_DIV_SH)
+#define __PSS_LMEM_INIT_DONE             0x00001000
+#define __PSS_LMEM_RESET                 0x00000200
+#define __PSS_LMEM_INIT_EN               0x00000100
+#define __PSS_LPU1_RESET                 0x00000002
+#define __PSS_LPU0_RESET                 0x00000001
+#define HQM_QSET0_RXQ_DRBL_P0            0x00038000
+#define __RXQ0_ADD_VECTORS_P             0x80000000
+#define __RXQ0_STOP_P                    0x40000000
+#define __RXQ0_PRD_PTR_P                 0x0000ffff
+#define HQM_QSET1_RXQ_DRBL_P0            0x00038080
+#define __RXQ1_ADD_VECTORS_P             0x80000000
+#define __RXQ1_STOP_P                    0x40000000
+#define __RXQ1_PRD_PTR_P                 0x0000ffff
+#define HQM_QSET0_RXQ_DRBL_P1            0x0003c000
+#define HQM_QSET1_RXQ_DRBL_P1            0x0003c080
+#define HQM_QSET0_TXQ_DRBL_P0            0x00038020
+#define __TXQ0_ADD_VECTORS_P             0x80000000
+#define __TXQ0_STOP_P                    0x40000000
+#define __TXQ0_PRD_PTR_P                 0x0000ffff
+#define HQM_QSET1_TXQ_DRBL_P0            0x000380a0
+#define __TXQ1_ADD_VECTORS_P             0x80000000
+#define __TXQ1_STOP_P                    0x40000000
+#define __TXQ1_PRD_PTR_P                 0x0000ffff
+#define HQM_QSET0_TXQ_DRBL_P1            0x0003c020
+#define HQM_QSET1_TXQ_DRBL_P1            0x0003c0a0
+#define HQM_QSET0_IB_DRBL_1_P0           0x00038040
+#define __IB1_0_ACK_P                    0x80000000
+#define __IB1_0_DISABLE_P                0x40000000
+#define __IB1_0_NUM_OF_ACKED_EVENTS_P    0x0000ffff
+#define HQM_QSET1_IB_DRBL_1_P0           0x000380c0
+#define __IB1_1_ACK_P                    0x80000000
+#define __IB1_1_DISABLE_P                0x40000000
+#define __IB1_1_NUM_OF_ACKED_EVENTS_P    0x0000ffff
+#define HQM_QSET0_IB_DRBL_1_P1           0x0003c040
+#define HQM_QSET1_IB_DRBL_1_P1           0x0003c0c0
+#define HQM_QSET0_IB_DRBL_2_P0           0x00038060
+#define __IB2_0_ACK_P                    0x80000000
+#define __IB2_0_DISABLE_P                0x40000000
+#define __IB2_0_NUM_OF_ACKED_EVENTS_P    0x0000ffff
+#define HQM_QSET1_IB_DRBL_2_P0           0x000380e0
+#define __IB2_1_ACK_P                    0x80000000
+#define __IB2_1_DISABLE_P                0x40000000
+#define __IB2_1_NUM_OF_ACKED_EVENTS_P    0x0000ffff
+#define HQM_QSET0_IB_DRBL_2_P1           0x0003c060
+#define HQM_QSET1_IB_DRBL_2_P1           0x0003c0e0
+
+
+/*
+ * These definitions are either in error/missing in spec. Its auto-generated
+ * from hard coded values in regparse.pl.
+ */
+#define __EMPHPOST_AT_4G_MK_FIX          0x0000001c
+#define __EMPHPOST_AT_4G_SH_FIX          0x00000002
+#define __EMPHPRE_AT_4G_FIX              0x00000003
+#define __SFP_TXRATE_EN_FIX              0x00000100
+#define __SFP_RXRATE_EN_FIX              0x00000080
+
+
+/*
+ * These register definitions are auto-generated from hard coded values
+ * in regparse.pl.
+ */
+
+
+/*
+ * These register mapping definitions are auto-generated from mapping tables
+ * in regparse.pl.
+ */
+#define BFA_IOC0_HBEAT_REG               HOST_SEM0_INFO_REG
+#define BFA_IOC0_STATE_REG               HOST_SEM1_INFO_REG
+#define BFA_IOC1_HBEAT_REG               HOST_SEM2_INFO_REG
+#define BFA_IOC1_STATE_REG               HOST_SEM3_INFO_REG
+#define BFA_FW_USE_COUNT                 HOST_SEM4_INFO_REG
+
+#define CPE_DEPTH_Q(__n) \
+	(CPE_DEPTH_Q0 + (__n) * (CPE_DEPTH_Q1 - CPE_DEPTH_Q0))
+#define CPE_QCTRL_Q(__n) \
+	(CPE_QCTRL_Q0 + (__n) * (CPE_QCTRL_Q1 - CPE_QCTRL_Q0))
+#define CPE_PI_PTR_Q(__n) \
+	(CPE_PI_PTR_Q0 + (__n) * (CPE_PI_PTR_Q1 - CPE_PI_PTR_Q0))
+#define CPE_CI_PTR_Q(__n) \
+	(CPE_CI_PTR_Q0 + (__n) * (CPE_CI_PTR_Q1 - CPE_CI_PTR_Q0))
+#define RME_DEPTH_Q(__n) \
+	(RME_DEPTH_Q0 + (__n) * (RME_DEPTH_Q1 - RME_DEPTH_Q0))
+#define RME_QCTRL_Q(__n) \
+	(RME_QCTRL_Q0 + (__n) * (RME_QCTRL_Q1 - RME_QCTRL_Q0))
+#define RME_PI_PTR_Q(__n) \
+	(RME_PI_PTR_Q0 + (__n) * (RME_PI_PTR_Q1 - RME_PI_PTR_Q0))
+#define RME_CI_PTR_Q(__n) \
+	(RME_CI_PTR_Q0 + (__n) * (RME_CI_PTR_Q1 - RME_CI_PTR_Q0))
+#define HQM_QSET_RXQ_DRBL_P0(__n) \
+	(HQM_QSET0_RXQ_DRBL_P0 + (__n) * (HQM_QSET1_RXQ_DRBL_P0 - \
+	HQM_QSET0_RXQ_DRBL_P0))
+#define HQM_QSET_TXQ_DRBL_P0(__n) \
+	(HQM_QSET0_TXQ_DRBL_P0 + (__n) * (HQM_QSET1_TXQ_DRBL_P0 - \
+	HQM_QSET0_TXQ_DRBL_P0))
+#define HQM_QSET_IB_DRBL_1_P0(__n) \
+	(HQM_QSET0_IB_DRBL_1_P0 + (__n) * (HQM_QSET1_IB_DRBL_1_P0 - \
+	HQM_QSET0_IB_DRBL_1_P0))
+#define HQM_QSET_IB_DRBL_2_P0(__n) \
+	(HQM_QSET0_IB_DRBL_2_P0 + (__n) * (HQM_QSET1_IB_DRBL_2_P0 - \
+	HQM_QSET0_IB_DRBL_2_P0))
+#define HQM_QSET_RXQ_DRBL_P1(__n) \
+	(HQM_QSET0_RXQ_DRBL_P1 + (__n) * (HQM_QSET1_RXQ_DRBL_P1 - \
+	HQM_QSET0_RXQ_DRBL_P1))
+#define HQM_QSET_TXQ_DRBL_P1(__n) \
+	(HQM_QSET0_TXQ_DRBL_P1 + (__n) * (HQM_QSET1_TXQ_DRBL_P1 - \
+	HQM_QSET0_TXQ_DRBL_P1))
+#define HQM_QSET_IB_DRBL_1_P1(__n) \
+	(HQM_QSET0_IB_DRBL_1_P1 + (__n) * (HQM_QSET1_IB_DRBL_1_P1 - \
+	HQM_QSET0_IB_DRBL_1_P1))
+#define HQM_QSET_IB_DRBL_2_P1(__n) \
+	(HQM_QSET0_IB_DRBL_2_P1 + (__n) * (HQM_QSET1_IB_DRBL_2_P1 - \
+	HQM_QSET0_IB_DRBL_2_P1))
+
+#define CPE_Q_NUM(__fn, __q)  (((__fn) << 2) + (__q))
+#define RME_Q_NUM(__fn, __q)  (((__fn) << 2) + (__q))
+#define CPE_Q_MASK(__q)  ((__q) & 0x3)
+#define RME_Q_MASK(__q)  ((__q) & 0x3)
+
+
+/*
+ * PCI MSI-X vector defines
+ */
+enum {
+    BFA_MSIX_CPE_Q0 = 0,
+    BFA_MSIX_CPE_Q1 = 1,
+    BFA_MSIX_CPE_Q2 = 2,
+    BFA_MSIX_CPE_Q3 = 3,
+    BFA_MSIX_RME_Q0 = 4,
+    BFA_MSIX_RME_Q1 = 5,
+    BFA_MSIX_RME_Q2 = 6,
+    BFA_MSIX_RME_Q3 = 7,
+    BFA_MSIX_LPU_ERR = 8,
+    BFA_MSIX_CT_MAX = 9,
+};
+
+/*
+ * And corresponding host interrupt status bit field defines
+ */
+#define __HFN_INT_CPE_Q0                   0x00000001U
+#define __HFN_INT_CPE_Q1                   0x00000002U
+#define __HFN_INT_CPE_Q2                   0x00000004U
+#define __HFN_INT_CPE_Q3                   0x00000008U
+#define __HFN_INT_CPE_Q4                   0x00000010U
+#define __HFN_INT_CPE_Q5                   0x00000020U
+#define __HFN_INT_CPE_Q6                   0x00000040U
+#define __HFN_INT_CPE_Q7                   0x00000080U
+#define __HFN_INT_RME_Q0                   0x00000100U
+#define __HFN_INT_RME_Q1                   0x00000200U
+#define __HFN_INT_RME_Q2                   0x00000400U
+#define __HFN_INT_RME_Q3                   0x00000800U
+#define __HFN_INT_RME_Q4                   0x00001000U
+#define __HFN_INT_RME_Q5                   0x00002000U
+#define __HFN_INT_RME_Q6                   0x00004000U
+#define __HFN_INT_RME_Q7                   0x00008000U
+#define __HFN_INT_ERR_EMC                  0x00010000U
+#define __HFN_INT_ERR_LPU0                 0x00020000U
+#define __HFN_INT_ERR_LPU1                 0x00040000U
+#define __HFN_INT_ERR_PSS                  0x00080000U
+#define __HFN_INT_MBOX_LPU0                0x00100000U
+#define __HFN_INT_MBOX_LPU1                0x00200000U
+#define __HFN_INT_MBOX1_LPU0               0x00400000U
+#define __HFN_INT_MBOX1_LPU1               0x00800000U
+#define __HFN_INT_CPE_MASK                 0x000000ffU
+#define __HFN_INT_RME_MASK                 0x0000ff00U
+
+
+/*
+ * catapult memory map.
+ */
+#define LL_PGN_HQM0                      0x0096
+#define LL_PGN_HQM1                      0x0097
+#define PSS_SMEM_PAGE_START	0x8000
+#define PSS_SMEM_PGNUM(_pg0, _ma)	((_pg0) + ((_ma) >> 15))
+#define PSS_SMEM_PGOFF(_ma)	((_ma) & 0x7fff)
+
+/*
+ * End of catapult memory map
+ */
+
+
+#endif /* __BFI_CTREG_H__ */
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/bfi/bfi.h linux-2.6.32-rc4-mod/drivers/net/bna/include/bfi/bfi.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/bfi/bfi.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/bfi/bfi.h	2009-10-16 10:30:54.193366000 -0700
@@ -0,0 +1,181 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFI_H__
+#define __BFI_H__
+
+#include <bfa_os_inc.h>
+#include <defs/bfa_defs_status.h>
+
+#pragma pack(1)
+
+/**
+ * Msg header common to all msgs
+ */
+struct bfi_mhdr_s {
+	u8         msg_class;	/*  @ref bfi_mclass_t	    */
+	u8         msg_id;		/*  msg opcode with in the class   */
+	union {
+		struct {
+			u8         rsvd;
+			u8         lpu_id;	/*  msg destination	    */
+		} h2i;
+		u16        i2htok;	/*  token in msgs to host	    */
+	} mtag;
+};
+
+#define bfi_h2i_set(_mh, _mc, _op, _lpuid) do {		\
+	(_mh).msg_class 		= (_mc);      \
+	(_mh).msg_id			= (_op);      \
+	(_mh).mtag.h2i.lpu_id	= (_lpuid);      \
+} while (0)
+
+#define bfi_i2h_set(_mh, _mc, _op, _i2htok) do {		\
+	(_mh).msg_class 		= (_mc);      \
+	(_mh).msg_id			= (_op);      \
+	(_mh).mtag.i2htok		= (_i2htok);      \
+} while (0)
+
+/*
+ * Message opcodes: 0-127 to firmware, 128-255 to host
+ */
+#define BFI_I2H_OPCODE_BASE	128
+#define BFA_I2HM(_x) 			((_x) + BFI_I2H_OPCODE_BASE)
+
+/**
+ ****************************************************************************
+ *
+ * Scatter Gather Element and Page definition
+ *
+ ****************************************************************************
+ */
+
+#define BFI_SGE_INLINE	1
+#define BFI_SGE_INLINE_MAX	(BFI_SGE_INLINE + 1)
+
+/**
+ * SG Flags
+ */
+enum {
+	BFI_SGE_DATA	= 0,	/*  data address, not last	     */
+	BFI_SGE_DATA_CPL	= 1,	/*  data addr, last in current page */
+	BFI_SGE_DATA_LAST	= 3,	/*  data address, last		     */
+	BFI_SGE_LINK	= 2,	/*  link address		     */
+	BFI_SGE_PGDLEN	= 2,	/*  cumulative data length for page */
+};
+
+/**
+ * DMA addresses
+ */
+union bfi_addr_u {
+	struct {
+		u32        addr_lo;
+		u32        addr_hi;
+	} a32;
+};
+
+/**
+ * Scatter Gather Element
+ */
+struct bfi_sge_s {
+#ifdef __BIGENDIAN
+	u32        flags:2,
+			rsvd:2,
+			sg_len:28;
+#else
+	u32        sg_len:28,
+			rsvd:2,
+			flags:2;
+#endif
+	union bfi_addr_u sga;
+};
+
+/**
+ * Scatter Gather Page
+ */
+#define BFI_SGPG_DATA_SGES		7
+#define BFI_SGPG_SGES_MAX		(BFI_SGPG_DATA_SGES + 1)
+#define BFI_SGPG_RSVD_WD_LEN	8
+struct bfi_sgpg_s {
+	struct bfi_sge_s sges[BFI_SGPG_SGES_MAX];
+	u32	rsvd[BFI_SGPG_RSVD_WD_LEN];
+};
+
+/*
+ * Large Message structure - 128 Bytes size Msgs
+ */
+#define BFI_LMSG_SZ		128
+#define BFI_LMSG_PL_WSZ	\
+			((BFI_LMSG_SZ - sizeof(struct bfi_mhdr_s)) / 4)
+
+struct bfi_msg_s {
+	struct bfi_mhdr_s mhdr;
+	u32	pl[BFI_LMSG_PL_WSZ];
+};
+
+/**
+ * Mailbox message structure
+ */
+#define BFI_MBMSG_SZ		7
+struct bfi_mbmsg_s {
+	struct bfi_mhdr_s	mh;
+	u32		pl[BFI_MBMSG_SZ];
+};
+
+/**
+ * Message Classes
+ */
+enum bfi_mclass {
+	BFI_MC_IOC		= 1,	/*  IO Controller (IOC)	    */
+	BFI_MC_DIAG		= 2,	/*  Diagnostic Msgs		    */
+	BFI_MC_FLASH		= 3,	/*  Flash message class	    */
+	BFI_MC_CEE		= 4,
+	BFI_MC_FC_PORT		= 5,	/*  FC port		   	    */
+	BFI_MC_IOCFC		= 6,	/*  FC - IO Controller (IOC)	    */
+	BFI_MC_LL		= 7,	/*  Link Layer		 	    */
+	BFI_MC_UF		= 8,	/*  Unsolicited frame receive	    */
+	BFI_MC_FCXP		= 9,	/*  FC Transport		    */
+	BFI_MC_LPS		= 10,	/*  lport fc login services	    */
+	BFI_MC_RPORT		= 11,	/*  Remote port		    */
+	BFI_MC_ITNIM		= 12,	/*  I-T nexus (Initiator mode)	    */
+	BFI_MC_IOIM_READ	= 13,	/*  read IO (Initiator mode)	    */
+	BFI_MC_IOIM_WRITE	= 14,	/*  write IO (Initiator mode)	    */
+	BFI_MC_IOIM_IO		= 15,	/*  IO (Initiator mode)	    */
+	BFI_MC_IOIM		= 16,	/*  IO (Initiator mode)	    */
+	BFI_MC_IOIM_IOCOM	= 17,	/*  good IO completion		    */
+	BFI_MC_TSKIM		= 18,	/*  Initiator Task management	    */
+	BFI_MC_SBOOT		= 19,	/*  SAN boot services		    */
+	BFI_MC_IPFC		= 20,	/*  IP over FC Msgs		    */
+	BFI_MC_PORT		= 21,	/*  Physical port		    */
+	BFI_MC_MAX		= 32
+};
+
+#define BFI_IOC_MAX_CQS		4
+#define BFI_IOC_MAX_CQS_ASIC	8
+#define BFI_IOC_MSGLEN_MAX	32	/* 32 bytes */
+
+#pragma pack()
+
+#endif /* __BFI_H__ */
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/bfi/bfi_ioc.h linux-2.6.32-rc4-mod/drivers/net/bna/include/bfi/bfi_ioc.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/bfi/bfi_ioc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/bfi/bfi_ioc.h	2009-10-16 10:30:54.224383000 -0700
@@ -0,0 +1,209 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFI_IOC_H__
+#define __BFI_IOC_H__
+
+#include "bfi.h"
+#include <defs/bfa_defs_ioc.h>
+
+#pragma pack(1)
+
+enum bfi_ioc_h2i_msgs {
+	BFI_IOC_H2I_ENABLE_REQ 		= 1,
+	BFI_IOC_H2I_DISABLE_REQ 	= 2,
+	BFI_IOC_H2I_GETATTR_REQ 	= 3,
+	BFI_IOC_H2I_DBG_SYNC	 	= 4,
+	BFI_IOC_H2I_DBG_DUMP	 	= 5,
+};
+
+enum bfi_ioc_i2h_msgs {
+	BFI_IOC_I2H_ENABLE_REPLY	= BFA_I2HM(1),
+	BFI_IOC_I2H_DISABLE_REPLY 	= BFA_I2HM(2),
+	BFI_IOC_I2H_GETATTR_REPLY 	= BFA_I2HM(3),
+	BFI_IOC_I2H_READY_EVENT 	= BFA_I2HM(4),
+	BFI_IOC_I2H_HBEAT		= BFA_I2HM(5),
+};
+
+/**
+ * BFI_IOC_H2I_GETATTR_REQ message
+ */
+struct bfi_ioc_getattr_req_s {
+	struct bfi_mhdr_s	mh;
+	union bfi_addr_u	attr_addr;
+};
+
+struct bfi_ioc_attr_s {
+	wwn_t           mfg_wwn;
+	mac_t		mfg_mac;
+	u16	rsvd_a;
+	char            brcd_serialnum[STRSZ(BFA_MFG_SERIALNUM_SIZE)];
+	u8         pcie_gen;
+	u8         pcie_lanes_orig;
+	u8         pcie_lanes;
+	u8         rx_bbcredit;	/*  receive buffer credits */
+	u32        adapter_prop;	/*  adapter properties     */
+	u16        maxfrsize;	/*  max receive frame size */
+	char         	asic_rev;
+	u8         rsvd_b;
+	char            fw_version[BFA_VERSION_LEN];
+	char            optrom_version[BFA_VERSION_LEN];
+	struct bfa_mfg_vpd_s	vpd;
+};
+
+/**
+ * BFI_IOC_I2H_GETATTR_REPLY message
+ */
+struct bfi_ioc_getattr_reply_s {
+	struct bfi_mhdr_s  mh;		/*  Common msg header          */
+	u8		status;	/*  cfg reply status           */
+	u8		rsvd[3];
+};
+
+/**
+ * Firmware memory page offsets
+ */
+#define BFI_IOC_SMEM_PG0_CB	(0x40)
+#define BFI_IOC_SMEM_PG0_CT	(0x180)
+
+/**
+ * Firmware trace offset
+ */
+#define BFI_IOC_TRC_OFF		(0x4b00)
+#define BFI_IOC_TRC_ENTS	256
+
+#define BFI_IOC_FW_SIGNATURE	(0xbfadbfad)
+#define BFI_IOC_MD5SUM_SZ	4
+struct bfi_ioc_image_hdr_s {
+	u32        signature;	/*  constant signature */
+	u32        rsvd_a;
+	u32        exec;		/*  exec vector        */
+	u32        param;		/*  parameters         */
+	u32        rsvd_b[4];
+	u32        md5sum[BFI_IOC_MD5SUM_SZ];
+};
+
+/**
+ *  BFI_IOC_I2H_READY_EVENT message
+ */
+struct bfi_ioc_rdy_event_s {
+	struct bfi_mhdr_s  mh;			/*  common msg header */
+	u8         init_status;	/*  init event status */
+	u8         rsvd[3];
+};
+
+struct bfi_ioc_hbeat_s {
+	struct bfi_mhdr_s  mh;		/*  common msg header		*/
+	u32	   hb_count;	/*  current heart beat count	*/
+};
+
+/**
+ * IOC hardware/firmware state
+ */
+enum bfi_ioc_state {
+	BFI_IOC_UNINIT 	 = 0,		/*  not initialized                 */
+	BFI_IOC_INITING 	 = 1,	/*  h/w is being initialized        */
+	BFI_IOC_HWINIT 	 = 2,		/*  h/w is initialized              */
+	BFI_IOC_CFG 	 = 3,		/*  IOC configuration in progress   */
+	BFI_IOC_OP 		 = 4,	/*  IOC is operational              */
+	BFI_IOC_DISABLING 	 = 5,	/*  IOC is being disabled           */
+	BFI_IOC_DISABLED 	 = 6,	/*  IOC is disabled                 */
+	BFI_IOC_CFG_DISABLED = 7,	/*  IOC is being disabled;transient */
+	BFI_IOC_HBFAIL       = 8,	/*  IOC heart-beat failure          */
+	BFI_IOC_MEMTEST      = 9,	/*  IOC is doing memtest            */
+};
+
+#define BFI_IOC_ENDIAN_SIG  0x12345678
+
+enum {
+	BFI_ADAPTER_TYPE_FC   = 0x01,		/*  FC adapters           */
+	BFI_ADAPTER_TYPE_MK   = 0x0f0000,	/*  adapter type mask     */
+	BFI_ADAPTER_TYPE_SH   = 16,	        /*  adapter type shift    */
+	BFI_ADAPTER_NPORTS_MK = 0xff00,		/*  number of ports mask  */
+	BFI_ADAPTER_NPORTS_SH = 8,	        /*  number of ports shift */
+	BFI_ADAPTER_SPEED_MK  = 0xff,		/*  adapter speed mask    */
+	BFI_ADAPTER_SPEED_SH  = 0,	        /*  adapter speed shift   */
+	BFI_ADAPTER_PROTO     = 0x100000,	/*  prototype adapaters   */
+	BFI_ADAPTER_TTV       = 0x200000,	/*  TTV debug capable     */
+	BFI_ADAPTER_UNSUPP    = 0x400000,	/*  unknown adapter type  */
+};
+
+#define BFI_ADAPTER_GETP(__prop, __adap_prop)          		\
+    (((__adap_prop) & BFI_ADAPTER_ ## __prop ## _MK) >>         \
+     BFI_ADAPTER_ ## __prop ## _SH)
+#define BFI_ADAPTER_SETP(__prop, __val)         		\
+    ((__val) << BFI_ADAPTER_ ## __prop ## _SH)
+#define BFI_ADAPTER_IS_PROTO(__adap_type)   			\
+    ((__adap_type) & BFI_ADAPTER_PROTO)
+#define BFI_ADAPTER_IS_TTV(__adap_type)     			\
+    ((__adap_type) & BFI_ADAPTER_TTV)
+#define BFI_ADAPTER_IS_UNSUPP(__adap_type)  			\
+    ((__adap_type) & BFI_ADAPTER_UNSUPP)
+#define BFI_ADAPTER_IS_SPECIAL(__adap_type)                     \
+    ((__adap_type) & (BFI_ADAPTER_TTV | BFI_ADAPTER_PROTO |     \
+			BFI_ADAPTER_UNSUPP))
+
+/**
+ * BFI_IOC_H2I_ENABLE_REQ & BFI_IOC_H2I_DISABLE_REQ messages
+ */
+struct bfi_ioc_ctrl_req_s {
+	struct bfi_mhdr_s	mh;
+	u8			ioc_class;
+	u8         	rsvd[3];
+};
+
+/**
+ * BFI_IOC_I2H_ENABLE_REPLY & BFI_IOC_I2H_DISABLE_REPLY messages
+ */
+struct bfi_ioc_ctrl_reply_s {
+	struct bfi_mhdr_s  mh;		/*  Common msg header     */
+	u8         status;		/*  enable/disable status */
+	u8         rsvd[3];
+};
+
+#define BFI_IOC_MSGSZ   8
+/**
+ * H2I Messages
+ */
+union bfi_ioc_h2i_msg_u {
+	struct bfi_mhdr_s 	mh;
+	struct bfi_ioc_ctrl_req_s enable_req;
+	struct bfi_ioc_ctrl_req_s disable_req;
+	struct bfi_ioc_getattr_req_s getattr_req;
+	u32       		mboxmsg[BFI_IOC_MSGSZ];
+};
+
+/**
+ * I2H Messages
+ */
+union bfi_ioc_i2h_msg_u {
+	struct bfi_mhdr_s      	mh;
+	struct bfi_ioc_rdy_event_s 	rdy_event;
+	u32       		mboxmsg[BFI_IOC_MSGSZ];
+};
+
+#pragma pack()
+
+#endif /* __BFI_IOC_H__ */
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/bfi/bfi_ll.h linux-2.6.32-rc4-mod/drivers/net/bna/include/bfi/bfi_ll.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/bfi/bfi_ll.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/bfi/bfi_ll.h	2009-10-16 10:30:54.274374000 -0700
@@ -0,0 +1,443 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ *	Copyright (c) 2007-2008 Brocade Communications Systems, Inc.
+ *	All rights reserved.
+ *
+ *	file bfi_if.h BNA Hardware and Firmware Interface
+ */
+#ifndef __BFI_LL_H__
+#define __BFI_LL_H__
+
+#include <bfi/bfi.h>
+#include <defs/bfa_defs_ioc.h>
+
+#pragma pack(1)
+
+/**
+ *	"enums" for all LL mailbox messages other than IOC
+ */
+enum {
+	BFI_LL_H2I_MAC_UCAST_SET_REQ = 1,
+	BFI_LL_H2I_MAC_UCAST_ADD_REQ = 2,
+	BFI_LL_H2I_MAC_UCAST_DEL_REQ = 3,
+
+	BFI_LL_H2I_MAC_MCAST_ADD_REQ = 4,
+	BFI_LL_H2I_MAC_MCAST_DEL_REQ = 5,
+	BFI_LL_H2I_MAC_MCAST_FILTER_REQ = 6,
+	BFI_LL_H2I_MAC_MCAST_DEL_ALL_REQ = 7,
+
+	BFI_LL_H2I_PORT_ADMIN_REQ = 8,
+	BFI_LL_H2I_STATS_GET_REQ = 9,
+	BFI_LL_H2I_STATS_CLEAR_REQ = 10,
+
+	BFI_LL_H2I_RXF_PROMISCUOUS_SET_REQ = 11,
+	BFI_LL_H2I_RXF_DEFAULT_SET_REQ = 12,
+
+	BFI_LL_H2I_TXQ_STOP_REQ = 13,
+	BFI_LL_H2I_RXQ_STOP_REQ = 14,
+
+	BFI_LL_H2I_DIAG_LOOPBACK_REQ = 15,
+
+	BFI_LL_H2I_SET_PAUSE_REQ = 16,
+	BFI_LL_H2I_MTU_INFO_REQ = 17,
+
+	BFI_LL_H2I_RX_REQ = 18,
+};
+
+enum {
+	BFI_LL_I2H_MAC_UCAST_SET_RSP = BFA_I2HM(1),
+	BFI_LL_I2H_MAC_UCAST_ADD_RSP = BFA_I2HM(2),
+	BFI_LL_I2H_MAC_UCAST_DEL_RSP = BFA_I2HM(3),
+
+	BFI_LL_I2H_MAC_MCAST_ADD_RSP = BFA_I2HM(4),
+	BFI_LL_I2H_MAC_MCAST_DEL_RSP = BFA_I2HM(5),
+	BFI_LL_I2H_MAC_MCAST_FILTER_RSP = BFA_I2HM(6),
+	BFI_LL_I2H_MAC_MCAST_DEL_ALL_RSP = BFA_I2HM(7),
+
+	BFI_LL_I2H_PORT_ADMIN_RSP = BFA_I2HM(8),
+	BFI_LL_I2H_STATS_GET_RSP = BFA_I2HM(9),
+	BFI_LL_I2H_STATS_CLEAR_RSP = BFA_I2HM(10),
+
+	BFI_LL_I2H_RXF_PROMISCUOUS_SET_RSP = BFA_I2HM(11),
+	BFI_LL_I2H_RXF_DEFAULT_SET_RSP = BFA_I2HM(12),
+
+	BFI_LL_I2H_TXQ_STOP_RSP = BFA_I2HM(13),
+	BFI_LL_I2H_RXQ_STOP_RSP = BFA_I2HM(14),
+
+	BFI_LL_I2H_DIAG_LOOPBACK_RSP = BFA_I2HM(15),
+
+	BFI_LL_I2H_SET_PAUSE_RSP = BFA_I2HM(16),
+
+	BFI_LL_I2H_MTU_INFO_RSP = BFA_I2HM(17),
+	BFI_LL_I2H_RX_RSP = BFA_I2HM(18),
+
+	BFI_LL_I2H_LINK_DOWN_AEN = BFA_I2HM(19),
+	BFI_LL_I2H_LINK_UP_AEN = BFA_I2HM(20),
+	BFI_LL_I2H_CEE_DOWN_AEN = BFA_I2HM(21),
+	BFI_LL_I2H_CEE_UP_AEN = BFA_I2HM(22),
+};
+
+/**
+ *        BFI_LL_H2I_MAC_UCAST_SET_REQ
+ *        BFI_LL_H2I_MAC_UCAST_ADD_REQ
+ *        BFI_LL_H2I_MAC_UCAST_DEL_REQ
+ *        BFI_LL_H2I_MAC_MCAST_ADD_REQ
+ *        BFI_LL_H2I_MAC_MCAST_DEL_REQ
+ */
+struct bfi_ll_mac_addr_req {
+	struct bfi_mhdr_s  mh;         /*  common msg header */
+	u8		rxf_id;
+	u8		rsvd1[3];
+	mac_t		mac_addr;
+	u8		rsvd2[2];
+};
+
+/**
+ *	  BFI_LL_H2I_MAC_MCAST_FILTER_REQ
+ */
+struct bfi_ll_mcast_filter_req {
+	struct bfi_mhdr_s  mh;         /*  common msg header */
+	u8		rxf_id;
+	u8		enable;
+	u8		rsvd[2];
+};
+
+/**
+ *	  BFI_LL_H2I_MAC_MCAST_DEL_ALL_REQ
+ */
+struct bfi_ll_mcast_del_all_req {
+	struct bfi_mhdr_s  mh;         /*  common msg header */
+	u8		   rxf_id;
+	u8		   rsvd[3];
+};
+
+/**
+ *	BFI_LL_H2I_TXQ_STOP_REQ
+ *	BFI_LL_H2I_RXQ_STOP_REQ
+ */
+struct bfi_ll_q_stop_req {
+	struct bfi_mhdr_s mh;		/*  common msg header */
+	u32	q_id_mask[2];	/*  bit-mask for queue ids */
+};
+
+/**
+ *    BFI_LL_I2H_STATS_GET_REQ
+ *    BFI_LL_I2H_STATS_CLEAR_REQ
+ */
+struct bfi_ll_stats_req {
+	struct bfi_mhdr_s  mh;         		/*  common msg header */
+/*  bit-mask for non-function statistics */
+	u16	stats_mask;
+	u8		rsvd[2];
+	u32	rxf_id_mask[2];		 /*  bit-mask for RxF Statistics */
+	u32	txf_id_mask[2];		 /*  bit-mask for TxF Statistics */
+/*  where statistics are returned */
+	union bfi_addr_u  host_buffer;
+};
+
+
+#define BFI_LL_STATS_MAC	(1 << 0)	/*  MAC Statistics */
+#define BFI_LL_STATS_BPC	(1 << 1)	/*  Pause Stats from BPC */
+#define BFI_LL_STATS_RAD	(1 << 2)	/*  Rx Admission Statistics */
+#define BFI_LL_STATS_RX_FC	(1 << 3)	/*  Rx FC Stats from RxA */
+#define BFI_LL_STATS_TX_FC	(1 << 4)	/*  Tx FC Stats from TxA */
+
+#define BFI_LL_STATS_ALL	0x1f
+
+
+
+struct bfi_ll_port_admin_req {
+	struct bfi_mhdr_s  mh;         		/*  common msg header */
+	u8		 up;
+	u8		 rsvd[3];
+};
+
+/**
+ *      BFI_LL_H2I_RXF_PROMISCUOUS_SET_REQ
+ *      BFI_LL_H2I_RXF_DEFAULT_SET_REQ
+ */
+struct bfi_ll_rxf_req {
+	struct bfi_mhdr_s  mh;         /*  common msg header */
+	u8		rxf_id;
+	u8		enable;
+	u8		rsvd[2];
+};
+
+/**
+ *      BFI_LL_H2I_RX_REQ
+ */
+struct bfi_ll_rxf_multi_req {
+	struct bfi_mhdr_s  mh;         /*  common msg header */
+	u32	rxf_id_mask[2];
+	u8		enable;
+	u8		rsvd[3];
+};
+
+/**
+ *      BFI_LL_H2I_DIAG_LOOPBACK
+ */
+struct bfi_ll_diag_lb_req{
+		struct bfi_mhdr_s		mh;		/* 4 bytes */
+/* =1 : enable, =0 : disable */
+		u8					enable;
+/* cable or Serdes */
+		u8					mode;
+		u8					rsvd[2];
+};
+
+
+enum {
+	BFI_LL_DIAG_LB_OPMODE_EXT = 0,
+	BFI_LL_DIAG_LB_OPMODE_CBL = 1,
+};
+
+/**
+ *	BFI_LL_H2I_SET_PAUSE_REQ
+ */
+struct bfi_ll_set_pause_req {
+	struct bfi_mhdr_s mh;
+	u8		tx_pause; /* 1 = enable, 0 =  disable */
+	u8		rx_pause; /* 1 = enable, 0 =  disable */
+	u8		rsvd[2];
+};
+
+/**
+ *	BFI_LL_H2I_MTU_INFO_REQ
+ */
+struct bfi_ll_mtu_info_req {
+	struct bfi_mhdr_s mh;
+	u16	mtu;
+	u8		rsvd[2];
+};
+
+/**
+ *	  Response header format used by all responses
+ *	  For both responses and asynchronous notifications
+ */
+struct bfi_ll_rsp {
+	struct bfi_mhdr_s  mh;         		/*  common msg header */
+	u8 	 error;
+	u8		 rsvd[3];
+};
+
+/**
+ *	BFI_LL_I2H_LINK_DOWN_AEN
+ *	BFI_LL_I2H_LINK_UP_AEN
+ *	BFI_LL_I2H_CEE_DOWN_AEN
+ *	BFI_LL_I2H_CEE_UP_AEN
+ */
+struct bfi_ll_aen {
+	struct bfi_mhdr_s  mh;          /*  common msg header */
+	u32           reason;
+	u8            prio_map;    /*  LL priority bit-map */
+	u8            rsvd[3];
+};
+
+/**
+ * 	The following error codes can be returned
+ *	by the mbox commands
+ */
+enum {
+	BFI_LL_CMD_OK 		= 0,
+	BFI_LL_CMD_FAIL 	= 1,
+	BFI_LL_CMD_DUP_ENTRY	= 2,	/*  Duplicate entry in CAM */
+	BFI_LL_CMD_CAM_FULL	= 3,	/*  CAM is full */
+	BFI_LL_CMD_NOT_OWNER	= 4,   	/*  Not permitted, b'cos not owner */
+	BFI_LL_CMD_NOT_EXEC	= 5,   	/*  Was not sent to f/w at all */
+};
+
+/* Statistics */
+#define BFI_LL_TXF_ID_MAX  	64
+#define BFI_LL_RXF_ID_MAX  	64
+
+/* TxF Frame Statistics */
+struct bfi_ll_stats_txf {
+	u64 ucast_octets;
+	u64 ucast;
+	u64 ucast_vlan;
+
+	u64 mcast_octets;
+	u64 mcast;
+	u64 mcast_vlan;
+
+	u64 bcast_octets;
+	u64 bcast;
+	u64 bcast_vlan;
+
+	u64 errors;
+	u64 filter_vlan;      /* frames filtered due to VLAN */
+	u64 filter_mac_sa;    /* frames filtered due to SA check */
+};
+
+
+/* RxF Frame Statistics */
+struct bfi_ll_stats_rxf {
+	u64 ucast_octets;
+	u64 ucast;
+	u64 ucast_vlan;
+
+	u64 mcast_octets;
+	u64 mcast;
+	u64 mcast_vlan;
+
+	u64 bcast_octets;
+	u64 bcast;
+	u64 bcast_vlan;
+	u64 frame_drops;
+};
+
+
+/* FC Tx Frame Statistics */
+struct bfi_ll_stats_fc_tx {
+	u64 txf_ucast_octets;
+	u64 txf_ucast;
+	u64 txf_ucast_vlan;
+
+	u64 txf_mcast_octets;
+	u64 txf_mcast;
+	u64 txf_mcast_vlan;
+
+	u64 txf_bcast_octets;
+	u64 txf_bcast;
+	u64 txf_bcast_vlan;
+
+	u64 txf_parity_errors;
+	u64 txf_timeout;
+	u64 txf_fid_parity_errors;
+};
+
+
+/* FC Rx Frame Statistics */
+struct bfi_ll_stats_fc_rx {
+	u64 rxf_ucast_octets;
+	u64 rxf_ucast;
+	u64 rxf_ucast_vlan;
+
+	u64 rxf_mcast_octets;
+	u64 rxf_mcast;
+	u64 rxf_mcast_vlan;
+
+	u64 rxf_bcast_octets;
+	u64 rxf_bcast;
+	u64 rxf_bcast_vlan;
+};
+
+
+/* RAD Frame Statistics */
+struct bfi_ll_stats_rad {
+	u64 rx_frames;
+	u64 rx_octets;
+	u64 rx_vlan_frames;
+
+	u64 rx_ucast;
+	u64 rx_ucast_octets;
+	u64 rx_ucast_vlan;
+
+	u64 rx_mcast;
+	u64 rx_mcast_octets;
+	u64 rx_mcast_vlan;
+
+	u64 rx_bcast;
+	u64 rx_bcast_octets;
+	u64 rx_bcast_vlan;
+
+	u64 rx_drops;
+};
+
+
+/* BPC Tx Registers */
+struct bfi_ll_stats_bpc {
+    /* transmit stats */
+	u64 tx_pause[8];
+	u64 tx_zero_pause[8]; /*  Pause cancellation */
+	u64 tx_first_pause[8];/*  Pause initiation rather than retention*/
+
+	/* receive stats */
+	u64 rx_pause[8];
+	u64 rx_zero_pause[8]; /*  Pause cancellation */
+	u64 rx_first_pause[8];/*  Pause initiation rather than retention*/
+};
+
+
+/* MAC Rx Statistics */
+struct bfi_ll_stats_mac {
+	u64 frame_64;          /* both rx and tx counter */
+	u64 frame_65_127;      /* both rx and tx counter */
+	u64 frame_128_255;     /* both rx and tx counter */
+	u64 frame_256_511;     /* both rx and tx counter */
+	u64 frame_512_1023;    /* both rx and tx counter */
+	u64 frame_1024_1518;   /* both rx and tx counter */
+	u64 frame_1519_1522;   /* both rx and tx counter */
+
+	/* receive stats */
+	u64 rx_bytes;
+	u64 rx_packets;
+	u64 rx_fcs_error;
+	u64 rx_multicast;
+	u64 rx_broadcast;
+	u64 rx_control_frames;
+	u64 rx_pause;
+	u64 rx_unknown_opcode;
+	u64 rx_alignment_error;
+	u64 rx_frame_length_error;
+	u64 rx_code_error;
+	u64 rx_carrier_sense_error;
+	u64 rx_undersize;
+	u64 rx_oversize;
+	u64 rx_fragments;
+	u64 rx_jabber;
+	u64 rx_drop;
+
+	/* transmit stats */
+	u64 tx_bytes;
+	u64 tx_packets;
+	u64 tx_multicast;
+	u64 tx_broadcast;
+	u64 tx_pause;
+	u64 tx_deferral;
+	u64 tx_excessive_deferral;
+	u64 tx_single_collision;
+	u64 tx_muliple_collision;
+	u64 tx_late_collision;
+	u64 tx_excessive_collision;
+	u64 tx_total_collision;
+	u64 tx_pause_honored;
+	u64 tx_drop;
+	u64 tx_jabber;
+	u64 tx_fcs_error;
+	u64 tx_control_frame;
+	u64 tx_oversize;
+	u64 tx_undersize;
+	u64 tx_fragments;
+};
+
+
+/* Complete statistics */
+struct bfi_ll_stats {
+	struct bfi_ll_stats_mac		mac_stats;
+	struct bfi_ll_stats_bpc		bpc_stats;
+	struct bfi_ll_stats_rad		rad_stats;
+	struct bfi_ll_stats_fc_rx	fc_rx_stats;
+	struct bfi_ll_stats_fc_tx	fc_tx_stats;
+	struct bfi_ll_stats_rxf	rxf_stats[BFI_LL_RXF_ID_MAX];
+	struct bfi_ll_stats_txf	txf_stats[BFI_LL_TXF_ID_MAX];
+};
+
+#pragma pack()
+
+#endif  /* __BFI_LL_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/cee/bfa_cee.h linux-2.6.32-rc4-mod/drivers/net/bna/include/cee/bfa_cee.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/cee/bfa_cee.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/cee/bfa_cee.h	2009-10-16 10:30:54.302367000 -0700
@@ -0,0 +1,82 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFA_CEE_H__
+#define __BFA_CEE_H__
+
+#include <defs/bfa_defs_cee.h>
+#include <bfa_ioc.h>
+
+typedef void (*bfa_cee_get_attr_cbfn_t) (void *dev, bfa_status_t status);
+typedef void (*bfa_cee_get_stats_cbfn_t) (void *dev, bfa_status_t status);
+typedef void (*bfa_cee_reset_stats_cbfn_t) (void *dev, bfa_status_t status);
+typedef void (*bfa_cee_hbfail_cbfn_t) (void *dev, bfa_status_t status);
+
+struct bfa_cee_cbfn_s {
+	bfa_cee_get_attr_cbfn_t    get_attr_cbfn;
+	void *get_attr_cbarg;
+	bfa_cee_get_stats_cbfn_t   get_stats_cbfn;
+	void *get_stats_cbarg;
+	bfa_cee_reset_stats_cbfn_t reset_stats_cbfn;
+	void *reset_stats_cbarg;
+};
+
+struct bfa_cee_s {
+	void *dev;
+	bfa_boolean_t get_attr_pending;
+	bfa_boolean_t get_stats_pending;
+	bfa_boolean_t reset_stats_pending;
+	bfa_status_t get_attr_status;
+	bfa_status_t get_stats_status;
+	bfa_status_t reset_stats_status;
+	struct bfa_cee_cbfn_s cbfn;
+	struct bfa_ioc_hbfail_notify_s hbfail;
+	struct bfa_trc_mod_s *trcmod;
+	struct bfa_log_mod_s *logmod;
+	struct bfa_cee_attr_s *attr;
+	struct bfa_cee_stats_s *stats;
+	struct bfa_dma_s attr_dma;
+	struct bfa_dma_s stats_dma;
+	struct bfa_ioc_s *ioc;
+	struct bfa_mbox_cmd_s get_cfg_mb;
+	struct bfa_mbox_cmd_s get_stats_mb;
+	struct bfa_mbox_cmd_s reset_stats_mb;
+};
+
+u32 bfa_cee_meminfo(void);
+void bfa_cee_mem_claim(struct bfa_cee_s *cee, u8 *dma_kva,
+			 u64 dma_pa);
+void bfa_cee_attach(struct bfa_cee_s *cee, struct bfa_ioc_s *ioc, void *dev,
+			struct bfa_trc_mod_s *trcmod,
+			struct bfa_log_mod_s *logmod);
+void bfa_cee_detach(struct bfa_cee_s *cee);
+bfa_status_t bfa_cee_get_attr(struct bfa_cee_s *cee,
+			 struct bfa_cee_attr_s *attr,
+			bfa_cee_get_attr_cbfn_t cbfn, void *cbarg);
+bfa_status_t bfa_cee_get_stats(struct bfa_cee_s *cee,
+			struct bfa_cee_stats_s *stats,
+			bfa_cee_get_stats_cbfn_t cbfn, void *cbarg);
+bfa_status_t bfa_cee_reset_stats(struct bfa_cee_s *cee,
+			bfa_cee_reset_stats_cbfn_t cbfn, void *cbarg);
+#endif /* __BFA_CEE_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/cna/pstats/ethport_defs.h linux-2.6.32-rc4-mod/drivers/net/bna/include/cna/pstats/ethport_defs.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/cna/pstats/ethport_defs.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/cna/pstats/ethport_defs.h	2009-10-16 10:30:54.342372000 -0700
@@ -0,0 +1,43 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved.
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __ETHPORT_DEFS_H__
+#define __ETHPORT_DEFS_H__
+
+struct bnad_drv_stats {
+	u64 netif_queue_stop;
+	u64 netif_queue_wakeup;
+	u64 tso4;
+	u64 tso6;
+	u64 tso_err;
+	u64 tcpcsum_offload;
+	u64 udpcsum_offload;
+	u64 csum_help;
+	u64 csum_help_err;
+
+	u64 hw_stats_updates;
+	u64 netif_rx_schedule;
+	u64 netif_rx_complete;
+	u64 netif_rx_dropped;
+};
+#endif
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/cna/pstats/phyport_defs.h linux-2.6.32-rc4-mod/drivers/net/bna/include/cna/pstats/phyport_defs.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/cna/pstats/phyport_defs.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/cna/pstats/phyport_defs.h	2009-10-16 10:30:54.359375000 -0700
@@ -0,0 +1,225 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved.
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __PHYPORT_DEFS_H__
+#define __PHYPORT_DEFS_H__
+
+#define BNA_TXF_ID_MAX  	64
+#define BNA_RXF_ID_MAX  	64
+
+/*
+ * Statistics
+ */
+
+/*
+ * TxF Frame Statistics
+ */
+struct bna_stats_txf {
+	u64        ucast_octets;
+	u64        ucast;
+	u64        ucast_vlan;
+
+	u64        mcast_octets;
+	u64        mcast;
+	u64        mcast_vlan;
+
+	u64        bcast_octets;
+	u64        bcast;
+	u64        bcast_vlan;
+
+	u64        errors;
+	u64        filter_vlan;	/* frames filtered due to VLAN */
+	u64        filter_mac_sa;	/* frames filtered due to SA check */
+};
+
+/*
+ * RxF Frame Statistics
+ */
+struct bna_stats_rxf {
+	u64        ucast_octets;
+	u64        ucast;
+	u64        ucast_vlan;
+
+	u64        mcast_octets;
+	u64        mcast;
+	u64        mcast_vlan;
+
+	u64        bcast_octets;
+	u64        bcast;
+	u64        bcast_vlan;
+	u64        frame_drops;
+};
+
+/*
+ * FC Tx Frame Statistics
+ */
+struct bna_stats_fc_tx {
+	u64        txf_ucast_octets;
+	u64        txf_ucast;
+	u64        txf_ucast_vlan;
+
+	u64        txf_mcast_octets;
+	u64        txf_mcast;
+	u64        txf_mcast_vlan;
+
+	u64        txf_bcast_octets;
+	u64        txf_bcast;
+	u64        txf_bcast_vlan;
+
+	u64        txf_parity_errors;
+	u64        txf_timeout;
+	u64        txf_fid_parity_errors;
+};
+
+/*
+ * FC Rx Frame Statistics
+ */
+struct bna_stats_fc_rx {
+	u64        rxf_ucast_octets;
+	u64        rxf_ucast;
+	u64        rxf_ucast_vlan;
+
+	u64        rxf_mcast_octets;
+	u64        rxf_mcast;
+	u64        rxf_mcast_vlan;
+
+	u64        rxf_bcast_octets;
+	u64        rxf_bcast;
+	u64        rxf_bcast_vlan;
+};
+
+/*
+ * RAD Frame Statistics
+ */
+struct cna_stats_rad {
+	u64        rx_frames;
+	u64        rx_octets;
+	u64        rx_vlan_frames;
+
+	u64        rx_ucast;
+	u64        rx_ucast_octets;
+	u64        rx_ucast_vlan;
+
+	u64        rx_mcast;
+	u64        rx_mcast_octets;
+	u64        rx_mcast_vlan;
+
+	u64        rx_bcast;
+	u64        rx_bcast_octets;
+	u64        rx_bcast_vlan;
+
+	u64        rx_drops;
+};
+
+/*
+ * BPC Tx Registers
+ */
+struct cna_stats_bpc_tx {
+	u64        tx_pause[8];
+	u64        tx_zero_pause[8];	/*  Pause cancellation */
+	u64        tx_first_pause[8];	/*  Pause initiation rather
+						 *than retention */
+};
+
+/*
+ * BPC Rx Registers
+ */
+struct cna_stats_bpc_rx {
+	u64        rx_pause[8];
+	u64        rx_zero_pause[8];	/*  Pause cancellation */
+	u64        rx_first_pause[8];	/*  Pause initiation rather
+						 *than retention */
+};
+
+/*
+ * MAC Rx Statistics
+ */
+struct cna_stats_mac_rx {
+	u64        frame_64;	/* both rx and tx counter */
+	u64        frame_65_127;	/* both rx and tx counter */
+	u64        frame_128_255;	/* both rx and tx counter */
+	u64        frame_256_511;	/* both rx and tx counter */
+	u64        frame_512_1023;	/* both rx and tx counter */
+	u64        frame_1024_1518;	/* both rx and tx counter */
+	u64        frame_1518_1522;	/* both rx and tx counter */
+	u64        rx_bytes;
+	u64        rx_packets;
+	u64        rx_fcs_error;
+	u64        rx_multicast;
+	u64        rx_broadcast;
+	u64        rx_control_frames;
+	u64        rx_pause;
+	u64        rx_unknown_opcode;
+	u64        rx_alignment_error;
+	u64        rx_frame_length_error;
+	u64        rx_code_error;
+	u64        rx_carrier_sense_error;
+	u64        rx_undersize;
+	u64        rx_oversize;
+	u64        rx_fragments;
+	u64        rx_jabber;
+	u64        rx_drop;
+};
+
+/*
+ * MAC Tx Statistics
+ */
+struct cna_stats_mac_tx {
+	u64        tx_bytes;
+	u64        tx_packets;
+	u64        tx_multicast;
+	u64        tx_broadcast;
+	u64        tx_pause;
+	u64        tx_deferral;
+	u64        tx_excessive_deferral;
+	u64        tx_single_collision;
+	u64        tx_muliple_collision;
+	u64        tx_late_collision;
+	u64        tx_excessive_collision;
+	u64        tx_total_collision;
+	u64        tx_pause_honored;
+	u64        tx_drop;
+	u64        tx_jabber;
+	u64        tx_fcs_error;
+	u64        tx_control_frame;
+	u64        tx_oversize;
+	u64        tx_undersize;
+	u64        tx_fragments;
+};
+
+/*
+ * Complete statistics
+ */
+struct bna_stats {
+	struct cna_stats_mac_rx mac_rx_stats;
+	struct cna_stats_bpc_rx bpc_rx_stats;
+	struct cna_stats_rad rad_stats;
+	struct bna_stats_fc_rx fc_rx_stats;
+	struct cna_stats_mac_tx mac_tx_stats;
+	struct cna_stats_bpc_tx bpc_tx_stats;
+	struct bna_stats_fc_tx fc_tx_stats;
+	struct bna_stats_rxf rxf_stats[BNA_TXF_ID_MAX];
+	struct bna_stats_txf txf_stats[BNA_RXF_ID_MAX];
+};
+
+#endif
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/cs/bfa_debug.h linux-2.6.32-rc4-mod/drivers/net/bna/include/cs/bfa_debug.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/cs/bfa_debug.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/cs/bfa_debug.h	2009-10-16 10:30:54.453377000 -0700
@@ -0,0 +1,51 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/**
+ *  bfa_debug.h BFA debug interfaces
+ */
+
+#ifndef __BFA_DEBUG_H__
+#define __BFA_DEBUG_H__
+
+#define bfa_assert(__cond)	do {					\
+	if (!(__cond)) 							\
+		bfa_panic(__LINE__, __FILE__, #__cond);      \
+} while (0)
+
+#define bfa_sm_fault(__mod, __event)	do {				\
+	bfa_sm_panic((__mod)->logm, __LINE__, __FILE__, __event);      \
+} while (0)
+
+#ifndef BFA_PERF_BUILD
+#define bfa_assert_fp(__cond)	bfa_assert(__cond)
+#else
+#define bfa_assert_fp(__cond)
+#endif
+
+struct bfa_log_mod_s;
+void bfa_panic(int line, char *file, char *panicstr);
+void bfa_sm_panic(struct bfa_log_mod_s *logm, int line, char *file, int event);
+
+#endif /* __BFA_DEBUG_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/cs/bfa_q.h linux-2.6.32-rc4-mod/drivers/net/bna/include/cs/bfa_q.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/cs/bfa_q.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/cs/bfa_q.h	2009-10-16 10:30:54.392371000 -0700
@@ -0,0 +1,88 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/**
+ *  bfa_q.h Circular queue definitions.
+ */
+
+#ifndef __BFA_Q_H__
+#define __BFA_Q_H__
+
+#define bfa_q_first(_q) ((void *)(((struct list_head *) (_q))->next))
+#define bfa_q_next(_qe)	(((struct list_head *) (_qe))->next)
+#define bfa_q_prev(_qe) (((struct list_head *) (_qe))->prev)
+
+/*
+ * bfa_q_qe_init - to initialize a queue element
+ */
+#define bfa_q_qe_init(_qe) {						\
+	bfa_q_next(_qe) = (struct list_head *) NULL;			\
+	bfa_q_prev(_qe) = (struct list_head *) NULL;			\
+}
+
+/*
+ * bfa_q_deq - dequeue an element from head of the queue
+ */
+#define bfa_q_deq(_q, _qe) {						\
+	if (!list_empty(_q)) {					\
+		(*((struct list_head **) (_qe))) = bfa_q_next(_q);	\
+		bfa_q_prev(bfa_q_next(*((struct list_head **) _qe))) =	\
+						(struct list_head *) (_q); \
+		bfa_q_next(_q) = bfa_q_next(*((struct list_head **) _qe)); \
+		BFA_Q_DBG_INIT(*((struct list_head **) _qe));		\
+	} else {							\
+		*((struct list_head **) (_qe)) = (struct list_head *) NULL; \
+	}								\
+}
+
+/*
+ * bfa_q_deq_tail - dequeue an element from tail of the queue
+ */
+#define bfa_q_deq_tail(_q, _qe) {					    \
+	if (!list_empty(_q)) {					            \
+		*((struct list_head **) (_qe)) = bfa_q_prev(_q);	    \
+		bfa_q_next(bfa_q_prev(*((struct list_head **) _qe))) = 	    \
+						(struct list_head *) (_q);  \
+		bfa_q_prev(_q) = bfa_q_prev(*(struct list_head **) _qe);    \
+		BFA_Q_DBG_INIT(*((struct list_head **) _qe));		    \
+	} else {							    \
+		*((struct list_head **) (_qe)) = (struct list_head *) NULL; \
+	}								    \
+}
+
+/*
+ * #ifdef BFA_DEBUG (Using bfa_assert to check for debug_build is not
+ * consistent across modules)
+ */
+#ifndef BFA_PERF_BUILD
+#define BFA_Q_DBG_INIT(_qe)	bfa_q_qe_init(_qe)
+#else
+#define BFA_Q_DBG_INIT(_qe)
+#endif
+
+#define bfa_q_is_on_q(_q, _qe)		\
+	bfa_q_is_on_q_func(_q, (struct list_head *)(_qe))
+extern int bfa_q_is_on_q_func(struct list_head *q, struct list_head *qe);
+
+#endif
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/cs/bfa_sm.h linux-2.6.32-rc4-mod/drivers/net/bna/include/cs/bfa_sm.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/cs/bfa_sm.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/cs/bfa_sm.h	2009-10-16 10:30:54.421366000 -0700
@@ -0,0 +1,76 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/**
+ *  bfasm.h State machine defines
+ */
+
+#ifndef __BFA_SM_H__
+#define __BFA_SM_H__
+
+typedef void (*bfa_sm_t)(void *sm, int event);
+
+#define bfa_sm_set_state(_sm, _state)	((_sm)->sm = (bfa_sm_t)(_state))
+#define bfa_sm_send_event(_sm, _event)	((_sm)->sm((_sm), (_event)))
+#define bfa_sm_get_state(_sm)		((_sm)->sm)
+#define bfa_sm_cmp_state(_sm, _state)	((_sm)->sm == (bfa_sm_t)(_state))
+
+/**
+ * For converting from state machine function to state encoding.
+ */
+struct bfa_sm_table_s {
+	bfa_sm_t	sm;	/*  state machine function	*/
+	int		state;	/*  state machine encoding	*/
+	char		*name;	/*  state name for display	*/
+};
+#define BFA_SM(_sm)	((bfa_sm_t)(_sm))
+
+int bfa_sm_to_state(struct bfa_sm_table_s *smt, bfa_sm_t sm);
+
+/**
+ * State machine with entry actions.
+ */
+typedef void (*bfa_fsm_t)(void *fsm, int event);
+
+/**
+ * oc - object class eg. bfa_ioc
+ * st - state, eg. reset
+ * otype - object type, eg. struct bfa_ioc_s
+ * etype - object type, eg. enum ioc_event
+ */
+#define bfa_fsm_state_decl(oc, st, otype, etype)		\
+	static void oc ## _sm_ ## st(otype * fsm, etype event);      \
+	static void oc ## _sm_ ## st ## _entry(otype * fsm)
+
+#define bfa_fsm_set_state(_fsm, _state) do {	\
+	(_fsm)->fsm = (bfa_fsm_t)(_state);      \
+	_state ## _entry(_fsm);      \
+} while (0)
+
+#define bfa_fsm_send_event(_fsm, _event)	\
+	((_fsm)->fsm((_fsm), (_event)))
+#define bfa_fsm_cmp_state(_fsm, _state)		\
+	((_fsm)->fsm == (bfa_fsm_t)(_state))
+
+#endif
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/cs/bfa_trc.h linux-2.6.32-rc4-mod/drivers/net/bna/include/cs/bfa_trc.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/cs/bfa_trc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/cs/bfa_trc.h	2009-10-16 10:30:54.437374000 -0700
@@ -0,0 +1,67 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+#ifndef __BFA_TRC_H__
+#define __BFA_TRC_H__
+
+#ifndef BFA_TRC_MAX
+#define BFA_TRC_MAX	(4 * 1024)
+#endif
+
+struct bfa_trc_s {
+#ifdef __BIGENDIAN
+	u16	fileno;
+	u16	line;
+#else
+	u16	line;
+	u16	fileno;
+#endif
+	u32	timestamp;
+	union {
+		struct {
+			u32	rsvd;
+			u32	u32;
+		} u32;
+		u64	u64;
+	} data;
+};
+
+struct bfa_trc_mod_s {
+	u32	head;
+	u32	tail;
+	u32	ntrc;
+	u32	stopped;
+	u32	ticks;
+	u32	rsvd[3];
+	struct bfa_trc_s trc[BFA_TRC_MAX];
+};
+
+static inline void
+bfa_trc_init(struct bfa_trc_mod_s *trcm)
+{
+	trcm->head = trcm->tail = trcm->stopped = 0;
+	trcm->ntrc = BFA_TRC_MAX;
+}
+
+#endif /* __BFA_TRC_H__ */
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_adapter.h linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_adapter.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_adapter.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_adapter.h	2009-10-16 10:30:54.498372000 -0700
@@ -0,0 +1,89 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+#ifndef __BFA_DEFS_ADAPTER_H__
+#define __BFA_DEFS_ADAPTER_H__
+
+#include <protocol/types.h>
+#include <defs/bfa_defs_version.h>
+#include <defs/bfa_defs_mfg.h>
+
+/**
+ * BFA adapter level attributes.
+ */
+enum {
+	BFA_ADAPTER_SERIAL_NUM_LEN = STRSZ(BFA_MFG_SERIALNUM_SIZE),
+					/*
+					 *!< adapter serial num length
+					 */
+	BFA_ADAPTER_MODEL_NAME_LEN  = 16,  /*  model name length */
+	BFA_ADAPTER_MODEL_DESCR_LEN = 128, /*  model description length */
+	BFA_ADAPTER_MFG_NAME_LEN    = 8,   /*  manufacturer name length */
+	BFA_ADAPTER_SYM_NAME_LEN    = 64,  /*  adapter symbolic name length */
+	BFA_ADAPTER_OS_TYPE_LEN	    = 64,  /*  adapter os type length */
+};
+
+struct bfa_adapter_attr_s {
+	char            manufacturer[BFA_ADAPTER_MFG_NAME_LEN];
+	char            serial_num[BFA_ADAPTER_SERIAL_NUM_LEN];
+	u32	rsvd1;
+	char            model[BFA_ADAPTER_MODEL_NAME_LEN];
+	char            model_descr[BFA_ADAPTER_MODEL_DESCR_LEN];
+	wwn_t           pwwn;
+	char            node_symname[FC_SYMNAME_MAX];
+	char            hw_ver[BFA_VERSION_LEN];
+	char            fw_ver[BFA_VERSION_LEN];
+	char            optrom_ver[BFA_VERSION_LEN];
+	char            os_type[BFA_ADAPTER_OS_TYPE_LEN];
+	struct bfa_mfg_vpd_s	vpd;
+	struct mac_s	mac;
+
+	u8		nports;
+	u8		max_speed;
+	u8		prototype;
+	char	        asic_rev;
+
+	u8         pcie_gen;
+	u8         pcie_lanes_orig;
+	u8         pcie_lanes;
+	u8	        cna_capable;
+};
+
+/**
+ * BFA adapter level events
+ * Arguments below are in BFAL context from Mgmt
+ * BFA_PORT_AEN_ADD:        [in]: None     [out]: serial_num, pwwn, nports
+ * BFA_PORT_AEN_REMOVE:     [in]: pwwn     [out]: serial_num, pwwn, nports
+ */
+enum bfa_adapter_aen_event {
+	BFA_ADAPTER_AEN_ADD 	= 1,	/*  New Adapter found event */
+	BFA_ADAPTER_AEN_REMOVE 	= 2,	/*  Adapter removed event */
+};
+
+struct bfa_adapter_aen_data_s {
+	char            serial_num[BFA_ADAPTER_SERIAL_NUM_LEN];
+	u32        nports;	/*  Number of NPorts */
+	wwn_t           pwwn;	/*  WWN of one of its physical port */
+};
+
+#endif /* __BFA_DEFS_ADAPTER_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_cee.h linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_cee.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_cee.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_cee.h	2009-10-16 10:30:54.562371000 -0700
@@ -0,0 +1,165 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ *  bfa_defs_cee.h Interface declarations between host based
+ *	BFAL and DCBX/LLDP module in Firmware
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+#ifndef __BFA_DEFS_CEE_H__
+#define __BFA_DEFS_CEE_H__
+
+#include <defs/bfa_defs_types.h>
+#include <protocol/types.h>
+
+#pragma pack(1)
+
+#define BFA_CEE_LLDP_MAX_STRING_LEN (128)
+
+
+/* FIXME: this is coming from the protocol spec. Can the host & apps share the
+   protocol .h files ?
+ */
+#define BFA_CEE_LLDP_SYS_CAP_OTHER       0x0001
+#define BFA_CEE_LLDP_SYS_CAP_REPEATER    0x0002
+#define BFA_CEE_LLDP_SYS_CAP_MAC_BRIDGE  0x0004
+#define BFA_CEE_LLDP_SYS_CAP_WLAN_AP     0x0008
+#define BFA_CEE_LLDP_SYS_CAP_ROUTER      0x0010
+#define BFA_CEE_LLDP_SYS_CAP_TELEPHONE 	 0x0020
+#define BFA_CEE_LLDP_SYS_CAP_DOCSIS_CD   0x0040
+#define BFA_CEE_LLDP_SYS_CAP_STATION     0x0080
+#define BFA_CEE_LLDP_SYS_CAP_CVLAN	     0x0100
+#define BFA_CEE_LLDP_SYS_CAP_SVLAN 	     0x0200
+#define BFA_CEE_LLDP_SYS_CAP_TPMR		 0x0400
+
+
+/* LLDP string type */
+struct bfa_cee_lldp_str_s {
+	u8 sub_type;
+	u8 len;
+	u8 rsvd[2];
+	u8 value[BFA_CEE_LLDP_MAX_STRING_LEN];
+};
+
+
+/* LLDP paramters */
+struct bfa_cee_lldp_cfg_s {
+	struct bfa_cee_lldp_str_s chassis_id;
+	struct bfa_cee_lldp_str_s port_id;
+	struct bfa_cee_lldp_str_s port_desc;
+	struct bfa_cee_lldp_str_s sys_name;
+	struct bfa_cee_lldp_str_s sys_desc;
+	struct bfa_cee_lldp_str_s mgmt_addr;
+	u16    time_to_interval;
+	u16    enabled_system_cap;
+};
+
+enum bfa_cee_dcbx_version_e {
+	DCBX_PROTOCOL_PRECEE = 1,
+	DCBX_PROTOCOL_CEE    = 2,
+};
+
+enum bfa_cee_lls_e {
+	CEE_LLS_DOWN_NO_TLV = 0, /* LLS is down because the TLV not sent by
+				  * the peer */
+	CEE_LLS_DOWN        = 1, /* LLS is down as advertised by the peer */
+	CEE_LLS_UP          = 2,
+};
+
+/* CEE/DCBX parameters */
+struct bfa_cee_dcbx_cfg_s {
+	u8 pgid[8];
+	u8 pg_percentage[8];
+	u8 pfc_enabled;          /* bitmap of priorties with PFC enabled */
+	u8 fcoe_user_priority;   /* bitmap of priorities used for FcoE
+				       * traffic */
+	u8 dcbx_version;	/* operating version:CEE or preCEE */
+	u8 lls_fcoe;	/* FCoE Logical Link Status */
+	u8 lls_lan;	/* LAN Logical Link Status */
+	u8 rsvd[3];
+};
+
+/* CEE status */
+/* Making this to tri-state for the benefit of port list command */
+enum bfa_cee_status_e {
+    CEE_PHY_DOWN = 0,
+    CEE_PHY_UP = 1,
+    CEE_UP = 2,
+};
+
+/* CEE Query */
+struct bfa_cee_attr_s {
+	u8                   cee_status;
+	u8                   error_reason;
+	struct bfa_cee_lldp_cfg_s lldp_remote;
+	struct bfa_cee_dcbx_cfg_s dcbx_remote;
+	mac_t src_mac;
+	u8 link_speed;
+	u8 filler[3];
+};
+
+
+
+
+/* LLDP/DCBX/CEE Statistics */
+
+struct bfa_cee_lldp_stats_s {
+	u32 frames_transmitted;
+	u32 frames_aged_out;
+	u32 frames_discarded;
+	u32 frames_in_error;
+	u32 frames_rcvd;
+	u32 tlvs_discarded;
+	u32 tlvs_unrecognized;
+};
+
+struct bfa_cee_dcbx_stats_s {
+	u32 subtlvs_unrecognized;
+	u32 negotiation_failed;
+	u32 remote_cfg_changed;
+	u32 tlvs_received;
+	u32 tlvs_invalid;
+	u32 seqno;
+	u32 ackno;
+	u32 recvd_seqno;
+	u32 recvd_ackno;
+};
+
+struct bfa_cee_cfg_stats_s {
+	u32 cee_status_down;
+	u32 cee_status_up;
+	u32 cee_hw_cfg_changed;
+	u32 recvd_invalid_cfg;
+};
+
+
+struct bfa_cee_stats_s {
+	struct bfa_cee_lldp_stats_s lldp_stats;
+	struct bfa_cee_dcbx_stats_s dcbx_stats;
+	struct bfa_cee_cfg_stats_s  cfg_stats;
+};
+
+#pragma pack()
+
+
+#endif	/* __BFA_DEFS_CEE_H__ */
+
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_ioc.h linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_ioc.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_ioc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_ioc.h	2009-10-16 10:30:54.577375000 -0700
@@ -0,0 +1,158 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFA_DEFS_IOC_H__
+#define __BFA_DEFS_IOC_H__
+
+#include <protocol/types.h>
+#include <defs/bfa_defs_types.h>
+#include <defs/bfa_defs_version.h>
+#include <defs/bfa_defs_adapter.h>
+
+enum {
+	BFA_IOC_DRIVER_LEN	= 16,
+	BFA_IOC_CHIP_REV_LEN 	= 8,
+};
+
+/**
+ * Driver and firmware versions.
+ */
+struct bfa_ioc_driver_attr_s {
+	char            driver[BFA_IOC_DRIVER_LEN];	/*  driver name */
+	char            driver_ver[BFA_VERSION_LEN];	/*  driver version */
+	char            fw_ver[BFA_VERSION_LEN];	/*  firmware version*/
+	char            bios_ver[BFA_VERSION_LEN];	/*  bios version */
+	char            efi_ver[BFA_VERSION_LEN];	/*  EFI version */
+	char            ob_ver[BFA_VERSION_LEN];	/*  openboot version*/
+};
+
+/**
+ * IOC PCI device attributes
+ */
+struct bfa_ioc_pci_attr_s {
+	u16        vendor_id;	/*  PCI vendor ID */
+	u16        device_id;	/*  PCI device ID */
+	u16        ssid;		/*  subsystem ID */
+	u16        ssvid;		/*  subsystem vendor ID */
+	u32        pcifn;		/*  PCI device function */
+	u32        rsvd;		/* padding */
+	u8         chip_rev[BFA_IOC_CHIP_REV_LEN];	 /*  chip revision */
+};
+
+/**
+ * IOC states
+ */
+enum bfa_ioc_state {
+	BFA_IOC_RESET       = 1,  /*  IOC is in reset state */
+	BFA_IOC_SEMWAIT     = 2,  /*  Waiting for IOC hardware semaphore */
+	BFA_IOC_HWINIT 	    = 3,  /*  IOC hardware is being initialized */
+	BFA_IOC_GETATTR     = 4,  /*  IOC is being configured */
+	BFA_IOC_OPERATIONAL = 5,  /*  IOC is operational */
+	BFA_IOC_INITFAIL    = 6,  /*  IOC hardware failure */
+	BFA_IOC_HBFAIL      = 7,  /*  IOC heart-beat failure */
+	BFA_IOC_DISABLING   = 8,  /*  IOC is being disabled */
+	BFA_IOC_DISABLED    = 9,  /*  IOC is disabled */
+	BFA_IOC_FWMISMATCH  = 10, /*  IOC firmware different from drivers */
+};
+
+/**
+ * IOC firmware stats
+ */
+struct bfa_fw_ioc_stats_s {
+	u32        hb_count;
+	u32        cfg_reqs;
+	u32        enable_reqs;
+	u32        disable_reqs;
+	u32        stats_reqs;
+	u32        clrstats_reqs;
+	u32        unknown_reqs;
+	u32        ic_reqs;		/*  interrupt coalesce reqs */
+};
+
+/**
+ * IOC driver stats
+ */
+struct bfa_ioc_drv_stats_s {
+	u32	ioc_isrs;
+	u32	ioc_enables;
+	u32	ioc_disables;
+	u32	ioc_hbfails;
+	u32	ioc_boots;
+	u32	stats_tmos;
+	u32        hb_count;
+	u32        disable_reqs;
+	u32        enable_reqs;
+	u32        disable_replies;
+	u32        enable_replies;
+};
+
+/**
+ * IOC statistics
+ */
+struct bfa_ioc_stats_s {
+	struct bfa_ioc_drv_stats_s	drv_stats; /*  driver IOC stats */
+	struct bfa_fw_ioc_stats_s 	fw_stats;  /*  firmware IOC stats */
+};
+
+
+enum bfa_ioc_type_e {
+	BFA_IOC_TYPE_FC	  = 1,
+	BFA_IOC_TYPE_FCoE = 2,
+	BFA_IOC_TYPE_LL	  = 3,
+};
+
+/**
+ * IOC attributes returned in queries
+ */
+struct bfa_ioc_attr_s {
+	enum bfa_ioc_type_e		ioc_type;
+	enum bfa_ioc_state 		state;		/*  IOC state      */
+	struct bfa_adapter_attr_s	adapter_attr;	/*  HBA attributes */
+	struct bfa_ioc_driver_attr_s 	driver_attr;	/*  driver attr    */
+	struct bfa_ioc_pci_attr_s	pci_attr;
+	u8				port_id;	/*  port number    */
+};
+
+/**
+ * BFA IOC level events
+ */
+enum bfa_ioc_aen_event {
+	BFA_IOC_AEN_HBGOOD	= 1,	/*  Heart Beat restore event	*/
+	BFA_IOC_AEN_HBFAIL	= 2,	/*  Heart Beat failure event	*/
+	BFA_IOC_AEN_ENABLE	= 3,	/*  IOC enabled event		*/
+	BFA_IOC_AEN_DISABLE	= 4,	/*  IOC disabled event		*/
+	BFA_IOC_AEN_FWMISMATCH	= 5,	/*  IOC firmware mismatch	*/
+};
+
+/**
+ * BFA IOC level event data, now just a place holder
+ */
+struct bfa_ioc_aen_data_s {
+	enum bfa_ioc_type_e ioc_type;
+	wwn_t	pwwn;
+	mac_t	mac;
+};
+
+#endif /* __BFA_DEFS_IOC_H__ */
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_mfg.h linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_mfg.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_mfg.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_mfg.h	2009-10-16 10:30:54.546371000 -0700
@@ -0,0 +1,65 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+#ifndef __BFA_DEFS_MFG_H__
+#define __BFA_DEFS_MFG_H__
+
+#include <bfa_os_inc.h>
+
+/**
+ * Manufacturing block version
+ */
+#define BFA_MFG_VERSION				1
+
+/**
+ * Manufacturing block format
+ */
+#define BFA_MFG_SERIALNUM_SIZE			11
+#define BFA_MFG_PARTNUM_SIZE			14
+#define BFA_MFG_SUPPLIER_ID_SIZE		10
+#define BFA_MFG_SUPPLIER_PARTNUM_SIZE	20
+#define BFA_MFG_SUPPLIER_SERIALNUM_SIZE	20
+#define BFA_MFG_SUPPLIER_REVISION_SIZE	4
+#define STRSZ(_n)	(((_n) + 4) & ~3)
+
+/**
+ * VPD data length
+ */
+#define BFA_MFG_VPD_LEN     256
+
+/**
+ * All numerical fields are in big-endian format.
+ */
+struct bfa_mfg_vpd_s {
+    u8     version;    /*  vpd data version */
+    u8     vpd_sig[3]; /*  characters 'V', 'P', 'D' */
+    u8     chksum;     /*  u8 checksum */
+    u8     vendor;     /*  vendor */
+    u8     len;        /*  vpd data length excluding header */
+    u8     rsv;
+    u8     data[BFA_MFG_VPD_LEN];  /*  vpd data */
+};
+
+#pragma pack(1)
+
+#endif /* __BFA_DEFS_MFG_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_pci.h linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_pci.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_pci.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_pci.h	2009-10-16 10:30:54.515373000 -0700
@@ -0,0 +1,48 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFA_DEFS_PCI_H__
+#define __BFA_DEFS_PCI_H__
+
+/**
+ * PCI device and vendor ID information
+ */
+enum {
+	BFA_PCI_VENDOR_ID_BROCADE	= 0x1657,
+	BFA_PCI_DEVICE_ID_FC_8G2P	= 0x13,
+	BFA_PCI_DEVICE_ID_FC_8G1P	= 0x17,
+	BFA_PCI_DEVICE_ID_CT		= 0x14,
+};
+
+/**
+ * PCI sub-system device and vendor ID information
+ */
+enum {
+	BFA_PCI_FCOE_SSDEVICE_ID	= 0x14,
+};
+
+#define BFA_PCI_ACCESS_RANGES 1	/* Maximum number of device address ranges
+				 * mapped through different BAR(s). */
+
+#endif /* __BFA_DEFS_PCI_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_status.h linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_status.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_status.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_status.h	2009-10-16 10:30:54.592373000 -0700
@@ -0,0 +1,262 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+#ifndef __BFA_DEFS_STATUS_H__
+#define __BFA_DEFS_STATUS_H__
+
+/**
+ * API status return values
+ *
+ * NOTE: The error msgs are auto generated from the comments. Only singe line
+ * comments are supported
+ */
+enum bfa_status {
+	BFA_STATUS_OK 		= 0,	/*  Success */
+	BFA_STATUS_FAILED 	= 1,	/*  Operation failed */
+	BFA_STATUS_EINVAL 	= 2,	/*  Invalid params Check input
+					 * parameters */
+	BFA_STATUS_ENOMEM 	= 3,	/*  Out of resources */
+	BFA_STATUS_ENOSYS 	= 4,	/*  Function not implemented */
+	BFA_STATUS_ETIMER 	= 5,	/*  Timer expired - Retry, if
+					 * persists, contact support */
+	BFA_STATUS_EPROTOCOL 	= 6,	/*  Protocol error */
+	BFA_STATUS_ENOFCPORTS 	= 7,	/*  No FC ports resources */
+	BFA_STATUS_NOFLASH 	= 8,	/*  Flash not present */
+	BFA_STATUS_BADFLASH 	= 9,	/*  Flash is corrupted or bad */
+	BFA_STATUS_SFP_UNSUPP 	= 10,	/*  Unsupported SFP - Replace SFP */
+	BFA_STATUS_UNKNOWN_VFID = 11,	/*  VF_ID not found */
+	BFA_STATUS_DATACORRUPTED = 12,	/*  Diag returned data corrupted
+					 * contact support */
+	BFA_STATUS_DEVBUSY 	= 13,	/*  Device busy - Retry operation */
+	BFA_STATUS_ABORTED 	= 14,	/*  Operation aborted */
+	BFA_STATUS_NODEV 	= 15,	/*  Dev is not present */
+	BFA_STATUS_HDMA_FAILED 	= 16,	/*  Host dma failed contact support */
+	BFA_STATUS_FLASH_BAD_LEN = 17,	/*  Flash bad length */
+	BFA_STATUS_UNKNOWN_LWWN = 18,	/*  LPORT PWWN not found */
+	BFA_STATUS_UNKNOWN_RWWN = 19,	/*  RPORT PWWN not found */
+	BFA_STATUS_FCPT_LS_RJT 	= 20,	/*  Got LS_RJT for FC Pass
+					 * through Req */
+	BFA_STATUS_VPORT_EXISTS = 21,	/*  VPORT already exists */
+	BFA_STATUS_VPORT_MAX 	= 22,	/*  Reached max VPORT supported
+					 * limit */
+	BFA_STATUS_UNSUPP_SPEED = 23,	/*  Invalid Speed Check speed
+					 * setting */
+	BFA_STATUS_INVLD_DFSZ 	= 24,	/*  Invalid Max data field size */
+	BFA_STATUS_CNFG_FAILED 	= 25,	/*  Setting can not be persisted */
+	BFA_STATUS_CMD_NOTSUPP 	= 26,	/*  Command/API not supported */
+	BFA_STATUS_NO_ADAPTER 	= 27,	/*  No Brocade Adapter Found */
+	BFA_STATUS_LINKDOWN 	= 28,	/*  Link is down - Check or replace
+					 * SFP/cable */
+	BFA_STATUS_FABRIC_RJT 	= 29,	/*  Reject from attached fabric */
+	BFA_STATUS_UNKNOWN_VWWN = 30,	/*  VPORT PWWN not found */
+	BFA_STATUS_NSLOGIN_FAILED = 31,	/*  Nameserver login failed */
+	BFA_STATUS_NO_RPORTS 	= 32,	/*  No remote ports found */
+	BFA_STATUS_NSQUERY_FAILED = 33,	/*  Nameserver query failed */
+	BFA_STATUS_PORT_OFFLINE = 34,	/*  Port is not online */
+	BFA_STATUS_RPORT_OFFLINE = 35,	/*  RPORT is not online */
+	BFA_STATUS_TGTOPEN_FAILED = 36,	/*  Remote SCSI target open failed */
+	BFA_STATUS_BAD_LUNS 	= 37,	/*  No valid LUNs found */
+	BFA_STATUS_IO_FAILURE 	= 38,	/*  SCSI target IO failure */
+	BFA_STATUS_NO_FABRIC 	= 39,	/*  No switched fabric present */
+	BFA_STATUS_EBADF 	= 40,	/*  Bad file descriptor */
+	BFA_STATUS_EINTR 	= 41,	/*  A signal was caught during ioctl */
+	BFA_STATUS_EIO 		= 42,	/*  I/O error */
+	BFA_STATUS_ENOTTY 	= 43,	/*  Inappropriate I/O control
+					 * operation */
+	BFA_STATUS_ENXIO 	= 44,	/*  No such device or address */
+	BFA_STATUS_EFOPEN 	= 45,	/*  Failed to open file */
+	BFA_STATUS_VPORT_WWN_BP = 46,	/*  WWN is same as base port's WWN */
+	BFA_STATUS_PORT_NOT_DISABLED = 47, /*  Port not disabled disable port
+					    * first */
+	BFA_STATUS_BADFRMHDR 	= 48,	/*  Bad frame header */
+	BFA_STATUS_BADFRMSZ 	= 49,	/*  Bad frame size check and replace
+					 * SFP/cable */
+	BFA_STATUS_MISSINGFRM 	= 50,	/*  Missing frame check and replace
+					 * SFP/cable */
+	BFA_STATUS_LINKTIMEOUT 	= 51,	/*  Link timeout check and replace
+					 * SFP/cable */
+	BFA_STATUS_NO_FCPIM_NEXUS = 52,	/*  No FCP Nexus exists with the
+					 * rport */
+	BFA_STATUS_CHECKSUM_FAIL = 53,	/*  checksum failure */
+	BFA_STATUS_GZME_FAILED 	= 54,	/*  Get zone member query failed */
+	BFA_STATUS_SCSISTART_REQD = 55,	/*  SCSI disk require START command */
+	BFA_STATUS_IOC_FAILURE 	= 56,	/*  IOC failure - Retry, if persists
+					 * contact support */
+	BFA_STATUS_INVALID_WWN 	= 57,	/*  Invalid WWN */
+	BFA_STATUS_MISMATCH 	= 58,	/*  Version mismatch */
+	BFA_STATUS_IOC_ENABLED 	= 59,	/*  IOC is already enabled */
+	BFA_STATUS_ADAPTER_ENABLED = 60, /*  Adapter is not disabled disable
+					  * adapter first */
+	BFA_STATUS_IOC_NON_OP 	= 61,	/*  IOC is not operational. Enable IOC
+					 * and if it still fails,
+					 * contact support */
+	BFA_STATUS_ADDR_MAP_FAILURE = 62, /*  PCI base address not mapped
+					   * in OS */
+	BFA_STATUS_SAME_NAME 	= 63,	/*  Name exists! use a different
+					 * name */
+	BFA_STATUS_PENDING      = 64,   /*  API completes asynchronously */
+	BFA_STATUS_8G_SPD	= 65,	/*  Speed setting not valid for
+					 * 8G HBA */
+	BFA_STATUS_4G_SPD	= 66,	/*  Speed setting not valid for
+					 * 4G HBA */
+	BFA_STATUS_AD_IS_ENABLE = 67,	/*  Adapter is already enabled */
+	BFA_STATUS_EINVAL_TOV 	= 68,	/*  Invalid path failover TOV */
+	BFA_STATUS_EINVAL_QDEPTH = 69,	/*  Invalid queue depth value */
+	BFA_STATUS_VERSION_FAIL = 70,	/*  Application/Driver version
+					 * mismatch */
+	BFA_STATUS_DIAG_BUSY    = 71,	/*  diag busy */
+	BFA_STATUS_BEACON_ON	= 72,	/*  Port Beacon already on */
+	BFA_STATUS_BEACON_OFF	= 73,	/*  Port Beacon already off */
+	BFA_STATUS_LBEACON_ON   = 74,	/*  Link End-to-End Beacon already
+					 * on */
+	BFA_STATUS_LBEACON_OFF	= 75,	/*  Link End-to-End Beacon already
+					 * off */
+	BFA_STATUS_PORT_NOT_INITED = 76, /*  Port not initialized */
+	BFA_STATUS_RPSC_ENABLED = 77, /*  Target has a valid speed */
+	BFA_STATUS_ENOFSAVE = 78,	/*  No saved firmware trace */
+	BFA_STATUS_BAD_FILE = 79,	/*  Not a valid Brocade Boot Code
+					 * file */
+	BFA_STATUS_RLIM_EN = 80,	/*  Target rate limiting is already
+					 * enabled */
+	BFA_STATUS_RLIM_DIS = 81,  /*  Target rate limiting is already
+				    * disabled */
+	BFA_STATUS_IOC_DISABLED = 82,   /*  IOC is already disabled */
+	BFA_STATUS_ADAPTER_DISABLED = 83,   /*  Adapter is already disabled */
+	BFA_STATUS_BIOS_DISABLED = 84,   /*  Bios is already disabled */
+	BFA_STATUS_AUTH_ENABLED = 85,   /*  Authentication is already
+					 * enabled */
+	BFA_STATUS_AUTH_DISABLED = 86,   /*  Authentication is already
+					 * disabled */
+	BFA_STATUS_ERROR_TRL_ENABLED = 87,   /*  Target rate limiting is
+					      * enabled */
+	BFA_STATUS_ERROR_QOS_ENABLED = 88,   /*  QoS is enabled */
+	BFA_STATUS_NO_SFP_DEV = 89, /*  No SFP device check or replace SFP */
+	BFA_STATUS_MEMTEST_FAILED = 90,	/*  Memory test failed contact
+					 * support */
+	BFA_STATUS_INVALID_DEVID = 91,	/*  Invalid device id provided */
+	BFA_STATUS_QOS_ENABLED = 92, /*  QOS is already enabled */
+	BFA_STATUS_QOS_DISABLED = 93, /*  QOS is already disabled */
+	BFA_STATUS_INCORRECT_DRV_CONFIG = 94, /*  Check configuration
+					       * key/value pair */
+	BFA_STATUS_REG_FAIL = 95, /*  Can't read windows registry */
+	BFA_STATUS_IM_INV_CODE = 96, /*  Invalid IOCTL code */
+	BFA_STATUS_IM_INV_VLAN = 97, /*  Invalid VLAN ID */
+	BFA_STATUS_IM_INV_ADAPT_NAME = 98, /*  Invalid adapter name */
+	BFA_STATUS_IM_LOW_RESOURCES = 99, /*  Memory allocation failure in
+					   * driver */
+	BFA_STATUS_IM_VLANID_IS_PVID = 100, /*  Given VLAN id same as PVID */
+	BFA_STATUS_IM_VLANID_EXISTS = 101, /*  Given VLAN id already exists */
+	BFA_STATUS_IM_FW_UPDATE_FAIL = 102, /*  Updating firmware with new
+					     * VLAN ID failed */
+	BFA_STATUS_PORTLOG_ENABLED = 103, /*  Port Log is already enabled */
+	BFA_STATUS_PORTLOG_DISABLED = 104, /*  Port Log is already disabled */
+	BFA_STATUS_FILE_NOT_FOUND = 105, /*  Specified file could not be
+					  * found */
+	BFA_STATUS_QOS_FC_ONLY = 106, /*  QOS can be enabled for FC mode
+				       * only */
+	BFA_STATUS_RLIM_FC_ONLY = 107, /*  RATELIM can be enabled for FC mode
+					* only */
+	BFA_STATUS_CT_SPD = 108, /*  Invalid speed selection for Catapult. */
+	BFA_STATUS_LEDTEST_OP = 109, /*  LED test is operating */
+	BFA_STATUS_CEE_NOT_DN = 110, /*  eth port is not at down state, please
+				      * bring down first */
+	BFA_STATUS_10G_SPD = 111, /*  Speed setting not valid for 10G HBA */
+	BFA_STATUS_IM_INV_TEAM_NAME = 112, /*  Invalid team name */
+	BFA_STATUS_IM_DUP_TEAM_NAME = 113, /*  Given team name already
+					    * exists */
+	BFA_STATUS_IM_ADAPT_ALREADY_IN_TEAM = 114, /*  Given adapter is part
+						    * of another team */
+	BFA_STATUS_IM_ADAPT_HAS_VLANS = 115, /*  Adapter has VLANs configured.
+					      * Delete all VLANs before
+					      * creating team */
+	BFA_STATUS_IM_PVID_MISMATCH = 116, /*  Mismatching PVIDs configured
+					    * for adapters */
+	BFA_STATUS_IM_LINK_SPEED_MISMATCH = 117, /*  Mismatching link speeds
+						  * configured for adapters */
+	BFA_STATUS_IM_MTU_MISMATCH = 118, /*  Mismatching MTUs configured for
+					   * adapters */
+	BFA_STATUS_IM_RSS_MISMATCH = 119, /*  Mismatching RSS parameters
+					   * configured for adapters */
+	BFA_STATUS_IM_HDS_MISMATCH = 120, /*  Mismatching HDS parameters
+					   * configured for adapters */
+	BFA_STATUS_IM_OFFLOAD_MISMATCH = 121, /*  Mismatching offload
+					       * parameters configured for
+					       * adapters */
+	BFA_STATUS_IM_PORT_PARAMS = 122, /*  Error setting port parameters */
+	BFA_STATUS_IM_PORT_NOT_IN_TEAM = 123, /*  Port is not part of team */
+	BFA_STATUS_IM_CANNOT_REM_PRI = 124, /*  Primary adapter cannot be
+					     * removed. Change primary before
+					     * removing */
+	BFA_STATUS_IM_MAX_PORTS_REACHED = 125, /*  Exceeding maximum ports
+						* per team */
+	BFA_STATUS_IM_LAST_PORT_DELETE = 126, /*  Last port in team being
+					       * deleted */
+	BFA_STATUS_IM_NO_DRIVER = 127, /*  IM driver is not installed */
+	BFA_STATUS_IM_MAX_VLANS_REACHED = 128, /*  Exceeding maximum VLANs
+						* per port */
+	BFA_STATUS_TOMCAT_SPD_NOT_ALLOWED = 129, /* Bios speed config not
+						  * allowed for CNA */
+	BFA_STATUS_NO_MINPORT_DRIVER = 130, /*  Miniport driver is not
+					     * loaded */
+	BFA_STATUS_CARD_TYPE_MISMATCH = 131, /*  Card type mismatch */
+	BFA_STATUS_BAD_ASICBLK = 132, /*  Bad ASIC block */
+	BFA_STATUS_NO_DRIVER = 133, /*  Storage/Ethernet driver not loaded */
+	BFA_STATUS_INVALID_MAC = 134, /*  Invalid mac address */
+	BFA_STATUS_IM_NO_VLAN = 135, /*  No VLANs configured on the adapter */
+	BFA_STATUS_IM_ETH_LB_FAILED = 136, /*  Ethernet loopback test failed */
+	BFA_STATUS_IM_PVID_REMOVE = 137, /*  Cannot remove port vlan (PVID) */
+	BFA_STATUS_IM_PVID_EDIT = 138, /*  Cannot edit port vlan (PVID) */
+	BFA_STATUS_CNA_NO_BOOT = 139, /*  Boot upload not allowed for CNA */
+	BFA_STATUS_IM_PVID_NON_ZERO = 140, /*  Port VLAN ID (PVID) is Set to
+					    * Non-Zero Value */
+	BFA_STATUS_IM_INETCFG_LOCK_FAILED = 141, /*  Acquiring Network
+						  * Subsytem Lock Failed.Please
+						  * try after some time */
+	BFA_STATUS_IM_GET_INETCFG_FAILED = 142, /*  Acquiring Network Subsytem
+						 * handle Failed. Please try
+						 * after some time */
+	BFA_STATUS_IM_NOT_BOUND = 143, /*  Brocade 10G Ethernet Service is not
+					* Enabled on this port */
+	BFA_STATUS_INSUFFICIENT_PERMS = 144, /*  User doesn't have sufficient
+					      * permissions to execute the BCU
+					      * application */
+	BFA_STATUS_IM_INV_VLAN_NAME = 145, /*  Invalid/Reserved Vlan name
+					    * string. The name is not allowed
+					    * for the normal Vlans */
+	BFA_STATUS_CMD_NOTSUPP_CNA = 146, /*  Command not supported for CNA */
+	BFA_STATUS_IM_PASSTHRU_EDIT = 147, /*  Can not edit passthru vlan id */
+	BFA_STATUS_IM_BIND_FAILED = 148, /*! < IM Driver bind operation
+					  * failed */
+	BFA_STATUS_IM_UNBIND_FAILED = 149, /* ! < IM Driver unbind operation
+					    * failed */
+	BFA_STATUS_MAX_VAL		/*  Unknown error code */
+};
+#define bfa_status_t enum bfa_status
+
+enum bfa_eproto_status {
+	BFA_EPROTO_BAD_ACCEPT = 0,
+	BFA_EPROTO_UNKNOWN_RSP = 1
+};
+#define bfa_eproto_status_t enum bfa_eproto_status
+
+#endif /* __BFA_DEFS_STATUS_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_types.h linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_types.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_types.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_types.h	2009-10-16 10:30:54.607374000 -0700
@@ -0,0 +1,37 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+#ifndef __BFA_DEFS_TYPES_H__
+#define __BFA_DEFS_TYPES_H__
+
+#include <bfa_os_inc.h>
+
+enum bfa_boolean {
+	BFA_FALSE = 0,
+	BFA_TRUE  = 1
+};
+#define bfa_boolean_t enum bfa_boolean
+
+#define BFA_STRING_32	32
+
+#endif /* __BFA_DEFS_TYPES_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_version.h linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_version.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/defs/bfa_defs_version.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/defs/bfa_defs_version.h	2009-10-16 10:30:54.531367000 -0700
@@ -0,0 +1,29 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+#ifndef __BFA_DEFS_VERSION_H__
+#define __BFA_DEFS_VERSION_H__
+
+#define BFA_VERSION_LEN		64
+
+#endif
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/include/protocol/types.h linux-2.6.32-rc4-mod/drivers/net/bna/include/protocol/types.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/include/protocol/types.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/include/protocol/types.h	2009-10-16 10:30:54.634374000 -0700
@@ -0,0 +1,49 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/**
+ *  types.h Protocol defined base types
+ */
+
+#ifndef __TYPES_H__
+#define __TYPES_H__
+
+#include <bfa_os_inc.h>
+
+#define wwn_t u64
+#define lun_t u64
+
+#define WWN_NULL	(0)
+#define FC_SYMNAME_MAX	256	/*  max name server symbolic name size */
+#define FC_ALPA_MAX	128
+
+#pragma pack(1)
+
+#define MAC_ADDRLEN	(6)
+struct mac_s { u8 mac[MAC_ADDRLEN]; };
+#define mac_t struct mac_s
+
+#pragma pack()
+
+#endif
