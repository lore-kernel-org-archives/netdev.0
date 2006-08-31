From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] Wireless-2.6 changes for bcm43xx and SoftMAC for WE-21
Date: Thu, 31 Aug 2006 10:01:39 -0500
Message-ID: <44F6F9D3.1090605@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

As discussed earlier, here is the wireless-2.6 patch for WE-21 in bcm43xx-softmac. The core patch 
for the SSID length, which I believe is non-controversial, must be applied first.

Larry

------------------------------------------------------

Patch to make bcm43xx-softmac be compatible with the revised SSID length of WE-21.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>


Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_wx.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -80,10 +80,10 @@ ieee80211softmac_wx_set_essid(struct net
  	 * If it's our network, ignore the change, we're already doing it!
  	 */
  	if((sm->associnfo.associating || sm->associated) &&
-	   (data->essid.flags && data->essid.length && extra)) {
+	   (data->essid.flags && data->essid.length)) {
  		/* Get the associating network */
  		n = ieee80211softmac_get_network_by_bssid(sm, sm->associnfo.bssid);
-		if(n && n->essid.len == (data->essid.length - 1) &&
+		if(n && n->essid.len == data->essid.length &&
  		   !memcmp(n->essid.data, extra, n->essid.len)) {
  			dprintk(KERN_INFO PFX "Already associating or associated to "MAC_FMT"\n",
  				MAC_ARG(sm->associnfo.bssid));
@@ -109,8 +109,8 @@ ieee80211softmac_wx_set_essid(struct net
  	sm->associnfo.static_essid = 0;
  	sm->associnfo.assoc_wait = 0;

-	if (data->essid.flags && data->essid.length && extra /*required?*/) {
-		length = min(data->essid.length - 1, IW_ESSID_MAX_SIZE);
+	if (data->essid.flags && data->essid.length) {
+		length = min((int) data->essid.length, IW_ESSID_MAX_SIZE);
  		if (length) {
  			memcpy(sm->associnfo.req_essid.data, extra, length);
  			sm->associnfo.static_essid = 1;
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -334,7 +334,7 @@ static int bcm43xx_wx_get_nick(struct ne
  	size_t len;

  	mutex_lock(&bcm->mutex);
-	len = strlen(bcm->nick) + 1;
+	len = strlen(bcm->nick);
  	memcpy(extra, bcm->nick, len);
  	data->data.length = (__u16)len;
  	data->data.flags = 1;
