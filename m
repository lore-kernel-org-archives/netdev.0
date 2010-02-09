From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] sfc: Fix SFE4002 initialisation
Date: Tue, 09 Feb 2010 15:52:57 +0000
Message-ID: <1265730777.2126.110.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52334 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411Ab0BIPxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 10:53:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Commit 357d46a17e54c9a87e0e6ef3930ff4ab2d232b81 "sfc: QT202x: Remove
unreliable MMD check at initialisation" broke initialisation of the
SFE4002.  efx_mdio_reset_mmd() returns a positive value rather than 0
on success.  The above commit causes this value to be propagated up
by qt202x_reset_phy(), which is treated as a failure by its callers.
Change qt202x_reset_phy() to return 0 if successful.

The PCI layer treats >0 as "fail, but please call remove() anyway",
which means that unloading the driver would cause a crash.  Add a
WARN_ON() on the failure path of efx_pci_probe() to provide early
warning if there are any other cases where we do this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    1 +
 drivers/net/sfc/qt202x_phy.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 103e8b0..46997e1 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2284,6 +2284,7 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
  fail2:
 	efx_fini_struct(efx);
  fail1:
+	WARN_ON(rc > 0);
 	EFX_LOG(efx, "initialisation failed. rc=%d\n", rc);
 	free_netdev(net_dev);
 	return rc;
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index e0d13a4..67eec7a 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -320,7 +320,7 @@ static int qt202x_reset_phy(struct efx_nic *efx)
 
 	falcon_board(efx)->type->init_phy(efx);
 
-	return rc;
+	return 0;
 
  fail:
 	EFX_ERR(efx, "PHY reset timed out\n");
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

