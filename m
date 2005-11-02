From: matthieu castet <castet.matthieu@free.fr>
Subject: [test] airo : first WPA-PSK support
Date: Wed, 02 Nov 2005 19:46:53 +0100
Message-ID: <4369099D.3010502@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020406020404050506040703"
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: netdev@vger.kernel.org, hostap@shmoo.com
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020406020404050506040703
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I have a working linux airo driver that support  WPA-PSK, but it is very 
ugly.
It only support one card, and don't support MPI350. Also it only works 
with WPA.

Currently the RX and TX key are set only for set_tx=1 key. The card 
should report valid mic key with EV_MIC, but the driver hangs for an 
unknow reason.

There still lot's of work to complete WPA support and merge it with an 
universal driver.

Attached a diff against 2.6.14 kernel.

If you test it, please send me your comment.


Matthieu

--------------020406020404050506040703
Content-Type: text/x-patch;
 name="airo_wpa.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="airo_wpa.diff"

--- /usr/src/linux-2.6.14/drivers/net/wireless/airo.c	2005-10-28 02:02:08.000000000 +0200
+++ airo.c	2005-11-02 19:36:35.000000000 +0100
@@ -46,6 +46,26 @@
 #include <linux/pci.h>
 #include <asm/uaccess.h>
 
+#include <linux/crypto.h>
+#include <asm/scatterlist.h>
+
+
+int trace_io=0;
+u8 rx_key [8];
+u8 tx_key [8];
+struct crypto_tfm *tfm_michael = NULL;
+
+static void dump(u8* data,int size) {
+        int i;  
+        printk("0: ");
+        for (i=0;i<size;i++) {
+                printk("%2x ", data[i]);
+                if (i%0x10==0xf)
+                        printk("\n%x: ", i+1);
+        }
+        printk("\n");
+}
+
 #ifdef CONFIG_PCI
 static struct pci_device_id card_ids[] = {
 	{ 0x14b9, 1, PCI_ANY_ID, PCI_ANY_ID, },
@@ -85,7 +105,7 @@
 #endif
 
 /* Support Cisco MIC feature */
-#define MICSUPPORT
+//#define MICSUPPORT
 
 #if defined(MICSUPPORT) && !defined(CONFIG_CRYPTO)
 #warning MIC support requires Crypto API
@@ -469,8 +489,10 @@
 #define RID_STATSDELTACLEAR 0xFF6A
 #define RID_ECHOTEST_RID 0xFF70
 #define RID_ECHOTEST_RESULTS 0xFF71
-#define RID_BSSLISTFIRST 0xFF72
-#define RID_BSSLISTNEXT  0xFF73
+//#define RID_BSSLISTFIRST 0xFF72
+//#define RID_BSSLISTNEXT  0xFF73
+#define RID_BSSLISTFIRST 0xFF74
+#define RID_BSSLISTNEXT  0xFF75
 
 typedef struct {
 	u16 cmd;
@@ -505,6 +527,15 @@
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
+
 /* These structures are from the Aironet's PC4500 Developers Manual */
 typedef struct {
 	u16 len;
@@ -574,7 +605,7 @@
 	u16 beaconListenTimeout;
 	u16 joinNetTimeout;
 	u16 authTimeout;
-	u16 authType;
+	u16 authType; /* 31 */
 #define AUTH_OPEN 0x1
 #define AUTH_ENCRYPT 0x101
 #define AUTH_SHAREDKEY 0x102
@@ -589,7 +620,7 @@
 #define DISABLE_REFRESH 0xFFFF
 	u16 _reserved1a[1];
 	/*---------- Power save operation ----------*/
-	u16 powerSaveMode;
+	u16 powerSaveMode; /* 40 */
 #define POWERSAVE_CAM 0
 #define POWERSAVE_PSP 1
 #define POWERSAVE_PSPCAM 2
@@ -602,7 +633,7 @@
 	/*---------- Ap/Ibss config items ----------*/
 	u16 beaconPeriod;
 	u16 atimDuration;
-	u16 hopPeriod;
+	u16 hopPeriod; /* 50 */
 	u16 channelSet;
 	u16 channel;
 	u16 dtimPeriod;
@@ -619,15 +650,15 @@
 #define TXPOWER_DEFAULT 0
 	u16 rssiThreshold;
 #define RSSI_DEFAULT 0
-        u16 modulation;
+        u16 modulation; /* 60 */
 #define PREAMBLE_AUTO 0
 #define PREAMBLE_LONG 1
 #define PREAMBLE_SHORT 2
 	u16 preamble;
 	u16 homeProduct;
-	u16 radioSpecific;
+	u16 radioSpecific; /* 63 */
 	/*---------- Aironet Extensions ----------*/
-	u8 nodeName[16];
+	u8 nodeName[16]; /* 71 */
 	u16 arlThreshold;
 	u16 arlDecay;
 	u16 arlDelay;
@@ -642,6 +673,9 @@
 #define MAGIC_STAY_IN_CAM (1<<10)
 	u8 magicControl;
 	u16 autoWake;
+	u16 _reserved5[4]; /* 81 */
+	u16 enc_algo;
+	u16 wap;
 } ConfigRid;
 
 typedef struct {
@@ -771,6 +805,8 @@
   } fh;
   u16 dsChannel;
   u16 atimWindow;
+  u16 junk[17];
+  u8 iep[40];
 } BSSListRid;
 
 typedef struct {
@@ -793,6 +829,13 @@
 } MICRid;
 
 typedef struct {
+	u16 len;
+	u16 unknow[16]; /* Is there the size here ??? */
+	u16 reqIE[26];
+	u16 respIE[3];
+} IERID;
+
+typedef struct {
 	u16 typelen;
 
 	union {
@@ -1199,6 +1242,9 @@
 	mic_module		mod[2];
 	mic_statistics		micstats;
 #endif
+	u8 LLC [10];
+
+	
 	HostRxDesc rxfids[MPI_MAX_FIDS]; // rx/tx/config MPI350 descriptors
 	HostTxDesc txfids[MPI_MAX_FIDS];
 	HostRidDesc config_desc;
@@ -1232,6 +1278,41 @@
 static int flashputbuf(struct airo_info *ai);
 static int flashrestart(struct airo_info *ai,struct net_device *dev);
 
+
+/* MIC for WPA */
+static void micinit(struct airo_info *ai)
+{
+	MICRid mic_rid;
+
+	clear_bit(JOB_MIC, &ai->flags);
+	PC4500_readrid(ai, RID_MIC, &mic_rid, sizeof(mic_rid), 0);
+	up(&ai->sem);
+
+	if (mic_rid.state & 0xff) {
+		/* Key must be valid and different */
+		if (mic_rid.multicastValid) {
+		}
+
+		/* Key must be valid and different */
+		if (mic_rid.unicastValid) {
+			memcpy(rx_key,mic_rid.unicast,8);
+			memcpy(tx_key,mic_rid.unicast+8,8);
+	
+		}
+	} else {
+      /* So next time we have a valid key and mic is enabled, we will update
+       * the sequence number if the key is the same as before.
+       */
+		memset(rx_key,0,8);
+		memset(tx_key,0,8);
+	}
+	dump(rx_key, 8);
+	dump(tx_key, 8);
+}
+
+static int micsetup(struct airo_info *ai) {
+	return SUCCESS;
+}
 #ifdef MICSUPPORT
 /***********************************************************************
  *                              MIC ROUTINES                           *
@@ -1244,7 +1325,7 @@
 static void emmh32_init(emmh32_context *context);
 static void emmh32_update(emmh32_context *context, u8 *pOctets, int len);
 static void emmh32_final(emmh32_context *context, u8 digest[4]);
-static int flashpchar(struct airo_info *ai,int byte,int dwelltime);
+/*static */int flashpchar(struct airo_info *ai,int byte,int dwelltime);
 
 /* micinit - Initialize mic seed */
 
@@ -1755,7 +1836,23 @@
 	}
 	return rc;
 }
+static int writeWpaKeyRid(struct airo_info*ai, WpaKeyRid *pwkr, int lock) {
+	int rc;
+	WpaKeyRid wkr = *pwkr;
 
+	wkr.len = cpu_to_le16(sizeof(WpaKeyRid));
+	wkr.kindex = cpu_to_le16(wkr.kindex);
+	wkr.klen = cpu_to_le16(wkr.klen);
+
+	//for (rc=0;rc< sizeof(WpaKeyRid)/2; rc++)
+	//	printk("wpa %d : %x\n", rc, *(((u16*)&(wkr)) + rc));
+
+	trace_io = 0;
+	rc = PC4500_writerid(ai, 0xff25, &wkr, sizeof(wkr), lock);
+	trace_io = 0;
+	if (rc!=SUCCESS) printk(KERN_ERR "airo:  WEP_TEMP set %x\n", rc);
+	return rc;
+}
 static int readSsidRid(struct airo_info*ai, SsidRid *ssidr) {
 	int i;
 	int rc = PC4500_readrid(ai, RID_SSID, ssidr, sizeof(*ssidr), 1);
@@ -2412,6 +2509,7 @@
 #ifdef MICSUPPORT
 	crypto_free_tfm(ai->tfm);
 #endif
+	crypto_free_tfm(tfm_michael);
 	del_airo_dev( dev );
 	free_netdev( dev );
 }
@@ -2769,8 +2867,9 @@
 	SET_NETDEV_DEV(dev, dmdev);
 
 
-	if (test_bit(FLAG_MPI,&ai->flags))
+	//if (test_bit(FLAG_MPI,&ai->flags))
 		reset_card (dev, 1);
+	msleep(300);
 
 	rc = request_irq( dev->irq, airo_interrupt, SA_SHIRQ, dev->name, dev );
 	if (rc) {
@@ -2898,8 +2997,21 @@
 	struct airo_info *ai = dev->priv;
 	union iwreq_data wrqu;
 	StatusRid status_rid;
+	IERID ie_rid;
 
 	clear_bit(JOB_EVENT, &ai->flags);
+
+	PC4500_readrid(ai, 0xff76, &ie_rid, sizeof(ie_rid), 0);
+
+	memset(&wrqu, 0, sizeof(wrqu));
+	wrqu.data.length = 52;
+	wireless_send_event(dev, IWEVASSOCREQIE, &wrqu, ie_rid.reqIE);
+
+	wrqu.data.length = 6;
+	wireless_send_event(dev, IWEVASSOCRESPIE, &wrqu, ie_rid.respIE);
+	memset(&wrqu, 0, sizeof(wrqu));
+
+
 	PC4500_readrid(ai, RID_STATUS, &status_rid, sizeof(status_rid), 0);
 	up(&ai->sem);
 	wrqu.data.length = 0;
@@ -3024,12 +3136,14 @@
 
 		if ( status & EV_MIC ) {
 			OUT4500( apriv, EVACK, EV_MIC );
-#ifdef MICSUPPORT
+			printk("new mic key...\n");
+			//XXX update mic key for WPA...
+//#ifdef MICSUPPORT
 			if (test_bit(FLAG_MIC_CAPABLE, &apriv->flags)) {
 				set_bit(JOB_MIC, &apriv->flags);
 				wake_up_interruptible(&apriv->thr_wait);
 			}
-#endif
+//#endif
 		}
 		if ( status & EV_LINK ) {
 			union iwreq_data	wrqu;
@@ -3112,6 +3226,13 @@
 				/* Send event to user space */
 				wireless_send_event(dev, SIOCGIWAP, &wrqu,NULL);
 			}
+
+			if(newStatus == ASSOCIATED) {
+				/*IWEVASSOCREQIE*/
+				/*IWEVASSOCRESPIE*/
+			}
+			
+			printk("status : %x\n", newStatus);
 		}
 
 		/* Check to see if there is something to receive */
@@ -3264,6 +3385,32 @@
 			}
 #endif /* WIRELESS_SPY */
 			OUT4500( apriv, EVACK, EV_RX);
