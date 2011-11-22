From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-11-22
Date: Tue, 22 Nov 2011 14:35:05 -0500
Message-ID: <20111122193505.GC8452@tuxdriver.com>
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

Here is the latest batch of fixes intended for 3.2.  This includes a
correction for a user-visible error in mac80211's debugfs info, a fix
for a potential memory corrupter in prism54, an endian fix for rt2x00,
an endian fix for mac80211, a fix for a NULL derefernce in cfg80211, a
locking fix and a deadlock fix for p54spi, and a pair of rt2x00 fixes
for handling some spurious interrupts that hardware can generate.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit f23aa62545c18728eb2b9434aa258be27e07dd49:

  caif: fix endian conversion in cffrml_transmit() (2011-11-21 16:46:24 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

Ben Greear (1):
      mac80211: Fix AMSDU rate printout in debugfs.

Dan Carpenter (1):
      prism54: potential memory corruption in prism54_get_essid()

Gertjan van Wingerde (1):
      rt2x00: Fix efuse EEPROM reading on PPC32.

Helmut Schaa (1):
      mac80211: Fix endian bug in radiotap header generation

Johannes Berg (1):
      cfg80211: fix regulatory NULL dereference

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Michael Buesch (2):
      p54spi: Add missing spin_lock_init
      p54spi: Fix workqueue deadlock

Stanislaw Gruszka (2):
      rt2800pci: handle spurious interrupts
      rt2x00: handle spurious pci interrupts

 drivers/net/wireless/p54/p54spi.c        |    5 +++--
 drivers/net/wireless/prism54/isl_ioctl.c |    2 +-
 drivers/net/wireless/rt2x00/rt2400pci.c  |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c  |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c  |    2 +-
 drivers/net/wireless/rt2x00/rt2800pci.c  |    7 ++++++-
 drivers/net/wireless/rt2x00/rt61pci.c    |    2 +-
 net/mac80211/debugfs_sta.c               |    4 ++--
 net/mac80211/status.c                    |    8 ++++----
 net/wireless/reg.c                       |    4 ++++
 10 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
index f18df82..78d0d69 100644
--- a/drivers/net/wireless/p54/p54spi.c
+++ b/drivers/net/wireless/p54/p54spi.c
@@ -588,8 +588,6 @@ static void p54spi_op_stop(struct ieee80211_hw *dev)
 
 	WARN_ON(priv->fw_state != FW_STATE_READY);
 
-	cancel_work_sync(&priv->work);
-
 	p54spi_power_off(priv);
 	spin_lock_irqsave(&priv->tx_lock, flags);
 	INIT_LIST_HEAD(&priv->tx_pending);
@@ -597,6 +595,8 @@ static void p54spi_op_stop(struct ieee80211_hw *dev)
 
 	priv->fw_state = FW_STATE_OFF;
 	mutex_unlock(&priv->mutex);
+
+	cancel_work_sync(&priv->work);
 }
 
 static int __devinit p54spi_probe(struct spi_device *spi)
@@ -656,6 +656,7 @@ static int __devinit p54spi_probe(struct spi_device *spi)
 	init_completion(&priv->fw_comp);
 	INIT_LIST_HEAD(&priv->tx_pending);
 	mutex_init(&priv->mutex);
+	spin_lock_init(&priv->tx_lock);
 	SET_IEEE80211_DEV(hw, &spi->dev);
 	priv->common.open = p54spi_op_start;
 	priv->common.stop = p54spi_op_stop;
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index d97a2ca..bc2ba80 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -778,7 +778,7 @@ prism54_get_essid(struct net_device *ndev, struct iw_request_info *info,
 		dwrq->flags = 0;
 		dwrq->length = 0;
 	}
-	essid->octets[essid->length] = '\0';
+	essid->octets[dwrq->length] = '\0';
 	memcpy(extra, essid->octets, dwrq->length);
 	kfree(essid);
 
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index 3a6b402..676c765 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -1380,7 +1380,7 @@ static irqreturn_t rt2400pci_interrupt(int irq, void *dev_instance)
 	rt2x00pci_register_write(rt2x00dev, CSR7, reg);
 
 	if (!reg)
-		return IRQ_NONE;
+		return IRQ_HANDLED;
 
 	if (!test_bit(DEVICE_STATE_ENABLED_RADIO, &rt2x00dev->flags))
 		return IRQ_HANDLED;
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index dcc0e1f..d0b627c 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -1512,7 +1512,7 @@ static irqreturn_t rt2500pci_interrupt(int irq, void *dev_instance)
 	rt2x00pci_register_write(rt2x00dev, CSR7, reg);
 
 	if (!reg)
-		return IRQ_NONE;
+		return IRQ_HANDLED;
 
 	if (!test_bit(DEVICE_STATE_ENABLED_RADIO, &rt2x00dev->flags))
 		return IRQ_HANDLED;
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index 3f183a1..1ba079d 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -3771,7 +3771,7 @@ static void rt2800_efuse_read(struct rt2x00_dev *rt2x00dev, unsigned int i)
 	/* Apparently the data is read from end to start */
 	rt2800_register_read_lock(rt2x00dev, EFUSE_DATA3, &reg);
 	/* The returned value is in CPU order, but eeprom is le */
