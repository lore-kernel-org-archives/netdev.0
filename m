From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/16] sfc: Hold MAC lock for longer in efx_init_port()
Date: Thu, 26 Nov 2009 02:11:19 +0000
Message-ID: <1259201479.2806.23.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31287 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbZKZCLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:11:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although efx_init_port() is only called at probe time and so cannot
race with port reconfiguration, most of the functions it calls can
expect to be called with the MAC lock held.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 4ebad61..155aa1c 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -737,23 +737,27 @@ static int efx_init_port(struct efx_nic *efx)
 
 	EFX_LOG(efx, "init port\n");
 
+	mutex_lock(&efx->mac_lock);
+
 	rc = efx->phy_op->init(efx);
 	if (rc)
-		return rc;
-	mutex_lock(&efx->mac_lock);
+		goto fail1;
 	efx->phy_op->reconfigure(efx);
 	rc = falcon_switch_mac(efx);
-	mutex_unlock(&efx->mac_lock);
 	if (rc)
-		goto fail;
+		goto fail2;
 	efx->mac_op->reconfigure(efx);
 
 	efx->port_initialized = true;
 	efx_stats_enable(efx);
+
+	mutex_unlock(&efx->mac_lock);
 	return 0;
 
-fail:
+fail2:
 	efx->phy_op->fini(efx);
+fail1:
+	mutex_unlock(&efx->mac_lock);
 	return rc;
 }
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

