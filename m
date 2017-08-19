From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC net] fsl/man: Inherit parent device and of_node
Date: Fri, 18 Aug 2017 17:12:55 -0700
Message-ID: <20170819001255.20755-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, madalin.bucur@nxp.com,
        junote@outlook.com, igal.liberman@freescale.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34960 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdHSAM7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 20:12:59 -0400
Received: by mail-qk0-f196.google.com with SMTP id a77so10109357qkb.2
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 17:12:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
Madalin,

After this patch, Junote was able to get the DSA switch probed correctly however
he was also observing a resource conflict, but I don't think this patch is responsible
for that per-se, please review:

iommu: Adding device ffe488000.port to group 21
fsl_mac ffe4e0000.ethernet: FMan dTSEC version: 0x08240101
fsl_mac ffe4e0000.ethernet: FMan MAC address: 00:04:9f:ef:05:01
fsl_mac dpaa-ethernet.0: __devm_request_mem_region(mac) failed
fsl_mac: probe of dpaa-ethernet.0 failed with error -16
fsl_mac dpaa-ethernet.0: __devm_request_mem_region(mac) failed
fsl_mac: probe of dpaa-ethernet.0 failed with error -16
fsl_dpa dpaa-ethernet.0 eth0: Probed interface eth0

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
2.11.0
