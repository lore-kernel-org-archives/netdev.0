From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Fri, 18 Sep 2015 16:43:39 +0100
Message-ID: <20150918154339.GJ21084@n2100.arm.linux.org.uk>
References: <20150914114209.GL21084@n2100.arm.linux.org.uk>
 <20150917.151247.2129216999071943354.davem@davemloft.net>
 <20150917231422.GY21084@n2100.arm.linux.org.uk>
 <55FBF59E.3010205@list.ru>
 <20150918121311.GD21084@n2100.arm.linux.org.uk>
 <55FC070A.6020707@list.ru>
 <20150918131257.GF21084@n2100.arm.linux.org.uk>
 <55FC151F.6040708@list.ru>
 <20150918135746.GG21084@n2100.arm.linux.org.uk>
 <55FC2387.9080304@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, andrew@lunn.ch,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:58528 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754535AbbIRPnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 11:43:50 -0400
Content-Disposition: inline
In-Reply-To: <55FC2387.9080304@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 05:45:27PM +0300, Stas Sergeev wrote:
> 18.09.2015 16:57, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=D1=
=82:
> > On Fri, Sep 18, 2015 at 04:43:59PM +0300, Stas Sergeev wrote:
> >> 18.09.2015 16:12, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=
=D1=82:
> >>> On Fri, Sep 18, 2015 at 03:43:54PM +0300, Stas Sergeev wrote:
> >>>> 18.09.2015 15:13, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=
=B5=D1=82:
> >>>>> On Fri, Sep 18, 2015 at 02:29:34PM +0300, Stas Sergeev wrote:
> >>>>>> 18.09.2015 02:14, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=
=B5=D1=82:
> >>>>>>>  _But_ using the in-band status
> >>>>>>>    property fundamentally requires this for mvneta to behave =
correctly:
> >>>>>>>
> >>>>>>> 		phy-mode =3D "sgmii";
> >>>>>>> 		managed =3D "in-band-status";
> >>>>>>> 		fixed-link {
> >>>>>>> 		};
> >>>>>>>
> >>>>>>>    with _no_ phy node.
> >>>>>> I don't understand this one.
> >>>>>> At least for me it works without empty fixed-link.
> >>>>>> There may be some bug.
> >>>>>
> >>>>>         if (cause_rx_tx & MVNETA_MISCINTR_INTR_MASK) {
> >>>>>                 u32 cause_misc =3D mvreg_read(pp, MVNETA_INTR_M=
ISC_CAUSE);
> >>>>>
> >>>>>                 mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
> >>>>>                 if (pp->use_inband_status && (cause_misc &
> >>>>>                                 (MVNETA_CAUSE_PHY_STATUS_CHANGE=
 |
> >>>>>                                  MVNETA_CAUSE_LINK_CHANGE |
> >>>>>                                  MVNETA_CAUSE_PSC_SYNC_CHANGE))=
) {
> >>>>>                         mvneta_fixed_link_update(pp, pp->phy_de=
v);
> >>>>>                 }
> >>>>>
> >>>>> pp->use_inband_status is set when managed =3D "in-band-status" =
is set.
> >>>>> We detect changes in the in-band status, and call mvneta_fixed_=
link_update():
> >>>>>
> >>>>> mvneta_fixed_link_update() reads the status, and communicates t=
hat into
> >>>>> the fixed-link phy:
> >>>>>
> >>>>>         u32 gmac_stat =3D mvreg_read(pp, MVNETA_GMAC_STATUS);
> >>>>>
> >>>>> 	... code setting status.* values from gmac_stat ...
> >>>>>         changed.link =3D 1;
> >>>>>         changed.speed =3D 1;
> >>>>>         changed.duplex =3D 1;
> >>>>> 	fixed_phy_update_state(phy, &status, &changed);
> >>>>>
> >>>>> fixed_phy_update_state() then looks up the phy in its list, com=
paring only
> >>>>> the address:
> >>>>>
> >>>>>         if (!phydev || !phydev->bus)
> >>>>>                 return -EINVAL;
> >>>>>
> >>>>>         list_for_each_entry(fp, &fmb->phys, node) {
> >>>>>                 if (fp->addr =3D=3D phydev->addr) {
> >>>>>
> >>>>> updating fp->* with the new state, calling fixed_phy_update_reg=
s().  This
> >>>>> updates the fixed-link phy emulated registers, and phylib then =
notices
> >>>>> the change in link status, and notifies the netdevice attached =
to the
> >>>>> PHY it found of the change.
> >>>>>
> >>>>> Now, one of two things happens as a result of this:
> >>>>>
> >>>>> 1. If pp->phy_dev is a fixed-link phy, this finds the correct f=
ixed-link
> >>>>>    phy to update its "fixed-link" properties, and the "not so f=
ixed" phy
> >>>>>    changes its parameters according to the new status.
> >>>>>
> >>>>> 2. If pp->phy_dev is a MDIO phy which matches the address of a =
fixed-link
> >>>>>    phy,
> >>>> Doesn't the above loop iterates only "fixed_mdio_bus platform_fm=
b"?
> >>>> I don't think MDIO PHYs can appear there. If they can - the bug =
is
> >>>> very nasty. Have you seen exactly when/why that happens?
> >>>
> >>> I think I explained it fully - please follow the code paths I've =
detailed
> >>> above.
> >> I try. What I don't understand is why both PHYs get the
> >> same address on the "Fixed MDIO bus".
> >=20
> > They aren't both on the fixed MDIO bus - that's the whole point I'm
> > making.  They get the same phydev->addr but on _different_ buses.
>
> So you have an MDIO phy for which mvneta seems to have
> use_inband_status=3D=3Dtrue, correct?

That is one very real possibililty.  Cisco SGMII in-band status is for =
a
SGMII PHY to inform the MAC about the properties of the link to which t=
he
PHY is attached.

So, specifying "managed =3D in-band-status" along with a real PHY is ve=
ry
much a _real_ possibility, as I've previously explained.

> AFAICS if it has use_inband_status=3D=3Dtrue,
> then it went through of_phy_register_fixed_link(dn),

That's totally incorrect.  The test for setting use_inband_status in
mvneta is:

        err =3D of_property_read_string(dn, "managed", &managed);
        pp->use_inband_status =3D (err =3D=3D 0 &&
                                 strcmp(managed, "in-band-status") =3D=3D=
 0);

So, use_inband_status can be set _whatever_.  It doesn't matter if
there's a fixed-phy being used, or whether a real MDIO phy has been
specified.

The _actual_ situation I had when I encountered the problem was:

eth0 - connected to a DSA switch
eth1 - connected to SFP "phy" with in-band-status enabled (for 1000base=
-X)
       where this phy is sitting on its own virtual MDIO bus.
eth2 - connected to a RGMII phy.

At boot, eth2 is brought up by DHCP, and eth0 is configured up as part
of the switch initialisation.  eth0 comes up fine.

Then, I manually brought up eth1, very unexpectedly eth0 immediately we=
nt
down - and this was completely repeatable, caused by this problem.

> You described the update status path very precisely in your prev mail=
,
> but this doesn't help because what I don't understand is the particul=
ar
> _setup_ path that leads to use_inband_status=3D=3Dtrue yet the phy is=
 not
> on the fmb.

I think I covered that in the email to which you're replying, where I
show you that I have a "phy=3D" node within the ethernet definition.
That means:

        phy_node =3D of_parse_phandle(dn, "phy", 0);

will return non-NULL, and that means:

        if (!phy_node) {
                if (!of_phy_is_fixed_link(dn)) {
                        dev_err(&pdev->dev, "no PHY specified\n");
                        err =3D -ENODEV;
                        goto err_free_irq;
                }

                err =3D of_phy_register_fixed_link(dn);

the code here is never reached.

I'm failing to see what the problem is - the code you keep referring
me to won't be called in the situation I'm describing.

--=20
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
