From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 5/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 10 Aug 2010 21:48:36 -0700
Message-ID: <201008110448.o7B4mamG014679@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:32958 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750920Ab0HKEsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 00:48:39 -0400
Received: from pps.filterd (m0000542 [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.14.3/8.14.3) with SMTP id o7B4jJZ5005768
	for <netdev@vger.kernel.org>; Tue, 10 Aug 2010 21:48:39 -0700
Received: from hq-exedge.brocade.com (hq-exedge.brocade.com [66.243.153.82])
	by mx0a-000f0801.pphosted.com with ESMTP id qkmbv80qv-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 10 Aug 2010 21:48:37 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 5/6 which contains linux driver source for
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
Source is based against net-next-2.6.

We wish this patch to be considered for inclusion in net-next-2.6

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 bfa_cee.h           |   72 +++++
 bfa_defs.h          |  243 +++++++++++++++++++
 bfa_defs_cna.h      |  223 ++++++++++++++++++
 bfa_defs_mfg_comm.h |  244 +++++++++++++++++++
 bfa_defs_status.h   |  216 +++++++++++++++++
 bfa_ioc.h           |  343 ++++++++++++++++++++++++++++
 bfa_sm.h            |   88 +++++++
 bfa_wc.h            |   69 +++++
 bfi.h               |  392 ++++++++++++++++++++++++++++++++
 bfi_cna.h           |  199 ++++++++++++++++
 bfi_ctreg.h         |  637 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 bfi_ll.h            |  438 +++++++++++++++++++++++++++++++++++
 cna.h               |   81 ++++++
 13 files changed, 3245 insertions(+)

diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_cee.h net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_cee.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_cee.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_cee.h	2010-08-10 12:23:09.966138000 -0700
@@ -0,0 +1,72 @@
+/*
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
+ */
+
+#ifndef __BFA_CEE_H__
+#define __BFA_CEE_H__
+
+#include "bfa_defs_cna.h"
+#include "bfa_ioc.h"
+
+typedef void (*bfa_cee_get_attr_cbfn_t) (void *dev, enum bfa_status status);
+typedef void (*bfa_cee_get_stats_cbfn_t) (void *dev, enum bfa_status status);
+typedef void (*bfa_cee_reset_stats_cbfn_t) (void *dev, enum bfa_status status);
+typedef void (*bfa_cee_hbfail_cbfn_t) (void *dev, enum bfa_status status);
+
+struct bfa_cee_cbfn {
+	bfa_cee_get_attr_cbfn_t    get_attr_cbfn;
+	void *get_attr_cbarg;
+	bfa_cee_get_stats_cbfn_t   get_stats_cbfn;
+	void *get_stats_cbarg;
+	bfa_cee_reset_stats_cbfn_t reset_stats_cbfn;
+	void *reset_stats_cbarg;
+};
+
+struct bfa_cee {
+	void *dev;
+	bool get_attr_pending;
+	bool get_stats_pending;
+	bool reset_stats_pending;
+	enum bfa_status get_attr_status;
+	enum bfa_status get_stats_status;
+	enum bfa_status reset_stats_status;
+	struct bfa_cee_cbfn cbfn;
+	struct bfa_ioc_hbfail_notify hbfail;
+	struct bfa_cee_attr *attr;
+	struct bfa_cee_stats *stats;
+	struct bfa_dma attr_dma;
+	struct bfa_dma stats_dma;
+	struct bfa_ioc *ioc;
+	struct bfa_mbox_cmd get_cfg_mb;
+	struct bfa_mbox_cmd get_stats_mb;
+	struct bfa_mbox_cmd reset_stats_mb;
+};
+
+u32 bfa_cee_meminfo(void);
+void bfa_cee_mem_claim(struct bfa_cee *cee, u8 *dma_kva,
+	u64 dma_pa);
+void bfa_cee_attach(struct bfa_cee *cee, struct bfa_ioc *ioc, void *dev);
+void bfa_cee_detach(struct bfa_cee *cee);
+enum bfa_status bfa_cee_get_attr(struct bfa_cee *cee,
+	struct bfa_cee_attr *attr, bfa_cee_get_attr_cbfn_t cbfn, void *cbarg);
+enum bfa_status bfa_cee_get_stats(struct bfa_cee *cee,
+	struct bfa_cee_stats *stats, bfa_cee_get_stats_cbfn_t cbfn,
+	void *cbarg);
+enum bfa_status bfa_cee_reset_stats(struct bfa_cee *cee,
+	bfa_cee_reset_stats_cbfn_t cbfn, void *cbarg);
+
+#endif /* __BFA_CEE_H__ */
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_defs.h net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_defs.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_defs.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_defs.h	2010-08-10 12:23:10.019139000 -0700
@@ -0,0 +1,243 @@
+/*
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
+ */
+
+#ifndef __BFA_DEFS_H__
+#define __BFA_DEFS_H__
+
+#include "cna.h"
+#include "bfa_defs_status.h"
+#include "bfa_defs_mfg_comm.h"
+
+#define BFA_STRING_32	32
+#define BFA_VERSION_LEN 64
+
+/**
+ * ---------------------- adapter definitions ------------
+ */
+
+/**
+ * BFA adapter level attributes.
+ */
+enum {
+	BFA_ADAPTER_SERIAL_NUM_LEN = STRSZ(BFA_MFG_SERIALNUM_SIZE),
+					/*
+					 *!< adapter serial num length
+					 */
+	BFA_ADAPTER_MODEL_NAME_LEN  = 16,  /*!< model name length */
+	BFA_ADAPTER_MODEL_DESCR_LEN = 128, /*!< model description length */
+	BFA_ADAPTER_MFG_NAME_LEN    = 8,   /*!< manufacturer name length */
+	BFA_ADAPTER_SYM_NAME_LEN    = 64,  /*!< adapter symbolic name length */
+	BFA_ADAPTER_OS_TYPE_LEN	    = 64,  /*!< adapter os type length */
+};
+
+struct bfa_adapter_attr {
+	char		manufacturer[BFA_ADAPTER_MFG_NAME_LEN];
+	char		serial_num[BFA_ADAPTER_SERIAL_NUM_LEN];
+	u32	card_type;
+	char		model[BFA_ADAPTER_MODEL_NAME_LEN];
+	char		model_descr[BFA_ADAPTER_MODEL_DESCR_LEN];
+	u64		pwwn;
+	char		node_symname[FC_SYMNAME_MAX];
+	char		hw_ver[BFA_VERSION_LEN];
+	char		fw_ver[BFA_VERSION_LEN];
+	char		optrom_ver[BFA_VERSION_LEN];
+	char		os_type[BFA_ADAPTER_OS_TYPE_LEN];
+	struct bfa_mfg_vpd vpd;
+	struct mac mac;
+
+	u8		nports;
+	u8		max_speed;
+	u8		prototype;
+	char	        asic_rev;
+
+	u8		pcie_gen;
+	u8		pcie_lanes_orig;
+	u8		pcie_lanes;
+	u8	        cna_capable;
+
+	u8		is_mezz;
+	u8		trunk_capable;
+};
+
+/**
+ * ---------------------- IOC definitions ------------
+ */
+
+enum {
+	BFA_IOC_DRIVER_LEN	= 16,
+	BFA_IOC_CHIP_REV_LEN 	= 8,
+};
+
+/**
+ * Driver and firmware versions.
+ */
+struct bfa_ioc_driver_attr {
+	char		driver[BFA_IOC_DRIVER_LEN];	/*!< driver name */
+	char		driver_ver[BFA_VERSION_LEN];	/*!< driver version */
+	char		fw_ver[BFA_VERSION_LEN];	/*!< firmware version */
+	char		bios_ver[BFA_VERSION_LEN];	/*!< bios version */
+	char		efi_ver[BFA_VERSION_LEN];	/*!< EFI version */
+	char		ob_ver[BFA_VERSION_LEN];	/*!< openboot version */
+};
+
+/**
+ * IOC PCI device attributes
+ */
+struct bfa_ioc_pci_attr {
+	u16	vendor_id;	/*!< PCI vendor ID */
+	u16	device_id;	/*!< PCI device ID */
+	u16	ssid;		/*!< subsystem ID */
+	u16	ssvid;		/*!< subsystem vendor ID */
+	u32	pcifn;		/*!< PCI device function */
+	u32	rsvd;		/* padding */
+	char		chip_rev[BFA_IOC_CHIP_REV_LEN];	 /*!< chip revision */
+};
+
+/**
+ * IOC states
+ */
+enum bfa_ioc_state {
+	BFA_IOC_RESET		= 1,	/*!< IOC is in reset state */
+	BFA_IOC_SEMWAIT		= 2,	/*!< Waiting for IOC h/w semaphore */
+	BFA_IOC_HWINIT		= 3,	/*!< IOC h/w is being initialized */
+	BFA_IOC_GETATTR		= 4,	/*!< IOC is being configured */
+	BFA_IOC_OPERATIONAL	= 5,	/*!< IOC is operational */
+	BFA_IOC_INITFAIL	= 6,	/*!< IOC hardware failure */
+	BFA_IOC_HBFAIL		= 7,	/*!< IOC heart-beat failure */
+	BFA_IOC_DISABLING	= 8,	/*!< IOC is being disabled */
+	BFA_IOC_DISABLED	= 9,	/*!< IOC is disabled */
+	BFA_IOC_FWMISMATCH	= 10,	/*!< IOC f/w different from drivers */
+};
+
+/**
+ * IOC firmware stats
+ */
+struct bfa_fw_ioc_stats {
+	u32	enable_reqs;
+	u32	disable_reqs;
+	u32	get_attr_reqs;
+	u32	dbg_sync;
+	u32	dbg_dump;
+	u32	unknown_reqs;
+};
+
+/**
+ * IOC driver stats
+ */
+struct bfa_ioc_drv_stats {
+	u32	ioc_isrs;
+	u32	ioc_enables;
+	u32	ioc_disables;
+	u32	ioc_hbfails;
+	u32	ioc_boots;
+	u32	stats_tmos;
+	u32	hb_count;
+	u32	disable_reqs;
+	u32	enable_reqs;
+	u32	disable_replies;
+	u32	enable_replies;
+};
+
+/**
+ * IOC statistics
+ */
+struct bfa_ioc_stats {
+	struct bfa_ioc_drv_stats drv_stats; /*!< driver IOC stats */
+	struct bfa_fw_ioc_stats fw_stats;  /*!< firmware IOC stats */
+};
+
+enum bfa_ioc_type {
+	BFA_IOC_TYPE_FC		= 1,
+	BFA_IOC_TYPE_FCoE	= 2,
+	BFA_IOC_TYPE_LL		= 3,
+};
+
+/**
+ * IOC attributes returned in queries
+ */
+struct bfa_ioc_attr {
+	enum bfa_ioc_type ioc_type;
+	enum bfa_ioc_state 		state;		/*!< IOC state      */
+	struct bfa_adapter_attr adapter_attr;	/*!< HBA attributes */
+	struct bfa_ioc_driver_attr driver_attr;	/*!< driver attr    */
+	struct bfa_ioc_pci_attr pci_attr;
+	u8				port_id;	/*!< port number    */
+	u8				rsvd[7];	/*!< 64bit align    */
+};
+
+/**
+ * ---------------------- mfg definitions ------------
+ */
+
+/**
+ * Checksum size
+ */
+#define BFA_MFG_CHKSUM_SIZE			16
+
+#define BFA_MFG_PARTNUM_SIZE			14
+#define BFA_MFG_SUPPLIER_ID_SIZE		10
+#define BFA_MFG_SUPPLIER_PARTNUM_SIZE		20
+#define BFA_MFG_SUPPLIER_SERIALNUM_SIZE		20
+#define BFA_MFG_SUPPLIER_REVISION_SIZE		4
+
+#pragma pack(1)
+
+/**
+ * @brief BFA adapter manufacturing block definition.
+ *
+ * All numerical fields are in big-endian format.
+ */
+struct bfa_mfg_block {
+	u8		version;	/*!< manufacturing block version */
+	u8		mfg_sig[3];	/*!< characters 'M', 'F', 'G' */
+	u16	mfgsize;	/*!< mfg block size */
+	u16	u16_chksum;	/*!< old u16 checksum */
+	char		brcd_serialnum[STRSZ(BFA_MFG_SERIALNUM_SIZE)];
+	char		brcd_partnum[STRSZ(BFA_MFG_PARTNUM_SIZE)];
+	u8		mfg_day;	/*!< manufacturing day */
+	u8		mfg_month;	/*!< manufacturing month */
+	u16	mfg_year;	/*!< manufacturing year */
+	u64		mfg_wwn;	/*!< wwn base for this adapter */
+	u8		num_wwn;	/*!< number of wwns assigned */
+	u8		mfg_speeds;	/*!< speeds allowed for this adapter */
+	u8		rsv[2];
+	char		supplier_id[STRSZ(BFA_MFG_SUPPLIER_ID_SIZE)];
+	char		supplier_partnum[STRSZ(BFA_MFG_SUPPLIER_PARTNUM_SIZE)];
+	char
+		supplier_serialnum[STRSZ(BFA_MFG_SUPPLIER_SERIALNUM_SIZE)];
+	char
+		supplier_revision[STRSZ(BFA_MFG_SUPPLIER_REVISION_SIZE)];
+	mac_t		mfg_mac;	/*!< mac address */
+	u8		num_mac;	/*!< number of mac addresses */
+	u8		rsv2;
+	u32	mfg_type;	/*!< card type */
+	u8		rsv3[108];
+	u8		md5_chksum[BFA_MFG_CHKSUM_SIZE]; /*!< md5 checksum */
+};
+
+#pragma pack()
+
+/**
+ * ---------------------- pci definitions ------------
+ */
+
+#define bfa_asic_id_ct(devid)			\
+	((devid) == PCI_DEVICE_ID_BROCADE_CT ||	\
+	(devid) == PCI_DEVICE_ID_BROCADE_CT_FC)
+
+#endif /* __BFA_DEFS_H__ */
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_defs_cna.h net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_defs_cna.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_defs_cna.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_defs_cna.h	2010-08-10 12:23:10.027137000 -0700
@@ -0,0 +1,223 @@
+/*
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
+ */
+
+#ifndef __BFA_DEFS_CNA_H__
+#define __BFA_DEFS_CNA_H__
+
+#include "bfa_defs.h"
+
+/**
+ * @brief
+ * FC physical port statistics.
+ */
+struct bfa_port_fc_stats {
+	u64	secs_reset;	/*!< Seconds since stats is reset */
+	u64	tx_frames;	/*!< Tx frames			*/
+	u64	tx_words;	/*!< Tx words			*/
+	u64	tx_lip;		/*!< Tx LIP			*/
+	u64	tx_nos;		/*!< Tx NOS			*/
+	u64	tx_ols;		/*!< Tx OLS			*/
+	u64	tx_lr;		/*!< Tx LR			*/
+	u64	tx_lrr;		/*!< Tx LRR			*/
+	u64	rx_frames;	/*!< Rx frames			*/
+	u64	rx_words;	/*!< Rx words			*/
+	u64	lip_count;	/*!< Rx LIP			*/
+	u64	nos_count;	/*!< Rx NOS			*/
+	u64	ols_count;	/*!< Rx OLS			*/
+	u64	lr_count;	/*!< Rx LR			*/
+	u64	lrr_count;	/*!< Rx LRR			*/
+	u64	invalid_crcs;	/*!< Rx CRC err frames		*/
+	u64	invalid_crc_gd_eof; /*!< Rx CRC err good EOF frames */
+	u64	undersized_frm; /*!< Rx undersized frames	*/
+	u64	oversized_frm;	/*!< Rx oversized frames	*/
+	u64	bad_eof_frm;	/*!< Rx frames with bad EOF	*/
+	u64	error_frames;	/*!< Errored frames		*/
+	u64	dropped_frames;	/*!< Dropped frames		*/
+	u64	link_failures;	/*!< Link Failure (LF) count	*/
+	u64	loss_of_syncs;	/*!< Loss of sync count		*/
+	u64	loss_of_signals; /*!< Loss of signal count	*/
+	u64	primseq_errs;	/*!< Primitive sequence protocol err. */
+	u64	bad_os_count;	/*!< Invalid ordered sets	*/
+	u64	err_enc_out;	/*!< Encoding err nonframe_8b10b */
+	u64	err_enc;	/*!< Encoding err frame_8b10b	*/
+};
+
+/**
+ * @brief
+ * Eth Physical Port statistics.
+ */
+struct bfa_port_eth_stats {
+	u64	secs_reset;	/*!< Seconds since stats is reset */
+	u64	frame_64;	/*!< Frames 64 bytes		*/
+	u64	frame_65_127;	/*!< Frames 65-127 bytes	*/
+	u64	frame_128_255;	/*!< Frames 128-255 bytes	*/
+	u64	frame_256_511;	/*!< Frames 256-511 bytes	*/
+	u64	frame_512_1023;	/*!< Frames 512-1023 bytes	*/
+	u64	frame_1024_1518; /*!< Frames 1024-1518 bytes	*/
+	u64	frame_1519_1522; /*!< Frames 1519-1522 bytes	*/
+	u64	tx_bytes;	/*!< Tx bytes			*/
+	u64	tx_packets;	 /*!< Tx packets		*/
+	u64	tx_mcast_packets; /*!< Tx multicast packets	*/
+	u64	tx_bcast_packets; /*!< Tx broadcast packets	*/
+	u64	tx_control_frame; /*!< Tx control frame		*/
+	u64	tx_drop;	/*!< Tx drops			*/
+	u64	tx_jabber;	/*!< Tx jabber			*/
+	u64	tx_fcs_error;	/*!< Tx FCS errors		*/
+	u64	tx_fragments;	/*!< Tx fragments		*/
+	u64	rx_bytes;	/*!< Rx bytes			*/
+	u64	rx_packets;	/*!< Rx packets			*/
+	u64	rx_mcast_packets; /*!< Rx multicast packets	*/
+	u64	rx_bcast_packets; /*!< Rx broadcast packets	*/
+	u64	rx_control_frames; /*!< Rx control frames	*/
+	u64	rx_unknown_opcode; /*!< Rx unknown opcode	*/
+	u64	rx_drop;	/*!< Rx drops			*/
+	u64	rx_jabber;	/*!< Rx jabber			*/
+	u64	rx_fcs_error;	/*!< Rx FCS errors		*/
+	u64	rx_alignment_error; /*!< Rx alignment errors	*/
+	u64	rx_frame_length_error; /*!< Rx frame len errors	*/
+	u64	rx_code_error;	/*!< Rx code errors		*/
+	u64	rx_fragments;	/*!< Rx fragments		*/
+	u64	rx_pause;	/*!< Rx pause			*/
+	u64	rx_zero_pause;	/*!< Rx zero pause		*/
+	u64	tx_pause;	/*!< Tx pause			*/
+	u64	tx_zero_pause;	/*!< Tx zero pause		*/
+	u64	rx_fcoe_pause;	/*!< Rx FCoE pause		*/
+	u64	rx_fcoe_zero_pause; /*!< Rx FCoE zero pause	*/
+	u64	tx_fcoe_pause;	/*!< Tx FCoE pause		*/
+	u64	tx_fcoe_zero_pause; /*!< Tx FCoE zero pause	*/
+};
+
+/**
+ * @brief
+ *		Port statistics.
+ */
+union bfa_port_stats_u {
+	struct bfa_port_fc_stats fc;
+	struct bfa_port_eth_stats eth;
+};
+
+#pragma pack(1)
+
+#define BFA_CEE_LLDP_MAX_STRING_LEN (128)
+#define BFA_CEE_DCBX_MAX_PRIORITY	(8)
+#define BFA_CEE_DCBX_MAX_PGID		(8)
+
+#define BFA_CEE_LLDP_SYS_CAP_OTHER	0x0001
+#define BFA_CEE_LLDP_SYS_CAP_REPEATER	0x0002
+#define BFA_CEE_LLDP_SYS_CAP_MAC_BRIDGE	0x0004
+#define BFA_CEE_LLDP_SYS_CAP_WLAN_AP	0x0008
+#define BFA_CEE_LLDP_SYS_CAP_ROUTER	0x0010
+#define BFA_CEE_LLDP_SYS_CAP_TELEPHONE	0x0020
+#define BFA_CEE_LLDP_SYS_CAP_DOCSIS_CD	0x0040
+#define BFA_CEE_LLDP_SYS_CAP_STATION	0x0080
+#define BFA_CEE_LLDP_SYS_CAP_CVLAN	0x0100
+#define BFA_CEE_LLDP_SYS_CAP_SVLAN	0x0200
+#define BFA_CEE_LLDP_SYS_CAP_TPMR	0x0400
+
+/* LLDP string type */
+struct bfa_cee_lldp_str {
+	u8 sub_type;
+	u8 len;
+	u8 rsvd[2];
+	u8 value[BFA_CEE_LLDP_MAX_STRING_LEN];
+};
+
+/* LLDP paramters */
+struct bfa_cee_lldp_cfg {
+	struct bfa_cee_lldp_str chassis_id;
+	struct bfa_cee_lldp_str port_id;
+	struct bfa_cee_lldp_str port_desc;
+	struct bfa_cee_lldp_str sys_name;
+	struct bfa_cee_lldp_str sys_desc;
+	struct bfa_cee_lldp_str mgmt_addr;
+	u16 time_to_live;
+	u16 enabled_system_cap;
+};
+
+enum bfa_cee_dcbx_version {
+	DCBX_PROTOCOL_PRECEE	= 1,
+	DCBX_PROTOCOL_CEE	= 2,
+};
+
+enum bfa_cee_lls {
+	/* LLS is down because the TLV not sent by the peer */
+	CEE_LLS_DOWN_NO_TLV = 0,
+	/* LLS is down as advertised by the peer */
+	CEE_LLS_DOWN	= 1,
+	CEE_LLS_UP	= 2,
+};
+
+/* CEE/DCBX parameters */
+struct bfa_cee_dcbx_cfg {
+	u8 pgid[BFA_CEE_DCBX_MAX_PRIORITY];
+	u8 pg_percentage[BFA_CEE_DCBX_MAX_PGID];
+	u8 pfc_primap; /* bitmap of priorties with PFC enabled */
+	u8 fcoe_primap; /* bitmap of priorities used for FcoE traffic */
+	u8 iscsi_primap; /* bitmap of priorities used for iSCSI traffic */
+	u8 dcbx_version; /* operating version:CEE or preCEE */
+	u8 lls_fcoe; /* FCoE Logical Link Status */
+	u8 lls_lan; /* LAN Logical Link Status */
+	u8 rsvd[2];
+};
+
+/* CEE status */
+/* Making this to tri-state for the benefit of port list command */
+enum bfa_cee_status {
+	CEE_UP = 0,
+	CEE_PHY_UP = 1,
+	CEE_LOOPBACK = 2,
+	CEE_PHY_DOWN = 3,
+};
+
+/* CEE Query */
+struct bfa_cee_attr {
+	u8	cee_status;
+	u8 error_reason;
+	struct bfa_cee_lldp_cfg lldp_remote;
+	struct bfa_cee_dcbx_cfg dcbx_remote;
+	mac_t src_mac;
+	u8 link_speed;
+	u8 nw_priority;
+	u8 filler[2];
+};
+
+/* LLDP/DCBX/CEE Statistics */
+struct bfa_cee_stats {
+	u32	lldp_tx_frames;		/*!< LLDP Tx Frames */
+	u32	lldp_rx_frames;		/*!< LLDP Rx Frames */
+	u32	lldp_rx_frames_invalid;	/*!< LLDP Rx Frames invalid */
+	u32	lldp_rx_frames_new;	/*!< LLDP Rx Frames new */
+	u32	lldp_tlvs_unrecognized;	/*!< LLDP Rx unrecognized TLVs */
+	u32	lldp_rx_shutdown_tlvs;	/*!< LLDP Rx shutdown TLVs */
+	u32	lldp_info_aged_out;	/*!< LLDP remote info aged out */
+	u32	dcbx_phylink_ups;	/*!< DCBX phy link ups */
+	u32	dcbx_phylink_downs;	/*!< DCBX phy link downs */
+	u32	dcbx_rx_tlvs;		/*!< DCBX Rx TLVs */
+	u32	dcbx_rx_tlvs_invalid;	/*!< DCBX Rx TLVs invalid */
+	u32	dcbx_control_tlv_error;	/*!< DCBX control TLV errors */
+	u32	dcbx_feature_tlv_error;	/*!< DCBX feature TLV errors */
+	u32	dcbx_cee_cfg_new;	/*!< DCBX new CEE cfg rcvd */
+	u32	cee_status_down;	/*!< CEE status down */
+	u32	cee_status_up;		/*!< CEE status up */
+	u32	cee_hw_cfg_changed;	/*!< CEE hw cfg changed */
+	u32	cee_rx_invalid_cfg;	/*!< CEE invalid cfg */
+};
+
+#pragma pack()
+
+#endif	/* __BFA_DEFS_CNA_H__ */
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_defs_mfg_comm.h net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_defs_mfg_comm.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_defs_mfg_comm.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_defs_mfg_comm.h	2010-08-10 12:23:10.010141000 -0700
@@ -0,0 +1,244 @@
+/*
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
+ */
+#ifndef __BFA_DEFS_MFG_COMM_H__
+#define __BFA_DEFS_MFG_COMM_H__
+
+#include "cna.h"
+
+/**
+ * Manufacturing block version
+ */
+#define BFA_MFG_VERSION				2
+#define BFA_MFG_VERSION_UNINIT			0xFF
+
+/**
+ * Manufacturing block encrypted version
+ */
+#define BFA_MFG_ENC_VER				2
+
+/**
+ * Manufacturing block version 1 length
+ */
+#define BFA_MFG_VER1_LEN			128
+
+/**
+ * Manufacturing block header length
+ */
+#define BFA_MFG_HDR_LEN				4
+
+#define BFA_MFG_SERIALNUM_SIZE			11
+#define STRSZ(_n)				(((_n) + 4) & ~3)
+
+/**
+ * Manufacturing card type
+ */
+enum {
+	BFA_MFG_TYPE_CB_MAX  = 825,      /*!< Crossbow card type max	*/
+	BFA_MFG_TYPE_FC8P2   = 825,      /*!< 8G 2port FC card		*/
+	BFA_MFG_TYPE_FC8P1   = 815,      /*!< 8G 1port FC card		*/
+	BFA_MFG_TYPE_FC4P2   = 425,      /*!< 4G 2port FC card		*/
+	BFA_MFG_TYPE_FC4P1   = 415,      /*!< 4G 1port FC card		*/
+	BFA_MFG_TYPE_CNA10P2 = 1020,     /*!< 10G 2port CNA card	*/
+	BFA_MFG_TYPE_CNA10P1 = 1010,     /*!< 10G 1port CNA card	*/
+	BFA_MFG_TYPE_JAYHAWK = 804,	 /*!< Jayhawk mezz card		*/
+	BFA_MFG_TYPE_WANCHESE = 1007,	 /*!< Wanchese mezz card	*/
+	BFA_MFG_TYPE_ASTRA    = 807,	 /*!< Astra mezz card		*/
+	BFA_MFG_TYPE_LIGHTNING_P0 = 902, /*!< Lightning mezz card - old	*/
+	BFA_MFG_TYPE_LIGHTNING = 1741,	 /*!< Lightning mezz card	*/
+	BFA_MFG_TYPE_INVALID = 0,	 /*!< Invalid card type		*/
+};
+
+#pragma pack(1)
+
+/**
+ * Check if 1-port card
+ */
+#define bfa_mfg_is_1port(type) (( \
+	(type) == BFA_MFG_TYPE_FC8P1 || \
+	(type) == BFA_MFG_TYPE_FC4P1 || \
+	(type) == BFA_MFG_TYPE_CNA10P1))
+
+/**
+ * Check if Mezz card
+ */
+#define bfa_mfg_is_mezz(type) (( \
+	(type) == BFA_MFG_TYPE_JAYHAWK || \
+	(type) == BFA_MFG_TYPE_WANCHESE || \
+	(type) == BFA_MFG_TYPE_ASTRA || \
+	(type) == BFA_MFG_TYPE_LIGHTNING_P0 || \
+	(type) == BFA_MFG_TYPE_LIGHTNING))
+
+/**
+ * Check if card type valid
+ */
+#define bfa_mfg_is_card_type_valid(type) (( \
+	(type) == BFA_MFG_TYPE_FC8P2 || \
+	(type) == BFA_MFG_TYPE_FC8P1 || \
+	(type) == BFA_MFG_TYPE_FC4P2 || \
+	(type) == BFA_MFG_TYPE_FC4P1 || \
+	(type) == BFA_MFG_TYPE_CNA10P2 || \
+	(type) == BFA_MFG_TYPE_CNA10P1 || \
+	bfa_mfg_is_mezz(type)))
+
+/**
+ * Check if the card having old wwn/mac handling
+ */
+#define bfa_mfg_is_old_wwn_mac_model(type) (( \
+	(type) == BFA_MFG_TYPE_FC8P2 || \
+	(type) == BFA_MFG_TYPE_FC8P1 || \
+	(type) == BFA_MFG_TYPE_FC4P2 || \
+	(type) == BFA_MFG_TYPE_FC4P1 || \
+	(type) == BFA_MFG_TYPE_CNA10P2 || \
+	(type) == BFA_MFG_TYPE_CNA10P1 || \
+	(type) == BFA_MFG_TYPE_JAYHAWK || \
+	(type) == BFA_MFG_TYPE_WANCHESE))
+
+#define bfa_mfg_increment_wwn_mac(m, i)				\
+do {								\
+	u32 t = ((m)[0] << 16) | ((m)[1] << 8) | (m)[2];	\
+	t += (i);						\
+	(m)[0] = (t >> 16) & 0xFF;				\
+	(m)[1] = (t >> 8) & 0xFF;				\
+	(m)[2] = t & 0xFF;					\
+} while (0)
+
+#define bfa_mfg_adapter_prop_init_flash(card_type, prop)	\
+do {								\
+	switch ((card_type)) {					\
+	case BFA_MFG_TYPE_FC8P2:				\
+	case BFA_MFG_TYPE_JAYHAWK:				\
+	case BFA_MFG_TYPE_ASTRA:				\
+		(prop) = BFI_ADAPTER_SETP(NPORTS, 2) |		\
+			BFI_ADAPTER_SETP(SPEED, 8);		\
+		break;						\
+	case BFA_MFG_TYPE_FC8P1:				\
+		(prop) = BFI_ADAPTER_SETP(NPORTS, 1) |		\
+			BFI_ADAPTER_SETP(SPEED, 8);		\
+		break;						\
+	case BFA_MFG_TYPE_FC4P2:				\
+		(prop) = BFI_ADAPTER_SETP(NPORTS, 2) |		\
+			BFI_ADAPTER_SETP(SPEED, 4);		\
+		break;						\
+	case BFA_MFG_TYPE_FC4P1:				\
+		(prop) = BFI_ADAPTER_SETP(NPORTS, 1) |		\
+			BFI_ADAPTER_SETP(SPEED, 4);		\
+		break;						\
+	case BFA_MFG_TYPE_CNA10P2:				\
+	case BFA_MFG_TYPE_WANCHESE:				\
+	case BFA_MFG_TYPE_LIGHTNING_P0:				\
+	case BFA_MFG_TYPE_LIGHTNING:				\
+		(prop) = BFI_ADAPTER_SETP(NPORTS, 2);		\
+		(prop) |= BFI_ADAPTER_SETP(SPEED, 10);		\
+		break;						\
+	case BFA_MFG_TYPE_CNA10P1:				\
+		(prop) = BFI_ADAPTER_SETP(NPORTS, 1);		\
+		(prop) |= BFI_ADAPTER_SETP(SPEED, 10);		\
+		break;						\
+	default:						\
+		(prop) = BFI_ADAPTER_UNSUPP;			\
+	}							\
+} while (0)
+
+enum {
+	CB_GPIO_TTV	= (1),		/*!< TTV debug capable cards	*/
+	CB_GPIO_FC8P2   = (2),		/*!< 8G 2port FC card		*/
+	CB_GPIO_FC8P1   = (3),		/*!< 8G 1port FC card		*/
+	CB_GPIO_FC4P2   = (4),		/*!< 4G 2port FC card		*/
+	CB_GPIO_FC4P1   = (5),		/*!< 4G 1port FC card		*/
+	CB_GPIO_DFLY    = (6),		/*!< 8G 2port FC mezzanine card	*/
+	CB_GPIO_PROTO   = (1 << 7)	/*!< 8G 2port FC prototypes	*/
+};
+
+#define bfa_mfg_adapter_prop_init_gpio(gpio, card_type, prop)	\
+do {								\
+	if ((gpio) & CB_GPIO_PROTO) {				\
+		(prop) |= BFI_ADAPTER_PROTO;			\
+		(gpio) &= ~CB_GPIO_PROTO;			\
+	}							\
+	switch ((gpio)) {					\
+	case CB_GPIO_TTV:					\
+		(prop) |= BFI_ADAPTER_TTV;			\
+	case CB_GPIO_DFLY:					\
+	case CB_GPIO_FC8P2:					\
+		(prop) |= BFI_ADAPTER_SETP(NPORTS, 2);		\
+		(prop) |= BFI_ADAPTER_SETP(SPEED, 8);		\
+		(card_type) = BFA_MFG_TYPE_FC8P2;		\
+		break;						\
+	case CB_GPIO_FC8P1:					\
+		(prop) |= BFI_ADAPTER_SETP(NPORTS, 1);		\
+		(prop) |= BFI_ADAPTER_SETP(SPEED, 8);		\
+		(card_type) = BFA_MFG_TYPE_FC8P1;		\
+		break;						\
+	case CB_GPIO_FC4P2:					\
+		(prop) |= BFI_ADAPTER_SETP(NPORTS, 2);		\
+		(prop) |= BFI_ADAPTER_SETP(SPEED, 4);		\
+		(card_type) = BFA_MFG_TYPE_FC4P2;		\
+		break;						\
+	case CB_GPIO_FC4P1:					\
+		(prop) |= BFI_ADAPTER_SETP(NPORTS, 1);		\
+		(prop) |= BFI_ADAPTER_SETP(SPEED, 4);		\
+		(card_type) = BFA_MFG_TYPE_FC4P1;		\
+		break;						\
+	default:						\
+		(prop) |= BFI_ADAPTER_UNSUPP;			\
+		(card_type) = BFA_MFG_TYPE_INVALID;		\
+	}							\
+} while (0)
+
+/**
+ * VPD data length
+ */
+#define BFA_MFG_VPD_LEN			512
+#define BFA_MFG_VPD_LEN_INVALID		0
+
+#define BFA_MFG_VPD_PCI_HDR_OFF		137
+#define BFA_MFG_VPD_PCI_VER_MASK	0x07	/*!< version mask 3 bits */
+#define BFA_MFG_VPD_PCI_VDR_MASK	0xf8	/*!< vendor mask 5 bits */
+
+/**
+ * VPD vendor tag
+ */
+enum {
+	BFA_MFG_VPD_UNKNOWN	= 0,     /*!< vendor unknown 		*/
+	BFA_MFG_VPD_IBM 	= 1,     /*!< vendor IBM 		*/
+	BFA_MFG_VPD_HP  	= 2,     /*!< vendor HP  		*/
+	BFA_MFG_VPD_DELL  	= 3,     /*!< vendor DELL  		*/
+	BFA_MFG_VPD_PCI_IBM 	= 0x08,  /*!< PCI VPD IBM     		*/
+	BFA_MFG_VPD_PCI_HP  	= 0x10,  /*!< PCI VPD HP		*/
+	BFA_MFG_VPD_PCI_DELL  	= 0x20,  /*!< PCI VPD DELL		*/
+	BFA_MFG_VPD_PCI_BRCD 	= 0xf8,  /*!< PCI VPD Brocade 		*/
+};
+
+/**
+ * @brief BFA adapter flash vpd data definition.
+ *
+ * All numerical fields are in big-endian format.
+ */
+struct bfa_mfg_vpd {
+	u8		version;	/*!< vpd data version */
+	u8		vpd_sig[3];	/*!< characters 'V', 'P', 'D' */
+	u8		chksum;		/*!< u8 checksum */
+	u8		vendor;		/*!< vendor */
+	u8 	len;		/*!< vpd data length excluding header */
+	u8 	rsv;
+	u8		data[BFA_MFG_VPD_LEN];	/*!< vpd data */
+};
+
+#pragma pack()
+
+#endif /* __BFA_DEFS_MFG_H__ */
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_defs_status.h net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_defs_status.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_defs_status.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_defs_status.h	2010-08-10 12:23:10.000153000 -0700
@@ -0,0 +1,216 @@
+/*
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
+	BFA_STATUS_OK 		= 0,
+	BFA_STATUS_FAILED 	= 1,
+	BFA_STATUS_EINVAL 	= 2,
+	BFA_STATUS_ENOMEM 	= 3,
+	BFA_STATUS_ENOSYS 	= 4,
+	BFA_STATUS_ETIMER 	= 5,
+	BFA_STATUS_EPROTOCOL 	= 6,
+	BFA_STATUS_ENOFCPORTS 	= 7,
+	BFA_STATUS_NOFLASH 	= 8,
+	BFA_STATUS_BADFLASH 	= 9,
+	BFA_STATUS_SFP_UNSUPP 	= 10,
+	BFA_STATUS_UNKNOWN_VFID = 11,
+	BFA_STATUS_DATACORRUPTED = 12,
+	BFA_STATUS_DEVBUSY 	= 13,
+	BFA_STATUS_ABORTED 	= 14,
+	BFA_STATUS_NODEV 	= 15,
+	BFA_STATUS_HDMA_FAILED 	= 16,
+	BFA_STATUS_FLASH_BAD_LEN = 17,
+	BFA_STATUS_UNKNOWN_LWWN = 18,
+	BFA_STATUS_UNKNOWN_RWWN = 19,
+	BFA_STATUS_FCPT_LS_RJT 	= 20,
+	BFA_STATUS_VPORT_EXISTS = 21,
+	BFA_STATUS_VPORT_MAX 	= 22,
+	BFA_STATUS_UNSUPP_SPEED = 23,
+	BFA_STATUS_INVLD_DFSZ 	= 24,
+	BFA_STATUS_CNFG_FAILED 	= 25,
+	BFA_STATUS_CMD_NOTSUPP 	= 26,
+	BFA_STATUS_NO_ADAPTER 	= 27,
+	BFA_STATUS_LINKDOWN 	= 28,
+	BFA_STATUS_FABRIC_RJT 	= 29,
+	BFA_STATUS_UNKNOWN_VWWN = 30,
+	BFA_STATUS_NSLOGIN_FAILED = 31,
+	BFA_STATUS_NO_RPORTS 	= 32,
+	BFA_STATUS_NSQUERY_FAILED = 33,
+	BFA_STATUS_PORT_OFFLINE = 34,
+	BFA_STATUS_RPORT_OFFLINE = 35,
+	BFA_STATUS_TGTOPEN_FAILED = 36,
+	BFA_STATUS_BAD_LUNS 	= 37,
+	BFA_STATUS_IO_FAILURE 	= 38,
+	BFA_STATUS_NO_FABRIC 	= 39,
+	BFA_STATUS_EBADF 	= 40,
+	BFA_STATUS_EINTR 	= 41,
+	BFA_STATUS_EIO 		= 42,
+	BFA_STATUS_ENOTTY 	= 43,
+	BFA_STATUS_ENXIO 	= 44,
+	BFA_STATUS_EFOPEN 	= 45,
+	BFA_STATUS_VPORT_WWN_BP = 46,
+	BFA_STATUS_PORT_NOT_DISABLED = 47,
+	BFA_STATUS_BADFRMHDR 	= 48,
+	BFA_STATUS_BADFRMSZ 	= 49,
+	BFA_STATUS_MISSINGFRM 	= 50,
+	BFA_STATUS_LINKTIMEOUT 	= 51,
+	BFA_STATUS_NO_FCPIM_NEXUS = 52,
+	BFA_STATUS_CHECKSUM_FAIL = 53,
+	BFA_STATUS_GZME_FAILED 	= 54,
+	BFA_STATUS_SCSISTART_REQD = 55,
+	BFA_STATUS_IOC_FAILURE 	= 56,
+	BFA_STATUS_INVALID_WWN 	= 57,
+	BFA_STATUS_MISMATCH 	= 58,
+	BFA_STATUS_IOC_ENABLED 	= 59,
+	BFA_STATUS_ADAPTER_ENABLED = 60,
+	BFA_STATUS_IOC_NON_OP 	= 61,
+	BFA_STATUS_ADDR_MAP_FAILURE = 62,
+	BFA_STATUS_SAME_NAME 	= 63,
+	BFA_STATUS_PENDING      = 64,
+	BFA_STATUS_8G_SPD	= 65,
+	BFA_STATUS_4G_SPD	= 66,
+	BFA_STATUS_AD_IS_ENABLE = 67,
+	BFA_STATUS_EINVAL_TOV 	= 68,
+	BFA_STATUS_EINVAL_QDEPTH = 69,
+	BFA_STATUS_VERSION_FAIL = 70,
+	BFA_STATUS_DIAG_BUSY    = 71,
+	BFA_STATUS_BEACON_ON	= 72,
+	BFA_STATUS_BEACON_OFF	= 73,
+	BFA_STATUS_LBEACON_ON   = 74,
+	BFA_STATUS_LBEACON_OFF	= 75,
+	BFA_STATUS_PORT_NOT_INITED = 76,
+	BFA_STATUS_RPSC_ENABLED = 77,
+	BFA_STATUS_ENOFSAVE 	= 78,
+	BFA_STATUS_BAD_FILE		= 79,
+	BFA_STATUS_RLIM_EN		= 80,
+	BFA_STATUS_RLIM_DIS		= 81,
+	BFA_STATUS_IOC_DISABLED  = 82,
+	BFA_STATUS_ADAPTER_DISABLED  = 83,
+	BFA_STATUS_BIOS_DISABLED  = 84,
+	BFA_STATUS_AUTH_ENABLED  = 85,
+	BFA_STATUS_AUTH_DISABLED  = 86,
+	BFA_STATUS_ERROR_TRL_ENABLED  = 87,
+	BFA_STATUS_ERROR_QOS_ENABLED  = 88,
+	BFA_STATUS_NO_SFP_DEV = 89,
+	BFA_STATUS_MEMTEST_FAILED = 90,
+	BFA_STATUS_INVALID_DEVID = 91,
+	BFA_STATUS_QOS_ENABLED = 92,
+	BFA_STATUS_QOS_DISABLED = 93,
+	BFA_STATUS_INCORRECT_DRV_CONFIG = 94,
+	BFA_STATUS_REG_FAIL = 95,
+	BFA_STATUS_IM_INV_CODE = 96,
+	BFA_STATUS_IM_INV_VLAN = 97,
+	BFA_STATUS_IM_INV_ADAPT_NAME = 98,
+	BFA_STATUS_IM_LOW_RESOURCES = 99,
+	BFA_STATUS_IM_VLANID_IS_PVID = 100,
+	BFA_STATUS_IM_VLANID_EXISTS = 101,
+	BFA_STATUS_IM_FW_UPDATE_FAIL = 102,
+	BFA_STATUS_PORTLOG_ENABLED = 103,
+	BFA_STATUS_PORTLOG_DISABLED = 104,
+	BFA_STATUS_FILE_NOT_FOUND = 105,
+	BFA_STATUS_QOS_FC_ONLY = 106,
+	BFA_STATUS_RLIM_FC_ONLY = 107,
+	BFA_STATUS_CT_SPD = 108,
+	BFA_STATUS_LEDTEST_OP = 109,
+	BFA_STATUS_CEE_NOT_DN = 110,
+	BFA_STATUS_10G_SPD = 111,
+	BFA_STATUS_IM_INV_TEAM_NAME = 112,
+	BFA_STATUS_IM_DUP_TEAM_NAME = 113,
+	BFA_STATUS_IM_ADAPT_ALREADY_IN_TEAM = 114,
+	BFA_STATUS_IM_ADAPT_HAS_VLANS = 115,
+	BFA_STATUS_IM_PVID_MISMATCH = 116,
+	BFA_STATUS_IM_LINK_SPEED_MISMATCH = 117,
+	BFA_STATUS_IM_MTU_MISMATCH = 118,
+	BFA_STATUS_IM_RSS_MISMATCH = 119,
+	BFA_STATUS_IM_HDS_MISMATCH = 120,
+	BFA_STATUS_IM_OFFLOAD_MISMATCH = 121,
+	BFA_STATUS_IM_PORT_PARAMS = 122,
+	BFA_STATUS_IM_PORT_NOT_IN_TEAM = 123,
+	BFA_STATUS_IM_CANNOT_REM_PRI = 124,
+	BFA_STATUS_IM_MAX_PORTS_REACHED = 125,
+	BFA_STATUS_IM_LAST_PORT_DELETE = 126,
+	BFA_STATUS_IM_NO_DRIVER = 127,
+	BFA_STATUS_IM_MAX_VLANS_REACHED = 128,
+	BFA_STATUS_TOMCAT_SPD_NOT_ALLOWED = 129,
+	BFA_STATUS_NO_MINPORT_DRIVER = 130,
+	BFA_STATUS_CARD_TYPE_MISMATCH = 131,
+	BFA_STATUS_BAD_ASICBLK = 132,
+	BFA_STATUS_NO_DRIVER = 133,
+	BFA_STATUS_INVALID_MAC = 134,
+	BFA_STATUS_IM_NO_VLAN = 135,
+	BFA_STATUS_IM_ETH_LB_FAILED = 136,
+	BFA_STATUS_IM_PVID_REMOVE = 137,
+	BFA_STATUS_IM_PVID_EDIT = 138,
+	BFA_STATUS_CNA_NO_BOOT = 139,
+	BFA_STATUS_IM_PVID_NON_ZERO = 140,
+	BFA_STATUS_IM_INETCFG_LOCK_FAILED = 141,
+	BFA_STATUS_IM_GET_INETCFG_FAILED = 142,
+	BFA_STATUS_IM_NOT_BOUND = 143,
+	BFA_STATUS_INSUFFICIENT_PERMS = 144,
+	BFA_STATUS_IM_INV_VLAN_NAME = 145,
+	BFA_STATUS_CMD_NOTSUPP_CNA = 146,
+	BFA_STATUS_IM_PASSTHRU_EDIT = 147,
+	BFA_STATUS_IM_BIND_FAILED = 148,
+	BFA_STATUS_IM_UNBIND_FAILED = 149,
+	BFA_STATUS_IM_PORT_IN_TEAM = 150,
+	BFA_STATUS_IM_VLAN_NOT_FOUND = 151,
+	BFA_STATUS_IM_TEAM_NOT_FOUND = 152,
+	BFA_STATUS_IM_TEAM_CFG_NOT_ALLOWED = 153,
+	BFA_STATUS_PBC = 154,
+	BFA_STATUS_DEVID_MISSING = 155,
+	BFA_STATUS_BAD_FWCFG = 156,
+	BFA_STATUS_CREATE_FILE = 157,
+	BFA_STATUS_INVALID_VENDOR = 158,
+	BFA_STATUS_SFP_NOT_READY = 159,
+	BFA_STATUS_FLASH_UNINIT = 160,
+	BFA_STATUS_FLASH_EMPTY = 161,
+	BFA_STATUS_FLASH_CKFAIL = 162,
+	BFA_STATUS_TRUNK_UNSUPP = 163,
+	BFA_STATUS_TRUNK_ENABLED = 164,
+	BFA_STATUS_TRUNK_DISABLED  = 165,
+	BFA_STATUS_TRUNK_ERROR_TRL_ENABLED = 166,
+	BFA_STATUS_BOOT_CODE_UPDATED = 167,
+	BFA_STATUS_BOOT_VERSION = 168,
+	BFA_STATUS_CARDTYPE_MISSING = 169,
+	BFA_STATUS_INVALID_CARDTYPE = 170,
+	BFA_STATUS_NO_TOPOLOGY_FOR_CNA = 171,
+	BFA_STATUS_IM_VLAN_OVER_TEAM_DELETE_FAILED = 172,
+	BFA_STATUS_ETHBOOT_ENABLED  = 173,
+	BFA_STATUS_ETHBOOT_DISABLED  = 174,
+	BFA_STATUS_IOPROFILE_OFF = 175,
+	BFA_STATUS_NO_PORT_INSTANCE = 176,
+	BFA_STATUS_BOOT_CODE_TIMEDOUT = 177,
+	BFA_STATUS_NO_VPORT_LOCK = 178,
+	BFA_STATUS_VPORT_NO_CNFG = 179,
+	BFA_STATUS_MAX_VAL
+};
+
+enum bfa_eproto_status {
+	BFA_EPROTO_BAD_ACCEPT = 0,
+	BFA_EPROTO_UNKNOWN_RSP = 1
+};
+
+#endif /* __BFA_DEFS_STATUS_H__ */
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_ioc.h net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_ioc.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_ioc.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_ioc.h	2010-08-10 12:23:09.975154000 -0700
@@ -0,0 +1,343 @@
+/*
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
+ */
+
+#ifndef __BFA_IOC_H__
+#define __BFA_IOC_H__
+
+#include "bfa_sm.h"
+#include "bfi.h"
+#include "cna.h"
+
+#define BFA_IOC_TOV		3000	/* msecs */
+#define BFA_IOC_HWSEM_TOV	500	/* msecs */
+#define BFA_IOC_HB_TOV		500	/* msecs */
+#define BFA_IOC_HWINIT_MAX	2
+#define BFA_IOC_TOV_RECOVER	BFA_IOC_HB_TOV
+
+/**
+ * Generic Scatter Gather Element used by driver
+ */
+struct bfa_sge {
+	u32	sg_len;
+	void	*sg_addr;
+};
+
+/**
+ * PCI device information required by IOC
+ */
+struct bfa_pcidev {
+	int	pci_slot;
+	u8	pci_func;
+	u16	device_id;
+	void	__iomem *pci_bar_kva;
+};
+
+/**
+ * Structure used to remember the DMA-able memory block's KVA and Physical
+ * Address
+ */
+struct bfa_dma {
+	void	*kva;	/* ! Kernel virtual address	*/
+	u64	pa;	/* ! Physical address		*/
+};
+
+#define BFA_DMA_ALIGN_SZ	256
+
+/**
+ * smem size for Crossbow and Catapult
+ */
+#define BFI_SMEM_CB_SIZE	0x200000U	/* ! 2MB for crossbow	*/
+#define BFI_SMEM_CT_SIZE	0x280000U	/* ! 2.5MB for catapult	*/
+
+/**
+ * @brief BFA dma address assignment macro
+ */
+#define bfa_dma_addr_set(dma_addr, pa)	\
+		__bfa_dma_addr_set(&dma_addr, (u64)pa)
+
+static inline void
+__bfa_dma_addr_set(union bfi_addr_u *dma_addr, u64 pa)
+{
+	dma_addr->a32.addr_lo = (u32) pa;
+	dma_addr->a32.addr_hi = (u32) (upper_32_bits(pa));
+}
+
+/**
+ * @brief BFA dma address assignment macro. (big endian format)
+ */
+#define bfa_dma_be_addr_set(dma_addr, pa)	\
+		__bfa_dma_be_addr_set(&dma_addr, (u64)pa)
+static inline void
+__bfa_dma_be_addr_set(union bfi_addr_u *dma_addr, u64 pa)
+{
+	dma_addr->a32.addr_lo = (u32) htonl(pa);
+	dma_addr->a32.addr_hi = (u32) htonl(upper_32_bits(pa));
+}
+
+struct bfa_ioc_regs {
+	void __iomem *hfn_mbox_cmd;
+	void __iomem *hfn_mbox;
+	void __iomem *lpu_mbox_cmd;
+	void __iomem *lpu_mbox;
+	void __iomem *pss_ctl_reg;
+	void __iomem *pss_err_status_reg;
+	void __iomem *app_pll_fast_ctl_reg;
+	void __iomem *app_pll_slow_ctl_reg;
+	void __iomem *ioc_sem_reg;
+	void __iomem *ioc_usage_sem_reg;
+	void __iomem *ioc_init_sem_reg;
+	void __iomem *ioc_usage_reg;
+	void __iomem *host_page_num_fn;
+	void __iomem *heartbeat;
+	void __iomem *ioc_fwstate;
+	void __iomem *ll_halt;
+	void __iomem *err_set;
+	void __iomem *shirq_isr_next;
+	void __iomem *shirq_msk_next;
+	void __iomem *smem_page_start;
+	u32	smem_pg0;
+};
+
+/**
+ * IOC Mailbox structures
+ */
+struct bfa_mbox_cmd {
+	struct list_head	qe;
+	u32			msg[BFI_IOC_MSGSZ];
+};
+
+/**
+ * IOC mailbox module
+ */
+typedef void (*bfa_ioc_mbox_mcfunc_t)(void *cbarg, struct bfi_mbmsg *m);
+struct bfa_ioc_mbox_mod {
+	struct list_head	cmd_q;		/*!< pending mbox queue	*/
+	int			nmclass;	/*!< number of handlers */
+	struct {
+		bfa_ioc_mbox_mcfunc_t	cbfn;	/*!< message handlers	*/
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
+struct bfa_ioc_cbfn {
+	bfa_ioc_enable_cbfn_t	enable_cbfn;
+	bfa_ioc_disable_cbfn_t	disable_cbfn;
+	bfa_ioc_hbfail_cbfn_t	hbfail_cbfn;
+	bfa_ioc_reset_cbfn_t	reset_cbfn;
+};
+
+/**
+ * Heartbeat failure notification queue element.
+ */
+struct bfa_ioc_hbfail_notify {
+	struct list_head	qe;
+	bfa_ioc_hbfail_cbfn_t	cbfn;
+	void			*cbarg;
+};
+
+/**
+ * Initialize a heartbeat failure notification structure
+ */
+#define bfa_ioc_hbfail_init(__notify, __cbfn, __cbarg) do {	\
+	(__notify)->cbfn = (__cbfn);				\
+	(__notify)->cbarg = (__cbarg);				\
+} while (0)
+
+struct bfa_ioc {
+	bfa_fsm_t		fsm;
+	struct bfa 		*bfa;
+	struct bfa_pcidev 	pcidev;
+	struct bfa_timer_mod	*timer_mod;
+	struct timer_list 	ioc_timer;
+	struct timer_list 	sem_timer;
+	struct timer_list	hb_timer;
+	u32			hb_count;
+	u32			retry_count;
+	struct list_head	hb_notify_q;
+	void			*dbg_fwsave;
+	int			dbg_fwsave_len;
+	bool			dbg_fwsave_once;
+	enum bfi_mclass		ioc_mc;
+	struct bfa_ioc_regs 	ioc_regs;
+	struct bfa_ioc_drv_stats stats;
+	bool			auto_recover;
+	bool			fcmode;
+	bool			ctdev;
+	bool			cna;
+	bool			pllinit;
+	bool   			stats_busy;	/*!< outstanding stats */
+	u8			port_id;
+
+	struct bfa_dma		attr_dma;
+	struct bfi_ioc_attr	*attr;
+	struct bfa_ioc_cbfn	*cbfn;
+	struct bfa_ioc_mbox_mod	mbox_mod;
+	struct bfa_ioc_hwif	*ioc_hwif;
+};
+
+struct bfa_ioc_hwif {
+	enum bfa_status (*ioc_pll_init) (void __iomem *rb, bool fcmode);
+	bool		(*ioc_firmware_lock)	(struct bfa_ioc *ioc);
+	void		(*ioc_firmware_unlock)	(struct bfa_ioc *ioc);
+	void		(*ioc_reg_init)	(struct bfa_ioc *ioc);
+	void		(*ioc_map_port)	(struct bfa_ioc *ioc);
+	void		(*ioc_isr_mode_set)	(struct bfa_ioc *ioc,
+					bool msix);
+	void		(*ioc_notify_hbfail)	(struct bfa_ioc *ioc);
+	void		(*ioc_ownership_reset)	(struct bfa_ioc *ioc);
+};
+
+#define bfa_ioc_pcifn(__ioc)		((__ioc)->pcidev.pci_func)
+#define bfa_ioc_devid(__ioc)		((__ioc)->pcidev.device_id)
+#define bfa_ioc_bar0(__ioc)		((__ioc)->pcidev.pci_bar_kva)
+#define bfa_ioc_portid(__ioc)		((__ioc)->port_id)
+#define bfa_ioc_fetch_stats(__ioc, __stats) \
+		(((__stats)->drv_stats) = (__ioc)->stats)
+#define bfa_ioc_clr_stats(__ioc)	\
+		memset(&(__ioc)->stats, 0, sizeof((__ioc)->stats))
+#define bfa_ioc_maxfrsize(__ioc)	((__ioc)->attr->maxfrsize)
+#define bfa_ioc_rx_bbcredit(__ioc)	((__ioc)->attr->rx_bbcredit)
+#define bfa_ioc_speed_sup(__ioc)	\
+	BFI_ADAPTER_GETP(SPEED, (__ioc)->attr->adapter_prop)
+#define bfa_ioc_get_nports(__ioc)	\
+	BFI_ADAPTER_GETP(NPORTS, (__ioc)->attr->adapter_prop)
+
+#define bfa_ioc_stats(_ioc, _stats)	((_ioc)->stats._stats++)
+#define BFA_IOC_FWIMG_MINSZ	(16 * 1024)
+#define BFA_IOC_FWIMG_TYPE(__ioc)					\
+	(((__ioc)->ctdev) ? 						\
+	 (((__ioc)->fcmode) ? BFI_IMAGE_CT_FC : BFI_IMAGE_CT_CNA) :	\
+	 BFI_IMAGE_CB_FC)
+#define BFA_IOC_FW_SMEM_SIZE(__ioc)					\
+	(((__ioc)->ctdev) ? BFI_SMEM_CT_SIZE : BFI_SMEM_CB_SIZE)
+#define BFA_IOC_FLASH_CHUNK_NO(off)		(off / BFI_FLASH_CHUNK_SZ_WORDS)
+#define BFA_IOC_FLASH_OFFSET_IN_CHUNK(off)	(off % BFI_FLASH_CHUNK_SZ_WORDS)
+#define BFA_IOC_FLASH_CHUNK_ADDR(chunkno)  (chunkno * BFI_FLASH_CHUNK_SZ_WORDS)
+
+/**
+ * IOC mailbox interface
+ */
+void bfa_ioc_mbox_queue(struct bfa_ioc *ioc, struct bfa_mbox_cmd *cmd);
+void bfa_ioc_mbox_register(struct bfa_ioc *ioc,
+		bfa_ioc_mbox_mcfunc_t *mcfuncs);
+void bfa_ioc_mbox_isr(struct bfa_ioc *ioc);
+void bfa_ioc_mbox_send(struct bfa_ioc *ioc, void *ioc_msg, int len);
+void bfa_ioc_msgget(struct bfa_ioc *ioc, void *mbmsg);
+void bfa_ioc_mbox_regisr(struct bfa_ioc *ioc, enum bfi_mclass mc,
+		bfa_ioc_mbox_mcfunc_t cbfn, void *cbarg);
+
+/**
+ * IOC interfaces
+ */
+
+#define bfa_ioc_pll_init_asic(__ioc) \
+	((__ioc)->ioc_hwif->ioc_pll_init((__ioc)->pcidev.pci_bar_kva, \
+			   (__ioc)->fcmode))
+
+enum bfa_status bfa_ioc_pll_init(struct bfa_ioc *ioc);
+enum bfa_status bfa_ioc_cb_pll_init(void __iomem *rb, bool fcmode);
+enum bfa_status bfa_ioc_ct_pll_init(void __iomem *rb, bool fcmode);
+
+#define	bfa_ioc_isr_mode_set(__ioc, __msix)			\
+			((__ioc)->ioc_hwif->ioc_isr_mode_set(__ioc, __msix))
+#define	bfa_ioc_ownership_reset(__ioc)				\
+			((__ioc)->ioc_hwif->ioc_ownership_reset(__ioc))
+
+void bfa_ioc_set_ct_hwif(struct bfa_ioc *ioc);
+
+void bfa_ioc_attach(struct bfa_ioc *ioc, void *bfa,
+		struct bfa_ioc_cbfn *cbfn);
+void bfa_ioc_auto_recover(bool auto_recover);
+void bfa_ioc_detach(struct bfa_ioc *ioc);
+void bfa_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
+		enum bfi_mclass mc);
+u32 bfa_ioc_meminfo(void);
+void bfa_ioc_mem_claim(struct bfa_ioc *ioc,  u8 *dm_kva, u64 dm_pa);
+void bfa_ioc_enable(struct bfa_ioc *ioc);
+void bfa_ioc_disable(struct bfa_ioc *ioc);
+bool bfa_ioc_intx_claim(struct bfa_ioc *ioc);
+
+void bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type,
+		u32 boot_param);
+void bfa_ioc_isr(struct bfa_ioc *ioc, struct bfi_mbmsg *msg);
+void bfa_ioc_error_isr(struct bfa_ioc *ioc);
+bool bfa_ioc_is_operational(struct bfa_ioc *ioc);
+bool bfa_ioc_is_initialized(struct bfa_ioc *ioc);
+bool bfa_ioc_is_disabled(struct bfa_ioc *ioc);
+bool bfa_ioc_fw_mismatch(struct bfa_ioc *ioc);
+bool bfa_ioc_adapter_is_disabled(struct bfa_ioc *ioc);
+void bfa_ioc_cfg_complete(struct bfa_ioc *ioc);
+enum bfa_ioc_type bfa_ioc_get_type(struct bfa_ioc *ioc);
+void bfa_ioc_get_adapter_serial_num(struct bfa_ioc *ioc, char *serial_num);
+void bfa_ioc_get_adapter_fw_ver(struct bfa_ioc *ioc, char *fw_ver);
+void bfa_ioc_get_adapter_optrom_ver(struct bfa_ioc *ioc, char *optrom_ver);
+void bfa_ioc_get_adapter_model(struct bfa_ioc *ioc, char *model);
+void bfa_ioc_get_adapter_manufacturer(struct bfa_ioc *ioc,
+		char *manufacturer);
+void bfa_ioc_get_pci_chip_rev(struct bfa_ioc *ioc, char *chip_rev);
+enum bfa_ioc_state bfa_ioc_get_state(struct bfa_ioc *ioc);
+
+void bfa_ioc_get_attr(struct bfa_ioc *ioc, struct bfa_ioc_attr *ioc_attr);
+void bfa_ioc_get_adapter_attr(struct bfa_ioc *ioc,
+		struct bfa_adapter_attr *ad_attr);
+u32 bfa_ioc_smem_pgnum(struct bfa_ioc *ioc, u32 fmaddr);
+u32 bfa_ioc_smem_pgoff(struct bfa_ioc *ioc, u32 fmaddr);
+void bfa_ioc_set_fcmode(struct bfa_ioc *ioc);
+bool bfa_ioc_get_fcmode(struct bfa_ioc *ioc);
+void bfa_ioc_hbfail_register(struct bfa_ioc *ioc,
+	struct bfa_ioc_hbfail_notify *notify);
+bool bfa_ioc_sem_get(void __iomem *sem_reg);
+void bfa_ioc_sem_release(void __iomem *sem_reg);
+void bfa_ioc_hw_sem_release(struct bfa_ioc *ioc);
+void bfa_ioc_fwver_get(struct bfa_ioc *ioc,
+			struct bfi_ioc_image_hdr *fwhdr);
+bool bfa_ioc_fwver_cmp(struct bfa_ioc *ioc,
+			struct bfi_ioc_image_hdr *fwhdr);
+
+/*
+ * Timeout APIs
+ */
+void bfa_ioc_timeout(void *ioc);
+void bfa_ioc_hb_check(void *ioc);
+void bfa_ioc_sem_timeout(void *ioc);
+
+/*
+ * bfa mfg wwn API functions
+ */
+u64 bfa_ioc_get_pwwn(struct bfa_ioc *ioc);
+u64 bfa_ioc_get_nwwn(struct bfa_ioc *ioc);
+mac_t bfa_ioc_get_mac(struct bfa_ioc *ioc);
+u64 bfa_ioc_get_mfg_pwwn(struct bfa_ioc *ioc);
+u64 bfa_ioc_get_mfg_nwwn(struct bfa_ioc *ioc);
+mac_t bfa_ioc_get_mfg_mac(struct bfa_ioc *ioc);
+u64 bfa_ioc_get_adid(struct bfa_ioc *ioc);
+
+/*
+ * F/W Image Size & Chunk
+ */
+u32 *bfa_cb_image_get_chunk(int type, u32 off);
+u32 bfa_cb_image_get_size(int type);
+
+#endif /* __BFA_IOC_H__ */
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_sm.h net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_sm.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_sm.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_sm.h	2010-08-10 12:23:09.983149000 -0700
@@ -0,0 +1,88 @@
+/*
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
+ */
+
+/**
+ * @file bfasm.h State machine defines
+ */
+
+#ifndef __BFA_SM_H__
+#define __BFA_SM_H__
+
+#include "cna.h"
+
+typedef void (*bfa_sm_t)(void *sm, int event);
+
+/**
+ * oc - object class eg. bfa_ioc
+ * st - state, eg. reset
+ * otype - object type, eg. struct bfa_ioc
+ * etype - object type, eg. enum ioc_event
+ */
+#define bfa_sm_state_decl(oc, st, otype, etype)		\
+	static void oc ## _sm_ ## st(otype * fsm, etype event)
+
+#define bfa_sm_set_state(_sm, _state)	((_sm)->sm = (bfa_sm_t)(_state))
+#define bfa_sm_send_event(_sm, _event)	((_sm)->sm((_sm), (_event)))
+#define bfa_sm_get_state(_sm)		((_sm)->sm)
+#define bfa_sm_cmp_state(_sm, _state)	((_sm)->sm == (bfa_sm_t)(_state))
+
+/**
+ * For converting from state machine function to state encoding.
+ */
+struct bfa_sm_table {
+	bfa_sm_t	sm;	/*!< state machine function	*/
+	int		state;	/*!< state machine encoding	*/
+	char		*name;	/*!< state name for display	*/
+};
+#define BFA_SM(_sm)	((bfa_sm_t)(_sm))
+
+/**
+ * State machine with entry actions.
+ */
+typedef void (*bfa_fsm_t)(void *fsm, int event);
+
+/**
+ * oc - object class eg. bfa_ioc
+ * st - state, eg. reset
+ * otype - object type, eg. struct bfa_ioc
+ * etype - object type, eg. enum ioc_event
+ */
+#define bfa_fsm_state_decl(oc, st, otype, etype)		\
+	static void oc ## _sm_ ## st(otype * fsm, etype event);	\
+	static void oc ## _sm_ ## st ## _entry(otype * fsm)
+
+#define bfa_fsm_set_state(_fsm, _state) do {	\
+	(_fsm)->fsm = (bfa_fsm_t)(_state);	\
+	_state ## _entry(_fsm);			\
+} while (0)
+
+#define bfa_fsm_send_event(_fsm, _event)	((_fsm)->fsm((_fsm), (_event)))
+#define bfa_fsm_get_state(_fsm)			((_fsm)->fsm)
+#define bfa_fsm_cmp_state(_fsm, _state)		\
+	((_fsm)->fsm == (bfa_fsm_t)(_state))
+
+static inline int
+bfa_sm_to_state(struct bfa_sm_table *smt, bfa_sm_t sm)
+{
+	int	i = 0;
+
+	while (smt[i].sm && smt[i].sm != sm)
+		i++;
+	return smt[i].state;
+}
+#endif
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_wc.h net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_wc.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfa_wc.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfa_wc.h	2010-08-10 12:23:09.992137000 -0700
@@ -0,0 +1,69 @@
+/*
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
+ */
+
+/**
+ * @file bfa_wc.h Generic wait counter.
+ */
+
+#ifndef __BFA_WC_H__
+#define __BFA_WC_H__
+
+typedef void (*bfa_wc_resume_t) (void *cbarg);
+
+struct bfa_wc {
+	bfa_wc_resume_t wc_resume;
+	void		*wc_cbarg;
+	int		wc_count;
+};
+
+static inline void
+bfa_wc_up(struct bfa_wc *wc)
+{
+	wc->wc_count++;
+}
+
+static inline void
+bfa_wc_down(struct bfa_wc *wc)
+{
+	wc->wc_count--;
+	if (wc->wc_count == 0)
+		wc->wc_resume(wc->wc_cbarg);
+}
+
+/**
+ * Initialize a waiting counter.
+ */
+static inline void
+bfa_wc_init(struct bfa_wc *wc, bfa_wc_resume_t wc_resume, void *wc_cbarg)
+{
+	wc->wc_resume = wc_resume;
+	wc->wc_cbarg = wc_cbarg;
+	wc->wc_count = 0;
+	bfa_wc_up(wc);
+}
+
+/**
+ * Wait for counter to reach zero
+ */
+static inline void
+bfa_wc_wait(struct bfa_wc *wc)
+{
+	bfa_wc_down(wc);
+}
+
+#endif
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfi.h net-next-2.6.35-rc1-mod/drivers/net/bna/bfi.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfi.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfi.h	2010-08-10 12:23:09.926137000 -0700
@@ -0,0 +1,392 @@
+/*
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
+ */
+
+#ifndef __BFI_H__
+#define __BFI_H__
+
+#include "bfa_defs.h"
+
+#pragma pack(1)
+
+/**
+ * BFI FW image type
+ */
+#define	BFI_FLASH_CHUNK_SZ			256	/*!< Flash chunk size */
+#define	BFI_FLASH_CHUNK_SZ_WORDS	(BFI_FLASH_CHUNK_SZ/sizeof(u32))
+enum {
+	BFI_IMAGE_CB_FC,
+	BFI_IMAGE_CT_FC,
+	BFI_IMAGE_CT_CNA,
+	BFI_IMAGE_MAX,
+};
+
+/**
+ * Msg header common to all msgs
+ */
+struct bfi_mhdr {
+	u8		msg_class;	/*!< @ref enum bfi_mclass	    */
+	u8		msg_id;		/*!< msg opcode with in the class   */
+	union {
+		struct {
+			u8	rsvd;
+			u8	lpu_id;	/*!< msg destination		    */
+		} h2i;
+		u16	i2htok;	/*!< token in msgs to host	    */
+	} mtag;
+};
+
+#define bfi_h2i_set(_mh, _mc, _op, _lpuid) do {		\
+	(_mh).msg_class 		= (_mc);		\
+	(_mh).msg_id			= (_op);		\
+	(_mh).mtag.h2i.lpu_id	= (_lpuid);			\
+} while (0)
+
+#define bfi_i2h_set(_mh, _mc, _op, _i2htok) do {		\
+	(_mh).msg_class 		= (_mc);		\
+	(_mh).msg_id			= (_op);		\
+	(_mh).mtag.i2htok		= (_i2htok);		\
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
+	BFI_SGE_DATA		= 0,	/*!< data address, not last	     */
+	BFI_SGE_DATA_CPL	= 1,	/*!< data addr, last in current page */
+	BFI_SGE_DATA_LAST	= 3,	/*!< data address, last		     */
+	BFI_SGE_LINK		= 2,	/*!< link address		     */
+	BFI_SGE_PGDLEN		= 2,	/*!< cumulative data length for page */
+};
+
+/**
+ * DMA addresses
+ */
+union bfi_addr_u {
+	struct {
+		u32	addr_lo;
+		u32	addr_hi;
+	} a32;
+};
+
+/**
+ * Scatter Gather Element
+ */
+struct bfi_sge {
+#ifdef __BIGENDIAN
+	u32	flags:2,
+			rsvd:2,
+			sg_len:28;
+#else
+	u32	sg_len:28,
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
+struct bfi_sgpg {
+	struct bfi_sge sges[BFI_SGPG_SGES_MAX];
+	u32	rsvd[BFI_SGPG_RSVD_WD_LEN];
+};
+
+/*
+ * Large Message structure - 128 Bytes size Msgs
+ */
+#define BFI_LMSG_SZ		128
+#define BFI_LMSG_PL_WSZ	\
+			((BFI_LMSG_SZ - sizeof(struct bfi_mhdr)) / 4)
+
+struct bfi_msg {
+	struct bfi_mhdr mhdr;
+	u32	pl[BFI_LMSG_PL_WSZ];
+};
+
+/**
+ * Mailbox message structure
+ */
+#define BFI_MBMSG_SZ		7
+struct bfi_mbmsg {
+	struct bfi_mhdr mh;
+	u32		pl[BFI_MBMSG_SZ];
+};
+
+/**
+ * Message Classes
+ */
+enum bfi_mclass {
+	BFI_MC_IOC		= 1,	/*!< IO Controller (IOC)	    */
+	BFI_MC_DIAG		= 2,	/*!< Diagnostic Msgs		    */
+	BFI_MC_FLASH		= 3,	/*!< Flash message class	    */
+	BFI_MC_CEE		= 4,	/*!< CEE			    */
+	BFI_MC_FCPORT		= 5,	/*!< FC port			    */
+	BFI_MC_IOCFC		= 6,	/*!< FC - IO Controller (IOC)	    */
+	BFI_MC_LL		= 7,	/*!< Link Layer			    */
+	BFI_MC_UF		= 8,	/*!< Unsolicited frame receive	    */
+	BFI_MC_FCXP		= 9,	/*!< FC Transport		    */
+	BFI_MC_LPS		= 10,	/*!< lport fc login services	    */
+	BFI_MC_RPORT		= 11,	/*!< Remote port		    */
+	BFI_MC_ITNIM		= 12,	/*!< I-T nexus (Initiator mode)	    */
+	BFI_MC_IOIM_READ	= 13,	/*!< read IO (Initiator mode)	    */
+	BFI_MC_IOIM_WRITE	= 14,	/*!< write IO (Initiator mode)	    */
+	BFI_MC_IOIM_IO		= 15,	/*!< IO (Initiator mode)	    */
+	BFI_MC_IOIM		= 16,	/*!< IO (Initiator mode)	    */
+	BFI_MC_IOIM_IOCOM	= 17,	/*!< good IO completion		    */
+	BFI_MC_TSKIM		= 18,	/*!< Initiator Task management	    */
+	BFI_MC_SBOOT		= 19,	/*!< SAN boot services		    */
+	BFI_MC_IPFC		= 20,	/*!< IP over FC Msgs		    */
+	BFI_MC_PORT		= 21,	/*!< Physical port		    */
+	BFI_MC_SFP		= 22,	/*!< SFP module			    */
+	BFI_MC_MSGQ		= 23,	/*!< MSGQ			    */
+	BFI_MC_ENET		= 24,	/*!< ENET commands/responses	    */
+	BFI_MC_MAX		= 32
+};
+
+#define BFI_IOC_MAX_CQS		4
+#define BFI_IOC_MAX_CQS_ASIC	8
+#define BFI_IOC_MSGLEN_MAX	32	/* 32 bytes */
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
+/**
+ *----------------------------------------------------------------------
+ *				IOC
+ *----------------------------------------------------------------------
+ */
+
+enum bfi_ioc_h2i_msgs {
+	BFI_IOC_H2I_ENABLE_REQ		= 1,
+	BFI_IOC_H2I_DISABLE_REQ		= 2,
+	BFI_IOC_H2I_GETATTR_REQ		= 3,
+	BFI_IOC_H2I_DBG_SYNC		= 4,
+	BFI_IOC_H2I_DBG_DUMP		= 5,
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
+struct bfi_ioc_getattr_req {
+	struct bfi_mhdr mh;
+	union bfi_addr_u	attr_addr;
+};
+
+struct bfi_ioc_attr {
+	u64		mfg_pwwn;	/*!< Mfg port wwn	   */
+	u64		mfg_nwwn;	/*!< Mfg node wwn	   */
+	mac_t		mfg_mac;	/*!< Mfg mac		   */
+	u16	rsvd_a;
+	u64		pwwn;
+	u64		nwwn;
+	mac_t		mac;		/*!< PBC or Mfg mac	   */
+	u16	rsvd_b;
+	mac_t		fcoe_mac;
+	u16	rsvd_c;
+	char		brcd_serialnum[STRSZ(BFA_MFG_SERIALNUM_SIZE)];
+	u8		pcie_gen;
+	u8		pcie_lanes_orig;
+	u8		pcie_lanes;
+	u8		rx_bbcredit;	/*!< receive buffer credits */
+	u32	adapter_prop;	/*!< adapter properties     */
+	u16	maxfrsize;	/*!< max receive frame size */
+	char		asic_rev;
+	u8		rsvd_d;
+	char		fw_version[BFA_VERSION_LEN];
+	char		optrom_version[BFA_VERSION_LEN];
+	struct bfa_mfg_vpd vpd;
+	u32	card_type;	/*!< card type			*/
+};
+
+/**
+ * BFI_IOC_I2H_GETATTR_REPLY message
+ */
+struct bfi_ioc_getattr_reply {
+	struct bfi_mhdr mh;	/*!< Common msg header		*/
+	u8			status;	/*!< cfg reply status		*/
+	u8			rsvd[3];
+};
+
+/**
+ * Firmware memory page offsets
+ */
+#define BFI_IOC_SMEM_PG0_CB	(0x40)
+#define BFI_IOC_SMEM_PG0_CT	(0x180)
+
+/**
+ * Firmware statistic offset
+ */
+#define BFI_IOC_FWSTATS_OFF	(0x6B40)
+#define BFI_IOC_FWSTATS_SZ	(4096)
+
+/**
+ * Firmware trace offset
+ */
+#define BFI_IOC_TRC_OFF		(0x4b00)
+#define BFI_IOC_TRC_ENTS	256
+
+#define BFI_IOC_FW_SIGNATURE	(0xbfadbfad)
+#define BFI_IOC_MD5SUM_SZ	4
+struct bfi_ioc_image_hdr {
+	u32	signature;	/*!< constant signature */
+	u32	rsvd_a;
+	u32	exec;		/*!< exec vector	*/
+	u32	param;		/*!< parameters		*/
+	u32	rsvd_b[4];
+	u32	md5sum[BFI_IOC_MD5SUM_SZ];
+};
+
+/**
+ *  BFI_IOC_I2H_READY_EVENT message
+ */
+struct bfi_ioc_rdy_event {
+	struct bfi_mhdr mh;		/*!< common msg header */
+	u8			init_status;	/*!< init event status */
+	u8			rsvd[3];
+};
+
+struct bfi_ioc_hbeat {
+	struct bfi_mhdr mh;		/*!< common msg header		*/
+	u32	   hb_count;	/*!< current heart beat count	*/
+};
+
+/**
+ * IOC hardware/firmware state
+ */
+enum bfi_ioc_state {
+	BFI_IOC_UNINIT		= 0,	/*!< not initialized		     */
+	BFI_IOC_INITING		= 1,	/*!< h/w is being initialized	     */
+	BFI_IOC_HWINIT		= 2,	/*!< h/w is initialized		     */
+	BFI_IOC_CFG		= 3,	/*!< IOC configuration in progress   */
+	BFI_IOC_OP		= 4,	/*!< IOC is operational		     */
+	BFI_IOC_DISABLING	= 5,	/*!< IOC is being disabled	     */
+	BFI_IOC_DISABLED	= 6,	/*!< IOC is disabled		     */
+	BFI_IOC_CFG_DISABLED	= 7,	/*!< IOC is being disabled;transient */
+	BFI_IOC_FAIL		= 8,	/*!< IOC heart-beat failure	     */
+	BFI_IOC_MEMTEST		= 9,	/*!< IOC is doing memtest	     */
+};
+
+#define BFI_IOC_ENDIAN_SIG  0x12345678
+
+enum {
+	BFI_ADAPTER_TYPE_FC	= 0x01,		/*!< FC adapters	   */
+	BFI_ADAPTER_TYPE_MK	= 0x0f0000,	/*!< adapter type mask     */
+	BFI_ADAPTER_TYPE_SH	= 16,	        /*!< adapter type shift    */
+	BFI_ADAPTER_NPORTS_MK	= 0xff00,	/*!< number of ports mask  */
+	BFI_ADAPTER_NPORTS_SH	= 8,	        /*!< number of ports shift */
+	BFI_ADAPTER_SPEED_MK	= 0xff,		/*!< adapter speed mask    */
+	BFI_ADAPTER_SPEED_SH	= 0,	        /*!< adapter speed shift   */
+	BFI_ADAPTER_PROTO	= 0x100000,	/*!< prototype adapaters   */
+	BFI_ADAPTER_TTV		= 0x200000,	/*!< TTV debug capable     */
+	BFI_ADAPTER_UNSUPP	= 0x400000,	/*!< unknown adapter type  */
+};
+
+#define BFI_ADAPTER_GETP(__prop, __adap_prop)			\
+	(((__adap_prop) & BFI_ADAPTER_ ## __prop ## _MK) >>	\
+		BFI_ADAPTER_ ## __prop ## _SH)
+#define BFI_ADAPTER_SETP(__prop, __val)				\
+	((__val) << BFI_ADAPTER_ ## __prop ## _SH)
+#define BFI_ADAPTER_IS_PROTO(__adap_type)			\
+	((__adap_type) & BFI_ADAPTER_PROTO)
+#define BFI_ADAPTER_IS_TTV(__adap_type)				\
+	((__adap_type) & BFI_ADAPTER_TTV)
+#define BFI_ADAPTER_IS_UNSUPP(__adap_type)			\
+	((__adap_type) & BFI_ADAPTER_UNSUPP)
+#define BFI_ADAPTER_IS_SPECIAL(__adap_type)			\
+	((__adap_type) & (BFI_ADAPTER_TTV | BFI_ADAPTER_PROTO |	\
+			BFI_ADAPTER_UNSUPP))
+
+/**
+ * BFI_IOC_H2I_ENABLE_REQ & BFI_IOC_H2I_DISABLE_REQ messages
+ */
+struct bfi_ioc_ctrl_req {
+	struct bfi_mhdr mh;
+	u8			ioc_class;
+	u8			rsvd[3];
+	u32		tv_sec;
+};
+
+/**
+ * BFI_IOC_I2H_ENABLE_REPLY & BFI_IOC_I2H_DISABLE_REPLY messages
+ */
+struct bfi_ioc_ctrl_reply {
+	struct bfi_mhdr mh;		/*!< Common msg header     */
+	u8			status;		/*!< enable/disable status */
+	u8			rsvd[3];
+};
+
+#define BFI_IOC_MSGSZ   8
+/**
+ * H2I Messages
+ */
+union bfi_ioc_h2i_msg_u {
+	struct bfi_mhdr mh;
+	struct bfi_ioc_ctrl_req enable_req;
+	struct bfi_ioc_ctrl_req disable_req;
+	struct bfi_ioc_getattr_req getattr_req;
+	u32			mboxmsg[BFI_IOC_MSGSZ];
+};
+
+/**
+ * I2H Messages
+ */
+union bfi_ioc_i2h_msg_u {
+	struct bfi_mhdr mh;
+	struct bfi_ioc_rdy_event rdy_event;
+	u32			mboxmsg[BFI_IOC_MSGSZ];
+};
+
+#pragma pack()
+
+#endif /* __BFI_H__ */
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfi_cna.h net-next-2.6.35-rc1-mod/drivers/net/bna/bfi_cna.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfi_cna.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfi_cna.h	2010-08-10 12:23:09.957137000 -0700
@@ -0,0 +1,199 @@
+/*
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
+ */
+#ifndef __BFI_CNA_H__
+#define __BFI_CNA_H__
+
+#include "bfi.h"
+#include "bfa_defs_cna.h"
+
+#pragma pack(1)
+
+enum bfi_port_h2i {
+	BFI_PORT_H2I_ENABLE_REQ		= (1),
+	BFI_PORT_H2I_DISABLE_REQ	= (2),
+	BFI_PORT_H2I_GET_STATS_REQ	= (3),
+	BFI_PORT_H2I_CLEAR_STATS_REQ	= (4),
+};
+
+enum bfi_port_i2h {
+	BFI_PORT_I2H_ENABLE_RSP		= BFA_I2HM(1),
+	BFI_PORT_I2H_DISABLE_RSP	= BFA_I2HM(2),
+	BFI_PORT_I2H_GET_STATS_RSP	= BFA_I2HM(3),
+	BFI_PORT_I2H_CLEAR_STATS_RSP	= BFA_I2HM(4),
+};
+
+/**
+ * Generic REQ type
+ */
+struct bfi_port_generic_req {
+	struct bfi_mhdr mh;		/*!< msg header			    */
+	u32	msgtag;		/*!< msgtag for reply		    */
+	u32	rsvd;
+};
+
+/**
+ * Generic RSP type
+ */
+struct bfi_port_generic_rsp {
+	struct bfi_mhdr mh;		/*!< common msg header		    */
+	u8		status;		/*!< port enable status		    */
+	u8		rsvd[3];
+	u32	msgtag;		/*!< msgtag for reply		    */
+};
+
+/**
+ * @todo
+ * BFI_PORT_H2I_ENABLE_REQ
+ */
+
+/**
+ * @todo
+ * BFI_PORT_I2H_ENABLE_RSP
+ */
+
+/**
+ * BFI_PORT_H2I_DISABLE_REQ
+ */
+
+/**
+ * BFI_PORT_I2H_DISABLE_RSP
+ */
+
+/**
+ * BFI_PORT_H2I_GET_STATS_REQ
+ */
+struct bfi_port_get_stats_req {
+	struct bfi_mhdr mh;		/*!< common msg header		    */
+	union bfi_addr_u   dma_addr;
+};
+
+/**
+ * BFI_PORT_I2H_GET_STATS_RSP
+ */
+
+/**
+ * BFI_PORT_H2I_CLEAR_STATS_REQ
+ */
+
+/**
+ * BFI_PORT_I2H_CLEAR_STATS_RSP
+ */
+
+union bfi_port_h2i_msg_u {
+	struct bfi_mhdr mh;
+	struct bfi_port_generic_req enable_req;
+	struct bfi_port_generic_req disable_req;
+	struct bfi_port_get_stats_req getstats_req;
+	struct bfi_port_generic_req clearstats_req;
+};
+
+union bfi_port_i2h_msg_u {
+	struct bfi_mhdr mh;
+	struct bfi_port_generic_rsp enable_rsp;
+	struct bfi_port_generic_rsp disable_rsp;
+	struct bfi_port_generic_rsp getstats_rsp;
+	struct bfi_port_generic_rsp clearstats_rsp;
+};
+
+/* @brief Mailbox commands from host to (DCBX/LLDP) firmware */
+enum bfi_cee_h2i_msgs {
+	BFI_CEE_H2I_GET_CFG_REQ = 1,
+	BFI_CEE_H2I_RESET_STATS = 2,
+	BFI_CEE_H2I_GET_STATS_REQ = 3,
+};
+
+/* @brief Mailbox reply and AEN messages from DCBX/LLDP firmware to host */
+enum bfi_cee_i2h_msgs {
+	BFI_CEE_I2H_GET_CFG_RSP = BFA_I2HM(1),
+	BFI_CEE_I2H_RESET_STATS_RSP = BFA_I2HM(2),
+	BFI_CEE_I2H_GET_STATS_RSP = BFA_I2HM(3),
+};
+
+/* Data structures */
+
+/*
+ * @brief H2I command structure for resetting the stats.
+ * BFI_CEE_H2I_RESET_STATS
+ */
+struct bfi_lldp_reset_stats {
+	struct bfi_mhdr mh;
+};
+
+/*
+ * @brief H2I command structure for resetting the stats.
+ * BFI_CEE_H2I_RESET_STATS
+ */
+struct bfi_cee_reset_stats {
+	struct bfi_mhdr mh;
+};
+
+/*
+ * @brief  get configuration  command from host
+ * BFI_CEE_H2I_GET_CFG_REQ
+ */
+struct bfi_cee_get_req {
+	struct bfi_mhdr mh;
+	union bfi_addr_u   dma_addr;
+};
+
+/*
+ * @brief reply message from firmware
+ * BFI_CEE_I2H_GET_CFG_RSP
+ */
+struct bfi_cee_get_rsp {
+	struct bfi_mhdr mh;
+	u8			cmd_status;
+	u8			rsvd[3];
+};
+
+/*
+ * @brief  get configuration  command from host
+ * BFI_CEE_H2I_GET_STATS_REQ
+ */
+struct bfi_cee_stats_req {
+	struct bfi_mhdr mh;
+	union bfi_addr_u   dma_addr;
+};
+
+/*
+ * @brief reply message from firmware
+ * BFI_CEE_I2H_GET_STATS_RSP
+ */
+struct bfi_cee_stats_rsp {
+	struct bfi_mhdr mh;
+	u8			cmd_status;
+	u8			rsvd[3];
+};
+
+/* @brief mailbox command structures from host to firmware */
+union bfi_cee_h2i_msg_u {
+	struct bfi_mhdr mh;
+	struct bfi_cee_get_req get_req;
+	struct bfi_cee_stats_req stats_req;
+};
+
+/* @brief mailbox message structures from firmware to host	*/
+union bfi_cee_i2h_msg_u {
+	struct bfi_mhdr mh;
+	struct bfi_cee_get_rsp get_rsp;
+	struct bfi_cee_stats_rsp stats_rsp;
+};
+
+#pragma pack()
+
+#endif /* __BFI_CNA_H__ */
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfi_ctreg.h net-next-2.6.35-rc1-mod/drivers/net/bna/bfi_ctreg.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfi_ctreg.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfi_ctreg.h	2010-08-10 12:23:09.939139000 -0700
@@ -0,0 +1,637 @@
+/*
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
+#define HOSTFN0_LPU_MBOX0_0		0x00019200
+#define HOSTFN1_LPU_MBOX0_8		0x00019260
+#define LPU_HOSTFN0_MBOX0_0		0x00019280
+#define LPU_HOSTFN1_MBOX0_8		0x000192e0
+#define HOSTFN2_LPU_MBOX0_0		0x00019400
+#define HOSTFN3_LPU_MBOX0_8		0x00019460
+#define LPU_HOSTFN2_MBOX0_0		0x00019480
+#define LPU_HOSTFN3_MBOX0_8		0x000194e0
+#define HOSTFN0_INT_STATUS		0x00014000
+#define __HOSTFN0_HALT_OCCURRED		0x01000000
+#define __HOSTFN0_INT_STATUS_LVL_MK	0x00f00000
+#define __HOSTFN0_INT_STATUS_LVL_SH	20
+#define __HOSTFN0_INT_STATUS_LVL(_v)	((_v) << __HOSTFN0_INT_STATUS_LVL_SH)
+#define __HOSTFN0_INT_STATUS_P_MK	0x000f0000
+#define __HOSTFN0_INT_STATUS_P_SH	16
+#define __HOSTFN0_INT_STATUS_P(_v)	((_v) << __HOSTFN0_INT_STATUS_P_SH)
+#define __HOSTFN0_INT_STATUS_F		0x0000ffff
+#define HOSTFN0_INT_MSK			0x00014004
+#define HOST_PAGE_NUM_FN0		0x00014008
+#define __HOST_PAGE_NUM_FN		0x000001ff
+#define HOST_MSIX_ERR_INDEX_FN0		0x0001400c
+#define __MSIX_ERR_INDEX_FN		0x000001ff
+#define HOSTFN1_INT_STATUS		0x00014100
+#define __HOSTFN1_HALT_OCCURRED		0x01000000
+#define __HOSTFN1_INT_STATUS_LVL_MK	0x00f00000
+#define __HOSTFN1_INT_STATUS_LVL_SH	20
+#define __HOSTFN1_INT_STATUS_LVL(_v)	((_v) << __HOSTFN1_INT_STATUS_LVL_SH)
+#define __HOSTFN1_INT_STATUS_P_MK	0x000f0000
+#define __HOSTFN1_INT_STATUS_P_SH	16
+#define __HOSTFN1_INT_STATUS_P(_v)	((_v) << __HOSTFN1_INT_STATUS_P_SH)
+#define __HOSTFN1_INT_STATUS_F		0x0000ffff
+#define HOSTFN1_INT_MSK			0x00014104
+#define HOST_PAGE_NUM_FN1		0x00014108
+#define HOST_MSIX_ERR_INDEX_FN1		0x0001410c
+#define APP_PLL_425_CTL_REG		0x00014204
+#define __P_425_PLL_LOCK		0x80000000
+#define __APP_PLL_425_SRAM_USE_100MHZ	0x00100000
+#define __APP_PLL_425_RESET_TIMER_MK	0x000e0000
+#define __APP_PLL_425_RESET_TIMER_SH	17
+#define __APP_PLL_425_RESET_TIMER(_v)	((_v) << __APP_PLL_425_RESET_TIMER_SH)
+#define __APP_PLL_425_LOGIC_SOFT_RESET	0x00010000
+#define __APP_PLL_425_CNTLMT0_1_MK	0x0000c000
+#define __APP_PLL_425_CNTLMT0_1_SH	14
+#define __APP_PLL_425_CNTLMT0_1(_v)	((_v) << __APP_PLL_425_CNTLMT0_1_SH)
+#define __APP_PLL_425_JITLMT0_1_MK	0x00003000
+#define __APP_PLL_425_JITLMT0_1_SH	12
+#define __APP_PLL_425_JITLMT0_1(_v)	((_v) << __APP_PLL_425_JITLMT0_1_SH)
+#define __APP_PLL_425_HREF		0x00000800
+#define __APP_PLL_425_HDIV		0x00000400
+#define __APP_PLL_425_P0_1_MK		0x00000300
+#define __APP_PLL_425_P0_1_SH		8
+#define __APP_PLL_425_P0_1(_v)		((_v) << __APP_PLL_425_P0_1_SH)
+#define __APP_PLL_425_Z0_2_MK		0x000000e0
+#define __APP_PLL_425_Z0_2_SH		5
+#define __APP_PLL_425_Z0_2(_v)		((_v) << __APP_PLL_425_Z0_2_SH)
+#define __APP_PLL_425_RSEL200500	0x00000010
+#define __APP_PLL_425_ENARST		0x00000008
+#define __APP_PLL_425_BYPASS		0x00000004
+#define __APP_PLL_425_LRESETN		0x00000002
+#define __APP_PLL_425_ENABLE		0x00000001
+#define APP_PLL_312_CTL_REG		0x00014208
+#define __P_312_PLL_LOCK		0x80000000
+#define __ENABLE_MAC_AHB_1		0x00800000
+#define __ENABLE_MAC_AHB_0		0x00400000
+#define __ENABLE_MAC_1			0x00200000
+#define __ENABLE_MAC_0			0x00100000
+#define __APP_PLL_312_RESET_TIMER_MK	0x000e0000
+#define __APP_PLL_312_RESET_TIMER_SH	17
+#define __APP_PLL_312_RESET_TIMER(_v)	((_v) << __APP_PLL_312_RESET_TIMER_SH)
+#define __APP_PLL_312_LOGIC_SOFT_RESET	0x00010000
+#define __APP_PLL_312_CNTLMT0_1_MK	0x0000c000
+#define __APP_PLL_312_CNTLMT0_1_SH	14
+#define __APP_PLL_312_CNTLMT0_1(_v)	((_v) << __APP_PLL_312_CNTLMT0_1_SH)
+#define __APP_PLL_312_JITLMT0_1_MK	0x00003000
+#define __APP_PLL_312_JITLMT0_1_SH	12
+#define __APP_PLL_312_JITLMT0_1(_v)	((_v) << __APP_PLL_312_JITLMT0_1_SH)
+#define __APP_PLL_312_HREF		0x00000800
+#define __APP_PLL_312_HDIV		0x00000400
+#define __APP_PLL_312_P0_1_MK		0x00000300
+#define __APP_PLL_312_P0_1_SH		8
+#define __APP_PLL_312_P0_1(_v)		((_v) << __APP_PLL_312_P0_1_SH)
+#define __APP_PLL_312_Z0_2_MK		0x000000e0
+#define __APP_PLL_312_Z0_2_SH		5
+#define __APP_PLL_312_Z0_2(_v)		((_v) << __APP_PLL_312_Z0_2_SH)
+#define __APP_PLL_312_RSEL200500	0x00000010
+#define __APP_PLL_312_ENARST		0x00000008
+#define __APP_PLL_312_BYPASS		0x00000004
+#define __APP_PLL_312_LRESETN		0x00000002
+#define __APP_PLL_312_ENABLE		0x00000001
+#define MBIST_CTL_REG			0x00014220
+#define __EDRAM_BISTR_START		0x00000004
+#define __MBIST_RESET			0x00000002
+#define __MBIST_START			0x00000001
+#define MBIST_STAT_REG			0x00014224
+#define __EDRAM_BISTR_STATUS		0x00000008
+#define __EDRAM_BISTR_DONE		0x00000004
+#define __MEM_BIT_STATUS		0x00000002
+#define __MBIST_DONE			0x00000001
+#define HOST_SEM0_REG			0x00014230
+#define __HOST_SEMAPHORE		0x00000001
+#define HOST_SEM1_REG			0x00014234
+#define HOST_SEM2_REG			0x00014238
+#define HOST_SEM3_REG			0x0001423c
+#define HOST_SEM0_INFO_REG		0x00014240
+#define HOST_SEM1_INFO_REG		0x00014244
+#define HOST_SEM2_INFO_REG		0x00014248
+#define HOST_SEM3_INFO_REG		0x0001424c
+#define ETH_MAC_SER_REG			0x00014288
+#define __APP_EMS_CKBUFAMPIN		0x00000020
+#define __APP_EMS_REFCLKSEL		0x00000010
+#define __APP_EMS_CMLCKSEL		0x00000008
+#define __APP_EMS_REFCKBUFEN2		0x00000004
+#define __APP_EMS_REFCKBUFEN1		0x00000002
+#define __APP_EMS_CHANNEL_SEL		0x00000001
+#define HOSTFN2_INT_STATUS		0x00014300
+#define __HOSTFN2_HALT_OCCURRED		0x01000000
+#define __HOSTFN2_INT_STATUS_LVL_MK	0x00f00000
+#define __HOSTFN2_INT_STATUS_LVL_SH	20
+#define __HOSTFN2_INT_STATUS_LVL(_v)	((_v) << __HOSTFN2_INT_STATUS_LVL_SH)
+#define __HOSTFN2_INT_STATUS_P_MK	0x000f0000
+#define __HOSTFN2_INT_STATUS_P_SH	16
+#define __HOSTFN2_INT_STATUS_P(_v)	((_v) << __HOSTFN2_INT_STATUS_P_SH)
+#define __HOSTFN2_INT_STATUS_F		0x0000ffff
+#define HOSTFN2_INT_MSK			0x00014304
+#define HOST_PAGE_NUM_FN2		0x00014308
+#define HOST_MSIX_ERR_INDEX_FN2		0x0001430c
+#define HOSTFN3_INT_STATUS		0x00014400
+#define __HALT_OCCURRED			0x01000000
+#define __HOSTFN3_INT_STATUS_LVL_MK	0x00f00000
+#define __HOSTFN3_INT_STATUS_LVL_SH	20
+#define __HOSTFN3_INT_STATUS_LVL(_v)	((_v) << __HOSTFN3_INT_STATUS_LVL_SH)
+#define __HOSTFN3_INT_STATUS_P_MK	0x000f0000
+#define __HOSTFN3_INT_STATUS_P_SH	16
+#define __HOSTFN3_INT_STATUS_P(_v)	((_v) << __HOSTFN3_INT_STATUS_P_SH)
+#define __HOSTFN3_INT_STATUS_F		0x0000ffff
+#define HOSTFN3_INT_MSK			0x00014404
+#define HOST_PAGE_NUM_FN3		0x00014408
+#define HOST_MSIX_ERR_INDEX_FN3		0x0001440c
+#define FNC_ID_REG			0x00014600
+#define __FUNCTION_NUMBER		0x00000007
+#define FNC_PERS_REG			0x00014604
+#define __F3_FUNCTION_ACTIVE		0x80000000
+#define __F3_FUNCTION_MODE		0x40000000
+#define __F3_PORT_MAP_MK		0x30000000
+#define __F3_PORT_MAP_SH		28
+#define __F3_PORT_MAP(_v)		((_v) << __F3_PORT_MAP_SH)
+#define __F3_VM_MODE			0x08000000
+#define __F3_INTX_STATUS_MK		0x07000000
+#define __F3_INTX_STATUS_SH		24
+#define __F3_INTX_STATUS(_v)		((_v) << __F3_INTX_STATUS_SH)
+#define __F2_FUNCTION_ACTIVE		0x00800000
+#define __F2_FUNCTION_MODE		0x00400000
+#define __F2_PORT_MAP_MK		0x00300000
+#define __F2_PORT_MAP_SH		20
+#define __F2_PORT_MAP(_v)		((_v) << __F2_PORT_MAP_SH)
+#define __F2_VM_MODE			0x00080000
+#define __F2_INTX_STATUS_MK		0x00070000
+#define __F2_INTX_STATUS_SH		16
+#define __F2_INTX_STATUS(_v)		((_v) << __F2_INTX_STATUS_SH)
+#define __F1_FUNCTION_ACTIVE		0x00008000
+#define __F1_FUNCTION_MODE		0x00004000
+#define __F1_PORT_MAP_MK		0x00003000
+#define __F1_PORT_MAP_SH		12
+#define __F1_PORT_MAP(_v)		((_v) << __F1_PORT_MAP_SH)
+#define __F1_VM_MODE			0x00000800
+#define __F1_INTX_STATUS_MK		0x00000700
+#define __F1_INTX_STATUS_SH		8
+#define __F1_INTX_STATUS(_v)		((_v) << __F1_INTX_STATUS_SH)
+#define __F0_FUNCTION_ACTIVE		0x00000080
+#define __F0_FUNCTION_MODE		0x00000040
+#define __F0_PORT_MAP_MK		0x00000030
+#define __F0_PORT_MAP_SH		4
+#define __F0_PORT_MAP(_v)		((_v) << __F0_PORT_MAP_SH)
+#define __F0_VM_MODE		0x00000008
+#define __F0_INTX_STATUS		0x00000007
+enum {
+	__F0_INTX_STATUS_MSIX		= 0x0,
+	__F0_INTX_STATUS_INTA		= 0x1,
+	__F0_INTX_STATUS_INTB		= 0x2,
+	__F0_INTX_STATUS_INTC		= 0x3,
+	__F0_INTX_STATUS_INTD		= 0x4,
+};
+#define OP_MODE				0x0001460c
+#define __APP_ETH_CLK_LOWSPEED		0x00000004
+#define __GLOBAL_CORECLK_HALFSPEED	0x00000002
+#define __GLOBAL_FCOE_MODE		0x00000001
+#define HOST_SEM4_REG			0x00014610
+#define HOST_SEM5_REG			0x00014614
+#define HOST_SEM6_REG			0x00014618
+#define HOST_SEM7_REG			0x0001461c
+#define HOST_SEM4_INFO_REG		0x00014620
+#define HOST_SEM5_INFO_REG		0x00014624
+#define HOST_SEM6_INFO_REG		0x00014628
+#define HOST_SEM7_INFO_REG		0x0001462c
+#define HOSTFN0_LPU0_MBOX0_CMD_STAT	0x00019000
+#define __HOSTFN0_LPU0_MBOX0_INFO_MK	0xfffffffe
+#define __HOSTFN0_LPU0_MBOX0_INFO_SH	1
+#define __HOSTFN0_LPU0_MBOX0_INFO(_v)	((_v) << __HOSTFN0_LPU0_MBOX0_INFO_SH)
+#define __HOSTFN0_LPU0_MBOX0_CMD_STATUS 0x00000001
+#define HOSTFN0_LPU1_MBOX0_CMD_STAT	0x00019004
+#define __HOSTFN0_LPU1_MBOX0_INFO_MK	0xfffffffe
+#define __HOSTFN0_LPU1_MBOX0_INFO_SH	1
+#define __HOSTFN0_LPU1_MBOX0_INFO(_v)	((_v) << __HOSTFN0_LPU1_MBOX0_INFO_SH)
+#define __HOSTFN0_LPU1_MBOX0_CMD_STATUS 0x00000001
+#define LPU0_HOSTFN0_MBOX0_CMD_STAT	0x00019008
+#define __LPU0_HOSTFN0_MBOX0_INFO_MK	0xfffffffe
+#define __LPU0_HOSTFN0_MBOX0_INFO_SH	1
+#define __LPU0_HOSTFN0_MBOX0_INFO(_v)	((_v) << __LPU0_HOSTFN0_MBOX0_INFO_SH)
+#define __LPU0_HOSTFN0_MBOX0_CMD_STATUS 0x00000001
+#define LPU1_HOSTFN0_MBOX0_CMD_STAT	0x0001900c
+#define __LPU1_HOSTFN0_MBOX0_INFO_MK	0xfffffffe
+#define __LPU1_HOSTFN0_MBOX0_INFO_SH	1
+#define __LPU1_HOSTFN0_MBOX0_INFO(_v)	((_v) << __LPU1_HOSTFN0_MBOX0_INFO_SH)
+#define __LPU1_HOSTFN0_MBOX0_CMD_STATUS 0x00000001
+#define HOSTFN1_LPU0_MBOX0_CMD_STAT	0x00019010
+#define __HOSTFN1_LPU0_MBOX0_INFO_MK	0xfffffffe
+#define __HOSTFN1_LPU0_MBOX0_INFO_SH	1
+#define __HOSTFN1_LPU0_MBOX0_INFO(_v)	((_v) << __HOSTFN1_LPU0_MBOX0_INFO_SH)
+#define __HOSTFN1_LPU0_MBOX0_CMD_STATUS 0x00000001
+#define HOSTFN1_LPU1_MBOX0_CMD_STAT	0x00019014
+#define __HOSTFN1_LPU1_MBOX0_INFO_MK	0xfffffffe
+#define __HOSTFN1_LPU1_MBOX0_INFO_SH	1
+#define __HOSTFN1_LPU1_MBOX0_INFO(_v)	((_v) << __HOSTFN1_LPU1_MBOX0_INFO_SH)
+#define __HOSTFN1_LPU1_MBOX0_CMD_STATUS 0x00000001
+#define LPU0_HOSTFN1_MBOX0_CMD_STAT	0x00019018
+#define __LPU0_HOSTFN1_MBOX0_INFO_MK	0xfffffffe
+#define __LPU0_HOSTFN1_MBOX0_INFO_SH	1
+#define __LPU0_HOSTFN1_MBOX0_INFO(_v)	((_v) << __LPU0_HOSTFN1_MBOX0_INFO_SH)
+#define __LPU0_HOSTFN1_MBOX0_CMD_STATUS 0x00000001
+#define LPU1_HOSTFN1_MBOX0_CMD_STAT	0x0001901c
+#define __LPU1_HOSTFN1_MBOX0_INFO_MK	0xfffffffe
+#define __LPU1_HOSTFN1_MBOX0_INFO_SH	1
+#define __LPU1_HOSTFN1_MBOX0_INFO(_v)	((_v) << __LPU1_HOSTFN1_MBOX0_INFO_SH)
+#define __LPU1_HOSTFN1_MBOX0_CMD_STATUS 0x00000001
+#define HOSTFN2_LPU0_MBOX0_CMD_STAT	0x00019150
+#define __HOSTFN2_LPU0_MBOX0_INFO_MK	0xfffffffe
+#define __HOSTFN2_LPU0_MBOX0_INFO_SH	1
+#define __HOSTFN2_LPU0_MBOX0_INFO(_v)	((_v) << __HOSTFN2_LPU0_MBOX0_INFO_SH)
+#define __HOSTFN2_LPU0_MBOX0_CMD_STATUS 0x00000001
+#define HOSTFN2_LPU1_MBOX0_CMD_STAT	0x00019154
+#define __HOSTFN2_LPU1_MBOX0_INFO_MK	0xfffffffe
+#define __HOSTFN2_LPU1_MBOX0_INFO_SH	1
+#define __HOSTFN2_LPU1_MBOX0_INFO(_v)	((_v) << __HOSTFN2_LPU1_MBOX0_INFO_SH)
+#define __HOSTFN2_LPU1_MBOX0BOX0_CMD_STATUS 0x00000001
+#define LPU0_HOSTFN2_MBOX0_CMD_STAT	0x00019158
+#define __LPU0_HOSTFN2_MBOX0_INFO_MK	0xfffffffe
+#define __LPU0_HOSTFN2_MBOX0_INFO_SH	1
+#define __LPU0_HOSTFN2_MBOX0_INFO(_v)	((_v) << __LPU0_HOSTFN2_MBOX0_INFO_SH)
+#define __LPU0_HOSTFN2_MBOX0_CMD_STATUS 0x00000001
+#define LPU1_HOSTFN2_MBOX0_CMD_STAT	0x0001915c
+#define __LPU1_HOSTFN2_MBOX0_INFO_MK	0xfffffffe
+#define __LPU1_HOSTFN2_MBOX0_INFO_SH	1
+#define __LPU1_HOSTFN2_MBOX0_INFO(_v)	((_v) << __LPU1_HOSTFN2_MBOX0_INFO_SH)
+#define __LPU1_HOSTFN2_MBOX0_CMD_STATUS 0x00000001
+#define HOSTFN3_LPU0_MBOX0_CMD_STAT	0x00019160
+#define __HOSTFN3_LPU0_MBOX0_INFO_MK	0xfffffffe
+#define __HOSTFN3_LPU0_MBOX0_INFO_SH	1
+#define __HOSTFN3_LPU0_MBOX0_INFO(_v)	((_v) << __HOSTFN3_LPU0_MBOX0_INFO_SH)
+#define __HOSTFN3_LPU0_MBOX0_CMD_STATUS 0x00000001
+#define HOSTFN3_LPU1_MBOX0_CMD_STAT	0x00019164
+#define __HOSTFN3_LPU1_MBOX0_INFO_MK	0xfffffffe
+#define __HOSTFN3_LPU1_MBOX0_INFO_SH	1
+#define __HOSTFN3_LPU1_MBOX0_INFO(_v)	((_v) << __HOSTFN3_LPU1_MBOX0_INFO_SH)
+#define __HOSTFN3_LPU1_MBOX0_CMD_STATUS 0x00000001
+#define LPU0_HOSTFN3_MBOX0_CMD_STAT	0x00019168
+#define __LPU0_HOSTFN3_MBOX0_INFO_MK	0xfffffffe
+#define __LPU0_HOSTFN3_MBOX0_INFO_SH	1
+#define __LPU0_HOSTFN3_MBOX0_INFO(_v)	((_v) << __LPU0_HOSTFN3_MBOX0_INFO_SH)
+#define __LPU0_HOSTFN3_MBOX0_CMD_STATUS 0x00000001
+#define LPU1_HOSTFN3_MBOX0_CMD_STAT	0x0001916c
+#define __LPU1_HOSTFN3_MBOX0_INFO_MK	0xfffffffe
+#define __LPU1_HOSTFN3_MBOX0_INFO_SH	1
+#define __LPU1_HOSTFN3_MBOX0_INFO(_v)	((_v) << __LPU1_HOSTFN3_MBOX0_INFO_SH)
+#define __LPU1_HOSTFN3_MBOX0_CMD_STATUS	0x00000001
+#define FW_INIT_HALT_P0			0x000191ac
+#define __FW_INIT_HALT_P		0x00000001
+#define FW_INIT_HALT_P1			0x000191bc
+#define CPE_PI_PTR_Q0			0x00038000
+#define __CPE_PI_UNUSED_MK		0xffff0000
+#define __CPE_PI_UNUSED_SH		16
+#define __CPE_PI_UNUSED(_v)		((_v) << __CPE_PI_UNUSED_SH)
+#define __CPE_PI_PTR			0x0000ffff
+#define CPE_PI_PTR_Q1			0x00038040
+#define CPE_CI_PTR_Q0			0x00038004
+#define __CPE_CI_UNUSED_MK		0xffff0000
+#define __CPE_CI_UNUSED_SH		16
+#define __CPE_CI_UNUSED(_v)		((_v) << __CPE_CI_UNUSED_SH)
+#define __CPE_CI_PTR			0x0000ffff
+#define CPE_CI_PTR_Q1			0x00038044
+#define CPE_DEPTH_Q0			0x00038008
+#define __CPE_DEPTH_UNUSED_MK		0xf8000000
+#define __CPE_DEPTH_UNUSED_SH		27
+#define __CPE_DEPTH_UNUSED(_v)		((_v) << __CPE_DEPTH_UNUSED_SH)
+#define __CPE_MSIX_VEC_INDEX_MK		0x07ff0000
+#define __CPE_MSIX_VEC_INDEX_SH		16
+#define __CPE_MSIX_VEC_INDEX(_v)	((_v) << __CPE_MSIX_VEC_INDEX_SH)
+#define __CPE_DEPTH			0x0000ffff
+#define CPE_DEPTH_Q1			0x00038048
+#define CPE_QCTRL_Q0			0x0003800c
+#define __CPE_CTRL_UNUSED30_MK		0xfc000000
+#define __CPE_CTRL_UNUSED30_SH		26
+#define __CPE_CTRL_UNUSED30(_v)		((_v) << __CPE_CTRL_UNUSED30_SH)
+#define __CPE_FUNC_INT_CTRL_MK		0x03000000
+#define __CPE_FUNC_INT_CTRL_SH		24
+#define __CPE_FUNC_INT_CTRL(_v)		((_v) << __CPE_FUNC_INT_CTRL_SH)
+enum {
+	__CPE_FUNC_INT_CTRL_DISABLE		= 0x0,
+	__CPE_FUNC_INT_CTRL_F2NF		= 0x1,
+	__CPE_FUNC_INT_CTRL_3QUART		= 0x2,
+	__CPE_FUNC_INT_CTRL_HALF		= 0x3,
+};
+#define __CPE_CTRL_UNUSED20_MK		0x00f00000
+#define __CPE_CTRL_UNUSED20_SH		20
+#define __CPE_CTRL_UNUSED20(_v)		((_v) << __CPE_CTRL_UNUSED20_SH)
+#define __CPE_SCI_TH_MK			0x000f0000
+#define __CPE_SCI_TH_SH			16
+#define __CPE_SCI_TH(_v)		((_v) << __CPE_SCI_TH_SH)
+#define __CPE_CTRL_UNUSED10_MK		0x0000c000
+#define __CPE_CTRL_UNUSED10_SH		14
+#define __CPE_CTRL_UNUSED10(_v)		((_v) << __CPE_CTRL_UNUSED10_SH)
+#define __CPE_ACK_PENDING		0x00002000
+#define __CPE_CTRL_UNUSED40_MK		0x00001c00
+#define __CPE_CTRL_UNUSED40_SH		10
+#define __CPE_CTRL_UNUSED40(_v)		((_v) << __CPE_CTRL_UNUSED40_SH)
+#define __CPE_PCIEID_MK			0x00000300
+#define __CPE_PCIEID_SH			8
+#define __CPE_PCIEID(_v)		((_v) << __CPE_PCIEID_SH)
+#define __CPE_CTRL_UNUSED00_MK		0x000000fe
+#define __CPE_CTRL_UNUSED00_SH		1
+#define __CPE_CTRL_UNUSED00(_v)		((_v) << __CPE_CTRL_UNUSED00_SH)
+#define __CPE_ESIZE			0x00000001
+#define CPE_QCTRL_Q1			0x0003804c
+#define __CPE_CTRL_UNUSED31_MK		0xfc000000
+#define __CPE_CTRL_UNUSED31_SH		26
+#define __CPE_CTRL_UNUSED31(_v)		((_v) << __CPE_CTRL_UNUSED31_SH)
+#define __CPE_CTRL_UNUSED21_MK		0x00f00000
+#define __CPE_CTRL_UNUSED21_SH		20
+#define __CPE_CTRL_UNUSED21(_v)		((_v) << __CPE_CTRL_UNUSED21_SH)
+#define __CPE_CTRL_UNUSED11_MK		0x0000c000
+#define __CPE_CTRL_UNUSED11_SH		14
+#define __CPE_CTRL_UNUSED11(_v)		((_v) << __CPE_CTRL_UNUSED11_SH)
+#define __CPE_CTRL_UNUSED41_MK		0x00001c00
+#define __CPE_CTRL_UNUSED41_SH		10
+#define __CPE_CTRL_UNUSED41(_v)		((_v) << __CPE_CTRL_UNUSED41_SH)
+#define __CPE_CTRL_UNUSED01_MK		0x000000fe
+#define __CPE_CTRL_UNUSED01_SH		1
+#define __CPE_CTRL_UNUSED01(_v)		((_v) << __CPE_CTRL_UNUSED01_SH)
+#define RME_PI_PTR_Q0			0x00038020
+#define __LATENCY_TIME_STAMP_MK		0xffff0000
+#define __LATENCY_TIME_STAMP_SH		16
+#define __LATENCY_TIME_STAMP(_v)	((_v) << __LATENCY_TIME_STAMP_SH)
+#define __RME_PI_PTR			0x0000ffff
+#define RME_PI_PTR_Q1			0x00038060
+#define RME_CI_PTR_Q0			0x00038024
+#define __DELAY_TIME_STAMP_MK		0xffff0000
+#define __DELAY_TIME_STAMP_SH		16
+#define __DELAY_TIME_STAMP(_v)		((_v) << __DELAY_TIME_STAMP_SH)
+#define __RME_CI_PTR			0x0000ffff
+#define RME_CI_PTR_Q1			0x00038064
+#define RME_DEPTH_Q0			0x00038028
+#define __RME_DEPTH_UNUSED_MK		0xf8000000
+#define __RME_DEPTH_UNUSED_SH		27
+#define __RME_DEPTH_UNUSED(_v)		((_v) << __RME_DEPTH_UNUSED_SH)
+#define __RME_MSIX_VEC_INDEX_MK		0x07ff0000
+#define __RME_MSIX_VEC_INDEX_SH		16
+#define __RME_MSIX_VEC_INDEX(_v)	((_v) << __RME_MSIX_VEC_INDEX_SH)
+#define __RME_DEPTH			0x0000ffff
+#define RME_DEPTH_Q1			0x00038068
+#define RME_QCTRL_Q0			0x0003802c
+#define __RME_INT_LATENCY_TIMER_MK	0xff000000
+#define __RME_INT_LATENCY_TIMER_SH	24
+#define __RME_INT_LATENCY_TIMER(_v)	((_v) << __RME_INT_LATENCY_TIMER_SH)
+#define __RME_INT_DELAY_TIMER_MK	0x00ff0000
+#define __RME_INT_DELAY_TIMER_SH	16
+#define __RME_INT_DELAY_TIMER(_v)	((_v) << __RME_INT_DELAY_TIMER_SH)
+#define __RME_INT_DELAY_DISABLE		0x00008000
+#define __RME_DLY_DELAY_DISABLE		0x00004000
+#define __RME_ACK_PENDING		0x00002000
+#define __RME_FULL_INTERRUPT_DISABLE	0x00001000
+#define __RME_CTRL_UNUSED10_MK		0x00000c00
+#define __RME_CTRL_UNUSED10_SH		10
+#define __RME_CTRL_UNUSED10(_v)		((_v) << __RME_CTRL_UNUSED10_SH)
+#define __RME_PCIEID_MK			0x00000300
+#define __RME_PCIEID_SH			8
+#define __RME_PCIEID(_v)		((_v) << __RME_PCIEID_SH)
+#define __RME_CTRL_UNUSED00_MK		0x000000fe
+#define __RME_CTRL_UNUSED00_SH		1
+#define __RME_CTRL_UNUSED00(_v)		((_v) << __RME_CTRL_UNUSED00_SH)
+#define __RME_ESIZE			0x00000001
+#define RME_QCTRL_Q1			0x0003806c
+#define __RME_CTRL_UNUSED11_MK		0x00000c00
+#define __RME_CTRL_UNUSED11_SH		10
+#define __RME_CTRL_UNUSED11(_v)		((_v) << __RME_CTRL_UNUSED11_SH)
+#define __RME_CTRL_UNUSED01_MK		0x000000fe
+#define __RME_CTRL_UNUSED01_SH		1
+#define __RME_CTRL_UNUSED01(_v)		((_v) << __RME_CTRL_UNUSED01_SH)
+#define PSS_CTL_REG			0x00018800
+#define __PSS_I2C_CLK_DIV_MK		0x007f0000
+#define __PSS_I2C_CLK_DIV_SH		16
+#define __PSS_I2C_CLK_DIV(_v)		((_v) << __PSS_I2C_CLK_DIV_SH)
+#define __PSS_LMEM_INIT_DONE		0x00001000
+#define __PSS_LMEM_RESET		0x00000200
+#define __PSS_LMEM_INIT_EN		0x00000100
+#define __PSS_LPU1_RESET		0x00000002
+#define __PSS_LPU0_RESET		0x00000001
+#define PSS_ERR_STATUS_REG		0x00018810
+#define __PSS_LPU1_TCM_READ_ERR		0x00200000
+#define __PSS_LPU0_TCM_READ_ERR		0x00100000
+#define __PSS_LMEM5_CORR_ERR		0x00080000
+#define __PSS_LMEM4_CORR_ERR		0x00040000
+#define __PSS_LMEM3_CORR_ERR		0x00020000
+#define __PSS_LMEM2_CORR_ERR		0x00010000
+#define __PSS_LMEM1_CORR_ERR		0x00008000
+#define __PSS_LMEM0_CORR_ERR		0x00004000
+#define __PSS_LMEM5_UNCORR_ERR		0x00002000
+#define __PSS_LMEM4_UNCORR_ERR		0x00001000
+#define __PSS_LMEM3_UNCORR_ERR		0x00000800
+#define __PSS_LMEM2_UNCORR_ERR		0x00000400
+#define __PSS_LMEM1_UNCORR_ERR		0x00000200
+#define __PSS_LMEM0_UNCORR_ERR		0x00000100
+#define __PSS_BAL_PERR			0x00000080
+#define __PSS_DIP_IF_ERR		0x00000040
+#define __PSS_IOH_IF_ERR		0x00000020
+#define __PSS_TDS_IF_ERR		0x00000010
+#define __PSS_RDS_IF_ERR		0x00000008
+#define __PSS_SGM_IF_ERR		0x00000004
+#define __PSS_LPU1_RAM_ERR		0x00000002
+#define __PSS_LPU0_RAM_ERR		0x00000001
+#define ERR_SET_REG			0x00018818
+#define __PSS_ERR_STATUS_SET		0x003fffff
+#define PMM_1T_RESET_REG_P0		0x0002381c
+#define __PMM_1T_RESET_P		0x00000001
+#define PMM_1T_RESET_REG_P1		0x00023c1c
+#define HQM_QSET0_RXQ_DRBL_P0		0x00038000
+#define __RXQ0_ADD_VECTORS_P		0x80000000
+#define __RXQ0_STOP_P			0x40000000
+#define __RXQ0_PRD_PTR_P		0x0000ffff
+#define HQM_QSET1_RXQ_DRBL_P0		0x00038080
+#define __RXQ1_ADD_VECTORS_P		0x80000000
+#define __RXQ1_STOP_P			0x40000000
+#define __RXQ1_PRD_PTR_P		0x0000ffff
+#define HQM_QSET0_RXQ_DRBL_P1		0x0003c000
+#define HQM_QSET1_RXQ_DRBL_P1		0x0003c080
+#define HQM_QSET0_TXQ_DRBL_P0		0x00038020
+#define __TXQ0_ADD_VECTORS_P		0x80000000
+#define __TXQ0_STOP_P			0x40000000
+#define __TXQ0_PRD_PTR_P		0x0000ffff
+#define HQM_QSET1_TXQ_DRBL_P0		0x000380a0
+#define __TXQ1_ADD_VECTORS_P		0x80000000
+#define __TXQ1_STOP_P			0x40000000
+#define __TXQ1_PRD_PTR_P		0x0000ffff
+#define HQM_QSET0_TXQ_DRBL_P1		0x0003c020
+#define HQM_QSET1_TXQ_DRBL_P1		0x0003c0a0
+#define HQM_QSET0_IB_DRBL_1_P0		0x00038040
+#define __IB1_0_ACK_P			0x80000000
+#define __IB1_0_DISABLE_P		0x40000000
+#define __IB1_0_COALESCING_CFG_P_MK	0x00ff0000
+#define __IB1_0_COALESCING_CFG_P_SH	16
+#define __IB1_0_COALESCING_CFG_P(_v)	((_v) << __IB1_0_COALESCING_CFG_P_SH)
+#define __IB1_0_NUM_OF_ACKED_EVENTS_P	0x0000ffff
+#define HQM_QSET1_IB_DRBL_1_P0		0x000380c0
+#define __IB1_1_ACK_P			0x80000000
+#define __IB1_1_DISABLE_P		0x40000000
+#define __IB1_1_COALESCING_CFG_P_MK	0x00ff0000
+#define __IB1_1_COALESCING_CFG_P_SH	16
+#define __IB1_1_COALESCING_CFG_P(_v)	((_v) << __IB1_1_COALESCING_CFG_P_SH)
+#define __IB1_1_NUM_OF_ACKED_EVENTS_P	0x0000ffff
+#define HQM_QSET0_IB_DRBL_1_P1		0x0003c040
+#define HQM_QSET1_IB_DRBL_1_P1		0x0003c0c0
+#define HQM_QSET0_IB_DRBL_2_P0		0x00038060
+#define __IB2_0_ACK_P			0x80000000
+#define __IB2_0_DISABLE_P		0x40000000
+#define __IB2_0_COALESCING_CFG_P_MK	0x00ff0000
+#define __IB2_0_COALESCING_CFG_P_SH	16
+#define __IB2_0_COALESCING_CFG_P(_v)	((_v) << __IB2_0_COALESCING_CFG_P_SH)
+#define __IB2_0_NUM_OF_ACKED_EVENTS_P	0x0000ffff
+#define HQM_QSET1_IB_DRBL_2_P0		0x000380e0
+#define __IB2_1_ACK_P			0x80000000
+#define __IB2_1_DISABLE_P		0x40000000
+#define __IB2_1_COALESCING_CFG_P_MK	0x00ff0000
+#define __IB2_1_COALESCING_CFG_P_SH	16
+#define __IB2_1_COALESCING_CFG_P(_v)	((_v) << __IB2_1_COALESCING_CFG_P_SH)
+#define __IB2_1_NUM_OF_ACKED_EVENTS_P	0x0000ffff
+#define HQM_QSET0_IB_DRBL_2_P1		0x0003c060
+#define HQM_QSET1_IB_DRBL_2_P1		0x0003c0e0
+
+/*
+ * These definitions are either in error/missing in spec. Its auto-generated
+ * from hard coded values in regparse.pl.
+ */
+#define __EMPHPOST_AT_4G_MK_FIX		0x0000001c
+#define __EMPHPOST_AT_4G_SH_FIX		0x00000002
+#define __EMPHPRE_AT_4G_FIX		0x00000003
+#define __SFP_TXRATE_EN_FIX		0x00000100
+#define __SFP_RXRATE_EN_FIX		0x00000080
+
+/*
+ * These register definitions are auto-generated from hard coded values
+ * in regparse.pl.
+ */
+
+/*
+ * These register mapping definitions are auto-generated from mapping tables
+ * in regparse.pl.
+ */
+#define BFA_IOC0_HBEAT_REG		HOST_SEM0_INFO_REG
+#define BFA_IOC0_STATE_REG		HOST_SEM1_INFO_REG
+#define BFA_IOC1_HBEAT_REG		HOST_SEM2_INFO_REG
+#define BFA_IOC1_STATE_REG		HOST_SEM3_INFO_REG
+#define BFA_FW_USE_COUNT		 HOST_SEM4_INFO_REG
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
+#define HQM_QSET_RXQ_DRBL_P0(__n) (HQM_QSET0_RXQ_DRBL_P0 + (__n) \
+	* (HQM_QSET1_RXQ_DRBL_P0 - HQM_QSET0_RXQ_DRBL_P0))
+#define HQM_QSET_TXQ_DRBL_P0(__n) (HQM_QSET0_TXQ_DRBL_P0 + (__n) \
+	* (HQM_QSET1_TXQ_DRBL_P0 - HQM_QSET0_TXQ_DRBL_P0))
+#define HQM_QSET_IB_DRBL_1_P0(__n) (HQM_QSET0_IB_DRBL_1_P0 + (__n) \
+	* (HQM_QSET1_IB_DRBL_1_P0 - HQM_QSET0_IB_DRBL_1_P0))
+#define HQM_QSET_IB_DRBL_2_P0(__n) (HQM_QSET0_IB_DRBL_2_P0 + (__n) \
+	* (HQM_QSET1_IB_DRBL_2_P0 - HQM_QSET0_IB_DRBL_2_P0))
+#define HQM_QSET_RXQ_DRBL_P1(__n) (HQM_QSET0_RXQ_DRBL_P1 + (__n) \
+	* (HQM_QSET1_RXQ_DRBL_P1 - HQM_QSET0_RXQ_DRBL_P1))
+#define HQM_QSET_TXQ_DRBL_P1(__n) (HQM_QSET0_TXQ_DRBL_P1 + (__n) \
+	* (HQM_QSET1_TXQ_DRBL_P1 - HQM_QSET0_TXQ_DRBL_P1))
+#define HQM_QSET_IB_DRBL_1_P1(__n) (HQM_QSET0_IB_DRBL_1_P1 + (__n) \
+	* (HQM_QSET1_IB_DRBL_1_P1 - HQM_QSET0_IB_DRBL_1_P1))
+#define HQM_QSET_IB_DRBL_2_P1(__n) (HQM_QSET0_IB_DRBL_2_P1 + (__n) \
+	* (HQM_QSET1_IB_DRBL_2_P1 - HQM_QSET0_IB_DRBL_2_P1))
+
+#define CPE_Q_NUM(__fn, __q) (((__fn) << 2) + (__q))
+#define RME_Q_NUM(__fn, __q) (((__fn) << 2) + (__q))
+#define CPE_Q_MASK(__q) ((__q) & 0x3)
+#define RME_Q_MASK(__q) ((__q) & 0x3)
+
+/*
+ * PCI MSI-X vector defines
+ */
+enum {
+	BFA_MSIX_CPE_Q0 = 0,
+	BFA_MSIX_CPE_Q1 = 1,
+	BFA_MSIX_CPE_Q2 = 2,
+	BFA_MSIX_CPE_Q3 = 3,
+	BFA_MSIX_RME_Q0 = 4,
+	BFA_MSIX_RME_Q1 = 5,
+	BFA_MSIX_RME_Q2 = 6,
+	BFA_MSIX_RME_Q3 = 7,
+	BFA_MSIX_LPU_ERR = 8,
+	BFA_MSIX_CT_MAX = 9,
+};
+
+/*
+ * And corresponding host interrupt status bit field defines
+ */
+#define __HFN_INT_CPE_Q0		0x00000001U
+#define __HFN_INT_CPE_Q1		0x00000002U
+#define __HFN_INT_CPE_Q2		0x00000004U
+#define __HFN_INT_CPE_Q3		0x00000008U
+#define __HFN_INT_CPE_Q4		0x00000010U
+#define __HFN_INT_CPE_Q5		0x00000020U
+#define __HFN_INT_CPE_Q6		0x00000040U
+#define __HFN_INT_CPE_Q7		0x00000080U
+#define __HFN_INT_RME_Q0		0x00000100U
+#define __HFN_INT_RME_Q1		0x00000200U
+#define __HFN_INT_RME_Q2		0x00000400U
+#define __HFN_INT_RME_Q3		0x00000800U
+#define __HFN_INT_RME_Q4		0x00001000U
+#define __HFN_INT_RME_Q5		0x00002000U
+#define __HFN_INT_RME_Q6		0x00004000U
+#define __HFN_INT_RME_Q7		0x00008000U
+#define __HFN_INT_ERR_EMC		0x00010000U
+#define __HFN_INT_ERR_LPU0		0x00020000U
+#define __HFN_INT_ERR_LPU1		0x00040000U
+#define __HFN_INT_ERR_PSS		0x00080000U
+#define __HFN_INT_MBOX_LPU0		0x00100000U
+#define __HFN_INT_MBOX_LPU1		0x00200000U
+#define __HFN_INT_MBOX1_LPU0		0x00400000U
+#define __HFN_INT_MBOX1_LPU1		0x00800000U
+#define __HFN_INT_LL_HALT		0x01000000U
+#define __HFN_INT_CPE_MASK		0x000000ffU
+#define __HFN_INT_RME_MASK		0x0000ff00U
+
+/*
+ * catapult memory map.
+ */
+#define LL_PGN_HQM0		0x0096
+#define LL_PGN_HQM1		0x0097
+#define PSS_SMEM_PAGE_START	0x8000
+#define PSS_SMEM_PGNUM(_pg0, _ma)	((_pg0) + ((_ma) >> 15))
+#define PSS_SMEM_PGOFF(_ma)	((_ma) & 0x7fff)
+
+/*
+ * End of catapult memory map
+ */
+
+#endif /* __BFI_CTREG_H__ */
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bfi_ll.h net-next-2.6.35-rc1-mod/drivers/net/bna/bfi_ll.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/bfi_ll.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/bfi_ll.h	2010-08-10 12:23:09.948142000 -0700
@@ -0,0 +1,438 @@
+/*
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
+ */
+#ifndef __BFI_LL_H__
+#define __BFI_LL_H__
+
+#include "bfi.h"
+
+#pragma pack(1)
+
+/**
+ * @brief
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
+} ;
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
+
+	BFI_LL_I2H_PORT_ENABLE_AEN = BFA_I2HM(21),
+	BFI_LL_I2H_PORT_DISABLE_AEN = BFA_I2HM(22),
+} ;
+
+/**
+ * @brief bfi_ll_mac_addr_req is used by:
+ *        BFI_LL_H2I_MAC_UCAST_SET_REQ
+ *        BFI_LL_H2I_MAC_UCAST_ADD_REQ
+ *        BFI_LL_H2I_MAC_UCAST_DEL_REQ
+ *        BFI_LL_H2I_MAC_MCAST_ADD_REQ
+ *        BFI_LL_H2I_MAC_MCAST_DEL_REQ
+ */
+struct bfi_ll_mac_addr_req {
+	struct bfi_mhdr mh;		/*!< common msg header */
+	u8		rxf_id;
+	u8		rsvd1[3];
+	mac_t		mac_addr;
+	u8		rsvd2[2];
+};
+
+/**
+ * @brief bfi_ll_mcast_filter_req is used by:
+ *	  BFI_LL_H2I_MAC_MCAST_FILTER_REQ
+ */
+struct bfi_ll_mcast_filter_req {
+	struct bfi_mhdr mh;		/*!< common msg header */
+	u8		rxf_id;
+	u8		enable;
+	u8		rsvd[2];
+};
+
+/**
+ * @brief bfi_ll_mcast_del_all is used by:
+ *	  BFI_LL_H2I_MAC_MCAST_DEL_ALL_REQ
+ */
+struct bfi_ll_mcast_del_all_req {
+	struct bfi_mhdr mh;		/*!< common msg header */
+	u8		   rxf_id;
+	u8		   rsvd[3];
+};
+
+/**
+ * @brief bfi_ll_q_stop_req is used by:
+ *	BFI_LL_H2I_TXQ_STOP_REQ
+ *	BFI_LL_H2I_RXQ_STOP_REQ
+ */
+struct bfi_ll_q_stop_req {
+	struct bfi_mhdr mh;		/*!< common msg header */
+	u32	q_id_mask[2];	/* !< bit-mask for queue ids */
+};
+
+/**
+ * @brief bfi_ll_stats_req is used by:
+ *    BFI_LL_I2H_STATS_GET_REQ
+ *    BFI_LL_I2H_STATS_CLEAR_REQ
+ */
+struct bfi_ll_stats_req {
+	struct bfi_mhdr mh;	/*!< common msg header */
+	u16 stats_mask;	/* !< bit-mask for non-function statistics */
+	u8	rsvd[2];
+	u32 rxf_id_mask[2];	/* !< bit-mask for RxF Statistics */
+	u32 txf_id_mask[2];	/* !< bit-mask for TxF Statistics */
+	union bfi_addr_u  host_buffer;	/* !< where statistics are returned */
+};
+
+/**
+ * @brief defines for "stats_mask" above.
+ */
+#define BFI_LL_STATS_MAC	(1 << 0)	/* !< MAC Statistics */
+#define BFI_LL_STATS_BPC	(1 << 1)	/* !< Pause Stats from BPC */
+#define BFI_LL_STATS_RAD	(1 << 2)	/* !< Rx Admission Statistics */
+#define BFI_LL_STATS_RX_FC	(1 << 3)	/* !< Rx FC Stats from RxA */
+#define BFI_LL_STATS_TX_FC	(1 << 4)	/* !< Tx FC Stats from TxA */
+
+#define BFI_LL_STATS_ALL	0x1f
+
+/**
+ * @brief bfi_ll_port_admin_req
+ */
+struct bfi_ll_port_admin_req {
+	struct bfi_mhdr mh;		/*!< common msg header */
+	u8		 up;
+	u8		 rsvd[3];
+};
+
+/**
+ * @brief bfi_ll_rxf_req is used by:
+ *      BFI_LL_H2I_RXF_PROMISCUOUS_SET_REQ
+ *      BFI_LL_H2I_RXF_DEFAULT_SET_REQ
+ */
+struct bfi_ll_rxf_req {
+	struct bfi_mhdr mh;		/*!< common msg header */
+	u8		rxf_id;
+	u8		enable;
+	u8		rsvd[2];
+};
+
+/**
+ * @brief bfi_ll_rxf_multi_req is used by:
+ *	BFI_LL_H2I_RX_REQ
+ */
+struct bfi_ll_rxf_multi_req {
+	struct bfi_mhdr mh;		/*!< common msg header */
+	u32	rxf_id_mask[2];
+	u8		enable;
+	u8		rsvd[3];
+};
+
+/**
+ * @brief enum for Loopback opmodes
+ */
+enum {
+	BFI_LL_DIAG_LB_OPMODE_EXT = 0,
+	BFI_LL_DIAG_LB_OPMODE_CBL = 1,
+};
+
+/**
+ * @brief bfi_ll_set_pause_req is used by:
+ *	BFI_LL_H2I_SET_PAUSE_REQ
+ */
+struct bfi_ll_set_pause_req {
+	struct bfi_mhdr mh;
+	u8		tx_pause; /* 1 = enable, 0 =  disable */
+	u8		rx_pause; /* 1 = enable, 0 =  disable */
+	u8		rsvd[2];
+};
+
+/**
+ * @brief bfi_ll_mtu_info_req is used by:
+ *	BFI_LL_H2I_MTU_INFO_REQ
+ */
+struct bfi_ll_mtu_info_req {
+	struct bfi_mhdr mh;
+	u16	mtu;
+	u8		rsvd[2];
+};
+
+/**
+ * @brief
+ *	  Response header format used by all responses
+ *	  For both responses and asynchronous notifications
+ */
+struct bfi_ll_rsp {
+	struct bfi_mhdr mh;		/*!< common msg header */
+	u8		error;
+	u8		rsvd[3];
+};
+
+/**
+ * @brief bfi_ll_cee_aen is used by:
+ *	BFI_LL_I2H_LINK_DOWN_AEN
+ *	BFI_LL_I2H_LINK_UP_AEN
+ */
+struct bfi_ll_aen {
+	struct bfi_mhdr mh;		/*!< common msg header */
+	u32	reason;
+	u8		cee_linkup;
+	u8		prio_map;    /*!< LL priority bit-map */
+	u8		rsvd[2];
+};
+
+/**
+ * @brief
+ * 	The following error codes can be returned
+ *	by the mbox commands
+ */
+enum {
+	BFI_LL_CMD_OK 		= 0,
+	BFI_LL_CMD_FAIL 	= 1,
+	BFI_LL_CMD_DUP_ENTRY	= 2,	/* !< Duplicate entry in CAM */
+	BFI_LL_CMD_CAM_FULL	= 3,	/* !< CAM is full */
+	BFI_LL_CMD_NOT_OWNER	= 4,   	/* !< Not permitted, b'cos not owner */
+	BFI_LL_CMD_NOT_EXEC	= 5,   	/* !< Was not sent to f/w at all */
+	BFI_LL_CMD_WAITING	= 6,	/* !< Waiting for completion (VMware) */
+	BFI_LL_CMD_PORT_DISABLED	= 7,	/* !< port in disabled state */
+} ;
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
+/* BPC Tx Registers */
+struct bfi_ll_stats_bpc {
+	/* transmit stats */
+	u64 tx_pause[8];
+	u64 tx_zero_pause[8];	/*!< Pause cancellation */
+	/*!<Pause initiation rather than retention */
+	u64 tx_first_pause[8];
+
+	/* receive stats */
+	u64 rx_pause[8];
+	u64 rx_zero_pause[8];	/*!< Pause cancellation */
+	/*!<Pause initiation rather than retention */
+	u64 rx_first_pause[8];
+};
+
+/* MAC Rx Statistics */
+struct bfi_ll_stats_mac {
+	u64 frame_64;		/* both rx and tx counter */
+	u64 frame_65_127;		/* both rx and tx counter */
+	u64 frame_128_255;		/* both rx and tx counter */
+	u64 frame_256_511;		/* both rx and tx counter */
+	u64 frame_512_1023;	/* both rx and tx counter */
+	u64 frame_1024_1518;	/* both rx and tx counter */
+	u64 frame_1519_1522;	/* both rx and tx counter */
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
diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/cna.h net-next-2.6.35-rc1-mod/drivers/net/bna/cna.h
--- net-next-2.6.35-rc1-orig/drivers/net/bna/cna.h	1969-12-31 16:00:00.000000000 -0800
+++ net-next-2.6.35-rc1-mod/drivers/net/bna/cna.h	2010-08-10 12:23:09.916140000 -0700
@@ -0,0 +1,81 @@
+/*
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
+ * Copyright (c) 2006-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ */
+
+#ifndef __CNA_H__
+#define __CNA_H__
+
+#include <linux/version.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <linux/bitops.h>
+#include <linux/timer.h>
+#include <linux/interrupt.h>
+#include <linux/if_ether.h>
+#include <asm/page.h>
+#include <asm/io.h>
+#include <asm/string.h>
+
+#include <linux/list.h>
+
+#define bfa_sm_fault(__mod, __event)    do {                            \
+	pr_err("SM Assertion failure: %s: %d: event = %d", __FILE__, __LINE__, \
+		__event); \
+} while (0)
+
+extern char bfa_version[];
+
+#define	CNA_FW_FILE_CT	"ctfw_cna.bin"
+#define FC_SYMNAME_MAX	256	/*!< max name server symbolic name size */
+
+#pragma pack(1)
+
+#define MAC_ADDRLEN	(6)
+typedef struct mac { u8 mac[MAC_ADDRLEN]; } mac_t;
+
+#pragma pack()
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
+	if (!list_empty(_q)) {						\
+		(*((struct list_head **) (_qe))) = bfa_q_next(_q);	\
+		bfa_q_prev(bfa_q_next(*((struct list_head **) _qe))) =	\
+						(struct list_head *) (_q); \
+		bfa_q_next(_q) = bfa_q_next(*((struct list_head **) _qe)); \
+		bfa_q_qe_init(*((struct list_head **) _qe));		\
+	} else {							\
+		*((struct list_head **) (_qe)) = (struct list_head *) NULL; \
+	}								\
+}
+
+#endif /* __CNA_H__ */
