From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC 4/4] net: mvmdio: disable interrupt if resource size is
 too small
Date: Sat, 07 Jan 2017 11:28:36 +0000
Message-ID: <E1cPpAq-0005uQ-1T@rmk-PC.armlinux.org.uk>
References: <20170107112656.GL14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-arm-kernel@lists.infradead.org,
        Marcin Wojtas <mw@semihalf.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        netdev@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cooper <jason@lakedaemon.net>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Rob Herring <robh+dt@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:59830 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758200AbdAGL3J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 06:29:09 -0500
In-Reply-To: <20170107112656.GL14217@n2100.armlinux.org.uk>
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
