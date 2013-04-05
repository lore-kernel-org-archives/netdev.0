From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH 1/5 v2] mv643xx_eth: add Device Tree bindings
Date: Fri, 05 Apr 2013 22:35:41 +0200
Message-ID: <515F359D.7000306@gmail.com>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <1365071235-11611-2-git-send-email-florian@openwrt.org>
 <20130404212906.GA25904@schnuecks.de> <515E9FE0.8050402@openwrt.org>
 <CABJ1b_TdzE_Q9qLsdSGZy8byFpCTtVBUy5FtxiZAx7QqgG-rVg@mail.gmail.com>
 <20130405180443.GE3598@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, moinejf@free.fr,
 Simon Baatz <gmbnomis@gmail.com>, andrew@lunn.ch, netdev@vger.kernel.org,
 devicetree-discuss@lists.ozlabs.org, rob.herring@calxeda.com,
 davem@davemloft.net, grant.likely@secretlab.ca, jogo@openwrt.org,
 buytenh@wantstofly.org, jm@lentin.co.uk,
 Florian Fainelli <florian@openwrt.org>, linux-arm-kernel@lists.infradead.org,
 jason@lakedaemon.net
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20130405180443.GE3598@obsidianresearch.com>
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

On 04/05/2013 08:04 PM, Jason Gunthorpe wrote:
> On Fri, Apr 05, 2013 at 03:58:03PM +0200, Sebastian Hesselbarth wrote:
>> I don't think that the ethernet controller should probe the PHY's on mdio-bus
>> at all. At least not for DT enabled platforms. I had a look at DT and non-DT
>> mdio-bus sources, and realized that there is a bus scan for non-DT only.
>> of_mdiobus_register requires you to set (and know) the PHY address.
>
> DT platforms should have the option to use the standard phy-phandle
> connection:
>
>
> 		mdio@72004 {
> 			#address-cells =<1>;
> 			#size-cells =<0>;
> 			compatible = "marvell,orion-mdio";
> 			reg =<0x72004 0x84>;
> 			status = "disabled";
>
> +                        PHY1: ethernet-phy@1 {
> +                                reg =<1>;
> +                                device_type = "ethernet-phy";
> +                        };
> 		};
>
> 		ethernet-group@72000 {
> 			#address-cells =<1>;
> 			#size-cells =<0>;
> 			compatible = "marvell,mv643xx-eth-block";
> 			reg =<0x72000 0x4000>;
> 			tx-csum-limit =<1600>;
> 			status = "disabled";
>
> 			egiga0: ethernet@0 {
> 				device_type = "network";
> 				compatible = "marvell,mv643xx-eth";
> 				reg =<0>;
> 				interrupts =<29>;
> 				clocks =<&gate_clk 2>;
> +	                        phy-handle =<&PHY1>;
> 			};
> 		};
>
> When phy-handle is present the ethernet driver should not probe/scan for
> phys.
>
> There is standard code to handle all of this - an important gain is
> that the phy driver now has access to a DT node and can apply
> phy-specific properties.

The above is what I use as a modification of Florian's patches.
I compared of_mdiobus_register against mdiobus_register. The difference
is that DT version does not scan the bus for attached PHYs. That is ok,
if you know the phy_address of the PHY that you pass the handle of. But 
in most cases there will be only one PHY on the mdiobus and especially
for new boards probing will help here.

>> We had a similar discussion whether to probe or not for DT nodes,
>> and I guess there also will be some discussion about the above
>> patch. OTOH we could just (again) ask users of every
>> kirkwood/orion5x/dove board to tell their phy addresses and fail to
>> probe the phy for new boards...
>
> Maybe print a warning and call the no-DT phy probe code if phy-handle
> is nor present?

I think it would be best to spam each probing result during mdiobus
scan to encourage people to edit the DT and put in the phy_addr
directly. IMHO it will be best to have bus scan on mdiobus rather than
ethernet driver.

> Not sure this should be in the common code, phy probing is sketchy, it
> shouldn't be encouraged, IMHO..

Actually, it is in common code (non-DT case) and I think passing the
phy_addr by DT node like above is best. But for boards you don't
know the address (yet) probing helps a lot. If all phy nodes have their
reg property set, no probing will be performed.

For testing mdio bus probe, I used

mdio {
	...
	ethphy: ethernet-phy {
		reg = <32>;
	};
};

And 32 should be defined as OF_PHY_ADDR_AUTOSCAN. It is an invalid
address as max phy_addr is 31. I also thought about a bool property
but passing an invalid reg property in SoC file allows to overwrite
it in board file with the actual address easily.
And AFAIK bool properties cannot be removed later on by board specific
nodes.

Sebastian
