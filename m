From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [patch 1/2] proc_fops: convert drivers/isdn/ to seq_file
Date: Sun, 10 Jan 2010 19:42:49 +0100
Message-ID: <4B4A1FA9.7030505@imap.cc>
References: <200912220025.nBM0PVBC005140@imap1.linux-foundation.org> <4B320D61.4070403@imap.cc> <20100105211934.GA21210@x200>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig01C4794F812567C349101A67"
Cc: akpm@linux-foundation.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:36956 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750876Ab0AJStG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 13:49:06 -0500
In-Reply-To: <20100105211934.GA21210@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig01C4794F812567C349101A67
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 05.01.2010 22:19 schrieb Alexey Dobriyan:
> Here is hopefully last version and sorry for delay.

Looks good. Thanks.

> [PATCH] proc_fops: convert drivers/isdn/ to seq_file
>=20
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Acked-by: Tilman Schmidt <tilman@imap.cc>

for the Documentation and drivers/isdn/gigaset parts.

> ---
>=20
>  Documentation/isdn/INTERFACE.CAPI       |    9 -
>  drivers/isdn/capi/capi.c                |   99 +++++-----------
>  drivers/isdn/capi/capidrv.c             |   55 ++------
>  drivers/isdn/capi/kcapi.c               |    8 -
>  drivers/isdn/gigaset/capi.c             |   75 +++++-------
>  drivers/isdn/hardware/avm/avmcard.h     |    6=20
>  drivers/isdn/hardware/avm/b1.c          |   54 +++++---
>  drivers/isdn/hardware/avm/b1dma.c       |   71 +++++------
>  drivers/isdn/hardware/avm/b1isa.c       |    2=20
>  drivers/isdn/hardware/avm/b1pci.c       |    4=20
>  drivers/isdn/hardware/avm/b1pcmcia.c    |    2=20
>  drivers/isdn/hardware/avm/c4.c          |   53 +++++---
>  drivers/isdn/hardware/avm/t1isa.c       |    2=20
>  drivers/isdn/hardware/avm/t1pci.c       |    2=20
>  drivers/isdn/hardware/eicon/capimain.c  |   40 +++---
>  drivers/isdn/hardware/eicon/diva_didd.c |   45 +++----
>  drivers/isdn/hardware/eicon/divasi.c    |   48 ++++---
>  drivers/isdn/hardware/eicon/divasproc.c |  198 ++++++++++++++---------=
---------
>  drivers/isdn/hysdn/hycapi.c             |   56 ++++-----
>  include/linux/isdn/capilli.h            |    3=20
>  net/bluetooth/cmtp/capi.c               |   37 +++--
>  21 files changed, 411 insertions(+), 458 deletions(-)
>=20
> --- a/Documentation/isdn/INTERFACE.CAPI
> +++ b/Documentation/isdn/INTERFACE.CAPI
> @@ -149,10 +149,11 @@ char *(*procinfo)(struct capi_ctr *ctrlr)
>  	pointer to a callback function returning the entry for the device in
>  	the CAPI controller info table, /proc/capi/controller
> =20
> -read_proc_t *ctr_read_proc
> -	pointer to the read_proc callback function for the device's proc file=

