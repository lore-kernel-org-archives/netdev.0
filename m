From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Provide SYN packet for passive connections
Date: Sun, 11 Mar 2012 20:10:33 -0700
Message-ID: <1331521833.2449.32.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1203111944520.1019@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34440 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022Ab2CLDKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 23:10:40 -0400
Received: by wejx9 with SMTP id x9so2801326wej.19
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2012 20:10:39 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1203111944520.1019@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 11 mars 2012 =C3=A0 19:48 -0700, Tom Herbert a =C3=A9crit :
> This patch allows a server application to get the TCP SYN packets for
> its passive connections.  This is useful if the server is doing
> fingerprinting of clients based on SYN packet contents.
>=20
> Two socket options are added: TCP_SAVE_SYN and TCP_SAVED_SYN.  The
> first is used on a listener socket to enable saving the SYN packets
> for child connections.  The latter is used to retrieve the SYN for
> and accepted connection.  TCP_SAVED_SYN is read once, it frees the
> saved SYN packet.
>=20
> The data returned TCP_SAVED_SYN is the IP header (v4 or v6) through
> the TCP header.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/tcp.h                |    2 ++
>  include/net/inet_connection_sock.h |   31 ++++++++++++++++++++++++++=
+++++
>  include/net/request_sock.h         |    6 +++++-
>  net/ipv4/inet_connection_sock.c    |    2 ++
>  net/ipv4/tcp.c                     |   32 ++++++++++++++++++++++++++=
++++++
>  net/ipv4/tcp_ipv4.c                |    2 ++
>  net/ipv4/tcp_minisocks.c           |    2 ++
>  net/ipv6/tcp_ipv6.c                |    2 ++
>  8 files changed, 78 insertions(+), 1 deletions(-)
>=20
=2E..

>  			tp->linger2 =3D -1;
> @@ -2632,6 +2639,31 @@ static int do_tcp_getsockopt(struct sock *sk, =
int level,
>  	case TCP_USER_TIMEOUT:
>  		val =3D jiffies_to_msecs(icsk->icsk_user_timeout);
>  		break;
> +	case TCP_SAVE_SYN:
> +		val =3D icsk->icsk_save_syn;
> +		break;
> +	case TCP_SAVED_SYN: {
> +		if (get_user(len, optlen))
> +			return -EFAULT;
> +
> +		if (icsk->icsk_saved_syn) {
> +			struct sk_buff *skb =3D icsk->icsk_saved_syn;
> +			void *b =3D skb_network_header(skb);
> +			void *e =3D (void *)tcp_hdr(skb) + tcp_hdrlen(skb);
> +
> +			len =3D min_t(unsigned int, e - b, len);
> +			if (put_user(len, optlen))
> +				return -EFAULT;
> +			if (copy_to_user(optval, b, len))
> +				return -EFAULT;
> +			inet_csk_free_syn(sk);
> +		} else {


I am concerned by the fact that socket might be not locked here, so thi=
s
code is racy if two threads happen to call this at the same time.

Or maybe its locked and I am too lazy ? :)
