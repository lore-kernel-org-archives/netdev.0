From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 4/9] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 28 Aug 2009 22:18:39 -0700
Message-ID: <200908290518.n7T5IdcQ031884@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amathur@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:35853 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbZH2FXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 01:23:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 4/9 which contains linux driver source for 
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.

We wish this patch to be considered for inclusion in 2.6.30 

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---


diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_callback_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_callback_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_callback_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_callback_priv.h	2009-08-28 21:09:23.216883000 -0700
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
+typedef void (*bfa_cb_cbfn_t) (void *cbarg, bfa_boolean_t complete);
+
+/**
+ * Generic BFA callback element.
+ */
+struct bfa_cb_qe_s {
+	struct list_head qe;
+	bfa_cb_cbfn_t cbfn;
+	bfa_boolean_t once;
+	u32 rsvd;
+	void *cbarg;
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
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_csdebug.c linux-2.6.30.5-mod/drivers/net/bna/bfa_csdebug.c
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_csdebug.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_csdebug.c	2009-08-28 21:09:23.038897000 -0700
@@ -0,0 +1,63 @@
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
+#include <cs/bfa_debug.h>
+#include <bfa_os_inc.h>
+#include <cs/bfa_q.h>
+#include <log/bfa_log_hal.h>
+
+/**
+ *  cs_debug_api
+ */
+
+
+void
+bfa_panic(int line, char *file, char *panicstr)
+{
+	bfa_log(NULL, BFA_LOG_HAL_ASSERT, file, line, panicstr);
+	bfa_os_panic();
+}
+
+void
+bfa_sm_panic(struct bfa_log_mod_s *logm, int line, char *file, int event)
+{
+	bfa_log(logm, BFA_LOG_HAL_SM_ASSERT, file, line, event);
+	bfa_os_panic();
+}
+
+int
+bfa_q_is_on_q_func(struct list_head *q, struct list_head *qe)
+{
+	struct list_head *tqe;
+
+	tqe = bfa_q_next(q);
+	while (tqe != q) {
+		if (tqe == qe)
+			return (1);
+		tqe = bfa_q_next(tqe);
+		if (tqe == NULL)
+			break;
+	}
+	return (0);
+}
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfad_drv.h linux-2.6.30.5-mod/drivers/net/bna/bfad_drv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfad_drv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfad_drv.h	2009-08-28 21:09:23.249890000 -0700
@@ -0,0 +1,395 @@
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
+ * Contains base driver definitions.
+ */
+
+/**
+ *  bfa_drv.h Linux driver data structures.
+ */
+
+#ifndef __BFAD_DRV_H__
+#define __BFAD_DRV_H__
+
+#include "bfa_os_inc.h"
+
+#include <bfa.h>
+#include <bfa_svc.h>
+#include <fcs/bfa_fcs.h>
+#include <defs/bfa_defs_pci.h>
+#include <defs/bfa_defs_port.h>
+#include <defs/bfa_defs_rport.h>
+#include <fcs/bfa_fcs_rport.h>
+#include <defs/bfa_defs_vport.h>
+#include <fcs/bfa_fcs_vport.h>
+
+#include <cs/bfa_plog.h>
+#include "aen/bfa_aen.h"
+#include <log/bfa_log_linux.h>
+
+#define BFAD_DRIVER_NAME        "bfa"
+#ifdef BFA_DRIVER_VERSION
+#define BFAD_DRIVER_VERSION    BFA_DRIVER_VERSION
+#else
+#define BFAD_DRIVER_VERSION    "2.0.0.0"
+#endif
+
+#if defined(CONFIG_PCIEPORTBUS) && defined(CONFIG_PCIEAER)
+#define BFAD_ENABLE_PCIE_AER(x) pci_enable_pcie_error_reporting(x)
+#else
+#define BFAD_ENABLE_PCIE_AER(x) {}
+#endif
+
+
+#define BFAD_IRQ_FLAGS IRQF_SHARED
+
+#ifndef FC_PORTSPEED_8GBIT
+#define FC_PORTSPEED_8GBIT 0x10
+#endif
+
+/*
+ * BFAD flags
+ */
+#define BFAD_MSIX_ON				0x00000001
+#define BFAD_HAL_INIT_DONE			0x00000002
+#define BFAD_DRV_INIT_DONE			0x00000004
+#define BFAD_CFG_PPORT_DONE			0x00000008
+#define BFAD_HAL_START_DONE			0x00000010
+#define BFAD_PORT_ONLINE			0x00000020
+#define BFAD_RPORT_ONLINE			0x00000040
+
+#define BFAD_PORT_DELETE			0x00000001
+
+/*
+ * BFAD related definition
+ */
+#define SCSI_SCAN_DELAY		HZ
+#define BFAD_STOP_TIMEOUT	30
+#define BFAD_SUSPEND_TIMEOUT	BFAD_STOP_TIMEOUT
+
+/*
+ * BFAD configuration parameter default values
+ */
+#define BFAD_LUN_QUEUE_DEPTH 		32
+#define BFAD_IO_MAX_SGE 		SG_ALL
+
+#define bfad_isr_t irq_handler_t
+
+#if defined(__VMKERNEL_MODULE__)
+#ifndef CONFIG_PCI_MSI
+#define CONFIG_PCI_MSI
+#endif
+#endif
+
+#ifdef CONFIG_PCI_MSI
+#define MAX_MSIX_ENTRY 22
+
+struct bfad_msix_s {
+	struct bfad_s *bfad;
+	struct msix_entry msix;
+};
+#endif
+
+enum bfad_port_pvb_type {
+	BFAD_PORT_PHYS_BASE = 0,
+	BFAD_PORT_PHYS_VPORT = 1,
+	BFAD_PORT_VF_BASE = 2,
+	BFAD_PORT_VF_VPORT = 3,
+};
+
+/*
+ * PORT data structure
+ */
+struct bfad_port_s {
+	struct list_head list_entry;
+	struct bfad_s *bfad;
+	struct bfa_fcs_port_s *fcs_port;
+	u32 roles;
+	s32 flags;
+	u32 supported_fc4s;
+	u8 ipfc_flags;
+	enum bfad_port_pvb_type pvb_type;
+	struct bfad_im_port_s *im_port;	/* IM specific data */
+	struct bfad_tm_port_s *tm_port;	/* TM specific data */
+	struct bfad_ipfc_port_s *ipfc_port;	/* IPFC specific data */
+};
+
+/*
+ * VPORT data structure
+ */
+struct bfad_vport_s {
+	struct bfad_port_s drv_port;
+	struct bfa_fcs_vport_s fcs_vport;
+	struct completion *comp_del;
+};
+
+/*
+ * VF data structure
+ */
+struct bfad_vf_s {
+	bfa_fcs_vf_t fcs_vf;
+	struct bfad_port_s base_port;	/* base port for vf */
+	struct bfad_s *bfad;
+};
+
+struct bfad_cfg_param_s {
+	u32 rport_del_timeout;
+	u32 ioc_queue_depth;
+	u32 lun_queue_depth;
+	u32 io_max_sge;
+	u32 binding_method;
+};
+
+#define BFAD_AEN_MAX_APPS 8
+struct bfad_aen_file_s {
+	struct list_head qe;
+	struct bfad_s *bfad;
+	s32 ri;
+	s32 app_id;
+};
+
+/*
+ * BFAD (PCI function) data structure
+ */
+struct bfad_s {
+	struct list_head list_entry;
+	struct bfa_s bfa;
+	struct bfa_fcs_s bfa_fcs;
+	struct pci_dev *pcidev;
+	const char *pci_name;
+	struct bfa_pcidev_s hal_pcidev;
+	struct bfa_ioc_pci_attr_s pci_attr;
+	unsigned long pci_bar0_map;
+	void __iomem *pci_bar0_kva;
+	struct completion comp;
+	struct completion suspend;
+	struct completion disable_comp;
+	bfa_boolean_t disable_active;
+	struct bfad_port_s pport;	/* physical port of the BFAD */
+	struct bfa_meminfo_s meminfo;
+	struct bfa_iocfc_cfg_s ioc_cfg;
+	u32 inst_no;		/* BFAD instance number */
+	u32 bfad_flags;
+	spinlock_t bfad_lock;
+	struct bfad_cfg_param_s cfg_data;
+#ifdef CONFIG_PCI_MSI
+	struct bfad_msix_s msix_tab[MAX_MSIX_ENTRY];
+	int nvec;
+#endif
+
+	char adapter_name[BFA_ADAPTER_SYM_NAME_LEN];
+	char port_name[BFA_ADAPTER_SYM_NAME_LEN];
+	struct timer_list hal_tmo;
+	unsigned long hs_start;
+	struct bfad_im_s *im;	/* IM specific data */
+	struct bfad_tm_s *tm;	/* TM specific data */
+	struct bfad_ipfc_s *ipfc;	/* IPFC specific data */
+	struct bfa_log_mod_s log_data;
+	struct bfa_trc_mod_s *trcmod;
+	struct bfa_log_mod_s *logmod;
+	struct bfa_aen_s *aen;
+	struct bfa_aen_s aen_buf;
+	struct bfad_aen_file_s file_buf[BFAD_AEN_MAX_APPS];
+	struct list_head file_q;
+	struct list_head file_free_q;
+	struct bfa_plog_s plog_buf;
+	int ref_count;
+	bfa_boolean_t ipfc_enabled;
+	struct fc_host_statistics link_stats;
+
+	struct kobject *bfa_kobj;
+	struct kobject *ioc_kobj;
+	struct kobject *pport_kobj;
+	struct kobject *lport_kobj;
+};
+
+/*
+ * RPORT data structure
+ */
+struct bfad_rport_s {
+	struct bfa_fcs_rport_s fcs_rport;
+};
+
+struct bfad_buf_info {
+	void *virt;
+	dma_addr_t phys;
+	u32 size;
+};
+
+struct bfad_fcxp {
+	struct bfad_port_s *port;
+	struct bfa_rport_s *bfa_rport;
+	bfa_status_t req_status;
+	u16 tag;
+	u16 rsp_len;
+	u16 rsp_maxlen;
+	u8 use_ireqbuf;
+	u8 use_irspbuf;
+	u32 num_req_sgles;
+	u32 num_rsp_sgles;
+	struct fchs_s fchs;
+	void *reqbuf_info;
+	void *rspbuf_info;
+	struct bfa_sge_s *req_sge;
+	struct bfa_sge_s *rsp_sge;
+	fcxp_send_cb_t send_cbfn;
+	void *send_cbarg;
+	void *bfa_fcxp;
+	struct completion comp;
+};
+
+struct bfad_hal_comp {
+	bfa_status_t status;
+	struct completion comp;
+};
+
+/*
+ * Macro to obtain the immediate lower power
+ * of two for the integer.
+ */
+#define nextLowerInt(x)                         	\
+do {                                            	\
+	int j;                                  	\
+	(*x)--;    		                	\
+	for (j = 1; j < (sizeof(int) * 8); j <<= 1)     \
+		(*x) = (*x) | (*x) >> j;        	\
+	(*x)++;                  	        	\
+	(*x) = (*x) >> 1;                       	\
+} while (0)
+
+
+#define BFAD_WORK_HANDLER(name) void name(struct work_struct *work)
+#define BFAD_INIT_WORK(x, work, func) INIT_WORK(&(x)->work, func)
+
+#define list_remove_head(list, entry, type, member)       	\
+do {                                                    	\
+	entry = NULL;                                           \
+	if (!list_empty(list)) {                                \
+		entry = list_entry((list)->next, type, member); 	\
+		list_del_init(&entry->member);                  	\
+	}								\
+} while (0)
+
+#define list_get_first(list, type, member)				\
+((list_empty(list)) ? NULL :						\
+	list_entry((list)->next, type, member))
+
+bfa_boolean_t bfad_is_ready(void);
+bfa_status_t bfad_vport_create(struct bfad_s *bfad, u16 vf_id,
+			       struct bfa_port_cfg_s *port_cfg);
+bfa_status_t bfad_vf_create(struct bfad_s *bfad, u16 vf_id,
+			    struct bfa_port_cfg_s *port_cfg);
+bfa_status_t bfad_cfg_pport(struct bfad_s *bfad, enum bfa_port_role role);
+bfa_status_t bfad_drv_init(struct bfad_s *bfad);
+struct bfad_s *bfad_find_bfad_by_inst_no(int inst_no);
+void bfad_drv_start(struct bfad_s *bfad);
+void bfad_uncfg_pport(struct bfad_s *bfad);
+void bfad_drv_stop(struct bfad_s *bfad);
+void bfad_remove_intr(struct bfad_s *bfad);
+void bfad_hal_mem_release(struct bfad_s *bfad);
+void bfad_hcb_comp(void *arg, bfa_status_t status);
+
+int bfad_os_ioctl_init(void);
+int bfad_os_ioctl_exit(void);
+int bfad_setup_intr(struct bfad_s *bfad);
+void bfad_remove_intr(struct bfad_s *bfad);
+int bfad_os_pci_register_driver(struct pci_driver *drv);
+void bfad_os_pci_unregister_driver(struct pci_driver *drv);
+void bfad_os_device_sysfs_create(struct bfad_s *);
+void bfad_os_device_sysfs_remove(struct bfad_s *);
+void bfad_os_pci_set_mwi(struct pci_dev *pdev);
+void bfad_os_idr_init(struct idr *idr);
+void bfad_os_idr_destroy(struct idr *idr);
+void *bfad_os_dma_alloc(struct bfad_s *bfad, struct bfa_mem_elem_s
+			*meminfo_elem, dma_addr_t * phys_addr);
+void bfad_os_dma_free(struct bfad_s *bfad, struct bfa_mem_elem_s
+		      *meminfo_elem);
+void bfad_os_idr_remove(struct idr *idp, int id);
+int bfad_os_idr_pre_get(struct idr *idp, gfp_t gfp_mask);
+void bfad_os_iounmap(struct pci_dev *pdev, struct bfad_s *bfad);
+
+void bfad_update_hal_cfg(struct bfa_iocfc_cfg_s *bfa_cfg);
+bfa_status_t bfad_hal_mem_alloc(struct bfad_s *bfad);
+void bfad_bfa_tmo(unsigned long data);
+void bfad_init_timer(struct bfad_s *bfad);
+int bfad_pci_init(struct pci_dev *pdev, struct bfad_s *bfad);
+void bfad_pci_uninit(struct pci_dev *pdev, struct bfad_s *bfad);
+void bfad_fcs_port_cfg(struct bfad_s *bfad);
+void bfad_drv_uninit(struct bfad_s *bfad);
+void bfad_drv_log_level_set(struct bfad_s *bfad);
+bfa_status_t bfad_fc4_module_init(void);
+void bfad_fc4_module_exit(void);
+int bfad_ipfc_probe(struct bfad_s *bfad);
+int bfad_ipfc_probe_undo(struct bfad_s *bfad);
+void bfad_ipfc_probe_post(struct bfad_s *bfad);
+int bfad_ipfc_module_init(void);
+void bfad_ipfc_module_exit(void);
+int bfad_ipfc_port_online(struct bfad_s *bfad, struct bfad_port_s *port);
+int bfad_ipfc_port_offline(struct bfad_s *bfad, struct bfad_port_s *port);
+int bfad_ipfc_port_new(struct bfad_s *bfad,
+		       struct bfad_port_s *port, int port_type);
+int bfad_ipfc_port_delete(struct bfad_s *bfad, struct bfad_port_s *port);
+
+
+
+
+void bfad_pci_remove(struct pci_dev *pdev);
+int bfad_pci_probe(struct pci_dev *pdev, const struct pci_device_id *pid);
+void bfad_os_rport_online_wait(struct bfad_s *bfad);
+int bfad_os_get_linkup_delay(struct bfad_s *bfad);
+u32 bfa_os_get_instance_id(struct bfad_s *bfad);
+int bfad_install_msix_handler(struct bfad_s *bfad);
+
+extern struct idr bfad_im_port_index;
+extern struct pci_driver *bfad_pci_driver_p;
+
+extern struct pci_device_id bfad_id_table[];
+extern int bfad_scan_done;
+extern struct list_head bfad_list;
+extern char *os_name;
+extern char *os_patch;
+extern char *host_name;
+extern int num_rports;
+extern int num_ios;
+extern int num_tms;
+extern int num_fcxps;
+extern int num_ufbufs;
+extern int reqq_size;
+extern int rspq_size;
+extern int num_sgpgs;
+extern int rport_del_timeout;
+extern int bfa_lun_queue_depth;
+extern int bfa_io_max_sge;
+extern int log_level;
+extern int ioc_auto_recover;
+extern int ipfc_enable;
+extern int ipfc_mtu;
+extern int linkup_delay;
+extern int msix_disable;
+
+extern int supported_fc4s;
+
+
+#endif /* __BFAD_DRV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfad_fwimg.c linux-2.6.30.5-mod/drivers/net/bna/bfad_fwimg.c
--- linux-2.6.30.5-orig/drivers/net/bna/bfad_fwimg.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfad_fwimg.c	2009-08-28 21:09:23.393882000 -0700
@@ -0,0 +1,108 @@
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
+ *  bfad_fwimg.c Linux driver PCI interface module.
+ */
+#include <bfa_os_inc.h>
+#include <bfad_drv.h>
+#include <bfad_im_compat.h>
+#include <defs/bfa_defs_version.h>
+#include <linux/errno.h>
+#include <linux/sched.h>
+#include <linux/init.h>
+#include <linux/fs.h>
+#include <asm/uaccess.h>
+#include <asm/fcntl.h>
+#include <linux/pci.h>
+#include <linux/firmware.h>
+#include <bfa_fwimg_priv.h>
+#include <bfa.h>
+
+u32 bfi_image_ct_size;
+u32 bfi_image_cb_size;
+u32 *bfi_image_ct;
+u32 *bfi_image_cb;
+
+
+#define	BFAD_FW_FILE_CT	"ctfw.bin"
+#define	BFAD_FW_FILE_CB	"cbfw.bin"
+
+u32 *
+bfad_read_firmware(struct pci_dev *pdev, u32 ** bfi_image,
+		   u32 * bfi_image_size, char *fw_name)
+{
+	const struct firmware *fw;
+
+	if (request_firmware(&fw, fw_name, &pdev->dev)) {
+		printk(KERN_ALERT "Can't locate firmware %s\n", fw_name);
+		goto error;
+	}
+
+	*bfi_image = vmalloc(fw->size);
+	if (NULL == *bfi_image) {
+		printk(KERN_ALERT "Fail to allocate buffer for fw image "
+		       "size=%x!\n", (u32) fw->size);
+		goto error;
+	}
+
+	memcpy(*bfi_image, fw->data, fw->size);
+	*bfi_image_size = fw->size / sizeof(u32);
+
+	return (*bfi_image);
+
+      error:
+	return (NULL);
+}
+
+u32 *
+bfad_get_firmware_buf(struct pci_dev * pdev)
+{
+	if (pdev->device == BFA_PCI_DEVICE_ID_CT) {
+		if (bfi_image_ct_size == 0)
+			bfad_read_firmware(pdev, &bfi_image_ct,
+					   &bfi_image_ct_size, BFAD_FW_FILE_CT);
+		return (bfi_image_ct);
+	} else {
+		if (bfi_image_cb_size == 0)
+			bfad_read_firmware(pdev, &bfi_image_cb,
+					   &bfi_image_cb_size, BFAD_FW_FILE_CB);
+		return (bfi_image_cb);
+	}
+}
+
+u32 *
+bfi_image_ct_get_chunk(u32 off)
+{
+	return (u32 *) (bfi_image_ct + off);
+}
+
+u32 *
+bfi_image_cb_get_chunk(u32 off)
+{
+	return (u32 *) (bfi_image_cb + off);
+}
+
+
+char bfa_version[BFA_VERSION_LEN] = "rmody_pvt_bld 08/26/2009 11.26.03";
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfad_im_compat.h linux-2.6.30.5-mod/drivers/net/bna/bfad_im_compat.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfad_im_compat.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfad_im_compat.h	2009-08-28 21:09:23.178883000 -0700
@@ -0,0 +1,53 @@
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
+#ifndef __BFAD_IM_COMPAT_H__
+#define __BFAD_IM_COMPAT_H__
+
+extern u32 *bfi_image_buf;
+extern u32 bfi_image_size;
+
+extern struct device_attribute *bfad_im_host_attrs[];
+extern struct device_attribute *bfad_im_vport_attrs[];
+
+u32 *bfad_get_firmware_buf(struct pci_dev *pdev);
+u32 *bfad_read_firmware(struct pci_dev *pdev, u32 ** bfi_image,
+			u32 * bfi_image_size, char *fw_name);
+
+static inline u32 *
+bfad_load_fwimg(struct pci_dev *pdev)
+{
+	return (bfad_get_firmware_buf(pdev));
+}
+
+static inline void
+bfad_free_fwimg(void)
+{
+	if (bfi_image_ct_size && bfi_image_ct)
+		vfree(bfi_image_ct);
+	if (bfi_image_cb_size && bfi_image_cb)
+		vfree(bfi_image_cb);
+}
+
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_fcpim_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_fcpim_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_fcpim_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_fcpim_priv.h	2009-08-28 21:09:23.409885000 -0700
@@ -0,0 +1,191 @@
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
+#ifndef __BFA_FCPIM_PRIV_H__
+#define __BFA_FCPIM_PRIV_H__
+
+#include <bfa_fcpim.h>
+#include <defs/bfa_defs_fcpim.h>
+#include <cs/bfa_wc.h>
+#include "bfa_sgpg_priv.h"
+
+#define BFA_ITNIM_MIN   32
+#define BFA_ITNIM_MAX   1024
+
+#define BFA_IOIM_MIN    8
+#define BFA_IOIM_MAX    2000
+
+#define BFA_TSKIM_MIN   4
+#define BFA_TSKIM_MAX   512
+#define BFA_FCPIM_PATHTOV_DEF	(30 * 1000)	/* in millisecs */
+#define BFA_FCPIM_PATHTOV_MAX	(90 * 1000)	/* in millisecs */
+
+#define bfa_fcpim_stats(__fcpim, __stats)   \
+    (__fcpim)->stats.__stats ++
+
+struct bfa_fcpim_mod_s {
+	struct bfa_s *bfa;
+	struct bfa_itnim_s *itnim_arr;
+	struct bfa_ioim_s *ioim_arr;
+	struct bfa_ioim_sp_s *ioim_sp_arr;
+	struct bfa_tskim_s *tskim_arr;
+	struct bfa_dma_s snsbase;
+	int num_itnims;
+	int num_ioim_reqs;
+	int num_tskim_reqs;
+	u32 path_tov;
+	u16 q_depth;
+	u16 rsvd;
+	struct list_head itnim_q;	/*  queue of active itnim    */
+	struct list_head ioim_free_q;	/*  free IO resources        */
+	struct list_head ioim_resfree_q;	/*  IOs waiting for f/w      */
+	struct list_head ioim_comp_q;	/*  IO global comp Q         */
+	struct list_head tskim_free_q;
+	u32 ios_active;		/*  current active IOs        */
+	u32 delay_comp;
+	struct bfa_fcpim_stats_s stats;
+};
+
+struct bfa_ioim_s;
+struct bfa_tskim_s;
+
+/**
+ * BFA IO (initiator mode)
+ */
+struct bfa_ioim_s {
+	struct list_head qe;	/*  queue elememt            */
+	bfa_sm_t sm;		/*  BFA ioim state machine   */
+	struct bfa_s *bfa;	/*  BFA module               */
+	struct bfa_fcpim_mod_s *fcpim;	/*  parent fcpim module      */
+	struct bfa_itnim_s *itnim;	/*  i-t-n nexus for this IO  */
+	struct bfad_ioim_s *dio;	/*  driver IO handle         */
+	u16 iotag;		/*  FWI IO tag               */
+	u16 abort_tag;		/*  unqiue abort request tag */
+	u16 nsges;		/*  number of SG elements    */
+	u16 nsgpgs;		/*  number of SG pages       */
+	struct bfa_sgpg_s *sgpg;	/*  first SG page            */
+	struct list_head sgpg_q;	/*  allocated SG pages       */
+	struct bfa_cb_qe_s hcb_qe;	/*  bfa callback qelem       */
+	bfa_cb_cbfn_t io_cbfn;	/*  IO completion handler    */
+	struct bfa_ioim_sp_s *iosp;	/*  slow-path IO handling    */
+};
+
+struct bfa_ioim_sp_s {
+	struct bfi_msg_s comp_rspmsg;	/*  IO comp f/w response     */
+	u8 *snsinfo;		/*  sense info for this IO   */
+	struct bfa_sgpg_wqe_s sgpg_wqe;	/*  waitq elem for sgpg      */
+	struct bfa_reqq_wait_s reqq_wait;	/*  to wait for room in reqq */
+	bfa_boolean_t abort_explicit;	/*  aborted by OS            */
+	struct bfa_tskim_s *tskim;	/*  Relevant TM cmd          */
+};
+
+/**
+ * BFA Task management command (initiator mode)
+ */
+struct bfa_tskim_s {
+	struct list_head qe;
+	bfa_sm_t sm;
+	struct bfa_s *bfa;	/*  BFA module  */
+	struct bfa_fcpim_mod_s *fcpim;	/*  parent fcpim module      */
+	struct bfa_itnim_s *itnim;	/*  i-t-n nexus for this IO  */
+	struct bfad_tskim_s *dtsk;	/*  driver task mgmt cmnd    */
+	bfa_boolean_t notify;	/*  notify itnim on TM comp  */
+	lun_t lun;		/*  lun if applicable        */
+	enum fcp_tm_cmnd tm_cmnd;	/*  task management command  */
+	u16 tsk_tag;		/*  FWI IO tag               */
+	u8 tsecs;		/*  timeout in seconds       */
+	struct bfa_reqq_wait_s reqq_wait;	/*  to wait for room in reqq */
+	struct list_head io_q;	/*  queue of affected IOs    */
+	struct bfa_wc_s wc;	/*  waiting counter          */
+	struct bfa_cb_qe_s hcb_qe;	/*  bfa callback qelem       */
+	enum bfi_tskim_status tsk_status;	/*  TM status                */
+};
+
+/**
+ * BFA i-t-n (initiator mode)
+ */
+struct bfa_itnim_s {
+	struct list_head qe;	/*  queue element               */
+	bfa_sm_t sm;		/*  i-t-n im BFA state machine  */
+	struct bfa_s *bfa;	/*  bfa instance                */
+	struct bfa_rport_s *rport;	/*  bfa rport                   */
+	void *ditn;		/*  driver i-t-n structure      */
+	struct bfi_mhdr_s mhdr;	/*  pre-built mhdr              */
+	u8 msg_no;		/*  itnim/rport firmware handle */
+	u8 reqq;		/*  CQ for requests             */
+	struct bfa_cb_qe_s hcb_qe;	/*  bfa callback qelem          */
+	struct list_head pending_q;	/*  queue of pending IO requests */
+	struct list_head io_q;	/*  queue of active IO requests */
+	struct list_head io_cleanup_q;	/*  IO being cleaned up         */
+	struct list_head tsk_q;	/*  queue of active TM commands */
+	struct list_head delay_comp_q;	/*  queue of failed inflight cmds */
+	bfa_boolean_t seq_rec;	/*  SQER supported              */
+	bfa_boolean_t is_online;	/*  itnim is ONLINE for IO      */
+	bfa_boolean_t iotov_active;	/*  IO TOV timer is active       */
+	struct bfa_wc_s wc;	/*  waiting counter             */
+	struct bfa_timer_s timer;	/*  pending IO TOV               */
+	struct bfa_reqq_wait_s reqq_wait;	/*  to wait for room in reqq */
+	struct bfa_fcpim_mod_s *fcpim;	/*  fcpim module                */
+	struct bfa_itnim_hal_stats_s stats;
+};
+
+#define bfa_itnim_is_online(_itnim) (_itnim)->is_online
+#define BFA_FCPIM_MOD(_hal) (&(_hal)->modules.fcpim_mod)
+#define BFA_IOIM_FROM_TAG(_fcpim, _iotag)	\
+	(&fcpim->ioim_arr[_iotag])
+#define BFA_TSKIM_FROM_TAG(_fcpim, _tmtag)                  \
+    (&fcpim->tskim_arr[_tmtag & (fcpim->num_tskim_reqs - 1)])
+
+/*
+ * function prototypes
+ */
+void bfa_ioim_attach(struct bfa_fcpim_mod_s *fcpim,
+		     struct bfa_meminfo_s *minfo);
+void bfa_ioim_detach(struct bfa_fcpim_mod_s *fcpim);
+void bfa_ioim_isr(struct bfa_s *bfa, struct bfi_msg_s *msg);
+void bfa_ioim_good_comp_isr(struct bfa_s *bfa, struct bfi_msg_s *msg);
+void bfa_ioim_cleanup(struct bfa_ioim_s *ioim);
+void bfa_ioim_cleanup_tm(struct bfa_ioim_s *ioim, struct bfa_tskim_s *tskim);
+void bfa_ioim_iocdisable(struct bfa_ioim_s *ioim);
+void bfa_ioim_tov(struct bfa_ioim_s *ioim);
+
+void bfa_tskim_attach(struct bfa_fcpim_mod_s *fcpim,
+		      struct bfa_meminfo_s *minfo);
+void bfa_tskim_detach(struct bfa_fcpim_mod_s *fcpim);
+void bfa_tskim_isr(struct bfa_s *bfa, struct bfi_msg_s *msg);
+void bfa_tskim_iodone(struct bfa_tskim_s *tskim);
+void bfa_tskim_iocdisable(struct bfa_tskim_s *tskim);
+void bfa_tskim_cleanup(struct bfa_tskim_s *tskim);
+
+void bfa_itnim_meminfo(struct bfa_iocfc_cfg_s *cfg, u32 * km_len, u32 * dm_len);
+void bfa_itnim_attach(struct bfa_fcpim_mod_s *fcpim,
+		      struct bfa_meminfo_s *minfo);
+void bfa_itnim_detach(struct bfa_fcpim_mod_s *fcpim);
+void bfa_itnim_iocdisable(struct bfa_itnim_s *itnim);
+void bfa_itnim_isr(struct bfa_s *bfa, struct bfi_msg_s *msg);
+void bfa_itnim_iodone(struct bfa_itnim_s *itnim);
+void bfa_itnim_tskdone(struct bfa_itnim_s *itnim);
+bfa_boolean_t bfa_itnim_hold_io(struct bfa_itnim_s *itnim);
+
+#endif /* __BFA_FCPIM_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_fwimg_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_fwimg_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_fwimg_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_fwimg_priv.h	2009-08-28 21:09:23.495884000 -0700
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
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa.h linux-2.6.30.5-mod/drivers/net/bna/bfa.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa.h	2009-08-28 21:09:23.433883000 -0700
@@ -0,0 +1,183 @@
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
+#ifndef __BFA_H__
+#define __BFA_H__
+
+#include <bfa_os_inc.h>
+#include <cs/bfa_debug.h>
+#include <cs/bfa_q.h>
+#include <cs/bfa_trc.h>
+#include <cs/bfa_log.h>
+#include <cs/bfa_plog.h>
+#include <defs/bfa_defs_status.h>
+#include <defs/bfa_defs_ioc.h>
+#include <defs/bfa_defs_iocfc.h>
+#include <aen/bfa_aen.h>
+#include <bfi/bfi.h>
+
+struct bfa_s;
+#include <bfa_intr_priv.h>
+
+struct bfa_pcidev_s;
+
+/**
+ * PCI devices supported by the current BFA
+ */
+struct bfa_pciid_s {
+	u16 device_id;
+	u16 vendor_id;
+};
+
+extern char bfa_version[];
+
+/**
+ * BFA Power Mgmt Commands
+ */
+enum bfa_pm_cmd {
+	BFA_PM_CTL_D0 = 0,
+	BFA_PM_CTL_D1 = 1,
+	BFA_PM_CTL_D2 = 2,
+	BFA_PM_CTL_D3 = 3,
+};
+
+/**
+ * BFA memory resources
+ */
+enum bfa_mem_type {
+	BFA_MEM_TYPE_KVA = 1,	/*! Kernel Virtual Memory *(non-dma-able) */
+	BFA_MEM_TYPE_DMA = 2,	/*! DMA-able memory */
+	BFA_MEM_TYPE_MAX = BFA_MEM_TYPE_DMA,
+};
+
+struct bfa_mem_elem_s {
+	enum bfa_mem_type mem_type;	/*  see enum bfa_mem_type       */
+	u32 mem_len;		/*  Total Length in Bytes       */
+	u8 *kva;		/*  kernel virtual address      */
+	u64 dma;		/*  dma address if DMA memory   */
+	u8 *kva_curp;		/*  kva allocation cursor       */
+	u64 dma_curp;		/*  dma allocation cursor       */
+};
+
+struct bfa_meminfo_s {
+	struct bfa_mem_elem_s meminfo[BFA_MEM_TYPE_MAX];
+};
+#define bfa_meminfo_kva(_m)	\
+	(_m)->meminfo[BFA_MEM_TYPE_KVA - 1].kva_curp
+#define bfa_meminfo_dma_virt(_m)	\
+	(_m)->meminfo[BFA_MEM_TYPE_DMA - 1].kva_curp
+#define bfa_meminfo_dma_phys(_m)	\
+	(_m)->meminfo[BFA_MEM_TYPE_DMA - 1].dma_curp
+
+/**
+ * Generic Scatter Gather Element used by driver
+ */
+struct bfa_sge_s {
+	u32 sg_len;
+	void *sg_addr;
+};
+
+#define bfa_sge_to_be(__sge) do {                                          \
+	((u32 *)(__sge))[0] = bfa_os_htonl(((u32 *)(__sge))[0]);      \
+	((u32 *)(__sge))[1] = bfa_os_htonl(((u32 *)(__sge))[1]);      \
+	((u32 *)(__sge))[2] = bfa_os_htonl(((u32 *)(__sge))[2]);      \
+} while (0)
+
+
+/*
+ * bfa stats interfaces
+ */
+#define bfa_stats(_mod, _stats)	(_mod)->stats._stats ++
+
+#define bfa_ioc_get_stats(__bfa, __ioc_stats)	\
+	bfa_ioc_fetch_stats(&(__bfa)->ioc, __ioc_stats)
+#define bfa_ioc_clear_stats(__bfa)	\
+	bfa_ioc_clr_stats(&(__bfa)->ioc)
+
+/*
+ * bfa API functions
+ */
+void bfa_get_pciids(struct bfa_pciid_s **pciids, int *npciids);
+void bfa_cfg_get_default(struct bfa_iocfc_cfg_s *cfg);
+void bfa_cfg_get_min(struct bfa_iocfc_cfg_s *cfg);
+void bfa_cfg_get_meminfo(struct bfa_iocfc_cfg_s *cfg,
+			 struct bfa_meminfo_s *meminfo);
+void bfa_attach(struct bfa_s *bfa, void *bfad, struct bfa_iocfc_cfg_s *cfg,
+		struct bfa_meminfo_s *meminfo, struct bfa_pcidev_s *pcidev);
+void bfa_init_trc(struct bfa_s *bfa, struct bfa_trc_mod_s *trcmod);
+void bfa_init_log(struct bfa_s *bfa, struct bfa_log_mod_s *logmod);
+void bfa_init_aen(struct bfa_s *bfa, struct bfa_aen_s *aen);
+void bfa_init_plog(struct bfa_s *bfa, struct bfa_plog_s *plog);
+void bfa_detach(struct bfa_s *bfa);
+void bfa_init(struct bfa_s *bfa);
+void bfa_start(struct bfa_s *bfa);
+void bfa_stop(struct bfa_s *bfa);
+void bfa_attach_fcs(struct bfa_s *bfa);
+void bfa_cb_init(void *bfad, bfa_status_t status);
+void bfa_cb_stop(void *bfad, bfa_status_t status);
+void bfa_cb_updateq(void *bfad, bfa_status_t status);
+
+bfa_boolean_t bfa_intx(struct bfa_s *bfa);
+void bfa_isr_enable(struct bfa_s *bfa);
+void bfa_isr_disable(struct bfa_s *bfa);
+void bfa_msix_getvecs(struct bfa_s *bfa, u32 * msix_vecs_bmap,
+		      u32 * num_vecs, u32 * max_vec_bit);
+#define bfa_msix(__bfa, __vec) (__bfa)->msix.handler[__vec](__bfa, __vec)
+
+void bfa_comp_deq(struct bfa_s *bfa, struct list_head *comp_q);
+void bfa_comp_process(struct bfa_s *bfa, struct list_head *comp_q);
+void bfa_comp_free(struct bfa_s *bfa, struct list_head *comp_q);
+
+typedef void (*bfa_cb_ioc_t) (void *cbarg, enum bfa_status status);
+void bfa_iocfc_get_attr(struct bfa_s *bfa, struct bfa_iocfc_attr_s *attr);
+bfa_status_t bfa_iocfc_get_stats(struct bfa_s *bfa,
+				 struct bfa_iocfc_stats_s *stats,
+				 bfa_cb_ioc_t cbfn, void *cbarg);
+bfa_status_t bfa_iocfc_clear_stats(struct bfa_s *bfa,
+				   bfa_cb_ioc_t cbfn, void *cbarg);
+void bfa_get_attr(struct bfa_s *bfa, struct bfa_ioc_attr_s *ioc_attr);
+
+void bfa_adapter_get_attr(struct bfa_s *bfa,
+			  struct bfa_adapter_attr_s *ad_attr);
+u64 bfa_adapter_get_id(struct bfa_s *bfa);
+
+bfa_status_t bfa_iocfc_israttr_set(struct bfa_s *bfa,
+				   struct bfa_iocfc_intr_attr_s *attr);
+
+void bfa_iocfc_enable(struct bfa_s *bfa);
+void bfa_iocfc_disable(struct bfa_s *bfa);
+void bfa_ioc_auto_recover(bfa_boolean_t auto_recover);
+void bfa_cb_ioc_disable(void *bfad);
+void bfa_timer_tick(struct bfa_s *bfa);
+#define bfa_timer_start(_bfa, _timer, _timercb, _arg, _timeout)	\
+	bfa_timer_begin(&(_bfa)->timer_mod, _timer, _timercb, _arg, _timeout)
+
+/*
+ * BFA debug API functions
+ */
+bfa_status_t bfa_debug_fwtrc(struct bfa_s *bfa, void *trcdata, int *trclen);
+bfa_status_t bfa_debug_fwsave(struct bfa_s *bfa, void *trcdata, int *trclen);
+
+#include "bfa_priv.h"
+
+#endif /* __BFA_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_log_module.c linux-2.6.30.5-mod/drivers/net/bna/bfa_log_module.c
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_log_module.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_log_module.c	2009-08-28 21:09:23.272882000 -0700
@@ -0,0 +1,491 @@
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
+#include <cs/bfa_log.h>
+#include <aen/bfa_aen_adapter.h>
+#include <aen/bfa_aen_audit.h>
+#include <aen/bfa_aen_ethport.h>
+#include <aen/bfa_aen_ioc.h>
+#include <aen/bfa_aen_itnim.h>
+#include <aen/bfa_aen_lport.h>
+#include <aen/bfa_aen_port.h>
+#include <aen/bfa_aen_rport.h>
+#include <log/bfa_log_fcs.h>
+#include <log/bfa_log_hal.h>
+#include <log/bfa_log_linux.h>
+#include <log/bfa_log_wdrv.h>
+
+struct bfa_log_msgdef_s bfa_log_msg_array[] = {
+
+
+/* messages define for BFA_AEN_CAT_ADAPTER Module */
+	{BFA_AEN_ADAPTER_ADD, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_ADAPTER_ADD",
+	 "New adapter found: SN = %s, base port WWN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_ADAPTER_REMOVE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_WARNING, "BFA_AEN_ADAPTER_REMOVE",
+	 "Adapter removed: SN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+
+
+
+/* messages define for BFA_AEN_CAT_AUDIT Module */
+	{BFA_AEN_AUDIT_AUTH_ENABLE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "BFA_AEN_AUDIT_AUTH_ENABLE",
+	 "Authentication enabled for base port: WWN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_AUDIT_AUTH_DISABLE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "BFA_AEN_AUDIT_AUTH_DISABLE",
+	 "Authentication disabled for base port: WWN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+
+
+
+/* messages define for BFA_AEN_CAT_ETHPORT Module */
+	{BFA_AEN_ETHPORT_LINKUP, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_ETHPORT_LINKUP",
+	 "Base port ethernet linkup: mac = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_ETHPORT_LINKDOWN, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_ETHPORT_LINKDOWN",
+	 "Base port ethernet linkdown: mac = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_ETHPORT_ENABLE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_ETHPORT_ENABLE",
+	 "Base port ethernet interface enabled: mac = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_ETHPORT_DISABLE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_ETHPORT_DISABLE",
+	 "Base port ethernet interface disabled: mac = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+
+
+
+/* messages define for BFA_AEN_CAT_IOC Module */
+	{BFA_AEN_IOC_HBGOOD, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG, BFA_LOG_INFO,
+	 "BFA_AEN_IOC_HBGOOD",
+	 "Heart Beat of IOC %d is good.",
+	 ((BFA_LOG_D << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_IOC_HBFAIL, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_CRITICAL,
+	 "BFA_AEN_IOC_HBFAIL",
+	 "Heart Beat of IOC %d has failed.",
+	 ((BFA_LOG_D << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_IOC_ENABLE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG, BFA_LOG_INFO,
+	 "BFA_AEN_IOC_ENABLE",
+	 "IOC %d is enabled.",
+	 ((BFA_LOG_D << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_IOC_DISABLE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_IOC_DISABLE",
+	 "IOC %d is disabled.",
+	 ((BFA_LOG_D << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_IOC_FWMISMATCH, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_CRITICAL, "BFA_AEN_IOC_FWMISMATCH",
+	 "Running firmware version is incompatible with the driver version.",
+	 (0), 0},
+
+
+
+
+/* messages define for BFA_AEN_CAT_ITNIM Module */
+	{BFA_AEN_ITNIM_ONLINE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_ITNIM_ONLINE",
+	 "Target (WWN = %s) is online for initiator (WWN = %s).",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_ITNIM_OFFLINE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_ITNIM_OFFLINE",
+	 "Target (WWN = %s) offlined by initiator (WWN = %s).",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_ITNIM_DISCONNECT, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_ERROR, "BFA_AEN_ITNIM_DISCONNECT",
+	 "Target (WWN = %s) connectivity lost for initiator (WWN = %s).",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+
+
+
+/* messages define for BFA_AEN_CAT_LPORT Module */
+	{BFA_AEN_LPORT_NEW, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG, BFA_LOG_INFO,
+	 "BFA_AEN_LPORT_NEW",
+	 "New logical port created: WWN = %s, Role = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_LPORT_DELETE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_LPORT_DELETE",
+	 "Logical port deleted: WWN = %s, Role = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_LPORT_ONLINE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_LPORT_ONLINE",
+	 "Logical port online: WWN = %s, Role = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_LPORT_OFFLINE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_LPORT_OFFLINE",
+	 "Logical port taken offline: WWN = %s, Role = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_LPORT_DISCONNECT, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_ERROR, "BFA_AEN_LPORT_DISCONNECT",
+	 "Logical port lost fabric connectivity: WWN = %s, Role = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_LPORT_NEW_PROP, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_LPORT_NEW_PROP",
+	 "New virtual port created using proprietary interface: WWN = %s, Role = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_LPORT_DELETE_PROP, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "BFA_AEN_LPORT_DELETE_PROP",
+	 "Virtual port deleted using proprietary interface: WWN = %s, Role = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_LPORT_NEW_STANDARD, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "BFA_AEN_LPORT_NEW_STANDARD",
+	 "New virtual port created using standard interface: WWN = %s, Role = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_LPORT_DELETE_STANDARD, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "BFA_AEN_LPORT_DELETE_STANDARD",
+	 "Virtual port deleted using standard interface: WWN = %s, Role = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_LPORT_NPIV_DUP_WWN, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_WARNING, "BFA_AEN_LPORT_NPIV_DUP_WWN",
+	 "Virtual port login failed. Duplicate WWN = %s reported by fabric.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_LPORT_NPIV_FABRIC_MAX, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_WARNING, "BFA_AEN_LPORT_NPIV_FABRIC_MAX",
+	 "Virtual port (WWN = %s) login failed. Max NPIV ports already exist in"
+	 " fabric/fport.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_LPORT_NPIV_UNKNOWN, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_WARNING, "BFA_AEN_LPORT_NPIV_UNKNOWN",
+	 "Virtual port (WWN = %s) login failed.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+
+
+
+/* messages define for BFA_AEN_CAT_PORT Module */
+	{BFA_AEN_PORT_ONLINE, BFA_LOG_ATTR_NONE, BFA_LOG_INFO,
+	 "BFA_AEN_PORT_ONLINE",
+	 "Base port online: WWN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_PORT_OFFLINE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_WARNING,
+	 "BFA_AEN_PORT_OFFLINE",
+	 "Base port offline: WWN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_PORT_RLIR, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG, BFA_LOG_INFO,
+	 "BFA_AEN_PORT_RLIR",
+	 "RLIR event not supported.",
+	 (0), 0},
+
+	{BFA_AEN_PORT_SFP_INSERT, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_PORT_SFP_INSERT",
+	 "New SFP found: WWN/MAC = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_PORT_SFP_REMOVE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_WARNING, "BFA_AEN_PORT_SFP_REMOVE",
+	 "SFP removed: WWN/MAC = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_PORT_SFP_POM, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_WARNING,
+	 "BFA_AEN_PORT_SFP_POM",
+	 "SFP POM level to %s: WWN/MAC = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_PORT_ENABLE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_PORT_ENABLE",
+	 "Base port enabled: WWN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_PORT_DISABLE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_PORT_DISABLE",
+	 "Base port disabled: WWN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_PORT_AUTH_ON, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_PORT_AUTH_ON",
+	 "Authentication successful for base port: WWN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_PORT_AUTH_OFF, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_ERROR,
+	 "BFA_AEN_PORT_AUTH_OFF",
+	 "Authentication unsuccessful for base port: WWN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_PORT_DISCONNECT, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_ERROR,
+	 "BFA_AEN_PORT_DISCONNECT",
+	 "Base port (WWN = %s) lost fabric connectivity.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_PORT_QOS_NEG, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_WARNING,
+	 "BFA_AEN_PORT_QOS_NEG",
+	 "QOS negotiation failed for base port: WWN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_PORT_FABRIC_NAME_CHANGE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_WARNING, "BFA_AEN_PORT_FABRIC_NAME_CHANGE",
+	 "Base port WWN = %s, Fabric WWN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_PORT_SFP_ACCESS_ERROR, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_WARNING, "BFA_AEN_PORT_SFP_ACCESS_ERROR",
+	 "SFP access error: WWN/MAC = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_AEN_PORT_SFP_UNSUPPORT, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_WARNING, "BFA_AEN_PORT_SFP_UNSUPPORT",
+	 "Unsupported SFP found: WWN/MAC = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+
+
+
+/* messages define for BFA_AEN_CAT_RPORT Module */
+	{BFA_AEN_RPORT_ONLINE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_RPORT_ONLINE",
+	 "Remote port (WWN = %s) online for logical port (WWN = %s).",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_RPORT_OFFLINE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_RPORT_OFFLINE",
+	 "Remote port (WWN = %s) offlined by logical port (WWN = %s).",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_RPORT_DISCONNECT, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_ERROR, "BFA_AEN_RPORT_DISCONNECT",
+	 "Remote port (WWN = %s) connectivity lost for logical port (WWN = %s).",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) | 0), 2},
+
+	{BFA_AEN_RPORT_QOS_PRIO, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_RPORT_QOS_PRIO",
+	 "QOS priority changed to %s: RPWWN = %s and LPWWN = %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) |
+	  (BFA_LOG_S << BFA_LOG_ARG2) | 0), 3},
+
+	{BFA_AEN_RPORT_QOS_FLOWID, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "BFA_AEN_RPORT_QOS_FLOWID",
+	 "QOS flow ID changed to %d: RPWWN = %s and LPWWN = %s.",
+	 ((BFA_LOG_D << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) |
+	  (BFA_LOG_S << BFA_LOG_ARG2) | 0), 3},
+
+
+
+
+/* messages define for FCS Module */
+	{BFA_LOG_FCS_FABRIC_NOSWITCH, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "FCS_FABRIC_NOSWITCH",
+	 "No switched fabric presence is detected.",
+	 (0), 0},
+
+	{BFA_LOG_FCS_FABRIC_ISOLATED, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "FCS_FABRIC_ISOLATED",
+	 "Port is isolated due to VF_ID mismatch. PWWN: %s, Port VF_ID: %04x and"
+	 " switch port VF_ID: %04x.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_X << BFA_LOG_ARG1) |
+	  (BFA_LOG_X << BFA_LOG_ARG2) | 0), 3},
+
+
+
+
+/* messages define for HAL Module */
+	{BFA_LOG_HAL_ASSERT, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_ERROR,
+	 "HAL_ASSERT",
+	 "Assertion failure: %s:%d: %s",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_D << BFA_LOG_ARG1) |
+	  (BFA_LOG_S << BFA_LOG_ARG2) | 0), 3},
+
+	{BFA_LOG_HAL_HEARTBEAT_FAILURE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_CRITICAL, "HAL_HEARTBEAT_FAILURE",
+	 "Firmware heartbeat failure at %d",
+	 ((BFA_LOG_D << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_LOG_HAL_FCPIM_PARM_INVALID, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "HAL_FCPIM_PARM_INVALID",
+	 "Driver configuration %s value %d is invalid. Value should be within"
+	 " %d and %d.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_D << BFA_LOG_ARG1) |
+	  (BFA_LOG_D << BFA_LOG_ARG2) | (BFA_LOG_D << BFA_LOG_ARG3) | 0), 4},
+
+	{BFA_LOG_HAL_SM_ASSERT, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_ERROR,
+	 "HAL_SM_ASSERT",
+	 "SM Assertion failure: %s:%d: event = %d",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | (BFA_LOG_D << BFA_LOG_ARG1) |
+	  (BFA_LOG_D << BFA_LOG_ARG2) | 0), 3},
+
+
+
+
+/* messages define for LINUX Module */
+	{BFA_LOG_LINUX_DEVICE_CLAIMED, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "LINUX_DEVICE_CLAIMED",
+	 "bfa device at %s claimed.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_LOG_LINUX_HASH_INIT_FAILED, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "LINUX_HASH_INIT_FAILED",
+	 "Hash table initialization failure for the port %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_LOG_LINUX_SYSFS_FAILED, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "LINUX_SYSFS_FAILED",
+	 "sysfs file creation failure for the port %s.",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_LOG_LINUX_MEM_ALLOC_FAILED, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "LINUX_MEM_ALLOC_FAILED",
+	 "Memory allocation failed: %s.  ",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_LOG_LINUX_DRIVER_REGISTRATION_FAILED,
+	 BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG, BFA_LOG_INFO,
+	 "LINUX_DRIVER_REGISTRATION_FAILED",
+	 "%s.  ",
+	 ((BFA_LOG_S << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_LOG_LINUX_ITNIM_FREE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "LINUX_ITNIM_FREE",
+	 "scsi%d: FCID: %s WWPN: %s",
+	 ((BFA_LOG_D << BFA_LOG_ARG0) | (BFA_LOG_S << BFA_LOG_ARG1) |
+	  (BFA_LOG_S << BFA_LOG_ARG2) | 0), 3},
+
+	{BFA_LOG_LINUX_ITNIM_ONLINE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "LINUX_ITNIM_ONLINE",
+	 "Target: %d:0:%d FCID: %s WWPN: %s",
+	 ((BFA_LOG_D << BFA_LOG_ARG0) | (BFA_LOG_D << BFA_LOG_ARG1) |
+	  (BFA_LOG_S << BFA_LOG_ARG2) | (BFA_LOG_S << BFA_LOG_ARG3) | 0), 4},
+
+	{BFA_LOG_LINUX_ITNIM_OFFLINE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "LINUX_ITNIM_OFFLINE",
+	 "Target: %d:0:%d FCID: %s WWPN: %s",
+	 ((BFA_LOG_D << BFA_LOG_ARG0) | (BFA_LOG_D << BFA_LOG_ARG1) |
+	  (BFA_LOG_S << BFA_LOG_ARG2) | (BFA_LOG_S << BFA_LOG_ARG3) | 0), 4},
+
+	{BFA_LOG_LINUX_SCSI_HOST_FREE, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "LINUX_SCSI_HOST_FREE",
+	 "Free scsi%d",
+	 ((BFA_LOG_D << BFA_LOG_ARG0) | 0), 1},
+
+	{BFA_LOG_LINUX_SCSI_ABORT, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO,
+	 "LINUX_SCSI_ABORT",
+	 "scsi%d: abort cmnd %p, iotag %x",
+	 ((BFA_LOG_D << BFA_LOG_ARG0) | (BFA_LOG_P << BFA_LOG_ARG1) |
+	  (BFA_LOG_X << BFA_LOG_ARG2) | 0), 3},
+
+	{BFA_LOG_LINUX_SCSI_ABORT_COMP, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "LINUX_SCSI_ABORT_COMP",
+	 "scsi%d: complete abort 0x%p, iotag 0x%x",
+	 ((BFA_LOG_D << BFA_LOG_ARG0) | (BFA_LOG_P << BFA_LOG_ARG1) |
+	  (BFA_LOG_X << BFA_LOG_ARG2) | 0), 3},
+
+
+
+
+/* messages define for WDRV Module */
+	{BFA_LOG_WDRV_IOC_INIT_ERROR, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "WDRV_IOC_INIT_ERROR",
+	 "IOC initialization has failed.",
+	 (0), 0},
+
+	{BFA_LOG_WDRV_IOC_INTERNAL_ERROR, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "WDRV_IOC_INTERNAL_ERROR",
+	 "IOC internal error.  ",
+	 (0), 0},
+
+	{BFA_LOG_WDRV_IOC_START_ERROR, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "WDRV_IOC_START_ERROR",
+	 "IOC could not be started.  ",
+	 (0), 0},
+
+	{BFA_LOG_WDRV_IOC_STOP_ERROR, BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "WDRV_IOC_STOP_ERROR",
+	 "IOC could not be stopped.  ",
+	 (0), 0},
+
+	{BFA_LOG_WDRV_INSUFFICIENT_RESOURCES,
+	 BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "WDRV_INSUFFICIENT_RESOURCES",
+	 "Insufficient memory.  ",
+	 (0), 0},
+
+	{BFA_LOG_WDRV_BASE_ADDRESS_MAP_ERROR,
+	 BFA_LOG_ATTR_NONE | BFA_LOG_ATTR_LOG,
+	 BFA_LOG_INFO, "WDRV_BASE_ADDRESS_MAP_ERROR",
+	 "Unable to map the IOC onto the system address space.  ",
+	 (0), 0},
+
+
+	{0, 0, 0, "", "", 0, 0},
+};
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_lps_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_lps_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_lps_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_lps_priv.h	2009-08-28 21:09:23.464891000 -0700
@@ -0,0 +1,45 @@
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
+#ifndef __BFA_LPS_PRIV_H__
+#define __BFA_LPS_PRIV_H__
+
+#include <bfa_svc.h>
+
+struct bfa_lps_mod_s {
+	struct list_head lps_free_q;
+	struct list_head lps_active_q;
+	struct bfa_lps_s *lps_arr;
+	int num_lps;
+};
+
+#define BFA_LPS_MOD(__bfa)		(&(__bfa)->modules.lps_mod)
+#define BFA_LPS_FROM_TAG(__mod, __tag)	(&(__mod)->lps_arr[__tag])
+
+/*
+ * external functions
+ */
+void bfa_lps_isr(struct bfa_s *bfa, struct bfi_msg_s *msg);
+
+#endif /* __BFA_LPS_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_modules_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_modules_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_modules_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_modules_priv.h	2009-08-28 21:09:23.115885000 -0700
@@ -0,0 +1,50 @@
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
+#ifndef __BFA_MODULES_PRIV_H__
+#define __BFA_MODULES_PRIV_H__
+
+#include "bfa_uf_priv.h"
+#include "bfa_port_priv.h"
+#include "bfa_rport_priv.h"
+#include "bfa_fcxp_priv.h"
+#include "bfa_lps_priv.h"
+#include "bfa_fcpim_priv.h"
+#include <cee/bfa_cee.h>
+#include <port/bfa_port.h>
+
+
+struct bfa_modules_s {
+	struct bfa_pport_s pport;	/*  physical port module        */
+	struct bfa_fcxp_mod_s fcxp_mod;	/*  fcxp module         */
+	struct bfa_lps_mod_s lps_mod;	/*  fcxp module         */
+	struct bfa_uf_mod_s uf_mod;	/*  unsolicited frame module    */
+	struct bfa_rport_mod_s rport_mod;	/*  remote port module        */
+	struct bfa_fcpim_mod_s fcpim_mod;	/*  FCP initiator module      */
+	struct bfa_sgpg_mod_s sgpg_mod;	/*  SG page module              */
+	struct bfa_cee_s cee;	/*  CEE Module                 */
+	struct bfa_port_s port;	/*  Physical port module        */
+};
+
+#endif /* __BFA_MODULES_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_os_inc.h linux-2.6.30.5-mod/drivers/net/bna/bfa_os_inc.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_os_inc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_os_inc.h	2009-08-28 21:09:23.074888000 -0700
@@ -0,0 +1,203 @@
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
+#include <scsi/scsi.h>
+#include <scsi/scsi_host.h>
+
+#include <scsi/scsi_tcq.h>
+#include <scsi/scsi_transport_fc.h>
+#include <scsi/scsi_transport.h>
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
+#define BFA_LOG_TRACE(bfad, level, mask, fmt, arg...)			\
+		BFA_LOG(bfad, level, mask, fmt, ## arg)
+#define BFA_DEV_TRACE(bfad, level, fmt, arg...)				\
+		BFA_DEV_PRINTF(bfad, level, fmt, ## arg)
+#define BFA_TRACE(level, fmt, arg...)					\
+		BFA_PRINTF(level, fmt, ## arg)
+#else
+#define BFA_LOG_TRACE(bfad, level, mask, fmt, arg...)
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
+#define BFA_LOG(bfad, level, mask, fmt, arg...)				\
+do { 									\
+	if (((mask) & (((struct bfad_s *)(bfad))->			\
+		cfg_data[cfg_log_mask])) || (level[1] <= '3'))		\
+		dev_printk(level, &(((struct bfad_s *)			\
+			(bfad))->pcidev->dev), fmt, ##arg);      \
+} while (0)
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
+struct bfa_log_mod_s;
+void bfa_os_printf(struct bfa_log_mod_s *log_mod, u32 msg_id,
+		   const char *fmt, ...);
+#endif
+
+#define boolean_t int
+
+/**
+ * For current time stamp, OS API will fill-in
+ */
+struct bfa_timeval_s {
+	u32 tv_sec;		/*  seconds        */
+	u32 tv_usec;		/*  microseconds   */
+};
+
+void bfa_os_gettimeofday(struct bfa_timeval_s *tv);
+
+#endif /* __BFA_OS_INC_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_priv.h	2009-08-28 21:09:23.510882000 -0700
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
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#ifndef __BFA_PRIV_H__
+#define __BFA_PRIV_H__
+
+#include "bfa_iocfc.h"
+#include "bfa_intr_priv.h"
+#include "bfa_trcmod_priv.h"
+#include "bfa_modules_priv.h"
+#include "bfa_fwimg_priv.h"
+#include <cs/bfa_log.h>
+#include <bfa_timer.h>
+
+/**
+ * Macro to define a new BFA module
+ */
+#define BFA_MODULE(__mod) 						\
+	static void bfa_ ## __mod ## _meminfo(				\
+			struct bfa_iocfc_cfg_s *cfg, u32 *ndm_len,	\
+			u32 *dm_len);      \
+	static void bfa_ ## __mod ## _attach(struct bfa_s *bfa,		\
+			void *bfad, struct bfa_iocfc_cfg_s *cfg, 	\
+			struct bfa_meminfo_s *meminfo,			\
+			struct bfa_pcidev_s *pcidev);      \
+	static void bfa_ ## __mod ## _initdone(struct bfa_s *bfa);      \
+	static void bfa_ ## __mod ## _detach(struct bfa_s *bfa);      \
+	static void bfa_ ## __mod ## _start(struct bfa_s *bfa);      \
+	static void bfa_ ## __mod ## _stop(struct bfa_s *bfa);      \
+	static void bfa_ ## __mod ## _iocdisable(struct bfa_s *bfa);      \
+									\
+	extern struct bfa_module_s hal_mod_ ## __mod;			\
+	struct bfa_module_s hal_mod_ ## __mod = {			\
+		bfa_ ## __mod ## _meminfo,				\
+		bfa_ ## __mod ## _attach,				\
+		bfa_ ## __mod ## _initdone,				\
+		bfa_ ## __mod ## _detach,				\
+		bfa_ ## __mod ## _start,				\
+		bfa_ ## __mod ## _stop,					\
+		bfa_ ## __mod ## _iocdisable,				\
+	}
+
+#define BFA_CACHELINE_SZ	(256)
+
+/**
+ * Structure used to interact between different BFA sub modules
+ *
+ * Each sub module needs to implement only the entry points relevant to it (and
+ * can leave entry points as NULL)
+ */
+struct bfa_module_s {
+	void (*meminfo) (struct bfa_iocfc_cfg_s * cfg, u32 * km_len,
+			 u32 * dm_len);
+	void (*attach) (struct bfa_s * bfa, void *bfad,
+			struct bfa_iocfc_cfg_s * cfg,
+			struct bfa_meminfo_s * meminfo,
+			struct bfa_pcidev_s * pcidev);
+	void (*initdone) (struct bfa_s * bfa);
+	void (*detach) (struct bfa_s * bfa);
+	void (*start) (struct bfa_s * bfa);
+	void (*stop) (struct bfa_s * bfa);
+	void (*iocdisable) (struct bfa_s * bfa);
+};
+
+extern struct bfa_module_s *hal_mods[];
+
+struct bfa_s {
+	void *bfad;		/*  BFA driver instance    */
+	struct bfa_aen_s *aen;	/*  AEN module              */
+	struct bfa_plog_s *plog;	/*  portlog buffer          */
+	struct bfa_log_mod_s *logm;	/*  driver logging modulen */
+	struct bfa_trc_mod_s *trcmod;	/*  driver tracing          */
+	struct bfa_ioc_s ioc;	/*  IOC module              */
+	struct bfa_iocfc_s iocfc;	/*  IOCFC module            */
+	struct bfa_timer_mod_s timer_mod;	/*  timer module            */
+	struct bfa_modules_s modules;	/*  BFA modules     */
+	struct list_head comp_q;	/*  pending completions    */
+	bfa_boolean_t rme_process;	/*  RME processing enabled */
+	struct list_head reqq_waitq[BFI_IOC_MAX_CQS];
+	bfa_boolean_t fcs;	/*  FCS is attached to BFA */
+	struct bfa_msix_s msix;
+};
+
+extern bfa_isr_func_t bfa_isrs[BFI_MC_MAX];
+extern bfa_ioc_mbox_mcfunc_t bfa_mbox_isrs[];
+extern bfa_boolean_t bfa_auto_recover;
+extern struct bfa_module_s hal_mod_flash;
+extern struct bfa_module_s hal_mod_fcdiag;
+extern struct bfa_module_s hal_mod_sgpg;
+extern struct bfa_module_s hal_mod_pport;
+extern struct bfa_module_s hal_mod_fcxp;
+extern struct bfa_module_s hal_mod_lps;
+extern struct bfa_module_s hal_mod_uf;
+extern struct bfa_module_s hal_mod_rport;
+extern struct bfa_module_s hal_mod_fcpim;
+extern struct bfa_module_s hal_mod_pbind;
+
+#endif /* __BFA_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_svc.h linux-2.6.30.5-mod/drivers/net/bna/bfa_svc.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_svc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_svc.h	2009-08-28 21:09:23.149900000 -0700
@@ -0,0 +1,328 @@
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
+#ifndef __BFA_SVC_H__
+#define __BFA_SVC_H__
+
+/*
+ * forward declarations
+ */
+struct bfa_fcxp_s;
+
+#include <defs/bfa_defs_status.h>
+#include <defs/bfa_defs_pport.h>
+#include <defs/bfa_defs_rport.h>
+#include <defs/bfa_defs_qos.h>
+#include <cs/bfa_sm.h>
+#include <bfa.h>
+
+/**
+ * 		BFA rport information.
+ */
+struct bfa_rport_info_s {
+	u16 max_frmsz;		/*  max rcv pdu size               */
+	u32 pid:24,		/*  remote port ID                 */
+	  lp_tag:8;
+	u32 local_pid:24,	/*  local port ID                   */
+	  cisc:8;		/*  CIRO supported                  */
+	u8 fc_class;		/*  supported FC classes. enum fc_cos */
+	u8 vf_en;		/*  virtual fabric enable          */
+	u16 vf_id;		/*  virtual fabric ID              */
+	enum bfa_pport_speed speed;	/*  Rport's current speed           */
+};
+
+/**
+ * BFA rport data structure
+ */
+struct bfa_rport_s {
+	struct list_head qe;	/*  queue element */
+	bfa_sm_t sm;		/*  state machine */
+	struct bfa_s *bfa;	/*  backpointer to BFA */
+	void *rport_drv;	/*  fcs/driver rport object */
+	u16 fw_handle;		/*  firmware rport handle */
+	u16 rport_tag;		/*  BFA rport tag */
+	struct bfa_rport_info_s rport_info;	/*  rport info from *fcs/driver */
+	struct bfa_reqq_wait_s reqq_wait;	/*  to wait for room in reqq */
+	struct bfa_cb_qe_s hcb_qe;	/*  BFA callback qelem */
+	struct bfa_rport_hal_stats_s stats;	/*  BFA rport statistics  */
+	struct bfa_rport_qos_attr_s qos_attr;
+	union a {
+		bfa_status_t status;	/*  f/w status */
+		void *fw_msg;	/*  QoS scn event */
+	} event_arg;
+};
+#define BFA_RPORT_FC_COS(_rport)	((_rport)->rport_info.fc_class)
+
+/**
+ * Send completion callback.
+ */
+typedef void (*bfa_cb_fcxp_send_t) (void *bfad_fcxp, struct bfa_fcxp_s * fcxp,
+				    void *cbarg, enum bfa_status req_status,
+				    u32 rsp_len, u32 resid_len,
+				    struct fchs_s * rsp_fchs);
+
+/**
+ * BFA fcxp allocation (asynchronous)
+ */
+typedef void (*bfa_fcxp_alloc_cbfn_t) (void *cbarg, struct bfa_fcxp_s * fcxp);
+
+struct bfa_fcxp_wqe_s {
+	struct list_head qe;
+	bfa_fcxp_alloc_cbfn_t alloc_cbfn;
+	void *alloc_cbarg;
+};
+
+typedef u64(*bfa_fcxp_get_sgaddr_t) (void *bfad_fcxp, int sgeid);
+typedef u32(*bfa_fcxp_get_sglen_t) (void *bfad_fcxp, int sgeid);
+
+#define BFA_UF_BUFSZ	(2 * 1024 + 256)
+
+/**
+ * @todo private
+ */
+struct bfa_uf_buf_s {
+	u8 d[BFA_UF_BUFSZ];
+};
+
+
+struct bfa_uf_s {
+	struct list_head qe;	/*  queue element         */
+	struct bfa_s *bfa;	/*  bfa instance          */
+	u16 uf_tag;		/*  identifying tag f/w messages */
+	u16 vf_id;
+	u16 src_rport_handle;
+	u16 rsvd;
+	u8 *data_ptr;
+	u16 data_len;		/*  actual receive length         */
+	u16 pb_len;		/*  posted buffer length          */
+	void *buf_kva;		/*  buffer virtual address        */
+	u64 buf_pa;		/*  buffer physical address       */
+	struct bfa_cb_qe_s hcb_qe;	/*  comp: BFA comp qelem          */
+	struct bfa_sge_s sges[BFI_SGE_INLINE_MAX];
+};
+
+typedef void (*bfa_cb_pport_t) (void *cbarg, enum bfa_status status);
+
+/**
+ * bfa lport login/logout service interface
+ */
+struct bfa_lps_s {
+	struct list_head qe;	/*  queue element */
+	struct bfa_s *bfa;	/*  parent bfa instance */
+	bfa_sm_t sm;		/*  finite state machine        */
+	u8 lp_tag;		/*  lport tag                   */
+	u8 reqq;		/*  lport request queue */
+	u8 alpa;		/*  ALPA for loop topologies    */
+	u32 lp_pid;		/*  lport port ID               */
+	bfa_boolean_t fdisc;	/*  send FDISC instead of FLOGI */
+	bfa_boolean_t auth_en;	/*  enable authentication       */
+	bfa_boolean_t auth_req;	/*  authentication required     */
+	bfa_boolean_t npiv_en;	/*  NPIV is allowed by peer     */
+	bfa_boolean_t fport;	/*  attached peer is F_PORT     */
+	bfa_boolean_t brcd_switch;	/*  attached peer is brcd switch    */
+	bfa_status_t status;	/*  login status                */
+	u16 pdusz;		/*  max receive PDU size        */
+	u16 pr_bbcred;		/*  BB_CREDIT from peer         */
+	u8 lsrjt_rsn;		/*  LSRJT reason                */
+	u8 lsrjt_expl;		/*  LSRJT explanation           */
+	wwn_t pwwn;		/*  port wwn of lport           */
+	wwn_t nwwn;		/*  node wwn of lport           */
+	wwn_t pr_pwwn;		/*  port wwn of lport peer      */
+	wwn_t pr_nwwn;		/*  node wwn of lport peer      */
+	mac_t lp_mac;		/*  fpma/spma MAC for lport     */
+	mac_t fcf_mac;		/*  FCF MAC of lport            */
+	struct bfa_reqq_wait_s wqe;	/*  request wait queue element  */
+	void *uarg;		/*  user callback arg           */
+	struct bfa_cb_qe_s hcb_qe;	/*  comp: callback qelem        */
+	struct bfi_lps_login_rsp_s *loginrsp;
+	bfa_eproto_status_t ext_status;
+};
+
+/*
+ * bfa pport API functions
+ */
+bfa_status_t bfa_pport_enable(struct bfa_s *bfa);
+bfa_status_t bfa_pport_disable(struct bfa_s *bfa);
+bfa_status_t bfa_pport_cfg_speed(struct bfa_s *bfa, enum bfa_pport_speed speed);
+enum bfa_pport_speed bfa_pport_get_speed(struct bfa_s *bfa);
+bfa_status_t bfa_pport_cfg_topology(struct bfa_s *bfa,
+				    enum bfa_pport_topology topo);
+enum bfa_pport_topology bfa_pport_get_topology(struct bfa_s *bfa);
+bfa_status_t bfa_pport_cfg_hardalpa(struct bfa_s *bfa, u8 alpa);
+bfa_boolean_t bfa_pport_get_hardalpa(struct bfa_s *bfa, u8 * alpa);
+u8 bfa_pport_get_myalpa(struct bfa_s *bfa);
+bfa_status_t bfa_pport_clr_hardalpa(struct bfa_s *bfa);
+bfa_status_t bfa_pport_cfg_maxfrsize(struct bfa_s *bfa, u16 maxsize);
+u16 bfa_pport_get_maxfrsize(struct bfa_s *bfa);
+u32 bfa_pport_mypid(struct bfa_s *bfa);
+u8 bfa_pport_get_rx_bbcredit(struct bfa_s *bfa);
+bfa_status_t bfa_pport_trunk_enable(struct bfa_s *bfa, u8 bitmap);
+bfa_status_t bfa_pport_trunk_disable(struct bfa_s *bfa);
+bfa_boolean_t bfa_pport_trunk_query(struct bfa_s *bfa, u32 * bitmap);
+void bfa_pport_get_attr(struct bfa_s *bfa, struct bfa_pport_attr_s *attr);
+wwn_t bfa_pport_get_wwn(struct bfa_s *bfa, bfa_boolean_t node);
+bfa_status_t bfa_pport_get_stats(struct bfa_s *bfa,
+				 union bfa_pport_stats_u *stats,
+				 bfa_cb_pport_t cbfn, void *cbarg);
+bfa_status_t bfa_pport_clear_stats(struct bfa_s *bfa, bfa_cb_pport_t cbfn,
+				   void *cbarg);
+void bfa_pport_event_register(struct bfa_s *bfa,
+			      void (*event_cbfn) (void *cbarg,
+						  bfa_pport_event_t event),
+			      void *event_cbarg);
+bfa_boolean_t bfa_pport_is_disabled(struct bfa_s *bfa);
+void bfa_pport_cfg_qos(struct bfa_s *bfa, bfa_boolean_t on_off);
+void bfa_pport_cfg_ratelim(struct bfa_s *bfa, bfa_boolean_t on_off);
+bfa_status_t bfa_pport_cfg_ratelim_speed(struct bfa_s *bfa,
+					 enum bfa_pport_speed speed);
+enum bfa_pport_speed bfa_pport_get_ratelim_speed(struct bfa_s *bfa);
+
+void bfa_pport_set_tx_bbcredit(struct bfa_s *bfa, u16 tx_bbcredit);
+void bfa_pport_busy(struct bfa_s *bfa, bfa_boolean_t status);
+void bfa_pport_beacon(struct bfa_s *bfa, bfa_boolean_t beacon,
+		      bfa_boolean_t link_e2e_beacon);
+void bfa_cb_pport_event(void *cbarg, bfa_pport_event_t event);
+void bfa_pport_qos_get_attr(struct bfa_s *bfa, struct bfa_qos_attr_s *qos_attr);
+void bfa_pport_qos_get_vc_attr(struct bfa_s *bfa,
+			       struct bfa_qos_vc_attr_s *qos_vc_attr);
+bfa_status_t bfa_pport_get_qos_stats(struct bfa_s *bfa,
+				     union bfa_pport_stats_u *stats,
+				     bfa_cb_pport_t cbfn, void *cbarg);
+bfa_status_t bfa_pport_clear_qos_stats(struct bfa_s *bfa, bfa_cb_pport_t cbfn,
+				       void *cbarg);
+bfa_boolean_t bfa_pport_is_ratelim(struct bfa_s *bfa);
+bfa_boolean_t bfa_pport_is_linkup(struct bfa_s *bfa);
+
+/*
+ * bfa rport API functions
+ */
+struct bfa_rport_s *bfa_rport_create(struct bfa_s *bfa, void *rport_drv);
+void bfa_rport_delete(struct bfa_rport_s *rport);
+void bfa_rport_online(struct bfa_rport_s *rport,
+		      struct bfa_rport_info_s *rport_info);
+void bfa_rport_offline(struct bfa_rport_s *rport);
+void bfa_rport_speed(struct bfa_rport_s *rport, enum bfa_pport_speed speed);
+void bfa_rport_get_stats(struct bfa_rport_s *rport,
+			 struct bfa_rport_hal_stats_s *stats);
+void bfa_rport_clear_stats(struct bfa_rport_s *rport);
+void bfa_cb_rport_online(void *rport);
+void bfa_cb_rport_offline(void *rport);
+void bfa_cb_rport_qos_scn_flowid(void *rport,
+				 struct bfa_rport_qos_attr_s old_qos_attr,
+				 struct bfa_rport_qos_attr_s new_qos_attr);
+void bfa_cb_rport_qos_scn_prio(void *rport,
+			       struct bfa_rport_qos_attr_s old_qos_attr,
+			       struct bfa_rport_qos_attr_s new_qos_attr);
+void bfa_rport_get_qos_attr(struct bfa_rport_s *rport,
+			    struct bfa_rport_qos_attr_s *qos_attr);
+
+/*
+ * bfa fcxp API functions
+ */
+struct bfa_fcxp_s *bfa_fcxp_alloc(void *bfad_fcxp, struct bfa_s *bfa,
+				  int nreq_sgles, int nrsp_sgles,
+				  bfa_fcxp_get_sgaddr_t get_req_sga,
+				  bfa_fcxp_get_sglen_t get_req_sglen,
+				  bfa_fcxp_get_sgaddr_t get_rsp_sga,
+				  bfa_fcxp_get_sglen_t get_rsp_sglen);
+void bfa_fcxp_alloc_wait(struct bfa_s *bfa, struct bfa_fcxp_wqe_s *wqe,
+			 bfa_fcxp_alloc_cbfn_t alloc_cbfn, void *cbarg);
+void bfa_fcxp_walloc_cancel(struct bfa_s *bfa, struct bfa_fcxp_wqe_s *wqe);
+void bfa_fcxp_discard(struct bfa_fcxp_s *fcxp);
+
+void *bfa_fcxp_get_reqbuf(struct bfa_fcxp_s *fcxp);
+void *bfa_fcxp_get_rspbuf(struct bfa_fcxp_s *fcxp);
+
+void bfa_fcxp_free(struct bfa_fcxp_s *fcxp);
+
+void bfa_fcxp_send(struct bfa_fcxp_s *fcxp,
+		   struct bfa_rport_s *rport, u16 vf_id, u8 lp_tag,
+		   bfa_boolean_t cts, enum fc_cos cos,
+		   u32 reqlen, struct fchs_s *fchs,
+		   bfa_cb_fcxp_send_t cbfn,
+		   void *cbarg, u32 rsp_maxlen, u8 rsp_timeout);
+bfa_status_t bfa_fcxp_abort(struct bfa_fcxp_s *fcxp);
+u32 bfa_fcxp_get_reqbufsz(struct bfa_fcxp_s *fcxp);
+u32 bfa_fcxp_get_maxrsp(struct bfa_s *bfa);
+
+static inline void *
+bfa_uf_get_frmbuf(struct bfa_uf_s *uf)
+{
+	return uf->data_ptr;
+}
+
+static inline u16
+bfa_uf_get_frmlen(struct bfa_uf_s *uf)
+{
+	return uf->data_len;
+}
+
+/**
+ *      Callback prototype for unsolicited frame receive handler.
+ *
+ * @param[in]           cbarg           callback arg for receive handler
+ * @param[in]           uf              unsolicited frame descriptor
+ *
+ * @return None
+ */
+typedef void (*bfa_cb_uf_recv_t) (void *cbarg, struct bfa_uf_s * uf);
+
+/*
+ * bfa uf API functions
+ */
+void bfa_uf_recv_register(struct bfa_s *bfa, bfa_cb_uf_recv_t ufrecv,
+			  void *cbarg);
+void bfa_uf_free(struct bfa_uf_s *uf);
+
+/**
+ * bfa lport service api
+ */
+
+struct bfa_lps_s *bfa_lps_alloc(struct bfa_s *bfa);
+void bfa_lps_delete(struct bfa_lps_s *lps);
+void bfa_lps_discard(struct bfa_lps_s *lps);
+void bfa_lps_flogi(struct bfa_lps_s *lps, void *uarg, u8 alpa, u16 pdusz,
+		   wwn_t pwwn, wwn_t nwwn, bfa_boolean_t auth_en);
+void bfa_lps_fdisc(struct bfa_lps_s *lps, void *uarg, u16 pdusz, wwn_t pwwn,
+		   wwn_t nwwn);
+void bfa_lps_flogo(struct bfa_lps_s *lps);
+void bfa_lps_fdisclogo(struct bfa_lps_s *lps);
+u8 bfa_lps_get_tag(struct bfa_lps_s *lps);
+bfa_boolean_t bfa_lps_is_npiv_en(struct bfa_lps_s *lps);
+bfa_boolean_t bfa_lps_is_fport(struct bfa_lps_s *lps);
+bfa_boolean_t bfa_lps_is_brcd_fabric(struct bfa_lps_s *lps);
+bfa_boolean_t bfa_lps_is_authreq(struct bfa_lps_s *lps);
+bfa_eproto_status_t bfa_lps_get_extstatus(struct bfa_lps_s *lps);
+u32 bfa_lps_get_pid(struct bfa_lps_s *lps);
+u8 bfa_lps_get_tag_from_pid(struct bfa_s *bfa, u32 pid);
+u16 bfa_lps_get_peer_bbcredit(struct bfa_lps_s *lps);
+wwn_t bfa_lps_get_peer_pwwn(struct bfa_lps_s *lps);
+wwn_t bfa_lps_get_peer_nwwn(struct bfa_lps_s *lps);
+u8 bfa_lps_get_lsrjt_rsn(struct bfa_lps_s *lps);
+u8 bfa_lps_get_lsrjt_expl(struct bfa_lps_s *lps);
+void bfa_cb_lps_flogi_comp(void *bfad, void *uarg, bfa_status_t status);
+void bfa_cb_lps_flogo_comp(void *bfad, void *uarg);
+void bfa_cb_lps_fdisc_comp(void *bfad, void *uarg, bfa_status_t status);
+void bfa_cb_lps_fdisclogo_comp(void *bfad, void *uarg);
+
+#endif /* __BFA_SVC_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_timer.c linux-2.6.30.5-mod/drivers/net/bna/bfa_timer.c
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_timer.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_timer.c	2009-08-28 21:09:23.328884000 -0700
@@ -0,0 +1,97 @@
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
+#include <bfa_timer.h>
+#include <cs/bfa_debug.h>
+
+void
+bfa_timer_init(struct bfa_timer_mod_s *mod)
+{
+	INIT_LIST_HEAD(&mod->timer_q);
+}
+
+void
+bfa_timer_beat(struct bfa_timer_mod_s *mod)
+{
+	struct list_head *qh = &mod->timer_q;
+	struct list_head *qe, *qe_next;
+	struct bfa_timer_s *elem;
+	struct list_head timedout_q;
+
+	INIT_LIST_HEAD(&timedout_q);
+
+	qe = bfa_q_next(qh);
+
+	while (qe != qh) {
+		qe_next = bfa_q_next(qe);
+
+		elem = (struct bfa_timer_s *) qe;
+		if (elem->timeout <= BFA_TIMER_FREQ) {
+			elem->timeout = 0;
+			list_del(&elem->qe);
+			list_add_tail(&elem->qe, &timedout_q);
+		} else {
+			elem->timeout -= BFA_TIMER_FREQ;
+		}
+
+		qe = qe_next;	/* go to next elem */
+	}
+
+	/*
+	 * Pop all the timeout entries
+	 */
+	while (!list_empty(&timedout_q)) {
+		bfa_q_deq(&timedout_q, &elem);
+		elem->timercb(elem->arg);
+	}
+}
+
+/**
+ * Should be called with lock protection
+ */
+void
+bfa_timer_begin(struct bfa_timer_mod_s *mod, struct bfa_timer_s *timer,
+		void (*timercb) (void *), void *arg, unsigned int timeout)
+{
+
+	bfa_assert(timercb != NULL);
+	bfa_assert(!bfa_q_is_on_q(&mod->timer_q, timer));
+
+	timer->timeout = timeout;
+	timer->timercb = timercb;
+	timer->arg = arg;
+
+	list_add_tail(&timer->qe, &mod->timer_q);
+}
+
+/**
+ * Should be called with lock protection
+ */
+void
+bfa_timer_stop(struct bfa_timer_s *timer)
+{
+	bfa_assert(!list_empty(&timer->qe));
+
+	list_del(&timer->qe);
+}
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bfa_trcmod_priv.h linux-2.6.30.5-mod/drivers/net/bna/bfa_trcmod_priv.h
--- linux-2.6.30.5-orig/drivers/net/bna/bfa_trcmod_priv.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bfa_trcmod_priv.h	2009-08-28 21:09:23.378890000 -0700
@@ -0,0 +1,73 @@
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
+ *  hal_trcmod.h BFA trace modules
+ */
+
+#ifndef __BFA_TRCMOD_PRIV_H__
+#define __BFA_TRCMOD_PRIV_H__
+
+#include <cs/bfa_trc.h>
+
+/*
+ * !!! Only append to the enums defined here to avoid any versioning
+ * !!! needed between trace utility and driver version
+ */
+enum {
+	BFA_TRC_HAL_IOC = 1,
+	BFA_TRC_HAL_INTR = 2,
+	BFA_TRC_HAL_FCXP = 3,
+	BFA_TRC_HAL_UF = 4,
+	BFA_TRC_HAL_DIAG = 5,
+	BFA_TRC_HAL_RPORT = 6,
+	BFA_TRC_HAL_FCPIM = 7,
+	BFA_TRC_HAL_IOIM = 8,
+	BFA_TRC_HAL_TSKIM = 9,
+	BFA_TRC_HAL_ITNIM = 10,
+	BFA_TRC_HAL_PPORT = 11,
+	BFA_TRC_HAL_SGPG = 12,
+	BFA_TRC_HAL_FLASH = 13,
+	BFA_TRC_HAL_DEBUG = 14,
+	BFA_TRC_HAL_WWN = 15,
+	BFA_TRC_HAL_FLASH_RAW = 16,
+	BFA_TRC_HAL_SBOOT = 17,
+	BFA_TRC_HAL_SBOOT_IO = 18,
+	BFA_TRC_HAL_SBOOT_INTR = 19,
+	BFA_TRC_HAL_SBTEST = 20,
+	BFA_TRC_HAL_IPFC = 21,
+	BFA_TRC_HAL_IOCFC = 22,
+	BFA_TRC_HAL_FCPTM = 23,
+	BFA_TRC_HAL_IOTM = 24,
+	BFA_TRC_HAL_TSKTM = 25,
+	BFA_TRC_HAL_TIN = 26,
+	BFA_TRC_HAL_LPS = 27,
+	BFA_TRC_HAL_FCDIAG = 28,
+	BFA_TRC_HAL_PBIND = 29,
+	BFA_TRC_HAL_IOCFC_CT = 30,
+	BFA_TRC_HAL_IOCFC_CB = 31,
+	BFA_TRC_HAL_IOCFC_Q = 32,
+};
+
+#endif /* __BFA_TRCMOD_PRIV_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bnad_defs.h linux-2.6.30.5-mod/drivers/net/bna/bnad_defs.h
--- linux-2.6.30.5-orig/drivers/net/bna/bnad_defs.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bnad_defs.h	2009-08-28 21:09:23.297891000 -0700
@@ -0,0 +1,36 @@
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
+ */
+
+#ifndef _BNAD_DEFS_H_
+#define _BNAD_DEFS_H_
+
+#define BNAD_NAME	"bna"
+#define BNAD_VERSION	"2.0.0.0"
+
+#ifndef PCI_VENDOR_ID_BROCADE
+#define PCI_VENDOR_ID_BROCADE	0x1657
+#endif
+
+#ifndef PCI_DEVICE_ID_BROCADE_CATAPULT
+#define PCI_DEVICE_ID_BROCADE_CATAPULT	0x0014
+#endif
+
+#endif /* _BNAD_DEFS_H_ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bnad_ethtool.c linux-2.6.30.5-mod/drivers/net/bna/bnad_ethtool.c
--- linux-2.6.30.5-orig/drivers/net/bna/bnad_ethtool.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bnad_ethtool.c	2009-08-28 21:09:23.361884000 -0700
@@ -0,0 +1,1316 @@
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
+ */
+
+/**
+ *  bna_ethtool.c  Brocade 10G PCIe Ethernet driver.
+ */
+
+#include <linux/types.h>
+#include <linux/ethtool.h>
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+#include <linux/interrupt.h>
+#include <linux/skbuff.h>
+#include <linux/if_ether.h>
+#ifdef __ESX_COS__
+#include <asm/uaccess.h>	/* copy_from_user(), copy_to_user() */
+#endif
+#ifndef __VMKERNEL_MODULE__
+#include <linux/rtnetlink.h>
+#endif
+
+#include "bnad.h"
+#include "bna_os.h"
+#include "bna_hwreg.h"
+#include "bna_log_trc.h"
+#include "bna_iocll.h"
+#include "bnad_defs.h"
+#include "phyport_defs.h"
+
+#define BNAD_ETHTOOL_STATS_NUM						\
+    (sizeof (struct net_device_stats) / sizeof (unsigned long) +	\
+    sizeof (struct bnad_drv_stats) / sizeof (u64) +		\
+     (offsetof(struct bna_stats, rxf_stats[0]) +			\
+    sizeof (struct bna_stats_txf)) / sizeof (u64))
+
+static char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
+	"rx_packets",
+	"tx_packets",
+	"rx_bytes",
+	"tx_bytes",
+	"rx_errors",
+	"tx_errors",
+	"rx_dropped",
+	"tx_dropped",
+	"multicast",
+	"collisions",
+
+	"rx_length_errors",
+	"rx_over_errors",
+	"rx_crc_errors",
+	"rx_frame_errors",
+	"rx_fifo_errors",
+	"rx_missed_errors",
+
+	"tx_aborted_errors",
+	"tx_carrier_errors",
+	"tx_fifo_errors",
+	"tx_heartbeat_errors",
+	"tx_window_errors",
+
+	"rx_compressed",
+	"tx_compressed",
+
+	"netif_queue_stop",
+	"netif_queue_wakeup",
+	"tso4",
+	"tso6",
+	"tso_err",
+	"tcpcsum_offload",
+	"udpcsum_offload",
+	"csum_help",
+	"csum_help_err",
+	"hw_stats_updates",
+	"netif_rx_schedule",
+	"netif_rx_complete",
+	"netif_rx_dropped",
+
+	"mac_frame_64",
+	"mac_frame_65_127",
+	"mac_frame_128_255",
+	"mac_frame_256_511",
+	"mac_frame_512_1023",
+	"mac_frame_1024_1518",
+	"mac_frame_1518_1522",
+	"mac_rx_bytes",
+	"mac_rx_packets",
+	"mac_rx_fcs_error",
+	"mac_rx_multicast",
+	"mac_rx_broadcast",
+	"mac_rx_control_frames",
+	"mac_rx_pause",
+	"mac_rx_unknown_opcode",
+	"mac_rx_alignment_error",
+	"mac_rx_frame_length_error",
+	"mac_rx_code_error",
+	"mac_rx_carrier_sense_error",
+	"mac_rx_undersize",
+	"mac_rx_oversize",
+	"mac_rx_fragments",
+	"mac_rx_jabber",
+	"mac_rx_drop",
+
+	"bpc_rx_pause_0",
+	"bpc_rx_pause_1",
+	"bpc_rx_pause_2",
+	"bpc_rx_pause_3",
+	"bpc_rx_pause_4",
+	"bpc_rx_pause_5",
+	"bpc_rx_pause_6",
+	"bpc_rx_pause_7",
+	"bpc_rx_zero_pause_0",
+	"bpc_rx_zero_pause_1",
+	"bpc_rx_zero_pause_2",
+	"bpc_rx_zero_pause_3",
+	"bpc_rx_zero_pause_4",
+	"bpc_rx_zero_pause_5",
+	"bpc_rx_zero_pause_6",
+	"bpc_rx_zero_pause_7",
+	"bpc_rx_first_pause_0",
+	"bpc_rx_first_pause_1",
+	"bpc_rx_first_pause_2",
+	"bpc_rx_first_pause_3",
+	"bpc_rx_first_pause_4",
+	"bpc_rx_first_pause_5",
+	"bpc_rx_first_pause_6",
+	"bpc_rx_first_pause_7",
+
+	"rad_rx_frames",
+	"rad_rx_octets",
+	"rad_rx_vlan_frames",
+	"rad_rx_ucast",
+	"rad_rx_ucast_octets",
+	"rad_rx_ucast_vlan",
+	"rad_rx_mcast",
+	"rad_rx_mcast_octets",
+	"rad_rx_mcast_vlan",
+	"rad_rx_bcast",
+	"rad_rx_bcast_octets",
+	"rad_rx_bcast_vlan",
+	"rad_rx_drops",
+
+	"fc_rx_ucast_octets",
+	"fc_rx_ucast",
+	"fc_rx_ucast_vlan",
+	"fc_rx_mcast_octets",
+	"fc_rx_mcast",
+	"fc_rx_mcast_vlan",
+	"fc_rx_bcast_octets",
+	"fc_rx_bcast",
+	"fc_rx_bcast_vlan",
+
+	"mac_tx_bytes",
+	"mac_tx_packets",
+	"mac_tx_multicast",
+	"mac_tx_broadcast",
+	"mac_tx_pause",
+	"mac_tx_deferral",
+	"mac_tx_excessive_deferral",
+	"mac_tx_single_collision",
+	"mac_tx_muliple_collision",
+	"mac_tx_late_collision",
+	"mac_tx_excessive_collision",
+	"mac_tx_total_collision",
+	"mac_tx_pause_honored",
+	"mac_tx_drop",
+	"mac_tx_jabber",
+	"mac_tx_fcs_error",
+	"mac_tx_control_frame",
+	"mac_tx_oversize",
+	"mac_tx_undersize",
+	"mac_tx_fragments",
+
+	"bpc_tx_pause_0",
+	"bpc_tx_pause_1",
+	"bpc_tx_pause_2",
+	"bpc_tx_pause_3",
+	"bpc_tx_pause_4",
+	"bpc_tx_pause_5",
+	"bpc_tx_pause_6",
+	"bpc_tx_pause_7",
+	"bpc_tx_zero_pause_0",
+	"bpc_tx_zero_pause_1",
+	"bpc_tx_zero_pause_2",
+	"bpc_tx_zero_pause_3",
+	"bpc_tx_zero_pause_4",
+	"bpc_tx_zero_pause_5",
+	"bpc_tx_zero_pause_6",
+	"bpc_tx_zero_pause_7",
+	"bpc_tx_first_pause_0",
+	"bpc_tx_first_pause_1",
+	"bpc_tx_first_pause_2",
+	"bpc_tx_first_pause_3",
+	"bpc_tx_first_pause_4",
+	"bpc_tx_first_pause_5",
+	"bpc_tx_first_pause_6",
+	"bpc_tx_first_pause_7",
+
+	"fc_tx_ucast_octets",
+	"fc_tx_ucast",
+	"fc_tx_ucast_vlan",
+	"fc_tx_mcast_octets",
+	"fc_tx_mcast",
+	"fc_tx_mcast_vlan",
+	"fc_tx_bcast_octets",
+	"fc_tx_bcast",
+	"fc_tx_bcast_vlan",
+	"fc_tx_parity_errors",
+	"fc_tx_timeout",
+	"fc_tx_fid_parity_errors",
+
+	"txf0_ucast_octets",
+	"txf0_ucast",
+	"txf0_ucast_vlan",
+	"txf0_mcast_octets",
+	"txf0_mcast",
+	"txf0_mcast_vlan",
+	"txf0_bcast_octets",
+	"txf0_bcast",
+	"txf0_bcast_vlan",
+	"txf0_errors",
+	"txf0_filter_vlan",
+	"txf0_filter_mac_sa"
+};
+
+static int bnad_get_regs_len(struct net_device *netdev);
+static int bnad_get_stats_count(struct net_device *netdev);
+
+static int
+bnad_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	struct bna_port_param port_param;
+
+	bnad_lock();
+	spin_lock_irq(&bnad->priv_lock);
+	bna_port_param_get(bnad->priv, &port_param);
+	spin_unlock_irq(&bnad->priv_lock);
+
+	if (port_param.speed == BNA_LINK_SPEED_10Gbps) {
+		cmd->supported = SUPPORTED_10000baseT_Full;
+		cmd->advertising = ADVERTISED_10000baseT_Full;
+	}
+
+	if (port_param.autoneg) {
+		cmd->supported |= SUPPORTED_Autoneg;
+		cmd->advertising |= ADVERTISED_Autoneg;
+		cmd->autoneg = AUTONEG_ENABLE;
+	} else
+		cmd->autoneg = AUTONEG_DISABLE;
+#if 0
+	if (bnad_is_fibre(bnad->priv)) {
+		cmd->supported |= SUPPORTED_FIBRE;
+		cmd->advertising |= ADVERTISED_FIBRE;
+		cmd->port = PORT_FIBRE;
+	} else {
+		cmd->supported |= SUPPORTED_TP;
+		cmd->advertising |= ADVERTISED_TP;
+		cmd->port = PORT_TP;
+	}
+#else
+	cmd->supported |= SUPPORTED_FIBRE;
+	cmd->advertising |= ADVERTISED_FIBRE;
+	cmd->port = PORT_FIBRE;
+#endif
+	cmd->phy_address = 0;
+
+	if (netif_carrier_ok(netdev)) {
+		cmd->speed = SPEED_10000;
+		cmd->duplex = DUPLEX_FULL;
+	} else {
+		cmd->speed = -1;
+		cmd->duplex = -1;
+	}
+	cmd->transceiver = XCVR_EXTERNAL;
+	cmd->maxtxpkt = 0;
+	cmd->maxrxpkt = 0;
+	bnad_unlock();
+	return 0;
+}
+
+static int
+bnad_set_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+{
+	/* 10G full duplex setting supported only */
+	if (cmd->autoneg == AUTONEG_ENABLE) {
+		return -EOPNOTSUPP;
+	} else {
+		if ((cmd->speed == SPEED_10000) && (cmd->duplex == DUPLEX_FULL))
+			return 0;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static void
+bnad_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	struct bfa_ioc_attr_s *ioc_attr;
+
+	strcpy(drvinfo->driver, BNAD_NAME);
+	strcpy(drvinfo->version, BNAD_VERSION);
+
+	ioc_attr = kzalloc(sizeof(*ioc_attr), GFP_KERNEL);
+	if (ioc_attr) {
+		memset(ioc_attr, 0, sizeof(*ioc_attr));
+		spin_lock_irq(&bnad->priv_lock);
+		bna_iocll_getattr(bnad->priv, ioc_attr);
+		spin_unlock_irq(&bnad->priv_lock);
+
+		strncpy(drvinfo->fw_version, ioc_attr->adapter_attr.fw_ver,
+			sizeof(drvinfo->fw_version) - 1);
+		kfree(ioc_attr);
+	}
+
+	strncpy(drvinfo->bus_info, pci_name(bnad->pcidev), ETHTOOL_BUSINFO_LEN);
+}
+
+static int
+get_regs(struct bnad *bnad, u32 * regs)
+{
+	int num = 0, i;
+	u32 reg_addr;
+
+#define BNAD_GET_REG(addr) 					\
+do {								\
+	if (regs)						\
+		regs[num++] = readl(bnad->bar0 + (addr));      \
+	else							\
+		num++;						\
+} while (0)
+
+	/* DMA Block Internal Registers */
+	BNAD_GET_REG(DMA_CTRL_REG0);
+	BNAD_GET_REG(DMA_CTRL_REG1);
+	BNAD_GET_REG(DMA_ERR_INT_STATUS);
+	BNAD_GET_REG(DMA_ERR_INT_ENABLE);
+	BNAD_GET_REG(DMA_ERR_INT_STATUS_SET);
+
+	/* APP Block Register Address Offset from BAR0 */
+	BNAD_GET_REG(HOSTFN0_INT_STATUS);
+	BNAD_GET_REG(HOSTFN0_INT_MASK);
+	BNAD_GET_REG(HOST_PAGE_NUM_FN0);
+	BNAD_GET_REG(HOST_MSIX_ERR_INDEX_FN0);
+	BNAD_GET_REG(FN0_PCIE_ERR_REG);
+	BNAD_GET_REG(FN0_ERR_TYPE_STATUS_REG);
+	BNAD_GET_REG(FN0_ERR_TYPE_MSK_STATUS_REG);
+
+	BNAD_GET_REG(HOSTFN1_INT_STATUS);
+	BNAD_GET_REG(HOSTFN1_INT_MASK);
+	BNAD_GET_REG(HOST_PAGE_NUM_FN1);
+	BNAD_GET_REG(HOST_MSIX_ERR_INDEX_FN1);
+	BNAD_GET_REG(FN1_PCIE_ERR_REG);
+	BNAD_GET_REG(FN1_ERR_TYPE_STATUS_REG);
+	BNAD_GET_REG(FN1_ERR_TYPE_MSK_STATUS_REG);
+
+	BNAD_GET_REG(PCIE_MISC_REG);
+
+	BNAD_GET_REG(HOST_SEM0_REG);
+	BNAD_GET_REG(HOST_SEM1_REG);
+	BNAD_GET_REG(HOST_SEM2_REG);
+	BNAD_GET_REG(HOST_SEM3_REG);
+	BNAD_GET_REG(HOST_SEM0_INFO_REG);
+	BNAD_GET_REG(HOST_SEM1_INFO_REG);
+	BNAD_GET_REG(HOST_SEM2_INFO_REG);
+	BNAD_GET_REG(HOST_SEM3_INFO_REG);
+
+	BNAD_GET_REG(TEMPSENSE_CNTL_REG);
+	BNAD_GET_REG(TEMPSENSE_STAT_REG);
+
+	BNAD_GET_REG(APP_LOCAL_ERR_STAT);
+	BNAD_GET_REG(APP_LOCAL_ERR_MSK);
+
+	BNAD_GET_REG(PCIE_LNK_ERR_STAT);
+	BNAD_GET_REG(PCIE_LNK_ERR_MSK);
+
+	BNAD_GET_REG(FCOE_FIP_ETH_TYPE);
+	BNAD_GET_REG(RESV_ETH_TYPE);
+
+	BNAD_GET_REG(HOSTFN2_INT_STATUS);
+	BNAD_GET_REG(HOSTFN2_INT_MASK);
+	BNAD_GET_REG(HOST_PAGE_NUM_FN2);
+	BNAD_GET_REG(HOST_MSIX_ERR_INDEX_FN2);
+	BNAD_GET_REG(FN2_PCIE_ERR_REG);
+	BNAD_GET_REG(FN2_ERR_TYPE_STATUS_REG);
+	BNAD_GET_REG(FN2_ERR_TYPE_MSK_STATUS_REG);
+
+	BNAD_GET_REG(HOSTFN3_INT_STATUS);
+	BNAD_GET_REG(HOSTFN3_INT_MASK);
+	BNAD_GET_REG(HOST_PAGE_NUM_FN3);
+	BNAD_GET_REG(HOST_MSIX_ERR_INDEX_FN3);
+	BNAD_GET_REG(FN3_PCIE_ERR_REG);
+	BNAD_GET_REG(FN3_ERR_TYPE_STATUS_REG);
+	BNAD_GET_REG(FN3_ERR_TYPE_MSK_STATUS_REG);
+
+	/* Host Command Status Registers */
+	reg_addr = HOST_CMDSTS0_CLR_REG;
+	for (i = 0; i < 16; i++) {
+		BNAD_GET_REG(reg_addr);
+		BNAD_GET_REG(reg_addr + 4);
+		BNAD_GET_REG(reg_addr + 8);
+		reg_addr += 0x10;
+	}
+
+	/* Function ID register */
+	BNAD_GET_REG(FNC_ID_REG);
+
+	/* Function personality register */
+	BNAD_GET_REG(FNC_PERS_REG);
+
+	/* Operation mode register */
+	BNAD_GET_REG(OP_MODE);
+
+	/* LPU0 Registers */
+	BNAD_GET_REG(LPU0_MBOX_CTL_REG);
+	BNAD_GET_REG(LPU0_MBOX_CMD_REG);
+	BNAD_GET_REG(LPU0_MBOX_LINK_0REG);
+	BNAD_GET_REG(LPU1_MBOX_LINK_0REG);
+	BNAD_GET_REG(LPU0_MBOX_STATUS_0REG);
+	BNAD_GET_REG(LPU1_MBOX_STATUS_0REG);
+	BNAD_GET_REG(LPU0_ERR_STATUS_REG);
+	BNAD_GET_REG(LPU0_ERR_SET_REG);
+
+	/* LPU1 Registers */
+	BNAD_GET_REG(LPU1_MBOX_CTL_REG);
+	BNAD_GET_REG(LPU1_MBOX_CMD_REG);
+	BNAD_GET_REG(LPU0_MBOX_LINK_1REG);
+	BNAD_GET_REG(LPU1_MBOX_LINK_1REG);
+	BNAD_GET_REG(LPU0_MBOX_STATUS_1REG);
+	BNAD_GET_REG(LPU1_MBOX_STATUS_1REG);
+	BNAD_GET_REG(LPU1_ERR_STATUS_REG);
+	BNAD_GET_REG(LPU1_ERR_SET_REG);
+
+	/* PSS Registers */
+	BNAD_GET_REG(PSS_CTL_REG);
+	BNAD_GET_REG(PSS_ERR_STATUS_REG);
+	BNAD_GET_REG(ERR_STATUS_SET);
+	BNAD_GET_REG(PSS_RAM_ERR_STATUS_REG);
+
+	/* Catapult CPQ Registers */
+	BNAD_GET_REG(HOSTFN0_LPU0_MBOX0_CMD_STAT);
+	BNAD_GET_REG(HOSTFN0_LPU1_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN0_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN0_MBOX0_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN0_LPU0_MBOX1_CMD_STAT);
+	BNAD_GET_REG(HOSTFN0_LPU1_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN0_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN0_MBOX1_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN1_LPU0_MBOX0_CMD_STAT);
+	BNAD_GET_REG(HOSTFN1_LPU1_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN1_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN1_MBOX0_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN1_LPU0_MBOX1_CMD_STAT);
+	BNAD_GET_REG(HOSTFN1_LPU1_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN1_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN1_MBOX1_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN2_LPU0_MBOX0_CMD_STAT);
+	BNAD_GET_REG(HOSTFN2_LPU1_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN2_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN2_MBOX0_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN2_LPU0_MBOX1_CMD_STAT);
+	BNAD_GET_REG(HOSTFN2_LPU1_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN2_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN2_MBOX1_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN3_LPU0_MBOX0_CMD_STAT);
+	BNAD_GET_REG(HOSTFN3_LPU1_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN3_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN3_MBOX0_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN3_LPU0_MBOX1_CMD_STAT);
+	BNAD_GET_REG(HOSTFN3_LPU1_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN3_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN3_MBOX1_CMD_STAT);
+
+	/* Host Function Force Parity Error Registers */
+	BNAD_GET_REG(HOSTFN0_LPU_FORCE_PERR);
+	BNAD_GET_REG(HOSTFN1_LPU_FORCE_PERR);
+	BNAD_GET_REG(HOSTFN2_LPU_FORCE_PERR);
+	BNAD_GET_REG(HOSTFN3_LPU_FORCE_PERR);
+
+	/* LL Port[0|1] Halt Mask Registers */
+	BNAD_GET_REG(LL_HALT_MSK_P0);
+	BNAD_GET_REG(LL_HALT_MSK_P1);
+
+	/* LL Port[0|1] Error Mask Registers */
+	BNAD_GET_REG(LL_ERR_MSK_P0);
+	BNAD_GET_REG(LL_ERR_MSK_P1);
+
+	/* EMC FLI Registers */
+	BNAD_GET_REG(FLI_CMD_REG);
+	BNAD_GET_REG(FLI_ADDR_REG);
+	BNAD_GET_REG(FLI_CTL_REG);
+	BNAD_GET_REG(FLI_WRDATA_REG);
+	BNAD_GET_REG(FLI_RDDATA_REG);
+	BNAD_GET_REG(FLI_DEV_STATUS_REG);
+	BNAD_GET_REG(FLI_SIG_WD_REG);
+
+	BNAD_GET_REG(FLI_DEV_VENDOR_REG);
+	BNAD_GET_REG(FLI_ERR_STATUS_REG);
+
+	/* RxAdm 0 Registers */
+	BNAD_GET_REG(RAD0_CTL_REG);
+	BNAD_GET_REG(RAD0_PE_PARM_REG);
+	BNAD_GET_REG(RAD0_BCN_REG);
+	BNAD_GET_REG(RAD0_DEFAULT_REG);
+	BNAD_GET_REG(RAD0_PROMISC_REG);
+	BNAD_GET_REG(RAD0_BCNQ_REG);
+	BNAD_GET_REG(RAD0_DEFAULTQ_REG);
+
+	BNAD_GET_REG(RAD0_ERR_STS);
+	BNAD_GET_REG(RAD0_SET_ERR_STS);
+	BNAD_GET_REG(RAD0_ERR_INT_EN);
+	BNAD_GET_REG(RAD0_FIRST_ERR);
+	BNAD_GET_REG(RAD0_FORCE_ERR);
+
+	BNAD_GET_REG(RAD0_MAC_MAN_1H);
+	BNAD_GET_REG(RAD0_MAC_MAN_1L);
+	BNAD_GET_REG(RAD0_MAC_MAN_2H);
+	BNAD_GET_REG(RAD0_MAC_MAN_2L);
+	BNAD_GET_REG(RAD0_MAC_MAN_3H);
+	BNAD_GET_REG(RAD0_MAC_MAN_3L);
+	BNAD_GET_REG(RAD0_MAC_MAN_4H);
+	BNAD_GET_REG(RAD0_MAC_MAN_4L);
+
+	BNAD_GET_REG(RAD0_LAST4_IP);
+
+	/* RxAdm 1 Registers */
+	BNAD_GET_REG(RAD1_CTL_REG);
+	BNAD_GET_REG(RAD1_PE_PARM_REG);
+	BNAD_GET_REG(RAD1_BCN_REG);
+	BNAD_GET_REG(RAD1_DEFAULT_REG);
+	BNAD_GET_REG(RAD1_PROMISC_REG);
+	BNAD_GET_REG(RAD1_BCNQ_REG);
+	BNAD_GET_REG(RAD1_DEFAULTQ_REG);
+
+	BNAD_GET_REG(RAD1_ERR_STS);
+	BNAD_GET_REG(RAD1_SET_ERR_STS);
+	BNAD_GET_REG(RAD1_ERR_INT_EN);
+
+	/* TxA0 Registers */
+	BNAD_GET_REG(TXA0_CTRL_REG);
+	/* TxA0 TSO Sequence # Registers (RO) */
+	for (i = 0; i < 8; i++) {
+		BNAD_GET_REG(TXA0_TSO_TCP_SEQ_REG(i));
+		BNAD_GET_REG(TXA0_TSO_IP_INFO_REG(i));
+	}
+
+	/* TxA1 Registers */
+	BNAD_GET_REG(TXA1_CTRL_REG);
+	/* TxA1 TSO Sequence # Registers (RO) */
+	for (i = 0; i < 8; i++) {
+		BNAD_GET_REG(TXA1_TSO_TCP_SEQ_REG(i));
+		BNAD_GET_REG(TXA1_TSO_IP_INFO_REG(i));
+	}
+
+	/* RxA Registers */
+	BNAD_GET_REG(RXA0_CTL_REG);
+	BNAD_GET_REG(RXA1_CTL_REG);
+
+	/* PLB0 Registers */
+	BNAD_GET_REG(PLB0_ECM_TIMER_REG);
+	BNAD_GET_REG(PLB0_RL_CTL);
+	for (i = 0; i < 8; i++)
+		BNAD_GET_REG(PLB0_RL_MAX_BC(i));
+	BNAD_GET_REG(PLB0_RL_TU_PRIO);
+	for (i = 0; i < 8; i++)
+		BNAD_GET_REG(PLB0_RL_BYTE_CNT(i));
+	BNAD_GET_REG(PLB0_RL_MIN_REG);
+	BNAD_GET_REG(PLB0_RL_MAX_REG);
+	BNAD_GET_REG(PLB0_EMS_ADD_REG);
+
+	/* PLB1 Registers */
+	BNAD_GET_REG(PLB1_ECM_TIMER_REG);
+	BNAD_GET_REG(PLB1_RL_CTL);
+	for (i = 0; i < 8; i++)
+		BNAD_GET_REG(PLB1_RL_MAX_BC(i));
+	BNAD_GET_REG(PLB1_RL_TU_PRIO);
+	for (i = 0; i < 8; i++)
+		BNAD_GET_REG(PLB1_RL_BYTE_CNT(i));
+	BNAD_GET_REG(PLB1_RL_MIN_REG);
+	BNAD_GET_REG(PLB1_RL_MAX_REG);
+	BNAD_GET_REG(PLB1_EMS_ADD_REG);
+
+	/* HQM Control Register */
+	BNAD_GET_REG(HQM0_CTL_REG);
+	BNAD_GET_REG(HQM0_RXQ_STOP_SEM);
+	BNAD_GET_REG(HQM0_TXQ_STOP_SEM);
+	BNAD_GET_REG(HQM1_CTL_REG);
+	BNAD_GET_REG(HQM1_RXQ_STOP_SEM);
+	BNAD_GET_REG(HQM1_TXQ_STOP_SEM);
+
+	/* LUT Registers */
+	BNAD_GET_REG(LUT0_ERR_STS);
+	BNAD_GET_REG(LUT0_SET_ERR_STS);
+	BNAD_GET_REG(LUT1_ERR_STS);
+	BNAD_GET_REG(LUT1_SET_ERR_STS);
+
+	/* TRC Registers */
+	BNAD_GET_REG(TRC_CTL_REG);
+	BNAD_GET_REG(TRC_MODS_REG);
+	BNAD_GET_REG(TRC_TRGC_REG);
+	BNAD_GET_REG(TRC_CNT1_REG);
+	BNAD_GET_REG(TRC_CNT2_REG);
+	BNAD_GET_REG(TRC_NXTS_REG);
+	BNAD_GET_REG(TRC_DIRR_REG);
+	for (i = 0; i < 10; i++)
+		BNAD_GET_REG(TRC_TRGM_REG(i));
+	for (i = 0; i < 10; i++)
+		BNAD_GET_REG(TRC_NXTM_REG(i));
+	for (i = 0; i < 10; i++)
+		BNAD_GET_REG(TRC_STRM_REG(i));
+
+#undef BNAD_GET_REG
+	return num;
+}
+
+static int
+bnad_get_regs_len(struct net_device *netdev)
+{
+	return (get_regs(netdev_priv(netdev), NULL) * sizeof(u32));
+}
+
+static void
+bnad_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *buf)
+{
+	memset(buf, 0, bnad_get_regs_len(netdev));
+	get_regs(netdev_priv(netdev), buf);
+}
+
+static void
+bnad_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wolinfo)
+{
+	wolinfo->supported = 0;
+	wolinfo->wolopts = 0;
+}
+
+#if 0
+static int
+bnad_get_eeprom_len(struct net_device *netdev)
+{
+	return 0;
+}
+
+static int
+bnad_get_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
+		u8 * buf)
+{
+	if (eeprom->len == 0)
+		return -EINVAL;
+	return 0;
+}
+
+static int
+bnad_set_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
+		u8 * buf)
+{
+
+}
+#endif
+
+static int
+bnad_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_lock();
+	coalesce->rx_coalesce_usecs = bnad->rx_coalescing_timeo *
+		BNAD_COALESCING_TIMER_UNIT;
+	coalesce->rx_max_coalesced_frames = bnad->rx_interpkt_count;
+#ifdef CATAPULT_BRINGUP
+	coalesce->rx_coalesce_usecs_irq = bnad->rx_interpkt_timeo;
+#endif
+	coalesce->tx_coalesce_usecs = bnad->tx_coalescing_timeo *
+		BNAD_COALESCING_TIMER_UNIT;
+	coalesce->tx_max_coalesced_frames = bnad->tx_interpkt_count;
+
+#ifdef BNA_DYN_INTR_MOD
+	coalesce->use_adaptive_rx_coalesce = bnad->rx_dyn_coalesce_on;
+#endif
+	bnad_unlock();
+	return 0;
+}
+
+static int
+bnad_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int i, err = 0, reset = 0;
+	u16 ib_id;
+
+	if (coalesce->rx_coalesce_usecs == 0 || coalesce->rx_coalesce_usecs >
+	    BNAD_MAX_COALESCING_TIMEO * BNAD_COALESCING_TIMER_UNIT)
+		return -EINVAL;
+	if (coalesce->rx_max_coalesced_frames > BNAD_MAX_INTERPKT_COUNT)
+		return -EINVAL;
+	if (coalesce->rx_coalesce_usecs_irq == 0 ||
+	    coalesce->rx_coalesce_usecs_irq > BNAD_MAX_INTERPKT_TIMEO)
+		return -EINVAL;
+
+	if (coalesce->tx_coalesce_usecs == 0 || coalesce->tx_coalesce_usecs >
+	    BNAD_MAX_COALESCING_TIMEO * BNAD_COALESCING_TIMER_UNIT)
+		return -EINVAL;
+	if (coalesce->tx_max_coalesced_frames > BNAD_MAX_INTERPKT_COUNT)
+		return -EINVAL;
+
+	bnad_lock();
+
+#ifdef BNA_DYN_INTR_MOD
+	bnad->rx_dyn_coalesce_on = coalesce->use_adaptive_rx_coalesce;
+#endif
+
+	bnad->rx_coalescing_timeo = coalesce->rx_coalesce_usecs /
+		BNAD_COALESCING_TIMER_UNIT;
+	if (bnad->rx_coalescing_timeo == 0)
+		bnad->rx_coalescing_timeo = 1;
+	if (!test_bit(BNAD_DISABLED, &bnad->state)) {
+		for (i = 0; i < bnad->cq_num; i++) {
+			ib_id = bnad->cq_table[i].cq_config.ib_id;
+			bnad->ib_table[ib_id].ib_config.coalescing_timer =
+				bnad->rx_coalescing_timeo;
+#ifdef BNA_DYN_INTR_MOD
+			if (!bnad->rx_dyn_coalesce_on) {
+				bnad->cq_table[i].rx_coalescing_timeo =
+					bnad->rx_coalescing_timeo;
+			}
+#endif
+#ifndef BNAD_NAPI
+#ifdef BNAD_DYN_INTR_MOD
+			if (!bnad->rx_dyn_coalesce_on) {
+#endif
+				spin_lock_irq(&bnad->priv_lock);
+				bna_ib_coalescing_timer_set(bnad->priv,
+							    &bnad->cq_table[i].
+							    ib,
+							    bnad->
+							    rx_coalescing_timeo);
+				spin_unlock_irq(&bnad->priv_lock);
+#ifdef BNAD_DYN_INTR_MOD
+			}
+#endif
+#endif
+		}
+	}
+	if (coalesce->rx_max_coalesced_frames != bnad->rx_interpkt_count) {
+		bnad->rx_interpkt_count = coalesce->rx_max_coalesced_frames;
+		reset++;
+	}
+	if (coalesce->rx_coalesce_usecs_irq != bnad->rx_interpkt_timeo) {
+		bnad->rx_interpkt_timeo = coalesce->rx_coalesce_usecs_irq;
+		reset++;
+	}
+
+	bnad->tx_coalescing_timeo = coalesce->tx_coalesce_usecs /
+		BNAD_COALESCING_TIMER_UNIT;
+	if (bnad->tx_coalescing_timeo == 0)
+		bnad->tx_coalescing_timeo = 1;
+	if (!test_bit(BNAD_DISABLED, &bnad->state)) {
+		for (i = 0; i < bnad->txq_num; i++) {
+			ib_id = bnad->txq_table[i].txq_config.ib_id;
+			bnad->ib_table[ib_id].ib_config.coalescing_timer =
+				bnad->tx_coalescing_timeo;
+#ifndef BNAD_NAPI
+			spin_lock_irq(&bnad->priv_lock);
+			bna_ib_coalescing_timer_set(bnad->priv,
+						    &bnad->txq_table[i].ib,
+						    bnad->tx_coalescing_timeo);
+			spin_unlock_irq(&bnad->priv_lock);
+#endif
+		}
+	}
+	if (coalesce->tx_max_coalesced_frames != bnad->tx_interpkt_count) {
+		bnad->tx_interpkt_count = coalesce->tx_max_coalesced_frames;
+		reset++;
+	}
+
+	if (reset)
+		err = bnad_sw_reset(netdev);
+
+	bnad_unlock();
+
+	return err;
+}
+
+static void
+bnad_get_ringparam(struct net_device *netdev,
+		   struct ethtool_ringparam *ringparam)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_lock();
+	ringparam->rx_max_pending = BNAD_MAX_Q_DEPTH / bnad_rxqs_per_cq;
+	ringparam->rx_mini_max_pending = 0;
+	ringparam->rx_jumbo_max_pending = 0;
+	ringparam->tx_max_pending = BNAD_MAX_Q_DEPTH;
+
+	ringparam->rx_pending = bnad->rxq_depth;
+	ringparam->rx_mini_max_pending = 0;
+	ringparam->rx_jumbo_max_pending = 0;
+	ringparam->tx_pending = bnad->txq_depth;
+	bnad_unlock();
+}
+
+static int
+bnad_set_ringparam(struct net_device *netdev,
+		   struct ethtool_ringparam *ringparam)
+{
+	int err = 0;
+	struct bnad *bnad = netdev_priv(netdev);
+	bnad_lock();
+	if (ringparam->rx_pending == bnad->rxq_depth &&
+	    ringparam->tx_pending == bnad->txq_depth) {
+		bnad_unlock();
+		return 0;
+	}
+
+	if (ringparam->rx_pending < BNAD_MIN_Q_DEPTH ||
+	    ringparam->rx_pending > BNAD_MAX_Q_DEPTH / bnad_rxqs_per_cq ||
+	    !BNA_POWER_OF_2(ringparam->rx_pending)) {
+		bnad_unlock();
+		return -EINVAL;
+	}
+	if (ringparam->tx_pending < BNAD_MIN_Q_DEPTH ||
+	    ringparam->tx_pending > BNAD_MAX_Q_DEPTH ||
+	    !BNA_POWER_OF_2(ringparam->tx_pending)) {
+		bnad_unlock();
+		return -EINVAL;
+	}
+
+	if (ringparam->rx_pending != bnad->rxq_depth) {
+		bnad->rxq_depth = ringparam->rx_pending;
+		bnad->flags |= BNAD_F_RXQ_DEPTH;
+	}
+	if (ringparam->tx_pending != bnad->txq_depth) {
+		bnad->txq_depth = ringparam->tx_pending;
+		bnad->flags |= BNAD_F_TXQ_DEPTH;
+	}
+
+	err = bnad_sw_reset(netdev);
+	bnad_unlock();
+	return err;
+}
+
+static void
+bnad_get_pauseparam(struct net_device *netdev,
+		    struct ethtool_pauseparam *pauseparam)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	bnad_lock();
+	pauseparam->autoneg = 0;
+	pauseparam->rx_pause = bnad->pause_config.rx_pause;
+	pauseparam->tx_pause = bnad->pause_config.tx_pause;
+	bnad_unlock();
+}
+
+static int
+bnad_set_pauseparam(struct net_device *netdev,
+		    struct ethtool_pauseparam *pauseparam)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int err;
+
+	if (pauseparam->autoneg == AUTONEG_ENABLE)
+		return -EINVAL;
+	bnad_lock();
+	if (pauseparam->rx_pause != bnad->pause_config.rx_pause ||
+	    pauseparam->tx_pause != bnad->pause_config.tx_pause) {
+		bnad->pause_config.rx_pause = pauseparam->rx_pause;
+		bnad->pause_config.tx_pause = pauseparam->tx_pause;
+		spin_lock_irq(&bnad->priv_lock);
+		err = bna_set_pause_config(bnad->priv, &bnad->pause_config,
+					   bnad);
+		BNA_ASSERT(!err);
+		spin_unlock_irq(&bnad->priv_lock);
+	}
+	bnad_unlock();
+	return 0;
+}
+
+static u32
+bnad_get_rx_csum(struct net_device *netdev)
+{
+	u32 rx_csum;
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_lock();
+	rx_csum = bnad->rx_csum;
+	bnad_unlock();
+	return rx_csum;
+}
+
+static int
+bnad_set_rx_csum(struct net_device *netdev, u32 rx_csum)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_lock();
+	bnad->rx_csum = rx_csum;
+	bnad_unlock();
+	return 0;
+}
+
+static int
+bnad_set_tx_csum(struct net_device *netdev, u32 tx_csum)
+{
+	if (tx_csum) {
+		netdev->features |= NETIF_F_IP_CSUM;
+#ifdef NETIF_F_IPV6_CSUM
+		netdev->features |= NETIF_F_IPV6_CSUM;
+#endif
+	} else {
+		netdev->features &= ~NETIF_F_IP_CSUM;
+#ifdef NETIF_F_IPV6_CSUM
+		netdev->features &= ~NETIF_F_IPV6_CSUM;
+#endif
+	}
+	return 0;
+}
+
+#ifdef NETIF_F_TSO
+static int
+bnad_set_tso(struct net_device *netdev, u32 tso)
+{
+	if (tso) {
+		netdev->features |= NETIF_F_TSO;
+#ifdef NETIF_F_TSO6
+		netdev->features |= NETIF_F_TSO6;
+#endif
+	} else {
+		netdev->features &= ~NETIF_F_TSO;
+#ifdef NETIF_F_TSO6
+		netdev->features &= ~NETIF_F_TSO6;
+#endif
+	}
+	return 0;
+}
+#endif
+
+#if 0
+static void
+bnad_self_test(struct net_device *netdev, struct ethtool_test *test,
+	       u64 * count)
+{
+
+
+}
+#endif
+
+static void
+bnad_get_strings(struct net_device *netdev, u32 stringset, u8 * string)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int i;
+#if defined(DEBUG_RX) || defined (DEBUG_TX)
+	int j;
+#endif
+	bnad_lock();
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < BNAD_ETHTOOL_STATS_NUM; i++) {
+			BNA_ASSERT(strlen(bnad_net_stats_strings[i]) <
+				   ETH_GSTRING_LEN);
+			memcpy(string, bnad_net_stats_strings[i],
+			       ETH_GSTRING_LEN);
+			string += ETH_GSTRING_LEN;
+		}
+
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+		for (i = 0; i < bnad->rxf_num; i++) {
+			if (!test_bit(i, &bnad->rxf_active))
+				continue;
+#else
+		i = 0;
+#endif
+		sprintf(string, "rxf%d_ucast_octets", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxf%d_ucast", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxf%d_ucast_vlan", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxf%d_mcast_octets", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxf%d_mcast", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxf%d_mcast_vlan", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxf%d_bcast_octets", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxf%d_bcast", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxf%d_bcast_vlan", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxf%d_frame_drops", i);
+		string += ETH_GSTRING_LEN;
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+	}
+#endif
+
+#ifdef CATAPULT_BRINGUP
+	sprintf(string, "netif_queue_stopped");
+	string += ETH_GSTRING_LEN;
+	sprintf(string, "bna_state");
+	string += ETH_GSTRING_LEN;
+#endif
+
+	for (i = 0; i < bnad->cq_num; i++) {
+		sprintf(string, "cq%d_producer_index", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "cq%d_consumer_index", i);
+		string += ETH_GSTRING_LEN;
+	}
+
+	for (i = 0; i < bnad->rxq_num; i++) {
+		sprintf(string, "rxq%d_packets", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxq%d_bytes", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxq%d_packets_with_error", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxq%d_allocbuf_failed", i);
+		string += ETH_GSTRING_LEN;
+
+		sprintf(string, "rxq%d_producer_index", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "rxq%d_consumer_index", i);
+		string += ETH_GSTRING_LEN;
+
+#ifdef DEBUG_RX
+		for (j = 0; j < BNAD_MAX_RXQSETS_USED; j++) {
+			sprintf(string, "rxq%d_packets_cpu%d", i, j);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxq%d_bytes_cpu%d", i, j);
+			string += ETH_GSTRING_LEN;
+		}
+#endif
+	}
+
+	for (i = 0; i < bnad->txq_num; i++) {
+		sprintf(string, "txq%d_packets", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "txq%d_bytes", i);
+		string += ETH_GSTRING_LEN;
+
+		sprintf(string, "txq%d_producer_index", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "txq%d_consumer_index", i);
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "txq%d_hw_consumer_index", i);
+		string += ETH_GSTRING_LEN;
+#ifdef DEBUG_TX
+		sprintf(string, "txq%d_max_tso", i);
+		string += ETH_GSTRING_LEN;
+		for (j = 0; j < 32; j++) {
+			sprintf(string, "txq%d_vectors_%d", i, j);
+			string += ETH_GSTRING_LEN;
+		}
+#endif
+	}
+	break;
+
+default:
+	break;
+}
+
+bnad_unlock();
+}
+
+#if 0
+/* Need priv_lock? */
+static int
+bnad_phys_id(struct net_device *netdev, u32 seconds)
+{
+	int i;
+	struct bnad *bnad = netdev_priv(netdev);
+
+	if (!seconds)
+		seconds = 4;
+	bnad_lock();
+	config = bnad_get_led_config(bnad->priv);
+	for (i = 0; i < seconds * 2; i++) {
+		bnad_config_led(bnad->priv, ON);
+		msleep_interruptible(250);
+		bnad_config_led(bnad->priv, OFF);
+		msleep_interruptible(250);
+	}
+
+	bnad_config_led(bnad->priv, config);
+	bnad_unlock();
+	return 0;
+}
+#endif
+
+static void
+bnad_get_ethtool_stats(struct net_device *netdev, struct ethtool_stats *stats,
+		       u64 * buf)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int i, bi, j;
+	unsigned long *net_stats;
+	u64 *stats64;
+
+	bi = 0;
+	memset(buf, 0, bnad_get_stats_count(netdev) * sizeof(u64));
+	bnad_get_stats(netdev);
+
+	net_stats = (unsigned long *) &bnad->net_stats;
+	for (i = 0; i < sizeof(struct net_device_stats) /
+	     sizeof(unsigned long); i++)
+		buf[bi++] = net_stats[i];
+
+	stats64 = (u64 *) &bnad->stats;
+	for (i = 0; i < sizeof(struct bnad_drv_stats) / sizeof(u64); i++)
+		buf[bi++] = stats64[i];
+
+	stats64 = (u64 *) bnad->hw_stats;
+	for (i = 0; i < offsetof(struct bna_stats, rxf_stats[0]) / sizeof(u64);
+	     i++)
+		buf[bi++] = stats64[i];
+
+	stats64 = (u64 *) &bnad->hw_stats->txf_stats[0];
+	for (i = 0; i < sizeof(struct bna_stats_txf) / sizeof(u64); i++)
+		buf[bi++] = stats64[i];
+
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+	for (j = 0; j < bnad->rxf_num; j++) {
+		if (!test_bit(j, &bnad->rxf_active))
+			continue;
+#else
+	j = 0;
+#endif
+	stats64 = (u64 *) &bnad->hw_stats->rxf_stats[j];
+	for (i = 0; i < sizeof(struct bna_stats_rxf) / sizeof(u64); i++)
+		buf[bi++] = stats64[i];
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+}
+#endif
+
+#ifdef CATAPULT_BRINGUP
+buf[bi++] = netif_queue_stopped(netdev);
+buf[bi++] = bnad->state;
+#endif
+
+if (bnad->cq_table && bnad->rxq_table && bnad->txq_table) {
+	for (i = 0; i < bnad->cq_num; i++) {
+		buf[bi++] = bnad->cq_table[i].cq.q.producer_index;
+		buf[bi++] = bnad->cq_table[i].cq.q.consumer_index;
+	}
+
+	for (i = 0; i < bnad->rxq_num; i++) {
+		buf[bi++] = bnad->rxq_table[i].rx_packets;
+		buf[bi++] = bnad->rxq_table[i].rx_bytes;
+		buf[bi++] = bnad->rxq_table[i].rx_packets_with_error;
+		buf[bi++] = bnad->rxq_table[i].rxbuf_alloc_failed;
+
+		buf[bi++] = bnad->rxq_table[i].rxq.q.producer_index;
+		buf[bi++] = bnad->rxq_table[i].rxq.q.consumer_index;
+#ifdef DEBUG_RX
+		for (j = 0; j < BNAD_MAX_RXQSETS_USED; j++) {
+			buf[bi++] = bnad->rxq_table[i].rx_packets_cpu[j];
+			buf[bi++] = bnad->rxq_table[i].rx_bytes_cpu[j];
+		}
+#endif
+	}
+	for (i = 0; i < bnad->txq_num; i++) {
+		buf[bi++] = bnad->txq_table[i].tx_packets;
+		buf[bi++] = bnad->txq_table[i].tx_bytes;
+
+		buf[bi++] = bnad->txq_table[i].txq.q.producer_index;
+		buf[bi++] = bnad->txq_table[i].txq.q.consumer_index;
+		buf[bi++] = *(bnad->txq_table[i].hw_consumer_index);
+#ifdef DEBUG_TX
+		buf[bi++] = bnad->txq_table[i].max_tso;
+		for (j = 0; j < 32; j++)
+			buf[bi++] = bnad->txq_table[i].tx_vectors[j];
+#endif
+	}
+}
+}
+
+#if 0
+/* XXX use get_sset_count */
+static int
+bnad_self_test_count(struct net_device *netdev)
+{
+	return 0;
+}
+#endif
+
+/* XXX use get_sset_count */
+static int
+bnad_get_stats_count(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int count;
+
+	bnad_lock();
+#if defined(__VMKERNEL_MODULE__) && defined(__VMKNETDDI_QUEUEOPS__)
+	u32 i, rxf_active_num = 0;
+
+	for (i = 0; i < bnad->rxf_num; i++) {
+		if (!test_bit(i, &bnad->rxf_active))
+			continue;
+		rxf_active_num++;
+	}
+	count = BNAD_ETHTOOL_STATS_NUM + rxf_active_num * 10 + bnad->rxq_num * 4
+		+ bnad->txq_num * 2;
+#else
+	count = BNAD_ETHTOOL_STATS_NUM + 10 + bnad->rxq_num * 4 +
+		bnad->txq_num * 2;
+#endif
+
+#ifdef CATAPULT_BRINGUP
+	/* netif_queue_stopped, state */
+	count += 2;
+#endif
+
+	/* CQ producer_index, consumer_index */
+	count += bnad->cq_num * 2;
+
+	/* RxQ producer_index, consumer_index */
+	count += bnad->rxq_num * 2;
+#ifdef DEBUG_RX
+	/* RxQ rx_packets_cpu and rx_bytes_cpu */
+	count += bnad->rxq_num * 2 * BNAD_MAX_RXQSETS_USED;
+#endif
+
+	/* TxQ producer_index, consumer_index, hw_consumer_index */
+	count += bnad->txq_num * 3;
+#ifdef DEBUG_TX
+	/* max_tso */
+	count += bnad->txq_num;
+
+	/* tx_vectors */
+	count += bnad->txq_num * 32;
+#endif
+	bnad_unlock();
+	return count;
+}
+
+static struct ethtool_ops bnad_ethtool_ops = {
+	.get_settings = bnad_get_settings,
+	.set_settings = bnad_set_settings,
+	.get_drvinfo = bnad_get_drvinfo,
+	.get_regs_len = bnad_get_regs_len,
+	.get_regs = bnad_get_regs,
+	.get_wol = bnad_get_wol,
+	.get_msglevel = bnad_get_msglevel,
+	.set_msglevel = bnad_set_msglevel,
+	.get_link = ethtool_op_get_link,
+#if 0
+	.get_eeprom_len = bnad_get_eeprom_len,
+	.get_eeprom = bnad_get_eeprom,
+	.set_eeprom = bnad_set_eeprom,
+#endif
+	.get_coalesce = bnad_get_coalesce,
+	.set_coalesce = bnad_set_coalesce,
+	.get_ringparam = bnad_get_ringparam,
+	.set_ringparam = bnad_set_ringparam,
+	.get_pauseparam = bnad_get_pauseparam,
+	.set_pauseparam = bnad_set_pauseparam,
+	.get_rx_csum = bnad_get_rx_csum,
+	.set_rx_csum = bnad_set_rx_csum,
+	.get_tx_csum = ethtool_op_get_tx_csum,
+	.set_tx_csum = bnad_set_tx_csum,
+	.get_sg = ethtool_op_get_sg,
+	.set_sg = ethtool_op_set_sg,
+#ifdef NETIF_F_TSO
+	.get_tso = ethtool_op_get_tso,
+	.set_tso = bnad_set_tso,
+#endif
+#ifdef NETIF_F_LRO
+	.get_flags = ethtool_op_get_flags,
+	.set_flags = ethtool_op_set_flags,
+#endif
+#if 0
+	.self_test = bnad_self_test,
+#endif
+	.get_strings = bnad_get_strings,
+#if 0
+	.phys_id = bnad_phys_id,
+#endif
+	.get_ethtool_stats = bnad_get_ethtool_stats,
+#if 0
+	.self_test_count = bnad_self_test_count,
+#endif
+	.get_stats_count = bnad_get_stats_count
+};
+
+void
+bnad_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &bnad_ethtool_ops);
+}
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bna_if.c linux-2.6.30.5-mod/drivers/net/bna/bna_if.c
--- linux-2.6.30.5-orig/drivers/net/bna/bna_if.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bna_if.c	2009-08-28 21:09:23.313886000 -0700
@@ -0,0 +1,615 @@
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
+ *	file bna_if.c BNA Hardware and Firmware Interface
+ */
+#include <bna_os.h>
+#include <bna_log_trc.h>
+#include "bna.h"
+#include "bna_hwreg.h"
+#include "bna_priv.h"
+#include "bna_iocll.h"
+#include "bna_intr.h"
+#include "bna_trcmod.h"
+#include <bfi/bfi_cee.h>
+#include <aen/bfa_aen.h>
+#include <aen/bfa_aen_port.h>
+#include <aen/bfa_aen_ethport.h>
+#include <protocol/types.h>
+#include <cee/bfa_cee.h>
+
+
+
+BNA_TRC_FILE(HAL, IF);
+
+#define BNA_FLASH_DMA_BUF_SZ	0x010000	/* 64K */
+
+#define DO_CALLBACK(cbfn)	\
+do {				\
+	if (mb_cbfns->cbfn) {      \
+		if (qe && qe->cbarg) {      \
+			(mb_cbfns->cbfn)(qe->cbarg, status);      \
+		} else {					\
+			(mb_cbfns->cbfn)(dev->cbarg, status);      \
+		}			\
+	}			\
+} while (0)
+
+#define bna_mbox_q_is_empty(mb_q)		\
+	((mb_q)->producer_index == 		\
+	    (mb_q)->consumer_index)
+
+#define bna_mbox_q_first(mb_q)			\
+	 (&(mb_q)->mb_qe[(mb_q)->consumer_index])
+
+/* FIXME : Should come from the driver */
+static u32 bna_ioc_auto_recover;
+
+/**
+ * bna_register_callback()
+ *
+ *	  Function called by the driver to register a callback
+ *	  with the BNA
+ *
+ * @param[in] bna_dev   - Opaque handle to BNA private device
+ * @param[in] cbfns	- Structure for the callback functions.
+ * @param[in] cbarg	- Argument to use with the callback
+ * @param[in] cmd_code  - Command code exported to the drivers
+ *
+ * @return void
+ */
+void
+bna_register_callback(struct bna_dev_s *dev, struct bna_mbox_cbfn *cbfns,
+		      void *cbarg)
+{
+	bna_os_memcpy(&dev->mb_cbfns, cbfns, sizeof(dev->mb_cbfns));
+	dev->cbarg = cbarg;
+}
+
+void
+bna_mbox_q_init(struct bna_mbox_q *q)
+{
+	BNA_ASSERT(BNA_POWER_OF_2(BNA_MAX_MBOX_CMD_QUEUE));
+
+	q->producer_index = q->consumer_index = 0;
+	q->posted = NULL;
+}
+
+static struct bna_mbox_cmd_qe *
+bna_mbox_enq(struct bna_mbox_q *mbox_q, void *cmd, u32 cmd_len, void *cbarg)
+{
+	struct bna_mbox_cmd_qe *qe;
+
+	if (!BNA_QE_FREE_CNT(mbox_q, BNA_MAX_MBOX_CMD_QUEUE)) {
+		BNA_LOG_WARN(("No free Mbox Command Element\n"));
+		return NULL;
+	}
+
+	BNA_LOG_DEBUG(("Mbox PI 0x%x\n", mbox_q->producer_index));
+
+	qe = &mbox_q->mb_qe[mbox_q->producer_index];
+	BNA_QE_INDX_ADD(mbox_q->producer_index, 1, BNA_MAX_MBOX_CMD_QUEUE);
+	bna_os_memcpy(&qe->cmd.msg[0], cmd, cmd_len);
+	qe->cmd_len = cmd_len;
+	qe->cbarg = cbarg;
+
+	return qe;
+}
+
+static void
+bna_mbox_deq(struct bna_mbox_q *mbox_q)
+{
+
+	BNA_LOG_DEBUG(("Mbox CI 0x%x\n", mbox_q->consumer_index));
+
+	/* Free one from the head */
+	BNA_QE_INDX_ADD(mbox_q->consumer_index, 1, BNA_MAX_MBOX_CMD_QUEUE);
+}
+
+static void
+bna_do_stats_update(struct bna_dev_s *dev, u8 status)
+{
+	if (status != BFI_LL_CMD_OK)
+		return;
+	bna_stats_process(dev);
+}
+
+static void
+bna_port_aen_post(struct bna_dev_s *dev, enum bfa_ethport_aen_event event)
+{
+	union bfa_aen_data_u aen_data;
+
+	aen_data.ethport.mac = bfa_ioc_get_mac(&dev->ioc);
+
+}
+
+static void
+bna_do_drv_ll_cb(struct bna_dev_s *dev, u8 cmd_code,
+		 u8 status, struct bna_mbox_cmd_qe *qe)
+{
+	struct bna_mbox_cbfn *mb_cbfns = &dev->mb_cbfns;
+
+	switch (cmd_code) {
+	case BFI_LL_I2H_MAC_UCAST_SET_RSP:
+		DO_CALLBACK(ucast_set_cb);
+		break;
+	case BFI_LL_I2H_MAC_UCAST_ADD_RSP:
+		DO_CALLBACK(ucast_add_cb);
+		break;
+	case BFI_LL_I2H_MAC_UCAST_DEL_RSP:
+		DO_CALLBACK(ucast_del_cb);
+		break;
+	case BFI_LL_I2H_MAC_MCAST_ADD_RSP:
+		DO_CALLBACK(mcast_add_cb);
+		break;
+	case BFI_LL_I2H_MAC_MCAST_DEL_RSP:
+		DO_CALLBACK(mcast_del_cb);
+		break;
+	case BFI_LL_I2H_MAC_MCAST_FILTER_RSP:
+		DO_CALLBACK(mcast_filter_cb);
+		break;
+	case BFI_LL_I2H_MAC_MCAST_DEL_ALL_RSP:
+		DO_CALLBACK(mcast_del_all_cb);
+		break;
+	case BFI_LL_I2H_RXF_PROMISCUOUS_SET_RSP:
+		DO_CALLBACK(set_promisc_cb);
+		break;
+	case BFI_LL_I2H_RXF_DEFAULT_SET_RSP:
+		DO_CALLBACK(set_default_cb);
+		break;
+	case BFI_LL_I2H_TXQ_STOP_RSP:
+		DO_CALLBACK(txq_stop_cb);
+		break;
+	case BFI_LL_I2H_RXQ_STOP_RSP:
+		DO_CALLBACK(rxq_stop_cb);
+		break;
+	case BFI_LL_I2H_PORT_ADMIN_RSP:
+		DO_CALLBACK(port_admin_cb);
+		{
+			struct bfi_ll_port_admin_req *pa =
+				(struct bfi_ll_port_admin_req *) (&qe->cmd.
+								  msg[0]);
+			if (pa->up)
+				bna_port_aen_post(dev, BFA_ETHPORT_AEN_ENABLE);
+			else
+				bna_port_aen_post(dev, BFA_ETHPORT_AEN_DISABLE);
+
+		}
+		break;
+	case BFI_LL_I2H_STATS_GET_RSP:
+		bna_do_stats_update(dev, status);
+		DO_CALLBACK(stats_get_cb);
+		break;
+	case BFI_LL_I2H_STATS_CLEAR_RSP:
+		DO_CALLBACK(stats_clr_cb);
+		break;
+	case BFI_LL_I2H_LINK_DOWN_AEN:
+		DO_CALLBACK(link_down_cb);
+		bna_port_aen_post(dev, BFA_ETHPORT_AEN_LINKDOWN);
+		break;
+	case BFI_LL_I2H_LINK_UP_AEN:
+		DO_CALLBACK(link_up_cb);
+		bna_port_aen_post(dev, BFA_ETHPORT_AEN_LINKUP);
+		break;
+	case BFI_LL_I2H_DIAG_LOOPBACK_RSP:
+		DO_CALLBACK(set_diag_lb_cb);
+		break;
+	case BFI_LL_I2H_SET_PAUSE_RSP:
+		DO_CALLBACK(set_pause_cb);
+		break;
+	case BFI_LL_I2H_MTU_INFO_RSP:
+		DO_CALLBACK(mtu_info_cb);
+		break;
+	case BFI_LL_I2H_RX_RSP:
+		DO_CALLBACK(rxf_cb);
+		break;
+	case BFI_LL_I2H_CEE_DOWN_AEN:
+		break;
+	case BFI_LL_I2H_CEE_UP_AEN:
+		break;
+	default:
+		BNA_LOG_WARN(("cb(): unknown msg Id %d for LL class\n",
+			      cmd_code));
+		break;
+	}
+}
+
+
+static enum bna_status_e
+bna_flush_mbox_q(struct bna_dev_s *dev, u8 wait_for_rsp)
+{
+	struct bna_mbox_q *q;
+	struct bna_mbox_cmd_qe *qe = NULL;
+	u8 msg_id = 0, msg_class = 0;
+
+	q = &dev->mbox_q;
+
+	if (bna_mbox_q_is_empty(q)) {
+		BNA_TRACE(dev, wait_for_rsp);
+		return BNA_OK;
+	}
+	if (q->posted != NULL && wait_for_rsp) {
+		qe = (struct bna_mbox_cmd_qe *) (q->posted);
+		/* The driver has to retry */
+		BNA_TRACE(dev, *((u32 *) (&qe->cmd.msg[0])));
+		return BNA_BUSY;
+	}
+
+	BNA_TRACE(dev, dev->port);
+	while (!bna_mbox_q_is_empty(q)) {
+		qe = bna_mbox_q_first(q);
+		msg_class =
+			((struct bfi_mhdr_s *) (&qe->cmd.msg[0]))->msg_class;
+		msg_id = ((struct bfi_mhdr_s *) (&qe->cmd.msg[0]))->msg_id;
+
+		BNA_TRACE(dev, *((u32 *) (&qe->cmd.msg[0])));
+
+		BNA_ASSERT(msg_class == BFI_MC_LL);
+
+		bna_do_drv_ll_cb(dev, BFA_I2HM(msg_id), BFI_LL_CMD_NOT_EXEC,
+				 qe);
+		bna_mbox_deq(q);
+	}
+	/* Reinit the queue, i.e prod = cons = 0; */
+	bna_mbox_q_init(q);
+	return BNA_OK;
+}
+
+enum bna_status_e
+bna_cleanup(void *bna_dev)
+{
+	struct bna_dev_s *dev = (struct bna_dev_s *) bna_dev;
+
+	dev->msg_ctr = 0;
+
+	return bna_flush_mbox_q(dev, 0);
+}
+
+/**
+ * Check both command queues
+ * Write to mailbox if required
+ */
+static enum bna_status_e
+bna_chk_n_snd_q(struct bna_dev_s *dev)
+{
+	struct bna_mbox_cmd_qe *qe = NULL;
+	struct bna_mbox_q *q;
+	struct bfi_mhdr_s *mh = NULL;
+
+	q = &dev->mbox_q;
+
+	if ((bna_mbox_q_is_empty(q)) || (q->posted != NULL)) {
+		BNA_TRACE(dev, dev->port);
+		return BNA_OK;
+	}
+
+	qe = bna_mbox_q_first(q);
+	/* Do not post any more commands if disable pending */
+	if (dev->ioc_disable_pending == 1) {
+		BNA_TRACE(dev, *((u32 *) (&qe->cmd.msg[0])));
+		return BNA_OK;
+	}
+
+	mh = ((struct bfi_mhdr_s *) (&qe->cmd.msg[0]));
+	mh->mtag.i2htok = bna_os_htons(dev->msg_ctr);
+	dev->msg_ctr++;
+	bfa_ioc_mbox_queue(&dev->ioc, &qe->cmd);
+	q->posted = qe;
+
+	return BNA_OK;
+}
+
+enum bna_status_e
+bna_mbox_send(struct bna_dev_s *dev, void *cmd, u32 cmd_len, void *cbarg)
+{
+	struct bna_mbox_cmd_qe *qe;
+	struct bna_mbox_q *q;
+	struct bfi_mhdr_s *mh = (struct bfi_mhdr_s *) cmd;
+
+	BNA_ASSERT(cmd_len <= BNA_MAX_MBOX_CMD_LEN);
+
+	if (dev->ioc_disable_pending) {
+		BNA_TRACE_WARN(dev, *((u32 *) cmd),
+			       ("IOC Disable is pending : Cannot queue Cmd "
+				"class %d id %d\n", mh->msg_class, mh->msg_id));
+		return BNA_FAIL;
+	}
+
+	if (!bfa_ioc_is_operational(&dev->ioc)) {
+		BNA_TRACE_ERROR(dev, *((u32 *) cmd),
+				("IOC is not operational : Cannot queue Cmd "
+				 "class %d id %d\n", mh->msg_class,
+				 mh->msg_id));
+		return BNA_FAIL;
+	}
+
+	q = &dev->mbox_q;
+	qe = bna_mbox_enq(q, cmd, cmd_len, cbarg);
+	if (qe == NULL)
+		return BNA_FAIL;
+
+	BNA_TRACE(dev, *(u32 *) cmd);
+	return bna_chk_n_snd_q(dev);
+}
+
+
+/**
+ * Returns 1, if this is an aen, 0 otherwise
+ */
+static int
+bna_is_aen(u8 msg_id)
+{
+	return (msg_id == BFI_LL_I2H_LINK_DOWN_AEN ||
+		msg_id == BFI_LL_I2H_LINK_UP_AEN ||
+		msg_id == BFI_LL_I2H_CEE_DOWN_AEN
+		|| msg_id == BFI_LL_I2H_CEE_UP_AEN);
+}
+
+static void
+bna_err_handler(struct bna_dev_s *dev, u32 intr_status)
+{
+	u32 curr_mask;
+
+	BNA_LOG_DEBUG(("HW ERROR : INT statux 0x%x on port %d\n",
+		       intr_status, dev->port));
+
+	bfa_ioc_error_isr(&dev->ioc);
+
+	/*
+	 * Disable all the bits in interrupt mask, including
+	 * the mbox & error bits.
+	 * This is required so that once h/w error hits, we don't
+	 * get into a loop.
+	 */
+	bna_intx_disable(dev, &curr_mask);
+
+	if (dev->mb_cbfns.hw_error_cb)
+		(dev->mb_cbfns.hw_error_cb) (dev->cbarg, 0);
+}
+
+void
+bna_ll_isr(void *llarg, struct bfi_mbmsg_s *msg)
+{
+	u32 aen = 0;
+	struct bna_dev_s *dev = (struct bna_dev_s *) llarg;
+	struct bna_mbox_cmd_qe *qe = NULL;
+	struct bna_mbox_q *mbox_q = NULL;
+	struct bfi_ll_rsp *mb_rsp = NULL;
+
+	mb_rsp = (struct bfi_ll_rsp *) (msg);
+
+	BNA_ASSERT(mb_rsp->mh.msg_class == BFI_MC_LL);
+	BNA_TRACE(dev, *(u32 *) (&mb_rsp->mh));
+
+	aen = bna_is_aen(mb_rsp->mh.msg_id);
+	if (!aen) {
+		mbox_q = &dev->mbox_q;
+
+		BNA_ASSERT(!bna_mbox_q_is_empty(mbox_q));
+		qe = bna_mbox_q_first(mbox_q);
+		BNA_ASSERT(mbox_q->posted == qe);
+
+		if (BFA_I2HM(((struct bfi_mhdr_s *) (&qe->cmd.msg[0]))->msg_id)
+		    != mb_rsp->mh.msg_id) {
+			BNA_TRACE_ERROR(dev, *((u32 *) (&qe->cmd.msg[0])),
+					("Invalid Rsp Msg %d:%d (Expected %d:%d) "
+					 "on %d\n", mb_rsp->mh.msg_class,
+					 mb_rsp->mh.msg_id,
+					 ((struct bfi_mhdr_s *) (&qe->cmd.
+								 msg[0]))->
+					 msg_class,
+					 BFA_I2HM(((struct bfi_mhdr_s *)
+						   (&qe->cmd.msg[0]))->msg_id),
+					 dev->port));
+			BNA_ASSERT(0);
+			return;
+		}
+		bna_mbox_deq(mbox_q);
+		mbox_q->posted = NULL;
+	}
+	bna_do_drv_ll_cb(dev, mb_rsp->mh.msg_id, mb_rsp->error, qe);
+	bna_chk_n_snd_q(dev);
+}
+
+
+void
+bna_mbox_err_handler(struct bna_dev_s *dev, u32 intr_status)
+{
+	if (BNA_IS_ERR_INTR(intr_status)) {
+		bna_err_handler(dev, intr_status);
+		return;
+	}
+
+	if (BNA_IS_MBOX_INTR(intr_status))
+		bfa_ioc_mbox_isr(&dev->ioc);
+}
+
+/**
+ * bna_port_admin()
+ *
+ *   Enable (up) or disable (down) the interface administratively.
+ *
+ * @param[in]  dev	- pointer to BNA device structure
+ * @param[in]  enable - enable/disable the interface.
+ *
+ * @return BNA_OK or BNA_FAIL
+ */
+enum bna_status_e
+bna_port_admin(struct bna_dev_s *bna_dev, enum bna_enable_e enable)
+{
+	struct bna_dev_s *dev = (struct bna_dev_s *) bna_dev;
+	struct bfi_ll_port_admin_req ll_req;
+
+	ll_req.mh.msg_class = BFI_MC_LL;
+	ll_req.mh.msg_id = BFI_LL_H2I_PORT_ADMIN_REQ;
+	ll_req.mh.mtag.i2htok = 0;
+
+	ll_req.up = enable;
+
+	/* send to f/w */
+	return bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+}
+
+/**
+ * bna_port_param_get()
+ *
+ *   Get the port parameters.
+ *
+ * @param[in]   dev	   - pointer to BNA device structure
+ * @param[out]  param_ptr - pointer to where the parameters will be returned.
+ *
+ * @return void
+ */
+void
+bna_port_param_get(struct bna_dev_s *dev, struct bna_port_param *param_ptr)
+{
+	param_ptr->supported = BNA_TRUE;
+	param_ptr->advertising = BNA_TRUE;
+	param_ptr->speed = BNA_LINK_SPEED_10Gbps;
+	param_ptr->duplex = BNA_TRUE;
+	param_ptr->autoneg = BNA_FALSE;
+	param_ptr->port = dev->port;
+}
+
+/**
+ * bna_port_mac_get()
+ *
+ *   Get the Burnt-in or permanent MAC address.  This function does not return
+ *   the MAC set thru bna_rxf_ucast_mac_set() but the one that is assigned to
+ *   the port upon reset.
+ *
+ * @param[in]  dev	 - pointer to BNA device structure
+ * @param[out] mac_ptr - Burnt-in or permanent MAC address.
+ *
+ * @return void
+ */
+void
+bna_port_mac_get(struct bna_dev_s *bna_dev, bna_mac_t * mac_ptr)
+{
+	struct bna_dev_s *dev = (struct bna_dev_s *) bna_dev;
+	mac_t mac;
+
+	mac = bfa_ioc_get_mac(&dev->ioc);
+
+	/* TODO : Use mac_t, remove memcpy */
+	bna_os_memcpy(mac_ptr, &mac, sizeof(*mac_ptr));
+}
+
+/**
+ *	IOC Integration
+ */
+
+/**
+ *	bfa_iocll_cbfn
+ *	Structure for callbacks to be implemented by
+ *	the driver.
+ */
+static struct bfa_ioc_cbfn_s bfa_iocll_cbfn = {
+	bna_iocll_enable_cbfn,
+	bna_iocll_disable_cbfn,
+	bna_iocll_hbfail_cbfn,
+	bna_iocll_reset_cbfn
+};
+
+
+static void
+bna_iocll_memclaim(struct bna_dev_s *dev, struct bna_meminfo *mi)
+{
+
+	bfa_ioc_mem_claim(&dev->ioc, mi[BNA_DMA_MEM_T_ATTR].kva,
+			  mi[BNA_DMA_MEM_T_ATTR].dma);
+
+	if (bna_ioc_auto_recover)
+		bfa_ioc_debug_memclaim(&dev->ioc, mi[BNA_KVA_MEM_T_FWTRC].kva);
+}
+
+void
+bna_iocll_meminfo(struct bna_dev_s *dev, struct bna_meminfo *mi)
+{
+
+
+	mi[BNA_DMA_MEM_T_ATTR].len =
+		BNA_ALIGN(bfa_ioc_meminfo(), BNA_PAGE_SIZE);
+
+	mi[BNA_KVA_MEM_T_FWTRC].len = bfa_ioc_debug_trcsz(bna_ioc_auto_recover);
+}
+
+void
+bna_iocll_attach(struct bna_dev_s *dev, void *bnad,
+		 struct bna_meminfo *meminfo, struct bfa_pcidev_s *pcidev,
+		 struct bfa_trc_mod_s *trcmod, struct bfa_aen_s *aen,
+		 struct bfa_log_mod_s *logm)
+{
+	bfa_ioc_attach(&dev->ioc, bnad, &bfa_iocll_cbfn, &dev->timer_mod,
+		       trcmod, aen, logm);
+	bfa_ioc_pci_init(&dev->ioc, pcidev, BFI_MC_LL);
+
+	bfa_ioc_mbox_regisr(&dev->ioc, BFI_MC_LL, bna_ll_isr, dev);
+	bna_iocll_memclaim(dev, meminfo);
+
+
+	bfa_timer_init(&dev->timer_mod);
+
+}
+
+/**
+ * FIXME :
+ * Either the driver or CAL should serialize
+ * this IOC disable
+ * Currently this is happening indirectly b'cos
+ * bfa_ioc_disable() is not called if there
+ * is an outstanding cmd in the queue, which
+ * could not be flushed.
+ */
+enum bna_status_e
+bna_iocll_disable(struct bna_dev_s *dev)
+{
+	enum bna_status_e ret;
+
+	dev->ioc_disable_pending = 1;
+	if ((ret = bna_flush_mbox_q(dev, 1)) != BNA_OK) {
+		BNA_LOG_WARN(("Unable to flush Mbox Queues [%d]\n", ret));
+		return ret;
+	}
+
+	bfa_ioc_disable(&dev->ioc);
+	dev->ioc_disable_pending = 0;
+
+	return BNA_OK;
+}
+
+void
+bna_iocll_getinfo(struct bna_dev_s *dev, char *serial_num, u32 size)
+{
+	struct bfa_adapter_attr_s ad_attr;
+	u32 length;
+
+	bfa_ioc_get_adapter_attr(&dev->ioc, &ad_attr);
+	length = BNA_MIN(size, sizeof(ad_attr.serial_num));
+	bna_os_memcpy(serial_num, ad_attr.serial_num, length);
+}
+
+/* Dummy */
+/* FIXME : Delete once bfa_diag.c is fixed */
+void
+bfa_pport_beacon(struct bfa_s *bfa, bfa_boolean_t beacon,
+		 bfa_boolean_t link_e2e_beacon)
+{
+}
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bna_iocll.h linux-2.6.30.5-mod/drivers/net/bna/bna_iocll.h
--- linux-2.6.30.5-orig/drivers/net/bna/bna_iocll.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bna_iocll.h	2009-08-28 21:09:23.448899000 -0700
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
+
+#ifndef __BNA_IOCLL_H__
+#define __BNA_IOCLL_H__
+
+#include <bfa.h>
+#include <bfa_ioc.h>
+#include <bfa_timer.h>
+#include <bfi/bfi_ll.h>
+
+#define BNA_IOC_TIMER_FREQ BFA_TIMER_FREQ
+
+/*
+ * LL specific IOC functions.
+ */
+void bna_iocll_meminfo(struct bna_dev_s *bna_dev, struct bna_meminfo *meminfo);
+void bna_iocll_attach(struct bna_dev_s *bna_dev, void *bnad,
+		      struct bna_meminfo *meminfo,
+		      struct bfa_pcidev_s *pcidev,
+		      struct bfa_trc_mod_s *trcmod, struct bfa_aen_s *aen,
+		      struct bfa_log_mod_s *logmod);
+enum bna_status_e bna_iocll_disable(struct bna_dev_s *bna_dev);
+void bna_iocll_getinfo(struct bna_dev_s *bna_dev, char *serial_num, u32 size);
+#define bna_iocll_detach(dev) bfa_ioc_detach(&((dev)->ioc))
+#define bna_iocll_enable(dev) bfa_ioc_enable(&((dev)->ioc))
+#define bna_iocll_debug_fwsave(dev, trc_data, trc_len)		\
+	bfa_ioc_debug_fwsave(&((dev)->ioc), (trc_data), (trc_len))
+#define bna_iocll_debug_fwtrc(dev, trc_data, trc_len)		\
+	bfa_ioc_debug_fwtrc(&((dev)->ioc), (trc_data), (trc_len))
+#define bna_iocll_timer(dev) bfa_timer_beat(&((dev)->timer_mod))
+#define bna_iocll_getstats(dev, ioc_stats)	\
+	bfa_ioc_fetch_stats(&((dev)->ioc), (ioc_stats))
+#define bna_iocll_resetstats(dev) bfa_ioc_clr_stats(&((dev)->ioc))
+#define bna_iocll_getattr(dev, ioc_attr)	\
+	bfa_ioc_get_attr(&((dev)->ioc), (ioc_attr))
+
+/**
+ * Callback functions to be implemented by the driver
+ */
+void bna_iocll_enable_cbfn(void *bnad, enum bfa_status status);
+void bna_iocll_disable_cbfn(void *bnad);
+void bna_iocll_hbfail_cbfn(void *bnad);
+void bna_iocll_reset_cbfn(void *bnad);
+
+#endif /* __BNA_IOCLL_H__ */
