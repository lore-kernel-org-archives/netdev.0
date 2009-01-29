From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/20] sfc: Fix post-reset MAC selection
Date: Thu, 29 Jan 2009 19:19:09 +0000
Message-ID: <1233256749.3656.28.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:60352 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753068AbZA2TTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:19:12 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Modify falcon_switch_mac() to always set NIC_STAT_REG, even if the the
MAC is the same as it was before.  This ensures that the value is
correct after an online reset.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index ae7b0b4..d9412f8 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2283,16 +2283,12 @@ int falcon_switch_mac(struct efx_nic *efx)
 		efx->link_fd = true;
 	}
 
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
 	efx->mac_op = (EFX_IS10G(efx) ?
 		       &falcon_xmac_operations : &falcon_gmac_operations);
-	if (old_mac_op == efx->mac_op)
-		return 0;
-
-	WARN_ON(!mutex_is_locked(&efx->mac_lock));
-
-	/* Not all macs support a mac-level link state */
-	efx->mac_up = true;
 
+	/* Always push the NIC_STAT_REG setting even if the mac hasn't
+	 * changed, because this function is run post online reset */
 	falcon_read(efx, &nic_stat, NIC_STAT_REG);
 	strap_val = EFX_IS10G(efx) ? 5 : 3;
 	if (falcon_rev(efx) >= FALCON_REV_B0) {
@@ -2305,8 +2301,13 @@ int falcon_switch_mac(struct efx_nic *efx)
 		BUG_ON(EFX_OWORD_FIELD(nic_stat, STRAP_PINS) != strap_val);
 	}
 
+	if (old_mac_op == efx->mac_op)
+		return 0;
 
 	EFX_LOG(efx, "selected %cMAC\n", EFX_IS10G(efx) ? 'X' : 'G');
+	/* Not all macs support a mac-level link state */
+	efx->mac_up = true;
+
 	return falcon_reset_macs(efx);
 }
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

