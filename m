From: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Thu, 7 Apr 2016 16:43:47 -0500
Message-ID: <5706D493.8020700@codeaurora.org>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
 <20151231231039.GA8886@rob-hp-laptop> <56ABADEA.40801@codeaurora.org>
 <CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com>
 <5706B4EF.2050600@codeaurora.org> <20160407201009.GA16136@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Gilad Avidov <gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-msm <linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sagar Dharia <sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160407201009.GA16136-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andrew Lunn wrote:
>> I'm back to working on this driver, and I need some more help with
>> how to handle the phy.  mdio-gpio.txt doesn't really tell me much.
>> I'm actually working on an ACPI system and not DT.
>
> I can help you with DT, but not ACPI.
>
> The MDIO bus can be a separate Linux device. Since you have GPIO lines
> for the MDIO bus, it makes sense for this to be a mdio-gpio device. So
> in DT, you would have:
>
> mdio0: mdio {
>          compatible = "virtual,mdio-gpio";
>          #address-cells = <1>;
>          #size-cells = <0>;
>          gpios = <&qcomgpio 123 0
>                   &qcomgpio 124 0>;
>
> 	phy0: ethernet-phy@8 {
>          	reg = <9>;
> 	};
> };
>
> Here i've assumed the PHY is using address 8 on the bus. Change as
> needed.
>
> In your MAC DT node, you then have phy-handle pointing to this phy:
>
>    emac0: qcom,emac@feb20000 {
>    	cell-index = <0>;
> 	compatible = "qcom,emac";
> 	reg-names = "base", "csr", "ptp", "sgmii";
> 	reg =   <0xfeb20000 0x10000>,
> 	    	<0xfeb36000 0x1000>,
> 		<0xfeb3c000 0x4000>,
> 		<0xfeb38000 0x400>;
> 	#address-cells = <0>;
> 	interrupt-parent = <&emac0>;
> 	#interrupt-cells = <1>;
> 	interrupts = <0 1>;
> 	interrupt-map-mask = <0xffffffff>;
> 	interrupt-map = <0 &intc 0 76 0
> 	 	         1 &intc 0 80 0>;
>         	interrupt-names = "emac_core0", "sgmii_irq";
>    	qcom,emac-tstamp-en;
> 	qcom,emac-ptp-frac-ns-adj = <125000000 1>;
>
> 	phy-handle = <&phy0>
> }
>
> In the driver, you need to connect the PHY to the MAC. You do this
> using something like:
>
>           if (dev->of_node) {
>                   phy_np = of_parse_phandle(dev->of_node, "phy-handle", 0);
>                   if (!phy_np) {
>                           netdev_dbg(ndev, "No phy-handle found in DT\n");
>                           return -ENODEV;
>                   }
>
>                   phy_dev = of_phy_connect(ndev, phy_np, &xxxx_enet_adjust_link,
>                                            0, pdata->phy_mode);
>                   if (!phy_dev) {
>                           netdev_err(ndev, "Could not connect to PHY\n");
>                           return -ENODEV;
>                   }

Thank you very much.  I'll study this in detail.

> Do you have an ACPI table describing this hardware? What does it look
> like?

So a little background.  There are several versions of this driver 
floating in Qualcomm, and this is the first serious attempt to upstream 
it.  I'm trying to reconcile Gilad's driver with the one we use 
internally for our ACPI-enabled ARM server platform (the QDF2432).

My goal is to get Gilad's driver accepted upstream with minimal changes 
on my part.  I will then follow up with several patches that enable ACPI 
and our SOC, as well as adding missing parts like ethtool and 1588 support.

On my platform, firmware (UEFI) configures all of the GPIOs.  I need to 
get confirmation, but it appears that we don't actually make any GPIO 
calls at all.  I see code that looks like this:

	for (i = 0; (!adpt->no_mdio_gpio) && i < EMAC_NUM_GPIO; i++) {
		gpio_info = &adpt->gpio_info[i];
		retval = of_get_named_gpio(node, gpio_info->name, 0);
		if (retval < 0)
			return retval;

And on our ACPI system, adpt->no_mdio_gpio is always true:

	/* Assume GPIOs required for MDC/MDIO are enabled in firmware */
	adpt->no_mdio_gpio = true;

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
