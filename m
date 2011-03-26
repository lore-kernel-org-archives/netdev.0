From: Joe Perches <joe@perches.com>
Subject: [PATCH] smsc911x: Use pr_fmt, netdev_<level>, and netif_<level>
Date: Fri, 25 Mar 2011 17:21:22 -0700
Message-ID: <1301098883.4132.23.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeongtae Park <jtp.park@samsung.com>,
	netdev <netdev@vger.kernel.org>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4275 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932395Ab1CZAVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2011 20:21:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the more common/verbose logging styles.

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove smsc911x prefixes from format strings.
Rename SMSC_WARNING to SMSC_WARN.
Remove DPRINTK macro.
Use netif_<level> in SMSC_<level> macros.
Convert NETIF_MSG_<foo> uses to lower case.
Add no_printk verification in non-debug uses.
Add pdata to SMSC_<level> uses to avoid hidden variable uses.
Convert printks to netdev_<level> as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>

---

 drivers/net/smsc911x.c |  292 ++++++++++++++++++++++++------------------------
 drivers/net/smsc911x.h |   22 ++--
 2 files changed, 155 insertions(+), 159 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 1566259..5453b74 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -29,6 +29,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/crc32.h>
 #include <linux/delay.h>
 #include <linux/errno.h>
@@ -248,8 +250,8 @@ static int smsc911x_mac_complete(struct smsc911x_data *pdata)
 		if (!(val & MAC_CSR_CMD_CSR_BUSY_))
 			return 0;
 	}
-	SMSC_WARNING(HW, "Timed out waiting for MAC not BUSY. "
-		"MAC_CSR_CMD: 0x%08X", val);
+	SMSC_WARN(pdata, hw, "Timed out waiting for MAC not BUSY. "
+		  "MAC_CSR_CMD: 0x%08X", val);
 	return -EIO;
 }
 
@@ -262,7 +264,7 @@ static u32 smsc911x_mac_read(struct smsc911x_data *pdata, unsigned int offset)
 
 	temp = smsc911x_reg_read(pdata, MAC_CSR_CMD);
 	if (unlikely(temp & MAC_CSR_CMD_CSR_BUSY_)) {
-		SMSC_WARNING(HW, "MAC busy at entry");
+		SMSC_WARN(pdata, hw, "MAC busy at entry");
 		return 0xFFFFFFFF;
 	}
 
@@ -277,7 +279,7 @@ static u32 smsc911x_mac_read(struct smsc911x_data *pdata, unsigned int offset)
 	if (likely(smsc911x_mac_complete(pdata) == 0))
 		return smsc911x_reg_read(pdata, MAC_CSR_DATA);
 
-	SMSC_WARNING(HW, "MAC busy after read");
+	SMSC_WARN(pdata, hw, "MAC busy after read");
 	return 0xFFFFFFFF;
 }
 
@@ -291,8 +293,8 @@ static void smsc911x_mac_write(struct smsc911x_data *pdata,
 
 	temp = smsc911x_reg_read(pdata, MAC_CSR_CMD);
 	if (unlikely(temp & MAC_CSR_CMD_CSR_BUSY_)) {
-		SMSC_WARNING(HW,
-			"smsc911x_mac_write failed, MAC busy at entry");
+		SMSC_WARN(pdata, hw,
+			  "smsc911x_mac_write failed, MAC busy at entry");
 		return;
 	}
 
@@ -310,8 +312,7 @@ static void smsc911x_mac_write(struct smsc911x_data *pdata,
 	if (likely(smsc911x_mac_complete(pdata) == 0))
 		return;
 
-	SMSC_WARNING(HW,
-		"smsc911x_mac_write failed, MAC busy after write");
+	SMSC_WARN(pdata, hw, "smsc911x_mac_write failed, MAC busy after write");
 }
 
 /* Get a phy register */
@@ -326,8 +327,7 @@ static int smsc911x_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
 
 	/* Confirm MII not busy */
 	if (unlikely(smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_)) {
-		SMSC_WARNING(HW,
-			"MII is busy in smsc911x_mii_read???");
+		SMSC_WARN(pdata, hw, "MII is busy in smsc911x_mii_read???");
 		reg = -EIO;
 		goto out;
 	}
@@ -343,7 +343,7 @@ static int smsc911x_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
 			goto out;
 		}
 
-	SMSC_WARNING(HW, "Timed out waiting for MII read to finish");
+	SMSC_WARN(pdata, hw, "Timed out waiting for MII read to finish");
 	reg = -EIO;
 
 out:
@@ -364,8 +364,7 @@ static int smsc911x_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
 
 	/* Confirm MII not busy */
 	if (unlikely(smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_)) {
-		SMSC_WARNING(HW,
-			"MII is busy in smsc911x_mii_write???");
+		SMSC_WARN(pdata, hw, "MII is busy in smsc911x_mii_write???");
 		reg = -EIO;
 		goto out;
 	}
@@ -385,7 +384,7 @@ static int smsc911x_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
 			goto out;
 		}
 
-	SMSC_WARNING(HW, "Timed out waiting for MII write to finish");
+	SMSC_WARN(pdata, hw, "Timed out waiting for MII write to finish");
 	reg = -EIO;
 
 out:
