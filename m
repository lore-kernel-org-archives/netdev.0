From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x-rc net driver updates
Date: Mon, 20 Sep 2004 14:32:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920183252.GA14037@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/ieee1394/eth1394.c  |    2 
 drivers/net/Kconfig         |    4 -
 drivers/net/r8169.c         |   16 ++++-
 drivers/net/wireless/airo.c |  139 +++++++++++++++++++++++++-------------------
 4 files changed, 97 insertions(+), 64 deletions(-)

through these ChangeSets:

<achirica@telefonica.net> (04/09/20 1.1928)
   [PATCH] Compatibility fixes for different card versions

<romieu@fr.zoreil.com> (04/09/20 1.1927)
   [PATCH] r8169: default on disabling PCIDAC
   
   Default to disabling PCI DAC as this option appears unsafe on amd64
   (original suggestion by Hans-Frieder Vogt <hfvogt@arcor.de>).
   
   The driver will typically report PCI System error when something goes
   wrong. The relevant interrupt is not masked any more and the driver
   can thus be disabled.
   
   Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

<akpm@osdl.org> (04/09/17 1.1926)
   [PATCH] fix driver name in eth1394 as returned by ETHTOOL_GDRVINFO
   
   From: Thierry Vignaud <tvignaud@mandrakesoft.com>
   
   The GDRVINFO command of the ETHTOOL ioctl returns a bogus driver name.
   
   Signed-off-by: Andrew Morton <akpm@osdl.org>

<olh@suse.de> (04/09/16 1.1925)
   [PATCH] mark mace and bmac as ppc32 only
   
   mace and bmac are only used in "oldworld" PowerMacs.
   Mark them as ppc32 only.

diff -Nru a/drivers/ieee1394/eth1394.c b/drivers/ieee1394/eth1394.c
--- a/drivers/ieee1394/eth1394.c	2004-09-20 14:31:50 -04:00
+++ b/drivers/ieee1394/eth1394.c	2004-09-20 14:31:50 -04:00
@@ -132,7 +132,7 @@
 };
 
 /* Our ieee1394 highlevel driver */
-#define ETH1394_DRIVER_NAME "ip1394"
+#define ETH1394_DRIVER_NAME "eth1394"
 static const char driver_name[] = ETH1394_DRIVER_NAME;
 
 static kmem_cache_t *packet_task_cache;
diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2004-09-20 14:31:50 -04:00
+++ b/drivers/net/Kconfig	2004-09-20 14:31:50 -04:00
@@ -200,7 +200,7 @@
 
 config MACE
 	tristate "MACE (Power Mac ethernet) support"
-	depends on NET_ETHERNET && PPC_PMAC
+	depends on NET_ETHERNET && PPC_PMAC && PPC32
 	select CRC32
 	help
 	  Power Macintoshes and clones with Ethernet built-in on the
@@ -223,7 +223,7 @@
 
 config BMAC
 	tristate "BMAC (G3 ethernet) support"
-	depends on NET_ETHERNET && PPC_PMAC
+	depends on NET_ETHERNET && PPC_PMAC && PPC32
 	select CRC32
 	help
 	  Say Y for support of BMAC Ethernet interfaces. These are used on G3
diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c	2004-09-20 14:31:50 -04:00
+++ b/drivers/net/r8169.c	2004-09-20 14:31:50 -04:00
@@ -156,6 +156,7 @@
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
 static int rx_copybreak = 200;
