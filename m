From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] mvneta: add FIXED_PHY dependency
Date: Mon, 09 Nov 2015 17:57:43 +0100
Message-ID: <6910088.dNmooXDTJR@wuerfel>
References: <4225885.EYXTHjRPmX@wuerfel> <20151109164232.GB3388@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	Stas Sergeev <stsp@users.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:64455 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbbKIQ6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 11:58:35 -0500
In-Reply-To: <20151109164232.GB3388@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 09 November 2015 17:42:32 Andrew Lunn wrote:
> On Mon, Nov 09, 2015 at 03:08:57PM +0100, Arnd Bergmann wrote:
> > The fixed_phy infrastructure is done in a way that is optional,
> > by providing 'static inline' helper functions doing nothing in
> > include/linux/phy_fixed.h for all its APIs. However, three out
> > of the four users (DSA, BCMGENET, and SYSTEMPORT) always
> > 'select FIXED_PHY', presumably because they need that.
> 
> Hi Arnd
> 
> Need is probably too strong, it could be considered an optional
> feature. If you don't have a fixed_phy property in your DT blob, you
> don't need fixed phy support in your image.

Ok, I see.

> > MVNETA is the fourth one, and if that is built-in but FIXED_PHY
> > is configured as a loadable module, we get a link error:
> > 
> > drivers/built-in.o: In function `mvneta_fixed_link_update':
> > fpga-mgr.c:(.text+0x33ed80): undefined reference to `fixed_phy_update_state'
> > 
> > Presumably this driver has the same dependency as the others,
> > so this patch also uses 'select' to ensure that the fixed-phy
> > support is built-in.
> 
> This will work, and is uniform with the other instances. But maybe a
> more correct fix is to ensure fixed-phy is never a module when there
> is a builtin user.

That is hard to express with Kconfig. The alternative I listed instead
guarantees that CONFIG_MVNETA cannot be set to 'y' whenever FIXED_PHY=m.
For all practical purposes that has the same effect.

The fixed-phy support isn't very big (around 2KB), so I wonder how
relevant that optimization is.

> > Should we perhaps make 'FIXED_PHY' a silent option and remove the
> > inline helpers, based on the assumption that a driver that wants these
> > will not work without them?
> 
> I suppose it comes down to, are we allowed to optionally implement
> part of the DT binding?

I'm not sure what you are asking. A lot of DT bindings have both
optional and mandatory properties. For mvneta, the "phy" and "phy-mode"
properties are listed as mandatory, so the driver can safely assume
that they are always present. If there are reasons to leave them out,
and for the driver to handle that case correctly, the binding
should be updated to mark them as optional.

	Arnd
