From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: [PATCH 2/2] net: arc_emac: don't pass multicast packets to kernel in non-multicast mode
Date: Mon, 14 Nov 2016 16:20:27 +0300
Message-ID: <1479129627-27524-2-git-send-email-al.kochet@gmail.com>
References: <1479129627-27524-1-git-send-email-al.kochet@gmail.com>
Cc: Alexander Kochetkov <al.kochet@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, tremyfr@gmail.com, peter.chen@nxp.com,
        wxt@rock-chips.com, weiyj.lk@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479129627-27524-1-git-send-email-al.kochet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch disable capturing multicast packets when multicast mode
disabled for ethernet ('ifconfig eth0 -multicast'). In that case
no multicast packet will be passed to kernel.
---
 drivers/net/ethernet/arc/emac_main.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 2e4ee86..30ad833 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -460,7 +460,7 @@ static void arc_emac_set_rx_mode(struct net_device *ndev)
 		if (ndev->flags & IFF_ALLMULTI) {
 			arc_reg_set(priv, R_LAFL, ~0);
 			arc_reg_set(priv, R_LAFH, ~0);
-		} else {
+		} else if (ndev->flags & IFF_MULTICAST) {
 			struct netdev_hw_addr *ha;
 			unsigned int filter[2] = { 0, 0 };
 			int bit;
@@ -469,9 +469,11 @@ static void arc_emac_set_rx_mode(struct net_device *ndev)
 				bit = ether_crc_le(ETH_ALEN, ha->addr) >> 26;
 				filter[bit >> 5] |= 1 << (bit & 31);
 			}
-
 			arc_reg_set(priv, R_LAFL, filter[0]);
 			arc_reg_set(priv, R_LAFH, filter[1]);
+		} else {
+			arc_reg_set(priv, R_LAFL, 0);
+			arc_reg_set(priv, R_LAFH, 0);
 		}
 	}
 }
-- 
1.7.9.5
