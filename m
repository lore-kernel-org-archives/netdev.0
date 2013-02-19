From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: [PATCH v2 5/5] usb: musb: omap2430: use the new generic PHY framework
Date: Tue, 19 Feb 2013 11:23:18 +0530
Message-ID: <1361253198-7401-6-git-send-email-kishon@ti.com>
References: <1361253198-7401-1-git-send-email-kishon@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <rob@landley.net>, <tony@atomide.com>, <linux@arm.linux.org.uk>,
 <eballetbo@gmail.com>, <javier@dowhile0.org>, <kishon@ti.com>,
 <balbi@ti.com>, <gregkh@linuxfoundation.org>,
 <akpm@linux-foundation.org>, <mchehab@redhat.com>, <cesarb@cesarb.net>,
 <davem@davemloft.net>, <arnd@arndb.de>, <santosh.shilimkar@ti.com>,
 <broonie@opensource.wolfsonmicro.com>, <swarren@nvidia.com>,
 <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-arm-kernel@lists.infradead.org>, <linux-omap@vger.kernel.org>,
 <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1361253198-7401-1-git-send-email-kishon@ti.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Use the generic PHY framework API to get the PHY. The usb_phy_set_suspend
and usb_phy_set_resume is replaced with phy_suspend and phy_resume to
align with the new PHY framework.

musb->xceiv can't be removed as of now because musb core uses xceiv.state and
xceiv.otg. Once there is a separate state machine to handle otg, these can be
moved out of xceiv and then we can start using the generic PHY framework.

Signed-off-by: Kishon Vijay Abraham I <kishon@ti.com>
---
 drivers/usb/musb/musb_core.h |    2 ++
 drivers/usb/musb/omap2430.c  |   22 ++++++++++++++++------
 2 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/usb/musb/musb_core.h b/drivers/usb/musb/musb_core.h
index 7fb4819..78251fd 100644
--- a/drivers/usb/musb/musb_core.h
+++ b/drivers/usb/musb/musb_core.h
@@ -46,6 +46,7 @@
 #include <linux/usb.h>
 #include <linux/usb/otg.h>
 #include <linux/usb/musb.h>
+#include <linux/phy/phy.h>
 
 struct musb;
 struct musb_hw_ep;
@@ -357,6 +358,7 @@ struct musb {
 	u16			int_tx;
 
 	struct usb_phy		*xceiv;
+	struct phy		*phy;
 
 	int nIrq;
 	unsigned		irq_wake:1;
diff --git a/drivers/usb/musb/omap2430.c b/drivers/usb/musb/omap2430.c
index 1762354..99378af 100644
--- a/drivers/usb/musb/omap2430.c
+++ b/drivers/usb/musb/omap2430.c
@@ -345,14 +345,24 @@ static int omap2430_musb_init(struct musb *musb)
 	 * up through ULPI.  TWL4030-family PMICs include one,
 	 * which needs a driver, drivers aren't always needed.
 	 */
-	if (dev->parent->of_node)
+	if (dev->parent->of_node) {
+		musb->phy = devm_of_phy_get(dev->parent, "usb-phy", 0);
+
+		/* We can't totally remove musb->xceiv as of now because
+		 * musb core uses xceiv.state and xceiv.otg. Once we have
+		 * a separate state machine to handle otg, these can be moved
+		 * out of xceiv and then we can start using the generic PHY
+		 * framework
+		 */
 		musb->xceiv = devm_usb_get_phy_by_phandle(dev->parent,
 		    "usb-phy", 0);
-	else
+	} else {
 		musb->xceiv = devm_usb_get_phy_dev(dev, 0);
+		musb->phy = devm_phy_get(dev, 0);
+	}
 
-	if (IS_ERR_OR_NULL(musb->xceiv)) {
-		pr_err("HS USB OTG: no transceiver configured\n");
+	if (IS_ERR_OR_NULL(musb->xceiv) || IS_ERR_OR_NULL(musb->phy)) {
+		dev_err(dev, "no transceiver configured\n");
 		return -EPROBE_DEFER;
 	}
 
@@ -608,7 +618,7 @@ static int omap2430_runtime_suspend(struct device *dev)
 				OTG_INTERFSEL);
 
 		omap2430_low_level_exit(musb);
-		usb_phy_set_suspend(musb->xceiv, 1);
+		phy_suspend(musb->phy);
 	}
 
 	return 0;
@@ -624,7 +634,7 @@ static int omap2430_runtime_resume(struct device *dev)
 		musb_writel(musb->mregs, OTG_INTERFSEL,
 				musb->context.otg_interfsel);
 
-		usb_phy_set_suspend(musb->xceiv, 0);
+		phy_resume(musb->phy);
 	}
 
 	return 0;
-- 
1.7.10.4
