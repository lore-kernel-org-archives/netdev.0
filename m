From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net v2 1/1] net: fec: add netif status check before set mac address
Date: Thu, 10 Sep 2015 09:35:39 +0800
Message-ID: <1441848939-30108-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<l.stach@pengutronix.de>, <f.fainelli@gmail.com>,
	<b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0104.outbound.protection.outlook.com ([157.56.111.104]:40991
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752283AbbIJBgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2015 21:36:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There exist one issue by below case that case system hang:
ifconfig eth0 down
ifconfig eth0 hw ether 00:10:19:19:81:19

After eth0 down, all fec clocks are gated off. In the .fec_set_mac_address()
function, it will set new MAC address to registers, which causes system hang.

So it needs to add netif status check to avoid registers access when clocks are
gated off. Until eth0 up the new MAC address are wrote into related registers.

V2:
As Lucas Stach's suggestion, add a comment in the code to explain why it needed.

CC: Lucas Stach <l.stach@pengutronix.de>
CC: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 91925e3..d0d83aef 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3029,6 +3029,14 @@ fec_set_mac_address(struct net_device *ndev, void *p)
 		memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
 	}
 
+	/* Add netif status check here to avoid system hang in below case:
+	 * ifconfig ethx down; ifconfig ethx hw ether xx:xx:xx:xx:xx:xx;
+	 * After ethx down, fec all clocks are gated off and then register
+	 * access causes system hang.
+	 */
+	if (!netif_running(ndev))
+		return 0;
+
 	writel(ndev->dev_addr[3] | (ndev->dev_addr[2] << 8) |
 		(ndev->dev_addr[1] << 16) | (ndev->dev_addr[0] << 24),
 		fep->hwp + FEC_ADDR_LOW);
-- 
1.9.1
