From: Oliver Graute <oliver.graute@gmail.com>
Subject: Re: Micrel Phy KSZ8031 clock select setting in dts
Date: Mon, 20 Jun 2016 19:14:06 +0200
Message-ID: <20160620171406.GA4455@graute-opti>
References: <20160617130438.GB6604@graute-opti>
 <bda2a612-37fd-9b73-5aad-6bc62ac2f520@cogentembedded.com>
 <5766f2a8.8f1d1c0a.10cf8.1751@mx.google.com>
 <20160620062101.GL9677@pengutronix.de>
 <20160620120821.GA19639@graute-opti>
 <20160620124539.GB20362@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sascha Hauer <s.hauer@pengutronix.de>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, f.fainelli@gmail.com, johan@kernel.org,
	bth@kamstrup.dk
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36580 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739AbcFTRPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 13:15:20 -0400
Received: by mail-wm0-f66.google.com with SMTP id c82so12715249wme.3
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 10:15:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160620124539.GB20362@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/06/16, Andrew Lunn wrote:
> > &fec1 {
> > 	pinctrl-names = "default";
> > 	pinctrl-0 = <&pinctrl_enet1>;
> > 	phy-mode = "rmii";
> > 	micrel,rmii-reference-clock-select-25-mhz;
> > 	clocks,rmii-ref;
> 
> You are adding phy properties, not MAC properties. Please put them in
> the phy node.

yes, you are right. I fixed this and added the clock like sascha and
sergei proposed. (thx to you all)

my dts node now looks like this:

&fec1 {
	pinctrl-names = "default";
	pinctrl-0 = <&pinctrl_enet1>;
	phy-mode = "rmii";
	status = "okay";

	mdio {
		#address-cells = <1>;
		#size-cells = <0>;

		ethphy0: ethernet-phy@0 {
			compatible = "micrel,ksz8031";
			micrel,rmii-reference-clock-select-25-mhz;
			clocks = <&mdc>;
			clock-names = "rmii-ref";
			phy-handle = <&ethphy0>;
			reg = <0>;
		};

	};

	mdc: rmii-ref {
		#clock-cells = <0>;
		compatible ="fixed-clock";
		clock-frequency = <50000000>;
	};
};


But I also needed to invert the behavior of KSZPHY_RMII_REF_CLK_SEL in
the micrel.c driver to get everything working with my revison of Micrel Phy.

If I understood you right this should not be necessary. So something in
dts is still wrong.


diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 7f4e042..198a24f 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -181,10 +181,14 @@ static int kszphy_rmii_clk_sel(struct phy_device *phydev, bool val)
 		return ctrl;
 	}
 
-	if (val)
+	if (val){
+		printk(KERN_DEBUG "if kszphy_rmii_clk_sel val=0x%x \n", val);
 		ctrl |= KSZPHY_RMII_REF_CLK_SEL;
-	else
-		ctrl &= ~KSZPHY_RMII_REF_CLK_SEL;
+	}
+	else{
+		printk(KERN_DEBUG "else kszphy_rmii_clk_sel val=0x%x \n", val);
+		ctrl |= KSZPHY_RMII_REF_CLK_SEL;
+	}

Best Regards,

Oliver
