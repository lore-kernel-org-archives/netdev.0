From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Wed, 16 Jan 2008 16:27:52 -0500
Message-ID: <20080116212752.GE3164@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3846 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751310AbYAPVwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 16:52:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

A few more fixes for 2.6.24...note that this branch is based
on 2.6.24-rc8.

Thanks,

John

---

Individual patches available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-jgarzik/

---

The following changes since commit cbd9c883696da72b2b1f03f909dbacc04bbf8b58:
  Linus Torvalds (1):
        Linux 2.6.24-rc8

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Ivo van Doorn (1):
      rt2x00: Fix ieee80211 payload alignment

Marc Pignat (1):
      wireless/libertas support for 88w8385 sdio older revision

Randy Dunlap (1):
      hostap: section mismatch warning

Stefano Brivio (2):
      ipw2200: fix typo in kerneldoc
      b43: fix use-after-free rfkill bug

 drivers/net/wireless/b43/rfkill.c        |   11 ++++++-----
 drivers/net/wireless/hostap/hostap_plx.c |    6 +++---
 drivers/net/wireless/ipw2200.c           |    2 +-
 drivers/net/wireless/libertas/if_sdio.c  |    4 ++++
 drivers/net/wireless/rt2x00/rt2x00pci.c  |    2 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c  |   11 +++++++++--
 6 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/b43/rfkill.c b/drivers/net/wireless/b43/rfkill.c
index 98cf70c..11f53cb 100644
--- a/drivers/net/wireless/b43/rfkill.c
+++ b/drivers/net/wireless/b43/rfkill.c
@@ -138,8 +138,11 @@ void b43_rfkill_init(struct b43_wldev *dev)
 	rfk->rfkill->user_claim_unsupported = 1;
 
 	rfk->poll_dev = input_allocate_polled_device();
-	if (!rfk->poll_dev)
-		goto err_free_rfk;
+	if (!rfk->poll_dev) {
+		rfkill_free(rfk->rfkill);
+		goto err_freed_rfk;
+	}
+
 	rfk->poll_dev->private = dev;
 	rfk->poll_dev->poll = b43_rfkill_poll;
 	rfk->poll_dev->poll_interval = 1000; /* msecs */
@@ -175,8 +178,7 @@ err_unreg_rfk:
 err_free_polldev:
 	input_free_polled_device(rfk->poll_dev);
 	rfk->poll_dev = NULL;
-err_free_rfk:
-	rfkill_free(rfk->rfkill);
+err_freed_rfk:
 	rfk->rfkill = NULL;
 out_error:
 	rfk->registered = 0;
@@ -195,6 +197,5 @@ void b43_rfkill_exit(struct b43_wldev *dev)
 	rfkill_unregister(rfk->rfkill);
 	input_free_polled_device(rfk->poll_dev);
 	rfk->poll_dev = NULL;
-	rfkill_free(rfk->rfkill);
 	rfk->rfkill = NULL;
 }
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index 040dc3e..cbf15d7 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -608,7 +608,7 @@ static void prism2_plx_remove(struct pci_dev *pdev)
 
 MODULE_DEVICE_TABLE(pci, prism2_plx_id_table);
 
-static struct pci_driver prism2_plx_drv_id = {
+static struct pci_driver prism2_plx_driver = {
 	.name		= "hostap_plx",
 	.id_table	= prism2_plx_id_table,
 	.probe		= prism2_plx_probe,
@@ -618,13 +618,13 @@ static struct pci_driver prism2_plx_drv_id = {
 
 static int __init init_prism2_plx(void)
 {
-	return pci_register_driver(&prism2_plx_drv_id);
+	return pci_register_driver(&prism2_plx_driver);
 }
 
 
 static void __exit exit_prism2_plx(void)
 {
-	pci_unregister_driver(&prism2_plx_drv_id);
+	pci_unregister_driver(&prism2_plx_driver);
 }
 
 
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 88062c1..003f73f 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -4935,7 +4935,7 @@ static int ipw_queue_reset(struct ipw_priv *priv)
 /**
  * Reclaim Tx queue entries no more used by NIC.
  *
- * When FW adwances 'R' index, all entries between old and
+ * When FW advances 'R' index, all entries between old and
  * new 'R' index need to be reclaimed. As result, some free space
  * forms. If there is enough free space (> low mark), wake Tx queue.
  *
diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
index b24425f..4f1efb1 100644
--- a/drivers/net/wireless/libertas/if_sdio.c
+++ b/drivers/net/wireless/libertas/if_sdio.c
@@ -871,6 +871,10 @@ static int if_sdio_probe(struct sdio_func *func,
 		if (sscanf(func->card->info[i],
 				"ID: %x", &model) == 1)
 			break;
+               if (!strcmp(func->card->info[i], "IBIS Wireless SDIO Card")) {
+                       model = 4;
+                       break;
+               }
 	}
 
 	if (i == func->card->num_info) {
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index 6d5d9ab..04663eb 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -149,7 +149,7 @@ void rt2x00pci_rxdone(struct rt2x00_dev *rt2x00dev)
 		 * The data behind the ieee80211 header must be
 		 * aligned on a 4 byte boundary.
 		 */
-		align = NET_IP_ALIGN + (2 * (header_size % 4 == 0));
+		align = header_size % 4;
 
 		/*
 		 * Allocate the sk_buffer, initialize it and copy
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index ab4797e..568d738 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -245,13 +245,20 @@ static void rt2x00usb_interrupt_rxdone(struct urb *urb)
 	 * Allocate a new sk buffer to replace the current one.
 	 * If allocation fails, we should drop the current frame
 	 * so we can recycle the existing sk buffer for the new frame.
+	 * As alignment we use 2 and not NET_IP_ALIGN because we need
+	 * to be sure we have 2 bytes room in the head. (NET_IP_ALIGN
+	 * can be 0 on some hardware). We use these 2 bytes for frame
+	 * alignment later, we assume that the chance that
+	 * header_size % 4 == 2 is bigger then header_size % 2 == 0
+	 * and thus optimize alignment by reserving the 2 bytes in
+	 * advance.
 	 */
 	frame_size = entry->ring->data_size + entry->ring->desc_size;
-	skb = dev_alloc_skb(frame_size + NET_IP_ALIGN);
+	skb = dev_alloc_skb(frame_size + 2);
 	if (!skb)
 		goto skip_entry;
 
-	skb_reserve(skb, NET_IP_ALIGN);
+	skb_reserve(skb, 2);
 	skb_put(skb, frame_size);
 
 	/*
-- 
John W. Linville
linville@tuxdriver.com
