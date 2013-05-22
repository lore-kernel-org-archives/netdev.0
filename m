From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH 2/2] net: mv643xx_eth: proper initialization for Kirkwood SoCs
Date: Wed, 22 May 2013 22:04:02 +0200
Message-ID: <1369253042-15082-2-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:48229 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428Ab3EVUEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 16:04:14 -0400
In-Reply-To: <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethernet controllers found on Kirkwood SoCs not only suffer from loosing
MAC address register contents on clock gating but also some important
registers are reset to values that would break ethernet. This patch
clears the CLK125_BYPASS_EN bit for DT enabled Kirkwood only by using
of_machine_is_compatible() instead of #ifdefs. Non-DT Kirkwood is not
affected as it installs a clock gating workaround because of the MAC
address issue above. Other Orion SoCs do not suffer from register reset,
do not have the bit in question, or do not have the register at all.
Moreover, system controllers on PPC using this driver should also be
protected from clearing that bit.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Note: In contrast to the reset value of 0 for CLK125_BYPASS_EN bit as
stated in Kirkwood datasheet, we confirmed that reset value is 1 instead.
Either datasheet is wrong about it, there is some post-boot self-check or
BootROM flips that bit.

Cc: David Miller <davem@davemloft.net>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index f2c229c..d9ad8c7 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -119,6 +119,8 @@ static char mv643xx_eth_driver_version[] = "1.4";
 #define  LINK_UP			0x00000002
 #define TXQ_COMMAND			0x0048
 #define TXQ_FIX_PRIO_CONF		0x004c
+#define PORT_SERIAL_CONTROL1		0x004c
+#define  CLK125_BYPASS_EN		0x00000010
 #define TX_BW_RATE			0x0050
 #define TX_BW_MTU			0x0058
 #define TX_BW_BURST			0x005c
@@ -2843,6 +2845,14 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	mp->dev = dev;
 
+	/* Kirkwood resets some registers on gated clocks. Especially
+	 * CLK125_BYPASS_EN must be cleared but is not available on
+	 * all other SoCs/System Controllers using this driver.
+	 */
+	if (of_machine_is_compatible("marvell,kirkwood"))
+		wrlp(mp, PORT_SERIAL_CONTROL1,
+		     rdlp(mp, PORT_SERIAL_CONTROL1) & ~CLK125_BYPASS_EN);
+
 	/*
 	 * Start with a default rate, and if there is a clock, allow
 	 * it to override the default.
-- 
1.7.10.4
