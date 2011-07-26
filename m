From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH] net/smsc911x: add device tree probe support
Date: Tue, 26 Jul 2011 09:01:55 +0800
Message-ID: <20110726010154.GG21641@S2100-06.ap.freescale.net>
References: <1311587040-8988-1-git-send-email-shawn.guo@linaro.org>
	<20110725213723.GI26735@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches@linaro.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Shawn Guo <shawn.guo@linaro.org>, "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20110725213723.GI26735@ponder.secretlab.ca>
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

On Mon, Jul 25, 2011 at 03:37:23PM -0600, Grant Likely wrote:
> On Mon, Jul 25, 2011 at 05:44:00PM +0800, Shawn Guo wrote:
> > It adds device tree probe support for smsc911x driver.
> > 
> > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> > Cc: Grant Likely <grant.likely@secretlab.ca>
> > Cc: Steve Glendinning <steve.glendinning@smsc.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > ---
> >  Documentation/devicetree/bindings/net/smsc.txt |   34 +++++++
> >  drivers/net/smsc911x.c                         |  123 +++++++++++++++++++-----
> >  2 files changed, 132 insertions(+), 25 deletions(-)
> >  create mode 100644 Documentation/devicetree/bindings/net/smsc.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/smsc.txt b/Documentation/devicetree/bindings/net/smsc.txt
> > new file mode 100644
> > index 0000000..1920695
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/smsc.txt
> > @@ -0,0 +1,34 @@
> > +* Smart Mixed-Signal Connectivity (SMSC) LAN Controller
> > +
> > +Required properties:
> > +- compatible : Should be "smsc,lan<model>""smsc,lan"
> 
> Drop "smsc,lan".  That's far too generic.
> 
The following devices are supported by the driver.

LAN9115, LAN9116, LAN9117, LAN9118
LAN9215, LAN9216, LAN9217, LAN9218
LAN9210, LAN9211
LAN9220, LAN9221

If we only keep specific <model> as the compatible, we will have a
long match table which is actually used nowhere to distinguish the
device.

So we need some level generic compatible to save the meaningless
long match table.  What about: 

static const struct of_device_id smsc_dt_ids[] = {
        { .compatible = "smsc,lan9", },
        { /* sentinel */ }
};

Or:

static const struct of_device_id smsc_dt_ids[] = {
        { .compatible = "smsc,lan91", },
        { .compatible = "smsc,lan92", },
        { /* sentinel */ }
};

> > +- reg : Address and length of the io space for SMSC LAN
> > +- smsc-int-gpios : Should specify the GPIO for SMSC LAN interrupt line
> 
> This looks broken.  Shouldn't this be specified as a normal
> "interrupts" property?
> 
> > +- phy-mode : String, operation mode of the PHY interface.
> > +  Supported values are: "mii", "gmii", "sgmii", "tbi", "rmii",
> > +  "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid", "rtbi", "smii".
> > +
> > +Optional properties:
> > +- smsc,irq-active-high : Indicates the IRQ polarity is active-low
> > +- smsc,irq-push-pull : Indicates the IRQ type is push-pull
> > +- smsc,register-needs-shift : Indicates the register access needs shift
> > +- smsc,access-in-32bit : Indicates the access to controller is in 32-bit
> > +  mode
> 
> Currently, reg-io-width and reg-shift are being used to manipulate
> register access on ns16550 serial ports.  The same thing can be used
> here.  See bindings/tty/serial/of-serial.txt
> 
They are not exactly same.  reg-io-width and reg-shift in of-serial.txt
are giving a number, while register-needs-shift and access-in-32bit
here just tells a flag.  But if you have a strong position to make
them consistent, I can change them to reg-io-width and reg-shift and
get smsc911x parse numbers instead of flags.