+static int use_dac;
 
 enum RTL8169_registers {
 	MAC0 = 0,		/* Ethernet hardware address. */
@@ -358,6 +359,8 @@
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 MODULE_PARM(media, "1-" __MODULE_STRING(MAX_UNITS) "i");
 MODULE_PARM(rx_copybreak, "i");
+MODULE_PARM(use_dac, "i");
+MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
 MODULE_LICENSE("GPL");
 
 static int rtl8169_open(struct net_device *dev);
@@ -375,7 +378,7 @@
 #endif
 
 static const u16 rtl8169_intr_mask =
-	LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
+	SYSErr | LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
 static const u16 rtl8169_napi_event =
 	RxOK | RxOverflow | RxFIFOOver | TxOK | TxErr;
 static const unsigned int rtl8169_rx_config =
@@ -984,7 +987,7 @@
 	tp->cp_cmd = PCIMulRW | RxChkSum;
 
 	if ((sizeof(dma_addr_t) > 4) &&
-	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK))
+	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK) && use_dac)
 		tp->cp_cmd |= PCIDAC;
 	else {
 		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
@@ -1760,6 +1763,15 @@
 
 		if (!(status & rtl8169_intr_mask))
 			break;
+
+		if (unlikely(status & SYSErr)) {
+			printk(KERN_ERR PFX "%s: PCI error (status: 0x%04x)."
+			       " Device disabled.\n", dev->name, status);
+			RTL_W8(ChipCmd, 0x00);
+			RTL_W16(IntrMask, 0x0000);
+			RTL_R16(IntrMask);
+			break;
+		}
 
 		if (status & LinkChg)
 			rtl8169_check_link_status(dev, tp, ioaddr);
diff -Nru a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
--- a/drivers/net/wireless/airo.c	2004-09-20 14:31:50 -04:00
+++ b/drivers/net/wireless/airo.c	2004-09-20 14:31:50 -04:00
@@ -1816,7 +1816,8 @@
 	if (!test_bit (FLAG_COMMIT, &ai->flags))
 		return SUCCESS;
 
-	clear_bit (FLAG_COMMIT | FLAG_RESET, &ai->flags);
+	clear_bit (FLAG_COMMIT, &ai->flags);
+	clear_bit (FLAG_RESET, &ai->flags);
 	checkThrottle(ai);
 	cfgr = ai->config;
 
@@ -1980,9 +1981,6 @@
 	ai->txfids[0].tx_desc.eoc = 1;
 	ai->txfids[0].tx_desc.len =len+sizeof(WifiHdr);
 
-	memcpy((char *)ai->txfids[0].card_ram_off,
-		(char *)&ai->txfids[0].tx_desc, sizeof(TxFid));
-
 /*
  * Magic, the cards firmware needs a length count (2 bytes) in the host buffer
  * right after  TXFID_HDR.The TXFID_HDR contains the status short so payloadlen
@@ -2012,6 +2010,7 @@
 			return ERROR;
 
 		*payloadLen = cpu_to_le16(len-sizeof(etherHead)+sizeof(pMic));
+		ai->txfids[0].tx_desc.len += sizeof(pMic);
 		/* copy data into airo dma buffer */
 		memcpy (sendbuf, buffer, sizeof(etherHead));
 		buffer += sizeof(etherHead);
@@ -2030,6 +2029,9 @@
 		memcpy(sendbuf, buffer, len);
 	}
 
+	memcpy((char *)ai->txfids[0].card_ram_off,
+		(char *)&ai->txfids[0].tx_desc, sizeof(TxFid));
+
 	OUT4500(ai, EVACK, 8);
 
 	dev_kfree_skb_any(skb);
@@ -2184,6 +2186,12 @@
 	struct airo_info *priv = dev->priv;
 	u32 *fids = priv->fids;
 
