From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 6/10] hostap: Clear station statistic on accounting start
Date: Sat, 12 Mar 2005 16:32:57 -0800
Message-ID: <20050313003257.GG8253@jm.kir.nu>
References: <20050313001706.GA8253@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050313001706.GA8253@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>From Gunter Burchardt <gbur@informatik.uni-rostock.de>

Added new ioctl command for hostapd to clear station specific
accounting data when starting a new accounting session.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_ap.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_ap.c	2005-03-12 16:10:40.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_ap.c	2005-03-12 16:10:56.000000000 -0800
@@ -2582,6 +2582,31 @@
 }
 
 
+static int prism2_hostapd_sta_clear_stats(struct ap_data *ap,
+					  struct prism2_hostapd_param *param)
+{
+	struct sta_info *sta;
+	int rate;
+
+	spin_lock_bh(&ap->sta_table_lock);
+	sta = ap_get_sta(ap, param->sta_addr);
+	if (sta) {
+		sta->rx_packets = sta->tx_packets = 0;
+		sta->rx_bytes = sta->tx_bytes = 0;
+		for (rate = 0; rate < WLAN_RATE_COUNT; rate++) {
+			sta->tx_count[rate] = 0;
+			sta->rx_count[rate] = 0;
+		}
+	}
+	spin_unlock_bh(&ap->sta_table_lock);
+
+	if (!sta)
+		return -ENOENT;
+
+	return 0;
+}
+
+
 static int prism2_hostapd(struct ap_data *ap,
 			  struct prism2_hostapd_param *param)
 {
@@ -2597,6 +2622,8 @@
 		return prism2_hostapd_get_info_sta(ap, param);
 	case PRISM2_HOSTAPD_SET_FLAGS_STA:
 		return prism2_hostapd_set_flags_sta(ap, param);
+	case PRISM2_HOSTAPD_STA_CLEAR_STATS:
+		return prism2_hostapd_sta_clear_stats(ap, param);
 	default:
 		printk(KERN_WARNING "prism2_hostapd: unknown cmd=%d\n",
 		       param->cmd);
Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_common.h
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_common.h	2005-03-12 16:10:40.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_common.h	2005-03-12 16:10:56.000000000 -0800
@@ -482,6 +482,7 @@
 	PRISM2_HOSTAPD_SET_GENERIC_ELEMENT = 12,
 	PRISM2_HOSTAPD_MLME = 13,
 	PRISM2_HOSTAPD_SCAN_REQ = 14,
+	PRISM2_HOSTAPD_STA_CLEAR_STATS = 15,
 };
 
 #define PRISM2_HOSTAPD_MAX_BUF_SIZE 1024



-- 
Jouni Malinen                                            PGP id EFC895FA
