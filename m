From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: mdio-thunder.c:undefined reference to `mdiobus_unregister'
Date: Mon, 12 Jun 2017 09:17:15 -0700
Message-ID: <65ac6724-3b40-86ca-534d-f5bede84703c@gmail.com>
References: <201706121044.hytIipdV%fengguang.wu@intel.com>
 <d61b3289-9149-4a43-b8bd-4c3b94590e5f@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Arnd Bergmann <arnd@arndb.de>
To: Randy Dunlap <rdunlap@infradead.org>,
        kbuild test robot <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d61b3289-9149-4a43-b8bd-4c3b94590e5f@infradead.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/12/2017 09:09 AM, Randy Dunlap wrote:
> On 06/11/17 19:14, kbuild test robot wrote:
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>> head:   32c1431eea4881a6b17bd7c639315010aeefa452
>> commit: 90eff9096c01ba90cdae504a6b95ee87fe2556a3 net: phy: Allow splitting MDIO bus/device support from PHYs
>> date:   3 months ago
>> config: x86_64-randconfig-s2-06120830 (attached as .config)
>> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
>> reproduce:
>>         git checkout 90eff9096c01ba90cdae504a6b95ee87fe2556a3
>>         # save the attached .config to linux build tree
>>         make ARCH=x86_64 
>>
>> All errors (new ones prefixed by >>):
>>
>>    drivers/built-in.o: In function `thunder_mdiobus_pci_remove':
>>>> mdio-thunder.c:(.text+0x2a212f): undefined reference to `mdiobus_unregister'
>>>> mdio-thunder.c:(.text+0x2a2138): undefined reference to `mdiobus_free'
>>    drivers/built-in.o: In function `thunder_mdiobus_pci_probe':
>>    mdio-thunder.c:(.text+0x2a22e7): undefined reference to `devm_mdiobus_alloc_size'
>>    mdio-thunder.c:(.text+0x2a236f): undefined reference to `of_mdiobus_register'
>>
>> ---
>> 0-DAY kernel test infrastructure                Open Source Technology Center
>> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>>
> 
> Ugh. I don't know the solution to this one.
> 
> CONFIG_MDIO_DEVICE=y
> CONFIG_MDIO_THUNDER=y
> CONFIG_PHYLIB=m
> 
> First 2 lines are OK, but the third line causes the problem...
> in drivers/net/phy/Makefile:
> 
> # PHYLIB implies MDIO_DEVICE, in that case, we have a bunch of circular
> # dependencies that does not make it possible to split mdio-bus objects into a
> # dedicated loadable module, so we bundle them all together into libphy.ko
> ifdef CONFIG_PHYLIB
> libphy-y			+= $(mdio-bus-y)
> else
> obj-$(CONFIG_MDIO_DEVICE)	+= mdio-bus.o
> endif
> libphy-$(CONFIG_SWPHY)		+= swphy.o
> libphy-$(CONFIG_LED_TRIGGER_PHY)	+= phy_led_triggers.o
> 
> obj-$(CONFIG_PHYLIB)		+= libphy.o
> 
> 
> So PHYLIB is built as libphy.ko and the mdiobus functions are there
> instead of being in mdio-bus.o (so they are not built-in), while the
> mdio-thunder driver is built-in.

We may need:

depends on !(MDIO_DEVICE=y && PHYLIB=m)

similar to what MDIO_BITBANG already has.

I will cook something later today, thanks!
-- 
Florian
