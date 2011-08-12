From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 2/3] drivers/staging/rtl8192e: Don't pass huge struct by
 value
Date: Sat, 13 Aug 2011 01:04:45 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1108130058310.7387@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	Mike McCormack <mikem@ring3k.org>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stefan Weil <weil@mail.berlios.de>,
	Andrea Merello <andreamrl@tiscali.it>, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Sat, 13 Aug 2011 00:52:32 +0200

struct ieee80211_network is fairly large (more than half a kilobyte),
so let's pass a pointer instead of passing the entire structure by
value when ieee80211_is_54g() and ieee80211_is_shortslot() need to
look at a few members.
Also remove parentheses around the values being returned from those
two functions - 'return' is not a function.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/staging/rtl8192e/ieee80211/ieee80211.h     |    4 ++--
 .../staging/rtl8192e/ieee80211/ieee80211_softmac.c |   14 +++++++-------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/rtl8192e/ieee80211/ieee80211.h b/drivers/staging/rtl8192e/ieee80211/ieee80211.h
index 6d7963e..abc7a1b 100644
--- a/drivers/staging/rtl8192e/ieee80211/ieee80211.h
+++ b/drivers/staging/rtl8192e/ieee80211/ieee80211.h
@@ -2425,8 +2425,8 @@ int ieee80211_wx_set_mlme(struct ieee80211_device *ieee,
 int ieee80211_wx_set_gen_ie(struct ieee80211_device *ieee, u8 *ie, size_t len);
 
 /* ieee80211_softmac.c */
-short ieee80211_is_54g(struct ieee80211_network net);
-short ieee80211_is_shortslot(struct ieee80211_network net);
+short ieee80211_is_54g(const struct ieee80211_network *net);
+short ieee80211_is_shortslot(const struct ieee80211_network *net);
 int ieee80211_rx_frame_softmac(struct ieee80211_device *ieee, struct sk_buff *skb,
 			struct ieee80211_rx_stats *rx_stats, u16 type,
 			u16 stype);
diff --git a/drivers/staging/rtl8192e/ieee80211/ieee80211_softmac.c b/drivers/staging/rtl8192e/ieee80211/ieee80211_softmac.c
index 60e9a09..4a5e9b2 100644
--- a/drivers/staging/rtl8192e/ieee80211/ieee80211_softmac.c
+++ b/drivers/staging/rtl8192e/ieee80211/ieee80211_softmac.c
@@ -33,14 +33,14 @@ u8 rsn_authen_cipher_suite[16][4] = {
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
+	return (net->capability & WLAN_CAPABILITY_SHORT_SLOT);
 }
 
 /* returns the total length needed for pleacing the RATE MFIE
@@ -723,7 +723,7 @@ static struct sk_buff* ieee80211_probe_resp(struct ieee80211_device *ieee, u8 *d
 	else
 		atim_len = 0;
 
-	if(ieee80211_is_54g(ieee->current_network))
+	if(ieee80211_is_54g(&ieee->current_network))
 		erp_len = 3;
 	else
 		erp_len = 0;
@@ -1351,7 +1351,7 @@ void ieee80211_associate_complete_wq(struct work_struct *work)
         struct ieee80211_device *ieee = container_of(work, struct ieee80211_device, associate_complete_wq);
 	printk(KERN_INFO "Associated successfully\n");
 	ieee->is_roaming = false;
-	if(ieee80211_is_54g(ieee->current_network) &&
+	if(ieee80211_is_54g(&ieee->current_network) &&
 		(ieee->modulation & IEEE80211_OFDM_MODULATION)){
 
 		ieee->rate = 108;
@@ -1504,7 +1504,7 @@ inline void ieee80211_softmac_new_net(struct ieee80211_device *ieee, struct ieee
 					ieee->state = IEEE80211_ASSOCIATING;
 					queue_work(ieee->wq, &ieee->associate_procedure_wq);
 				}else{
-					if(ieee80211_is_54g(ieee->current_network) &&
+					if(ieee80211_is_54g(&ieee->current_network) &&
 						(ieee->modulation & IEEE80211_OFDM_MODULATION)){
 						ieee->rate = 108;
 						ieee->SetWirelessMode(ieee, IEEE_G);
-- 
1.7.6


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