@@ -426,18 +425,20 @@ static void smsc911x_phy_initialise_external(struct smsc911x_data *pdata)
 	unsigned int hwcfg = smsc911x_reg_read(pdata, HW_CFG);
 
 	if (pdata->config.flags & SMSC911X_FORCE_INTERNAL_PHY) {
-		SMSC_TRACE(HW, "Forcing internal PHY");
+		SMSC_TRACE(pdata, hw, "Forcing internal PHY");
 		pdata->using_extphy = 0;
 	} else if (pdata->config.flags & SMSC911X_FORCE_EXTERNAL_PHY) {
-		SMSC_TRACE(HW, "Forcing external PHY");
+		SMSC_TRACE(pdata, hw, "Forcing external PHY");
 		smsc911x_phy_enable_external(pdata);
 		pdata->using_extphy = 1;
 	} else if (hwcfg & HW_CFG_EXT_PHY_DET_) {
-		SMSC_TRACE(HW, "HW_CFG EXT_PHY_DET set, using external PHY");
+		SMSC_TRACE(pdata, hw,
+			   "HW_CFG EXT_PHY_DET set, using external PHY");
 		smsc911x_phy_enable_external(pdata);
 		pdata->using_extphy = 1;
 	} else {
-		SMSC_TRACE(HW, "HW_CFG EXT_PHY_DET clear, using internal PHY");
+		SMSC_TRACE(pdata, hw,
+			   "HW_CFG EXT_PHY_DET clear, using internal PHY");
 		pdata->using_extphy = 0;
 	}
 }
@@ -509,13 +510,13 @@ static int smsc911x_phy_check_loopbackpkt(struct smsc911x_data *pdata)
 		} while ((i--) && (!status));
 
 		if (!status) {
-			SMSC_WARNING(HW, "Failed to transmit "
-				"during loopback test");
+			SMSC_WARN(pdata, hw,
+				  "Failed to transmit during loopback test");
 			continue;
 		}
 		if (status & TX_STS_ES_) {
-			SMSC_WARNING(HW, "Transmit encountered "
-				"errors during loopback test");
+			SMSC_WARN(pdata, hw,
+				  "Transmit encountered errors during loopback test");
 			continue;
 		}
 
@@ -527,13 +528,13 @@ static int smsc911x_phy_check_loopbackpkt(struct smsc911x_data *pdata)
 		} while ((i--) && (!status));
 
 		if (!status) {
-			SMSC_WARNING(HW,
-				"Failed to receive during loopback test");
+			SMSC_WARN(pdata, hw,
+				  "Failed to receive during loopback test");
 			continue;
 		}
 		if (status & RX_STS_ES_) {
-			SMSC_WARNING(HW, "Receive encountered "
-				"errors during loopback test");
+			SMSC_WARN(pdata, hw,
+				  "Receive encountered errors during loopback test");
 			continue;
 		}
 
@@ -546,9 +547,9 @@ static int smsc911x_phy_check_loopbackpkt(struct smsc911x_data *pdata)
 		smsc911x_rx_readfifo(pdata, (unsigned int *)bufp, rdsz);
 
 		if (pktlength != (MIN_PACKET_SIZE + 4)) {
-			SMSC_WARNING(HW, "Unexpected packet size "
-				"during loop back test, size=%d, will retry",
-				pktlength);
+			SMSC_WARN(pdata, hw, "Unexpected packet size "
+				  "during loop back test, size=%d, will retry",
+				  pktlength);
 		} else {
 			unsigned int j;
 			int mismatch = 0;
@@ -560,12 +561,12 @@ static int smsc911x_phy_check_loopbackpkt(struct smsc911x_data *pdata)
 				}
 			}
 			if (!mismatch) {
-				SMSC_TRACE(HW, "Successfully verified "
+				SMSC_TRACE(pdata, hw, "Successfully verified "
 					   "loopback packet");
 				return 0;
 			} else {
-				SMSC_WARNING(HW, "Data mismatch "
-					"during loop back test, will retry");
+				SMSC_WARN(pdata, hw, "Data mismatch "
+					  "during loop back test, will retry");
 			}
 		}
 	}
@@ -582,7 +583,7 @@ static int smsc911x_phy_reset(struct smsc911x_data *pdata)
 	BUG_ON(!phy_dev);
 	BUG_ON(!phy_dev->bus);
 
