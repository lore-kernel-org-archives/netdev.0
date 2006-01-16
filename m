From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: [PATCH] WLAN acx100: OOPS fix, KERN_xxx, misc.
Date: Mon, 16 Jan 2006 15:02:33 +0100
Message-ID: <20060116140233.GA8170@rhlx01.fht-esslingen.de>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="qDbXVdCdHGoSgWSk"
Cc: netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org


--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all (and especially Denis),

acx-20060116_misc.diff:
- fix OOPS in acx_l_rxmonitor() (wrong ndev->type setting leading to memcpy
  of negative size) by reworking monitor mode type setup and adding
  missing sanity checks
- rename acx1XX_ie_powermgmt_t to more correct acx1XX_ie_powersave_t
- fix format string compile warnings
- add <linux/compiler.h> include apparently required for __iomem define
  around Linux 2.6.8
- rework eCPU init by replacing static msleep with faster, more intelligent
  (hopefully) busy-wait

acx-20060116_KERN_xxx.diff (too large: gzipped):
- add proper KERN_xxx prefixes to printk() as requested recently

Note that both patches are based on acx-20060116 proper (rediffed from
acx-20060113), smallish conflicts may result; apply acx-20060116_KERN_xxx.diff after acx-20060116_misc.diff.

Andreas Mohr

--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="acx-20060116_misc.diff"

diff -urN acx-20060116.orig/acx_struct.h acx-20060116_misc/acx_struct.h
--- acx-20060116.orig/acx_struct.h	2006-01-15 12:03:38.000000000 +0100
+++ acx-20060116_misc/acx_struct.h	2006-01-16 14:12:04.000000000 +0100
@@ -1202,6 +1202,7 @@
 	u8		ap[ETH_ALEN];		/* The AP we want, FF:FF:FF:FF:FF:FF is any */
 	u16		aid;			/* The Association ID sent from the AP / last used AID if we're an AP */
 	u16		mode;			/* mode from iwconfig */
+	int		monitor_type;		/* ARPHRD_IEEE80211 or ARPHRD_IEEE80211_PRISM */
 	u16		status;			/* 802.11 association status */
 	u8		essid_active;		/* specific ESSID active, or select any? */
 	u8		essid_len;		/* to avoid dozens of strlen() */
@@ -1623,7 +1624,7 @@
 #define PS_OPT_TX_PSPOLL	0x02 /* send PSPoll frame to fetch waiting frames from AP (on frame with matching AID) */
 #define PS_OPT_STILL_RCV_BCASTS	0x01
 
-typedef struct acx100_ie_powermgmt {
+typedef struct acx100_ie_powersave {
 	u16	type ACX_PACKED;
 	u16	len ACX_PACKED;
 	u8	wakeup_cfg ACX_PACKED;
@@ -1631,9 +1632,9 @@
 	u8	options ACX_PACKED;
 	u8	hangover_period ACX_PACKED; /* remaining wake time after Tx MPDU w/ PS bit, in values of 1/1024 seconds */
 	u16	enhanced_ps_transition_time ACX_PACKED; /* rem. wake time for Enh. PS */
-} acx100_ie_powermgmt_t;
+} acx100_ie_powersave_t;
 
