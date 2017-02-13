From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [net-next] ARM: orion: fix PHYLIB dependency
Date: Mon, 13 Feb 2017 15:31:20 +0100
Message-ID: <CAK8P3a1tJ_DPb1aDngazF0UnfWzwY0+v0Oz1DOiUPpBdDyyu_Q@mail.gmail.com>
References: <20170209150834.1158193-1-arnd@arndb.de> <CAK8P3a2Yss8r0qoubg2C7Jp+0JE3Fx+igWHQOscR+SB6d+W_HA@mail.gmail.com>
 <352146cc-845c-2860-44ca-7338eb53e260@gmail.com> <2626135.PlNJ5EMbcM@wuerfel>
 <b78765e9-2696-5587-0485-e497eb4459db@gmail.com> <CAK8P3a2BAgtKmEeaom8kNQghLnjGWLGC782OTBTGcfcD_Z8WgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cooper <jason@lakedaemon.net>,
        Networking <netdev@vger.kernel.org>,
        Russell King <linux@armlinux.org.uk>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a2BAgtKmEeaom8kNQghLnjGWLGC782OTBTGcfcD_Z8WgQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 10, 2017 at 10:32 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Fri, Feb 10, 2017 at 9:57 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 02/10/2017 12:05 PM, Arnd Bergmann wrote:
>>> On Friday, February 10, 2017 9:42:21 AM CET Florian Fainelli wrote:
>>>> On 02/10/2017 12:20 AM, Arnd Bergmann wrote:
>>>>> On Thu, Feb 9, 2017 at 7:22 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>>>>> On 02/09/2017 07:08 AM, Arnd Bergmann wrote:
>>>>>> I disabled CONFIG_NETDEVICES to force CONFIG_PHY not to be set here, and
>>>>>> I was not able to reproduce this, what am I missing?
>>>>>
>>>>> In the ARMv5 allmodconfig build, this fails because CONFIG_PHY=m, and
>>>>> we can't call into it. You could use IS_BUILTIN instead of IS_ENABLED in
>>>>> the header as a oneline workaround, but I think that would be more confusing
>>>>> to real users that try to use CONFIG_PHY=m without realizing why they lose
>>>>> access to their switch.
>>>>
>>>> I see, this patch should also help fixing this:
>>>>
>>>> http://patchwork.ozlabs.org/patch/726381/
>>>
>>> I think you still have the same problem, as you can still have the
>>> boardinfo registration in a loadable module.
>>
>> The patch exports mdiobus_register_board_info() so that should solve
>> your problem here, and I did verify this with a loadable module that
>> references mdiobus_register_board_info() in that case.
>
> No, that's a different problem. What you get with arm allmodconfig
> (try it!) is that mdio-bus.ko is a loadable module, but referenced
> from built-in code rather than the other way around. Exporting
> the symbol doesn't change anything since the module cannot
> be loaded by the time we need the symbol.

I got another failure with my patch applied:

drivers/net/phy/mdio-boardinfo.o: In function
`mdiobus_setup_mdiodev_from_board_info':
mdio-boardinfo.c:(.text.mdiobus_setup_mdiodev_from_board_info+0x48):
undefined reference to `mdio_device_create'
mdio-boardinfo.c:(.text.mdiobus_setup_mdiodev_from_board_info+0x78):
undefined reference to `mdio_device_register'
mdio-boardinfo.c:(.text.mdiobus_setup_mdiodev_from_board_info+0x84):
undefined reference to `mdio_device_free'
mdio-boardinfo.c:(.text.mdiobus_setup_mdiodev_from_board_info+0xa8):
undefined reference to `mdio_device_bus_match'

I hadn't realized earlier that the function has to call back into
the mdio layer. This is theoretically fixable too, but it's probably easier
to make all of the MDIO bus layer builtin whenever there is a user of
mdiobus_register_board_info().

      Arnd
