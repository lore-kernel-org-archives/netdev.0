From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH net-next 6/7] net/faraday: Fix phy link irq on Aspeed G5 SoCs
Date: Tue, 20 Sep 2016 16:00:06 +0930
Message-ID: <20160920063007.24291-7-joel@jms.id.au>
References: <20160920063007.24291-1-joel@jms.id.au>
Cc: gwshan@linux.vnet.ibm.com, andrew@lunn.ch, andrew@aj.id.au,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        benh@kernel.crashing.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160920063007.24291-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Aspeed SoC with a direct PHY connection (non-NSCI), we receive
continual PHYSTS interrupts:

 [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
 [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
 [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
 [   20.300000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG

This is because the driver was enabling low-level sensitive interrupt
generation where the systems are wired for high-level. All CPU cycles
are spent servicing this interrupt.

Signed-off-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 7ba0f2d58a8b..5466df028381 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -223,6 +223,10 @@ static void ftgmac100_start_hw(struct ftgmac100 *priv, int speed)
 {
 	int maccr = MACCR_ENABLE_ALL;
 
+	if (of_machine_is_compatible("aspeed,ast2500")) {
+		maccr &= ~FTGMAC100_MACCR_PHY_LINK_LEVEL;
+	}
+
 	switch (speed) {
 	default:
 	case 10:
-- 
2.9.3
