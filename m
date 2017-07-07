From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 2/2] net: ethernet: fsl: add phy reset after clk enable
 option
Date: Fri, 7 Jul 2017 16:00:10 +0200
Message-ID: <20170707140010.GD24237@lunn.ch>
References: <1499346330-12166-1-git-send-email-richard.leitner@skidata.com>
 <1499346330-12166-2-git-send-email-richard.leitner@skidata.com>
 <AM4PR0401MB2260ECD4508E26FF16670004FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <81105c77-d48f-271b-2de1-c877b9413184@skidata.com>
 <AM4PR0401MB226089839458F5F92C3B1F39FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <6de114cb-4521-4bb2-d0a3-4aea32936bd3@skidata.com>
 <AM4PR0401MB22609FFACD2BB51247709936FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <b68f444e-cea4-acaa-d1e9-7955a577ed35@skidata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Duan <fugang.duan-3arQi8VN3Tc@public.gmane.org>,
        "robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dev-M/VWbR8SM2SsTnJN9+BGXg@public.gmane.org" <dev-M/VWbR8SM2SsTnJN9+BGXg@public.gmane.org>
To: Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <b68f444e-cea4-acaa-d1e9-7955a577ed35-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Ok. I'm fine with moving the phy-reset-gpios binding into the PHY.
> But one question still remains: Who should then trigger the "hard
> reset" of the PHY?

Hi Richard

I think i see a few whys to do this, but first i need to check
something. Is the clock which is causing a problem this one:

        /* clk_ref is optional, depends on board */
        fep->clk_ref = devm_clk_get(&pdev->dev, "enet_clk_ref");
        if (IS_ERR(fep->clk_ref))
                fep->clk_ref = NULL;

Possible solutions:

1) clocks are referenced counted. If it is turned on twice, it needs
   to be turned off twice before it is actually turned off. So, make
   the PHY driver also clk_prepare_enable() this clock. When the FEC
   tries to turn it off, it will stay ticking. Problem avoided, at the
   expense of some power.

2) More complex, but make the PHY driver also a clock driver. Have the
   PHY driver export a clock which the FEC use, as "enet_clk_ref". The
   implementation of this clock, would both turn the real clock on,
   and the perform the reset.

Both require no changes to the FEC, or any other MAC driver using this
PHY, so long as the MAC driver uses the common clock infrastructure to
control the clock to the PHY.

	Andrew


 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
