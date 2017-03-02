From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH net v5 2/2] net: ethernet: bgmac: mac address change bug
Date: Thu,  2 Mar 2017 17:59:57 -0500
Message-ID: <1488495597-5835-3-git-send-email-jon.mason@broadcom.com>
References: <1488495597-5835-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Hari Vyas <hariv@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488495597-5835-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hari Vyas <hariv@broadcom.com>

ndo_set_mac_address() passes struct sockaddr * as 2nd parameter to
bgmac_set_mac_address() but code assumed u8 *.  This caused two bytes
chopping and the wrong mac address was configured.

Signed-off-by: Hari Vyas <hariv@broadcom.com>
Signed-off-by: Jon Mason <jon.mason@broadcom.com>
Fixes: 4e209001b86 ("bgmac: write mac address to hardware in ndo_set_mac_address")
---
 drivers/net/ethernet/broadcom/bgmac.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 4150467..fd66fca 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1223,12 +1223,16 @@ static netdev_tx_t bgmac_start_xmit(struct sk_buff *skb,
 static int bgmac_set_mac_address(struct net_device *net_dev, void *addr)
 {
 	struct bgmac *bgmac = netdev_priv(net_dev);
+	struct sockaddr *sa = addr;
 	int ret;
 
 	ret = eth_prepare_mac_addr_change(net_dev, addr);
 	if (ret < 0)
 		return ret;
-	bgmac_write_mac_address(bgmac, (u8 *)addr);
+
+	ether_addr_copy(net_dev->dev_addr, sa->sa_data);
+	bgmac_write_mac_address(bgmac, net_dev->dev_addr);
+
 	eth_commit_mac_addr_change(net_dev, addr);
 	return 0;
 }
-- 
2.7.4