-	SMSC_TRACE(HW, "Performing PHY BCR Reset");
+	SMSC_TRACE(pdata, hw, "Performing PHY BCR Reset");
 	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MII_BMCR, BMCR_RESET);
 	do {
 		msleep(1);
@@ -591,7 +592,7 @@ static int smsc911x_phy_reset(struct smsc911x_data *pdata)
 	} while ((i--) && (temp & BMCR_RESET));
 
 	if (temp & BMCR_RESET) {
-		SMSC_WARNING(HW, "PHY reset failed to complete.");
+		SMSC_WARN(pdata, hw, "PHY reset failed to complete");
 		return -EIO;
 	}
 	/* Extra delay required because the phy may not be completed with
@@ -695,11 +696,11 @@ static void smsc911x_phy_update_flowcontrol(struct smsc911x_data *pdata)
 		else
 			afc &= ~0xF;
 
-		SMSC_TRACE(HW, "rx pause %s, tx pause %s",
-			(cap & FLOW_CTRL_RX ? "enabled" : "disabled"),
-			(cap & FLOW_CTRL_TX ? "enabled" : "disabled"));
+		SMSC_TRACE(pdata, hw, "rx pause %s, tx pause %s",
+			   (cap & FLOW_CTRL_RX ? "enabled" : "disabled"),
+			   (cap & FLOW_CTRL_TX ? "enabled" : "disabled"));
 	} else {
-		SMSC_TRACE(HW, "half duplex");
+		SMSC_TRACE(pdata, hw, "half duplex");
 		flow = 0;
 		afc |= 0xF;
 	}
@@ -722,17 +723,17 @@ static void smsc911x_phy_adjust_link(struct net_device *dev)
 
 	if (phy_dev->duplex != pdata->last_duplex) {
 		unsigned int mac_cr;
-		SMSC_TRACE(HW, "duplex state has changed");
+		SMSC_TRACE(pdata, hw, "duplex state has changed");
 
 		spin_lock_irqsave(&pdata->mac_lock, flags);
 		mac_cr = smsc911x_mac_read(pdata, MAC_CR);
 		if (phy_dev->duplex) {
-			SMSC_TRACE(HW,
-				"configuring for full duplex mode");
+			SMSC_TRACE(pdata, hw,
+				   "configuring for full duplex mode");
 			mac_cr |= MAC_CR_FDPX_;
 		} else {
-			SMSC_TRACE(HW,
-				"configuring for half duplex mode");
+			SMSC_TRACE(pdata, hw,
+				   "configuring for half duplex mode");
 			mac_cr &= ~MAC_CR_FDPX_;
 		}
 		smsc911x_mac_write(pdata, MAC_CR, mac_cr);
@@ -744,9 +745,9 @@ static void smsc911x_phy_adjust_link(struct net_device *dev)
 
 	carrier = netif_carrier_ok(dev);
 	if (carrier != pdata->last_carrier) {
-		SMSC_TRACE(HW, "carrier state has changed");
+		SMSC_TRACE(pdata, hw, "carrier state has changed");
 		if (carrier) {
-			SMSC_TRACE(HW, "configuring for carrier OK");
+			SMSC_TRACE(pdata, hw, "configuring for carrier OK");
 			if ((pdata->gpio_orig_setting & GPIO_CFG_LED1_EN_) &&
 			    (!pdata->using_extphy)) {
 				/* Restore original GPIO configuration */
