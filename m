From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] softmac: complete shared key authentication
Date: Thu,  1 Jun 2006 15:34:26 +0100 (BST)
Message-ID: <20060601143426.EE30089CF47@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:64950 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1750997AbWFAOea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 10:34:30 -0400
To: linville@tuxdriver.com
Cc: johannes@sipsolutions.net
Cc: ipw2100-admin@linux.intel.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch finishes of the partially-complete shared key authentication
implementation in softmac. 

The complication here is that we need to encrypt a management frame during
the authentication process. I don't think there are any other scenarios where
this would have to happen.

To get around this without causing too many headaches, we decided to just use
software encryption for this frame. The softmac config option now selects
IEEE80211_CRYPT_WEP so that we can ensure this available. This also involved
a modification to some otherwise unused ieee80211 API.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Acked-by: Johannes Berg <johannes@sipsolutions.net>

Index: linux/net/ieee80211/softmac/ieee80211softmac_auth.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -107,6 +107,7 @@ ieee80211softmac_auth_queue(void *data)
 	printkl(KERN_WARNING PFX "Authentication timed out with "MAC_FMT"\n", MAC_ARG(net->bssid));
 	/* Remove this item from the queue */
 	spin_lock_irqsave(&mac->lock, flags);
+	net->authenticating = 0;
 	ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_AUTH_TIMEOUT, net);
 	cancel_delayed_work(&auth->work); /* just to make sure... */
 	list_del(&auth->list);
