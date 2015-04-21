From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC PATCH 3/3] driver/net/usb: Add support for DSA to ax88772b
Date: Tue, 21 Apr 2015 15:10:09 +0200
Message-ID: <87d22xocem.fsf@nemi.mork.no>
References: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz>
	<1429622791-7195-4-git-send-email-kaisrja1@fel.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sojkam1@fel.cvut.cz, tkonecny@retia.cz, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Kaisrlik <ja.kaisrlik@gmail.com>
To: Jan Kaisrlik <kaisrja1@fel.cvut.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34501 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751842AbbDUNKU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 09:10:20 -0400
In-Reply-To: <1429622791-7195-4-git-send-email-kaisrja1@fel.cvut.cz> (Jan
	Kaisrlik's message of "Tue, 21 Apr 2015 13:26:31 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Kaisrlik <kaisrja1@fel.cvut.cz> writes:

> From: Jan Kaisrlik <ja.kaisrlik@gmail.com>
>
> This patch adds a possibility to use the RMII interface of the ax8877=
2b
> instead of the Ethernet PHY which is used now.
>
> Binding DSA to a USB device is done via sysfs.
>
> ---
>  drivers/net/usb/asix.h         |   7 ++
>  drivers/net/usb/asix_devices.c | 258 +++++++++++++++++++++++++++++++=
+++++++++-
>  2 files changed, 261 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
> index 5d049d0..6b1a5f5 100644
> --- a/drivers/net/usb/asix.h
> +++ b/drivers/net/usb/asix.h
> @@ -174,6 +174,13 @@ struct asix_rx_fixup_info {
> =20
>  struct asix_common_private {
>  	struct asix_rx_fixup_info rx_fixup_info;
> +#ifdef CONFIG_NET_DSA
> +	struct kobject kobj;
> +	struct mii_bus *mdio;
> +	int use_embphy;
> +	bool dsa_up;
> +	struct usbnet *dev;
> +#endif
>  };
> =20
>  extern const struct driver_info ax88172a_info;
> diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_de=
vices.c
> index bf49792..57b3a34 100644
> --- a/drivers/net/usb/asix_devices.c
> +++ b/drivers/net/usb/asix_devices.c
> @@ -35,6 +35,88 @@
> =20
>  #define	PHY_MODE_RTL8211CL	0x000C
> =20
> +#ifdef CONFIG_NET_DSA
> +
> +#define AX88772_RMII 0x02
> +#define AX88772_MAX_PORTS 0x20
> +#define MV88e6065_ID  0x0c89
> +
> +#include <linux/phy.h>
> +#include <net/dsa.h>
> +
> +#define to_asix_obj(x) container_of(x, struct asix_common_private, k=
obj)
> +#define to_asix_attr(x) container_of(x, struct asix_attribute, attr)
> +
> +static int mii_asix_read(struct mii_bus *bus, int phy_id, int regnum=
)
> +{
> +	return asix_mdio_read(((struct usbnet *)bus->priv)->net, phy_id, re=
gnum);
> +}
> +
> +static int mii_asix_write(struct mii_bus *bus, int phy_id, int regnu=
m, u16 val)
> +{
> +	asix_mdio_write(((struct usbnet *)bus->priv)->net, phy_id, regnum, =
val);
> +	return 0;
> +}
> +
> +static int ax88772_init_mdio(struct usbnet *dev){
> +	struct asix_common_private *priv =3D dev->driver_priv;
> +	int ret, i;
> +
> +	priv->mdio =3D mdiobus_alloc();
> +	if (!priv->mdio) {
> +		netdev_err(dev->net, "Could not allocate mdio bus\n");
> +		return -ENOMEM;
> +	}
> +
> +	priv->mdio->priv =3D (void *)dev;
> +	priv->mdio->read =3D &mii_asix_read;
> +	priv->mdio->write =3D &mii_asix_write;
> +	priv->mdio->name =3D "ax88772 mdio bus";
> +	priv->mdio->parent =3D &dev->udev->dev;
> +
> +	/* mii bus name is usb-<usb bus number>-<usb device number> */
> +	snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "usb-%03d:%03d",dev->udev=
->bus->busnum, dev->udev->devnum);
> +
> +	priv->mdio->irq =3D kzalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL)=
;
> +	if (!priv->mdio->irq) {
> +		ret =3D -ENOMEM;
> +		goto free;
> +	}
> +
> +	for (i =3D 0; i < PHY_MAX_ADDR; i++)
> +		priv->mdio->irq[i] =3D PHY_POLL;
> +
> +	ret =3D mdiobus_register(priv->mdio);
> +	if (ret) {
> +		netdev_err(dev->net, "Could not register MDIO bus\n");
> +		goto free_irq;
> +	}
> +
> +	netdev_info(dev->net, "registered mdio bus %s\n", priv->mdio->id);
> +	return 0;
> +
> +free_irq:
> +	kfree(priv->mdio->irq);
> +free:
> +	mdiobus_free(priv->mdio);
> +	return ret;
> +}

There is already identical code in drivers/net/usb/ax88172a.c.  Any
chance these ASIX devices can share some code, or does it all have to b=
e
duplicated for each new chip?


> +//	dsa_free(); TODO