> 
> > +- smsc,force-internal-phy : Forces SMSC LAN controller to use
> > +  internal PHY
> > +- smsc,force-external-phy : Forces SMSC LAN controller to use
> > +  external PHY
> 
> I would expect using an external phy would also expect a phy-device
> property to connect to the phy node.
> 
I do not understand the details.  But from the comment below in the
code, I guess the "external phy" is not external?

/* Autodetects and enables external phy if present on supported chips.
 * autodetection can be overridden by specifying SMSC911X_FORCE_INTERNAL_PHY
 * or SMSC911X_FORCE_EXTERNAL_PHY in the platform_data flags. */

> > +- smsc,save-mac-address : Indicates that mac address needs to be saved
> > +  before resetting the controller
> > +- local-mac-address : 6 bytes, mac address
> > +
> > +Examples:
> > +
> > +lan9220@f4000000 {
> > +	compatible = "smsc,lan9220", "smsc,lan";
> > +	reg = <0xf4000000 0x2000000>;
> > +	phy-mode = "mii";
> > +	smsc-int-gpios = <&gpio1 31 0>; /* GPIO2_31 */
> > +	smsc,irq-push-pull;
> > +	smsc,access-in-32bit;
> > +};
> > diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> > index b9016a3..0097048 100644
> > --- a/drivers/net/smsc911x.c
> > +++ b/drivers/net/smsc911x.c
> > @@ -53,6 +53,10 @@
> >  #include <linux/phy.h>
> >  #include <linux/smsc911x.h>
> >  #include <linux/device.h>
> > +#include <linux/of.h>
> > +#include <linux/of_device.h>
> > +#include <linux/of_gpio.h>
> > +#include <linux/of_net.h>
> >  #include "smsc911x.h"
> >  
> >  #define SMSC_CHIPNAME		"smsc911x"
> > @@ -2095,25 +2099,67 @@ static const struct smsc911x_ops shifted_smsc911x_ops = {
> >  	.tx_writefifo = smsc911x_tx_writefifo_shift,
> >  };
> >  
> > +#ifdef CONFIG_OF
> > +static int __devinit smsc911x_probe_config_dt(
> > +				struct smsc911x_platform_config *config,
> > +				struct device_node *np)
> > +{
> > +	const char *mac;
> > +
> > +	if (!np)
> > +		return -ENODEV;
> > +
> > +	config->phy_interface = of_get_phy_mode(np);
> > +
> > +	mac = of_get_mac_address(np);
> > +	if (mac)
> > +		memcpy(config->mac, mac, ETH_ALEN);
> > +
> > +	if (of_get_property(np, "smsc,irq-active-high", NULL))
> > +		config->irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_HIGH;
> > +
> > +	if (of_get_property(np, "smsc,irq-push-pull", NULL))
> > +		config->irq_type = SMSC911X_IRQ_TYPE_PUSH_PULL;
> > +
> > +	if (of_get_property(np, "smsc,register-needs-shift", NULL))
> > +		config->shift = 1;
> > +
> > +	if (of_get_property(np, "smsc,access-in-32bit", NULL))
> > +		config->flags |= SMSC911X_USE_32BIT;
> > +
> > +	if (of_get_property(np, "smsc,force-internal-phy", NULL))
> > +		config->flags |= SMSC911X_FORCE_INTERNAL_PHY;
> > +
> > +	if (of_get_property(np, "smsc,force-external-phy", NULL))
> > +		config->flags |= SMSC911X_FORCE_EXTERNAL_PHY;
> > +
> > +	if (of_get_property(np, "smsc,save-mac-address", NULL))
> > +		config->flags |= SMSC911X_SAVE_MAC_ADDRESS;
> > +
> > +	return 0;
> > +}
> > +#else
> > +static inline int smsc911x_probe_config_dt(
> > +				struct smsc911x_platform_config *config,
> > +				struct device_node *np)
> > +{
> > +	return -ENODEV;
> > +}
> > +#endif /* CONFIG_OF */
> > +
> >  static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
> >  {
> > +	struct device_node *np = pdev->dev.of_node;
> >  	struct net_device *dev;
> >  	struct smsc911x_data *pdata;
> >  	struct smsc911x_platform_config *config = pdev->dev.platform_data;
> >  	struct resource *res, *irq_res;
> >  	unsigned int intcfg = 0;
> > -	int res_size, irq_flags;
> > -	int retval;
> > +	int irq_gpio, res_size, irq_flags = 0;
> > +	int retval = 0;
> >  
> >  	pr_info("Driver version %s\n", SMSC_DRV_VERSION);
> >  
> > -	/* platform data specifies irq & dynamic bus configuration */
> > -	if (!pdev->dev.platform_data) {
> > -		pr_warn("platform_data not provided\n");
> > -		retval = -ENODEV;
> > -		goto out_0;
> > -	}
> > -
> >  	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
> >  					   "smsc911x-memory");
> >  	if (!res)
> > @@ -2125,13 +2171,6 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
> >  	}
> >  	res_size = resource_size(res);
> >  
> > -	irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> > -	if (!irq_res) {
> > -		pr_warn("Could not allocate irq resource\n");
> > -		retval = -ENODEV;
> > -		goto out_0;
> > -	}
> > -
> 
> This should still work for the device-tree situation.  Why remove it?
> 
> >  	if (!request_mem_region(res->start, res_size, SMSC_CHIPNAME)) {
> >  		retval = -EBUSY;
> >  		goto out_0;
> > @@ -2148,26 +2187,53 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
> >  
> >  	pdata = netdev_priv(dev);
> >  
> > -	dev->irq = irq_res->start;
> > -	irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
> > -	pdata->ioaddr = ioremap_nocache(res->start, res_size);
> > -
> > -	/* copy config parameters across to pdata */
> > -	memcpy(&pdata->config, config, sizeof(pdata->config));
> > +	if (np) {
> > +		irq_gpio = of_get_named_gpio(np, "smsc-int-gpios", 0);
> > +		retval = gpio_request_one(irq_gpio, GPIOF_IN, "smsc-int-gpio");
> > +		if (!retval)
> > +			dev->irq = gpio_to_irq(irq_gpio);
> 
> Yeah, that's definitely the wrong way to handle this.  If the
> device it wired to a gpio controller, then the gpio controller also
> need to be an interrupt controller to ensure that it can map interrupt
> numbers.
> 

Here it is.  Please let me know if it is what you mean.

diff --git a/arch/arm/boot/dts/imx53-ard.dts b/arch/arm/boot/dts/imx53-ard.dts
index 6a007f1..0b17af8 100644
--- a/arch/arm/boot/dts/imx53-ard.dts
+++ b/arch/arm/boot/dts/imx53-ard.dts
@@ -320,7 +320,8 @@
 			compatible = "smsc,lan9220", "smsc,lan";
 			reg = <0xf4000000 0x2000000>;
 			phy-mode = "mii";
-			smsc-int-gpios = <&gpio1 31 0>; /* GPIO2_31 */
+			interrupt-parent = <&gpio1>;
+			interrupts = <31>;
 			smsc,irq-push-pull;
 			smsc,access-in-32bit;
 		};
diff --git a/arch/arm/boot/dts/imx53.dtsi b/arch/arm/boot/dts/imx53.dtsi
index 746221c..224f67f 100644
--- a/arch/arm/boot/dts/imx53.dtsi
+++ b/arch/arm/boot/dts/imx53.dtsi
@@ -89,6 +89,8 @@
 			interrupts = <50 51>;
 			gpio-controller;
 			#gpio-cells = <2>;
+			interrupt-controller;
+			#interrupt-cells = <1>;
 		};
 
 		gpio1: gpio@53f88000 { /* GPIO2 */
@@ -97,6 +99,8 @@
 			interrupts = <52 53>;
 			gpio-controller;
 			#gpio-cells = <2>;
+			interrupt-controller;
+			#interrupt-cells = <1>;
 		};
 
 		gpio2: gpio@53f8c000 { /* GPIO3 */
@@ -105,6 +109,8 @@
 			interrupts = <54 55>;
 			gpio-controller;
 			#gpio-cells = <2>;
+			interrupt-controller;
+			#interrupt-cells = <1>;
 		};
 
 		gpio3: gpio@53f90000 { /* GPIO4 */
@@ -113,6 +119,8 @@
 			interrupts = <56 57>;
 			gpio-controller;
 			#gpio-cells = <2>;
+			interrupt-controller;
+			#interrupt-cells = <1>;
 		};
 
 		wdt@53f98000 { /* WDOG1 */
@@ -950,6 +958,8 @@
 			interrupts = <103 104>;
 			gpio-controller;
 			#gpio-cells = <2>;
+			interrupt-controller;
+			#interrupt-cells = <1>;
 		};
 
 		gpio5: gpio@53fe0000 { /* GPIO6 */
@@ -958,6 +968,8 @@
 			interrupts = <105 106>;
 			gpio-controller;
 			#gpio-cells = <2>;
+			interrupt-controller;
+			#interrupt-cells = <1>;
 		};
 
 		gpio6: gpio@53fe4000 { /* GPIO7 */
@@ -966,6 +978,8 @@
 			interrupts = <107 108>;
 			gpio-controller;
 			#gpio-cells = <2>;
+			interrupt-controller;
+			#interrupt-cells = <1>;
 		};
 
 		i2c@53fec000 { /* I2C3 */
diff --git a/arch/arm/mach-mx5/imx53-dt.c b/arch/arm/mach-mx5/imx53-dt.c
index ac06f04..04dc1ab 100644
--- a/arch/arm/mach-mx5/imx53-dt.c
+++ b/arch/arm/mach-mx5/imx53-dt.c
@@ -51,6 +51,11 @@ static const struct of_device_id imx53_tzic_of_match[] __initconst = {
 	{ /* sentinel */ }
 };
 
+static const struct of_device_id imx53_gpio_of_match[] __initconst = {
+	{ .compatible = "fsl,imx53-gpio", },
+	{ /* sentinel */ }
+};
+
 static const struct of_device_id imx53_iomuxc_of_match[] __initconst = {
 	{ .compatible = "fsl,imx53-iomuxc", },
 	{ /* sentinel */ }
@@ -90,12 +95,28 @@ static void __init imx53_ard_eim_config(void)
 
 static void __init imx53_dt_init(void)
 {
+	int gpio_irq = MXC_INTERNAL_IRQS + ARCH_NR_GPIOS;
+
 	if (of_machine_is_compatible("fsl,imx53-ard"))
 		imx53_ard_eim_config();
 
 	mxc_iomuxc_dt_init(imx53_iomuxc_of_match);
 
 	irq_domain_generate_simple(imx53_tzic_of_match, MX53_TZIC_BASE_ADDR, 0);
+	gpio_irq -= 32;
+	irq_domain_generate_simple(imx53_gpio_of_match, MX53_GPIO1_BASE_ADDR, gpio_irq);
+	gpio_irq -= 32;
+	irq_domain_generate_simple(imx53_gpio_of_match, MX53_GPIO2_BASE_ADDR, gpio_irq);
+	gpio_irq -= 32;
+	irq_domain_generate_simple(imx53_gpio_of_match, MX53_GPIO3_BASE_ADDR, gpio_irq);
+	gpio_irq -= 32;
+	irq_domain_generate_simple(imx53_gpio_of_match, MX53_GPIO4_BASE_ADDR, gpio_irq);
+	gpio_irq -= 32;
+	irq_domain_generate_simple(imx53_gpio_of_match, MX53_GPIO5_BASE_ADDR, gpio_irq);
+	gpio_irq -= 32;
+	irq_domain_generate_simple(imx53_gpio_of_match, MX53_GPIO6_BASE_ADDR, gpio_irq);
+	gpio_irq -= 32;
+	irq_domain_generate_simple(imx53_gpio_of_match, MX53_GPIO7_BASE_ADDR, gpio_irq);
 
 	of_platform_populate(NULL, of_default_bus_match_table,
 			     imx53_auxdata_lookup, NULL);
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 0097048..6dd025e 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -2187,25 +2187,10 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	pdata = netdev_priv(dev);
 
-	if (np) {
-		irq_gpio = of_get_named_gpio(np, "smsc-int-gpios", 0);
-		retval = gpio_request_one(irq_gpio, GPIOF_IN, "smsc-int-gpio");
-		if (!retval)
-			dev->irq = gpio_to_irq(irq_gpio);
-	} else {
-		irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-		if (irq_res) {
-			dev->irq = irq_res->start;
-			irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
-		} else {
-			retval = -ENODEV;
-		}
-	}
-
-	if (retval) {
-		SMSC_WARN(pdata, probe, "Error smsc911x irq not found");
-		retval = -EINVAL;
-		goto out_free_netdev_2;
+	irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (irq_res) {
+		dev->irq = irq_res->start;
+		irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
 	}
 
 	pdata->ioaddr = ioremap_nocache(res->start, res_size);


> > +	} else {
> > +		irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> > +		if (irq_res) {
> > +			dev->irq = irq_res->start;
> > +			irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
> > +		} else {
> > +			retval = -ENODEV;
> > +		}
> > +	}
> >  
> > -	pdata->dev = dev;
> > -	pdata->msg_enable = ((1 << debug) - 1);
> > +	if (retval) {
> > +		SMSC_WARN(pdata, probe, "Error smsc911x irq not found");
> > +		retval = -EINVAL;
> > +		goto out_free_netdev_2;
> > +	}
> >  
> > +	pdata->ioaddr = ioremap_nocache(res->start, res_size);
> >  	if (pdata->ioaddr == NULL) {
> >  		SMSC_WARN(pdata, probe, "Error smsc911x base address invalid");
> >  		retval = -ENOMEM;
> >  		goto out_free_netdev_2;
> >  	}
> >  
> > +	pdata->dev = dev;
> > +	pdata->msg_enable = ((1 << debug) - 1);
> > +
> > +	retval = smsc911x_probe_config_dt(&pdata->config, np);
> > +	if (retval && config) {
> > +		/* copy config parameters across to pdata */
> > +		memcpy(&pdata->config, config, sizeof(pdata->config));
> > +		retval = 0;
> > +	}
> > +
> > +	if (retval) {
> > +		SMSC_WARN(pdata, probe, "Error smsc911x config not found");
> > +		goto out_unmap_io_3;
> > +	}
> > +
> >  	/* assume standard, non-shifted, access to HW registers */
> >  	pdata->ops = &standard_smsc911x_ops;
> >  	/* apply the right access if shifting is needed */
> > -	if (config->shift)
> > +	if (pdata->config.shift)
> >  		pdata->ops = &shifted_smsc911x_ops;
> >  
> >  	retval = smsc911x_init(dev);
> > @@ -2314,6 +2380,12 @@ static const struct dev_pm_ops smsc911x_pm_ops = {
> >  #define SMSC911X_PM_OPS NULL
> >  #endif
> >  
> > +static const struct of_device_id smsc_dt_ids[] = {
> > +	{ .compatible = "smsc,lan", },
> 
> As mentioned above, "smsc,lan" is far too generic.
> 
Again

static const struct of_device_id smsc_dt_ids[] = {
        { .compatible = "smsc,lan9", },
        { /* sentinel */ }
};

Or:

static const struct of_device_id smsc_dt_ids[] = {
        { .compatible = "smsc,lan91", },
        { .compatible = "smsc,lan92", },
        { /* sentinel */ }
};

You pick :)

-- 
Regards,
Shawn
