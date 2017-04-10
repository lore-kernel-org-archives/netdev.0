From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 4/6] net: mvmdio: disable interrupt if resource size is too
 small
Date: Mon, 10 Apr 2017 16:28:20 +0100
Message-ID: <E1cxbEq-0006gR-Dy@rmk-PC.armlinux.org.uk>
References: <20170410152728.GT17774@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:37680 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753334AbdDJP2b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:28:31 -0400
In-Reply-To: <20170410152728.GT17774@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable the MDIO interrupt, falling back to polled mode, if the resource
size does not allow us to access the interrupt registers.  All current
DT bindings use a size of 0x84, which allows access, but verifying it is
good practice.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 6ea5caddca62..614dfde657fe 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -221,6 +221,12 @@ static int orion_mdio_probe(struct platform_device *pdev)
 		clk_prepare_enable(dev->clk);
 
 	dev->err_interrupt = platform_get_irq(pdev, 0);
+	if (dev->err_interrupt > 0 &&
+	    resource_size(r) < MVMDIO_ERR_INT_MASK + 4) {
+		dev_err(&pdev->dev,
+			"disabling interrupt, resource size is too small\n");
+		dev->err_interrupt = 0;
+	}
 	if (dev->err_interrupt > 0) {
 		ret = devm_request_irq(&pdev->dev, dev->err_interrupt,
 					orion_mdio_err_irq,
-- 
2.7.4
