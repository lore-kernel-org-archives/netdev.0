From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 8/12] Host AP: Do not bridge packets to unauthorized ports
Date: Sun, 7 Nov 2004 23:14:59 -0800
Message-ID: <20041108071459.GI1076@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix inner-BSS bridge (ap_bridge_packets=1) not to bridge packets to
unauthorized ports when IEEE 802.1X/WPA is used (i.e., require that
the STA completes authentication before capturing packets in the inner
bridge); previously, only association status was used and an attacker
could have capture packets to any MAC address even without having
proper credentials for using the network (although, the packets were
dropped because the controlled port for the STA was unauthorized).

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c	2004-11-07 22:38:51 -08:00
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c	2004-11-07 22:38:51 -08:00
@@ -1035,7 +1035,7 @@
 			if (skb2 == NULL)
 				printk(KERN_DEBUG "%s: skb_clone failed for "
 				       "multicast frame\n", dev->name);
-		} else if (hostap_is_sta_assoc(local->ap, dst)) {
+		} else if (hostap_is_sta_authorized(local->ap, dst)) {
 			/* send frame directly to the associated STA using
 			 * wireless media and not passing to higher layers */
 			local->ap->bridged_unicast++;
diff -Nru a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
--- a/drivers/net/wireless/hostap/hostap_ap.c	2004-11-07 22:38:51 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ap.c	2004-11-07 22:38:51 -08:00
@@ -3061,6 +3061,24 @@
 
 
 /* Called only as a tasklet (software IRQ) */
+int hostap_is_sta_authorized(struct ap_data *ap, u8 *sta_addr)
+{
+	struct sta_info *sta;
+	int ret = 0;
+
+	spin_lock(&ap->sta_table_lock);
+	sta = ap_get_sta(ap, sta_addr);
+	if (sta != NULL && (sta->flags & WLAN_STA_ASSOC) && !sta->ap &&
+	    ((sta->flags & WLAN_STA_AUTHORIZED) ||
+	     ap->local->ieee_802_1x == 0))
+		ret = 1;
+	spin_unlock(&ap->sta_table_lock);
+
+	return ret;
+}
+
+
+/* Called only as a tasklet (software IRQ) */
 int hostap_add_sta(struct ap_data *ap, u8 *sta_addr)
 {
 	struct sta_info *sta;
@@ -3219,6 +3237,7 @@
 EXPORT_SYMBOL(hostap_update_sta_ps);
 EXPORT_SYMBOL(hostap_handle_sta_rx);
 EXPORT_SYMBOL(hostap_is_sta_assoc);
+EXPORT_SYMBOL(hostap_is_sta_authorized);
 EXPORT_SYMBOL(hostap_add_sta);
 EXPORT_SYMBOL(hostap_update_rates);
 EXPORT_SYMBOL(hostap_add_wds_links);
diff -Nru a/drivers/net/wireless/hostap/hostap_ap.h b/drivers/net/wireless/hostap/hostap_ap.h
--- a/drivers/net/wireless/hostap/hostap_ap.h	2004-11-07 22:38:51 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ap.h	2004-11-07 22:38:51 -08:00
@@ -255,6 +255,7 @@
 			     struct hostap_ieee80211_hdr *hdr,
 			     struct prism2_crypt_data **crypt, void **sta_ptr);
 int hostap_is_sta_assoc(struct ap_data *ap, u8 *sta_addr);
+int hostap_is_sta_authorized(struct ap_data *ap, u8 *sta_addr);
 int hostap_add_sta(struct ap_data *ap, u8 *sta_addr);
 int hostap_update_rx_stats(struct ap_data *ap,
 			   struct hostap_ieee80211_hdr *hdr,



-- 
Jouni Malinen                                            PGP id EFC895FA
