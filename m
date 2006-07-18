From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] ieee80211: small ERP handling additions
Date: Tue, 18 Jul 2006 21:30:34 +0100 (BST)
Message-ID: <20060718203034.E13A38DEF41@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:8177 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932385AbWGRUae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 16:30:34 -0400
To: linville@tuxdriver.com
Cc: ipw2100-admin@linux.intel.com
Cc: johannes@sipsolutions.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds a flag to the ieee80211_network structure which indicates whether
the stored erp_value is valid (a check against 0 is not enough, since an ERP
of 0 is valid and very meaningful).

I also added the ERP IE bit-definitions to ieee80211.h.

This is needed by some upcoming softmac patches.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Acked-by: Johannes Berg <johannes@sipsolutions.net>

Index: linux/include/net/ieee80211.h
===================================================================
--- linux.orig/include/net/ieee80211.h
+++ linux/include/net/ieee80211.h
@@ -240,6 +240,11 @@ struct ieee80211_snap_hdr {
 #define WLAN_CAPABILITY_SHORT_SLOT_TIME (1<<10)
 #define WLAN_CAPABILITY_DSSS_OFDM (1<<13)
 
+/* 802.11g ERP information element */
+#define WLAN_ERP_NON_ERP_PRESENT (1<<0)
+#define WLAN_ERP_USE_PROTECTION (1<<1)
+#define WLAN_ERP_BARKER_PREAMBLE (1<<2)
+
 /* Status codes */
 enum ieee80211_statuscode {
 	WLAN_STATUS_SUCCESS = 0,
@@ -747,6 +752,8 @@ struct ieee80211_txb {
 #define NETWORK_HAS_IBSS_DFS            (1<<8)
 #define NETWORK_HAS_TPC_REPORT          (1<<9)
 
+#define NETWORK_HAS_ERP_VALUE           (1<<10)
+
 #define QOS_QUEUE_NUM                   4
 #define QOS_OUI_LEN                     3
 #define QOS_OUI_TYPE                    2
Index: linux/net/ieee80211/ieee80211_rx.c
===================================================================
--- linux.orig/net/ieee80211/ieee80211_rx.c
+++ linux/net/ieee80211/ieee80211_rx.c
@@ -1166,6 +1166,7 @@ static int ieee80211_parse_info_param(st
 
 		case MFIE_TYPE_ERP_INFO:
 			network->erp_value = info_element->data[0];
+			network->flags |= NETWORK_HAS_ERP_VALUE;
 			IEEE80211_DEBUG_MGMT("MFIE_TYPE_ERP_SET: %d\n",
 					     network->erp_value);
 			break;
