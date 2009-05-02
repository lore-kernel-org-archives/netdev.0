From: Sergey Vlasov <vsu-u2l5PoMzF/Uox3rIn2DAYQ@public.gmane.org>
Subject: Re: [PATCH 4/5] initdev:kernel: Await network init device
	discovery, v2
Date: Sat, 2 May 2009 17:36:03 +0400
Message-ID: <20090502133603.GB8116@atlas.home>
References: <20090502022858.GA15981@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="V0207lvV8h4k8FAm"
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090502022858.GA15981-CFZJ1or75eBPWxJt6d6B6bQa8qPdvLwY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--V0207lvV8h4k8FAm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 01, 2009 at 07:28:58PM -0700, David VomLehn wrote:
> Delay IP autoconfiguration until network boot devices have been initializ=
ed.
> This depends on the boot device discovery code and on the asynchronous
> function call infrastructure.
>=20
> History
> v2	Change bootdev_* to initdev_*
> v1	Initial release
>=20
> Signed-off-by: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
> ---
>  net/core/dev.c      |    2 +
>  net/ipv4/ipconfig.c |   56 +++++++++++++++++++++++++++++++++++++++++++++=
+++++-
>  2 files changed, 57 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 308a7d0..73cb282 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -93,6 +93,7 @@
>  #include <linux/ethtool.h>
>  #include <linux/notifier.h>
>  #include <linux/skbuff.h>
> +#include <linux/device.h>
>  #include <net/net_namespace.h>
>  #include <net/sock.h>
>  #include <linux/rtnetlink.h>
> @@ -4497,6 +4498,7 @@ int register_netdevice(struct net_device *dev)
>  		dev->reg_state =3D NETREG_UNREGISTERED;
>  	}
> =20
> +	initdev_registered(BOOTDEV_NETDEV);
>  out:
>  	return ret;
> =20
> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
> index 90d22ae..65a7ecd 100644
> --- a/net/ipv4/ipconfig.c
> +++ b/net/ipv4/ipconfig.c
> @@ -53,6 +53,7 @@
>  #include <linux/root_dev.h>
>  #include <linux/delay.h>
>  #include <linux/nfs_fs.h>
> +#include <linux/async.h>
>  #include <net/net_namespace.h>
>  #include <net/arp.h>
>  #include <net/ip.h>
> @@ -182,12 +183,48 @@ struct ic_device {
>  static struct ic_device *ic_first_dev __initdata =3D NULL;/* List of ope=
n device */
>  static struct net_device *ic_dev __initdata =3D NULL;	/* Selected device=
 */
> =20
> +/*
> + * Wait for required network devices to come up
> + * If the networking device name was specified on the kernel command line
> + * and that device is now registered, we have the device we want to conf=
igure
> + * and we return true. Otherwise, we return false. So, if no device was
> + * specified on the command line, we wait for all possible network devic=
es to
> + * be initialized.
> + */
> +static bool have_all_netdevs(void)
> +{
> +	struct net_device *dev;
> +	bool	result =3D false;
> +
> +	rtnl_lock();
> +
> +	for_each_netdev(&init_net, dev) {
> +		if (dev->flags & IFF_LOOPBACK)
> +			continue;
> +
> +		/* If a specific device name was specified and that name is
> +		 * registered, we have the device we need. */
> +		if (user_dev_name[0] && !strcmp(dev->name, user_dev_name)) {
> +			result =3D true;
> +			break;
> +		}
> +	}
> +
> +	rtnl_unlock();
> +
> +	return result;
> +
> +}
> +
>  static int __init ic_open_devs(void)
>  {
>  	struct ic_device *d, **last;
>  	struct net_device *dev;
>  	unsigned short oflags;
> =20
> +	/* Wait for networking devices */
> +	initdev_wait(BOOTDEV_NETDEV, have_all_netdevs);
> +
>  	last =3D &ic_first_dev;
>  	rtnl_lock();
> =20
> @@ -1263,6 +1300,7 @@ __be32 __init root_nfs_parse_addr(char *name)
> =20
>  /*
>   *	IP Autoconfig dispatcher.
> + *	Return zero on success, negative one on failure
>   */
> =20
>  static int __init ip_auto_config(void)
> @@ -1397,7 +1435,23 @@ static int __init ip_auto_config(void)
>  	return 0;
>  }
> =20
> -late_initcall(ip_auto_config);
> +static void __init ip_auto_config_async(void *data, async_cookie_t cooki=
e)
> +{
> +	ip_auto_config();
> +}
> +
> +static async_cookie_t ic_cookie;

This write-only variable is useless.

> +/*
> + * Start a thread to do IP autoconfiguration
> + */
> +static int __init ip_auto_configurator(void)
> +{
> +	ic_cookie =3D async_schedule(ip_auto_config_async, NULL);
> +
> +	return 0;
> +}
> +
> +late_initcall(ip_auto_configurator);
> =20
> =20
>  /*
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--V0207lvV8h4k8FAm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkn8TEMACgkQW82GfkQfsqLVhgCZAWUNR/PA4gpkCRHBTwwG72rB
ejUAn2PQXbya8SIcahwId4el8Pp75SV4
=FH1J
-----END PGP SIGNATURE-----

--V0207lvV8h4k8FAm--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
