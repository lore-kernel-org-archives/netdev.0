From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 28/33] sfc: Use mutex_lock_interruptible() for ethtool EEPROM access
Date: Fri, 12 Dec 2008 12:59:23 +0000
Message-ID: <20081212125922.GB10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:48412 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758005AbYLLM7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:59:25 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool must contend with the MTD driver for the SPI bus lock, which
may carry out long operations such as flash erase.  Allow it to be
interrupted while waiting.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index eab3e5c..3aaece6 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -568,10 +568,13 @@ static int efx_ethtool_get_eeprom(struct net_device *net_dev,
 	size_t len;
 	int rc;
 
-	mutex_lock(&efx->spi_lock);
+	rc = mutex_lock_interruptible(&efx->spi_lock);
+	if (rc)
+		return rc;
 	rc = falcon_spi_read(spi, eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
 			     eeprom->len, &len, buf);
 	mutex_unlock(&efx->spi_lock);
+
 	eeprom->magic = EFX_ETHTOOL_EEPROM_MAGIC;
 	eeprom->len = len;
 	return rc;
@@ -588,10 +591,13 @@ static int efx_ethtool_set_eeprom(struct net_device *net_dev,
 	if (eeprom->magic != EFX_ETHTOOL_EEPROM_MAGIC)
 		return -EINVAL;
 
-	mutex_lock(&efx->spi_lock);
+	rc = mutex_lock_interruptible(&efx->spi_lock);
+	if (rc)
+		return rc;
 	rc = falcon_spi_write(spi, eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
 			      eeprom->len, &len, buf);
 	mutex_unlock(&efx->spi_lock);
+
 	eeprom->len = len;
 	return rc;
 }
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