+	if (test_bit(FLAG_MPI, &priv->flags)) {
+		/* Not implemented yet for MPI350 */
+		netif_stop_queue(dev);
+		return -ENETDOWN;
+	}
+
 	if ( skb == NULL ) {
 		printk( KERN_ERR "airo:  skb == NULL!!!\n" );
 		return 0;
@@ -2249,12 +2257,14 @@
 {
 	struct airo_info *local =  dev->priv;
 
-	/* Get stats out of the card if available */
-	if (down_trylock(&local->sem) != 0) {
-		set_bit(JOB_STATS, &local->flags);
-		wake_up_interruptible(&local->thr_wait);
-	} else
-		airo_read_stats(local);
+	if (!test_bit(JOB_STATS, &local->flags)) {
+		/* Get stats out of the card if available */
+		if (down_trylock(&local->sem) != 0) {
+			set_bit(JOB_STATS, &local->flags);
+			wake_up_interruptible(&local->thr_wait);
+		} else
+			airo_read_stats(local);
+	}
 
 	return &local->stats;
 }
@@ -2340,6 +2350,9 @@
 void stop_airo_card( struct net_device *dev, int freeres )
 {
 	struct airo_info *ai = dev->priv;
+
+	set_bit(FLAG_RADIO_DOWN, &ai->flags);
+	disable_MAC(ai, 1);
 	disable_interrupts(ai);
 	free_irq( dev->irq, dev );
 	takedown_proc_entry( dev, ai );
@@ -3406,13 +3419,8 @@
 }
 
 static void enable_interrupts( struct airo_info *ai ) {
-	/* Reset the status register */
-	u16 status = IN4500( ai, EVSTAT );
-	OUT4500( ai, EVACK, status );
 	/* Enable the interrupts */
 	OUT4500( ai, EVINTEN, STATUS_INTS );
-	/* Note there is a race condition between the last two lines that
-	   I don't know how to get rid of right now... */
 }
 
 static void disable_interrupts( struct airo_info *ai ) {
@@ -3460,7 +3468,7 @@
 		memcpy(buffer + ETH_ALEN * 2,
 			ai->rxfids[0].virtual_host_addr + ETH_ALEN * 2 + off,
 			len - ETH_ALEN * 2 - off);
-		if (decapsulate (ai, &micbuf, (etherHead*)buffer, len - off)) {
+		if (decapsulate (ai, &micbuf, (etherHead*)buffer, len - off - ETH_ALEN * 2)) {
 badmic:
 			dev_kfree_skb_irq (skb);
 			goto badrx;
@@ -3670,18 +3678,6 @@
 		status = readCapabilityRid(ai, &cap_rid, lock);
 		if ( status != SUCCESS ) return ERROR;
 
-		/*
-		 * This driver supports MPI350 firmwares up to, and
-		 * including 5.30.17
-		 */
-		if (test_bit(FLAG_MPI, &ai->flags) &&
-		    strncmp (cap_rid.prodVer, "5.00.", 5) &&
-		    strncmp (cap_rid.prodVer, "5b00.", 5) &&
-		    strncmp (cap_rid.prodVer, "5.02.", 5) &&
-		    strncmp (cap_rid.prodVer, "5.20.", 5) &&
-		    strncmp (cap_rid.prodVer, "5.30.", 5))
-			printk(KERN_ERR "airo: Firmware version %s is not supported. Use it at your own risk!\n", cap_rid.prodVer);
-
 		status = PC4500_readrid(ai,RID_RSSI,&rssi_rid,sizeof(rssi_rid),lock);
 		if ( status == SUCCESS ) {
 			if (ai->rssi || (ai->rssi = kmalloc(512, GFP_KERNEL)) != NULL)
@@ -3716,9 +3712,9 @@
 
 		/* Check to see if there are any insmod configured
 		   rates to add */
-		if ( rates ) {
+		if ( rates[0] ) {
 			int i = 0;
-			if ( rates[0] ) memset(ai->config.rates,0,sizeof(ai->config.rates));
+			memset(ai->config.rates,0,sizeof(ai->config.rates));
 			for( i = 0; i < 8 && rates[i]; i++ ) {
 				ai->config.rates[i] = rates[i];
 			}
@@ -3785,7 +3781,6 @@
 static u16 issuecommand(struct airo_info *ai, Cmd *pCmd, Resp *pRsp) {
         // Im really paranoid about letting it run forever!
 	int max_tries = 600000;
-	u16 cmd;
 
 	if (IN4500(ai, EVSTAT) & EV_CMD)
 		OUT4500(ai, EVACK, EV_CMD);
@@ -3794,26 +3789,23 @@
 	OUT4500(ai, PARAM1, pCmd->parm1);
 	OUT4500(ai, PARAM2, pCmd->parm2);
 	OUT4500(ai, COMMAND, pCmd->cmd);
-	while ( max_tries-- && (IN4500(ai, EVSTAT) & EV_CMD) == 0 &&
-		(cmd = IN4500(ai, COMMAND)) != 0 )
-			if (cmd == pCmd->cmd)
-				// PC4500 didn't notice command, try again
-				OUT4500(ai, COMMAND, pCmd->cmd);
-	if ( max_tries == -1 ) {
-		printk( KERN_ERR
-			"airo: Max tries exceeded when issueing command\n" );
-                return ERROR;
-	}
 
 	while (max_tries-- && (IN4500(ai, EVSTAT) & EV_CMD) == 0) {
+		if ((IN4500(ai, COMMAND)) == pCmd->cmd)
+			// PC4500 didn't notice command, try again
+			OUT4500(ai, COMMAND, pCmd->cmd);
 		if (!in_atomic() && (max_tries & 255) == 0)
 			schedule();
 	}
+
 	if ( max_tries == -1 ) {
 		printk( KERN_ERR
-			"airo: Max tries exceeded waiting for command\n" );
-                return ERROR;
+			"airo: Max tries exceeded when issueing command\n" );
+		if (IN4500(ai, COMMAND) & COMMAND_BUSY)
+			OUT4500(ai, EVACK, EV_CLEARCOMMANDBUSY);
+		return ERROR;
 	}
+
 	// command completed
 	pRsp->status = IN4500(ai, STATUS);
 	pRsp->rsp0 = IN4500(ai, RESP0);
@@ -4509,8 +4501,6 @@
 		len = priv->readlen - pos;
 	if (copy_to_user(buffer, priv->rbuffer + pos, len))
 		return -EFAULT;
-	if (pos + len > priv->writelen)
-		priv->writelen = pos + len;
 	*offset = pos + len;
 	return len;
 }
@@ -5521,7 +5511,6 @@
 		mpi_init_descriptors(ai);
 		setup_card(ai, dev->dev_addr, 0);
 		clear_bit(FLAG_RADIO_OFF, &ai->flags);
-		clear_bit(FLAG_RADIO_DOWN, &ai->flags);
 		clear_bit(FLAG_PENDING_XMIT, &ai->flags);
 	} else {
 		OUT4500(ai, EVACK, EV_AWAKEN);
@@ -5606,6 +5595,30 @@
  * would not work at all... - Jean II
  */
 
+static int airo_get_quality (StatusRid *status_rid, CapabilityRid *cap_rid)
+{
+	int quality = 0;
+
+	if ((status_rid->mode & 0x3f) == 0x3f && (cap_rid->hardCap & 8)) {
+		if (memcmp(cap_rid->prodName, "350", 3))
+			if (status_rid->signalQuality > 0x20)
+				quality = 0;
+			else
+				quality = 0x20 - status_rid->signalQuality;
+		else
+			if (status_rid->signalQuality > 0xb0)
+				quality = 0;
+			else if (status_rid->signalQuality < 0x10)
+				quality = 0xa0;
+			else
+				quality = 0xb0 - status_rid->signalQuality;
+	}
+	return quality;
+}
+
+#define airo_get_max_quality(cap_rid) (memcmp((cap_rid)->prodName, "350", 3) ? 0x20 : 0xa0)
+#define airo_get_avg_quality(cap_rid) (memcmp((cap_rid)->prodName, "350", 3) ? 0x10 : 0x50);
+
 /*------------------------------------------------------------------*/
 /*
  * Wireless Handler : get protocol name
@@ -6293,7 +6306,8 @@
 	readCapabilityRid(local, &cap_rid, 1);
 
 	if (vwrq->disabled) {
-		set_bit (FLAG_RADIO_OFF | FLAG_COMMIT, &local->flags);
+		set_bit (FLAG_RADIO_OFF, &local->flags);
+		set_bit (FLAG_COMMIT, &local->flags);
 		return -EINPROGRESS;		/* Call commit handler */
 	}
 	if (vwrq->flags != IW_TXPOW_MWATT) {
@@ -6432,7 +6446,7 @@
 	range->num_frequency = k;
 
 	/* Hum... Should put the right values there */
-	range->max_qual.qual = 10;
+	range->max_qual.qual = airo_get_max_quality(&cap_rid);
 	range->max_qual.level = 0x100 - 120;	/* -120 dBm */
 	range->max_qual.noise = 0;
 	range->sensitivity = 65535;
@@ -6499,7 +6513,7 @@
 	/* Experimental measurements - boundary 11/5.5 Mb/s */
 	/* Note : with or without the (local->rssi), results
 	 * are somewhat different. - Jean II */
-	range->avg_qual.qual = 6;
+	range->avg_qual.qual = airo_get_avg_quality(&cap_rid);
 	if (local->rssi)
 		range->avg_qual.level = 186;	/* -70 dBm */
 	else
@@ -7113,6 +7127,7 @@
 {
 	StatusRid status_rid;
 	StatsRid stats_rid;
+	CapabilityRid cap_rid;
 	u32 *vals = stats_rid.vals;
 
 	/* Get stats out of the card */
@@ -7121,6 +7136,7 @@
 		up(&local->sem);
 		return;
 	}
+	readCapabilityRid(local, &cap_rid, 0);
 	readStatusRid(local, &status_rid, 0);
 	readStatsRid(local, &stats_rid, RID_STATS, 0);
 	up(&local->sem);
@@ -7129,7 +7145,7 @@
 	local->wstats.status = status_rid.mode;
 
 	/* Signal quality and co. But where is the noise level ??? */
-	local->wstats.qual.qual = status_rid.signalQuality;
+	local->wstats.qual.qual = airo_get_quality(&status_rid, &cap_rid);
 	if (local->rssi)
 		local->wstats.qual.level = 0x100 - local->rssi[status_rid.sigQuality].rssidBm;
 	else
@@ -7156,12 +7172,14 @@
 {
 	struct airo_info *local =  dev->priv;
 
-	/* Get stats out of the card if available */
-	if (down_trylock(&local->sem) != 0) {
-		set_bit(JOB_WSTATS, &local->flags);
-		wake_up_interruptible(&local->thr_wait);
-	} else
-		airo_read_wireless_stats(local);
+	if (!test_bit(JOB_WSTATS, &local->flags)) {
+		/* Get stats out of the card if available */
+		if (down_trylock(&local->sem) != 0) {
+			set_bit(JOB_WSTATS, &local->flags);
+			wake_up_interruptible(&local->thr_wait);
+		} else
+			airo_read_wireless_stats(local);
+	}
 
 	return &local->wstats;
 }
@@ -7188,9 +7206,11 @@
 	{
 	case AIROGCAP:      ridcode = RID_CAPABILITIES; break;
 	case AIROGCFG:      ridcode = RID_CONFIG;
-		disable_MAC (ai, 1);
-		writeConfigRid (ai, 1);
-		enable_MAC (ai, &rsp, 1);
+		if (test_bit(FLAG_COMMIT, &ai->flags)) {
+			disable_MAC (ai, 1);
+			writeConfigRid (ai, 1);
+			enable_MAC (ai, &rsp, 1);
+		}
 		break;
 	case AIROGSLIST:    ridcode = RID_SSID;         break;
 	case AIROGVLIST:    ridcode = RID_APLIST;       break;
@@ -7270,6 +7290,7 @@
 	case AIROPCAP:      ridcode = RID_CAPABILITIES; break;
 	case AIROPAPLIST:   ridcode = RID_APLIST;       break;
 	case AIROPCFG: ai->config.len = 0;
+			    clear_bit(FLAG_COMMIT, &ai->flags);
 			    ridcode = RID_CONFIG;       break;
 	case AIROPWEPKEYNV: ridcode = RID_WEP_PERM;     break;
 	case AIROPLEAPUSR:  ridcode = RID_LEAPUSERNAME; break;
