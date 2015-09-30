From: Vladimir Zapolskiy <vz@mleia.com>
Subject: [PATCH] net: lpc_eth: fix warnings caused by enabling unprepared clock
Date: Thu,  1 Oct 2015 00:37:43 +0300
Message-ID: <1443649063-10817-1-git-send-email-vz@mleia.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li271-223.members.linode.com ([178.79.152.223]:38744 "EHLO
	mail.mleia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932845AbbI3Vhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 17:37:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If common clock framework is configured, the driver generates warnings,
which are fixed by this change:

    WARNING: CPU: 0 PID: 1 at linux/drivers/clk/clk.c:727 clk_core_enable+0x2c/0xa4()
    Modules linked in:
    CPU: 0 PID: 1 Comm: swapper Not tainted 4.3.0-rc2+ #141
    Hardware name: LPC32XX SoC (Flattened Device Tree)
    Backtrace:
    [<>] (dump_backtrace) from [<>] (show_stack+0x18/0x1c)
    [<>] (show_stack) from [<>] (dump_stack+0x20/0x28)
    [<>] (dump_stack) from [<>] (warn_slowpath_common+0x90/0xb8)
    [<>] (warn_slowpath_common) from [<>] (warn_slowpath_null+0x24/0x2c)
    [<>] (warn_slowpath_null) from [<>] (clk_core_enable+0x2c/0xa4)
    [<>] (clk_core_enable) from [<>] (clk_enable+0x24/0x38)
    [<>] (clk_enable) from [<>] (lpc_eth_drv_probe+0xfc/0x99c)
    [<>] (lpc_eth_drv_probe) from [<>] (platform_drv_probe+0x50/0xa0)
    [<>] (platform_drv_probe) from [<>] (driver_probe_device+0x18c/0x408)
    [<>] (driver_probe_device) from [<>] (__driver_attach+0x70/0x94)
    [<>] (__driver_attach) from [<>] (bus_for_each_dev+0x74/0x98)
    [<>] (bus_for_each_dev) from [<>] (driver_attach+0x20/0x28)
    [<>] (driver_attach) from [<>] (bus_add_driver+0x11c/0x248)
    [<>] (bus_add_driver) from [<>] (driver_register+0xa4/0xe8)
    [<>] (driver_register) from [<>] (__platform_driver_register+0x50/0x64)
    [<>] (__platform_driver_register) from [<>] (lpc_eth_driver_init+0x18/0x20)
    [<>] (lpc_eth_driver_init) from [<>] (do_one_initcall+0x11c/0x1dc)
    [<>] (do_one_initcall) from [<>] (kernel_init_freeable+0x10c/0x1d4)
    [<>] (kernel_init_freeable) from [<>] (kernel_init+0x10/0xec)
    [<>] (kernel_init) from [<>] (ret_from_fork+0x14/0x24)

Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
---
 drivers/net/ethernet/nxp/lpc_eth.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 66fd868..b159ef8 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -476,13 +476,12 @@ static void __lpc_get_mac(struct netdata_local *pldat, u8 *mac)
 	mac[5] = tmp >> 8;
 }
 
-static void __lpc_eth_clock_enable(struct netdata_local *pldat,
-				   bool enable)
+static void __lpc_eth_clock_enable(struct netdata_local *pldat, bool enable)
 {
 	if (enable)
-		clk_enable(pldat->clk);
+		clk_prepare_enable(pldat->clk);
 	else
-		clk_disable(pldat->clk);
+		clk_disable_unprepare(pldat->clk);
 }
 
 static void __lpc_params_setup(struct netdata_local *pldat)
@@ -1494,7 +1493,7 @@ err_out_free_irq:
 err_out_iounmap:
 	iounmap(pldat->net_base);
 err_out_disable_clocks:
-	clk_disable(pldat->clk);
+	clk_disable_unprepare(pldat->clk);
 	clk_put(pldat->clk);
 err_out_free_dev:
 	free_netdev(ndev);
@@ -1519,7 +1518,7 @@ static int lpc_eth_drv_remove(struct platform_device *pdev)
 	iounmap(pldat->net_base);
 	mdiobus_unregister(pldat->mii_bus);
 	mdiobus_free(pldat->mii_bus);
-	clk_disable(pldat->clk);
+	clk_disable_unprepare(pldat->clk);
 	clk_put(pldat->clk);
 	free_netdev(ndev);
 
@@ -1540,7 +1539,7 @@ static int lpc_eth_drv_suspend(struct platform_device *pdev,
 		if (netif_running(ndev)) {
 			netif_device_detach(ndev);
 			__lpc_eth_shutdown(pldat);
-			clk_disable(pldat->clk);
+			clk_disable_unprepare(pldat->clk);
 
 			/*
 			 * Reset again now clock is disable to be sure
-- 
2.1.4
