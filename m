From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] WE-21 for bcm43xx (wireless-2.6 git)
Date: Wed, 30 Aug 2006 19:57:20 -0500
Message-ID: <44F633F0.7090605@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
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

John,

Please apply Jean's patch to wireless-2.6. It should apply cleanly to the version you pushed earlier
today (8/30). I have compiled and tested. For complete operation with WE-21, it also needs the patch
entitled [PATCH 2.6.18] WE-21 support (core API) at
(http://www.spinics.net/lists/netdev/msg13599.html). It works without that second patch, just at WE-20.

Thanks,

Larry

-------------------

Patch to update bcm43xx-SoftMAC for WE-21.

Signed-off-by: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

-------------------------------------------------------------

diff -u a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-08-29 14:45:56.000000000 -0700
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-08-30 14:56:35.000000000 -0700
@@ -63,6 +63,12 @@ ieee80211softmac_wx_get_scan_results(str
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_get_scan_results);

+#if WIRELESS_EXT > 20
+#define IW_ESSID_FIX	0
+#else
+#define IW_ESSID_FIX	1
+#endif
+
 int
 ieee80211softmac_wx_set_essid(struct net_device *net_dev,
 			      struct iw_request_info *info,
@@ -80,10 +86,10 @@ ieee80211softmac_wx_set_essid(struct net
 	 * If it's our network, ignore the change, we're already doing it!
 	 */
 	if((sm->associnfo.associating || sm->associated) &&
-	   (data->essid.flags && data->essid.length && extra)) {
+	   (data->essid.flags && data->essid.length)) {
 		/* Get the associating network */
 		n = ieee80211softmac_get_network_by_bssid(sm, sm->associnfo.bssid);
-		if(n && n->essid.len == (data->essid.length - 1) &&
+		if(n && n->essid.len == (data->essid.length - IW_ESSID_FIX) &&
 		   !memcmp(n->essid.data, extra, n->essid.len)) {
 			dprintk(KERN_INFO PFX "Already associating or associated to "MAC_FMT"\n",
 				MAC_ARG(sm->associnfo.bssid));
@@ -109,8 +115,8 @@ ieee80211softmac_wx_set_essid(struct net
 	sm->associnfo.static_essid = 0;
 	sm->associnfo.assoc_wait = 0;

-	if (data->essid.flags && data->essid.length && extra /*required?*/) {
-		length = min(data->essid.length - 1, IW_ESSID_MAX_SIZE);
+	if (data->essid.flags && data->essid.length) {
+		length = min((int) data->essid.length - IW_ESSID_FIX, IW_ESSID_MAX_SIZE);
 		if (length) {
 			memcpy(sm->associnfo.req_essid.data, extra, length);
 			sm->associnfo.static_essid = 1;
diff -u a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-08-29 14:46:08.000000000 -0700
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-08-30 14:57:31.000000000 -0700
@@ -334,7 +334,11 @@ static int bcm43xx_wx_get_nick(struct ne
 	size_t len;

 	mutex_lock(&bcm->mutex);
+#if WIRELESS_EXT > 20
+	len = strlen(bcm->nick);
+#else
 	len = strlen(bcm->nick) + 1;
+#endif
 	memcpy(extra, bcm->nick, len);
 	data->data.length = (__u16)len;
 	data->data.flags = 1;

=======
