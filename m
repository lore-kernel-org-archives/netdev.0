From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] ieee80211: Drop and count duplicate data frames to remove
	'replay detected' log messages
Date: Tue, 03 Oct 2006 18:49:32 -0500
Message-ID: <4522F70C.mailLS51WH3IW@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

In the SoftMAC version of the IEEE 802.11 stack, not all duplicate messages are
detected. For the most part, there is no difficulty; however ifor TKIP and CCMP
encryption, the duplicates result in a "replay detected" log message where the
received and previous values of the TSC are identical. This change adds a new
variable to the ieee80211_device structure that holds the 'seq_ctl' value for
the previous frame. When a new frame repeats the value, the frame is dropped and
the appropriate counter is incremented.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

This patch replaces the one that I originally sent on 9/25. This version logs the
dropped packets, which addresses the objections to the previous one.

Larry


Index: wireless-2.6/net/ieee80211/ieee80211_rx.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/ieee80211_rx.c
+++ wireless-2.6/net/ieee80211/ieee80211_rx.c
@@ -479,6 +479,11 @@ int ieee80211_rx(struct ieee80211_device
 			goto rx_exit;
 	}
 #endif
+	/* drop duplicate 802.11 retransmissions (IEEE 802.11 Chap. 9.29) */
+	if (sc == ieee->prev_seq_ctl)
+		goto rx_dropped;
+	else
+		ieee->prev_seq_ctl = sc;
 
 	/* Data frame - extract src/dst addresses */
 	if (skb->len < IEEE80211_3ADDR_LEN)
Index: wireless-2.6/include/net/ieee80211.h
===================================================================
--- wireless-2.6.orig/include/net/ieee80211.h
+++ wireless-2.6/include/net/ieee80211.h
@@ -1076,6 +1076,8 @@ struct ieee80211_device {
 	int perfect_rssi;
 	int worst_rssi;
 
+	u16 prev_seq_ctl;	/* used to drop duplicate frames */
+
 	/* Callback functions */
 	void (*set_security) (struct net_device * dev,
 			      struct ieee80211_security * sec);
