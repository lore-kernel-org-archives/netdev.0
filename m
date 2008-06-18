From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: I2C adapter initialisation fixes
Date: Wed, 18 Jun 2008 11:58:41 +0100
Message-ID: <20080618105839.GL5350@solarflare.com>
References: <cover.1213035602.git.bhutchings@solarflare.com> <20080609182509.GJ11300@solarflare.com> <485885A7.5060409@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean Delvare <khali@linux-fr.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.mbr-roch.zen.net.uk ([212.23.3.142]:39250 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752238AbYFRK6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 06:58:48 -0400
Content-Disposition: inline
In-Reply-To: <485885A7.5060409@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As recommended by Jean Delvare:
- Increase timeout to 50 ms
- Leave adapter class clear so that unwanted drivers do not probe our bus
- Use strlcpy() for name initialisation

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 630406e..9138ee5 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -223,13 +223,8 @@ static struct i2c_algo_bit_data falcon_i2c_bit_operations = {
 	.getsda		= falcon_getsda,
 	.getscl		= falcon_getscl,
 	.udelay		= 5,
-	/*
-	 * This is the number of system clock ticks after which
-	 * i2c-algo-bit gives up waiting for SCL to become high.
-	 * It must be at least 2 since the first tick can happen
-	 * immediately after it starts waiting.
-	 */
-	.timeout	= 2,
+	/* Wait up to 50 ms for slave to let us pull SCL high */
+	.timeout	= DIV_ROUND_UP(HZ, 20),
 };
 
 /**************************************************************************
@@ -2479,12 +2474,11 @@ int falcon_probe_nic(struct efx_nic *efx)
 
 	/* Initialise I2C adapter */
  	efx->i2c_adap.owner = THIS_MODULE;
- 	efx->i2c_adap.class = I2C_CLASS_HWMON;
 	nic_data->i2c_data = falcon_i2c_bit_operations;
 	nic_data->i2c_data.data = efx;
  	efx->i2c_adap.algo_data = &nic_data->i2c_data;
 	efx->i2c_adap.dev.parent = &efx->pci_dev->dev;
-	strcpy(efx->i2c_adap.name, "SFC4000 GPIO");
+	strlcpy(efx->i2c_adap.name, "SFC4000 GPIO", sizeof(efx->i2c_adap.name));
 	rc = i2c_bit_add_bus(&efx->i2c_adap);
 	if (rc)
 		goto fail5;
---

I've corrected the comment about what timeout means.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
