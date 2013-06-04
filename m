From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCHv2 1/3] net: phy: prevent linking breakage
Date: Tue, 4 Jun 2013 16:36:50 +0100
Message-ID: <CAGVrzcbRS3x5fgD1BfOk4-oTUsAY9FA2V621OvZLJQNZ01brCg@mail.gmail.com>
References: <1369741403-25315-2-git-send-email-alexandre.belloni@free-electrons.com>
 <51A5BA86.3070609@free-electrons.com> <20130530.024201.1913984663902628192.davem@davemloft.net>
 <6466898.RnYOe3jpGG@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	alexandre.belloni@free-electrons.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Russell King <linux@arm.linux.org.uk>, shawn.guo@linaro.org,
	kernel@pengutronix.de
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6466898.RnYOe3jpGG@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/6/4 Arnd Bergmann <arnd@arndb.de>:
>> Or you properly segregate the networking bits of the platform code so
>> that it can be built only when the necessary networking portions are
>> enabled.
>>
>> Sometimes having dummy stubs makes sense, but not in this situation.
>
> Currently most users of this function are doing something like
>
> static int foo_phy_fixup(struct phy_device *phydev)
> {
>         ...
> }
>
> static int __init boo_board_init(void)
> {
>          if (IS_BUILTIN(CONFIG_PHYLIB))
>                 phy_register_fixup_for_uid(phy_id, foo_phy_fixup);
> }
>
> which is practically the same as having a dummy stub. It leads to
> the foo_phy_fixup() function always getting compiled and then discarded
> by gcc when CONFIG_PHYLIB is disabled.
>
> The method is currently broken when network drivers are enabled as
> modules, because we are missing the fixup then.
>
> I think we should use IS_ENABLED() here to force a build error
> in that case, and have something like
>
> config ARCH_FOO
>         bool "support for the foo platform"
>         select PHYLIB if NET
>
> in the platform Kconfig file, to ensure PHYLIB is always built-in.
>
> I still think the inline alternatives would be helpful, but using
> if (IS_ENABLED(CONFIG_PHYLIB)) in the platform code would also
> work.

It seems to me that what David proposes is to have say an
arch/arm/mach-foo/phy-fixups.c file which is only enabled when
CONFIG_PHYLIB is set (obj-$(CONFIG_PHYLIB) += phy-fixup.o), such that
it does not need to have any conditionnals when calling
phy_register_fixup. This sounds a little unusual, but why not.
--
Florian
