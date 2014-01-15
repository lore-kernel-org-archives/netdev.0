From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH net-next 1/2] r6040: add delays in MDIO read/write polling loops
Date: Wed, 15 Jan 2014 13:04:25 -0800
Message-ID: <1389819866-32142-2-git-send-email-florian@openwrt.org>
References: <1389819866-32142-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <florian@openwrt.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:46329 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaAOVEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 16:04:44 -0500
In-Reply-To: <1389819866-32142-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On newer and faster machines (Vortex X86DX) using the r6040 driver, it
was noticed that the driver was returning an error during probing traced
down to being the MDIO bus probing and the inability to complete a MDIO
read operation in time. It turns out that the MDIO operations on these
faster machines usually complete after ~2140 iterations which is bigger
than 2048 (MAC_DEF_TIMEOUT) and results in spurious timeouts depending
on the system load.

Update r6040_phy_read() and r6040_phy_write() to include a 1
micro second delay in each busy-looping iteration of the loop which is a
much safer operation than incrementing MAC_DEF_TIMEOUT.

Reported-by: Nils Koehler <nils.koehler@ibt-interfaces.de>
Reported-by: Daniel Goertzen <daniel.goertzen@gmail.com>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 1e49ec5..ff4683a 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -222,6 +222,7 @@ static int r6040_phy_read(void __iomem *ioaddr, int phy_addr, int reg)
 		cmd = ioread16(ioaddr + MMDIO);
 		if (!(cmd & MDIO_READ))
 			break;
+		udelay(1);
 	}
 
 	if (limit < 0)
@@ -245,6 +246,7 @@ static int r6040_phy_write(void __iomem *ioaddr,
 		cmd = ioread16(ioaddr + MMDIO);
 		if (!(cmd & MDIO_WRITE))
 			break;
+		udelay(1);
 	}
 
 	return (limit < 0) ? -ETIMEDOUT : 0;
-- 
1.8.3.2
