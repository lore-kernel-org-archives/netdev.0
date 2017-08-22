From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] fsl/man: Inherit parent device and of_node
Date: Tue, 22 Aug 2017 15:24:47 -0700
Message-ID: <20170822222447.16754-1-f.fainelli@gmail.com>
Cc: junote@outlook.com, madalin.bucur@nxp.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Junote Cai reported that he was not able to get a DSA setup involving the
Freescale DPAA/FMAN driver to work and narrowed it down to
of_find_net_device_by_node(). This function requires the network device's
device reference to be correctly set which is the case here, though we have
lost any device_node association there.

The problem is that dpaa_eth_add_device() allocates a "dpaa-ethernet" platform
device, and later on dpaa_eth_probe() is called but SET_NETDEV_DEV() won't be
propagating &pdev->dev.of_node properly. Fix this by inherenting both the parent
device and the of_node when dpaa_eth_add_device() creates the platform device.

Fixes: 3933961682a3 ("fsl/fman: Add FMan MAC driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/freescale/fman/mac.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fman/mac.c b/drivers/net/ethernet/freescale/fman/mac.c
index 6e67d22fd0d5..1c7da16ad0ff 100644
--- a/drivers/net/ethernet/freescale/fman/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac.c
@@ -623,6 +623,8 @@ static struct platform_device *dpaa_eth_add_device(int fman_id,
 		goto no_mem;
 	}
 
+	pdev->dev.of_node = node;
+	pdev->dev.parent = priv->dev;
 	set_dma_ops(&pdev->dev, get_dma_ops(priv->dev));
 
 	ret = platform_device_add_data(pdev, &data, sizeof(data));
-- 
2.9.3
