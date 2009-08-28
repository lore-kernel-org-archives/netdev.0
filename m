From: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Subject: [PATCH] net: sh_eth: add value of ether_link pin in platform_data
Date: Fri, 28 Aug 2009 18:25:03 +0900
Message-ID: <4A97A26F.4060904@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The method of ETHER_LINK pin is board dependence.
This patch adding paramters are:
 - no_ether_link          : If set to 1, do not use ETHER_LINK
 - ether_link_active_low  : If set to 1, ETHER_LINK is active low.

Signed-off-by: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
---
 arch/sh/include/asm/sh_eth.h |    3 +++
 drivers/net/sh_eth.c         |    6 +++++-
 drivers/net/sh_eth.h         |    3 +++
 3 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/arch/sh/include/asm/sh_eth.h b/arch/sh/include/asm/sh_eth.h
index bb83258..acf9970 100644
--- a/arch/sh/include/asm/sh_eth.h
+++ b/arch/sh/include/asm/sh_eth.h
@@ -6,6 +6,9 @@ enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
 struct sh_eth_plat_data {
 	int phy;
 	int edmac_endian;
+
+	unsigned no_ether_link:1;
+	unsigned ether_link_active_low:1;
 };

 #endif
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index a2d82dd..793d4d9 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -772,13 +772,15 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 			mdp->stats.tx_carrier_errors++;
 		if (felic_stat & ECSR_LCHNG) {
 			/* Link Changed */
-			if (mdp->cd->no_psr) {
+			if (mdp->cd->no_psr || mdp->no_ether_link) {
 				if (mdp->link == PHY_DOWN)
 					link_stat = 0;
 				else
 					link_stat = PHY_ST_LINK;
 			} else {
 				link_stat = (ctrl_inl(ioaddr + PSR));
+				if (mdp->ether_link_active_low)
+					link_stat = ~link_stat;
 			}
 			if (!(link_stat & PHY_ST_LINK)) {
 				/* Link Down : disable tx and rx */
@@ -1410,6 +1412,8 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	mdp->phy_id = pd->phy;
 	/* EDMAC endian */
 	mdp->edmac_endian = pd->edmac_endian;
+	mdp->no_ether_link = pd->no_ether_link;
+	mdp->ether_link_active_low = pd->ether_link_active_low;

 	/* set cpu data */
 	mdp->cd = &sh_eth_my_cpu_data;
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index 9afe5b4..ba151f8 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -729,6 +729,9 @@ struct sh_eth_private {
 	char post_rx;		/* POST receive */
 	char post_fw;		/* POST forward */
 	struct net_device_stats tsu_stats;	/* TSU forward status */
+
+	unsigned no_ether_link:1;
+	unsigned ether_link_active_low:1;
 };

 static inline void sh_eth_soft_swap(char *src, int len)
-- 
1.5.5

