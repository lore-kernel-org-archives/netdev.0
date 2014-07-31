From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] netdev: octeon_mgmt: Use devm_ioremap_resource
Date: Thu, 31 Jul 2014 12:36:53 +0530
Message-ID: <20140731070653.GA3759@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: Luka Perkov <luka@openwrt.org>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	David Daney <david.daney@cavium.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the use of devm_ioremap_resource instead of
devm_request_mem_region and devm_ioremap. The error handling on the
platform_get_resource is done way with. The size and start fields in the
octeon_mgmt are no longer needed. So they are removed and there
initialization skipped. Also, error handling is added on the values
returned by devm_ioremap_resource.

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
Not compile tested.
 drivers/net/ethernet/octeon/octeon_mgmt.c | 64 +++++++------------------------
 1 file changed, 13 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 979c698..5d61a26 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -148,12 +148,6 @@ struct octeon_mgmt {
 	struct tasklet_struct tx_clean_tasklet;
 	struct phy_device *phydev;
 	struct device_node *phy_np;
-	resource_size_t mix_phys;
-	resource_size_t mix_size;
-	resource_size_t agl_phys;
-	resource_size_t agl_size;
-	resource_size_t agl_prt_ctl_phys;
-	resource_size_t agl_prt_ctl_size;
 };
 
 static void octeon_mgmt_set_rx_irq(struct octeon_mgmt *p, int enable)
@@ -1418,6 +1412,7 @@ static int octeon_mgmt_probe(struct platform_device *pdev)
 	struct resource *res_agl_prt_ctl;
 	int len;
 	int result;
+	void *ret;
 
 	netdev = alloc_etherdev(sizeof(struct octeon_mgmt));
 	if (netdev == NULL)
@@ -1452,62 +1447,29 @@ static int octeon_mgmt_probe(struct platform_device *pdev)
 	p->irq = result;
 
 	res_mix = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (res_mix == NULL) {
-		dev_err(&pdev->dev, "no 'reg' resource\n");
-		result = -ENXIO;
+	ret = devm_ioremap_resource(&pdev->dev, res_mix);
+	if (IS_ERR(ret)) {
+		result = PTR_ERR(ret);
 		goto err;
 	}
+	p->mix = (u64)ret;
 
 	res_agl = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-	if (res_agl == NULL) {
-		dev_err(&pdev->dev, "no 'reg' resource\n");
-		result = -ENXIO;
+	ret = devm_ioremap_resource(&pdev->dev, res_agl);
+	if (IS_ERR(ret)) {
+		result = PTR_ERR(ret);
 		goto err;
 	}
+	p->agl = (u64)ret;
 
 	res_agl_prt_ctl = platform_get_resource(pdev, IORESOURCE_MEM, 3);
-	if (res_agl_prt_ctl == NULL) {
-		dev_err(&pdev->dev, "no 'reg' resource\n");
-		result = -ENXIO;
-		goto err;
-	}
-
-	p->mix_phys = res_mix->start;
-	p->mix_size = resource_size(res_mix);
-	p->agl_phys = res_agl->start;
-	p->agl_size = resource_size(res_agl);
-	p->agl_prt_ctl_phys = res_agl_prt_ctl->start;
-	p->agl_prt_ctl_size = resource_size(res_agl_prt_ctl);
-
-
-	if (!devm_request_mem_region(&pdev->dev, p->mix_phys, p->mix_size,
-				     res_mix->name)) {
-		dev_err(&pdev->dev, "request_mem_region (%s) failed\n",
-			res_mix->name);
-		result = -ENXIO;
-		goto err;
-	}
-
-	if (!devm_request_mem_region(&pdev->dev, p->agl_phys, p->agl_size,
-				     res_agl->name)) {
-		result = -ENXIO;
-		dev_err(&pdev->dev, "request_mem_region (%s) failed\n",
-			res_agl->name);
-		goto err;
-	}
-
-	if (!devm_request_mem_region(&pdev->dev, p->agl_prt_ctl_phys,
-				     p->agl_prt_ctl_size, res_agl_prt_ctl->name)) {
-		result = -ENXIO;
-		dev_err(&pdev->dev, "request_mem_region (%s) failed\n",
-			res_agl_prt_ctl->name);
+	ret = devm_ioremap_resource(&pdev->dev, res_agl_prt_ctl);
+	if (IS_ERR(ret)) {
+		result = PTR_ERR(ret);
 		goto err;
 	}
+	p->agl_prt_ctl = (u64)ret;
 
-	p->mix = (u64)devm_ioremap(&pdev->dev, p->mix_phys, p->mix_size);
-	p->agl = (u64)devm_ioremap(&pdev->dev, p->agl_phys, p->agl_size);
-	p->agl_prt_ctl = (u64)devm_ioremap(&pdev->dev, p->agl_prt_ctl_phys,
-					   p->agl_prt_ctl_size);
 	spin_lock_init(&p->lock);
 
 	skb_queue_head_init(&p->tx_list);
-- 
1.9.1