-	rt2x00dev->eeprom[i] = cpu_to_le32(reg);
+	*(u32 *)&rt2x00dev->eeprom[i] = cpu_to_le32(reg);
 	rt2800_register_read_lock(rt2x00dev, EFUSE_DATA2, &reg);
 	*(u32 *)&rt2x00dev->eeprom[i + 2] = cpu_to_le32(reg);
 	rt2800_register_read_lock(rt2x00dev, EFUSE_DATA1, &reg);
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless/rt2x00/rt2800pci.c
index da48c8a..4dc2d0f 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -880,8 +880,13 @@ static irqreturn_t rt2800pci_interrupt(int irq, void *dev_instance)
 	rt2x00pci_register_read(rt2x00dev, INT_SOURCE_CSR, &reg);
 	rt2x00pci_register_write(rt2x00dev, INT_SOURCE_CSR, reg);
 
+	/*
+	 * Some devices can generate interrupts with empty CSR register, we
+	 * "handle" such irq's to prevent interrupt controller treat them as
+	 * spurious interrupts and disable irq line.
+	 */
 	if (!reg)
-		return IRQ_NONE;
+		return IRQ_HANDLED;
 
 	if (!test_bit(DEVICE_STATE_ENABLED_RADIO, &rt2x00dev->flags))
 		return IRQ_HANDLED;
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index bf55b4a..9d83e70 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -2337,7 +2337,7 @@ static irqreturn_t rt61pci_interrupt(int irq, void *dev_instance)
 	rt2x00pci_register_write(rt2x00dev, INT_SOURCE_CSR, reg);
 
 	if (!reg && !reg_mcu)
-		return IRQ_NONE;
+		return IRQ_HANDLED;
 
 	if (!test_bit(DEVICE_STATE_ENABLED_RADIO, &rt2x00dev->flags))
 		return IRQ_HANDLED;
diff --git a/net/mac80211/debugfs_sta.c b/net/mac80211/debugfs_sta.c
index c5f3417..3110cbd 100644
--- a/net/mac80211/debugfs_sta.c
+++ b/net/mac80211/debugfs_sta.c
@@ -274,9 +274,9 @@ static ssize_t sta_ht_capa_read(struct file *file, char __user *userbuf,
 
 		PRINT_HT_CAP((htc->cap & BIT(10)), "HT Delayed Block Ack");
 
-		PRINT_HT_CAP((htc->cap & BIT(11)), "Max AMSDU length: "
-			     "3839 bytes");
 		PRINT_HT_CAP(!(htc->cap & BIT(11)), "Max AMSDU length: "
+			     "3839 bytes");
+		PRINT_HT_CAP((htc->cap & BIT(11)), "Max AMSDU length: "
 			     "7935 bytes");
 
 		/*
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 80de436..16518f3 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -260,7 +260,7 @@ static void ieee80211_add_tx_radiotap_header(struct ieee80211_supported_band
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	struct ieee80211_radiotap_header *rthdr;
 	unsigned char *pos;
-	__le16 txflags;
+	u16 txflags;
 
 	rthdr = (struct ieee80211_radiotap_header *) skb_push(skb, rtap_len);
 
@@ -290,13 +290,13 @@ static void ieee80211_add_tx_radiotap_header(struct ieee80211_supported_band
 	txflags = 0;
 	if (!(info->flags & IEEE80211_TX_STAT_ACK) &&
 	    !is_multicast_ether_addr(hdr->addr1))
-		txflags |= cpu_to_le16(IEEE80211_RADIOTAP_F_TX_FAIL);
+		txflags |= IEEE80211_RADIOTAP_F_TX_FAIL;
 
 	if ((info->status.rates[0].flags & IEEE80211_TX_RC_USE_RTS_CTS) ||
 	    (info->status.rates[0].flags & IEEE80211_TX_RC_USE_CTS_PROTECT))
-		txflags |= cpu_to_le16(IEEE80211_RADIOTAP_F_TX_CTS);
+		txflags |= IEEE80211_RADIOTAP_F_TX_CTS;
 	else if (info->status.rates[0].flags & IEEE80211_TX_RC_USE_RTS_CTS)
-		txflags |= cpu_to_le16(IEEE80211_RADIOTAP_F_TX_RTS);
+		txflags |= IEEE80211_RADIOTAP_F_TX_RTS;
 
 	put_unaligned_le16(txflags, pos);
 	pos += 2;
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index e71f5a6..77e9267 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -2037,6 +2037,10 @@ static int __set_regdom(const struct ieee80211_regdomain *rd)
 	}
 
 	request_wiphy = wiphy_idx_to_wiphy(last_request->wiphy_idx);
+	if (!request_wiphy) {
+		reg_set_request_processed();
+		return -ENODEV;
+	}
 
 	if (!last_request->intersect) {
 		int r;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
