From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 04/11] sfc: SFN4111T: Fix GPIO sharing between I2C and FLASH_CFG_1
Date: Fri, 30 Jan 2009 03:49:29 +0000
Message-ID: <20090130034928.GF15266@solarflare.com>
References: <20090129.170811.135213740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:33690 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754122AbZA3Dtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 22:49:31 -0500
Content-Disposition: inline
In-Reply-To: <20090129.170811.135213740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change sfn4111t_reset() to change only GPIO output enables so that it
doesn't break subsequent I2C operations.

Update comments to explain exactly what we're doing.

Add a short sleep to make sure the FLASH_CFG_1 value is latched before
any subsequent I2C operations.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/sfe4001.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index 16b80ac..c7c95db 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -186,19 +186,22 @@ static int sfn4111t_reset(struct efx_nic *efx)
 {
 	efx_oword_t reg;
 
-	/* GPIO pins are also used for I2C, so block that temporarily */
+	/* GPIO 3 and the GPIO register are shared with I2C, so block that */
 	mutex_lock(&efx->i2c_adap.bus_lock);
 
+	/* Pull RST_N (GPIO 2) low then let it up again, setting the
+	 * FLASH_CFG_1 strap (GPIO 3) appropriately.  Only change the
+	 * output enables; the output levels should always be 0 (low)
+	 * and we rely on external pull-ups. */
 	falcon_read(efx, &reg, GPIO_CTL_REG_KER);
 	EFX_SET_OWORD_FIELD(reg, GPIO2_OEN, true);
-	EFX_SET_OWORD_FIELD(reg, GPIO2_OUT, false);
 	falcon_write(efx, &reg, GPIO_CTL_REG_KER);
 	msleep(1000);
-	EFX_SET_OWORD_FIELD(reg, GPIO2_OUT, true);
-	EFX_SET_OWORD_FIELD(reg, GPIO3_OEN, true);
-	EFX_SET_OWORD_FIELD(reg, GPIO3_OUT,
-			    !(efx->phy_mode & PHY_MODE_SPECIAL));
+	EFX_SET_OWORD_FIELD(reg, GPIO2_OEN, false);
+	EFX_SET_OWORD_FIELD(reg, GPIO3_OEN,
+			    !!(efx->phy_mode & PHY_MODE_SPECIAL));
 	falcon_write(efx, &reg, GPIO_CTL_REG_KER);
+	msleep(1);
 
 	mutex_unlock(&efx->i2c_adap.bus_lock);
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
