From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 11/17] sfc: Move mdio_lock to struct
 falcon_nic_data
Date: Thu, 02 Dec 2010 23:47:35 +0000
Message-ID: <1291333655.3259.34.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13095 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932322Ab0LBXri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:47:38 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only have direct access to MDIO on Falcon, so move this out of
struct efx_nic.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    1 -
 drivers/net/sfc/falcon.c     |   11 +++++++----
 drivers/net/sfc/net_driver.h |    2 --
 drivers/net/sfc/nic.h        |    2 ++
 4 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 6aed6ac..7e820d9 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2198,7 +2198,6 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	/* Initialise common structures */
 	memset(efx, 0, sizeof(*efx));
 	spin_lock_init(&efx->biu_lock);
-	mutex_init(&efx->mdio_lock);
 #ifdef CONFIG_SFC_MTD
 	INIT_LIST_HEAD(&efx->mtd_list);
 #endif
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index ca59f7e..af62899 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -717,6 +717,7 @@ static int falcon_mdio_write(struct net_device *net_dev,
 			     int prtad, int devad, u16 addr, u16 value)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
+	struct falcon_nic_data *nic_data = efx->nic_data;
 	efx_oword_t reg;
 	int rc;
 
@@ -724,7 +725,7 @@ static int falcon_mdio_write(struct net_device *net_dev,
 		   "writing MDIO %d register %d.%d with 0x%04x\n",
 		    prtad, devad, addr, value);
 
-	mutex_lock(&efx->mdio_lock);
+	mutex_lock(&nic_data->mdio_lock);
 
 	/* Check MDIO not currently being accessed */
 	rc = falcon_gmii_wait(efx);
@@ -760,7 +761,7 @@ static int falcon_mdio_write(struct net_device *net_dev,
 	}
 
 out:
-	mutex_unlock(&efx->mdio_lock);
+	mutex_unlock(&nic_data->mdio_lock);
 	return rc;
 }
 
@@ -769,10 +770,11 @@ static int falcon_mdio_read(struct net_device *net_dev,
 			    int prtad, int devad, u16 addr)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
+	struct falcon_nic_data *nic_data = efx->nic_data;
 	efx_oword_t reg;
 	int rc;
 
-	mutex_lock(&efx->mdio_lock);
+	mutex_lock(&nic_data->mdio_lock);
 
 	/* Check MDIO not currently being accessed */
 	rc = falcon_gmii_wait(efx);
@@ -811,7 +813,7 @@ static int falcon_mdio_read(struct net_device *net_dev,
 	}
 
 out:
-	mutex_unlock(&efx->mdio_lock);
+	mutex_unlock(&nic_data->mdio_lock);
 	return rc;
 }
 
@@ -839,6 +841,7 @@ static int falcon_probe_port(struct efx_nic *efx)
 	}
 
 	/* Fill out MDIO structure and loopback modes */
+	mutex_init(&nic_data->mdio_lock);
 	efx->mdio.mdio_read = falcon_mdio_read;
 	efx->mdio.mdio_write = falcon_mdio_write;
 	rc = efx->phy_op->probe(efx);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index e5ee2d5..2ffc920 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -679,7 +679,6 @@ struct efx_filter_state;
  * @mac_op: MAC interface
  * @mac_address: Permanent MAC address
  * @phy_type: PHY type
- * @mdio_lock: MDIO lock
  * @phy_op: PHY interface
  * @phy_data: PHY private data (including PHY-specific stats)
  * @mdio: PHY MDIO interface
@@ -766,7 +765,6 @@ struct efx_nic {
 	unsigned char mac_address[ETH_ALEN];
 
 	unsigned int phy_type;
-	struct mutex mdio_lock;
 	struct efx_phy_operations *phy_op;
 	void *phy_data;
 	struct mdio_if_info mdio;
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 2a0fff3..980cf4b 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -117,6 +117,7 @@ struct falcon_board {
  * @spi_flash: SPI flash device
  * @spi_eeprom: SPI EEPROM device
  * @spi_lock: SPI bus lock
+ * @mdio_lock: MDIO bus lock
  */
 struct falcon_nic_data {
 	struct pci_dev *pci_dev2;
@@ -128,6 +129,7 @@ struct falcon_nic_data {
 	struct efx_spi_device spi_flash;
 	struct efx_spi_device spi_eeprom;
 	struct mutex spi_lock;
+	struct mutex mdio_lock;
 };
 
 static inline struct falcon_board *falcon_board(struct efx_nic *efx)
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

