From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 1/3] drivers/staging/rtl8187se: Don't pass huge struct by
 value
Date: Sat, 13 Aug 2011 01:04:36 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1108130054220.7387@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	Andrea Merello <andreamrl@tiscali.it>,
	Andre Nogueira <andre.neo.net@gmail.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stefan Weil <weil@mail.berlios.de>,
	Ilia Mirkin <imirkin@alum.mit.edu>, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:22404 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388Ab1HLXE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 19:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Juhl <jj@chaosbits.net>
Date: Sat, 13 Aug 2011 00:51:40 +0200

struct ieee80211_network is fairly large (more than half a kilobyte),
so let's pass a pointer instead of passing the entire structure by
value when ieee80211_is_54g() and ieee80211_is_shortslot() need to
look at a few members.
Also remove parentheses around the values being returned from those
two functions - 'return' is not a function.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/staging/rtl8187se/ieee80211/ieee80211.h    |    4 ++--
 .../rtl8187se/ieee80211/ieee80211_softmac.c        |   14 +++++++-------
 drivers/staging/rtl8187se/r8180_rtl8225z2.c        |    4 ++--
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211.h b/drivers/staging/rtl8187se/ieee80211/ieee80211.h
index e79a7e2..40dd715 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211.h
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211.h
@@ -1339,8 +1339,8 @@ int ieee80211_wx_set_mlme(struct ieee80211_device *ieee,
 
 int ieee80211_wx_set_gen_ie(struct ieee80211_device *ieee, u8 *ie, size_t len);
 /* ieee80211_softmac.c */
-extern short ieee80211_is_54g(struct ieee80211_network net);
-extern short ieee80211_is_shortslot(struct ieee80211_network net);
+extern short ieee80211_is_54g(const struct ieee80211_network *net);
+extern short ieee80211_is_shortslot(const struct ieee80211_network *net);
 extern int ieee80211_rx_frame_softmac(struct ieee80211_device *ieee, struct sk_buff *skb,
 			struct ieee80211_rx_stats *rx_stats, u16 type,
 			u16 stype);
diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c
index 38e67f0..26bacb9 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c
@@ -32,14 +32,14 @@ u8 rsn_authen_cipher_suite[16][4] = {
 	{0x00,0x0F,0xAC,0x05}, //WEP-104
 };
 
-short ieee80211_is_54g(struct ieee80211_network net)
+short ieee80211_is_54g(const struct ieee80211_network *net)
 {
-	return ((net.rates_ex_len > 0) || (net.rates_len > 4));
+	return (net->rates_ex_len > 0) || (net->rates_len > 4);
 }
 
-short ieee80211_is_shortslot(struct ieee80211_network net)
+short ieee80211_is_shortslot(const struct ieee80211_network *net)
 {
-	return (net.capability & WLAN_CAPABILITY_SHORT_SLOT);
+	return net->capability & WLAN_CAPABILITY_SHORT_SLOT;
 }
 
 /* returns the total length needed for pleacing the RATE MFIE
@@ -789,7 +789,7 @@ static struct sk_buff* ieee80211_probe_resp(struct ieee80211_device *ieee, u8 *d
 	else
 		atim_len = 0;
 
-	if(ieee80211_is_54g(ieee->current_network))
+	if(ieee80211_is_54g(&ieee->current_network))
 		erp_len = 3;
 	else
 		erp_len = 0;
@@ -1258,7 +1258,7 @@ void ieee80211_associate_complete_wq(struct work_struct *work)
 	struct ieee80211_device *ieee = container_of(work, struct ieee80211_device, associate_complete_wq);
 
 	printk(KERN_INFO "Associated successfully\n");
-	if(ieee80211_is_54g(ieee->current_network) &&
+	if(ieee80211_is_54g(&ieee->current_network) &&
 		(ieee->modulation & IEEE80211_OFDM_MODULATION)){
 
 		ieee->rate = 540;
@@ -1379,7 +1379,7 @@ inline void ieee80211_softmac_new_net(struct ieee80211_device *ieee, struct ieee
 				ieee->beinretry = false;
 				queue_work(ieee->wq, &ieee->associate_procedure_wq);
 			}else{
-				if(ieee80211_is_54g(ieee->current_network) &&
+				if(ieee80211_is_54g(&ieee->current_network) &&
 						(ieee->modulation & IEEE80211_OFDM_MODULATION)){
 					ieee->rate = 540;
 					printk(KERN_INFO"Using G rates\n");
diff --git a/drivers/staging/rtl8187se/r8180_rtl8225z2.c b/drivers/staging/rtl8187se/r8180_rtl8225z2.c
index 3f09f76..ee5b867 100644
--- a/drivers/staging/rtl8187se/r8180_rtl8225z2.c
+++ b/drivers/staging/rtl8187se/r8180_rtl8225z2.c
@@ -596,7 +596,7 @@ static void rtl8225_rf_set_chan(struct net_device *dev, short ch)
 {
 	struct r8180_priv *priv = ieee80211_priv(dev);
 	short gset = (priv->ieee80211->state == IEEE80211_LINKED &&
-		ieee80211_is_54g(priv->ieee80211->current_network)) ||
+		ieee80211_is_54g(&priv->ieee80211->current_network)) ||
 		priv->ieee80211->iw_mode == IW_MODE_MONITOR;
 
 	rtl8225_SetTXPowerLevel(dev, ch);
@@ -615,7 +615,7 @@ static void rtl8225_rf_set_chan(struct net_device *dev, short ch)
 	}
 
 	if (priv->ieee80211->state == IEEE80211_LINKED &&
-	    ieee80211_is_shortslot(priv->ieee80211->current_network))
+	    ieee80211_is_shortslot(&priv->ieee80211->current_network))
 		write_nic_byte(dev, SLOT, 0x9);
 	else
 		write_nic_byte(dev, SLOT, 0x14);
-- 
1.7.6


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

