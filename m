From: Tomoya MORINAGA <tomoya.rohm@gmail.com>
Subject: [PATCH 1/2 v2] pch_gbe: Do not abort probe on bad MAC
Date: Fri, 20 Apr 2012 15:54:45 +0900
Message-ID: <1334904885-10171-1-git-send-email-tomoya.rohm@gmail.com>
Cc: Darren Hart <dvhart@linux.intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Alan Cox <alan@linux.intel.com>,
	Tomoya MORINAGA <tomoya.rohm@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jon Mason <jdmason@kudzu.us>, netdev@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Joe Perches <joe@perches.com>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:40984 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087Ab2DTGzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 02:55:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Darren Hart <dvhart@linux.intel.com>

If the MAC is invalid or not implemented, do not abort the probe. Issue
a warning and prevent bringing the interface up until a MAC is set manually
(via ifconfig $IFACE hw ether $MAC).

Tested on two platforms, one with a valid MAC, the other without a MAC. The real
MAC is used if present, the interface fails to come up until the MAC is set on
the other. They successfully get an IP over DHCP and pass a simple ping and
login over ssh test.

This is meant to allow the Inforce SYS940X development board:
http://www.inforcecomputing.com/SYS940X_ECX.html
(and others suffering from a missing MAC) to work with the mainline kernel.
Without this patch, the probe will fail and the interface will not be created,
preventing the user from configuring the MAC manually.

This does not make any attempt to address a missing or invalid MAC for the
pch_phub driver.

commit 2b53d07891630dead46d65c8f896955fd3ae0302
kernel 3.0

Cc: stable@vger.kernel.org
Signed-off-by: Darren Hart <dvhart@linux.intel.com>
CC: Arjan van de Ven <arjan@linux.intel.com>
CC: Alan Cox <alan@linux.intel.com>
CC: Tomoya MORINAGA <tomoya.rohm@gmail.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Paul Gortmaker <paul.gortmaker@windriver.com>
CC: Jon Mason <jdmason@kudzu.us>
CC: netdev@vger.kernel.org
CC: Mark Brown <broonie@opensource.wolfsonmicro.com>
CC: David Laight <David.Laight@ACULAB.COM>
CC: Joe Perches <joe@perches.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Tomoya MORINAGA <tomoya.rohm@gmail.com>
---
v2
 - Separate into 2 patches because folder structure was changed.
---
 drivers/net/pch_gbe/pch_gbe_main.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index eac3c5c..e7412f2 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -1701,6 +1701,12 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
 	struct pch_gbe_rx_ring *rx_ring = adapter->rx_ring;
 	int err;
 
+	/* Ensure we have a valid MAC */
+	if (!is_valid_ether_addr(adapter->hw.mac.addr)) {
+		pr_err("Error: Invalid MAC address\n");
+		return -EINVAL;
+	}
+
 	/* hardware has been reset, we need to reload some things */
 	pch_gbe_set_multi(netdev);
 
@@ -2392,9 +2398,14 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 
 	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
-		dev_err(&pdev->dev, "Invalid MAC Address\n");
-		ret = -EIO;
-		goto err_free_adapter;
+		/*
+		 * If the MAC is invalid (or just missing), display a warning
+		 * but do not abort setting up the device. pch_gbe_up will
+		 * prevent the interface from being brought up until a valid MAC
+		 * is set.
+		 */
+		dev_err(&pdev->dev, "Invalid MAC address, "
+		                    "interface disabled.\n");
 	}
 	setup_timer(&adapter->watchdog_timer, pch_gbe_watchdog,
 		    (unsigned long)adapter);
-- 
1.7.7.6