@@ -755,7 +756,7 @@ static void smsc911x_phy_adjust_link(struct net_device *dev)
 					pdata->gpio_setting);
 			}
 		} else {
-			SMSC_TRACE(HW, "configuring for no carrier");
+			SMSC_TRACE(pdata, hw, "configuring for no carrier");
 			/* Check global setting that LED1
 			 * usage is 10/100 indicator */
 			pdata->gpio_setting = smsc911x_reg_read(pdata,
@@ -787,25 +788,25 @@ static int smsc911x_mii_probe(struct net_device *dev)
 	/* find the first phy */
 	phydev = phy_find_first(pdata->mii_bus);
 	if (!phydev) {
-		pr_err("%s: no PHY found\n", dev->name);
+		netdev_err(dev, "no PHY found\n");
 		return -ENODEV;
 	}
 
-	SMSC_TRACE(PROBE, "PHY: addr %d, phy_id 0x%08X",
-			phydev->addr, phydev->phy_id);
+	SMSC_TRACE(pdata, probe, "PHY: addr %d, phy_id 0x%08X",
+		   phydev->addr, phydev->phy_id);
 
 	ret = phy_connect_direct(dev, phydev,
 			&smsc911x_phy_adjust_link, 0,
 			pdata->config.phy_interface);
 
 	if (ret) {
-		pr_err("%s: Could not attach to PHY\n", dev->name);
+		netdev_err(dev, "Could not attach to PHY\n");
 		return ret;
 	}
 
-	pr_info("%s: attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		dev->name, phydev->drv->name,
-		dev_name(&phydev->dev), phydev->irq);
+	netdev_info(dev,
+		    "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
+		    phydev->drv->name, dev_name(&phydev->dev), phydev->irq);
 
 	/* mask with MAC supported features */
 	phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
@@ -818,13 +819,13 @@ static int smsc911x_mii_probe(struct net_device *dev)
 
 #ifdef USE_PHY_WORK_AROUND
 	if (smsc911x_phy_loopbacktest(dev) < 0) {
-		SMSC_WARNING(HW, "Failed Loop Back Test");
+		SMSC_WARN(pdata, hw, "Failed Loop Back Test");
 		return -ENODEV;
 	}
-	SMSC_TRACE(HW, "Passed Loop Back Test");
+	SMSC_TRACE(pdata, hw, "Passed Loop Back Test");
 #endif				/* USE_PHY_WORK_AROUND */
 
-	SMSC_TRACE(HW, "phy initialised successfully");
+	SMSC_TRACE(pdata, hw, "phy initialised successfully");
 	return 0;
 }
 
@@ -860,8 +861,8 @@ static int __devinit smsc911x_mii_init(struct platform_device *pdev,
 		smsc911x_phy_initialise_external(pdata);
 		break;
 	default:
-		SMSC_TRACE(HW, "External PHY is not supported, "
-			"using internal PHY");
+		SMSC_TRACE(pdata, hw, "External PHY is not supported, "
+			   "using internal PHY");
 		pdata->using_extphy = 0;
 		break;
 	}
@@ -872,12 +873,12 @@ static int __devinit smsc911x_mii_init(struct platform_device *pdev,
 	}
 
 	if (mdiobus_register(pdata->mii_bus)) {
-		SMSC_WARNING(PROBE, "Error registering mii bus");
+		SMSC_WARN(pdata, probe, "Error registering mii bus");
 		goto err_out_free_bus_2;
 	}
 
 	if (smsc911x_mii_probe(dev) < 0) {
-		SMSC_WARNING(PROBE, "Error registering mii bus");
+		SMSC_WARN(pdata, probe, "Error registering mii bus");
 		goto err_out_unregister_bus_3;
 	}
 
@@ -913,8 +914,7 @@ static void smsc911x_tx_update_txcounters(struct net_device *dev)
 			 * does not reference a hardware defined reserved bit
 			 * but rather a driver defined one.
 			 */
-			SMSC_WARNING(HW,
-				"Packet tag reserved bit is high");
+			SMSC_WARN(pdata, hw, "Packet tag reserved bit is high");
 		} else {
 			if (unlikely(tx_stat & TX_STS_ES_)) {
 				dev->stats.tx_errors++;
@@ -977,8 +977,8 @@ smsc911x_rx_fastforward(struct smsc911x_data *pdata, unsigned int pktbytes)
 		} while ((val & RX_DP_CTRL_RX_FFWD_) && --timeout);
 
 		if (unlikely(timeout == 0))
-			SMSC_WARNING(HW, "Timed out waiting for "
-				"RX FFWD to finish, RX_DP_CTRL: 0x%08X", val);
+			SMSC_WARN(pdata, hw, "Timed out waiting for "
+				  "RX FFWD to finish, RX_DP_CTRL: 0x%08X", val);
 	} else {
 		unsigned int temp;
 		while (pktwords--)
@@ -1021,8 +1021,8 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
 		smsc911x_rx_counterrors(dev, rxstat);
 
 		if (unlikely(rxstat & RX_STS_ES_)) {
-			SMSC_WARNING(RX_ERR,
-				"Discarding packet with error bit set");
+			SMSC_WARN(pdata, rx_err,
+				  "Discarding packet with error bit set");
 			/* Packet has an error, discard it and continue with
 			 * the next */
 			smsc911x_rx_fastforward(pdata, pktwords);
@@ -1032,8 +1032,8 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
 
 		skb = netdev_alloc_skb(dev, pktlength + NET_IP_ALIGN);
 		if (unlikely(!skb)) {
-			SMSC_WARNING(RX_ERR,
-				"Unable to allocate skb for rx packet");
+			SMSC_WARN(pdata, rx_err,
+				  "Unable to allocate skb for rx packet");
 			/* Drop the packet and stop this polling iteration */
 			smsc911x_rx_fastforward(pdata, pktwords);
 			dev->stats.rx_dropped++;
@@ -1083,8 +1083,8 @@ static void smsc911x_rx_multicast_update(struct smsc911x_data *pdata)
 	smsc911x_mac_write(pdata, MAC_CR, mac_cr);
 	smsc911x_mac_write(pdata, HASHH, pdata->hashhi);
 	smsc911x_mac_write(pdata, HASHL, pdata->hashlo);
-	SMSC_TRACE(HW, "maccr 0x%08X, HASHH 0x%08X, HASHL 0x%08X",
-		mac_cr, pdata->hashhi, pdata->hashlo);
+	SMSC_TRACE(pdata, hw, "maccr 0x%08X, HASHH 0x%08X, HASHL 0x%08X",
+		   mac_cr, pdata->hashhi, pdata->hashlo);
 }
 
 static void smsc911x_rx_multicast_update_workaround(struct smsc911x_data *pdata)
@@ -1102,7 +1102,7 @@ static void smsc911x_rx_multicast_update_workaround(struct smsc911x_data *pdata)
 
 	/* Check Rx has stopped */
 	if (smsc911x_mac_read(pdata, MAC_CR) & MAC_CR_RXEN_)
-		SMSC_WARNING(DRV, "Rx not stopped");
+		SMSC_WARN(pdata, drv, "Rx not stopped");
 
 	/* Perform the update - safe to do now Rx has stopped */
 	smsc911x_rx_multicast_update(pdata);
@@ -1131,7 +1131,7 @@ static int smsc911x_soft_reset(struct smsc911x_data *pdata)
 	} while ((--timeout) && (temp & HW_CFG_SRST_));
 
 	if (unlikely(temp & HW_CFG_SRST_)) {
-		SMSC_WARNING(DRV, "Failed to complete reset");
+		SMSC_WARN(pdata, drv, "Failed to complete reset");
 		return -EIO;
 	}
 	return 0;
@@ -1160,18 +1160,18 @@ static int smsc911x_open(struct net_device *dev)
 
 	/* if the phy is not yet registered, retry later*/
 	if (!pdata->phy_dev) {
-		SMSC_WARNING(HW, "phy_dev is NULL");
+		SMSC_WARN(pdata, hw, "phy_dev is NULL");
 		return -EAGAIN;
 	}
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		SMSC_WARNING(HW, "dev_addr is not a valid MAC address");
+		SMSC_WARN(pdata, hw, "dev_addr is not a valid MAC address");
 		return -EADDRNOTAVAIL;
 	}
 
 	/* Reset the LAN911x */
 	if (smsc911x_soft_reset(pdata)) {
-		SMSC_WARNING(HW, "soft reset failed");
+		SMSC_WARN(pdata, hw, "soft reset failed");
 		return -EIO;
 	}
 
