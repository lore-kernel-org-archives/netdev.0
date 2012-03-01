From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Restricting payload size in do_tcp_sendpages.
Date: Thu, 01 Mar 2012 07:58:45 -0800
Message-ID: <1330617525.2465.77.camel@edumazet-laptop>
References: <CAJNbMryYORXmp0CPhL9zt8ne5P5yOKvNLsqnjeNwb4m0OAQeiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ashwin Rao <ashwin.shirvanthe@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37379 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959Ab2CAP6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 10:58:53 -0500
Received: by wibhm2 with SMTP id hm2so21716wib.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 07:58:52 -0800 (PST)
In-Reply-To: <CAJNbMryYORXmp0CPhL9zt8ne5P5yOKvNLsqnjeNwb4m0OAQeiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 mars 2012 =C3=A0 16:16 +0100, Ashwin Rao a =C3=A9crit :
> Hi,
>=20
> I would like to perform some experiments where I want TCP to send
> packets of size less than the MSS even more than an MSS worth of data
> is available in the TCP buffers.  I am performing these experiments t=
o
> submit a patch that can avoid synchronization of TCP flows. I have
> modified the following code in the function do_tcp_sendpages in the
> file net/ipv4/tcp.c.  For testing purposes I have currently set the
> mss_now to half of the value that would have been typically used. I
> have even updated the size_goal which controls the maximum size that
> can be sent when offloading is enabled. To avoid coalescing smaller
> skbs I have even set the can_coalesce to 0. Despite these changes the
> frames sent over the Ethernet have the length of 1514 bytes. I would
> like to know which function is responsible for coalescing these
> packets despite forcing a small segment size.
>=20
> *** linux-3.2.6/net/ipv4/tcp.c=09
> --- linux-3.2.6-modified/net/ipv4/tcp.c
> *************** static ssize_t do_tcp_sendpages(struct s
> *** 774,779 ****
> --- 774,783 ----
>   	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
>=20
>   	mss_now =3D tcp_send_mss(sk, &size_goal, flags);
> +     /* hack begin */
> +     mss_now =3D mss_now >> 1;
> +     size_goal =3D mss_now;
> +     /* hack end */
>   	copied =3D 0;
>=20
>   	err =3D -EPIPE;
> *************** new_segment:
> *** 805,810 ****
> --- 809,817 ----
>=20
>   		i =3D skb_shinfo(skb)->nr_frags;
>   		can_coalesce =3D skb_can_coalesce(skb, i, page, offset);
> +             /* hack begin */
> +             can_coalesce =3D 0;
> +             /* hack end */
>   		if (!can_coalesce && i >=3D MAX_SKB_FRAGS) {
>   			tcp_mark_push(tp, skb);
>   			goto new_segment;
> *************** wait_for_memory:
> *** 857,862 ****
> --- 864,873 ----
>   			goto do_error;
>=20
>   		mss_now =3D tcp_send_mss(sk, &size_goal, flags);
> +             /* hack begin */
> +             mss_now =3D mss_now >> 1;
> +             size_goal =3D mss_now;
> +             /* hack end */
>   	}
>=20
>=20

You dont need to hack kernel

man 7 tcp

       TCP_MAXSEG
              The  maximum  segment  size  for  outgoing TCP packets.  =
If this
              option is set before connection establishment, it  also  =
changes
              the  MSS value announced to the other end in the initial =
packet.
              Values greater than the (eventual) interface MTU have no =
effect.
              TCP  will  also  impose  its minimum and maximum bounds o=
ver the
              value provided.