@@ -212,13 +213,13 @@ ieee80211softmac_auth_resp(struct net_de
 			aq->state = IEEE80211SOFTMAC_AUTH_SHARED_RESPONSE; 
 			spin_unlock_irqrestore(&mac->lock, flags);
 
-			/* Switch to correct channel for this network */
-			mac->set_channel(mac->dev, net->channel);
-			
-			/* Send our response (How to encrypt?) */
+			/* Send our response */
 			ieee80211softmac_send_mgt_frame(mac, aq->net, IEEE80211_STYPE_AUTH, aq->state);
-			break;
+			return 0;
 		case IEEE80211SOFTMAC_AUTH_SHARED_PASS:
+			kfree(net->challenge);
+			net->challenge = NULL;
+			net->challenge_len = 0;
 			/* Check the status code of the response */
 			switch(auth->status) {
 			case WLAN_STATUS_SUCCESS:
@@ -229,6 +230,7 @@ ieee80211softmac_auth_resp(struct net_de
 				spin_unlock_irqrestore(&mac->lock, flags);
 				printkl(KERN_NOTICE PFX "Shared Key Authentication completed with "MAC_FMT"\n", 
 					MAC_ARG(net->bssid));
+				ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_AUTHENTICATED, net);
 				break;
 			default:
 				printkl(KERN_NOTICE PFX "Shared Key Authentication with "MAC_FMT" failed, error code: %i\n", 
Index: linux/net/ieee80211/softmac/ieee80211softmac_io.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_io.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_io.c
@@ -268,26 +268,27 @@ ieee80211softmac_reassoc_req(struct ieee
 static u32
 ieee80211softmac_auth(struct ieee80211_auth **pkt, 
 	struct ieee80211softmac_device *mac, struct ieee80211softmac_network *net,
-	u16 transaction, u16 status)
+	u16 transaction, u16 status, int *encrypt_mpdu)
 {
 	u8 *data;
+	int auth_mode = mac->ieee->sec.auth_mode;
+	int is_shared_response = (auth_mode == WLAN_AUTH_SHARED_KEY
+		&& transaction == IEEE80211SOFTMAC_AUTH_SHARED_RESPONSE);
+
 	/* Allocate Packet */
 	(*pkt) = (struct ieee80211_auth *)ieee80211softmac_alloc_mgt(
 		2 +		/* Auth Algorithm */
 		2 +		/* Auth Transaction Seq */
 		2 +		/* Status Code */
 		 /* Challenge Text IE */
-		mac->ieee->open_wep ? 0 : 
-		1 + 1 + WLAN_AUTH_CHALLENGE_LEN
-	);	
+		is_shared_response ? 0 : 1 + 1 + net->challenge_len
+	);
 	if (unlikely((*pkt) == NULL))
 		return 0;
 	ieee80211softmac_hdr_3addr(mac, &((*pkt)->header), IEEE80211_STYPE_AUTH, net->bssid, net->bssid);
 		
 	/* Algorithm */
-	(*pkt)->algorithm = mac->ieee->open_wep ? 
-		cpu_to_le16(WLAN_AUTH_OPEN) :
-		cpu_to_le16(WLAN_AUTH_SHARED_KEY);
+	(*pkt)->algorithm = cpu_to_le16(auth_mode);
 	/* Transaction */
 	(*pkt)->transaction = cpu_to_le16(transaction);
 	/* Status */
@@ -295,18 +296,20 @@ ieee80211softmac_auth(struct ieee80211_a
 	
 	data = (u8 *)(*pkt)->info_element;
 	/* Challenge Text */
-	if(!mac->ieee->open_wep){
+	if (is_shared_response) {
 		*data = MFIE_TYPE_CHALLENGE;
 		data++;
 		
 		/* Copy the challenge in */
-		// *data = challenge length
-		// data += sizeof(u16);
-		// memcpy(data, challenge, challenge length);
-		// data += challenge length;
-		
-		/* Add the full size to the packet length */
-	}
+		*data = net->challenge_len;
+		data++;
+		memcpy(data, net->challenge, net->challenge_len);
+		data += net->challenge_len;
+
+		/* Make sure this frame gets encrypted with the shared key */
+		*encrypt_mpdu = 1;
+	} else
+		*encrypt_mpdu = 0;
 
 	/* Return the packet size */
 	return (data - (u8 *)(*pkt));
@@ -396,6 +399,7 @@ ieee80211softmac_send_mgt_frame(struct i
 {
 	void *pkt = NULL;
 	u32 pkt_size = 0;
+	int encrypt_mpdu = 0;
 
 	switch(type) {
 	case IEEE80211_STYPE_ASSOC_REQ:
@@ -405,7 +409,7 @@ ieee80211softmac_send_mgt_frame(struct i
 		pkt_size = ieee80211softmac_reassoc_req((struct ieee80211_reassoc_request **)(&pkt), mac, (struct ieee80211softmac_network *)ptrarg);
 		break;
 	case IEEE80211_STYPE_AUTH:
-		pkt_size = ieee80211softmac_auth((struct ieee80211_auth **)(&pkt), mac, (struct ieee80211softmac_network *)ptrarg, (u16)(arg & 0xFFFF), (u16) (arg >> 16));
+		pkt_size = ieee80211softmac_auth((struct ieee80211_auth **)(&pkt), mac, (struct ieee80211softmac_network *)ptrarg, (u16)(arg & 0xFFFF), (u16) (arg >> 16), &encrypt_mpdu);
 		break;
 	case IEEE80211_STYPE_DISASSOC:
 	case IEEE80211_STYPE_DEAUTH:
@@ -434,7 +438,8 @@ ieee80211softmac_send_mgt_frame(struct i
 	 * or get rid of it alltogether?
 	 * Does this work for you now?
 	 */
-	ieee80211_tx_frame(mac->ieee, (struct ieee80211_hdr *)pkt, pkt_size);
+	ieee80211_tx_frame(mac->ieee, (struct ieee80211_hdr *)pkt,
+		IEEE80211_3ADDR_LEN, pkt_size, encrypt_mpdu);
 
 	kfree(pkt);
 	return 0;
@@ -479,7 +484,7 @@ ieee80211softmac_send_ctl_frame(struct i
 		return -ENOMEM;
 	
 	/* Send the packet to the ieee80211 layer for tx */
-	ieee80211_tx_frame(mac->ieee, (struct ieee80211_hdr *) pkt, pkt_size);
+	ieee80211_tx_frame(mac->ieee, (struct ieee80211_hdr *) pkt, IEEE80211_2ADDR_LEN, pkt_size, 0);
 
 	kfree(pkt);
 	return 0;
Index: linux/include/net/ieee80211.h
===================================================================
--- linux.orig/include/net/ieee80211.h
+++ linux/include/net/ieee80211.h
@@ -1241,7 +1241,8 @@ extern int ieee80211_set_encryption(stru
 extern int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev);
 extern void ieee80211_txb_free(struct ieee80211_txb *);
 extern int ieee80211_tx_frame(struct ieee80211_device *ieee,
-			      struct ieee80211_hdr *frame, int len);
+			      struct ieee80211_hdr *frame, int hdr_len,
+			      int total_len, int encrypt_mpdu);
 
 /* ieee80211_rx.c */
 extern int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
Index: linux/net/ieee80211/ieee80211_tx.c
===================================================================
--- linux.orig/net/ieee80211/ieee80211_tx.c
+++ linux/net/ieee80211/ieee80211_tx.c
@@ -516,7 +516,8 @@ int ieee80211_xmit(struct sk_buff *skb, 
 /* Incoming 802.11 strucure is converted to a TXB
  * a block of 802.11 fragment packets (stored as skbs) */
 int ieee80211_tx_frame(struct ieee80211_device *ieee,
-		       struct ieee80211_hdr *frame, int len)
+		       struct ieee80211_hdr *frame, int hdr_len, int total_len,
+		       int encrypt_mpdu)
 {
 	struct ieee80211_txb *txb = NULL;
 	unsigned long flags;
@@ -526,6 +527,9 @@ int ieee80211_tx_frame(struct ieee80211_
 
 	spin_lock_irqsave(&ieee->lock, flags);
 
+	if (encrypt_mpdu && !ieee->sec.encrypt)
+		encrypt_mpdu = 0;
+
 	/* If there is no driver handler to take the TXB, dont' bother
 	 * creating it... */
 	if (!ieee->hard_start_xmit) {
@@ -533,32 +537,41 @@ int ieee80211_tx_frame(struct ieee80211_
 		goto success;
 	}
 
-	if (unlikely(len < 24)) {
+	if (unlikely(total_len < 24)) {
 		printk(KERN_WARNING "%s: skb too small (%d).\n",
-		       ieee->dev->name, len);
+		       ieee->dev->name, total_len);
 		goto success;
 	}
 
+	if (encrypt_mpdu)
+		frame->frame_ctl |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
+
 	/* When we allocate the TXB we allocate enough space for the reserve
 	 * and full fragment bytes (bytes_per_frag doesn't include prefix,
 	 * postfix, header, FCS, etc.) */
-	txb = ieee80211_alloc_txb(1, len, ieee->tx_headroom, GFP_ATOMIC);
+	txb = ieee80211_alloc_txb(1, total_len, ieee->tx_headroom, GFP_ATOMIC);
 	if (unlikely(!txb)) {
 		printk(KERN_WARNING "%s: Could not allocate TXB\n",
 		       ieee->dev->name);
 		goto failed;
 	}
 	txb->encrypted = 0;
-	txb->payload_size = len;
+	txb->payload_size = total_len;
 
 	skb_frag = txb->fragments[0];
 
-	memcpy(skb_put(skb_frag, len), frame, len);
+	memcpy(skb_put(skb_frag, total_len), frame, total_len);
 
 	if (ieee->config &
 	    (CFG_IEEE80211_COMPUTE_FCS | CFG_IEEE80211_RESERVE_FCS))
 		skb_put(skb_frag, 4);
 
+	/* To avoid overcomplicating things, we do the corner-case frame
+	 * encryption in software. The only real situation where encryption is
+	 * needed here is during software-based shared key authentication. */
+	if (encrypt_mpdu)
+		ieee80211_encrypt_fragment(ieee, skb_frag, hdr_len);
+
       success:
 	spin_unlock_irqrestore(&ieee->lock, flags);
 
Index: linux/net/ieee80211/softmac/Kconfig
===================================================================
--- linux.orig/net/ieee80211/softmac/Kconfig
+++ linux/net/ieee80211/softmac/Kconfig
@@ -2,6 +2,7 @@ config IEEE80211_SOFTMAC
 	tristate "Software MAC add-on to the IEEE 802.11 networking stack"
 	depends on IEEE80211 && EXPERIMENTAL
 	select WIRELESS_EXT
+	select IEEE80211_CRYPT_WEP
 	---help---
 	This option enables the hardware independent software MAC addon
 	for the IEEE 802.11 networking stack.
