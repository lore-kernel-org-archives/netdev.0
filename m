From: <dinguyen@opensource.altera.com>
Subject: [PATCH] stmmac: platform: fix stmmac probe failure
Date: Mon, 1 Dec 2014 14:00:54 -0600
Message-ID: <1417464054-8777-1-git-send-email-dinguyen@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dinh.linux@gmail.com>, <maxime.ripard@free-electrons.com>,
	<olof@lixom.net>, <vbridger@opensource.altera.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Dinh Nguyen <dinguyen@opensource.altera.com>
To: <davem@davemloft.net>, <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dinh Nguyen <dinguyen@opensource.altera.com>

The commit 571dcfde23712b ("stmmac: platform: fix default values of the filter
bins setting") broke support for stmmac probe for all CONFIG_OF platforms.

[    0.743567] Unable to handle kernel NULL pointer dereference at virtual address 00000048
[    0.751679] pgd = c0004000
[    0.754384] [00000048] *pgd=00000000
[    0.757983] Internal error: Oops: 805 [#1] SMP ARM
[    0.762774] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.18.0-rc7 #1
[    0.769034] task: ee86c000 ti: ee870000 task.ti: ee870000
[    0.774429] PC is at stmmac_pltfr_probe+0x40/0x5d0
[    0.779217] LR is at devm_ioremap_nocache+0x54/0x74
...
[    0.951644] [<c0287938>] (stmmac_pltfr_probe) from [<c0234c4c>] (platform_drv_probe+0x44/0xa4)
[    0.960250] [<c0234c4c>] (platform_drv_probe) from [<c023390c>] (driver_probe_device+0x10c/0x240)
[    0.969113] [<c023390c>] (driver_probe_device) from [<c0233b10>] (__driver_attach+0x8c/0x90)
[    0.977544] [<c0233b10>] (__driver_attach) from [<c02320fc>] (bus_for_each_dev+0x6c/0xa0)

The reason is that in stmmac_pltfr_probe(), the plat_dat on a CONFIG_OF
platform is NULL until devm_kzalloc() is called to allocate plat_dat.

Signed-off-by: Dinh Nguyen <dinguyen@opensource.altera.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 5b0da39..62c9e75 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -265,12 +265,6 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 
 	plat_dat = dev_get_platdata(&pdev->dev);
 
-	/* Set default value for multicast hash bins */
-	plat_dat->multicast_filter_bins = HASH_TABLE_SIZE;
-
-	/* Set default value for unicast filter entries */
-	plat_dat->unicast_filter_entries = 1;
-
 	if (pdev->dev.of_node) {
 		if (!plat_dat)
 			plat_dat = devm_kzalloc(&pdev->dev,
@@ -288,6 +282,12 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 		}
 	}
 
+	/* Set default value for multicast hash bins */
+	plat_dat->multicast_filter_bins = HASH_TABLE_SIZE;
+
+	/* Set default value for unicast filter entries */
+	plat_dat->unicast_filter_entries = 1;
+
 	/* Custom setup (if needed) */
 	if (plat_dat->setup) {
 		plat_dat->bsp_priv = plat_dat->setup(pdev);
-- 
2.0.3
