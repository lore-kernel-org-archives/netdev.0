From: matthieu castet <castet.matthieu@free.fr>
Subject: RFC airo : wpa support
Date: Sat, 05 May 2007 00:52:54 +0200
Message-ID: <463BB946.3000807@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040009050904010600000603"
Cc: Dan Williams <dcbw@redhat.com>
To: Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g19.free.fr ([212.27.42.28]:51321 "EHLO smtp2-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767461AbXEDWw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 18:52:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040009050904010600000603
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I attach a diff against 2.6.21 for adding wpa support for airo driver.
In then end of 2005 I manage to make work wpa but the code was really 
ugly. I manage to find some time to clean it.


To support wpa, a new interface of the firmware should be used. This 
interface is incompatible with the old interface and using both 
interface at the same time make the firmware hang.

Porting OPEN and WEP mode to new interface need some driver rewrite, and 
the old interface should be keep for the older cards (or the cards that 
doesn't have newer firmware).
That's why I didn't do it, and I added a module parameter for choosing 
between the old driver behavior (with no wpa support) or the driver with 
wpa only support.


The wireless extension handlers are a bit ugly, I will be very happy, if 
somebody could help me to clean them.

Any comments are appreciated.


Matthieu


PS : the lastest version of the driver can be found in 
http://svn.gna.org/viewcvs/airo-wpa/branches/kernel/

PS2 : There is some remaining trace in the driver for debug purpose, 
that will be removed in the final version

--------------040009050904010600000603
Content-Type: text/x-patch;
 name="airo_wpa.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="airo_wpa.diff"

Index: airo.c
===================================================================
--- airo.c	(revision 16)
+++ airo.c	(working copy)
@@ -16,6 +16,7 @@
     Code was also integrated from the Cisco Aironet driver for Linux.
     Support for MPI350 cards was added by Fabrice Bellet
     <fabrice@bellet.info>.
+    (C) 2005-2007 Matthieu CASTET <castet.matthieu@free.fr> for WPA support
 
 ======================================================================*/
 
@@ -91,6 +92,12 @@
 #include <linux/delay.h>
 #endif
 
+/* enable rx mic checking
+ *disable because it takes some time in ISR
+ * XXX crypto doesn't work anymore in ISR on 2.6.21
+ */
+//#define WPA_CHECK_RX_MIC
+
 /* Hack to do some power saving */
 #define POWER_ON_DOWN
 
@@ -223,6 +230,7 @@
 int maxencrypt /* = 0 */; /* The highest rate that the card can encrypt at.
 		       0 means no limit.  For old cards this was 4 */
 
+static int wpa_enabled; /* If set the card is in WPA mode. This is incompatible with WEP or open mode */
 static int auto_wep /* = 0 */; /* If set, it tries to figure out the wep mode */
 static int aux_bap /* = 0 */; /* Checks to see if the aux ports are needed to read
 		    the bap, needed on some older cards and buses. */
@@ -250,6 +258,9 @@
 module_param_array(rates, int, NULL, 0);
 module_param_array(ssids, charp, NULL, 0);
 module_param(auto_wep, int, 0);
+module_param(wpa_enabled, int, 0);
+MODULE_PARM_DESC(wpa_enabled, "If non-zero, the driver can use WPA \
+but Open and WEP mode won't be possible");
 MODULE_PARM_DESC(auto_wep, "If non-zero, the driver will keep looping through \
 the authentication options until an association is made.  The value of \
 auto_wep is number of the wep keys to check.  A value of 2 will try using \
@@ -452,6 +463,7 @@
 #define RID_UNKNOWN22  0xFF22
 #define RID_LEAPUSERNAME 0xFF23
 #define RID_LEAPPASSWORD 0xFF24
+#define RID_WPA        0xFF25
 #define RID_STATUS     0xFF50
 #define RID_BEACON_HST 0xFF51
 #define RID_BUSY_HST   0xFF52
@@ -506,6 +518,14 @@
 	u8 key[16];
 } WepKeyRid;
 
+typedef struct {
+	u16 len;
+	u16 kindex;
+	u8 mac[ETH_ALEN];
+	u16 klen;
+	u8 key[48];
+} WpaKeyRid;
+
 /* These structures are from the Aironet's PC4500 Developers Manual */
 typedef struct {
 	u16 len;
@@ -525,7 +545,20 @@
 #define MOD_MOK 2
 } ModulationRid;
 
+/* Only present on firmware >= 5.30.17 */
 typedef struct {
+	u16 _reserved5[4];
+	u16 auth_cipher;
+#define AUTH_CIPHER_NONE 1
+#define AUTH_CIPHER_WEP 0xc
+#define AUTH_CIPHER_TKIP 0x210
+	u16 auth_key;
+#define AUTH_KEY_MGMT_NONE 1
+#define AUTH_KEY_MGMT_802_1X 4
+#define AUTH_KEY_MGMT_PSK 8
+} ConfigRidExtra;
+
+typedef struct {
 	u16 len; /* sizeof(ConfigRid) */
 	u16 opmode; /* operating mode */
 #define MODE_STA_IBSS 0
@@ -580,6 +613,7 @@
 #define AUTH_ENCRYPT 0x101
 #define AUTH_SHAREDKEY 0x102
 #define AUTH_ALLOW_UNENCRYPTED 0x200
+#define AUTH_ENCRYPT_WPA 0xc101
 	u16 associationTimeout;
 	u16 specifiedApTimeout;
 	u16 offlineScanInterval;
@@ -643,6 +677,8 @@
 #define MAGIC_STAY_IN_CAM (1<<10)
 	u8 magicControl;
 	u16 autoWake;
+	/* Only present on firmware >= 5.30.17 */
+	ConfigRidExtra extra;
 } ConfigRid;
 
 typedef struct {
@@ -1227,6 +1263,15 @@
 	unsigned int bssListFirst;
 	unsigned int bssListNext;
 	unsigned int bssListRidLen;
+	unsigned int ConfigRidLen;
+	unsigned char wpa_tx_key [8];
+	unsigned char wpa_rx_key [8];
+	unsigned char wpa_rx_key_m [8];
+	unsigned char wpa_rx_key_m_old [8];
+	u8 LLC [10];
+	struct crypto_hash *tfm_michael;
+	int wpa_enabled;
+	int wpa_key_enabled;
 
 	struct list_head network_list;
 	struct list_head network_free_list;
@@ -1723,6 +1768,55 @@
 	digest[3] = val & 0xFF;
 }
 
+static void wpa_compute_mic(struct airo_info *ai ,char *pPacket, u8 *mic, int len, char *key)
+{
+	struct scatterlist sg[3];
+	struct hash_desc desc;
+
+	sg[0].page = virt_to_page(pPacket);
+	sg[0].offset = offset_in_page(pPacket);
+	sg[0].length = sizeof(etherHead);
+
+
+	sg[1].page = virt_to_page(ai->LLC);
+	sg[1].offset = offset_in_page(ai->LLC);
+	sg[1].length = sizeof(ai->LLC);
+
+	sg[2].page = virt_to_page(pPacket + sizeof(etherHead));
+	sg[2].offset = offset_in_page(pPacket + sizeof(etherHead));
+	sg[2].length = len - sizeof(etherHead);
+
+	crypto_hash_setkey(ai->tfm_michael, key, 8);
+
+	desc.tfm = ai->tfm_michael;
+	desc.flags = 0;
+
+	crypto_hash_digest(&desc, sg, len + sizeof(ai->LLC),
+			mic);
+}
+
+#ifdef WPA_CHECK_RX_MIC
+static int wpa_check_rx_mic(struct airo_info *ai ,char *buffer, int len)
+{
+	u8 mic[8];
+	/* multicast */
+	if (buffer[0] & 1) {
+		wpa_compute_mic(ai, buffer, mic, len, ai->wpa_rx_key_m);
+		if (memcmp(mic, buffer + len, 8)) {
+			/* we don't know the current index, try the old one */
+			wpa_compute_mic(ai, buffer, mic, len, ai->wpa_rx_key_m_old);
+			return memcmp(mic, buffer + len, 8);
+		}
+	}
+	else {
+		wpa_compute_mic(ai, buffer, mic, len, ai->wpa_rx_key);
+		return memcmp(mic, buffer + len, 8);
+	}
+	return 0;
+}
+#endif
+
+
 static int readBSSListRid(struct airo_info *ai, int first,
 		      BSSListRid *list) {
 	int rc;
@@ -1786,6 +1880,18 @@
 	return rc;
 }
 
+static int writeWpaKeyRid(struct airo_info*ai, WpaKeyRid *pwkr, int lock) {
+	int rc;
+	WpaKeyRid wkr = *pwkr;
+
+	wkr.len = cpu_to_le16(wkr.len);
+	wkr.kindex = cpu_to_le16(wkr.kindex);
+	wkr.klen = cpu_to_le16(wkr.klen);
+	rc = PC4500_writerid(ai, RID_WPA, &wkr, sizeof(wkr), lock);
+	if (rc!=SUCCESS) airo_print_err(ai->dev->name, "WPA set %x", rc);
+	return rc;
+}
+
 static int readSsidRid(struct airo_info*ai, SsidRid *ssidr) {
 	int i;
 	int rc = PC4500_readrid(ai, RID_SSID, ssidr, sizeof(*ssidr), 1);
@@ -1816,7 +1922,7 @@
 	if (ai->config.len)
 		return SUCCESS;
 
-	rc = PC4500_readrid(ai, RID_ACTUALCONFIG, &cfg, sizeof(cfg), lock);
+	rc = PC4500_readrid(ai, RID_ACTUALCONFIG, &cfg, ai->ConfigRidLen, lock);
 	if (rc != SUCCESS)
 		return rc;
 
@@ -1879,7 +1985,7 @@
 	for(s = &cfgr.autoWake; s <= &cfgr.autoWake; s++)
 		*s = cpu_to_le16(*s);
 
-	return PC4500_writerid( ai, RID_CONFIG, &cfgr, sizeof(cfgr), lock);
+	return PC4500_writerid( ai, RID_CONFIG, &cfgr, ai->ConfigRidLen, lock);
 }
 static int readStatusRid(struct airo_info*ai, StatusRid *statr, int lock) {
 	int rc = PC4500_readrid(ai, RID_STATUS, statr, sizeof(*statr), lock);
@@ -2040,7 +2146,20 @@
 	 * Firmware automaticly puts 802 header on so
 	 * we don't need to account for it in the length
 	 */
-	if (test_bit(FLAG_MIC_CAPABLE, &ai->flags) && ai->micstats.enabled &&
+	if (ai->wpa_key_enabled) {
+		u8 mic [8];
+
+		*payloadLen = cpu_to_le16(len-sizeof(etherHead)+8);
+		ai->txfids[0].tx_desc.len += 8;
+
+		wpa_compute_mic(ai, buffer, mic, len, ai->wpa_tx_key);
+
+		dev->trans_start = jiffies;
+		/* copy data into airo dma buffer */
+		memcpy(sendbuf, buffer, len);
+		memcpy(sendbuf + len, mic, 8);
+	}
+    else if (test_bit(FLAG_MIC_CAPABLE, &ai->flags) && ai->micstats.enabled &&
 		(ntohs(((u16 *)buffer)[6]) != 0x888E)) {
 		MICBuffer pMic;
 
@@ -2434,6 +2553,8 @@
 		}
         }
 	crypto_free_cipher(ai->tfm);
+	if (ai->tfm_michael)
+		crypto_free_hash(ai->tfm_michael);
 	del_airo_dev( dev );
 	free_netdev( dev );
 }
@@ -2770,6 +2891,7 @@
 	if ((cap_rid.softVer > 0x530)
 	  || ((cap_rid.softVer == 0x530) && (cap_rid.softSubVer >= 17))) {
 		airo_print_info(name, "WPA is supported.");
+		airo_print_info(name, "Version 5.41 is recomended");
 		return 1;
 	}
 
@@ -2799,6 +2921,11 @@
 	}
 
 	ai = dev->priv;
+	/* this is needed for initialisation, the firware check will be done
+	 * latter. The windows driver, do it a different way : it reads
+	 * ConfigRid.len .
+	 */
+	ai->ConfigRidLen = sizeof(ConfigRid) - sizeof(ConfigRidExtra);
 	ai->wifidev = NULL;
 	ai->flags = 0;
 	ai->jobs = 0;
@@ -2881,15 +3008,29 @@
 	}
 
 	/* Test for WPA support */
