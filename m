From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 14/16] Host AP: Updated to use Linux wireless extensions v17
Date: Sat, 13 Nov 2004 21:23:55 -0800
Message-ID: <20041114052355.GF14810@jm.kir.nu>
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

Patch from Jean Tourrilhes <jt@hpl.hp.com>:

HostAP WE-17 support:
- allow large scan requests
- export event capability
- new spy data handling

jkm: removed support for old WE versions (ifdefs)

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap.c b/drivers/net/wireless/hostap/hostap.c
--- a/drivers/net/wireless/hostap/hostap.c	2004-11-13 20:56:35 -08:00
+++ b/drivers/net/wireless/hostap/hostap.c	2004-11-13 20:56:35 -08:00
@@ -890,8 +890,12 @@
 
 	/* kernel callbacks */
 	dev->get_stats = hostap_get_stats;
-	if (main_dev || (iface && iface->type == HOSTAP_INTERFACE_MAIN))
-		dev->get_wireless_stats =  hostap_get_wireless_stats;
+	if (iface) {
+		/* Currently, we point to the proper spy_data only on
+		 * the main_dev. This could be fixed. Jean II */
+		iface->wireless_data.spy_data = &iface->spy_data;
+		dev->wireless_data = &iface->wireless_data;
+	}
 	dev->wireless_handlers =
 		(struct iw_handler_def *) &hostap_iw_handler_def;
 	dev->do_ioctl = hostap_ioctl;
diff -Nru a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
--- a/drivers/net/wireless/hostap/hostap_ioctl.c	2004-11-13 20:56:35 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c	2004-11-13 20:56:35 -08:00
@@ -13,6 +13,10 @@
 	local_info_t *local = iface->local;
 	struct iw_statistics *wstats;
 
+	/* Why are we doing that ? Jean II */
+	if (iface->type != HOSTAP_INTERFACE_MAIN)
+		return NULL;
+
 	wstats = &local->wstats;
 
 	wstats->status = 0;
@@ -989,6 +993,17 @@
 	range->min_frag = 256;
 	range->max_frag = 2346;
 
+	/* Event capability (kernel + driver) */
+	range->event_capa[0] = (IW_EVENT_CAPA_K_0 |
+				IW_EVENT_CAPA_MASK(SIOCGIWTHRSPY) |
+				IW_EVENT_CAPA_MASK(SIOCGIWAP) |
+				IW_EVENT_CAPA_MASK(SIOCGIWSCAN));
+	range->event_capa[1] = IW_EVENT_CAPA_K_1;
+	range->event_capa[4] = (IW_EVENT_CAPA_MASK(IWEVTXDROP) |
+				IW_EVENT_CAPA_MASK(IWEVCUSTOM) |
+				IW_EVENT_CAPA_MASK(IWEVREGISTERED) |
+				IW_EVENT_CAPA_MASK(IWEVEXPIRED));
+
 	return 0;
 }
 
@@ -1818,13 +1833,14 @@
 
 /* Translate scan data returned from the card to a card independant
  * format that the Wireless Tools will understand - Jean II */
-static inline int prism2_translate_scan(local_info_t *local, char *buffer)
+static inline int prism2_translate_scan(local_info_t *local,
+					char *buffer, int buflen)
 {
 	struct hfa384x_scan_result *scan;
 	struct hfa384x_hostscan_result *hscan;
 	int entries, entry, hostscan;
 	char *current_ev = buffer;
-	char *end_buf = buffer + IW_SCAN_MAX_DATA;
+	char *end_buf = buffer + buflen;
 	u8 *bssid;
 	struct list_head *ptr;
 
@@ -1858,6 +1874,12 @@
 				local, scan, hscan, hostscan, NULL, bssid,
 				current_ev, end_buf);
 		}
+		/* Check if there is space for one more entry */
+		if ((end_buf - current_ev) <= IW_EV_ADDR_LEN) {
+			/* Ask user space to try again with a bigger buffer */
+			spin_unlock_bh(&local->lock);
+			return -E2BIG;
+		}
 	}
 
 	spin_unlock_bh(&local->lock);
@@ -1894,7 +1916,7 @@
 	}
 	local->scan_timestamp = 0;
 
-	res = prism2_translate_scan(local, extra);
+	res = prism2_translate_scan(local, extra, data->length);
 
 	if (res >= 0) {
 		data->length = res;
@@ -3372,7 +3394,7 @@
 	.standard	= (iw_handler *) prism2_handler,
 	.private	= (iw_handler *) prism2_private_handler,
 	.private_args	= (struct iw_priv_args *) prism2_priv,
-	.spy_offset	= offsetof(struct hostap_interface, spy_data),
+	.get_wireless_stats = hostap_get_wireless_stats,
 };
 
 
diff -Nru a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
--- a/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-13 20:56:35 -08:00
+++ b/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-13 20:56:35 -08:00
@@ -924,12 +924,8 @@
 	struct net_device *dev; /* pointer to this device */
 	struct local_info *local; /* pointer to shared private data */
 	struct net_device_stats stats;
-	/* Note: this data area must be at a fixed offset from dev->priv.
-	 * Unfortunately, this model does not fit the current Host AP netdev
-	 * data structure because this should really be in local_into_t that is
-	 * shared by all virtual interfaces. Currently, only the main data
-	 * device (wlan#) is used for iwspy entries. */
 	struct iw_spy_data spy_data; /* iwspy support */
+	struct iw_public_data wireless_data;
 
 	enum {
 		HOSTAP_INTERFACE_MASTER,


-- 
Jouni Malinen                                            PGP id EFC895FA
