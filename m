From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: [PATCH 1/2] ethtool.h: Add #defines for unidirectional ethernet duplex
Date: Sun, 29 Aug 2010 03:34:11 -0400
Message-ID: <AANLkTi=CT8jVpn0UJ7SLYHCXvqZJ3yWMbqRJ+XPUTZSB@mail.gmail.com>
References: <1282938138-17844-1-git-send-email-Kyle.D.Moffett@boeing.com>
 <1282938138-17844-2-git-send-email-Kyle.D.Moffett@boeing.com> <20100828.160357.102557054.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kyle.D.Moffett@boeing.com, linux-kernel@vger.kernel.org,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100828.160357.102557054.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 28, 2010 at 19:03, David Miller <davem@davemloft.net> wrote=
:
> From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
> Date: Fri, 27 Aug 2010 15:42:17 -0400
>> In order to configure those kinds of forced modes from userspace, we
>> need to add additional options to the "ethtool" interface. =C2=A0As =
such
>> "unidirectional" ethernet modes most closely resemble ethernet "dupl=
ex",
>> we add two additional DUPLEX_* defines to the ethtool interface:
>>
>> =C2=A0 #define DUPLEX_TXONLY 0x02
>> =C2=A0 #define DUPLEX_RXONLY 0x03
>
> A fine idea, but you're really going to have to audit all of the netw=
orking
> drivers to clean up the existing uses that assume this thing is a bit=
map
> and that there are only essentially two values ('0' and '1'). =C2=A0F=
or example:

Well... basically every driver would require specific tweaks to enable
unidirectional link support even in the best case *anyways*.

=46or example, several SOC chipsets have errata which require a receive
clock in order to reset the chip.  When they are in the "link down"
state, they provide their own fake PHY receive clock copied from an
onboard fixed clock, and when they are in the "link up" state they use
the incoming clock.  Furthermore, they require the RX and TX clocks to
be running at the same frequency (if the RX clock is available)
because of a PLL linking them, so in order to make them work with
unidirectional links, you have to significantly fudge with the fake RX
clock in order to keep the chip operational.

> Finally, phy_ethtool_sset() does this too, so with your patch applied=
 even
> phylib would reject the new settings:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (cmd->autoneg =3D=3D AUTONEG_DISABLE &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0((cmd->speed !=3D SPEED_1000=
 &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cmd->speed !=3D SPEED=
_100 &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cmd->speed !=3D SPEED=
_10) ||
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (cmd->duplex !=3D DUPLEX_HA=
LF &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cmd->duplex !=3D DUPL=
EX_FULL)))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL=
;
>
> making it impossible to add support for TX-only or RX-only in a phyli=
b
> using driver.

As you noted, phylib does not have support for the txonly/rxonly
duplex, so drivers using that will automatically return EINVAL as they
would for any other unsupported ethtool options.  I have a very
involved patch series for phylib that reworks some of the ethtool
operations to be more easily customized by individual PHYs but it's
not quite done yet, let alone tested.

Due to the complexity of the phylib patches and because sky2 does not
use phylib yet, I'd like to start with just the simplistic tested sky2
patch.  Since all other drivers would just return -EINVAL, there is no
possibility for ABI/API breakage outside of the sky2 driver.


> There are probably other similar dragons hiding in various drivers, y=
ou'll
> really have to do a full audit of how every driver stores and makes u=
se of
> duplex settings before we can seriously apply this patch.

If everyone thinks this particular choice of interface is appropriate
for configuring unidirectional links then I think these two patches
should be mergeable.  I'd especially like to get the first one (which
defines the constants) merged, as that reasonably defines the ABI and
provides a reference for the minor patches to the "ethtool" program.
If you really want I can try to post some of the sample phylib patches
but as I said they're still in very rough shape, as I wanted to get
the ABI extension reviewed and committed before I invested too much
time in them.

In general, my plan for phylib drivers is to change ethtool_sset() and
ethtool_gset() to be phy_driver function pointers.  When the ethernet
driver's mydriver_ethtool_sset() function is called, it will perform
any of its own validation on the settings first, then call static
inline phy_ethtool_sset(), which will look up the function pointer and
call that (by default genphy_ethtool_sset(), based on the current
global version).  Any PHY which has appropriate bits to support
unidirectional operation would customize that function to allow
additional modes and program the PHY regs accordingly.  Please let me
know if this makes sense to you or if you have any other questions.

Thanks again for your comments!

Cheers,
Kyle Moffett
