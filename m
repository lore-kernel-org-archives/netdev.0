From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/5] soreuseport: TCP/IPv4 implementation
Date: Fri, 25 Jan 2013 09:08:11 +0100
Message-ID: <20130125080811.GM9147@secunet.com>
References: <alpine.DEB.2.00.1301221141310.26417@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58737 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751307Ab3AYIIO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 03:08:14 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1301221141310.26417@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2013 at 11:50:24AM -0800, Tom Herbert wrote:
> -	} else if (tb->fastreuse &&
> -		   (!sk->sk_reuse || sk->sk_state =3D=3D TCP_LISTEN))
> -		tb->fastreuse =3D 0;
> +		if (sk->sk_reuseport) {
> +			tb->fastreuseport =3D 1;
> +			tb->fastuid =3D uid;
> +		} else {
> +			tb->fastreuseport =3D 0;
> +			tb->fastuid =3D 0;
> +		}
> +	} else {
> +		if (tb->fastreuse &&
> +		    (!sk->sk_reuse || sk->sk_state =3D=3D TCP_LISTEN))
> +			tb->fastreuse =3D 0;
> +		if (tb->fastreuseport &&
> +		    (!sk->sk_reuseport || !uid_eq(tb->fastuid, uid))) {
> +			tb->fastreuseport =3D 0;
> +			tb->fastuid =3D 0;
> +		}

I'm getting the following compile error due to the 0 assignment
to tb->fastuid:

net/ipv4/inet_connection_sock.c: In function =E2=80=98inet_csk_get_port=
=E2=80=99:
net/ipv4/inet_connection_sock.c:232:16: error: incompatible types when =
assigning to type =E2=80=98kuid_t=E2=80=99 from type =E2=80=98int=E2=80=
=99
net/ipv4/inet_connection_sock.c:241:16: error: incompatible types when =
assigning to type =E2=80=98kuid_t=E2=80=99 from type =E2=80=98int=E2=80=
=99
  CC      lib/show_mem.o
  CC      net/ipv6/ipv6_sockglue.o
make[3]: *** [net/ipv4/inet_connection_sock.o] Error 1
make[2]: *** [net/ipv4] Error 2

I have not seen this reported so far what surprises me a bit.
This is net-next from today complied with
gcc (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3
