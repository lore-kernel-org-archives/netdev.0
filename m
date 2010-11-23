From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-11-23
Date: Tue, 23 Nov 2010 16:05:19 -0500
Message-ID: <20101123210518.GB2372@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are some fixes intended for 2.6.37 -- a collection of one-liners!  :-)

The carl9170 patch fixes a NULL pointer dereference.  The b43-pci-bridge
one just adds a device ID.  The ath9k patch fixes a timeout that also
triggers a warning in dmesg.  Finally, the b43 patch fixes a resource
leak on an error path.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit cf41a51db89850033efc11c18a5257de810b5417:

  of/phylib: Use device tree properties to initialize Marvell PHYs. (2010-11-22 08:34:23 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (1):
      carl9170: fix virtual interface setup crash

Daniel Klaffenbach (1):
      ssb: b43-pci-bridge: Add new vendor for BCM4318

Felix Fietkau (1):
      ath9k: fix timeout on stopping rx dma

Guennadi Liakhovetski (1):
      wireless: b43: fix error path in SDIO

 drivers/net/wireless/ath/ath9k/recv.c    |    2 +-
 drivers/net/wireless/ath/carl9170/main.c |    2 +-
 drivers/net/wireless/b43/sdio.c          |    1 +
 drivers/ssb/b43_pci_bridge.c             |    1 +
 include/linux/pci_ids.h                  |    1 +
 5 files changed, 5 insertions(+), 2 deletions(-)
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index c76ea53..1a62e35 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -518,7 +518,7 @@ bool ath_stoprecv(struct ath_softc *sc)
 	bool stopped;
 
 	spin_lock_bh(&sc->rx.rxbuflock);
-	ath9k_hw_stoppcurecv(ah);
+	ath9k_hw_abortpcurecv(ah);
 	ath9k_hw_setrxfilter(ah, 0);
 	stopped = ath9k_hw_stopdmarecv(ah);
 
diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
index 980ae70..a314c2c 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -647,7 +647,7 @@ init:
 	}
 
 unlock:
-	if (err && (vif_id != -1)) {
+	if (err && (vif_id >= 0)) {
 		vif_priv->active = false;
 		bitmap_release_region(&ar->vif_bitmap, vif_id, 0);
 		ar->vifs--;
diff --git a/drivers/net/wireless/b43/sdio.c b/drivers/net/wireless/b43/sdio.c
index 9a55338..09e2dfd 100644
--- a/drivers/net/wireless/b43/sdio.c
+++ b/drivers/net/wireless/b43/sdio.c
@@ -163,6 +163,7 @@ static int b43_sdio_probe(struct sdio_func *func,
 err_free_ssb:
 	kfree(sdio);
 err_disable_func:
+	sdio_claim_host(func);
 	sdio_disable_func(func);
 err_release_host:
 	sdio_release_host(func);
diff --git a/drivers/ssb/b43_pci_bridge.c b/drivers/ssb/b43_pci_bridge.c
index ef9c6a0..744d3f6 100644
--- a/drivers/ssb/b43_pci_bridge.c
+++ b/drivers/ssb/b43_pci_bridge.c
@@ -24,6 +24,7 @@ static const struct pci_device_id b43_pci_bridge_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4312) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4315) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4318) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_BCM_GVC,  0x4318) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4319) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4320) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4321) },
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index d278dd9..f29c25e 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2043,6 +2043,7 @@
 #define PCI_DEVICE_ID_AFAVLAB_P030	0x2182
 #define PCI_SUBDEVICE_ID_AFAVLAB_P061		0x2150
 
+#define PCI_VENDOR_ID_BCM_GVC          0x14a4
 #define PCI_VENDOR_ID_BROADCOM		0x14e4
 #define PCI_DEVICE_ID_TIGON3_5752	0x1600
 #define PCI_DEVICE_ID_TIGON3_5752M	0x1601
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
