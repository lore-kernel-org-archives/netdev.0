From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH 2/2] net: mv643xx_eth: proper initialization for Kirkwood
 SoCs
Date: Fri, 24 May 2013 00:40:26 +0200
Message-ID: <519E9ADA.3040204@gmail.com>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com> <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com> <1369253042-15082-2-git-send-email-sebastian.hesselbarth@gmail.com> <20130522201607.GA18823@obsidianresearch.com> <20130523160111.GP31290@titan.lakedaemon.net> <20130523171112.GB31281@obsidianresearch.com> <20130523172339.GQ31290@titan.lakedaemon.net> <20130523175357.GB2821@obsidianresearch.com> <20130523184028.GU31290@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130523184028.GU31290@titan.lakedaemon.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/23/2013 08:40 PM, Jason Cooper wrote:
> On Thu, May 23, 2013 at 11:53:57AM -0600, Jason Gunthorpe wrote:
>> On Thu, May 23, 2013 at 01:23:39PM -0400, Jason Cooper wrote:
>>> Shouldn't it rather be
>>>
>>> 	compatible = "marvell,kirkwood-eth", "marvell,orion-eth";
>>
>> Not sure about orion-eth?

Jason, Jason,

sorry I didn't came back to this conversation earlier. I already
reworked the patch to rely on 
of_device_is_compatible(.."marvell,kirkwood-eth"..). This is a
kirkwood only thing as other Orions cannot do clock gating or
retain critcal register content (Dove). I will stick with orion-eth
for all other and maybe introduce new compatible strings (and new
fixes) as soon as issues surface.

>>> I'm inclined to go with of_machine_is_compatible() since the only
>>> concrete difference we know is that the tweak is needed on kirkwood and
>>> nowhere else.
>>
>> But there is a larger problem here then just this one bit.
>>
>> The PSC1 register must be set properly for the board layout, and today
>> we rely on the bootloader to set it. In fact, even with Sebastian's
>> change the ethernet port won't work without bootloader
>> intervention. The PortReset bit should also be cleared by the driver
>> (and it is only present on some variants of this IP block,
>> apparently).

Actually, fixing modular scenarios is only for the sake of multiarch
someday. I don't see the point in running current kernel without eth
compiled in _on a NAS SoC_ ;)

On Dockstar which I tested, clearing CLK125_BYPASS_EN to make it work
after clock gating, it might be a coincidence that bootloader's PSC1
setup matches reset value here - so please test the patch on other
Kirkwood boards also.

But, as long as no other issue arise, I will not start to modifiy
mv643xx_eth out of the blue. I has been working for ages and breaking
PPC is not my intention. There are other things David Miller already
requested to get fixed and honestly I even thought about a fresh start
for it. Maybe I'll come back to it when barebox gets it's driver
someday.

>> We know that some Marvell SOC's wack the ethernet registers when they
>> clock gate, and the flip of Clk125Bypass is another symptom of this
>> general problem.

Which SoCs except Kirkwood? I cannot reproduce any of this behavior on
Dove - and from what I can see from the FS of Orion5x or MV78x00 there
are no clock gating registers.

>> So, long term, the PSC1 must be fully set by the driver, based on DT
>> information describing the board (eg RGMII/MII/1000Base-X [SFP] Phy
>> type), and the layout of this register seems to vary on a SOC by SOC
>> basis.

Agree, but I tend to not go at it now. mv643xx_eth has never set up that
registers and actually it never connects anything else than GMII phy (or 
no phy at all). The latter is easy but the for the other, I like to
give up that brain-dead multi-device driver and stick with one device
for both shared and up to three ports. From what I can see from e.g.
ixgbe or any other multi-port eth drivers they all attach the network
device to a single (pci) device.

>> Thus, I think it is appropriate to call this variant of the eth IP
>> 'marvell,kirkwood-eth' which indicates that the register block follows
>> the kirkwood manual and the PSC1 register specifically has the
>> kirkwood layout.
>
> Ok, so mv643xx_eth would match both "marvell,orion-eth" and
> "marvell,kirkwood-eth", then write to PSC1 iff it sees a node matching
> "marvell,kirkwood-eth".  I'm not too keen on that, however, the matching
> of the machine doesn't look to good, either.

I didn't choose "marvell,mv643xx-eth" for two reasons
(a) The DT layout is slightly different with phy-handle instead of phy
and marvell prefixed properties. Choosing a compatible string that
matches any PPC compatible string will cause driver racing with sysdev
code to set up platform_data.

(b) I chose to name the controller "orion-eth" and the port
"orion-eth-port" .. PPC has "mv64360-eth" for the port and some 
"mv64360-eth-block" or "-group" for the controller. IMHO not intuitive,
but it just a name anyway.

> Perhaps a better answer is to add a boolean, "marvell,kirkwood_psc1" and
> check for that?
>
> Or, marvell,psc1_reset =<0xWWXXYYZZ>;

For the _long_ run: Exploit either already present phy properties for
MII and friends or introduce new marvell prefixed .. but not misuse DT
for register values here. Each SoC should setup mv643xx_eth properly,
but that should be based on a clean approach _and_ enough people willing
to test that.

I just have a Dockstar and Topkick which is running 24/7. I didn't even
check if only 6281 suffers from it or also 6282 or maybe only some
revisions of 6281. This patch is a fix, nothing more nothing
less. If you have Kirkwoods around, please test if it suffers from
loosing the MAC address and if it works after insmod with the fix
installed.

>> The question is what other Marvell SOCs have the same PSC1 layout as
>> kirkwood?
>
> I think marvell,psc1_reset =<>; gives us the most flexibility in
> accurately describing the hardware.

IMHO using that is just another workaround for a broken driver. We
could hack the whole register setup in DT as it would still accurately
describe HW. Don't get me wrong, but I don't like it.

Haven't checked how happy Linus Walleij is about pinctrl drivers with
reg values hacked in lately.

Sebastian