-typedef struct acx111_ie_powermgmt {
+typedef struct acx111_ie_powersave {
 	u16	type ACX_PACKED;
 	u16	len ACX_PACKED;
 	u8	wakeup_cfg ACX_PACKED;
@@ -1642,7 +1643,7 @@
 	u8	hangover_period ACX_PACKED; /* remaining wake time after Tx MPDU w/ PS bit, in values of 1/1024 seconds */
 	u32	beacon_rx_time ACX_PACKED;
 	u32	enhanced_ps_transition_time ACX_PACKED; /* rem. wake time for Enh. PS */
-} acx111_ie_powermgmt_t;
+} acx111_ie_powersave_t;
 
 
 /***********************************************************************
diff -urN acx-20060116.orig/common.c acx-20060116_misc/common.c
--- acx-20060116.orig/common.c	2006-01-15 12:38:43.000000000 +0100
+++ acx-20060116_misc/common.c	2006-01-16 14:22:02.000000000 +0100
@@ -183,7 +183,7 @@
 		diff -= adev->lock_time;
 		if (diff > max_lock_time) {
 			where = sanitize_str(where);
-			printk("max lock hold time %d CPU ticks from %s "
+			printk("max lock hold time %ld CPU ticks from %s "
 				"to %s\n", diff, adev->last_lock, where);
 			max_lock_time = diff;
 		}
@@ -230,7 +230,7 @@
 		unsigned long diff = jiffies - adev->sem_time;
 		if (diff > max_sem_time) {
 			where = sanitize_str(where);
-			printk("max sem hold time %d jiffies from %s "
+			printk("max sem hold time %ld jiffies from %s "
 				"to %s\n", diff, adev->last_sem, where);
 			max_sem_time = diff;
 		}
@@ -838,7 +838,7 @@
 acx100_ie_len[] = {
 	0,
 	ACX100_IE_ACX_TIMER_LEN,
-	sizeof(acx100_ie_powermgmt_t)-4, /* is that 6 or 8??? */
+	sizeof(acx100_ie_powersave_t)-4, /* is that 6 or 8??? */
 	ACX1xx_IE_QUEUE_CONFIG_LEN,
 	ACX100_IE_BLOCK_SIZE_LEN,
 	ACX1xx_IE_MEMORY_CONFIG_OPTIONS_LEN,
