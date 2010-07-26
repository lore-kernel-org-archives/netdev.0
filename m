From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 2/4] drivers/net/wireless: Use wiphy_<level>
Date: Mon, 26 Jul 2010 14:39:58 -0700
Message-ID: <10ab8a7658c4e6cc7b01139744b52c323d3f131d.1280177971.git.joe@perches.com>
References: <cover.1280177971.git.joe@perches.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1280177971.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Standardize the logging macros used.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/adm8211.c                 |   53 ++++----
 drivers/net/wireless/at76c50x-usb.c            |  139 +++++++++----------
 drivers/net/wireless/ath/ar9170/cmd.c          |    7 +-
 drivers/net/wireless/ath/ar9170/led.c          |    4 +-
 drivers/net/wireless/ath/ar9170/main.c         |  172 +++++++++++-------------
 drivers/net/wireless/ath/ar9170/phy.c          |    8 +-
 drivers/net/wireless/ath/ath9k/ahb.c           |    7 +-
 drivers/net/wireless/ath/ath9k/pci.c           |    7 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c         |   11 +-
 drivers/net/wireless/iwlwifi/iwl-core.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c    |   13 +-
 drivers/net/wireless/mac80211_hwsim.c          |   99 +++++++-------
 drivers/net/wireless/mwl8k.c                   |  123 +++++++----------
 drivers/net/wireless/orinoco/cfg.c             |    5 +-
 drivers/net/wireless/p54/eeprom.c              |   76 +++++------
 drivers/net/wireless/p54/fwio.c                |   53 ++++----
 drivers/net/wireless/p54/led.c                 |    8 +-
 drivers/net/wireless/p54/p54pci.c              |    3 +-
 drivers/net/wireless/p54/txrx.c                |   36 +++---
 drivers/net/wireless/rtl818x/rtl8180_dev.c     |   17 +--
 drivers/net/wireless/rtl818x/rtl8187_dev.c     |   11 +-
 drivers/net/wireless/rtl818x/rtl8187_rtl8225.c |    8 +-
 22 files changed, 398 insertions(+), 464 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index bde2fa8..a105087 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -373,8 +373,8 @@ static void adm8211_interrupt_rci(struct ieee80211_hw *dev)
 		pktlen = status & RDES0_STATUS_FL;
 		if (pktlen > RX_PKT_SIZE) {
 			if (net_ratelimit())
-				printk(KERN_DEBUG "%s: frame too long (%d)\n",
-				       wiphy_name(dev->wiphy), pktlen);
+				wiphy_debug(dev->wiphy, "frame too long (%d)\n",
+					    pktlen);
 			pktlen = RX_PKT_SIZE;
 		}
 
@@ -454,10 +454,10 @@ static void adm8211_interrupt_rci(struct ieee80211_hw *dev)
 
 static irqreturn_t adm8211_interrupt(int irq, void *dev_id)
 {
-#define ADM8211_INT(x)							   \
-do {									   \
-	if (unlikely(stsr & ADM8211_STSR_ ## x))			   \
-		printk(KERN_DEBUG "%s: " #x "\n", wiphy_name(dev->wiphy)); \
+#define ADM8211_INT(x)						\
+do {								\
+	if (unlikely(stsr & ADM8211_STSR_ ## x))		\
+		wiphy_debug(dev->wiphy, "%s\n", #x);		\
 } while (0)
 
 	struct ieee80211_hw *dev = dev_id;
@@ -570,9 +570,9 @@ static int adm8211_write_bbp(struct ieee80211_hw *dev, u8 addr, u8 data)
 	}
 
 	if (timeout == 0) {
-		printk(KERN_DEBUG "%s: adm8211_write_bbp(%d,%d) failed"
-		       " prewrite (reg=0x%08x)\n",
-		       wiphy_name(dev->wiphy), addr, data, reg);
+		wiphy_debug(dev->wiphy,
+			    "adm8211_write_bbp(%d,%d) failed prewrite (reg=0x%08x)\n",
+			    addr, data, reg);
 		return -ETIMEDOUT;
 	}
 
@@ -605,9 +605,9 @@ static int adm8211_write_bbp(struct ieee80211_hw *dev, u8 addr, u8 data)
 	if (timeout == 0) {
 		ADM8211_CSR_WRITE(BBPCTL, ADM8211_CSR_READ(BBPCTL) &
 				  ~ADM8211_BBPCTL_WR);
-		printk(KERN_DEBUG "%s: adm8211_write_bbp(%d,%d) failed"
-		       " postwrite (reg=0x%08x)\n",
-		       wiphy_name(dev->wiphy), addr, data, reg);
+		wiphy_debug(dev->wiphy,
+			    "adm8211_write_bbp(%d,%d) failed postwrite (reg=0x%08x)\n",
+			    addr, data, reg);
 		return -ETIMEDOUT;
 	}
 
@@ -675,8 +675,8 @@ static int adm8211_rf_set_channel(struct ieee80211_hw *dev, unsigned int chan)
 		break;
 
 	default:
-		printk(KERN_DEBUG "%s: unsupported transceiver type %d\n",
-		       wiphy_name(dev->wiphy), priv->transceiver_type);
+		wiphy_debug(dev->wiphy, "unsupported transceiver type %d\n",
+			    priv->transceiver_type);
 		break;
 	}
 
@@ -732,8 +732,8 @@ static int adm8211_rf_set_channel(struct ieee80211_hw *dev, unsigned int chan)
 
 	/* Nothing to do for ADMtek BBP */
 	} else if (priv->bbp_type != ADM8211_TYPE_ADMTEK)
-		printk(KERN_DEBUG "%s: unsupported BBP type %d\n",
-		       wiphy_name(dev->wiphy), priv->bbp_type);
+		wiphy_debug(dev->wiphy, "unsupported bbp type %d\n",
+			    priv->bbp_type);
 
 	ADM8211_RESTORE();
 
@@ -1027,13 +1027,12 @@ static int adm8211_hw_init_bbp(struct ieee80211_hw *dev)
 			break;
 
 		default:
-			printk(KERN_DEBUG "%s: unsupported transceiver %d\n",
-			       wiphy_name(dev->wiphy), priv->transceiver_type);
+			wiphy_debug(dev->wiphy, "unsupported transceiver %d\n",
+				    priv->transceiver_type);
 			break;
 		}
 	} else
-		printk(KERN_DEBUG "%s: unsupported BBP %d\n",
-		       wiphy_name(dev->wiphy), priv->bbp_type);
+		wiphy_debug(dev->wiphy, "unsupported bbp %d\n", priv->bbp_type);
 
 	ADM8211_CSR_WRITE(SYNRF, 0);
 
@@ -1509,15 +1508,13 @@ static int adm8211_start(struct ieee80211_hw *dev)
 	/* Power up MAC and RF chips */
 	retval = adm8211_hw_reset(dev);
 	if (retval) {
-		printk(KERN_ERR "%s: hardware reset failed\n",
-		       wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy, "hardware reset failed\n");
 		goto fail;
 	}
 
 	retval = adm8211_init_rings(dev);
 	if (retval) {
-		printk(KERN_ERR "%s: failed to initialize rings\n",
-		       wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy, "failed to initialize rings\n");
 		goto fail;
 	}
 
@@ -1528,8 +1525,7 @@ static int adm8211_start(struct ieee80211_hw *dev)
 	retval = request_irq(priv->pdev->irq, adm8211_interrupt,
 			     IRQF_SHARED, "adm8211", dev);
 	if (retval) {
-		printk(KERN_ERR "%s: failed to register IRQ handler\n",
-		       wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy, "failed to register irq handler\n");
 		goto fail;
 	}
 
@@ -1906,9 +1902,8 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 		goto err_free_eeprom;
 	}
 
-	printk(KERN_INFO "%s: hwaddr %pM, Rev 0x%02x\n",
-	       wiphy_name(dev->wiphy), dev->wiphy->perm_addr,
-	       pdev->revision);
+	wiphy_info(dev->wiphy, "hwaddr %pm, rev 0x%02x\n",
+		   dev->wiphy->perm_addr, pdev->revision);
 
 	return 0;
 
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index cd8caea..9b0f055 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -658,8 +658,8 @@ static int at76_get_hw_config(struct at76_priv *priv)
 exit:
 	kfree(hwcfg);
 	if (ret < 0)
-		printk(KERN_ERR "%s: cannot get HW Config (error %d)\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy, "cannot get hw config (error %d)\n",
+			  ret);
 
 	return ret;
 }
@@ -794,8 +794,9 @@ static int at76_wait_completion(struct at76_priv *priv, int cmd)
 	do {
 		status = at76_get_cmd_status(priv->udev, cmd);
 		if (status < 0) {
-			printk(KERN_ERR "%s: at76_get_cmd_status failed: %d\n",
-			       wiphy_name(priv->hw->wiphy), status);
+			wiphy_err(priv->hw->wiphy,
+				  "at76_get_cmd_status failed: %d\n",
+				  status);
 			break;
 		}
 
@@ -810,9 +811,8 @@ static int at76_wait_completion(struct at76_priv *priv, int cmd)
 
 		schedule_timeout_interruptible(HZ / 10);	/* 100 ms */
 		if (time_after(jiffies, timeout)) {
-			printk(KERN_ERR
-			       "%s: completion timeout for command %d\n",
-			       wiphy_name(priv->hw->wiphy), cmd);
+			wiphy_err(priv->hw->wiphy,
+				  "completion timeout for command %d\n", cmd);
 			status = -ETIMEDOUT;
 			break;
 		}
@@ -833,9 +833,9 @@ static int at76_set_mib(struct at76_priv *priv, struct set_mib_buffer *buf)
 
 	ret = at76_wait_completion(priv, CMD_SET_MIB);
 	if (ret != CMD_STATUS_COMPLETE) {
-		printk(KERN_INFO
-		       "%s: set_mib: at76_wait_completion failed "
-		       "with %d\n", wiphy_name(priv->hw->wiphy), ret);
+		wiphy_info(priv->hw->wiphy,
+			   "set_mib: at76_wait_completion failed with %d\n",
+			   ret);
 		ret = -EIO;
 	}
 
@@ -855,8 +855,8 @@ static int at76_set_radio(struct at76_priv *priv, int enable)
 
 	ret = at76_set_card_command(priv->udev, cmd, NULL, 0);
 	if (ret < 0)
-		printk(KERN_ERR "%s: at76_set_card_command(%d) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), cmd, ret);
+		wiphy_err(priv->hw->wiphy,
+			  "at76_set_card_command(%d) failed: %d\n", cmd, ret);
 	else
 		ret = 1;
 
@@ -876,8 +876,8 @@ static int at76_set_pm_mode(struct at76_priv *priv)
 
 	ret = at76_set_mib(priv, &priv->mib_buf);
 	if (ret < 0)
-		printk(KERN_ERR "%s: set_mib (pm_mode) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy, "set_mib (pm_mode) failed: %d\n",
+			  ret);
 
 	return ret;
 }
@@ -893,8 +893,8 @@ static int at76_set_preamble(struct at76_priv *priv, u8 type)
 
 	ret = at76_set_mib(priv, &priv->mib_buf);
 	if (ret < 0)
-		printk(KERN_ERR "%s: set_mib (preamble) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy, "set_mib (preamble) failed: %d\n",
+			  ret);
 
 	return ret;
 }
@@ -910,8 +910,8 @@ static int at76_set_frag(struct at76_priv *priv, u16 size)
 
 	ret = at76_set_mib(priv, &priv->mib_buf);
 	if (ret < 0)
-		printk(KERN_ERR "%s: set_mib (frag threshold) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy,
+			  "set_mib (frag threshold) failed: %d\n", ret);
 
 	return ret;
 }
@@ -927,8 +927,7 @@ static int at76_set_rts(struct at76_priv *priv, u16 size)
 
 	ret = at76_set_mib(priv, &priv->mib_buf);
 	if (ret < 0)
-		printk(KERN_ERR "%s: set_mib (rts) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy, "set_mib (rts) failed: %d\n", ret);
 
 	return ret;
 }
@@ -944,8 +943,8 @@ static int at76_set_autorate_fallback(struct at76_priv *priv, int onoff)
 
 	ret = at76_set_mib(priv, &priv->mib_buf);
 	if (ret < 0)
-		printk(KERN_ERR "%s: set_mib (autorate fallback) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy,
+			  "set_mib (autorate fallback) failed: %d\n", ret);
 
 	return ret;
 }
