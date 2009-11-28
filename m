From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/32] sfc: Replace MDIO spinlock with mutex
Date: Sat, 28 Nov 2009 03:44:33 +0000
Message-ID: <1259379873.2811.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42379 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840AbZK1Do3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:44:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

We never use MDIO in atomic context, so we don't need to spin.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    2 +-
 drivers/net/sfc/falcon.c     |   12 ++++++------
 drivers/net/sfc/net_driver.h |    4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index b5a7e91..6338ad8 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1922,7 +1922,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	/* Initialise common structures */
 	memset(efx, 0, sizeof(*efx));
 	spin_lock_init(&efx->biu_lock);
-	spin_lock_init(&efx->phy_lock);
+	mutex_init(&efx->mdio_lock);
 	mutex_init(&efx->spi_lock);
 	INIT_WORK(&efx->reset_work, efx_reset_work);
 	INIT_DELAYED_WORK(&efx->monitor_work, efx_monitor);
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index e16faad..372dbbc 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2110,7 +2110,7 @@ static int falcon_mdio_write(struct net_device *net_dev,
 	EFX_REGDUMP(efx, "writing MDIO %d register %d.%d with 0x%04x\n",
 		    prtad, devad, addr, value);
 
-	spin_lock_bh(&efx->phy_lock);
+	mutex_lock(&efx->mdio_lock);
 
 	/* Check MDIO not currently being accessed */
 	rc = falcon_gmii_wait(efx);
@@ -2145,8 +2145,8 @@ static int falcon_mdio_write(struct net_device *net_dev,
 		udelay(10);
 	}
 
- out:
-	spin_unlock_bh(&efx->phy_lock);
+out:
+	mutex_unlock(&efx->mdio_lock);
 	return rc;
 }
 
@@ -2158,7 +2158,7 @@ static int falcon_mdio_read(struct net_device *net_dev,
 	efx_oword_t reg;
 	int rc;
 
-	spin_lock_bh(&efx->phy_lock);
+	mutex_lock(&efx->mdio_lock);
 
 	/* Check MDIO not currently being accessed */
 	rc = falcon_gmii_wait(efx);
@@ -2194,8 +2194,8 @@ static int falcon_mdio_read(struct net_device *net_dev,
 			prtad, devad, addr, rc);
 	}
 
- out:
-	spin_unlock_bh(&efx->phy_lock);
+out:
+	mutex_unlock(&efx->mdio_lock);
 	return rc;
 }
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index fb9327c..0aeaeda 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -724,7 +724,7 @@ union efx_multicast_hash {
  * @mac_op: MAC interface
  * @mac_address: Permanent MAC address
  * @phy_type: PHY type
- * @phy_lock: PHY access lock
+ * @mdio_lock: MDIO lock
  * @phy_op: PHY interface
  * @phy_data: PHY private data (including PHY-specific stats)
  * @mdio: PHY MDIO interface
@@ -806,7 +806,7 @@ struct efx_nic {
 	unsigned char mac_address[ETH_ALEN];
 
 	enum phy_type phy_type;
-	spinlock_t phy_lock;
+	struct mutex mdio_lock;
 	struct efx_phy_operations *phy_op;
 	void *phy_data;
 	struct mdio_if_info mdio;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

