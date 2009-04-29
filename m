From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/16] mdio: Add mdio45_ethtool_spauseparam_an()
Date: Wed, 29 Apr 2009 19:19:36 +0100
Message-ID: <1241029176.3246.62.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:60466 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754098AbZD2STh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:19:37 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements the ETHTOOL_SPAUSEPARAM operation for MDIO (clause 45)
PHYs with auto-negotiation MMDs.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/mdio.c   |   30 ++++++++++++++++++++++++++++++
 include/linux/mdio.h |    3 +++
 2 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index 0604a25..2fb0d16 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -275,6 +275,36 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 EXPORT_SYMBOL(mdio45_ethtool_gset_npage);
 
 /**
+ * mdio45_ethtool_spauseparam_an - set auto-negotiated pause parameters
+ * @mdio: MDIO interface
+ * @ecmd: Ethtool request structure
+ *
+ * This function assumes that the PHY has an auto-negotiation MMD.  It
+ * will enable and disable advertising of flow control as appropriate.
+ */
+void mdio45_ethtool_spauseparam_an(const struct mdio_if_info *mdio,
+				   const struct ethtool_pauseparam *ecmd)
+{
+	int adv, old_adv;
+
+	WARN_ON(!(mdio->mmds & MDIO_DEVS_AN));
+
+	old_adv = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_AN,
+				  MDIO_AN_ADVERTISE);
+	adv = old_adv & ~(ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
+	if (ecmd->autoneg)
+		adv |= mii_advertise_flowctrl(
+			(ecmd->rx_pause ? FLOW_CTRL_RX : 0) |
+			(ecmd->tx_pause ? FLOW_CTRL_TX : 0));
+	if (adv != old_adv) {
+		mdio->mdio_write(mdio->dev, mdio->prtad, MDIO_MMD_AN,
+				 MDIO_AN_ADVERTISE, adv);
+		mdio45_nway_restart(mdio);
+	}
+}
+EXPORT_SYMBOL(mdio45_ethtool_spauseparam_an);
+
+/**
  * mdio_mii_ioctl - MII ioctl interface for MDIO (clause 22 or 45) PHYs
  * @mdio: MDIO interface
  * @mii_data: MII ioctl data structure
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index ba41537..5645c0f 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -279,6 +279,9 @@ extern int mdio45_nway_restart(const struct mdio_if_info *mdio);
 extern void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 				      struct ethtool_cmd *ecmd,
 				      u32 npage_adv, u32 npage_lpa);
+extern void
+mdio45_ethtool_spauseparam_an(const struct mdio_if_info *mdio,
+			      const struct ethtool_pauseparam *ecmd);
 
 /**
  * mdio45_ethtool_gset - get settings for ETHTOOL_GSET

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

