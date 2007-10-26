From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH 1] net: fix and typo's
Date: Fri, 26 Oct 2007 19:07:10 +0200
Message-ID: <47221EBE.3070109@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.tiscali.nl ([195.241.79.178]:60717 "EHLO
	smtp-out3.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755175AbXJZR2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 13:28:05 -0400
Received: from [82.171.216.234] (helo=[192.168.1.2])
	by smtp-out3.tiscali.nl with esmtp (Tiscali http://www.tiscali.nl)
	id 1IlSeP-00060e-FA
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 19:07:13 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A few patches with changes to net code. I have sent these to the lkml
previously, but they were not yet merged. I am fairly new to kernel 
programming, so it is possible that I make some mistakes. I'll explain my
rationale, please nack if incorrect, an additional bit of explanation is
appreciated even more.

The condition '!x & y,' does make little sense: the '!' has a higher
priority than '&'. It behaves therefore like '!x && y'. In the case 
bitanding flags, however, '!(x & y)' appears to be desired.

Warning: the change of '!x & y,' to '!(x & y)' may change behavior. if
not desired, I propose changing this to '!x && y', to make it explicitly
clear.

These '&' typo's can be spotted with:
a="A-Za-z0-9_"
git-grep "\![^$a()]*[$a]\+\([$a.]*\|->\)*\(\[[$a.]*\]\)\?[ \W]*&[^&]\+"

--
        Fix priority mistakes similar to '!x & y'
    
        Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index cf70522..14141a5 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -283,7 +283,7 @@ static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
 			adapter->flags &= ~FLAG_HAS_WOL;
 		/* quad ports only support WoL on port A */
 		if (adapter->flags & FLAG_IS_QUAD_PORT &&
-		    (!adapter->flags & FLAG_IS_QUAD_PORT_A))
+		    (!(adapter->flags & FLAG_IS_QUAD_PORT_A)))
 			adapter->flags &= ~FLAG_HAS_WOL;
 		break;
 
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 074055e..e3eca6d 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -6407,7 +6407,7 @@ static int airo_set_encode(struct net_device *dev,
 			set_wep_key(local, index, NULL, 0, perm, 1);
 		} else
 			/* Don't complain if only change the mode */
-			if(!dwrq->flags & IW_ENCODE_MODE) {
+			if(!(dwrq->flags & IW_ENCODE_MODE)) {
 				return -EINVAL;
 			}
 	}
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 059ce3f..57cc7e5 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1759,7 +1759,7 @@ static int atmel_set_encode(struct net_device *dev,
 			priv->default_key = index;
 		} else
 			/* Don't complain if only change the mode */
-			if (!dwrq->flags & IW_ENCODE_MODE) {
+			if (!(dwrq->flags & IW_ENCODE_MODE)) {
 				return -EINVAL;
 			}
 	}
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index c6f5aa3..d93438c 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -1380,7 +1380,7 @@ static int wlan_get_encodeext(struct net_device *dev,
 		index = adapter->wep_tx_keyidx;
 	}
 
-	if (!ext->ext_flags & IW_ENCODE_EXT_GROUP_KEY &&
+	if (!(ext->ext_flags & IW_ENCODE_EXT_GROUP_KEY) &&
 	    ext->alg != IW_ENCODE_ALG_WEP) {
 		if (index != 0 || adapter->mode != IW_MODE_INFRA)
 			goto out;
diff --git a/drivers/net/wireless/p54common.c b/drivers/net/wireless/p54common.c
index 1437db0..8ee1453 100644
--- a/drivers/net/wireless/p54common.c
+++ b/drivers/net/wireless/p54common.c
@@ -374,7 +374,7 @@ static void p54_rx_frame_sent(struct ieee80211_hw *dev, struct sk_buff *skb)
 			if ((entry_hdr->magic1 & cpu_to_le16(0x4000)) != 0)
 				pad = entry_data->align[0];
 
-			if (!status.control.flags & IEEE80211_TXCTL_NO_ACK) {
+			if (!(status.control.flags & IEEE80211_TXCTL_NO_ACK)) {
 				if (!(payload->status & 0x01))
 					status.flags |= IEEE80211_TX_STATUS_ACK;
 				else
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 6d80ca4..b9d0073 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -1118,7 +1118,7 @@ prism54_set_encode(struct net_device *ndev, struct iw_request_info *info,
 			    mgt_set_request(priv, DOT11_OID_DEFKEYID, 0,
 					    &index);
 		} else {
-			if (!dwrq->flags & IW_ENCODE_MODE) {
+			if (!(dwrq->flags & IW_ENCODE_MODE)) {
 				/* we cannot do anything. Complain. */
 				return -EINVAL;
 			}
@@ -2610,7 +2610,7 @@ prism2_ioctl_set_encryption(struct net_device *dev,
 			    mgt_set_request(priv, DOT11_OID_DEFKEYID, 0,
 					    &index);
 		} else {
-			if (!param->u.crypt.flags & IW_ENCODE_MODE) {
+			if (!(param->u.crypt.flags & IW_ENCODE_MODE)) {
 				/* we cannot do anything. Complain. */
 				return -EINVAL;
 			}
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c b/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c
index 857dcf3..3c1cca4 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c
@@ -403,7 +403,7 @@ static int uw2453_init_hw(struct zd_rf *rf)
 		if (r)
 			return r;
 
-		if (!intr_status & 0xf) {
+		if (!(intr_status & 0xf)) {
 			dev_dbg_f(zd_chip_dev(chip),
 				"PLL locked on configuration %d\n", i);
 			found_config = i;
diff --git a/net/ieee80211/ieee80211_wx.c b/net/ieee80211/ieee80211_wx.c
index d309e8f..623489a 100644
--- a/net/ieee80211/ieee80211_wx.c
+++ b/net/ieee80211/ieee80211_wx.c
@@ -709,7 +709,7 @@ int ieee80211_wx_get_encodeext(struct ieee80211_device *ieee,
 	} else
 		idx = ieee->tx_keyidx;
 
-	if (!ext->ext_flags & IW_ENCODE_EXT_GROUP_KEY &&
+	if (!(ext->ext_flags & IW_ENCODE_EXT_GROUP_KEY) &&
 	    ext->alg != IW_ENCODE_ALG_WEP)
 		if (idx != 0 || ieee->iw_mode != IW_MODE_INFRA)
 			return -EINVAL;
