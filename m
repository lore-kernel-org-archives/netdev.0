From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH 1/2] sh_eth: Fix sleeping function called from invalid context
Date: Thu, 13 Nov 2014 16:02:14 +0900
Message-ID: <1415862135-27972-2-git-send-email-ykaneko0929@gmail.com>
References: <1415862135-27972-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1415862135-27972-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>

Fix the bug as follows:

----
[ 1238.161349] BUG: sleeping function called from invalid context at drivers/base/power/runtime.c:952
[ 1238.188279] in_atomic(): 1, irqs_disabled(): 0, pid: 1388, name: cat
[ 1238.207425] CPU: 0 PID: 1388 Comm: cat Not tainted 3.10.31-ltsi-00046-gefa0b46 #1087
[ 1238.230737] Backtrace:
[ 1238.238123] [<c0012e64>] (dump_backtrace+0x0/0x10c) from [<c0013000>] (show_stack+0x18/0x1c)
[ 1238.263499]  r6:000003b8 r5:c06160c0 r4:c0669e00 r3:00404000
[ 1238.280583] [<c0012fe8>] (show_stack+0x0/0x1c) from [<c04515a4>] (dump_stack+0x20/0x28)
[ 1238.304631] [<c0451584>] (dump_stack+0x0/0x28) from [<c004970c>] (__might_sleep+0xf8/0x118)
[ 1238.329734] [<c0049614>] (__might_sleep+0x0/0x118) from [<c02465ac>] (__pm_runtime_resume+0x38/0x90)
[ 1238.357170]  r7:d616f000 r6:c049c458 r5:00000004 r4:d6a17210
[ 1238.374251] [<c0246574>] (__pm_runtime_resume+0x0/0x90) from [<c029b1c4>] (sh_eth_get_stats+0x44/0x280)
[ 1238.402468]  r7:d616f000 r6:c049c458 r5:d5c21000 r4:d5c21000
[ 1238.419552] [<c029b180>] (sh_eth_get_stats+0x0/0x280) from [<c03ae39c>] (dev_get_stats+0x54/0x88)
[ 1238.446204]  r5:d5c21000 r4:d5ed7e08
[ 1238.456980] [<c03ae348>] (dev_get_stats+0x0/0x88) from [<c03c677c>] (netstat_show.isra.15+0x54/0x9c)
[ 1238.484413]  r6:d5c21000 r5:d5c21238 r4:00000028 r3:00000001
[ 1238.501495] [<c03c6728>] (netstat_show.isra.15+0x0/0x9c) from [<c03c69b8>] (show_tx_errors+0x18/0x1c)
[ 1238.529196]  r7:d5f945d8 r6:d5f945c0 r5:c049716c r4:c0650e7c
[ 1238.546279] [<c03c69a0>] (show_tx_errors+0x0/0x1c) from [<c023963c>] (dev_attr_show+0x24/0x50)
[ 1238.572157] [<c0239618>] (dev_attr_show+0x0/0x50) from [<c010c148>] (sysfs_read_file+0xb0/0x140)
[ 1238.598554]  r5:c049716c r4:d5c21240
[ 1238.609326] [<c010c098>] (sysfs_read_file+0x0/0x140) from [<c00b9ee4>] (vfs_read+0xb0/0x13c)
[ 1238.634679] [<c00b9e34>] (vfs_read+0x0/0x13c) from [<c00ba0ac>] (SyS_read+0x44/0x74)
[ 1238.657944]  r8:bef45bf0 r7:00000000 r6:d6ac0600 r5:00000000 r4:00000000
[ 1238.678172] [<c00ba068>] (SyS_read+0x0/0x74) from [<c000eec0>] (ret_fast_syscall+0x0/0x30)
----

Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 64 +++++++++++++++++++----------------
 drivers/net/ethernet/renesas/sh_eth.h |  1 +
 2 files changed, 36 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 60e9c2c..862a691 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2042,6 +2042,8 @@ static int sh_eth_open(struct net_device *ndev)
 	if (ret)
 		goto out_free_irq;
 
