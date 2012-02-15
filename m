From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible bugfix for AF_UNIX, SOCK_SEQPACKET sockets
Date: Wed, 15 Feb 2012 13:42:07 +0100
Message-ID: <1329309727.2437.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAFJW8X86fGhK4cwH0=dQrK8TSJdmPB51TgLjcK=wdOBQzNeF-A@mail.gmail.com>
	 <1329287109.2555.44.camel@edumazet-laptop>
	 <CAFJW8X_1CNxe0PhxyaBjYSu0xNw0ymyDVFmsA0C5XsHK9F2D8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Piergiorgio Beruto <piergiorgio.beruto@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:54561 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753924Ab2BOMmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 07:42:11 -0500
Received: by wics10 with SMTP id s10so482043wic.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 04:42:10 -0800 (PST)
In-Reply-To: <CAFJW8X_1CNxe0PhxyaBjYSu0xNw0ymyDVFmsA0C5XsHK9F2D8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 11:43 +0100, Piergiorgio Beruto=
 a =C3=A9crit :

> Yes, there's nothing that "doesn't work", it's a matter of performanc=
e
> (I am working on strong embedded so I'm quite concerned about both
> memory usage and "speed").
>=20
> The problem is that when the socket queue is filled with short sized
> packets, dequeue operation would allocate a lot of "big" chunks of
> memory, progressively smaller (first one the size of the queue, secon=
d
> one =3D queue size - first packet size and so on).
>=20
> Besides the waste of memory, you get less perfromance as malloc()
> would use the heap or mmap() depending on the size of the chunk
> (usually 64 bytes) and  the use of mmap is more memory efficient but
> quite slower.

I see

> Ok, that's why I asked :) But if you agree with my objection regardin=
g
> performance, what about adding a brand new (linux only) ioctl which
> implements the other behaviour? So the code would look something like
> this:
>=20
> case SIOCINQ:
> case SIOCPSZ:     //// new packet size ioctl
>        {
>                struct sk_buff *skb;
>=20
>                if (sk->sk_state =3D=3D TCP_LISTEN) {
>                        err =3D -EINVAL;
>                        break;
>                }
>=20
>                spin_lock(&sk->sk_receive_queue.lock);
>                if ((sk->sk_type =3D=3D SOCK_STREAM ||
>                    sk->sk_type =3D=3D SOCK_SEQPACKET) &&
>                    ioctl_code !=3D SIOCPSZ) {       //// have SIOCPSZ
> behave as for datagram sockets
>                        skb_queue_walk(&sk->sk_receive_queue, skb)
>                                amount +=3D skb->len;
>                } else {
>                        skb =3D skb_peek(&sk->sk_receive_queue);
>                        if (skb)
>                                amount =3D skb->len;
>                }
>                spin_unlock(&sk->sk_receive_queue.lock);
>                err =3D put_user(amount, (int __user *)arg);
>                break;
>        }

ioctl() are deprecated, and such a change has ramification (for example
on strace tool)

You could use a recvmsg( ... MSG_PEEK|MSG_TRUNC) to get size of next
packet (passing a small buffer)

Ah... it seems af_unix doesnt handle MSG_TRUNC semantic as
UDP/RAW/NETLINK sockets do.


diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 85d3bb7..70d9414 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1824,7 +1824,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb,=
 struct socket *sock,
 		if (UNIXCB(skb).fp)
 			siocb->scm->fp =3D scm_fp_dup(UNIXCB(skb).fp);
 	}
-	err =3D size;
+	err =3D (flags & MSG_TRUNC) ? skb->len : size;
=20
 	scm_recv(sock, msg, siocb->scm, flags);
=20
