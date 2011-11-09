From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH Kernel-3.1.0] mdio-gpio: Add reset functionality to mdio-gpio driver.
Date: Wed,  9 Nov 2011 13:38:51 +0000
Message-ID: <1320845931-25782-1-git-send-email-srinivas.kandagatla@st.com>
Cc: davem@davemloft.net, stuart.menefy@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:39396 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753263Ab1KINnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 08:43:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds phy reset functionality to mdio-bitbang driver. Now
mdio_gpio_platform_data has new member as function pointer which can be
filled at the bsp level for a callback from phy infrastructure. Also the
mdio-bitbang driver fills-in the reset function of mii_bus structure.

Without this patch the bsp level code has to takecare of the reseting
PHY's on the bus, which become bit hacky for every bsp and
phy-infrastructure is ignored aswell.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Cc: Stuart Menefy <stuart.menefy@st.com>
---
Hi All,
Recently In my attempt to get mdio-bitbang driver working to debug 
an issue, I have noticed that mii bus reset functionality is 
missing in the mdio-bitbang driver.
This functionality is very much needed to reset devices on the mii-bus. 
Without this functionality BSP level code has to add code to do reset 
before the mdio-bitbang driver probe is called.

As mii-bus infrastructure already provides the mii-bus drivers to 
support reset function callbacks, Its much neat way to get reset 
functionality support in to mdio-bitbang driver.

This patch adds reset functionality to mdio-gpio driver.

thanks,
srini


 drivers/net/phy/mdio-bitbang.c |    9 +++++++++
 drivers/net/phy/mdio-gpio.c    |    1 +
 include/linux/mdio-bitbang.h   |    3 +++
 include/linux/mdio-gpio.h      |    2 ++
 4 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
index 6539189..4b99cfc 100644
--- a/drivers/net/phy/mdio-bitbang.c
+++ b/drivers/net/phy/mdio-bitbang.c
@@ -202,6 +202,14 @@ static int mdiobb_write(struct mii_bus *bus, int phy, int reg, u16 val)
 	return 0;
 }
 
+static int mdiobb_reset(struct mii_bus *bus)
+{
+	struct mdiobb_ctrl *ctrl = bus->priv;
+	if (ctrl->ops->reset)
+		ctrl->ops->reset(bus);
+	return 0;
+}
+
 struct mii_bus *alloc_mdio_bitbang(struct mdiobb_ctrl *ctrl)
 {
 	struct mii_bus *bus;
@@ -214,6 +222,7 @@ struct mii_bus *alloc_mdio_bitbang(struct mdiobb_ctrl *ctrl)
 
 	bus->read = mdiobb_read;
 	bus->write = mdiobb_write;
+	bus->reset = mdiobb_reset;
 	bus->priv = ctrl;
 
 	return bus;
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 2843c90..367e0d0 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -97,6 +97,7 @@ static struct mii_bus * __devinit mdio_gpio_bus_init(struct device *dev,
 	bitbang->ctrl.ops = &mdio_gpio_ops;
 	bitbang->mdc = pdata->mdc;
 	bitbang->mdio = pdata->mdio;
+	mdio_gpio_ops.reset = pdata->reset;
 
 	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
 	if (!new_bus)
diff --git a/include/linux/mdio-bitbang.h b/include/linux/mdio-bitbang.h
index 8ea9a42..7c88677 100644
--- a/include/linux/mdio-bitbang.h
+++ b/include/linux/mdio-bitbang.h
@@ -27,6 +27,9 @@ struct mdiobb_ops {
 
 	/* Retrieve the state Management Data I/O pin. */
 	int (*get_mdio_data)(struct mdiobb_ctrl *ctrl);
+
+	/* reset callback */
+	int (*reset)(struct mii_bus *bus);
 };
 
 struct mdiobb_ctrl {
diff --git a/include/linux/mdio-gpio.h b/include/linux/mdio-gpio.h
index e9d3fdf..7c9fe3c 100644
--- a/include/linux/mdio-gpio.h
+++ b/include/linux/mdio-gpio.h
@@ -20,6 +20,8 @@ struct mdio_gpio_platform_data {
 
 	unsigned int phy_mask;
 	int irqs[PHY_MAX_ADDR];
+	/* reset callback */
+	int (*reset)(struct mii_bus *bus);
 };
 
 #endif /* __LINUX_MDIO_GPIO_H */
-- 
1.6.3.3
