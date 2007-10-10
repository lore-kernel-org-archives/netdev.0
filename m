From: Anton Arapov <aarapov@redhat.com>
Subject: Re: [PATCH] division-by-zero in inet_csk_get_port
Date: Wed, 10 Oct 2007 11:00:17 +0200
Message-ID: <m31wc3l4ym.fsf@bandura.englab.brq.redhat.com>
References: <20071010085530.GA7532@iris.sw.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752194AbXJJJAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 05:00:23 -0400
In-Reply-To: <20071010085530.GA7532@iris.sw.ru> (Denis V. Lunev's message of "Wed\, 10 Oct 2007 12\:55\:30 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Transfer-Encoding: quoted-printable


Ok, I've got it, so we have to do the same with the following:
quote from inet_hashtables.c and inet6_hashtables.c. I'll prepare the
patch.

And just a curious, does the /* Treat low > high as high =3D=3D low */
idea will keep after the sysctl will be patched?

int inet_hash_connect(struct inet_timewait_death_row *death_row,
                      struct sock *sk)
{
        struct inet_hashinfo *hinfo =3D death_row->hashinfo;
        const unsigned short snum =3D inet_sk(sk)->num;
        struct inet_bind_hashbucket *head;
        struct inet_bind_bucket *tb;
        int ret;

        if (!snum) {
                int low =3D sysctl_local_port_range[0];
                int high =3D sysctl_local_port_range[1];
>                int range =3D high - low;
                int i;
                int port;
                static u32 hint;
                u32 offset =3D hint + inet_sk_port_offset(sk);
                struct hlist_node *node;
                struct inet_timewait_sock *tw =3D NULL;

                local_bh_disable();
                for (i =3D 1; i <=3D range; i++) {
>                        port =3D low + (i + offset) % range;
=20

"Denis V. Lunev" <den@openvz.org> writes:
> This patch fixed a possible division-by-zero in inet_csk_get_port
> treating situation low > high as if low =3D=3D high.
>
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> CC: Antov Arapov  <aarapov@redhat.com>
>
> --- ./net/ipv4/inet_connection_sock.c.getport	2007-10-09 15:16:02.0000000=
00 +0400
> +++ ./net/ipv4/inet_connection_sock.c	2007-10-10 12:44:04.000000000 +0400
> @@ -80,7 +80,14 @@ int inet_csk_get_port(struct inet_hashin
>  		int low =3D sysctl_local_port_range[0];
>  		int high =3D sysctl_local_port_range[1];
>  		int remaining =3D (high - low) + 1;
> -		int rover =3D net_random() % (high - low) + low;
> +		int rover;
> +
> +		/* Treat low > high as high =3D=3D low */
> +		if (remaining <=3D 1) {
> +			remaining =3D 1;
> +			rover =3D low;
> +		} else
> +			rover =3D net_random() % (high - low) + low;
>=20=20
>  		do {
>  			head =3D &hashinfo->bhash[inet_bhashfn(rover, hashinfo->bhash_size)];

=2D-=20
Anton Arapov, <aarapov@redhat.com>
Kernel Development, Red Hat
GPG Key ID: 0x6FA8C812

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFHDJSlVub9yW+oyBIRAsfQAKD0sMxK0pLWfdDhmmz8DA8ftlT2TgCffr/m
hNfnfk/NsZiqwGZUkDS1mbk=
=ReYa
-----END PGP SIGNATURE-----
--=-=-=--