-	if (airo_test_wpa_capable(ai)) {
+	if (airo_test_wpa_capable(ai) && wpa_enabled) {
+		char LLC1 [] = {0, 0, 0, 0, 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00};
 		set_bit(FLAG_WPA_CAPABLE, &ai->flags);
 		ai->bssListFirst = RID_WPA_BSSLISTFIRST;
 		ai->bssListNext = RID_WPA_BSSLISTNEXT;
 		ai->bssListRidLen = sizeof(BSSListRid);
+		ai->ConfigRidLen = sizeof(ConfigRid);
+		memcpy(ai->LLC, LLC1, sizeof(ai->LLC));
+		ai->tfm_michael = crypto_alloc_hash("michael_mic", 0, CRYPTO_ALG_ASYNC);
+		if (ai->tfm_michael == NULL) {
+			printk(KERN_DEBUG "crypto API michael_mic failed. Removing WPA\n");
+		}
+		else {
+			ai->wpa_enabled = 1;
+			/* we don't want to enable wep mode : it will make the firmware 
+			 * hanging */
+			auto_wep = 0;
+		}
 	} else {
 		ai->bssListFirst = RID_BSSLISTFIRST;
 		ai->bssListNext = RID_BSSLISTNEXT;
 		ai->bssListRidLen = sizeof(BSSListRid) - sizeof(BSSListRidExtra);
+		ai->ConfigRidLen = sizeof(ConfigRid) - sizeof(ConfigRidExtra);
 	}
 
 	rc = register_netdev(dev);
@@ -3193,7 +3334,9 @@
 
 		if ( status & EV_MIC ) {
 			OUT4500( apriv, EVACK, EV_MIC );
-			if (test_bit(FLAG_MIC_CAPABLE, &apriv->flags)) {
+			if (apriv->wpa_enabled) {
+			}
+			else if (test_bit(FLAG_MIC_CAPABLE, &apriv->flags)) {
 				set_bit(JOB_MIC, &apriv->jobs);
 				wake_up_interruptible(&apriv->thr_wait);
 			}
@@ -3237,6 +3380,8 @@
 			  leaving BSS */
 #define RC_NOAUTH 9 /* Station requesting (Re)Association is not
 		       Authenticated with the responding station */
+			printk("status : %x\n", newStatus);
+
 			if (newStatus == FORCELOSS && apriv->scan_timeout > 0)
 				scan_forceloss = 1;
 			if(newStatus == ASSOCIATED || newStatus == REASSOCIATED) {
@@ -3363,7 +3508,9 @@
 			} else {
 				MICBuffer micbuf;
 				bap_read (apriv, buffer, ETH_ALEN*2, BAP0);
-				if (apriv->micstats.enabled) {
+				if (apriv->wpa_key_enabled) {
+				}
+				else if (apriv->micstats.enabled) {
 					bap_read (apriv,(u16*)&micbuf,sizeof(micbuf),BAP0);
 					if (ntohs(micbuf.typelen) > 0x05DC)
 						bap_setup (apriv, fid, 0x44, BAP0);
@@ -3376,7 +3523,18 @@
 					}
 				}
 				bap_read(apriv,buffer+ETH_ALEN,len,BAP0);
-				if (decapsulate(apriv,&micbuf,(etherHead*)buffer,len)) {
+				if (apriv->wpa_key_enabled) {
+					len -= 8;
+
+					//this is easy to do, but take some time in ISR
+#ifdef WPA_CHECK_RX_MIC
+					if (wpa_check_rx_mic(apriv, skb->data, len + hdrlen))
+						goto badmic;
+	
+#endif
+					skb_trim (skb, len + hdrlen);
+				}
+				else if (decapsulate(apriv,&micbuf,(etherHead*)buffer,len)) {
 badmic:
 					dev_kfree_skb_irq (skb);
 badrx:
@@ -3607,7 +3765,9 @@
 		}
 		buffer = skb_put(skb,len);
 		memcpy(buffer, ai->rxfids[0].virtual_host_addr, ETH_ALEN * 2);
-		if (ai->micstats.enabled) {
+		if (ai->wpa_key_enabled) {
+		}
+		else if (ai->micstats.enabled) {
 			memcpy(&micbuf,
 				ai->rxfids[0].virtual_host_addr + ETH_ALEN * 2,
 				sizeof(micbuf));
@@ -3622,7 +3782,17 @@
 		memcpy(buffer + ETH_ALEN * 2,
 			ai->rxfids[0].virtual_host_addr + ETH_ALEN * 2 + off,
 			len - ETH_ALEN * 2 - off);
-		if (decapsulate (ai, &micbuf, (etherHead*)buffer, len - off - ETH_ALEN * 2)) {
+		if (ai->wpa_key_enabled) {
+			len -= 8;
+
+#ifdef WPA_CHECK_RX_MIC
+			if (wpa_check_rx_mic(ai, buffer, len))
+				goto badmic;
+#endif
+
+			skb_trim (skb, len);
+		}
+		else if (decapsulate (ai, &micbuf, (etherHead*)buffer, len - off - ETH_ALEN * 2)) {
 badmic:
 			dev_kfree_skb_irq (skb);
 			goto badrx;
@@ -4322,7 +4492,10 @@
 	}
 	len -= ETH_ALEN * 2;
 
-	if (test_bit(FLAG_MIC_CAPABLE, &ai->flags) && ai->micstats.enabled && 
+	if (ai->wpa_key_enabled) {
+		miclen = 8;
+	}
+	else if (test_bit(FLAG_MIC_CAPABLE, &ai->flags) && ai->micstats.enabled && 
 	    (ntohs(((u16 *)pPacket)[6]) != 0x888E)) {
 		if (encapsulate(ai,(etherHead *)pPacket,&pMic,len) != SUCCESS)
 			return ERROR;
@@ -4336,9 +4509,27 @@
 	payloadLen = cpu_to_le16(len + miclen);
 	bap_write(ai, &payloadLen, sizeof(payloadLen),BAP1);
 	bap_write(ai, (const u16*)pPacket, sizeof(etherHead), BAP1);
-	if (miclen)
-		bap_write(ai, (const u16*)&pMic, miclen, BAP1);
-	bap_write(ai, (const u16*)(pPacket + sizeof(etherHead)), len, BAP1);
+	if (ai->wpa_key_enabled) {
+		u8 mic[8];
+
+		wpa_compute_mic(ai, pPacket, mic, len + sizeof(etherHead), ai->wpa_tx_key);
+		//XXX ugly hack because we write per 16 bits packet
+		bap_write(ai, (const u16*)(pPacket + sizeof(etherHead)), len - (len&1), BAP1);
+		if (len&1) {
+			u8 tmp [2];
+			tmp [0] = pPacket [sizeof(etherHead) + len-1];
+			tmp [1] = mic[0];
+			bap_write(ai, (const u16*)tmp, 2, BAP1);
+			bap_write(ai, (const u16*)(mic+1), sizeof(mic)-1, BAP1);
+		}
+		else
+			bap_write(ai, (const u16*)mic, sizeof(mic), BAP1);
+	}
+	else {
+		if (miclen)
+			bap_write(ai, (const u16*)&pMic, miclen, BAP1);
+		bap_write(ai, (const u16*)(pPacket + sizeof(etherHead)), len, BAP1);
+	}
 	// issue the transmit command
 	memset( &cmd, 0, sizeof( cmd ) );
 	cmd.cmd = CMD_TRANSMIT;
@@ -6370,6 +6561,10 @@
 	int perm = ( dwrq->flags & IW_ENCODE_TEMP ? 0 : 1 );
 	u16 currentAuthType = local->config.authType;
 
+	/* In wpa mode, only wpa is allowed */
+	if (local->wpa_enabled)
+		return -EINVAL;
+
 	/* Is WEP supported ? */
 	readCapabilityRid(local, &cap_rid, 1);
 	/* Older firmware doesn't support this...
@@ -6465,6 +6660,7 @@
 	readConfigRid(local, 1);
 	/* Check encryption mode */
 	switch(local->config.authType)	{
+		case AUTH_ENCRYPT_WPA:
 		case AUTH_ENCRYPT:
 			dwrq->flags = IW_ENCODE_OPEN;
 			break;
@@ -6496,6 +6692,85 @@
 /*
  * Wireless Handler : set extended Encryption parameters
  */
+static int airo_set_encodeext_wpa(struct airo_info *local,
+							struct iw_encode_ext *ext,
+							struct iw_point *encoding)
+{
+	static const unsigned char macaddr[ETH_ALEN] = { 0x01, 0, 0, 0, 0, 0 };
+	WpaKeyRid wkr;
+	int index = (encoding->flags & IW_ENCODE_INDEX) - 1;
+
+	printk("set wpa : %d %d %d %x\n", ext->alg, ext->key_len, index, ext->ext_flags);
+
+	memset(&wkr, 0, sizeof(wkr));
+	wkr.len = sizeof(wkr);
+
+	if ((encoding->flags & IW_ENCODE_DISABLED) ||
+			ext->alg == IW_ENCODE_ALG_NONE || ext->key_len == 0) {
+		wkr.kindex = index;
+		memcpy( wkr.mac, macaddr, ETH_ALEN );
+		printk(KERN_INFO "Wpa Removing key %d\n", index);
+		memset(local->wpa_tx_key, 0, 8);
+		memset(local->wpa_rx_key, 0, 8);
+		memset(local->wpa_rx_key_m, 0, 8);
+		memset(local->wpa_rx_key_m_old, 0, 8);
+		local->wpa_key_enabled = 0;
+	}
+	else if (ext->alg == IW_ENCODE_ALG_WEP)
+		return -EOPNOTSUPP;
+	else if (ext->alg == IW_ENCODE_ALG_TKIP && ext->key_len == 32) {
+		// we cannot set a WPA key in a non-WPA mode
+		if (local->config.authType != AUTH_ENCRYPT_WPA)
+			return -EINVAL;
+		wkr.kindex = index;
+		memcpy( wkr.mac, macaddr, ETH_ALEN );
+		wkr.klen = 0x30;
+
+		/* firmware use ndis order + a hole at 16-21 */
+		memcpy(wkr.key, ext->key, 16); /* temporal key */
+		memcpy(wkr.key + 40, ext->key + 16, 8); /*TX*/
+		memcpy(wkr.key + 32, ext->key + 24, 8); /*RX*/
+
+		if (ext->ext_flags & IW_ENCODE_EXT_RX_SEQ_VALID) {
+			memcpy(wkr.key + 22, ext->rx_seq, 6);
+		}
+
+		if (ext->ext_flags & IW_ENCODE_EXT_GROUP_KEY) {
+			memcpy(local->wpa_rx_key_m_old, local->wpa_rx_key_m, 8);
+			memcpy(local->wpa_rx_key_m, ext->key+16, 8);
+		}
+		else {
+			memcpy(local->wpa_tx_key, ext->key+16, 8);
+			memcpy(local->wpa_rx_key, ext->key+24, 8);
+		}
+	}
+	else
+		return -EINVAL;
+
+
+
+	if (down_interruptible(&local->sem))
+		return ERROR;
+
+	writeWpaKeyRid(local, &wkr, 0);
+
+	if (ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY) {
+		memset(&wkr, 0, sizeof(wkr));
+		wkr.len = sizeof(wkr);
+		wkr.kindex = 0xffff;
+		wkr.mac[0] = (char)index;
+		wkr.klen = 0x30;
+
+		printk(KERN_INFO "Setting default tx key to %d\n", index);
+		writeWpaKeyRid(local, &wkr, 0);
+
+		local->wpa_key_enabled = 1;
+	}
+
+	up(&local->sem);
+	return 0;
+}
+
 static int airo_set_encodeext(struct net_device *dev,
 			   struct iw_request_info *info,
 			    union iwreq_data *wrqu,
@@ -6518,6 +6793,8 @@
 	} */
 	readConfigRid(local, 1);
 
+	if (local->wpa_enabled)
+		return airo_set_encodeext_wpa(local, ext, encoding);
 	/* Determine and validate the key index */
 	idx = encoding->flags & IW_ENCODE_INDEX;
 	if (idx) {
@@ -6592,6 +6869,7 @@
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
 	CapabilityRid cap_rid;		/* Card capability info */
 	int idx, max_key_len;
+	printk("get_encode\n");
 
 	/* Is it supported ? */
 	readCapabilityRid(local, &cap_rid, 1);
@@ -6617,6 +6895,7 @@
 
 	/* Check encryption mode */
 	switch(local->config.authType) {
+		case AUTH_ENCRYPT_WPA:
 		case AUTH_ENCRYPT:
 			encoding->flags = IW_ENCODE_ALG_WEP | IW_ENCODE_ENABLED;
 			break;
@@ -6642,6 +6921,20 @@
 }
 
 
+static void wpa_off(struct airo_info *local)
+{
+	printk(KERN_INFO"WPA dis\n");
+	local->config.authType=AUTH_OPEN;
+	local->config.extra.auth_key=AUTH_KEY_MGMT_NONE;
+}
+
+static void wpa_on(struct airo_info *local)
+{
+	printk(KERN_INFO"WPA enable\n");
+	local->config.authType=AUTH_ENCRYPT_WPA;
+	local->config.extra.auth_cipher=AUTH_CIPHER_TKIP;
+	//local->config.extra._reserved5[0]=0x40;
+}
 /*------------------------------------------------------------------*/
 /*
  * Wireless Handler : set extended authentication parameters
@@ -6656,17 +6949,55 @@
 
 	switch (param->flags & IW_AUTH_INDEX) {
 	case IW_AUTH_WPA_VERSION:
+		if (param->value == IW_AUTH_WPA_VERSION_WPA)
+			wpa_on(local);
+		else if (param->value == IW_AUTH_WPA_VERSION_DISABLED)
+			wpa_off(local);
+		else
+			return -EINVAL;
+		break;
 	case IW_AUTH_CIPHER_PAIRWISE:
 	case IW_AUTH_CIPHER_GROUP:
+		if ((param->value == IW_AUTH_CIPHER_TKIP) && (local->config.authType == AUTH_ENCRYPT_WPA))
+			return 0;
+		else if (((param->value == IW_AUTH_CIPHER_WEP40) ||(param->value == IW_AUTH_CIPHER_WEP104))
+				&& (local->config.authType != AUTH_ENCRYPT_WPA))
+			return 0;
+		else if ((param->value == IW_AUTH_CIPHER_NONE) && (local->config.authType != AUTH_ENCRYPT_WPA))
+			local->config.authType = AUTH_OPEN;
+		else
+			return -EINVAL;
+		break;
 	case IW_AUTH_KEY_MGMT:
+		if (local->config.authType != AUTH_ENCRYPT_WPA)
+			return -EINVAL;
+		if (param->value == IW_AUTH_KEY_MGMT_802_1X)
+			local->config.extra.auth_key=AUTH_KEY_MGMT_802_1X;
+		else if (param->value == IW_AUTH_KEY_MGMT_PSK)
+			local->config.extra.auth_key=AUTH_KEY_MGMT_PSK;
+		else
+			return -EINVAL;
+		break;
+	case IW_AUTH_PRIVACY_INVOKED:
+		if (!param->value) {
+			if (local->config.authType == AUTH_ENCRYPT_WPA)
+				wpa_off(local);
+			else
+				wpa_on(local);
+		}
+		else
+			return 0;
+		break;
 	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
-	case IW_AUTH_PRIVACY_INVOKED:
+	case IW_AUTH_TKIP_COUNTERMEASURES:
 		/*
 		 * airo does not use these parameters
 		 */
 		break;
 
 	case IW_AUTH_DROP_UNENCRYPTED:
+		if (local->wpa_enabled)
+			break;
 		if (param->value) {
 			/* Only change auth type if unencrypted */
 			if (currentAuthType == AUTH_OPEN)
@@ -6675,15 +7006,16 @@
 			local->config.authType = AUTH_OPEN;
 		}
 
-		/* Commit the changes to flags if needed */
-		if (local->config.authType != currentAuthType)
-			set_bit (FLAG_COMMIT, &local->flags);
 		break;
 
 	case IW_AUTH_80211_AUTH_ALG: {
 			/* FIXME: What about AUTH_OPEN?  This API seems to
 			 * disallow setting our auth to AUTH_OPEN.
 			 */
+			/* does not make sense with WPA */
+			if (local->config.authType == AUTH_ENCRYPT_WPA)
+				return 0;
+
 			if (param->value & IW_AUTH_ALG_SHARED_KEY) {
 				local->config.authType = AUTH_SHAREDKEY;
 			} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
@@ -6691,21 +7023,20 @@
 			} else
 				return -EINVAL;
 			break;
-
-			/* Commit the changes to flags if needed */
-			if (local->config.authType != currentAuthType)
-				set_bit (FLAG_COMMIT, &local->flags);
 		}
 
 	case IW_AUTH_WPA_ENABLED:
-		/* Silently accept disable of WPA */
-		if (param->value > 0)
-			return -EOPNOTSUPP;
+		if (param->value == 0)
+			wpa_off(local);
+		else
+			wpa_on(local);
 		break;
 
 	default:
 		return -EOPNOTSUPP;
 	}
+
+	set_bit (FLAG_COMMIT, &local->flags);
 	return -EINPROGRESS;
 }
 
@@ -6757,7 +7088,30 @@
 	return 0;
 }
 
+static int airo_disasociate(struct net_device *dev,
+		struct iw_request_info *info,
+		struct iw_point *data, char *extra)
+{
+	struct airo_info *local = dev->priv;
+	Resp rsp;
+	SsidRid SSID_rid;		/* SSIDs */
 
+	/* reset the list */
+	memset(&SSID_rid, 0, sizeof(SSID_rid));
+
+	/* Set the SSID */
+	strcpy(SSID_rid.ssids[0].ssid, "tsunami");
+	SSID_rid.ssids[0].len = 7;
+	SSID_rid.len = sizeof(SSID_rid);
+	/* Write it to the card */
+	disable_MAC(local, 1);
+	writeSsidRid(local, &SSID_rid, 1);
+	enable_MAC(local, &rsp, 1);
+
+	return 0;
+}
+
+
 /*------------------------------------------------------------------*/
 /*
  * Wireless Handler : set Tx-Power
@@ -7574,6 +7928,7 @@
 	(iw_handler) airo_set_encodeext,	/* SIOCSIWENCODEEXT */
 	(iw_handler) airo_get_encodeext,	/* SIOCGIWENCODEEXT */
 	(iw_handler) NULL,			/* SIOCSIWPMKSA */
+	[SIOCSIWMLME-SIOCSIWCOMMIT] = (iw_handler) airo_disasociate,
 };
 
 /* Note : don't describe AIROIDIFC and AIROOLDIDIFC in here.

--------------040009050904010600000603--
