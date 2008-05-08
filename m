From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: Add missing locking to cfg80211_dev_rename
Date: Fri, 09 May 2008 00:18:20 +0200
Message-ID: <1210285100.3547.79.camel@johannes.berg>
References: <20080506173030.653828076@theryb.frec.bull.fr>
	 <20080506173335.922289888@theryb.frec.bull.fr>
	 <m13aoueyq8.fsf@frodo.ebiederm.org> <20080507190838.GA4467@suse.de>
	 <m1ej8ccwlx.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ud1hiflYVFADckWe6QeR"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org,
	Greg KH <gregkh@suse.de>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:41612 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762183AbYEHWTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 18:19:51 -0400
In-Reply-To: <m1ej8ccwlx.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ud1hiflYVFADckWe6QeR
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-05-08 at 14:30 -0700, Eric W. Biederman wrote:
> device_rename only performs useful and race free validity
> checking at the optional sysfs level so depending on it
> for all of the validity checking in cfg80211_dev_rename
> is racy.
>=20
> Instead implement all of the needed validity checking
> and locking in cfg80211_dev_rename.

Makes sense, thanks, I didn't really think about it not being compiled
in.

> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Johannes Berg <johannes@sipsolutions.net>

> ---
>  net/wireless/core.c |   33 ++++++++++++++++++++++++++++-----
>  1 files changed, 28 insertions(+), 5 deletions(-)
>=20
> diff --git a/net/wireless/core.c b/net/wireless/core.c
> index 80afacd..f1da0b9 100644
> --- a/net/wireless/core.c
> +++ b/net/wireless/core.c
> @@ -143,8 +143,11 @@ void cfg80211_put_dev(struct cfg80211_registered_dev=
ice *drv)
>  int cfg80211_dev_rename(struct cfg80211_registered_device *rdev,
>  			char *newname)
>  {
> +	struct cfg80211_registered_device *drv;
>  	int idx, taken =3D -1, result, digits;
> =20
> +	mutex_lock(&cfg80211_drv_mutex);
> +
>  	/* prohibit calling the thing phy%d when %d is not its number */
>  	sscanf(newname, PHY_NAME "%d%n", &idx, &taken);
>  	if (taken =3D=3D strlen(newname) && idx !=3D rdev->idx) {
> @@ -156,14 +159,30 @@ int cfg80211_dev_rename(struct cfg80211_registered_=
device *rdev,
>  		 * deny the name if it is phy<idx> where <idx> is printed
>  		 * without leading zeroes. taken =3D=3D strlen(newname) here
>  		 */
> +		result =3D -EINVAL;
>  		if (taken =3D=3D strlen(PHY_NAME) + digits)
> -			return -EINVAL;
> +			goto out_unlock;
> +	}
> +
> +
> +	/* Ignore nop renames */
> +	result =3D 0;
> +	if (strcmp(newname, dev_name(&rdev->wiphy.dev)) =3D=3D 0)
> +		goto out_unlock;
> +
> +	/* Ensure another device does not already have this name. */
> +	list_for_each_entry(drv, &cfg80211_drv_list, list) {
> +		result =3D -EINVAL;
> +		if (strcmp(newname, dev_name(&drv->wiphy.dev)) =3D=3D 0)
> +			goto out_unlock;
>  	}
> =20
> -	/* this will check for collisions */
> +	/* this will only check for collisions in sysfs
> +	 * which is not even always compiled in.
> +	 */
>  	result =3D device_rename(&rdev->wiphy.dev, newname);
>  	if (result)
> -		return result;
> +		goto out_unlock;
> =20
>  	if (!debugfs_rename(rdev->wiphy.debugfsdir->d_parent,
>  			    rdev->wiphy.debugfsdir,
> @@ -172,9 +191,13 @@ int cfg80211_dev_rename(struct cfg80211_registered_d=
evice *rdev,
>  		printk(KERN_ERR "cfg80211: failed to rename debugfs dir to %s!\n",
>  		       newname);
> =20
> -	nl80211_notify_dev_rename(rdev);
> +	result =3D 0;
> +out_unlock:
> +	mutex_unlock(&cfg80211_drv_mutex);
> +	if (result =3D=3D 0)
> +		nl80211_notify_dev_rename(rdev);
> =20
> -	return 0;
> +	return result;
>  }
> =20
>  /* exported functions */

--=-ud1hiflYVFADckWe6QeR
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASCN8K6Vg1VMiehFYAQKfMQ/9EuN7ARC72ab/rxNd4+jGO3XN3UlYPZ+t
ytHyqNrM1RUjN+2XO+Nxb/6y4astz8POlKKAVl1G+ZPuQAK40YoYNYeQ5jZjGZ3p
8ACKYeN8Fx+wfoCXfZpSrj7c0lFZ8p+YGPtWoBX7y+PDCVgVHPAwC0M65itdzZNi
8oG2eNacQBK3hnNgz2syZ7hg1AjyFOYql3HjcldLBF4DzjVbN0egPQNlUut2iGji
gupM8zNMZLVaFzGsDxGLU8I3V5V5PYQy9179FeWFMpW6OzzfP+3CN12blEpsIamP
iS48xjn05LBBZoFCHCweNg9x+dsnbeKPLgawTP/tH59RCP96TX3d+LWUacpZTg+b
oa8hPFG+L+gnezouLmiVpUTkAqEpwxQ6opDzUPMaHDglrFWszyui4uVEVrdwCAPu
Dj/jqiIXP4ESyeXrFPmvR9qgOoyvKmyovtIXxXtMSO7KqZKLUcXtiVdvEunqZXfC
tR6iz9+WKgZ9tOhg44+ug2uYt37rl+yu7yVtqUWBA1hg3EUUT0afLjnpqXpjqCSJ
QRZg2jMLSBpSOf3Cx7xgxjfWWLXYPmViT8DSWY0OeFd1O+FIPG/35JzEQ1xaGLy0
oOA/LjoarFq//VRe35GU1OUduRjIJmQhzUX0Zm6s7TQJY+qEH0aHsl5h4ctkE4sa
dwh4rt8hWGw=
=o7fD
-----END PGP SIGNATURE-----

--=-ud1hiflYVFADckWe6QeR--

