From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 5/5] net: make mpc5200 fec driver use of_mdio
	infrastructure
Date: Tue, 10 Mar 2009 13:48:26 -0600
Message-ID: <fa686aa40903101248n33ee35c2o32c4b24b349b14fc@mail.gmail.com>
References: <20090310150751.12455.70598.stgit@localhost.localdomain>
	 <20090310152224.12455.99348.stgit@localhost.localdomain>
	 <20090310191638.GA8539@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: afleming@freescale.com, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:52236 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754448AbZCJTs2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 15:48:28 -0400
In-Reply-To: <20090310191638.GA8539@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 1:16 PM, Anton Vorontsov
<avorontsov@ru.mvista.com> wrote:
> On Tue, Mar 10, 2009 at 09:22:24AM -0600, Grant Likely wrote:
>> From: Grant Likely <grant.likely@secretlab.ca>
> [...]
>> +static int mpc52xx_fec_notifier_phy_add(struct notifier_block *nb,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long event, void *_dev)
>> +{
> [...]
>> + =A0 =A0 rc =3D phy_connect_direct(priv->ndev, priv->phydev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mpc52xx_fe=
c_adjust_link, 0, 0);
>> + =A0 =A0 if (rc) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 dev_err(dev, "phy_connect_direct() failed\=
n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 rc =3D register_netdev(priv->ndev);
>> + =A0 =A0 if (rc) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 phy_disconnect(priv->phydev);
>> + =A0 =A0 =A0 =A0 =A0 =A0 dev_err(dev, "register_netdev() failed\n")=
;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 return 0;
>> +}
> [...]
>> =A0static int __devinit
>> =A0mpc52xx_fec_probe(struct of_device *op, const struct of_device_id=
 *match)
>> @@ -896,7 +874,6 @@ mpc52xx_fec_probe(struct of_device *op, const st=
ruct of_device_id *match)
> [...]
>> + =A0 =A0 /* Register the new network device immediately if we don't=
 need
>> + =A0 =A0 =A0* to wait for a phy_device first. */
>> + =A0 =A0 if (!priv->phy_node) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (priv->seven_wire_mode)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&ndev->dev, "usin=
g 7-wire PHY mode\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&ndev->dev, "Fixe=
d speed MII link: %i%cD\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->s=
peed, priv->duplex ? 'F' : 'H');
>> + =A0 =A0 =A0 =A0 =A0 =A0 rv =3D register_netdev(ndev);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (rv < 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto probe_error;
>> =A0 =A0 =A0 }
> [...]
>
> Two registration points for the netdev... That's ugly. :-/
>
> What problem are you trying to solve w/ these patches, btw?
>
> `ifconfig ethX up` is safe even w/o PHY attached.
>
> All the (user-visible) changes is that we no longer have "ethX"
> until PHY is registered, and I can't say that this is good either.

=46air enough.  If it is okay to register the PHY after registering the
netdev, then I have no problem with it.  I'll change the patch.

> I can't say that the probing code is much prettier or easier to
> understand... But maybe there are some other problems that you're
> solving, which I don't see so far?

Primary problem is that this driver currently does not work for a PHY
on a different MDIO bus.  Secondary is that current code depends on
phys being registered before the FEC.

> That is, can you explain why the changes are needed? Did you
> consider other solutions?

Yes, I considered doing some kind of platform function to call and get
the name of the PHY, but any such thing turned out to be fragile and
rather platform specific.  The bus notifier approach seemed to be the
simplest way to defer part of initialization while waiting for the PHY
to become available.  I want to be using common code here as I've got
another Ethernet driver (ll_temac; not posted yet) that needs to do
the same thing.

>> eliminates the assumption that the PHY for the FEC is always
>> attached to the FEC's own MDIO bus. With this patch, the FEC can
>> use a PHY attached to any MDIO bus if it is described in the device
>> tree.
>
> AFAIK, Gianfar and UCC Geth drivers can do this too, so I'm assuming
> that this isn't the cause for these major changes.

Certainly the mpc5200-fec driver's original phy code certainly wasn't
as robust as the ucc_geth and gianfar phy handling.

ucc_geth open codes a solution to decode the phy_device name from
several nodes in the device tree and doesn't handle the case where the
ucc_geth is initialized before the phy_device is registered.  gianfar
open codes the same thing.  This solution uses common code to locate
the phy_device, and it works regardless of what order devices are
registered in.

That being said, the 5200 driver originally using probe() time to
connect to the phy.  If I change it to be connected at open time, then
does the registration order issue become irrelevant?  Regardless, I
think all the drivers should be using common code for obtaining the
phy_device from the device tree.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
