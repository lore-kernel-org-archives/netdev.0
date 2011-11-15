From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: Re: [PATCH Kernel-3.1.0] mdio-gpio: Add reset functionality to mdio-gpio
 driver.
Date: Tue, 15 Nov 2011 12:07:36 +0000
Message-ID: <4EC25608.8070308@st.com>
References: <1320845931-25782-1-git-send-email-srinivas.kandagatla@st.com> <20111114.144222.2216968580935980384.davem@davemloft.net>
Reply-To: srinivas.kandagatla@st.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060506020005090500030509"
Cc: netdev@vger.kernel.org, stuart.menefy@st.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:49498 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1749667Ab1KOMLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 07:11:41 -0500
In-Reply-To: <20111114.144222.2216968580935980384.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060506020005090500030509
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


Hi Dave,
Thanks for the comments,

David Miller wrote:
> From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
> Date: Wed,  9 Nov 2011 13:38:51 +0000
>
>> +	mdio_gpio_ops.reset = pdata->reset;
>
> What if I have multiple types of devices backing a mdio_gpio, each using
> different reset operations?
>
> You can't write this variable method into a globally used set of ops.
I agree with your comment.
Here is the modified patch, which moves the reset function pointer to
mdiobb_ctrl struct.

Thanks
srini



--------------060506020005090500030509
Content-Type: text/x-patch;
 name="0001-mdio-gpio-Add-reset-functionality-to-mdio-gpio-drive.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-mdio-gpio-Add-reset-functionality-to-mdio-gpio-drive.pa";
 filename*1="tch"

>From ea136182ac86535252bed85b1c465ff8cf586f60 Mon Sep 17 00:00:00 2001
From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Date: Tue, 15 Nov 2011 11:54:15 +0000
Subject: [PATCH Kernel-3.1.0] mdio-gpio: Add reset functionality to mdio-gpio driver(v2).

This patch adds phy reset functionality to mdio-gpio driver. Now
mdio_gpio_platform_data has new member as function pointer which can be
filled at the bsp level for a callback from phy infrastructure. Also the
mdio-bitbang driver fills-in the reset function of mii_bus structure.

Without this patch the bsp level code has to takecare of the reseting
PHY's on the bus, which become bit hacky for every bsp and
phy-infrastructure is ignored aswell.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/phy/mdio-bitbang.c |    9 +++++++++
 drivers/net/phy/mdio-gpio.c    |    1 +
 include/linux/mdio-bitbang.h   |    2 ++
 include/linux/mdio-gpio.h      |    2 ++
 4 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
index 6539189..daec9b0 100644
--- a/drivers/net/phy/mdio-bitbang.c
+++ b/drivers/net/phy/mdio-bitbang.c
@@ -202,6 +202,14 @@ static int mdiobb_write(struct mii_bus *bus, int phy, int reg, u16 val)
 	return 0;
 }
 
+static int mdiobb_reset(struct mii_bus *bus)
+{
+	struct mdiobb_ctrl *ctrl = bus->priv;
+	if (ctrl->reset)
+		ctrl->reset(bus);
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
index 2843c90..89c5a3e 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -95,6 +95,7 @@ static struct mii_bus * __devinit mdio_gpio_bus_init(struct device *dev,
 		goto out;
 
 	bitbang->ctrl.ops = &mdio_gpio_ops;
+	bitbang->ctrl.reset = pdata->reset;
 	bitbang->mdc = pdata->mdc;
 	bitbang->mdio = pdata->mdio;
 
diff --git a/include/linux/mdio-bitbang.h b/include/linux/mdio-bitbang.h
index 8ea9a42..e8e7e1d 100644
--- a/include/linux/mdio-bitbang.h
+++ b/include/linux/mdio-bitbang.h
@@ -31,6 +31,8 @@ struct mdiobb_ops {
 
 struct mdiobb_ctrl {
 	const struct mdiobb_ops *ops;
+	/* reset callback */
+	int (*reset)(struct mii_bus *bus);
 };
 
 /* The returned bus is not yet registered with the phy layer. */
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


--------------060506020005090500030509--