@@ -1191,8 +1191,8 @@ static int smsc911x_open(struct net_device *dev)
 	}
 
 	if (unlikely(timeout == 0))
-		SMSC_WARNING(IFUP,
-			"Timed out waiting for EEPROM busy bit to clear");
+		SMSC_WARN(pdata, ifup,
+			  "Timed out waiting for EEPROM busy bit to clear");
 
 	smsc911x_reg_write(pdata, GPIO_CFG, 0x70070000);
 
@@ -1210,22 +1210,22 @@ static int smsc911x_open(struct net_device *dev)
 	intcfg = ((10 << 24) | INT_CFG_IRQ_EN_);
 
 	if (pdata->config.irq_polarity) {
-		SMSC_TRACE(IFUP, "irq polarity: active high");
+		SMSC_TRACE(pdata, ifup, "irq polarity: active high");
 		intcfg |= INT_CFG_IRQ_POL_;
 	} else {
-		SMSC_TRACE(IFUP, "irq polarity: active low");
+		SMSC_TRACE(pdata, ifup, "irq polarity: active low");
 	}
 
 	if (pdata->config.irq_type) {
-		SMSC_TRACE(IFUP, "irq type: push-pull");
+		SMSC_TRACE(pdata, ifup, "irq type: push-pull");
 		intcfg |= INT_CFG_IRQ_TYPE_;
 	} else {
-		SMSC_TRACE(IFUP, "irq type: open drain");
+		SMSC_TRACE(pdata, ifup, "irq type: open drain");
 	}
 
 	smsc911x_reg_write(pdata, INT_CFG, intcfg);
 
-	SMSC_TRACE(IFUP, "Testing irq handler using IRQ %d", dev->irq);
+	SMSC_TRACE(pdata, ifup, "Testing irq handler using IRQ %d", dev->irq);
 	pdata->software_irq_signal = 0;
 	smp_wmb();
 
@@ -1241,14 +1241,15 @@ static int smsc911x_open(struct net_device *dev)
 	}
 
 	if (!pdata->software_irq_signal) {
-		dev_warn(&dev->dev, "ISR failed signaling test (IRQ %d)\n",
-			 dev->irq);
+		netdev_warn(dev, "ISR failed signaling test (IRQ %d)\n",
+			    dev->irq);
 		return -ENODEV;
 	}
-	SMSC_TRACE(IFUP, "IRQ handler passed test using IRQ %d", dev->irq);
+	SMSC_TRACE(pdata, ifup, "IRQ handler passed test using IRQ %d",
+		   dev->irq);
 
-	dev_info(&dev->dev, "SMSC911x/921x identified at %#08lx, IRQ: %d\n",
-		 (unsigned long)pdata->ioaddr, dev->irq);
+	netdev_info(dev, "SMSC911x/921x identified at %#08lx, IRQ: %d\n",
+		    (unsigned long)pdata->ioaddr, dev->irq);
 
 	/* Reset the last known duplex and carrier */
 	pdata->last_duplex = -1;
@@ -1313,7 +1314,7 @@ static int smsc911x_stop(struct net_device *dev)
 	if (pdata->phy_dev)
 		phy_stop(pdata->phy_dev);
 
-	SMSC_TRACE(IFDOWN, "Interface stopped");
+	SMSC_TRACE(pdata, ifdown, "Interface stopped");
 	return 0;
 }
 
@@ -1331,8 +1332,8 @@ static int smsc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	freespace = smsc911x_reg_read(pdata, TX_FIFO_INF) & TX_FIFO_INF_TDFREE_;
 
 	if (unlikely(freespace < TX_FIFO_LOW_THRESHOLD))
-		SMSC_WARNING(TX_ERR,
-			"Tx data fifo low, space available: %d", freespace);
+		SMSC_WARN(pdata, tx_err,
+			  "Tx data fifo low, space available: %d", freespace);
 
 	/* Word alignment adjustment */
 	tx_cmd_a = (u32)((ulong)skb->data & 0x03) << 16;
