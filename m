From: David Decotigny <decot@google.com>
Subject: [PATCHv3 7/7] net/igb/e1000/e1000e: more robust ethtool duplex/speed configuration
Date: Wed, 27 Apr 2011 18:27:23 -0700
Message-ID: <1303954043-17440-8-git-send-email-decot__1512.76488691128$1303954181$gmane$org@google.com>
References: <1303954043-17440-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	mirq-linux@rere.qmqm.pl, Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyc
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:15480 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932441Ab1D1B2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 21:28:01 -0400
In-Reply-To: <1303954043-17440-1-git-send-email-decot@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes sure that one cannot request a 99Mbps full-duplex and
get a 100Mbps half-duplex configuration in return due to the way the
speed/duplex parameters are handled internally. Credits to Ben Hutchings
for spotting this.

Tested: e1000 works
Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/e1000/e1000.h         |    2 +-
 drivers/net/e1000/e1000_ethtool.c |    2 +-
 drivers/net/e1000/e1000_main.c    |   42 +++++++++++++++++++++---------------
 drivers/net/e1000e/ethtool.c      |   24 ++++++++++++++-------
 drivers/net/igb/igb.h             |    2 +-
 drivers/net/igb/igb_ethtool.c     |    2 +-
 drivers/net/igb/igb_main.c        |   23 +++++++++++++-------
 7 files changed, 59 insertions(+), 38 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index a881dd0..b1b23dd 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -349,7 +349,7 @@ extern int e1000_up(struct e1000_adapter *adapter);
 extern void e1000_down(struct e1000_adapter *adapter);
 extern void e1000_reinit_locked(struct e1000_adapter *adapter);
 extern void e1000_reset(struct e1000_adapter *adapter);
-extern int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx);
+extern int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx);
 extern int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
 extern int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
 extern void e1000_free_all_rx_resources(struct e1000_adapter *adapter);
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 127fef4..4fa727c 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -199,7 +199,7 @@ static int e1000_set_settings(struct net_device *netdev,
 		ecmd->advertising = hw->autoneg_advertised;
 	} else {
 		u32 speed = ethtool_cmd_speed(ecmd);
-		if (e1000_set_spd_dplx(adapter, speed + ecmd->duplex)) {
+		if (e1000_set_spd_dplx(adapter, speed, ecmd->duplex)) {
 			clear_bit(__E1000_RESETTING, &adapter->flags);
 			return -EINVAL;
 		}
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 477e066..c18cb8e 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -96,7 +96,6 @@ int e1000_up(struct e1000_adapter *adapter);
 void e1000_down(struct e1000_adapter *adapter);
 void e1000_reinit_locked(struct e1000_adapter *adapter);
 void e1000_reset(struct e1000_adapter *adapter);
-int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx);
 int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
 int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
 void e1000_free_all_tx_resources(struct e1000_adapter *adapter);
@@ -4385,7 +4384,6 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 	struct mii_ioctl_data *data = if_mii(ifr);
 	int retval;
 	u16 mii_reg;
-	u16 spddplx;
 	unsigned long flags;
 
 	if (hw->media_type != e1000_media_type_copper)
@@ -4424,17 +4422,18 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 					hw->autoneg = 1;
 					hw->autoneg_advertised = 0x2F;
 				} else {
+					u32 speed;
 					if (mii_reg & 0x40)
-						spddplx = SPEED_1000;
+						speed = SPEED_1000;
 					else if (mii_reg & 0x2000)
-						spddplx = SPEED_100;
+						speed = SPEED_100;
 					else
-						spddplx = SPEED_10;
-					spddplx += (mii_reg & 0x100)
-						   ? DUPLEX_FULL :
-						   DUPLEX_HALF;
-					retval = e1000_set_spd_dplx(adapter,
-								    spddplx);
+						speed = SPEED_10;
+					retval = e1000_set_spd_dplx(
+						adapter, speed,
+						((mii_reg & 0x100)
+						 ? DUPLEX_FULL :
+						 DUPLEX_HALF));
 					if (retval)
 						return retval;
 				}
@@ -4596,20 +4595,24 @@ static void e1000_restore_vlan(struct e1000_adapter *adapter)
 	}
 }
 
-int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
+int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
 {
 	struct e1000_hw *hw = &adapter->hw;
 
 	hw->autoneg = 0;
 
+	/* Make sure dplx is at most 1 bit and lsb of speed is not set
+	 * for the switch() below to work */
+	if ((spd & 1) || (dplx & ~1))
+		goto err_inval;
+
 	/* Fiber NICs only allow 1000 gbps Full duplex */
 	if ((hw->media_type == e1000_media_type_fiber) &&
-		spddplx != (SPEED_1000 + DUPLEX_FULL)) {
-		e_err(probe, "Unsupported Speed/Duplex configuration\n");
-		return -EINVAL;
-	}
+	    spd != SPEED_1000 &&
+	    dplx != DUPLEX_FULL)
+		goto err_inval;
 
