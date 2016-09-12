From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
        <u.kleine-koenig@pengutronix.de>
Subject: About enet_out clk on i.MX28, i.MX6 and i.MX7
Date: Mon, 12 Sep 2016 17:36:07 +0200
Message-ID: <20160912153607.qqkosq4uu2rl76eg@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>,
        Lauri Hintsala <lauri.hintsala@bluegiga.com>,
        Shawn Guo <shawnguo@kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>, kernel@pengutronix.de
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:40129 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934162AbcILPgM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 11:36:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

to operate the MDIO bus a clk is required. On some i.MX SoCs it can be
configured if that clk is provided by the CPU or not (i.e. something
else provides it).

The devicetree abstraction for that is (e.g. on i.MX28):

	mac0: ethernet@800f0000 {
		compatible = "fsl,imx28-fec";
		...
		clocks = <&clks 57>, <&clks 57>, <&clks 64>;
		clock-names = "ipg", "ahb", "enet_out";
		...
	};

and the driver does:

	/* enet_out is optional, depends on board */
	fep->clk_enet_out = devm_clk_get(&pdev->dev, "enet_out");
	if (IS_ERR(fep->clk_enet_out))
		fep->clk_enet_out = NULL;

. IMHO this is clumsy and wrong. See for example
arch/arm/boot/dts/imx28-m28evk.dts which has:

	ethernet@800f0000 {
		...
		clocks = <&clks 57>, <&clks 57>;
		clock-names = "ipg", "ahb";
	}

to get rid of this entry. Moreover enet_out isn't a clock for the fec
instance but for the mdio bus, so the better binding would be:

	mac0: ethernet@800f0000 {
		compatible = "fsl,imx28-fec";

		clocks = <&clks 57>, <&clks 57>;
		clock-names = "ipg", "ahb";

		mdio {
			clocks = <&clks 64>;
			...
		};
	};

This better matches reality and is easier to overwrite per board without
repeating stuff from imx28.dtsi as it is now.

What do you think? Compatibility isn't a big concern, the fec driver
could just keep handling "enet_out" as is and learn about the optional
mdio/clocks.
This would handle old dtbs just fine.

Slightly related: Some machines (bluegiga,apx4devkit, karo,tx28) still
enable enet_out clk in arch/arm/mach-mxs/mach-mxs.c. I think this can be
dropped, right? (Unless recent kernels should still handle dtbs that
don't have enet_out in the fec node. That affects dtbs built between

	v3.6-rc1~144^2~7^2~11 = 3143bbb42b3d ("ARM: mxs: convert apx4devkit board to device tree")
and

	v3.10-rc1~63^2~10^2~20 = f231a9fe7f80 ("ARM: dts: mxs: add enet_out clock to devicetree")
.)

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-König            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