+			if (tfm_michael && rx_key [0]) {
+				struct scatterlist sg[3];
+				u8 mic [8];
+
+				sg[0].page = virt_to_page(skb->data);
+				sg[0].offset = offset_in_page(skb->data);
+				sg[0].length = 12;
+
+
+				sg[1].page = virt_to_page(apriv->LLC);
+				sg[1].offset = offset_in_page(apriv->LLC);
+				sg[1].length = sizeof(apriv->LLC);
+
+				sg[2].page = virt_to_page(skb->data+12);
+				sg[2].offset = offset_in_page(skb->data+12);
+				sg[2].length = len  - 8;
+				crypto_digest_init(tfm_michael);
+				crypto_digest_setkey(tfm_michael, rx_key, 8);
+				crypto_digest_update(tfm_michael, sg, 3);
+				crypto_digest_final(tfm_michael, mic);
+				if (memcmp(mic, skb->data + skb->len - 8, 8))
+					printk("rx mic error \n");
+
+				len -= 8;
+				skb_trim (skb, len + hdrlen);
+			}
 
 			if (test_bit(FLAG_802_11, &apriv->flags)) {
 				skb->mac.raw = skb->data;
@@ -3357,8 +3504,10 @@
 static void OUT4500( struct airo_info *ai, u16 reg, u16 val ) {
 	if (test_bit(FLAG_MPI,&ai->flags))
 		reg <<= 1;
-	if ( !do8bitIO )
-		outw( val, ai->dev->base_addr + reg );
+	if ( !do8bitIO ) {
+		if (trace_io)
+		printk("->port (0x%x) val :0x%x\n",reg, val);
+		outw( val, ai->dev->base_addr + reg ); }
 	else {
 		outb( val & 0xff, ai->dev->base_addr + reg );
 		outb( val >> 8, ai->dev->base_addr + reg + 1 );
@@ -3711,6 +3860,7 @@
 		ai->config.authType = AUTH_OPEN;
 		ai->config.modulation = MOD_CCK;
 
+		//XXX don"t work for wpa...
 #ifdef MICSUPPORT
 		if ((cap_rid.len>=sizeof(cap_rid)) && (cap_rid.extSoftCap&1) &&
 		    (micsetup(ai) == SUCCESS)) {
@@ -3718,6 +3868,17 @@
 			set_bit(FLAG_MIC_CAPABLE, &ai->flags);
 		}
 #endif
+			tfm_michael = crypto_alloc_tfm("michael_mic", 0);
+			
+			{
+				char LLC1 [] = {0, 0, 0, 0, 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00};
+				memcpy(ai->LLC, LLC1, sizeof(LLC1));
+			}
+			if (tfm_michael == NULL) {
+				printk(KERN_DEBUG "crypto API michael_mic\n");
+			}
+
+			
 
 		/* Save off the MAC */
 		for( i = 0; i < ETH_ALEN; i++ ) {
@@ -3774,6 +3935,7 @@
 		return ERROR;
 	}
 
+#if 0
 	/* Grab the initial wep key, we gotta save it for auto_wep */
 	rc = readWepKeyRid(ai, &wkr, 1, lock);
 	if (rc == SUCCESS) do {
@@ -3783,6 +3945,7 @@
 		}
 		rc = readWepKeyRid(ai, &wkr, 0, lock);
 	} while(lastindex != wkr.kindex);
+#endif
 
 	if (auto_wep) {
 		ai->expires = RUN_AT(3*HZ);
@@ -3950,7 +4113,12 @@
 static int bap_write(struct airo_info *ai, const u16 *pu16Src,
 		     int bytelen, int whichbap)
 {
+	int i;
 	bytelen = (bytelen + 1) & (~1); // round up to even value
+	if (trace_io)
+	for (i=0;i<bytelen>>1;i++) {
+		printk("   idx : %d val :0x%x\n", i, *(pu16Src+i));
+	}
 	if ( !do8bitIO )
 		outsw( ai->dev->base_addr+DATA0+whichbap,
 		       pu16Src, bytelen>>1 );
@@ -4206,12 +4374,49 @@
 	if (bap_setup(ai, txFid, 0x0036, BAP1) != SUCCESS) return ERROR;
 	/* The hardware addresses aren't counted as part of the payload, so
 	 * we have to subtract the 12 bytes for the addresses off */
-	payloadLen = cpu_to_le16(len + miclen);
+	//if (tfm_michael && tx_key [0])
+	//	miclen += 8;
+	payloadLen = cpu_to_le16(len + miclen + 8);
 	bap_write(ai, &payloadLen, sizeof(payloadLen),BAP1);
 	bap_write(ai, (const u16*)pPacket, sizeof(etherHead), BAP1);
 	if (miclen)
 		bap_write(ai, (const u16*)&pMic, miclen, BAP1);
+	if (tfm_michael && tx_key [0]) {
+				struct scatterlist sg[3];
+				u8 mic [8];
+
+				sg[0].page = virt_to_page(pPacket);
+				sg[0].offset = offset_in_page(pPacket);
+				sg[0].length = sizeof(etherHead);
+
+
+				sg[1].page = virt_to_page(ai->LLC);
+				sg[1].offset = offset_in_page(ai->LLC);
+				sg[1].length = sizeof(ai->LLC);
+
+				sg[2].page = virt_to_page(pPacket + sizeof(etherHead));
+				sg[2].offset = offset_in_page(pPacket + sizeof(etherHead));
+				sg[2].length = len;
+				crypto_digest_init(tfm_michael);
+				crypto_digest_setkey(tfm_michael, tx_key, 8);
+				crypto_digest_update(tfm_michael, sg, 3);
+				crypto_digest_final(tfm_michael, mic);
+				
+				//XXX ugly hack
+				bap_write(ai, (const u16*)(pPacket + sizeof(etherHead)), len - (len&1), BAP1);
+				if (len&1) {
+					u8 tmp [2];
+					tmp [0] = pPacket [sizeof(etherHead) + len-1];
+					tmp [1] = mic[0];
+					bap_write(ai, (const u16*)tmp, 2, BAP1);
+					bap_write(ai, (const u16*)(mic+1), sizeof(mic)-1, BAP1);
+				}
+				else
+					bap_write(ai, (const u16*)mic, sizeof(mic), BAP1);
+		}
+	else
 	bap_write(ai, (const u16*)(pPacket + sizeof(etherHead)), len, BAP1);
+
 	// issue the transmit command
 	memset( &cmd, 0, sizeof( cmd ) );
 	cmd.cmd = CMD_TRANSMIT;
@@ -5125,6 +5330,8 @@
 	return 0;
 }
 
+
+
 static void proc_wepkey_on_close( struct inode *inode, struct file *file ) {
 	struct proc_data *data;
 	struct proc_dir_entry *dp = PDE(inode);
@@ -5401,6 +5608,7 @@
 static void timer_func( struct net_device *dev ) {
 	struct airo_info *apriv = dev->priv;
 	Resp rsp;
+#if 0
 
 /* We don't have a link so try changing the authtype */
 	readConfigRid(apriv, 0);
@@ -5428,6 +5636,7 @@
 	set_bit (FLAG_COMMIT, &apriv->flags);
 	writeConfigRid(apriv, 0);
 	enable_MAC(apriv, &rsp, 0);
+#endif
 	up(&apriv->sem);
 
 /* Schedule check to see if the change worked */
@@ -5815,7 +6024,7 @@
 	/* If none, we may want to get the one that was set */
 
 	/* Push it out ! */
-	dwrq->length = status_rid.SSIDlen + 1;
+	dwrq->length = status_rid.SSIDlen;
 	dwrq->flags = 1; /* active */
 
 	return 0;
@@ -6278,6 +6487,102 @@
 	return -EINPROGRESS;		/* Call commit handler */
 }
 
+static int airo_set_encode_ext(struct net_device *dev,
+			   struct iw_request_info *info,
+			   union iwreq_data *wrqu,
+			   char *extra)
+{
+	struct iw_encode_ext *ext = (struct iw_encode_ext *) extra;
+	struct airo_info *local = dev->priv;
+	CapabilityRid cap_rid;		/* Card capability info */
+	static const unsigned char macaddr[ETH_ALEN] = { 0x01, 0, 0, 0, 0, 0 };
+	WpaKeyRid wkr;
+	Resp rsp;
+
+	int index = (wrqu->encoding.flags & IW_ENCODE_INDEX) - 1;
+
+	/* Is WEP supported ? */
+	readCapabilityRid(local, &cap_rid, 1);
+	/* Older firmware doesn't support this...
+	if(!(cap_rid.softCap & 2)) {
+		return -EOPNOTSUPP;
+	} */
+	readConfigRid(local, 1);
+
+		/* Check the index (none -> use current) */
+		if ((index < 0) || (index >= ((cap_rid.softCap & 0x80) ? 4:1)))
+			return -EINVAL;
+
+
+		//printk("set wpa : %d %d %x\n", ext->alg, ext->key_len, sizeof(wkr));
+		msleep(10);
+	if (down_interruptible(&local->sem))
+			return ERROR;
+
+	memset(&wkr, 0, sizeof(wkr));
+	wkr.len = sizeof(wkr);
+	if ((wrqu->encoding.flags & IW_ENCODE_DISABLED) ||
+			ext->alg == IW_ENCODE_ALG_NONE || ext->key_len == 0) {
+		//remove key
+		wkr.kindex = index;
+		memcpy( wkr.mac, macaddr, ETH_ALEN );
+		printk(KERN_INFO "Removing key %d\n", index);
+
+		memset(rx_key,0,8);
+		memset(tx_key,0,8);
+	}
+	else if (ext->alg == IW_ENCODE_ALG_TKIP && ext->key_len == 32) {
+		wkr.kindex = index;
+		memcpy( wkr.mac, macaddr, ETH_ALEN );
+		wkr.klen = /*ext->key_len*/ 0x30;
+		//memcpy(wkr.key, ext->key, ext->key_len);
+		/* firmware use ndis order + a hole */
+		memcpy(wkr.key, ext->key, 16);
+		memcpy(wkr.key + 32, ext->key + 24, 8); /*RX*/
+		memcpy(wkr.key + 40, ext->key + 16, 8); /*TX*/
+		/*printk("key : ");
+		int i;
+		for (i=0;i<32;i++)
+			printk("%x ", (char)(*(char*)(ext->key + i)));
+		printk("\n");*/
+		dump(ext->key, 32);
+		printk(KERN_INFO "Setting key %d\n", index);
+	}
+	else
+		return -EINVAL;
+
+
+
+	printk("len %d, idx %d, mac %x, key %x\n", wkr.klen, wkr.kindex, wkr.mac[0], wkr.key[0]);
+
+	//disable_MAC(local, 1);
+	//if (index >= 3)
+	writeWpaKeyRid(local, &wkr, 0);
+	//enable_MAC(local, &rsp, 1);
+
+	if (ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY) {
+	//disable_MAC(local, 1);
+		//set the key active
+		wkr.kindex = 0xffff;
+		wkr.mac[0] = (char)index;
+		//wkr.klen = /*ext->key_len*/0x30;
+		memset(wkr.key, 0, sizeof(wkr.key));
+		printk(KERN_INFO "Setting transmit key to %d\n", index);
+		writeWpaKeyRid(local, &wkr, 0);
+
+
+		memcpy(rx_key,ext->key+24,8);
+		memcpy(tx_key,ext->key+16,8);
+
+	//enable_MAC(local, &rsp, 1);
+	}
+
+	up(&local->sem);
+	return 0;
+}
+
+
+
 /*------------------------------------------------------------------*/
 /*
  * Wireless Handler : get Encryption Key
@@ -6571,6 +6876,8 @@
 				IW_EVENT_CAPA_MASK(SIOCGIWSCAN));
 	range->event_capa[1] = IW_EVENT_CAPA_K_1;
 	range->event_capa[4] = IW_EVENT_CAPA_MASK(IWEVTXDROP);
+
+	range->enc_capa = IW_ENC_CAPA_CIPHER_TKIP | IW_ENC_CAPA_WPA;
 	return 0;
 }
 
@@ -6821,6 +7128,7 @@
 	u16			capabilities;
 	char *			current_val;	/* For rates */
 	int			i;
+	unsigned char buf[40/*MAX_WPA_IE_LEN*/ * 2 + 30];
 
 	/* First entry *MUST* be the AP MAC address */
 	iwe.cmd = SIOCGIWAP;
@@ -6909,6 +7217,35 @@
 
 	/* The other data in the scan result are not really
 	 * interesting, so for now drop it - Jean II */
+	iwe.cmd = IWEVCUSTOM;
+	sprintf(buf, "bcn_int=%d", bss->beaconInterval);
+	iwe.u.data.length = strlen(buf);
+	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, buf);
+
+	iwe.cmd = IWEVCUSTOM;
+	sprintf(buf, "atim=%u", bss->atimWindow);
+	current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, buf);
+	
+	if (/*WPA*/ 1) {
+		unsigned char ielen = 2 + bss->iep[1];
+		if (ielen <= 40/*SSID_MAX_WPA_IE_LEN*/) {
+
+			if (bss->iep[0] == 0xdd /* WLAN_EID_GENERIC */ && bss->iep[1] >= 4
+					&& memcmp(bss->iep + 2, "\x00\x50\xf2\x01", 4) == 0) {
+				unsigned char *p = buf;
+				p += sprintf(p, "wpa_ie=");
+				for (i = 0; i < ielen; i++)
+					p += sprintf(p, "%02x", bss->iep[i]);
+
+				iwe.cmd = IWEVCUSTOM;
+				iwe.u.data.length = strlen(buf);
+				current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
+						buf);
+			}
+		}
+	}
+
+	
 	return current_ev;
 }
 
