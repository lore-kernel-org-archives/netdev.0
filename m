From: Kumar Gala <galak@kernel.crashing.org>
Subject: RFC: Provide setting of Link Partner Autonegotiation
Date: Sat, 20 Jan 2007 16:49:29 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0701201644490.17790@gate.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36493 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750771AbXATWtc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jan 2007 17:49:32 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's the start of a patch to provide the state of the link partner's 
autoneg.  This is useful to know if the link partner is trying to force a 
speed and we aren't matching.

I wasn't sure how to handle this for all the drivers that handle phy's 
themselves.  Is there some way to have this set to a 'not supported value' 
in ethtool_get_settings and leave it to the driver specific function to 
modify it?

I'll followup with an ethtool patch once we figure out the kernel side.

- kumar

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index e175f39..77694d5 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -299,6 +299,7 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
  	cmd->phy_address = phydev->addr;
  	cmd->transceiver = XCVR_EXTERNAL;
  	cmd->autoneg = phydev->autoneg;
+	cmd->lp_autoneg = phydev->link_partner_autoneg;

  	return 0;
  }
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index a4d7529..a7137c8 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -62,6 +62,7 @@ struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
  	dev->interface = PHY_INTERFACE_MODE_GMII;

  	dev->autoneg = AUTONEG_ENABLE;
+	dev->link_partner_autoneg = AUTONEG_ENABLE;

  	dev->addr = addr;
  	dev->phy_id = phy_id;
@@ -441,6 +442,16 @@ int genphy_update_link(struct phy_device *phydev)
  	else
  		phydev->link = 1;

+	/* Read Auto-Negotiation Expansion */
+	status = phy_read(phydev, MII_EXPANSION);
+	if (status < 0)
+		return status;
+
+	if (status & EXPANSION_NWAY)
+		phydev->link_partner_autoneg = AUTONEG_ENABLE;
+	else
+		phydev->link_partner_autoneg = AUTONEG_DISABLE;
+
  	return 0;
  }
  EXPORT_SYMBOL(genphy_update_link);
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c6310ae..18b0b17 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -26,7 +26,8 @@ struct ethtool_cmd {
  	__u8	autoneg;	/* Enable or disable autonegotiation */
  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
-	__u32	reserved[4];
+	__u32	lp_autoneg;	/* Link partner's ability for autonegotiation */
+	__u32	reserved[3];
  };

  #define ETHTOOL_BUSINFO_LEN	32
diff --git a/include/linux/phy.h b/include/linux/phy.h
index edd4c88..f91a9c0 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -269,6 +269,8 @@ struct phy_device {

  	int link_timeout;

+	int link_partner_autoneg;
+
  	/* Interrupt number for this PHY
  	 * -1 means no interrupt */
  	int irq;