@@ -1432,7 +1433,7 @@ static void smsc911x_set_multicast_list(struct net_device *dev)
 		 * receiving data */
 		if (!pdata->multicast_update_pending) {
 			unsigned int temp;
-			SMSC_TRACE(HW, "scheduling mcast update");
+			SMSC_TRACE(pdata, hw, "scheduling mcast update");
 			pdata->multicast_update_pending = 1;
 
 			/* Request the hardware to stop, then perform the
@@ -1474,7 +1475,7 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
 	if (unlikely(intsts & inten & INT_STS_RXSTOP_INT_)) {
 		/* Called when there is a multicast update scheduled and
 		 * it is now safe to complete the update */
-		SMSC_TRACE(INTR, "RX Stop interrupt");
+		SMSC_TRACE(pdata, intr, "RX Stop interrupt");
 		smsc911x_reg_write(pdata, INT_STS, INT_STS_RXSTOP_INT_);
 		if (pdata->multicast_update_pending)
 			smsc911x_rx_multicast_update_workaround(pdata);
@@ -1491,7 +1492,7 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
 	}
 
 	if (unlikely(intsts & inten & INT_STS_RXE_)) {
-		SMSC_TRACE(INTR, "RX Error interrupt");
+		SMSC_TRACE(pdata, intr, "RX Error interrupt");
 		smsc911x_reg_write(pdata, INT_STS, INT_STS_RXE_);
 		serviced = IRQ_HANDLED;
 	}
@@ -1505,8 +1506,7 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
 			/* Schedule a NAPI poll */
 			__napi_schedule(&pdata->napi);
 		} else {
-			SMSC_WARNING(RX_ERR,
-				"napi_schedule_prep failed");
+			SMSC_WARN(pdata, rx_err, "napi_schedule_prep failed");
 		}
 		serviced = IRQ_HANDLED;
 	}
@@ -1543,7 +1543,7 @@ static int smsc911x_set_mac_address(struct net_device *dev, void *p)
 	smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
 	spin_unlock_irq(&pdata->mac_lock);
 
-	dev_info(&dev->dev, "MAC Address: %pM\n", dev->dev_addr);
+	netdev_info(dev, "MAC Address: %pM\n", dev->dev_addr);
 
 	return 0;
 }
@@ -1649,9 +1649,9 @@ static int smsc911x_eeprom_send_cmd(struct smsc911x_data *pdata, u32 op)
 	int timeout = 100;
 	u32 e2cmd;
 
-	SMSC_TRACE(DRV, "op 0x%08x", op);
+	SMSC_TRACE(pdata, drv, "op 0x%08x", op);
 	if (smsc911x_reg_read(pdata, E2P_CMD) & E2P_CMD_EPC_BUSY_) {
-		SMSC_WARNING(DRV, "Busy at start");
+		SMSC_WARN(pdata, drv, "Busy at start");
 		return -EBUSY;
 	}
 
@@ -1664,12 +1664,12 @@ static int smsc911x_eeprom_send_cmd(struct smsc911x_data *pdata, u32 op)
 	} while ((e2cmd & E2P_CMD_EPC_BUSY_) && (--timeout));
 
 	if (!timeout) {
-		SMSC_TRACE(DRV, "TIMED OUT");
+		SMSC_TRACE(pdata, drv, "TIMED OUT");
 		return -EAGAIN;
 	}
 
 	if (e2cmd & E2P_CMD_EPC_TIMEOUT_) {
-		SMSC_TRACE(DRV, "Error occured during eeprom operation");
+		SMSC_TRACE(pdata, drv, "Error occured during eeprom operation");
 		return -EINVAL;
 	}
 
