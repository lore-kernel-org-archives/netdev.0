From: Richard Leitner <richard.leitner@skidata.com>
Subject: Re: [PATCH 2/2] net: ethernet: fsl: add phy reset after clk enable
 option
Date: Wed, 12 Jul 2017 11:21:06 +0200
Message-ID: <e6b838e5-af7a-07be-42db-59b901cc04db@skidata.com>
References: <1499346330-12166-1-git-send-email-richard.leitner@skidata.com>
 <1499346330-12166-2-git-send-email-richard.leitner@skidata.com>
 <AM4PR0401MB2260ECD4508E26FF16670004FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <81105c77-d48f-271b-2de1-c877b9413184@skidata.com>
 <AM4PR0401MB226089839458F5F92C3B1F39FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <6de114cb-4521-4bb2-d0a3-4aea32936bd3@skidata.com>
 <AM4PR0401MB22609FFACD2BB51247709936FFAA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <b68f444e-cea4-acaa-d1e9-7955a577ed35@skidata.com>
 <20170707140010.GD24237@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "mark.rutland@arm.com" <mark.rutland@arm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "dev@g0hl1n.net" <dev@g0hl1n.net>,
        Richard Leitner <richard.leitner@skidata.com>
To: Andrew Lunn <andrew@lunn.ch>, Andy Duan <fugang.duan@nxp.com>,
        "robh+dt@kernel.org" <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170707140010.GD24237@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 07/07/2017 04:00 PM, Andrew Lunn wrote:
>> Ok. I'm fine with moving the phy-reset-gpios binding into the PHY.
>> But one question still remains: Who should then trigger the "hard
>> reset" of the PHY?
> 
> Hi Richard
> 
> I think i see a few whys to do this, but first i need to check
> something. Is the clock which is causing a problem this one:
> 
>         /* clk_ref is optional, depends on board */
>         fep->clk_ref = devm_clk_get(&pdev->dev, "enet_clk_ref");
>         if (IS_ERR(fep->clk_ref))
>                 fep->clk_ref = NULL;

Yes. It's this one.

> 
> Possible solutions:
> 
> 1) clocks are referenced counted. If it is turned on twice, it needs
>    to be turned off twice before it is actually turned off. So, make
>    the PHY driver also clk_prepare_enable() this clock. When the FEC
>    tries to turn it off, it will stay ticking. Problem avoided, at the
>    expense of some power.

Somehow this approach triggers a "workaround-feeling" for me...
Furthermore as you say it "wastes" (at least some) power. For exactly
this reason the disabling of the clock was implemented in commit
e8fcfcd5684a ("net: fec: optimize the clock management to save power").

> 
> 2) More complex, but make the PHY driver also a clock driver. Have the
>    PHY driver export a clock which the FEC use, as "enet_clk_ref". The
>    implementation of this clock, would both turn the real clock on,
>    and the perform the reset.

This seems as a good solution to me. Furthermore IMHO it would be good
to move all PHY related dt bindings (reset-gpio, clk, etc.) from the MAC
into the PHY node.

Or are there any reasons/arguments against this approach?

> 
> Both require no changes to the FEC, or any other MAC driver using this
> PHY, so long as the MAC driver uses the common clock infrastructure to
> control the clock to the PHY.
As (IMHO) the new approach likely won't be backported to stable releases
I want to stress again the point that commit e8fcfcd5684a
("net: fec: optimize the clock management to save power") introduced
this problem and therefore "broke the PHY" for our board.

So would it be possible to add a "quick" bugfix patch (maybe this patch
or another one removing the clk disable) so this fix can be backported
to stable? Otherwise our board is only working with another
"out-of-tree" patch (which I want to avoid)...

kind regards,
Richard.L
