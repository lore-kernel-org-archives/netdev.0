From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Tue, 10 Jul 2007 14:57:58 -0400
Message-ID: <20070710185758.GH7927@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3099 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752956AbXGJTCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 15:02:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 71780f59e127bb281a9302d430495ca9586c14e7:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../ieee1394/linux1394-2.6

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-jgarzik

Adrian Bunk (1):
      drivers/net/wireless/libertas/wext.c: remove dead code

Dan Williams (1):
      libertas: fix disabling WPA

Daniel Drake (4):
      zd1211rw: Allow channels 1-11 for unrecognised regulatory domains
      zd1211rw: Detect more AL2230S radios
      zd1211rw: Add ID for Buffalo WLI-U2-KG54L
      zd1211rw: Defer firmware load until first ifup

Holger Schurig (1):
      libertas: fix use-after-free in rx path

Jean Tourrilhes (1):
      softmac: Fix ESSID problem

Matthias Kaehlcke (1):
      use list_for_each_entry() for iteration in Prism 54 driver

Michael Wu (1):
      rtl8187: fix endianness issue in rtl8225 register writing

Michal Schmidt (5):
      airo: disable the PCI device when unloading module
      airo: delay some initialization until the netdev is up
      airo: fix a race causing initialization failures
      airo: simpler calling convention for enable_MAC()
      airo: start with radio off

Robert P. J. Day (1):
      WIRELESS: Remove clearly obsolete libertas/version.h file.

Stephen Hemminger (2):
      ipw2200: rf kill switch polling power saving
      ipw2100: RF kill switch timer power save

 drivers/net/wireless/airo.c                    |  208 ++++++++++++------------
 drivers/net/wireless/ipw2100.c                 |   11 +-
 drivers/net/wireless/ipw2200.c                 |    5 +-
 drivers/net/wireless/libertas/cmd.c            |    2 +-
 drivers/net/wireless/libertas/rx.c             |    1 -
 drivers/net/wireless/libertas/version.h        |    1 -
 drivers/net/wireless/libertas/wext.c           |    3 -
 drivers/net/wireless/prism54/isl_ioctl.c       |   22 +--
 drivers/net/wireless/rtl8187_rtl8225.c         |    4 +-
 drivers/net/wireless/zd1211rw/zd_chip.c        |   88 ++---------
 drivers/net/wireless/zd1211rw/zd_chip.h        |   13 +-
 drivers/net/wireless/zd1211rw/zd_mac.c         |   59 +++++---
 drivers/net/wireless/zd1211rw/zd_mac.h         |    3 +-
 drivers/net/wireless/zd1211rw/zd_rf.c          |    3 +-
 drivers/net/wireless/zd1211rw/zd_rf.h          |    2 +-
 drivers/net/wireless/zd1211rw/zd_rf_al2230.c   |   12 +-
 drivers/net/wireless/zd1211rw/zd_rf_al7230b.c  |    2 +-
 drivers/net/wireless/zd1211rw/zd_rf_rf2959.c   |    2 +-
 drivers/net/wireless/zd1211rw/zd_rf_uw2453.c   |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c         |   98 ++++++++---
 drivers/net/wireless/zd1211rw/zd_usb.h         |    3 +
 net/ieee80211/softmac/ieee80211softmac_assoc.c |    5 +-
 22 files changed, 280 insertions(+), 269 deletions(-)
 delete mode 100644 drivers/net/wireless/libertas/version.h

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 2d3a180..1c54908 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -52,6 +52,8 @@
 
 #include "airo.h"
 
