From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Fri, 18 Sep 2015 14:57:46 +0100
Message-ID: <20150918135746.GG21084@n2100.arm.linux.org.uk>
References: <20150914103207.GH21084@n2100.arm.linux.org.uk>
 <55F6AA25.2070603@list.ru>
 <20150914114209.GL21084@n2100.arm.linux.org.uk>
 <20150917.151247.2129216999071943354.davem@davemloft.net>
 <20150917231422.GY21084@n2100.arm.linux.org.uk>
 <55FBF59E.3010205@list.ru>
 <20150918121311.GD21084@n2100.arm.linux.org.uk>
 <55FC070A.6020707@list.ru>
 <20150918131257.GF21084@n2100.arm.linux.org.uk>
 <55FC151F.6040708@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, andrew@lunn.ch,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:58298 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831AbbIRN55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 09:57:57 -0400
Content-Disposition: inline
In-Reply-To: <55FC151F.6040708@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 04:43:59PM +0300, Stas Sergeev wrote:
> 18.09.2015 16:12, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=D1=
=82:
> > On Fri, Sep 18, 2015 at 03:43:54PM +0300, Stas Sergeev wrote:
> >> 18.09.2015 15:13, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=
=D1=82:
> >>> On Fri, Sep 18, 2015 at 02:29:34PM +0300, Stas Sergeev wrote:
> >>>> 18.09.2015 02:14, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=
=B5=D1=82:
> >>>>>  _But_ using the in-band status
> >>>>>    property fundamentally requires this for mvneta to behave co=
rrectly:
> >>>>>
> >>>>> 		phy-mode =3D "sgmii";
> >>>>> 		managed =3D "in-band-status";
> >>>>> 		fixed-link {
> >>>>> 		};
> >>>>>
> >>>>>    with _no_ phy node.
> >>>> I don't understand this one.
> >>>> At least for me it works without empty fixed-link.
> >>>> There may be some bug.
> >>>
> >>>         if (cause_rx_tx & MVNETA_MISCINTR_INTR_MASK) {
> >>>                 u32 cause_misc =3D mvreg_read(pp, MVNETA_INTR_MIS=
C_CAUSE);
> >>>
> >>>                 mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
> >>>                 if (pp->use_inband_status && (cause_misc &
> >>>                                 (MVNETA_CAUSE_PHY_STATUS_CHANGE |
> >>>                                  MVNETA_CAUSE_LINK_CHANGE |
> >>>                                  MVNETA_CAUSE_PSC_SYNC_CHANGE))) =
{
> >>>                         mvneta_fixed_link_update(pp, pp->phy_dev)=
;
> >>>                 }
> >>>
> >>> pp->use_inband_status is set when managed =3D "in-band-status" is=
 set.
> >>> We detect changes in the in-band status, and call mvneta_fixed_li=
nk_update():
> >>>
> >>> mvneta_fixed_link_update() reads the status, and communicates tha=
t into
> >>> the fixed-link phy:
> >>>
> >>>         u32 gmac_stat =3D mvreg_read(pp, MVNETA_GMAC_STATUS);
> >>>
> >>> 	... code setting status.* values from gmac_stat ...
> >>>         changed.link =3D 1;
> >>>         changed.speed =3D 1;
> >>>         changed.duplex =3D 1;
> >>> 	fixed_phy_update_state(phy, &status, &changed);
> >>>
> >>> fixed_phy_update_state() then looks up the phy in its list, compa=
ring only
> >>> the address:
> >>>
> >>>         if (!phydev || !phydev->bus)
> >>>                 return -EINVAL;
> >>>
> >>>         list_for_each_entry(fp, &fmb->phys, node) {
> >>>                 if (fp->addr =3D=3D phydev->addr) {
> >>>
> >>> updating fp->* with the new state, calling fixed_phy_update_regs(=
).  This
> >>> updates the fixed-link phy emulated registers, and phylib then no=
tices
> >>> the change in link status, and notifies the netdevice attached to=
 the
> >>> PHY it found of the change.
> >>>
> >>> Now, one of two things happens as a result of this:
> >>>
> >>> 1. If pp->phy_dev is a fixed-link phy, this finds the correct fix=
ed-link
> >>>    phy to update its "fixed-link" properties, and the "not so fix=
ed" phy
> >>>    changes its parameters according to the new status.
> >>>
> >>> 2. If pp->phy_dev is a MDIO phy which matches the address of a fi=
xed-link
> >>>    phy,
> >> Doesn't the above loop iterates only "fixed_mdio_bus platform_fmb"=
?
> >> I don't think MDIO PHYs can appear there. If they can - the bug is
> >> very nasty. Have you seen exactly when/why that happens?
> >=20
> > I think I explained it fully - please follow the code paths I've de=
tailed
> > above.
> I try. What I don't understand is why both PHYs get the
> same address on the "Fixed MDIO bus".

They aren't both on the fixed MDIO bus - that's the whole point I'm
making.  They get the same phydev->addr but on _different_ buses.

> > Specifically, look at this code:
> >=20
> >          if (!phydev || !phydev->bus)
> >                  return -EINVAL;
> >=20
> >          list_for_each_entry(fp, &fmb->phys, node) {
> >                  if (fp->addr =3D=3D phydev->addr) {

Look at this closely - at what point is there any validation that "phyd=
ev"
is actually a fixed-link phy?  There is no validation done.  The only
criteria there are:
- phydev is not NULL
- phydev->bus is not NULL (which is true of any registered phy)
- phydev->addr matches _any_ fixed-link phy.

I've already sent a patch earlier today to address this issue.

If you place a WARN_ON(fp->phydev !=3D phydev) then that'll show you
when it incorrectly matches.

> > Consider what the effect is if you have a MDIO phy at address 0 on =
eth0
> > which has in-band-status enabled.
> So as I understand, you have MDIO phy with DT looking like this:
> ethernet@70000 {
>   status =3D "okay";
>   phy-mode =3D "sgmii";
>   managed =3D "in-band-status";
> }
> W/O either "phy" of "fixed-link" nodes. Correct?
> mvneta calls of_phy_register_fixed_link(dn) on it after not
> finding the "phy" node. And it will do the same with the second
> non-MDIO phy. What I don't see is how do they get the same addr
> on the same bus, could you please clarify that a bit?

		mdio@72004 {
			phy_dedicated: ethernet-phy@0 {
				reg =3D <0>;
			};
		};

		eth1: ethernet@30000 {
			phy =3D <&phy_dedicated>;
			phy-mode =3D "sgmii";
			managed =3D "in-band-status";
		};

		eth0: ethernet@70000 {
			phy-mode =3D "sgmii";
			fixed-link {
				speed =3D 1000;
				full-duplex;
			};
		};

Bring eth0 up first, everything works.  Then, bring eth1 up, and eth0
goes down.

This happens because when eth1 is brought up, eth1's mvneta calls into
fixed_phy_update_state() with a pointer to the "phy_dedicated" PHY at
address 0.  fixed_phy_update_state() scans the fixed-link phys for one
at address 0, and finds the fixed-link phy associated with eth0.
This causes the fixed link code to change the settings for eth0.

As I have already shown in my previous setup diagrams, it is _entirely_
reasonable to use in-band status with SGMII with a phy attached.

--=20
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
