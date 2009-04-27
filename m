From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v3 09/13] net: Rework ucc_geth driver to use of_mdio
	infrastructure
Date: Mon, 27 Apr 2009 09:36:07 -0600
Message-ID: <fa686aa40904270836v352b7d24sb5798ca95d71ccd@mail.gmail.com>
References: <20090425224458.32392.31296.stgit@localhost.localdomain>
	<20090425225323.32392.1254.stgit@localhost.localdomain> <OFD90DF3E8.3B40B9BF-ONC12575A4.0030C830-C12575A4.00317AE2@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Fleming <afleming@freescale.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	linuxppc-dev-bounces+joakim.tjernlund=transmode.se@ozlabs.org,
	netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f166.google.com ([209.85.217.166]:39341 "EHLO
	mail-gx0-f166.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525AbZD0PgY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 11:36:24 -0400
Received: by gxk10 with SMTP id 10so4872413gxk.13
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 08:36:24 -0700 (PDT)
In-Reply-To: <OFD90DF3E8.3B40B9BF-ONC12575A4.0030C830-C12575A4.00317AE2@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 26, 2009 at 3:00 AM, Joakim Tjernlund
<Joakim.Tjernlund@transmode.se> wrote:
> Change in fixed link case, see inline.
>
>>
>> From: Grant Likely <grant.likely@secretlab.ca>
>>
>> This patch simplifies the driver by making use of more common code.
>>
>> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
>> Acked-by: Andy Fleming <afleming@freescale.com>
>> ---
>>
>> =A0drivers/net/ucc_geth.c | =A0 47
> ++++++++++++-----------------------------------
>> =A0drivers/net/ucc_geth.h | =A0 =A02 +-
>> =A02 files changed, 13 insertions(+), 36 deletions(-)
>>
>>
>> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
>> index d3f39e8..195b490 100644
>> --- a/drivers/net/ucc_geth.c
>> +++ b/drivers/net/ucc_geth.c
>> @@ -27,6 +27,7 @@
>> =A0#include <linux/mii.h>
>> =A0#include <linux/phy.h>
>> =A0#include <linux/workqueue.h>
>> +#include <linux/of_mdio.h>
>> =A0#include <linux/of_platform.h>
>>
>> =A0#include <asm/uaccess.h>
>> @@ -1542,12 +1543,14 @@ static int init_phy(struct net_device *dev)
>> =A0 =A0 priv->oldspeed =3D 0;
>> =A0 =A0 priv->oldduplex =3D -1;
>>
>> - =A0 phydev =3D phy_connect(dev, ug_info->phy_bus_id, &adjust_link,=
 0,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->phy_interface);
>> + =A0 if (!ug_info->phy_node)
>> + =A0 =A0 =A0return 0;
>>
>> - =A0 if (IS_ERR(phydev)) {
>> + =A0 phydev =3D of_phy_connect(dev, ug_info->phy_node, &adjust_link=
, 0,
>> + =A0 =A0 =A0 =A0 =A0 =A0priv->phy_interface);
>> + =A0 if (!phydev) {
>> =A0 =A0 =A0 =A0printk("%s: Could not attach to PHY\n", dev->name);
>> - =A0 =A0 =A0return PTR_ERR(phydev);
>> + =A0 =A0 =A0return -ENODEV;
>> =A0 =A0 }
>>
>> =A0 =A0 phydev->supported &=3D (ADVERTISED_10baseT_Half |
>> @@ -3519,14 +3522,12 @@ static int ucc_geth_probe(struct of_device*
> ofdev, const struct of_device_id *ma
>> =A0{
>> =A0 =A0 struct device *device =3D &ofdev->dev;
>> =A0 =A0 struct device_node *np =3D ofdev->node;
>> - =A0 struct device_node *mdio;
>> =A0 =A0 struct net_device *dev =3D NULL;
>> =A0 =A0 struct ucc_geth_private *ugeth =3D NULL;
>> =A0 =A0 struct ucc_geth_info *ug_info;
>> =A0 =A0 struct resource res;
>> =A0 =A0 struct device_node *phy;
>> =A0 =A0 int err, ucc_num, max_speed =3D 0;
>> - =A0 const phandle *ph;
>> =A0 =A0 const u32 *fixed_link;
>> =A0 =A0 const unsigned int *prop;
>> =A0 =A0 const char *sprop;
>> @@ -3626,45 +3627,21 @@ static int ucc_geth_probe(struct of_device*
> ofdev, const struct of_device_id *ma
>> =A0 =A0 ug_info->uf_info.irq =3D irq_of_parse_and_map(np, 0);
>> =A0 =A0 fixed_link =3D of_get_property(np, "fixed-link", NULL);
>> =A0 =A0 if (fixed_link) {
>> - =A0 =A0 =A0snprintf(ug_info->phy_bus_id, sizeof(ug_info->phy_bus_i=
d),
>> - =A0 =A0 =A0 =A0 =A0PHY_ID_FMT, "0", fixed_link[0]);
>> =A0 =A0 =A0 =A0phy =3D NULL;
>
> phy assigned to NULL ...
>
>> =A0 =A0 } else {
>> - =A0 =A0 =A0char bus_name[MII_BUS_ID_SIZE];
>> -
>> - =A0 =A0 =A0ph =3D of_get_property(np, "phy-handle", NULL);
>> - =A0 =A0 =A0phy =3D of_find_node_by_phandle(*ph);
>> -
>> + =A0 =A0 =A0phy =3D of_parse_phandle(np, "phy-handle", 0);
>> =A0 =A0 =A0 =A0if (phy =3D=3D NULL)
>> =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> -
>> - =A0 =A0 =A0/* set the PHY address */
>> - =A0 =A0 =A0prop =3D of_get_property(phy, "reg", NULL);
>> - =A0 =A0 =A0if (prop =3D=3D NULL)
>> - =A0 =A0 =A0 =A0 return -1;
>> -
>> - =A0 =A0 =A0/* Set the bus id */
>> - =A0 =A0 =A0mdio =3D of_get_parent(phy);
>> -
>> - =A0 =A0 =A0if (mdio =3D=3D NULL)
>> - =A0 =A0 =A0 =A0 return -ENODEV;
>> -
>> - =A0 =A0 =A0err =3D of_address_to_resource(mdio, 0, &res);
>> -
>> - =A0 =A0 =A0if (err) {
>> - =A0 =A0 =A0 =A0 of_node_put(mdio);
>> - =A0 =A0 =A0 =A0 return err;
>> - =A0 =A0 =A0}
>> - =A0 =A0 =A0fsl_pq_mdio_bus_name(bus_name, mdio);
>> - =A0 =A0 =A0of_node_put(mdio);
>> - =A0 =A0 =A0snprintf(ug_info->phy_bus_id, sizeof(ug_info->phy_bus_i=
d),
>> - =A0 =A0 =A0 =A0 "%s:%02x", bus_name, *prop);
>> =A0 =A0 }
>> + =A0 ug_info->phy_node =3D phy;
>>
>> =A0 =A0 /* get the phy interface type, or default to MII */
>> =A0 =A0 prop =3D of_get_property(np, "phy-connection-type", NULL);
>> =A0 =A0 if (!prop) {
>> =A0 =A0 =A0 =A0/* handle interface property present in old trees */
>> + =A0 =A0 =A0if (!phy)
>> + =A0 =A0 =A0 =A0 return -ENODEV;
>
> .. here an error is returned. Is this intentional?

Yes, I did that intentionally because it looked like a bug to me
because of_get_property() is passed the phy value.  However, I suppose
that if phy is null then of_get_property will just return NULL, so I
think I made a mistake.  I'll post a patch to remove these two lines.

g.

>
>> +
>> =A0 =A0 =A0 =A0prop =3D of_get_property(phy, "interface", NULL);
>> =A0 =A0 =A0 =A0if (prop !=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 phy_interface =3D enet_to_phy_interface[*prop];
>> diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
>> index 2f8ee7c..bc31975 100644
>> --- a/drivers/net/ucc_geth.h
>> +++ b/drivers/net/ucc_geth.h
>> @@ -1100,7 +1100,7 @@ struct ucc_geth_info {
>> =A0 =A0 u32 eventRegMask;
>> =A0 =A0 u16 pausePeriod;
>> =A0 =A0 u16 extensionField;
>> - =A0 char phy_bus_id[BUS_ID_SIZE];
>> + =A0 struct device_node *phy_node;
>> =A0 =A0 u8 weightfactor[NUM_TX_QUEUES];
>> =A0 =A0 u8 interruptcoalescingmaxvalue[NUM_RX_QUEUES];
>> =A0 =A0 u8 l2qt[UCC_GETH_VLAN_PRIORITY_MAX];
>>
>> _______________________________________________
>> Linuxppc-dev mailing list
>> Linuxppc-dev@ozlabs.org
>> https://ozlabs.org/mailman/listinfo/linuxppc-dev
>>
>>
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
