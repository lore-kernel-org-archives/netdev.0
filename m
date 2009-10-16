From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 4/6] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 16 Oct 2009 11:24:56 -0700
Message-ID: <200910161824.n9GIOuLh010144@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amathur@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:36259 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461AbZJPSaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 14:30:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 4/6 which contains linux driver source for
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.

We wish this patch to be considered for inclusion in 2.6.32

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 bfa_ioc.h    |  266 ++++++
 bfa_os_inc.h |  210 +++++
 bfa_timer.h  |   60 +
 bna.h        | 2300 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 bna_hwreg.h  | 1004 +++++++++++++++++++++++++
 bna_intr.h   |   96 ++
 6 files changed, 3936 insertions(+)

diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bfa_ioc.h linux-2.6.32-rc4-mod/drivers/net/bna/bfa_ioc.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bfa_ioc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bfa_ioc.h	2009-10-16 10:30:53.772448000 -0700
@@ -0,0 +1,266 @@
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
+#ifndef __BFA_IOC_H__
+#define __BFA_IOC_H__
+
+#include <cs/bfa_sm.h>
+#include <bfi/bfi.h>
+#include <bfi/bfi_ioc.h>
+#include <bfi/bfi_boot.h>
+#include <bfa_timer.h>
+
+/**
+ * PCI device information required by IOC
+ */
+struct bfa_pcidev_s {
+	int             pci_slot;
+	u8         pci_func;
+	u16	device_id;
+	bfa_os_addr_t   pci_bar_kva;
+};
+
+/**
+ * Structure used to remember the DMA-able memory block's KVA and Physical
+ * Address
+ */
+struct bfa_dma_s {
+	void		*kva;	/*! Kernel virtual address	*/
+	u64	pa;	/*! Physical address		*/
+};
+
+#define BFA_DMA_ALIGN_SZ	256
+#define BFA_ROUNDUP(_l, _s)	(((_l) + ((_s) - 1)) & ~((_s) - 1))
+
+
+
+#define bfa_dma_addr_set(dma_addr, pa)	\
+		__bfa_dma_addr_set(&dma_addr, (u64)pa)
+
+static inline void
+__bfa_dma_addr_set(union bfi_addr_u *dma_addr, u64 pa)
+{
+	dma_addr->a32.addr_lo = (u32) pa;
+	dma_addr->a32.addr_hi = (u32) (bfa_os_u32(pa));
+}
+
+
+#define bfa_dma_be_addr_set(dma_addr, pa)	\
+		__bfa_dma_be_addr_set(&dma_addr, (u64)pa)
+static inline void
+__bfa_dma_be_addr_set(union bfi_addr_u *dma_addr, u64 pa)
+{
+	dma_addr->a32.addr_lo = (u32) bfa_os_htonl(pa);
+	dma_addr->a32.addr_hi = (u32) bfa_os_htonl(bfa_os_u32(pa));
+}
+
+struct bfa_ioc_regs_s {
+	bfa_os_addr_t   hfn_mbox_cmd;
+	bfa_os_addr_t   hfn_mbox;
+	bfa_os_addr_t   lpu_mbox_cmd;
+	bfa_os_addr_t   lpu_mbox;
+	bfa_os_addr_t   pss_ctl_reg;
+	bfa_os_addr_t   app_pll_fast_ctl_reg;
+	bfa_os_addr_t   app_pll_slow_ctl_reg;
+	bfa_os_addr_t   ioc_sem_reg;
+	bfa_os_addr_t   ioc_usage_sem_reg;
+	bfa_os_addr_t   ioc_usage_reg;
+	bfa_os_addr_t   host_page_num_fn;
+	bfa_os_addr_t   heartbeat;
+	bfa_os_addr_t   ioc_fwstate;
+	bfa_os_addr_t   ll_halt;
+	bfa_os_addr_t   shirq_isr_next;
+	bfa_os_addr_t   shirq_msk_next;
+	bfa_os_addr_t   smem_page_start;
+	u32	smem_pg0;
+};
+
+#define bfa_reg_read(_raddr)	bfa_os_reg_read(_raddr)
+#define bfa_reg_write(_raddr, _val)	bfa_os_reg_write(_raddr, _val)
+#define bfa_mem_read(_raddr, _off)	bfa_os_mem_read(_raddr, _off)
+#define bfa_mem_write(_raddr, _off, _val)	\
+					bfa_os_mem_write(_raddr, _off, _val)
+/**
+ * IOC Mailbox structures
+ */
+struct bfa_mbox_cmd_s {
+	struct list_head		qe;
+	u32	msg[BFI_IOC_MSGSZ];
+};
+
+/**
+ * IOC mailbox module
+ */
+typedef void (*bfa_ioc_mbox_mcfunc_t)(void *cbarg, struct bfi_mbmsg_s *m);
+struct bfa_ioc_mbox_mod_s {
+	struct list_head	cmd_q;		/*  pending mbox queue	*/
+	int		nmclass;	/*  number of handlers */
+	struct {
+		bfa_ioc_mbox_mcfunc_t	cbfn;	/*  message handlers	*/
+		void			*cbarg;
+	} mbhdlr[BFI_MC_MAX];
+};
+
+/**
+ * IOC callback function interfaces
+ */
+typedef void (*bfa_ioc_enable_cbfn_t)(void *bfa, enum bfa_status status);
+typedef void (*bfa_ioc_disable_cbfn_t)(void *bfa);
+typedef void (*bfa_ioc_hbfail_cbfn_t)(void *bfa);
+typedef void (*bfa_ioc_reset_cbfn_t)(void *bfa);
+struct bfa_ioc_cbfn_s {
+	bfa_ioc_enable_cbfn_t	enable_cbfn;
+	bfa_ioc_disable_cbfn_t	disable_cbfn;
+	bfa_ioc_hbfail_cbfn_t	hbfail_cbfn;
+	bfa_ioc_reset_cbfn_t	reset_cbfn;
+};
+
+/**
+ * Heartbeat failure notification queue element.
+ */
+struct bfa_ioc_hbfail_notify_s {
+	struct list_head		qe;
+	bfa_ioc_hbfail_cbfn_t	cbfn;
+	void			*cbarg;
+};
+
+/**
+ * Initialize a heartbeat failure notification structure
+ */
+#define bfa_ioc_hbfail_init(__notify, __cbfn, __cbarg) do {	\
+	(__notify)->cbfn = (__cbfn);      \
+	(__notify)->cbarg = (__cbarg);      \
+} while (0)
+
+struct bfa_ioc_s {
+	bfa_fsm_t		fsm;
+	struct bfa_s		*bfa;
+	struct bfa_pcidev_s	pcidev;
+	struct bfa_timer_mod_s 	*timer_mod;
+	struct bfa_timer_s 	ioc_timer;
+	struct bfa_timer_s 	sem_timer;
+	u32		hb_count;
+	u32		hb_fail;
+	u32		retry_count;
+	struct list_head		hb_notify_q;
+	void			*dbg_fwsave;
+	int			dbg_fwsave_len;
+	bfa_boolean_t		dbg_fwsave_once;
+	enum bfi_mclass		ioc_mc;
+	struct bfa_ioc_regs_s 	ioc_regs;
+	struct bfa_trc_mod_s	*trcmod;
+	struct bfa_aen_s	*aen;
+	struct bfa_log_mod_s	*logm;
+	struct bfa_ioc_drv_stats_s	stats;
+	bfa_boolean_t		auto_recover;
+	bfa_boolean_t		fcmode;
+	bfa_boolean_t		ctdev;
+	bfa_boolean_t		cna;
+	bfa_boolean_t		pllinit;
+	u8			port_id;
+
+	struct bfa_dma_s	attr_dma;
+	struct bfi_ioc_attr_s	*attr;
+	struct bfa_ioc_cbfn_s	*cbfn;
+	struct bfa_ioc_mbox_mod_s mbox_mod;
+};
+
+#define bfa_ioc_pcifn(__ioc)		((__ioc)->pcidev.pci_func)
+#define bfa_ioc_devid(__ioc)		((__ioc)->pcidev.device_id)
+#define bfa_ioc_bar0(__ioc)		((__ioc)->pcidev.pci_bar_kva)
+#define bfa_ioc_portid(__ioc)		((__ioc)->port_id)
+#define bfa_ioc_fetch_stats(__ioc, __stats) \
+		(((__stats)->drv_stats) = (__ioc)->stats)
+#define bfa_ioc_clr_stats(__ioc)	\
+		bfa_os_memset(&(__ioc)->stats, 0, sizeof((__ioc)->stats))
+#define bfa_ioc_maxfrsize(__ioc)	((__ioc)->attr->maxfrsize)
+#define bfa_ioc_rx_bbcredit(__ioc)	((__ioc)->attr->rx_bbcredit)
+#define bfa_ioc_speed_sup(__ioc)	\
+	BFI_ADAPTER_GETP(SPEED, (__ioc)->attr->adapter_prop)
+
+/**
+ * IOC mailbox interface
+ */
+void bfa_ioc_mbox_queue(struct bfa_ioc_s *ioc, struct bfa_mbox_cmd_s *cmd);
+void bfa_ioc_mbox_register(struct bfa_ioc_s *ioc,
+		bfa_ioc_mbox_mcfunc_t *mcfuncs);
+void bfa_ioc_mbox_isr(struct bfa_ioc_s *ioc);
+void bfa_ioc_mbox_send(struct bfa_ioc_s *ioc, void *ioc_msg, int len);
+void bfa_ioc_msgget(struct bfa_ioc_s *ioc, void *mbmsg);
+void bfa_ioc_mbox_regisr(struct bfa_ioc_s *ioc, enum bfi_mclass mc,
+		bfa_ioc_mbox_mcfunc_t cbfn, void *cbarg);
+
+/**
+ * IOC interfaces
+ */
+void bfa_ioc_attach(struct bfa_ioc_s *ioc, void *bfa,
+		struct bfa_ioc_cbfn_s *cbfn, struct bfa_timer_mod_s *timer_mod,
+		struct bfa_trc_mod_s *trcmod,
+		struct bfa_aen_s *aen, struct bfa_log_mod_s *logm);
+void bfa_ioc_detach(struct bfa_ioc_s *ioc);
+void bfa_ioc_pci_init(struct bfa_ioc_s *ioc, struct bfa_pcidev_s *pcidev,
+		enum bfi_mclass mc);
+u32 bfa_ioc_meminfo(void);
+void bfa_ioc_mem_claim(struct bfa_ioc_s *ioc,  u8 *dm_kva, u64 dm_pa);
+void bfa_ioc_enable(struct bfa_ioc_s *ioc);
+void bfa_ioc_disable(struct bfa_ioc_s *ioc);
+bfa_boolean_t bfa_ioc_intx_claim(struct bfa_ioc_s *ioc);
+
+void bfa_ioc_boot(struct bfa_ioc_s *ioc, u32 boot_type, u32 boot_param);
+void bfa_ioc_isr(struct bfa_ioc_s *ioc, struct bfi_mbmsg_s *msg);
+void bfa_ioc_error_isr(struct bfa_ioc_s *ioc);
+void bfa_ioc_isr_mode_set(struct bfa_ioc_s *ioc, bfa_boolean_t intx);
+bfa_status_t bfa_ioc_pll_init(struct bfa_ioc_s *ioc);
+bfa_boolean_t bfa_ioc_is_operational(struct bfa_ioc_s *ioc);
+bfa_boolean_t bfa_ioc_is_disabled(struct bfa_ioc_s *ioc);
+bfa_boolean_t bfa_ioc_fw_mismatch(struct bfa_ioc_s *ioc);
+bfa_boolean_t bfa_ioc_adapter_is_disabled(struct bfa_ioc_s *ioc);
+void bfa_ioc_cfg_complete(struct bfa_ioc_s *ioc);
+void bfa_ioc_get_attr(struct bfa_ioc_s *ioc, struct bfa_ioc_attr_s *ioc_attr);
+void bfa_ioc_get_adapter_attr(struct bfa_ioc_s *ioc,
+		struct bfa_adapter_attr_s *ad_attr);
+int bfa_ioc_debug_trcsz(bfa_boolean_t auto_recover);
+void bfa_ioc_debug_memclaim(struct bfa_ioc_s *ioc, void *dbg_fwsave);
+bfa_status_t bfa_ioc_debug_fwsave(struct bfa_ioc_s *ioc, void *trcdata,
+		int *trclen);
+bfa_status_t bfa_ioc_debug_fwtrc(struct bfa_ioc_s *ioc, void *trcdata,
+				 int *trclen);
+u32 bfa_ioc_smem_pgnum(struct bfa_ioc_s *ioc, u32 fmaddr);
+u32 bfa_ioc_smem_pgoff(struct bfa_ioc_s *ioc, u32 fmaddr);
+void bfa_ioc_set_fcmode(struct bfa_ioc_s *ioc);
+bfa_boolean_t bfa_ioc_get_fcmode(struct bfa_ioc_s *ioc);
+void bfa_ioc_hbfail_register(struct bfa_ioc_s *ioc,
+	struct bfa_ioc_hbfail_notify_s *notify);
+
+/*
+ * bfa mfg wwn API functions
+ */
+wwn_t bfa_ioc_get_pwwn(struct bfa_ioc_s *ioc);
+wwn_t bfa_ioc_get_nwwn(struct bfa_ioc_s *ioc);
+wwn_t bfa_ioc_get_wwn_naa5(struct bfa_ioc_s *ioc, u16 inst);
+mac_t bfa_ioc_get_mac(struct bfa_ioc_s *ioc);
+u64 bfa_ioc_get_adid(struct bfa_ioc_s *ioc);
+
+#endif /* __BFA_IOC_H__ */
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bfa_os_inc.h linux-2.6.32-rc4-mod/drivers/net/bna/bfa_os_inc.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bfa_os_inc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bfa_os_inc.h	2009-10-16 10:30:53.787436000 -0700
@@ -0,0 +1,210 @@
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
+ * Contains declarations all OS Specific files needed for BFA layer
+ */
+
+#ifndef __BFA_OS_INC_H__
+#define __BFA_OS_INC_H__
+
+#ifndef __KERNEL__
+#include <stdint.h>
+#else
+#include <linux/types.h>
+
+#include <linux/version.h>
+#include <linux/pci.h>
+
+#include <linux/dma-mapping.h>
+#define SET_MODULE_VERSION(VER)
+
+#include <linux/idr.h>
+
+#include <linux/interrupt.h>
+#include <linux/cdev.h>
+#include <linux/fs.h>
+#include <linux/delay.h>
+#include <linux/vmalloc.h>
+
+#include <linux/workqueue.h>
+
+
+
+#define BFA_ERR			KERN_ERR
+#define BFA_WARNING		KERN_WARNING
+#define BFA_NOTICE		KERN_NOTICE
+#define BFA_INFO		KERN_INFO
+#define BFA_DEBUG		KERN_DEBUG
+
+#define LOG_BFAD_INIT		0x00000001
+#define LOG_FCP_IO		0x00000002
+
+#ifdef DEBUG
+#define BFA_DEV_TRACE(bfad, level, fmt, arg...)				\
+		BFA_DEV_PRINTF(bfad, level, fmt, ## arg)
+#define BFA_TRACE(level, fmt, arg...)					\
+		BFA_PRINTF(level, fmt, ## arg)
+#else
+#define BFA_DEV_TRACE(bfad, level, fmt, arg...)
+#define BFA_TRACE(level, fmt, arg...)
+#endif
+
+#define BFA_ASSERT(p) do {						\
+	if (!(p)) {      \
+		printk(KERN_ERR "assert(%s) failed at %s:%d\n",		\
+		#p, __FILE__, __LINE__);      \
+		BUG();      \
+	}								\
+} while (0)
+
+
+#ifndef BFA_DEV_PRINTF
+#define BFA_DEV_PRINTF(bfad, level, fmt, arg...)			\
+		dev_printk(level, &(((struct bfad_s *)			\
+			(bfad))->pcidev->dev), fmt, ##arg);
+#endif
+
+#define BFA_PRINTF(level, fmt, arg...)					\
+		printk(level fmt, ##arg);
+
+int bfa_os_MWB(void *);
+
+#define bfa_os_mmiowb()		mmiowb()
+
+#define bfa_swap_3b(_x)				\
+	((((_x) & 0xff) << 16) |		\
+	((_x) & 0x00ff00) |			\
+	(((_x) & 0xff0000) >> 16))
+
+#define bfa_swap_8b(_x) 				\
+     ((((_x) & 0xff00000000000000ull) >> 56)		\
+      | (((_x) & 0x00ff000000000000ull) >> 40)		\
+      | (((_x) & 0x0000ff0000000000ull) >> 24)		\
+      | (((_x) & 0x000000ff00000000ull) >> 8)		\
+      | (((_x) & 0x00000000ff000000ull) << 8)		\
+      | (((_x) & 0x0000000000ff0000ull) << 24)		\
+      | (((_x) & 0x000000000000ff00ull) << 40)		\
+      | (((_x) & 0x00000000000000ffull) << 56))
+
+#define bfa_os_swap32(_x) 			\
+	((((_x) & 0xff) << 24) 		|	\
+	(((_x) & 0x0000ff00) << 8)	|	\
+	(((_x) & 0x00ff0000) >> 8)	|	\
+	(((_x) & 0xff000000) >> 24))
+
+
+#ifndef __BIGENDIAN
+#define bfa_os_htons(_x) ((u16)((((_x) & 0xff00) >> 8) | \
+				 (((_x) & 0x00ff) << 8)))
+
+#define bfa_os_htonl(_x)	bfa_os_swap32(_x)
+#define bfa_os_htonll(_x)	bfa_swap_8b(_x)
+#define bfa_os_hton3b(_x)	bfa_swap_3b(_x)
+
+#define bfa_os_wtole(_x)   (_x)
+
+#else
+
+#define bfa_os_htons(_x)   (_x)
+#define bfa_os_htonl(_x)   (_x)
+#define bfa_os_hton3b(_x)  (_x)
+#define bfa_os_htonll(_x)  (_x)
+#define bfa_os_wtole(_x)   bfa_os_swap32(_x)
+
+#endif
+
+#define bfa_os_ntohs(_x)   bfa_os_htons(_x)
+#define bfa_os_ntohl(_x)   bfa_os_htonl(_x)
+#define bfa_os_ntohll(_x)  bfa_os_htonll(_x)
+#define bfa_os_ntoh3b(_x)  bfa_os_hton3b(_x)
+
+#define bfa_os_u32(__pa64) ((__pa64) >> 32)
+
+#define bfa_os_memset	memset
+#define bfa_os_memcpy	memcpy
+#define bfa_os_udelay	udelay
+#define bfa_os_vsprintf vsprintf
+
+#define bfa_os_assign(__t, __s) __t = __s
+
+#define bfa_os_addr_t char __iomem *
+#define bfa_os_panic()
+
+#define bfa_os_reg_read(_raddr) bfa_os_wtole(readl(_raddr))
+#define bfa_os_reg_write(_raddr, _val) writel(bfa_os_wtole((_val)), (_raddr))
+#define bfa_os_mem_read(_raddr, _off)                                   \
+	bfa_os_ntohl(readl(((_raddr) + (_off))))
+#define bfa_os_mem_write(_raddr, _off, _val)                            \
+	writel(bfa_os_htonl((_val)), ((_raddr) + (_off)))
+
+#define BFA_TRC_TS(_trcm)						\
+			({						\
+				struct timeval tv;			\
+									\
+				do_gettimeofday(&tv);      \
+				(tv.tv_sec*1000000+tv.tv_usec);      \
+			 })
+
+#endif
+
+#define boolean_t int
+
+/**
+ * For current time stamp, OS API will fill-in
+ */
+struct bfa_timeval_s {
+	u32	tv_sec;		/*  seconds        */
+	u32	tv_usec;	/*  microseconds   */
+};
+
+void bfa_os_gettimeofday(struct bfa_timeval_s *tv);
+
+static inline void
+wwn2str(char *wwn_str, u64 wwn)
+{
+	union {
+		u64 wwn;
+		u8 byte[8];
+	} w;
+
+	w.wwn = wwn;
+	sprintf(wwn_str, "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x", w.byte[0],
+		w.byte[1], w.byte[2], w.byte[3], w.byte[4], w.byte[5],
+		w.byte[6], w.byte[7]);
+}
+
+static inline void
+fcid2str(char *fcid_str, u32 fcid)
+{
+	union {
+		u32 fcid;
+		u8 byte[4];
+	} f;
+
+	f.fcid = fcid;
+	sprintf(fcid_str, "%02x:%02x:%02x", f.byte[1], f.byte[2], f.byte[3]);
+}
+
+#endif /* __BFA_OS_INC_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bfa_timer.h linux-2.6.32-rc4-mod/drivers/net/bna/bfa_timer.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bfa_timer.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bfa_timer.h	2009-10-16 10:30:53.804448000 -0700
@@ -0,0 +1,60 @@
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
+#ifndef __BFA_TIMER_H__
+#define __BFA_TIMER_H__
+
+#include <bfa_os_inc.h>
+#include <cs/bfa_q.h>
+
+struct bfa_s;
+
+typedef void (*bfa_timer_cbfn_t)(void *);
+
+/**
+ * BFA timer data structure
+ */
+struct bfa_timer_s {
+	struct list_head	qe;
+	bfa_timer_cbfn_t timercb;
+	void            *arg;
+	int             timeout;	/**< in millisecs. */
+};
+
+/**
+ * Timer module structure
+ */
+struct bfa_timer_mod_s {
+	struct list_head timer_q;
+};
+
+#define BFA_TIMER_FREQ 500 /**< specified in millisecs */
+
+void bfa_timer_beat(struct bfa_timer_mod_s *mod);
+void bfa_timer_init(struct bfa_timer_mod_s *mod);
+void bfa_timer_begin(struct bfa_timer_mod_s *mod, struct bfa_timer_s *timer,
+			bfa_timer_cbfn_t timercb, void *arg,
+			unsigned int timeout);
+void bfa_timer_stop(struct bfa_timer_s *timer);
+
+#endif /* __BFA_TIMER_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bna.h linux-2.6.32-rc4-mod/drivers/net/bna/bna.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bna.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bna.h	2009-10-16 10:30:53.824442000 -0700
@@ -0,0 +1,2300 @@
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
+ *    Copyright (c) 2008- Brocade Communications Systems, Inc.
+ *    All rights reserved.
+ *
+ *    @file bna.h
+ *    BNA Exported Definitions & Prototypes
+ */
+
+#ifndef __BNA_H__
+#define __BNA_H__
+
+#include <bna_os.h>
+#include <cna.h>
+#include <bfa_timer.h>
+#include <bfa_ioc.h>
+#include <cna/pstats/phyport_defs.h>
+#include <cna/pstats/ethport_defs.h>
+#include <cee/bfa_cee.h>
+
+#define BNA_VLAN_ID_MAX 	4095
+
+#define BNA_TXQ_ID_MAX  	64
+#define BNA_RXQ_ID_MAX  	64
+#define BNA_CQ_ID_MAX   	64
+
+#define BNA_IB_ID_MAX   	128
+#define BNA_RIT_SIZE		256
+#define BNA_RIT_ID_MAX  	64
+
+#define BNA_UCAST_TABLE_SIZE	256
+#define BNA_MCAST_TABLE_SIZE	256
+
+#define BNA_HW_STATS_SIZE   	16384
+#define BNA_DEFAULT_RXF_ID  	0
+#define BNA_DEFAULT_TXF_ID  	0
+
+#define BNA_RXF_ID_NONE		255
+
+#define LOG_CRITICAL_LEVEL  1
+#define LOG_ERROR_LEVEL     2
+#define LOG_WARN_LEVEL      5
+#define LOG_INFO_LEVEL      6
+#define LOG_DEBUG_LEVEL     7
+
+struct bna_dma_addr {
+	u32	msb;
+	u32	lsb;
+};
+
+struct bna_dma_addr_le {
+	u32	le_lsb;
+	u32	le_msb;
+};
+
+#define BNA_MIN(x, y) (((x) < (y)) ? (x) : (y))
+
+#define BNA_MAC_IS_MULTICAST(_mac_ms_octet)	\
+					((_mac_ms_octet) & 0x01)
+#define BNA_MAC_IS_UNICAST(_mac_ms_octet)	\
+			(!BNA_MAC_IS_MULTICAST((_mac_ms_octet)))
+
+#define BNA_POWER_OF_2(x) (((x) & ((x) - 1)) == 0)
+#define BNA_TO_POWER_OF_2(x)		\
+do {					\
+	int _shift = 0;			\
+	while ((x) && (x) != 1) {      \
+		(x) >>= 1;		\
+		_shift++;		\
+	}				\
+	(x) <<= _shift;			\
+} while (0)
+
+#define BNA_TO_POWER_OF_2_HIGH(x)       \
+do {                                    \
+		int n = 1;                      \
+		while (n < (x)) {      \
+			n <<= 1;                \
+		}                               \
+		(x) = n;                        \
+} while (0)
+
+/**
+ * BNA_SET_DMA_ADDR()
+ *
+ *  Converts a dma address _addr from the host
+ *  endian format to the bna_dma_addr_t format.
+ *
+ * @param[in] _addr 	- DMA'able address in host endian format
+ * @param[in] _bna_dma_addr - Pointer to bna_dma_addr_t where address
+ *  			- will be stored.
+ */
+#define BNA_SET_DMA_ADDR(_addr, _bna_dma_addr)  			\
+do {									\
+	u64 tmp_addr = 						\
+	bna_os_dma_addr64((u64)(_addr));      \
+	(_bna_dma_addr)->msb = ((struct bna_dma_addr *)&tmp_addr)->msb;	\
+	(_bna_dma_addr)->lsb = ((struct bna_dma_addr *)&tmp_addr)->lsb;	\
+} while (0)
+
+/**
+ * BNA_GET_DMA_ADDR()
+ *
+ *  Converts a dma address _addr from the host
+ *  endian format to the bna_dma_addr_t format.
+ *
+ * @parma[in] _bna_dma_addr	- Pointer to bna_dma_addr_t where address will
+ * 				be stored.
+ * @param[in] _addr 		- DMA'able address in host endian format
+ */
+#define BNA_GET_DMA_ADDR(_bna_dma_addr, _addr)  			\
+do {									\
+	(_addr) = ((u64)(bna_os_ntohl((_bna_dma_addr)->msb)) << 32)\
+		| ((bna_os_ntohl((_bna_dma_addr)->lsb) & 0xffffffff));      \
+} while (0)
+
+/**
+ * BNA_ALIGN()
+ *
+ *	Aligns a size to a given value
+ *
+ * @param[in] _x	- Actual size to align
+ * @param[in] _a	- Value to which size should be aligned
+ *
+ */
+#define BNA_ALIGN(x, a)     (((x) + (a) - 1) & ~((a) - 1))
+
+enum bna_enable_e {BNA_DISABLE = 0, BNA_ENABLE = 1};
+
+enum bna_status_e {
+	BNA_OK = 0,
+	BNA_FAIL = 1,
+	BNA_DUPLICATE = 2,
+	BNA_BUSY = 3
+};
+
+enum {
+    BNA_FALSE = 0,
+    BNA_TRUE = 1
+};
+
+#define BNA_LARGE_PKT_SIZE 1000
+/**
+ * This structure is for dynamic interrupt moderation
+ * Should be part of the driver private structure.
+ */
+struct bna_pkt_rate {
+	u32 small_pkt_cnt;
+	u32 large_pkt_cnt;
+};
+#define BNA_UPDATE_PKT_CNT(_pkt, _len)		\
+do {						\
+	if ((_len) > BNA_LARGE_PKT_SIZE) {      \
+		(_pkt)->large_pkt_cnt++;	\
+	} else {				\
+		(_pkt)->small_pkt_cnt++;	\
+	}					\
+} while (0)
+
+/**
+ *  BNA callback function prototype The driver registers this
+ *  callback with BNA. This is called from the mailbox/error
+ *  handler routine of BNA, for further driver processing.
+ *
+ * @param[in] cbarg - Opaque cookie used by the driver to identify the callback.
+ * @param[in] cmd_code - Command code for the callback
+ * @param[in] status - Status as returned by the f/w
+ *
+ * @return    void
+ */
+
+typedef void (*bna_cbfn_t)(void *cbarg, u8 status);
+typedef void (*bna_diag_cbfn_t)(void *cbarg, void *data, u8 status);
+
+/**
+ *	Structure of callbacks implemented by the driver
+ */
+struct bna_mbox_cbfn {
+	bna_cbfn_t	ucast_set_cb;
+	bna_cbfn_t	ucast_add_cb;
+	bna_cbfn_t	ucast_del_cb;
+
+	bna_cbfn_t	mcast_add_cb;
+	bna_cbfn_t	mcast_del_cb;
+	bna_cbfn_t	mcast_filter_cb;
+	bna_cbfn_t	mcast_del_all_cb;
+
+	bna_cbfn_t	set_promisc_cb;
+	bna_cbfn_t	set_default_cb;
+
+	bna_cbfn_t	txq_stop_cb;
+	bna_cbfn_t	rxq_stop_cb;
+
+	bna_cbfn_t	port_admin_cb;
+	bna_cbfn_t	link_up_cb;
+	bna_cbfn_t	link_down_cb;
+
+	bna_cbfn_t	stats_get_cb;
+	bna_cbfn_t	stats_clr_cb;
+
+	bna_cbfn_t	hw_error_cb;
+
+	bna_cbfn_t      lldp_get_cfg_cb;
+	bna_cbfn_t      cee_get_stats_cb;
+
+	bna_cbfn_t	set_diag_lb_cb;	/* Diagnostics */
+
+	bna_cbfn_t	set_pause_cb;
+
+	bna_cbfn_t	mtu_info_cb;
+
+	bna_cbfn_t	rxf_cb;
+
+	bna_diag_cbfn_t	diag_get_temp_cb;
+	bna_diag_cbfn_t	diag_sfpshow_cb;
+	bna_diag_cbfn_t	diag_fwping_cb;
+	bna_diag_cbfn_t	diag_ledtest_cb;
+};
+
+struct bna_chip_regs_offset {
+	u32 page_addr;
+	u32 fn_int_status;
+	u32 fn_int_mask;
+	u32 msix_idx;
+};
+/**
+ * Memory mapped addresses of often used chip registers
+ */
+struct bna_chip_regs{
+	u8 *page_addr;
+	u8 *fn_int_status;
+	u8 *fn_int_mask;
+};
+
+#define BNA_MAX_MBOX_CMD_QUEUE  256
+#define BNA_MAX_MBOX_CMD_LEN	(BFI_IOC_MSGSZ * 4) /* 32 bytes */
+
+struct bna_mbox_cmd_qe {
+	struct bfa_mbox_cmd_s	cmd;
+	u32 cmd_len;	   /*  Length of the message in bytes */
+	void 	*cbarg;		/* non-default callback argument */
+};
+
+struct bna_mbox_q {
+	u32 producer_index;
+	u32 consumer_index;
+	void 	*posted;	/* Pointer to the posted element */
+	struct 	bna_mbox_cmd_qe mb_qe[BNA_MAX_MBOX_CMD_QUEUE];
+};
+
+/**
+ * BNA device structure
+ */
+struct bna_dev_s {
+	u8		*bar0;
+
+	u8		pci_fn;
+	u8		port;
+
+	u8		rxf_promiscuous_id;
+	u8		rxf_default_id;
+	u8		rit_size[BNA_RIT_ID_MAX];
+	u32	vlan_table[BNA_RXF_ID_MAX][(BNA_VLAN_ID_MAX + 1) / 32];
+	enum bna_enable_e	vlan_filter_enable[BNA_RXF_ID_MAX];
+	u64	rxf_active;
+	u64	txf_active;
+	u64	rxf_active_last;
+	u64	txf_active_last;
+
+	struct bfi_ll_stats  *hw_stats;
+	struct bna_dma_addr hw_stats_dma;
+
+	struct bna_stats  stats;
+
+	u32	mcast_47_32[BNA_MCAST_TABLE_SIZE];
+	u32	mcast_31_0[BNA_MCAST_TABLE_SIZE];
+
+	u32	tmp_mc_47_32[BNA_MCAST_TABLE_SIZE];
+	u32	tmp_mc_31_0[BNA_MCAST_TABLE_SIZE];
+
+	u32	rxa_arb_pri;	/* RxA Arbitration Priority */
+
+	struct bna_chip_regs regs;	/* Pointer to oft used registers */
+
+	struct bna_mbox_q mbox_q;
+	struct bna_mbox_cbfn	mb_cbfns;
+	void		*cbarg;		/* Argument to callback function */
+
+	/* IOC integration */
+	struct bfa_ioc_s 	ioc;
+	struct bfa_timer_mod_s 	timer_mod;
+	struct bfa_trc_mod_s	*trcmod;
+	struct bna_pkt_rate 	pkt_rate;  /* Packet rate structure */
+	u8			ioc_disable_pending;
+
+
+	u16		msg_ctr; /* Counter for mailbox messages posted */
+	struct bfa_cee_s 	*cee;
+};
+
+#define bna_get_handle_size() (sizeof(struct bna_dev_s))
+
+u8 bna_calc_coalescing_timer(struct bna_dev_s *dev, struct bna_pkt_rate *pkt);
+
+/**
+ * bna_reg_read()
+ *
+ *	Function to read the value of a register.
+ *	Returns value in little-endian format.
+ *
+ * @param[in] _raddr	- Absolute address of the register to read
+ *
+ * @return    u32	- Value of the register read
+ */
+#define bna_reg_read(_raddr)	bna_os_reg_read(_raddr)
+
+/**
+ * bna_reg_write()
+ *
+ *	Function to write the value to a register.
+ *	Writes in little-endian format.
+ *
+ * @param[in] _raddr	- Absolute address of the register to write.
+ * @param[in] _val	- Value to be written.
+ *
+ * @return    void
+ */
+#define bna_reg_write(_raddr, _val) bna_os_reg_write(_raddr, _val)
+
+/**
+ * bna_mem_readw()
+ *
+ *	Function to read the value of a memory location word by word.
+ *	Returns value in big-endian format.
+ *
+ * @param[in] _raddr	- Absolute address of the memory location to read.
+ *
+ * @return    u32	- Value (word) of the memory location read.
+ */
+/* #define bna_mem_readw(_raddr)	  bna_os_mem_readw(_raddr) */
+#define bna_mem_readw(_raddr)	  bna_os_reg_read(_raddr)
+
+/**
+ * bna_mem_writew()
+ *
+ *	Function to write a value to a given memory location.
+ *	Writes in big-endian format.
+ *
+ * @param[in] _raddr	- Absolute address of the memory location to write.
+ * @param[in] _val	- Value to be written.
+ *
+ * @return    void
+ */
+/* #define bna_mem_writew(_raddr, _val)	bna_os_mem_writew(_raddr, _val) */
+#define bna_mem_writew(_raddr, _val)	bna_os_reg_write(_raddr, _val)
+
+/**
+ *	Holds DMA physical and virtual memory addresses
+ *	and length. This is used for making IOC calls.
+ */
+struct bna_meminfo {
+	u8 *kva;	/* Kernel virtual address */
+	u64 dma;	/* Actual physical address */
+	u32 len;	/* Memory size in bytes */
+};
+
+enum bna_dma_mem_type {
+	BNA_DMA_MEM_T_DIAG = 0,
+	BNA_DMA_MEM_T_FLASH = 1,
+	BNA_DMA_MEM_T_ATTR = 2,
+	BNA_KVA_MEM_T_FWTRC = 3,
+	BNA_MEM_T_MAX,
+};
+
+
+
+
+/**
+ * bna_register_callback()
+ *
+ *  Function called by the driver to register a callback with
+ *  the BNA
+ *
+ * @param[in] dev    - Opaque handle to BNA private device.
+ * @param[in] cbfns  - Structure of callbacks from drivers.
+ * @param[in] cbarg  - Argument to use with the callback.
+ *
+ * @return    BNA_OK or BNA_FAIL
+ */
+void bna_register_callback(struct bna_dev_s *dev, struct bna_mbox_cbfn *cbfns,
+	void *cbarg);
+
+/* Port Management */
+
+struct bna_port_stats {
+	u64 rx_frame_64;
+	u64 rx_frame_65_127;
+	u64 rx_frame_128_255;
+	u64 rx_frame_256_511;
+	u64 rx_frame_512_1023;
+	u64 rx_frame_1024_1518;
+	u64 rx_frame_1518_1522;
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
+#define BNA_LINK_SPEED_10Gbps	10000
+struct bna_port_param {
+	u32 supported; /* Speeds and Flow Control supported */
+	u32 advertising;   /* speeds and Flow-Control advertised */
+	u32 speed;
+	u32 duplex;
+	u32 autoneg;
+	u32 port;
+};
+
+/**
+ * bna_port_param_get()
+ *
+ *   Get the port parameters.
+ *
+ * @param[in]   dev		- pointer to BNA device structure
+ * @param[out]  param_ptr	- pointer to where the parameters will be
+ *       			  returned.
+ * @return void
+ */
+void bna_port_param_get(struct bna_dev_s *dev,
+	 struct bna_port_param *param_ptr);
+
+
+/**
+ * bna_port_mac_get()
+ *
+ *   Get the Burnt-in or permanent MAC address.  This function does not return
+ *   the MAC set thru bna_rxf_ucast_mac_set() but the one that is assigned to
+ *   the port upon reset.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[out] mac_ptr - Burnt-in or permanent MAC address.
+ *
+ * @return void
+ */
+void bna_port_mac_get(struct bna_dev_s *dev, u8 *mac_ptr);
+
+
+/**
+ * bna_port_admin()
+ *
+ *   Enable (up) or disable (down) the interface administratively.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  enable - enable/disable the interface.
+ *
+ * @return void
+ */
+enum bna_status_e bna_port_admin(struct bna_dev_s *dev,
+	enum bna_enable_e enable);
+
+
+/**
+ * bna_port_stats_get()
+ *
+ *   Get the port statistics.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure
+ * @param[out]  stats_ptr - pointer to where the statistics will be returned.
+ *
+ * @return void
+ */
+void bna_port_stats_get(void *dev, struct bna_port_stats *stats_ptr);
+
+/**
+ * Ethernet 802.3X PAUSE confiiguration
+ */
+struct bna_pause_config {
+	u8		tx_pause;
+	u8		rx_pause;
+};
+
+/**
+ * bna_set_pause_config()
+ *
+ *   Enable/disable Tx/Rx pause through F/W
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure
+ * @param[in]   pause 	  - pointer to struct bna_pause_config
+ * @param[in]   cbarg	  - argument for the callback function
+ *
+ * @return BNA_OK in case of success BNA_FAIL otherwise.
+ */
+enum bna_status_e bna_set_pause_config(struct bna_dev_s *dev,
+	struct bna_pause_config *pause, void *cbarg);
+
+/**
+ * bna_mtu_info()
+ *
+ *   Send MTU information to F/W.
+ *   This is required to do PAUSE efficiently.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure
+ * @param[in]   mtu	  - current mtu size
+ * @param[in]   cbarg	  - argument for the callback function
+ *
+ * @return BNA_OK in case of success BNA_FAIL otherwise.
+ */
+enum bna_status_e bna_mtu_info(struct bna_dev_s *dev, u16 mtu, void *cbarg);
+
+/*
+ *
+ *
+ *   D O O R B E L L   D E F I N E S
+ *
+ *
+ */
+
+/**
+ * These macros build the data portion of the TxQ/RxQ doorbell.
+ */
+#define BNA_DOORBELL_Q_PRD_IDX(_producer_index) (0x80000000 | (_producer_index))
+#define BNA_DOORBELL_Q_STOP			(0x40000000)
+
+/* These macros build the data portion of the IB doorbell. */
+#define BNA_DOORBELL_IB_INT_ACK(_timeout, _events) \
+				(0x80000000 | ((_timeout) << 16) | (_events))
+#define BNA_DOORBELL_IB_INT_DISABLE 		(0x40000000)
+
+
+/*
+ *
+ *
+ *   I N T E R R U P T   B L O C K   D E F I N E S
+ *
+ *
+ */
+
+/* IB Structure */
+struct bna_ib {
+	void __iomem *doorbell_addr;	/* PCI address for IB doorbell */
+	u32 doorbell_ack;		/* ack data format except for #
+					of events */
+};
+
+
+/* IB Control Flags in IB Configuration */
+typedef u8 bna_ib_cf_t;
+
+#define BNA_IB_CF_RESERVED1 		(1 << 7)
+#define BNA_IB_CF_ACK_PENDING		(1 << 6)	/* Read Only */
+#define BNA_IB_CF_INTER_PKT_DMA		(1 << 5)	/* DMA segment w/o
+							   issuing interrupt */
+#define BNA_IB_CF_INT_ENABLE		(1 << 4)	/* Interrupt enable */
+#define BNA_IB_CF_INTER_PKT_ENABLE	(1 << 3)	/* Inter Packet
+							   Mechanism enable */
+#define BNA_IB_CF_COALESCING_MODE	(1 << 2)	/* 1 = Continuous Mode;
+							   0 = One-shot */
+#define BNA_IB_CF_MSIX_MODE		(1 << 1)	/* 1 = MSIX mode;
+							    0 = INTx mode */
+#define BNA_IB_CF_MASTER_ENABLE		(1 << 0)	/* Master Enable */
+
+
+/* IB Configuration Structure */
+struct bna_ib_config {
+	struct bna_dma_addr	ib_seg_addr;	/* Host Address of IB Segment */
+	u8			coalescing_timer;
+	bna_ib_cf_t		control_flags;
+	u8			msix_vector;
+	u8			interpkt_count;
+	u8			interpkt_timer;
+	u8			seg_size;	/* No. of entries */
+	u8			index_table_offset;
+};
+
+
+/*
+ * bna_ib_idx_reset()
+ *
+ *   For the specified IB, it clears the IB index
+ *
+ * @param[in] cfg_ptr - pointer to IB Configuration Structure.
+ *
+ * @return none
+ */
+void
+bna_ib_idx_reset(struct bna_dev_s *dev, const struct bna_ib_config *cfg_ptr);
+
+/**
+ * bna_ib_config_set()
+ *
+ *   For IB "ib_id", it configures the Interrupt Block specified by "cfg_ptr".
+ *
+ * @param[in] ib_ptr  - pointer to IB Data Structure.
+ * @param[in] ib_id   - interrupt-block ID
+ * @param[in] cfg_ptr - pointer to IB Configuration Structure.
+ *
+ * @return None
+ */
+void bna_ib_config_set(struct bna_dev_s *bna_dev, struct bna_ib *ib_ptr,
+	unsigned int ib_id, const struct bna_ib_config *cfg_ptr);
+
+
+/**
+ * bna_ib_ack()
+ *
+ *   Acknowledges the number of events triggered by the current interrupt.
+ *
+ * @param[in] bna_dev   - Opaque handle to bna device.
+ * @param[in] ib_ptr	- pointer to IB Data Structure.
+ * @param[in] events	- number of events to acknowledge.
+ *
+ * @return None
+ */
+static inline void bna_ib_ack(struct bna_dev_s *bna_dev,
+	const struct bna_ib *ib_ptr, u16 events) {
+	/*
+	 * bna_os_reg_write is defined in a header
+	 * included later
+	 */
+	bna_os_reg_write(ib_ptr->doorbell_addr,
+		(ib_ptr->doorbell_ack | events));
+}
+
+
+/**
+ * bna_ib_coalescing_timer_set()
+ *
+ *   Sets the timeout value in the coalescing timer
+ *
+ * @param[in] ib_ptr  - pointer to IB Data Structure.
+ * @param[in] timeout - coalescing timer value.
+ *
+ * @return None
+ */
+static inline void
+bna_ib_coalescing_timer_set(struct bna_dev_s *dev,
+    struct bna_ib *ib_ptr, u8 cls_timer) {
+	ib_ptr->doorbell_ack = BNA_DOORBELL_IB_INT_ACK(cls_timer, 0);
+}
+
+
+
+/**
+ * bna_ib_disable()
+ *
+ *   Disables the Interrupt Block "ib_id".
+ *
+ * @param[in] bna_dev - pointer to BNA private handle.
+ * @param[in] ib_ptr  - pointer to IB Data Structure.
+ *
+ * @return None
+ */
+void bna_ib_disable(struct bna_dev_s *bna_dev, const struct bna_ib *ib_ptr);
+
+
+/**
+ * Interrupt status register, mailbox status bits
+ */
+#define __LPU02HOST_MBOX0_STATUS_BITS 0x00100000
+#define __LPU12HOST_MBOX0_STATUS_BITS 0x00200000
+#define __LPU02HOST_MBOX1_STATUS_BITS 0x00400000
+#define __LPU12HOST_MBOX1_STATUS_BITS 0x00800000
+
+#define __LPU02HOST_MBOX0_MASK_BITS	0x00100000
+#define __LPU12HOST_MBOX0_MASK_BITS	0x00200000
+#define __LPU02HOST_MBOX1_MASK_BITS	0x00400000
+#define __LPU12HOST_MBOX1_MASK_BITS	0x00800000
+
+#define __LPU2HOST_MBOX_MASK_BITS			 \
+	(__LPU02HOST_MBOX0_MASK_BITS | __LPU02HOST_MBOX1_MASK_BITS |	\
+	  __LPU12HOST_MBOX0_MASK_BITS | __LPU12HOST_MBOX1_MASK_BITS)
+
+#define __LPU2HOST_IB_STATUS_BITS	0x0000ffff
+
+#define BNA_IS_LPU0_MBOX_INTR(_intr_status) \
+	((_intr_status) & (__LPU02HOST_MBOX0_STATUS_BITS | \
+			__LPU02HOST_MBOX1_STATUS_BITS))
+
+#define BNA_IS_LPU1_MBOX_INTR(_intr_status) \
+	((_intr_status) & (__LPU12HOST_MBOX0_STATUS_BITS | \
+		__LPU12HOST_MBOX1_STATUS_BITS))
+
+/**
+ * BNA_IS_MBOX_INTR()
+ *
+ *  Checks if the mailbox interrupt status bits
+ *  are set
+ *
+ * @param[in] _intr_status - Interrupt Status Register
+ */
+#define BNA_IS_MBOX_INTR(_intr_status)		\
+	((_intr_status) &  			\
+	(__LPU02HOST_MBOX0_STATUS_BITS |	\
+	 __LPU02HOST_MBOX1_STATUS_BITS |	\
+	 __LPU12HOST_MBOX0_STATUS_BITS |	\
+	 __LPU12HOST_MBOX1_STATUS_BITS))
+
+#define __EMC_ERROR_STATUS_BITS		0x00010000
+#define __LPU0_ERROR_STATUS_BITS	0x00020000
+#define __LPU1_ERROR_STATUS_BITS	0x00040000
+#define __PSS_ERROR_STATUS_BITS		0x00080000
+
+#define __HALT_STATUS_BITS		0x01000000
+
+#define __EMC_ERROR_MASK_BITS		0x00010000
+#define __LPU0_ERROR_MASK_BITS		0x00020000
+#define __LPU1_ERROR_MASK_BITS		0x00040000
+#define __PSS_ERROR_MASK_BITS		0x00080000
+
+#define __HALT_MASK_BITS		0x01000000
+
+#define __ERROR_MASK_BITS		\
+	(__EMC_ERROR_MASK_BITS | __LPU0_ERROR_MASK_BITS | \
+	  __LPU1_ERROR_MASK_BITS | __PSS_ERROR_MASK_BITS | \
+	  __HALT_MASK_BITS)
+
+/**
+ * BNA_IS_ERR_INTR()
+ *
+ *  Checks if the error interrupt status bits
+ *  are set
+ *
+ * @param[in] _intr_status - Interrupt Status Register
+ */
+#define BNA_IS_ERR_INTR(_intr_status)	\
+	((_intr_status) &  		\
+	(__EMC_ERROR_STATUS_BITS |  	\
+	 __LPU0_ERROR_STATUS_BITS | 	\
+	 __LPU1_ERROR_STATUS_BITS | 	\
+	 __PSS_ERROR_STATUS_BITS  | 	\
+	 __HALT_STATUS_BITS))
+
+/**
+ * BNA_IS_MBOX_ERR_INTR()
+ *
+ *  Checks if the mailbox and error interrupt status bits
+ *  are set
+ *
+ * @param[in] _intr_status - Interrupt Status Register
+ */
+#define BNA_IS_MBOX_ERR_INTR(_intr_status)	\
+	(BNA_IS_MBOX_INTR((_intr_status)) |	\
+	 BNA_IS_ERR_INTR((_intr_status)))	\
+
+/**
+ * BNA_IS_INTX_DATA_INTR()
+ *
+ *  Checks if the data bits (low 16 bits)
+ *  are set in case of INTx
+ *
+ * @param[in] _intr_status - Interrupt Status Register
+ */
+#define BNA_IS_INTX_DATA_INTR(_intr_status)	\
+	((_intr_status) & __LPU2HOST_IB_STATUS_BITS)
+
+/**
+ * BNA_INTR_STATUS_MBOX_CLR()
+ *
+ *  Clears the mailbox bits in _intr_status
+ *  Does not write to hardware
+ *
+ * @param[in] _intr_status - Interrupt Status Register
+ */
+#define BNA_INTR_STATUS_MBOX_CLR(_intr_status)			\
+do {								\
+	(_intr_status) &= ~(__LPU02HOST_MBOX0_STATUS_BITS |	\
+			__LPU02HOST_MBOX1_STATUS_BITS | 	\
+			__LPU12HOST_MBOX0_STATUS_BITS | 	\
+			__LPU12HOST_MBOX1_STATUS_BITS);      \
+} while (0)
+
+/**
+ * BNA_INTR_STATUS_ERR_CLR()
+ *
+ *  Clears the error bits in _intr_status
+ *  Does not write to hardware
+ *
+ * @param[in] _intr_status - Interrupt Status Register
+ */
+#define BNA_INTR_STATUS_ERR_CLR(_intr_status)		\
+do {							\
+	(_intr_status) &= ~(__EMC_ERROR_STATUS_BITS |	\
+		__LPU0_ERROR_STATUS_BITS |		\
+		__LPU1_ERROR_STATUS_BITS |		\
+		__PSS_ERROR_STATUS_BITS  |		\
+		__HALT_STATUS_BITS);      \
+} while (0)
+
+
+/**
+ * bna_mbox_err_handler()
+ *
+ *    The driver calls this API back after processing the
+ *    mailbox/error interrupt for MSIX and INTx types.
+ *    Should be called with a lock held.
+ *    This will do the following for mbox interrupt :
+ *  1) Read the contents of the mbox
+ *  	2) Call a function registered by the OS driver to handle
+ *     the mailbox command.
+ *  3) Queue the next mbox command
+ *    This will do the following for error interrupt :
+ *  1) Interpret the type of error & call the
+ *     right BNA handler.
+ *  2) Call the driver defined callback.
+ *
+ * @param[in] bna_dev   - Pointer to BNA private handle.
+ * @param[in] status	- Interrupt status register.
+ *
+ * @return void
+ */
+void bna_mbox_err_handler(struct bna_dev_s *bna_dev, u32 status);
+
+/**
+ * bna_mbox_send()
+ *
+ *    The driver calls this API to send a command to the
+ *    firmware
+ *
+ * @param[in] bna_dev   - Pointer to BNA private handle.
+ * @param[in] cmd   	- pointer to the command structur
+ * @param[in] cmd_len   - length of the command structure
+ *
+ * @return BNA_OK or BNA_FAIL
+ */
+enum bna_status_e bna_mbox_send(struct bna_dev_s *bna_dev, void *cmd,
+	u32 cmd_len, void *cbarg);
+
+
+
+/*******************************************************************/
+/*
+ *
+ *
+ *   Q U E U E   D E F I N E S
+ *
+ *
+ */
+#define BNA_TXQ_ENTRY_SIZE	64  /* bytes */
+#define BNA_RXQ_ENTRY_SIZE	8   /* bytes */
+#define BNA_CQ_ENTRY_SIZE	16  /* bytes */
+/**
+ *  Queue Page Table (QPT)
+ */
+struct bna_qpt {				/* Queue Page Table */
+	struct bna_dma_addr	hw_qpt_ptr;	/* Pointer to QPT used by HW */
+	void *kv_qpt_ptr;	/* Kernel virtual pointer to
+						   hw QPT */
+	void			**qpt_ptr;	/* Pointer to S/W QPT for page
+						   segmented Q's */
+	u16		page_count;	/* Size of QPT (i.e., number of
+						   pages) */
+	u16		page_size;	/* Size of each page */
+};
+
+#define BNA_QPT_SIZE(_queue_size, _page_size)	\
+			(((_queue_size) + (_page_size) - 1)/(_page_size))
+
+struct bna_q {
+	u16	producer_index;
+	u16	consumer_index;
+	u32	q_depth;	/* Depth of the q */
+	void		**qpt_ptr;	/* pointer to SW QPT for Page-segmented
+					   queue */
+};
+
+
+/**
+ * BNA_TXQ_QPGE_PTR_GET()
+ *
+ *   Gets the pointer corresponding to an queue-entry index for a
+ *   page-segmented queue.
+ *
+ *   NOTE:  _q_depth, sizeof(_cast) and BNA_PAGE_SIZE must be power of two.
+ *  		_q_depth * sizeof(_cast) must be multiple of a BNA_PAGE_SIZE.
+ *
+ * @param[in]  _qe_idx  	 - producer/consumer queue entry index
+ * @param[in]  _q_ptr   	 - pointer to page-segmented queue structure
+ * @param[out] _qe_ptr  	 - producer/consumer queue-entry pointer
+ * @param[out] _qe_ptr_range	 - number of entries addressable by
+ *                                 queue-entry pointer (warns going beyond the
+ *                                 page-size)
+ */
+/* TxQ element is 64 bytes */
+#define BNA_TXQ_PAGE_INDEX_MAX (BNA_PAGE_SIZE >> 6)
+#define BNA_TXQ_PAGE_INDEX_MAX_SHIFT (BNA_PAGE_SHIFT - 6)
+
+#define BNA_TXQ_QPGE_PTR_GET(_qe_idx, _q_ptr, _qe_ptr, _qe_ptr_range) \
+{ \
+      unsigned int page_index;        /* index within a page */ \
+      void *page_addr; \
+      \
+      page_index = (_qe_idx) & (BNA_TXQ_PAGE_INDEX_MAX - 1);      \
+      (_qe_ptr_range) = (BNA_TXQ_PAGE_INDEX_MAX - page_index);      \
+      page_addr = \
+	(_q_ptr)->qpt_ptr[((_qe_idx) >> BNA_TXQ_PAGE_INDEX_MAX_SHIFT)]; \
+      (_qe_ptr) = &((struct bna_txq_entry *)(page_addr))[page_index]; \
+}
+
+/**
+ * BNA_RXQ_QPGE_PTR_GET()
+ *
+ *   Gets the pointer corresponding to an queue-entry index for a
+ *   page-segmented queue.
+ *
+ *   NOTE:  _q_depth, sizeof(_cast) and BNA_PAGE_SIZE must be power of two.
+ *  		_q_depth * sizeof(_cast) must be multiple of a BNA_PAGE_SIZE.
+ *
+ * @param[in]  _qe_idx  	 - producer/consumer queue entry index
+ * @param[in]  _q_ptr   	 - pointer to page-segmented queue structure
+ * @param[out] _qe_ptr  	 - producer/consumer queue-entry pointer
+ * @param[out] _qe_ptr_range	 - number of entries addressable by
+ *                                 queue-entry pointer (warns going beyond the
+ *                                 page-size)
+ */
+#define BNA_RXQ_PAGE_INDEX_MAX (BNA_PAGE_SIZE >> 3) /* RxQ element is 8 bytes */
+#define BNA_RXQ_PAGE_INDEX_MAX_SHIFT (BNA_PAGE_SHIFT - 3)
+
+#define BNA_RXQ_QPGE_PTR_GET(_qe_idx, _q_ptr, _qe_ptr, _qe_ptr_range) \
+{ \
+      unsigned int page_index;        /* index within a page */ \
+      void *page_addr; \
+      \
+      page_index = (_qe_idx) & (BNA_RXQ_PAGE_INDEX_MAX - 1);      \
+      (_qe_ptr_range) = (BNA_RXQ_PAGE_INDEX_MAX - page_index);      \
+      page_addr = \
+	(_q_ptr)->qpt_ptr[((_qe_idx) >> BNA_RXQ_PAGE_INDEX_MAX_SHIFT)]; \
+      (_qe_ptr) = &((struct bna_rxq_entry *)(page_addr))[page_index]; \
+}
+
+/**
+ * BNA_CQ_QPGE_PTR_GET()
+ *
+ *   Gets the pointer corresponding to an queue-entry index for a
+ *   page-segmented queue.
+ *
+ *   NOTE:  _q_depth, sizeof(_cast) and BNA_PAGE_SIZE must be power of two.
+ *  		_q_depth * sizeof(_cast) must be multiple of a BNA_PAGE_SIZE.
+ *
+ * @param[in]  _qe_idx  	 - producer/consumer queue entry index
+ * @param[in]  _q_ptr   	 - pointer to page-segmented queue structure
+ * @param[out] _qe_ptr  	 - producer/consumer queue-entry pointer
+ * @param[out] _qe_ptr_range	 - number of entries addressable by
+ *                                 queue-entry pointer (warns going beyond the
+ *                                 page-size)
+ */
+#define BNA_CQ_PAGE_INDEX_MAX (BNA_PAGE_SIZE >> 4) /* CQ element is 16 bytes */
+#define BNA_CQ_PAGE_INDEX_MAX_SHIFT (BNA_PAGE_SHIFT - 4)
+
+#define BNA_CQ_QPGE_PTR_GET(_qe_idx, _q_ptr, _qe_ptr, _qe_ptr_range) \
+{ \
+      unsigned int page_index;        /* index within a page */ \
+      void *page_addr; \
+      \
+      page_index = (_qe_idx) & (BNA_CQ_PAGE_INDEX_MAX - 1);      \
+      (_qe_ptr_range) = (BNA_CQ_PAGE_INDEX_MAX - page_index);      \
+      page_addr = \
+	(_q_ptr)->qpt_ptr[((_qe_idx) >> BNA_CQ_PAGE_INDEX_MAX_SHIFT)]; \
+      (_qe_ptr) = &((struct bna_cq_entry *)(page_addr))[page_index]; \
+}
+
+/**
+ * BNA_QE_INDX_2_PTR()
+ *
+ *   Gets the pointer corresponding to an queue-entry index for a virtually-
+ *   contiguous queue.
+ *
+ *   NOTE:  _q_depth must be power of two.
+ *
+ * @param[in]  _cast		 - type cast of the entry.
+ * @param[in]  _qe_idx  	 - producer/consumer queue entry index
+ * @param[in]  _q_base  	 - queue base address
+ */
+#define BNA_QE_INDX_2_PTR(_cast, _qe_idx, _q_base) \
+	(&((_cast *)(_q_base))[(_qe_idx)])
+
+
+/**
+ * BNA_QE_INDX_RANGE()
+ *
+ *   Returns number of entries that can be consecutively addressed for the
+ *   specified queue.  This function indicates when BNA_QE_INDX_2_PTR() must
+ *   be called again get a new pointer due to the effect of wrapping around
+ *   the queue.
+ *
+ *   NOTE:  _q_depth must be power of two.
+ *
+ * @param[in]  _qe_idx  	 - producer/consumer queue entry index
+ * @param[in]  _q_depth 	 - queue size in number of entries
+ */
+#define BNA_QE_INDX_RANGE(_qe_idx, _q_depth) \
+	((_q_depth) - (_qe_idx))
+
+
+/**
+ * BNA_QE_INDX_ADD()
+ *
+ *   Adds to a producer or consumer queue-entry index for either
+ *   virtually-contiguous or page-segmented queue.
+ *
+ *   NOTE:  _q_depth must power of two.
+ *
+ * @param[in]  _qe_idx  - producer/consumer queue entry index
+ * @param[out] _qe_idx  - updated producer/consumer queue entry index
+ * @param[in]  _q_depth - queue size in number of entries
+ */
+#define BNA_QE_INDX_ADD(_qe_idx, _qe_num, _q_depth) \
+	((_qe_idx) = ((_qe_idx) + (_qe_num)) & ((_q_depth) - 1))
+
+
+/**
+ * BNA_QE_FREE_CNT
+ *
+ *   Returns the number of entries that can be added into the queue.
+ *
+ *   NOTE:  Must reserved one entry to distinguish between an empty
+ *  		and a full queue.
+ *
+ * @param[in]  _q_ptr   - pointer to queue structure
+ * @param[in]  _q_depth - queue size in number of entries
+ */
+#define BNA_QE_FREE_CNT(_q_ptr, _q_depth) \
+  (((_q_ptr)->consumer_index - (_q_ptr)->producer_index - 1) & ((_q_depth) - 1))
+
+/**
+ * BNA_QE_IN_USE_CNT
+ *
+ *    Returns the number of entries in the queue.
+ *
+ * @param[in]  _q_ptr   - pointer to queue structure
+ * @param[in]  _q_depth - queue size in number of entries
+ */
+#define BNA_QE_IN_USE_CNT(_q_ptr, _q_depth) \
+   ((((_q_ptr)->producer_index - (_q_ptr)->consumer_index)) & (_q_depth - 1))
+
+
+/**
+ * BNA_Q_GET_CI
+ *
+ *    Returns the current consumer index for that queue.
+ *
+ * @param[in]  _q_ptr   - pointer to queue (Tx/Rx/C) structure
+ */
+#define BNA_Q_GET_CI(_q_ptr)   \
+	((_q_ptr)->q.consumer_index)
+
+/**
+ * BNA_Q_GET_PI
+ *
+ *    Returns the current producer index for that queue.
+ *
+ * @param[in]  _q_ptr   - pointer to queue (Tx/Rx/C) structure
+ */
+#define BNA_Q_GET_PI(_q_ptr)   \
+	((_q_ptr)->q.producer_index)
+
+/**
+ * BNA_Q_PI_ADD
+ *
+ *   Increments the producer index of the queue by a certain number
+ *
+ * @param[in]  _q_ptr   - pointer to queue (Tx/Rx/C) structure
+ * @param[in]  _num 	- the number by which CI needs to be incremented
+ */
+#define BNA_Q_PI_ADD(_q_ptr, _num) 		\
+	(_q_ptr)->q.producer_index =			\
+		(((_q_ptr)->q.producer_index + (_num))  \
+		& ((_q_ptr)->q.q_depth - 1))
+
+/**
+ * BNA_Q_CI_ADD
+ *
+ *   Increments the consumer index of the queue by a certain number
+ *
+ * @param[in]  _q_ptr   - pointer to queue (Tx/Rx/C) structure
+ * @param[in]  _num 	- the number by which CI needs to be incremented
+ */
+#define BNA_Q_CI_ADD(_q_ptr, _num) 		\
+	(_q_ptr)->q.consumer_index =			\
+		(((_q_ptr)->q.consumer_index + (_num))  \
+		& ((_q_ptr)->q.q_depth - 1))
+
+/**
+ * BNA_Q_FREE_COUNT()
+ *
+ *  Returns the number of free entries for TxQ/RxQ/CQ
+ *
+ * @param[in] _q_ptr	- pointer to TxQ/RxQ/CQ
+ */
+#define BNA_Q_FREE_COUNT(_q_ptr)			\
+	(BNA_QE_FREE_CNT(&((_q_ptr)->q), (_q_ptr)->q.q_depth))
+
+/**
+ * BNA_Q_FREE_COUNT()
+ *
+ *  Returns the number of entries in use for the queue.
+ *
+ * @param[in] _q_ptr	- pointer to TxQ/RxQ/CQ
+ */
+#define BNA_Q_IN_USE_COUNT(_q_ptr)  		\
+	(BNA_QE_IN_USE_CNT(&(_q_ptr)->q, (_q_ptr)->q.q_depth))
+/*
+ *
+ *
+ *   T X   Q U E U E   D E F I N E S
+ *
+ *
+ */
+/* TxQ Vector (a.k.a. Tx-Buffer Descriptor) */
+struct bna_txq_wi_vector {  /* Tx Buffer Descriptor */
+	u16		reserved;
+	u16		length; 	/* Only 14 LSB are valid */
+	struct bna_dma_addr  host_addr; 	/* Tx-Buffer DMA address */
+};
+
+
+/* TxQ Entry Opcodes */
+#define BNA_TXQ_WI_SEND 		(0x402)	/* Single Frame Transmission */
+#define BNA_TXQ_WI_SEND_LSO 		(0x403)	/* Multi-Frame Transmission */
+#define BNA_TXQ_WI_EXTENSION		(0x104)	/* Extension WI */
+typedef u16 bna_txq_wi_opcode_t;
+
+
+/* TxQ Entry Control Flags */
+#define BNA_TXQ_WI_CF_FCOE_CRC  	(1 << 8)
+#define BNA_TXQ_WI_CF_IPID_MODE 	(1 << 5)
+#define BNA_TXQ_WI_CF_INS_PRIO  	(1 << 4)
+#define BNA_TXQ_WI_CF_INS_VLAN  	(1 << 3)
+#define BNA_TXQ_WI_CF_UDP_CKSUM 	(1 << 2)
+#define BNA_TXQ_WI_CF_TCP_CKSUM 	(1 << 1)
+#define BNA_TXQ_WI_CF_IP_CKSUM  	(1 << 0)
+typedef u16 bna_txq_wi_ctrl_flag_t;
+
+
+/**
+ *  TxQ Entry Structure
+ *
+ *  BEWARE:  Load values into this structure with correct endianess.
+ */
+struct bna_txq_entry {
+	union {
+		struct {
+			u8 reserved;
+			u8 num_vectors;	/* number of vectors present */
+			bna_txq_wi_opcode_t opcode; /* Either BNA_TXQ_WI_SEND or
+						BNA_TXQ_WI_SEND_LSO */
+			bna_txq_wi_ctrl_flag_t  flags;	/* OR of all the flags*/
+			u16	l4_hdr_size_n_offset;
+			u16	vlan_tag;
+			u16	lso_mss; /* Only 14 LSB are valid */
+			u32	frame_length; /* Only 24 LSB are valid*/
+		} wi;
+
+		struct {
+			u16	reserved;
+			bna_txq_wi_opcode_t 	opcode;/* Must be
+						BNA_TXQ_WI_EXTENSION */
+			u32	reserved2[3]; /* Place holder for
+					    removed vector (12 bytes) */
+		} wi_ext;
+	} hdr;
+	struct bna_txq_wi_vector vector[4];
+};
+#define wi_hdr  	hdr.wi
+#define wi_ext_hdr  hdr.wi_ext
+
+#define BNA_TXQ_WI_L4_HDR_N_OFFSET(_hdr_size, _offset) \
+		(((_hdr_size) << 10) | ((_offset) & 0x3FF))
+
+/* TxQ Structure */
+struct bna_txq {
+	u32	*doorbell;
+	struct		bna_q q;
+};
+
+
+/* TxQ Configuration */
+struct bna_txq_config {
+	struct bna_qpt qpt;
+	u16	ib_id;
+	u8 	ib_seg_index;	/* index into IB segment */
+	u8 	txf_id;		/* Tx-Function ID */
+	u8 	priority;	/* frame or scheduling priority? FIXME*/
+	u16	wrr_quota;	/* Weighted Round-Robin Quota */
+};
+
+
+/**
+ * bna_txq_config()
+ *
+ * For TxQ "txq_id", it configures the Tx-Queue as specified by "cfg_ptr".
+ */
+void bna_txq_config(struct bna_dev_s *dev, struct bna_txq *q_ptr,
+		unsigned int txq_id, const struct bna_txq_config *cfg_ptr);
+
+
+
+/**
+ * bna_txq_pg_prod_ptr()
+ *
+ * Returns the producer pointer and its range for the specified page-segmented
+ * queue.
+ */
+static inline struct bna_txq_entry
+	*bna_txq_pg_prod_ptr(const struct bna_txq *q_ptr,
+			      unsigned int *ptr_range) {
+	struct bna_txq_entry *qe_ptr;
+
+	BNA_TXQ_QPGE_PTR_GET(q_ptr->q.producer_index,
+			  &q_ptr->q, qe_ptr, *ptr_range);
+	return qe_ptr;
+}
+
+/**
+ * bna_txq_prod_indx_doorbell()
+ *
+ * Informs Catapult ASIC about queued entries.
+ */
+static inline void bna_txq_prod_indx_doorbell(const struct bna_txq *q_ptr)
+{
+	bna_os_reg_write(q_ptr->doorbell,
+			 BNA_DOORBELL_Q_PRD_IDX(q_ptr->q.producer_index));
+}
+
+
+/**
+ * bna_txq_pg_cons_ptr()
+ *
+ * Returns the consumer pointer and its range for the specified
+ * page-segmented
+ * queue.
+ */
+static inline struct bna_txq_entry
+*bna_txq_pg_cons_ptr(const struct bna_txq *q_ptr, unsigned int *ptr_range) {
+	struct bna_txq_entry *qe_ptr;
+
+	BNA_TXQ_QPGE_PTR_GET(q_ptr->q.consumer_index,
+			  &q_ptr->q, qe_ptr, *ptr_range);
+	return qe_ptr;
+}
+
+/**
+ * bna_txq_stop()
+ *
+ * 	Stops the RxQ identified by the RxQ Id.
+ *  	Should be called with a lock held
+ *	The driver should wait for the response to
+ *	know if the Q stop is successful or not.
+ *
+ * @param[in] q_id	- Id of the TxQ
+ *
+ * @return    BNA_OK in case of success, else BNA_FAIL
+ */
+enum bna_status_e bna_txq_stop(struct bna_dev_s *bna_dev, u32 txq_id);
+
+/*
+ *
+ *
+ *   R X   Q U E U E   D E F I N E S
+ *
+ *
+ */
+/* RxQ Entry (Rx-Vector, Rx-Buffer Address) */
+struct bna_rxq_entry {	/* Rx-Buffer */
+	struct bna_dma_addr  host_addr; 	 /* Rx-Buffer DMA address */
+};
+
+
+/* RxQ Structure */
+struct bna_rxq {
+	u32	*doorbell;
+	struct bna_q   q;
+};
+
+
+/* RxQ Configuration */
+struct bna_rxq_config {
+	struct bna_qpt   qpt;
+	u8 	cq_id;  		/* Completion Queue ID */
+	u16	buffer_size;	/* Rx-Buffer Length */
+};
+
+/**
+ *  bna_rxq_config()
+ *
+ *  For RxQ "rxq_id", it configures the Rx-Queue as specified by "cfg_ptr".
+ */
+void bna_rxq_config(struct bna_dev_s *dev, struct bna_rxq *q_ptr,
+		unsigned int rxq_id, const struct bna_rxq_config *cfg_ptr);
+
+/**
+ * bna_rxq_pg_prod_ptr()
+ *
+ * Returns the producer pointer and its range for the specified
+ * page-segmented
+ * queue.
+ */
+static inline struct bna_rxq_entry
+*bna_rxq_pg_prod_ptr(const struct bna_rxq *q_ptr, unsigned int *ptr_range) {
+	struct bna_rxq_entry *qe_ptr;
+
+	BNA_RXQ_QPGE_PTR_GET(q_ptr->q.producer_index,
+			  &q_ptr->q, qe_ptr, *ptr_range);
+	return qe_ptr;
+}
+/**
+ * bna_rxq_pg_cons_ptr()
+ *
+ * Returns the consumer pointer and its range for the specified
+ * page-segmented
+ * queue.
+ */
+static inline struct bna_rxq_entry
+*bna_rxq_pg_cons_ptr(const struct bna_rxq *q_ptr, unsigned int *ptr_range) {
+	struct  bna_rxq_entry *qe_ptr;
+
+	BNA_RXQ_QPGE_PTR_GET(q_ptr->q.consumer_index,
+			  &q_ptr->q, qe_ptr, *ptr_range);
+	return qe_ptr;
+}
+
+/**
+ * bna_rxq_prod_indx_doorbell()
+ *
+ * Informs Catapult ASIC about queued entries.
+ */
+static inline void bna_rxq_prod_indx_doorbell(const struct bna_rxq *q_ptr)
+{
+	bna_os_reg_write(q_ptr->doorbell,
+		BNA_DOORBELL_Q_PRD_IDX(q_ptr->q.producer_index));
+}
+
+
+/**
+ * bna_rxq_stop()
+ *
+ * 	Stops the RxQ identified by the RxQ Id.
+ *	Should be called with a lock held
+ *	The driver should wait for the response to
+ *	know if the Q stop is successful or not.
+ *
+ * @param[in] q_id	- Id of the RxQ
+ *
+ * @return    BNA_OK in case of success, else BNA_FAIL
+ */
+enum bna_status_e bna_rxq_stop(struct bna_dev_s *bna_dev, u32 rxq_id);
+
+/**
+ * bna_multi_rxq_stop()
+ *
+ * 	Stops the set of RxQs identified by rxq_id_mask
+ *	Should be called with a lock held
+ *	The driver should wait for the response to
+ *	know if the Q stop is successful or not.
+ *
+ * @param[in] q_id	- Id of the RxQ
+ *
+ * @return    BNA_OK in case of success, else BNA_FAIL
+ */
+enum bna_status_e bna_multi_rxq_stop(struct bna_dev_s *dev, u64 rxq_id_mask);
+/*
+ *
+ *
+ *   R X   C O M P L E T I O N   Q U E U E   D E F I N E S
+ *
+ *
+ */
+/* CQ Entry Flags */
+#define	BNA_CQ_EF_MAC_ERROR 	(1 <<  0)
+#define	BNA_CQ_EF_FCS_ERROR 	(1 <<  1)
+#define	BNA_CQ_EF_TOO_LONG  	(1 <<  2)
+#define	BNA_CQ_EF_FC_CRC_OK 	(1 <<  3)
+
+#define	BNA_CQ_EF_RSVD1 	(1 <<  4)
+#define	BNA_CQ_EF_L4_CKSUM_OK	(1 <<  5)
+#define	BNA_CQ_EF_L3_CKSUM_OK	(1 <<  6)
+#define	BNA_CQ_EF_HDS_HEADER	(1 <<  7)
+
+#define	BNA_CQ_EF_UDP   	(1 <<  8)
+#define	BNA_CQ_EF_TCP   	(1 <<  9)
+#define	BNA_CQ_EF_IP_OPTIONS	(1 << 10)
+#define	BNA_CQ_EF_IPV6  	(1 << 11)
+
+#define	BNA_CQ_EF_IPV4  	(1 << 12)
+#define	BNA_CQ_EF_VLAN  	(1 << 13)
+#define	BNA_CQ_EF_RSS   	(1 << 14)
+#define	BNA_CQ_EF_RSVD2 	(1 << 15)
+
+#define	BNA_CQ_EF_MCAST_MATCH   (1 << 16)
+#define	BNA_CQ_EF_MCAST 	(1 << 17)
+#define BNA_CQ_EF_BCAST 	(1 << 18)
+#define	BNA_CQ_EF_REMOTE 	(1 << 19)
+
+#define	BNA_CQ_EF_LOCAL		(1 << 20)
+typedef u32 bna_cq_e_flag_t;
+
+
+/* CQ Entry Structure */
+struct bna_cq_entry {
+	bna_cq_e_flag_t flags;
+	u16	vlan_tag;
+	u16	length;
+	u32	rss_hash;
+	u8 	valid;
+	u8 	reserved1;
+	u8 	reserved2;
+	u8 	rxq_id;
+};
+
+
+/* CQ Structure */
+struct bna_cq {
+	struct bna_q   q;
+};
+
+
+/* CQ Configuration */
+struct bna_cq_config {
+	struct bna_qpt	qpt;
+	u16	ib_id;
+	u8		ib_seg_index;   /* index into IB segment */
+};
+
+/**
+ *  bna_cq_config()
+ *
+ *  For CQ "cq_id", it configures the Rx-Completion Queue as specified by
+ *  "cfg_ptr".
+ */
+void bna_cq_config(struct bna_dev_s *dev, struct bna_cq *q_ptr,
+	unsigned int cq_id, const struct bna_cq_config *cfg_ptr);
+
+
+/**
+ * bna_cq_pg_prod_ptr()
+ *
+ * Returns the producer pointer and its range for the specified
+ * page-segmented
+ * queue.
+ */
+static inline struct bna_cq_entry
+*bna_cq_pg_prod_ptr(const struct bna_cq *q_ptr, unsigned int *ptr_range) {
+	struct bna_cq_entry *qe_ptr;
+
+	BNA_CQ_QPGE_PTR_GET(q_ptr->q.producer_index,
+			  &q_ptr->q, qe_ptr, *ptr_range);
+	return qe_ptr;
+}
+/**
+ * bna_cq_pg_cons_ptr()
+ *
+ * Returns the consumer pointer and its range for the specified
+ * page-segmented
+ * queue.
+ */
+static inline struct bna_cq_entry
+*bna_cq_pg_cons_ptr(const struct bna_cq *q_ptr, unsigned int *ptr_range) {
+	struct  bna_cq_entry *qe_ptr;
+
+	BNA_CQ_QPGE_PTR_GET(q_ptr->q.consumer_index,
+			  &q_ptr->q, qe_ptr, *ptr_range);
+	return qe_ptr;
+}
+/*
+ *
+ *
+ *   T X   F U N C T I O N   D E F I N E S
+ *
+ *
+ */
+
+/**
+ * TxF Control Flags
+ *
+ * BNA_TXF_CF_VLAN_INSERT & BNA_TXF_CF_VLAN_ADMIT are only applicable when
+ * BNA_TXF_CF_VLAN_WI_BASED == 0 (i.e., VLAN MODE = By Tx-Function).
+ */
+#define	BNA_TXF_CF_VSWITCH_UCAST	(1 << 15)
+#define	BNA_TXF_CF_VSWITCH_MCAST	(1 << 14)
+#define	BNA_TXF_CF_VLAN_WI_BASED	(1 << 13) /*  else Tx-Function Based */
+#define	BNA_TXF_CF_MAC_SA_CHECK 	(1 << 12)
+#define	BNA_TXF_CF_RSVD1		(1 << 11)
+#define	BNA_TXF_CF_VLAN_INSERT  (1 << 10) /*  Insert function's VLAN ID */
+#define	BNA_TXF_CF_VLAN_ADMIT   (1 <<  9) /*  process VLAN frames from Host */
+#define	BNA_TXF_CF_VLAN_FILTER  (1 <<  8) /*  check against Rx VLAN Table */
+#define	BNA_TXF_CF_RSVD2		(0x7F << 1)
+#define	BNA_TXF_CF_ENABLE   		(1 <<  0)
+typedef u16 bna_txf_ctrl_flag_t;
+
+
+/* TxF Configuration */
+struct bna_txf_config {
+	bna_txf_ctrl_flag_t flags; /* OR of bna_txf_ctrl_flag_t */
+	u16	vlan;	/* valid when BNA_TXF_CF_VLAN_WI_BASED == 0 */
+	u8 	rxf_id; /* validate BNA_TXF_CF_VSWITCH_UCAST */
+};
+
+/**
+ * bna_txf_config_set()
+ *
+ *   For TxF "txf_id", it configures the TxF specified by "cfg_ptr" and
+ *   indicates to the statistics collector to collect statistics for this
+ *   Tx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  txf_id  - tx-function ID.
+ * @param[in]  cfg_ptr - pointer to tx-function configuration.
+ *
+ * @return void
+ */
+void bna_txf_config_set(struct bna_dev_s *dev, unsigned int txf_id,
+     const struct bna_txf_config *cfg_ptr);
+
+
+/**
+ * bna_txf_config_clear()
+ *
+ *   For TxF "txf_id", it clears its configuration and indicates to the
+ *   statistics collector to stop collecting statistics for this
+ *   Tx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  txf_id  - tx-function ID.
+ *
+ * @return void
+ */
+void bna_txf_config_clear(struct bna_dev_s *dev, unsigned int txf_id);
+
+
+
+/**
+ * bna_txf_disable()
+ *
+ *  Disables the Tx Function without clearing the configuration
+ *  Also disables collection of statistics.
+ *
+ * @param[in] bna_dev   - Pointer to BNA BNA device handle
+ * @param[in] txf_id	- Id of the Tx Function to be disabled
+ *
+ * @return void
+ */
+void bna_txf_disable(struct bna_dev_s *bna_dev, unsigned int txf_id);
+
+/**
+ * bna_txf_enable()
+ *
+ *  Enables the Tx Function
+ *
+ * @param[in] bna_dev   - Pointer to BNA BNA device handle
+ * @param[in] txf_id	- Id of the Tx Function to be disabled
+ *
+ * @return void
+ */
+void bna_txf_enable(struct bna_dev_s *bna_dev, unsigned int txf_id);
+
+/*
+ *
+ *
+ *   R X   I N D I R E C T I O N   T A B L E   D E F I N E S
+ *
+ *
+ */
+/**
+ *  Receive-Function RIT (Receive Indirection Table)
+ *
+ *  RIT is required by RSS.  However, in Catapult-LL, RIT must still be
+ *  present for non-RSS.  For non-RSS it just defines the unicast RxQs
+ *  associated to a function.
+ *
+ *  Each entry in the RIT holds two RxQs which are either Small and Large
+ *  Buffer RxQs or Header and Data Buffer RxQs.  "large_rxq_id" is used when
+ *  neither Small/Large or Header-Data Split is configured.
+ */
+struct bna_rit_entry {
+	u8  large_rxq_id;   /* used for either large or data buffers */
+	u8  small_rxq_id;   /* used for either small or header buffers */
+};
+
+
+/**
+ * bna_rit_config_set()
+ *
+ *   Loads RIT entries "rit" into RIT starting from RIT index "rit_offset".
+ *   Care must be taken not to overlap regions within the RIT.
+ *
+ * @param[in]  dev  	  - pointer to BNA device structure
+ * @param[in]  rit_offset - receive-indirection-table index.
+ * @param[in]  rit[]	  - receive-indirection-table segment.
+ * @param[in]  rit_size   - size of receive-indirection-table segment.
+ *
+ * @return void
+ */
+void bna_rit_config_set(struct bna_dev_s *dev, unsigned int rit_offset,
+		const struct bna_rit_entry rit[], unsigned int rit_size);
+
+
+/*
+ *******************************************************************************
+ *
+ *   R X   F U N C T I O N   D E F I N E S
+ *
+ *******************************************************************************
+ */
+
+/* RxF RSS (Receive Side Scaling) */
+#define	BNA_RSS_V4_TCP  	(1 << 11)
+#define	BNA_RSS_V4_IP   	(1 << 10)
+#define	BNA_RSS_V6_TCP  	(1 <<  9)
+#define	BNA_RSS_V6_IP   	(1 <<  8)
+typedef u16 bna_rxf_rss_type_t;
+
+#define BNA_RSS_HASH_KEY_LEN 10 /* in words */
+
+struct bna_rxf_rss {
+	bna_rxf_rss_type_t type;
+	u8 	hash_mask;
+	u32 	toeplitz_hash_key[BNA_RSS_HASH_KEY_LEN];
+};
+
+
+/* RxF HDS (Header Data Split) */
+#define	BNA_HDS_V4_TCP  	(1 << 11)
+#define	BNA_HDS_V4_UDP  	(1 << 10)
+#define	BNA_HDS_V6_TCP  	(1 <<  9)
+#define	BNA_HDS_V6_UDP  	(1 <<  8)
+#define	BNA_HDS_FORCED  	(1 <<  7)
+typedef u16 bna_rxf_hds_type_t;
+
+
+#define BNA_HDS_FORCE_OFFSET_MIN	24  /* bytes */
+#define BNA_HDS_FORCE_OFFSET_MAX	60  /* bytes */
+
+
+struct bna_rxf_hds {
+	bna_rxf_hds_type_t	type;		/* OR of bna_rxf_hds_type_t */
+	u8 		header_size;	/* max header size for split */
+	u8 		forced_offset;	/* HDS at a force offset */
+};
+
+
+/* RxF Control Flags */
+#define	BNA_RXF_CF_SM_LG_RXQ			(1 << 15)
+#define	BNA_RXF_CF_DEFAULT_VLAN 		(1 << 14)
+#define	BNA_RXF_CF_DEFAULT_FUNCTION_ENABLE	(1 << 13)
+#define	BNA_RXF_CF_VLAN_STRIP   		(1 << 12)
+#define	BNA_RXF_CF_RSS_ENABLE   		(1 <<  8)
+typedef u16 bna_rxf_ctrl_flag_t;
+
+
+/* RxF Configuration Structure */
+struct bna_rxf_config {
+	u8 	rit_offset; 	/* offset into RIT */
+	u8 	mcast_rxq_id;	/* multicast RxQ ID */
+	u16	default_vlan;	/* default VLAN for untagged frames */
+	bna_rxf_ctrl_flag_t flags;  	/* OR of bna_rxf_ctrl_flag_t */
+	struct bna_rxf_hds  hds;	/* valid when BNA_RXF_SM_LG_RXQ == 0 */
+	struct bna_rxf_rss  rss;	/* valid when BNA_RXF_RSS_ENABLE == 1 */
+};
+
+
+/**
+ * bna_rxf_config_set()
+ *
+ *   For RxF "rxf_id", it configures RxF based on "cfg_ptr", and indicates
+ *   to the statistics collector to collect statistics for this Rx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  cfg_ptr - pointer to rx-function configuration.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_config_set(struct bna_dev_s *dev, unsigned int rxf_id,
+				const struct bna_rxf_config *cfg_ptr);
+
+
+/**
+ * bna_rxf_config_clear()
+ *
+ *   For RxF "rxf_id", it clear its configuration and indicates to the
+ *   statistics collector to stop collecting statistics for this
+ *   Rx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ *
+ * @return  void
+ */
+void bna_rxf_config_clear(struct bna_dev_s *dev, unsigned int rxf_id);
+
+/**
+ * bna_multi_rxf_active()
+ *
+ *  Disables/Enables the Rx Function without clearing the configuration
+ *  Also disables/enables collection of statistics.
+ *
+ * @param[in] bna_dev   - Pointer to BNA BNA device handle
+ * @param[in] rxf_id	- Id of the Rx Function to be disabled
+ * @param[in] enable	- 1 = enable, 0 = disable
+ *
+ * @return BNA_OK if mbox command succeeded else BNA_FAIL
+ */
+enum bna_status_e bna_multi_rxf_active(struct bna_dev_s *dev, u64 rxf_id_mask,
+    u8 enable);
+/**
+ * bna_rxf_disable()
+ *
+ *  Disables the Rx Function without clearing the configuration
+ *  Also disables collection of statistics.
+ *
+ * @param[in] bna_dev   - Pointer to BNA BNA device handle
+ * @param[in] rxf_id	- Id of the Rx Function to be disabled
+ *
+ * @return BNA_OK if mbox command succeeded else BNA_FAIL
+ */
+enum bna_status_e bna_rxf_disable(struct bna_dev_s *bna_dev,
+	unsigned int rxf_id);
+
+/**
+ * bna_multi_rxf_disable()
+ *
+ *  Disables multiple Rx Functions as per the mask
+ *  Also disables collection of statistics.
+ *
+ * @param[in] dev 		- Pointer to BNA device handle
+ * @param[in] rxf_id_mask    	- Mask of the functions to be
+				  disabled
+ *
+ * @return    BNA_OK if mbox command succeeded, else BNA_FAIL
+ */
+#define bna_multi_rxf_disable(dev, rxf_id_mask)	\
+		bna_multi_rxf_active((dev), (rxf_id_mask), 0)
+
+/**
+ * bna_rxf_enable()
+ *
+ *  Enables the Rx Function
+ *
+ * @param[in] bna_dev   - Pointer to BNA BNA device handle
+ * @param[in] rxf_id	- Id of the Rx Function to be disabled
+ *
+ * @return BNA_OK if mbox command succeeded else BNA_FAIL
+ */
+enum bna_status_e bna_rxf_enable(struct bna_dev_s *bna_dev,
+	unsigned int rxf_id);
+
+/**
+ * bna_multi_rxf_enable()
+ *
+ *  Enables multiple Rx Functions as per the mask
+ *  Also enables collection of statistics.
+ *
+ * @param[in] dev               - Pointer to BNA device handle
+ * @param[in] rxf_id_mask       - Mask of the functions to be
+ *                                enabled
+ *
+ * @return    BNA_OK if mbox command succeeded, else BNA_FAIL
+ */
+#define bna_multi_rxf_enable(dev, rxf_id_mask)	\
+		bna_multi_rxf_active((dev), (rxf_id_mask), 1)
+
+
+/* TODO : Delete when windows migration is complete */
+void bna_rxf_disable_old(struct bna_dev_s *dev, unsigned int rxf_id);
+
+
+/**
+ * bna_rxf_ucast_mac_set()
+ *
+ *   For RxF "rxf_id", it overwrites the burnt-in unicast MAC with
+ *   the one specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_ptr - pointer to unicast MAC address.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_ucast_mac_set(struct bna_dev_s *dev,
+		unsigned int rxf_id, const u8 *mac_ptr);
+
+
+/**
+ * bna_rxf_ucast_mac_add()
+ *
+ *   For RxF "rxf_id", it adds the unicast MAC specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_ptr - pointer to unicast MAC address.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_ucast_mac_add(struct bna_dev_s *dev,
+	unsigned int rxf_id, const u8 *mac_ptr);
+
+
+/**
+ * bna_rxf_ucast_mac_del()
+ *
+ *   For RxF "rxf_id", it deletes the unicast MAC specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_ptr - pointer to unicast MAC address.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_ucast_mac_del(struct bna_dev_s *dev,
+		unsigned int rxf_id, const u8 *mac_ptr);
+
+
+/**
+ * bna_rxf_mcast_mac_add()
+ *
+ *   For RxF "rxf_id", it adds the multicast MAC specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_ptr - pointer to multicast MAC address.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_mcast_mac_add(struct bna_dev_s *dev,
+	unsigned int rxf_id, const u8 *mac_ptr);
+
+
+/**
+ * bna_rxf_mcast_mac_del()
+ *
+ *   For RxF "rxf_id", it deletes the multicast MAC specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_ptr - pointer to multicast MAC address.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_mcast_mac_del(struct bna_dev_s *dev,
+	unsigned int rxf_id, const u8 *mac_ptr);
+
+/**
+ *  bna_rxf_broadcast()
+ *
+ *  For RxF "rxf_id", it enables/disables the broadcast address.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable broadcast address
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_broadcast(struct bna_dev_s *bna_dev,
+		unsigned int rxf_id, enum bna_enable_e enable);
+
+/**
+ * bna_rxf_mcast_mac_set_list()
+ *
+ *  For RxF "rxf_id", it sets the multicast MAC addresses
+ *  specified by "mac_addr_ptr". The function first deletes the
+ *  MAC addresses in the existing list that is not found in the
+ *  new list. It then adds the new addresses that ar ein the new
+ *  list but not in the old list. It then replaces the old list
+ *  with the new list in the bna_dev structure.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to the list of mac
+ *  	 adddresses to set
+ * @param[in]  mac_addr_num - number of mac addresses in the
+ *  	 list
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_mcast_mac_set_list(struct bna_dev_s *bna_dev, unsigned int rxf_id,
+		const u8 *mac_addr_ptr , unsigned int mac_addr_num);
+
+/**
+ * bna_mcast_mac_reset_list()
+ *
+ *  Resets the multicast MAC address list kept by driver.
+ *  Called when the hw gets reset.
+ *
+ * @param[in]  dev  - pointer to BNA device structure
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_mcast_mac_reset_list(struct bna_dev_s *bna_dev);
+
+/**
+ * bna_rxf_mcast_filter()
+ *
+ *   For RxF "rxf_id", it enables/disables the Multicast Filter.
+ *   Disabling the Multicast Filter allows reception of any multicast frame.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable Multicast Filtering.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_mcast_filter(struct bna_dev_s *dev,
+	unsigned int rxf_id, enum bna_enable_e enable);
+
+/**
+ * bna_rxf_mcast_del_all()
+ *
+ *   For RxF "rxf_id", it clears the MCAST cam and MVT.
+ *   This functionality is required by some of the drivers.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_mcast_del_all(struct bna_dev_s *dev,
+	unsigned int rxf_id);
+
+
+/**
+ * bna_rxf_vlan_add()
+ *
+ *   For RxF "rxf_id", it adds this function as a member of the
+ *   specified "vlan_id".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  vlan_id - VLAN ID.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void   bna_rxf_vlan_add(struct bna_dev_s *dev, unsigned int rxf_id,
+			       unsigned int vlan_id);
+
+
+/**
+ * bna_rxf_vlan_del()
+ *
+ *   For RxF "rxf_id", it removes this function as a member of the
+ *   specified "vlan_id".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  vlan_id - VLAN ID.
+ *
+ * @return void
+ */
+void bna_rxf_vlan_del(struct bna_dev_s *dev, unsigned int rxf_id,
+			       unsigned int vlan_id);
+
+
+/**
+ * bna_rxf_vlan_filter()
+ *
+ *   For RxF "rxf_id", it enables/disables the VLAN filter.
+ *   Disabling the VLAN Filter allows reception of any VLAN-tagged frame.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable VLAN Filtering.
+ *
+ * @return void
+ */
+void bna_rxf_vlan_filter(struct bna_dev_s *dev, unsigned int rxf_id,
+				  enum bna_enable_e enable);
+
+/**
+ * bna_rxf_vlan_del_all()
+ *
+ *   For RxF "rxf_id", it clears all the VLANs.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+
+ *
+ * @return void
+ */
+void bna_rxf_vlan_del_all(struct bna_dev_s *bna_dev, unsigned int rxf_id);
+
+/**
+ * bna_rxf_promiscuous_mode()
+ *
+ *   For RxF "rxf_id", it enables/disables promiscuous-mode.
+ *   Only one RxF is allowed to be in promiscuous-mode, and will only disable
+ *   the promiscuous-mode if the RxF ID is the one in promiscuous-mode.
+ *   Must be called after the RxF has been configured.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable promiscuous-mode..
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_promiscuous(struct bna_dev_s *dev,
+	unsigned int rxf_id, enum bna_enable_e enable);
+
+
+/* FIXME : Remove BNA_VM_OS */
+#ifdef BNA_VM_OS
+/**
+ * bna_rxf_default_mode()
+ *
+ *   For RxF "rxf_id", it enables/disables default mode.
+ *   Only one RxF is allowed to be in default-mode, and will only disable
+ *   the default-mode if the RxF ID is the one in default-mode.
+ *   Must be called after the RxF has been configured.
+ *   Must remove all unicast MAC associated to this RxF.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable default mode..
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_default_mode(struct bna_dev_s *dev,
+	unsigned int rxf_id, enum bna_enable_e enable);
+#endif  /* BNA_VM_OS */
+
+/**
+ * bna_rxf_frame_stats_get()
+ *
+ *   For RxF "rxf_id", it loads frame statistics into "stats_ptr".
+ *
+ * @param[in]  dev  	 - pointer to BNA device structure
+ * @param[in]  rxf_id    - rx-function ID.
+ * @param[out] stats_ptr - pointer to rx-function statistics structure
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void bna_rxf_frame_stats_get(struct bna_dev_s *dev, unsigned int rxf_id,
+				      struct bna_stats_rxf **stats_ptr);
+
+/**
+ * bna_txf_frame_stats_get()
+ *
+ *   For TxF "txf_id", it loads frame statistics into "stats_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  txf_id    - tx-function ID.
+ * @param[out] stats_ptr - pointer to tx-function statistics structure
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void bna_txf_frame_stats_get(struct bna_dev_s *dev, unsigned int txf_id,
+				      struct bna_stats_txf **stats_ptr);
+
+/**
+ *  bna_mac_rx_stats_get()
+ *
+ *  Loads MAC Rx statistics into "stats_ptr".
+ *
+ * @param[in]  dev	 - pointer to BNA device structure
+
+ * @param[out]  stats_ptr - pointer to stats structure
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void bna_mac_rx_stats_get(struct bna_dev_s *bna_dev,
+				   struct cna_stats_mac_rx **stats_ptr);
+
+/**
+ *  bna_mac_tx_stats_get()
+ *
+ *  Loads MAC Tx statistics into "stats_ptr".
+ *
+ * @param[in]  dev	 - pointer to BNA device structure
+
+ * @param[out]  stats_ptr - pointer to stats structure
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void bna_mac_tx_stats_get(struct bna_dev_s *bna_dev,
+				   struct cna_stats_mac_tx **stats_ptr);
+
+/**
+ *  bna_all_stats_get()
+ *
+ *  Loads all statistics into "stats_ptr".
+ *
+ * @param[in]  dev	 - pointer to BNA device structure
+
+ * @param[out]  stats_ptr - pointer to stats structure
+ *
+ * @return void
+ */
+void bna_all_stats_get(struct bna_dev_s *bna_dev,
+				  struct bna_stats **stats_ptr);
+/**
+ * bna_stats_get()
+ *
+ *   Get the statistics from the device. This function needs to
+ *   be scheduled every second to get periodic update of the
+ *   statistics data from hardware.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure.
+ *
+ * @return void
+ */
+enum bna_status_e bna_stats_get(struct bna_dev_s *dev);
+
+/**
+ * bna_stats_clear()
+ *
+ *   Clear the statistics in the device.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_stats_clear(struct bna_dev_s *bna_dev);
+
+/**
+ * bna_rxf_stats_clear()
+ *
+ *   Clear the statistics for specified txf.
+ *
+ * @param[in]   dev        - pointer to BNA device structure.
+ * @param[in]  rxf_id      - rx-function ID.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_stats_clear(struct bna_dev_s *dev,
+	unsigned int rxf_id);
+
+/**
+ * bna_lldp_stats_clear()
+ *
+ *   Clear the lldp-dcbcx statistics in the device.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_lldp_stats_clear(struct bna_dev_s *bna_dev);
+
+/**
+ * bna_get_cfg_req()
+ *
+ *   Gets the LLDP-DCBCXP Config from the f/w.
+ *
+ * @param[in]   dev 	      - pointer to BNA device structure.
+ * @param[in]   dma_addr_bna  - dma address to return the config.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_get_cfg_req(struct bna_dev_s *bna_dev,
+	struct bna_dma_addr *dma_addr_bna);
+
+/**
+
+* bna_get_cee_stats_req()
+*
+*   Gets the LLDP-DCBCXP stats from the f/w.
+*
+* @param[in]   dev           - pointer to BNA device structure.
+* @param[in]   dma_addr_bna  - dma address to return the config.
+*
+* @return BNA_OK   - successful
+* @return BNA_FAIL - failed on sanity checks.
+*/
+enum bna_status_e bna_get_cee_stats_req(struct bna_dev_s *bna_dev,
+	struct bna_dma_addr *dma_addr_bna);
+
+/**
+ * bna_stats_process()
+ *
+ *   Process the statistics data DMAed from the device. This
+ *   function needs to be scheduled upon getting an asynchronous
+ *   notification from the firmware.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure.
+ *
+ * @return void
+ */
+void bna_stats_process(struct bna_dev_s *bna_dev);
+
+/**
+ * bna_init()
+ *
+ *   Called by the driver during initialization. The driver is
+ *   expected to allocate struct bna_dev_s structure for the BNA layer.
+ *   Should be called with the lock held.
+ *
+ * @param[in]  bna_handle  - pointer to BNA device structure
+ * 			     allocated by the calling driver
+ * @param[in]  bar0 	   - BAR0 value
+ * @param[in]  stats	   - pointer to stats host buffer
+ * @param[in]  stats_dma   - pointer to DMA value for stats
+ * @param[in]  trcmod      - pointer to struct bfa_trc_mod_s
+ *			     (for Interrupt Moderation)
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void bna_init(struct bna_dev_s *bna_handle, void * bar0,
+    void *stats, struct bna_dma_addr stats_dma, struct bfa_trc_mod_s *trcmod);
+
+/**
+ * bna_uninit()
+ *
+ *   Called by the driver during removal/unload.
+ *
+ * @param[in]  bna_handle  - pointer to BNA device structure
+ * 			     allocated by the calling driver
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_uninit(void *bna_handle);
+
+/**
+ * bna_cleanup()
+ *
+ *   Called by the driver from the hb_fail callback to
+ *   to let bna do the cleanup.
+ *   This should be called before driver frees memory.
+ *   Should be called with the lock held.
+ *
+ * @param[in]  bna_handle  - pointer to BNA device structure
+ * 			     allocated by the calling driver
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_cleanup(void *bna_handle);
+
+#endif  /* __BNA_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bna_hwreg.h linux-2.6.32-rc4-mod/drivers/net/bna/bna_hwreg.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bna_hwreg.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bna_hwreg.h	2009-10-16 10:30:53.848453000 -0700
@@ -0,0 +1,1004 @@
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
+ * See <license_file> for copyright and licensing details.
+ */
+
+/*
+ *  bna_hwreg.h Catapult host block register definitions
+ *
+ */
+
+#ifndef __BNA_HWREG_H__
+#define __BNA_HWREG_H__
+
+#include <bfi/bfi_ctreg.h>
+
+/**************************************************************
+ *               REGISTER ACCESS
+ **************************************************************/
+/**
+ * CPE Block Register Address Offset from BAR0
+ */
+	/* TODO */
+/**
+ * RME Block Register Address Offset from BAR0
+ */
+	/* TODO */
+/**
+ * SGM Block Register Address Offset from BAR0
+ */
+	/* TODO */
+
+/**
+ * DMA Block Register Host Window Start Address
+ */
+#define DMA_BLK_REG_ADDR		0x00013000
+/**
+ * DMA Block Internal Registers
+ */
+#define DMA_CTRL_REG0			(DMA_BLK_REG_ADDR + 0x000)
+#define DMA_CTRL_REG1			(DMA_BLK_REG_ADDR + 0x004)
+#define DMA_ERR_INT_STATUS		(DMA_BLK_REG_ADDR + 0x008)
+#define DMA_ERR_INT_ENABLE		(DMA_BLK_REG_ADDR + 0x00c)
+#define DMA_ERR_INT_STATUS_SET		(DMA_BLK_REG_ADDR + 0x010)
+
+/**
+ * APP Block Register Address Offset from BAR0
+ */
+#define APP_BLK_REG_ADDR		0x00014000
+
+/**
+ * Host Function Interrupt Mask Registers
+ */
+#define HOSTFN0_INT_MASK		(APP_BLK_REG_ADDR + 0x004)
+#define HOSTFN1_INT_MASK		(APP_BLK_REG_ADDR + 0x104)
+#define HOSTFN2_INT_MASK		(APP_BLK_REG_ADDR + 0x304)
+#define HOSTFN3_INT_MASK		(APP_BLK_REG_ADDR + 0x404)
+
+/**
+ * Host Function PCIe Error Registers
+ * Duplicates "Correctable" & "Uncorrectable"
+ * registers in PCIe Config space.
+ */
+#define FN0_PCIE_ERR_REG		(APP_BLK_REG_ADDR + 0x014)
+#define FN1_PCIE_ERR_REG		(APP_BLK_REG_ADDR + 0x114)
+#define FN2_PCIE_ERR_REG		(APP_BLK_REG_ADDR + 0x314)
+#define FN3_PCIE_ERR_REG		(APP_BLK_REG_ADDR + 0x414)
+
+/**
+ * Host Function Error Type Status Registers
+ */
+#define FN0_ERR_TYPE_STATUS_REG		(APP_BLK_REG_ADDR + 0x018)
+#define FN1_ERR_TYPE_STATUS_REG		(APP_BLK_REG_ADDR + 0x118)
+#define FN2_ERR_TYPE_STATUS_REG		(APP_BLK_REG_ADDR + 0x318)
+#define FN3_ERR_TYPE_STATUS_REG		(APP_BLK_REG_ADDR + 0x418)
+/**
+ * Host Function Error Type Mask Registers
+ */
+#define FN0_ERR_TYPE_MSK_STATUS_REG	(APP_BLK_REG_ADDR + 0x01c)
+#define FN1_ERR_TYPE_MSK_STATUS_REG	(APP_BLK_REG_ADDR + 0x11c)
+#define FN2_ERR_TYPE_MSK_STATUS_REG	(APP_BLK_REG_ADDR + 0x31c)
+#define FN3_ERR_TYPE_MSK_STATUS_REG	(APP_BLK_REG_ADDR + 0x41c)
+
+/**
+ * Catapult Host Semaphore Status Registers (App block)
+ */
+#define HOST_SEM_STS0_REG		(APP_BLK_REG_ADDR + 0x630)
+#define HOST_SEM_STS1_REG		(APP_BLK_REG_ADDR + 0x634)
+#define HOST_SEM_STS2_REG		(APP_BLK_REG_ADDR + 0x638)
+#define HOST_SEM_STS3_REG		(APP_BLK_REG_ADDR + 0x63c)
+#define HOST_SEM_STS4_REG		(APP_BLK_REG_ADDR + 0x640)
+#define HOST_SEM_STS5_REG		(APP_BLK_REG_ADDR + 0x644)
+#define HOST_SEM_STS6_REG		(APP_BLK_REG_ADDR + 0x648)
+#define HOST_SEM_STS7_REG		(APP_BLK_REG_ADDR + 0x64c)
+
+/**
+ * PCIe Misc Register
+ * Check catapult_spec.pdf for details
+ */
+#define PCIE_MISC_REG			(APP_BLK_REG_ADDR + 0x200)
+/**
+ * Temp Sensor Control Registers
+ */
+#define TEMPSENSE_CNTL_REG		(APP_BLK_REG_ADDR + 0x250)
+#define TEMPSENSE_STAT_REG		(APP_BLK_REG_ADDR + 0x254)
+
+/**
+ * APP Block local error registers
+ */
+#define APP_LOCAL_ERR_STAT		(APP_BLK_REG_ADDR + 0x258)
+#define APP_LOCAL_ERR_MSK		(APP_BLK_REG_ADDR + 0x25c)
+
+/**
+ * PCIe Link Error registers
+ */
+#define PCIE_LNK_ERR_STAT		(APP_BLK_REG_ADDR + 0x260)
+#define PCIE_LNK_ERR_MSK		(APP_BLK_REG_ADDR + 0x264)
+
+/**
+ * FCoE/FIP Ethertype Register
+ * 31:16 -- Chip wide value for FIP type
+ * 15:0  -- Chip wide value for FCoE type
+ */
+#define FCOE_FIP_ETH_TYPE		(APP_BLK_REG_ADDR + 0x280)
+
+/**
+ * Reserved Ethertype Register
+ * 31:16 -- Reserved
+ * 15:0  -- Other ethertype
+ */
+#define RESV_ETH_TYPE			(APP_BLK_REG_ADDR + 0x284)
+
+/**
+ * Host Command Status Registers
+ * Each set consists of 3 registers :
+ * clear, set, cmd
+ * 16 such register sets in all
+ * See catapult_spec.pdf for detailed functionality
+ * Put each type in a single macro accessed by _num ?
+ */
+#define HOST_CMDSTS0_CLR_REG		(APP_BLK_REG_ADDR + 0x500)
+#define HOST_CMDSTS0_SET_REG		(APP_BLK_REG_ADDR + 0x504)
+#define HOST_CMDSTS0_REG		(APP_BLK_REG_ADDR + 0x508)
+#define HOST_CMDSTS1_CLR_REG		(APP_BLK_REG_ADDR + 0x510)
+#define HOST_CMDSTS1_SET_REG		(APP_BLK_REG_ADDR + 0x514)
+#define HOST_CMDSTS1_REG		(APP_BLK_REG_ADDR + 0x518)
+#define HOST_CMDSTS2_CLR_REG		(APP_BLK_REG_ADDR + 0x520)
+#define HOST_CMDSTS2_SET_REG		(APP_BLK_REG_ADDR + 0x524)
+#define HOST_CMDSTS2_REG		(APP_BLK_REG_ADDR + 0x528)
+#define HOST_CMDSTS3_CLR_REG		(APP_BLK_REG_ADDR + 0x530)
+#define HOST_CMDSTS3_SET_REG		(APP_BLK_REG_ADDR + 0x534)
+#define HOST_CMDSTS3_REG		(APP_BLK_REG_ADDR + 0x538)
+#define HOST_CMDSTS4_CLR_REG		(APP_BLK_REG_ADDR + 0x540)
+#define HOST_CMDSTS4_SET_REG		(APP_BLK_REG_ADDR + 0x544)
+#define HOST_CMDSTS4_REG		(APP_BLK_REG_ADDR + 0x548)
+#define HOST_CMDSTS5_CLR_REG		(APP_BLK_REG_ADDR + 0x550)
+#define HOST_CMDSTS5_SET_REG		(APP_BLK_REG_ADDR + 0x554)
+#define HOST_CMDSTS5_REG		(APP_BLK_REG_ADDR + 0x558)
+#define HOST_CMDSTS6_CLR_REG		(APP_BLK_REG_ADDR + 0x560)
+#define HOST_CMDSTS6_SET_REG		(APP_BLK_REG_ADDR + 0x564)
+#define HOST_CMDSTS6_REG		(APP_BLK_REG_ADDR + 0x568)
+#define HOST_CMDSTS7_CLR_REG		(APP_BLK_REG_ADDR + 0x570)
+#define HOST_CMDSTS7_SET_REG		(APP_BLK_REG_ADDR + 0x574)
+#define HOST_CMDSTS7_REG		(APP_BLK_REG_ADDR + 0x578)
+#define HOST_CMDSTS8_CLR_REG		(APP_BLK_REG_ADDR + 0x580)
+#define HOST_CMDSTS8_SET_REG		(APP_BLK_REG_ADDR + 0x584)
+#define HOST_CMDSTS8_REG		(APP_BLK_REG_ADDR + 0x588)
+#define HOST_CMDSTS9_CLR_REG		(APP_BLK_REG_ADDR + 0x590)
+#define HOST_CMDSTS9_SET_REG		(APP_BLK_REG_ADDR + 0x594)
+#define HOST_CMDSTS9_REG		(APP_BLK_REG_ADDR + 0x598)
+#define HOST_CMDSTS10_CLR_REG		(APP_BLK_REG_ADDR + 0x5A0)
+#define HOST_CMDSTS10_SET_REG		(APP_BLK_REG_ADDR + 0x5A4)
+#define HOST_CMDSTS10_REG		(APP_BLK_REG_ADDR + 0x5A8)
+#define HOST_CMDSTS11_CLR_REG		(APP_BLK_REG_ADDR + 0x5B0)
+#define HOST_CMDSTS11_SET_REG		(APP_BLK_REG_ADDR + 0x5B4)
+#define HOST_CMDSTS11_REG		(APP_BLK_REG_ADDR + 0x5B8)
+#define HOST_CMDSTS12_CLR_REG		(APP_BLK_REG_ADDR + 0x5C0)
+#define HOST_CMDSTS12_SET_REG		(APP_BLK_REG_ADDR + 0x5C4)
+#define HOST_CMDSTS12_REG		(APP_BLK_REG_ADDR + 0x5C8)
+#define HOST_CMDSTS13_CLR_REG		(APP_BLK_REG_ADDR + 0x5D0)
+#define HOST_CMDSTS13_SET_REG		(APP_BLK_REG_ADDR + 0x5D4)
+#define HOST_CMDSTS13_REG		(APP_BLK_REG_ADDR + 0x5D8)
+#define HOST_CMDSTS14_CLR_REG		(APP_BLK_REG_ADDR + 0x5E0)
+#define HOST_CMDSTS14_SET_REG		(APP_BLK_REG_ADDR + 0x5E4)
+#define HOST_CMDSTS14_REG		(APP_BLK_REG_ADDR + 0x5E8)
+#define HOST_CMDSTS15_CLR_REG		(APP_BLK_REG_ADDR + 0x5F0)
+#define HOST_CMDSTS15_SET_REG		(APP_BLK_REG_ADDR + 0x5F4)
+#define HOST_CMDSTS15_REG		(APP_BLK_REG_ADDR + 0x5F8)
+
+/**
+ * IOQ Block Register Address Offset from BAR0
+ */
+	/* TODO ? */
+/**
+ * IOH Block Register Address Offset from BAR0
+ */
+	/* Required only in FC mode */
+/**
+ * DIP Block Register Address Offset from BAR0
+ */
+	/* Required only in FC mode */
+/**
+ * SIP Block Register Address Offset from BAR0
+ */
+	/* Required only in FC mode */
+
+/**
+ * LPU0 Block Register Address Offset from BAR0
+ * Range 0x18000 - 0x18033
+ */
+#define LPU0_BLK_REG_ADDR		0x00018000
+
+/**
+ * LPU0 Registers
+ * Should they be directly used from host,
+ * except for diagnostics ?
+ * CTL_REG : Control register
+ * CMD_REG : Triggers exec. of cmd. in
+ *           Mailbox memory
+ */
+#define LPU0_MBOX_CTL_REG		(LPU0_BLK_REG_ADDR + 0x000)
+#define LPU0_MBOX_CMD_REG		(LPU0_BLK_REG_ADDR + 0x004)
+#define LPU0_MBOX_LINK_0REG		(LPU0_BLK_REG_ADDR + 0x008)
+#define LPU1_MBOX_LINK_0REG		(LPU0_BLK_REG_ADDR + 0x00c)
+#define LPU0_MBOX_STATUS_0REG		(LPU0_BLK_REG_ADDR + 0x010)
+#define LPU1_MBOX_STATUS_0REG		(LPU0_BLK_REG_ADDR + 0x014)
+#define LPU0_ERR_STATUS_REG		(LPU0_BLK_REG_ADDR + 0x018)
+#define LPU0_ERR_SET_REG		(LPU0_BLK_REG_ADDR + 0x020)
+
+/**
+ * LPU1 Block Register Address Offset from BAR0
+ * Range 0x18400 - 0x18433
+ */
+#define LPU1_BLK_REG_ADDR		0x00018400
+
+/**
+ * LPU1 Registers
+ * Same as LPU0 registers above
+ */
+#define LPU1_MBOX_CTL_REG		(LPU1_BLK_REG_ADDR + 0x000)
+#define LPU1_MBOX_CMD_REG		(LPU1_BLK_REG_ADDR + 0x004)
+#define LPU0_MBOX_LINK_1REG		(LPU1_BLK_REG_ADDR + 0x008)
+#define LPU1_MBOX_LINK_1REG		(LPU1_BLK_REG_ADDR + 0x00c)
+#define LPU0_MBOX_STATUS_1REG		(LPU1_BLK_REG_ADDR + 0x010)
+#define LPU1_MBOX_STATUS_1REG		(LPU1_BLK_REG_ADDR + 0x014)
+#define LPU1_ERR_STATUS_REG		(LPU1_BLK_REG_ADDR + 0x018)
+#define LPU1_ERR_SET_REG		(LPU1_BLK_REG_ADDR + 0x020)
+
+/**
+ * PSS Block Register Address Offset from BAR0
+ * Range 0x18800 - 0x188DB
+ */
+#define PSS_BLK_REG_ADDR		0x00018800
+
+/**
+ * PSS Registers
+ * For details, see catapult_spec.pdf
+ * ERR_STATUS_REG : Indicates error in PSS module
+ * RAM_ERR_STATUS_REG : Indicates RAM module that detected error
+ */
+#define PSS_ERR_STATUS_REG		(PSS_BLK_REG_ADDR + 0x010)
+#define ERR_STATUS_SET			(PSS_BLK_REG_ADDR + 0x018)
+#define PSS_RAM_ERR_STATUS_REG		(PSS_BLK_REG_ADDR + 0x01C)
+
+/**
+ * PSS Semaphore Lock Registers, total 16
+ * First read when unlocked returns 0,
+ * and is set to 1, atomically.
+ * Subsequent reads returns 1.
+ * To clear set the value to 0.
+ * Range : 0x20 to 0x5c
+ */
+#define PSS_SEM_LOCK_REG(_num) 		\
+	(PSS_BLK_REG_ADDR + 0x020 + ((_num) << 2))
+
+/**
+ * PSS Semaphore Status Registers,
+ * corresponding to the lock registers above
+ */
+#define PSS_SEM_STATUS_REG(_num) 		\
+	(PSS_BLK_REG_ADDR + 0x060 + ((_num) << 2))
+
+/**
+ * Catapult CPQ Registers
+ * Defines for Mailbox Registers
+ * Used to send mailbox commands to firmware from
+ * host. The data part is written to the MBox
+ * memory, registers are used to indicate that
+ * a commnad is resident in memory.
+ *
+ * Note : LPU0<->LPU1 mailboxes are not listed here
+ */
+#define CPQ_BLK_REG_ADDR		0x00019000
+
+#define HOSTFN0_LPU0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x130)
+#define HOSTFN0_LPU1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x134)
+#define LPU0_HOSTFN0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x138)
+#define LPU1_HOSTFN0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x13C)
+
+#define HOSTFN1_LPU0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x140)
+#define HOSTFN1_LPU1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x144)
+#define LPU0_HOSTFN1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x148)
+#define LPU1_HOSTFN1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x14C)
+
+#define HOSTFN2_LPU0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x170)
+#define HOSTFN2_LPU1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x174)
+#define LPU0_HOSTFN2_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x178)
+#define LPU1_HOSTFN2_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x17C)
+
+#define HOSTFN3_LPU0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x180)
+#define HOSTFN3_LPU1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x184)
+#define LPU0_HOSTFN3_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x188)
+#define LPU1_HOSTFN3_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x18C)
+
+/**
+ * Host Function Force Parity Error Registers
+ */
+#define HOSTFN0_LPU_FORCE_PERR		(CPQ_BLK_REG_ADDR + 0x120)
+#define HOSTFN1_LPU_FORCE_PERR		(CPQ_BLK_REG_ADDR + 0x124)
+#define HOSTFN2_LPU_FORCE_PERR		(CPQ_BLK_REG_ADDR + 0x128)
+#define HOSTFN3_LPU_FORCE_PERR		(CPQ_BLK_REG_ADDR + 0x12C)
+
+/**
+ * LL Port[0|1] Halt Mask Registers
+ */
+#define LL_HALT_MSK_P0			(CPQ_BLK_REG_ADDR + 0x1A0)
+#define LL_HALT_MSK_P1			(CPQ_BLK_REG_ADDR + 0x1B0)
+
+/**
+ * LL Port[0|1] Error Mask Registers
+ */
+#define LL_ERR_MSK_P0			(CPQ_BLK_REG_ADDR + 0x1D0)
+#define LL_ERR_MSK_P1			(CPQ_BLK_REG_ADDR + 0x1D4)
+
+/**
+ * TXQ Block Register Address Offset from BAR0
+ */
+	/* TODO :
+	 * For per-port registers, offsets look
+	 * skewed, need clarification
+	 */
+/**
+ * RDS (Rx Frame Data Store) Block Register Address Offset from BAR0
+ */
+	/* Host does not need to access these */
+/**
+ * TDS (Tx Frame Data Store) Block Register Address Offset from BAR0
+ */
+	/* Host does not need to access these */
+/**
+ * BAL Block Register Address Offset from BAR0
+ */
+	/* TODO : Some of these may be needed */
+
+/**
+ * EMC FLI (Flash Controller) Block Register Address Offset from BAR0
+ */
+#define FLI_BLK_REG_ADDR		0x0001D000
+
+/**
+ * EMC FLI Registers
+ */
+#define FLI_CMD_REG			(FLI_BLK_REG_ADDR + 0x000)
+#define FLI_ADDR_REG			(FLI_BLK_REG_ADDR + 0x004)
+#define FLI_CTL_REG			(FLI_BLK_REG_ADDR + 0x008)
+#define FLI_WRDATA_REG			(FLI_BLK_REG_ADDR + 0x00C)
+#define FLI_RDDATA_REG			(FLI_BLK_REG_ADDR + 0x010)
+#define FLI_DEV_STATUS_REG		(FLI_BLK_REG_ADDR + 0x014)
+#define FLI_SIG_WD_REG			(FLI_BLK_REG_ADDR + 0x018)
+/*
+ * H/W document lists the following vendor ID register as
+ * FLI_ERR_VENDOR_REG -- typo ?
+ * RO register
+ * 31:16 -- Vendor Id
+ * 15:0  -- Device Id
+ */
+#define FLI_DEV_VENDOR_REG		(FLI_BLK_REG_ADDR + 0x01C)
+#define FLI_ERR_STATUS_REG		(FLI_BLK_REG_ADDR + 0x020)
+
+/**
+ * FPG (FC Port Group) Block Register Address Offset from BAR0
+ */
+	/* FC driver specific */
+
+/**
+ * RAD (RxAdm) Block Register Address Offset from BAR0
+ * RAD0 Range : 0x20000 - 0x203FF
+ * RAD1 Range : 0x20400 - 0x207FF
+ */
+#define RAD0_BLK_REG_ADDR		0x00020000
+#define RAD1_BLK_REG_ADDR		0x00020400
+
+/**
+ * RAD0 Registers
+ */
+#define RAD0_CTL_REG			(RAD0_BLK_REG_ADDR + 0x000)
+#define RAD0_PE_PARM_REG		(RAD0_BLK_REG_ADDR + 0x004)
+#define RAD0_BCN_REG			(RAD0_BLK_REG_ADDR + 0x008)
+/*
+ * Default function ID register
+ */
+#define RAD0_DEFAULT_REG		(RAD0_BLK_REG_ADDR + 0x00C)
+/*
+ * Default promiscuous ID register
+ */
+#define RAD0_PROMISC_REG		(RAD0_BLK_REG_ADDR + 0x010)
+
+#define RAD0_BCNQ_REG			(RAD0_BLK_REG_ADDR + 0x014)
+/*
+ * This register selects 1 of 8 PM Q's using
+ * VLAN pri, for non-BCN packets without a VLAN tag
+ */
+#define RAD0_DEFAULTQ_REG		(RAD0_BLK_REG_ADDR + 0x018)
+
+#define RAD0_ERR_STS			(RAD0_BLK_REG_ADDR + 0x01C)
+#define RAD0_SET_ERR_STS		(RAD0_BLK_REG_ADDR + 0x020)
+#define RAD0_ERR_INT_EN			(RAD0_BLK_REG_ADDR + 0x024)
+#define RAD0_FIRST_ERR          (RAD0_BLK_REG_ADDR + 0x028)
+#define RAD0_FORCE_ERR          (RAD0_BLK_REG_ADDR + 0x02C)
+
+#define RAD0_IF_RCVD            (RAD0_BLK_REG_ADDR + 0x030)
+#define RAD0_IF_RCVD_OCTETS_HIGH (RAD0_BLK_REG_ADDR + 0x034)
+#define RAD0_IF_RCVD_OCTETS_LOW (RAD0_BLK_REG_ADDR + 0x038)
+#define RAD0_IF_RCVD_VLAN       (RAD0_BLK_REG_ADDR + 0x03C)
+#define RAD0_IF_RCVD_UCAST       (RAD0_BLK_REG_ADDR + 0x040)
+#define RAD0_IF_RCVD_UCAST_OCTETS_HIGH  (RAD0_BLK_REG_ADDR + 0x044)
+#define RAD0_IF_RCVD_UCAST_OCTETS_LOW   (RAD0_BLK_REG_ADDR + 0x048)
+#define RAD0_IF_RCVD_UCAST_VLAN (RAD0_BLK_REG_ADDR + 0x04C)
+#define RAD0_IF_RCVD_MCAST      (RAD0_BLK_REG_ADDR + 0x050)
+#define RAD0_IF_RCVD_MCAST_OCTETS_HIGH  (RAD0_BLK_REG_ADDR + 0x054)
+#define RAD0_IF_RCVD_MCAST_OCTETS_LOW   (RAD0_BLK_REG_ADDR + 0x058)
+#define RAD0_IF_RCVD_MCAST_VLAN (RAD0_BLK_REG_ADDR + 0x05C)
+#define RAD0_IF_RCVD_BCAST      (RAD0_BLK_REG_ADDR + 0x060)
+#define RAD0_IF_RCVD_BCAST_OCTETS_HIGH  (RAD0_BLK_REG_ADDR + 0x064)
+#define RAD0_IF_RCVD_BCAST_OCTETS_LOW   (RAD0_BLK_REG_ADDR + 0x068)
+#define RAD0_IF_RCVD_BCAST_VLAN (RAD0_BLK_REG_ADDR + 0x06C)
+#define RAD0_DROPPED_FRAMES     (RAD0_BLK_REG_ADDR + 0x070)
+
+#define RAD0_MAC_MAN_1H         (RAD0_BLK_REG_ADDR + 0x080)
+#define RAD0_MAC_MAN_1L         (RAD0_BLK_REG_ADDR + 0x084)
+#define RAD0_MAC_MAN_2H         (RAD0_BLK_REG_ADDR + 0x088)
+#define RAD0_MAC_MAN_2L         (RAD0_BLK_REG_ADDR + 0x08C)
+#define RAD0_MAC_MAN_3H         (RAD0_BLK_REG_ADDR + 0x090)
+#define RAD0_MAC_MAN_3L         (RAD0_BLK_REG_ADDR + 0x094)
+#define RAD0_MAC_MAN_4H         (RAD0_BLK_REG_ADDR + 0x098)
+#define RAD0_MAC_MAN_4L         (RAD0_BLK_REG_ADDR + 0x09C)
+
+
+#define RAD0_LAST4_IP           (RAD0_BLK_REG_ADDR + 0x100)
+
+/**
+ * RAD1 Registers
+ */
+#define RAD1_CTL_REG			(RAD1_BLK_REG_ADDR + 0x000)
+#define RAD1_PE_PARM_REG		(RAD1_BLK_REG_ADDR + 0x004)
+#define RAD1_BCN_REG			(RAD1_BLK_REG_ADDR + 0x008)
+/*
+ * Default function ID register
+ */
+#define RAD1_DEFAULT_REG		(RAD1_BLK_REG_ADDR + 0x00C)
+/*
+ * Promiscuous function ID register
+ */
+#define RAD1_PROMISC_REG		(RAD1_BLK_REG_ADDR + 0x010)
+
+#define RAD1_BCNQ_REG			(RAD1_BLK_REG_ADDR + 0x014)
+/*
+ * This register selects 1 of 8 PM Q's using
+ * VLAN pri, for non-BCN packets without a VLAN tag
+ */
+#define RAD1_DEFAULTQ_REG		(RAD1_BLK_REG_ADDR + 0x018)
+
+#define RAD1_ERR_STS			(RAD1_BLK_REG_ADDR + 0x01C)
+#define RAD1_SET_ERR_STS		(RAD1_BLK_REG_ADDR + 0x020)
+#define RAD1_ERR_INT_EN			(RAD1_BLK_REG_ADDR + 0x024)
+/*
+ * RxAdm Statistics Registers:
+ * F/W will access these, not required immediately for host
+ */
+
+/**
+ * RLB (Rx Loop Back) Block Register Address Offset from BAR0
+ */
+	/* TODO : ?? */
+/**
+ * TXA Block Register Address Offset from BAR0
+ * TXA0 Range : 0x21000 - 0x213FF
+ * TXA1 Range : 0x21400 - 0x217FF
+ */
+#define TXA0_BLK_REG_ADDR		0x00021000
+#define TXA1_BLK_REG_ADDR		0x00021400
+
+/**
+ * TXA Registers
+ */
+#define TXA0_CTRL_REG			(TXA0_BLK_REG_ADDR + 0x000)
+#define TXA1_CTRL_REG			(TXA1_BLK_REG_ADDR + 0x000)
+
+/**
+ * TSO Sequence # Registers (RO)
+ * Total 8 (for 8 queues)
+ * Holds the last seq.# for TSO frames
+ * See catapult_spec.pdf for more details
+ */
+#define TXA0_TSO_TCP_SEQ_REG(_num)		\
+	(TXA0_BLK_REG_ADDR + 0x020 + ((_num) << 2))
+
+#define TXA1_TSO_TCP_SEQ_REG(_num)		\
+	(TXA1_BLK_REG_ADDR + 0x020 + ((_num) << 2))
+
+/**
+ * TSO IP ID # Registers (RO)
+ * Total 8 (for 8 queues)
+ * Holds the last IP ID for TSO frames
+ * See catapult_spec.pdf for more details
+ */
+#define TXA0_TSO_IP_INFO_REG(_num)		\
+	(TXA0_BLK_REG_ADDR + 0x040 + ((_num) << 2))
+
+#define TXA1_TSO_IP_INFO_REG(_num)		\
+	(TXA1_BLK_REG_ADDR + 0x040 + ((_num) << 2))
+
+/**
+ * RXA Block Register Address Offset from BAR0
+ * RXA0 Range : 0x21800 - 0x21BFF
+ * RXA1 Range : 0x21C00 - 0x21FFF
+ */
+#define RXA0_BLK_REG_ADDR		0x00021800
+#define RXA1_BLK_REG_ADDR		0x00021C00
+
+/**
+ * RXA Registers
+ */
+#define RXA0_CTL_REG			(RXA0_BLK_REG_ADDR + 0x040)
+#define RXA1_CTL_REG			(RXA1_BLK_REG_ADDR + 0x040)
+
+/**
+ * PPLB Block Register Address Offset from BAR0
+ * PPLB0 Range : 0x22000 - 0x223FF
+ * PPLB1 Range : 0x22400 - 0x227FF
+ */
+#define PLB0_BLK_REG_ADDR		0x00022000
+#define PLB1_BLK_REG_ADDR		0x00022400
+
+/**
+ * PLB Registers
+ */
+/**
+ * Holds RL timer used time stamps in RLT tagged frames
+ */
+#define PLB0_ECM_TIMER_REG		(PLB0_BLK_REG_ADDR + 0x05C)
+#define PLB1_ECM_TIMER_REG		(PLB1_BLK_REG_ADDR + 0x05C)
+/**
+ * Controls the rate-limiter on each of the priority class
+ */
+#define PLB0_RL_CTL			(PLB0_BLK_REG_ADDR + 0x060)
+#define PLB1_RL_CTL			(PLB1_BLK_REG_ADDR + 0x060)
+/**
+ * Max byte register, total 8, 0-7
+ * see catapult_spec.pdf for details
+ */
+#define PLB0_RL_MAX_BC(_num)			\
+	(PLB0_BLK_REG_ADDR + 0x064 + ((_num) << 2))
+#define PLB1_RL_MAX_BC(_num)			\
+	(PLB1_BLK_REG_ADDR + 0x064 + ((_num) << 2))
+/**
+ * RL Time Unit Register for priority 0-7
+ * 4 bits per priority
+ * (2^rl_unit)*1us is the actual time period
+ */
+#define PLB0_RL_TU_PRIO			(PLB0_BLK_REG_ADDR + 0x084)
+#define PLB1_RL_TU_PRIO			(PLB1_BLK_REG_ADDR + 0x084)
+/**
+ * RL byte count register,
+ * bytes transmitted in (rl_unit*1)us time period
+ * 1 per priority, 8 in all, 0-7.
+ */
+#define PLB0_RL_BYTE_CNT(_num)			\
+	(PLB0_BLK_REG_ADDR + 0x088 + ((_num) << 2))
+#define PLB1_RL_BYTE_CNT(_num)			\
+	(PLB1_BLK_REG_ADDR + 0x088 + ((_num) << 2))
+/**
+ * RL Min factor register
+ * 2 bits per priority,
+ * 4 factors possible: 1, 0.5, 0.25, 0
+ * 2'b00 - 0; 2'b01 - 0.25; 2'b10 - 0.5; 2'b11 - 1
+ */
+#define PLB0_RL_MIN_REG			(PLB0_BLK_REG_ADDR + 0x0A8)
+#define PLB1_RL_MIN_REG			(PLB1_BLK_REG_ADDR + 0x0A8)
+/**
+ * RL Max factor register
+ * 2 bits per priority,
+ * 4 factors possible: 1, 0.5, 0.25, 0
+ * 2'b00 - 0; 2'b01 - 0.25; 2'b10 - 0.5; 2'b11 - 1
+ */
+#define PLB0_RL_MAX_REG			(PLB0_BLK_REG_ADDR + 0x0AC)
+#define PLB1_RL_MAX_REG			(PLB1_BLK_REG_ADDR + 0x0AC)
+
+/**
+ * MAC SERDES Address Paging register
+ */
+#define PLB0_EMS_ADD_REG		(PLB0_BLK_REG_ADDR + 0xD0)
+#define PLB1_EMS_ADD_REG		(PLB1_BLK_REG_ADDR + 0xD0)
+
+/**
+ * LL EMS Registers
+ */
+#define LL_EMS0_BLK_REG_ADDR		0x00026800
+#define LL_EMS1_BLK_REG_ADDR		0x00026C00
+
+/**
+ * BPC Block Register Address Offset from BAR0
+ * BPC0 Range : 0x23000 - 0x233FF
+ * BPC1 Range : 0x23400 - 0x237FF
+ */
+#define BPC0_BLK_REG_ADDR		0x00023000
+#define BPC1_BLK_REG_ADDR		0x00023400
+
+/**
+ * BPC Registers
+ */
+	/* TODO */
+/**
+ * PMM Block Register Address Offset from BAR0
+ * PMM0 Range : 0x23800 - 0x23BFF
+ * PMM1 Range : 0x23C00 - 0x23FFF
+ */
+#define PMM0_BLK_REG_ADDR		0x00023800
+#define PMM1_BLK_REG_ADDR		0x00023C00
+/**
+ * PMM Registers
+ */
+	/* TODO */
+
+/**
+ * HQM Block Register Address Offset from BAR0
+ * HQM0 Range : 0x24000 - 0x243FF
+ * HQM1 Range : 0x24400 - 0x247FF
+ */
+#define HQM0_BLK_REG_ADDR		0x00024000
+#define HQM1_BLK_REG_ADDR		0x00024400
+/**
+ * HQM Control Register
+ * Controls some aspects of IB
+ * See catapult_spec.pdf for details
+ */
+#define HQM0_CTL_REG			(HQM0_BLK_REG_ADDR + 0x000)
+#define HQM1_CTL_REG			(HQM1_BLK_REG_ADDR + 0x000)
+/**
+ * HQM Stop Q Semaphore Registers.
+ * Only one Queue resource can be stopped at
+ * any given time. This register controls access
+ * to the single stop Q resource.
+ * See catapult_spec.pdf for details
+ */
+#define HQM0_RXQ_STOP_SEM		(HQM0_BLK_REG_ADDR + 0x028)
+#define HQM0_TXQ_STOP_SEM		(HQM0_BLK_REG_ADDR + 0x02C)
+#define HQM1_RXQ_STOP_SEM		(HQM1_BLK_REG_ADDR + 0x028)
+#define HQM1_TXQ_STOP_SEM		(HQM1_BLK_REG_ADDR + 0x02C)
+
+/**
+ * LUT Block Register Address Offset from BAR0
+ * LUT0 Range : 0x25800 - 0x25BFF
+ * LUT1 Range : 0x25C00 - 0x25FFF
+ */
+#define LUT0_BLK_REG_ADDR		0x00025800
+#define LUT1_BLK_REG_ADDR		0x00025C00
+/**
+ * LUT Registers
+ * See catapult_spec.pdf for details
+ */
+#define LUT0_ERR_STS			(LUT0_BLK_REG_ADDR + 0x000)
+#define LUT1_ERR_STS			(LUT1_BLK_REG_ADDR + 0x000)
+#define LUT0_SET_ERR_STS		(LUT0_BLK_REG_ADDR + 0x004)
+#define LUT1_SET_ERR_STS		(LUT1_BLK_REG_ADDR + 0x004)
+
+/**
+ * LDM (Link Layer DMA) Registers
+ */
+	/* TODO */
+
+/**
+ * SGD (Scatter/Gather Database) Registers
+ */
+	/* TODO */
+
+/**
+ * TRC (Debug/Trace) Register Offset from BAR0
+ * Range : 0x26000 -- 0x263FFF
+ */
+#define TRC_BLK_REG_ADDR		0x00026000
+/**
+ * TRC Registers
+ * See catapult_spec.pdf for details of each
+ */
+#define TRC_CTL_REG			(TRC_BLK_REG_ADDR + 0x000)
+#define TRC_MODS_REG			(TRC_BLK_REG_ADDR + 0x004)
+#define TRC_TRGC_REG			(TRC_BLK_REG_ADDR + 0x008)
+#define TRC_CNT1_REG			(TRC_BLK_REG_ADDR + 0x010)
+#define TRC_CNT2_REG			(TRC_BLK_REG_ADDR + 0x014)
+#define TRC_NXTS_REG			(TRC_BLK_REG_ADDR + 0x018)
+#define TRC_DIRR_REG			(TRC_BLK_REG_ADDR + 0x01C)
+/**
+ * TRC Trigger match filters, total 10
+ * Determines the trigger condition
+ */
+#define TRC_TRGM_REG(_num)		\
+	(TRC_BLK_REG_ADDR + 0x040 + ((_num) << 2))
+/**
+ * TRC Next State filters, total 10
+ * Determines the next state conditions
+ */
+#define TRC_NXTM_REG(_num)		\
+	(TRC_BLK_REG_ADDR + 0x080 + ((_num) << 2))
+/**
+ * TRC Store Match filters, total 10
+ * Determines the store conditions
+ */
+#define TRC_STRM_REG(_num)		\
+	(TRC_BLK_REG_ADDR + 0x0C0 + ((_num) << 2))
+
+
+
+/**************************************************************
+ *               DOORBELLS ACCESS
+ **************************************************************/
+/**
+ * Catapult doorbells
+ * Each doorbell-queue set has
+ * 1 RxQ, 1 TxQ, 2 IBs in that order
+ * Size of each entry in 32 bytes, even though only 1 word
+ * is used. For Non-VM case each doorbell-q set is
+ * separated by 128 bytes, for VM case it is separated
+ * by 4K bytes
+ * Non VM case Range : 0x38000 - 0x39FFF
+ * VM case Range     : 0x100000 - 0x11FFFF
+ * The range applies to both HQMs
+ */
+#define HQM_DOORBELL_BLK_BASE_ADDR	0x00038000
+#define HQM_DOORBELL_VM_BLK_BASE_ADDR	0x00100000
+
+/**************************************************************
+ *               MEMORY ACCESS
+ **************************************************************/
+/**
+ * Catapult H/W Block Memory Access Address
+ * To the host a memory space of 32K (page) is visible
+ * at a time. The address range is from 0x08000 to 0x0FFFF
+ */
+#define HW_BLK_HOST_MEM_ADDR		0x08000
+
+/**
+ * Catapult LUT Memory Access Page Numbers
+ * Range : LUT0 0xa0-0xa1
+ *         LUT1 0xa2-0xa3
+ */
+#define LUT0_MEM_BLK_BASE_PG_NUM	0x000000A0
+#define LUT1_MEM_BLK_BASE_PG_NUM	0x000000A2
+
+/**
+ * Catapult RxFn Database Memory Block Base Offset
+ *
+ * The Rx function database exists in LUT block.
+ * In PCIe space this is accessible as a 256x32
+ * bit block. Each entry in this database is 4
+ * (4 byte) words. Max. entries is 64.
+ * Address of an entry corresponding to a function
+ * = base_addr + (function_no. * 16)
+ */
+#define RX_FNDB_RAM_BASE_OFFSET		0x0000B400
+
+/**
+ * Catapult TxFn Database Memory Block Base Offset Address
+ *
+ * The Tx function database exists in LUT block.
+ * In PCIe space this is accessible as a 64x32
+ * bit block. Each entry in this database is 1
+ * (4 byte) word. Max. entries is 64.
+ * Address of an entry corresponding to a function
+ * = base_addr + (function_no. * 4)
+ */
+#define TX_FNDB_RAM_BASE_OFFSET		0x0000B800
+
+/**
+ * Catapult Unicast CAM Base Offset Address
+ *
+ * Exists in LUT memory space.
+ * Shared by both the LL & FCoE driver.
+ * Size is 256x48 bits; mapped to PCIe space
+ * 512x32 bit blocks. For each address, bits
+ * are written in the order : [47:32] and then
+ * [31:0].
+ */
+#define UCAST_CAM_BASE_OFFSET		0x0000A800
+
+/**
+ * Catapult Unicast RAM Base Offset Address
+ *
+ * Exists in LUT memory space.
+ * Shared by both the LL & FCoE driver.
+ * Size is 256x9 bits.
+ */
+#define UCAST_RAM_BASE_OFFSET		0x0000B000
+
+/**
+ * Catapult Mulicast CAM Base Offset Address
+ *
+ * Exists in LUT memory space.
+ * Shared by both the LL & FCoE driver.
+ * Size is 256x48 bits; mapped to PCIe space
+ * 512x32 bit blocks. For each address, bits
+ * are written in the order : [47:32] and then
+ * [31:0].
+ */
+#define MCAST_CAM_BASE_OFFSET		0x0000A000
+
+/**
+ * Catapult VLAN RAM Base Offset Address
+ *
+ * Exists in LUT memory space.
+ * Size is 4096x66 bits; mapped to PCIe space as
+ * 8192x32 bit blocks.
+ * All the 4K entries are within the address range
+ * 0x0000 to 0x8000, so in the first LUT page.
+ */
+#define VLAN_RAM_BASE_OFFSET		0x00000000
+
+/**
+ * Catapult Tx Stats RAM Base Offset Address
+ *
+ * Exists in LUT memory space.
+ * Size is 1024x33 bits;
+ * Each Tx function has 64 bytes of space
+ */
+#define TX_STATS_RAM_BASE_OFFSET	0x00009000
+
+/**
+ * Catapult Rx Stats RAM Base Offset Address
+ *
+ * Exists in LUT memory space.
+ * Size is 1024x33 bits;
+ * Each Rx function has 64 bytes of space
+ */
+#define RX_STATS_RAM_BASE_OFFSET	0x00008000
+/**
+ * Catapult RXA Memory Access Page Numbers
+ */
+#define RXA0_MEM_BLK_BASE_PG_NUM	0x0000008C
+#define RXA1_MEM_BLK_BASE_PG_NUM	0x0000008D
+
+/**
+ * Catapult Multicast Vector Table Base Offset Address
+ *
+ * Exists in RxA memory space.
+ * Organized as 512x65 bit block.
+ * However for each entry 16 bytes allocated (power of 2)
+ * Total size 512*16 bytes.
+ * There are two logical divisions, 256 entries each :
+ * a) Entries 0x00 to 0xff (256) -- Approx. MVT
+ *    Offset 0x000 to 0xFFF
+ * b) Entries 0x100 to 0x1ff (256) -- Exact MVT
+ *    Offsets 0x1000 to 0x1FFF
+ */
+#define MCAST_APPROX_MVT_BASE_OFFSET	0x00000000
+#define MCAST_EXACT_MVT_BASE_OFFSET	0x00001000
+/**
+ * Catapult RxQ Translate Table (RIT) Base Offset Address
+ *
+ * Exists in RxA memory space
+ * Total no. of entries 64
+ * Each entry is 1 (4 byte) word.
+ * 31:12 -- Reserved
+ * 11:0  -- Two 6 bit RxQ Ids
+ */
+#define FUNCTION_TO_RXQ_TRANSLATE	0x00002000
+
+/**
+ * Catapult RxAdm (RAD) Memory Access Page Numbers
+ */
+#define RAD0_MEM_BLK_BASE_PG_NUM	0x00000086
+#define RAD1_MEM_BLK_BASE_PG_NUM	0x00000087
+
+/**
+ * Catapult RSS Table Base Offset Address
+ *
+ * Exists in RAD memory space.
+ * Each entry is 352 bits, but alligned on
+ * 64 byte (512 bit) boundary. Accessed
+ * 4 byte words, the whole entry can be
+ * broken into 11 word accesses.
+ */
+#define RSS_TABLE_BASE_OFFSET		0x00000800
+
+/**
+ * Catapult CPQ Block Page Number
+ * This value is written to the page number registers
+ * to access the memory associated with the mailboxes.
+ */
+#define CPQ_BLK_PG_NUM			0x00000005
+
+/**
+ * Clarification :
+ * LL functions are 2 & 3; can HostFn0/HostFn1
+ * <-> LPU0/LPU1 memories be used ?
+ */
+/**
+ * Catapult HostFn0/HostFn1 to LPU0/LPU1 Mbox memory
+ * Per catapult_spec.pdf, the offset of the mbox
+ * memory is in the register space at an offset of 0x200
+ */
+#define CPQ_BLK_REG_MBOX_ADDR		(CPQ_BLK_REG_ADDR + 0x200)
+
+#define HOSTFN_LPU_MBOX			(CPQ_BLK_REG_MBOX_ADDR + 0x000)
+/**
+ * Catapult LPU0/LPU1 to HostFn0/HostFn1 Mbox memory
+ */
+#define LPU_HOSTFN_MBOX			(CPQ_BLK_REG_MBOX_ADDR + 0x080)
+
+/**
+ * Catapult HQM Block Page Number
+ * This is written to the page number register for
+ * the appropriate function to access the memory
+ * associated with HQM
+ */
+#define HQM0_BLK_PG_NUM			0x00000096
+#define HQM1_BLK_PG_NUM			0x00000097
+
+/**
+ * Note that TxQ and RxQ entries are interlaced
+ * the HQM memory, i.e RXQ0, TXQ0, RXQ1, TXQ1.. etc.
+ */
+
+#define HQM_RXTX_Q_RAM_BASE_OFFSET	0x00004000
+
+/**
+ * CQ Memory
+ * Exists in HQM Memory space
+ * Each entry is 16 (4 byte) words of which
+ * only 12 words are used for configuration
+ * Total 64 entries per HQM memory space
+ */
+#define HQM_CQ_RAM_BASE_OFFSET		0x00006000
+
+/**
+ * Interrupt Block (IB) Memory
+ * Exists in HQM Memory space
+ * Each entry is 8 (4 byte) words of which
+ * only 5 words are used for configuration
+ * Total 128 entries per HQM memory space
+ */
+#define HQM_IB_RAM_BASE_OFFSET		0x00001000
+
+/**
+ * Index Table (IT) Memory
+ * Exists in HQM Memory space
+ * Each entry is 1 (4 byte) word which
+ * is used for configuration
+ * Total 128 entries per HQM memory space
+ */
+#define HQM_INDX_TBL_RAM_BASE_OFFSET	0x00002000
+
+/**
+ * PSS Block Memory Page Number
+ * This is written to the appropriate page number
+ * register to access the CPU memory.
+ * Also known as the PSS secondary memory (SMEM).
+ * Range : 0x180 to 0x1CF
+ * See catapult_spec.pdf for details
+ */
+#define PSS_BLK_PG_NUM			0x00000180
+
+/**
+ * Offsets of different instances of PSS SMEM
+ * 2.5M of continuous 1T memory space : 2 blocks
+ * of 1M each (32 pages each, page=32KB) and 4 smaller
+ * blocks of 128K each (4 pages each, page=32KB)
+ * PSS_LMEM_INST0 is used for firmware download
+ */
+#define PSS_LMEM_INST0			0x00000000
+#define PSS_LMEM_INST1			0x00100000
+#define PSS_LMEM_INST2			0x00200000
+#define PSS_LMEM_INST3			0x00220000
+#define PSS_LMEM_INST4			0x00240000
+#define PSS_LMEM_INST5			0x00260000
+
+#endif /* __BNA_HWREG_H__ */
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bna_intr.h linux-2.6.32-rc4-mod/drivers/net/bna/bna_intr.h
--- linux-2.6.32-rc4-orig/drivers/net/bna/bna_intr.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bna_intr.h	2009-10-16 10:30:53.865440000 -0700
@@ -0,0 +1,96 @@
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
+ *
+ * File for interrupt macros and functions
+ */
+
+#ifndef __BNA_INTR_H__
+#define __BNA_INTR_H__
+
+static inline void
+bna_intx_disable(struct bna_dev_s *dev, u32 *cur_mask)
+{
+		/* Store the original mask */
+		*cur_mask = bna_reg_read(dev->regs.fn_int_mask);
+		bna_reg_write(dev->regs.fn_int_mask, 0xffffffff);
+}
+
+#define bna_intx_enable(dev, new_mask) 			\
+	bna_reg_write((dev)->regs.fn_int_mask, (new_mask))
+
+#define bna_mbox_intr_disable(dev)		\
+	bna_reg_write((dev)->regs.fn_int_mask, 	\
+	     (bna_reg_read((dev)->regs.fn_int_mask) | \
+	     (__LPU2HOST_MBOX_MASK_BITS | __ERROR_MASK_BITS)))
+
+#define bna_mbox_intr_enable(dev)		\
+	bna_reg_write((dev)->regs.fn_int_mask, 	\
+	     (bna_reg_read((dev)->regs.fn_int_mask) & \
+	     ~(__LPU2HOST_MBOX_MASK_BITS | __ERROR_MASK_BITS)))
+
+static inline void
+bna_intr_status_get(struct bna_dev_s *dev, u32 *status)
+{
+		*status = bna_reg_read(dev->regs.fn_int_status);
+		/*
+		 * Clear the status bits before returning
+		 * But do not touch the mailbox bits as yet
+		 */
+		/* Write a '1' to clear the required bits */
+		if (*status) {
+				bna_reg_write(dev->regs.fn_int_status,
+					*status &
+					~(__LPU02HOST_MBOX0_STATUS_BITS |
+					__LPU02HOST_MBOX1_STATUS_BITS |
+					__LPU12HOST_MBOX0_STATUS_BITS |
+					__LPU12HOST_MBOX1_STATUS_BITS));
+		}
+}
+
+#define bna_intr_status_get_no_clr(dev, status)		\
+	{*(status) = bna_reg_read((dev)->regs.fn_int_status)}
+
+#define bna_intr_mask_get(dev, mask)		\
+	(*mask) = bna_reg_read((dev)->regs.fn_int_mask)
+
+#define bna_intr_ack(dev, intr_bmap)		\
+	bna_reg_write((dev)->regs.fn_int_status, (intr_bmap))
+
+#define bna_ib_intx_disable(dev, ib_id)		\
+	bna_reg_write((dev)->regs.fn_int_mask, 	\
+	    bna_reg_read((dev)->regs.fn_int_mask) | \
+	    (1 << (ib_id)))
+
+#define bna_ib_intx_enable(dev, ib_id)		\
+	bna_reg_write((dev)->regs.fn_int_mask, 	\
+	    bna_reg_read((dev)->regs.fn_int_mask) & \
+	    ~(1 << (ib_id)))
+
+extern const struct bna_chip_regs_offset reg_offset[];
+#define bna_mbox_msix_idx_set(dev, msix_vector)		\
+	bna_reg_write((dev)->bar0 + reg_offset[(dev)->pci_fn].msix_idx, \
+	    ((msix_vector) & 0x000001ff))
+
+
+#endif /* __BNA_INTR_H__ */
+
