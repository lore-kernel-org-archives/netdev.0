From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-11-22 #2
Date: Tue, 22 Nov 2011 16:56:12 -0500
Message-ID: <20111122215611.GI8452@tuxdriver.com>
References: <20111122193505.GC8452@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55966 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287Ab1KVWA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 17:00:28 -0500
Content-Disposition: inline
In-Reply-To: <20111122193505.GC8452@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the latest batch of fixes intended for 3.2.  This includes a
correction for a user-visible error in mac80211's debugfs info, a fix
for a potential memory corrupter in prism54, an endian fix for rt2x00,
an endian fix for mac80211, a fix for a NULL derefernce in cfg80211, a
locking fix for p54spi and a deadlock fix also for p54spi.

This reverts the problematic rt2x00 patches from the earlier pull
request.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 5eccdf5e06eb67779716ae26142402a1ae9b012c:

  tc: comment spelling fixes (2011-11-22 16:37:01 -0500)

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

John W. Linville (3):
      Revert "rt2x00: handle spurious pci interrupts"
      Revert "rt2800pci: handle spurious interrupts"
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Michael Buesch (2):
      p54spi: Add missing spin_lock_init
      p54spi: Fix workqueue deadlock

Stanislaw Gruszka (2):
      rt2800pci: handle spurious interrupts
      rt2x00: handle spurious pci interrupts

 drivers/net/wireless/p54/p54spi.c        |    5 +++--
 drivers/net/wireless/prism54/isl_ioctl.c |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c  |    2 +-
 net/mac80211/debugfs_sta.c               |    4 ++--
 net/mac80211/status.c                    |    8 ++++----
 net/wireless/reg.c                       |    4 ++++
 6 files changed, 15 insertions(+), 10 deletions(-)

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
