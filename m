From: Hong Liu <hong.liu@intel.com>
Subject: Re: [patch] ieee80211: fix not allocating IV+ICV space when
	usingencryption in ieee80211_tx_frame
Date: Wed, 21 Jun 2006 11:35:08 +0800
Message-ID: <1150860908.26493.379.camel@devlinux-hong>
References: <1150770394.26493.47.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-2nWZ8MEn8UF5OpwUQMY2"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10654 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751956AbWFUDfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 23:35:04 -0400
To: linville@tuxdriver.com
In-Reply-To: <1150770394.26493.47.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-2nWZ8MEn8UF5OpwUQMY2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2006-06-20 at 10:26, Hong Liu wrote:
> We should preallocate IV+ICV space when encrypting the frame.
> Currently no problem shows up just because dev_alloc_skb aligns the
> data len to SMP_CACHE_BYTES which can be used for ICV.
> 
> Thanks,
> Hong
> 

Please apply this new patch.
The previous patch has a problem when security is not set.


--=-2nWZ8MEn8UF5OpwUQMY2
Content-Disposition: attachment; filename=ieee80211-1.1.14-newtxfix.patch
Content-Type: text/x-patch; name=ieee80211-1.1.14-newtxfix.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urp a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
--- a/net/ieee80211/ieee80211_tx.c	2006-06-20 09:36:13.000000000 +0800
+++ b/net/ieee80211/ieee80211_tx.c	2006-06-21 11:22:56.000000000 +0800
@@ -562,10 +562,13 @@ int ieee80211_tx_frame(struct ieee80211_
 	struct net_device_stats *stats = &ieee->stats;
 	struct sk_buff *skb_frag;
 	int priority = -1;
+	int fraglen = total_len;
+	int headroom = ieee->tx_headroom;
+	struct ieee80211_crypt_data *crypt = ieee->crypt[ieee->tx_keyidx];
 
 	spin_lock_irqsave(&ieee->lock, flags);
 
-	if (encrypt_mpdu && !ieee->sec.encrypt)
+	if (encrypt_mpdu && (!ieee->sec.encrypt || !crypt))
 		encrypt_mpdu = 0;
 
 	/* If there is no driver handler to take the TXB, dont' bother
@@ -581,20 +584,24 @@ int ieee80211_tx_frame(struct ieee80211_
 		goto success;
 	}
 
-	if (encrypt_mpdu)
+	if (encrypt_mpdu) {
 		frame->frame_ctl |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
+		fraglen += crypt->ops->extra_mpdu_prefix_len +
+			   crypt->ops->extra_mpdu_postfix_len;
+		headroom += crypt->ops->extra_mpdu_prefix_len;
+	}
 
 	/* When we allocate the TXB we allocate enough space for the reserve
 	 * and full fragment bytes (bytes_per_frag doesn't include prefix,
 	 * postfix, header, FCS, etc.) */
-	txb = ieee80211_alloc_txb(1, total_len, ieee->tx_headroom, GFP_ATOMIC);
+	txb = ieee80211_alloc_txb(1, fraglen, headroom, GFP_ATOMIC);
 	if (unlikely(!txb)) {
 		printk(KERN_WARNING "%s: Could not allocate TXB\n",
 		       ieee->dev->name);
 		goto failed;
 	}
 	txb->encrypted = 0;
-	txb->payload_size = total_len;
+	txb->payload_size = fraglen;
 
 	skb_frag = txb->fragments[0];
 

--=-2nWZ8MEn8UF5OpwUQMY2--