Probably not like that...


> +static ssize_t usb_dsa_store(struct asix_common_private *priv,
> +		struct asix_attribute *attr, const char *buf, size_t count)
> +{
> +	ax88772_set_bind_dsa(priv);
> +	return count;
> +}
> +
> +static ssize_t usb_dsa_show(struct asix_common_private *priv,
> +		struct asix_attribute *attr, char *buf)
> +{
> +	return scnprintf(buf, PAGE_SIZE, "usb_dsa_binding.\n");
> +}

I'm not sure I understand this at all.  What kind of userspace API are
you trying to provide here? Maybe you could document these attributes
Documentation/ABI/testing/ to make it more clear?

> +static void driver_release(struct kobject *kobj)
> +{
> +	pr_debug("driver: '%s': %s\n", kobject_name(kobj), __func__);
> +//   kfree(drv_priv); TODO free
> +}

Ah, I guess you might have missed this section of
Documentation/kobject.txt ?:

  One important point cannot be overstated: every kobject must have a
  release() method, and the kobject must persist (in a consistent state=
)
  until that method is called. If these constraints are not met, the
  code is flawed.  Note that the kernel will warn you if you forget to
  provide a release() method.  Do not try to get rid of this warning by
  providing an "empty" release function; you will be mocked mercilessly
  by the kobject maintainer if you attempt this.

Better CC Greg KH on your next attempt to make sure you get the mocking
you deserve :-)


> +static ssize_t usb_dsa_attr_show(struct kobject *kobj,
> +	struct attribute *attr,
> +	char *buf)
> +{
> +	struct asix_attribute *attribute;
> +	struct asix_common_private *priv;
> +
> +	attribute =3D to_asix_attr(attr);
> +	priv =3D to_asix_obj(kobj);
> +
> +	if (!attribute->show)
> +		return -EINVAL;
> +
> +	return attribute->show(priv, attribute, buf);
> +}
> +static ssize_t usb_dsa_attr_store(struct kobject *kobj,
> +		struct attribute *attr,
> +		const char *buf, size_t len)
> +{
> +	struct asix_attribute *attribute;
> +	struct asix_common_private *priv;
> +
> +	attribute =3D to_asix_attr(attr);
> +	priv =3D to_asix_obj(kobj);
> +
> +	if (!attribute->store)
> +		return -EINVAL;
> +	return attribute->store(priv, attribute, buf, len);
> +}
> +
> +static struct asix_attribute asix_attribute =3D  __ATTR(usb_dsa_bind=
, 0664, usb_dsa_show, usb_dsa_store);
> +static struct attribute *asix_default_attrs[] =3D {
> +	&asix_attribute.attr,
> +	NULL,
> +};
> +static const struct sysfs_ops dsa_bind_sysfs_ops =3D {
> +	.show   =3D usb_dsa_attr_show,
> +	.store  =3D usb_dsa_attr_store,
> +};
> +static struct kobj_type dsa_bind_ktype =3D {
> +	.sysfs_ops      =3D &dsa_bind_sysfs_ops,
> +	.release        =3D driver_release,
> +	.default_attrs  =3D asix_default_attrs,
> +};
> +#endif
> +
>  static int ax88772_bind(struct usbnet *dev, struct usb_interface *in=
tf)
>  {
>  	int ret, embd_phy, i;
>  	u8 buf[ETH_ALEN];
>  	u32 phyid;
> +#ifdef CONFIG_NET_DSA
> +	struct asix_common_private *priv;
> +#endif
> =20
>  	usbnet_get_endpoints(dev,intf);
> =20
> @@ -465,6 +688,25 @@ static int ax88772_bind(struct usbnet *dev, stru=
ct usb_interface *intf)
>  		return ret;
>  	}
> =20
> +	dev->driver_priv =3D kzalloc(sizeof(struct asix_common_private), GF=
P_KERNEL);

Unconditional allocation.

> +	if (!dev->driver_priv)
> +		return -ENOMEM;
> +
> +#ifdef CONFIG_NET_DSA
> +	priv =3D dev->driver_priv;
> +	priv->dev =3D dev;
> +	priv->dsa_up =3D 0;
> +	priv->kobj.kset =3D kset_create_and_add("DSA_BIND", NULL, kobject_g=
et(&dev->udev->dev.kobj));
> +	if (!priv->kobj.kset){
> +		ret =3D -ENOMEM;
> +		goto free;
> +	}
> +
> +	ret =3D kobject_init_and_add(&priv->kobj, &dsa_bind_ktype, NULL, "d=
sa_bind");
> +	if (ret)
> +		goto free_kobj;
> +#endif

I see that you reference the usb device here, but I don't see why.  Thi=
s
is related to et network device, isn't it?  What's wrong about simply
using dev->net->sysfs_groups[0] instead?


> +#ifdef CONFIG_NET_DSA
> +free_kobj:
> +	kobject_put(&priv->kobj);
> +free:
> +	kfree(priv);
> +	return ret;
> +#endif

Conditional kfree.  Obfuscated by the fact that you have a conditionall=
y
defined *priv pointing to dev->driver_priv, but it doesn't change the
fact that you leak on errors.




Bj=C3=B8rn
