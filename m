From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Fri, 18 Sep 2015 14:12:57 +0100
Message-ID: <20150918131257.GF21084@n2100.arm.linux.org.uk>
References: <20150914103207.GH21084@n2100.arm.linux.org.uk>
 <55F6AA25.2070603@list.ru>
 <20150914114209.GL21084@n2100.arm.linux.org.uk>
 <20150917.151247.2129216999071943354.davem@davemloft.net>
 <20150917231422.GY21084@n2100.arm.linux.org.uk>
 <55FBF59E.3010205@list.ru>
 <20150918121311.GD21084@n2100.arm.linux.org.uk>
 <55FC070A.6020707@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, andrew@lunn.ch,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:58193 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbbIRNNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 09:13:10 -0400
Content-Disposition: inline
In-Reply-To: <55FC070A.6020707@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 03:43:54PM +0300, Stas Sergeev wrote:
> 18.09.2015 15:13, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=D1=
=82:
> > On Fri, Sep 18, 2015 at 02:29:34PM +0300, Stas Sergeev wrote:
> >> 18.09.2015 02:14, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=
=D1=82:
> >>>  _But_ using the in-band status
> >>>    property fundamentally requires this for mvneta to behave corr=
ectly:
> >>>
> >>> 		phy-mode =3D "sgmii";
> >>> 		managed =3D "in-band-status";
> >>> 		fixed-link {
> >>> 		};
> >>>
> >>>    with _no_ phy node.
> >> I don't understand this one.
> >> At least for me it works without empty fixed-link.
> >> There may be some bug.
> >=20
> >         if (cause_rx_tx & MVNETA_MISCINTR_INTR_MASK) {
> >                 u32 cause_misc =3D mvreg_read(pp, MVNETA_INTR_MISC_=
CAUSE);
> >=20
> >                 mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
> >                 if (pp->use_inband_status && (cause_misc &
> >                                 (MVNETA_CAUSE_PHY_STATUS_CHANGE |
> >                                  MVNETA_CAUSE_LINK_CHANGE |
> >                                  MVNETA_CAUSE_PSC_SYNC_CHANGE))) {
> >                         mvneta_fixed_link_update(pp, pp->phy_dev);
> >                 }
> >=20
> > pp->use_inband_status is set when managed =3D "in-band-status" is s=
et.
> > We detect changes in the in-band status, and call mvneta_fixed_link=
_update():
> >=20
> > mvneta_fixed_link_update() reads the status, and communicates that =
into
> > the fixed-link phy:
> >=20
> >         u32 gmac_stat =3D mvreg_read(pp, MVNETA_GMAC_STATUS);
> >=20
> > 	... code setting status.* values from gmac_stat ...
> >         changed.link =3D 1;
> >         changed.speed =3D 1;
> >         changed.duplex =3D 1;
> > 	fixed_phy_update_state(phy, &status, &changed);
> >=20
> > fixed_phy_update_state() then looks up the phy in its list, compari=
ng only
> > the address:
> >=20
> >         if (!phydev || !phydev->bus)
> >                 return -EINVAL;
> >=20
> >         list_for_each_entry(fp, &fmb->phys, node) {
> >                 if (fp->addr =3D=3D phydev->addr) {
> >=20
> > updating fp->* with the new state, calling fixed_phy_update_regs().=
  This
> > updates the fixed-link phy emulated registers, and phylib then noti=
ces
> > the change in link status, and notifies the netdevice attached to t=
he
> > PHY it found of the change.
> >=20
> > Now, one of two things happens as a result of this:
> >=20
> > 1. If pp->phy_dev is a fixed-link phy, this finds the correct fixed=
-link
> >    phy to update its "fixed-link" properties, and the "not so fixed=
" phy
> >    changes its parameters according to the new status.
> >=20
> > 2. If pp->phy_dev is a MDIO phy which matches the address of a fixe=
d-link
> >    phy,
> Doesn't the above loop iterates only "fixed_mdio_bus platform_fmb"?
> I don't think MDIO PHYs can appear there. If they can - the bug is
> very nasty. Have you seen exactly when/why that happens?

I think I explained it fully - please follow the code paths I've detail=
ed
above.

Specifically, look at this code:

         if (!phydev || !phydev->bus)
                 return -EINVAL;

         list_for_each_entry(fp, &fmb->phys, node) {
                 if (fp->addr =3D=3D phydev->addr) {

Consider what the effect is if you have a MDIO phy at address 0 on eth0
which has in-band-status enabled.

Now if you have a fixed-link phy on the fixed-link bus at address 0
connected to eth1.

Bring eth1 up, everything works as one would expect, it gains the fixed
link settings.

Now bring eth0 up.  Because there's no distinction in mvneta between a
fixed-link phy and a MDIO phy, it ends up calling fixed_phy_update_stat=
e()
with the MDIO phy, which has phydev->addr =3D 0.

The fixed-link code scans every phy on the fixed-link bus, looking for
one with address 0, and it finds that, and modifies the state of that
phy.

eth1 now gains the settings that eth0 communicated into the fixed-link
phy layer.

> > Now, a fixed-link phy is only created in mvneta when there is no MD=
IO phy
> > specified, but when there is a fixed-link specification in DT:
> >=20
> >         phy_node =3D of_parse_phandle(dn, "phy", 0);
> >         if (!phy_node) {
> >                 if (!of_phy_is_fixed_link(dn)) {
> >                         dev_err(&pdev->dev, "no PHY specified\n");
> >                         err =3D -ENODEV;
> >                         goto err_free_irq;
> >                 }
> >=20
> >                 err =3D of_phy_register_fixed_link(dn);
> >                 if (err < 0) {
> >                         dev_err(&pdev->dev, "cannot register fixed =
PHY\n");
> >                         goto err_free_irq;
> >                 }
> >=20
> > If there's neither a MDIO PHY nor a fixed-link, then the network dr=
iver
> > fails to initialise the device.
> But it does.

Please, look again at the code I quoted above.

> In fact, of_mdio.c has this code:
>=20
>         err =3D of_property_read_string(np, "managed", &managed);
>         if (err =3D=3D 0) {
>                 if (strcmp(managed, "in-band-status") =3D=3D 0) {
>                         /* status is zeroed, namely its .link member =
*/
>                         phy =3D fixed_phy_register(PHY_POLL, &status,=
 np);
>                         return IS_ERR(phy) ? PTR_ERR(phy) : 0;
>                 }
>         }
>=20
> Which is exactly for the case you describe.

That code is in of_phy_register_fixed_link().  That code will _NOT_ be
reached if a MDIO phy is specified.  Again, please read the code.

> >>> What I don't know is how many generations of the mvneta hardware =
have
> >>> support for both serdes modes, but what I'm basically saying is t=
hat
> >>> the solution we now have seems to be somewhat lacking - maybe it =
should
> >>> have been "auto", "in-band-sgmii" and "in-band-1000base-x" with t=
he
> >>> ability to add additional modes later.
> >>
> >> Well, you need to be quick with such a change, esp now when the pa=
tch
> >> was queued to -stable.
> >> What alternatives do we have here?
> >> Will the following work too?
> >>  		phy-mode =3D "1000base-x";
> >>  		managed =3D "in-band-status";
> >=20
> > There's no chance of being "quick" here - the issues are complex an=
d not
> > trivial to solve in a day - I've already spent all week thinking ab=
out
> > the issues here, and I'm only _just_ starting to come up with a pot=
ential
> > solution this morning, though I haven't yet assessed whether it'll =
be
> > feasible.
> >=20
> > The problem I have with the above is that it fixes the phy mode to =
either
> > SGMII or 1000base-X, whereas what we need for the SFP case is to ha=
ve the
> > down-link object tell the MAC driver whether it wants SGMII or 1000=
base-X
> > mode.
> Not that I understand that SFP business at all.
> Maybe if some downlink tells the MAC what autoneg protocol will
> be used, you can have:
>   		phy-mode =3D "1000base-x" | "sgmii" | "serdes-auto";
>   		managed =3D "in-band-status";
>=20
> and "serdes-auto" will use either "1000base-x" or "sgmii", depending
> on what the downlink says?

Maybe, but rather than guessing and getting it wrong, let's wait until
we know what kind of a solution is necessary here.  Rushing this will
only create another design mistake and an even larger can of worms.

--=20
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
