From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 5/6] rtlwifi: btcoexist: Add routines for RTL8812AE - all configs
Date: Fri, 23 Jan 2015 11:10:43 -0600
Message-ID: <1422033044-7461-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1422033044-7461-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, Troy Tan <troy_tan@realsil.com.cn>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:61498 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756305AbbAWRLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 12:11:02 -0500
In-Reply-To: <1422033044-7461-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Tan <troy_tan@realsil.com.cn>

This patch adds the routines used for all antenna configurations.

Signed-off-by: Troy Tan <troy_tan@realsil.com.cn>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 .../wireless/rtlwifi/btcoexist/halbtc8812a_ext.c   | 921 +++++++++++++++++++++
 .../wireless/rtlwifi/btcoexist/halbtc8812a_ext.h   | 359 ++++++++
 2 files changed, 1280 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a_ext.c
 create mode 100644 drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a_ext.h

diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a_ext.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a_ext.c
new file mode 100644
index 0000000..4a324b4
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a_ext.c
@@ -0,0 +1,921 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2012  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#include "halbt_precomp.h"
+#include "halbtc8812a_ext.h"
+
+/*global for socket TRX, it is actually rtlpriv*/
+static struct rtl_priv *pbtcoexadapter;
+
+static void *safe_memcpy(void *dest, const void *src, u32 n, u32 max_len)
+{
+	if (n > max_len) {
+		memcpy(dest, src, max_len);
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+			  "critical error in memcpy!\n");
+	} else {
+		/*ok case*/
+		memcpy(dest, src, n);
+	}
+	return NULL;
+}
+
+static void btinfo_evt_dump(struct btinfo_8761au *info)
+{
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "cid:0x%02x, len:%u\n", info->cid, info->len);
+
+	if (info->len > 2)
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "byte2:%s%s%s%s%s%s%s%s\n",
+			  info->connection ? "connection " : "",
+			  info->scoe_sco ? "scoe_sco " : "",
+			  info->inq_page ? "inq_page " : "",
+			  info->acl_busy ? "acl_busy " : "",
+			  info->sco_busy ? "sco_busy " : "",
+			  info->hid ? "hid " : "",
+			  info->a2dp ? "a2dp " : "",
+			  info->ftp ? "ftp" : "");
+
+	if (info->len > 3)
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "retry_cnt:%u\n", info->retry_cnt);
+
+	if (info->len > 4)
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL, "rssi:%u\n",
+			  info->rssi);
+
+	if (info->len > 5)
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL, "byte5:%s%s\n",
+			  info->esco_sco ? "eSCO_SCO " : "",
+			  info->master_slave ? "Master_Slave " : "");
+}
+
+static void rtl_btcoex_btinfo_cmd(struct rtl_priv *rtlpriv, u8 *buf,
+				  u16 buf_len)
+{
+	struct btinfo_8761au *info = (struct btinfo_8761au *)buf;
+	u8 cmd_idx;
+	u8 len;
+
+	cmd_idx = info->cid;
+
+	if (info->len > buf_len-2) {
+		WARN_ON(1);
+		len = buf_len-2;
+	} else {
+		len = info->len;
+	}
+
+	btinfo_evt_dump(info);
+
+	/* transform BT-FW btinfo to WiFI-FW C2H format and notify */
+	if (cmd_idx == BTINFO_WIFI_FETCH) {
+		buf[1] = 0;
+	} else if (cmd_idx == BTINFO_BT_AUTO_RPT) {
+		buf[1] = 2;
+	} else if (0x01 == cmd_idx || 0x02 == cmd_idx) {
+		/* troy, it should run here */
+		buf[1] = buf[0];
+	}
+
+	rtlpriv->btcoexist.btc_ops->btc_btinfo_notify(rtlpriv, &buf[1], len+1);
+}
+
+static u8 rtl_send_comp_ev_to_bt(struct rtl_priv *rtlpriv,
+				 enum HCI_EXTENSION_COMMANDS BT_RELATED_CMD,
+				 enum HCI_STATUS status)
+{
+	struct rtl_hci_event *hci_event;
+	u8 local_buf[6] = "";
+	u8 len = 0, tx_event_length = 0;
+	u8 *ret_par;
+	u8 *event_data = NULL;
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "#LEVEL_END, rtl_send_comp_ev_to_bt\n");
+
+	hci_event = (struct rtl_hci_event *)(&local_buf[0]);
+	event_data = hci_event->data;
+	hci_event->event_code = HCI_EVENT_COMMAND_COMPLETE;
+	*event_data = 0x1;
+	*(event_data + 1) = HCIOPCODELOW(BT_RELATED_CMD, OGF_EXTENSION);
+	*(event_data + 2) = HCIOPCODEHIGHT(BT_RELATED_CMD, OGF_EXTENSION);
+
+	len = len + 3;
+	ret_par = &hci_event->data[len];
+	ret_par[0] = status;
+	len++;
+	hci_event->length = len;
+	/* total tx event length + event_code length + sizeof(length) */
+	tx_event_length = hci_event->length + 2;
+	rtl_btcoex_dump_tx_msg((u8 *)hci_event, tx_event_length,
+			       "rtl_send_comp_ev_to_bt");
+	status = rtl_btcoex_sendmsgbysocket(rtlpriv, (u8 *)hci_event,
+					    tx_event_length, false);
+	return status;
+}
+
+static u8 rtl_btcoex_parse_BT_info_notify_cmd(struct rtl_priv *rtlpriv,
+					      u8 *pcmd, u16 cmdlen)
+{
+	u8 curpollenable = pcmd[0];
+	u8 curpolltime = pcmd[1];
+	u8 btinforeason = pcmd[2];
+	u8 btinfolen = pcmd[3];
+	u8 btinfo[BT_INFO_LENGTH];
+	enum HCI_STATUS status = HCI_STATUS_SUCCESS;
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL, "%s\n", __func__);
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "current Poll Enable: %d, currrent Poll Time: %d\n",
+		  curpollenable, curpolltime);
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "BT Info reason: %d, BT Info length: %d\n",
+		  btinforeason, btinfolen);
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x\n",
+		  pcmd[4], pcmd[5], pcmd[6], pcmd[7], pcmd[8],
+		  pcmd[9], pcmd[10], pcmd[11]);
+
+	memset(btinfo, 0, BT_INFO_LENGTH);
+
+	if (BT_INFO_LENGTH != btinfolen) {
+		status = HCI_STATUS_INVALID_HCI_CMD_PARA_VALUE;
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+			  "Error BT Info Length: %d\n", btinfolen);
+	} else {
+		if (0x1 == btinforeason || 0x2 == btinforeason) {
+			safe_memcpy(btinfo, &pcmd[4], btinfolen,
+				    BT_INFO_LENGTH);
+			btinfo[0] = btinforeason;
+			rtl_btcoex_btinfo_cmd(rtlpriv, btinfo, btinfolen);
+		} else {
+			BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+				  "Other BT info reason\n");
+		}
+	}
+
+	return rtl_send_comp_ev_to_bt(rtlpriv, HCI_BT_INFO_NOTIFY, status);
+}
+
+static u8 rtl_btcoex_parse_BT_patch_ver_info_cmd(struct rtl_priv *rtlpriv,
+						 u8 *pcmd, u16 cmdlen)
+{
+	enum HCI_STATUS status = HCI_STATUS_SUCCESS;
+	u16		btpatchver = 0x0, bthciver = 0x0;
+
+	bthciver = pcmd[0] | pcmd[1]<<8;
+	btpatchver = pcmd[2] | pcmd[3]<<8;
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "%s, cmd:%02x %02x %02x %02x\n",
+		  __func__, pcmd[0], pcmd[1], pcmd[2], pcmd[3]);
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "%s, HCI Ver:%d, Patch Ver:%d\n",
+		  __func__, bthciver, btpatchver);
+	rtlpriv->btcoexist.btc_ops->btc_set_bt_patch_version(bthciver,
+							     btpatchver);
+
+	return rtl_send_comp_ev_to_bt(rtlpriv, HCI_BT_PATCH_VERSION_NOTIFY,
+				      status);
+}
+
+static u8 rtl_btcoex_parse_HCI_Ver_notify_cmd(struct rtl_priv *rtlpriv,
+					      u8 *pcmd, u16 cmdlen)
+{
+	enum HCI_STATUS status = HCI_STATUS_SUCCESS;
+	u16 hciver = pcmd[0] | pcmd[1] << 8;
+	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
+	struct bt_mgnt *bt_mgnt = &pcoex_info->btmgnt;
+
+	bt_mgnt->ext_config.hci_ext_ver = hciver;
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL, "%s, HCI Version: %d\n",
+		  __func__, bt_mgnt->ext_config.hci_ext_ver);
+	if (bt_mgnt->ext_config.hci_ext_ver  < 4) {
+		status = HCI_STATUS_INVALID_HCI_CMD_PARA_VALUE;
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "%s, Version = %d, HCI Version must be < 4\n",
+			  __func__, bt_mgnt->ext_config.hci_ext_ver);
+
+	} else {
+		rtlpriv->btcoexist.btc_ops->btc_set_hci_version(hciver);
+	}
+
+	return rtl_send_comp_ev_to_bt(rtlpriv, HCI_EXTENSION_VERSION_NOTIFY,
+				      status);
+}
+
+static u8 rtl_btcoex_parse_WIFI_scan_notify_cmd(struct rtl_priv *rtlpriv,
+						u8 *pcmd, u16 cmdlen)
+{
+	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
+	struct bt_mgnt *bt_mgnt = &pcoex_info->btmgnt;
+	enum HCI_STATUS status = HCI_STATUS_SUCCESS;
+
+	bt_mgnt->ext_config.enable_wifi_scan_notify = pcmd[0];
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "%s, enable_wifi_scan_notify: %d\n", __func__,
+		  bt_mgnt->ext_config.enable_wifi_scan_notify);
+
+	return rtl_send_comp_ev_to_bt(rtlpriv, HCI_ENABLE_WIFI_SCAN_NOTIFY,
+				      status);
+}
+
+static u8 rtl_btcoex_parse_HCI_link_status_notify_cmd(struct rtl_priv *rtlpriv,
+						      u8 *pcmd, u16 cmdlen)
+{
+	enum HCI_STATUS	status = HCI_STATUS_SUCCESS;
+	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
+	struct bt_mgnt *bt_mgnt = &pcoex_info->btmgnt;
+	u8 i, num_of_handle = 0;
+	u16		connect_handle;
+	u8 bt_profile, bt_corespec, link_role;
+	u8 *ptriple;
+
+	bt_mgnt->support_profile = false;
+
+	bt_mgnt->ext_config.number_of_acl = 0;
+	bt_mgnt->ext_config.number_of_sco = 0;
+
+	num_of_handle = pcmd[0];
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL, "num_of_handle = 0x%x\n",
+		  num_of_handle);
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL, "hci_extension_ver = %d\n",
+		  bt_mgnt->ext_config.hci_ext_ver);
+
+	ptriple = &pcmd[1];
+	for (i = 0; i < num_of_handle; i++) {
+		if (bt_mgnt->ext_config.hci_ext_ver < 1) {
+			connect_handle = *((u8 *)&ptriple[0]);
+			bt_profile = ptriple[2];
+			bt_corespec = ptriple[3];
+			if (BT_PROFILE_SCO == bt_profile) {
+				bt_mgnt->ext_config.number_of_sco++;
+			} else {
+				bt_mgnt->ext_config.number_of_acl++;
+				bt_mgnt->ext_config.acl_link[i].connect_handle =
+					connect_handle;
+				bt_mgnt->ext_config.acl_link[i].bt_profile =
+					bt_profile;
+				bt_mgnt->ext_config.acl_link[i].bt_corespec =
+					bt_corespec;
+			}
+			BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+				  "Connection_Handle =0x%x, bt_profile =%d, BTSpec =%d\n",
+				  connect_handle, bt_profile, bt_corespec);
+			ptriple += 4;
+		} else if (bt_mgnt->ext_config.hci_ext_ver >= 1) {
+			connect_handle = *((u16 *)&ptriple[0]);
+			bt_profile = ptriple[2];
+			bt_corespec = ptriple[3];
+			link_role = ptriple[4];
+			if (BT_PROFILE_SCO == bt_profile) {
+				bt_mgnt->ext_config.number_of_sco++;
+			} else {
+				bt_mgnt->ext_config.number_of_acl++;
+				bt_mgnt->ext_config.acl_link[i].connect_handle =
+					connect_handle;
+				bt_mgnt->ext_config.acl_link[i].bt_profile =
+					bt_profile;
+				bt_mgnt->ext_config.acl_link[i].bt_corespec =
+					bt_corespec;
+				bt_mgnt->ext_config.acl_link[i].link_role =
+					link_role;
+			}
+			BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+				  "Connection_Handle =0x%x, bt_profile =%d, BTSpec =%d, link_role =%d\n",
+				  connect_handle, bt_profile, bt_corespec,
+				  link_role);
+
+			ptriple += 5;
+		}
+	}
+	rtlpriv->btcoexist.btc_ops->btc_stack_update_profile_info();
+	return rtl_send_comp_ev_to_bt(rtlpriv, HCI_LINK_STATUS_NOTIFY, status);
+}
+
+static u8 rtl_btcoex_parse_HCI_BT_coex_notify_cmd(struct rtl_priv *rtlpriv,
+						  u8 *pcmd, u16 cmdlen)
+{
+	enum HCI_STATUS	status = HCI_STATUS_SUCCESS;
+
+	return rtl_send_comp_ev_to_bt(rtlpriv, HCI_BT_COEX_NOTIFY, status);
+}
+
+static u8 rtl_btcoex_parse_HCI_BT_operation_notify_cmd(struct rtl_priv *rtlpriv,
+						       u8 *pcmd, u16 cmdlen)
+{
+	enum HCI_STATUS	status = HCI_STATUS_SUCCESS;
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "%s, OP code: %d\n", __func__, pcmd[0]);
+
+	switch (pcmd[0]) {
+	case HCI_BT_OP_NONE:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "[bt operation] : Operation None!!\n");
+		break;
+	case HCI_BT_OP_INQUIRY_START:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "[bt operation] : Inquiry start!!\n");
+		break;
+	case HCI_BT_OP_INQUIRY_FINISH:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "[bt operation] : Inquiry finished!!\n");
+		break;
+	case HCI_BT_OP_PAGING_START:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "[bt operation] : Paging is started!!\n");
+		break;
+	case HCI_BT_OP_PAGING_SUCCESS:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "[bt operation] : Paging complete successfully!!\n");
+		break;
+	case HCI_BT_OP_PAGING_UNSUCCESS:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "[bt operation] : Paging complete unsuccessfully!!\n");
+		break;
+	case HCI_BT_OP_PAIRING_START:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "[bt operation] : Pairing start!!\n");
+		break;
+	case HCI_BT_OP_PAIRING_FINISH:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "[bt operation] : Pairing finished!!\n");
+		break;
+	case HCI_BT_OP_BT_DEV_ENABLE:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "[bt operation] : BT Device is enabled!!\n");
+		break;
+	case HCI_BT_OP_BT_DEV_DISABLE:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "[bt operation] : BT Device is disabled!!\n");
+		break;
+	default:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "[bt operation] : Unknown, error!!\n");
+		break;
+	}
+
+	return rtl_send_comp_ev_to_bt(rtlpriv, HCI_BT_OPERATION_NOTIFY, status);
+}
+
+static u8 rtl_btcoex_parse_BT_AFH_MAP_notify_cmd(struct rtl_priv *rtlpriv,
+						 u8 *pcmd, u16 cmdlen)
+{
+	enum HCI_STATUS	status = HCI_STATUS_SUCCESS;
+
+	return rtl_send_comp_ev_to_bt(rtlpriv, HCI_BT_AFH_MAP_NOTIFY, status);
+}
+
+static u8 rtl_btcoex_parse_BT_register_val_notify_cmd(struct rtl_priv *rtlpriv,
+						      u8 *pcmd, u16 cmdlen)
+{
+	enum HCI_STATUS	status = HCI_STATUS_SUCCESS;
+
+	return rtl_send_comp_ev_to_bt(rtlpriv, HCI_BT_REGISTER_VALUE_NOTIFY,
+				      status);
+}
+
+static u8 rtl_btcoex_parse_HCI_BT_abnormal_notify_cmd(struct rtl_priv *rtlpriv,
+						      u8 *pcmd, u16 cmdlen)
+{
+	enum HCI_STATUS	status = HCI_STATUS_SUCCESS;
+
+	return rtl_send_comp_ev_to_bt(rtlpriv, HCI_BT_ABNORMAL_NOTIFY, status);
+}
+
+static u8 rtl_btcoex_parse_HCI_query_RF_status_cmd(struct rtl_priv *rtlpriv,
+						   u8 *pcmd, u16 cmdlen)
+{
+	enum HCI_STATUS	status = HCI_STATUS_SUCCESS;
+
+	return rtl_send_comp_ev_to_bt(rtlpriv, HCI_QUERY_RF_STATUS, status);
+}
+
+/*****************************************
+* HCI cmd format :
+*| 15 - 0						|
+*| OPcode (OCF|OGF<<10)		|
+*| 15 - 8		|7 - 0			|
+*|Cmd para	|Cmd para Length	|
+*|Cmd para......				|
+******************************************/
+
+/* bit 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 */
+/*	 |	OCF			             |	   OGF       | */
+static void rtl_btcoex_parse_hci_extend_cmd(struct rtl_priv *rtlpriv, u8 *pcmd,
+					    u16 len, const u16 hci_OCF)
+{
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL, "#LEVEL2,");
+	switch (hci_OCF) {
+	case HCI_EXTENSION_VERSION_NOTIFY:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "HCI_EXTENSION_VERSION_NOTIFY\n#LEVEL3,");
+		rtl_btcoex_parse_HCI_Ver_notify_cmd(rtlpriv, pcmd, len);
+		break;
+	case HCI_LINK_STATUS_NOTIFY:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "HCI_LINK_STATUS_NOTIFY#LEVEL3\n");
+		rtl_btcoex_parse_HCI_link_status_notify_cmd(rtlpriv, pcmd, len);
+		break;
+	case HCI_BT_OPERATION_NOTIFY:
+		/* only for 8723a 2ant*/
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "HCI_BT_OPERATION_NOTIFY\n#LEVEL3,");
+		rtl_btcoex_parse_HCI_BT_operation_notify_cmd(rtlpriv,
+							     pcmd, len);
+		break;
+	case HCI_ENABLE_WIFI_SCAN_NOTIFY:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "HCI_ENABLE_WIFI_SCAN_NOTIFY\n#LEVEL3,");
+		rtl_btcoex_parse_WIFI_scan_notify_cmd(rtlpriv, pcmd, len);
+		break;
+	case HCI_QUERY_RF_STATUS:
+		/*  only for 8723b 2ant */
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "HCI_QUERY_RF_STATUS\n#LEVEL3,");
+		rtl_btcoex_parse_HCI_query_RF_status_cmd(rtlpriv, pcmd, len);
+		break;
+	case HCI_BT_ABNORMAL_NOTIFY:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "HCI_BT_ABNORMAL_NOTIFY\n#LEVEL3,");
+		rtl_btcoex_parse_HCI_BT_abnormal_notify_cmd(rtlpriv, pcmd, len);
+		break;
+	case HCI_BT_INFO_NOTIFY:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "HCI_BT_INFO_NOTIFY\n#LEVEL3,");
+		rtl_btcoex_parse_BT_info_notify_cmd(rtlpriv, pcmd, len);
+		break;
+	case HCI_BT_COEX_NOTIFY:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "HCI_BT_COEX_NOTIFY\n#LEVEL3,");
+		rtl_btcoex_parse_HCI_BT_coex_notify_cmd(rtlpriv, pcmd, len);
+		break;
+	case HCI_BT_PATCH_VERSION_NOTIFY:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "HCI_BT_PATCH_VERSION_NOTIFY\n#LEVEL3,");
+		rtl_btcoex_parse_BT_patch_ver_info_cmd(rtlpriv, pcmd, len);
+		break;
+	case HCI_BT_AFH_MAP_NOTIFY:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "HCI_BT_AFH_MAP_NOTIFY\n#LEVEL3,");
+		rtl_btcoex_parse_BT_AFH_MAP_notify_cmd(rtlpriv, pcmd, len);
+		break;
+	case HCI_BT_REGISTER_VALUE_NOTIFY:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "HCI_BT_REGISTER_VALUE_NOTIFY\n#LEVEL3,");
+		rtl_btcoex_parse_BT_register_val_notify_cmd(rtlpriv, pcmd, len);
+		break;
+	default:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+			  "ERROR!!! Unknown OCF: %x\n", hci_OCF);
+		break;
+	}
+}
+
+static void rtl_btcoex_parse_hci_cmd(struct rtl_priv *rtlpriv, u8 *pcmd,
+				     u16 len)
+{
+	u16 opcode = pcmd[0] | pcmd[1]<<8;
+	u16 hci_OGF = HCI_OGF(opcode);
+	u16 hci_OCF = HCI_OCF(opcode);
+	u8 cmdlen = len - 3;
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "#LEVEL1, OGF: %x, OCF: %x\n", hci_OGF, hci_OCF);
+
+	switch (hci_OGF) {
+	case OGF_EXTENSION:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "#LEVEL1, HCI_EXTENSION_CMD_OGF\n");
+		rtl_btcoex_parse_hci_extend_cmd(rtlpriv, &pcmd[3], cmdlen,
+						hci_OCF);
+		break;
+	default:
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  "#LEVEL1, Other OGF: %x\n", hci_OGF);
+		break;
+	}
+}
+
+static u16 rtl_btcoex_parse_recv_data(u8 *msg, u8 msg_size)
+{
+	u8 *cmp_msg1 = attend_ack;
+	u8 *cmp_msg2 = leave_ack;
+	u8 *cmp_msg3 = bt_leave;
+	u8 *cmp_msg4 = invite_req;
+	u8 *cmp_msg5 = attend_req;
+	u8 *cmp_msg6 = invite_rsp;
+	u8 res = OTHER;
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "\n>>>>>>>>>>>>>>>>>>>>>>>BT_TO_WIFI");
+
+	if (memcmp(cmp_msg1, msg, msg_size) == 0) {
+		res = RX_ATTEND_ACK;
+	} else if (memcmp(cmp_msg2, msg, msg_size) == 0) {
+		res = RX_LEAVE_ACK;
+	} else if (memcmp(cmp_msg3, msg, msg_size) == 0) {
+		res = RX_BT_LEAVE;
+	} else if (memcmp(cmp_msg4, msg, msg_size) == 0) {
+		res = RX_INVITE_REQ;
+	} else if (memcmp(cmp_msg5, msg, msg_size) == 0) {
+		res = RX_ATTEND_REQ;
+	} else if (memcmp(cmp_msg6, msg, msg_size) == 0) {
+		res = RX_INVITE_RSP;
+	} else {
+		res = OTHER;
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL, ", other_cmd!\n");
+	}
+
+	if (OTHER != res)
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+			  ", base_cmd:%s\n", msg);
+	return res;
+}
+
+static void rtl_btcoex_recvmsg_int(struct sock *sk_in)
+{
+	struct rtl_priv *rtlpriv = pbtcoexadapter;
+	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
+
+	pcoex_info->sk_store = sk_in;
+	queue_delayed_work(pbtcoexadapter->works.rtl_wq,
+			   &rtlpriv->works.socket_wq, 0);
+}
+
+static void rtl_btcoex_recvmsgbysocket(void *data)
+{
+	struct rtl_priv *rtlpriv = pbtcoexadapter;
+	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
+	struct sock *sk = pcoex_info->sk_store;
+	struct sk_buff *skb = NULL;
+	u8 *recv_data;
+	u32 len = 0;
+	u16 recv_length = 0;
+	u16 parse_res = 0;
+
+	recv_data = kzalloc(RECV_DATA_MAX_LEN, GFP_ATOMIC);
+	if (!recv_data)
+		return;
+	if (!sk) {
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+			  "critical error when receive socket data!\n");
+		return;
+	}
+	len = skb_queue_len(&sk->sk_receive_queue);
+	while (len > 0) {
+		skb = skb_dequeue(&sk->sk_receive_queue);
+
+		/* important: cut the udp header from skb->data!
+		 * header length is 8 byte
+		 */
+		recv_length = skb->len-8;
+		memset(recv_data, 0, RECV_DATA_MAX_LEN);
+		safe_memcpy(recv_data, skb->data+8, recv_length,
+			    RECV_DATA_MAX_LEN);
+
+		parse_res = rtl_btcoex_parse_recv_data(recv_data, recv_length);
+		if (RX_ATTEND_ACK == parse_res) { /* attend ack */
+			pcoex_info->bt_attend = true;
+			BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+				  "RX_ATTEND_ACK!, sock_open:%d, bt_attend:%d\n",
+				  pcoex_info->sock_open,
+				  pcoex_info->bt_attend);
+		}
+		if (RX_ATTEND_REQ == parse_res) { /* attend req from BT */
+			pcoex_info->bt_attend = true;
+			BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+				  "RX_BT_ATTEND_REQ!, sock_open:%d, bt_attend:%d\n",
+				  pcoex_info->sock_open,
+				  pcoex_info->bt_attend);
+			rtl_btcoex_sendmsgbysocket(pbtcoexadapter, attend_ack,
+						   sizeof(attend_ack), false);
+		}
+		if (RX_INVITE_REQ == parse_res) { /* attend req from BT */
+			pcoex_info->bt_attend = true;
+			BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+				  "RX_INVITE_REQ!, sock_open:%d, bt_attend:%d\n",
+				  pcoex_info->sock_open,
+				  pcoex_info->bt_attend);
+			rtl_btcoex_sendmsgbysocket(pbtcoexadapter, invite_rsp,
+						   sizeof(invite_rsp), false);
+		}
+		if (RX_INVITE_RSP == parse_res) {
+			/* attend req from BT */
+			pcoex_info->bt_attend = true;
+			BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+				  "RX_INVITE_RSP!, sock_open:%d, bt_attend:%d\n",
+				  pcoex_info->sock_open,
+				  pcoex_info->bt_attend);
+		} else if (RX_LEAVE_ACK == parse_res) {
+			/* mean BT know wifi  will leave */
+			pcoex_info->bt_attend = false;
+			BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+				  "RX_LEAVE_ACK!, sock_open:%d, bt_attend:%d\n",
+				  pcoex_info->sock_open,
+				  pcoex_info->bt_attend);
+		} else if (RX_BT_LEAVE == parse_res) { /* BT leave */
+			rtl_btcoex_sendmsgbysocket(pbtcoexadapter, leave_ack,
+						   sizeof(leave_ack),
+						   false); /*  no ack */
+			pcoex_info->bt_attend = false;
+			BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+				  "RX_BT_LEAVE!sock_open:%d, bt_attend:%d\n",
+				  pcoex_info->sock_open,
+				  pcoex_info->bt_attend);
+		} else { /*todo: check if recv data are really hci cmds*/
+			if (pcoex_info->bt_attend)
+				rtl_btcoex_parse_hci_cmd(pbtcoexadapter,
+							 recv_data,
+							 recv_length);
+		}
+		len--;
+		kfree_skb(skb);
+		/*never do a sleep in this context!*/
+	}
+	kfree(recv_data);
+}
+
+u8 rtl_btcoex_sendmsgbysocket(struct rtl_priv *rtlpriv, u8 *msg, u8 msg_size,
+			      bool force)
+{
+	struct msghdr	udpmsg;
+	struct iovec	iov;
+	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
+	u8 error;
+	mm_segment_t	oldfs;
+
+	if (!force) {
+		if (!pcoex_info->bt_attend) {
+			BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+				  "TX Blocked: WiFi-BT disconnected\n");
+			return _FAIL;
+		}
+	}
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "<<<<<<<<<<<<<<<<<<<<<<<<WIFI_TO_BT, msg:%s\n", msg);
+
+	iov.iov_base	 = (void __user *)msg;
+	iov.iov_len	 = msg_size;
+	udpmsg.msg_name	 = &pcoex_info->bt_addr;
+	udpmsg.msg_namelen = sizeof(struct sockaddr_in);
+	udpmsg.msg_control = NULL;
+	udpmsg.msg_controllen = 0;
+	udpmsg.msg_flags = MSG_DONTWAIT | MSG_NOSIGNAL;
+	udpmsg.msg_flags = 0;
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+	error = sock_sendmsg(pcoex_info->udpsock, &udpmsg, msg_size);
+	set_fs(oldfs);
+	if (error < 0) {
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+			  "Error when sendimg msg, error:%d\n", error);
+		return _FAIL;
+	}
+	return _SUCCESS;
+}
+
+static u8 rtl_btcoex_create_kernel_socket(struct rtl_priv *rtlpriv,
+					  u8 is_invite)
+{
+	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
+	s8 kernel_socket_err;
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+		  "%s CONNECT_PORT %d\n", __func__, CONNECT_PORT);
+
+	if (!pcoex_info) {
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL, "coex_info: NULL\n");
+		return _FAIL;
+	}
+
+	kernel_socket_err = sock_create(PF_INET, SOCK_DGRAM, 0,
+					&pcoex_info->udpsock);
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+		  "binding socket, err = %d\n", kernel_socket_err);
+
+	if (kernel_socket_err < 0) {
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+			  "Error during creation of socket error:%d\n",
+			  kernel_socket_err);
+		return _FAIL;
+	}
+	memset(&pcoex_info->sin, 0, sizeof(pcoex_info->sin));
+	pcoex_info->sin.sin_family = AF_INET;
+	pcoex_info->sin.sin_port = htons(CONNECT_PORT);
+	pcoex_info->sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+
+	memset(&pcoex_info->bt_addr, 0, sizeof(pcoex_info->bt_addr));
+	pcoex_info->bt_addr.sin_family = AF_INET;
+	pcoex_info->bt_addr.sin_port = htons(CONNECT_PORT_BT);
+	pcoex_info->bt_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+
+	pcoex_info->sk_store = NULL;
+
+	kernel_socket_err =
+	   pcoex_info->udpsock->ops->bind(pcoex_info->udpsock,
+					  (struct sockaddr *)&pcoex_info->sin,
+					  sizeof(pcoex_info->sin));
+	if (kernel_socket_err == 0) {
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+			  "binding socket success\n");
+		pcoex_info->udpsock->sk->sk_data_ready =
+			rtl_btcoex_recvmsg_int;
+		pcoex_info->sock_open |=  KERNEL_SOCKET_OK;
+		pcoex_info->bt_attend = false;
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+			  "WIFI sending attend_req\n");
+		rtl_btcoex_sendmsgbysocket(rtlpriv, attend_req,
+					   sizeof(attend_req), true);
+		return _SUCCESS;
+	}
+	pcoex_info->bt_attend = false;
+	sock_release(pcoex_info->udpsock);
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+		  "Error binding socket: %d\n",
+		  kernel_socket_err);
+	return _FAIL;
+}
+
+static void rtl_btcoex_close_kernel_socket(struct rtl_priv *rtlpriv)
+{
+	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
+
+	if (pcoex_info->sock_open & KERNEL_SOCKET_OK) {
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+			  "release kernel socket\n");
+		cancel_delayed_work(&rtlpriv->works.socket_wq);
+
+		sock_release(pcoex_info->udpsock);
+		pcoex_info->sock_open &= ~(KERNEL_SOCKET_OK);
+		if (pcoex_info->bt_attend)
+			pcoex_info->bt_attend = false;
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+			  "sock_open:%d, bt_attend:%d\n",
+			  pcoex_info->sock_open, pcoex_info->bt_attend);
+	}
+}
+
+void rtl_btcoex_init_socket(struct rtl_priv *rtlpriv)
+{
+	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
+	u8 is_invite = false;
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+		  "8812AE:init socket with 8761AU\n");
+
+	INIT_DELAYED_WORK(&rtlpriv->works.socket_wq,
+			  (void *)rtl_btcoex_recvmsgbysocket);
+
+	if (!pcoex_info->is_exist) {
+		memset(pcoex_info, 0, sizeof(struct bt_coex_info));
+		pbtcoexadapter = rtlpriv;
+		rtl_btcoex_create_kernel_socket(rtlpriv, is_invite);
+		pcoex_info->is_exist = true;
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+			  "set coex_info->is_exist: %d\n",
+			  pcoex_info->is_exist);
+	}
+}
+
+void rtl_btcoex_close_socket(struct rtl_priv *rtlpriv)
+{
+	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+		  "set coex_info->is_exist: %d\n", pcoex_info->is_exist);
+	if (pcoex_info->is_exist) {
+		pcoex_info->is_exist = false;
+		if (pcoex_info->bt_attend)  {/*inform BT wifi leave*/
+			rtl_btcoex_sendmsgbysocket(rtlpriv, wifi_leave,
+						   sizeof(wifi_leave), false);
+			msleep(50);
+		}
+		rtl_btcoex_close_kernel_socket(rtlpriv);
+		pbtcoexadapter = NULL;
+	}
+}
+
+void rtl_btcoex_dump_tx_msg(u8 *tx_msg, u8 len, u8 *msg_name)
+{
+}
+
+void rtl_btcoex_sendeventextbtcoexcontrol(struct rtl_priv *rtlpriv,
+					  u8 needdbgrsp, u8 datalen,
+					  void *pdata)
+{
+	u8 len = 0, tx_event_length = 0;
+	u8 local_buf[32] = "";
+	u8 *ret_par;
+	u8 opcode = 0;
+	u8 *pinbuf = (u8 *)pdata;
+	struct rtl_hci_event *hci_event;
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "#LEVEL_WIFI_ACTIVE, SendEventExtBtCoexControl\n");
+	opcode = pinbuf[0];
+
+	hci_event = (struct rtl_hci_event *)(&local_buf[0]);
+
+	hci_event->event_code = HCI_EVENT_EXTENSION_RTK;
+	/* extension event code */
+	hci_event->data[0] = HCI_EVENT_EXT_BT_COEX_CONTROL;
+	len++;
+	ret_par = hci_event->data + len;
+	memcpy(&ret_par[0], pdata, datalen); /*maybe not safe here*/
+	len += datalen;
+	hci_event->length = len;
+	/* total tx event length + event_code length + sizeof(length) */
+	tx_event_length = hci_event->length + 2;
+	rtl_btcoex_dump_tx_msg((u8 *)hci_event, tx_event_length,
+			       "BT COEX CONTROL");
+	rtl_btcoex_sendmsgbysocket(rtlpriv, (u8 *)hci_event, tx_event_length,
+				   false);
+}
+
+void rtl_btcoex_sendeventextbtinfocontrol(struct rtl_priv *rtlpriv, u8 datalen,
+					  void *pdata)
+{
+	struct rtl_hci_event *hci_event;
+	struct bt_coex_info *pcoex_info = &rtlpriv->coex_info;
+	struct bt_mgnt *bt_mgnt = &pcoex_info->btmgnt;
+	u8 *ret_par;
+	u8 len = 0, tx_event_length = 0;
+	u8 local_buf[32] = "";
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "#LEVEL_WIFI_ACTIVE, SendEventExtBtInfoControl\n");
+
+	if (bt_mgnt->ext_config.hci_ext_ver < 4) { /* no support */
+		BTC_PRINT(BTC_MSG_SOCKET, SOCKET_CRITICAL,
+			  "ERROR: hci_extension_ver = %d, oonly versions < 4 supported\n",
+			  bt_mgnt->ext_config.hci_ext_ver);
+		return;
+	}
+	hci_event = (struct rtl_hci_event *)(&local_buf[0]);
+	hci_event->event_code = HCI_EVENT_EXTENSION_RTK;
+	hci_event->data[0] = HCI_EVENT_EXT_BT_INFO_CONTROL;
+	len++;
+	ret_par = hci_event->data + len;
+
+	memcpy(&ret_par[0], pdata, datalen);/*maybe not safe here*/
+	len += datalen;
+	hci_event->length = len;
+	/* total tx event length + event_code length + sizeof(length) */
+	tx_event_length = hci_event->length + 2;
+	rtl_btcoex_dump_tx_msg((u8 *)hci_event, tx_event_length,
+			       "BT INFO CONTROL");
+	rtl_btcoex_sendmsgbysocket(rtlpriv, (u8 *)hci_event, tx_event_length,
+				   false);
+}
+
+void rtl_btcoex_sendscannotify(struct rtl_priv *rtlpriv, u8 scantype)
+{
+	struct rtl_hci_event *hci_event;
+	u8 tx_event_length = 0;
+	u8 local_buf[7] = "";
+	u8 *event_data = NULL;
+
+	BTC_PRINT(BTC_MSG_SOCKET, SOCKET_NORMAL,
+		  "#LEVEL_WIFI_ACTIVE, SendScanNotify\n");
+
+	hci_event = (struct rtl_hci_event *)(&local_buf[0]);
+	hci_event->event_code = HCI_EVENT_EXTENSION_RTK;
+	event_data = hci_event->data;
+	*(event_data) = HCI_EVENT_EXT_WIFI_SCAN_NOTIFY;
+	*(event_data + 1) = scantype;
+	hci_event->length = 2;
+	/* total tx event length + event_code length + sizeof(length) */
+	tx_event_length = hci_event->length + 2;
+	rtl_btcoex_dump_tx_msg((u8 *)hci_event, tx_event_length,
+			       "WIFI SCAN OPERATION");
+	rtl_btcoex_sendmsgbysocket(rtlpriv, (u8 *)hci_event, tx_event_length,
+				   false);
+}
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a_ext.h b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a_ext.h
new file mode 100644
index 0000000..8f750c9
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8812a_ext.h
@@ -0,0 +1,359 @@
+#ifndef __8812A_EXT_H__
+#define __8812A_EXT_H__
+
+/* for socket */
+#include <net/sock.h>
+#include <net/tcp.h>
+#include <linux/udp.h>
+#include <linux/in.h>
+#include <linux/netlink.h>
+
+#define _FAIL 0
+#define _SUCCESS 1
+#define BT_INFO_LENGTH 8
+#define RECV_DATA_MAX_LEN 255
+#define BTINFO_WIFI_FETCH 0x23
+#define BTINFO_BT_AUTO_RPT 0x27
+
+#define CONNECT_PORT 30000
+#define CONNECT_PORT_BT 30001
+#define KERNEL_SOCKET_OK 0x01
+
+#define OTHER 0
+#define RX_ATTEND_ACK 1
+#define RX_LEAVE_ACK 2
+#define RX_BT_LEAVE 3
+#define RX_INVITE_REQ 4
+#define RX_ATTEND_REQ 5
+#define RX_INVITE_RSP 6
+
+#define invite_req "INVITE_REQ"
+#define invite_rsp "INVITE_RSP"
+#define attend_req "ATTEND_REQ"
+#define attend_ack "ATTEND_ACK"
+#define wifi_leave "WIFI_LEAVE"
+#define leave_ack "LEAVE_ACK"
+#define bt_leave "BT_LEAVE"
+
+#define BT_INFO_NOTIFY_CMD 0x0106
+#define BT_INFO_LEN 8
+
+struct hci_link_info {
+	u16		connect_handle;
+	u8		incoming_traffic_mode;
+	u8		outgoing_traffic_mode;
+	u8		bt_profile;
+	u8		bt_corespec;
+	s8		bt_RSSI;
+	u8		traffic_profile;
+	u8		link_role;
+};
+
+#define	MAX_BT_ACL_LINK_NUM		8
+
+struct hci_ext_config {
+	struct hci_link_info	acl_link[MAX_BT_ACL_LINK_NUM];
+	u8	bt_operation_code;
+	u16	current_connect_handle;
+	u8	current_incoming_traffic_mode;
+	u8	current_outgoing_traffic_mode;
+
+	u8	number_of_acl;
+	u8	number_of_sco;
+	u8	current_bt_status;
+	u16	hci_ext_ver;
+	bool	enable_wifi_scan_notify;
+};
+
+struct hci_phy_link_bss_info {
+	u16	bdcap;		/* capability information */
+};
+
+enum BT_CONNECT_TYPE {
+	BT_CONNECT_AUTH_REQ	= 0x00,
+	BT_CONNECT_AUTH_RSP	= 0x01,
+	BT_CONNECT_ASOC_REQ	= 0x02,
+	BT_CONNECT_ASOC_RSP	= 0x03,
+	BT_DISCONNECT		= 0x04
+};
+
+struct rtl_hci_event {
+	    u8		event_code;
+	    u8		length; /* total cmd length = extension event length+1
+				 * (extension event code length)
+				 */
+	    u8		data[1]; /*  byte1 is extension event code */
+};
+
+struct btinfo_8761au {
+	u8 cid;
+	u8 len;
+
+	u8 connection:1;
+	u8 scoe_sco:1;
+	u8 inq_page:1;
+	u8 acl_busy:1;
+	u8 sco_busy:1;
+	u8 hid:1;
+	u8 a2dp:1;
+	u8 ftp:1;
+
+	u8 retry_cnt:4;
+	u8 rsvd_34:1;
+	u8 page:1;
+	u8 trx_mask:1;
+	u8 sniff_attempt:1;
+
+	u8 rssi;
+
+	u8 a2dp_rate:1;
+	u8 re_init:1;
+	u8 max_power:1;
+	u8 en_ignore_wlan_act:1;
+	u8 tx_power_low:1;
+	u8 tx_power_high:1;
+	u8 esco_sco:1;
+	u8 master_slave:1;
+
+	u8 acl_trx_tp_low;
+	u8 acl_trx_tp_high;
+};
+
+#define HCIOPCODE(_OCF, _OGF)     ((_OGF)<<10|(_OCF))
+#define HCIOPCODELOW(_OCF, _OGF)	(u8)(HCIOPCODE(_OCF, _OGF)&0x00ff)
+#define HCIOPCODEHIGHT(_OCF, _OGF) (u8)(HCIOPCODE(_OCF, _OGF)>>8)
+#define HCI_OGF(__opcode)  (unsigned char)((0xFC00 & (__opcode)) >> 10)
+#define HCI_OCF(__opcode)  (0x3FF & (__opcode))
+
+enum HCI_STATUS {
+	/* Success */
+	HCI_STATUS_SUCCESS				= 0x00,
+	/* Unknown HCI Command */
+	HCI_STATUS_UNKNOW_HCI_CMD			= 0x01,
+	/* Unknown Connection Identifier */
+	HCI_STATUS_UNKNOW_CONNECT_ID			= 0X02,
+	/* Hardware Failure */
+	HCI_STATUS_HW_FAIL				= 0X03,
+	/* Page Timeout */
+	HCI_STATUS_PAGE_TIMEOUT				= 0X04,
+	/* Authentication Failure */
+	HCI_STATUS_AUTH_FAIL				= 0X05,
+	/* PIN or Key Missing */
+	HCI_STATUS_PIN_OR_KEY_MISSING			= 0X06,
+	/* Memory Capacity Exceeded */
+	HCI_STATUS_MEM_CAP_EXCEED			= 0X07,
+	/* Connection Timeout */
+	HCI_STATUS_CONNECT_TIMEOUT			= 0X08,
+	/* Connection Limit Exceeded */
+	HCI_STATUS_CONNECT_LIMIT			= 0X09,
+	/* Synchronous Connection Limit To A Device Exceeded */
+	HCI_STATUS_SYN_CONNECT_LIMIT			= 0X0a,
+	/* ACL Connection Already Exists */
+	HCI_STATUS_ACL_CONNECT_EXISTS			= 0X0b,
+	/* Command Disallowed */
+	HCI_STATUS_CMD_DISALLOW				= 0X0c,
+	/* Connection Rejected due to Limited Resources */
+	HCI_STATUS_CONNECT_RJT_LIMIT_RESOURCE		= 0X0d,
+	/* Connection Rejected Due To Security Reasons */
+	HCI_STATUS_CONNECT_RJT_SEC_REASON		= 0X0e,
+	/* Connection Rejected due to Unacceptable BD_ADDR */
+	HCI_STATUS_CONNECT_RJT_UNACCEPT_BD_ADDR		= 0X0f,
+	/* Connection Accept Timeout Exceeded */
+	HCI_STATUS_CONNECT_ACCEPT_TIMEOUT		= 0X10,
+	/* Unsupported Feature or Parameter Value */
+	HCI_STATUS_UNSUPPORT_FEATURE_PARA_VALUE		= 0X11,
+	/* Invalid HCI Command Parameters */
+	HCI_STATUS_INVALID_HCI_CMD_PARA_VALUE		= 0X12,
+	/* Remote User Terminated Connection */
+	HCI_STATUS_REMOTE_USER_TERMINATE_CONNECT	= 0X13,
+	/* Remote Device Terminated Connection due to Low Resources */
+	HCI_STATUS_REMOTE_DEV_TERMINATE_LOW_RESOURCE	= 0X14,
+	/* Remote Device Terminated Connection due to Power Off */
+	HCI_STATUS_REMOTE_DEV_TERMINATE_CONNECT_POWER_OFF	= 0X15,
+	/* Connection Terminated By Local Host */
+	HCI_STATUS_CONNECT_TERMINATE_LOCAL_HOST		= 0X16,
+	/* Repeated Attempts */
+	HCI_STATUS_REPEATE_ATTEMPT			= 0X17,
+	/* Pairing Not Allowed */
+	HCI_STATUS_PAIR_NOT_ALLOW			= 0X18,
+	/* Unknown LMP PDU */
+	HCI_STATUS_UNKNOW_LMP_PDU			= 0X19,
+	/* Unsupported Remote Feature / Unsupported LMP Feature */
+	HCI_STATUS_UNSUPPORT_REMOTE_LMP_FEATURE		= 0X1a,
+	/* SCO Offset Rejected */
+	HCI_STATUS_SOC_OFFSET_REJECT			= 0X1b,
+	/* SCO Interval Rejected */
+	HCI_STATUS_SOC_INTERVAL_REJECT			= 0X1c,
+	/* SCO Air Mode Rejected */
+	HCI_STATUS_SOC_AIR_MODE_REJECT			= 0X1d,
+	/* Invalid LMP Parameters */
+	HCI_STATUS_INVALID_LMP_PARA			= 0X1e,
+	/* Unspecified Error */
+	HCI_STATUS_UNSPECIFIC_ERROR			= 0X1f,
+	/* Unsupported LMP Parameter Value */
+	HCI_STATUS_UNSUPPORT_LMP_PARA_VALUE		= 0X20,
+	/* Role Change Not Allowed */
+	HCI_STATUS_ROLE_CHANGE_NOT_ALLOW		= 0X21,
+	/* LMP Response Timeout */
+	HCI_STATUS_LMP_RESPONSE_TIMEOUT			= 0X22,
+	/* LMP Error Transaction Collision */
+	HCI_STATUS_LMP_ERROR_TRANSACTION_COLLISION	= 0X23,
+	/* LMP PDU Not Allowed */
+	HCI_STATUS_LMP_PDU_NOT_ALLOW			= 0X24,
+	/* Encryption Mode Not Acceptable */
+	HCI_STATUS_ENCRYPTION_MODE_NOT_ALLOW		= 0X25,
+	/* Link Key Can Not be Changed */
+	HCI_STATUS_LINK_KEY_CAN_NOT_CHANGE		= 0X26,
+	/* Requested QoS Not Supported */
+	HCI_STATUS_REQUEST_QOS_NOT_SUPPORT		= 0X27,
+	/* Instant Passed */
+	HCI_STATUS_INSTANT_PASSED			= 0X28,
+	/* Pairing With Unit Key Not Supported */
+	HCI_STATUS_PAIRING_UNIT_KEY_NOT_SUPPORT		= 0X29,
+	/* Different Transaction Collision */
+	HCI_STATUS_DIFFERENT_TRANSACTION_COLLISION	= 0X2a,
+	/* Reserved */
+	HCI_STATUS_RESERVE_1				= 0X2b,
+	/* QoS Unacceptable Parameter */
+	HCI_STATUS_QOS_UNACCEPT_PARA			= 0X2c,
+	/* QoS Rejected */
+	HCI_STATUS_QOS_REJECT				= 0X2d,
+	/* Channel Classification Not Supported */
+	HCI_STATUS_CHNL_CLASSIFICATION_NOT_SUPPORT	= 0X2e,
+	/* Insufficient Security */
+	HCI_STATUS_INSUFFICIENT_SECURITY		= 0X2f,
+	/* Parameter Out Of Mandatory Range */
+	HCI_STATUS_PARA_OUT_OF_RANGE			= 0x30,
+	/* Reserved */
+	HCI_STATUS_RESERVE_2				= 0X31,
+	/* Role Switch Pending */
+	HCI_STATUS_ROLE_SWITCH_PENDING			= 0X32,
+	/* Reserved */
+	HCI_STATUS_RESERVE_3				= 0X33,
+	/* Reserved Slot Violation */
+	HCI_STATUS_RESERVE_SOLT_VIOLATION		= 0X34,
+	/* Role Switch Failed */
+	HCI_STATUS_ROLE_SWITCH_FAIL			= 0X35,
+	/* Extended Inquiry Response Too Large */
+	HCI_STATUS_EXTEND_INQUIRY_RSP_TOO_LARGE		= 0X36,
+	/* Secure Simple Pairing Not Supported By Host. */
+	HCI_STATUS_SEC_SIMPLE_PAIRING_NOT_SUPPORT	= 0X37,
+	/* Host Busy - Pairing */
+	HCI_STATUS_HOST_BUSY_PAIRING			= 0X38,
+	/* Connection Rejected due to No Suitable Channel Found */
+	HCI_STATUS_CONNECT_REJ_NOT_SUIT_CHNL_FOUND	= 0X39,
+	/* CONTROLLER BUSY */
+	HCI_STATUS_CONTROLLER_BUSY			= 0X3a
+};
+
+#define HCI_EVENT_COMMAND_COMPLETE			0x0e
+
+#define OGF_EXTENSION					0X3f
+
+enum HCI_EXTENSION_COMMANDS {
+	HCI_SET_ACL_LINK_DATA_FLOW_MODE			= 0x0010,
+	HCI_SET_ACL_LINK_STATUS				= 0x0020,
+	HCI_SET_SCO_LINK_STATUS				= 0x0030,
+	HCI_SET_RSSI_VALUE				= 0x0040,
+	HCI_SET_CURRENT_BLUETOOTH_STATUS		= 0x0041,
+
+	/* The following is for RTK8723 */
+	HCI_EXTENSION_VERSION_NOTIFY			= 0x0100,
+	HCI_LINK_STATUS_NOTIFY				= 0x0101,
+	HCI_BT_OPERATION_NOTIFY				= 0x0102,
+	HCI_ENABLE_WIFI_SCAN_NOTIFY			= 0x0103,
+	HCI_QUERY_RF_STATUS				= 0x0104,
+	HCI_BT_ABNORMAL_NOTIFY				= 0x0105,
+	HCI_BT_INFO_NOTIFY				= 0x0106,
+	HCI_BT_COEX_NOTIFY				= 0x0107,
+	HCI_BT_PATCH_VERSION_NOTIFY			= 0x0108,
+	HCI_BT_AFH_MAP_NOTIFY				= 0x0109,
+	HCI_BT_REGISTER_VALUE_NOTIFY			= 0x010a,
+
+	/* The following is for IVT */
+	HCI_WIFI_CURRENT_CHANNEL			= 0x0300,
+	HCI_WIFI_CURRENT_BANDWIDTH			= 0x0301,
+	HCI_WIFI_CONNECTION_STATUS			= 0x0302
+};
+
+#define HCI_EVENT_EXTENSION_RTK				0xfe
+enum RTW_HCI_EXT_EVENT {
+	HCI_EVENT_EXT_WIFI_SCAN_NOTIFY			= 0x01,
+	HCI_EVENT_EXT_WIFI_RF_STATUS_NOTIFY		= 0x02,
+	HCI_EVENT_EXT_BT_INFO_CONTROL			= 0x03,
+	HCI_EVENT_EXT_BT_COEX_CONTROL			= 0x04
+};
+
+enum BT_TRAFFIC_MODE {
+	/* Best Effort. Default. for HCRP, PAN, SDP, RFCOMM-based
+	 * profiles like FTP, OPP, SPP, DUN, etc.
+	 */
+	BT_MOTOR_EXT_BE		= 0x00,
+	/* Guaranteed Latency. This is used e.g. for HID and AVRCP. */
+	BT_MOTOR_EXT_GUL	= 0x01,
+	/* Guaranteed Bandwidth. */
+	BT_MOTOR_EXT_GUB	= 0X02,
+	/* Guaranteed Latency and Bandwidth. for A2DP and VDP. */
+	BT_MOTOR_EXT_GULB	= 0X03
+};
+
+enum BT_TRAFFIC_MODE_PROFILE {
+	BT_PROFILE_NONE,
+	BT_PROFILE_A2DP,
+	BT_PROFILE_PAN,
+	BT_PROFILE_HID,
+	BT_PROFILE_SCO
+};
+
+struct bt_mgnt {
+	bool				bt_connect_in_progress;
+	bool				loglink_in_progress;
+	bool				phylink_in_progress;
+	bool				phylink_in_progress_start_ll;
+	u8				bt_current_phy_link_handle;
+	u16				bt_current_log_link_handle;
+	u8				current_connect_entry_num;
+	u8				disconnect_entry_num;
+	u8				current_bt_connection_cnt;
+	enum BT_CONNECT_TYPE		bt_current_connect_type;
+	enum BT_CONNECT_TYPE		bt_receive_connect_pkt;
+	u8				bt_auth_count;
+	u8				bt_asoc_count;
+	bool				start_send_supervision_pkt;
+	bool				bt_operation_on;
+	bool				bt_need_amp_status_chg;
+	bool				joiner_need_send_auth;
+	struct hci_phy_link_bss_info	bss_desc;
+	struct hci_ext_config		ext_config;
+	bool				need_notify_amp_no_cap;
+	bool				create_support_qos;
+	bool				support_profile;
+	u8				bt_hannel;
+	bool				check_chnl_is_suit;
+	bool				bt_scan;
+	bool				bt_logo_rest;
+	bool				rf_status_notified;
+	bool				bt_rsved_page_download;
+};
+
+#define SOCK_STORE_MAX 10
+struct bt_coex_info {
+	/* For Kernel Socket */
+	struct socket *udpsock;
+	struct sockaddr_in sin;
+	struct sockaddr_in bt_addr;
+	struct sock *sk_store;/*back up socket for UDP RX int*/
+	u32 pid;
+	/* store which socket is OK */
+	u8 sock_open;
+	u8 bt_attend;
+	u8 is_exist; /*  socket exist */
+	struct bt_mgnt btmgnt;
+};
+
+#define	PACKET_NORMAL			0
+#define	PACKET_DHCP			1
+#define	PACKET_ARP			2
+#define	PACKET_EAPOL			3
+
+#endif
-- 
2.1.2
