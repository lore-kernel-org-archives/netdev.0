From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 5/7] net: ethernet: ti: cpsw: fix secondary-emac probe error path
Date: Thu, 17 Nov 2016 17:40:02 +0100
Message-ID: <1479400804-9847-6-git-send-email-johan@kernel.org>
References: <1479400804-9847-1-git-send-email-johan@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479400804-9847-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to deregister the primary device in case the secondary emac
fails to probe.

kernel BUG at /home/johan/work/omicron/src/linux/net/core/dev.c:7743!
...
[<c05b3dec>] (free_netdev) from [<c04fe6c0>] (cpsw_probe+0x9cc/0xe50)
[<c04fe6c0>] (cpsw_probe) from [<c047b28c>] (platform_drv_probe+0x5c/0xc0)

Fixes: d9ba8f9e6298 ("driver: net: ethernet: cpsw: dual emac interface
implementation")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/cpsw.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c3b78bc4fe58..11b2daef3158 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2852,7 +2852,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		ret = cpsw_probe_dual_emac(priv);
 		if (ret) {
 			cpsw_err(priv, probe, "error probe slave 2 emac interface\n");
-			goto clean_ale_ret;
+			goto clean_unregister_netdev_ret;
 		}
 	}
 
@@ -2860,6 +2860,8 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	return 0;
 
+clean_unregister_netdev_ret:
+	unregister_netdev(ndev);
 clean_ale_ret:
 	cpsw_ale_destroy(cpsw->ale);
 clean_dma_ret:
-- 
2.7.3
