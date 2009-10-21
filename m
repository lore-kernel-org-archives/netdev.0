From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: possible circular locking dependency in ISDN PPP
Date: Wed, 21 Oct 2009 18:24:42 +0200
Message-ID: <4ADF35CA.5020207@imap.cc>
References: <4ADB93C4.4090607@imap.cc> <7b6bb4a50910182227y1281b40bj3fcc082d32cf4496@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig239C4265D1F2F745A65DB119"
Cc: LKML <linux-kernel@vger.kernel.org>,
	isdn4linux <isdn4linux@listserv.isdn4linux.de>,
	Netdev <netdev@vger.kernel.org>,
	Karsten Keil <isdn@linux-pingi.de>
To: Xiaotian Feng <xtfeng@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754427AbZJUQYx@vger.kernel.org>
In-Reply-To: <7b6bb4a50910182227y1281b40bj3fcc082d32cf4496@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig239C4265D1F2F745A65DB119
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Thanks for your analysis. The patch you propose does indeed prevent the
"circular locking dependency" message, with no noticeable ill effect.

I cannot say why xmit_lock was taken around isdn_net_lp_busy() in the
first place. The ISDN4Linux people would be the ones to comment on that.
If none of them objects, I propose you add a Signed-off-by line to your
patch and submit it to Karsten Keil, the ISDN maintainer, for inclusion.
You can also add a "Tested-by: Tilman Schmidt <tilman@imap.cc>" line.

Thanks,
Tilman

Am 19.10.2009 07:27 schrieb Xiaotian Feng:
> So there's a circular locking dependency.. Looking into isdn_net_get_lo=
cked_lp()
[...]
> Why do we need to hold xmit_lock while using
> isdn_net_lp_busy(nd->queue) ? Can following patch fix this bug?
>=20
> ---
> diff --git a/drivers/isdn/i4l/isdn_net.h b/drivers/isdn/i4l/isdn_net.h
> index 74032d0..7511f08 100644
> --- a/drivers/isdn/i4l/isdn_net.h
> +++ b/drivers/isdn/i4l/isdn_net.h
> @@ -83,19 +83,19 @@ static __inline__ isdn_net_local *
> isdn_net_get_locked_lp(isdn_net_dev *nd)
>=20
>         spin_lock_irqsave(&nd->queue_lock, flags);
>         lp =3D nd->queue;         /* get lp on top of queue */
> -       spin_lock(&nd->queue->xmit_lock);
>         while (isdn_net_lp_busy(nd->queue)) {
> -               spin_unlock(&nd->queue->xmit_lock);
>                 nd->queue =3D nd->queue->next;
>                 if (nd->queue =3D=3D lp) { /* not found -- should never=
 happen */
>                         lp =3D NULL;
>                         goto errout;
>                 }
> -               spin_lock(&nd->queue->xmit_lock);
>         }
>         lp =3D nd->queue;
>         nd->queue =3D nd->queue->next;
> +       spin_unlock_irqrestore(&nd->queue_lock, flags);
> +       spin_lock(&lp->xmit_lock);
>         local_bh_disable();
> +       return lp;
>  errout:
>         spin_unlock_irqrestore(&nd->queue_lock, flags);
>         return lp;
>=20

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)


--------------enig239C4265D1F2F745A65DB119
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFK3zXUQ3+did9BuFsRAjW8AJwL3SzKAXohbqJ3wCBkXpHdV+26ewCfbOHY
0SAccy0ec6LHrkgNx2bWfcI=
=e2Vg
-----END PGP SIGNATURE-----

--------------enig239C4265D1F2F745A65DB119--
