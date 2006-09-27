From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] ieee80211: Move IV/ICV stripping into ieee80211_rx
Date: Wed, 27 Sep 2006 03:50:31 +0100 (BST)
Message-ID: <20060927025031.90F567B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:31908 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932304AbWI0Cui (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 22:50:38 -0400
To: linville@tuxdriver.com
Cc: johannes@sipsolutions.net
Cc: mb@bu3sch.de
Cc: ipw2100-admin@linux.intel.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a host_strip_iv_icv flag to ieee80211 which indicates that
ieee80211_rx should strip the IV/ICV/other security features from the payload.
This saves on some memmove() calls in the driver and seems like something that
belongs in the stack as it can be used by bcm43xx, ipw2200, and zd1211rw

I will submit the ipw2200 patch separately as it needs testing.

This patch also adds some sensible variable reuse (idx vs keyidx) in
ieee80211_rx

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Acked-by: Johannes Berg <johannes@sipsolutions.net>

Index: linux/net/ieee80211/ieee80211_rx.c
===================================================================
--- linux.orig/net/ieee80211/ieee80211_rx.c
+++ linux/net/ieee80211/ieee80211_rx.c
@@ -415,17 +415,16 @@ int ieee80211_rx(struct ieee80211_device
 	    ieee->host_mc_decrypt : ieee->host_decrypt;
 
 	if (can_be_decrypted) {
-		int idx = 0;
 		if (skb->len >= hdrlen + 3) {
 			/* Top two-bits of byte 3 are the key index */
-			idx = skb->data[hdrlen + 3] >> 6;
+			keyidx = skb->data[hdrlen + 3] >> 6;
 		}
 
-		/* ieee->crypt[] is WEP_KEY (4) in length.  Given that idx
-		 * is only allowed 2-bits of storage, no value of idx can
-		 * be provided via above code that would result in idx
+		/* ieee->crypt[] is WEP_KEY (4) in length.  Given that keyidx
+		 * is only allowed 2-bits of storage, no value of keyidx can
+		 * be provided via above code that would result in keyidx
 		 * being out of range */
-		crypt = ieee->crypt[idx];
+		crypt = ieee->crypt[keyidx];
 
 #ifdef NOT_YET
 		sta = NULL;
@@ -655,6 +654,51 @@ int ieee80211_rx(struct ieee80211_device
 		goto rx_dropped;
 	}
 
+	/* If the frame was decrypted in hardware, we may need to strip off
+	 * any security data (IV, ICV, etc) that was left behind */
+	if (!can_be_decrypted && (fc & IEEE80211_FCTL_PROTECTED) &&
+	    ieee->host_strip_iv_icv) {
+	    	int trimlen = 0;
+
+		/* Top two-bits of byte 3 are the key index */
+		if (skb->len >= hdrlen + 3)
+			keyidx = skb->data[hdrlen + 3] >> 6;
+
+		/* To strip off any security data which appears before the
+		 * payload, we simply increase hdrlen (as the header gets
+		 * chopped off immediately below). For the security data which
+		 * appears after the payload, we use skb_trim. */
+
+		switch (ieee->sec.encode_alg[keyidx]) {
+		case SEC_ALG_WEP:
+			/* 4 byte IV */
+			hdrlen += 4;
+			/* 4 byte ICV */
+			trimlen = 4;
+			break;
+		case SEC_ALG_TKIP:
+			/* 4 byte IV, 4 byte ExtIV */
+			hdrlen += 8;
+			/* 8 byte MIC, 4 byte ICV */
+			trimlen = 12;
+			break;
+		case SEC_ALG_CCMP:
+			/* 8 byte CCMP header */
+			hdrlen += 8;
+			/* 8 byte MIC */
+			trimlen = 8;
+			break;
+		}
+
+		if (skb->len < trimlen)
+			goto rx_dropped;
+
+		__skb_trim(skb, skb->len - trimlen);
+
+		if (skb->len < hdrlen)
+			goto rx_dropped;
+	}
+
 	/* skb: hdr + (possible reassembled) full plaintext payload */
 
 	payload = skb->data + hdrlen;
Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
===================================================================
--- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ linux/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -543,25 +543,6 @@ int bcm43xx_rx(struct bcm43xx_private *b
 		break;
 	}
 
-	frame_ctl = le16_to_cpu(wlhdr->frame_ctl);
-	if ((frame_ctl & IEEE80211_FCTL_PROTECTED) && !bcm->ieee->host_decrypt) {
-		frame_ctl &= ~IEEE80211_FCTL_PROTECTED;
-		wlhdr->frame_ctl = cpu_to_le16(frame_ctl);		
-		/* trim IV and ICV */
-		/* FIXME: this must be done only for WEP encrypted packets */
-		if (skb->len < 32) {
-			dprintkl(KERN_ERR PFX "RX packet dropped (PROTECTED flag "
-					      "set and length < 32)\n");
-			return -EINVAL;
-		} else {		
-			memmove(skb->data + 4, skb->data, 24);
-			skb_pull(skb, 4);
-			skb_trim(skb, skb->len - 4);
-			stats.len -= 8;
-		}
-		wlhdr = (struct ieee80211_hdr_4addr *)(skb->data);
-	}
-	
 	switch (WLAN_FC_GET_TYPE(frame_ctl)) {
 	case IEEE80211_FTYPE_MGMT:
 		ieee80211_rx_mgt(bcm->ieee, wlhdr, &stats);
Index: linux/include/net/ieee80211.h
===================================================================
--- linux.orig/include/net/ieee80211.h
+++ linux/include/net/ieee80211.h
@@ -1037,6 +1037,10 @@ struct ieee80211_device {
 	/* host performs multicast decryption */
 	int host_mc_decrypt;
 
+	/* host should strip IV and ICV from protected frames */
+	/* meaningful only when hardware decryption is being used */
+	int host_strip_iv_icv;
+
 	int host_open_frag;
 	int host_build_iv;
 	int ieee802_1x;		/* is IEEE 802.1X used */
Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
===================================================================
--- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -693,6 +693,7 @@ static int bcm43xx_wx_set_swencryption(s
 	bcm->ieee->host_encrypt = !!on;
 	bcm->ieee->host_decrypt = !!on;
 	bcm->ieee->host_build_iv = !on;
+	bcm->ieee->host_strip_iv_icv = !on;
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 	mutex_unlock(&bcm->mutex);
 
