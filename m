From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: synchronize bind() with RTM_NEWADDR notifications
Date: Thu, 21 Oct 2010 12:25:53 +0200
Message-ID: <1287656753.6871.46.camel@edumazet-laptop>
References: <1287655930-16879-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57286 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756443Ab0JUKZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:25:58 -0400
Received: by wyb28 with SMTP id 28so4915395wyb.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 03:25:57 -0700 (PDT)
In-Reply-To: <1287655930-16879-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 21 octobre 2010 =C3=A0 13:12 +0300, Timo Ter=C3=A4s a =C3=A9cr=
it :
> Otherwise we have race condition to user land:
>  1. process A changes IP address
>  2. kernel sends RTM_NEWADDR
>  3. process B gets notification
>  4. process B tries to bind() to new IP but that fails with
> EADDRNOTAVAIL because FIB is not yet updated and inet_addr_type() in
> inet_bind() does not recognize the IP as local
>  5. kernel calls inetaddr_chain notifiers which updates FIB
>=20
> IPv6 side seems to handle the notifications properly: bind()
> immediately after RTM_NEWADDR succeeds as expected. This is because
> ipv6_chk_addr() uses inet6_addr_lst which is updated before address
> notification.
>=20
> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> ---
>  net/ipv4/af_inet.c  |    9 +++++++++
>  net/ipv6/af_inet6.c |    4 +++-
>  2 files changed, 12 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 6a1100c..21200e4 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -466,6 +466,15 @@ int inet_bind(struct socket *sock, struct sockad=
dr *uaddr, int addr_len)
>  	if (addr_len < sizeof(struct sockaddr_in))
>  		goto out;
> =20
> +	/* Acquire rtnl_lock to synchronize with possible simultaneous
> +	 * IP-address changes. This is needed because when RTM_NEWADDR
> +	 * is sent the new IP is not yet in FIB, but alas inet_addr_type
> +	 * checks the address type using FIB. Acquiring rtnl lock once
> +	 * makse sure that any address for which RTM_NEWADDR was sent
> +	 * earlier exists also in FIB. */
> +	rtnl_lock();
> +	rtnl_unlock();

You must be kidding ?

Really, this is a hot path...



