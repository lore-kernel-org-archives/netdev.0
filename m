From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next 1/1] net: fec: add netif status check before set mac address
Date: Wed, 9 Sep 2015 10:42:47 +0800
Message-ID: <1441766567-30689-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0105.outbound.protection.outlook.com ([157.56.111.105]:7396
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752851AbbIIC5s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2015 22:57:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There exist one issue by below case that case system hang:
ifconfig eth0 down
ifconfig eth0 hw ether 00:10:19:19:81:19

After eth0 down, all fec clocks are gated off. In the .fec_set_mac_address()
function, it will set new MAC address to registers, which causes system hang.

So it needs to add netif status check to avoid registers access when clocks are
gated off. Until eth0 up the new MAC address are wrote into related registers.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 91925e3..cd09dbb 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3029,6 +3029,9 @@ fec_set_mac_address(struct net_device *ndev, void *p)
 		memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
 	}
 
+	if (!netif_running(ndev))
+		return 0;
+
 	writel(ndev->dev_addr[3] | (ndev->dev_addr[2] << 8) |
 		(ndev->dev_addr[1] << 16) | (ndev->dev_addr[0] << 24),
 		fep->hwp + FEC_ADDR_LOW);
-- 
1.9.1
