From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 05/14] phylib: add *_direct() variants of phy_connect and
	phy_attach functions
Date: Sat, 18 Apr 2009 00:08:32 -0600
Message-ID: <fa686aa40904172308l38919bc0jfffbeb3a4106f582@mail.gmail.com>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
	<20090331082709.1427.48689.stgit@localhost.localdomain> <FD808CF0-C694-4388-BBBE-B92367663F54@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, olof@lixom.net,
	galak@kernel.crashing.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:56517 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbZDRGIs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 02:08:48 -0400
Received: by yx-out-2324.google.com with SMTP id 3so313698yxj.1
        for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 23:08:47 -0700 (PDT)
In-Reply-To: <FD808CF0-C694-4388-BBBE-B92367663F54@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2009 at 3:10 PM, Andy Fleming <afleming@freescale.com> =
wrote:
>
> On Mar 31, 2009, at 3:27 AM, Grant Likely wrote:
>
>> From: Grant Likely <grant.likely@secretlab.ca>
>>
>> Add phy_connect_direct() and phy_attach_direct() functions so that
>> drivers can use a pointer to the phy_device instead of trying to det=
ermine
>> the phy's bus_id string.
>>
>> This patch is useful for OF device tree descriptions of phy devices =
where
>> the driver doesn't need or know what the bus_id value in order to ge=
t a
>> phy_device pointer.
>>
>> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
>> ---
>> @@ -312,18 +339,21 @@ struct phy_device * phy_connect(struct net_dev=
ice
>> *dev, const char *bus_id,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy_interface_t interface)
>> {
>> =A0 =A0 =A0 =A0struct phy_device *phydev;
>> + =A0 =A0 =A0 struct device *d;
>> + =A0 =A0 =A0 int rc;
>>
>> - =A0 =A0 =A0 phydev =3D phy_attach(dev, bus_id, flags, interface);
>> -
>> - =A0 =A0 =A0 if (IS_ERR(phydev))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return phydev;
>> -
>> - =A0 =A0 =A0 phy_prepare_link(phydev, handler);
>> -
>> - =A0 =A0 =A0 phy_start_machine(phydev, NULL);
>> + =A0 =A0 =A0 /* Search the list of PHY devices on the mdio bus for =
the
>> + =A0 =A0 =A0 =A0* PHY with the requested name */
>> + =A0 =A0 =A0 d =3D bus_find_device_by_name(&mdio_bus_type, NULL, bu=
s_id);
>> + =A0 =A0 =A0 if (!d) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("PHY %s not found\n", bus_id);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENODEV);
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 phydev =3D to_phy_device(d);
>>
>> - =A0 =A0 =A0 if (phydev->irq > 0)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_start_interrupts(phydev);
>> + =A0 =A0 =A0 rc =3D phy_attach_direct(dev, phydev, flags, interface=
);
>> + =A0 =A0 =A0 if (rc)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(rc);
>
>
> Why not just invoke phy_attach(), here, and thereby avoid the duplica=
te
> search code?

Yeah, you're right.  I had done it this way for symmetry, but calling
phy_attach_direct is probably better.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
