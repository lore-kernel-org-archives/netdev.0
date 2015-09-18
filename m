From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Fri, 18 Sep 2015 13:13:12 +0100
Message-ID: <20150918121311.GD21084@n2100.arm.linux.org.uk>
References: <20150914103207.GH21084@n2100.arm.linux.org.uk>
 <55F6AA25.2070603@list.ru>
 <20150914114209.GL21084@n2100.arm.linux.org.uk>
 <20150917.151247.2129216999071943354.davem@davemloft.net>
 <20150917231422.GY21084@n2100.arm.linux.org.uk>
 <55FBF59E.3010205@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, andrew@lunn.ch,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:58056 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbbIRMNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 08:13:23 -0400
Content-Disposition: inline
In-Reply-To: <55FBF59E.3010205@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 02:29:34PM +0300, Stas Sergeev wrote:
> 18.09.2015 02:14, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=D1=
=82:
> >  _But_ using the in-band status
> >    property fundamentally requires this for mvneta to behave correc=
tly:
> >=20
> > 		phy-mode =3D "sgmii";
> > 		managed =3D "in-band-status";
> > 		fixed-link {
> > 		};
> >=20
> >    with _no_ phy node.
> I don't understand this one.
> At least for me it works without empty fixed-link.
> There may be some bug.

        if (cause_rx_tx & MVNETA_MISCINTR_INTR_MASK) {
                u32 cause_misc =3D mvreg_read(pp, MVNETA_INTR_MISC_CAUS=
E);

                mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
                if (pp->use_inband_status && (cause_misc &
                                (MVNETA_CAUSE_PHY_STATUS_CHANGE |
                                 MVNETA_CAUSE_LINK_CHANGE |
                                 MVNETA_CAUSE_PSC_SYNC_CHANGE))) {
                        mvneta_fixed_link_update(pp, pp->phy_dev);
                }

pp->use_inband_status is set when managed =3D "in-band-status" is set.
We detect changes in the in-band status, and call mvneta_fixed_link_upd=
ate():

mvneta_fixed_link_update() reads the status, and communicates that into
the fixed-link phy:

        u32 gmac_stat =3D mvreg_read(pp, MVNETA_GMAC_STATUS);

	... code setting status.* values from gmac_stat ...
        changed.link =3D 1;
        changed.speed =3D 1;
        changed.duplex =3D 1;
	fixed_phy_update_state(phy, &status, &changed);

fixed_phy_update_state() then looks up the phy in its list, comparing o=
nly
the address:

        if (!phydev || !phydev->bus)
                return -EINVAL;

        list_for_each_entry(fp, &fmb->phys, node) {
                if (fp->addr =3D=3D phydev->addr) {

updating fp->* with the new state, calling fixed_phy_update_regs().  Th=
is
updates the fixed-link phy emulated registers, and phylib then notices
the change in link status, and notifies the netdevice attached to the
PHY it found of the change.

Now, one of two things happens as a result of this:

1. If pp->phy_dev is a fixed-link phy, this finds the correct fixed-lin=
k
   phy to update its "fixed-link" properties, and the "not so fixed" ph=
y
   changes its parameters according to the new status.

2. If pp->phy_dev is a MDIO phy which matches the address of a fixed-li=
nk
   phy, the fixed-link phy state is updated with the new parameters, an=
d
   some other net device in the system changes link state - the setting=
s
   are not communicated back to the mvneta instance which changed link
   state.

3. If pp->phy_dev is a MDIO phy but does not match a fixed-link phy,
   nothing happens and fixed_phy_update_state() returns -ENOENT.  Again=
,
   the settings are not communicated back to the mvneta instance which
   changed link state.

Now, a fixed-link phy is only created in mvneta when there is no MDIO p=
hy
specified, but when there is a fixed-link specification in DT:

        phy_node =3D of_parse_phandle(dn, "phy", 0);
        if (!phy_node) {
                if (!of_phy_is_fixed_link(dn)) {
                        dev_err(&pdev->dev, "no PHY specified\n");
                        err =3D -ENODEV;
                        goto err_free_irq;
                }

                err =3D of_phy_register_fixed_link(dn);
                if (err < 0) {
                        dev_err(&pdev->dev, "cannot register fixed PHY\=
n");
                        goto err_free_irq;
                }

If there's neither a MDIO PHY nor a fixed-link, then the network driver
fails to initialise the device.

> > What I don't know is how many generations of the mvneta hardware ha=
ve
> > support for both serdes modes, but what I'm basically saying is tha=
t
> > the solution we now have seems to be somewhat lacking - maybe it sh=
ould
> > have been "auto", "in-band-sgmii" and "in-band-1000base-x" with the
> > ability to add additional modes later.
>
> Well, you need to be quick with such a change, esp now when the patch
> was queued to -stable.
> What alternatives do we have here?
> Will the following work too?
>  		phy-mode =3D "1000base-x";
>  		managed =3D "in-band-status";

There's no chance of being "quick" here - the issues are complex and no=
t
trivial to solve in a day - I've already spent all week thinking about
the issues here, and I'm only _just_ starting to come up with a potenti=
al
solution this morning, though I haven't yet assessed whether it'll be
feasible.

The problem I have with the above is that it fixes the phy mode to eith=
er
SGMII or 1000base-X, whereas what we need for the SFP case is to have t=
he
down-link object tell the MAC driver whether it wants SGMII or 1000base=
-X
mode.

--=20
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
