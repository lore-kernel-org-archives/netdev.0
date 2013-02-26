From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 01/27] rtlwifi: Modify the master header for for updates to vendor version 2013.02.07
Date: Mon, 25 Feb 2013 18:13:13 -0600
Message-ID: <1361837619-2985-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:39454 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759155Ab3BZAOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:03 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes add the new variables for P2P and modify the various struct
definitions for other new features.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
---
 drivers/net/wireless/rtlwifi/wifi.h | 80 ++++++++++++++++++++++++++++++++++++-
 1 file changed, 79 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index f13258a..9536963 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -278,7 +278,10 @@ enum hw_variables {
 	HW_VAR_SET_RPWM,
 	HW_VAR_H2C_FW_PWRMODE,
 	HW_VAR_H2C_FW_JOINBSSRPT,
+	HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
 	HW_VAR_FW_PSMODE_STATUS,
+	HW_VAR_RESUME_CLK_ON,
+	HW_VAR_FW_LPS_ACTION,
 	HW_VAR_1X1_RECV_COMBINE,
 	HW_VAR_STOP_SEND_BEACON,
 	HW_VAR_TSF_TIMER,
@@ -461,6 +464,7 @@ enum rtl_var_map {
 	EFUSE_MAX_SECTION_MAP,
 	EFUSE_REAL_CONTENT_SIZE,
 	EFUSE_OOB_PROTECT_BYTES_LEN,
+	EFUSE_ACCESS,
 
 	/*CAM map */
 	RWCAM,
@@ -826,7 +830,64 @@ struct rtl_rfkill {
 	bool rfkill_state;	/*0 is off, 1 is on */
 };
 
-#define IQK_MATRIX_REG_NUM	8
+/*for P2P PS**/
+#define	P2P_MAX_NOA_NUM		2
+
+enum p2p_role {
+	P2P_ROLE_DISABLE = 0,
+	P2P_ROLE_DEVICE = 1,
+	P2P_ROLE_CLIENT = 2,
+	P2P_ROLE_GO = 3
+};
+
+enum p2p_ps_state {
+	P2P_PS_DISABLE = 0,
+	P2P_PS_ENABLE = 1,
+	P2P_PS_SCAN = 2,
+	P2P_PS_SCAN_DONE = 3,
+	P2P_PS_ALLSTASLEEP = 4, /* for P2P GO */
+};
+
+enum p2p_ps_mode {
+	P2P_PS_NONE = 0,
+	P2P_PS_CTWINDOW = 1,
+	P2P_PS_NOA	 = 2,
+	P2P_PS_MIX = 3, /* CTWindow and NoA */
+};
+
+struct rtl_p2p_ps_info {
+	enum p2p_ps_mode p2p_ps_mode; /* indicate p2p ps mode */
+	enum p2p_ps_state p2p_ps_state; /*  indicate p2p ps state */
+	u8 noa_index; /*  Identifies instance of Notice of Absence timing. */
+	/*  Client traffic window. A period of time in TU after TBTT. */
+	u8 ctwindow;
+	u8 opp_ps; /*  opportunistic power save. */
+	u8 noa_num; /*  number of NoA descriptor in P2P IE. */
+	/*  Count for owner, Type of client. */
+	u8 noa_count_type[P2P_MAX_NOA_NUM];
+	/*  Max duration for owner, preferred or min acceptable duration
+	 * for client.
+	 */
+	u32 noa_duration[P2P_MAX_NOA_NUM];
+	/*  Length of interval for owner, preferred or max acceptable intervali
+	 * of client.
+	 */
+	u32 noa_interval[P2P_MAX_NOA_NUM];
+	/*  schedule in terms of the lower 4 bytes of the TSF timer. */
+	u32 noa_start_time[P2P_MAX_NOA_NUM];
+};
+
+struct p2p_ps_offload_t {
+	u8 offload_en:1;
+	u8 role:1; /* 1: Owner, 0: Client */
+	u8 ctwindow_en:1;
+	u8 noa0_en:1;
+	u8 noa1_en:1;
+	u8 allstasleep:1;
+	u8 discovery:1;
+	u8 reserved:1;
+};
+ #define IQK_MATRIX_REG_NUM	8
 #define IQK_MATRIX_SETTINGS_NUM	(1 + 24 + 21)
 struct iqk_matrix_regs {
 	bool iqk_done;
@@ -954,6 +1015,7 @@ struct rtl_sta_info {
 	u8 ratr_index;
 	u8 wireless_mode;
 	u8 mimo_ps;
+	u8 mac_addr[ETH_ALEN];
 	struct rtl_tid_data tids[MAX_TID_COUNT];
 
 	/* just used for ap adhoc or mesh*/
@@ -1005,6 +1067,8 @@ struct rtl_mac {
 	int n_bitrates;
 
 	bool offchan_delay;
+	u8 p2p;	/*using p2p role*/
+	bool p2p_in_use;
 
 	/*filters */
 	u32 rx_conf;
@@ -1014,6 +1078,7 @@ struct rtl_mac {
 
 	bool act_scanning;
 	u8 cnt_after_linked;
+	bool skip_scan;
 
 	/* early mode */
 	/* skb wait queue */
@@ -1341,6 +1406,7 @@ struct rtl_ps_ctl {
 	bool fw_current_inpsmode;
 	u8 reg_max_lps_awakeintvl;
 	bool report_linked;
+	bool low_power_enable;/*for 32k*/
 
 	/*for IPS */
 	bool inactiveps;
@@ -1373,6 +1439,11 @@ struct rtl_ps_ctl {
 	unsigned long last_beacon;
 	unsigned long last_action;
 	unsigned long last_slept;
+
+	/*For P2P PS */
+	struct rtl_p2p_ps_info p2p_ps_info;
+	u8 pwr_mode;
+	u8 smart_ps;
 };
 
 struct rtl_stats {
@@ -1670,6 +1741,9 @@ struct rtl_locks {
 	spinlock_t entry_list_lock;
 	spinlock_t usb_lock;
 
+	/*FW clock change */
+	spinlock_t fw_ps_lock;
+
 	/*Dual mac*/
 	spinlock_t cck_and_rw_pagea_lock;
 
@@ -1683,6 +1757,8 @@ struct rtl_works {
 	/*timer */
 	struct timer_list watchdog_timer;
 	struct timer_list dualmac_easyconcurrent_retrytimer;
+	struct timer_list fw_clockoff_timer;
+	struct timer_list fast_antenna_training_timer;
 
 	/*task */
 	struct tasklet_struct irq_tasklet;
@@ -1696,6 +1772,7 @@ struct rtl_works {
 	/* For SW LPS */
 	struct delayed_work ps_work;
 	struct delayed_work ps_rfon_wq;
+	struct delayed_work fwevt_wq;
 
 	struct work_struct lps_leave_work;
 };
@@ -1802,6 +1879,7 @@ struct rtl_global_var {
 };
 
 struct rtl_priv {
+	struct ieee80211_hw *hw;
 	struct completion firmware_loading_complete;
 	struct list_head list;
 	struct rtl_priv *buddy_priv;
-- 
1.8.1.4
