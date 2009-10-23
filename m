From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 24/27] sfc: Move MTD probe after netdev registration and
	name allocation
Date: Fri, 23 Oct 2009 19:33:09 +0100
Message-ID: <1256322789.2785.51.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8960 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015AbZJWSdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:33:06 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MTD partition is named based on the netdev name, which is set to
'eth%d' before registration.  Also, the MTD partition will currently
be left registered if netdev registration fails.

Fix both these problems by moving the MTD probe after netdev
registration.  Hold the RTNL to serialise this with the netdev
notifier that calls efx_mtd_rename().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 8fc6a6e..0d0243b 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2209,13 +2209,15 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	 * MAC stats succeeds. */
 	efx->state = STATE_RUNNING;
 
-	efx_mtd_probe(efx); /* allowed to fail */
-
 	rc = efx_register_netdev(efx);
 	if (rc)
 		goto fail5;
 
 	EFX_LOG(efx, "initialisation successful\n");
+
+	rtnl_lock();
+	efx_mtd_probe(efx); /* allowed to fail */
+	rtnl_unlock();
 	return 0;
 
  fail5:

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

