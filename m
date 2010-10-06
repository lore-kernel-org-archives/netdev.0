From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: powerpc, fs_enet: scanning PHY after Linux is up
Date: Wed, 6 Oct 2010 10:52:52 -0600
Message-ID: <AANLkTi=GkkD_-Vu-NswNedhgVuPaYePOHWa_2ytQgMf_@mail.gmail.com>
References: <4CA9830A.2030605@denx.de> <AANLkTinSersREjDnvg=8Gvpa6YmLuzgF1H8eEXRyCpW0@mail.gmail.com>
 <4CAC472F.5070001@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Holger Brunck <holger.brunck@keymile.com>,
	Detlev Zundel <dzu@denx.de>
To: hs@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:63240 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903Ab0JFQxO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 12:53:14 -0400
Received: by iwn5 with SMTP id 5so9958680iwn.19
        for <netdev@vger.kernel.org>; Wed, 06 Oct 2010 09:53:13 -0700 (PDT)
In-Reply-To: <4CAC472F.5070001@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 6, 2010 at 3:53 AM, Heiko Schocher <hs@denx.de> wrote:
> Hello Grant,
>
> Thanks for your answer!
>
> Grant Likely wrote:
>> On Mon, Oct 4, 2010 at 1:32 AM, Heiko Schocher <hs@denx.de> wrote:
>>> Hello all,
>>>
>>> we have on the mgcoge arch/powerpc/boot/dts/mgcoge.dts 3 fs_enet
>>> devices. The first is accessible on boot, and so get correct
>>> probed and works fine. For the other two fs_enet devices the PHYs
>>> are on startup in reset, and gets later, through userapplikations,
>>> out of reset ... so, on bootup, this 2 fs_enet devices could
>>> not detect the PHY in drivers/of/of_mdio.c of_mdiobus_register(),
>>> and if we want to use them later, we get for example:
>>>
>>> -bash-3.2# ifconfig eth2 172.31.31.33
>>> net eth2: Could not attach to PHY
>>> SIOCSIFFLAGS: No such device
>>>
>>> So the problem is, that we cannot rescan the PHYs, if they are
>>> accessible. Also we could not load the fs_enet driver as a module,
>>> because the first port is used fix.
>>>
>>> So, first question which comes in my mind, is:
>>>
>>> Is detecting the phy in drivers/of/of_mdio.c of_mdiobus_register()
>>> the right place, or should it not better be done, when really
>>> using the port?
>>>
>>> But we found another way to solve this issue:
>>>
>>> After the PHYs are out of reset, we just have to rescan the PHYs
>>> with (for example PHY with addr 1)
>>>
>>> err =3D mdiobus_scan(bus, 1);
>>>
>>> and
>>>
>>> of_find_node_by_path("/soc@f0000000/cpm@119c0/mdio@10d40/ethernet-p=
hy@1");
>>> of_node_get(np);
>>> dev_archdata_set_node(&err->dev.archdata, np);
>>>
>>> but thats just a hack ...
>>
>> Yeah, that's a hack. =A0It really needs to be done via the of_mdio
>> mechanisms so that dt <--> phy_device linkages remain consistent.
>
> Yep, I know, thats the reason why I ask ;-)
>
>>> So, the question is, is there a possibility to solve this problem?
>>>
>>> If there is no standard option, what would be with adding a
>>> "scan_phy" file in
>>>
>>> /proc/device-tree/soc\@f0000000/cpm\@119c0/mdio\@10d40
>>> (or better destination?)
>>>
>>> which with we could rescan a PHY with
>>> "echo addr > /proc/device-tree/soc\@f0000000/cpm\@119c0/mdio\@10d40=
/scan_phy"
>>> (so there is no need for using of_find_node_by_path(), as we should
>>> =A0have the associated device node here, and can step through the c=
hild
>>> =A0nodes with "for_each_child_of_node(np, child)" and check if reg =
=3D=3D addr)
>>>
>>> or shouldn;t be at least, if the phy couldn;t be found when opening
>>> the port, retrigger a scanning, if the phy now is accessible?
>>
>> One option would be to still register a phy_device for each phy
>> described in the device tree, but defer binding a driver to each phy
>> that doesn't respond. =A0Then at of_phy_find_device() time, if it
>
> Maybe I din;t get the trick, but the problem is, that
> you can;t register a phy_device in drivers/of/of_mdio.c
> of_mdiobus_register(), if the phy didn;t respond with the
> phy_id ... and of_phy_find_device() is not (yet) used in fs_enet

I'm suggesting modifying the phy layer so that it is possible to
register a phy_device that doesn't (yet) respond.

>> matches with a phy_device that isn't bound to a driver yet, then
>> re-trigger the binding operation. =A0At which point the phy id can b=
e
>> probed and the correct driver can be chosen. =A0If binding succeeds,
>> then return the phy_device handle. =A0If not, then fail as it curren=
tly
>> does.
>
> Wouldn;t it be good, just if we need a PHY (on calling fs_enet_open)
> to look if there is one?
>
> Something like that (not tested):
>
> in drivers/net/fs_enet/fs_enet-main.c in fs_init_phy()
> called from fs_enet_open():
>
> Do first:
> phydev =3D =A0of_phy_find_device(fep->fpi->phy_node);
>
> Look if there is a driver (phy_dev->drv =3D=3D NULL ?)
>
> If not, call new function
> of_mdiobus_register_phy(mii_bus, fep->fpi->phy_node)
> see below patch for it.
>
> If this succeeds, all is OK, and we can use this phy,
> else ethernet not work.

