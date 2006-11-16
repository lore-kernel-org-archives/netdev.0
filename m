From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH]: bcm43xx-d80211: fix hwcrypto issues (mcast)
Date: Thu, 16 Nov 2006 15:07:33 +0100
Message-ID: <200611161507.33971.mb@bu3sch.de>
References: <ej09qf$2nv$1@sea.gmane.org> <200611120934.28133.mb@bu3sch.de>
	<20061114142959.GA17486@keitarou>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul TBBle Hampson <Paul.Hampson-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
In-Reply-To: <20061114142959.GA17486@keitarou>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This fixes various bcm43xx-d80211 hwcrypto issues,
which mainly prevented mcast frames from being decrypted properly.

This is mostly a rewrite of the key managing code.
Note that after this patch v3 firmware is no longer supported.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-11-14 16:03:00.000000000 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-11-14 18:34:14.000000000 +0100
@@ -620,7 +620,6 @@ struct bcm43xx_stats {
 
 struct bcm43xx_key {
 	u8 enabled;
-	u8 used;
 	u8 algorithm;
 	u8 address[6];
 };
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-11-14 16:03:00.000000000 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-11-15 18:58:51.000000000 +0100
@@ -874,11 +874,12 @@ static void keymac_write(struct bcm43xx_
 {
 	u32 addrtmp[2];
 
+	assert(index >= 4 + 4);
+	memcpy(bcm->key[index].address, addr, 6);
 	/* We have two default TX keys and two default RX keys.
 	 * Physical mac 0 is mapped to physical key 8.
 	 * So we must adjust the index here.
 	 */
-	assert(index >= 4 + 4);
 	index -= 8;
 
 	addrtmp[0] = addr[0];
@@ -912,97 +913,88 @@ static void keymac_write(struct bcm43xx_
 	}
 }
 
-static int key_write_common(struct bcm43xx_private *bcm,
-			    u8 index, u8 algorithm,
-			    struct ieee80211_key_conf *keyconf,
-			    const u8 *mac_addr)
+static void do_key_write(struct bcm43xx_private *bcm,
+			 u8 index, u8 algorithm,
+			 const u8 *key, size_t key_len,
+			 const u8 *mac_addr)
 {
 	u8 buf[BCM43xx_SEC_KEYSIZE];
 
-	/* The "index" passed to this function is the
-	 * absolute key table index.
-	 */
-
-	if ((index >= bcm->max_nr_keys) ||
-	    (keyconf && (keyconf->keylen > BCM43xx_SEC_KEYSIZE)))
-		return -EINVAL;
+	assert(index < bcm->max_nr_keys);
+	assert(key_len <= BCM43xx_SEC_KEYSIZE);
 
 	memset(buf, 0, sizeof(buf));
-	if (mac_addr)
+	if (index >= 8)
 		keymac_write(bcm, index, buf); /* First zero out mac. */
-	if (keyconf)
-		memcpy(buf, keyconf->key, keyconf->keylen);
+	memcpy(buf, key, key_len);
 	key_write(bcm, index, algorithm, buf);
-	if (mac_addr)
+	if (index >= 8)
 		keymac_write(bcm, index, mac_addr);
-	bcm->key[index].algorithm = algorithm;
-	bcm->key[index].used = 1;
-	bcm->key[index].enabled = 1;
-	if (mac_addr)
-		memcpy(bcm->key[index].address, mac_addr, 6);
-	else
-		memset(bcm->key[index].address, 0, 6);
 
-	return 0;
+	bcm->key[index].algorithm = algorithm;
 }
 
-static int bcm43xx_default_key_write(struct bcm43xx_private *bcm,
-				     u8 index, u8 algorithm,
-				     struct ieee80211_key_conf *key)
+static int bcm43xx_key_write(struct bcm43xx_private *bcm,
+			     int index, u8 algorithm,
+			     const u8 *key, size_t key_len,
+			     const u8 *mac_addr,
+			     struct ieee80211_key_conf *keyconf)
 {
-	int err;
+	int i;
 
-	if (index > 3)
+	if (key_len > BCM43xx_SEC_KEYSIZE)
 		return -EINVAL;
+	if (index < 0) {
+		/* Per station key with associated MAC address.
+		 * Look if it already exists, if yes update, otherwise
+		 * allocate a new key.
+		 */
+		for (i = 8; i < bcm->max_nr_keys; i++) {
+			if (compare_ether_addr(bcm->key[i].address, mac_addr) == 0) {
+				/* found existing */
+				index = i;
+				break;
+			}
+		}
+		if (index < 0) {
+			for (i = 8; i < bcm->max_nr_keys; i++) {
+				if (!bcm->key[i].enabled) {
+					/* found empty */
+					index = i;
+					break;
+				}
+			}
+		}
+		if (index < 0) {
+			dprintk(KERN_ERR PFX "Out of hw key memory\n");
+			return -ENOBUFS;
+		}
+	} else
+		assert(index <= 3);
 
-	/* Write default TX key */
-	err = key_write_common(bcm, index, algorithm,
-			       key, NULL);
-	if (err)
-		return err;
-	/* Write default RX key */
-	err = key_write_common(bcm, index + 4, algorithm,
-			       key, NULL);
-	key->hw_key_idx = index;
-
-	return err;
-}
-
-static int bcm43xx_key_write(struct bcm43xx_private *bcm,
-			     u8 algorithm,
-			     struct ieee80211_key_conf *key,
-			     const u8 *mac_addr)
-{
-	int err;
-	u8 index;
-
-	for (index = 4 + 4; index < bcm->max_nr_keys; index++) {
-		if (!bcm->key[index].used)
-			break;
+	do_key_write(bcm, index, algorithm, key, key_len, mac_addr);
+	if (index <= 3) {
+		/* Default RX key */
+		assert(mac_addr == NULL);
+		do_key_write(bcm, index + 4, algorithm, key, key_len, NULL);
 	}
-	if (index >= bcm->max_nr_keys)
-		return -ENOBUFS;
+	keyconf->hw_key_idx = index;
 
-	err = key_write_common(bcm, index, algorithm,
-			       key, mac_addr);
-	key->hw_key_idx = index;
-
-	return err;
+	return 0;
 }
 
 static void bcm43xx_clear_keys(struct bcm43xx_private *bcm)
 {
-	static const u8 zero[6] = { 0 };
+	static const u8 zero[BCM43xx_SEC_KEYSIZE] = { 0 };
 	unsigned int i;
 
+	BUILD_BUG_ON(BCM43xx_SEC_KEYSIZE < ETH_ALEN);
 	for (i = 0; i < bcm->max_nr_keys; i++) {
-		key_write_common(bcm, i, 0, NULL,
-				 (i >= 4 + 4) ? zero : NULL);
-		bcm->key[i].used = 0;
+		do_key_write(bcm, i, BCM43xx_SEC_ALGO_NONE,
+			     zero, BCM43xx_SEC_KEYSIZE,
+			     zero);
 		bcm->key[i].enabled = 0;
-		bcm->key[i].algorithm = 0;
 	}
-	dprintk(KERN_INFO PFX "Keys cleared\n");
 }
 
 /* http://bcm-specs.sipsolutions.net/80211CoreReset */
@@ -1928,9 +1920,15 @@ static int bcm43xx_upload_microcode(stru
 	fwtime = bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
 				    BCM43xx_SHM_SH_UCODETIME);
 
-	phy->fw = BCM43xx_FW_3;
-	if (fwrev > 0x128)
-		phy->fw = BCM43xx_FW_4;
+	phy->fw = BCM43xx_FW_4;
+	if (fwrev <= 0x128) {
+		printk(KERN_ERR PFX "YOUR FIRMWARE IS TOO OLD. Firmware from "
+		       "binary drivers older than version 4.x is unsupported. "
+		       "You must upgrade your firmware files.\n");
+		bcm43xx_write32(bcm->wlcore, BCM43xx_MMIO_STATUS_BITFIELD, 0);
+		err = -EOPNOTSUPP;
+		goto out;
+	}
 	printk(KERN_DEBUG PFX "firmware revision %X, patchlevel %X, "
 			      "date 20%.2i-%.2i-%.2i %.2i:%.2i:%.2i\n",
 	       fwrev, fwpatch,
@@ -3630,7 +3628,6 @@ static int bcm43xx_net_set_key(struct ne
 	u8 algorithm;
 	u8 index;
 	int err = -EINVAL;
-	int i;
 
 	switch (key->alg) {
 	case ALG_NONE:
@@ -3665,33 +3662,33 @@ static int bcm43xx_net_set_key(struct ne
 		err = -ENODEV;
 		goto out_unlock;
 	}
-	if (bcm43xx_current_phy(bcm)->fw == BCM43xx_FW_3) {
-		/* No support for HW-crypto with v3 firmware. */
-		key->force_sw_encrypt = 1;
-		err = 0;
-		goto out_unlock;
-	}
 
 	switch (cmd) {
 	case SET_KEY:
+		key->force_sw_encrypt = 0;
 
 		if (algorithm == BCM43xx_SEC_ALGO_TKIP) {
 			/* FIXME: No TKIP hardware encryption for now. */
-			err = 0;
 			key->force_sw_encrypt = 1;
-			goto out_unlock;
+			algorithm = BCM43xx_SEC_ALGO_NONE;
 		}
 
 		if (is_broadcast_ether_addr(addr)) {
 			/* addr is FF:FF:FF:FF:FF:FF for default keys */
-			err = bcm43xx_default_key_write(bcm, index,
-							algorithm, key);
+			err = bcm43xx_key_write(bcm, index, algorithm,
+						key->key, key->keylen,
+						NULL, key);
 		} else {
-			err = bcm43xx_key_write(bcm, algorithm, key,
-						addr);
+			err = bcm43xx_key_write(bcm, -1, algorithm,
+						key->key, key->keylen,
+						addr, key);
 		}
-		if (err)
+		if (err) {
+			key->force_sw_encrypt = 1;
 			goto out_unlock;
+		}
+		bcm->key[key->hw_key_idx].enabled = 1;
+
 		if (algorithm == BCM43xx_SEC_ALGO_WEP40 ||
 		    algorithm == BCM43xx_SEC_ALGO_WEP104) {
 			bcm43xx_hf_write(bcm,
@@ -3702,21 +3699,23 @@ static int bcm43xx_net_set_key(struct ne
 					 bcm43xx_hf_read(bcm) &
 					 ~BCM43xx_HF_USEDEFKEYS);
 		}
-		key->force_sw_encrypt = 0;
 		break;
-	case DISABLE_KEY:
+	case DISABLE_KEY: {
+		static const u8 zero[BCM43xx_SEC_KEYSIZE] = { 0 };
+
+		algorithm = BCM43xx_SEC_ALGO_NONE;
 		if (is_broadcast_ether_addr(addr)) {
-			err = key_write_common(bcm, index, 0, NULL, NULL);
+			err = bcm43xx_key_write(bcm, index, algorithm,
+						zero, BCM43xx_SEC_KEYSIZE,
+						NULL, key);
 		} else {
-			static const u8 zero[6] = { 0 };
-
-			for (i = 8; i < bcm->max_nr_keys; i++) {
-				if (compare_ether_addr(bcm->key[i].address, addr) != 0)
-					continue;
-				err = key_write_common(bcm, i, 0, NULL, zero);
-			}
+			err = bcm43xx_key_write(bcm, -1, algorithm,
+						zero, BCM43xx_SEC_KEYSIZE,
+						addr, key);
 		}
+		bcm->key[key->hw_key_idx].enabled = 0;
 		break;
+	}
 	case REMOVE_ALL_KEYS:
 		bcm43xx_clear_keys(bcm);
 		err = 0;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c	2006-11-14 16:03:00.000000000 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c	2006-11-15 18:16:18.000000000 +0100
@@ -405,7 +405,6 @@ static void generate_txhdr_fw4(struct bc
 
 		assert(key_idx < bcm->max_nr_keys);
 		key = &(bcm->key[key_idx]);
-		assert(key->used);
 
 		if (key->enabled) {
 			/* Hardware appends ICV. */
@@ -648,34 +647,45 @@ void bcm43xx_rx(struct bcm43xx_private *
 
 	if ((macstat & BCM43xx_RX_MAC_DEC) &&
 	    !(macstat & BCM43xx_RX_MAC_DECERR)) {
+		unsigned int keyidx;
 		int wlhdr_len;
 		int iv_len;
 		int icv_len;
 
-		/* Remove PROTECTED flag to mark it as decrypted. */
-		assert(fctl & IEEE80211_FCTL_PROTECTED);
-		fctl &= ~IEEE80211_FCTL_PROTECTED;
-		wlhdr->frame_control = cpu_to_le16(fctl);
-
-		wlhdr_len = ieee80211_get_hdrlen(fctl);
-		if (skb->data[wlhdr_len + 3] & (1 << 5)) {
-			/* The Ext-IV Bit is set in the "KeyID"
-			 * octet of the IV.
-			 */
-			iv_len = 8;
-			icv_len = 8;
-		} else {
-			iv_len = 4;
-			icv_len = 4;
-		}
+		keyidx = ((macstat & BCM43xx_RX_MAC_KEYIDX)
+			  >> BCM43xx_RX_MAC_KEYIDX_SHIFT);
+		/* We must adjust the key index here. We want the "physical"
+		 * key index, but the ucode passed it slightly different.
+		 */
+		keyidx += 4;
+		assert((keyidx >= 4) && (keyidx < bcm->max_nr_keys));
+
+		if (bcm->key[keyidx].algorithm != BCM43xx_SEC_ALGO_NONE) {
+			/* Remove PROTECTED flag to mark it as decrypted. */
+			assert(fctl & IEEE80211_FCTL_PROTECTED);
+			fctl &= ~IEEE80211_FCTL_PROTECTED;
+			wlhdr->frame_control = cpu_to_le16(fctl);
+
+			wlhdr_len = ieee80211_get_hdrlen(fctl);
+			if (skb->data[wlhdr_len + 3] & (1 << 5)) {
+				/* The Ext-IV Bit is set in the "KeyID"
+				 * octet of the IV.
+				 */
+				iv_len = 8;
+				icv_len = 8;
+			} else {
+				iv_len = 4;
+				icv_len = 4;
+			}
 
-		/* Remove the IV */
-		memmove(skb->data + iv_len, skb->data, wlhdr_len);
-		skb_pull(skb, iv_len);
-		/* Remove the ICV */
-		skb_trim(skb, skb->len - icv_len);
+			/* Remove the IV */
+			memmove(skb->data + iv_len, skb->data, wlhdr_len);
+			skb_pull(skb, iv_len);
+			/* Remove the ICV */
+			skb_trim(skb, skb->len - icv_len);
 
-		status.flag |= RX_FLAG_DECRYPTED;
+			status.flag |= RX_FLAG_DECRYPTED;
+		}
 	}
 
 	status.signal = bcm43xx_rssi_postprocess(bcm, jssi,


-- 
Greetings Michael.
