From: Hong Liu <hong.liu@intel.com>
Subject: [patch] ieee80211: fix not allocating IV+ICV space when using
	encryption in ieee80211_tx_frame
Date: Tue, 20 Jun 2006 10:26:34 +0800
Message-ID: <1150770394.26493.47.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Iq1B+ccUxPbLLPJRn002"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52235 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S965013AbWFTC01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 22:26:27 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Iq1B+ccUxPbLLPJRn002
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

We should preallocate IV+ICV space when encrypting the frame.
Currently no problem shows up just because dev_alloc_skb aligns the
data len to SMP_CACHE_BYTES which can be used for ICV.

Thanks,
Hong

--=-Iq1B+ccUxPbLLPJRn002
Content-Disposition: attachment; filename=ieee80211-1.1.14-newtxfix.patch
Content-Type: text/x-patch; name=ieee80211-1.1.14-newtxfix.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urp a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
--- a/net/ieee80211/ieee80211_tx.c	2006-06-20 09:36:13.000000000 +0800
+++ b/net/ieee80211/ieee80211_tx.c	2006-06-20 09:32:39.000000000 +0800
@@ -562,10 +562,12 @@ int ieee80211_tx_frame(struct ieee80211_
 	struct net_device_stats *stats = &ieee->stats;
 	struct sk_buff *skb_frag;
 	int priority = -1;
+	int fraglen = total_len;
+	struct ieee80211_crypt_data *crypt = ieee->crypt[ieee->tx_keyidx];
 
 	spin_lock_irqsave(&ieee->lock, flags);
 
-	if (encrypt_mpdu && !ieee->sec.encrypt)
+	if (encrypt_mpdu && (!ieee->sec.encrypt || !crypt))
 		encrypt_mpdu = 0;
 
 	/* If there is no driver handler to take the TXB, dont' bother
@@ -581,20 +583,25 @@ int ieee80211_tx_frame(struct ieee80211_
 		goto success;
 	}
 
-	if (encrypt_mpdu)
+	if (encrypt_mpdu) {
 		frame->frame_ctl |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
+		/* mpdu_prefix_len will be add to the headroom */
+		fraglen += crypt->ops->extra_mpdu_postfix_len;
+	}
 
 	/* When we allocate the TXB we allocate enough space for the reserve
 	 * and full fragment bytes (bytes_per_frag doesn't include prefix,
 	 * postfix, header, FCS, etc.) */
-	txb = ieee80211_alloc_txb(1, total_len, ieee->tx_headroom, GFP_ATOMIC);
+	txb = ieee80211_alloc_txb(1, fraglen, ieee->tx_headroom +
+				  crypt->ops->extra_mpdu_prefix_len,
+				  GFP_ATOMIC);
 	if (unlikely(!txb)) {
 		printk(KERN_WARNING "%s: Could not allocate TXB\n",
 		       ieee->dev->name);
 		goto failed;
 	}
 	txb->encrypted = 0;
-	txb->payload_size = total_len;
+	txb->payload_size = fraglen;
 
 	skb_frag = txb->fragments[0];
 

--=-Iq1B+ccUxPbLLPJRn002--
