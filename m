From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 04/19] sfc: Warn if unable to create MTDs
Date: Thu, 16 Feb 2012 00:45:26 +0000
Message-ID: <1329353126.2565.30.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27607 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753354Ab2BPAr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:47:56 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Log an explicit warning if we are unable to create MTDs for a net
device.  Also correct the comment about why mtd_device_register() may
fail; there is no longer an MTD table to fill up.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    7 ++++++-
 drivers/net/ethernet/sfc/mtd.c |    2 +-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 2e6389c..ce07aa5 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2502,9 +2502,14 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 
 	netif_dbg(efx, probe, efx->net_dev, "initialisation successful\n");
 
+	/* Try to create MTDs, but allow this to fail */
 	rtnl_lock();
-	efx_mtd_probe(efx); /* allowed to fail */
+	rc = efx_mtd_probe(efx);
 	rtnl_unlock();
+	if (rc)
+		netif_warn(efx, probe, efx->net_dev,
+			   "failed to create MTDs (%d)\n", rc);
+
 	return 0;
 
  fail4:
diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
index 79c1922..26b3c23 100644
--- a/drivers/net/ethernet/sfc/mtd.c
+++ b/drivers/net/ethernet/sfc/mtd.c
@@ -280,7 +280,7 @@ fail:
 		--part;
 		efx_mtd_remove_partition(part);
 	}
-	/* mtd_device_register() returns 1 if the MTD table is full */
+	/* Failure is unlikely here, but probably means we're out of memory */
 	return -ENOMEM;
 }
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
