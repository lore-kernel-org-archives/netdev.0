From: Sebastian Reichel <sre@debian.org>
Subject: [PATCH 3/4] wl1251: spi: add vio regulator support
Date: Sun, 27 Oct 2013 17:14:28 +0100
Message-ID: <1382890469-25286-4-git-send-email-sre@debian.org>
References: <1382890469-25286-1-git-send-email-sre@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Russell King <linux@arm.linux.org.uk>, Pawel Moll <pawel.moll@arm.com>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>, Tony Lindgren <tony@atomide.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Stephen Warren <swarren@wwwdotorg.org>, linux-doc@vger.kernel.org,
 "John W. Linville" <linville@tuxdriver.com>,
 Rob Herring <rob.herring@calxeda.com>, linux-kernel@vger.kernel.org,
 Sachin Kamat <sachin.kamat@linaro.org>, Bill Pemberton <wfp5p@virginia.edu>,
 Sebastian Reichel <sre@debian.org>, Felipe Balbi <balbi@ti.com>,
 Rob Landley <rob@landley.net>, netdev@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-omap@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: Sebastian Reichel <sre@ring0.de>, Luciano Coelho <luca@coelho.fi>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1382890469-25286-1-git-send-email-sre@debian.org>
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

This patch adds support for requesting the regulator powering
the vio pin.

The patch also adds the regulator for the all boards using the
wl1251 in spi mode (only the Nokia N900).

Signed-off-by: Sebastian Reichel <sre@debian.org>
---
 arch/arm/mach-omap2/board-rx51-peripherals.c |  2 ++
 drivers/net/wireless/ti/wl1251/spi.c         | 19 +++++++++++++++++--
 drivers/net/wireless/ti/wl1251/wl1251.h      |  2 ++
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mach-omap2/board-rx51-peripherals.c b/arch/arm/mach-omap2/board-rx51-peripherals.c
index b9d95dd..a791fef 100644
--- a/arch/arm/mach-omap2/board-rx51-peripherals.c
+++ b/arch/arm/mach-omap2/board-rx51-peripherals.c
@@ -552,6 +552,8 @@ static struct regulator_consumer_supply rx51_vio_supplies[] = {
 	REGULATOR_SUPPLY("vio", "2-0063"),
 	/* lis3lv02d */
 	REGULATOR_SUPPLY("Vdd_IO", "3-001d"),
+	/* wl1251 */
+	REGULATOR_SUPPLY("vio", "spi4.0"),
 };
 
 static struct regulator_consumer_supply rx51_vaux1_consumers[] = {
diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index 9a2df9d..efea57a 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -27,6 +27,7 @@
 #include <linux/spi/spi.h>
 #include <linux/wl12xx.h>
 #include <linux/gpio.h>
+#include <linux/regulator/consumer.h>
 
 #include "wl1251.h"
 #include "reg.h"
@@ -306,13 +307,26 @@ static int wl1251_spi_probe(struct spi_device *spi)
 
 	irq_set_irq_type(wl->irq, IRQ_TYPE_EDGE_RISING);
 
-	ret = wl1251_init_ieee80211(wl);
+	wl->vio = devm_regulator_get(&spi->dev, "vio");
+	if (IS_ERR(wl->vio)) {
+		ret = PTR_ERR(wl->vio);
+		wl1251_error("vio regulator missing: %d", ret);
+		goto out_free;
+	}
+
+	ret = regulator_enable(wl->vio);
 	if (ret)
 		goto out_free;
 
+	ret = wl1251_init_ieee80211(wl);
+	if (ret)
+		goto disable_regulator;
+
 	return 0;
 
- out_free:
+disable_regulator:
+	regulator_disable(wl->vio);
+out_free:
 	ieee80211_free_hw(hw);
 
 	return ret;
@@ -324,6 +338,7 @@ static int wl1251_spi_remove(struct spi_device *spi)
 
 	free_irq(wl->irq, wl);
 	wl1251_free_hw(wl);
+	regulator_disable(wl->vio);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h b/drivers/net/wireless/ti/wl1251/wl1251.h
index 5e9808c..010718b 100644
--- a/drivers/net/wireless/ti/wl1251/wl1251.h
+++ b/drivers/net/wireless/ti/wl1251/wl1251.h
@@ -279,6 +279,8 @@ struct wl1251 {
 	int irq;
 	bool use_eeprom;
 
+	struct regulator *vio;
+
 	spinlock_t wl_lock;
 
 	enum wl1251_state state;
-- 
1.8.4.rc3
