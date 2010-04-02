From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 1/2] netdev: phy/mdio-octeon: Enable the hardware before using it.
Date: Thu,  1 Apr 2010 18:17:54 -0700
Message-ID: <1270171075-12741-2-git-send-email-ddaney@caviumnetworks.com>
References: <1270171075-12741-1-git-send-email-ddaney@caviumnetworks.com>
Cc: davem@davemloft.net, David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:10732 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756885Ab0DBBSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:18:55 -0400
In-Reply-To: <1270171075-12741-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases the mdio bus is not enabled at the time of probing.
This prevents anything from working, so we will enable it before
trying to use it, and disable it when the driver is removed.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/net/phy/mdio-octeon.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index 61a4461..dfaaf30 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -87,6 +87,7 @@ static int octeon_mdiobus_write(struct mii_bus *bus, int phy_id,
 static int __init octeon_mdiobus_probe(struct platform_device *pdev)
 {
 	struct octeon_mdiobus *bus;
+	union cvmx_smix_en smi_en;
 	int i;
 	int err = -ENOENT;
 
@@ -102,6 +103,10 @@ static int __init octeon_mdiobus_probe(struct platform_device *pdev)
 	if (!bus->mii_bus)
 		goto err;
 
+	smi_en.u64 = 0;
+	smi_en.s.en = 1;
+	cvmx_write_csr(CVMX_SMIX_EN(bus->unit), smi_en.u64);
+
 	/*
 	 * Standard Octeon evaluation boards don't support phy
 	 * interrupts, we need to poll.
@@ -132,17 +137,22 @@ err_register:
 
 err:
 	devm_kfree(&pdev->dev, bus);
+	smi_en.u64 = 0;
+	cvmx_write_csr(CVMX_SMIX_EN(bus->unit), smi_en.u64);
 	return err;
 }
 
 static int __exit octeon_mdiobus_remove(struct platform_device *pdev)
 {
 	struct octeon_mdiobus *bus;
+	union cvmx_smix_en smi_en;
 
 	bus = dev_get_drvdata(&pdev->dev);
 
 	mdiobus_unregister(bus->mii_bus);
 	mdiobus_free(bus->mii_bus);
+	smi_en.u64 = 0;
+	cvmx_write_csr(CVMX_SMIX_EN(bus->unit), smi_en.u64);
 	return 0;
 }
 
-- 
1.6.6.1