I don't like this approach because it muddies the concept of which
device is actually responsible for managing the phys on the bus.  Is
it managed by the mdio bus device or the Ethernet device?  It also has
a potential race condition.  Whereas triggering a late driver bind
will be safe.

Alternately, I'd also be okay with a common method to trigger a
reprobe of a particular phy from userspace, but I fear that would be a
significantly more complex solution.

>
> !!just no idea, how to get mii_bus pointer ...

You'd have to get the parent of the phy node, and then loop over all
the registered mdio busses looking for a bus that uses that node.

>
> here the patch for the new function of_mdiobus_register_phy():
>
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index b474833..7afbb0b 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -21,6 +21,51 @@
> =A0MODULE_AUTHOR("Grant Likely <grant.likely@secretlab.ca>");
> =A0MODULE_LICENSE("GPL");
>
> +int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node=
 *child)
> +{
> + =A0 =A0 =A0 struct phy_device *phy;
> + =A0 =A0 =A0 const __be32 *addr;
> + =A0 =A0 =A0 int len;
> + =A0 =A0 =A0 int rc;
> +
> + =A0 =A0 =A0 /* A PHY must have a reg property in the range [0-31] *=
/
> + =A0 =A0 =A0 addr =3D of_get_property(child, "reg", &len);
> + =A0 =A0 =A0 if (!addr || len < sizeof(*addr) || *addr >=3D 32 || *a=
ddr < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&mdio->dev, "%s has invalid PHY=
 address\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 child->full_name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (mdio->irq) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdio->irq[*addr] =3D irq_of_parse_and_m=
ap(child, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mdio->irq[*addr])
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdio->irq[*addr] =3D PH=
Y_POLL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 phy =3D get_phy_device(mdio, be32_to_cpup(addr));
> + =A0 =A0 =A0 if (!phy || IS_ERR(phy)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&mdio->dev, "error probing PHY =
at address %i\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *addr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -2;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 phy_scan_fixups(phy);
> + =A0 =A0 =A0 /* Associate the OF node with the device structure so i=
t
> + =A0 =A0 =A0 =A0* can be looked up later */
> + =A0 =A0 =A0 of_node_get(child);
> + =A0 =A0 =A0 dev_archdata_set_node(&phy->dev.archdata, child);
> +
> + =A0 =A0 =A0 /* All data is now stored in the phy struct; register i=
t */
> + =A0 =A0 =A0 rc =3D phy_device_register(phy);
> + =A0 =A0 =A0 if (rc) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_device_free(phy);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_node_put(child);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -3;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 dev_dbg(&mdio->dev, "registered phy %s at address %i\n"=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 child->name, *addr);
> +}
> +
> =A0/**
> =A0* of_mdiobus_register - Register mii_bus and create PHYs from the =
device tree
> =A0* @mdio: pointer to mii_bus structure
> @@ -31,7 +76,6 @@ MODULE_LICENSE("GPL");
> =A0*/
> =A0int of_mdiobus_register(struct mii_bus *mdio, struct device_node *=
np)
> =A0{
> - =A0 =A0 =A0 struct phy_device *phy;
> =A0 =A0 =A0 =A0struct device_node *child;
> =A0 =A0 =A0 =A0int rc, i;
>
> @@ -51,46 +95,7 @@ int of_mdiobus_register(struct mii_bus *mdio, stru=
ct device_node *np)
>
> =A0 =A0 =A0 =A0/* Loop over the child nodes and register a phy_device=
 for each one */
> =A0 =A0 =A0 =A0for_each_child_of_node(np, child) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 const __be32 *addr;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int len;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* A PHY must have a reg property in th=
e range [0-31] */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr =3D of_get_property(child, "reg", =
&len);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!addr || len < sizeof(*addr) || *ad=
dr >=3D 32 || *addr < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&mdio->dev, "%s=
 has invalid PHY address\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 child->=
full_name);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mdio->irq) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdio->irq[*addr] =3D ir=
q_of_parse_and_map(child, 0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mdio->irq[*addr])
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdio->i=
rq[*addr] =3D PHY_POLL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy =3D get_phy_device(mdio, be32_to_cp=
up(addr));
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!phy || IS_ERR(phy)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&mdio->dev, "er=
ror probing PHY at address %i\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *addr);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_scan_fixups(phy);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Associate the OF node with the devic=
e structure so it
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* can be looked up later */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_node_get(child);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_archdata_set_node(&phy->dev.archdat=
a, child);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* All data is now stored in the phy st=
ruct; register it */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D phy_device_register(phy);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rc) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_device_free(phy);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_node_put(child);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_dbg(&mdio->dev, "registered phy %s =
at address %i\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 child->name, *addr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 of_mdiobus_register_phy(mdio, child);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return 0;
>
> With this change, it would work on boot as actual (phy_device_registe=
r()
> will fail for the PHYs who don;t work when booting).
>
> Later, when opening the ethernet device, fs_init_phy, will look, if
> we have a valid phy with driver, if not we try to register it again.
> If this is successfull, we can use the device, if not we will fail,
> as now ... what do you think?

As mentioned above, it has the potential for some nasty confusion
about where exactly phy devices get registered, not to mention an
unlikely but potential race condition between the mdio bus and the
ethernet device trying to register the same phy since the MDIO bus
gets registered first, and then the bus loops over the phy nodes while
the bus is 'live'.

g.
