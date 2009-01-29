From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/20] sfc: SFN4111T: Fix GPIO sharing between I2C and
	FLASH_CFG_1
Date: Thu, 29 Jan 2009 19:18:05 +0000
Message-ID: <1233256685.3656.25.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:58322 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752268AbZA2TSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:18:08 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
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
index 2e9b4b4..95bb935 100644
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

