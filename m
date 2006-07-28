From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Thu, 27 Jul 2006 20:22:11 -0400
Message-ID: <20060728002206.GA11621@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:36361 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750717AbWG1AWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 20:22:33 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 64821324ca49f24be1a66f2f432108f96a24e596:
  Christoph Hellwig:
        fix compile regression for a few scsi drivers

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Chuck Ebbert:
      ieee80211: TKIP requires CRC32

Dan Williams:
      orinoco: fix setting transmit key only

Daniel Drake:
      softmac: do shared key auth in workqueue

Pavel Machek:
      zd1201: workaround interference problem

Robert Schulze:
      airo: should select crypto_aes

 drivers/net/wireless/Kconfig                  |    1 +
 drivers/net/wireless/bcm43xx/bcm43xx_main.c   |    2 +-
 drivers/net/wireless/orinoco.c                |    4 ++--
 drivers/net/wireless/zd1201.c                 |    2 ++
 net/ieee80211/Kconfig                         |    1 +
 net/ieee80211/softmac/ieee80211softmac_auth.c |   28 ++++++++++++++++++++-----
 6 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index fa9d2c4..2e8ac99 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -447,6 +447,7 @@ config AIRO_CS
 	tristate "Cisco/Aironet 34X/35X/4500/4800 PCMCIA cards"
 	depends on NET_RADIO && PCMCIA && (BROKEN || !M32R)
 	select CRYPTO
+	select CRYPTO_AES
 	---help---
 	  This is the standard Linux driver to support Cisco/Aironet PCMCIA
 	  802.11 wireless cards.  This driver is the same as the Aironet
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 3889f79..df317c1 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3701,7 +3701,7 @@ static void bcm43xx_ieee80211_set_securi
 	}
 	if (sec->flags & SEC_AUTH_MODE) {
 		secinfo->auth_mode = sec->auth_mode;
-		dprintk(", .auth_mode = %d\n", sec->auth_mode);
+		dprintk(", .auth_mode = %d", sec->auth_mode);
 	}
 	dprintk("\n");
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED &&
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index d6ed578..317ace7 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -2875,7 +2875,7 @@ static int orinoco_ioctl_setiwencode(str
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
 
-	if (erq->pointer) {
+	if (erq->length > 0) {
 		if ((index < 0) || (index >= ORINOCO_MAX_KEYS))
 			index = priv->tx_key;
 
@@ -2918,7 +2918,7 @@ static int orinoco_ioctl_setiwencode(str
 	if (erq->flags & IW_ENCODE_RESTRICTED)
 		restricted = 1;
 
-	if (erq->pointer) {
+	if (erq->pointer && erq->length > 0) {
 		priv->keys[index].len = cpu_to_le16(xlen);
 		memset(priv->keys[index].data, 0,
 		       sizeof(priv->keys[index].data));
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 662ecc8..c52e9bc 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -1820,6 +1820,8 @@ static int zd1201_probe(struct usb_inter
 	    zd->dev->name);
 
 	usb_set_intfdata(interface, zd);
+	zd1201_enable(zd);	/* zd1201 likes to startup enabled, */
+	zd1201_disable(zd);	/* interfering with all the wifis in range */
 	return 0;
 
 err_net:
diff --git a/net/ieee80211/Kconfig b/net/ieee80211/Kconfig
index dbb0852..f7e84e9 100644
--- a/net/ieee80211/Kconfig
+++ b/net/ieee80211/Kconfig
@@ -58,6 +58,7 @@ config IEEE80211_CRYPT_TKIP
 	depends on IEEE80211 && NET_RADIO
 	select CRYPTO
 	select CRYPTO_MICHAEL_MIC
+	select CRC32
 	---help---
 	Include software based cipher suites in support of IEEE 802.11i
 	(aka TGi, WPA, WPA2, WPA-PSK, etc.) for use with TKIP enabled
diff --git a/net/ieee80211/softmac/ieee80211softmac_auth.c b/net/ieee80211/softmac/ieee80211softmac_auth.c
index ebc33ca..4cef39e 100644
--- a/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ b/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -116,6 +116,16 @@ ieee80211softmac_auth_queue(void *data)
 	kfree(auth);
 }
 
+/* Sends a response to an auth challenge (for shared key auth). */
+static void
+ieee80211softmac_auth_challenge_response(void *_aq)
+{
+	struct ieee80211softmac_auth_queue_item *aq = _aq;
+
+	/* Send our response */
+	ieee80211softmac_send_mgt_frame(aq->mac, aq->net, IEEE80211_STYPE_AUTH, aq->state);
+}
+
 /* Handle the auth response from the AP
  * This should be registered with ieee80211 as handle_auth 
  */
@@ -197,24 +207,30 @@ ieee80211softmac_auth_resp(struct net_de
 		case IEEE80211SOFTMAC_AUTH_SHARED_CHALLENGE:
 			/* Check to make sure we have a challenge IE */
 			data = (u8 *)auth->info_element;
-			if(*data++ != MFIE_TYPE_CHALLENGE){
+			if (*data++ != MFIE_TYPE_CHALLENGE) {
 				printkl(KERN_NOTICE PFX "Shared Key Authentication failed due to a missing challenge.\n");
 				break;	
 			}
 			/* Save the challenge */
 			spin_lock_irqsave(&mac->lock, flags);
 			net->challenge_len = *data++; 	
-			if(net->challenge_len > WLAN_AUTH_CHALLENGE_LEN)
+			if (net->challenge_len > WLAN_AUTH_CHALLENGE_LEN)
 				net->challenge_len = WLAN_AUTH_CHALLENGE_LEN;
-			if(net->challenge != NULL)
+			if (net->challenge != NULL)
 				kfree(net->challenge);
 			net->challenge = kmalloc(net->challenge_len, GFP_ATOMIC);
 			memcpy(net->challenge, data, net->challenge_len);
 			aq->state = IEEE80211SOFTMAC_AUTH_SHARED_RESPONSE; 
-			spin_unlock_irqrestore(&mac->lock, flags);
 
-			/* Send our response */
-			ieee80211softmac_send_mgt_frame(mac, aq->net, IEEE80211_STYPE_AUTH, aq->state);
+			/* We reuse the work struct from the auth request here.
+			 * It is safe to do so as each one is per-request, and
+			 * at this point (dealing with authentication response)
+			 * we have obviously already sent the initial auth
+			 * request. */
+			cancel_delayed_work(&aq->work);
+			INIT_WORK(&aq->work, &ieee80211softmac_auth_challenge_response, (void *)aq);
+			schedule_work(&aq->work);
+			spin_unlock_irqrestore(&mac->lock, flags);
 			return 0;
 		case IEEE80211SOFTMAC_AUTH_SHARED_PASS:
 			kfree(net->challenge);
-- 
John W. Linville
linville@tuxdriver.com
