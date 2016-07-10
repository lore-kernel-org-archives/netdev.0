From: Sergei Trofimovich <slyfox@gentoo.org>
Subject: Re: [BUG?] tcp regression in v4.7-r1:
 c14ac9451c34832554db33386a4393be8bba3a7b breaks pulseaudio over TCP
Date: Sun, 10 Jul 2016 17:25:10 +0100
Message-ID: <20160710172510.4ec29e3e@sf>
References: <20160710124240.7d484f44@sf>
	<CACSApvbeMfzgbLyfBNBG=VyJXJWJ2W48NA=BLodQMyjYpiwDOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/gYHys_LTPlO1If=CJV7tv6m"; protocol="application/pgp-signature"
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Tanu Kaskinen <tanuk@iki.fi>
To: Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:51050 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820AbcGJQZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2016 12:25:27 -0400
In-Reply-To: <CACSApvbeMfzgbLyfBNBG=VyJXJWJ2W48NA=BLodQMyjYpiwDOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/gYHys_LTPlO1If=CJV7tv6m
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 10 Jul 2016 11:15:01 -0400
Soheil Hassas Yeganeh <soheil@google.com> wrote:

> On Sun, Jul 10, 2016 at 7:42 AM, Sergei Trofimovich <slyfox@gentoo.org> w=
rote:
> > Hi netdev folk!
> >
> > Commit c14ac9451c34832554db33386a4393be8bba3a7b
> > broke pulseaudio (PA) over TCP. =20
>=20
> Sorry that my patch broke your app and thanks for the bug report.
> Breaking PA was certainly not my intention.
>=20
> > PA does unusual thing: it calls
> >     sendmsg(cmsg_type=3DSCM_CREDENTIALS)
> >
> > on a TCP socket. It's not a new PA behaviour though.
> >
> > Originally reported as PA bug (has more details)
> >     https://bugs.freedesktop.org/show_bug.cgi?id=3D96873
> >
> > It looks like kernel used to ignore control messages
> > but now it does not:
> >     http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/diff=
/net/ipv4/tcp.c?id=3Dc14ac9451c34832554db33386a4393be8bba3a7b
> >
> > +       if (msg->msg_controllen) {
> > +               err =3D sock_cmsg_send(sk, msg, &sockc);
> > +               if (unlikely(err)) {
> > +                       err =3D -EINVAL;
> > +                       goto out_err;
> > +               }
> > +       }
> >
> > This change breaks streaming of pulse clients.
> >
> > Pulseaudio will be fixed at some point.
> >
> > But kernel change does not look like intentional
> > breakage of old behaviour.
> >
> > Perhaps kernel should have a grace period and only
> > warn about unsupported control messages for a socket? =20
>=20
> We have discussed ignoring certain control messages in another context:
> https://patchwork.ozlabs.org/patch/621837/
>=20
> But the counter-argument (which I agree with) is that: we used to
> accept garbage in control messages before, but that doesn't mean we
> should give up on strict checking.
>=20
> This new problem is a bit different though. We always ignore control
> messages of other layers:
>=20
> ip_cmsg_send:
>                  if (cmsg->cmsg_level !=3D SOL_IP)
>                          continue;
>=20
> sock_cmsg_send:
>                  if (cmsg->cmsg_level !=3D SOL_SOCKET)
>                          continue;
>=20
> Semantically SCM_RIGHTS and SCM_CREDENTIALS belong to the SOL_UNIX
> layer but they are historically sent on SOL_SOCKET. I believe we
> should ignore them as we would if they were sent on SOL_UNIX:
>=20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 08bf97e..6239abf 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1938,6 +1938,13 @@ int __sock_cmsg_send(struct sock *sk, struct
> msghdr *msg, struct cmsghdr *cmsg,
>                 sockc->tsflags &=3D ~SOF_TIMESTAMPING_TX_RECORD_MASK;
>                 sockc->tsflags |=3D tsflags;
>                 break;
> +       /* SCM_RIGHTS and SCM_CREDENTIALS are semantically in SOL_UNIX
> +        * yet they are sent on SOL_SOCKET. We should ignore them as
> +        * we do for control messages not in the SOL_SOCKET layers.
> +        */
> +       case SCM_RIGHTS:
> +       case SCM_CREDENTIALS:

Fixes PA for me. That was quick!

Perhaps to have those applications a change be fixed in future something li=
ke

+                       net_info_ratelimited("TCP(%s:%d): Application bug, =
<some meaningful explanation>\n",
+                                           current->comm,
+                                           task_pid_nr(current));

could signal the breakage? WDYT?

--=20

  Sergei

--Sig_/gYHys_LTPlO1If=CJV7tv6m
Content-Type: application/pgp-signature
Content-Description: Цифровая подпись OpenPGP

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAleCdukACgkQcaHudmEf86pxnQCeIdMZ/KOgiIMJNRmJ0xT/z/EC
XFIAn2CUw8skzOj3ADsqotPGcUVfTVuF
=LoQU
-----END PGP SIGNATURE-----

--Sig_/gYHys_LTPlO1If=CJV7tv6m--
