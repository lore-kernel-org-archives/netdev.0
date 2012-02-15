From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible bugfix for AF_UNIX, SOCK_SEQPACKET sockets
Date: Wed, 15 Feb 2012 07:25:09 +0100
Message-ID: <1329287109.2555.44.camel@edumazet-laptop>
References: <CAFJW8X86fGhK4cwH0=dQrK8TSJdmPB51TgLjcK=wdOBQzNeF-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Piergiorgio Beruto <piergiorgio.beruto@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49549 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304Ab2BOGZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 01:25:14 -0500
Received: by werb13 with SMTP id b13so393965wer.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 22:25:12 -0800 (PST)
In-Reply-To: <CAFJW8X86fGhK4cwH0=dQrK8TSJdmPB51TgLjcK=wdOBQzNeF-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 f=C3=A9vrier 2012 =C3=A0 23:05 +0100, Piergiorgio Beruto a =
=C3=A9crit :
> Hello,
> I would like to have your opinion regarding what I think could be a
> misbehaviour of the SIOCINQ ioctl on AF_UNIX domain sockets.
>=20
> I was implementing an IPC user-space library which makes use of a
> variety of sockets for sending data all around.
> When dealing with datagram sockets (i.e. SOCK_DGRAM, SOCK_RDM and
> SOCK_SEQPACKET) I used to implement the following paradigm:
>=20
> 1) issue the SIOCINQ (aka FIONREAD) ioctl and get the "size of the
> first queued datagram"
> 2) allocate memory of that size and fill it reading out data from the=
 socket
>=20
> This works very fine for UDP and TIPC (including SOCK_SEQPACKET)
> sockets but when using AF_UNIX (SEQPACKET) sockets the same ioctl
> returns instead the number of bytes queued (sum of all pending
> datagrams) .
>=20
> In short, there is no way (as far as I know) to work out how much
> memory to allocate in userspace before reading out the datagram.
> The workaround for this is to use a fixed swap buffer of the max
> possible size of your packets (assuming you know / can retrieve it
> somehow) and make a copy of your data (which is bad for performance
> anyway).
>=20

I dont understand.... SIOCINQ returns an upper limit to you.

So your app can malloc() a big enough buffer.

Yes, SEQPACKET preserves message boundaries so your recvmsg() can fill
part of the application buffer.

> Looking at the kernel code I've found this in the
> linux/net/unix/af_unix.c file (my comment with ////)
>=20
> case SIOCINQ:
> 	{
> 	        struct sk_buff *skb;
> =09
> 	        if (sk->sk_state =3D=3D TCP_LISTEN) {
> 	                err =3D -EINVAL;
> 	                break;
> 	        }
> =09
> 	        spin_lock(&sk->sk_receive_queue.lock);
> 	        if (sk->sk_type =3D=3D SOCK_STREAM ||
> 	            sk->sk_type =3D=3D SOCK_SEQPACKET) {           //// <---=
-----
> treats SEQPACKET as SOCK_STREAM
> 	                skb_queue_walk(&sk->sk_receive_queue, skb)
> 	                        amount +=3D skb->len;
> 	        } else {
> 	                skb =3D skb_peek(&sk->sk_receive_queue);
> 	                if (skb)
> 	                        amount =3D skb->len;
> 	        }
> 	        spin_unlock(&sk->sk_receive_queue.lock);
> 	        err =3D put_user(amount, (int __user *)arg);
> 	        break;
> 	}
>=20
> In my opinion SOCK_SEQPACKETS are similar to SOCK_STREAM because they
> are "connection oriented" sockets but from the I/O point of view are
> more similar to datagram ones.
>=20
> My proposal is to remove the above condition from the test and let th=
e
> function process SOCK_SEQPACKETS as if they were SOCK_DGRAM for this
> particular ioctl.
>=20

This behavior is undocumented in "man unix", so it is "implementation
dependant"

This change could break some applications.
