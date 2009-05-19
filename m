From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 1/1] e1000e: Expose MDI-X state via sysfs
Date: Tue, 19 May 2009 14:55:54 -0700
Message-ID: <9929d2390905191455i3103ead3p13c0b4c51be29b5@mail.gmail.com>
References: <20090519210553.GA2491@clala-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chaitanya Lala <clala@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:14316 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbZESVzy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 17:55:54 -0400
Received: by an-out-0708.google.com with SMTP id d40so180221and.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 14:55:55 -0700 (PDT)
In-Reply-To: <20090519210553.GA2491@clala-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 2:05 PM, Chaitanya Lala <clala@riverbed.com> wr=
ote:
> While debugging network connectivity problems, it is often helpful
> to report the MDI-X state. The is_mdix variable holds the current
> state which we expose on a per-interface basis as a sysfs attribute.
> We use sysfs over methods such as netlink due to the convenience of
> reading a file (using the cat command) as opposed to connecting to a
> netlink socket. If we use a fiber PHY then is_mdix will always be zer=
o
> as the mdi-x feature only applies to copper PHYs.
>
> Signed-off-by: Chaitanya Lala <clala@riverbed.com>
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
> ---

NAK.  We do not want to be adding sysfs entries for every little piece
of information in the driver.  Instead, I would suggest looking at
enhancing existing tools like ethtool to get that sort of information
in a more generic way which is not driver specific.

> =C2=A0drivers/net/e1000e/netdev.c | =C2=A0 35 +++++++++++++++++++++++=
++++++++++++
> =C2=A01 files changed, 35 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.=
c
> index ccaaee0..1c131b6 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -4765,6 +4765,32 @@ static const struct net_device_ops e1000e_netd=
ev_ops =3D {
> =C2=A0#endif
> =C2=A0};
>
> +static ssize_t e1000e_show_is_mdix(struct device *dev,
> + =C2=A0 =C2=A0struct device_attribute *attr, char *buf)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct net_device *netdev =3D container_of(dev=
, struct net_device, dev);
> + =C2=A0 =C2=A0 =C2=A0 struct e1000_adapter *adapter;
> + =C2=A0 =C2=A0 =C2=A0 struct e1000_hw *hw;
> + =C2=A0 =C2=A0 =C2=A0 ssize_t ret =3D -EINVAL;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (!buf)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err;
> +
> + =C2=A0 =C2=A0 =C2=A0 read_lock(&dev_base_lock);
> + =C2=A0 =C2=A0 =C2=A0 if (NETREG_REGISTERED =3D=3D netdev->reg_state=
) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 adapter =3D netdev=
_priv(netdev);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hw =3D &adapter->h=
w;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D sprintf(bu=
f, "%d\n", (hw->phy.is_mdix ? 1 : 0));
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 read_unlock(&dev_base_lock);
> +err:
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +/* Export attributes for the device */
> +static struct device_attribute device_attr_is_mdix =3D
> + =C2=A0 =C2=A0__ATTR(is_mdix, S_IRUGO, e1000e_show_is_mdix, NULL);
> +
> =C2=A0/**
> =C2=A0* e1000_probe - Device Initialization Routine
> =C2=A0* @pdev: PCI device information struct
> @@ -5046,6 +5072,10 @@ static int __devinit e1000_probe(struct pci_de=
v *pdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto err_regis=
ter;
>
> + =C2=A0 =C2=A0 =C2=A0 err =3D device_create_file(&netdev->dev, &devi=
ce_attr_is_mdix);
> + =C2=A0 =C2=A0 =C2=A0 if (err)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_sys_attr;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* carrier off reporting is important to e=
thtool even BEFORE open */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netif_carrier_off(netdev);
>
> @@ -5053,6 +5083,9 @@ static int __devinit e1000_probe(struct pci_dev=
 *pdev,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> +err_sys_attr:
> + =C2=A0 =C2=A0 =C2=A0 unregister_netdev(netdev);
> +
> =C2=A0err_register:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(adapter->flags & FLAG_HAS_AMT))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0e1000_release_=
hw_control(adapter);
> @@ -5105,6 +5138,8 @@ static void __devexit e1000_remove(struct pci_d=
ev *pdev)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0flush_scheduled_work();
>
> + =C2=A0 =C2=A0 =C2=A0 device_remove_file(&netdev->dev, &device_attr_=
is_mdix);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Release control of h/w to f/w. =C2=A0If=
 f/w is AMT enabled, this
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * would have already happened in close an=
d is redundant.
> --
> 1.6.0.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>



--=20
Cheers,
Jeff
