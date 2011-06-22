From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] ipv6/udp: Use the correct variable to
 determine non-blocking condition
Date: Wed, 22 Jun 2011 07:42:40 +0200
Message-ID: <1308721360.2713.5.camel@edumazet-laptop>
References: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
	 <1308689020-1873-3-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Xufeng Zhang <xufeng.zhang@windriver.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44904 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030Ab1FVFmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 01:42:44 -0400
Received: by wyb38 with SMTP id 38so304028wyb.19
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2011 22:42:43 -0700 (PDT)
In-Reply-To: <1308689020-1873-3-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 juin 2011 =C3=A0 16:43 -0400, Paul Gortmaker a =C3=A9crit :
> From: Xufeng Zhang <xufeng.zhang@windriver.com>
>=20
> udpv6_recvmsg() function is not using the correct variable to determi=
ne
> whether or not the socket is in non-blocking operation, this will lea=
d
> to unexpected behavior when a UDP checksum error occurs.
>=20
> Consider a non-blocking udp receive scenario: when udpv6_recvmsg() is
> called by sock_common_recvmsg(), MSG_DONTWAIT bit of flags variable i=
n
> udpv6_recvmsg() is cleared by "flags & ~MSG_DONTWAIT" in this call:
>=20
>     err =3D sk->sk_prot->recvmsg(iocb, sk, msg, size, flags & MSG_DON=
TWAIT,
>                    flags & ~MSG_DONTWAIT, &addr_len);
>=20
> i.e. with udpv6_recvmsg() getting these values:
>=20
> 	int noblock =3D flags & MSG_DONTWAIT
> 	int flags =3D flags & ~MSG_DONTWAIT
>=20
> So, when udp checksum error occurs, the execution will go to
> csum_copy_err, and then the problem happens:
>=20
>     csum_copy_err:
>             ...............
>             if (flags & MSG_DONTWAIT)
>                     return -EAGAIN;
>             goto try_again;
>             ...............
>=20
> But it will always go to try_again as MSG_DONTWAIT has been cleared
> from flags at call time -- only noblock contains the original value
> of MSG_DONTWAIT, so the test should be:
>=20
>             if (noblock)
>                     return -EAGAIN;
>=20
> This is also consistent with what the ipv4/udp code does.
>=20
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


