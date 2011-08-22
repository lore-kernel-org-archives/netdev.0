From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-08-22
Date: Mon, 22 Aug 2011 15:01:37 -0400
Message-ID: <20110822190136.GJ2534@tuxdriver.com>
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

This is a batch of fixes intended for 3.1.  Included is rewrite of an
earlier iwlagn fix that was revealed to be flawed (bad pointer access
during module unload), a fix for a memory leak, and a trio of rt2x00
fixes with detailed changelogs.  These have all been in linux-next
for the last week with no reported complaints.

Please let me know if there are problems!

John

---

The following changes since commit fbe5e29ec1886967255e76946aaf537b8cc9b81e:

  atm: br2684: Fix oops due to skb->dev being NULL (2011-08-20 14:13:05 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

Emmanuel Grumbach (2):
      Revert "iwlagn: sysfs couldn't find the priv pointer"
      iwlagn: sysfs couldn't find the priv pointer

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Julia Lawall (1):
      drivers/net/wireless/wl12xx: add missing kfree

Stanislaw Gruszka (3):
      rt2x00: fix crash in rt2800usb_write_tx_desc
      rt2x00: fix order of entry flags modification
      rt2x00: fix crash in rt2800usb_get_txwi

 drivers/net/wireless/iwlwifi/iwl-pci.c  |   25 ++++++++++---------------
 drivers/net/wireless/rt2x00/rt2800usb.c |   20 +++++++++++++++-----
 drivers/net/wireless/rt2x00/rt2x00usb.c |   17 +++++++----------
 drivers/net/wireless/wl12xx/acx.c       |    6 +-----
 drivers/net/wireless/wl12xx/testmode.c  |    5 ++++-
 5 files changed, 37 insertions(+), 36 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-pci.c b/drivers/net/wireless/iwlwifi/iwl-pci.c
index 69d4ec4..2fdbffa 100644
--- a/drivers/net/wireless/iwlwifi/iwl-pci.c
+++ b/drivers/net/wireless/iwlwifi/iwl-pci.c
@@ -478,27 +478,22 @@ out_no_pci:
 	return err;
 }
 
-static void iwl_pci_down(struct iwl_bus *bus)
-{
-	struct iwl_pci_bus *pci_bus = (struct iwl_pci_bus *) bus->bus_specific;
-
-	pci_disable_msi(pci_bus->pci_dev);
-	pci_iounmap(pci_bus->pci_dev, pci_bus->hw_base);
-	pci_release_regions(pci_bus->pci_dev);
-	pci_disable_device(pci_bus->pci_dev);
-	pci_set_drvdata(pci_bus->pci_dev, NULL);
-
-	kfree(bus);
-}
-
 static void __devexit iwl_pci_remove(struct pci_dev *pdev)
 {
 	struct iwl_priv *priv = pci_get_drvdata(pdev);
-	void *bus_specific = priv->bus->bus_specific;
+	struct iwl_bus *bus = priv->bus;
+	struct iwl_pci_bus *pci_bus = IWL_BUS_GET_PCI_BUS(bus);
+	struct pci_dev *pci_dev = IWL_BUS_GET_PCI_DEV(bus);
 
 	iwl_remove(priv);
 
-	iwl_pci_down(bus_specific);
+	pci_disable_msi(pci_dev);
+	pci_iounmap(pci_dev, pci_bus->hw_base);
+	pci_release_regions(pci_dev);
+	pci_disable_device(pci_dev);
+	pci_set_drvdata(pci_dev, NULL);
+
+	kfree(bus);
 }
 
 #ifdef CONFIG_PM
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index 9395631..dbf501c 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -464,6 +464,15 @@ static bool rt2800usb_txdone_entry_check(struct queue_entry *entry, u32 reg)
 	int wcid, ack, pid;
 	int tx_wcid, tx_ack, tx_pid;
 
+	if (test_bit(ENTRY_OWNER_DEVICE_DATA, &entry->flags) ||
+	    !test_bit(ENTRY_DATA_STATUS_PENDING, &entry->flags)) {
+		WARNING(entry->queue->rt2x00dev,
+			"Data pending for entry %u in queue %u\n",
+			entry->entry_idx, entry->queue->qid);
+		cond_resched();
+		return false;
+	}
+
 	wcid	= rt2x00_get_field32(reg, TX_STA_FIFO_WCID);
 	ack	= rt2x00_get_field32(reg, TX_STA_FIFO_TX_ACK_REQUIRED);
 	pid	= rt2x00_get_field32(reg, TX_STA_FIFO_PID_TYPE);
