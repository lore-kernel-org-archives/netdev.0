From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 02/14] ipw2200: SIOCGIWFREQ ioctl returns frequency rather than channel
Date: Mon, 21 Aug 2006 11:37:01 +0800
Message-ID: <20060821033701.GA5335@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55863 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932578AbWHUDi4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:38:56 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SIOCGIWFREQ ioctl fills the request structure's freq field by setting
the exponent to 0 and the mantissa to the current channel number. The
iwconfig tool works around this behaviour by looking up the frequency
from the channel table if a frequency below 1kHz is returned, other tools
(e.g. kwlaninfo) don't. According to the comment in the iwconfig source
the driver is supposed to return the frequency, not the channel number.

Signed-off-by: Ingo van Lil <inguin@gmx.de>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)

3ca92c3071e7e849d5d9d01f69c44128428dad30
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 89e076f..0b2c774 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -8562,9 +8562,26 @@ static int ipw_wx_get_freq(struct net_de
 	 * configured CHANNEL then return that; otherwise return ANY */
 	mutex_lock(&priv->mutex);
 	if (priv->config & CFG_STATIC_CHANNEL ||
-	    priv->status & (STATUS_ASSOCIATING | STATUS_ASSOCIATED))
-		wrqu->freq.m = priv->channel;
-	else
+	    priv->status & (STATUS_ASSOCIATING | STATUS_ASSOCIATED)) {
+		int i;
+
+		i = ieee80211_channel_to_index(priv->ieee, priv->channel);
+		BUG_ON(i == -1);
+		wrqu->freq.e = 1;
+
+		switch (ieee80211_is_valid_channel(priv->ieee, priv->channel)) {
+		case IEEE80211_52GHZ_BAND:
+			wrqu->freq.m = priv->ieee->geo.a[i].freq * 100000;
+			break;
+
+		case IEEE80211_24GHZ_BAND:
+			wrqu->freq.m = priv->ieee->geo.bg[i].freq * 100000;
+			break;
+
+		default:
+			BUG();
+		}
+	} else
 		wrqu->freq.m = 0;
 
 	mutex_unlock(&priv->mutex);
-- 
1.2.6
