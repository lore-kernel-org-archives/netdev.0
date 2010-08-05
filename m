From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch] isdn: fix information leak
Date: Thu, 5 Aug 2010 18:08:08 +0800
Message-ID: <AANLkTin4jtYuaxYfxDAgST857sD2K4Q28mPcPW=xd-V3@mail.gmail.com>
References: <20100805093806.GF9031@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50213 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758642Ab0HEKIa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 06:08:30 -0400
In-Reply-To: <20100805093806.GF9031@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 5, 2010 at 5:38 PM, Dan Carpenter <error27@gmail.com> wrote=
:
> The main motivation of this patch changing strcpy() to strlcpy().
> We strcpy() to copy a 48 byte buffers into a 49 byte buffers. =A0So a=
t
> best the last byte has leaked information, or maybe there is an
> overflow? =A0Anyway, this patch closes the information leaks by zeroi=
ng
> the memory and the calls to strlcpy() prevent overflows.

strlcpy() can handle the terminator NUL. so you don't need to zero it.

>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
>
> diff --git a/drivers/isdn/sc/ioctl.c b/drivers/isdn/sc/ioctl.c
> index 1081091..2655e3a 100644
> --- a/drivers/isdn/sc/ioctl.c
> +++ b/drivers/isdn/sc/ioctl.c
> @@ -174,7 +174,7 @@ int sc_ioctl(int card, scs_ioctl *data)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_debug("%s: SCIOGETSPID: ioctl recei=
ved\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc_ada=
pter[card]->devicename);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spid =3D kmalloc(SCIOC_SPIDSIZE, GFP_KE=
RNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spid =3D kzalloc(SCIOC_SPIDSIZE, GFP_KE=
RNEL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!spid) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(rcvmsg);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> @@ -194,7 +194,7 @@ int sc_ioctl(int card, scs_ioctl *data)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(rcvmsg);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return status;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcpy(spid, rcvmsg->msg_data.byte_arra=
y);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 strlcpy(spid, rcvmsg->msg_data.byte_arr=
ay, SCIOC_SPIDSIZE);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Package the switch type and send to=
 user space
> @@ -272,12 +272,12 @@ int sc_ioctl(int card, scs_ioctl *data)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return status;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dn =3D kmalloc(SCIOC_DNSIZE, GFP_KERNEL=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dn =3D kzalloc(SCIOC_DNSIZE, GFP_KERNEL=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!dn) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(rcvmsg);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcpy(dn, rcvmsg->msg_data.byte_array)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 strlcpy(dn, rcvmsg->msg_data.byte_array=
, SCIOC_DNSIZE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(rcvmsg);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> @@ -348,7 +348,7 @@ int sc_ioctl(int card, scs_ioctl *data)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_debug("%s: SCIOSTAT: ioctl received=
\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc_ada=
pter[card]->devicename);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bi =3D kmalloc (sizeof(boardInfo), GFP_=
KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bi =3D kzalloc(sizeof(boardInfo), GFP_K=
ERNEL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!bi) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(rcvmsg);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
