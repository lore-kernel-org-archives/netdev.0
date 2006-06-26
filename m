From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] Convert bcm43xx-softmac to use the ieee80211_is_valid_channel
 routine
Date: Sun, 25 Jun 2006 21:32:21 -0500
Message-ID: <449F4735.9000808@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:26058 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751414AbWFZCc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jun 2006 22:32:29 -0400
To: netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de,
	John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current version of bcm43xx-softmac uses local routines to check if a channel is valid. As noted 
in the comments, these routines do not take any regulatory information into account. This patch 
converts the code to use the equivalent routine in ieee80211, which is being converted to know about 
regulatory information.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.h b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
index 30a202b..1164936 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
@@ -112,30 +112,6 @@ int bcm43xx_channel_to_freq(struct bcm43
	return bcm43xx_channel_to_freq_bg(channel);
  }

-/* Lightweight function to check if a channel number is valid.
- * Note that this does _NOT_ check for geographical restrictions!
- */
-static inline
-int bcm43xx_is_valid_channel_a(u8 channel)
-{
-	return (channel >= IEEE80211_52GHZ_MIN_CHANNEL
-	       && channel <= IEEE80211_52GHZ_MAX_CHANNEL);
-}
-static inline
-int bcm43xx_is_valid_channel_bg(u8 channel)
-{
-	return (channel >= IEEE80211_24GHZ_MIN_CHANNEL
-	       && channel <= IEEE80211_24GHZ_MAX_CHANNEL);
-}
-static inline
-int bcm43xx_is_valid_channel(struct bcm43xx_private *bcm,
-			      u8 channel)
-{
-	if (bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_A)
-		return bcm43xx_is_valid_channel_a(channel);
-	return bcm43xx_is_valid_channel_bg(channel);
-}
-
  void bcm43xx_tsf_read(struct bcm43xx_private *bcm, u64 *tsf);
  void bcm43xx_tsf_write(struct bcm43xx_private *bcm, u64 tsf);

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_radio.c b/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
index af5c0bf..3900753 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
@@ -1594,11 +1594,11 @@ int bcm43xx_radio_selectchannel(struct b
	u16 r8, tmp;
	u16 freq;

-	if ((radio->manufact == 0x17F) &&
+	if (!ieee80211_is_valid_channel(bcm->ieee, channel))
+		return -EINVAL;
+	if ((radio->manufact == 0x17F) &&
	    (radio->version == 0x2060) &&
	    (radio->revision == 1)) {
-		if (channel > 200)
-			return -EINVAL;
		freq = channel2freq_a(channel);

		r8 = bcm43xx_radio_read16(bcm, 0x0008);
@@ -1651,9 +1651,6 @@ int bcm43xx_radio_selectchannel(struct b
		TODO(); //TODO: TSSI2dbm workaround
		bcm43xx_phy_xmitpower(bcm);//FIXME correct?
	} else {
-		if ((channel < 1) || (channel > 14))
-			return -EINVAL;
-
		if (synthetic_pu_workaround)
			bcm43xx_synth_pu_workaround(bcm, channel);

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index c35cb3a..5c36e29 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -119,7 +119,7 @@ static int bcm43xx_wx_set_channelfreq(st
		channel = bcm43xx_freq_to_channel(bcm, data->freq.m);
		freq = data->freq.m;
	}
-	if (!bcm43xx_is_valid_channel(bcm, channel))
+	if (!ieee80211_is_valid_channel(bcm->ieee, channel))
		goto out_unlock;
	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
		//ieee80211softmac_disassoc(softmac, $REASON);
