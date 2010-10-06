From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: powerpc, fs_enet: scanning PHY after Linux is up
Date: Wed, 6 Oct 2010 11:30:19 -0600
Message-ID: <AANLkTinWGw5AR8KSSdCyOWqCaMVL-wZH+2uB7zh404_i@mail.gmail.com>
References: <4CA9830A.2030605@denx.de> <AANLkTinSersREjDnvg=8Gvpa6YmLuzgF1H8eEXRyCpW0@mail.gmail.com>
 <4CAC472F.5070001@denx.de> <4CAC7EB0.6080502@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hs@denx.de, linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, Detlev Zundel <dzu@denx.de>
To: Holger brunck <holger.brunck@keymile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52386 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab0JFRal convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 13:30:41 -0400
Received: by iwn5 with SMTP id 5so9995814iwn.19
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 10:30:40 -0700 (PDT)
In-Reply-To: <4CAC7EB0.6080502@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 6, 2010 at 7:50 AM, Holger brunck <holger.brunck@keymile.co=
m> wrote:
> Hello Heiko,
>
> On 10/06/2010 11:53 AM, Heiko Schocher wrote:
>>>> So, the question is, is there a possibility to solve this problem?
>>>>
>>>> If there is no standard option, what would be with adding a
>>>> "scan_phy" file in
>>>>
>>>> /proc/device-tree/soc\@f0000000/cpm\@119c0/mdio\@10d40
>>>> (or better destination?)
>>>>
>>>> which with we could rescan a PHY with
>>>> "echo addr > /proc/device-tree/soc\@f0000000/cpm\@119c0/mdio\@10d4=
0/scan_phy"
>>>> (so there is no need for using of_find_node_by_path(), as we shoul=
d
>>>> =A0have the associated device node here, and can step through the =
child
>>>> =A0nodes with "for_each_child_of_node(np, child)" and check if reg=
 =3D=3D addr)
>>>>
>>>> or shouldn;t be at least, if the phy couldn;t be found when openin=
g
>>>> the port, retrigger a scanning, if the phy now is accessible?
>>>
>>> One option would be to still register a phy_device for each phy
>>> described in the device tree, but defer binding a driver to each ph=
y
>>> that doesn't respond. =A0Then at of_phy_find_device() time, if it
>>
>> Maybe I din;t get the trick, but the problem is, that
>> you can;t register a phy_device in drivers/of/of_mdio.c
>> of_mdiobus_register(), if the phy didn;t respond with the
>> phy_id ... and of_phy_find_device() is not (yet) used in fs_enet
>>
>>> matches with a phy_device that isn't bound to a driver yet, then
>>> re-trigger the binding operation. =A0At which point the phy id can =
be
>>> probed and the correct driver can be chosen. =A0If binding succeeds=
,
>>> then return the phy_device handle. =A0If not, then fail as it curre=
ntly
>>> does.
>>
>> Wouldn;t it be good, just if we need a PHY (on calling fs_enet_open)
>> to look if there is one?
>>
>> Something like that (not tested):
>>
>> in drivers/net/fs_enet/fs_enet-main.c in fs_init_phy()
>> called from fs_enet_open():
>>
>> Do first:
>> phydev =3D =A0of_phy_find_device(fep->fpi->phy_node);
>>
>> Look if there is a driver (phy_dev->drv =3D=3D NULL ?)
>>
>> If not, call new function
>> of_mdiobus_register_phy(mii_bus, fep->fpi->phy_node)
>> see below patch for it.
>>
>> If this succeeds, all is OK, and we can use this phy,
>> else ethernet not work.
>>
>> !!just no idea, how to get mii_bus pointer ...
>>
>
> in my understanding it should be posssible to get this pointer via th=
e parent of
> the device_node you got via the private data of the fs_enet:
> fep->fpi->phy_node->parent should point you to the device_node for th=
e mdio_bus.

Yes, this will give you the mdio bus node pointer.

> In the next step you should be able to get the pointer of of_device f=
or the
> mdio_bus:
> ofdevice* ofdev =3D to_of_device(fep->fpi->phy_node->parent);

of_device is just an alias for platform_device now, and not all mdio
busses will be instantiated by a platform device.  This method won't
always work.  What is really needed is the pointer to the mii_bus
structure.  That can be obtained by looping over the members of the
mdio_bus_class and comparing the mii_bus->device.parent->of_node to
the parent node from above.

g.
