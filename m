From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 9/10] hostap: Filter disconnect events
Date: Sat, 12 Mar 2005 16:35:30 -0800
Message-ID: <20050313003530.GJ8253@jm.kir.nu>
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

Filter out sequential disconnect events to make race condition with
received EAPOL frames less likely to happen (this improves
authentication success rate with some APs that send EAPOL frames very
quickly after the (re)association response).

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_info.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_info.c	2005-03-12 16:10:39.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_info.c	2005-03-12 16:11:01.000000000 -0800
@@ -428,7 +428,16 @@
 		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
 	}
 	wrqu.ap_addr.sa_family = ARPHRD_ETHER;
-	wireless_send_event(local->dev, SIOCGIWAP, &wrqu, NULL);
+
+	/*
+	 * Filter out sequential disconnect events in order not to cause a
+	 * flood of SIOCGIWAP events that have a race condition with EAPOL
+	 * frames and can confuse wpa_supplicant about the current association
+	 * status.
+	 */
+	if (connected || local->prev_linkstatus_connected)
+		wireless_send_event(local->dev, SIOCGIWAP, &wrqu, NULL);
+	local->prev_linkstatus_connected = connected;
 }
 
 
Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_wlan.h
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_wlan.h	2005-03-12 16:10:53.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_wlan.h	2005-03-12 16:11:01.000000000 -0800
@@ -833,6 +833,7 @@
 #define PRISM2_INFO_PENDING_LINKSTATUS 0
 #define PRISM2_INFO_PENDING_SCANRESULTS 1
 	int prev_link_status; /* previous received LinkStatus info */
+	int prev_linkstatus_connected;
 	u8 preferred_ap[6]; /* use this AP if possible */
 
 #ifdef PRISM2_CALLBACK


-- 
Jouni Malinen                                            PGP id EFC895FA
