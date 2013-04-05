From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH 1/5 v2] mv643xx_eth: add Device Tree bindings
Date: Fri, 5 Apr 2013 15:58:03 +0200
Message-ID: <CABJ1b_TdzE_Q9qLsdSGZy8byFpCTtVBUy5FtxiZAx7QqgG-rVg@mail.gmail.com>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <1365071235-11611-2-git-send-email-florian@openwrt.org>
 <20130404212906.GA25904@schnuecks.de>
 <515E9FE0.8050402@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, moinejf@free.fr,
 Simon Baatz <gmbnomis@gmail.com>, andrew@lunn.ch, netdev@vger.kernel.org,
 devicetree-discuss@lists.ozlabs.org, rob.herring@calxeda.com,
 grant.likely@secretlab.ca, jogo@openwrt.org,
 linux-arm-kernel@lists.infradead.org, jm@lentin.co.uk, davem@davemloft.net,
 buytenh@wantstofly.org, jason@lakedaemon.net
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <515E9FE0.8050402@openwrt.org>
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

On Fri, Apr 5, 2013 at 11:56 AM, Florian Fainelli <florian@openwrt.org> wrote:
> [snip]

Florian,

took me a while to try you patches out on Dove but now I fixed all
issues. I will
comment on all related patches but first I want to comment here.

One general note for Dove related patches: You didn't remove the registration of
ge platform_device from mach-dove/board-dt.c. That will lead to double
registration
of mdio and mv643xx_eth/shared, so you'll never be sure if DT or non-DT code is
executed. I haven't checked mach-kirkwood/board-dt.c or orion5x code.

>>>         if (!mv643xx_eth_version_printed++)
>>>                 pr_notice("MV-643xx 10/100/1000 ethernet driver version
>>> %s\n",
>>
>>
>> This is not related to your change, but there is a problem in this
>> function that has already been discussed in the past if I remember
>> correctly: The respective clock needs to be enabled here (at least
>> on Kirkwood), since accesses to the hardware are done below.
>> Enabling the clock only in mv643xx_eth_probe() is too late.
>>
>> As said, this is not a problem introduced by your changes (and which
>> is currently circumvented by enabling the respective clocks in
>> kirkwood_legacy_clk_init() and kirkwood_ge0x_init()), but we might
>> want to fix this now to get rid of unconditionally enabling the GE
>> clocks in the DT case.
>
>
> I think there may have been some confusion between the "ethernet-group"
> clock and the actual Ethernet port inside the "ethernet-group". The
> mv643xx_eth driver assumes we have a per-port clock gating scheme, while I
> think we have a per "ethernet-group" clock gating scheme instead. Like you
> said, I think this should be addressed separately.

IMHO, there should be a clocks property where ever you try to access registers,
i.e. in all three "parts" mv643xx_eth_shared (group), mv643xx_eth
(port) and mdio.
Since port depends on shared it would be ok to have it per group but that may
collide with other SoCs than Dove/Kirkwood that have per port clocks.

Is that separation (group/port) really required for any SoC?

>
> [snip]
>>
>> You don't change the clk initialization here:
>>
>> #if defined(CONFIG_HAVE_CLK)
>>         mp->clk = clk_get(&pdev->dev, (pdev->id ? "1" : "0"));
>>         if (!IS_ERR(mp->clk)) {
>>                 clk_prepare_enable(mp->clk);
>>                 mp->t_clk = clk_get_rate(mp->clk);
>>         }
>> #endif
>>
>> Which, if I understand correctly, works in the DT case because you
>> assign "clock-names" to the clocks in the DTS. However, I wonder
>> whether this works for any but the first Ethernet device.

Yes, it does. Assigned clocks from clocks property get a clock alias for
that device name (node name). Using anything else than NULL here is
IMHO just wrong. We should rather provide proper clock aliases for non-DT case.

>> In the old platform device setup, the pdev->id was set when
>> initialiazing the platform_device structure in common.c.  Where is
>> this done in the DT case?
>
> Looks like you are right, in the DT case, I assume that we should lookup the
> clock using NULL instead of "1" or "0" so we match any clock instead of a
> specific one.

Yes.

> [snip]
>>
>>
>> In phy_scan(), the phy is searched like this:
>>
>>                 snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
>>                                 "orion-mdio-mii", addr);
>>
>>                 phydev = phy_connect(mp->dev, phy_id,
>> mv643xx_eth_adjust_link,
>>                                 PHY_INTERFACE_MODE_GMII);
>>
>> But "orion-mdio-mii:xx" is the name of the PHY if MDIO is setup via a
>> platform_device. I could not get this to work if the MDIO device is
>> setup via DT. Am I doing something wrong?
>
> I just missed updating this part of the code to probe for PHYs. The board I
> tested with uses a "PHY_NONE" configuration. I will add the missing bits for
> of_phy_connect() to be called here.

I don't think that the ethernet controller should probe the PHY's on mdio-bus
at all. At least not for DT enabled platforms. I had a look at DT and non-DT
mdio-bus sources, and realized that there is a bus scan for non-DT only.
of_mdiobus_register requires you to set (and know) the PHY address.

I prepared a patch for of_mdio_register that will allow you to probe mdio and
assign phy addresses to each node found. Currently, the heuristic for probing
is: assign each phy node the next probed phy_addr starting with 0. But that
will not allow to e.g. set some PHY addresses and probe the rest.

We had a similar discussion whether to probe or not for DT nodes, and I guess
there also will be some discussion about the above patch. OTOH we could just
(again) ask users of every kirkwood/orion5x/dove board to tell their
phy addresses
and fail to probe the phy for new boards...

I will prepare a proper patch soon and post it on the corresponding lists.

>> Additionally, in phy_scan() there is this:
>>
>>         if (phy_addr == MV643XX_ETH_PHY_ADDR_DEFAULT) {
>>                 start = phy_addr_get(mp) & 0x1f;
>>                 num = 32;
>>         } else {
>>         ...
>>
>> MV643XX_ETH_PHY_ADDR_DEFAULT is defined as 0. However, many Kirkwood
>> devices use "MV643XX_ETH_PHY_ADDR(0)".  If the module probe is
>> deferred in mv643xx_eth because the MDIO driver is not yet loaded,
>> all 32 PHY addresses are scanned without success.  This is not needed
>> and clutters the log.
>
>
> Ok, I am not sure how we can circumvent the log cluttering that happens,
> what would be your suggestion?

My suggestion is to change MV643XX_ETH_PHY_ADDR_DEFAULT from a valid
phy address (0)
to something invalid (32). I understand that using 0 helps if you
don't want to set it in mv643xx's platform_data
but it is always difficult to rely on that if 0 is a valid number.

Changing the above to 32 should just work because most (all?) boards
using phy_scan should also
already use MV643XX_ETH_PHY_ADDR_DEFAULT. I also suggest to rename
current define to a
better name, e.g. MV643XX_ETH_PHY_ADDR_AUTOSCAN.

Sebastian