@@ -1682,7 +1682,7 @@ static int smsc911x_eeprom_read_location(struct smsc911x_data *pdata,
 	u32 op = E2P_CMD_EPC_CMD_READ_ | address;
 	int ret;
 
-	SMSC_TRACE(DRV, "address 0x%x", address);
+	SMSC_TRACE(pdata, drv, "address 0x%x", address);
 	ret = smsc911x_eeprom_send_cmd(pdata, op);
 
 	if (!ret)
@@ -1698,7 +1698,7 @@ static int smsc911x_eeprom_write_location(struct smsc911x_data *pdata,
 	u32 temp;
 	int ret;
 
-	SMSC_TRACE(DRV, "address 0x%x, data 0x%x", address, data);
+	SMSC_TRACE(pdata, drv, "address 0x%x, data 0x%x", address, data);
 	ret = smsc911x_eeprom_send_cmd(pdata, op);
 
 	if (!ret) {
@@ -1811,25 +1811,25 @@ static int __devinit smsc911x_init(struct net_device *dev)
 	struct smsc911x_data *pdata = netdev_priv(dev);
 	unsigned int byte_test;
 
-	SMSC_TRACE(PROBE, "Driver Parameters:");
-	SMSC_TRACE(PROBE, "LAN base: 0x%08lX",
-		(unsigned long)pdata->ioaddr);
-	SMSC_TRACE(PROBE, "IRQ: %d", dev->irq);
-	SMSC_TRACE(PROBE, "PHY will be autodetected.");
+	SMSC_TRACE(pdata, probe, "Driver Parameters:");
+	SMSC_TRACE(pdata, probe, "LAN base: 0x%08lX",
+		   (unsigned long)pdata->ioaddr);
+	SMSC_TRACE(pdata, probe, "IRQ: %d", dev->irq);
+	SMSC_TRACE(pdata, probe, "PHY will be autodetected.");
 
 	spin_lock_init(&pdata->dev_lock);
 
 	if (pdata->ioaddr == 0) {
-		SMSC_WARNING(PROBE, "pdata->ioaddr: 0x00000000");
+		SMSC_WARN(pdata, probe, "pdata->ioaddr: 0x00000000");
 		return -ENODEV;
 	}
 
 	/* Check byte ordering */
 	byte_test = smsc911x_reg_read(pdata, BYTE_TEST);
-	SMSC_TRACE(PROBE, "BYTE_TEST: 0x%08X", byte_test);
+	SMSC_TRACE(pdata, probe, "BYTE_TEST: 0x%08X", byte_test);
 	if (byte_test == 0x43218765) {
-		SMSC_TRACE(PROBE, "BYTE_TEST looks swapped, "
-			"applying WORD_SWAP");
+		SMSC_TRACE(pdata, probe, "BYTE_TEST looks swapped, "
+			   "applying WORD_SWAP");
 		smsc911x_reg_write(pdata, WORD_SWAP, 0xffffffff);
 
 		/* 1 dummy read of BYTE_TEST is needed after a write to
@@ -1840,12 +1840,13 @@ static int __devinit smsc911x_init(struct net_device *dev)
 	}
 
 	if (byte_test != 0x87654321) {
-		SMSC_WARNING(DRV, "BYTE_TEST: 0x%08X", byte_test);
+		SMSC_WARN(pdata, drv, "BYTE_TEST: 0x%08X", byte_test);
 		if (((byte_test >> 16) & 0xFFFF) == (byte_test & 0xFFFF)) {
-			SMSC_WARNING(PROBE,
-				"top 16 bits equal to bottom 16 bits");
-			SMSC_TRACE(PROBE, "This may mean the chip is set "
-				"for 32 bit while the bus is reading 16 bit");
+			SMSC_WARN(pdata, probe,
+				  "top 16 bits equal to bottom 16 bits");
+			SMSC_TRACE(pdata, probe,
+				   "This may mean the chip is set "
+				   "for 32 bit while the bus is reading 16 bit");
 		}
 		return -ENODEV;
 	}
@@ -1880,17 +1881,18 @@ static int __devinit smsc911x_init(struct net_device *dev)
 		break;
 
 	default:
-		SMSC_WARNING(PROBE, "LAN911x not identified, idrev: 0x%08X",
-			pdata->idrev);
+		SMSC_WARN(pdata, probe, "LAN911x not identified, idrev: 0x%08X",
+			  pdata->idrev);
 		return -ENODEV;
 	}
 
-	SMSC_TRACE(PROBE, "LAN911x identified, idrev: 0x%08X, generation: %d",
-		pdata->idrev, pdata->generation);
+	SMSC_TRACE(pdata, probe,
+		   "LAN911x identified, idrev: 0x%08X, generation: %d",
+		   pdata->idrev, pdata->generation);
 
 	if (pdata->generation == 0)
-		SMSC_WARNING(PROBE,
-			"This driver is not intended for this chip revision");
+		SMSC_WARN(pdata, probe,
+			  "This driver is not intended for this chip revision");
 
 	/* workaround for platforms without an eeprom, where the mac address
 	 * is stored elsewhere and set by the bootloader.  This saves the
@@ -1927,7 +1929,7 @@ static int __devexit smsc911x_drv_remove(struct platform_device *pdev)
 	BUG_ON(!pdata->ioaddr);
 	BUG_ON(!pdata->phy_dev);
 
-	SMSC_TRACE(IFDOWN, "Stopping driver.");
+	SMSC_TRACE(pdata, ifdown, "Stopping driver");
 
 	phy_disconnect(pdata->phy_dev);
 	pdata->phy_dev = NULL;
@@ -1961,11 +1963,11 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	int res_size, irq_flags;
 	int retval;
 
-	pr_info("%s: Driver version %s.\n", SMSC_CHIPNAME, SMSC_DRV_VERSION);
+	pr_info("Driver version %s\n", SMSC_DRV_VERSION);
 
 	/* platform data specifies irq & dynamic bus configuration */
 	if (!pdev->dev.platform_data) {
-		pr_warning("%s: platform_data not provided\n", SMSC_CHIPNAME);
+		pr_warn("platform_data not provided\n");
 		retval = -ENODEV;
 		goto out_0;
 	}
@@ -1975,8 +1977,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	if (!res)
 		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!res) {
-		pr_warning("%s: Could not allocate resource.\n",
-			SMSC_CHIPNAME);
+		pr_warn("Could not allocate resource\n");
 		retval = -ENODEV;
 		goto out_0;
 	}
@@ -1984,8 +1985,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	if (!irq_res) {
-		pr_warning("%s: Could not allocate irq resource.\n",
-			SMSC_CHIPNAME);
+		pr_warn("Could not allocate irq resource\n");
 		retval = -ENODEV;
 		goto out_0;
 	}
@@ -1997,7 +1997,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	dev = alloc_etherdev(sizeof(struct smsc911x_data));
 	if (!dev) {
-		pr_warning("%s: Could not allocate device.\n", SMSC_CHIPNAME);
+		pr_warn("Could not allocate device\n");
 		retval = -ENOMEM;
 		goto out_release_io_1;
 	}
@@ -2017,8 +2017,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	pdata->msg_enable = ((1 << debug) - 1);
 
 	if (pdata->ioaddr == NULL) {
-		SMSC_WARNING(PROBE,
-			"Error smsc911x base address invalid");
+		SMSC_WARN(pdata, probe, "Error smsc911x base address invalid");
 		retval = -ENOMEM;
 		goto out_free_netdev_2;
 	}
@@ -2043,8 +2042,8 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	retval = request_irq(dev->irq, smsc911x_irqhandler,
 			     irq_flags | IRQF_SHARED, dev->name, dev);
 	if (retval) {
-		SMSC_WARNING(PROBE,
-			"Unable to claim requested irq: %d", dev->irq);
+		SMSC_WARN(pdata, probe,
+			  "Unable to claim requested irq: %d", dev->irq);
 		goto out_unmap_io_3;
 	}
 
@@ -2052,19 +2051,18 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	retval = register_netdev(dev);
 	if (retval) {
-		SMSC_WARNING(PROBE,
-			"Error %i registering device", retval);
+		SMSC_WARN(pdata, probe, "Error %i registering device", retval);
 		goto out_unset_drvdata_4;
 	} else {
-		SMSC_TRACE(PROBE, "Network interface: \"%s\"", dev->name);
+		SMSC_TRACE(pdata, probe,
+			   "Network interface: \"%s\"", dev->name);
 	}
 
 	spin_lock_init(&pdata->mac_lock);
 
 	retval = smsc911x_mii_init(pdev, dev);
 	if (retval) {
-		SMSC_WARNING(PROBE,
-			"Error %i initialising mii", retval);
+		SMSC_WARN(pdata, probe, "Error %i initialising mii", retval);
 		goto out_unregister_netdev_5;
 	}
 
@@ -2073,10 +2071,12 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 	/* Check if mac address has been specified when bringing interface up */
 	if (is_valid_ether_addr(dev->dev_addr)) {
 		smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
-		SMSC_TRACE(PROBE, "MAC Address is specified by configuration");
+		SMSC_TRACE(pdata, probe,
+			   "MAC Address is specified by configuration");
 	} else if (is_valid_ether_addr(pdata->config.mac)) {
 		memcpy(dev->dev_addr, pdata->config.mac, 6);
-		SMSC_TRACE(PROBE, "MAC Address specified by platform data");
+		SMSC_TRACE(pdata, probe,
+			   "MAC Address specified by platform data");
 	} else {
 		/* Try reading mac address from device. if EEPROM is present
 		 * it will already have been set */
@@ -2084,20 +2084,20 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 		if (is_valid_ether_addr(dev->dev_addr)) {
 			/* eeprom values are valid  so use them */
-			SMSC_TRACE(PROBE,
-				"Mac Address is read from LAN911x EEPROM");
+			SMSC_TRACE(pdata, probe,
+				   "Mac Address is read from LAN911x EEPROM");
 		} else {
 			/* eeprom values are invalid, generate random MAC */
 			random_ether_addr(dev->dev_addr);
 			smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
-			SMSC_TRACE(PROBE,
-				"MAC Address is set to random_ether_addr");
+			SMSC_TRACE(pdata, probe,
+				   "MAC Address is set to random_ether_addr");
 		}
 	}
 
 	spin_unlock_irq(&pdata->mac_lock);
 
-	dev_info(&dev->dev, "MAC Address: %pM\n", dev->dev_addr);
+	netdev_info(dev, "MAC Address: %pM\n", dev->dev_addr);
 
 	return 0;
 
diff --git a/drivers/net/smsc911x.h b/drivers/net/smsc911x.h
index 50f712e..8d67aac 100644
--- a/drivers/net/smsc911x.h
+++ b/drivers/net/smsc911x.h
@@ -33,25 +33,21 @@
  * can be successfully looped back */
 #define USE_PHY_WORK_AROUND
 
-#define DPRINTK(nlevel, klevel, fmt, args...) \
-	((void)((NETIF_MSG_##nlevel & pdata->msg_enable) && \
-	printk(KERN_##klevel "%s: %s: " fmt "\n", \
-	pdata->dev->name, __func__, ## args)))
-
 #if USE_DEBUG >= 1
-#define SMSC_WARNING(nlevel, fmt, args...) \
-	DPRINTK(nlevel, WARNING, fmt, ## args)
+#define SMSC_WARN(pdata, nlevel, fmt, args...)			\
+	netif_warn(pdata, nlevel, (pdata)->dev,			\
+		   "%s: " fmt "\n", __func__, ##args)
 #else
-#define SMSC_WARNING(nlevel, fmt, args...) \
-	({ do {} while (0); 0; })
+#define SMSC_WARN(pdata, nlevel, fmt, args...)			\
+	no_printk(fmt "\n", ##args)
 #endif
 
 #if USE_DEBUG >= 2
-#define SMSC_TRACE(nlevel, fmt, args...) \
-	DPRINTK(nlevel, INFO, fmt, ## args)
+#define SMSC_TRACE(pdata, nlevel, fmt, args...)			\
+	netif_info(pdata, nlevel, pdata->dev, fmt "\n", ##args)
 #else
-#define SMSC_TRACE(nlevel, fmt, args...) \
-	({ do {} while (0); 0; })
+#define SMSC_TRACE(pdata, nlevel, fmt, args...)			\
+	no_printk(fmt "\n", ##args)
 #endif
 
 #ifdef CONFIG_DEBUG_SPINLOCK


