From: Nigel Cunningham <ncunningham@linuxmail.org>
Subject: Re: 2.4.29, e100 and a WOL packet causes keventd going mad
Date: Mon, 31 Jan 2005 14:58:25 +1100
Message-ID: <1107143905.21273.33.camel@desktop.cunninghams>
References: <20050130171849.GA3354@hardeman.nu>
	 <1107143255.18167.428.camel@localhost.localdomain>
Reply-To: ncunningham@linuxmail.org
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: David =?ISO-8859-1?Q?H=E4rdeman?= <david@2gen.com>,
        Michael Gernoth <simigern@stud.uni-erlangen.de>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sfeldma@pobox.com
In-Reply-To: <1107143255.18167.428.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

Do you also disable the WOL event when resuming?

Regards,

Nigel

On Mon, 2005-01-31 at 14:47, Scott Feldman wrote:
> On Sun, 2005-01-30 at 09:18, David H=E4rdeman wrote:
> > I experience the same problems as reported by Michael Gernoth when=20
> > sending a WOL-packet to computer with a e100 NIC which is already=20
> > powered on.
>=20
> I didn't look at the 2.4 case, but for 2.6, it seems e100 was enabling
> PME wakeup during probe.  PME shouldn't be enabled while the system is
> up.  I suspect the assertion of PME while the system is up is what's
> causing problems.  This patch moves PME wakeup enabling to either
> suspend or shutdown.
>=20
> David, would you give this patch a try?  Make sure the system still
> wakes from a magic packet if suspended or shut down, and doesn't cause
> kacpid to go crazy if system is running.  If it helps for 2.6, perhaps
> someone can look into 2.4 to see if there is something similar going on
> there.
>=20
> -scott
>=20
> --- linux-2.6.11-rc2/drivers/net/e100.c.orig	2005-01-30 19:13:56.850497=
376 -0800
> +++ linux-2.6.11-rc2/drivers/net/e100.c	2005-01-30 19:26:41.154305536 -=
0800
> @@ -1868,7 +1868,6 @@ static int e100_set_wol(struct net_devic
>  	else
>  		nic->flags &=3D ~wol_magic;
> =20
> -	pci_enable_wake(nic->pdev, 0, nic->flags & (wol_magic | e100_asf(nic)=
));
>  	e100_exec_cb(nic, NULL, e100_configure);
> =20
>  	return 0;
> @@ -2262,8 +2261,6 @@ static int __devinit e100_probe(struct p
>  	   (nic->eeprom[eeprom_id] & eeprom_id_wol))
>  		nic->flags |=3D wol_magic;
> =20
> -	pci_enable_wake(pdev, 0, nic->flags & (wol_magic | e100_asf(nic)));
> -
>  	strcpy(netdev->name, "eth%d");
>  	if((err =3D register_netdev(netdev))) {
>  		DPRINTK(PROBE, ERR, "Cannot register net device, aborting.\n");
> @@ -2344,6 +2341,15 @@ static int e100_resume(struct pci_dev *p
>  }
>  #endif
> =20
> +static void e100_shutdown(struct device *dev)
> +{
> +	struct pci_dev *pdev =3D container_of(dev, struct pci_dev, dev);
> +	struct net_device *netdev =3D pci_get_drvdata(pdev);
> +	struct nic *nic =3D netdev_priv(netdev);
> +
> +	pci_enable_wake(pdev, 0, nic->flags & (wol_magic | e100_asf(nic)));
> +}
> +
>  static struct pci_driver e100_driver =3D {
>  	.name =3D         DRV_NAME,
>  	.id_table =3D     e100_id_table,
> @@ -2353,6 +2359,9 @@ static struct pci_driver e100_driver =3D {
>  	.suspend =3D      e100_suspend,
>  	.resume =3D       e100_resume,
>  #endif
> +	.driver =3D {
> +		.shutdown =3D e100_shutdown,
> +	}
>  };
> =20
>  static int __init e100_init_module(void)
>=20
>=20
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
--=20
Nigel Cunningham
Software Engineer, Canberra, Australia
http://www.cyclades.com

Ph: +61 (2) 6292 8028      Mob: +61 (417) 100 574
