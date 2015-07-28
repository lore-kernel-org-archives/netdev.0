From: mohun106@gmail.com
Subject: [PATCH 2/3] net: mdio-octeon: Fix octeon_mdiobus_probe function for
 return values
Date: Mon, 27 Jul 2015 19:14:42 -0700
Message-ID: <1438049683-10630-3-git-send-email-mohun106@gmail.com>
References: <1438049683-10630-1-git-send-email-mohun106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
 Tomasz Nowicki <tomasz.nowicki@linaro.org>
To: f.fainelli@gmail.com, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1438049683-10630-1-git-send-email-mohun106@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>

This patch fixes a possible crash in the octeon_mdiobus_probe function
if the return values are not handled properly.

Signed-off-by: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>
Signed-off-by: Tomasz Nowicki <tomasz.nowicki@linaro.org>
---
 drivers/net/phy/mdio-octeon.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index 507aade..428ae75 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -277,24 +277,28 @@ static int octeon_mdiobus_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	res_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-
 	if (res_mem == NULL) {
 		dev_err(&pdev->dev, "found no memory resource\n");
-		err = -ENXIO;
-		goto fail;
+		return -ENXIO;
 	}
+
 	bus->mdio_phys = res_mem->start;
 	bus->regsize = resource_size(res_mem);
+
 	if (!devm_request_mem_region(&pdev->dev, bus->mdio_phys, bus->regsize,
 				     res_mem->name)) {
 		dev_err(&pdev->dev, "request_mem_region failed\n");
-		goto fail;
+		return -ENXIO;
 	}
+
 	bus->register_base =
 		(u64)devm_ioremap(&pdev->dev, bus->mdio_phys, bus->regsize);
+	if (!bus->register_base) {
+		dev_err(&pdev->dev, "dev_ioremap failed\n");
+		return -ENOMEM;
+	}
 
 	bus->mii_bus = mdiobus_alloc();
-
 	if (!bus->mii_bus)
 		goto fail;
 
-- 
1.7.1
