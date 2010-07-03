From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] net/ne: fix memory leak in ne_drv_probe()
Date: Sat,  3 Jul 2010 19:20:42 +0400
Message-ID: <1278170444-8170-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net_device allocated with alloc_eip_netdev() must be freed.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/ne.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index b8e2923..1063093 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -796,28 +796,30 @@ static int __init ne_drv_probe(struct platform_device *pdev)
 	dev = alloc_eip_netdev();
 	if (!dev)
 		return -ENOMEM;
 
 	/* ne.c doesn't populate resources in platform_device, but
 	 * rbtx4927_ne_init and rbtx4938_ne_init do register devices
 	 * with resources.
 	 */
 	res = platform_get_resource(pdev, IORESOURCE_IO, 0);
 	if (res) {
 		dev->base_addr = res->start;
 		dev->irq = platform_get_irq(pdev, 0);
 	} else {
-		if (this_dev < 0 || this_dev >= MAX_NE_CARDS)
+		if (this_dev < 0 || this_dev >= MAX_NE_CARDS) {
+			free_netdev(dev);
 			return -EINVAL;
+		}
 		dev->base_addr = io[this_dev];
 		dev->irq = irq[this_dev];
 		dev->mem_end = bad[this_dev];
 	}
 	err = do_ne_probe(dev);
 	if (err) {
 		free_netdev(dev);
 		return err;
 	}
 	platform_set_drvdata(pdev, dev);
 
 	/* Update with any values found by probing, don't update if
 	 * resources were specified.
-- 
1.7.0.4
