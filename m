From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH 3/4] fec: add support for Freescale i.MX25 PDK (3DS)
Date: Mon, 14 Dec 2009 12:19:41 +0200
Message-ID: <fb518184b206ec2727deda111cc5364134ace69a.1260785451.git.baruch@tkos.co.il>
References: <cover.1260785451.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Baruch Siach <baruch@tkos.co.il>,
	linux-arm-kernel@lists.infradead.org
To: Sascha Hauer <kernel@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.1260785451.git.baruch@tkos.co.il>
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

The i.MX25 PDK uses RMII to communicate with its PHY. This patch adds the
necessary bits to make the i.MX25 talk RMII.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 drivers/net/fec.c |   22 ++++++++++++++++++++++
 drivers/net/fec.h |    2 ++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 16a1d58..65c43d3 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -51,6 +51,7 @@
 #include "fec.h"
 
 #ifdef CONFIG_ARCH_MXC
+#include <asm/mach-types.h>
 #include <mach/hardware.h>
 #define FEC_ALIGNMENT	0xf
 #else
@@ -1722,6 +1723,25 @@ static int fec_enet_init(struct net_device *dev, int index)
 	return 0;
 }
 
+static void fec_localhw_setup(struct net_device *dev)
+{
+	struct fec_enet_private *fep = netdev_priv(dev);
+
+	if (!machine_is_mx25_3ds())
+		return;
+
+	/* disable the gasket and wait */
+	writel(0, fep->hwp + FEC_MIIGSK_ENR);
+	while (readl(fep->hwp + FEC_MIIGSK_ENR) & 4)
+		udelay(1);
+
+	/* configure the gasket for RMII, 50 MHz, no loopback, no echo */
+	writel(1, fep->hwp + FEC_MIIGSK_CFGR);
+
+	/* re-enable the gasket */
+	writel(2, fep->hwp + FEC_MIIGSK_ENR);
+}
+
 /* This function is called to start or restart the FEC during a link
  * change.  This only happens when switching between half and full
  * duplex.
@@ -1810,6 +1830,8 @@ fec_restart(struct net_device *dev, int duplex)
 	/* Set MII speed */
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
+	fec_localhw_setup(dev);
+
 	/* And last, enable the transmit and receive processing */
 	writel(2, fep->hwp + FEC_ECNTRL);
 	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
diff --git a/drivers/net/fec.h b/drivers/net/fec.h
index cc47f3f..2c48b25 100644
--- a/drivers/net/fec.h
+++ b/drivers/net/fec.h
@@ -43,6 +43,8 @@
 #define FEC_R_DES_START		0x180 /* Receive descriptor ring */
 #define FEC_X_DES_START		0x184 /* Transmit descriptor ring */
 #define FEC_R_BUFF_SIZE		0x188 /* Maximum receive buff size */
+#define FEC_MIIGSK_CFGR		0x300 /* MIIGSK Configuration reg */
+#define FEC_MIIGSK_ENR		0x308 /* MIIGSK Enable reg */
 
 #else
 
-- 
1.6.5