@@ -529,12 +538,11 @@ static void rt2800usb_txdone(struct rt2x00_dev *rt2x00dev)
 			entry = rt2x00queue_get_entry(queue, Q_INDEX_DONE);
 			if (rt2800usb_txdone_entry_check(entry, reg))
 				break;
+			entry = NULL;
 		}
 
-		if (!entry || rt2x00queue_empty(queue))
-			break;
-
-		rt2800_txdone_entry(entry, reg);
+		if (entry)
+			rt2800_txdone_entry(entry, reg);
 	}
 }
 
@@ -558,8 +566,10 @@ static void rt2800usb_work_txdone(struct work_struct *work)
 		while (!rt2x00queue_empty(queue)) {
 			entry = rt2x00queue_get_entry(queue, Q_INDEX_DONE);
 
-			if (test_bit(ENTRY_OWNER_DEVICE_DATA, &entry->flags))
+			if (test_bit(ENTRY_OWNER_DEVICE_DATA, &entry->flags) ||
+			    !test_bit(ENTRY_DATA_STATUS_PENDING, &entry->flags))
 				break;
+
 			if (test_bit(ENTRY_DATA_IO_FAILED, &entry->flags))
 				rt2x00lib_txdone_noinfo(entry, TXDONE_FAILURE);
 			else if (rt2x00queue_status_timeout(entry))
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index b6b4542..7fbb55c 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -262,23 +262,20 @@ static void rt2x00usb_interrupt_txdone(struct urb *urb)
 	struct queue_entry *entry = (struct queue_entry *)urb->context;
 	struct rt2x00_dev *rt2x00dev = entry->queue->rt2x00dev;
 
-	if (!test_and_clear_bit(ENTRY_OWNER_DEVICE_DATA, &entry->flags))
+	if (!test_bit(ENTRY_OWNER_DEVICE_DATA, &entry->flags))
 		return;
-
-	if (rt2x00dev->ops->lib->tx_dma_done)
-		rt2x00dev->ops->lib->tx_dma_done(entry);
-
-	/*
-	 * Report the frame as DMA done
-	 */
-	rt2x00lib_dmadone(entry);
-
 	/*
 	 * Check if the frame was correctly uploaded
 	 */
 	if (urb->status)
 		set_bit(ENTRY_DATA_IO_FAILED, &entry->flags);
+	/*
+	 * Report the frame as DMA done
+	 */
+	rt2x00lib_dmadone(entry);
 
+	if (rt2x00dev->ops->lib->tx_dma_done)
+		rt2x00dev->ops->lib->tx_dma_done(entry);
 	/*
 	 * Schedule the delayed work for reading the TX status
 	 * from the device.
diff --git a/drivers/net/wireless/wl12xx/acx.c b/drivers/net/wireless/wl12xx/acx.c
index 7e33f1f..34f6ab5 100644
--- a/drivers/net/wireless/wl12xx/acx.c
+++ b/drivers/net/wireless/wl12xx/acx.c
@@ -77,8 +77,6 @@ int wl1271_acx_sleep_auth(struct wl1271 *wl, u8 sleep_auth)
 	auth->sleep_auth = sleep_auth;
 
 	ret = wl1271_cmd_configure(wl, ACX_SLEEP_AUTH, auth, sizeof(*auth));
-	if (ret < 0)
-		return ret;
 
 out:
 	kfree(auth);
@@ -624,10 +622,8 @@ int wl1271_acx_cca_threshold(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_CCA_THRESHOLD,
 				   detection, sizeof(*detection));
-	if (ret < 0) {
+	if (ret < 0)
 		wl1271_warning("failed to set cca threshold: %d", ret);
-		return ret;
-	}
 
 out:
 	kfree(detection);
diff --git a/drivers/net/wireless/wl12xx/testmode.c b/drivers/net/wireless/wl12xx/testmode.c
index 5d5e1ef..88add68 100644
--- a/drivers/net/wireless/wl12xx/testmode.c
+++ b/drivers/net/wireless/wl12xx/testmode.c
@@ -139,12 +139,15 @@ static int wl1271_tm_cmd_interrogate(struct wl1271 *wl, struct nlattr *tb[])
 
 	if (ret < 0) {
 		wl1271_warning("testmode cmd interrogate failed: %d", ret);
+		kfree(cmd);
 		return ret;
 	}
 
 	skb = cfg80211_testmode_alloc_reply_skb(wl->hw->wiphy, sizeof(*cmd));
-	if (!skb)
+	if (!skb) {
+		kfree(cmd);
 		return -ENOMEM;
+	}
 
 	NLA_PUT(skb, WL1271_TM_ATTR_DATA, sizeof(*cmd), cmd);
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
