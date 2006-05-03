From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH wireless-dev] d80211: Add support for user space client MLME
Date: Wed, 3 May 2006 11:35:24 -0700
Message-ID: <20060503183524.GD10524@instant802.com>
References: <20060503164458.GB10524@instant802.com> <20060503201059.58477ea6@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-6.dex002.intermedia.net ([64.78.21.22]:1446 "EHLO
	dhost002-6.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1750710AbWECSfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 14:35:30 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060503201059.58477ea6@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 03, 2006 at 08:10:59PM +0200, Jiri Benc wrote:

> If you really feel this is a necessary feature (although I think we
> should focus more on putting the stack to a form suitable for inclusion
> in the kernel than on adding new features now), what about making the
> wmaster0ap interface appear only when the device is switched to user
> space MLME? Should I make a patch?

I think it would be nice to get this in so that both client and AP modes
can use the same mechanism (user space MLME); hostapd already needs this
wmaster0ap interface. In other words, if we do not want to see that
interface by default, we could just add a generic mechanism for
registering wmaster0ap that both hostapd and wpa_supplicant could use.
The Host AP driver (driver/net/wireless/hostap) is doing this with
PRISM2_PARAM_HOSTAPD parameter. I don't care how it's done, but some
simple mechanism would be preferred.

> I had in mind cards with large parts of MLME implemented in their
> firmware, when MLME is moved from the stack fully to userspace. Such
> cards probably won't allow you to handle e. g. scanning by switching
> channels and sending probe requests. I know, we're not going to support
> them soon, but isn't this something that will disallow the suppport at
> all?

No, move of MLME to user space should not change this at all. As an
example, wpa_supplicant supports both cases and the patch I'm working on
for getting Prism2 (full MAC for client mode) working with d80211 is
modifying the kernel side to allow this to be done. Both changes are
touching the same areas in the code, but there is no major change in
whether fullmac can be supported or not.

> > Some time ago, I sent a preliminary patch showing what kind of changes
> > are needed and this was mainly avoiding calls to some ieee80211_sta.c
> > functions.
> 
> Hm, I probably missed that patch (or maybe just can't remember). Could
> you post a link or something?

http://hostap.epitest.fi/releases/testing/jkm-wireless-dev-patches.tar.gz

That is not up-to-date with wireless-dev.git anymore, though. The key
patch is d80211_fullmac_client.diff which is small enough to include
here. Please note that this is not yet complete, so consider it more an
example on what type of changes are needed.


d80211: Add support for hardware-based client MLME (fullmac)

Add support for using hardware/firmware-based client MLME (fullmac) into
the Devicescape IEEE 802.11 stack. This adds a new flag, hw_client_mlme,
for the low-level drivers to indicate that the client MLME (management
frame processing) is implemented in hardware/firmware. This disables
host-based MLME implementation for client mode.

In addition to changes in net/d80211, this patch fixes client mode for
the Prism2/2.5/3 driver in drivers/net/wireless/d80211 by using the new
mode of implementing client MLME in firmware. AP mode (Host AP) is still
using host-based MLME.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


Index: wireless-dev/drivers/net/wireless/d80211/prism3_hw.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/prism3_hw.c
+++ wireless-dev/drivers/net/wireless/d80211/prism3_hw.c
@@ -2931,6 +2931,7 @@ static struct ieee80211_hw prism3_hw = {
 	.version = IEEE80211_VERSION,
 	.name = "prism3",
 	.host_broadcast_ps_buffering = 1,
+	.hw_client_mlme = 1,
 	.num_modes = 1,
 	.num_modes = NUM_ENTRIES(prism3_hw_modes),
 	.modes = prism3_hw_modes,
Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h
+++ wireless-dev/include/net/d80211.h
@@ -441,7 +441,11 @@ struct ieee80211_hw {
 
 	/* 1 = low-level driver supports skb fraglist (NETIF_F_FRAGLIST), i.e.,
 	 * more than one skb per frame */
-	unsigned int fraglist;
+	unsigned int fraglist:1;
+
+	/* 0 = client MLME in host software (softmac)
+	 * 1 = client MLME in hardware/firmware (fullmac) */
+	unsigned int hw_client_mlme:1;
 
         /* This is the time in us to change channels
          */
Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -1028,10 +1028,16 @@ static int ieee80211_ioctl_scan_req(stru
 	u8 *pos = param->u.scan_req.ssid;
 	int left = param_len - ((u8 *) pos - (u8 *) param);
 	int len = param->u.scan_req.ssid_len;
+	struct ieee80211_local *local = dev->priv;
 
 	if (left < len || len > IEEE80211_MAX_SSID_LEN)
 		return -EINVAL;
 
+	if (local->hw->hw_client_mlme) {
+		/* TODO: add local->hw->scan_req() */
+		return 0;
+	}
+
 	return ieee80211_sta_req_scan(dev, pos, len);
 }
 
@@ -1053,10 +1059,17 @@ static int ieee80211_ioctl_mlme(struct n
 				struct prism2_hostapd_param *param)
 {
 	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_local *local = dev->priv;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
 		return -EINVAL;
+
+	if (local->hw->hw_client_mlme) {
+		/* TODO: add local->hw->mlme() */
+		return 0;
+	}
+
 	switch (param->u.mlme.cmd) {
 	case MLME_STA_DEAUTH:
 		ieee80211_sta_deauthenticate(dev, param->u.mlme.reason_code);
@@ -1116,7 +1129,8 @@ static int ieee80211_set_gen_ie(struct n
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA)
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA &&
+	    !local->hw->hw_client_mlme)
 		return ieee80211_sta_set_extra_ie(dev, ie, len);
 
 	kfree(local->conf.generic_elem);
@@ -1783,7 +1797,8 @@ static int ieee80211_ioctl_siwessid(stru
 		len--;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA)
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA &&
+	    !local->hw->hw_client_mlme)
 		return ieee80211_sta_set_ssid(dev, ssid, len);
 
 	kfree(local->conf.ssid);
@@ -1806,7 +1821,8 @@ static int ieee80211_ioctl_giwessid(stru
 
 	struct ieee80211_sub_if_data *sdata;
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA) {
+	if (sdata->type == IEEE80211_SUB_IF_TYPE_STA &&
+	    !local->hw->hw_client_mlme) {
 		int res = ieee80211_sta_get_ssid(dev, ssid, &len);
 		if (res == 0)
 			data->length = len;
@@ -1841,6 +1857,8 @@ static int ieee80211_ioctl_siwap(struct 
 			printk(KERN_DEBUG "%s: Failed to config new BSSID to "
 			       "the low-level driver\n", dev->name);
 		}
+		if (local->hw->hw_client_mlme)
+			return 0;
 		return ieee80211_sta_set_bssid(dev, (u8 *) &ap_addr->sa_data);
 	}
 
@@ -1877,6 +1895,11 @@ static int ieee80211_ioctl_siwscan(struc
 		ssid = local->conf.ssid;
 		ssid_len = local->conf.ssid_len;
 	}
+	if (local->hw->hw_client_mlme) {
+		/* TODO: add local->hw->scan_req() */
+		return 0;
+	}
+
 	return ieee80211_sta_req_scan(dev, ssid, ssid_len);
 }
 
@@ -1887,6 +1910,13 @@ static int ieee80211_ioctl_giwscan(struc
 {
 	int res;
 	struct ieee80211_local *local = dev->priv;
+
+	if (local->hw->hw_client_mlme) {
+		/* TODO: add local->hw->get_scan() */
+		data->length = 0;
+		return 0;
+	}
+
 	if (local->sta_scanning)
 		return -EAGAIN;
 	res = ieee80211_sta_scan_results(dev, extra, IW_SCAN_MAX_DATA);
@@ -2692,6 +2722,7 @@ static int ieee80211_ioctl_siwmlme(struc
 				   struct iw_request_info *info,
 				   struct iw_point *data, char *extra)
 {
+	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
 	struct iw_mlme *mlme = (struct iw_mlme *) extra;
 
@@ -2699,6 +2730,11 @@ static int ieee80211_ioctl_siwmlme(struc
 	if (sdata->type != IEEE80211_SUB_IF_TYPE_STA)
 		return -EINVAL;
 
+	if (local->hw->hw_client_mlme) {
+		/* TODO: add local->hw->mlme() */
+		return 0;
+	}
+
 	switch (mlme->cmd) {
 	case IW_MLME_DEAUTH:
 		/* TODO: mlme->addr.sa_data */


-- 
Jouni Malinen                                            PGP id EFC895FA
