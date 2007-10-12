From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 2/2] NFS: handle IPv6 addresses in nfs ctl
Date: Fri, 12 Oct 2007 12:07:53 -0400
Message-ID: <470F9BD9.5090903@hp.com>
References: <470F3AF9.4050705@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:48855 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932345AbXJLQIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 12:08:30 -0400
In-Reply-To: <470F3AF9.4050705@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Aurelien,

Comments in-line.

Aur=E9lien Charbon wrote:
> Here is a second missing part of the IPv6 support in NFS server code=20
> concerning knfd syscall interface.

> -    struct sockaddr_in *sin;
> +    struct sockaddr_in6 *sin, sin6_storage;

Nit, should call this sin6 now.

> @@ -228,9 +228,20 @@ static ssize_t write_getfs(struct file *
>         return -EINVAL;
>     data =3D (struct nfsctl_fsparm*)buf;
>     err =3D -EPROTONOSUPPORT;
> -    if (data->gd_addr.sa_family !=3D AF_INET)
> +    sin =3D &sin6_storage;

This should be moved in the AF_INET case.

> +    switch (data->gd_addr.sa_family) {
> +    case AF_INET6:
> +        sin =3D (struct sockaddr_in6 *)&data->gd_addr;
> +        in6 =3D sin->sin6_addr;

in6 is a structure, not a pointer.  If you want it do this you have to=20
use ipv6_addr_copy().

> +    case AF_INET:
> +        /* Map v4 address into v6 structure */
> +        ipv6_addr_v4map(((struct sockaddr_in=20
> *)&data->gd_addr)->sin_addr, in6);

ipv6_addr_set(...)

> @@ -257,7 +265,7 @@ static ssize_t write_getfs(struct file *
> static ssize_t write_getfd(struct file *file, char *buf, size_t size)
> {
>     struct nfsctl_fdparm *data;
> -    struct sockaddr_in *sin;
> +    struct sockaddr_in6 *sin, sin6_storage;

Nit, sin -> sin6.

> @@ -268,18 +276,29 @@ static ssize_t write_getfd(struct file *
>         return -EINVAL;
>     data =3D (struct nfsctl_fdparm*)buf;
>     err =3D -EPROTONOSUPPORT;
> -    if (data->gd_addr.sa_family !=3D AF_INET)
> +    if (data->gd_addr.sa_family !=3D AF_INET &&
> +        data->gd_addr.sa_family !=3D AF_INET6)
>         goto out;
>     err =3D -EINVAL;
>     if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
>         goto out;
>=20
>     res =3D buf;
> -    sin =3D (struct sockaddr_in *)&data->gd_addr;
> +    sin =3D &sin6_storage;

Move in AF_INET case.

> -    /* IPv6 address mapping */
> -    ipv6_addr_v4map(sin->sin_addr, in6);
> +    switch (data->gd_addr.sa_family) {
> +    case AF_INET:
> +        /* IPv6 address mapping */
> +        ipv6_addr_v4map(((struct sockaddr_in=20
> *)&data->gd_addr)->sin_addr, in6);

Use ipv6_set_addr(...)

> +        break;
> +    case AF_INET6:
> +        sin =3D (struct sockaddr_in6 *)&data->gd_addr;
> +        in6 =3D sin->sin6_addr;

Must use ipv6_addr_copy() here too.

-Brian