@@ -889,7 +889,7 @@
 acx111_ie_len[] = {
 	0,
 	ACX100_IE_ACX_TIMER_LEN,
-	sizeof(acx111_ie_powermgmt_t)-4,
+	sizeof(acx111_ie_powersave_t)-4,
 	ACX1xx_IE_QUEUE_CONFIG_LEN,
 	ACX100_IE_BLOCK_SIZE_LEN,
 	ACX1xx_IE_MEMORY_CONFIG_OPTIONS_LEN,
@@ -2156,6 +2156,7 @@
 	adev->listen_interval = 100;
 	adev->beacon_interval = DEFAULT_BEACON_INTERVAL;
 	adev->mode = ACX_MODE_2_STA;
+	adev->monitor_type = ARPHRD_IEEE80211_PRISM;
 	adev->dtim_interval = DEFAULT_DTIM_INTERVAL;
 
 	adev->msdu_lifetime = DEFAULT_MSDU_LIFETIME;
@@ -2347,10 +2348,11 @@
 
 	skb_put(skb, skb_len);
 
+	if (adev->ndev->type == ARPHRD_IEEE80211) {
 		/* when in raw 802.11 mode, just copy frame as-is */
-	if (adev->ndev->type == ARPHRD_IEEE80211)
 		datap = skb->data;
-	else { /* otherwise, emulate prism header */
+	} else if (adev->ndev->type == ARPHRD_IEEE80211_PRISM) {
+		/* emulate prism header */
 		msg = (wlansniffrm_t*)skb->data;
 		datap = msg + 1;
 
@@ -2410,8 +2412,20 @@
 		msg->frmlen.status = WLANITEM_STATUS_data_ok;
 		msg->frmlen.len = 4;
 		msg->frmlen.data = skb_len;
+	} else {
+		printk(KERN_ERR "unsupported netdev type %d!\n",
+			adev->ndev->type);
+		dev_kfree_skb(skb);
+		return;
 	}
 
+	/* sanity check (keep it here) */
+	if (unlikely((int)skb_len < 0))
+	{
+		printk(KERN_ERR "skb_len bug (%d)!! Aborting...\n", (int)skb_len);
+		dev_kfree_skb(skb);
+		return;
+	}
 	memcpy(datap, ((unsigned char*)rxbuf)+payload_offset, skb_len);
 
 	skb->dev = adev->ndev;
@@ -2425,6 +2439,7 @@
 
 	adev->stats.rx_packets++;
 	adev->stats.rx_bytes += skb->len;
+
 end:
 	FN_EXIT0;
 }
@@ -5816,8 +5831,8 @@
 {
 	/* merge both structs in a union to be able to have common code */
 	union {
-		acx111_ie_powermgmt_t acx111;
-		acx100_ie_powermgmt_t acx100;
+		acx111_ie_powersave_t acx111;
+		acx100_ie_powersave_t acx100;
 	} pm;
 
 	/* change 802.11 power save mode settings */
@@ -6246,7 +6261,8 @@
 	}
 
 	if (adev->set_mask & GETSET_MODE) {
-		adev->ndev->type = ARPHRD_ETHER;
+		adev->ndev->type = (adev->mode == ACX_MODE_MONITOR) ?
+			adev->monitor_type : ARPHRD_ETHER;
 
 		switch (adev->mode) {
 		case ACX_MODE_3_AP:
@@ -6265,9 +6281,6 @@
 			acx_s_cmd_join_bssid(adev, adev->bssid);
 			break;
 		case ACX_MODE_MONITOR:
-			/* adev->ndev->type = ARPHRD_ETHER; */
-			/* adev->ndev->type = ARPHRD_IEEE80211; */
-			adev->ndev->type = ARPHRD_IEEE80211_PRISM;
 			acx111_s_feature_on(adev, 0, FEATURE2_NO_TXCRYPT|FEATURE2_SNIFFER);
 			/* this stops beacons */
 			acx_s_cmd_join_bssid(adev, adev->bssid);
diff -urN acx-20060116.orig/ioctl.c acx-20060116_misc/ioctl.c
--- acx-20060116.orig/ioctl.c	2006-01-15 12:02:26.000000000 +0100
+++ acx-20060116_misc/ioctl.c	2006-01-16 14:21:46.000000000 +0100
@@ -2078,13 +2078,14 @@
 
 	switch (params[0]) {
 	case 0:
-		adev->ndev->type = ARPHRD_ETHER;
+		/* no monitor mode. hmm, should we simply ignore it
+		 * or go back to enabling adev->netdev->type ARPHRD_ETHER? */
 		break;
 	case 1:
-		adev->ndev->type = ARPHRD_IEEE80211_PRISM;
+		adev->monitor_type = ARPHRD_IEEE80211_PRISM;
 		break;
 	case 2:
-		adev->ndev->type = ARPHRD_IEEE80211;
+		adev->monitor_type = ARPHRD_IEEE80211;
 		break;
 	}
 
diff -urN acx-20060116.orig/pci.c acx-20060116_misc/pci.c
--- acx-20060116.orig/pci.c	2006-01-15 12:01:41.000000000 +0100
+++ acx-20060116_misc/pci.c	2006-01-16 14:21:13.000000000 +0100
@@ -33,6 +33,7 @@
 
 #include <linux/config.h>
 #include <linux/version.h>
+#include <linux/compiler.h> /* required for Lx 2.6.8 ?? */
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -354,8 +355,9 @@
 		write_flush(adev);
 		write_reg32(adev, IO_ACX_EEPROM_CTL, 1);
 
+		count = 0xffff;
 		while (read_reg16(adev, IO_ACX_EEPROM_CTL)) {
-			if (unlikely(++count > 0xffff)) {
+			if (unlikely(!--count)) {
 				printk("WARNING, DANGER!!! "
 					"Timeout waiting for EEPROM write\n");
 				goto end;
@@ -369,13 +371,13 @@
 	write_flush(adev);
 
 	/* now start a verification run */
-	count = 0xffff;
 	for (i = 0; i < len; i++) {
 		write_reg32(adev, IO_ACX_EEPROM_CFG, 0);
 		write_reg32(adev, IO_ACX_EEPROM_ADDR, addr + i);
 		write_flush(adev);
 		write_reg32(adev, IO_ACX_EEPROM_CTL, 2);
 
+		count = 0xffff;
 		while (read_reg16(adev, IO_ACX_EEPROM_CTL)) {
 			if (unlikely(!--count)) {
 				printk("timeout waiting for EEPROM read\n");
@@ -747,18 +749,17 @@
 	temp = read_reg16(adev, IO_ACX_ECPU_CTRL) | 0x1;
 	write_reg16(adev, IO_ACX_ECPU_CTRL, temp);
 
-	/* now do soft reset of eCPU */
+	/* now do soft reset of eCPU, set bit */
 	temp = read_reg16(adev, IO_ACX_SOFT_RESET) | 0x1;
 	log(L_DEBUG, "%s: enable soft reset...\n", __func__);
 	write_reg16(adev, IO_ACX_SOFT_RESET, temp);
 	write_flush(adev);
 
-	/* now reset bit again */
+	/* now clear bit again: deassert eCPU reset */
 	log(L_DEBUG, "%s: disable soft reset and go to init mode...\n", __func__);
-	/* deassert eCPU reset */
 	write_reg16(adev, IO_ACX_SOFT_RESET, temp & ~0x1);
 
-	/* now start a burst read from initial flash EEPROM */
+	/* now start a burst read from initial EEPROM */
 	temp = read_reg16(adev, IO_ACX_EE_START) | 0x1;
 	write_reg16(adev, IO_ACX_EE_START, temp);
 	write_flush(adev);
@@ -893,6 +894,7 @@
 	int result = NOT_OK;
 	u16 hardware_info;
 	u16 ecpu_ctrl;
+	int count;
 
 	FN_ENTER;
 
@@ -927,12 +929,24 @@
 
 	acx_unlock(adev, flags);
 
-	/* without this delay acx100 may fail to report hardware_info
-	** (see below). Most probably eCPU runs some init code */
-	acx_s_msleep(10);
-
 	/* need to know radio type before fw load */
-	hardware_info = read_reg16(adev, IO_ACX_EEPROM_INFORMATION);
+ 	/* Need to wait for arrival of this information in a loop,
+ 	 * most probably since eCPU runs some init code from EEPROM
+ 	 * (started burst read in reset_mac()) which also
+ 	 * sets the radio type ID */
+ 
+ 	count = 0xffff;
+ 	do {
+ 		hardware_info = read_reg16(adev, IO_ACX_EEPROM_INFORMATION);
+ 		if (!--count)
+ 		{
+ 			msg = "eCPU didn't indicate radio type";
+ 			goto end_fail;
+ 		}
+ 		cpu_relax();
+ 	} while (!(hardware_info & 0xff00)); /* radio type still zero? */
+ 
+ 	/* printk("DEBUG: count %d\n", count); */
 	adev->form_factor = hardware_info & 0xff;
 	adev->radio_type = hardware_info >> 8;
 
@@ -940,11 +954,11 @@
 	if (OK != acxpci_s_upload_fw(adev))
 		goto end_fail;
 
-	acx_s_msleep(10);
+	/* acx_s_msleep(10);	this one really shouldn't be required */
 
 	/* now start eCPU by clearing bit */
-	log(L_DEBUG, "booted eCPU up and waiting for completion...\n");
 	write_reg16(adev, IO_ACX_ECPU_CTRL, ecpu_ctrl & ~0x1);
+	log(L_DEBUG, "booted eCPU up and waiting for completion...\n");
 
 	/* wait for eCPU bootup */
 	if (OK != acxpci_s_verify_init(adev)) {

--qDbXVdCdHGoSgWSk
Content-Type: application/x-gzip
Content-Disposition: attachment; filename="acx-20060116_KERN_xxx.diff.gz"
Content-Transfer-Encoding: base64

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

--qDbXVdCdHGoSgWSk--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
