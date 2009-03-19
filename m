From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 8/9] net/pasemi_mac: Rework pasemi_mac driver to use
	of_mdio infrastructure
Date: Wed, 18 Mar 2009 23:07:25 -0600
Message-ID: <fa686aa40903182207j292bab31r9683d2323abf32f1@mail.gmail.com>
References: <20090319050015.11320.61641.stgit@localhost.localdomain>
	 <20090319050055.11320.62033.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@ru.mvista.com,
	davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:9449 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520AbZCSFH0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:07:26 -0400
Received: by yx-out-2324.google.com with SMTP id 31so394125yxl.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 22:07:25 -0700 (PDT)
In-Reply-To: <20090319050055.11320.62033.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC, please don't apply yet.

On Wed, Mar 18, 2009 at 11:00 PM, Grant Likely
<grant.likely@secretlab.ca> wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
>
> This patch simplifies the driver by making use of more common code.
>
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
>
> =A0drivers/net/pasemi_mac.c | =A0 19 +++----------------
> =A0drivers/net/pasemi_mac.h | =A0 =A01 -
> =A02 files changed, 3 insertions(+), 17 deletions(-)
>
>
> diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
> index d0349e7..8c92d1f 100644
> --- a/drivers/net/pasemi_mac.c
> +++ b/drivers/net/pasemi_mac.c
> @@ -1086,34 +1086,21 @@ static int pasemi_mac_phy_init(struct net_dev=
ice *dev)
> =A0 =A0 =A0 =A0struct pasemi_mac *mac =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0struct device_node *dn, *phy_dn;
> =A0 =A0 =A0 =A0struct phy_device *phydev;
> - =A0 =A0 =A0 unsigned int phy_id;
> =A0 =A0 =A0 =A0const phandle *ph;
> =A0 =A0 =A0 =A0const unsigned int *prop;
> =A0 =A0 =A0 =A0struct resource r;
> =A0 =A0 =A0 =A0int ret;
>
> =A0 =A0 =A0 =A0dn =3D pci_device_to_OF_node(mac->pdev);
> - =A0 =A0 =A0 ph =3D of_get_property(dn, "phy-handle", NULL);
> - =A0 =A0 =A0 if (!ph)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> - =A0 =A0 =A0 phy_dn =3D of_find_node_by_phandle(*ph);
> -
> - =A0 =A0 =A0 prop =3D of_get_property(phy_dn, "reg", NULL);
> - =A0 =A0 =A0 ret =3D of_address_to_resource(phy_dn->parent, 0, &r);
> - =A0 =A0 =A0 if (ret)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
> -
> - =A0 =A0 =A0 phy_id =3D *prop;
> - =A0 =A0 =A0 snprintf(mac->phy_id, sizeof(mac->phy_id), "%x:%02x",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(int)r.start, phy_id);
> -
> + =A0 =A0 =A0 phy_dn =3D of_parse_phandle(dn, "phy-handle", 0);
> =A0 =A0 =A0 =A0of_node_put(phy_dn);
>
> =A0 =A0 =A0 =A0mac->link =3D 0;
> =A0 =A0 =A0 =A0mac->speed =3D 0;
> =A0 =A0 =A0 =A0mac->duplex =3D -1;
>
> - =A0 =A0 =A0 phydev =3D phy_connect(dev, mac->phy_id, &pasemi_adjust=
_link, 0, PHY_INTERFACE_MODE_SGMII);
> + =A0 =A0 =A0 phydev =3D of_phy_connect(dev, phy_dn, &pasemi_adjust_l=
ink, 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PHY_INT=
ERFACE_MODE_SGMII);
>
> =A0 =A0 =A0 =A0if (IS_ERR(phydev)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR "%s: Could not attach =
to phy\n", dev->name);
> diff --git a/drivers/net/pasemi_mac.h b/drivers/net/pasemi_mac.h
> index 1a115ec..e2f4efa 100644
> --- a/drivers/net/pasemi_mac.h
> +++ b/drivers/net/pasemi_mac.h
> @@ -100,7 +100,6 @@ struct pasemi_mac {
> =A0 =A0 =A0 =A0int =A0 =A0 duplex;
>
> =A0 =A0 =A0 =A0unsigned int =A0 =A0msg_enable;
> - =A0 =A0 =A0 char =A0 =A0phy_id[BUS_ID_SIZE];
> =A0};
>
> =A0/* Software status descriptor (ring_info) */
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
