From: Stas Sergeev <stsp@list.ru>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Fri, 18 Sep 2015 16:43:59 +0300
Message-ID: <55FC151F.6040708@list.ru>
References: <20150914103207.GH21084@n2100.arm.linux.org.uk>
 <55F6AA25.2070603@list.ru> <20150914114209.GL21084@n2100.arm.linux.org.uk>
 <20150917.151247.2129216999071943354.davem@davemloft.net>
 <20150917231422.GY21084@n2100.arm.linux.org.uk> <55FBF59E.3010205@list.ru>
 <20150918121311.GD21084@n2100.arm.linux.org.uk> <55FC070A.6020707@list.ru>
 <20150918131257.GF21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, andrew@lunn.ch,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp13.mail.ru ([94.100.181.94]:52240 "EHLO smtp13.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596AbbIRNoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 09:44:10 -0400
In-Reply-To: <20150918131257.GF21084@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

18.09.2015 16:12, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
> On Fri, Sep 18, 2015 at 03:43:54PM +0300, Stas Sergeev wrote:
>> 18.09.2015 15:13, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=D1=
=82:
>>> On Fri, Sep 18, 2015 at 02:29:34PM +0300, Stas Sergeev wrote:
>>>> 18.09.2015 02:14, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=
=D1=82:
>>>>>  _But_ using the in-band status
>>>>>    property fundamentally requires this for mvneta to behave corr=
ectly:
>>>>>
>>>>> 		phy-mode =3D "sgmii";
>>>>> 		managed =3D "in-band-status";
>>>>> 		fixed-link {
>>>>> 		};
>>>>>
>>>>>    with _no_ phy node.
>>>> I don't understand this one.
>>>> At least for me it works without empty fixed-link.
>>>> There may be some bug.
>>>
>>>         if (cause_rx_tx & MVNETA_MISCINTR_INTR_MASK) {
>>>                 u32 cause_misc =3D mvreg_read(pp, MVNETA_INTR_MISC_=
CAUSE);
>>>
>>>                 mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
>>>                 if (pp->use_inband_status && (cause_misc &
>>>                                 (MVNETA_CAUSE_PHY_STATUS_CHANGE |
>>>                                  MVNETA_CAUSE_LINK_CHANGE |
>>>                                  MVNETA_CAUSE_PSC_SYNC_CHANGE))) {
>>>                         mvneta_fixed_link_update(pp, pp->phy_dev);
>>>                 }
>>>
>>> pp->use_inband_status is set when managed =3D "in-band-status" is s=
et.
>>> We detect changes in the in-band status, and call mvneta_fixed_link=
_update():
>>>
>>> mvneta_fixed_link_update() reads the status, and communicates that =
into
>>> the fixed-link phy:
>>>
>>>         u32 gmac_stat =3D mvreg_read(pp, MVNETA_GMAC_STATUS);
>>>
>>> 	... code setting status.* values from gmac_stat ...
>>>         changed.link =3D 1;
>>>         changed.speed =3D 1;
>>>         changed.duplex =3D 1;
>>> 	fixed_phy_update_state(phy, &status, &changed);
>>>
>>> fixed_phy_update_state() then looks up the phy in its list, compari=
ng only
>>> the address:
>>>
>>>         if (!phydev || !phydev->bus)
>>>                 return -EINVAL;
>>>
>>>         list_for_each_entry(fp, &fmb->phys, node) {
>>>                 if (fp->addr =3D=3D phydev->addr) {
>>>
>>> updating fp->* with the new state, calling fixed_phy_update_regs().=
  This
>>> updates the fixed-link phy emulated registers, and phylib then noti=
ces
>>> the change in link status, and notifies the netdevice attached to t=
he
>>> PHY it found of the change.
>>>
>>> Now, one of two things happens as a result of this:
>>>
>>> 1. If pp->phy_dev is a fixed-link phy, this finds the correct fixed=
-link
>>>    phy to update its "fixed-link" properties, and the "not so fixed=
" phy
>>>    changes its parameters according to the new status.
>>>
>>> 2. If pp->phy_dev is a MDIO phy which matches the address of a fixe=
d-link
>>>    phy,
>> Doesn't the above loop iterates only "fixed_mdio_bus platform_fmb"?
>> I don't think MDIO PHYs can appear there. If they can - the bug is
>> very nasty. Have you seen exactly when/why that happens?
>=20
> I think I explained it fully - please follow the code paths I've deta=
iled
> above.
I try. What I don't understand is why both PHYs get the
same address on the "Fixed MDIO bus".

>=20
> Specifically, look at this code:
>=20
>          if (!phydev || !phydev->bus)
>                  return -EINVAL;
>=20
>          list_for_each_entry(fp, &fmb->phys, node) {
>                  if (fp->addr =3D=3D phydev->addr) {
>=20
> Consider what the effect is if you have a MDIO phy at address 0 on et=
h0
> which has in-band-status enabled.
So as I understand, you have MDIO phy with DT looking like this:
ethernet@70000 {
  status =3D "okay";
  phy-mode =3D "sgmii";
  managed =3D "in-band-status";
}
W/O either "phy" of "fixed-link" nodes. Correct?
mvneta calls of_phy_register_fixed_link(dn) on it after not
finding the "phy" node. And it will do the same with the second
non-MDIO phy. What I don't see is how do they get the same addr
on the same bus, could you please clarify that a bit?

>>> Now, a fixed-link phy is only created in mvneta when there is no MD=
IO phy
>>> specified, but when there is a fixed-link specification in DT:
>>>
>>>         phy_node =3D of_parse_phandle(dn, "phy", 0);
>>>         if (!phy_node) {
>>>                 if (!of_phy_is_fixed_link(dn)) {
>>>                         dev_err(&pdev->dev, "no PHY specified\n");
>>>                         err =3D -ENODEV;
>>>                         goto err_free_irq;
>>>                 }
>>>
>>>                 err =3D of_phy_register_fixed_link(dn);
>>>                 if (err < 0) {
>>>                         dev_err(&pdev->dev, "cannot register fixed =
PHY\n");
>>>                         goto err_free_irq;
>>>                 }
>>>
>>> If there's neither a MDIO PHY nor a fixed-link, then the network dr=
iver
>>> fails to initialise the device.
>> But it does.
>=20
> Please, look again at the code I quoted above.
>=20
>> In fact, of_mdio.c has this code:
>>
>>         err =3D of_property_read_string(np, "managed", &managed);
>>         if (err =3D=3D 0) {
>>                 if (strcmp(managed, "in-band-status") =3D=3D 0) {
>>                         /* status is zeroed, namely its .link member=
 */
>>                         phy =3D fixed_phy_register(PHY_POLL, &status=
, np);
>>                         return IS_ERR(phy) ? PTR_ERR(phy) : 0;
>>                 }
>>         }
>>
>> Which is exactly for the case you describe.
>=20
> That code is in of_phy_register_fixed_link().  That code will _NOT_ b=
e
> reached if a MDIO phy is specified.  Again, please read the code.
I think the DT quote is missing here for me to understand.
This code is for managed =3D "in-band-status", which is what I thought
you are talking about.
Could you please quote the DT that creates 2 PHYs with the
same addr on fmb? I'll try it here and from that will understand.


>> Maybe if some downlink tells the MAC what autoneg protocol will
>> be used, you can have:
>>   		phy-mode =3D "1000base-x" | "sgmii" | "serdes-auto";
>>   		managed =3D "in-band-status";
>>
>> and "serdes-auto" will use either "1000base-x" or "sgmii", depending
>> on what the downlink says?
>=20
> Maybe, but rather than guessing and getting it wrong, let's wait unti=
l
> we know what kind of a solution is necessary here.  Rushing this will
> only create another design mistake and an even larger can of worms.
That was just an idea of how to get it without changing the current
values of the "managed" property.
