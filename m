From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [net-next] ARM: orion: fix PHYLIB dependency
Date: Fri, 10 Feb 2017 22:32:44 +0100
Message-ID: <CAK8P3a2BAgtKmEeaom8kNQghLnjGWLGC782OTBTGcfcD_Z8WgQ@mail.gmail.com>
References: <20170209150834.1158193-1-arnd@arndb.de>
 <CAK8P3a2Yss8r0qoubg2C7Jp+0JE3Fx+igWHQOscR+SB6d+W_HA@mail.gmail.com>
 <352146cc-845c-2860-44ca-7338eb53e260@gmail.com> <2626135.PlNJ5EMbcM@wuerfel>
 <b78765e9-2696-5587-0485-e497eb4459db@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 Networking <netdev@vger.kernel.org>, Russell King <linux@armlinux.org.uk>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S . Miller" <davem@davemloft.net>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <b78765e9-2696-5587-0485-e497eb4459db@gmail.com>
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

On Fri, Feb 10, 2017 at 9:57 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 02/10/2017 12:05 PM, Arnd Bergmann wrote:
>> On Friday, February 10, 2017 9:42:21 AM CET Florian Fainelli wrote:
>>> On 02/10/2017 12:20 AM, Arnd Bergmann wrote:
>>>> On Thu, Feb 9, 2017 at 7:22 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>>>> On 02/09/2017 07:08 AM, Arnd Bergmann wrote:
>>>>> I disabled CONFIG_NETDEVICES to force CONFIG_PHY not to be set here, and
>>>>> I was not able to reproduce this, what am I missing?
>>>>
>>>> In the ARMv5 allmodconfig build, this fails because CONFIG_PHY=m, and
>>>> we can't call into it. You could use IS_BUILTIN instead of IS_ENABLED in
>>>> the header as a oneline workaround, but I think that would be more confusing
>>>> to real users that try to use CONFIG_PHY=m without realizing why they lose
>>>> access to their switch.
>>>
>>> I see, this patch should also help fixing this:
>>>
>>> http://patchwork.ozlabs.org/patch/726381/
>>
>> I think you still have the same problem, as you can still have the
>> boardinfo registration in a loadable module.
>
> The patch exports mdiobus_register_board_info() so that should solve
> your problem here, and I did verify this with a loadable module that
> references mdiobus_register_board_info() in that case.

No, that's a different problem. What you get with arm allmodconfig
(try it!) is that mdio-bus.ko is a loadable module, but referenced
from built-in code rather than the other way around. Exporting
the symbol doesn't change anything since the module cannot
be loaded by the time we need the symbol.

>>
>> I have come up with a patch too now and done some randconfig testing
>> on it (it took me several tries as well), please see below. It does
>> some of the same things as yours and some others.
>>
>> The main trick is to have a separate 'MDIO_BOARDINFO' Kconfig symbol
>> that can be selected regardless of all the other symbols, and that
>> will lead to the registration being either built-in when it's needed
>> or not built at all when either no board calls it, or PHYLIB is
>> disabled.
>
> Your patch is fine in premise except that you are making CONFIG_MDIO
> encompass both drivers/net/mdio.c and
> drivers/net/phy/mdio_{bus,device}.c and these do share the same header
> (for better or for worse), but are not quite dealing with MDIO at the
> same level. drivers/net/mdio.c is more like PHYLIB for the old-style,
> pre mdiobus() drivers helper functions.

Ah, makes sense. I had missed that part.

> I like it that you made MDIO_BOARDINFO separate, and that is probably a
> patch I should incorporate in the other patch splitting things up, see
> below though for the remainder of the changes.

Ok.

>>
>> From f35e89cacfabdf7b822772013389132605941def Mon Sep 17 00:00:00 2001
>> From: Arnd Bergmann <arnd@arndb.de>
>> Date: Wed, 27 Apr 2016 11:51:18 +0200
>> Subject: [PATCH] [RFC] move ethernet PHY config into drivers/phy/Kconfig
>>
>> Calling mdiobus_register_board_info from builtin code with CONFIG_PHYLIB=m
>> currently results in a link error:
>>
>> arch/arm/plat-orion/common.o: In function `orion_ge00_switch_init':
>> common.c:(.init.text+0x6a4): undefined reference to `mdiobus_register_board_info'
>>
>> As the long-term strategy is to separate mdio from phylib, and to get generic-phy
>> and (networking-only) phylib closer together, this performs a first step in that
>> direction: The Kconfig file for phylib gets logically pulled under the PHY
>> driver configuration and becomes independent from networking. This lets us
>> select the new CONFIG_MDIO_BOARDINFO from platforms that need it, and provide
>> the functions exactly when we need them.
>
> This is too broad, the only part that is worth in drivers/net/phy/ of
> pulling out of drivers/net/phy/ is what I tried to extract: mdio bus and
> device. There are some bad inter-dependencies between that code and
> phy_device.c and phy.c which makes it hard to split and make that part
> completely standalone for now.
>
> The only part that is truly valuable to non-Ethernet PHY devices is the
> MDIO bus/device registration part, which is available in my patch with
> CONFIG_MDIO_DEVICE, and which probably should not depend from
> NETDEVICES, so the other part of your patch makes sense too here.

My patch started out from something I had done a long time ago when
we discussed how the two subsystems (generic-phy and phylib) can
be tied together more. This has two aspects:

- Moving them into a single top-level Kconfig menu (and eventually
  directory) to make it easier to find one of them when you look in
  the wrong place. My patch starts doing that.
- making the MDIO bus available to generic-phy drivers. This is
  what your patch does.

Right now, we only really need part of my patch to fix the link
error, but it makes way more sense once all the parts come together.

    Arnd