> -	system entry, /proc/capi/controllers/<n>; will be called with a
> -	pointer to the device's capi_ctr structure as the last (data) argumen=
t
> +const struct file_operations *proc_fops
> +	pointers to callback functions for the device's proc file
> +	system entry, /proc/capi/controllers/<n>; pointer to the device's
> +	capi_ctr structure is available from struct proc_dir_entry::data
> +	which is available from struct inode.
> =20
>  Note: Callback functions except send_message() are never called in int=
errupt
>  context.
[...]
> --- a/drivers/isdn/gigaset/capi.c
> +++ b/drivers/isdn/gigaset/capi.c
> @@ -13,6 +13,8 @@
> =20
>  #include "gigaset.h"
>  #include <linux/ctype.h>
> +#include <linux/proc_fs.h>
> +#include <linux/seq_file.h>
>  #include <linux/isdn/capilli.h>
>  #include <linux/isdn/capicmd.h>
>  #include <linux/isdn/capiutil.h>
> @@ -2106,35 +2108,22 @@ static char *gigaset_procinfo(struct capi_ctr *=
ctr)
>  	return ctr->name;	/* ToDo: more? */
>  }
> =20
> -/**
> - * gigaset_ctr_read_proc() - build controller proc file entry
> - * @page:	buffer of PAGE_SIZE bytes for receiving the entry.
> - * @start:	unused.
> - * @off:	unused.
> - * @count:	unused.
> - * @eof:	unused.
> - * @ctr:	controller descriptor structure.
> - *
> - * Return value: length of generated entry
> - */
> -static int gigaset_ctr_read_proc(char *page, char **start, off_t off,
> -			  int count, int *eof, struct capi_ctr *ctr)
> +static int gigaset_proc_show(struct seq_file *m, void *v)
>  {
> +	struct capi_ctr *ctr =3D m->private;
>  	struct cardstate *cs =3D ctr->driverdata;
>  	char *s;
>  	int i;
> -	int len =3D 0;
> -	len +=3D sprintf(page+len, "%-16s %s\n", "name", ctr->name);
> -	len +=3D sprintf(page+len, "%-16s %s %s\n", "dev",
> +
> +	seq_printf(m, "%-16s %s\n", "name", ctr->name);
> +	seq_printf(m, "%-16s %s %s\n", "dev",
>  			dev_driver_string(cs->dev), dev_name(cs->dev));
> -	len +=3D sprintf(page+len, "%-16s %d\n", "id", cs->myid);
> +	seq_printf(m, "%-16s %d\n", "id", cs->myid);
>  	if (cs->gotfwver)
> -		len +=3D sprintf(page+len, "%-16s %d.%d.%d.%d\n", "firmware",
> +		seq_printf(m, "%-16s %d.%d.%d.%d\n", "firmware",
>  			cs->fwver[0], cs->fwver[1], cs->fwver[2], cs->fwver[3]);
> -	len +=3D sprintf(page+len, "%-16s %d\n", "channels",
> -			cs->channels);
> -	len +=3D sprintf(page+len, "%-16s %s\n", "onechannel",
> -			cs->onechannel ? "yes" : "no");
> +	seq_printf(m, "%-16s %d\n", "channels", cs->channels);
> +	seq_printf(m, "%-16s %s\n", "onechannel", cs->onechannel ? "yes" : "n=
o");
> =20
>  	switch (cs->mode) {
>  	case M_UNKNOWN:
> @@ -2152,7 +2141,7 @@ static int gigaset_ctr_read_proc(char *page, char=
 **start, off_t off,
>  	default:
>  		s =3D "??";
>  	}
> -	len +=3D sprintf(page+len, "%-16s %s\n", "mode", s);
> +	seq_printf(m, "%-16s %s\n", "mode", s);
> =20
>  	switch (cs->mstate) {
>  	case MS_UNINITIALIZED:
> @@ -2176,25 +2165,21 @@ static int gigaset_ctr_read_proc(char *page, ch=
ar **start, off_t off,
>  	default:
>  		s =3D "??";
>  	}
> -	len +=3D sprintf(page+len, "%-16s %s\n", "mstate", s);
> +	seq_printf(m, "%-16s %s\n", "mstate", s);
> =20
> -	len +=3D sprintf(page+len, "%-16s %s\n", "running",
> -			cs->running ? "yes" : "no");
> -	len +=3D sprintf(page+len, "%-16s %s\n", "connected",
> -			cs->connected ? "yes" : "no");
> -	len +=3D sprintf(page+len, "%-16s %s\n", "isdn_up",
> -			cs->isdn_up ? "yes" : "no");
> -	len +=3D sprintf(page+len, "%-16s %s\n", "cidmode",
> -			cs->cidmode ? "yes" : "no");
> +	seq_printf(m, "%-16s %s\n", "running", cs->running ? "yes" : "no");
> +	seq_printf(m, "%-16s %s\n", "connected", cs->connected ? "yes" : "no"=
);
> +	seq_printf(m, "%-16s %s\n", "isdn_up", cs->isdn_up ? "yes" : "no");
> +	seq_printf(m, "%-16s %s\n", "cidmode", cs->cidmode ? "yes" : "no");
> =20
>  	for (i =3D 0; i < cs->channels; i++) {
> -		len +=3D sprintf(page+len, "[%d]%-13s %d\n", i, "corrupted",
> +		seq_printf(m, "[%d]%-13s %d\n", i, "corrupted",
>  				cs->bcs[i].corrupted);
> -		len +=3D sprintf(page+len, "[%d]%-13s %d\n", i, "trans_down",
> +		seq_printf(m, "[%d]%-13s %d\n", i, "trans_down",
>  				cs->bcs[i].trans_down);
> -		len +=3D sprintf(page+len, "[%d]%-13s %d\n", i, "trans_up",
> +		seq_printf(m, "[%d]%-13s %d\n", i, "trans_up",
>  				cs->bcs[i].trans_up);
> -		len +=3D sprintf(page+len, "[%d]%-13s %d\n", i, "chstate",
> +		seq_printf(m, "[%d]%-13s %d\n", i, "chstate",
>  				cs->bcs[i].chstate);
>  		switch (cs->bcs[i].proto2) {
>  		case L2_BITSYNC:
> @@ -2209,11 +2194,23 @@ static int gigaset_ctr_read_proc(char *page, ch=
ar **start, off_t off,
>  		default:
>  			s =3D "??";
>  		}
> -		len +=3D sprintf(page+len, "[%d]%-13s %s\n", i, "proto2", s);
> +		seq_printf(m, "[%d]%-13s %s\n", i, "proto2", s);
>  	}
> -	return len;
> +	return 0;
>  }
> =20
> +static int gigaset_proc_open(struct inode *inode, struct file *file)
> +{
> +	return single_open(file, gigaset_proc_show, PDE(inode)->data);
> +}
> +
> +static const struct file_operations gigaset_proc_fops =3D {
> +	.owner		=3D THIS_MODULE,
> +	.open		=3D gigaset_proc_open,
> +	.read		=3D seq_read,
> +	.llseek		=3D seq_lseek,
> +	.release	=3D single_release,
> +};
> =20
>  static struct capi_driver capi_driver_gigaset =3D {
>  	.name		=3D "gigaset",
> @@ -2256,7 +2253,7 @@ int gigaset_isdn_register(struct cardstate *cs, c=
onst char *isdnid)
>  	iif->ctr.release_appl  =3D gigaset_release_appl;
>  	iif->ctr.send_message  =3D gigaset_send_message;
>  	iif->ctr.procinfo      =3D gigaset_procinfo;
> -	iif->ctr.ctr_read_proc =3D gigaset_ctr_read_proc;
> +	iif->ctr.proc_fops =3D &gigaset_proc_fops;
>  	INIT_LIST_HEAD(&iif->appls);
>  	skb_queue_head_init(&iif->sendqueue);
>  	atomic_set(&iif->sendqlen, 0);

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig01C4794F812567C349101A67
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org/

iEYEARECAAYFAktKH7UACgkQQ3+did9BuFsEvACglr8htpVC2zGiIaZ7WRB9cCsc
YzYAnjr1c2hSgQarqsjPqvkDFrlSqU+M
=6ttq
-----END PGP SIGNATURE-----

--------------enig01C4794F812567C349101A67--