@@ -963,8 +962,8 @@ static void at76_dump_mib_mac_addr(struct at76_priv *priv)
 	ret = at76_get_mib(priv->udev, MIB_MAC_ADDR, m,
 			   sizeof(struct mib_mac_addr));
 	if (ret < 0) {
-		printk(KERN_ERR "%s: at76_get_mib (MAC_ADDR) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy,
+			  "at76_get_mib (mac_addr) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -992,8 +991,8 @@ static void at76_dump_mib_mac_wep(struct at76_priv *priv)
 	ret = at76_get_mib(priv->udev, MIB_MAC_WEP, m,
 			   sizeof(struct mib_mac_wep));
 	if (ret < 0) {
-		printk(KERN_ERR "%s: at76_get_mib (MAC_WEP) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy,
+			  "at76_get_mib (mac_wep) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -1029,8 +1028,8 @@ static void at76_dump_mib_mac_mgmt(struct at76_priv *priv)
 	ret = at76_get_mib(priv->udev, MIB_MAC_MGMT, m,
 			   sizeof(struct mib_mac_mgmt));
 	if (ret < 0) {
-		printk(KERN_ERR "%s: at76_get_mib (MAC_MGMT) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy,
+			  "at76_get_mib (mac_mgmt) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -1065,8 +1064,8 @@ static void at76_dump_mib_mac(struct at76_priv *priv)
 
 	ret = at76_get_mib(priv->udev, MIB_MAC, m, sizeof(struct mib_mac));
 	if (ret < 0) {
-		printk(KERN_ERR "%s: at76_get_mib (MAC) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy,
+			  "at76_get_mib (mac) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -1102,8 +1101,8 @@ static void at76_dump_mib_phy(struct at76_priv *priv)
 
 	ret = at76_get_mib(priv->udev, MIB_PHY, m, sizeof(struct mib_phy));
 	if (ret < 0) {
-		printk(KERN_ERR "%s: at76_get_mib (PHY) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy,
+			  "at76_get_mib (phy) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -1135,8 +1134,8 @@ static void at76_dump_mib_local(struct at76_priv *priv)
 
 	ret = at76_get_mib(priv->udev, MIB_LOCAL, m, sizeof(struct mib_local));
 	if (ret < 0) {
-		printk(KERN_ERR "%s: at76_get_mib (LOCAL) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy,
+			  "at76_get_mib (local) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -1161,8 +1160,8 @@ static void at76_dump_mib_mdomain(struct at76_priv *priv)
 	ret = at76_get_mib(priv->udev, MIB_MDOMAIN, m,
 			   sizeof(struct mib_mdomain));
 	if (ret < 0) {
-		printk(KERN_ERR "%s: at76_get_mib (MDOMAIN) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy,
+			  "at76_get_mib (mdomain) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -1233,16 +1232,16 @@ static int at76_submit_rx_urb(struct at76_priv *priv)
 	struct sk_buff *skb = priv->rx_skb;
 
 	if (!priv->rx_urb) {
-		printk(KERN_ERR "%s: %s: priv->rx_urb is NULL\n",
-		       wiphy_name(priv->hw->wiphy), __func__);
+		wiphy_err(priv->hw->wiphy, "%s: priv->rx_urb is null\n",
+			  __func__);
 		return -EFAULT;
 	}
 
 	if (!skb) {
 		skb = dev_alloc_skb(sizeof(struct at76_rx_buffer));
 		if (!skb) {
-			printk(KERN_ERR "%s: cannot allocate rx skbuff\n",
-			       wiphy_name(priv->hw->wiphy));
+			wiphy_err(priv->hw->wiphy,
+				  "cannot allocate rx skbuff\n");
 			ret = -ENOMEM;
 			goto exit;
 		}
@@ -1261,15 +1260,14 @@ static int at76_submit_rx_urb(struct at76_priv *priv)
 			at76_dbg(DBG_DEVSTART,
 				 "usb_submit_urb returned -ENODEV");
 		else
-			printk(KERN_ERR "%s: rx, usb_submit_urb failed: %d\n",
-			       wiphy_name(priv->hw->wiphy), ret);
+			wiphy_err(priv->hw->wiphy,
+				  "rx, usb_submit_urb failed: %d\n", ret);
 	}
 
 exit:
 	if (ret < 0 && ret != -ENODEV)
-		printk(KERN_ERR "%s: cannot submit rx urb - please unload the "
-		       "driver and/or power cycle the device\n",
-		       wiphy_name(priv->hw->wiphy));
+		wiphy_err(priv->hw->wiphy,
+			  "cannot submit rx urb - please unload the driver and/or power cycle the device\n");
 
 	return ret;
 }
@@ -1438,8 +1436,8 @@ static int at76_startup_device(struct at76_priv *priv)
 	ret = at76_set_card_command(priv->udev, CMD_STARTUP, &priv->card_config,
 				    sizeof(struct at76_card_config));
 	if (ret < 0) {
-		printk(KERN_ERR "%s: at76_set_card_command failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy, "at76_set_card_command failed: %d\n",
+			  ret);
 		return ret;
 	}
 
@@ -1504,8 +1502,8 @@ static void at76_work_set_promisc(struct work_struct *work)
 
 	ret = at76_set_mib(priv, &priv->mib_buf);
 	if (ret < 0)
-		printk(KERN_ERR "%s: set_mib (promiscuous_mode) failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy,
+			  "set_mib (promiscuous_mode) failed: %d\n", ret);
 
 	mutex_unlock(&priv->mtx);
 }
@@ -1668,16 +1666,16 @@ static int at76_join(struct at76_priv *priv)
 				    sizeof(struct at76_req_join));
 
 	if (ret < 0) {
-		printk(KERN_ERR "%s: at76_set_card_command failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy, "at76_set_card_command failed: %d\n",
+			  ret);
 		return 0;
 	}
 
 	ret = at76_wait_completion(priv, CMD_JOIN);
 	at76_dbg(DBG_MAC80211, "%s: CMD_JOIN returned: 0x%02x", __func__, ret);
 	if (ret != CMD_STATUS_COMPLETE) {
-		printk(KERN_ERR "%s: at76_wait_completion failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy, "at76_wait_completion failed: %d\n",
+			  ret);
 		return 0;
 	}
 
@@ -1745,8 +1743,8 @@ static int at76_mac80211_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 	at76_dbg(DBG_MAC80211, "%s()", __func__);
 
 	if (priv->tx_urb->status == -EINPROGRESS) {
-		printk(KERN_ERR "%s: %s called while tx urb is pending\n",
-		       wiphy_name(priv->hw->wiphy), __func__);
+		wiphy_err(priv->hw->wiphy,
+			  "%s called while tx urb is pending\n", __func__);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1794,13 +1792,12 @@ static int at76_mac80211_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 			  submit_len, at76_mac80211_tx_callback, priv);
 	ret = usb_submit_urb(priv->tx_urb, GFP_ATOMIC);
 	if (ret) {
-		printk(KERN_ERR "%s: error in tx submit urb: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy, "error in tx submit urb: %d\n", ret);
 		if (ret == -EINVAL)
-			printk(KERN_ERR
-			       "%s: -EINVAL: tx urb %p hcpriv %p complete %p\n",
-			       wiphy_name(priv->hw->wiphy), priv->tx_urb,
-			       priv->tx_urb->hcpriv, priv->tx_urb->complete);
+			wiphy_err(priv->hw->wiphy,
+				  "-einval: tx urb %p hcpriv %p complete %p\n",
+				  priv->tx_urb,
+				  priv->tx_urb->hcpriv, priv->tx_urb->complete);
 	}
 
 	return 0;
@@ -1817,8 +1814,8 @@ static int at76_mac80211_start(struct ieee80211_hw *hw)
 
 	ret = at76_submit_rx_urb(priv);
 	if (ret < 0) {
-		printk(KERN_ERR "%s: open: submit_rx_urb failed: %d\n",
-		       wiphy_name(priv->hw->wiphy), ret);
+		wiphy_err(priv->hw->wiphy, "open: submit_rx_urb failed: %d\n",
+			  ret);
 		goto error;
 	}
 
@@ -2316,14 +2313,12 @@ static int at76_init_new_device(struct at76_priv *priv,
 
 	priv->mac80211_registered = 1;
 
-	printk(KERN_INFO "%s: USB %s, MAC %pM, firmware %d.%d.%d-%d\n",
-	       wiphy_name(priv->hw->wiphy),
-	       dev_name(&interface->dev), priv->mac_addr,
-	       priv->fw_version.major, priv->fw_version.minor,
-	       priv->fw_version.patch, priv->fw_version.build);
-	printk(KERN_INFO "%s: regulatory domain 0x%02x: %s\n",
-	       wiphy_name(priv->hw->wiphy),
-	       priv->regulatory_domain, priv->domain->name);
+	wiphy_info(priv->hw->wiphy, "usb %s, mac %pm, firmware %d.%d.%d-%d\n",
+		   dev_name(&interface->dev), priv->mac_addr,
+		   priv->fw_version.major, priv->fw_version.minor,
+		   priv->fw_version.patch, priv->fw_version.build);
+	wiphy_info(priv->hw->wiphy, "regulatory domain 0x%02x: %s\n",
+		   priv->regulatory_domain, priv->domain->name);
 
 exit:
 	return ret;
@@ -2485,7 +2480,7 @@ static void at76_disconnect(struct usb_interface *interface)
 	if (!priv)
 		return;
 
-	printk(KERN_INFO "%s: disconnecting\n", wiphy_name(priv->hw->wiphy));
+	wiphy_info(priv->hw->wiphy, "disconnecting\n");
 	at76_delete_device(priv);
 	dev_printk(KERN_INFO, &interface->dev, "disconnected\n");
 }
diff --git a/drivers/net/wireless/ath/ar9170/cmd.c b/drivers/net/wireless/ath/ar9170/cmd.c
index cf6f5c4..4604de0 100644
--- a/drivers/net/wireless/ath/ar9170/cmd.c
+++ b/drivers/net/wireless/ath/ar9170/cmd.c
@@ -48,8 +48,7 @@ int ar9170_write_mem(struct ar9170 *ar, const __le32 *data, size_t len)
 
 	err = ar->exec_cmd(ar, AR9170_CMD_WMEM, len, (u8 *) data, 0, NULL);
 	if (err)
-		printk(KERN_DEBUG "%s: writing memory failed\n",
-		       wiphy_name(ar->hw->wiphy));
+		wiphy_debug(ar->hw->wiphy, "writing memory failed\n");
 	return err;
 }
 
@@ -67,8 +66,8 @@ int ar9170_write_reg(struct ar9170 *ar, const u32 reg, const u32 val)
 	err = ar->exec_cmd(ar, AR9170_CMD_WREG, sizeof(buf),
 			   (u8 *) buf, 0, NULL);
 	if (err)
-		printk(KERN_DEBUG "%s: writing reg %#x (val %#x) failed\n",
-		       wiphy_name(ar->hw->wiphy), reg, val);
+		wiphy_debug(ar->hw->wiphy, "writing reg %#x (val %#x) failed\n",
+			    reg, val);
 	return err;
 }
 
diff --git a/drivers/net/wireless/ath/ar9170/led.c b/drivers/net/wireless/ath/ar9170/led.c
index 86c4e79..832d900 100644
--- a/drivers/net/wireless/ath/ar9170/led.c
+++ b/drivers/net/wireless/ath/ar9170/led.c
@@ -133,8 +133,8 @@ static int ar9170_register_led(struct ar9170 *ar, int i, char *name,
 	err = led_classdev_register(wiphy_dev(ar->hw->wiphy),
 				    &ar->leds[i].l);
 	if (err)
-		printk(KERN_ERR "%s: failed to register %s LED (%d).\n",
-		       wiphy_name(ar->hw->wiphy), ar->leds[i].name, err);
+		wiphy_err(ar->hw->wiphy, "failed to register %s LED (%d).\n",
+			  ar->leds[i].name, err);
 	else
 		ar->leds[i].registered = true;
 
diff --git a/drivers/net/wireless/ath/ar9170/main.c b/drivers/net/wireless/ath/ar9170/main.c
index 2abc875..5e2c514 100644
--- a/drivers/net/wireless/ath/ar9170/main.c
+++ b/drivers/net/wireless/ath/ar9170/main.c
@@ -198,12 +198,13 @@ static void ar9170_print_txheader(struct ar9170 *ar, struct sk_buff *skb)
 	struct ar9170_tx_info *arinfo = (void *) txinfo->rate_driver_data;
 	struct ieee80211_hdr *hdr = (void *) txc->frame_data;
 
-	printk(KERN_DEBUG "%s: => FRAME [skb:%p, q:%d, DA:[%pM] s:%d "
-			  "mac_ctrl:%04x, phy_ctrl:%08x, timeout:[%d ms]]\n",
-	       wiphy_name(ar->hw->wiphy), skb, skb_get_queue_mapping(skb),
-	       ieee80211_get_DA(hdr), ar9170_get_seq_h(hdr),
-	       le16_to_cpu(txc->mac_control), le32_to_cpu(txc->phy_control),
-	       jiffies_to_msecs(arinfo->timeout - jiffies));
+	wiphy_debug(ar->hw->wiphy,
+		    "=> FRAME [skb:%p, q:%d, DA:[%pM] s:%d "
+		    "mac_ctrl:%04x, phy_ctrl:%08x, timeout:[%d ms]]\n",
+		    skb, skb_get_queue_mapping(skb),
+		    ieee80211_get_DA(hdr), ar9170_get_seq_h(hdr),
+		    le16_to_cpu(txc->mac_control), le32_to_cpu(txc->phy_control),
+		    jiffies_to_msecs(arinfo->timeout - jiffies));
 }
 
 static void __ar9170_dump_txqueue(struct ar9170 *ar,
@@ -213,8 +214,8 @@ static void __ar9170_dump_txqueue(struct ar9170 *ar,
 	int i = 0;
 
 	printk(KERN_DEBUG "---[ cut here ]---\n");
-	printk(KERN_DEBUG "%s: %d entries in queue.\n",
-	       wiphy_name(ar->hw->wiphy), skb_queue_len(queue));
+	wiphy_debug(ar->hw->wiphy, "%d entries in queue.\n",
+		    skb_queue_len(queue));
 
 	skb_queue_walk(queue, skb) {
 		printk(KERN_DEBUG "index:%d =>\n", i++);
@@ -244,15 +245,14 @@ static void __ar9170_dump_txstats(struct ar9170 *ar)
 {
 	int i;
 
-	printk(KERN_DEBUG "%s: QoS queue stats\n",
-	       wiphy_name(ar->hw->wiphy));
+	wiphy_debug(ar->hw->wiphy, "qos queue stats\n");
 
 	for (i = 0; i < __AR9170_NUM_TXQ; i++)
-		printk(KERN_DEBUG "%s: queue:%d limit:%d len:%d waitack:%d "
-		       " stopped:%d\n", wiphy_name(ar->hw->wiphy), i,
-		       ar->tx_stats[i].limit, ar->tx_stats[i].len,
-		       skb_queue_len(&ar->tx_status[i]),
-		       ieee80211_queue_stopped(ar->hw, i));
+		wiphy_debug(ar->hw->wiphy,
+			    "queue:%d limit:%d len:%d waitack:%d stopped:%d\n",
+			    i, ar->tx_stats[i].limit, ar->tx_stats[i].len,
+			    skb_queue_len(&ar->tx_status[i]),
+			    ieee80211_queue_stopped(ar->hw, i));
 }
 #endif /* AR9170_QUEUE_STOP_DEBUG */
 
@@ -274,9 +274,9 @@ static void ar9170_recycle_expired(struct ar9170 *ar,
 
 		if (time_is_before_jiffies(arinfo->timeout)) {
 #ifdef AR9170_QUEUE_DEBUG
-			printk(KERN_DEBUG "%s: [%ld > %ld] frame expired => "
-			       "recycle\n", wiphy_name(ar->hw->wiphy),
-			       jiffies, arinfo->timeout);
+			wiphy_debug(ar->hw->wiphy,
+				    "[%ld > %ld] frame expired => recycle\n",
+				    jiffies, arinfo->timeout);
 			ar9170_print_txheader(ar, skb);
 #endif /* AR9170_QUEUE_DEBUG */
 			__skb_unlink(skb, queue);
@@ -317,8 +317,8 @@ static void ar9170_tx_status(struct ar9170 *ar, struct sk_buff *skb,
 		break;
 
 	default:
-		printk(KERN_ERR "%s: invalid tx_status response (%x).\n",
-		       wiphy_name(ar->hw->wiphy), tx_status);
+		wiphy_err(ar->hw->wiphy,
+			  "invalid tx_status response (%x)\n", tx_status);
 		break;
 	}
 
@@ -339,8 +339,7 @@ void ar9170_tx_callback(struct ar9170 *ar, struct sk_buff *skb)
 
 	if (ar->tx_stats[queue].len < AR9170_NUM_TX_LIMIT_SOFT) {
 #ifdef AR9170_QUEUE_STOP_DEBUG
-		printk(KERN_DEBUG "%s: wake queue %d\n",
-		       wiphy_name(ar->hw->wiphy), queue);
+		wiphy_debug(ar->hw->wiphy, "wake queue %d\n", queue);
 		__ar9170_dump_txstats(ar);
 #endif /* AR9170_QUEUE_STOP_DEBUG */
 		ieee80211_wake_queue(ar->hw, queue);
@@ -387,9 +386,9 @@ static struct sk_buff *ar9170_get_queued_skb(struct ar9170 *ar,
 
 		if (mac && compare_ether_addr(ieee80211_get_DA(hdr), mac)) {
 #ifdef AR9170_QUEUE_DEBUG
-			printk(KERN_DEBUG "%s: skip frame => DA %pM != %pM\n",
-			       wiphy_name(ar->hw->wiphy), mac,
-			       ieee80211_get_DA(hdr));
+			wiphy_debug(ar->hw->wiphy,
+				    "skip frame => da %pm != %pm\n",
+				    mac, ieee80211_get_DA(hdr));
 			ar9170_print_txheader(ar, skb);
 #endif /* AR9170_QUEUE_DEBUG */
 			continue;
@@ -400,8 +399,8 @@ static struct sk_buff *ar9170_get_queued_skb(struct ar9170 *ar,
 
 		if ((rate != AR9170_TX_INVALID_RATE) && (r != rate)) {
 #ifdef AR9170_QUEUE_DEBUG
-			printk(KERN_DEBUG "%s: skip frame => rate %d != %d\n",
-			       wiphy_name(ar->hw->wiphy), rate, r);
+			wiphy_debug(ar->hw->wiphy,
+				    "skip frame => rate %d != %d\n", rate, r);
 			ar9170_print_txheader(ar, skb);
 #endif /* AR9170_QUEUE_DEBUG */
 			continue;
@@ -413,9 +412,9 @@ static struct sk_buff *ar9170_get_queued_skb(struct ar9170 *ar,
 	}
 
 #ifdef AR9170_QUEUE_DEBUG
-	printk(KERN_ERR "%s: ESS:[%pM] does not have any "
-			"outstanding frames in queue.\n",
-			wiphy_name(ar->hw->wiphy), mac);
+	wiphy_err(ar->hw->wiphy,
+		  "ESS:[%pM] does not have any outstanding frames in queue.\n",
+		  mac);
 	__ar9170_dump_txqueue(ar, queue);
 #endif /* AR9170_QUEUE_DEBUG */
 	spin_unlock_irqrestore(&queue->lock, flags);
@@ -444,8 +443,8 @@ static void ar9170_tx_janitor(struct work_struct *work)
 
 	for (i = 0; i < __AR9170_NUM_TXQ; i++) {
 #ifdef AR9170_QUEUE_DEBUG
-		printk(KERN_DEBUG "%s: garbage collector scans queue:%d\n",
-		       wiphy_name(ar->hw->wiphy), i);
+		wiphy_debug(ar->hw->wiphy, "garbage collector scans queue:%d\n",
+			    i);
 		ar9170_dump_txqueue(ar, &ar->tx_pending[i]);
 		ar9170_dump_txqueue(ar, &ar->tx_status[i]);
 #endif /* AR9170_QUEUE_DEBUG */
@@ -495,8 +494,9 @@ void ar9170_handle_command_response(struct ar9170 *ar, void *buf, u32 len)
 		u32 q = (phy & AR9170_TX_PHY_QOS_MASK) >>
 			AR9170_TX_PHY_QOS_SHIFT;
 #ifdef AR9170_QUEUE_DEBUG
-		printk(KERN_DEBUG "%s: recv tx_status for %pM, p:%08x, q:%d\n",
-		       wiphy_name(ar->hw->wiphy), cmd->tx_status.dst, phy, q);
+		wiphy_debug(ar->hw->wiphy,
+			    "recv tx_status for %pm, p:%08x, q:%d\n",
+			    cmd->tx_status.dst, phy, q);
 #endif /* AR9170_QUEUE_DEBUG */
 
 		skb = ar9170_get_queued_skb(ar, cmd->tx_status.dst,
@@ -582,7 +582,7 @@ void ar9170_handle_command_response(struct ar9170 *ar, void *buf, u32 len)
 		break;
 
 	default:
-		printk(KERN_INFO "received unhandled event %x\n", cmd->type);
+		pr_info("received unhandled event %x\n", cmd->type);
 		print_hex_dump_bytes("dump:", DUMP_PREFIX_NONE, buf, len);
 		break;
 	}
@@ -675,9 +675,9 @@ static int ar9170_rx_mac_status(struct ar9170 *ar,
 		/* TODO: update netdevice's RX dropped/errors statistics */
 
 		if (ar9170_nag_limiter(ar))
-			printk(KERN_DEBUG "%s: received frame with "
-			       "suspicious error code (%#x).\n",
-			       wiphy_name(ar->hw->wiphy), error);
+			wiphy_debug(ar->hw->wiphy,
+				    "received frame with suspicious error code (%#x).\n",
+				    error);
 
 		return -EINVAL;
 	}
@@ -704,9 +704,9 @@ static int ar9170_rx_mac_status(struct ar9170 *ar,
 			break;
 		default:
 			if (ar9170_nag_limiter(ar))
-				printk(KERN_ERR "%s: invalid plcp cck rate "
-				       "(%x).\n", wiphy_name(ar->hw->wiphy),
-				       head->plcp[0]);
+				wiphy_err(ar->hw->wiphy,
+					  "invalid plcp cck rate (%x).\n",
+					  head->plcp[0]);
 			return -EINVAL;
 		}
 		break;
@@ -740,9 +740,9 @@ static int ar9170_rx_mac_status(struct ar9170 *ar,
 			break;
 		default:
 			if (ar9170_nag_limiter(ar))
-				printk(KERN_ERR "%s: invalid plcp ofdm rate "
-				       "(%x).\n", wiphy_name(ar->hw->wiphy),
-				       head->plcp[0]);
+				wiphy_err(ar->hw->wiphy,
+					  "invalid plcp ofdm rate (%x).\n",
+					  head->plcp[0]);
 			return -EINVAL;
 		}
 		if (status->band == IEEE80211_BAND_2GHZ)
@@ -761,8 +761,7 @@ static int ar9170_rx_mac_status(struct ar9170 *ar,
 
 	default:
 		if (ar9170_nag_limiter(ar))
-			printk(KERN_ERR "%s: invalid modulation\n",
-			       wiphy_name(ar->hw->wiphy));
+			wiphy_err(ar->hw->wiphy, "invalid modulation\n");
 		return -EINVAL;
 	}
 
@@ -863,8 +862,8 @@ static void ar9170_handle_mpdu(struct ar9170 *ar, u8 *buf, int len)
 			ar->rx_mpdu.has_plcp = true;
 		} else {
 			if (ar9170_nag_limiter(ar))
-				printk(KERN_ERR "%s: plcp info is clipped.\n",
-				       wiphy_name(ar->hw->wiphy));
+				wiphy_err(ar->hw->wiphy,
+					  "plcp info is clipped.\n");
 			return ;
 		}
 		break;
@@ -877,8 +876,8 @@ static void ar9170_handle_mpdu(struct ar9170 *ar, u8 *buf, int len)
 			phy = (void *)(buf + mpdu_len);
 		} else {
 			if (ar9170_nag_limiter(ar))
-				printk(KERN_ERR "%s: frame tail is clipped.\n",
-				       wiphy_name(ar->hw->wiphy));
+				wiphy_err(ar->hw->wiphy,
+					  "frame tail is clipped.\n");
 			return ;
 		}
 
@@ -888,9 +887,8 @@ static void ar9170_handle_mpdu(struct ar9170 *ar, u8 *buf, int len)
 			if (!ar9170_nag_limiter(ar))
 				return ;
 
-			printk(KERN_ERR "%s: rx stream did not start "
-					"with a first_mpdu frame tag.\n",
-			       wiphy_name(ar->hw->wiphy));
+			wiphy_err(ar->hw->wiphy,
+				  "rx stream did not start with a first_mpdu frame tag.\n");
 
 			return ;
 		}
@@ -954,8 +952,8 @@ void ar9170_rx(struct ar9170 *ar, struct sk_buff *skb)
 			if (!ar->rx_failover_missing) {
 				/* this is no "short read". */
 				if (ar9170_nag_limiter(ar)) {
-					printk(KERN_ERR "%s: missing tag!\n",
-					       wiphy_name(ar->hw->wiphy));
+					wiphy_err(ar->hw->wiphy,
+						  "missing tag!\n");
 					goto err_telluser;
 				} else
 					goto err_silent;
@@ -963,9 +961,8 @@ void ar9170_rx(struct ar9170 *ar, struct sk_buff *skb)
 
 			if (ar->rx_failover_missing > tlen) {
 				if (ar9170_nag_limiter(ar)) {
-					printk(KERN_ERR "%s: possible multi "
-					       "stream corruption!\n",
-					       wiphy_name(ar->hw->wiphy));
+					wiphy_err(ar->hw->wiphy,
+						  "possible multi stream corruption!\n");
 					goto err_telluser;
 				} else
 					goto err_silent;
@@ -997,9 +994,8 @@ void ar9170_rx(struct ar9170 *ar, struct sk_buff *skb)
 			if (ar->rx_failover_missing) {
 				/* TODO: handle double stream corruption. */
 				if (ar9170_nag_limiter(ar)) {
-					printk(KERN_ERR "%s: double rx stream "
-					       "corruption!\n",
-						wiphy_name(ar->hw->wiphy));
+					wiphy_err(ar->hw->wiphy,
+						  "double rx stream corruption!\n");
 					goto err_telluser;
 				} else
 					goto err_silent;
@@ -1042,9 +1038,9 @@ void ar9170_rx(struct ar9170 *ar, struct sk_buff *skb)
 
 	if (tlen) {
 		if (net_ratelimit())
-			printk(KERN_ERR "%s: %d bytes of unprocessed "
-					"data left in rx stream!\n",
-			       wiphy_name(ar->hw->wiphy), tlen);
+			wiphy_err(ar->hw->wiphy,
+				  "%d bytes of unprocessed data left in rx stream!\n",
+				  tlen);
 
 		goto err_telluser;
 	}
@@ -1052,10 +1048,9 @@ void ar9170_rx(struct ar9170 *ar, struct sk_buff *skb)
 	return ;
 
 err_telluser:
-	printk(KERN_ERR "%s: damaged RX stream data [want:%d, "
-			"data:%d, rx:%d, pending:%d ]\n",
-	       wiphy_name(ar->hw->wiphy), clen, wlen, tlen,
-	       ar->rx_failover_missing);
+	wiphy_err(ar->hw->wiphy,
+		  "damaged RX stream data [want:%d, data:%d, rx:%d, pending:%d ]\n",
+		  clen, wlen, tlen, ar->rx_failover_missing);
 
 	if (ar->rx_failover_missing)
 		print_hex_dump_bytes("rxbuf:", DUMP_PREFIX_OFFSET,
@@ -1065,9 +1060,8 @@ err_telluser:
 	print_hex_dump_bytes("stream:", DUMP_PREFIX_OFFSET,
 			     skb->data, skb->len);
 
-	printk(KERN_ERR "%s: please check your hardware and cables, if "
-			"you see this message frequently.\n",
-	       wiphy_name(ar->hw->wiphy));
+	wiphy_err(ar->hw->wiphy,
+		  "If you see this message frequently, please check your hardware and cables.\n");
 
 err_silent:
 	if (ar->rx_failover_missing) {
@@ -1384,10 +1378,10 @@ static void ar9170_tx(struct ar9170 *ar)
 
 		if (remaining_space < frames) {
 #ifdef AR9170_QUEUE_DEBUG
-			printk(KERN_DEBUG "%s: tx quota reached queue:%d, "
-			       "remaining slots:%d, needed:%d\n",
-			       wiphy_name(ar->hw->wiphy), i, remaining_space,
-			       frames);
+			wiphy_debug(ar->hw->wiphy,
+				    "tx quota reached queue:%d, "
+				    "remaining slots:%d, needed:%d\n",
+				    i, remaining_space, frames);
 #endif /* AR9170_QUEUE_DEBUG */
 			frames = remaining_space;
 		}
@@ -1396,18 +1390,14 @@ static void ar9170_tx(struct ar9170 *ar)
 		ar->tx_stats[i].count += frames;
 		if (ar->tx_stats[i].len >= ar->tx_stats[i].limit) {
 #ifdef AR9170_QUEUE_DEBUG
-			printk(KERN_DEBUG "%s: queue %d full\n",
-			       wiphy_name(ar->hw->wiphy), i);
-
-			printk(KERN_DEBUG "%s: stuck frames: ===>\n",
-			       wiphy_name(ar->hw->wiphy));
+			wiphy_debug(ar->hw->wiphy, "queue %d full\n", i);
+			wiphy_debug(ar->hw->wiphy, "stuck frames: ===>\n");
 			ar9170_dump_txqueue(ar, &ar->tx_pending[i]);
 			ar9170_dump_txqueue(ar, &ar->tx_status[i]);
 #endif /* AR9170_QUEUE_DEBUG */
 
 #ifdef AR9170_QUEUE_STOP_DEBUG
-			printk(KERN_DEBUG "%s: stop queue %d\n",
-			       wiphy_name(ar->hw->wiphy), i);
+			wiphy_debug(ar->hw->wiphy, "stop queue %d\n", i);
 			__ar9170_dump_txstats(ar);
 #endif /* AR9170_QUEUE_STOP_DEBUG */
 			ieee80211_stop_queue(ar->hw, i);
@@ -1435,8 +1425,7 @@ static void ar9170_tx(struct ar9170 *ar)
 					  msecs_to_jiffies(AR9170_TX_TIMEOUT);
 
 #ifdef AR9170_QUEUE_DEBUG
-			printk(KERN_DEBUG "%s: send frame q:%d =>\n",
-			       wiphy_name(ar->hw->wiphy), i);
+			wiphy_debug(ar->hw->wiphy, "send frame q:%d =>\n", i);
 			ar9170_print_txheader(ar, skb);
 #endif /* AR9170_QUEUE_DEBUG */
 
@@ -1453,26 +1442,25 @@ static void ar9170_tx(struct ar9170 *ar)
 		}
 
 #ifdef AR9170_QUEUE_DEBUG
-		printk(KERN_DEBUG "%s: ar9170_tx report for queue %d\n",
-		       wiphy_name(ar->hw->wiphy), i);
+		wiphy_debug(ar->hw->wiphy,
+			    "ar9170_tx report for queue %d\n", i);
 
-		printk(KERN_DEBUG "%s: unprocessed pending frames left:\n",
-		       wiphy_name(ar->hw->wiphy));
+		wiphy_debug(ar->hw->wiphy,
+			    "unprocessed pending frames left:\n");
 		ar9170_dump_txqueue(ar, &ar->tx_pending[i]);
 #endif /* AR9170_QUEUE_DEBUG */
 
 		if (unlikely(frames_failed)) {
 #ifdef AR9170_QUEUE_DEBUG
-			printk(KERN_DEBUG "%s: frames failed %d =>\n",
-			       wiphy_name(ar->hw->wiphy), frames_failed);
+			wiphy_debug(ar->hw->wiphy,
+				    "frames failed %d =>\n", frames_failed);
 #endif /* AR9170_QUEUE_DEBUG */
 
 			spin_lock_irqsave(&ar->tx_stats_lock, flags);
 			ar->tx_stats[i].len -= frames_failed;
 			ar->tx_stats[i].count -= frames_failed;
 #ifdef AR9170_QUEUE_STOP_DEBUG
-			printk(KERN_DEBUG "%s: wake queue %d\n",
-			       wiphy_name(ar->hw->wiphy), i);
+			wiphy_debug(ar->hw->wiphy, "wake queue %d\n", i);
 			__ar9170_dump_txstats(ar);
 #endif /* AR9170_QUEUE_STOP_DEBUG */
 			ieee80211_wake_queue(ar->hw, i);
diff --git a/drivers/net/wireless/ath/ar9170/phy.c b/drivers/net/wireless/ath/ar9170/phy.c
index 45a415e..0dbfcf7 100644
--- a/drivers/net/wireless/ath/ar9170/phy.c
+++ b/drivers/net/wireless/ath/ar9170/phy.c
@@ -670,8 +670,7 @@ static int ar9170_init_rf_banks_0_7(struct ar9170 *ar, bool band5ghz)
 	ar9170_regwrite_finish();
 	err = ar9170_regwrite_result();
 	if (err)
-		printk(KERN_ERR "%s: rf init failed\n",
-		       wiphy_name(ar->hw->wiphy));
+		wiphy_err(ar->hw->wiphy, "rf init failed\n");
 	return err;
 }
 
@@ -1702,9 +1701,8 @@ int ar9170_set_channel(struct ar9170 *ar, struct ieee80211_channel *channel,
 				       0x200 | ar->phy_heavy_clip);
 		if (err) {
 			if (ar9170_nag_limiter(ar))
-				printk(KERN_ERR "%s: failed to set "
-				       "heavy clip\n",
-				       wiphy_name(ar->hw->wiphy));
+				wiphy_err(ar->hw->wiphy,
+					  "failed to set heavy clip\n");
 		}
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/ahb.c b/drivers/net/wireless/ath/ath9k/ahb.c
index 85fdd26..1a984b0 100644
--- a/drivers/net/wireless/ath/ath9k/ahb.c
+++ b/drivers/net/wireless/ath/ath9k/ahb.c
@@ -131,11 +131,8 @@ static int ath_ahb_probe(struct platform_device *pdev)
 
 	ah = sc->sc_ah;
 	ath9k_hw_name(ah, hw_name, sizeof(hw_name));
-	printk(KERN_INFO
-	       "%s: %s mem=0x%lx, irq=%d\n",
-	       wiphy_name(hw->wiphy),
-	       hw_name,
-	       (unsigned long)mem, irq);
+	wiphy_info(hw->wiphy, "%s mem=0x%lx, irq=%d\n",
+		   hw_name, (unsigned long)mem, irq);
 
 	return 0;
 
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index 257b10b..b5b6514 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -209,11 +209,8 @@ static int ath_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	}
 
 	ath9k_hw_name(sc->sc_ah, hw_name, sizeof(hw_name));
-	printk(KERN_INFO
-	       "%s: %s mem=0x%lx, irq=%d\n",
-	       wiphy_name(hw->wiphy),
-	       hw_name,
-	       (unsigned long)mem, pdev->irq);
+	wiphy_info(hw->wiphy, "%s mem=0x%lx, irq=%d\n",
+		   hw_name, (unsigned long)mem, pdev->irq);
 
 	return 0;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 7391c63..bf9a217 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -27,6 +27,8 @@
  *
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
@@ -4389,19 +4391,18 @@ static int __init iwl_init(void)
 {
 
 	int ret;
-	printk(KERN_INFO DRV_NAME ": " DRV_DESCRIPTION ", " DRV_VERSION "\n");
-	printk(KERN_INFO DRV_NAME ": " DRV_COPYRIGHT "\n");
+	pr_info(DRV_DESCRIPTION ", " DRV_VERSION "\n");
+	pr_info(DRV_COPYRIGHT "\n");
 
 	ret = iwlagn_rate_control_register();
 	if (ret) {
-		printk(KERN_ERR DRV_NAME
-		       "Unable to register rate control algorithm: %d\n", ret);
+		pr_err("Unable to register rate control algorithm: %d\n", ret);
 		return ret;
 	}
 
 	ret = pci_register_driver(&iwl_driver);
 	if (ret) {
-		printk(KERN_ERR DRV_NAME "Unable to initialize PCI module\n");
+		pr_err("Unable to initialize PCI module\n");
 		goto error_register;
 	}
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 676d49d..73c4fda 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -170,7 +170,7 @@ struct ieee80211_hw *iwl_alloc_all(struct iwl_cfg *cfg,
 	struct ieee80211_hw *hw =
 		ieee80211_alloc_hw(sizeof(struct iwl_priv), hw_ops);
 	if (hw == NULL) {
-		printk(KERN_ERR "%s: Can not allocate network device\n",
+		pr_err("%s: Can not allocate network device\n",
 		       cfg->name);
 		goto out;
 	}
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 8eb3471..5a06ade 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -27,6 +27,8 @@
  *
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
@@ -3932,7 +3934,7 @@ static int iwl3945_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 	 *   space for this driver's private structure */
 	hw = iwl_alloc_all(cfg, &iwl3945_hw_ops);
 	if (hw == NULL) {
-		printk(KERN_ERR DRV_NAME "Can not allocate network device\n");
+		pr_err("Can not allocate network device\n");
 		err = -ENOMEM;
 		goto out;
 	}
@@ -4224,19 +4226,18 @@ static int __init iwl3945_init(void)
 {
 
 	int ret;
-	printk(KERN_INFO DRV_NAME ": " DRV_DESCRIPTION ", " DRV_VERSION "\n");
-	printk(KERN_INFO DRV_NAME ": " DRV_COPYRIGHT "\n");
+	pr_info(DRV_DESCRIPTION ", " DRV_VERSION "\n");
+	pr_info(DRV_COPYRIGHT "\n");
 
 	ret = iwl3945_rate_control_register();
 	if (ret) {
-		printk(KERN_ERR DRV_NAME
-		       "Unable to register rate control algorithm: %d\n", ret);
+		pr_err("Unable to register rate control algorithm: %d\n", ret);
 		return ret;
 	}
 
 	ret = pci_register_driver(&iwl3945_driver);
 	if (ret) {
-		printk(KERN_ERR DRV_NAME "Unable to initialize PCI module\n");
+		pr_err("Unable to initialize PCI module\n");
 		goto error_register;
 	}
 
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index e7f299d..01ad7f7 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -486,8 +486,7 @@ static bool mac80211_hwsim_tx_frame(struct ieee80211_hw *hw,
 	struct ieee80211_rx_status rx_status;
 
 	if (data->idle) {
-		printk(KERN_DEBUG "%s: Trying to TX when idle - reject\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_debug(hw->wiphy, "trying to tx when idle - reject\n");
 		return false;
 	}
 
@@ -576,7 +575,7 @@ static int mac80211_hwsim_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 static int mac80211_hwsim_start(struct ieee80211_hw *hw)
 {
 	struct mac80211_hwsim_data *data = hw->priv;
-	printk(KERN_DEBUG "%s:%s\n", wiphy_name(hw->wiphy), __func__);
+	wiphy_debug(hw->wiphy, "%s\n", __func__);
 	data->started = 1;
 	return 0;
 }
@@ -587,16 +586,15 @@ static void mac80211_hwsim_stop(struct ieee80211_hw *hw)
 	struct mac80211_hwsim_data *data = hw->priv;
 	data->started = 0;
 	del_timer(&data->beacon_timer);
-	printk(KERN_DEBUG "%s:%s\n", wiphy_name(hw->wiphy), __func__);
+	wiphy_debug(hw->wiphy, "%s\n", __func__);
 }
 
 
 static int mac80211_hwsim_add_interface(struct ieee80211_hw *hw,
 					struct ieee80211_vif *vif)
 {
-	printk(KERN_DEBUG "%s:%s (type=%d mac_addr=%pM)\n",
-	       wiphy_name(hw->wiphy), __func__, vif->type,
-	       vif->addr);
+	wiphy_debug(hw->wiphy, "%s (type=%d mac_addr=%pM)\n",
+		    __func__, vif->type, vif->addr);
 	hwsim_set_magic(vif);
 	return 0;
 }
@@ -605,9 +603,8 @@ static int mac80211_hwsim_add_interface(struct ieee80211_hw *hw,
 static void mac80211_hwsim_remove_interface(
 	struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 {
-	printk(KERN_DEBUG "%s:%s (type=%d mac_addr=%pM)\n",
-	       wiphy_name(hw->wiphy), __func__, vif->type,
-	       vif->addr);
+	wiphy_debug(hw->wiphy, "%s (type=%d mac_addr=%pM)\n",
+		    __func__, vif->type, vif->addr);
 	hwsim_check_magic(vif);
 	hwsim_clear_magic(vif);
 }
@@ -670,13 +667,14 @@ static int mac80211_hwsim_config(struct ieee80211_hw *hw, u32 changed)
 		[IEEE80211_SMPS_DYNAMIC] = "dynamic",
 	};
 
-	printk(KERN_DEBUG "%s:%s (freq=%d/%s idle=%d ps=%d smps=%s)\n",
-	       wiphy_name(hw->wiphy), __func__,
-	       conf->channel->center_freq,
-	       hwsim_chantypes[conf->channel_type],
-	       !!(conf->flags & IEEE80211_CONF_IDLE),
-	       !!(conf->flags & IEEE80211_CONF_PS),
-	       smps_modes[conf->smps_mode]);
+	wiphy_debug(hw->wiphy,
+		    "%s (freq=%d/%s idle=%d ps=%d smps=%s)\n",
+		    __func__,
+		    conf->channel->center_freq,
+		    hwsim_chantypes[conf->channel_type],
+		    !!(conf->flags & IEEE80211_CONF_IDLE),
+		    !!(conf->flags & IEEE80211_CONF_PS),
+		    smps_modes[conf->smps_mode]);
 
 	data->idle = !!(conf->flags & IEEE80211_CONF_IDLE);
 
@@ -696,7 +694,7 @@ static void mac80211_hwsim_configure_filter(struct ieee80211_hw *hw,
 {
 	struct mac80211_hwsim_data *data = hw->priv;
 
-	printk(KERN_DEBUG "%s:%s\n", wiphy_name(hw->wiphy), __func__);
+	wiphy_debug(hw->wiphy, "%s\n", __func__);
 
 	data->rx_filter = 0;
 	if (*total_flags & FIF_PROMISC_IN_BSS)
@@ -717,26 +715,23 @@ static void mac80211_hwsim_bss_info_changed(struct ieee80211_hw *hw,
 
 	hwsim_check_magic(vif);
 
-	printk(KERN_DEBUG "%s:%s(changed=0x%x)\n",
-	       wiphy_name(hw->wiphy), __func__, changed);
+	wiphy_debug(hw->wiphy, "%s(changed=0x%x)\n", __func__, changed);
 
 	if (changed & BSS_CHANGED_BSSID) {
-		printk(KERN_DEBUG "%s:%s: BSSID changed: %pM\n",
-		       wiphy_name(hw->wiphy), __func__,
-		       info->bssid);
+		wiphy_debug(hw->wiphy, "%s: BSSID changed: %pM\n",
+			    __func__, info->bssid);
 		memcpy(vp->bssid, info->bssid, ETH_ALEN);
 	}
 
 	if (changed & BSS_CHANGED_ASSOC) {
-		printk(KERN_DEBUG "  %s: ASSOC: assoc=%d aid=%d\n",
-		       wiphy_name(hw->wiphy), info->assoc, info->aid);
+		wiphy_debug(hw->wiphy, "  ASSOC: assoc=%d aid=%d\n",
+			    info->assoc, info->aid);
 		vp->assoc = info->assoc;
 		vp->aid = info->aid;
 	}
 
 	if (changed & BSS_CHANGED_BEACON_INT) {
-		printk(KERN_DEBUG "  %s: BCNINT: %d\n",
-		       wiphy_name(hw->wiphy), info->beacon_int);
+		wiphy_debug(hw->wiphy, "  BCNINT: %d\n", info->beacon_int);
 		data->beacon_int = 1024 * info->beacon_int / 1000 * HZ / 1000;
 		if (WARN_ON(!data->beacon_int))
 			data->beacon_int = 1;
@@ -746,31 +741,28 @@ static void mac80211_hwsim_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_ERP_CTS_PROT) {
-		printk(KERN_DEBUG "  %s: ERP_CTS_PROT: %d\n",
-		       wiphy_name(hw->wiphy), info->use_cts_prot);
+		wiphy_debug(hw->wiphy, "  ERP_CTS_PROT: %d\n",
+			    info->use_cts_prot);
 	}
 
 	if (changed & BSS_CHANGED_ERP_PREAMBLE) {
-		printk(KERN_DEBUG "  %s: ERP_PREAMBLE: %d\n",
-		       wiphy_name(hw->wiphy), info->use_short_preamble);
+		wiphy_debug(hw->wiphy, "  ERP_PREAMBLE: %d\n",
+			    info->use_short_preamble);
 	}
 
 	if (changed & BSS_CHANGED_ERP_SLOT) {
-		printk(KERN_DEBUG "  %s: ERP_SLOT: %d\n",
-		       wiphy_name(hw->wiphy), info->use_short_slot);
+		wiphy_debug(hw->wiphy, "  ERP_SLOT: %d\n", info->use_short_slot);
 	}
 
 	if (changed & BSS_CHANGED_HT) {
-		printk(KERN_DEBUG "  %s: HT: op_mode=0x%x, chantype=%s\n",
-		       wiphy_name(hw->wiphy),
-		       info->ht_operation_mode,
-		       hwsim_chantypes[info->channel_type]);
+		wiphy_debug(hw->wiphy, "  HT: op_mode=0x%x, chantype=%s\n",
+			    info->ht_operation_mode,
+			    hwsim_chantypes[info->channel_type]);
 	}
 
 	if (changed & BSS_CHANGED_BASIC_RATES) {
-		printk(KERN_DEBUG "  %s: BASIC_RATES: 0x%llx\n",
-		       wiphy_name(hw->wiphy),
-		       (unsigned long long) info->basic_rates);
+		wiphy_debug(hw->wiphy, "  BASIC_RATES: 0x%llx\n",
+			    (unsigned long long) info->basic_rates);
 	}
 }
 
@@ -824,10 +816,11 @@ static int mac80211_hwsim_conf_tx(
 	struct ieee80211_hw *hw, u16 queue,
 	const struct ieee80211_tx_queue_params *params)
 {
-	printk(KERN_DEBUG "%s:%s (queue=%d txop=%d cw_min=%d cw_max=%d "
-	       "aifs=%d)\n",
-	       wiphy_name(hw->wiphy), __func__, queue,
-	       params->txop, params->cw_min, params->cw_max, params->aifs);
+	wiphy_debug(hw->wiphy,
+		    "%s (queue=%d txop=%d cw_min=%d cw_max=%d aifs=%d)\n",
+		    __func__, queue,
+		    params->txop, params->cw_min,
+		    params->cw_max, params->aifs);
 	return 0;
 }
 
@@ -837,8 +830,7 @@ static int mac80211_hwsim_get_survey(
 {
 	struct ieee80211_conf *conf = &hw->conf;
 
-	printk(KERN_DEBUG "%s:%s (idx=%d)\n",
-	       wiphy_name(hw->wiphy), __func__, idx);
+	wiphy_debug(hw->wiphy, "%s (idx=%d)\n", __func__, idx);
 
 	if (idx != 0)
 		return -ENOENT;
@@ -1108,8 +1100,9 @@ static void hwsim_send_ps_poll(void *dat, u8 *mac, struct ieee80211_vif *vif)
 	if (!vp->assoc)
 		return;
 
-	printk(KERN_DEBUG "%s:%s: send PS-Poll to %pM for aid %d\n",
-	       wiphy_name(data->hw->wiphy), __func__, vp->bssid, vp->aid);
+	wiphy_debug(data->hw->wiphy,
+		    "%s: send PS-Poll to %pM for aid %d\n",
+		    __func__, vp->bssid, vp->aid);
 
 	skb = dev_alloc_skb(sizeof(*pspoll));
 	if (!skb)
@@ -1137,8 +1130,9 @@ static void hwsim_send_nullfunc(struct mac80211_hwsim_data *data, u8 *mac,
 	if (!vp->assoc)
 		return;
 
-	printk(KERN_DEBUG "%s:%s: send data::nullfunc to %pM ps=%d\n",
-	       wiphy_name(data->hw->wiphy), __func__, vp->bssid, ps);
+	wiphy_debug(data->hw->wiphy,
+		    "%s: send data::nullfunc to %pM ps=%d\n",
+		    __func__, vp->bssid, ps);
 
 	skb = dev_alloc_skb(sizeof(*hdr));
 	if (!skb)
@@ -1473,9 +1467,8 @@ static int __init init_mac80211_hwsim(void)
 			break;
 		}
 
-		printk(KERN_DEBUG "%s: hwaddr %pM registered\n",
-		       wiphy_name(hw->wiphy),
-		       hw->wiphy->perm_addr);
+		wiphy_debug(hw->wiphy, "hwaddr %pm registered\n",
+			    hw->wiphy->perm_addr);
 
 		data->debugfs = debugfs_create_dir("hwsim",
 						   hw->wiphy->debugfsdir);
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 0e34260..28beeaf 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -905,16 +905,14 @@ static int mwl8k_rxq_init(struct ieee80211_hw *hw, int index)
 
 	rxq->rxd = pci_alloc_consistent(priv->pdev, size, &rxq->rxd_dma);
 	if (rxq->rxd == NULL) {
-		printk(KERN_ERR "%s: failed to alloc RX descriptors\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "failed to alloc rx descriptors\n");
 		return -ENOMEM;
 	}
 	memset(rxq->rxd, 0, size);
 
 	rxq->buf = kmalloc(MWL8K_RX_DESCS * sizeof(*rxq->buf), GFP_KERNEL);
 	if (rxq->buf == NULL) {
-		printk(KERN_ERR "%s: failed to alloc RX skbuff list\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "failed to alloc rx skbuff list\n");
 		pci_free_consistent(priv->pdev, size, rxq->rxd, rxq->rxd_dma);
 		return -ENOMEM;
 	}
@@ -1141,16 +1139,14 @@ static int mwl8k_txq_init(struct ieee80211_hw *hw, int index)
 
 	txq->txd = pci_alloc_consistent(priv->pdev, size, &txq->txd_dma);
 	if (txq->txd == NULL) {
-		printk(KERN_ERR "%s: failed to alloc TX descriptors\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "failed to alloc tx descriptors\n");
 		return -ENOMEM;
 	}
 	memset(txq->txd, 0, size);
 
 	txq->skb = kmalloc(MWL8K_TX_DESCS * sizeof(*txq->skb), GFP_KERNEL);
 	if (txq->skb == NULL) {
-		printk(KERN_ERR "%s: failed to alloc TX skbuff list\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "failed to alloc tx skbuff list\n");
 		pci_free_consistent(priv->pdev, size, txq->txd, txq->txd_dma);
 		return -ENOMEM;
 	}
@@ -1206,11 +1202,12 @@ static void mwl8k_dump_tx_rings(struct ieee80211_hw *hw)
 				unused++;
 		}
 
-		printk(KERN_ERR "%s: txq[%d] len=%d head=%d tail=%d "
-		       "fw_owned=%d drv_owned=%d unused=%d\n",
-		       wiphy_name(hw->wiphy), i,
-		       txq->len, txq->head, txq->tail,
-		       fw_owned, drv_owned, unused);
+		wiphy_err(hw->wiphy,
+			  "txq[%d] len=%d head=%d tail=%d "
+			  "fw_owned=%d drv_owned=%d unused=%d\n",
+			  i,
+			  txq->len, txq->head, txq->tail,
+			  fw_owned, drv_owned, unused);
 	}
 }
 
@@ -1254,25 +1251,23 @@ static int mwl8k_tx_wait_empty(struct ieee80211_hw *hw)
 		if (timeout) {
 			WARN_ON(priv->pending_tx_pkts);
 			if (retry) {
-				printk(KERN_NOTICE "%s: tx rings drained\n",
-				       wiphy_name(hw->wiphy));
+				wiphy_notice(hw->wiphy, "tx rings drained\n");
 			}
 			break;
 		}
 
 		if (priv->pending_tx_pkts < oldcount) {
-			printk(KERN_NOTICE "%s: waiting for tx rings "
-			       "to drain (%d -> %d pkts)\n",
-			       wiphy_name(hw->wiphy), oldcount,
-			       priv->pending_tx_pkts);
+			wiphy_notice(hw->wiphy,
+				     "waiting for tx rings to drain (%d -> %d pkts)\n",
+				     oldcount, priv->pending_tx_pkts);
 			retry = 1;
 			continue;
 		}
 
 		priv->tx_wait = NULL;
 
-		printk(KERN_ERR "%s: tx rings stuck for %d ms\n",
-		       wiphy_name(hw->wiphy), MWL8K_TX_WAIT_TIMEOUT_MS);
+		wiphy_err(hw->wiphy, "tx rings stuck for %d ms\n",
+			  MWL8K_TX_WAIT_TIMEOUT_MS);
 		mwl8k_dump_tx_rings(hw);
 
 		rc = -ETIMEDOUT;
@@ -1423,8 +1418,8 @@ mwl8k_txq_xmit(struct ieee80211_hw *hw, int index, struct sk_buff *skb)
 				skb->len, PCI_DMA_TODEVICE);
 
 	if (pci_dma_mapping_error(priv->pdev, dma)) {
-		printk(KERN_DEBUG "%s: failed to dma map skb, "
-		       "dropping TX frame.\n", wiphy_name(hw->wiphy));
+		wiphy_debug(hw->wiphy,
+			    "failed to dma map skb, dropping TX frame.\n");
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
@@ -1572,10 +1567,9 @@ static int mwl8k_post_cmd(struct ieee80211_hw *hw, struct mwl8k_cmd_pkt *cmd)
 					PCI_DMA_BIDIRECTIONAL);
 
 	if (!timeout) {
-		printk(KERN_ERR "%s: Command %s timeout after %u ms\n",
-		       wiphy_name(hw->wiphy),
-		       mwl8k_cmd_name(cmd->code, buf, sizeof(buf)),
-		       MWL8K_CMD_TIMEOUT_MS);
+		wiphy_err(hw->wiphy, "command %s timeout after %u ms\n",
+			  mwl8k_cmd_name(cmd->code, buf, sizeof(buf)),
+			  MWL8K_CMD_TIMEOUT_MS);
 		rc = -ETIMEDOUT;
 	} else {
 		int ms;
@@ -1584,15 +1578,14 @@ static int mwl8k_post_cmd(struct ieee80211_hw *hw, struct mwl8k_cmd_pkt *cmd)
 
 		rc = cmd->result ? -EINVAL : 0;
 		if (rc)
-			printk(KERN_ERR "%s: Command %s error 0x%x\n",
-			       wiphy_name(hw->wiphy),
-			       mwl8k_cmd_name(cmd->code, buf, sizeof(buf)),
-			       le16_to_cpu(cmd->result));
+			wiphy_err(hw->wiphy, "command %s error 0x%x\n",
+				  mwl8k_cmd_name(cmd->code, buf, sizeof(buf)),
+				  le16_to_cpu(cmd->result));
 		else if (ms > 2000)
-			printk(KERN_NOTICE "%s: Command %s took %d ms\n",
-			       wiphy_name(hw->wiphy),
-			       mwl8k_cmd_name(cmd->code, buf, sizeof(buf)),
-			       ms);
+			wiphy_notice(hw->wiphy, "command %s took %d ms\n",
+				     mwl8k_cmd_name(cmd->code,
+						    buf, sizeof(buf)),
+				     ms);
 	}
 
 	return rc;
@@ -3192,8 +3185,8 @@ static int mwl8k_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 	int rc;
 
 	if (!priv->radio_on) {
-		printk(KERN_DEBUG "%s: dropped TX frame since radio "
-		       "disabled\n", wiphy_name(hw->wiphy));
+		wiphy_debug(hw->wiphy,
+			    "dropped TX frame since radio disabled\n");
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
@@ -3211,8 +3204,7 @@ static int mwl8k_start(struct ieee80211_hw *hw)
 	rc = request_irq(priv->pdev->irq, mwl8k_interrupt,
 			 IRQF_SHARED, MWL8K_NAME, hw);
 	if (rc) {
-		printk(KERN_ERR "%s: failed to register IRQ handler\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "failed to register irq handler\n");
 		return -EIO;
 	}
 
@@ -3299,9 +3291,8 @@ static int mwl8k_add_interface(struct ieee80211_hw *hw,
 	 * mode.  (Sniffer mode is only used on STA firmware.)
 	 */
 	if (priv->sniffer_enabled) {
-		printk(KERN_INFO "%s: unable to create STA "
-		       "interface due to sniffer mode being enabled\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_info(hw->wiphy,
+			   "unable to create STA interface because sniffer mode is enabled\n");
 		return -EINVAL;
 	}
 
@@ -3583,9 +3574,8 @@ mwl8k_configure_filter_sniffer(struct ieee80211_hw *hw,
 	 */
 	if (!list_empty(&priv->vif_list)) {
 		if (net_ratelimit())
-			printk(KERN_INFO "%s: not enabling sniffer "
-			       "mode because STA interface is active\n",
-			       wiphy_name(hw->wiphy));
+			wiphy_info(hw->wiphy,
+				   "not enabling sniffer mode because STA interface is active\n");
 		return 0;
 	}
 
@@ -3913,8 +3903,7 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 
 	priv->sram = pci_iomap(pdev, 0, 0x10000);
 	if (priv->sram == NULL) {
-		printk(KERN_ERR "%s: Cannot map device SRAM\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "cannot map device sram\n");
 		goto err_iounmap;
 	}
 
@@ -3926,8 +3915,7 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 	if (priv->regs == NULL) {
 		priv->regs = pci_iomap(pdev, 2, 0x10000);
 		if (priv->regs == NULL) {
-			printk(KERN_ERR "%s: Cannot map device registers\n",
-			       wiphy_name(hw->wiphy));
+			wiphy_err(hw->wiphy, "cannot map device registers\n");
 			goto err_iounmap;
 		}
 	}
@@ -3939,16 +3927,14 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 	/* Ask userland hotplug daemon for the device firmware */
 	rc = mwl8k_request_firmware(priv);
 	if (rc) {
-		printk(KERN_ERR "%s: Firmware files not found\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "firmware files not found\n");
 		goto err_stop_firmware;
 	}
 
 	/* Load firmware into hardware */
 	rc = mwl8k_load_firmware(hw);
 	if (rc) {
-		printk(KERN_ERR "%s: Cannot start firmware\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "cannot start firmware\n");
 		goto err_stop_firmware;
 	}
 
@@ -3959,9 +3945,8 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 	if (priv->ap_fw) {
 		priv->rxd_ops = priv->device_info->ap_rxd_ops;
 		if (priv->rxd_ops == NULL) {
-			printk(KERN_ERR "%s: Driver does not have AP "
-			       "firmware image support for this hardware\n",
-			       wiphy_name(hw->wiphy));
+			wiphy_err(hw->wiphy,
+				  "Driver does not have AP firmware image support for this hardware\n");
 			goto err_stop_firmware;
 		}
 	} else {
@@ -4039,8 +4024,7 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 	rc = request_irq(priv->pdev->irq, mwl8k_interrupt,
 			 IRQF_SHARED, MWL8K_NAME, hw);
 	if (rc) {
-		printk(KERN_ERR "%s: failed to register IRQ handler\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "failed to register irq handler\n");
 		goto err_free_queues;
 	}
 
@@ -4060,8 +4044,7 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 		rc = mwl8k_cmd_get_hw_spec_sta(hw);
 	}
 	if (rc) {
-		printk(KERN_ERR "%s: Cannot initialise firmware\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "cannot initialise firmware\n");
 		goto err_free_irq;
 	}
 
@@ -4075,15 +4058,14 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 	/* Turn radio off */
 	rc = mwl8k_cmd_radio_disable(hw);
 	if (rc) {
-		printk(KERN_ERR "%s: Cannot disable\n", wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "cannot disable\n");
 		goto err_free_irq;
 	}
 
 	/* Clear MAC address */
 	rc = mwl8k_cmd_set_mac_addr(hw, NULL, "\x00\x00\x00\x00\x00\x00");
 	if (rc) {
-		printk(KERN_ERR "%s: Cannot clear MAC address\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "cannot clear mac address\n");
 		goto err_free_irq;
 	}
 
@@ -4093,17 +4075,16 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 
 	rc = ieee80211_register_hw(hw);
 	if (rc) {
-		printk(KERN_ERR "%s: Cannot register device\n",
-		       wiphy_name(hw->wiphy));
+		wiphy_err(hw->wiphy, "cannot register device\n");
 		goto err_free_queues;
 	}
 
-	printk(KERN_INFO "%s: %s v%d, %pM, %s firmware %u.%u.%u.%u\n",
-	       wiphy_name(hw->wiphy), priv->device_info->part_name,
-	       priv->hw_rev, hw->wiphy->perm_addr,
-	       priv->ap_fw ? "AP" : "STA",
-	       (priv->fw_rev >> 24) & 0xff, (priv->fw_rev >> 16) & 0xff,
-	       (priv->fw_rev >> 8) & 0xff, priv->fw_rev & 0xff);
+	wiphy_info(hw->wiphy, "%s v%d, %pm, %s firmware %u.%u.%u.%u\n",
+		   priv->device_info->part_name,
+		   priv->hw_rev, hw->wiphy->perm_addr,
+		   priv->ap_fw ? "AP" : "STA",
+		   (priv->fw_rev >> 24) & 0xff, (priv->fw_rev >> 16) & 0xff,
+		   (priv->fw_rev >> 8) & 0xff, priv->fw_rev & 0xff);
 
 	return 0;
 
diff --git a/drivers/net/wireless/orinoco/cfg.c b/drivers/net/wireless/orinoco/cfg.c
index 8c4169c..09fae2f 100644
--- a/drivers/net/wireless/orinoco/cfg.c
+++ b/drivers/net/wireless/orinoco/cfg.c
@@ -117,9 +117,8 @@ static int orinoco_change_vif(struct wiphy *wiphy, struct net_device *dev,
 
 	case NL80211_IFTYPE_MONITOR:
 		if (priv->broken_monitor && !force_monitor) {
-			printk(KERN_WARNING "%s: Monitor mode support is "
-			       "buggy in this firmware, not enabling\n",
-			       wiphy_name(wiphy));
+			wiphy_warn(wiphy,
+				   "Monitor mode support is buggy in this firmware, not enabling\n");
 			err = -EINVAL;
 		}
 		break;
diff --git a/drivers/net/wireless/p54/eeprom.c b/drivers/net/wireless/p54/eeprom.c
index e51650e..d687cb7 100644
--- a/drivers/net/wireless/p54/eeprom.c
+++ b/drivers/net/wireless/p54/eeprom.c
@@ -149,16 +149,15 @@ static int p54_generate_band(struct ieee80211_hw *dev,
 			continue;
 
 		if (list->channels[i].data != CHAN_HAS_ALL) {
-			printk(KERN_ERR "%s:%s%s%s is/are missing for "
-					"channel:%d [%d MHz].\n",
-			       wiphy_name(dev->wiphy),
-			       (list->channels[i].data & CHAN_HAS_CAL ? "" :
-				" [iqauto calibration data]"),
-			       (list->channels[i].data & CHAN_HAS_LIMIT ? "" :
-				" [output power limits]"),
-			       (list->channels[i].data & CHAN_HAS_CURVE ? "" :
-				" [curve data]"),
-			       list->channels[i].index, list->channels[i].freq);
+			wiphy_err(dev->wiphy,
+				  "%s%s%s is/are missing for channel:%d [%d MHz].\n",
+				  (list->channels[i].data & CHAN_HAS_CAL ? "" :
+				   " [iqauto calibration data]"),
+				  (list->channels[i].data & CHAN_HAS_LIMIT ? "" :
+				   " [output power limits]"),
+				  (list->channels[i].data & CHAN_HAS_CURVE ? "" :
+				   " [curve data]"),
+				  list->channels[i].index, list->channels[i].freq);
 			continue;
 		}
 
@@ -168,9 +167,8 @@ static int p54_generate_band(struct ieee80211_hw *dev,
 	}
 
 	if (j == 0) {
-		printk(KERN_ERR "%s: Disabling totally damaged %s band.\n",
-		       wiphy_name(dev->wiphy), (band == IEEE80211_BAND_2GHZ) ?
-		       "2 GHz" : "5 GHz");
+		wiphy_err(dev->wiphy, "disabling totally damaged %d GHz band\n",
+			  (band == IEEE80211_BAND_2GHZ) ? 2 : 5);
 
 		ret = -ENODATA;
 		goto err_out;
@@ -244,9 +242,9 @@ static int p54_generate_channel_lists(struct ieee80211_hw *dev)
 
 	if ((priv->iq_autocal_len != priv->curve_data->entries) ||
 	    (priv->iq_autocal_len != priv->output_limit->entries))
-		printk(KERN_ERR "%s: Unsupported or damaged EEPROM detected. "
-				"You may not be able to use all channels.\n",
-				wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy,
+			  "Unsupported or damaged EEPROM detected. "
+			  "You may not be able to use all channels.\n");
 
 	max_channel_num = max_t(unsigned int, priv->output_limit->entries,
 				priv->iq_autocal_len);
@@ -419,15 +417,14 @@ static void p54_parse_rssical(struct ieee80211_hw *dev, void *data, int len,
 	int i;
 
 	if (len != (entry_size * num_entries)) {
-		printk(KERN_ERR "%s: unknown rssi calibration data packing "
-				 " type:(%x) len:%d.\n",
-		       wiphy_name(dev->wiphy), type, len);
+		wiphy_err(dev->wiphy,
+			  "unknown rssi calibration data packing type:(%x) len:%d.\n",
+			  type, len);
 
 		print_hex_dump_bytes("rssical:", DUMP_PREFIX_NONE,
 				     data, len);
 
-		printk(KERN_ERR "%s: please report this issue.\n",
-			wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy, "please report this issue.\n");
 		return;
 	}
 
@@ -445,15 +442,14 @@ static void p54_parse_default_country(struct ieee80211_hw *dev,
 	struct pda_country *country;
 
 	if (len != sizeof(*country)) {
-		printk(KERN_ERR "%s: found possible invalid default country "
-				"eeprom entry. (entry size: %d)\n",
-		       wiphy_name(dev->wiphy), len);
+		wiphy_err(dev->wiphy,
+			  "found possible invalid default country eeprom entry. (entry size: %d)\n",
+			  len);
 
 		print_hex_dump_bytes("country:", DUMP_PREFIX_NONE,
 				     data, len);
 
-		printk(KERN_ERR "%s: please report this issue.\n",
-			wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy, "please report this issue.\n");
 		return;
 	}
 
@@ -478,8 +474,8 @@ static int p54_convert_output_limits(struct ieee80211_hw *dev,
 		return -EINVAL;
 
 	if (data[0] != 0) {
-		printk(KERN_ERR "%s: unknown output power db revision:%x\n",
-		       wiphy_name(dev->wiphy), data[0]);
+		wiphy_err(dev->wiphy, "unknown output power db revision:%x\n",
+			  data[0]);
 		return -EINVAL;
 	}
 
@@ -587,10 +583,9 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
 				err = p54_convert_rev1(dev, curve_data);
 				break;
 			default:
-				printk(KERN_ERR "%s: unknown curve data "
-						"revision %d\n",
-						wiphy_name(dev->wiphy),
-						curve_data->cal_method_rev);
+				wiphy_err(dev->wiphy,
+					  "unknown curve data revision %d\n",
+					  curve_data->cal_method_rev);
 				err = -ENODEV;
 				break;
 			}
@@ -672,8 +667,8 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
 
 	if (!synth || !priv->iq_autocal || !priv->output_limit ||
 	    !priv->curve_data) {
-		printk(KERN_ERR "%s: not all required entries found in eeprom!\n",
-			wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy,
+			  "not all required entries found in eeprom!\n");
 		err = -EINVAL;
 		goto err;
 	}
@@ -699,15 +694,15 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
 	if (!is_valid_ether_addr(dev->wiphy->perm_addr)) {
 		u8 perm_addr[ETH_ALEN];
 
-		printk(KERN_WARNING "%s: Invalid hwaddr! Using randomly generated MAC addr\n",
-			wiphy_name(dev->wiphy));
+		wiphy_warn(dev->wiphy,
+			   "invalid hwaddr! using randomly generated mac addr\n");
 		random_ether_addr(perm_addr);
 		SET_IEEE80211_PERM_ADDR(dev, perm_addr);
 	}
 
-	printk(KERN_INFO "%s: hwaddr %pM, MAC:isl38%02x RF:%s\n",
-		wiphy_name(dev->wiphy),	dev->wiphy->perm_addr, priv->version,
-		p54_rf_chips[priv->rxhw]);
+	wiphy_info(dev->wiphy, "hwaddr %pm, mac:isl38%02x rf:%s\n",
+		   dev->wiphy->perm_addr, priv->version,
+		   p54_rf_chips[priv->rxhw]);
 
 	return 0;
 
@@ -719,8 +714,7 @@ err:
 	priv->output_limit = NULL;
 	priv->curve_data = NULL;
 
-	printk(KERN_ERR "%s: eeprom parse failed!\n",
-		wiphy_name(dev->wiphy));
+	wiphy_err(dev->wiphy, "eeprom parse failed!\n");
 	return err;
 }
 EXPORT_SYMBOL_GPL(p54_parse_eeprom);
diff --git a/drivers/net/wireless/p54/fwio.c b/drivers/net/wireless/p54/fwio.c
index c43a5d4..47006bc 100644
--- a/drivers/net/wireless/p54/fwio.c
+++ b/drivers/net/wireless/p54/fwio.c
@@ -62,16 +62,15 @@ int p54_parse_firmware(struct ieee80211_hw *dev, const struct firmware *fw)
 			case FW_LM20:
 			case FW_LM87: {
 				char *iftype = (char *)bootrec->data;
-				printk(KERN_INFO "%s: p54 detected a LM%c%c "
-						 "firmware\n",
-					wiphy_name(priv->hw->wiphy),
-					iftype[2], iftype[3]);
+				wiphy_info(priv->hw->wiphy,
+					   "p54 detected a LM%c%c firmware\n",
+					   iftype[2], iftype[3]);
 				break;
 				}
 			case FW_FMAC:
 			default:
-				printk(KERN_ERR "%s: unsupported firmware\n",
-					wiphy_name(priv->hw->wiphy));
+				wiphy_err(priv->hw->wiphy,
+					  "unsupported firmware\n");
 				return -ENODEV;
 			}
 			break;
@@ -125,15 +124,15 @@ int p54_parse_firmware(struct ieee80211_hw *dev, const struct firmware *fw)
 	}
 
 	if (fw_version)
-		printk(KERN_INFO "%s: FW rev %s - Softmac protocol %x.%x\n",
-			wiphy_name(priv->hw->wiphy), fw_version,
-			priv->fw_var >> 8, priv->fw_var & 0xff);
+		wiphy_info(priv->hw->wiphy,
+			   "fw rev %s - softmac protocol %x.%x\n",
+			   fw_version, priv->fw_var >> 8, priv->fw_var & 0xff);
 
 	if (priv->fw_var < 0x500)
-		printk(KERN_INFO "%s: you are using an obsolete firmware. "
-		       "visit http://wireless.kernel.org/en/users/Drivers/p54 "
-		       "and grab one for \"kernel >= 2.6.28\"!\n",
-			wiphy_name(priv->hw->wiphy));
+		wiphy_info(priv->hw->wiphy,
+			   "you are using an obsolete firmware. "
+			   "visit http://wireless.kernel.org/en/users/Drivers/p54 "
+			   "and grab one for \"kernel >= 2.6.28\"!\n");
 
 	if (priv->fw_var >= 0x300) {
 		/* Firmware supports QoS, use it! */
@@ -152,13 +151,14 @@ int p54_parse_firmware(struct ieee80211_hw *dev, const struct firmware *fw)
 		priv->hw->queues = P54_QUEUE_AC_NUM;
 	}
 
-	printk(KERN_INFO "%s: cryptographic accelerator "
-	       "WEP:%s, TKIP:%s, CCMP:%s\n", wiphy_name(priv->hw->wiphy),
-		(priv->privacy_caps & BR_DESC_PRIV_CAP_WEP) ? "YES" :
-		"no", (priv->privacy_caps & (BR_DESC_PRIV_CAP_TKIP |
-		BR_DESC_PRIV_CAP_MICHAEL)) ? "YES" : "no",
-		(priv->privacy_caps & BR_DESC_PRIV_CAP_AESCCMP) ?
-		"YES" : "no");
+	wiphy_info(priv->hw->wiphy,
+		   "cryptographic accelerator WEP:%s, TKIP:%s, CCMP:%s\n",
+		   (priv->privacy_caps & BR_DESC_PRIV_CAP_WEP) ? "YES" : "no",
+		   (priv->privacy_caps &
+		    (BR_DESC_PRIV_CAP_TKIP | BR_DESC_PRIV_CAP_MICHAEL))
+		   ? "YES" : "no",
+		   (priv->privacy_caps & BR_DESC_PRIV_CAP_AESCCMP)
+		   ? "YES" : "no");
 
 	if (priv->rx_keycache_size) {
 		/*
@@ -247,8 +247,7 @@ int p54_download_eeprom(struct p54_common *priv, void *buf,
 
 	if (!wait_for_completion_interruptible_timeout(
 	     &priv->eeprom_comp, HZ)) {
-		printk(KERN_ERR "%s: device does not respond!\n",
-		       wiphy_name(priv->hw->wiphy));
+		wiphy_err(priv->hw->wiphy, "device does not respond!\n");
 		ret = -EBUSY;
 	}
 	priv->eeprom = NULL;
@@ -523,9 +522,9 @@ int p54_scan(struct p54_common *priv, u16 mode, u16 dwell)
 	return 0;
 
 err:
-	printk(KERN_ERR "%s: frequency change to channel %d failed.\n",
-	       wiphy_name(priv->hw->wiphy), ieee80211_frequency_to_channel(
-	       priv->hw->conf.channel->center_freq));
+	wiphy_err(priv->hw->wiphy, "frequency change to channel %d failed.\n",
+		  ieee80211_frequency_to_channel(
+			  priv->hw->conf.channel->center_freq));
 
 	dev_kfree_skb_any(skb);
 	return -EINVAL;
@@ -676,8 +675,8 @@ int p54_upload_key(struct p54_common *priv, u8 algo, int slot, u8 idx, u8 len,
 		break;
 
 	default:
-		printk(KERN_ERR "%s: invalid cryptographic algorithm: %d\n",
-		       wiphy_name(priv->hw->wiphy), algo);
+		wiphy_err(priv->hw->wiphy,
+			  "invalid cryptographic algorithm: %d\n", algo);
 		dev_kfree_skb(skb);
 		return -EINVAL;
 	}
diff --git a/drivers/net/wireless/p54/led.c b/drivers/net/wireless/p54/led.c
index 9575ac0..ea91f5c 100644
--- a/drivers/net/wireless/p54/led.c
+++ b/drivers/net/wireless/p54/led.c
@@ -57,8 +57,8 @@ static void p54_update_leds(struct work_struct *work)
 
 	err = p54_set_leds(priv);
 	if (err && net_ratelimit())
-		printk(KERN_ERR "%s: failed to update LEDs (%d).\n",
-			wiphy_name(priv->hw->wiphy), err);
+		wiphy_err(priv->hw->wiphy,
+			  "failed to update leds (%d).\n", err);
 
 	if (rerun)
 		ieee80211_queue_delayed_work(priv->hw, &priv->led_work,
@@ -102,8 +102,8 @@ static int p54_register_led(struct p54_common *priv,
 
 	err = led_classdev_register(wiphy_dev(priv->hw->wiphy), &led->led_dev);
 	if (err)
-		printk(KERN_ERR "%s: Failed to register %s LED.\n",
-			wiphy_name(priv->hw->wiphy), name);
+		wiphy_err(priv->hw->wiphy,
+			  "failed to register %s led.\n", name);
 	else
 		led->registered = 1;
 
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index a5ea89c..822f8dc 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -466,8 +466,7 @@ static int p54p_open(struct ieee80211_hw *dev)
 	P54P_READ(dev_int);
 
 	if (!wait_for_completion_interruptible_timeout(&priv->boot_comp, HZ)) {
-		printk(KERN_ERR "%s: Cannot boot firmware!\n",
-		       wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy, "cannot boot firmware!\n");
 		p54p_stop(dev);
 		return -ETIMEDOUT;
 	}
diff --git a/drivers/net/wireless/p54/txrx.c b/drivers/net/wireless/p54/txrx.c
index 4e68910..427b46f 100644
--- a/drivers/net/wireless/p54/txrx.c
+++ b/drivers/net/wireless/p54/txrx.c
@@ -38,8 +38,8 @@ static void p54_dump_tx_queue(struct p54_common *priv)
 	u32 largest_hole = 0, free;
 
 	spin_lock_irqsave(&priv->tx_queue.lock, flags);
-	printk(KERN_DEBUG "%s: / --- tx queue dump (%d entries) ---\n",
-	       wiphy_name(priv->hw->wiphy), skb_queue_len(&priv->tx_queue));
+	wiphy_debug(priv->hw->wiphy, "/ --- tx queue dump (%d entries) ---\n",
+		    skb_queue_len(&priv->tx_queue));
 
 	prev_addr = priv->rx_start;
 	skb_queue_walk(&priv->tx_queue, skb) {
@@ -48,21 +48,23 @@ static void p54_dump_tx_queue(struct p54_common *priv)
 		hdr = (void *) skb->data;
 
 		free = range->start_addr - prev_addr;
-		printk(KERN_DEBUG "%s: | [%02d] => [skb:%p skb_len:0x%04x "
-		       "hdr:{flags:%02x len:%04x req_id:%04x type:%02x} "
-		       "mem:{start:%04x end:%04x, free:%d}]\n",
-		       wiphy_name(priv->hw->wiphy), i++, skb, skb->len,
-		       le16_to_cpu(hdr->flags), le16_to_cpu(hdr->len),
-		       le32_to_cpu(hdr->req_id), le16_to_cpu(hdr->type),
-		       range->start_addr, range->end_addr, free);
+		wiphy_debug(priv->hw->wiphy,
+			    "| [%02d] => [skb:%p skb_len:0x%04x "
+			    "hdr:{flags:%02x len:%04x req_id:%04x type:%02x} "
+			    "mem:{start:%04x end:%04x, free:%d}]\n",
+			    i++, skb, skb->len,
+			    le16_to_cpu(hdr->flags), le16_to_cpu(hdr->len),
+			    le32_to_cpu(hdr->req_id), le16_to_cpu(hdr->type),
+			    range->start_addr, range->end_addr, free);
 
 		prev_addr = range->end_addr;
 		largest_hole = max(largest_hole, free);
 	}
 	free = priv->rx_end - prev_addr;
 	largest_hole = max(largest_hole, free);
-	printk(KERN_DEBUG "%s: \\ --- [free: %d], largest free block: %d ---\n",
-	       wiphy_name(priv->hw->wiphy), free, largest_hole);
+	wiphy_debug(priv->hw->wiphy,
+		    "\\ --- [free: %d], largest free block: %d ---\n",
+		    free, largest_hole);
 	spin_unlock_irqrestore(&priv->tx_queue.lock, flags);
 }
 #endif /* P54_MM_DEBUG */
@@ -538,8 +540,7 @@ static void p54_rx_trap(struct p54_common *priv, struct sk_buff *skb)
 	case P54_TRAP_BEACON_TX:
 		break;
 	case P54_TRAP_RADAR:
-		printk(KERN_INFO "%s: radar (freq:%d MHz)\n",
-			wiphy_name(priv->hw->wiphy), freq);
+		wiphy_info(priv->hw->wiphy, "radar (freq:%d mhz)\n", freq);
 		break;
 	case P54_TRAP_NO_BEACON:
 		if (priv->vif)
@@ -558,8 +559,8 @@ static void p54_rx_trap(struct p54_common *priv, struct sk_buff *skb)
 		wiphy_rfkill_set_hw_state(priv->hw->wiphy, false);
 		break;
 	default:
-		printk(KERN_INFO "%s: received event:%x freq:%d\n",
-		       wiphy_name(priv->hw->wiphy), event, freq);
+		wiphy_info(priv->hw->wiphy, "received event:%x freq:%d\n",
+			   event, freq);
 		break;
 	}
 }
@@ -584,8 +585,9 @@ static int p54_rx_control(struct p54_common *priv, struct sk_buff *skb)
 		p54_rx_eeprom_readback(priv, skb);
 		break;
 	default:
-		printk(KERN_DEBUG "%s: not handling 0x%02x type control frame\n",
-		       wiphy_name(priv->hw->wiphy), le16_to_cpu(hdr->type));
+		wiphy_debug(priv->hw->wiphy,
+			    "not handling 0x%02x type control frame\n",
+			    le16_to_cpu(hdr->type));
 		break;
 	}
 	return 0;
diff --git a/drivers/net/wireless/rtl818x/rtl8180_dev.c b/drivers/net/wireless/rtl818x/rtl8180_dev.c
index 31808f9..1601cfa 100644
--- a/drivers/net/wireless/rtl818x/rtl8180_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180_dev.c
@@ -357,7 +357,7 @@ static int rtl8180_init_hw(struct ieee80211_hw *dev)
 
 	/* check success of reset */
 	if (rtl818x_ioread8(priv, &priv->map->CMD) & RTL818X_CMD_RESET) {
-		printk(KERN_ERR "%s: reset timeout!\n", wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy, "reset timeout!\n");
 		return -ETIMEDOUT;
 	}
 
@@ -441,8 +441,7 @@ static int rtl8180_init_rx_ring(struct ieee80211_hw *dev)
 					     &priv->rx_ring_dma);
 
 	if (!priv->rx_ring || (unsigned long)priv->rx_ring & 0xFF) {
-		printk(KERN_ERR "%s: Cannot allocate RX ring\n",
-		       wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy, "cannot allocate rx ring\n");
 		return -ENOMEM;
 	}
 
@@ -499,8 +498,8 @@ static int rtl8180_init_tx_ring(struct ieee80211_hw *dev,
 
 	ring = pci_alloc_consistent(priv->pdev, sizeof(*ring) * entries, &dma);
 	if (!ring || (unsigned long)ring & 0xFF) {
-		printk(KERN_ERR "%s: Cannot allocate TX ring (prio = %d)\n",
-		       wiphy_name(dev->wiphy), prio);
+		wiphy_err(dev->wiphy, "cannot allocate tx ring (prio = %d)\n",
+			  prio);
 		return -ENOMEM;
 	}
 
@@ -565,8 +564,7 @@ static int rtl8180_start(struct ieee80211_hw *dev)
 	ret = request_irq(priv->pdev->irq, rtl8180_interrupt,
 			  IRQF_SHARED, KBUILD_MODNAME, dev);
 	if (ret) {
-		printk(KERN_ERR "%s: failed to register IRQ handler\n",
-		       wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy, "failed to register irq handler\n");
 		goto err_free_rings;
 	}
 
@@ -1103,9 +1101,8 @@ static int __devinit rtl8180_probe(struct pci_dev *pdev,
 		goto err_iounmap;
 	}
 
-	printk(KERN_INFO "%s: hwaddr %pM, %s + %s\n",
-	       wiphy_name(dev->wiphy), mac_addr,
-	       chip_name, priv->rf->name);
+	wiphy_info(dev->wiphy, "hwaddr %pm, %s + %s\n",
+		   mac_addr, chip_name, priv->rf->name);
 
 	return 0;
 
diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/wireless/rtl818x/rtl8187_dev.c
index 891b849..5738a55 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
@@ -573,7 +573,7 @@ static int rtl8187_cmd_reset(struct ieee80211_hw *dev)
 	} while (--i);
 
 	if (!i) {
-		printk(KERN_ERR "%s: Reset timeout!\n", wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy, "reset timeout!\n");
 		return -ETIMEDOUT;
 	}
 
@@ -589,8 +589,7 @@ static int rtl8187_cmd_reset(struct ieee80211_hw *dev)
 	} while (--i);
 
 	if (!i) {
-		printk(KERN_ERR "%s: eeprom reset timeout!\n",
-		       wiphy_name(dev->wiphy));
+		wiphy_err(dev->wiphy, "eeprom reset timeout!\n");
 		return -ETIMEDOUT;
 	}
 
@@ -1527,9 +1526,9 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 	mutex_init(&priv->conf_mutex);
 	skb_queue_head_init(&priv->b_tx_status.queue);
 
-	printk(KERN_INFO "%s: hwaddr %pM, %s V%d + %s, rfkill mask %d\n",
-	       wiphy_name(dev->wiphy), mac_addr,
-	       chip_name, priv->asic_rev, priv->rf->name, priv->rfkill_mask);
+	wiphy_info(dev->wiphy, "hwaddr %pm, %s v%d + %s, rfkill mask %d\n",
+		   mac_addr, chip_name, priv->asic_rev, priv->rf->name,
+		   priv->rfkill_mask);
 
 #ifdef CONFIG_RTL8187_LEDS
 	eeprom_93cx6_read(&eeprom, 0x3F, &reg);
diff --git a/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c b/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c
index a098193..fd96f91 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c
@@ -366,8 +366,8 @@ static void rtl8225_rf_init(struct ieee80211_hw *dev)
 		rtl8225_write(dev, 0x02, 0x044d);
 		msleep(100);
 		if (!(rtl8225_read(dev, 6) & (1 << 7)))
-			printk(KERN_WARNING "%s: RF Calibration Failed! %x\n",
-			       wiphy_name(dev->wiphy), rtl8225_read(dev, 6));
+			wiphy_warn(dev->wiphy, "rf calibration failed! %x\n",
+				   rtl8225_read(dev, 6));
 	}
 
 	rtl8225_write(dev, 0x0, 0x127);
@@ -735,8 +735,8 @@ static void rtl8225z2_rf_init(struct ieee80211_hw *dev)
 		rtl8225_write(dev, 0x02, 0x044D);
 		msleep(100);
 		if (!(rtl8225_read(dev, 6) & (1 << 7)))
-			printk(KERN_WARNING "%s: RF Calibration Failed! %x\n",
-			       wiphy_name(dev->wiphy), rtl8225_read(dev, 6));
+			wiphy_warn(dev->wiphy, "rf calibration failed! %x\n",
+				   rtl8225_read(dev, 6));
 	}
 
 	msleep(200);
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
