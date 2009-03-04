From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/7] sfc: Clean up properly on reset failure paths
Date: Wed, 04 Mar 2009 19:52:52 +0000
Message-ID: <1236196372.3140.19.camel@achroite>
References: <1236196272.3140.15.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:52575 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755919AbZCDTw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 14:52:58 -0500
In-Reply-To: <1236196272.3140.15.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If MAC switching fails, stop the port properly.

If PHY reinitialisation fails, clear the port_initialized flag.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 45df110..8fa68d8 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -557,6 +557,8 @@ static void efx_link_status_changed(struct efx_nic *efx)
 
 }
 
+static void efx_fini_port(struct efx_nic *efx);
+
 /* This call reinitialises the MAC to pick up new PHY settings. The
  * caller must hold the mac_lock */
 void __efx_reconfigure_port(struct efx_nic *efx)
@@ -592,8 +594,8 @@ void __efx_reconfigure_port(struct efx_nic *efx)
 
 fail:
 	EFX_ERR(efx, "failed to reconfigure MAC\n");
-	efx->phy_op->fini(efx);
-	efx->port_initialized = false;
+	efx->port_enabled = false;
+	efx_fini_port(efx);
 }
 
 /* Reinitialise the MAC to pick up new PHY settings, even if the port is
@@ -1667,7 +1669,8 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method,
 			rc = efx->phy_op->init(efx);
 			if (rc)
 				ok = false;
-		} else
+		}
+		if (!ok)
 			efx->port_initialized = false;
 	}
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