+	mdp->is_opened = 1;
+
 	return ret;
 
 out_free_irq:
@@ -2131,6 +2133,36 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return NETDEV_TX_OK;
 }
 
+static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+
+	if (sh_eth_is_rz_fast_ether(mdp))
+		return &ndev->stats;
+
+	if (!mdp->is_opened)
+		return &ndev->stats;
+
+	ndev->stats.tx_dropped += sh_eth_read(ndev, TROCR);
+	sh_eth_write(ndev, 0, TROCR);	/* (write clear) */
+	ndev->stats.collisions += sh_eth_read(ndev, CDCR);
+	sh_eth_write(ndev, 0, CDCR);	/* (write clear) */
+	ndev->stats.tx_carrier_errors += sh_eth_read(ndev, LCCR);
+	sh_eth_write(ndev, 0, LCCR);	/* (write clear) */
+
+	if (sh_eth_is_gether(mdp)) {
+		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CERCR);
+		sh_eth_write(ndev, 0, CERCR);	/* (write clear) */
+		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CEECR);
+		sh_eth_write(ndev, 0, CEECR);	/* (write clear) */
+	} else {
+		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CNDCR);
+		sh_eth_write(ndev, 0, CNDCR);	/* (write clear) */
+	}
+
+	return &ndev->stats;
+}
+
 /* device close function */
 static int sh_eth_close(struct net_device *ndev)
 {
@@ -2145,6 +2177,7 @@ static int sh_eth_close(struct net_device *ndev)
 	sh_eth_write(ndev, 0, EDTRR);
 	sh_eth_write(ndev, 0, EDRRR);
 
+	sh_eth_get_stats(ndev);
 	/* PHY Disconnect */
 	if (mdp->phydev) {
 		phy_stop(mdp->phydev);
@@ -2163,36 +2196,9 @@ static int sh_eth_close(struct net_device *ndev)
 
 	pm_runtime_put_sync(&mdp->pdev->dev);
 
-	return 0;
-}
-
-static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	if (sh_eth_is_rz_fast_ether(mdp))
-		return &ndev->stats;
-
-	pm_runtime_get_sync(&mdp->pdev->dev);
-
-	ndev->stats.tx_dropped += sh_eth_read(ndev, TROCR);
-	sh_eth_write(ndev, 0, TROCR);	/* (write clear) */
-	ndev->stats.collisions += sh_eth_read(ndev, CDCR);
-	sh_eth_write(ndev, 0, CDCR);	/* (write clear) */
-	ndev->stats.tx_carrier_errors += sh_eth_read(ndev, LCCR);
-	sh_eth_write(ndev, 0, LCCR);	/* (write clear) */
-	if (sh_eth_is_gether(mdp)) {
-		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CERCR);
-		sh_eth_write(ndev, 0, CERCR);	/* (write clear) */
-		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CEECR);
-		sh_eth_write(ndev, 0, CEECR);	/* (write clear) */
-	} else {
-		ndev->stats.tx_carrier_errors += sh_eth_read(ndev, CNDCR);
-		sh_eth_write(ndev, 0, CNDCR);	/* (write clear) */
-	}
-	pm_runtime_put_sync(&mdp->pdev->dev);
+	mdp->is_opened = 0;
 
-	return &ndev->stats;
+	return 0;
 }
 
 /* ioctl to device function */
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index b37c427..9a1c550 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -508,6 +508,7 @@ struct sh_eth_private {
 	u32 rx_buf_sz;			/* Based on MTU+slack. */
 	int edmac_endian;
 	struct napi_struct napi;
+	bool is_opened;
 	/* MII transceiver section. */
 	u32 phy_id;			/* PHY ID */
 	struct mii_bus *mii_bus;	/* MDIO bus control */
-- 
1.9.1

