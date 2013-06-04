From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv2 1/3] net: phy: prevent linking breakage
Date: Tue, 04 Jun 2013 17:07:39 +0200
Message-ID: <6466898.RnYOe3jpGG@wuerfel>
References: <1369741403-25315-2-git-send-email-alexandre.belloni@free-electrons.com> <51A5BA86.3070609@free-electrons.com> <20130530.024201.1913984663902628192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: alexandre.belloni@free-electrons.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux@arm.linux.org.uk, shawn.guo@linaro.org, kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:64029 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757467Ab3FDPH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 11:07:57 -0400
In-Reply-To: <20130530.024201.1913984663902628192.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 30 May 2013 02:42:01 David Miller wrote:
> From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
> > On 28/05/2013 22:09, David Miller wrote:
> > But that is making it impossible to compile a kernel without any network
> > stack for those platforms or we are going back to either enclosing the
> > calls to phy_register_fixup{,_for_uid,_for_id} with #ifdef CONFIG_PHYLIB
> > or if(IS_BUILTIN(CONFIG_PHYLIB)). And as you can see, it is quite error
> > prone and is done only done for 2 platforms on a total of 6. I believe
> > fixing that in phy.h is more foolproof.
> 
> Or you properly segregate the networking bits of the platform code so
> that it can be built only when the necessary networking portions are
> enabled.
> 
> Sometimes having dummy stubs makes sense, but not in this situation.

Currently most users of this function are doing something like

static int foo_phy_fixup(struct phy_device *phydev)
{
	...
}

static int __init boo_board_init(void)
{
	 if (IS_BUILTIN(CONFIG_PHYLIB))
		phy_register_fixup_for_uid(phy_id, foo_phy_fixup);
}

which is practically the same as having a dummy stub. It leads to
the foo_phy_fixup() function always getting compiled and then discarded
by gcc when CONFIG_PHYLIB is disabled.

The method is currently broken when network drivers are enabled as
modules, because we are missing the fixup then.

I think we should use IS_ENABLED() here to force a build error
in that case, and have something like

config ARCH_FOO
	bool "support for the foo platform"
	select PHYLIB if NET

in the platform Kconfig file, to ensure PHYLIB is always built-in.

I still think the inline alternatives would be helpful, but using
if (IS_ENABLED(CONFIG_PHYLIB)) in the platform code would also
work.

	Arnd