-	switch (spddplx) {
+	switch (spd + dplx) {
 	case SPEED_10 + DUPLEX_HALF:
 		hw->forced_speed_duplex = e1000_10_half;
 		break;
@@ -4628,10 +4631,13 @@ int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
-		e_err(probe, "Unsupported Speed/Duplex configuration\n");
-		return -EINVAL;
+		goto err_inval;
 	}
 	return 0;
+
+err_inval:
+	e_err(probe, "Unsupported Speed/Duplex configuration\n");
+	return -EINVAL;
 }
 
 static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 12f1ee2..859d0d3 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -200,20 +200,25 @@ static int e1000_get_settings(struct net_device *netdev,
 	return 0;
 }
 
-static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
+static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
 {
 	struct e1000_mac_info *mac = &adapter->hw.mac;
 
 	mac->autoneg = 0;
 
+	/* Make sure dplx is at most 1 bit and lsb of speed is not set
+	 * for the switch() below to work */
+	if ((spd & 1) || (dplx & ~1))
+		goto err_inval;
+
 	/* Fiber NICs only allow 1000 gbps Full duplex */
 	if ((adapter->hw.phy.media_type == e1000_media_type_fiber) &&
-		spddplx != (SPEED_1000 + DUPLEX_FULL)) {
-		e_err("Unsupported Speed/Duplex configuration\n");
-		return -EINVAL;
+	    spd != SPEED_1000 &&
+	    dplx != DUPLEX_FULL) {
+		goto err_inval;
 	}
 
-	switch (spddplx) {
+	switch (spd + dplx) {
 	case SPEED_10 + DUPLEX_HALF:
 		mac->forced_speed_duplex = ADVERTISE_10_HALF;
 		break;
@@ -232,10 +237,13 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
-		e_err("Unsupported Speed/Duplex configuration\n");
-		return -EINVAL;
+		goto err_inval;
 	}
 	return 0;
+
+err_inval:
+	e_err("Unsupported Speed/Duplex configuration\n");
+	return -EINVAL;
 }
 
 static int e1000_set_settings(struct net_device *netdev,
@@ -272,7 +280,7 @@ static int e1000_set_settings(struct net_device *netdev,
 			hw->fc.requested_mode = e1000_fc_default;
 	} else {
 		u32 speed = ethtool_cmd_speed(ecmd);
-		if (e1000_set_spd_dplx(adapter, speed + ecmd->duplex)) {
+		if (e1000_set_spd_dplx(adapter, speed, ecmd->duplex)) {
 			clear_bit(__E1000_RESETTING, &adapter->state);
 			return -EINVAL;
 		}
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 1c687e2..f4fa4b1 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -360,7 +360,7 @@ extern int igb_up(struct igb_adapter *);
 extern void igb_down(struct igb_adapter *);
 extern void igb_reinit_locked(struct igb_adapter *);
 extern void igb_reset(struct igb_adapter *);
-extern int igb_set_spd_dplx(struct igb_adapter *, u16);
+extern int igb_set_spd_dplx(struct igb_adapter *, u32, u8);
 extern int igb_setup_tx_resources(struct igb_ring *);
 extern int igb_setup_rx_resources(struct igb_ring *);
 extern void igb_free_tx_resources(struct igb_ring *);
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 023aa9b..6e29634 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -224,7 +224,7 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 			hw->fc.requested_mode = e1000_fc_default;
 	} else {
 		u32 speed = ethtool_cmd_speed(ecmd);
-		if (igb_set_spd_dplx(adapter, speed + ecmd->duplex)) {
+		if (igb_set_spd_dplx(adapter, speed, ecmd->duplex)) {
 			clear_bit(__IGB_RESETTING, &adapter->state);
 			return -EINVAL;
 		}
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index cdfd572..ce7838e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -6349,21 +6349,25 @@ static void igb_restore_vlan(struct igb_adapter *adapter)
 	}
 }
 
-int igb_set_spd_dplx(struct igb_adapter *adapter, u16 spddplx)
+int igb_set_spd_dplx(struct igb_adapter *adapter, u32 spd, u8 dplx)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_mac_info *mac = &adapter->hw.mac;
 
 	mac->autoneg = 0;
 
+	/* Make sure dplx is at most 1 bit and lsb of speed is not set
+	 * for the switch() below to work */
+	if ((spd & 1) || (dplx & ~1))
+		goto err_inval;
+
 	/* Fiber NIC's only allow 1000 Gbps Full duplex */
 	if ((adapter->hw.phy.media_type == e1000_media_type_internal_serdes) &&
-		spddplx != (SPEED_1000 + DUPLEX_FULL)) {
-		dev_err(&pdev->dev, "Unsupported Speed/Duplex configuration\n");
-		return -EINVAL;
-	}
+	    spd != SPEED_1000 &&
+	    dplx != DUPLEX_FULL)
+		goto err_inval;
 
-	switch (spddplx) {
+	switch (spd + dplx) {
 	case SPEED_10 + DUPLEX_HALF:
 		mac->forced_speed_duplex = ADVERTISE_10_HALF;
 		break;
@@ -6382,10 +6386,13 @@ int igb_set_spd_dplx(struct igb_adapter *adapter, u16 spddplx)
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
-		dev_err(&pdev->dev, "Unsupported Speed/Duplex configuration\n");
-		return -EINVAL;
+		goto err_inval;
 	}
 	return 0;
+
+err_inval:
+	dev_err(&pdev->dev, "Unsupported Speed/Duplex configuration\n");
+	return -EINVAL;
 }
 
 static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake)
-- 
1.7.3.1

