From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 2.6.18] WE-21 for bcm43xx (wireless-2.6 git)
Date: Wed, 30 Aug 2006 15:01:22 -0700
Message-ID: <20060830220122.GA10367@bougret.hpl.hp.com>
References: <20060830011211.GO8405@bougret.hpl.hp.com> <200608301451.05697.mb@bu3sch.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:48106 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S932150AbWH3WBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 18:01:36 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200608301451.05697.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2006 at 02:51:05PM +0200, Michael Buesch wrote:
> On Wednesday 30 August 2006 03:12, Jean Tourrilhes wrote:
> >         Hi,
> > 
> >         WE-21 for Broadcom driver and SoftMAC...
> > 	This version is for wireless-2.6 git.
> > 
> >         Jean
> > 
> > Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>
> 
> Signed-off-by: Michael Buesch <mb@bu3sch.de>
> 
> Next time CC Larry Finger <Larry.Finger@lwfinger.net>,
> as he is the bcm43xx-softmac maintainer, please.

	This is the version of the patch for out-of-tree, I guess you
will need it. Not tested.

	Regards,

	Jean

-------------------------------------------------------------

diff -u -p linux/net/ieee80211/softmac/ieee80211softmac_wx.20.c linux/net/ieee80211/softmac/ieee80211softmac_wx.c
--- linux/net/ieee80211/softmac/ieee80211softmac_wx.20.c	2006-08-29 14:45:56.000000000 -0700
+++ linux/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-08-30 14:56:35.000000000 -0700
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
diff -u -p linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.20.c linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
--- linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.20.c	2006-08-29 14:46:08.000000000 -0700
+++ linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-08-30 14:57:31.000000000 -0700
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
