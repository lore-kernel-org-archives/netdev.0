From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 7/9] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 28 Aug 2009 22:18:39 -0700
Message-ID: <200908290518.n7T5IdjS031896@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amathur@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:35855 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbZH2FYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 01:24:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 7/9 which contains linux driver source for 
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.

We wish this patch to be considered for inclusion in 2.6.30 

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---


diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_adapter.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_adapter.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_adapter.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_adapter.h	2009-08-28 21:09:27.134637000 -0700
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
+	/*
+	 *!< adapter serial num length
+	 */
+	BFA_ADAPTER_MODEL_NAME_LEN = 16,	/*  model name length */
+	BFA_ADAPTER_MODEL_DESCR_LEN = 128,	/*  model description length */
+	BFA_ADAPTER_MFG_NAME_LEN = 8,	/*  manufacturer name length */
+	BFA_ADAPTER_SYM_NAME_LEN = 64,	/*  adapter symbolic name length */
+	BFA_ADAPTER_OS_TYPE_LEN = 64,	/*  adapter os type length */
+};
+
+struct bfa_adapter_attr_s {
+	char manufacturer[BFA_ADAPTER_MFG_NAME_LEN];
+	char serial_num[BFA_ADAPTER_SERIAL_NUM_LEN];
+	u32 rsvd1;
+	char model[BFA_ADAPTER_MODEL_NAME_LEN];
+	char model_descr[BFA_ADAPTER_MODEL_DESCR_LEN];
+	wwn_t pwwn;
+	char node_symname[FC_SYMNAME_MAX];
+	char hw_ver[BFA_VERSION_LEN];
+	char fw_ver[BFA_VERSION_LEN];
+	char optrom_ver[BFA_VERSION_LEN];
+	char os_type[BFA_ADAPTER_OS_TYPE_LEN];
+	struct bfa_mfg_vpd_s vpd;
+	struct mac_s mac;
+
+	u8 nports;
+	u8 max_speed;
+	u8 prototype;
+	char asic_rev;
+
+	u8 pcie_gen;
+	u8 pcie_lanes_orig;
+	u8 pcie_lanes;
+	u8 cna_capable;
+};
+
+/**
+ * BFA adapter level events
+ * Arguments below are in BFAL context from Mgmt
+ * BFA_PORT_AEN_ADD:        [in]: None     [out]: serial_num, pwwn, nports
+ * BFA_PORT_AEN_REMOVE:     [in]: pwwn     [out]: serial_num, pwwn, nports
+ */
+enum bfa_adapter_aen_event {
+	BFA_ADAPTER_AEN_ADD = 1,	/*  New Adapter found event */
+	BFA_ADAPTER_AEN_REMOVE = 2,	/*  Adapter removed event */
+};
+
+struct bfa_adapter_aen_data_s {
+	char serial_num[BFA_ADAPTER_SERIAL_NUM_LEN];
+	u32 nports;		/*  Number of NPorts */
+	wwn_t pwwn;		/*  WWN of one of its physical port */
+};
+
+#endif /* __BFA_DEFS_ADAPTER_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_aen.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_aen.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_aen.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_aen.h	2009-08-28 21:09:26.991613000 -0700
@@ -0,0 +1,80 @@
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
+#ifndef __BFA_DEFS_AEN_H__
+#define __BFA_DEFS_AEN_H__
+
+#include <defs/bfa_defs_types.h>
+#include <defs/bfa_defs_ioc.h>
+#include <defs/bfa_defs_adapter.h>
+#include <defs/bfa_defs_port.h>
+#include <defs/bfa_defs_lport.h>
+#include <defs/bfa_defs_rport.h>
+#include <defs/bfa_defs_itnim.h>
+#include <defs/bfa_defs_tin.h>
+#include <defs/bfa_defs_ipfc.h>
+#include <defs/bfa_defs_audit.h>
+#include <defs/bfa_defs_ethport.h>
+
+enum bfa_aen_category {
+	BFA_AEN_CAT_ADAPTER = 1,
+	BFA_AEN_CAT_PORT = 2,
+	BFA_AEN_CAT_LPORT = 3,
+	BFA_AEN_CAT_RPORT = 4,
+	BFA_AEN_CAT_ITNIM = 5,
+	BFA_AEN_CAT_TIN = 6,
+	BFA_AEN_CAT_IPFC = 7,
+	BFA_AEN_CAT_AUDIT = 8,
+	BFA_AEN_CAT_IOC = 9,
+	BFA_AEN_CAT_ETHPORT = 10,
+	BFA_AEN_MAX_CAT = 10
+};
+
+#pragma pack(1)
+union bfa_aen_data_u {
+	struct bfa_adapter_aen_data_s adapter;
+	struct bfa_port_aen_data_s port;
+	struct bfa_lport_aen_data_s lport;
+	struct bfa_rport_aen_data_s rport;
+	struct bfa_itnim_aen_data_s itnim;
+	struct bfa_audit_aen_data_s audit;
+	struct bfa_ioc_aen_data_s ioc;
+	struct bfa_ethport_aen_data_s ethport;
+};
+
+struct bfa_aen_entry_s {
+	enum bfa_aen_category aen_category;
+	int aen_type;
+	union bfa_aen_data_u aen_data;
+	struct bfa_timeval_s aen_tv;
+	s32 seq_num;
+	s32 bfad_num;
+	s32 rsvd[1];
+};
+
+#pragma pack()
+
+#define bfa_aen_event_t int
+
+#endif /* __BFA_DEFS_AEN_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_audit.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_audit.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_audit.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_audit.h	2009-08-28 21:09:26.830609000 -0700
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
+#ifndef __BFA_DEFS_AUDIT_H__
+#define __BFA_DEFS_AUDIT_H__
+
+#include <bfa_os_inc.h>
+
+/**
+ * BFA audit events
+ */
+enum bfa_audit_aen_event {
+	BFA_AUDIT_AEN_AUTH_ENABLE = 1,
+	BFA_AUDIT_AEN_AUTH_DISABLE = 2,
+};
+
+/**
+ * audit event data
+ */
+struct bfa_audit_aen_data_s {
+	wwn_t pwwn;
+};
+
+#endif /* __BFA_DEFS_AUDIT_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_auth.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_auth.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_auth.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_auth.h	2009-08-28 21:09:27.236608000 -0700
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
+#ifndef __BFA_DEFS_AUTH_H__
+#define __BFA_DEFS_AUTH_H__
+
+#include <defs/bfa_defs_types.h>
+
+#define PUBLIC_KEY			15409
+#define PRIVATE_KEY			19009
+#define KEY_LEN				32399
+#define BFA_AUTH_SECRET_STRING_LEN	256
+#define BFA_AUTH_FAIL_TIMEOUT		0xFF
+
+/**
+ * Authentication status
+ */
+enum bfa_auth_status {
+	BFA_AUTH_STATUS_NONE = 0,	/*  no authentication */
+	BFA_AUTH_UNINIT = 1,	/*  state - uninit */
+	BFA_AUTH_NEG_SEND = 2,	/*  state - negotiate send */
+	BFA_AUTH_CHAL_WAIT = 3,	/*  state - challenge wait */
+	BFA_AUTH_NEG_RETRY = 4,	/*  state - negotiate retry */
+	BFA_AUTH_REPLY_SEND = 5,	/*  state - reply send */
+	BFA_AUTH_STATUS_WAIT = 6,	/*  state - status wait */
+	BFA_AUTH_SUCCESS = 7,	/*  state - success */
+	BFA_AUTH_FAILED = 8,	/*  state - failed */
+	BFA_AUTH_STATUS_UNKNOWN = 9,	/*  authentication status unknown */
+};
+
+struct auth_proto_stats_s {
+	u32 auth_rjts;
+	u32 auth_negs;
+	u32 auth_dones;
+
+	u32 dhchap_challenges;
+	u32 dhchap_replies;
+	u32 dhchap_successes;
+};
+
+/**
+ * Authentication related statistics
+ */
+struct bfa_auth_stats_s {
+	u32 auth_failures;	/*  authentication failures */
+	u32 auth_successes;	/*  authentication successes */
+	struct auth_proto_stats_s auth_rx_stats;	/*  Rx protocol stats */
+	struct auth_proto_stats_s auth_tx_stats;	/*  Tx protocol stats */
+};
+
+/**
+ * Authentication hash function algorithms
+ */
+enum bfa_auth_algo {
+	BFA_AUTH_ALGO_MD5 = 1,	/*  Message-Digest algorithm 5 */
+	BFA_AUTH_ALGO_SHA1 = 2,	/*  Secure Hash Algorithm 1 */
+	BFA_AUTH_ALGO_MS = 3,	/*  MD5, then SHA-1 */
+	BFA_AUTH_ALGO_SM = 4,	/*  SHA-1, then MD5 */
+};
+
+/**
+ * DH Groups
+ *
+ * Current value could be combination of one or more of the following values
+ */
+enum bfa_auth_group {
+	BFA_AUTH_GROUP_DHNULL = 0,	/*  DH NULL (value == 0) */
+	BFA_AUTH_GROUP_DH768 = 1,	/*  DH group 768 (value == 1) */
+	BFA_AUTH_GROUP_DH1024 = 2,	/*  DH group 1024 (value == 2) */
+	BFA_AUTH_GROUP_DH1280 = 4,	/*  DH group 1280 (value == 3) */
+	BFA_AUTH_GROUP_DH1536 = 8,	/*  DH group 1536 (value == 4) */
+
+	BFA_AUTH_GROUP_ALL = 256	/*  Use default DH group order
+					 *    0, 1, 2, 3, 4 */
+};
+
+/**
+ * Authentication secret sources
+ */
+enum bfa_auth_secretsource {
+	BFA_AUTH_SECSRC_LOCAL = 1,	/*  locally configured */
+	BFA_AUTH_SECSRC_RADIUS = 2,	/*  use radius server */
+	BFA_AUTH_SECSRC_TACACS = 3,	/*  TACACS server */
+};
+
+/**
+ * Authentication attributes
+ */
+struct bfa_auth_attr_s {
+	enum bfa_auth_status status;
+	enum bfa_auth_algo algo;
+	enum bfa_auth_group dh_grp;
+	u16 rjt_code;
+	u16 rjt_code_exp;
+	u8 secret_set;
+	u8 resv[7];
+};
+
+#endif /* __BFA_DEFS_AUTH_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_boot.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_boot.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_boot.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_boot.h	2009-08-28 21:09:26.862677000 -0700
@@ -0,0 +1,78 @@
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
+#ifndef __BFA_DEFS_BOOT_H__
+#define __BFA_DEFS_BOOT_H__
+
+#include <protocol/types.h>
+#include <defs/bfa_defs_types.h>
+#include <defs/bfa_defs_pport.h>
+
+enum {
+	BFA_BOOT_BOOTLUN_MAX = 4,	/*  maximum boot lun per IOC */
+};
+
+#define BOOT_CFG_REV1	1
+
+/**
+ *      Boot options setting. Boot options setting determines from where
+ *      to get the boot lun information
+ */
+enum bfa_boot_bootopt {
+	BFA_BOOT_AUTO_DISCOVER = 0,	/*  Boot from blun provided by fabric */
+	BFA_BOOT_STORED_BLUN = 1,	/*  Boot from bluns stored in flash   */
+	BFA_BOOT_FIRST_LUN = 2,	/*  Boot from first discovered blun   */
+};
+
+/**
+ * Boot lun information.
+ */
+struct bfa_boot_bootlun_s {
+	wwn_t pwwn;		/*  port wwn of target */
+	lun_t lun;		/*  64-bit lun */
+};
+
+/**
+ * BOOT boot configuraton
+ */
+struct bfa_boot_cfg_s {
+	u8 version;
+	u8 rsvd1;
+	u16 chksum;
+
+	u8 enable;		/*  enable/disable SAN boot */
+	u8 speed;		/*  boot speed settings */
+	u8 topology;		/*  boot topology setting */
+	u8 bootopt;		/*  bfa_boot_bootopt_t */
+
+	u32 nbluns;		/*  number of boot luns */
+
+	u32 rsvd2;
+
+	struct bfa_boot_bootlun_s blun[BFA_BOOT_BOOTLUN_MAX];
+	struct bfa_boot_bootlun_s blun_disc[BFA_BOOT_BOOTLUN_MAX];
+};
+
+
+#endif /* __BFA_DEFS_BOOT_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_cee.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_cee.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_cee.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_cee.h	2009-08-28 21:09:27.044609000 -0700
@@ -0,0 +1,164 @@
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
+#include <defs/bfa_defs_pport.h>
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
+	u16 time_to_interval;
+	u16 enabled_system_cap;
+};
+
+enum bfa_cee_dcbx_version_e {
+	DCBX_PROTOCOL_PRECEE = 1,
+	DCBX_PROTOCOL_CEE = 2,
+};
+
+enum bfa_cee_lls_e {
+	CEE_LLS_DOWN_NO_TLV = 0,	/* LLS is down because the TLV not sent by
+					 * the peer */
+	CEE_LLS_DOWN = 1,	/* LLS is down as advertised by the peer */
+	CEE_LLS_UP = 2,
+};
+
+/* CEE/DCBX parameters */
+struct bfa_cee_dcbx_cfg_s {
+	u8 pgid[8];
+	u8 pg_percentage[8];
+	u8 pfc_enabled;		/* bitmap of priorties with PFC enabled */
+	u8 fcoe_user_priority;	/* bitmap of priorities used for FcoE
+				 * traffic */
+	u8 dcbx_version;	/* operating version:CEE or preCEE */
+	u8 lls_fcoe;		/* FCoE Logical Link Status */
+	u8 lls_lan;		/* LAN Logical Link Status */
+	u8 rsvd[3];
+};
+
+/* CEE status */
+/* Making this to tri-state for the benefit of port list command */
+enum bfa_cee_status_e {
+	CEE_PHY_DOWN = 0,
+	CEE_PHY_UP = 1,
+	CEE_UP = 2,
+};
+
+/* CEE Query */
+struct bfa_cee_attr_s {
+	u8 cee_status;
+	u8 error_reason;
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
+	struct bfa_cee_cfg_stats_s cfg_stats;
+};
+
+#pragma pack()
+
+
+#endif /* __BFA_DEFS_CEE_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_ethport.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_ethport.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_ethport.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_ethport.h	2009-08-28 21:09:26.935610000 -0700
@@ -0,0 +1,105 @@
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
+#ifndef __BFA_DEFS_ETHPORT_H__
+#define __BFA_DEFS_ETHPORT_H__
+
+#include <defs/bfa_defs_status.h>
+#include <protocol/types.h>
+#include <cna/pstats/phyport_defs.h>
+#include <cna/pstats/ethport_defs.h>
+
+struct bna_tx_info_s {
+	u32 miniport_state;
+	u32 adapter_state;
+	u64 tx_count;
+	u64 tx_wi;
+	u64 tx_sg;
+	u64 tx_tcp_chksum;
+	u64 tx_udp_chksum;
+	u64 tx_ip_chksum;
+	u64 tx_lsov1;
+	u64 tx_lsov2;
+	u64 tx_max_sg_len;
+};
+
+struct bna_rx_queue_info_s {
+	u16 q_id;
+	u16 buf_size;
+	u16 buf_count;
+	u16 rsvd;
+	u64 rx_count;
+	u64 rx_dropped;
+	u64 rx_unsupported;
+	u64 rx_internal_err;
+	u64 rss_count;
+	u64 vlan_count;
+	u64 rx_tcp_chksum;
+	u64 rx_udp_chksum;
+	u64 rx_ip_chksum;
+	u64 rx_hds;
+};
+
+struct bna_rx_q_set_s {
+	u16 q_set_type;
+	u32 miniport_state;
+	u32 adapter_state;
+	struct bna_rx_queue_info_s rx_queue[2];
+};
+
+struct bna_port_stats_s {
+	struct bna_tx_info_s tx_stats;
+	u16 qset_count;
+	struct bna_rx_q_set_s rx_qset[8];
+};
+
+struct bfa_ethport_stats_s {
+	struct bna_stats_txf txf_stats[1];
+	struct bna_stats_rxf rxf_stats[1];
+	struct bnad_drv_stats drv_stats;
+};
+
+/**
+ * Ethernet port events
+ * Arguments below are in BFAL context from Mgmt
+ * BFA_PORT_AEN_ETH_LINKUP:    [in]: mac [out]: mac
+ * BFA_PORT_AEN_ETH_LINKDOWN:  [in]: mac [out]: mac
+ * BFA_PORT_AEN_ETH_ENABLE:  [in]: mac [out]: mac
+ * BFA_PORT_AEN_ETH_DISABLE:  [in]: mac [out]: mac
+ *
+ */
+enum bfa_ethport_aen_event {
+	BFA_ETHPORT_AEN_LINKUP = 1,	/*  Base Port Ethernet link up event */
+	BFA_ETHPORT_AEN_LINKDOWN = 2,	/*  Base Port Ethernet link down event */
+	BFA_ETHPORT_AEN_ENABLE = 3,	/*  Base Port Ethernet link enable event */
+	BFA_ETHPORT_AEN_DISABLE = 4,	/*  Base Port Ethernet link disable
+					 * event */
+};
+
+struct bfa_ethport_aen_data_s {
+	mac_t mac;		/*  MAC address of the physical port */
+};
+
+
+#endif /* __BFA_DEFS_ETHPORT_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_fcpim.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_fcpim.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_fcpim.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_fcpim.h	2009-08-28 21:09:27.060607000 -0700
@@ -0,0 +1,52 @@
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
+#ifndef __BFA_DEFS_FCPIM_H__
+#define __BFA_DEFS_FCPIM_H__
+
+struct bfa_fcpim_stats_s {
+	u32 total_ios;		/*  Total IO count */
+	u32 qresumes;		/*  IO waiting for CQ space */
+	u32 no_iotags;		/*  NO IO contexts */
+	u32 io_aborts;		/*  IO abort requests */
+	u32 no_tskims;		/*  NO task management contexts */
+	u32 iocomp_ok;		/*  IO completions with OK status */
+	u32 iocomp_underrun;	/*  IO underrun (good) */
+	u32 iocomp_overrun;	/*  IO overrun (good) */
+	u32 iocomp_aborted;	/*  Aborted IO requests */
+	u32 iocomp_timedout;	/*  IO timeouts */
+	u32 iocom_nexus_abort;	/*  IO selection timeouts */
+	u32 iocom_proto_err;	/*  IO protocol errors */
+	u32 iocom_dif_err;	/*  IO SBC-3 protection errors */
+	u32 iocom_tm_abort;	/*  IO aborted by TM requests */
+	u32 iocom_sqer_needed;	/*  IO retry for SQ error
+				 *recovery */
+	u32 iocom_res_free;	/*  Delayed freeing of IO resources */
+	u32 iocomp_scsierr;	/*  IO with non-good SCSI status */
+	u32 iocom_hostabrts;	/*  Host IO abort requests */
+	u32 iocom_utags;	/*  IO comp with unknown tags */
+	u32 io_cleanups;	/*  IO implicitly aborted */
+	u32 io_tmaborts;	/*  IO aborted due to TM commands */
+	u32 rsvd;
+};
+#endif /*__BFA_DEFS_FCPIM_H__*/
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_iocfc.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_iocfc.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_iocfc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_iocfc.h	2009-08-28 21:09:27.090633000 -0700
@@ -0,0 +1,317 @@
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
+#ifndef __BFA_DEFS_IOCFC_H__
+#define __BFA_DEFS_IOCFC_H__
+
+#include <protocol/types.h>
+#include <defs/bfa_defs_types.h>
+#include <defs/bfa_defs_version.h>
+#include <defs/bfa_defs_adapter.h>
+#include <defs/bfa_defs_pm.h>
+
+#define BFA_IOCFC_INTR_DELAY	1125
+#define BFA_IOCFC_INTR_LATENCY	225
+
+/**
+ * Interrupt coalescing configuration.
+ */
+struct bfa_iocfc_intr_attr_s {
+	bfa_boolean_t coalesce;	/*  enable/disable coalescing */
+	u16 latency;		/*  latency in microseconds   */
+	u16 delay;		/*  delay in microseconds     */
+};
+
+/**
+ * IOC firmware configuraton
+ */
+struct bfa_iocfc_fwcfg_s {
+	u16 num_fabrics;	/*  number of fabrics           */
+	u16 num_lports;		/*  number of local lports      */
+	u16 num_rports;		/*  number of remote ports      */
+	u16 num_ioim_reqs;	/*  number of IO reqs           */
+	u16 num_tskim_reqs;	/*  task management requests    */
+	u16 num_iotm_reqs;	/*  number of TM IO reqs        */
+	u16 num_tsktm_reqs;	/*  TM task management requests */
+	u16 num_fcxp_reqs;	/*  unassisted FC exchanges     */
+	u16 num_uf_bufs;	/*  unsolicited recv buffers    */
+	u8 num_cqs;
+	u8 rsvd;
+};
+
+struct bfa_iocfc_drvcfg_s {
+	u16 num_reqq_elems;	/*  number of req queue elements */
+	u16 num_rspq_elems;	/*  number of rsp queue elements */
+	u16 num_sgpgs;		/*  number of total SG pages      */
+	u16 num_sboot_tgts;	/*  number of SAN boot targets    */
+	u16 num_sboot_luns;	/*  number of SAN boot luns       */
+	u16 ioc_recover;	/*  IOC recovery mode             */
+	u16 min_cfg;		/*  minimum configuration         */
+	u16 path_tov;		/*  device path timeout   */
+	bfa_boolean_t delay_comp;	/*  delay completion of
+					   failed inflight IOs */
+	u32 rsvd;
+};
+/**
+ * IOC configuration
+ */
+struct bfa_iocfc_cfg_s {
+	struct bfa_iocfc_fwcfg_s fwcfg;	/*  firmware side config */
+	struct bfa_iocfc_drvcfg_s drvcfg;	/*  driver side config    */
+};
+
+/**
+ * IOC firmware IO stats
+ */
+struct bfa_fw_io_stats_s {
+	u32 host_abort;		/*  IO aborted by host driver */
+	u32 host_cleanup;	/*  IO clean up by host driver */
+
+	u32 fw_io_timeout;	/*  IOs timedout */
+	u32 fw_frm_parse;	/*  frame parsed by f/w */
+	u32 fw_frm_data;	/*  fcp_data frame parsed by f/w */
+	u32 fw_frm_rsp;		/*  fcp_rsp frame parsed by f/w */
+	u32 fw_frm_xfer_rdy;	/*  xfer_rdy frame parsed by f/w */
+	u32 fw_frm_bls_acc;	/*  BLS ACC  frame parsed by f/w */
+	u32 fw_frm_tgt_abort;	/*  target ABTS parsed by f/w */
+	u32 fw_frm_unknown;	/*  unknown parsed by f/w */
+	u32 fw_data_dma;	/*  f/w DMA'ed the data frame */
+	u32 fw_frm_drop;	/*  f/w drop the frame */
+
+	u32 rec_timeout;	/*  FW rec timed out */
+	u32 error_rec;		/*  FW sending rec on
+				 * an error condition*/
+	u32 wait_for_si;	/*  FW wait for SI */
+	u32 rec_rsp_inval;	/*  REC rsp invalid */
+	u32 seqr_io_abort;	/*  target does not know cmd so abort */
+	u32 seqr_io_retry;	/*  SEQR failed so retry IO */
+
+	u32 itn_cisc_upd_rsp;	/*  ITN cisc updated on fcp_rsp */
+	u32 itn_cisc_upd_data;	/*  ITN cisc updated on fcp_data */
+	u32 itn_cisc_upd_xfer_rdy;	/*  ITN cisc updated on fcp_data */
+
+	u32 fcp_data_lost;	/*  fcp data lost */
+
+	u32 ro_set_in_xfer_rdy;	/*  Target set RO in Xfer_rdy frame */
+	u32 xfer_rdy_ooo_err;	/*  Out of order Xfer_rdy received */
+	u32 xfer_rdy_unknown_err;	/*  unknown error in xfer_rdy frame */
+
+	u32 io_abort_timeout;	/*  ABTS timedout  */
+	u32 sler_initiated;	/*  SLER initiated */
+
+	u32 unexp_fcp_rsp;	/*  fcp response in wrong state */
+
+	u32 fcp_rsp_under_run;	/*  fcp rsp IO underrun */
+	u32 fcp_rsp_under_run_wr;	/*  fcp rsp IO underrun for write */
+	u32 fcp_rsp_under_run_err;	/*  fcp rsp IO underrun error */
+	u32 fcp_rsp_resid_inval;	/*  invalid residue */
+	u32 fcp_rsp_over_run;	/*  fcp rsp IO overrun */
+	u32 fcp_rsp_over_run_err;	/*  fcp rsp IO overrun error */
+	u32 fcp_rsp_proto_err;	/*  protocol error in fcp rsp */
+	u32 fcp_rsp_sense_err;	/*  error in sense info in fcp rsp */
+	u32 fcp_conf_req;	/*  FCP conf requested */
+
+	u32 tgt_aborted_io;	/*  target initiated abort */
+
+	u32 ioh_edtov_timeout_event;	/*  IOH edtov timer popped */
+	u32 ioh_fcp_rsp_excp_event;	/*  IOH FCP_RSP exception */
+	u32 ioh_fcp_conf_event;	/*  IOH FCP_CONF */
+	u32 ioh_mult_frm_rsp_event;	/*  IOH multi_frame FCP_RSP */
+	u32 ioh_hit_class2_event;	/*  IOH hit class2 */
+	u32 ioh_miss_other_event;	/*  IOH miss other */
+	u32 ioh_seq_cnt_err_event;	/*  IOH seq cnt error */
+	u32 ioh_len_err_event;	/*  IOH len error - fcp_dl !=
+				 * bytes xfered */
+	u32 ioh_seq_len_err_event;	/*  IOH seq len error */
+	u32 ioh_data_oor_event;	/*  Data out of range */
+	u32 ioh_ro_ooo_event;	/*  Relative offset out of range */
+	u32 ioh_cpu_owned_event;	/*  IOH hit -iost owned by f/w */
+	u32 ioh_unexp_frame_event;	/*  unexpected frame recieved
+					 *   count */
+	u32 ioh_err_int;	/*  IOH error int during data-phase
+				 *   for scsi write
+				 */
+};
+
+/**
+ * IOC port firmware stats
+ */
+
+struct bfa_fw_port_fpg_stats_s {
+	u32 intr_evt;
+	u32 intr;
+	u32 intr_excess;
+	u32 intr_cause0;
+	u32 intr_other;
+	u32 intr_other_ign;
+	u32 sig_lost;
+	u32 sig_regained;
+	u32 sync_lost;
+	u32 sync_to;
+	u32 sync_regained;
+	u32 div2_overflow;
+	u32 div2_underflow;
+	u32 efifo_overflow;
+	u32 efifo_underflow;
+	u32 idle_rx;
+	u32 lrr_rx;
+	u32 lr_rx;
+	u32 ols_rx;
+	u32 nos_rx;
+	u32 lip_rx;
+	u32 arbf0_rx;
+	u32 mrk_rx;
+	u32 const_mrk_rx;
+	u32 prim_unknown;
+	u32 rsvd;
+};
+
+
+struct bfa_fw_port_lksm_stats_s {
+	u32 hwsm_success;	/*  hwsm state machine success          */
+	u32 hwsm_fails;		/*  hwsm fails                          */
+	u32 hwsm_wdtov;		/*  hwsm timed out                      */
+	u32 swsm_success;	/*  swsm success                        */
+	u32 swsm_fails;		/*  swsm fails                          */
+	u32 swsm_wdtov;		/*  swsm timed out                      */
+	u32 busybufs;		/*  link init failed due to busybuf     */
+	u32 buf_waits;		/*  bufwait state entries               */
+	u32 link_fails;		/*  link failures                       */
+	u32 psp_errors;		/*  primitive sequence protocol errors  */
+	u32 lr_unexp;		/*  No. of times LR rx-ed unexpectedly  */
+	u32 lrr_unexp;		/*  No. of times LRR rx-ed unexpectedly */
+	u32 lr_tx;		/*  No. of times LR tx started          */
+	u32 lrr_tx;		/*  No. of times LRR tx started         */
+	u32 ols_tx;		/*  No. of times OLS tx started         */
+	u32 nos_tx;		/*  No. of times NOS tx started         */
+};
+
+
+struct bfa_fw_port_snsm_stats_s {
+	u32 hwsm_success;	/*  Successful hwsm terminations        */
+	u32 hwsm_fails;		/*  hwsm fail count                     */
+	u32 hwsm_wdtov;		/*  hwsm timed out                      */
+	u32 swsm_success;	/*  swsm success                        */
+	u32 swsm_wdtov;		/*  swsm timed out                      */
+	u32 error_resets;	/*  error resets initiated by upsm      */
+	u32 sync_lost;		/*  Sync loss count                     */
+	u32 sig_lost;		/*  Signal loss count                   */
+};
+
+
+struct bfa_fw_port_physm_stats_s {
+	u32 module_inserts;	/*  Module insert count                 */
+	u32 module_xtracts;	/*  Module extracts count               */
+	u32 module_invalids;	/*  Invalid module inserted count       */
+	u32 module_read_ign;	/*  Module validation status ignored    */
+	u32 laser_faults;	/*  Laser fault count                   */
+	u32 rsvd;
+};
+
+
+struct bfa_fw_fip_stats_s {
+	u32 disc_req;		/*  Discovery solicit requests          */
+	u32 disc_rsp;		/*  Discovery solicit response          */
+	u32 disc_err;		/*  Discovery advt. parse errors        */
+	u32 disc_unsol;		/*  Discovery unsolicited               */
+	u32 disc_timeouts;	/*  Discovery timeouts                  */
+	u32 linksvc_unsupp;	/*  Unsupported link service req        */
+	u32 linksvc_err;	/*  Parse error in link service req     */
+	u32 logo_req;		/*  Number of FIP logos received        */
+	u32 clrvlink_req;	/*  Clear virtual link req              */
+	u32 op_unsupp;		/*  Unsupported FIP operation           */
+	u32 untagged;		/*  Untagged frames (ignored)           */
+	u32 rsvd;
+};
+
+
+struct bfa_fw_lps_stats_s {
+	u32 mac_invalids;	/*  Invalid mac assigned                */
+	u32 rsvd;
+};
+
+
+struct bfa_fw_fcoe_stats_s {
+	u32 cee_linkups;	/*  CEE link up count                   */
+	u32 cee_linkdns;	/*  CEE link down count                 */
+	u32 fip_linkups;	/*  FIP link up count                   */
+	u32 fip_linkdns;	/*  FIP link up count                   */
+	u32 fip_fails;		/*  FIP fail count                      */
+	u32 mac_invalids;	/*  Invalid mac assigned                */
+};
+
+/**
+ * IOC firmware FCoE port stats
+ */
+struct bfa_fw_fcoe_port_stats_s {
+	struct bfa_fw_fcoe_stats_s fcoe_stats;
+	struct bfa_fw_fip_stats_s fip_stats;
+};
+
+/**
+ * IOC firmware FC port stats
+ */
+struct bfa_fw_fc_port_stats_s {
+	struct bfa_fw_port_fpg_stats_s fpg_stats;
+	struct bfa_fw_port_physm_stats_s physm_stats;
+	struct bfa_fw_port_snsm_stats_s snsm_stats;
+	struct bfa_fw_port_lksm_stats_s lksm_stats;
+};
+
+/**
+ * IOC firmware FC port stats
+ */
+union bfa_fw_port_stats_s {
+	struct bfa_fw_fc_port_stats_s fc_stats;
+	struct bfa_fw_fcoe_port_stats_s fcoe_stats;
+};
+
+/**
+ * IOC firmware stats
+ */
+struct bfa_fw_stats_s {
+	struct bfa_fw_ioc_stats_s ioc_stats;
+	struct bfa_fw_io_stats_s io_stats;
+	union bfa_fw_port_stats_s port_stats;
+};
+
+/**
+ * IOC statistics
+ */
+struct bfa_iocfc_stats_s {
+	struct bfa_fw_stats_s fw_stats;	/*  firmware IOC stats      */
+};
+
+/**
+ * IOC attributes returned in queries
+ */
+struct bfa_iocfc_attr_s {
+	struct bfa_iocfc_cfg_s config;	/*  IOCFC config   */
+	struct bfa_iocfc_intr_attr_s intr_attr;	/*  interrupt attr */
+};
+
+#define BFA_IOCFC_PATHTOV_MAX	60
+#define BFA_IOCFC_QDEPTH_MAX	2000
+
+#endif /* __BFA_DEFS_IOC_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_ioc.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_ioc.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_ioc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_ioc.h	2009-08-28 21:09:27.105618000 -0700
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
+#include <defs/bfa_defs_pm.h>
+
+enum {
+	BFA_IOC_DRIVER_LEN = 16,
+	BFA_IOC_CHIP_REV_LEN = 8,
+};
+
+/**
+ * Driver and firmware versions.
+ */
+struct bfa_ioc_driver_attr_s {
+	char driver[BFA_IOC_DRIVER_LEN];	/*  driver name */
+	char driver_ver[BFA_VERSION_LEN];	/*  driver version */
+	char fw_ver[BFA_VERSION_LEN];	/*  firmware version */
+	char bios_ver[BFA_VERSION_LEN];	/*  bios version */
+	char efi_ver[BFA_VERSION_LEN];	/*  EFI version */
+	char ob_ver[BFA_VERSION_LEN];	/*  openboot version */
+};
+
+/**
+ * IOC PCI device attributes
+ */
+struct bfa_ioc_pci_attr_s {
+	u16 vendor_id;		/*  PCI vendor ID */
+	u16 device_id;		/*  PCI device ID */
+	u16 ssid;		/*  subsystem ID */
+	u16 ssvid;		/*  subsystem vendor ID */
+	u32 pcifn;		/*  PCI device function */
+	u32 rsvd;		/* padding */
+	u8 chip_rev[BFA_IOC_CHIP_REV_LEN];	/*  chip revision */
+};
+
+/**
+ * IOC states
+ */
+enum bfa_ioc_state {
+	BFA_IOC_RESET = 1,	/*  IOC is in reset state */
+	BFA_IOC_SEMWAIT = 2,	/*  Waiting for IOC hardware semaphore */
+	BFA_IOC_HWINIT = 3,	/*  IOC hardware is being initialized */
+	BFA_IOC_GETATTR = 4,	/*  IOC is being configured */
+	BFA_IOC_OPERATIONAL = 5,	/*  IOC is operational */
+	BFA_IOC_INITFAIL = 6,	/*  IOC hardware failure */
+	BFA_IOC_HBFAIL = 7,	/*  IOC heart-beat failure */
+	BFA_IOC_DISABLING = 8,	/*  IOC is being disabled */
+	BFA_IOC_DISABLED = 9,	/*  IOC is disabled */
+	BFA_IOC_FWMISMATCH = 10,	/*  IOC firmware different from drivers */
+};
+
+/**
+ * IOC firmware stats
+ */
+struct bfa_fw_ioc_stats_s {
+	u32 hb_count;
+	u32 cfg_reqs;
+	u32 enable_reqs;
+	u32 disable_reqs;
+	u32 stats_reqs;
+	u32 clrstats_reqs;
+	u32 unknown_reqs;
+	u32 ic_reqs;		/*  interrupt coalesce reqs */
+};
+
+/**
+ * IOC driver stats
+ */
+struct bfa_ioc_drv_stats_s {
+	u32 ioc_isrs;
+	u32 ioc_enables;
+	u32 ioc_disables;
+	u32 ioc_hbfails;
+	u32 ioc_boots;
+	u32 stats_tmos;
+	u32 hb_count;
+	u32 disable_reqs;
+	u32 enable_reqs;
+	u32 disable_replies;
+	u32 enable_replies;
+};
+
+/**
+ * IOC statistics
+ */
+struct bfa_ioc_stats_s {
+	struct bfa_ioc_drv_stats_s drv_stats;	/*  driver IOC stats */
+	struct bfa_fw_ioc_stats_s fw_stats;	/*  firmware IOC stats */
+};
+
+
+enum bfa_ioc_type_e {
+	BFA_IOC_TYPE_FC = 1,
+	BFA_IOC_TYPE_FCoE = 2,
+	BFA_IOC_TYPE_LL = 3,
+};
+
+/**
+ * IOC attributes returned in queries
+ */
+struct bfa_ioc_attr_s {
+	enum bfa_ioc_type_e ioc_type;
+	enum bfa_ioc_state state;	/*  IOC state      */
+	struct bfa_adapter_attr_s adapter_attr;	/*  HBA attributes */
+	struct bfa_ioc_driver_attr_s driver_attr;	/*  driver attr    */
+	struct bfa_ioc_pci_attr_s pci_attr;
+	u8 port_id;		/*  port number    */
+};
+
+/**
+ * BFA IOC level events
+ */
+enum bfa_ioc_aen_event {
+	BFA_IOC_AEN_HBGOOD = 1,	/*  Heart Beat restore event    */
+	BFA_IOC_AEN_HBFAIL = 2,	/*  Heart Beat failure event    */
+	BFA_IOC_AEN_ENABLE = 3,	/*  IOC enabled event           */
+	BFA_IOC_AEN_DISABLE = 4,	/*  IOC disabled event          */
+	BFA_IOC_AEN_FWMISMATCH = 5,	/*  IOC firmware mismatch       */
+};
+
+/**
+ * BFA IOC level event data, now just a place holder
+ */
+struct bfa_ioc_aen_data_s {
+	enum bfa_ioc_type_e ioc_type;
+	wwn_t pwwn;
+	mac_t mac;
+};
+
+#endif /* __BFA_DEFS_IOC_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_ipfc.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_ipfc.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_ipfc.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_ipfc.h	2009-08-28 21:09:27.310608000 -0700
@@ -0,0 +1,77 @@
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
+#ifndef __BFA_DEFS_IPFC_H__
+#define __BFA_DEFS_IPFC_H__
+
+#include <bfa_os_inc.h>
+#include <protocol/types.h>
+#include <defs/bfa_defs_types.h>
+
+/**
+ * FCS ip remote port states
+ */
+enum bfa_iprp_state {
+	BFA_IPRP_UNINIT = 0,	/*  PORT is not yet initialized */
+	BFA_IPRP_ONLINE = 1,	/*  process login is complete */
+	BFA_IPRP_OFFLINE = 2,	/*  iprp is offline */
+};
+
+/**
+ * FCS remote port statistics
+ */
+struct bfa_iprp_stats_s {
+	u32 offlines;
+	u32 onlines;
+	u32 rscns;
+	u32 plogis;
+	u32 logos;
+	u32 plogi_timeouts;
+	u32 plogi_rejects;
+};
+
+/**
+ * FCS iprp attribute returned in queries
+ */
+struct bfa_iprp_attr_s {
+	enum bfa_iprp_state state;
+};
+
+struct bfa_ipfc_stats_s {
+	u32 arp_sent;
+	u32 arp_recv;
+	u32 arp_reply_sent;
+	u32 arp_reply_recv;
+	u32 farp_sent;
+	u32 farp_recv;
+	u32 farp_reply_sent;
+	u32 farp_reply_recv;
+	u32 farp_reject_sent;
+	u32 farp_reject_recv;
+};
+
+struct bfa_ipfc_attr_s {
+	bfa_boolean_t enabled;
+};
+
+#endif /* __BFA_DEFS_IPFC_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_itnim.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_itnim.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_itnim.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_itnim.h	2009-08-28 21:09:27.030607000 -0700
@@ -0,0 +1,133 @@
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
+#ifndef __BFA_DEFS_ITNIM_H__
+#define __BFA_DEFS_ITNIM_H__
+
+#include <bfa_os_inc.h>
+#include <protocol/types.h>
+
+/**
+ * FCS itnim states
+ */
+enum bfa_itnim_state {
+	BFA_ITNIM_OFFLINE = 0,	/*  offline */
+	BFA_ITNIM_PRLI_SEND = 1,	/*  prli send */
+	BFA_ITNIM_PRLI_SENT = 2,	/*  prli sent */
+	BFA_ITNIM_PRLI_RETRY = 3,	/*  prli retry */
+	BFA_ITNIM_HCB_ONLINE = 4,	/*  online callback */
+	BFA_ITNIM_ONLINE = 5,	/*  online */
+	BFA_ITNIM_HCB_OFFLINE = 6,	/*  offline callback */
+	BFA_ITNIM_INITIATIOR = 7,	/*  initiator */
+};
+
+struct bfa_itnim_hal_stats_s {
+	u32 onlines;		/*  ITN nexus onlines (PRLI done) */
+	u32 offlines;		/*  ITN Nexus offlines  */
+	u32 creates;		/*  ITN create requests         */
+	u32 deletes;		/*  ITN delete requests         */
+	u32 create_comps;	/*  ITN create completions      */
+	u32 delete_comps;	/*  ITN delete completions      */
+	u32 sler_events;	/*  SLER (sequence level error
+				 * recovery) events */
+	u32 ioc_disabled;	/*  Num IOC disables            */
+	u32 cleanup_comps;	/*  ITN cleanup completions */
+	u32 tm_cmnds;		/*  task management(TM) cmnds sent */
+	u32 tm_fw_rsps;		/*  TM cmds firmware responses */
+	u32 tm_success;		/*  TM successes */
+	u32 tm_failures;	/*  TM failures */
+	u32 tm_io_comps;	/*  TM IO completions */
+	u32 tm_qresumes;	/*  TM queue resumes (after waiting
+				 * for resources)
+				 */
+	u32 tm_iocdowns;	/*  TM cmnds affected by IOC down */
+	u32 tm_cleanups;	/*  TM cleanups */
+	u32 tm_cleanup_comps;
+	/*  TM cleanup completions */
+	u32 ios;		/*  IO requests */
+	u32 io_comps;		/*  IO completions */
+	u64 input_reqs;		/*  INPUT requests */
+	u64 output_reqs;	/*  OUTPUT requests */
+};
+
+/**
+ * FCS remote port statistics
+ */
+struct bfa_itnim_stats_s {
+	u32 onlines;		/*  num rport online */
+	u32 offlines;		/*  num rport offline */
+	u32 prli_sent;		/*  num prli sent out */
+	u32 fcxp_alloc_wait;	/*  num fcxp alloc waits */
+	u32 prli_rsp_err;	/*  num prli rsp errors */
+	u32 prli_rsp_acc;	/*  num prli rsp accepts */
+	u32 initiator;		/*  rport is an initiator */
+	u32 prli_rsp_parse_err;	/*  prli rsp parsing errors */
+	u32 prli_rsp_rjt;	/*  num prli rsp rejects */
+	u32 timeout;		/*  num timeouts detected */
+	u32 sler;		/*  num sler notification from BFA */
+	u32 rsvd;
+	struct bfa_itnim_hal_stats_s hal_stats;
+};
+
+/**
+ * FCS itnim attributes returned in queries
+ */
+struct bfa_itnim_attr_s {
+	enum bfa_itnim_state state;	/*  FCS itnim state        */
+	u8 retry;		/*  data retransmision support */
+	u8 task_retry_id;	/*  task retry ident support   */
+	u8 rec_support;		/*  REC supported              */
+	u8 conf_comp;		/*  confirmed completion supp  */
+};
+
+/**
+ * BFA ITNIM events.
+ * Arguments below are in BFAL context from Mgmt
+ * BFA_ITNIM_AEN_NEW:       [in]: None  [out]: vf_id, lpwwn
+ * BFA_ITNIM_AEN_DELETE:    [in]: vf_id, lpwwn, rpwwn (0 = all fcp4 targets),
+ *				  [out]: vf_id, ppwwn, lpwwn, rpwwn
+ * BFA_ITNIM_AEN_ONLINE:    [in]: vf_id, lpwwn, rpwwn (0 = all fcp4 targets),
+ *				  [out]: vf_id, ppwwn, lpwwn, rpwwn
+ * BFA_ITNIM_AEN_OFFLINE:   [in]: vf_id, lpwwn, rpwwn (0 = all fcp4 targets),
+ *				  [out]: vf_id, ppwwn, lpwwn, rpwwn
+ * BFA_ITNIM_AEN_DISCONNECT:[in]: vf_id, lpwwn, rpwwn (0 = all fcp4 targets),
+ *				  [out]: vf_id, ppwwn, lpwwn, rpwwn
+ */
+enum bfa_itnim_aen_event {
+	BFA_ITNIM_AEN_ONLINE = 1,	/*  Target online */
+	BFA_ITNIM_AEN_OFFLINE = 2,	/*  Target offline */
+	BFA_ITNIM_AEN_DISCONNECT = 3,	/*  Target disconnected */
+};
+
+/**
+ * BFA ITNIM event data structure.
+ */
+struct bfa_itnim_aen_data_s {
+	u16 vf_id;		/*  vf_id of the IT nexus */
+	u16 rsvd[3];
+	wwn_t ppwwn;		/*  WWN of its physical port */
+	wwn_t lpwwn;		/*  WWN of logical port */
+	wwn_t rpwwn;		/*  WWN of remote(target) port */
+};
+
+#endif /* __BFA_DEFS_ITNIM_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_led.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_led.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_led.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_led.h	2009-08-28 21:09:27.178608000 -0700
@@ -0,0 +1,42 @@
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
+#ifndef __BFA_DEFS_LED_H__
+#define __BFA_DEFS_LED_H__
+
+#define	BFA_LED_MAX_NUM		3
+
+enum bfa_led_op {
+	BFA_LED_OFF = 0,
+	BFA_LED_ON = 1,
+	BFA_LED_FLICK = 2,
+	BFA_LED_BLINK = 3,
+};
+
+enum bfa_led_color {
+	BFA_LED_GREEN = 0,
+	BFA_LED_AMBER = 1,
+};
+
+#endif /* __BFA_DEFS_LED_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_lport.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_lport.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_lport.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_lport.h	2009-08-28 21:09:26.977608000 -0700
@@ -0,0 +1,75 @@
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
+#ifndef __BFA_DEFS_LPORT_H__
+#define __BFA_DEFS_LPORT_H__
+
+#include <defs/bfa_defs_types.h>
+#include <defs/bfa_defs_port.h>
+
+/**
+ * BFA AEN logical port events.
+ * Arguments below are in BFAL context from Mgmt
+ * BFA_LPORT_AEN_NEW:       [in]: None         [out]: vf_id, ppwwn, lpwwn, roles
+ * BFA_LPORT_AEN_DELETE:    [in]: lpwwn        [out]: vf_id, ppwwn. lpwwn, roles
+ * BFA_LPORT_AEN_ONLINE:    [in]: lpwwn        [out]: vf_id, ppwwn. lpwwn, roles
+ * BFA_LPORT_AEN_OFFLINE:   [in]: lpwwn        [out]: vf_id, ppwwn. lpwwn, roles
+ * BFA_LPORT_AEN_DISCONNECT:[in]: lpwwn        [out]: vf_id, ppwwn. lpwwn, roles
+ * BFA_LPORT_AEN_NEW_PROP:  [in]: None         [out]: vf_id, ppwwn. lpwwn, roles
+ * BFA_LPORT_AEN_DELETE_PROP:     [in]: lpwwn  [out]: vf_id, ppwwn. lpwwn, roles
+ * BFA_LPORT_AEN_NEW_STANDARD:    [in]: None   [out]: vf_id, ppwwn. lpwwn, roles
+ * BFA_LPORT_AEN_DELETE_STANDARD: [in]: lpwwn  [out]: vf_id, ppwwn. lpwwn, roles
+ * BFA_LPORT_AEN_NPIV_DUP_WWN:    [in]: lpwwn  [out]: vf_id, ppwwn. lpwwn, roles
+ * BFA_LPORT_AEN_NPIV_FABRIC_MAX: [in]: lpwwn  [out]: vf_id, ppwwn. lpwwn, roles
+ * BFA_LPORT_AEN_NPIV_UNKNOWN:    [in]: lpwwn  [out]: vf_id, ppwwn. lpwwn, roles
+ */
+enum bfa_lport_aen_event {
+	BFA_LPORT_AEN_NEW = 1,	/*  LPort created event */
+	BFA_LPORT_AEN_DELETE = 2,	/*  LPort deleted event */
+	BFA_LPORT_AEN_ONLINE = 3,	/*  LPort online event */
+	BFA_LPORT_AEN_OFFLINE = 4,	/*  LPort offline event */
+	BFA_LPORT_AEN_DISCONNECT = 5,	/*  LPort disconnect event */
+	BFA_LPORT_AEN_NEW_PROP = 6,	/*  VPort created event */
+	BFA_LPORT_AEN_DELETE_PROP = 7,	/*  VPort deleted event */
+	BFA_LPORT_AEN_NEW_STANDARD = 8,	/*  VPort created event */
+	BFA_LPORT_AEN_DELETE_STANDARD = 9,	/*  VPort deleted event */
+	BFA_LPORT_AEN_NPIV_DUP_WWN = 10,	/*  VPort configured with
+						 *   duplicate WWN event
+						 */
+	BFA_LPORT_AEN_NPIV_FABRIC_MAX = 11,	/*  Max NPIV in fabric/fport */
+	BFA_LPORT_AEN_NPIV_UNKNOWN = 12,	/*  Unknown NPIV Error code event */
+};
+
+/**
+ * BFA AEN event data structure
+ */
+struct bfa_lport_aen_data_s {
+	u16 vf_id;		/*  vf_id of this logical port */
+	u16 rsvd;
+	enum bfa_port_role roles;	/*  Logical port mode,IM/TM/IP etc */
+	wwn_t ppwwn;		/*  WWN of its physical port */
+	wwn_t lpwwn;		/*  WWN of this logical port */
+};
+
+#endif /* __BFA_DEFS_LPORT_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_mfg.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_mfg.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_mfg.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_mfg.h	2009-08-28 21:09:27.120607000 -0700
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
+	u8 version;		/*  vpd data version */
+	u8 vpd_sig[3];		/*  characters 'V', 'P', 'D' */
+	u8 chksum;		/*  u8 checksum */
+	u8 vendor;		/*  vendor */
+	u8 len;			/*  vpd data length excluding header */
+	u8 rsv;
+	u8 data[BFA_MFG_VPD_LEN];	/*  vpd data */
+};
+
+#pragma pack(1)
+
+#endif /* __BFA_DEFS_MFG_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_pci.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_pci.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_pci.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_pci.h	2009-08-28 21:09:27.193613000 -0700
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
+	BFA_PCI_VENDOR_ID_BROCADE = 0x1657,
+	BFA_PCI_DEVICE_ID_FC_8G2P = 0x13,
+	BFA_PCI_DEVICE_ID_FC_8G1P = 0x17,
+	BFA_PCI_DEVICE_ID_CT = 0x14,
+};
+
+/**
+ * PCI sub-system device and vendor ID information
+ */
+enum {
+	BFA_PCI_FCOE_SSDEVICE_ID = 0x14,
+};
+
+#define BFA_PCI_ACCESS_RANGES 1	/* Maximum number of device address ranges
+				 * mapped through different BAR(s). */
+
+#endif /* __BFA_DEFS_PCI_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_pm.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_pm.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_pm.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_pm.h	2009-08-28 21:09:26.905611000 -0700
@@ -0,0 +1,40 @@
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
+#ifndef __BFA_DEFS_PM_H__
+#define __BFA_DEFS_PM_H__
+
+#include <bfa_os_inc.h>
+
+/**
+ * BFA power management device states
+ */
+enum bfa_pm_ds {
+	BFA_PM_DS_D0 = 0,	/*  full power mode */
+	BFA_PM_DS_D1 = 1,	/*  power save state 1 */
+	BFA_PM_DS_D2 = 2,	/*  power save state 2 */
+	BFA_PM_DS_D3 = 3,	/*  power off state */
+};
+
+#endif /* __BFA_DEFS_PM_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_pom.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_pom.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_pom.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_pom.h	2009-08-28 21:09:26.962608000 -0700
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
+#ifndef __BFA_DEFS_POM_H__
+#define __BFA_DEFS_POM_H__
+
+#include <bfa_os_inc.h>
+#include <defs/bfa_defs_types.h>
+
+/**
+ * POM health status levels for each attributes.
+ */
+enum bfa_pom_entry_health {
+	BFA_POM_HEALTH_NOINFO = 1,	/*  no information */
+	BFA_POM_HEALTH_NORMAL = 2,	/*  health is normal */
+	BFA_POM_HEALTH_WARNING = 3,	/*  warning level */
+	BFA_POM_HEALTH_ALARM = 4,	/*  alarming level */
+};
+
+/**
+ * Reading of temperature/voltage/current/power
+ */
+struct bfa_pom_entry_s {
+	enum bfa_pom_entry_health health;	/*  POM entry health */
+	u32 curr_value;		/*  current value */
+	u32 thr_warn_high;	/*  threshold warning high */
+	u32 thr_warn_low;	/*  threshold warning low */
+	u32 thr_alarm_low;	/*  threshold alaram low */
+	u32 thr_alarm_high;	/*  threshold alarm high */
+};
+
+/**
+ * POM attributes
+ */
+struct bfa_pom_attr_s {
+	struct bfa_pom_entry_s temperature;	/*  centigrade */
+	struct bfa_pom_entry_s voltage;	/*  volts */
+	struct bfa_pom_entry_s curr;	/*  milli amps */
+	struct bfa_pom_entry_s txpower;	/*  micro watts */
+	struct bfa_pom_entry_s rxpower;	/*  micro watts */
+};
+
+#endif /* __BFA_DEFS_POM_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_port.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_port.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_port.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_port.h	2009-08-28 21:09:27.075606000 -0700
@@ -0,0 +1,252 @@
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
+#ifndef __BFA_DEFS_PORT_H__
+#define __BFA_DEFS_PORT_H__
+
+#include <bfa_os_inc.h>
+#include <protocol/types.h>
+#include <defs/bfa_defs_pport.h>
+#include <defs/bfa_defs_ioc.h>
+
+#define BFA_FCS_FABRIC_IPADDR_SZ  16
+
+/**
+ * symbolic names for base port/virtual port
+ */
+#define BFA_SYMNAME_MAXLEN	128	/* vmware/windows uses 128 bytes */
+struct bfa_port_symname_s {
+	char symname[BFA_SYMNAME_MAXLEN];
+};
+
+/**
+* Roles of FCS port:
+ *     - FCP IM and FCP TM roles cannot be enabled together for a FCS port
+ *     - Create multiple ports if both IM and TM functions required.
+ *     - Atleast one role must be specified.
+ */
+enum bfa_port_role {
+	BFA_PORT_ROLE_FCP_IM = 0x01,	/*  FCP initiator role */
+	BFA_PORT_ROLE_FCP_TM = 0x02,	/*  FCP target role */
+	BFA_PORT_ROLE_FCP_IPFC = 0x04,	/*  IP over FC role */
+	BFA_PORT_ROLE_FCP_MAX = BFA_PORT_ROLE_FCP_IPFC | BFA_PORT_ROLE_FCP_IM
+};
+
+/**
+ * FCS port configuration.
+ */
+struct bfa_port_cfg_s {
+	wwn_t pwwn;		/*  port wwn */
+	wwn_t nwwn;		/*  node wwn */
+	struct bfa_port_symname_s sym_name;	/*  vm port symbolic name */
+	enum bfa_port_role roles;	/*  FCS port roles */
+	u32 rsvd;
+	u8 tag[16];		/*  opaque tag from application */
+};
+
+/**
+ * FCS port states
+ */
+enum bfa_port_state {
+	BFA_PORT_UNINIT = 0,	/*  PORT is not yet initialized */
+	BFA_PORT_FDISC = 1,	/*  FDISC is in progress */
+	BFA_PORT_ONLINE = 2,	/*  login to fabric is complete */
+	BFA_PORT_OFFLINE = 3,	/*  No login to fabric */
+};
+
+/**
+ * FCS port type. Required for VmWare.
+ */
+enum bfa_port_type {
+	BFA_PORT_TYPE_PHYSICAL = 0,
+	BFA_PORT_TYPE_VIRTUAL,
+};
+
+/**
+ * FCS port offline reason. Required for VmWare.
+ */
+enum bfa_port_offline_reason {
+	BFA_PORT_OFFLINE_UNKNOWN = 0,
+	BFA_PORT_OFFLINE_LINKDOWN,
+	BFA_PORT_OFFLINE_FAB_UNSUPPORTED,	/*  NPIV not supported by the
+						 *    fabric */
+	BFA_PORT_OFFLINE_FAB_NORESOURCES,
+	BFA_PORT_OFFLINE_FAB_LOGOUT,
+};
+
+/**
+ * FCS lport info. Required for VmWare.
+ */
+struct bfa_port_info_s {
+	u8 port_type;		/* bfa_port_type_t : physical or
+				 * virtual */
+	u8 port_state;		/* one of bfa_port_state values */
+	u8 offline_reason;	/* one of bfa_port_offline_reason_t
+				 * values */
+	wwn_t port_wwn;
+	wwn_t node_wwn;
+
+	/*
+	 * following 4 feilds are valid for Physical Ports only
+	 */
+	u32 max_vports_supp;	/* Max supported vports */
+	u32 num_vports_inuse;	/* Num of in use vports */
+	u32 max_rports_supp;	/* Max supported rports */
+	u32 num_rports_inuse;	/* Num of doscovered rports */
+
+};
+
+/**
+ * FCS port statistics
+ */
+struct bfa_port_stats_s {
+	u32 ns_plogi_sent;
+	u32 ns_plogi_rsp_err;
+	u32 ns_plogi_acc_err;
+	u32 ns_plogi_accepts;
+	u32 ns_rejects;		/* NS command rejects */
+	u32 ns_plogi_unknown_rsp;
+	u32 ns_plogi_alloc_wait;
+
+	u32 ns_retries;		/* NS command retries */
+	u32 ns_timeouts;	/* NS command timeouts */
+
+	u32 ns_rspnid_sent;
+	u32 ns_rspnid_accepts;
+	u32 ns_rspnid_rsp_err;
+	u32 ns_rspnid_rejects;
+	u32 ns_rspnid_alloc_wait;
+
+	u32 ns_rftid_sent;
+	u32 ns_rftid_accepts;
+	u32 ns_rftid_rsp_err;
+	u32 ns_rftid_rejects;
+	u32 ns_rftid_alloc_wait;
+
+	u32 ns_rffid_sent;
+	u32 ns_rffid_accepts;
+	u32 ns_rffid_rsp_err;
+	u32 ns_rffid_rejects;
+	u32 ns_rffid_alloc_wait;
+
+	u32 ns_gidft_sent;
+	u32 ns_gidft_accepts;
+	u32 ns_gidft_rsp_err;
+	u32 ns_gidft_rejects;
+	u32 ns_gidft_unknown_rsp;
+	u32 ns_gidft_alloc_wait;
+
+	/*
+	 * Mgmt Server stats
+	 */
+	u32 ms_retries;		/* MS command retries */
+	u32 ms_timeouts;	/* MS command timeouts */
+	u32 ms_plogi_sent;
+	u32 ms_plogi_rsp_err;
+	u32 ms_plogi_acc_err;
+	u32 ms_plogi_accepts;
+	u32 ms_rejects;		/* NS command rejects */
+	u32 ms_plogi_unknown_rsp;
+	u32 ms_plogi_alloc_wait;
+
+	u32 num_rscn;		/* Num of RSCN received */
+	u32 num_portid_rscn;	/* Num portid format RSCN
+				 * received */
+
+	u32 uf_recvs;		/* unsolicited recv frames      */
+	u32 uf_recv_drops;	/* dropped received frames      */
+
+	u32 rsvd;		/* padding for 64 bit alignment */
+};
+
+/**
+ * BFA port attribute returned in queries
+ */
+struct bfa_port_attr_s {
+	enum bfa_port_state state;	/*  port state */
+	u32 pid;		/*  port ID */
+	struct bfa_port_cfg_s port_cfg;	/*  port configuration */
+	enum bfa_pport_type port_type;	/*  current topology */
+	u32 loopback;		/*  cable is externally looped back */
+	wwn_t fabric_name;	/*  attached switch's nwwn */
+	u8 fabric_ip_addr[BFA_FCS_FABRIC_IPADDR_SZ];	/*  attached
+							 * fabric's ip addr */
+};
+
+/**
+ * BFA physical port Level events
+ * Arguments below are in BFAL context from Mgmt
+ * BFA_PORT_AEN_ONLINE:     [in]: pwwn	[out]: pwwn
+ * BFA_PORT_AEN_OFFLINE:    [in]: pwwn	[out]: pwwn
+ * BFA_PORT_AEN_RLIR:       [in]: None	[out]: pwwn, rlir_data, rlir_len
+ * BFA_PORT_AEN_SFP_INSERT: [in]: pwwn	[out]: port_id, pwwn
+ * BFA_PORT_AEN_SFP_REMOVE: [in]: pwwn	[out]: port_id, pwwn
+ * BFA_PORT_AEN_SFP_POM:    [in]: pwwn	[out]: level, port_id, pwwn
+ * BFA_PORT_AEN_ENABLE:     [in]: pwwn	[out]: pwwn
+ * BFA_PORT_AEN_DISABLE:    [in]: pwwn	[out]: pwwn
+ * BFA_PORT_AEN_AUTH_ON:    [in]: pwwn	[out]: pwwn
+ * BFA_PORT_AEN_AUTH_OFF:   [in]: pwwn	[out]: pwwn
+ * BFA_PORT_AEN_DISCONNECT: [in]: pwwn	[out]: pwwn
+ * BFA_PORT_AEN_QOS_NEG:    [in]: pwwn	[out]: pwwn
+ * BFA_PORT_AEN_FABRIC_NAME_CHANGE: [in]: pwwn, [out]: pwwn, fwwn
+ *
+ */
+enum bfa_port_aen_event {
+	BFA_PORT_AEN_ONLINE = 1,	/*  Physical Port online event */
+	BFA_PORT_AEN_OFFLINE = 2,	/*  Physical Port offline event */
+	BFA_PORT_AEN_RLIR = 3,	/*  RLIR event, not supported */
+	BFA_PORT_AEN_SFP_INSERT = 4,	/*  SFP inserted event */
+	BFA_PORT_AEN_SFP_REMOVE = 5,	/*  SFP removed event */
+	BFA_PORT_AEN_SFP_POM = 6,	/*  SFP POM event */
+	BFA_PORT_AEN_ENABLE = 7,	/*  Physical Port enable event */
+	BFA_PORT_AEN_DISABLE = 8,	/*  Physical Port disable event */
+	BFA_PORT_AEN_AUTH_ON = 9,	/*  Physical Port auth success event */
+	BFA_PORT_AEN_AUTH_OFF = 10,	/*  Physical Port auth fail event */
+	BFA_PORT_AEN_DISCONNECT = 11,	/*  Physical Port disconnect event */
+	BFA_PORT_AEN_QOS_NEG = 12,	/*  Base Port QOS negotiation event */
+	BFA_PORT_AEN_FABRIC_NAME_CHANGE = 13,	/*  Fabric Name/WWN change
+						 * event */
+	BFA_PORT_AEN_SFP_ACCESS_ERROR = 14,	/*  SFP read error event */
+	BFA_PORT_AEN_SFP_UNSUPPORT = 15,	/*  Unsupported SFP event */
+};
+
+enum bfa_port_aen_sfp_pom {
+	BFA_PORT_AEN_SFP_POM_GREEN = 1,	/*  Normal */
+	BFA_PORT_AEN_SFP_POM_AMBER = 2,	/*  Warning */
+	BFA_PORT_AEN_SFP_POM_RED = 3,	/*  Critical */
+	BFA_PORT_AEN_SFP_POM_MAX = BFA_PORT_AEN_SFP_POM_RED
+};
+
+struct bfa_port_aen_data_s {
+	enum bfa_ioc_type_e ioc_type;
+	wwn_t pwwn;		/*  WWN of the physical port */
+	wwn_t fwwn;		/*  WWN of the fabric port */
+	mac_t mac;		/*  MAC addres of the ethernet port,
+				 * applicable to CNA port only */
+	int phy_port_num;	/*! For SFP related events */
+	enum bfa_port_aen_sfp_pom level;	/*  Only transitions will
+						 * be informed */
+};
+
+#endif /* __BFA_DEFS_PORT_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_pport.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_pport.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_pport.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_pport.h	2009-08-28 21:09:27.295611000 -0700
@@ -0,0 +1,390 @@
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
+#ifndef __BFA_DEFS_PPORT_H__
+#define __BFA_DEFS_PPORT_H__
+
+#include <bfa_os_inc.h>
+#include <protocol/fc.h>
+#include <defs/bfa_defs_types.h>
+#include <defs/bfa_defs_qos.h>
+#include <cna/pstats/phyport_defs.h>
+
+/* Modify char* port_stt[] in bfal_port.c if a new state was added */
+enum bfa_pport_states {
+	BFA_PPORT_ST_UNINIT = 1,
+	BFA_PPORT_ST_ENABLING_QWAIT = 2,
+	BFA_PPORT_ST_ENABLING = 3,
+	BFA_PPORT_ST_LINKDOWN = 4,
+	BFA_PPORT_ST_LINKUP = 5,
+	BFA_PPORT_ST_DISABLING_QWAIT = 6,
+	BFA_PPORT_ST_DISABLING = 7,
+	BFA_PPORT_ST_DISABLED = 8,
+	BFA_PPORT_ST_STOPPED = 9,
+	BFA_PPORT_ST_IOCDOWN = 10,
+	BFA_PPORT_ST_IOCDIS = 11,
+	BFA_PPORT_ST_FWMISMATCH = 12,
+	BFA_PPORT_ST_MAX_STATE,
+};
+
+/**
+ * 	Port speed settings. Each specific speed is a bit field. Use multiple
+ *      bits to specify speeds to be selected for auto-negotiation.
+ */
+enum bfa_pport_speed {
+	BFA_PPORT_SPEED_UNKNOWN = 0,
+	BFA_PPORT_SPEED_1GBPS = 1,
+	BFA_PPORT_SPEED_2GBPS = 2,
+	BFA_PPORT_SPEED_4GBPS = 4,
+	BFA_PPORT_SPEED_8GBPS = 8,
+	BFA_PPORT_SPEED_10GBPS = 10,
+	BFA_PPORT_SPEED_AUTO =
+		(BFA_PPORT_SPEED_1GBPS | BFA_PPORT_SPEED_2GBPS |
+		 BFA_PPORT_SPEED_4GBPS | BFA_PPORT_SPEED_8GBPS),
+};
+
+/**
+ * 		Port operational type (in sync with SNIA port type).
+ */
+enum bfa_pport_type {
+	BFA_PPORT_TYPE_UNKNOWN = 1,	/*  port type is unkown */
+	BFA_PPORT_TYPE_TRUNKED = 2,	/*  Trunked mode */
+	BFA_PPORT_TYPE_NPORT = 5,	/*  P2P with switched fabric */
+	BFA_PPORT_TYPE_NLPORT = 6,	/*  public loop */
+	BFA_PPORT_TYPE_LPORT = 20,	/*  private loop */
+	BFA_PPORT_TYPE_P2P = 21,	/*  P2P with no switched fabric */
+	BFA_PPORT_TYPE_VPORT = 22,	/*  NPIV - virtual port */
+};
+
+/**
+ * 		Port topology setting. A port's topology and fabric login status
+ * 		determine its operational type.
+ */
+enum bfa_pport_topology {
+	BFA_PPORT_TOPOLOGY_NONE = 0,	/*  No valid topology */
+	BFA_PPORT_TOPOLOGY_P2P = 1,	/*  P2P only */
+	BFA_PPORT_TOPOLOGY_LOOP = 2,	/*  LOOP topology */
+	BFA_PPORT_TOPOLOGY_AUTO = 3,	/*  auto topology selection */
+};
+
+/**
+ * 		Physical port loopback types.
+ */
+enum bfa_pport_opmode {
+	BFA_PPORT_OPMODE_NORMAL = 0x00,	/*  normal non-loopback mode */
+	BFA_PPORT_OPMODE_LB_INT = 0x01,	/*  internal loop back */
+	BFA_PPORT_OPMODE_LB_SLW = 0x02,	/*  serial link wrapback (serdes) */
+	BFA_PPORT_OPMODE_LB_EXT = 0x04,	/*  external loop back (serdes) */
+	BFA_PPORT_OPMODE_LB_CBL = 0x08,	/*  cabled loop back */
+	BFA_PPORT_OPMODE_LB_NLINT = 0x20,	/*  NL_Port internal loopback */
+};
+
+#define BFA_PPORT_OPMODE_LB_HARD(_mode)			\
+	((_mode == BFA_PPORT_OPMODE_LB_INT) ||		\
+     (_mode == BFA_PPORT_OPMODE_LB_SLW) ||		\
+     (_mode == BFA_PPORT_OPMODE_LB_EXT))
+
+/**
+		Port State (in sync with SNIA port state).
+ */
+enum bfa_pport_snia_state {
+	BFA_PPORT_STATE_UNKNOWN = 1,	/*  port is not initialized */
+	BFA_PPORT_STATE_ONLINE = 2,	/*  port is ONLINE */
+	BFA_PPORT_STATE_DISABLED = 3,	/*  port is disabled by user */
+	BFA_PPORT_STATE_BYPASSED = 4,	/*  port is bypassed (in LOOP) */
+	BFA_PPORT_STATE_DIAG = 5,	/*  port diagnostics is active */
+	BFA_PPORT_STATE_LINKDOWN = 6,	/*  link is down */
+	BFA_PPORT_STATE_LOOPBACK = 8,	/*  port is looped back */
+};
+
+/**
+ * 		Port link state
+ */
+enum bfa_pport_linkstate {
+	BFA_PPORT_LINKUP = 1,	/*  Physical port/Trunk link up */
+	BFA_PPORT_LINKDOWN = 2,	/*  Physical port/Trunk link down */
+	BFA_PPORT_TRUNK_LINKDOWN = 3,	/*  Trunk link down (new tmaster) */
+};
+
+/**
+ * 		Port link state event
+ */
+#define bfa_pport_event_t enum bfa_pport_linkstate
+
+/**
+ * 		Port link state reason code
+ */
+enum bfa_pport_linkstate_rsn {
+	BFA_PPORT_LINKSTATE_RSN_NONE = 0,
+	BFA_PPORT_LINKSTATE_RSN_DISABLED = 1,
+	BFA_PPORT_LINKSTATE_RSN_RX_NOS = 2,
+	BFA_PPORT_LINKSTATE_RSN_RX_OLS = 3,
+	BFA_PPORT_LINKSTATE_RSN_RX_LIP = 4,
+	BFA_PPORT_LINKSTATE_RSN_RX_LIPF7 = 5,
+	BFA_PPORT_LINKSTATE_RSN_SFP_REMOVED = 6,
+	BFA_PPORT_LINKSTATE_RSN_PORT_FAULT = 7,
+	BFA_PPORT_LINKSTATE_RSN_RX_LOS = 8,
+	BFA_PPORT_LINKSTATE_RSN_LOCAL_FAULT = 9,
+	BFA_PPORT_LINKSTATE_RSN_REMOTE_FAULT = 10,
+	BFA_PPORT_LINKSTATE_RSN_TIMEOUT = 11,
+
+
+
+	/* CEE related reason codes/errors */
+	CEE_LLDP_INFO_AGED_OUT = 20,
+	CEE_LLDP_SHUTDOWN_TLV_RCVD = 21,
+	CEE_PEER_NOT_ADVERTISE_DCBX = 22,
+	CEE_PEER_NOT_ADVERTISE_PG = 23,
+	CEE_PEER_NOT_ADVERTISE_PFC = 24,
+	CEE_PEER_NOT_ADVERTISE_FCOE = 25,
+	CEE_PG_NOT_COMPATIBLE = 26,
+	CEE_PFC_NOT_COMPATIBLE = 27,
+	CEE_FCOE_NOT_COMPATIBLE = 28,
+	CEE_BAD_PG_RCVD = 29,
+	CEE_BAD_BW_RCVD = 30,
+	CEE_BAD_PFC_RCVD = 31,
+	CEE_BAD_FCOE_PRI_RCVD = 32,
+	CEE_FCOE_PRI_PFC_OFF = 33,
+	CEE_DUP_CONTROL_TLV_RCVD = 34,
+	CEE_DUP_FEAT_TLV_RCVD = 35,
+	CEE_APPLY_NEW_CFG = 36,	/* reason, not an error */
+	CEE_PROTOCOL_INIT = 37,	/* reason, not an error */
+	CEE_PHY_LINK_DOWN = 38,
+	CEE_LLS_FCOE_ABSENT = 39,
+	CEE_LLS_FCOE_DOWN = 40
+};
+
+/**
+ *      Default Target Rate Limiting Speed.
+ */
+#define BFA_PPORT_DEF_TRL_SPEED  BFA_PPORT_SPEED_1GBPS
+
+/**
+ *      Physical port configuration
+ */
+struct bfa_pport_cfg_s {
+	u8 topology;		/*  bfa_pport_topology          */
+	u8 speed;		/*  enum bfa_pport_speed        */
+	u8 trunked;		/*  trunked or not              */
+	u8 qos_enabled;		/*  qos enabled or not          */
+	u8 trunk_ports;		/*  bitmap of trunked ports     */
+	u8 cfg_hardalpa;	/*  is hard alpa configured     */
+	u16 maxfrsize;		/*  maximum frame size          */
+	u8 hardalpa;		/*  configured hard alpa        */
+	u8 rx_bbcredit;		/*  receive buffer credits      */
+	u8 tx_bbcredit;		/*  transmit buffer credits     */
+	u8 ratelimit;		/*  ratelimit enabled or not    */
+	u8 trl_def_speed;	/*  ratelimit default speed     */
+	u8 rsvd[3];
+	u16 path_tov;		/*  device path timeout */
+	u16 q_depth;		/*  SCSI Queue depth            */
+};
+
+/**
+ * 		Port attribute values.
+ */
+struct bfa_pport_attr_s {
+	/*
+	 * Static fields
+	 */
+	wwn_t nwwn;		/*  node wwn */
+	wwn_t pwwn;		/*  port wwn */
+	enum fc_cos cos_supported;	/*  supported class of services */
+	u32 rsvd;
+	struct fc_symname_s port_symname;	/*  port symbolic name */
+	enum bfa_pport_speed speed_supported;	/*  supported speeds */
+	bfa_boolean_t pbind_enabled;	/*  Will be set if Persistent binding
+					 *   enabled. Relevant only in Windows
+					 */
+
+	/*
+	 * Configured values
+	 */
+	struct bfa_pport_cfg_s pport_cfg;	/*  pport cfg */
+
+	/*
+	 * Dynamic field - info from BFA
+	 */
+	enum bfa_pport_states port_state;	/*  current port state */
+	enum bfa_pport_speed speed;	/*  current speed */
+	enum bfa_pport_topology topology;	/*  current topology */
+	bfa_boolean_t beacon;	/*  current beacon status */
+	bfa_boolean_t link_e2e_beacon;	/*  set if link beacon on */
+	bfa_boolean_t plog_enabled;	/*  set if portlog is enabled */
+
+	/*
+	 * Dynamic field - info from FCS
+	 */
+	u32 pid;		/*  port ID */
+	enum bfa_pport_type port_type;	/*  current topology */
+	u32 loopback;		/*  external loopback */
+	u32 rsvd1;
+	u32 rsvd2;		/*  padding for 64 bit */
+};
+
+/**
+ * 		FC Port statistics.
+ */
+struct bfa_pport_fc_stats_s {
+	u64 secs_reset;		/*  seconds since stats is reset */
+	u64 tx_frames;		/*  transmitted frames */
+	u64 tx_words;		/*  transmitted words */
+	u64 rx_frames;		/*  received frames */
+	u64 rx_words;		/*  received words */
+	u64 lip_count;		/*  LIPs seen */
+	u64 nos_count;		/*  NOS count */
+	u64 error_frames;	/*  errored frames (sent?) */
+	u64 dropped_frames;	/*  dropped frames */
+	u64 link_failures;	/*  link failure count */
+	u64 loss_of_syncs;	/*  loss of sync count */
+	u64 loss_of_signals;	/*  loss of signal count */
+	u64 primseq_errs;	/*  primitive sequence protocol */
+	u64 bad_os_count;	/*  invalid ordered set */
+	u64 err_enc_out;	/*  Encoding error outside frame */
+	u64 invalid_crcs;	/*  frames received with invalid CRC */
+	u64 undersized_frm;	/*  undersized frames */
+	u64 oversized_frm;	/*  oversized frames */
+	u64 bad_eof_frm;	/*  frames with bad EOF */
+	struct bfa_qos_stats_s qos_stats;	/*  QoS statistics */
+};
+
+/**
+ * 		Eth Port statistics.
+ */
+struct bfa_pport_eth_stats_s {
+	u64 secs_reset;		/*  seconds since stats is reset */
+	u64 frame_64;		/*  both rx and tx counter */
+	u64 frame_65_127;	/* both rx and tx counter */
+	u64 frame_128_255;	/* both rx and tx counter */
+	u64 frame_256_511;	/* both rx and tx counter */
+	u64 frame_512_1023;	/* both rx and tx counter */
+	u64 frame_1024_1518;	/* both rx and tx counter */
+	u64 frame_1519_1522;	/* both rx and tx counter */
+
+	u64 tx_bytes;
+	u64 tx_packets;
+	u64 tx_mcast_packets;
+	u64 tx_bcast_packets;
+	u64 tx_control_frame;
+	u64 tx_drop;
+	u64 tx_jabber;
+	u64 tx_fcs_error;
+	u64 tx_fragments;
+
+	u64 rx_bytes;
+	u64 rx_packets;
+	u64 rx_mcast_packets;
+	u64 rx_bcast_packets;
+	u64 rx_control_frames;
+	u64 rx_unknown_opcode;
+	u64 rx_drop;
+	u64 rx_jabber;
+	u64 rx_fcs_error;
+	u64 rx_alignment_error;
+	u64 rx_frame_length_error;
+	u64 rx_code_error;
+	u64 rx_fragments;
+
+	u64 rx_pause;		/* BPC */
+	u64 rx_zero_pause;	/*  BPC Pause cancellation */
+	u64 tx_pause;		/* BPC */
+	u64 tx_zero_pause;	/*  BPC Pause cancellation */
+	u64 rx_fcoe_pause;	/* BPC */
+	u64 rx_fcoe_zero_pause;	/*  BPC Pause cancellation */
+	u64 tx_fcoe_pause;	/* BPC */
+	u64 tx_fcoe_zero_pause;	/*  BPC Pause cancellation */
+};
+
+/**
+ * 		Port statistics.
+ */
+union bfa_pport_stats_u {
+	struct bfa_pport_fc_stats_s fc;
+	struct bfa_pport_eth_stats_s eth;
+};
+
+/**
+ *              Port FCP mappings.
+ */
+struct bfa_pport_fcpmap_s {
+	char osdevname[256];
+	u32 bus;
+	u32 target;
+	u32 oslun;
+	u32 fcid;
+	wwn_t nwwn;
+	wwn_t pwwn;
+	u64 fcplun;
+	char luid[256];
+};
+
+/**
+ *              Port RNID info.
+ */
+struct bfa_pport_rnid_s {
+	wwn_t wwn;
+	u32 unittype;
+	u32 portid;
+	u32 attached_nodes_num;
+	u16 ip_version;
+	u16 udp_port;
+	u8 ipaddr[16];
+	u16 rsvd;
+	u16 topologydiscoveryflags;
+};
+
+/**
+ * 		Link state information
+ */
+struct bfa_pport_link_s {
+	u8 linkstate;		/*  Link state bfa_pport_linkstate */
+	u8 linkstate_rsn;	/*  bfa_pport_linkstate_rsn_t */
+	u8 topology;		/*  P2P/LOOP bfa_pport_topology */
+	u8 speed;		/*  Link speed (1/2/4/8 G) */
+	u32 linkstate_opt;	/*  Linkstate optional data (debug) */
+	u8 trunked;		/*  Trunked or not (1 or 0) */
+	u8 resvd[3];
+	struct bfa_qos_attr_s qos_attr;	/* QoS Attributes */
+	struct bfa_qos_vc_attr_s qos_vc_attr;	/*  VC info from ELP */
+	union {
+		struct {
+			u8 tmaster;	/*  Trunk Master or
+					 *    not (1 or 0) */
+			u8 tlinks;	/*  Trunk links bitmap
+					 *    (linkup) */
+			u8 resv1;	/*  Reserved */
+		} trunk_info;
+
+		struct {
+			u8 myalpa;	/*  alpa claimed */
+			u8 login_req;	/*  Login required or
+					 *    not (1 or 0) */
+			u8 alpabm_val;	/*  alpa bitmap valid
+					 *    or not (1 or 0) */
+			struct fc_alpabm_s alpabm;	/*  alpa bitmap */
+		} loop_info;
+	} tl;
+};
+
+#endif /* __BFA_DEFS_PPORT_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_qos.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_qos.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_qos.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_qos.h	2009-08-28 21:09:27.149607000 -0700
@@ -0,0 +1,106 @@
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
+#ifndef __BFA_DEFS_QOS_H__
+#define __BFA_DEFS_QOS_H__
+
+/**
+ * QoS states
+ */
+enum bfa_qos_state {
+	BFA_QOS_ONLINE = 1,	/*  QoS is online */
+	BFA_QOS_OFFLINE = 2,	/*  QoS is offline */
+};
+
+
+/**
+ * QoS  Priority levels.
+ */
+enum bfa_qos_priority {
+	BFA_QOS_UNKNOWN = 0,
+	BFA_QOS_HIGH = 1,	/*  QoS Priority Level High */
+	BFA_QOS_MED = 2,	/*  QoS Priority Level Medium */
+	BFA_QOS_LOW = 3,	/*  QoS Priority Level Low */
+};
+
+
+/**
+ * QoS  bandwidth allocation for each priority level
+ */
+enum bfa_qos_bw_alloc {
+	BFA_QOS_BW_HIGH = 60,	/*  bandwidth allocation for High */
+	BFA_QOS_BW_MED = 30,	/*  bandwidth allocation for Medium */
+	BFA_QOS_BW_LOW = 10,	/*  bandwidth allocation for Low */
+};
+
+/**
+ * QoS attribute returned in QoS Query
+ */
+struct bfa_qos_attr_s {
+	enum bfa_qos_state state;	/*  QoS current state */
+	u32 total_bb_cr;	/*  Total BB Credits */
+};
+
+/**
+ * These fields should be displayed only from the CLI.
+ * There will be a separate BFAL API (get_qos_vc_attr ?)
+ * to retrieve this.
+ *
+ */
+#define  BFA_QOS_MAX_VC  16
+
+struct bfa_qos_vc_info_s {
+	u8 vc_credit;
+	u8 borrow_credit;
+	u8 priority;
+	u8 resvd;
+};
+
+struct bfa_qos_vc_attr_s {
+	u16 total_vc_count;	/*  Total VC Count */
+	u16 shared_credit;
+	u32 elp_opmode_flags;
+	struct bfa_qos_vc_info_s vc_info[BFA_QOS_MAX_VC];	/*   as many as
+								 * total_vc_count */
+};
+
+/**
+ * QoS statistics
+ */
+struct bfa_qos_stats_s {
+	u32 flogi_sent;		/*  QoS Flogi sent */
+	u32 flogi_acc_recvd;	/*  QoS Flogi Acc received */
+	u32 flogi_rjt_recvd;	/*  QoS Flogi rejects received */
+	u32 flogi_retries;	/*  QoS Flogi retries */
+
+	u32 elp_recvd;		/*  QoS ELP received */
+	u32 elp_accepted;	/*  QoS ELP Accepted */
+	u32 elp_rejected;	/*  QoS ELP rejected */
+	u32 elp_dropped;	/*  QoS ELP dropped  */
+
+	u32 qos_rscn_recvd;	/*  QoS RSCN received */
+	u32 rsvd;		/* padding for 64 bit alignment */
+};
+
+#endif /* __BFA_DEFS_QOS_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_rport.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_rport.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_rport.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_rport.h	2009-08-28 21:09:27.280609000 -0700
@@ -0,0 +1,206 @@
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
+#ifndef __BFA_DEFS_RPORT_H__
+#define __BFA_DEFS_RPORT_H__
+
+#include <bfa_os_inc.h>
+#include <protocol/types.h>
+#include <defs/bfa_defs_pport.h>
+#include <defs/bfa_defs_port.h>
+#include <defs/bfa_defs_qos.h>
+
+/**
+ * FCS remote port states
+ */
+enum bfa_rport_state {
+	BFA_RPORT_UNINIT = 0,	/*  PORT is not yet initialized */
+	BFA_RPORT_OFFLINE = 1,	/*  rport is offline */
+	BFA_RPORT_PLOGI = 2,	/*  PLOGI to rport is in progress */
+	BFA_RPORT_ONLINE = 3,	/*  login to rport is complete */
+	BFA_RPORT_PLOGI_RETRY = 4,	/*  retrying login to rport */
+	BFA_RPORT_NSQUERY = 5,	/*  nameserver query */
+	BFA_RPORT_ADISC = 6,	/*  ADISC authentication */
+	BFA_RPORT_LOGO = 7,	/*  logging out with rport */
+	BFA_RPORT_LOGORCV = 8,	/*  handling LOGO from rport */
+	BFA_RPORT_NSDISC = 9,	/*  re-discover rport */
+};
+
+/**
+ *  Rport Scsi Function : Initiator/Target.
+ */
+enum bfa_rport_function {
+	BFA_RPORT_INITIATOR = 0x01,	/*  SCSI Initiator      */
+	BFA_RPORT_TARGET = 0x02,	/*  SCSI Target */
+};
+
+/**
+ * port/node symbolic names for rport
+ */
+#define BFA_RPORT_SYMNAME_MAXLEN	255
+struct bfa_rport_symname_s {
+	char symname[BFA_RPORT_SYMNAME_MAXLEN];
+};
+
+struct bfa_rport_hal_stats_s {
+	u32 sm_un_cr;		/*  uninit: create events      */
+	u32 sm_un_unexp;	/*  uninit: exception events   */
+	u32 sm_cr_on;		/*  created: online events     */
+	u32 sm_cr_del;		/*  created: delete events     */
+	u32 sm_cr_hwf;		/*  created: IOC down          */
+	u32 sm_cr_unexp;	/*  created: exception events  */
+	u32 sm_fwc_rsp;		/*  fw create: f/w responses   */
+	u32 sm_fwc_del;		/*  fw create: delete events   */
+	u32 sm_fwc_off;		/*  fw create: offline events  */
+	u32 sm_fwc_hwf;		/*  fw create: IOC down        */
+	u32 sm_fwc_unexp;	/*  fw create: exception events */
+	u32 sm_on_off;		/*  online: offline events     */
+	u32 sm_on_del;		/*  online: delete events      */
+	u32 sm_on_hwf;		/*  online: IOC down events    */
+	u32 sm_on_unexp;	/*  online: exception events   */
+	u32 sm_fwd_rsp;		/*  fw delete: fw responses    */
+	u32 sm_fwd_del;		/*  fw delete: delete events   */
+	u32 sm_fwd_hwf;		/*  fw delete: IOC down events */
+	u32 sm_fwd_unexp;	/*  fw delete: exception events */
+	u32 sm_off_del;		/*  offline: delete events     */
+	u32 sm_off_on;		/*  offline: online events     */
+	u32 sm_off_hwf;		/*  offline: IOC down events   */
+	u32 sm_off_unexp;	/*  offline: exception events  */
+	u32 sm_del_fwrsp;	/*  delete: fw responses       */
+	u32 sm_del_hwf;		/*  delete: IOC down events    */
+	u32 sm_del_unexp;	/*  delete: exception events   */
+	u32 sm_delp_fwrsp;	/*  delete pend: fw responses  */
+	u32 sm_delp_hwf;	/*  delete pend: IOC downs     */
+	u32 sm_delp_unexp;	/*  delete pend: exceptions    */
+	u32 sm_offp_fwrsp;	/*  off-pending: fw responses  */
+	u32 sm_offp_del;	/*  off-pending: deletes       */
+	u32 sm_offp_hwf;	/*  off-pending: IOC downs     */
+	u32 sm_offp_unexp;	/*  off-pending: exceptions    */
+	u32 sm_iocd_off;	/*  IOC down: offline events   */
+	u32 sm_iocd_del;	/*  IOC down: delete events    */
+	u32 sm_iocd_on;		/*  IOC down: online events    */
+	u32 sm_iocd_unexp;	/*  IOC down: exceptions       */
+	u32 rsvd;
+};
+
+/**
+ * FCS remote port statistics
+ */
+struct bfa_rport_stats_s {
+	u32 offlines;		/*  remote port offline count  */
+	u32 onlines;		/*  remote port online count   */
+	u32 rscns;		/*  RSCN affecting rport       */
+	u32 plogis;		/*  plogis sent                */
+	u32 plogi_accs;		/*  plogi accepts              */
+	u32 plogi_timeouts;	/*  plogi timeouts             */
+	u32 plogi_rejects;	/*  rcvd plogi rejects         */
+	u32 plogi_failed;	/*  local failure              */
+	u32 plogi_rcvd;		/*  plogis rcvd                */
+	u32 prli_rcvd;		/*  inbound PRLIs              */
+	u32 adisc_rcvd;		/*  ADISCs received            */
+	u32 adisc_rejects;	/*  recvd  ADISC rejects       */
+	u32 adisc_sent;		/*  ADISC requests sent        */
+	u32 adisc_accs;		/*  ADISC accepted by rport    */
+	u32 adisc_failed;	/*  ADISC failed (no response) */
+	u32 adisc_rejected;	/*  ADISC rejected by us    */
+	u32 logos;		/*  logos sent                 */
+	u32 logo_accs;		/*  LOGO accepts from rport    */
+	u32 logo_failed;	/*  LOGO failures              */
+	u32 logo_rejected;	/*  LOGO rejects from rport    */
+	u32 logo_rcvd;		/*  LOGO from remote port      */
+
+	u32 rpsc_rcvd;		/*  RPSC received            */
+	u32 rpsc_rejects;	/*  recvd  RPSC rejects       */
+	u32 rpsc_sent;		/*  RPSC requests sent        */
+	u32 rpsc_accs;		/*  RPSC accepted by rport    */
+	u32 rpsc_failed;	/*  RPSC failed (no response) */
+	u32 rpsc_rejected;	/*  RPSC rejected by us    */
+
+	u32 rsvd;
+	struct bfa_rport_hal_stats_s hal_stats;	/*  BFA rport stats    */
+};
+
+/**
+ *  Rport's QoS attributes
+ */
+struct bfa_rport_qos_attr_s {
+	enum bfa_qos_priority qos_priority;	/*  rport's QoS priority   */
+	u32 qos_flow_id;	/*  QoS flow Id        */
+};
+
+/**
+ * FCS remote port attributes returned in queries
+ */
+struct bfa_rport_attr_s {
+	wwn_t nwwn;		/*  node wwn */
+	wwn_t pwwn;		/*  port wwn */
+	enum fc_cos cos_supported;	/*  supported class of services */
+	u32 pid;		/*  port ID */
+	u32 df_sz;		/*  Max payload size */
+	enum bfa_rport_state state;	/*  Rport State machine state */
+	enum fc_cos fc_cos;	/*  FC classes of services */
+	bfa_boolean_t cisc;	/*  CISC capable device */
+	struct bfa_rport_symname_s symname;	/*  Symbolic Name */
+	enum bfa_rport_function scsi_function;	/*  Initiator/Target */
+	struct bfa_rport_qos_attr_s qos_attr;	/*  qos attributes  */
+	enum bfa_pport_speed curr_speed;	/*  operating speed got from
+						 * RPSC ELS. UNKNOWN, if RPSC
+						 * is not supported */
+	bfa_boolean_t trl_enforced;	/*  TRL enforced ? TRUE/FALSE */
+	enum bfa_pport_speed assigned_speed;	/* Speed assigned by the user.
+						 * will be used if RPSC is not
+						 * supported by the rport */
+};
+
+#define bfa_rport_aen_qos_data_t struct bfa_rport_qos_attr_s
+
+/**
+ * BFA remote port events
+ * Arguments below are in BFAL context from Mgmt
+ * BFA_RPORT_AEN_ONLINE:    [in]: lpwwn	[out]: vf_id, lpwwn, rpwwn
+ * BFA_RPORT_AEN_OFFLINE:   [in]: lpwwn [out]: vf_id, lpwwn, rpwwn
+ * BFA_RPORT_AEN_DISCONNECT:[in]: lpwwn [out]: vf_id, lpwwn, rpwwn
+ * BFA_RPORT_AEN_QOS_PRIO:  [in]: lpwwn [out]: vf_id, lpwwn, rpwwn, prio
+ * BFA_RPORT_AEN_QOS_FLOWID:[in]: lpwwn [out]: vf_id, lpwwn, rpwwn, flow_id
+ */
+enum bfa_rport_aen_event {
+	BFA_RPORT_AEN_ONLINE = 1,	/*  RPort online event */
+	BFA_RPORT_AEN_OFFLINE = 2,	/*  RPort offline event */
+	BFA_RPORT_AEN_DISCONNECT = 3,	/*  RPort disconnect event */
+	BFA_RPORT_AEN_QOS_PRIO = 4,	/*  QOS priority change event */
+	BFA_RPORT_AEN_QOS_FLOWID = 5,	/*  QOS flow Id change event */
+};
+
+struct bfa_rport_aen_data_s {
+	u16 vf_id;		/*  vf_id of this logical port */
+	u16 rsvd[3];
+	wwn_t ppwwn;		/*  WWN of its physical port */
+	wwn_t lpwwn;		/*  WWN of this logical port */
+	wwn_t rpwwn;		/*  WWN of this remote port */
+	union {
+		bfa_rport_aen_qos_data_t qos;
+	} priv;
+};
+
+#endif /* __BFA_DEFS_RPORT_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_status.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_status.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_status.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_status.h	2009-08-28 21:09:26.885607000 -0700
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
+	BFA_STATUS_OK = 0,	/*  Success */
+	BFA_STATUS_FAILED = 1,	/*  Operation failed */
+	BFA_STATUS_EINVAL = 2,	/*  Invalid params Check input
+				 * parameters */
+	BFA_STATUS_ENOMEM = 3,	/*  Out of resources */
+	BFA_STATUS_ENOSYS = 4,	/*  Function not implemented */
+	BFA_STATUS_ETIMER = 5,	/*  Timer expired - Retry, if
+				 * persists, contact support */
+	BFA_STATUS_EPROTOCOL = 6,	/*  Protocol error */
+	BFA_STATUS_ENOFCPORTS = 7,	/*  No FC ports resources */
+	BFA_STATUS_NOFLASH = 8,	/*  Flash not present */
+	BFA_STATUS_BADFLASH = 9,	/*  Flash is corrupted or bad */
+	BFA_STATUS_SFP_UNSUPP = 10,	/*  Unsupported SFP - Replace SFP */
+	BFA_STATUS_UNKNOWN_VFID = 11,	/*  VF_ID not found */
+	BFA_STATUS_DATACORRUPTED = 12,	/*  Diag returned data corrupted
+					 * contact support */
+	BFA_STATUS_DEVBUSY = 13,	/*  Device busy - Retry operation */
+	BFA_STATUS_ABORTED = 14,	/*  Operation aborted */
+	BFA_STATUS_NODEV = 15,	/*  Dev is not present */
+	BFA_STATUS_HDMA_FAILED = 16,	/*  Host dma failed contact support */
+	BFA_STATUS_FLASH_BAD_LEN = 17,	/*  Flash bad length */
+	BFA_STATUS_UNKNOWN_LWWN = 18,	/*  LPORT PWWN not found */
+	BFA_STATUS_UNKNOWN_RWWN = 19,	/*  RPORT PWWN not found */
+	BFA_STATUS_FCPT_LS_RJT = 20,	/*  Got LS_RJT for FC Pass
+					 * through Req */
+	BFA_STATUS_VPORT_EXISTS = 21,	/*  VPORT already exists */
+	BFA_STATUS_VPORT_MAX = 22,	/*  Reached max VPORT supported
+					 * limit */
+	BFA_STATUS_UNSUPP_SPEED = 23,	/*  Invalid Speed Check speed
+					 * setting */
+	BFA_STATUS_INVLD_DFSZ = 24,	/*  Invalid Max data field size */
+	BFA_STATUS_CNFG_FAILED = 25,	/*  Setting can not be persisted */
+	BFA_STATUS_CMD_NOTSUPP = 26,	/*  Command/API not supported */
+	BFA_STATUS_NO_ADAPTER = 27,	/*  No Brocade Adapter Found */
+	BFA_STATUS_LINKDOWN = 28,	/*  Link is down - Check or replace
+					 * SFP/cable */
+	BFA_STATUS_FABRIC_RJT = 29,	/*  Reject from attached fabric */
+	BFA_STATUS_UNKNOWN_VWWN = 30,	/*  VPORT PWWN not found */
+	BFA_STATUS_NSLOGIN_FAILED = 31,	/*  Nameserver login failed */
+	BFA_STATUS_NO_RPORTS = 32,	/*  No remote ports found */
+	BFA_STATUS_NSQUERY_FAILED = 33,	/*  Nameserver query failed */
+	BFA_STATUS_PORT_OFFLINE = 34,	/*  Port is not online */
+	BFA_STATUS_RPORT_OFFLINE = 35,	/*  RPORT is not online */
+	BFA_STATUS_TGTOPEN_FAILED = 36,	/*  Remote SCSI target open failed */
+	BFA_STATUS_BAD_LUNS = 37,	/*  No valid LUNs found */
+	BFA_STATUS_IO_FAILURE = 38,	/*  SCSI target IO failure */
+	BFA_STATUS_NO_FABRIC = 39,	/*  No switched fabric present */
+	BFA_STATUS_EBADF = 40,	/*  Bad file descriptor */
+	BFA_STATUS_EINTR = 41,	/*  A signal was caught during ioctl */
+	BFA_STATUS_EIO = 42,	/*  I/O error */
+	BFA_STATUS_ENOTTY = 43,	/*  Inappropriate I/O control
+				 * operation */
+	BFA_STATUS_ENXIO = 44,	/*  No such device or address */
+	BFA_STATUS_EFOPEN = 45,	/*  Failed to open file */
+	BFA_STATUS_VPORT_WWN_BP = 46,	/*  WWN is same as base port's WWN */
+	BFA_STATUS_PORT_NOT_DISABLED = 47,	/*  Port not disabled disable port
+						 * first */
+	BFA_STATUS_BADFRMHDR = 48,	/*  Bad frame header */
+	BFA_STATUS_BADFRMSZ = 49,	/*  Bad frame size check and replace
+					 * SFP/cable */
+	BFA_STATUS_MISSINGFRM = 50,	/*  Missing frame check and replace
+					 * SFP/cable */
+	BFA_STATUS_LINKTIMEOUT = 51,	/*  Link timeout check and replace
+					 * SFP/cable */
+	BFA_STATUS_NO_FCPIM_NEXUS = 52,	/*  No FCP Nexus exists with the
+					 * rport */
+	BFA_STATUS_CHECKSUM_FAIL = 53,	/*  checksum failure */
+	BFA_STATUS_GZME_FAILED = 54,	/*  Get zone member query failed */
+	BFA_STATUS_SCSISTART_REQD = 55,	/*  SCSI disk require START command */
+	BFA_STATUS_IOC_FAILURE = 56,	/*  IOC failure - Retry, if persists
+					 * contact support */
+	BFA_STATUS_INVALID_WWN = 57,	/*  Invalid WWN */
+	BFA_STATUS_MISMATCH = 58,	/*  Version mismatch */
+	BFA_STATUS_IOC_ENABLED = 59,	/*  IOC is already enabled */
+	BFA_STATUS_ADAPTER_ENABLED = 60,	/*  Adapter is not disabled disable
+						 * adapter first */
+	BFA_STATUS_IOC_NON_OP = 61,	/*  IOC is not operational. Enable IOC
+					 * and if it still fails,
+					 * contact support */
+	BFA_STATUS_ADDR_MAP_FAILURE = 62,	/*  PCI base address not mapped
+						 * in OS */
+	BFA_STATUS_SAME_NAME = 63,	/*  Name exists! use a different
+					 * name */
+	BFA_STATUS_PENDING = 64,	/*  API completes asynchronously */
+	BFA_STATUS_8G_SPD = 65,	/*  Speed setting not valid for
+				 * 8G HBA */
+	BFA_STATUS_4G_SPD = 66,	/*  Speed setting not valid for
+				 * 4G HBA */
+	BFA_STATUS_AD_IS_ENABLE = 67,	/*  Adapter is already enabled */
+	BFA_STATUS_EINVAL_TOV = 68,	/*  Invalid path failover TOV */
+	BFA_STATUS_EINVAL_QDEPTH = 69,	/*  Invalid queue depth value */
+	BFA_STATUS_VERSION_FAIL = 70,	/*  Application/Driver version
+					 * mismatch */
+	BFA_STATUS_DIAG_BUSY = 71,	/*  diag busy */
+	BFA_STATUS_BEACON_ON = 72,	/*  Port Beacon already on */
+	BFA_STATUS_BEACON_OFF = 73,	/*  Port Beacon already off */
+	BFA_STATUS_LBEACON_ON = 74,	/*  Link End-to-End Beacon already
+					 * on */
+	BFA_STATUS_LBEACON_OFF = 75,	/*  Link End-to-End Beacon already
+					 * off */
+	BFA_STATUS_PORT_NOT_INITED = 76,	/*  Port not initialized */
+	BFA_STATUS_RPSC_ENABLED = 77,	/*  Target has a valid speed */
+	BFA_STATUS_ENOFSAVE = 78,	/*  No saved firmware trace */
+	BFA_STATUS_BAD_FILE = 79,	/*  Not a valid Brocade Boot Code
+					 * file */
+	BFA_STATUS_RLIM_EN = 80,	/*  Target rate limiting is already
+					 * enabled */
+	BFA_STATUS_RLIM_DIS = 81,	/*  Target rate limiting is already
+					 * disabled */
+	BFA_STATUS_IOC_DISABLED = 82,	/*  IOC is already disabled */
+	BFA_STATUS_ADAPTER_DISABLED = 83,	/*  Adapter is already disabled */
+	BFA_STATUS_BIOS_DISABLED = 84,	/*  Bios is already disabled */
+	BFA_STATUS_AUTH_ENABLED = 85,	/*  Authentication is already
+					 * enabled */
+	BFA_STATUS_AUTH_DISABLED = 86,	/*  Authentication is already
+					 * disabled */
+	BFA_STATUS_ERROR_TRL_ENABLED = 87,	/*  Target rate limiting is
+						 * enabled */
+	BFA_STATUS_ERROR_QOS_ENABLED = 88,	/*  QoS is enabled */
+	BFA_STATUS_NO_SFP_DEV = 89,	/*  No SFP device check or replace SFP */
+	BFA_STATUS_MEMTEST_FAILED = 90,	/*  Memory test failed contact
+					 * support */
+	BFA_STATUS_INVALID_DEVID = 91,	/*  Invalid device id provided */
+	BFA_STATUS_QOS_ENABLED = 92,	/*  QOS is already enabled */
+	BFA_STATUS_QOS_DISABLED = 93,	/*  QOS is already disabled */
+	BFA_STATUS_INCORRECT_DRV_CONFIG = 94,	/*  Check configuration
+						 * key/value pair */
+	BFA_STATUS_REG_FAIL = 95,	/*  Can't read windows registry */
+	BFA_STATUS_IM_INV_CODE = 96,	/*  Invalid IOCTL code */
+	BFA_STATUS_IM_INV_VLAN = 97,	/*  Invalid VLAN ID */
+	BFA_STATUS_IM_INV_ADAPT_NAME = 98,	/*  Invalid adapter name */
+	BFA_STATUS_IM_LOW_RESOURCES = 99,	/*  Memory allocation failure in
+						 * driver */
+	BFA_STATUS_IM_VLANID_IS_PVID = 100,	/*  Given VLAN id same as PVID */
+	BFA_STATUS_IM_VLANID_EXISTS = 101,	/*  Given VLAN id already exists */
+	BFA_STATUS_IM_FW_UPDATE_FAIL = 102,	/*  Updating firmware with new
+						 * VLAN ID failed */
+	BFA_STATUS_PORTLOG_ENABLED = 103,	/*  Port Log is already enabled */
+	BFA_STATUS_PORTLOG_DISABLED = 104,	/*  Port Log is already disabled */
+	BFA_STATUS_FILE_NOT_FOUND = 105,	/*  Specified file could not be
+						 * found */
+	BFA_STATUS_QOS_FC_ONLY = 106,	/*  QOS can be enabled for FC mode
+					 * only */
+	BFA_STATUS_RLIM_FC_ONLY = 107,	/*  RATELIM can be enabled for FC mode
+					 * only */
+	BFA_STATUS_CT_SPD = 108,	/*  Invalid speed selection for Catapult. */
+	BFA_STATUS_LEDTEST_OP = 109,	/*  LED test is operating */
+	BFA_STATUS_CEE_NOT_DN = 110,	/*  eth port is not at down state, please
+					 * bring down first */
+	BFA_STATUS_10G_SPD = 111,	/*  Speed setting not valid for 10G HBA */
+	BFA_STATUS_IM_INV_TEAM_NAME = 112,	/*  Invalid team name */
+	BFA_STATUS_IM_DUP_TEAM_NAME = 113,	/*  Given team name already
+						 * exists */
+	BFA_STATUS_IM_ADAPT_ALREADY_IN_TEAM = 114,	/*  Given adapter is part
+							 * of another team */
+	BFA_STATUS_IM_ADAPT_HAS_VLANS = 115,	/*  Adapter has VLANs configured.
+						 * Delete all VLANs before
+						 * creating team */
+	BFA_STATUS_IM_PVID_MISMATCH = 116,	/*  Mismatching PVIDs configured
+						 * for adapters */
+	BFA_STATUS_IM_LINK_SPEED_MISMATCH = 117,	/*  Mismatching link speeds
+							 * configured for adapters */
+	BFA_STATUS_IM_MTU_MISMATCH = 118,	/*  Mismatching MTUs configured for
+						 * adapters */
+	BFA_STATUS_IM_RSS_MISMATCH = 119,	/*  Mismatching RSS parameters
+						 * configured for adapters */
+	BFA_STATUS_IM_HDS_MISMATCH = 120,	/*  Mismatching HDS parameters
+						 * configured for adapters */
+	BFA_STATUS_IM_OFFLOAD_MISMATCH = 121,	/*  Mismatching offload
+						 * parameters configured for
+						 * adapters */
+	BFA_STATUS_IM_PORT_PARAMS = 122,	/*  Error setting port parameters */
+	BFA_STATUS_IM_PORT_NOT_IN_TEAM = 123,	/*  Port is not part of team */
+	BFA_STATUS_IM_CANNOT_REM_PRI = 124,	/*  Primary adapter cannot be
+						 * removed. Change primary before
+						 * removing */
+	BFA_STATUS_IM_MAX_PORTS_REACHED = 125,	/*  Exceeding maximum ports
+						 * per team */
+	BFA_STATUS_IM_LAST_PORT_DELETE = 126,	/*  Last port in team being
+						 * deleted */
+	BFA_STATUS_IM_NO_DRIVER = 127,	/*  IM driver is not installed */
+	BFA_STATUS_IM_MAX_VLANS_REACHED = 128,	/*  Exceeding maximum VLANs
+						 * per port */
+	BFA_STATUS_TOMCAT_SPD_NOT_ALLOWED = 129,	/* Bios speed config not
+							 * allowed for CNA */
+	BFA_STATUS_NO_MINPORT_DRIVER = 130,	/*  Miniport driver is not
+						 * loaded */
+	BFA_STATUS_CARD_TYPE_MISMATCH = 131,	/*  Card type mismatch */
+	BFA_STATUS_BAD_ASICBLK = 132,	/*  Bad ASIC block */
+	BFA_STATUS_NO_DRIVER = 133,	/*  Storage/Ethernet driver not loaded */
+	BFA_STATUS_INVALID_MAC = 134,	/*  Invalid mac address */
+	BFA_STATUS_IM_NO_VLAN = 135,	/*  No VLANs configured on the adapter */
+	BFA_STATUS_IM_ETH_LB_FAILED = 136,	/*  Ethernet loopback test failed */
+	BFA_STATUS_IM_PVID_REMOVE = 137,	/*  Cannot remove port vlan (PVID) */
+	BFA_STATUS_IM_PVID_EDIT = 138,	/*  Cannot edit port vlan (PVID) */
+	BFA_STATUS_CNA_NO_BOOT = 139,	/*  Boot upload not allowed for CNA */
+	BFA_STATUS_IM_PVID_NON_ZERO = 140,	/*  Port VLAN ID (PVID) is Set to
+						 * Non-Zero Value */
+	BFA_STATUS_IM_INETCFG_LOCK_FAILED = 141,	/*  Acquiring Network
+							 * Subsytem Lock Failed.Please
+							 * try after some time */
+	BFA_STATUS_IM_GET_INETCFG_FAILED = 142,	/*  Acquiring Network Subsytem
+						 * handle Failed. Please try
+						 * after some time */
+	BFA_STATUS_IM_NOT_BOUND = 143,	/*  Brocade 10G Ethernet Service is not
+					 * Enabled on this port */
+	BFA_STATUS_INSUFFICIENT_PERMS = 144,	/*  User doesn't have sufficient
+						 * permissions to execute the BCU
+						 * application */
+	BFA_STATUS_IM_INV_VLAN_NAME = 145,	/*  Invalid/Reserved Vlan name
+						 * string. The name is not allowed
+						 * for the normal Vlans */
+	BFA_STATUS_CMD_NOTSUPP_CNA = 146,	/*  Command not supported for CNA */
+	BFA_STATUS_IM_PASSTHRU_EDIT = 147,	/*  Can not edit passthru vlan id */
+	BFA_STATUS_IM_BIND_FAILED = 148,	/*! < IM Driver bind operation
+						 * failed */
+	BFA_STATUS_IM_UNBIND_FAILED = 149,	/* ! < IM Driver unbind operation
+						 * failed */
+	BFA_STATUS_MAX_VAL	/*  Unknown error code */
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
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_tin.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_tin.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_tin.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_tin.h	2009-08-28 21:09:26.921606000 -0700
@@ -0,0 +1,125 @@
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
+#ifndef __BFA_DEFS_TIN_H__
+#define __BFA_DEFS_TIN_H__
+
+#include <protocol/types.h>
+#include <protocol/fc.h>
+
+/**
+ * FCS tin states
+ */
+enum bfa_tin_state_e {
+	BFA_TIN_SM_OFFLINE = 0,	/*  tin is offline */
+	BFA_TIN_SM_WOS_LOGIN = 1,	/*  Waiting PRLI ACC/RJT from ULP */
+	BFA_TIN_SM_WFW_ONLINE = 2,	/*  Waiting ACK to PRLI ACC from FW */
+	BFA_TIN_SM_ONLINE = 3,	/*  tin login is complete */
+	BFA_TIN_SM_WIO_RELOGIN = 4,	/*  tin relogin is in progress */
+	BFA_TIN_SM_WIO_LOGOUT = 5,	/*  Processing of PRLO req from
+					 *   Initiator is in progress
+					 */
+	BFA_TIN_SM_WOS_LOGOUT = 6,	/*  Processing of PRLO req from
+					 *   Initiator is in progress
+					 */
+	BFA_TIN_SM_WIO_CLEAN = 7,	/*  Waiting for IO cleanup before tin
+					 *   is offline. This can be triggered
+					 *   by RPORT LOGO (rcvd/sent) or by
+					 *   PRLO (rcvd/sent)
+					 */
+};
+
+struct bfa_prli_req_s {
+	struct fchs_s fchs;
+	struct fc_prli_s prli_payload;
+};
+
+struct bfa_prlo_req_s {
+	struct fchs_s fchs;
+	struct fc_prlo_s prlo_payload;
+};
+
+void bfa_tin_send_login_rsp(void *bfa_tin, u32 login_rsp,
+			    struct fc_ls_rjt_s rjt_payload);
+void bfa_tin_send_logout_rsp(void *bfa_tin, u32 logout_rsp,
+			     struct fc_ls_rjt_s rjt_payload);
+/**
+ * FCS target port statistics
+ */
+struct bfa_tin_stats_s {
+	u32 onlines;		/*  ITN nexus onlines (PRLI done) */
+	u32 offlines;		/*  ITN Nexus offlines  */
+	u32 prli_req_parse_err;	/*  prli req parsing errors */
+	u32 prli_rsp_rjt;	/*  num prli rsp rejects sent */
+	u32 prli_rsp_acc;	/*  num prli rsp accepts sent */
+	u32 cleanup_comps;	/*  ITN cleanup completions */
+};
+
+/**
+ * FCS tin attributes returned in queries
+ */
+struct bfa_tin_attr_s {
+	enum bfa_tin_state_e state;
+	u8 seq_retry;		/*  Sequence retry supported      */
+	u8 rsvd[3];
+};
+
+/**
+ * BFA TIN async event data structure for BFAL
+ */
+enum bfa_tin_aen_event {
+	BFA_TIN_AEN_ONLINE = 1,	/*  Target online */
+	BFA_TIN_AEN_OFFLINE = 2,	/*  Target offline */
+	BFA_TIN_AEN_DISCONNECT = 3,	/*  Target disconnected */
+};
+
+/**
+ * BFA TIN event data structure.
+ */
+struct bfa_tin_aen_data_s {
+	u16 vf_id;		/*  vf_id of the IT nexus */
+	u16 rsvd[3];
+	wwn_t lpwwn;		/*  WWN of logical port */
+	wwn_t rpwwn;		/*  WWN of remote(target) port */
+};
+
+/**
+ * Below APIs are needed from BFA driver
+ * Move these to BFA driver public header file?
+ */
+/*  TIN rcvd new PRLI & gets bfad_tin_t ptr from driver this callback */
+void *bfad_tin_rcvd_login_req(void *bfad_tm_port, void *bfa_tin,
+			      wwn_t rp_wwn, u32 rp_fcid,
+			      struct bfa_prli_req_s prli_req);
+/*  TIN rcvd new PRLO */
+void bfad_tin_rcvd_logout_req(void *bfad_tin, wwn_t rp_wwn, u32 rp_fcid,
+			      struct bfa_prlo_req_s prlo_req);
+/*  TIN is online and ready for IO */
+void bfad_tin_online(void *bfad_tin);
+/*  TIN is offline and BFA driver can shutdown its upper stack */
+void bfad_tin_offline(void *bfad_tin);
+/*  TIN does not need this BFA driver tin tag anymore, so can be freed */
+void bfad_tin_res_free(void *bfad_tin);
+
+#endif /* __BFA_DEFS_TIN_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_tsensor.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_tsensor.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_tsensor.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_tsensor.h	2009-08-28 21:09:27.325609000 -0700
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
+#ifndef __BFA_DEFS_TSENSOR_H__
+#define __BFA_DEFS_TSENSOR_H__
+
+#include <bfa_os_inc.h>
+#include <defs/bfa_defs_types.h>
+
+/**
+ * Temperature sensor status values
+ */
+enum bfa_tsensor_status {
+	BFA_TSENSOR_STATUS_UNKNOWN = 1,	/*  unkown status */
+	BFA_TSENSOR_STATUS_FAULTY = 2,	/*  sensor is faulty */
+	BFA_TSENSOR_STATUS_BELOW_MIN = 3,	/*  temperature below mininum */
+	BFA_TSENSOR_STATUS_NOMINAL = 4,	/*  normal temperature */
+	BFA_TSENSOR_STATUS_ABOVE_MAX = 5,	/*  temperature above maximum */
+};
+
+/**
+ * Temperature sensor attribute
+ */
+struct bfa_tsensor_attr_s {
+	enum bfa_tsensor_status status;	/*  temperature sensor status */
+	u32 value;		/*  current temperature in celsius */
+};
+
+#endif /* __BFA_DEFS_TSENSOR_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_types.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_types.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_types.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_types.h	2009-08-28 21:09:27.219612000 -0700
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
+	BFA_TRUE = 1
+};
+#define bfa_boolean_t enum bfa_boolean
+
+#define BFA_STRING_32	32
+
+#endif /* __BFA_DEFS_TYPES_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_version.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_version.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_version.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_version.h	2009-08-28 21:09:27.250611000 -0700
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
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_vf.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_vf.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_vf.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_vf.h	2009-08-28 21:09:27.265609000 -0700
@@ -0,0 +1,81 @@
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
+#ifndef __BFA_DEFS_VF_H__
+#define __BFA_DEFS_VF_H__
+
+#include <bfa_os_inc.h>
+#include <defs/bfa_defs_port.h>
+#include <protocol/types.h>
+
+/**
+ * VF states
+ */
+enum bfa_vf_state {
+	BFA_VF_UNINIT = 0,	/*  fabric is not yet initialized */
+	BFA_VF_LINK_DOWN = 1,	/*  link is down */
+	BFA_VF_FLOGI = 2,	/*  flogi is in progress */
+	BFA_VF_AUTH = 3,	/*  authentication in progress */
+	BFA_VF_NOFABRIC = 4,	/*  fabric is not present */
+	BFA_VF_ONLINE = 5,	/*  login to fabric is complete */
+	BFA_VF_EVFP = 6,	/*  EVFP is in progress */
+	BFA_VF_ISOLATED = 7,	/*  port isolated due to vf_id mismatch */
+};
+
+/**
+ * VF statistics
+ */
+struct bfa_vf_stats_s {
+	u32 flogi_sent;		/*  Num FLOGIs sent             */
+	u32 flogi_rsp_err;	/*  FLOGI response errors       */
+	u32 flogi_acc_err;	/*  FLOGI accept errors         */
+	u32 flogi_accepts;	/*  FLOGI accepts received      */
+	u32 flogi_rejects;	/*  FLOGI rejects received      */
+	u32 flogi_unknown_rsp;	/*  Unknown responses for FLOGI */
+	u32 flogi_alloc_wait;	/*  Allocation waits prior to
+				 * sending FLOGI
+				 */
+	u32 flogi_rcvd;		/*  FLOGIs received */
+	u32 flogi_rejected;	/*  Incoming FLOGIs rejected */
+	u32 fabric_onlines;	/*  Internal fabric online
+				 * notification sent to other
+				 * modules
+				 */
+	u32 fabric_offlines;	/*  Internal fabric offline
+				 * notification sent to other
+				 * modules
+				 */
+	u32 resvd;
+};
+
+/**
+ * VF attributes returned in queries
+ */
+struct bfa_vf_attr_s {
+	enum bfa_vf_state state;	/*  VF state */
+	u32 rsvd;
+	wwn_t fabric_name;	/*  fabric name */
+};
+
+#endif /* __BFA_DEFS_VF_H__ */
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_vport.h linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_vport.h
--- linux-2.6.30.5-orig/drivers/net/bna/include/defs/bfa_defs_vport.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/include/defs/bfa_defs_vport.h	2009-08-28 21:09:27.164607000 -0700
@@ -0,0 +1,98 @@
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
+#ifndef __BFA_DEFS_VPORT_H__
+#define __BFA_DEFS_VPORT_H__
+
+#include <bfa_os_inc.h>
+#include <defs/bfa_defs_port.h>
+#include <protocol/types.h>
+
+/**
+ * VPORT states
+ */
+enum bfa_vport_state {
+	BFA_FCS_VPORT_UNINIT = 0,
+	BFA_FCS_VPORT_CREATED = 1,
+	BFA_FCS_VPORT_OFFLINE = 1,
+	BFA_FCS_VPORT_FDISC_SEND = 2,
+	BFA_FCS_VPORT_FDISC = 3,
+	BFA_FCS_VPORT_FDISC_RETRY = 4,
+	BFA_FCS_VPORT_ONLINE = 5,
+	BFA_FCS_VPORT_DELETING = 6,
+	BFA_FCS_VPORT_CLEANUP = 6,
+	BFA_FCS_VPORT_LOGO_SEND = 7,
+	BFA_FCS_VPORT_LOGO = 8,
+	BFA_FCS_VPORT_ERROR = 9,
+	BFA_FCS_VPORT_MAX_STATE,
+};
+
+/**
+ * vport statistics
+ */
+struct bfa_vport_stats_s {
+	struct bfa_port_stats_s port_stats;	/*  base class (port) stats */
+	/*
+	 * TODO - remove
+	 */
+
+	u32 fdisc_sent;		/*  num fdisc sent */
+	u32 fdisc_accepts;	/*  fdisc accepts */
+	u32 fdisc_retries;	/*  fdisc retries */
+	u32 fdisc_timeouts;	/*  fdisc timeouts */
+	u32 fdisc_rsp_err;	/*  fdisc response error */
+	u32 fdisc_acc_bad;	/*  bad fdisc accepts */
+	u32 fdisc_rejects;	/*  fdisc rejects */
+	u32 fdisc_unknown_rsp;
+	/*
+	 *!< fdisc rsp unknown error
+	 */
+	u32 fdisc_alloc_wait;	/*  fdisc req (fcxp)alloc wait */
+
+	u32 logo_alloc_wait;	/*  logo req (fcxp) alloc wait */
+	u32 logo_sent;		/*  logo sent */
+	u32 logo_accepts;	/*  logo accepts */
+	u32 logo_rejects;	/*  logo rejects */
+	u32 logo_rsp_err;	/*  logo rsp errors */
+	u32 logo_unknown_rsp;
+	/*  logo rsp unknown errors */
+
+	u32 fab_no_npiv;	/*  fabric does not support npiv */
+
+	u32 fab_offline;	/*  offline events from fab SM */
+	u32 fab_online;		/*  online events from fab SM */
+	u32 fab_cleanup;	/*  cleanup request from fab SM */
+	u32 rsvd;
+};
+
+/**
+ * BFA vport attribute returned in queries
+ */
+struct bfa_vport_attr_s {
+	struct bfa_port_attr_s port_attr;	/*  base class (port) attributes */
+	enum bfa_vport_state vport_state;	/*  vport state */
+	u32 rsvd;
+};
+
+#endif /* __BFA_DEFS_VPORT_H__ */
