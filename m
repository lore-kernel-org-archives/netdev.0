From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Tue, 21 Jun 2011 21:55:59 +0800
Message-ID: <20110621135558.GB9228@S2101-09.ap.freescale.net>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
 <1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
 <20110618161934.GH8195@ponder.secretlab.ca>
 <20110619073000.GA23171@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <patches@linaro.org>, <netdev@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	Jason Liu <jason.hui@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	<linux-arm-kernel@lists.infradead.org>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:36183
	"EHLO AM1EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752978Ab1FUNpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 09:45:51 -0400
Content-Disposition: inline
In-Reply-To: <20110619073000.GA23171@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Grant,

I just gave a try to use aliases node for identify the device index.
Please take a look and let me know if it's what you expect.

On Sun, Jun 19, 2011 at 03:30:02PM +0800, Shawn Guo wrote:
[...]
> > >  
> > > +#ifdef CONFIG_OF
> > > +static int serial_imx_probe_dt(struct imx_port *sport,
> > > +		struct platform_device *pdev)
> > > +{
> > > +	struct device_node *node = pdev->dev.of_node;
> > > +	const __be32 *line;
> > > +
> > > +	if (!node)
> > > +		return -ENODEV;
> > > +
> > > +	line = of_get_property(node, "id", NULL);
> > > +	if (!line)
> > > +		return -ENODEV;
> > > +
> > > +	sport->port.line = be32_to_cpup(line) - 1;
> > 
> > Hmmm, I really would like to be rid of this.  Instead, if uarts must
> > be enumerated, the driver should look for a /aliases/uart* property
> > that matches the of_node.  Doing it that way is already established in
> > the OpenFirmware documentation, and it ensures there are no overlaps
> > in the global namespace.
> > 
> 
> I just gave one more try to avoid using 'aliases', and you gave a
> 'no' again.  Now, I know how hard you are on this.  Okay, I start
> thinking about your suggestion seriously :)
> 
> > We do need some infrastructure to make that easier though.  Would you
> > have time to help put that together?
> > 
> Ok, I will give it a try.
> 

diff --git a/arch/arm/boot/dts/imx51-babbage.dts b/arch/arm/boot/dts/imx51-babbage.dts
index da0381a..f4a5c3c 100644
--- a/arch/arm/boot/dts/imx51-babbage.dts
+++ b/arch/arm/boot/dts/imx51-babbage.dts
@@ -18,6 +18,12 @@
 	compatible = "fsl,imx51-babbage", "fsl,imx51";
 	interrupt-parent = <&tzic>;
 
+	aliases {
+		serial0 = &uart0;
+		serial1 = &uart1;
+		serial2 = &uart2;
+	};
+
 	chosen {
 		bootargs = "console=ttymxc0,115200 root=/dev/mmcblk0p3 rootwait";
 	};
@@ -47,29 +53,29 @@
 			reg = <0x70000000 0x40000>;
 			ranges;
 
-			uart@7000c000 {
+			uart2: uart@7000c000 {
 				compatible = "fsl,imx51-uart", "fsl,imx21-uart";
 				reg = <0x7000c000 0x4000>;
 				interrupts = <33>;
 				id = <3>;
-				fsl,has-rts-cts;
+				fsl,uart-has-rtscts;
 			};
 		};
 
-		uart@73fbc000 {
+		uart0: uart@73fbc000 {
 			compatible = "fsl,imx51-uart", "fsl,imx21-uart";
 			reg = <0x73fbc000 0x4000>;
 			interrupts = <31>;
 			id = <1>;
-			fsl,has-rts-cts;
+			fsl,uart-has-rtscts;
 		};
 
-		uart@73fc0000 {
+		uart1: uart@73fc0000 {
 			compatible = "fsl,imx51-uart", "fsl,imx21-uart";
 			reg = <0x73fc0000 0x4000>;
 			interrupts = <32>;
 			id = <2>;
-			fsl,has-rts-cts;
+			fsl,uart-has-rtscts;
 		};
 	};
 
diff --git a/drivers/of/base.c b/drivers/of/base.c
index 632ebae..13df5d2 100644
--- a/drivers/of/base.c
+++ b/drivers/of/base.c
@@ -737,6 +737,37 @@ err0:
 EXPORT_SYMBOL(of_parse_phandles_with_args);
 
 /**
+ *	of_get_device_index - Get device index by looking up "aliases" node
+ *	@np:	Pointer to device node that asks for device index
+ *	@name:	The device alias without index number
+ *
+ *	Returns the device index if find it, else returns -ENODEV.
+ */
+int of_get_device_index(struct device_node *np, const char *alias)
+{
+	struct device_node *aliases = of_find_node_by_name(NULL, "aliases");
+	struct property *prop;
+	char name[32];
+	int index = 0;
+
+	if (!aliases)
+		return -ENODEV;
+
+	while (1) {
+		snprintf(name, sizeof(name), "%s%d", alias, index);
+		prop = of_find_property(aliases, name, NULL);
+		if (!prop)
+			return -ENODEV;
+		if (np == of_find_node_by_path(prop->value))
+			break;
+		index++;
+	}
+
+	return index;
+}
+EXPORT_SYMBOL(of_get_device_index);
+
+/**
  * prom_add_property - Add a property to a node
  */
 int prom_add_property(struct device_node *np, struct property *prop)
diff --git a/drivers/tty/serial/imx.c b/drivers/tty/serial/imx.c
index da436e0..852668f 100644
--- a/drivers/tty/serial/imx.c
+++ b/drivers/tty/serial/imx.c
@@ -1271,18 +1271,18 @@ static int serial_imx_probe_dt(struct imx_port *sport,
 	struct device_node *node = pdev->dev.of_node;
 	const struct of_device_id *of_id =
 			of_match_device(imx_uart_dt_ids, &pdev->dev);
-	const __be32 *line;
+	int line;
 
 	if (!node)
 		return -ENODEV;
 
-	line = of_get_property(node, "id", NULL);
-	if (!line)
+	line = of_get_device_index(node, "serial");
+	if (IS_ERR_VALUE(line))
 		return -ENODEV;
 
-	sport->port.line = be32_to_cpup(line) - 1;
+	sport->port.line = line;
 
-	if (of_get_property(node, "fsl,has-rts-cts", NULL))
+	if (of_get_property(node, "fsl,uart-has-rtscts", NULL))
 		sport->have_rtscts = 1;
 
 	if (of_get_property(node, "fsl,irda-mode", NULL))
diff --git a/include/linux/of.h b/include/linux/of.h
index bfc0ed1..3153752 100644
--- a/include/linux/of.h
+++ b/include/linux/of.h
@@ -213,6 +213,8 @@ extern int of_parse_phandles_with_args(struct device_node *np,
 	const char *list_name, const char *cells_name, int index,
 	struct device_node **out_node, const void **out_args);
 
+extern int of_get_device_index(struct device_node *np, const char *alias);
+
 extern int of_machine_is_compatible(const char *compat);
 
 extern int prom_add_property(struct device_node* np, struct property* prop);

-- 
Regards,
Shawn

