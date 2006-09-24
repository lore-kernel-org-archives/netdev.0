From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH,RFT] ieee80211: Move IV/ICV stripping into ieee80211_rx
Date: Sun, 24 Sep 2006 23:43:17 +0100 (BST)
Message-ID: <20060924224317.D294E7B40A0@zog.reactivated.net>
Cc: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:14536 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751276AbWIXWnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 18:43:13 -0400
To: netdev@vger.kernel.org
Cc: yi.zhu@intel.com
Cc: jketreno@linux.intel.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a host_strip_iv_icv flag to ieee80211 which indicates that
ieee80211_rx should strip the IV/ICV/other security features from the payload.
This saves on some memmove() calls in the driver and seems like something that
belongs in the stack as it can be used by bcm43xx, ipw2200, and zd1211rw

I need someone to test this on ipw2200 as I don't have the hardware.
As hardware decryption is disabled in bcm43xx I'm guessing that the code doesn't
work yet? Either way I have added in the necessary changes should it be
enabled in the future.

This patch also adds some sensible variable reuse (idx vs keyidx) in
ieee80211_rx

Signed-off-by: Daniel Drake <dsd@gentoo.org>

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
@@ -544,25 +544,6 @@ int bcm43xx_rx(struct bcm43xx_private *b
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
Index: linux/drivers/net/wireless/ipw2200.c
===================================================================
--- linux.orig/drivers/net/wireless/ipw2200.c
+++ linux/drivers/net/wireless/ipw2200.c
@@ -7499,45 +7499,6 @@ static void ipw_bg_associate(void *data)
 	mutex_unlock(&priv->mutex);
 }
 
-static void ipw_rebuild_decrypted_skb(struct ipw_priv *priv,
-				      struct sk_buff *skb)
-{
-	struct ieee80211_hdr *hdr;
-	u16 fc;
-
-	hdr = (struct ieee80211_hdr *)skb->data;
-	fc = le16_to_cpu(hdr->frame_ctl);
-	if (!(fc & IEEE80211_FCTL_PROTECTED))
-		return;
-
-	fc &= ~IEEE80211_FCTL_PROTECTED;
-	hdr->frame_ctl = cpu_to_le16(fc);
-	switch (priv->ieee->sec.level) {
-	case SEC_LEVEL_3:
-		/* Remove CCMP HDR */
-		memmove(skb->data + IEEE80211_3ADDR_LEN,
-			skb->data + IEEE80211_3ADDR_LEN + 8,
-			skb->len - IEEE80211_3ADDR_LEN - 8);
-		skb_trim(skb, skb->len - 16);	/* CCMP_HDR_LEN + CCMP_MIC_LEN */
-		break;
-	case SEC_LEVEL_2:
-		break;
-	case SEC_LEVEL_1:
-		/* Remove IV */
-		memmove(skb->data + IEEE80211_3ADDR_LEN,
-			skb->data + IEEE80211_3ADDR_LEN + 4,
-			skb->len - IEEE80211_3ADDR_LEN - 4);
-		skb_trim(skb, skb->len - 8);	/* IV + ICV */
-		break;
-	case SEC_LEVEL_0:
-		break;
-	default:
-		printk(KERN_ERR "Unknow security level %d\n",
-		       priv->ieee->sec.level);
-		break;
-	}
-}
-
 static void ipw_handle_data_packet(struct ipw_priv *priv,
 				   struct ipw_rx_mem_buffer *rxb,
 				   struct ieee80211_rx_stats *stats)
@@ -7571,13 +7532,6 @@ static void ipw_handle_data_packet(struc
 
 	IPW_DEBUG_RX("Rx packet of %d bytes.\n", rxb->skb->len);
 
-	/* HW decrypt will not clear the WEP bit, MIC, PN, etc. */
-	hdr = (struct ieee80211_hdr_4addr *)rxb->skb->data;
-	if (priv->ieee->iw_mode != IW_MODE_MONITOR &&
-	    (is_multicast_ether_addr(hdr->addr1) ?
-	     !priv->ieee->host_mc_decrypt : !priv->ieee->host_decrypt))
-		ipw_rebuild_decrypted_skb(priv, rxb->skb);
-
 	if (!ieee80211_rx(priv->ieee, rxb->skb, stats))
 		priv->ieee->stats.rx_errors++;
 	else {			/* ieee80211_rx succeeded, so it now owns the SKB */
@@ -11573,6 +11527,8 @@ static int ipw_pci_probe(struct pci_dev 
 	priv->ieee->perfect_rssi = -20;
 	priv->ieee->worst_rssi = -85;
 
+	priv->ieee->host_strip_iv_icv = 1;
+
 	net_dev->open = ipw_net_open;
 	net_dev->stop = ipw_net_stop;
 	net_dev->init = ipw_net_init;
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
Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -4034,6 +4034,9 @@ static int bcm43xx_init_private(struct b
 	bcm->ieee->host_build_iv = 0;
 	bcm->ieee->host_encrypt = 1;
 	bcm->ieee->host_decrypt = 1;
+
+	/* required when hardware decryption is enabled */
+	/* bcm->ieee->host_strip_iv_icv = 1; */
 	
 	bcm->ieee->iw_mode = BCM43xx_INITIAL_IWMODE;
 	bcm->ieee->tx_headroom = sizeof(struct bcm43xx_txhdr);
