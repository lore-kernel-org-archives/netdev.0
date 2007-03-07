From: Greg KH <gregkh@suse.de>
Subject: [patch 097/101] revert "drivers/net/tulip/dmfe: support basic carrier detection"
Date: Wed, 07 Mar 2007 09:12:12 -0800
Message-ID: <20070307171657.461008445@mini.kroah.org>
References: <20070307171035.150802805@mini.kroah.org>
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	thomas@archlinux.org, val_henson@linux.intel.com,
	samuel.thibault@ens-lyon.org
To: linux-kernel@vger.kernel.org, stable@kernel.org, jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422919AbXCGRYK@vger.kernel.org>
Content-Disposition: inline; filename=revert-drivers-net-tulip-dmfe-support-basic-carrier-detection.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Andrew Morton <akpm@linux-foundation.org>

Revert 7628b0a8c01a02966d2228bdf741ddedb128e8f8.  Thomas Bachler
reports:

  Commit 7628b0a8c01a02966d2228bdf741ddedb128e8f8 (drivers/net/tulip/dmfe:
  support basic carrier detection) breaks networking on my Davicom DM9009. 
  ethtool always reports there is no link.  tcpdump shows incoming packets,
  but TX is disabled.  Reverting the above patch fixes the problem.


Cc: Samuel Thibault <samuel.thibault@ens-lyon.org>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Valerie Henson <val_henson@linux.intel.com>
Cc: Thomas Bachler <thomas@archlinux.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/tulip/dmfe.c |    9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

--- linux-2.6.20.1.orig/drivers/net/tulip/dmfe.c
+++ linux-2.6.20.1/drivers/net/tulip/dmfe.c
@@ -187,7 +187,7 @@ struct rx_desc {
 struct dmfe_board_info {
 	u32 chip_id;			/* Chip vendor/Device ID */
 	u32 chip_revision;		/* Chip revision */
-	struct DEVICE *dev;		/* net device */
+	struct DEVICE *next_dev;	/* next device */
 	struct pci_dev *pdev;		/* PCI device */
 	spinlock_t lock;
 
@@ -399,8 +399,6 @@ static int __devinit dmfe_init_one (stru
 	/* Init system & device */
 	db = netdev_priv(dev);
 
-	db->dev = dev;
-
 	/* Allocate Tx/Rx descriptor memory */
 	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
 	db->buf_pool_ptr = pci_alloc_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
@@ -428,7 +426,6 @@ static int __devinit dmfe_init_one (stru
 	dev->poll_controller = &poll_dmfe;
 #endif
 	dev->ethtool_ops = &netdev_ethtool_ops;
-	netif_carrier_off(db->dev);
 	spin_lock_init(&db->lock);
 
 	pci_read_config_dword(pdev, 0x50, &pci_pmr);
@@ -1053,7 +1050,6 @@ static void netdev_get_drvinfo(struct ne
 
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
-	.get_link               = ethtool_op_get_link,
 };
 
 /*
@@ -1148,7 +1144,6 @@ static void dmfe_timer(unsigned long dat
 		/* Link Failed */
 		DMFE_DBUG(0, "Link Failed", tmp_cr12);
 		db->link_failed = 1;
-		netif_carrier_off(db->dev);
 
 		/* For Force 10/100M Half/Full mode: Enable Auto-Nego mode */
 		/* AUTO or force 1M Homerun/Longrun don't need */
@@ -1171,8 +1166,6 @@ static void dmfe_timer(unsigned long dat
 			if ( (db->media_mode & DMFE_AUTO) &&
 				dmfe_sense_speed(db) )
 				db->link_failed = 1;
-			else
-				netif_carrier_on(db->dev);
 			dmfe_process_mode(db);
 			/* SHOW_MEDIA_TYPE(db->op_mode); */
 		}

--
