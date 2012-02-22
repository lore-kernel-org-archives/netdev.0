From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 22 Feb 2012 08:36:35 +0100
Message-ID: <1329896195.18384.83.camel@edumazet-laptop>
References: <20120222055139.GB8026@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:64788 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759Ab2BVHgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 02:36:42 -0500
Received: by wics10 with SMTP id s10so3999652wic.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 23:36:41 -0800 (PST)
In-Reply-To: <20120222055139.GB8026@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 f=C3=A9vrier 2012 =C3=A0 00:51 -0500, Neal Cardwell a =C3=
=A9crit :
> A few thoughts:
>=20
> (1) Currently __tcp_grow_window has a very large negative impact due
>     to quantization. AFAICT from inspecting the code, the rcv_ssthres=
h
>     converges to the following output values given the following inpu=
t
>     skb->truesize/skb->len input values:
>=20
> truesize/len   rcv_ssthresh
> ------------   -------------
> <=3D 4/3         3/4 * tcp_space()
> <=3D 8/3         3/8 * sysctl_tcp_rmem[2]
> <=3D 16/3        3/16 * sysctl_tcp_rmem[2]
> <=3D 32/3        3/32 * sysctl_tcp_rmem[2]
> ...
>=20
>   As a sanity-check of this table, note that in the report above wher=
e
>   we got tcpdump traces for the beginning and end of the connection,
>   the receive window converged to 338832, which was 2208 bytes above
>   (3/8)*sysctl_tcp_rmem[2] for his configuration of sysctl_tcp_rmem[2=
]
>   =3D 897664.
>=20
>   It would be nice to get rid of this huge jump between truesize of
>   4/3*skb->len and 8/3*skb->len. Ideally we could make this
>   continuous?
>=20

This skb->truesize/skb->len affair is suspect if you ask me.

We increase rcv_ssthresh if we receive a 'good skb', but we have no
guarantee of future skbs.

When we are close to the converged value, we might spend some time in
tcp_grow_window() and decide not to increase rcv_sshthresh

IMHO a better way would be to look at integration values
(sk->sk_rmem_alloc) to not increase rcv_sshthresh if socket receive
queue is full of 'bad skbs'

> (2) I don't think we want to scale the increment using truesize, but
>     rather calculate a cap using the truesize/skb->len ratio.
>=20
> (3) We should use this cap to also cap the post-incremented value of
>     rcv_ssthresh, so the increment itself does not take us over the
>     target. (Again, note the example where the receive window ended u=
p
>     about 2MSS above the target.)

Thats the 'oh we receive a good skb, lets add 2*MSS to rcv_sshthresh'
syndrom

>=20
> (4) We should only request an ACK now if the rcv_ssthresh actually
>     increases.


Note that with your patch and 'good skb', rcv_ssthresh increases slower
than before (MSS increases instead of 2*MSS)