@@ -7021,6 +7358,79 @@
 	return 0;
 }
 
+static int airo_set_auth(struct net_device *dev, struct iw_request_info *info,
+		struct iw_param *data, char *extra)
+{
+	struct airo_info *local = dev->priv;
+	readConfigRid(local, 1);
+
+	switch (data->flags & IW_AUTH_INDEX) {
+		case IW_AUTH_WPA_ENABLED:
+			if (data->value == 0) {
+				printk("WPA dis\n");
+				local->config.wap=1;
+				local->config.authType=0x1;
+			}
+			else {
+				printk("WPA enable\n");
+				local->config.wap=0x8;
+				local->config.enc_algo=0x210;
+				local->config.authType=0xc101;
+				local->config._reserved5[0]=0x40;
+			}
+			break;
+		default:
+			return /*-EOPNOTSUPP*/0;
+	}
+
+	set_bit (FLAG_COMMIT, &local->flags);
+
+	return -EINPROGRESS;		/* Call commit handler */
+
+}
+
+static int airo_set_ie(struct net_device *dev,
+		struct iw_request_info *info,
+		struct iw_point *data, char *extra)
+{
+return 0;
+}
+
+
+static int airo_disasociate(struct net_device *dev,
+		struct iw_request_info *info,
+		struct iw_point *data, char *extra)
+{
+	struct airo_info *local = dev->priv;
+	Resp rsp;
+#if 0
+	Cmd cmd;
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.cmd=CMD_LOSE_SYNC;
+	if (down_interruptible(&local->sem))
+		return -ERESTARTSYS;
+	issuecommand(local, &cmd, &rsp);
+	up(&local->sem);
+#else
+	SsidRid SSID_rid;		/* SSIDs */
+
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
+#endif
+	return 0;
+
+}
+
 /*------------------------------------------------------------------*/
 /*
  * Structures to export the Wireless Handlers
@@ -7082,6 +7492,10 @@
 	(iw_handler) airo_get_encode,		/* SIOCGIWENCODE */
 	(iw_handler) airo_set_power,		/* SIOCSIWPOWER */
 	(iw_handler) airo_get_power,		/* SIOCGIWPOWER */
+	[SIOCSIWAUTH-SIOCSIWCOMMIT] = (iw_handler) airo_set_auth,
+	[SIOCSIWGENIE-SIOCSIWCOMMIT] = (iw_handler) airo_set_ie,
+	[SIOCSIWENCODEEXT-SIOCSIWCOMMIT] = (iw_handler) airo_set_encode_ext,
+	[SIOCSIWMLME-SIOCSIWCOMMIT] = (iw_handler) airo_disasociate,
 };
 
 /* Note : don't describe AIROIDIFC and AIROOLDIDIFC in here.
@@ -7570,7 +7984,7 @@
  * x 50us for  echo .
  */
 
-static int flashpchar(struct airo_info *ai,int byte,int dwelltime) {
+/*static*/ int flashpchar(struct airo_info *ai,int byte,int dwelltime) {
 	int echo;
 	int waittime;
 

--------------020406020404050506040703
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
HostAP mailing list
HostAP@shmoo.com
http://lists.shmoo.com/mailman/listinfo/hostap

--------------020406020404050506040703--