+#define DRV_NAME "airo"
+
 #ifdef CONFIG_PCI
 static struct pci_device_id card_ids[] = {
 	{ 0x14b9, 1, PCI_ANY_ID, PCI_ANY_ID, },
@@ -71,7 +73,7 @@ static int airo_pci_suspend(struct pci_dev *pdev, pm_message_t state);
 static int airo_pci_resume(struct pci_dev *pdev);
 
 static struct pci_driver airo_driver = {
-	.name     = "airo",
+	.name     = DRV_NAME,
 	.id_table = card_ids,
 	.probe    = airo_pci_probe,
 	.remove   = __devexit_p(airo_pci_remove),
@@ -1092,7 +1094,7 @@ static int get_dec_u16( char *buffer, int *start, int limit );
 static void OUT4500( struct airo_info *, u16 register, u16 value );
 static unsigned short IN4500( struct airo_info *, u16 register );
 static u16 setup_card(struct airo_info*, u8 *mac, int lock);
-static int enable_MAC( struct airo_info *ai, Resp *rsp, int lock );
+static int enable_MAC(struct airo_info *ai, int lock);
 static void disable_MAC(struct airo_info *ai, int lock);
 static void enable_interrupts(struct airo_info*);
 static void disable_interrupts(struct airo_info*);
@@ -1250,7 +1252,7 @@ static int flashputbuf(struct airo_info *ai);
 static int flashrestart(struct airo_info *ai,struct net_device *dev);
 
 #define airo_print(type, name, fmt, args...) \
-	{ printk(type "airo(%s): " fmt "\n", name, ##args); }
+	printk(type DRV_NAME "(%s): " fmt "\n", name, ##args)
 
 #define airo_print_info(name, fmt, args...) \
 	airo_print(KERN_INFO, name, fmt, ##args)
@@ -1926,28 +1928,54 @@ static int readStatsRid(struct airo_info*ai, StatsRid *sr, int rid, int lock) {
 	return rc;
 }
 
+static void try_auto_wep(struct airo_info *ai)
+{
+	if (auto_wep && !(ai->flags & FLAG_RADIO_DOWN)) {
+		ai->expires = RUN_AT(3*HZ);
+		wake_up_interruptible(&ai->thr_wait);
+	}
+}
+
 static int airo_open(struct net_device *dev) {
-	struct airo_info *info = dev->priv;
-	Resp rsp;
+	struct airo_info *ai = dev->priv;
+	int rc = 0;
 
-	if (test_bit(FLAG_FLASHING, &info->flags))
+	if (test_bit(FLAG_FLASHING, &ai->flags))
 		return -EIO;
 
 	/* Make sure the card is configured.
 	 * Wireless Extensions may postpone config changes until the card
 	 * is open (to pipeline changes and speed-up card setup). If
 	 * those changes are not yet commited, do it now - Jean II */
-	if (test_bit (FLAG_COMMIT, &info->flags)) {
-		disable_MAC(info, 1);
-		writeConfigRid(info, 1);
+	if (test_bit(FLAG_COMMIT, &ai->flags)) {
+		disable_MAC(ai, 1);
+		writeConfigRid(ai, 1);
 	}
 
-	if (info->wifidev != dev) {
+	if (ai->wifidev != dev) {
+		clear_bit(JOB_DIE, &ai->jobs);
+		ai->airo_thread_task = kthread_run(airo_thread, dev, dev->name);
+		if (IS_ERR(ai->airo_thread_task))
+			return (int)PTR_ERR(ai->airo_thread_task);
+
+		rc = request_irq(dev->irq, airo_interrupt, IRQF_SHARED,
+			dev->name, dev);
+		if (rc) {
+			airo_print_err(dev->name,
+				"register interrupt %d failed, rc %d",
+				dev->irq, rc);
+			set_bit(JOB_DIE, &ai->jobs);
+			kthread_stop(ai->airo_thread_task);
+			return rc;
+		}
+
 		/* Power on the MAC controller (which may have been disabled) */
-		clear_bit(FLAG_RADIO_DOWN, &info->flags);
-		enable_interrupts(info);
+		clear_bit(FLAG_RADIO_DOWN, &ai->flags);
+		enable_interrupts(ai);
+
+		try_auto_wep(ai);
 	}
-	enable_MAC(info, &rsp, 1);
+	enable_MAC(ai, 1);
 
 	netif_start_queue(dev);
 	return 0;
@@ -2338,14 +2366,13 @@ static int airo_set_mac_address(struct net_device *dev, void *p)
 {
 	struct airo_info *ai = dev->priv;
 	struct sockaddr *addr = p;
-	Resp rsp;
 
 	readConfigRid(ai, 1);
 	memcpy (ai->config.macAddr, addr->sa_data, dev->addr_len);
 	set_bit (FLAG_COMMIT, &ai->flags);
 	disable_MAC(ai, 1);
 	writeConfigRid (ai, 1);
-	enable_MAC(ai, &rsp, 1);
+	enable_MAC(ai, 1);
 	memcpy (ai->dev->dev_addr, addr->sa_data, dev->addr_len);
 	if (ai->wifidev)
 		memcpy (ai->wifidev->dev_addr, addr->sa_data, dev->addr_len);
@@ -2392,6 +2419,11 @@ static int airo_close(struct net_device *dev) {
 		disable_MAC(ai, 1);
 #endif
 		disable_interrupts( ai );
+
+		free_irq(dev->irq, dev);
+
+		set_bit(JOB_DIE, &ai->jobs);
+		kthread_stop(ai->airo_thread_task);
 	}
 	return 0;
 }
@@ -2403,7 +2435,6 @@ void stop_airo_card( struct net_device *dev, int freeres )
 	set_bit(FLAG_RADIO_DOWN, &ai->flags);
 	disable_MAC(ai, 1);
 	disable_interrupts(ai);
-	free_irq( dev->irq, dev );
 	takedown_proc_entry( dev, ai );
 	if (test_bit(FLAG_REGISTERED, &ai->flags)) {
 		unregister_netdev( dev );
@@ -2414,9 +2445,6 @@ void stop_airo_card( struct net_device *dev, int freeres )
 		}
 		clear_bit(FLAG_REGISTERED, &ai->flags);
 	}
-	set_bit(JOB_DIE, &ai->jobs);
-	kthread_stop(ai->airo_thread_task);
-
 	/*
 	 * Clean out tx queue
 	 */
@@ -2554,8 +2582,7 @@ static int mpi_init_descriptors (struct airo_info *ai)
  * 2) Map PCI memory for issueing commands.
  * 3) Allocate memory (shared) to send and receive ethernet frames.
  */
-static int mpi_map_card(struct airo_info *ai, struct pci_dev *pci,
-		    const char *name)
+static int mpi_map_card(struct airo_info *ai, struct pci_dev *pci)
 {
 	unsigned long mem_start, mem_len, aux_start, aux_len;
 	int rc = -1;
@@ -2569,35 +2596,35 @@ static int mpi_map_card(struct airo_info *ai, struct pci_dev *pci,
 	aux_start = pci_resource_start(pci, 2);
 	aux_len = AUXMEMSIZE;
 
-	if (!request_mem_region(mem_start, mem_len, name)) {
-		airo_print_err(ai->dev->name, "Couldn't get region %x[%x] for %s",
-		       (int)mem_start, (int)mem_len, name);
+	if (!request_mem_region(mem_start, mem_len, DRV_NAME)) {
+		airo_print_err("", "Couldn't get region %x[%x]",
+			(int)mem_start, (int)mem_len);
 		goto out;
 	}
-	if (!request_mem_region(aux_start, aux_len, name)) {
-		airo_print_err(ai->dev->name, "Couldn't get region %x[%x] for %s",
-		       (int)aux_start, (int)aux_len, name);
+	if (!request_mem_region(aux_start, aux_len, DRV_NAME)) {
+		airo_print_err("", "Couldn't get region %x[%x]",
+			(int)aux_start, (int)aux_len);
 		goto free_region1;
 	}
 
 	ai->pcimem = ioremap(mem_start, mem_len);
 	if (!ai->pcimem) {
-		airo_print_err(ai->dev->name, "Couldn't map region %x[%x] for %s",
-		       (int)mem_start, (int)mem_len, name);
+		airo_print_err("", "Couldn't map region %x[%x]",
+			(int)mem_start, (int)mem_len);
 		goto free_region2;
 	}
 	ai->pciaux = ioremap(aux_start, aux_len);
 	if (!ai->pciaux) {
-		airo_print_err(ai->dev->name, "Couldn't map region %x[%x] for %s",
-		       (int)aux_start, (int)aux_len, name);
+		airo_print_err("", "Couldn't map region %x[%x]",
+			(int)aux_start, (int)aux_len);
 		goto free_memmap;
 	}
 
 	/* Reserve PKTSIZE for each fid and 2K for the Rids */
 	ai->shared = pci_alloc_consistent(pci, PCI_SHARED_LEN, &ai->shared_dma);
 	if (!ai->shared) {
-		airo_print_err(ai->dev->name, "Couldn't alloc_consistent %d",
-		       PCI_SHARED_LEN);
+		airo_print_err("", "Couldn't alloc_consistent %d",
+			PCI_SHARED_LEN);
 		goto free_auxmap;
 	}
 
@@ -2742,7 +2769,7 @@ static int airo_networks_allocate(struct airo_info *ai)
 	    kzalloc(AIRO_MAX_NETWORK_COUNT * sizeof(BSSListElement),
 		    GFP_KERNEL);
 	if (!ai->networks) {
-		airo_print_warn(ai->dev->name, "Out of memory allocating beacons");
+		airo_print_warn("", "Out of memory allocating beacons");
 		return -ENOMEM;
 	}
 
@@ -2770,7 +2797,6 @@ static int airo_test_wpa_capable(struct airo_info *ai)
 {
 	int status;
 	CapabilityRid cap_rid;
-	const char *name = ai->dev->name;
 
 	status = readCapabilityRid(ai, &cap_rid, 1);
 	if (status != SUCCESS) return 0;
@@ -2778,12 +2804,12 @@ static int airo_test_wpa_capable(struct airo_info *ai)
 	/* Only firmware versions 5.30.17 or better can do WPA */
 	if ((cap_rid.softVer > 0x530)
 	  || ((cap_rid.softVer == 0x530) && (cap_rid.softSubVer >= 17))) {
-		airo_print_info(name, "WPA is supported.");
+		airo_print_info("", "WPA is supported.");
 		return 1;
 	}
 
 	/* No WPA support */
-	airo_print_info(name, "WPA unsupported (only firmware versions 5.30.17"
+	airo_print_info("", "WPA unsupported (only firmware versions 5.30.17"
 		" and greater support WPA.  Detected %s)", cap_rid.prodVer);
 	return 0;
 }
@@ -2797,23 +2823,19 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	int i, rc;
 
 	/* Create the network device object. */
-        dev = alloc_etherdev(sizeof(*ai));
-        if (!dev) {
+	dev = alloc_netdev(sizeof(*ai), "", ether_setup);
+	if (!dev) {
 		airo_print_err("", "Couldn't alloc_etherdev");
 		return NULL;
-        }
-	if (dev_alloc_name(dev, dev->name) < 0) {
-		airo_print_err("", "Couldn't get name!");
-		goto err_out_free;
 	}
 
 	ai = dev->priv;
 	ai->wifidev = NULL;
-	ai->flags = 0;
+	ai->flags = 1 << FLAG_RADIO_DOWN;
 	ai->jobs = 0;
 	ai->dev = dev;
 	if (pci && (pci->device == 0x5000 || pci->device == 0xa504)) {
-		airo_print_dbg(dev->name, "Found an MPI350 card");
+		airo_print_dbg("", "Found an MPI350 card");
 		set_bit(FLAG_MPI, &ai->flags);
 	}
 	spin_lock_init(&ai->aux_lock);
@@ -2821,14 +2843,11 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	ai->config.len = 0;
 	ai->pci = pci;
 	init_waitqueue_head (&ai->thr_wait);
-	ai->airo_thread_task = kthread_run(airo_thread, dev, dev->name);
-	if (IS_ERR(ai->airo_thread_task))
-		goto err_out_free;
 	ai->tfm = NULL;
 	add_airo_dev(ai);
 
 	if (airo_networks_allocate (ai))
-		goto err_out_thr;
+		goto err_out_free;
 	airo_networks_initialize (ai);
 
 	/* The Airo-specific entries in the device structure. */
@@ -2851,27 +2870,22 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	dev->base_addr = port;
 
 	SET_NETDEV_DEV(dev, dmdev);
+	SET_MODULE_OWNER(dev);
 
 	reset_card (dev, 1);
 	msleep(400);
 
-	rc = request_irq( dev->irq, airo_interrupt, IRQF_SHARED, dev->name, dev );
-	if (rc) {
-		airo_print_err(dev->name, "register interrupt %d failed, rc %d",
-				irq, rc);
-		goto err_out_nets;
-	}
 	if (!is_pcmcia) {
-		if (!request_region( dev->base_addr, 64, dev->name )) {
+		if (!request_region(dev->base_addr, 64, DRV_NAME)) {
 			rc = -EBUSY;
 			airo_print_err(dev->name, "Couldn't request region");
-			goto err_out_irq;
+			goto err_out_nets;
 		}
 	}
 
 	if (test_bit(FLAG_MPI,&ai->flags)) {
-		if (mpi_map_card(ai, pci, dev->name)) {
-			airo_print_err(dev->name, "Could not map memory");
+		if (mpi_map_card(ai, pci)) {
+			airo_print_err("", "Could not map memory");
 			goto err_out_res;
 		}
 	}
@@ -2899,6 +2913,7 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 		ai->bssListRidLen = sizeof(BSSListRid) - sizeof(BSSListRidExtra);
 	}
 
+	strcpy(dev->name, "eth%d");
 	rc = register_netdev(dev);
 	if (rc) {
 		airo_print_err(dev->name, "Couldn't register_netdev");
@@ -2921,8 +2936,6 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	if (setup_proc_entry(dev, dev->priv) < 0)
 		goto err_out_wifi;
 
-	netif_start_queue(dev);
-	SET_MODULE_OWNER(dev);
 	return dev;
 
 err_out_wifi:
@@ -2940,14 +2953,9 @@ err_out_map:
 err_out_res:
 	if (!is_pcmcia)
 	        release_region( dev->base_addr, 64 );
-err_out_irq:
-	free_irq(dev->irq, dev);
 err_out_nets:
 	airo_networks_free(ai);
-err_out_thr:
 	del_airo_dev(ai);
-	set_bit(JOB_DIE, &ai->jobs);
-	kthread_stop(ai->airo_thread_task);
 err_out_free:
 	free_netdev(dev);
 	return NULL;
@@ -3529,9 +3537,11 @@ static u16 IN4500( struct airo_info *ai, u16 reg ) {
 	return rc;
 }
 
-static int enable_MAC( struct airo_info *ai, Resp *rsp, int lock ) {
+static int enable_MAC(struct airo_info *ai, int lock)
+{
 	int rc;
-        Cmd cmd;
+	Cmd cmd;
+	Resp rsp;
 
 	/* FLAG_RADIO_OFF : Radio disabled via /proc or Wireless Extensions
 	 * FLAG_RADIO_DOWN : Radio disabled via "ifconfig ethX down"
@@ -3547,7 +3557,7 @@ static int enable_MAC( struct airo_info *ai, Resp *rsp, int lock ) {
 	if (!test_bit(FLAG_ENABLED, &ai->flags)) {
 		memset(&cmd, 0, sizeof(cmd));
 		cmd.cmd = MAC_ENABLE;
-		rc = issuecommand(ai, &cmd, rsp);
+		rc = issuecommand(ai, &cmd, &rsp);
 		if (rc == SUCCESS)
 			set_bit(FLAG_ENABLED, &ai->flags);
 	} else
@@ -3557,8 +3567,12 @@ static int enable_MAC( struct airo_info *ai, Resp *rsp, int lock ) {
 	    up(&ai->sem);
 
 	if (rc)
-		airo_print_err(ai->dev->name, "%s: Cannot enable MAC, err=%d",
-			__FUNCTION__, rc);
+		airo_print_err(ai->dev->name, "Cannot enable MAC");
+	else if ((rsp.status & 0xFF00) != 0) {
+		airo_print_err(ai->dev->name, "Bad MAC enable reason=%x, "
+			"rid=%x, offset=%d", rsp.rsp0, rsp.rsp1, rsp.rsp2);
+		rc = ERROR;
+	}
 	return rc;
 }
 
@@ -3902,12 +3916,9 @@ static u16 setup_card(struct airo_info *ai, u8 *mac, int lock)
 		if ( status != SUCCESS ) return ERROR;
 	}
 
-	status = enable_MAC(ai, &rsp, lock);
-	if ( status != SUCCESS || (rsp.status & 0xFF00) != 0) {
-		airo_print_err(ai->dev->name, "Bad MAC enable reason = %x, rid = %x,"
-			" offset = %d", rsp.rsp0, rsp.rsp1, rsp.rsp2 );
+	status = enable_MAC(ai, lock);
+	if (status != SUCCESS)
 		return ERROR;
-	}
 
 	/* Grab the initial wep key, we gotta save it for auto_wep */
 	rc = readWepKeyRid(ai, &wkr, 1, lock);
@@ -3919,10 +3930,7 @@ static u16 setup_card(struct airo_info *ai, u8 *mac, int lock)
 		rc = readWepKeyRid(ai, &wkr, 0, lock);
 	} while(lastindex != wkr.kindex);
 
-	if (auto_wep) {
-		ai->expires = RUN_AT(3*HZ);
-		wake_up_interruptible(&ai->thr_wait);
-	}
+	try_auto_wep(ai);
 
 	return SUCCESS;
 }
@@ -4004,7 +4012,7 @@ static int bap_setup(struct airo_info *ai, u16 rid, u16 offset, int whichbap )
 		}
 		if ( !(max_tries--) ) {
 			airo_print_err(ai->dev->name,
-				"airo: BAP setup error too many retries\n");
+				"BAP setup error too many retries\n");
 			return ERROR;
 		}
 		// -- PC4500 missed it, try again
@@ -5152,7 +5160,6 @@ static void proc_SSID_on_close( struct inode *inode, struct file *file ) {
 	struct net_device *dev = dp->data;
 	struct airo_info *ai = dev->priv;
 	SsidRid SSID_rid;
-	Resp rsp;
 	int i;
 	int offset = 0;
 
@@ -5177,7 +5184,7 @@ static void proc_SSID_on_close( struct inode *inode, struct file *file ) {
 		SSID_rid.len = sizeof(SSID_rid);
 	disable_MAC(ai, 1);
 	writeSsidRid(ai, &SSID_rid, 1);
-	enable_MAC(ai, &rsp, 1);
+	enable_MAC(ai, 1);
 }
 
 static inline u8 hexVal(char c) {
@@ -5193,7 +5200,6 @@ static void proc_APList_on_close( struct inode *inode, struct file *file ) {
 	struct net_device *dev = dp->data;
 	struct airo_info *ai = dev->priv;
 	APListRid APList_rid;
-	Resp rsp;
 	int i;
 
 	if ( !data->writelen ) return;
@@ -5218,18 +5224,17 @@ static void proc_APList_on_close( struct inode *inode, struct file *file ) {
 	}
 	disable_MAC(ai, 1);
 	writeAPListRid(ai, &APList_rid, 1);
-	enable_MAC(ai, &rsp, 1);
+	enable_MAC(ai, 1);
 }
 
 /* This function wraps PC4500_writerid with a MAC disable */
 static int do_writerid( struct airo_info *ai, u16 rid, const void *rid_data,
 			int len, int dummy ) {
 	int rc;
-	Resp rsp;
 
 	disable_MAC(ai, 1);
 	rc = PC4500_writerid(ai, rid, rid_data, len, 1);
-	enable_MAC(ai, &rsp, 1);
+	enable_MAC(ai, 1);
 	return rc;
 }
 
@@ -5260,7 +5265,6 @@ static int set_wep_key(struct airo_info *ai, u16 index,
 		       const char *key, u16 keylen, int perm, int lock ) {
 	static const unsigned char macaddr[ETH_ALEN] = { 0x01, 0, 0, 0, 0, 0 };
 	WepKeyRid wkr;
-	Resp rsp;
 
 	memset(&wkr, 0, sizeof(wkr));
 	if (keylen == 0) {
@@ -5280,7 +5284,7 @@ static int set_wep_key(struct airo_info *ai, u16 index,
 
 	if (perm) disable_MAC(ai, lock);
 	writeWepKeyRid(ai, &wkr, perm, lock);
-	if (perm) enable_MAC(ai, &rsp, lock);
+	if (perm) enable_MAC(ai, lock);
 	return 0;
 }
 
@@ -5548,7 +5552,6 @@ static int proc_close( struct inode *inode, struct file *file )
    changed. */
 static void timer_func( struct net_device *dev ) {
 	struct airo_info *apriv = dev->priv;
-	Resp rsp;
 
 /* We don't have a link so try changing the authtype */
 	readConfigRid(apriv, 0);
@@ -5575,7 +5578,7 @@ static void timer_func( struct net_device *dev ) {
 	}
 	set_bit (FLAG_COMMIT, &apriv->flags);
 	writeConfigRid(apriv, 0);
-	enable_MAC(apriv, &rsp, 0);
+	enable_MAC(apriv, 0);
 	up(&apriv->sem);
 
 /* Schedule check to see if the change worked */
@@ -5597,8 +5600,10 @@ static int __devinit airo_pci_probe(struct pci_dev *pdev,
 			dev = _init_airo_card(pdev->irq, pdev->resource[0].start, 0, pdev, &pdev->dev);
 	else
 			dev = _init_airo_card(pdev->irq, pdev->resource[2].start, 0, pdev, &pdev->dev);
-	if (!dev)
+	if (!dev) {
+		pci_disable_device(pdev);
 		return -ENODEV;
+	}
 
 	pci_set_drvdata(pdev, dev);
 	return 0;
@@ -5610,6 +5615,8 @@ static void __devexit airo_pci_remove(struct pci_dev *pdev)
 
 	airo_print_info(dev->name, "Unregistering...");
 	stop_airo_card(dev, 1);
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
 }
 
 static int airo_pci_suspend(struct pci_dev *pdev, pm_message_t state)
@@ -5646,7 +5653,6 @@ static int airo_pci_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct airo_info *ai = dev->priv;
-	Resp rsp;
 	pci_power_t prev_state = pdev->current_state;
 
 	pci_set_power_state(pdev, PCI_D0);
@@ -5679,7 +5685,7 @@ static int airo_pci_resume(struct pci_dev *pdev)
 		ai->APList = NULL;
 	}
 	writeConfigRid(ai, 0);
-	enable_MAC(ai, &rsp, 0);
+	enable_MAC(ai, 0);
 	ai->power = PMSG_ON;
 	netif_device_attach(dev);
 	netif_wake_queue(dev);
@@ -5903,7 +5909,6 @@ static int airo_set_essid(struct net_device *dev,
 			  char *extra)
 {
 	struct airo_info *local = dev->priv;
-	Resp rsp;
 	SsidRid SSID_rid;		/* SSIDs */
 
 	/* Reload the list of current SSID */
@@ -5935,7 +5940,7 @@ static int airo_set_essid(struct net_device *dev,
 	/* Write it to the card */
 	disable_MAC(local, 1);
 	writeSsidRid(local, &SSID_rid, 1);
-	enable_MAC(local, &rsp, 1);
+	enable_MAC(local, 1);
 
 	return 0;
 }
@@ -6000,7 +6005,7 @@ static int airo_set_wap(struct net_device *dev,
 		memcpy(APList_rid.ap[0], awrq->sa_data, ETH_ALEN);
 		disable_MAC(local, 1);
 		writeAPListRid(local, &APList_rid, 1);
-		enable_MAC(local, &rsp, 1);
+		enable_MAC(local, 1);
 	}
 	return 0;
 }
@@ -7454,7 +7459,6 @@ static int airo_config_commit(struct net_device *dev,
 			      char *extra)			/* NULL */
 {
 	struct airo_info *local = dev->priv;
-	Resp rsp;
 
 	if (!test_bit (FLAG_COMMIT, &local->flags))
 		return 0;
@@ -7479,7 +7483,7 @@ static int airo_config_commit(struct net_device *dev,
 	if (down_interruptible(&local->sem))
 		return -ERESTARTSYS;
 	writeConfigRid(local, 0);
-	enable_MAC(local, &rsp, 0);
+	enable_MAC(local, 0);
 	if (test_bit (FLAG_RESET, &local->flags))
 		airo_set_promisc(local);
 	else
@@ -7746,7 +7750,6 @@ static int readrids(struct net_device *dev, aironet_ioctl *comp) {
 	unsigned char *iobuf;
 	int len;
 	struct airo_info *ai = dev->priv;
-	Resp rsp;
 
 	if (test_bit(FLAG_FLASHING, &ai->flags))
 		return -EIO;
@@ -7758,7 +7761,7 @@ static int readrids(struct net_device *dev, aironet_ioctl *comp) {
 		if (test_bit(FLAG_COMMIT, &ai->flags)) {
 			disable_MAC (ai, 1);
 			writeConfigRid (ai, 1);
-			enable_MAC (ai, &rsp, 1);
+			enable_MAC(ai, 1);
 		}
 		break;
 	case AIROGSLIST:    ridcode = RID_SSID;         break;
@@ -7815,7 +7818,6 @@ static int writerids(struct net_device *dev, aironet_ioctl *comp) {
 	struct airo_info *ai = dev->priv;
 	int  ridcode;
         int  enabled;
-	Resp      rsp;
 	static int (* writer)(struct airo_info *, u16 rid, const void *, int, int);
 	unsigned char *iobuf;
 
@@ -7849,7 +7851,7 @@ static int writerids(struct net_device *dev, aironet_ioctl *comp) {
 		 * same with MAC off
 		 */
 	case AIROPMACON:
-		if (enable_MAC(ai, &rsp, 1) != 0)
+		if (enable_MAC(ai, 1) != 0)
 			return -EIO;
 		return 0;
 
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index d51daf8..072ede7 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -1768,7 +1768,8 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
 
 		if (priv->stop_rf_kill) {
 			priv->stop_rf_kill = 0;
-			queue_delayed_work(priv->workqueue, &priv->rf_kill, HZ);
+			queue_delayed_work(priv->workqueue, &priv->rf_kill,
+					   round_jiffies(HZ));
 		}
 
 		deferred = 1;
@@ -2098,7 +2099,7 @@ static void isr_indicate_rf_kill(struct ipw2100_priv *priv, u32 status)
 	/* Make sure the RF Kill check timer is running */
 	priv->stop_rf_kill = 0;
 	cancel_delayed_work(&priv->rf_kill);
-	queue_delayed_work(priv->workqueue, &priv->rf_kill, HZ);
+	queue_delayed_work(priv->workqueue, &priv->rf_kill, round_jiffies(HZ));
 }
 
 static void isr_scan_complete(struct ipw2100_priv *priv, u32 status)
@@ -4233,7 +4234,8 @@ static int ipw_radio_kill_sw(struct ipw2100_priv *priv, int disable_radio)
 			/* Make sure the RF_KILL check timer is running */
 			priv->stop_rf_kill = 0;
 			cancel_delayed_work(&priv->rf_kill);
-			queue_delayed_work(priv->workqueue, &priv->rf_kill, HZ);
+			queue_delayed_work(priv->workqueue, &priv->rf_kill,
+					   round_jiffies(HZ));
 		} else
 			schedule_reset(priv);
 	}
@@ -5969,7 +5971,8 @@ static void ipw2100_rf_kill(struct work_struct *work)
 	if (rf_kill_active(priv)) {
 		IPW_DEBUG_RF_KILL("RF Kill active, rescheduling GPIO check\n");
 		if (!priv->stop_rf_kill)
-			queue_delayed_work(priv->workqueue, &priv->rf_kill, HZ);
+			queue_delayed_work(priv->workqueue, &priv->rf_kill,
+					   round_jiffies(HZ));
 		goto exit_unlock;
 	}
 
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 7cb2052..aa32a97 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -1751,7 +1751,7 @@ static int ipw_radio_kill_sw(struct ipw_priv *priv, int disable_radio)
 			/* Make sure the RF_KILL check timer is running */
 			cancel_delayed_work(&priv->rf_kill);
 			queue_delayed_work(priv->workqueue, &priv->rf_kill,
-					   2 * HZ);
+					   round_jiffies(2 * HZ));
 		} else
 			queue_work(priv->workqueue, &priv->up);
 	}
@@ -4690,7 +4690,8 @@ static void ipw_rx_notification(struct ipw_priv *priv,
 			else if (priv->config & CFG_BACKGROUND_SCAN
 				 && priv->status & STATUS_ASSOCIATED)
 				queue_delayed_work(priv->workqueue,
-						   &priv->request_scan, HZ);
+						   &priv->request_scan,
+						   round_jiffies(HZ));
 
 			/* Send an empty event to user space.
 			 * We don't send the received data on the event because
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index 13f6528..4a8f5dc 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -240,7 +240,7 @@ static int wlan_cmd_802_11_enable_rsn(wlan_private * priv,
 		if (*enable)
 			penableRSN->enable = cpu_to_le16(cmd_enable_rsn);
 		else
-			penableRSN->enable = cpu_to_le16(cmd_enable_rsn);
+			penableRSN->enable = cpu_to_le16(cmd_disable_rsn);
 	}
 
 	lbs_deb_leave(LBS_DEB_CMD);
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index 88d9d2d..769c86f 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -439,7 +439,6 @@ static int process_rxed_802_11_packet(wlan_private * priv, struct sk_buff *skb)
 	ret = 0;
 
 done:
-	skb->protocol = __constant_htons(0x0019);	/* ETH_P_80211_RAW */
 	lbs_deb_leave_args(LBS_DEB_RX, "ret %d", ret);
 	return ret;
 }
diff --git a/drivers/net/wireless/libertas/version.h b/drivers/net/wireless/libertas/version.h
deleted file mode 100644
index 8b13789..0000000
--- a/drivers/net/wireless/libertas/version.h
+++ /dev/null
@@ -1 +0,0 @@
-
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index f42b796..2fcc3bf 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -1719,9 +1719,6 @@ static int wlan_set_encodeext(struct net_device *dev,
 			pkey->type = KEY_TYPE_ID_TKIP;
 		} else if (alg == IW_ENCODE_ALG_CCMP) {
 			pkey->type = KEY_TYPE_ID_AES;
-		} else {
-			ret = -EINVAL;
-			goto out;
 		}
 
 		/* If WPA isn't enabled yet, do that now */
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 283be4a..585f599 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -1853,7 +1853,6 @@ prism54_del_mac(struct net_device *ndev, struct iw_request_info *info,
 	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_acl *acl = &priv->acl;
 	struct mac_entry *entry;
-	struct list_head *ptr;
 	struct sockaddr *addr = (struct sockaddr *) extra;
 
 	if (addr->sa_family != ARPHRD_ETHER)
@@ -1861,11 +1860,9 @@ prism54_del_mac(struct net_device *ndev, struct iw_request_info *info,
 
 	if (down_interruptible(&acl->sem))
 		return -ERESTARTSYS;
-	for (ptr = acl->mac_list.next; ptr != &acl->mac_list; ptr = ptr->next) {
-		entry = list_entry(ptr, struct mac_entry, _list);
-
+	list_for_each_entry(entry, &acl->mac_list, _list) {
 		if (memcmp(entry->addr, addr->sa_data, ETH_ALEN) == 0) {
-			list_del(ptr);
+			list_del(&entry->_list);
 			acl->size--;
 			kfree(entry);
 			up(&acl->sem);
@@ -1883,7 +1880,6 @@ prism54_get_mac(struct net_device *ndev, struct iw_request_info *info,
 	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_acl *acl = &priv->acl;
 	struct mac_entry *entry;
-	struct list_head *ptr;
 	struct sockaddr *dst = (struct sockaddr *) extra;
 
 	dwrq->length = 0;
@@ -1891,9 +1887,7 @@ prism54_get_mac(struct net_device *ndev, struct iw_request_info *info,
 	if (down_interruptible(&acl->sem))
 		return -ERESTARTSYS;
 
-	for (ptr = acl->mac_list.next; ptr != &acl->mac_list; ptr = ptr->next) {
-		entry = list_entry(ptr, struct mac_entry, _list);
-
+	list_for_each_entry(entry, &acl->mac_list, _list) {
 		memcpy(dst->sa_data, entry->addr, ETH_ALEN);
 		dst->sa_family = ARPHRD_ETHER;
 		dwrq->length++;
@@ -1960,7 +1954,6 @@ prism54_get_policy(struct net_device *ndev, struct iw_request_info *info,
 static int
 prism54_mac_accept(struct islpci_acl *acl, char *mac)
 {
-	struct list_head *ptr;
 	struct mac_entry *entry;
 	int res = 0;
 
@@ -1972,8 +1965,7 @@ prism54_mac_accept(struct islpci_acl *acl, char *mac)
 		return 1;
 	}
 
-	for (ptr = acl->mac_list.next; ptr != &acl->mac_list; ptr = ptr->next) {
-		entry = list_entry(ptr, struct mac_entry, _list);
+	list_for_each_entry(entry, &acl->mac_list, _list) {
 		if (memcmp(entry->addr, mac, ETH_ALEN) == 0) {
 			res = 1;
 			break;
@@ -2216,11 +2208,9 @@ prism54_wpa_bss_ie_init(islpci_private *priv)
 void
 prism54_wpa_bss_ie_clean(islpci_private *priv)
 {
-	struct list_head *ptr, *n;
+	struct islpci_bss_wpa_ie *bss, *n;
 
-	list_for_each_safe(ptr, n, &priv->bss_wpa_list) {
-		struct islpci_bss_wpa_ie *bss;
-		bss = list_entry(ptr, struct islpci_bss_wpa_ie, list);
+	list_for_each_entry_safe(bss, n, &priv->bss_wpa_list, list) {
 		kfree(bss);
 	}
 }
diff --git a/drivers/net/wireless/rtl8187_rtl8225.c b/drivers/net/wireless/rtl8187_rtl8225.c
index e25a09f..efc4120 100644
--- a/drivers/net/wireless/rtl8187_rtl8225.c
+++ b/drivers/net/wireless/rtl8187_rtl8225.c
@@ -67,7 +67,7 @@ static void rtl8225_write_bitbang(struct ieee80211_hw *dev, u8 addr, u16 data)
 	msleep(2);
 }
 
-static void rtl8225_write_8051(struct ieee80211_hw *dev, u8 addr, u16 data)
+static void rtl8225_write_8051(struct ieee80211_hw *dev, u8 addr, __le16 data)
 {
 	struct rtl8187_priv *priv = dev->priv;
 	u16 reg80, reg82, reg84;
@@ -106,7 +106,7 @@ void rtl8225_write(struct ieee80211_hw *dev, u8 addr, u16 data)
 	struct rtl8187_priv *priv = dev->priv;
 
 	if (priv->asic_rev)
-		rtl8225_write_8051(dev, addr, data);
+		rtl8225_write_8051(dev, addr, cpu_to_le16(data));
 	else
 		rtl8225_write_bitbang(dev, addr, data);
 }
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index 5b624bf..c39f198 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -49,8 +49,9 @@ void zd_chip_clear(struct zd_chip *chip)
 	ZD_MEMCLEAR(chip, sizeof(*chip));
 }
 
-static int scnprint_mac_oui(const u8 *addr, char *buffer, size_t size)
+static int scnprint_mac_oui(struct zd_chip *chip, char *buffer, size_t size)
 {
+	u8 *addr = zd_usb_to_netdev(&chip->usb)->dev_addr;
 	return scnprintf(buffer, size, "%02x-%02x-%02x",
 		         addr[0], addr[1], addr[2]);
 }
@@ -61,10 +62,10 @@ static int scnprint_id(struct zd_chip *chip, char *buffer, size_t size)
 	int i = 0;
 
 	i = scnprintf(buffer, size, "zd1211%s chip ",
-		      chip->is_zd1211b ? "b" : "");
+		      zd_chip_is_zd1211b(chip) ? "b" : "");
 	i += zd_usb_scnprint_id(&chip->usb, buffer+i, size-i);
 	i += scnprintf(buffer+i, size-i, " ");
-	i += scnprint_mac_oui(chip->e2p_mac, buffer+i, size-i);
+	i += scnprint_mac_oui(chip, buffer+i, size-i);
 	i += scnprintf(buffer+i, size-i, " ");
 	i += zd_rf_scnprint_id(&chip->rf, buffer+i, size-i);
 	i += scnprintf(buffer+i, size-i, " pa%1x %c%c%c%c%c", chip->pa_type,
@@ -366,64 +367,9 @@ error:
 	return r;
 }
 
-static int _read_mac_addr(struct zd_chip *chip, u8 *mac_addr,
-	                  const zd_addr_t *addr)
-{
-	int r;
-	u32 parts[2];
-
-	r = zd_ioread32v_locked(chip, parts, (const zd_addr_t *)addr, 2);
-	if (r) {
-		dev_dbg_f(zd_chip_dev(chip),
-			"error: couldn't read e2p macs. Error number %d\n", r);
-		return r;
-	}
-
-	mac_addr[0] = parts[0];
-	mac_addr[1] = parts[0] >>  8;
-	mac_addr[2] = parts[0] >> 16;
-	mac_addr[3] = parts[0] >> 24;
-	mac_addr[4] = parts[1];
-	mac_addr[5] = parts[1] >>  8;
-
-	return 0;
-}
-
-static int read_e2p_mac_addr(struct zd_chip *chip)
-{
-	static const zd_addr_t addr[2] = { E2P_MAC_ADDR_P1, E2P_MAC_ADDR_P2 };
-
-	ZD_ASSERT(mutex_is_locked(&chip->mutex));
-	return _read_mac_addr(chip, chip->e2p_mac, (const zd_addr_t *)addr);
-}
-
 /* MAC address: if custom mac addresses are to to be used CR_MAC_ADDR_P1 and
  *              CR_MAC_ADDR_P2 must be overwritten
  */
-void zd_get_e2p_mac_addr(struct zd_chip *chip, u8 *mac_addr)
-{
-	mutex_lock(&chip->mutex);
-	memcpy(mac_addr, chip->e2p_mac, ETH_ALEN);
-	mutex_unlock(&chip->mutex);
-}
-
-static int read_mac_addr(struct zd_chip *chip, u8 *mac_addr)
-{
-	static const zd_addr_t addr[2] = { CR_MAC_ADDR_P1, CR_MAC_ADDR_P2 };
-	return _read_mac_addr(chip, mac_addr, (const zd_addr_t *)addr);
-}
-
-int zd_read_mac_addr(struct zd_chip *chip, u8 *mac_addr)
-{
-	int r;
-
-	dev_dbg_f(zd_chip_dev(chip), "\n");
-	mutex_lock(&chip->mutex);
-	r = read_mac_addr(chip, mac_addr);
-	mutex_unlock(&chip->mutex);
-	return r;
-}
-
 int zd_write_mac_addr(struct zd_chip *chip, const u8 *mac_addr)
 {
 	int r;
@@ -444,12 +390,6 @@ int zd_write_mac_addr(struct zd_chip *chip, const u8 *mac_addr)
 
 	mutex_lock(&chip->mutex);
 	r = zd_iowrite32a_locked(chip, reqs, ARRAY_SIZE(reqs));
-#ifdef DEBUG
-	{
-		u8 tmp[ETH_ALEN];
-		read_mac_addr(chip, tmp);
-	}
-#endif /* DEBUG */
 	mutex_unlock(&chip->mutex);
 	return r;
 }
@@ -809,7 +749,7 @@ out:
 
 static int hw_reset_phy(struct zd_chip *chip)
 {
-	return chip->is_zd1211b ? zd1211b_hw_reset_phy(chip) :
+	return zd_chip_is_zd1211b(chip) ? zd1211b_hw_reset_phy(chip) :
 		                  zd1211_hw_reset_phy(chip);
 }
 
@@ -874,7 +814,7 @@ static int hw_init_hmac(struct zd_chip *chip)
 	if (r)
 		return r;
 
-	return chip->is_zd1211b ?
+	return zd_chip_is_zd1211b(chip) ?
 		zd1211b_hw_init_hmac(chip) : zd1211_hw_init_hmac(chip);
 }
 
@@ -1136,8 +1076,15 @@ static int read_fw_regs_offset(struct zd_chip *chip)
 	return 0;
 }
 
+/* Read mac address using pre-firmware interface */
+int zd_chip_read_mac_addr_fw(struct zd_chip *chip, u8 *addr)
+{
+	dev_dbg_f(zd_chip_dev(chip), "\n");
+	return zd_usb_read_fw(&chip->usb, E2P_MAC_ADDR_P1, addr,
+		ETH_ALEN);
+}
 
-int zd_chip_init_hw(struct zd_chip *chip, u8 device_type)
+int zd_chip_init_hw(struct zd_chip *chip)
 {
 	int r;
 	u8 rf_type;
@@ -1145,7 +1092,6 @@ int zd_chip_init_hw(struct zd_chip *chip, u8 device_type)
 	dev_dbg_f(zd_chip_dev(chip), "\n");
 
 	mutex_lock(&chip->mutex);
-	chip->is_zd1211b = (device_type == DEVICE_ZD1211B) != 0;
 
 #ifdef DEBUG
 	r = test_init(chip);
@@ -1201,10 +1147,6 @@ int zd_chip_init_hw(struct zd_chip *chip, u8 device_type)
 		goto out;
 #endif /* DEBUG */
 
-	r = read_e2p_mac_addr(chip);
-	if (r)
-		goto out;
-
 	r = read_cal_int_tables(chip);
 	if (r)
 		goto out;
@@ -1259,7 +1201,7 @@ static int update_channel_integration_and_calibration(struct zd_chip *chip,
 	r = update_pwr_int(chip, channel);
 	if (r)
 		return r;
-	if (chip->is_zd1211b) {
+	if (zd_chip_is_zd1211b(chip)) {
 		static const struct zd_ioreq16 ioreqs[] = {
 			{ CR69, 0x28 },
 			{},
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index 79d0288..f469857 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -704,7 +704,6 @@ struct zd_chip {
 	struct mutex mutex;
 	/* Base address of FW_REG_ registers */
 	zd_addr_t fw_regs_base;
-	u8 e2p_mac[ETH_ALEN];
 	/* EepSetPoint in the vendor driver */
 	u8 pwr_cal_values[E2P_CHANNEL_COUNT];
 	/* integration values in the vendor driver */
@@ -715,7 +714,7 @@ struct zd_chip {
 	unsigned int pa_type:4,
 		patch_cck_gain:1, patch_cr157:1, patch_6m_band_edge:1,
 		new_phy_layout:1, al2230s_bit:1,
-		is_zd1211b:1, supports_tx_led:1;
+		supports_tx_led:1;
 };
 
 static inline struct zd_chip *zd_usb_to_chip(struct zd_usb *usb)
@@ -734,9 +733,15 @@ void zd_chip_init(struct zd_chip *chip,
 	         struct net_device *netdev,
 	         struct usb_interface *intf);
 void zd_chip_clear(struct zd_chip *chip);
-int zd_chip_init_hw(struct zd_chip *chip, u8 device_type);
+int zd_chip_read_mac_addr_fw(struct zd_chip *chip, u8 *addr);
+int zd_chip_init_hw(struct zd_chip *chip);
 int zd_chip_reset(struct zd_chip *chip);
 
+static inline int zd_chip_is_zd1211b(struct zd_chip *chip)
+{
+	return chip->usb.is_zd1211b;
+}
+
 static inline int zd_ioread16v_locked(struct zd_chip *chip, u16 *values,
 	                              const zd_addr_t *addresses,
 				      unsigned int count)
@@ -825,8 +830,6 @@ static inline u8 _zd_chip_get_channel(struct zd_chip *chip)
 }
 u8  zd_chip_get_channel(struct zd_chip *chip);
 int zd_read_regdomain(struct zd_chip *chip, u8 *regdomain);
-void zd_get_e2p_mac_addr(struct zd_chip *chip, u8 *mac_addr);
-int zd_read_mac_addr(struct zd_chip *chip, u8 *mac_addr);
 int zd_write_mac_addr(struct zd_chip *chip, const u8 *mac_addr);
 int zd_chip_switch_radio_on(struct zd_chip *chip);
 int zd_chip_switch_radio_off(struct zd_chip *chip);
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 6753d24..f6c487a 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -86,38 +86,46 @@ out:
 	return r;
 }
 
-int zd_mac_init_hw(struct zd_mac *mac, u8 device_type)
+int zd_mac_preinit_hw(struct zd_mac *mac)
 {
 	int r;
-	struct zd_chip *chip = &mac->chip;
 	u8 addr[ETH_ALEN];
+
+	r = zd_chip_read_mac_addr_fw(&mac->chip, addr);
+	if (r)
+		return r;
+
+	memcpy(mac->netdev->dev_addr, addr, ETH_ALEN);
+	return 0;
+}
+
+int zd_mac_init_hw(struct zd_mac *mac)
+{
+	int r;
+	struct zd_chip *chip = &mac->chip;
 	u8 default_regdomain;
 
 	r = zd_chip_enable_int(chip);
 	if (r)
 		goto out;
-	r = zd_chip_init_hw(chip, device_type);
+	r = zd_chip_init_hw(chip);
 	if (r)
 		goto disable_int;
 
-	zd_get_e2p_mac_addr(chip, addr);
-	r = zd_write_mac_addr(chip, addr);
-	if (r)
-		goto disable_int;
 	ZD_ASSERT(!irqs_disabled());
-	spin_lock_irq(&mac->lock);
-	memcpy(mac->netdev->dev_addr, addr, ETH_ALEN);
-	spin_unlock_irq(&mac->lock);
 
 	r = zd_read_regdomain(chip, &default_regdomain);
 	if (r)
 		goto disable_int;
 	if (!zd_regdomain_supported(default_regdomain)) {
-		dev_dbg_f(zd_mac_dev(mac),
-			  "Regulatory Domain %#04x is not supported.\n",
-		          default_regdomain);
-		r = -EINVAL;
-		goto disable_int;
+		/* The vendor driver overrides the regulatory domain and
+		 * allowed channel registers and unconditionally restricts
+		 * available channels to 1-11 everywhere. Match their
+		 * questionable behaviour only for regdomains which we don't
+		 * recognise. */
+		dev_warn(zd_mac_dev(mac),  "Unrecognised regulatory domain: "
+			"%#04x. Defaulting to FCC.\n", default_regdomain);
+		default_regdomain = ZD_REGDOMAIN_FCC;
 	}
 	spin_lock_irq(&mac->lock);
 	mac->regdomain = mac->default_regdomain = default_regdomain;
@@ -164,14 +172,25 @@ int zd_mac_open(struct net_device *netdev)
 {
 	struct zd_mac *mac = zd_netdev_mac(netdev);
 	struct zd_chip *chip = &mac->chip;
+	struct zd_usb *usb = &chip->usb;
 	int r;
 
+	if (!usb->initialized) {
+		r = zd_usb_init_hw(usb);
+		if (r)
+			goto out;
+	}
+
 	tasklet_enable(&mac->rx_tasklet);
 
 	r = zd_chip_enable_int(chip);
 	if (r < 0)
 		goto out;
 
+	r = zd_write_mac_addr(chip, netdev->dev_addr);
+	if (r)
+		goto disable_int;
+
 	r = zd_chip_set_basic_rates(chip, CR_RATES_80211B | CR_RATES_80211G);
 	if (r < 0)
 		goto disable_int;
@@ -251,9 +270,11 @@ int zd_mac_set_mac_address(struct net_device *netdev, void *p)
 	dev_dbg_f(zd_mac_dev(mac),
 		  "Setting MAC to " MAC_FMT "\n", MAC_ARG(addr->sa_data));
 
-	r = zd_write_mac_addr(chip, addr->sa_data);
-	if (r)
-		return r;
+	if (netdev->flags & IFF_UP) {
+		r = zd_write_mac_addr(chip, addr->sa_data);
+		if (r)
+			return r;
+	}
 
 	spin_lock_irqsave(&mac->lock, flags);
 	memcpy(netdev->dev_addr, addr->sa_data, ETH_ALEN);
@@ -855,7 +876,7 @@ static int fill_ctrlset(struct zd_mac *mac,
 	/* ZD1211B: Computing the length difference this way, gives us
 	 * flexibility to compute the packet length.
 	 */
-	cs->packet_length = cpu_to_le16(mac->chip.is_zd1211b ?
+	cs->packet_length = cpu_to_le16(zd_chip_is_zd1211b(&mac->chip) ?
 			packet_length - frag_len : packet_length);
 
 	/*
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.h b/drivers/net/wireless/zd1211rw/zd_mac.h
index faf4c78..9f9344e 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -189,7 +189,8 @@ int zd_mac_init(struct zd_mac *mac,
 		struct usb_interface *intf);
 void zd_mac_clear(struct zd_mac *mac);
 
-int zd_mac_init_hw(struct zd_mac *mac, u8 device_type);
+int zd_mac_preinit_hw(struct zd_mac *mac);
+int zd_mac_init_hw(struct zd_mac *mac);
 
 int zd_mac_open(struct net_device *netdev);
 int zd_mac_stop(struct net_device *netdev);
diff --git a/drivers/net/wireless/zd1211rw/zd_rf.c b/drivers/net/wireless/zd1211rw/zd_rf.c
index 7407409..abe5d38 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf.c
@@ -34,7 +34,7 @@ static const char * const rfs[] = {
 	[AL2210_RF]	= "AL2210_RF",
 	[MAXIM_NEW_RF]	= "MAXIM_NEW_RF",
 	[UW2453_RF]	= "UW2453_RF",
-	[UNKNOWN_A_RF]	= "UNKNOWN_A_RF",
+	[AL2230S_RF]	= "AL2230S_RF",
 	[RALINK_RF]	= "RALINK_RF",
 	[INTERSIL_RF]	= "INTERSIL_RF",
 	[RF2959_RF]	= "RF2959_RF",
@@ -77,6 +77,7 @@ int zd_rf_init_hw(struct zd_rf *rf, u8 type)
 		r = zd_rf_init_rf2959(rf);
 		break;
 	case AL2230_RF:
+	case AL2230S_RF:
 		r = zd_rf_init_al2230(rf);
 		break;
 	case AL7230B_RF:
diff --git a/drivers/net/wireless/zd1211rw/zd_rf.h b/drivers/net/wireless/zd1211rw/zd_rf.h
index c6dfd82..30502f2 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf.h
+++ b/drivers/net/wireless/zd1211rw/zd_rf.h
@@ -26,7 +26,7 @@
 #define AL2210_RF			0x7
 #define MAXIM_NEW_RF			0x8
 #define UW2453_RF			0x9
-#define UNKNOWN_A_RF			0xa
+#define AL2230S_RF			0xa
 #define RALINK_RF			0xb
 #define INTERSIL_RF			0xc
 #define RF2959_RF			0xd
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_al2230.c b/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
index e7a4ecf..006774d 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
@@ -21,6 +21,8 @@
 #include "zd_usb.h"
 #include "zd_chip.h"
 
+#define IS_AL2230S(chip) ((chip)->al2230s_bit || (chip)->rf.type == AL2230S_RF)
+
 static const u32 zd1211_al2230_table[][3] = {
 	RF_CHANNEL( 1) = { 0x03f790, 0x033331, 0x00000d, },
 	RF_CHANNEL( 2) = { 0x03f790, 0x0b3331, 0x00000d, },
@@ -176,7 +178,7 @@ static int zd1211_al2230_init_hw(struct zd_rf *rf)
 	if (r)
 		return r;
 
-	if (chip->al2230s_bit) {
+	if (IS_AL2230S(chip)) {
 		r = zd_iowrite16a_locked(chip, ioreqs_init_al2230s,
 			ARRAY_SIZE(ioreqs_init_al2230s));
 		if (r)
@@ -188,7 +190,7 @@ static int zd1211_al2230_init_hw(struct zd_rf *rf)
 		return r;
 
 	/* improve band edge for AL2230S */
-	if (chip->al2230s_bit)
+	if (IS_AL2230S(chip))
 		r = zd_rfwrite_locked(chip, 0x000824, RF_RV_BITS);
 	else
 		r = zd_rfwrite_locked(chip, 0x0005a4, RF_RV_BITS);
@@ -314,7 +316,7 @@ static int zd1211b_al2230_init_hw(struct zd_rf *rf)
 	if (r)
 		return r;
 
-	if (chip->al2230s_bit) {
+	if (IS_AL2230S(chip)) {
 		r = zd_iowrite16a_locked(chip, ioreqs_init_al2230s,
 			ARRAY_SIZE(ioreqs_init_al2230s));
 		if (r)
@@ -328,7 +330,7 @@ static int zd1211b_al2230_init_hw(struct zd_rf *rf)
 	if (r)
 		return r;
 
-	if (chip->al2230s_bit)
+	if (IS_AL2230S(chip))
 		r = zd_rfwrite_locked(chip, 0x241000, RF_RV_BITS);
 	else
 		r = zd_rfwrite_locked(chip, 0x25a000, RF_RV_BITS);
@@ -422,7 +424,7 @@ int zd_rf_init_al2230(struct zd_rf *rf)
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
 	rf->switch_radio_off = al2230_switch_radio_off;
-	if (chip->is_zd1211b) {
+	if (zd_chip_is_zd1211b(chip)) {
 		rf->init_hw = zd1211b_al2230_init_hw;
 		rf->set_channel = zd1211b_al2230_set_channel;
 		rf->switch_radio_on = zd1211b_al2230_switch_radio_on;
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c b/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
index f4e8b6a..73d0bb2 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
@@ -473,7 +473,7 @@ int zd_rf_init_al7230b(struct zd_rf *rf)
 {
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
-	if (chip->is_zd1211b) {
+	if (zd_chip_is_zd1211b(chip)) {
 		rf->init_hw = zd1211b_al7230b_init_hw;
 		rf->switch_radio_on = zd1211b_al7230b_switch_radio_on;
 		rf->set_channel = zd1211b_al7230b_set_channel;
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_rf2959.c b/drivers/net/wireless/zd1211rw/zd_rf_rf2959.c
index 2d736bd..cc70d40 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_rf2959.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_rf2959.c
@@ -265,7 +265,7 @@ int zd_rf_init_rf2959(struct zd_rf *rf)
 {
 	struct zd_chip *chip = zd_rf_to_chip(rf);
 
-	if (chip->is_zd1211b) {
+	if (zd_chip_is_zd1211b(chip)) {
 		dev_err(zd_chip_dev(chip),
 		       "RF2959 is currently not supported for ZD1211B"
 		       " devices\n");
diff --git a/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c b/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c
index 414e40d..857dcf3 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf_uw2453.c
@@ -486,7 +486,7 @@ static int uw2453_switch_radio_on(struct zd_rf *rf)
 	if (r)
 		return r;
 
-	if (chip->is_zd1211b)
+	if (zd_chip_is_zd1211b(chip))
 		ioreqs[1].value = 0x7f;
 
 	return zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 740a219..a1a5474 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -71,6 +71,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0586, 0x3412), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0586, 0x3413), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0053, 0x5301), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0411, 0x00da), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{ USB_DEVICE(0x0ace, 0x20ff), .driver_info = DEVICE_INSTALLER },
@@ -195,26 +196,27 @@ static u16 get_word(const void *data, u16 offset)
 	return le16_to_cpu(p[offset]);
 }
 
-static char *get_fw_name(char *buffer, size_t size, u8 device_type,
+static char *get_fw_name(struct zd_usb *usb, char *buffer, size_t size,
 	               const char* postfix)
 {
 	scnprintf(buffer, size, "%s%s",
-		device_type == DEVICE_ZD1211B ?
+		usb->is_zd1211b ?
 			FW_ZD1211B_PREFIX : FW_ZD1211_PREFIX,
 		postfix);
 	return buffer;
 }
 
-static int handle_version_mismatch(struct usb_device *udev, u8 device_type,
+static int handle_version_mismatch(struct zd_usb *usb,
 	const struct firmware *ub_fw)
 {
+	struct usb_device *udev = zd_usb_to_usbdev(usb);
 	const struct firmware *ur_fw = NULL;
 	int offset;
 	int r = 0;
 	char fw_name[128];
 
 	r = request_fw_file(&ur_fw,
-		get_fw_name(fw_name, sizeof(fw_name), device_type, "ur"),
+		get_fw_name(usb, fw_name, sizeof(fw_name), "ur"),
 		&udev->dev);
 	if (r)
 		goto error;
@@ -237,11 +239,12 @@ error:
 	return r;
 }
 
-static int upload_firmware(struct usb_device *udev, u8 device_type)
+static int upload_firmware(struct zd_usb *usb)
 {
 	int r;
 	u16 fw_bcdDevice;
 	u16 bcdDevice;
+	struct usb_device *udev = zd_usb_to_usbdev(usb);
 	const struct firmware *ub_fw = NULL;
 	const struct firmware *uph_fw = NULL;
 	char fw_name[128];
@@ -249,7 +252,7 @@ static int upload_firmware(struct usb_device *udev, u8 device_type)
 	bcdDevice = get_bcdDevice(udev);
 
 	r = request_fw_file(&ub_fw,
-		get_fw_name(fw_name, sizeof(fw_name), device_type,  "ub"),
+		get_fw_name(usb, fw_name, sizeof(fw_name), "ub"),
 		&udev->dev);
 	if (r)
 		goto error;
@@ -264,7 +267,7 @@ static int upload_firmware(struct usb_device *udev, u8 device_type)
 			dev_warn(&udev->dev, "device has old bootcode, please "
 				"report success or failure\n");
 
-		r = handle_version_mismatch(udev, device_type, ub_fw);
+		r = handle_version_mismatch(usb, ub_fw);
 		if (r)
 			goto error;
 	} else {
@@ -275,7 +278,7 @@ static int upload_firmware(struct usb_device *udev, u8 device_type)
 
 
 	r = request_fw_file(&uph_fw,
-		get_fw_name(fw_name, sizeof(fw_name), device_type, "uphr"),
+		get_fw_name(usb, fw_name, sizeof(fw_name), "uphr"),
 		&udev->dev);
 	if (r)
 		goto error;
@@ -294,6 +297,30 @@ error:
 	return r;
 }
 
+/* Read data from device address space using "firmware interface" which does
+ * not require firmware to be loaded. */
+int zd_usb_read_fw(struct zd_usb *usb, zd_addr_t addr, u8 *data, u16 len)
+{
+	int r;
+	struct usb_device *udev = zd_usb_to_usbdev(usb);
+
+	r = usb_control_msg(udev, usb_rcvctrlpipe(udev, 0),
+		USB_REQ_FIRMWARE_READ_DATA, USB_DIR_IN | 0x40, addr, 0,
+		data, len, 5000);
+	if (r < 0) {
+		dev_err(&udev->dev,
+			"read over firmware interface failed: %d\n", r);
+		return r;
+	} else if (r != len) {
+		dev_err(&udev->dev,
+			"incomplete read over firmware interface: %d/%d\n",
+			r, len);
+		return -EIO;
+	}
+
+	return 0;
+}
+
 #define urb_dev(urb) (&(urb)->dev->dev)
 
 static inline void handle_regs_int(struct urb *urb)
@@ -920,9 +947,42 @@ static int eject_installer(struct usb_interface *intf)
 	return 0;
 }
 
+int zd_usb_init_hw(struct zd_usb *usb)
+{
+	int r;
+	struct zd_mac *mac = zd_usb_to_mac(usb);
+
+	dev_dbg_f(zd_usb_dev(usb), "\n");
+
+	r = upload_firmware(usb);
+	if (r) {
+		dev_err(zd_usb_dev(usb),
+		       "couldn't load firmware. Error number %d\n", r);
+		return r;
+	}
+
+	r = usb_reset_configuration(zd_usb_to_usbdev(usb));
+	if (r) {
+		dev_dbg_f(zd_usb_dev(usb),
+			"couldn't reset configuration. Error number %d\n", r);
+		return r;
+	}
+
+	r = zd_mac_init_hw(mac);
+	if (r) {
+		dev_dbg_f(zd_usb_dev(usb),
+		         "couldn't initialize mac. Error number %d\n", r);
+		return r;
+	}
+
+	usb->initialized = 1;
+	return 0;
+}
+
 static int probe(struct usb_interface *intf, const struct usb_device_id *id)
 {
 	int r;
+	struct zd_usb *usb;
 	struct usb_device *udev = interface_to_usbdev(intf);
 	struct net_device *netdev = NULL;
 
@@ -950,26 +1010,10 @@ static int probe(struct usb_interface *intf, const struct usb_device_id *id)
 		goto error;
 	}
 
-	r = upload_firmware(udev, id->driver_info);
-	if (r) {
-		dev_err(&intf->dev,
-		       "couldn't load firmware. Error number %d\n", r);
-		goto error;
-	}
+	usb = &zd_netdev_mac(netdev)->chip.usb;
+	usb->is_zd1211b = (id->driver_info == DEVICE_ZD1211B) != 0;
 
-	r = usb_reset_configuration(udev);
-	if (r) {
-		dev_dbg_f(&intf->dev,
-			"couldn't reset configuration. Error number %d\n", r);
-		goto error;
-	}
-
-	/* At this point the interrupt endpoint is not generally enabled. We
-	 * save the USB bandwidth until the network device is opened. But
-	 * notify that the initialization of the MAC will require the
-	 * interrupts to be temporary enabled.
-	 */
-	r = zd_mac_init_hw(zd_netdev_mac(netdev), id->driver_info);
+	r = zd_mac_preinit_hw(zd_netdev_mac(netdev));
 	if (r) {
 		dev_dbg_f(&intf->dev,
 		         "couldn't initialize mac. Error number %d\n", r);
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.h b/drivers/net/wireless/zd1211rw/zd_usb.h
index 506ea6a..961a7a1 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -188,6 +188,7 @@ struct zd_usb {
 	struct zd_usb_rx rx;
 	struct zd_usb_tx tx;
 	struct usb_interface *intf;
+	u8 is_zd1211b:1, initialized:1;
 };
 
 #define zd_usb_dev(usb) (&usb->intf->dev)
@@ -236,6 +237,8 @@ int zd_usb_iowrite16v(struct zd_usb *usb, const struct zd_ioreq16 *ioreqs,
 
 int zd_usb_rfwrite(struct zd_usb *usb, u32 value, u8 bits);
 
+int zd_usb_read_fw(struct zd_usb *usb, zd_addr_t addr, u8 *data, u16 len);
+
 extern struct workqueue_struct *zd_workqueue;
 
 #endif /* _ZD_USB_H */
diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index cc8110b..afb6c66 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -271,8 +271,11 @@ ieee80211softmac_assoc_work(struct work_struct *work)
 			 */
 			dprintk(KERN_INFO PFX "Associate: Scanning for networks first.\n");
 			ieee80211softmac_notify(mac->dev, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, ieee80211softmac_assoc_notify_scan, NULL);
-			if (ieee80211softmac_start_scan(mac))
+			if (ieee80211softmac_start_scan(mac)) {
 				dprintk(KERN_INFO PFX "Associate: failed to initiate scan. Is device up?\n");
+				mac->associnfo.associating = 0;
+				mac->associnfo.associated = 0;
+			}
 			goto out;
 		} else {
 			mac->associnfo.associating = 0;
-- 
John W. Linville
linville@tuxdriver.com
