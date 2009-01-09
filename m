From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 09 Jan 2009 18:57:38 +0100
Message-ID: <49679012.3000702@cosmosbay.com>
References: <20090108173028.GA22531@1wt.eu>	<49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com> <49677074.5090802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@zeus.com, w@1wt.eu, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:38464 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbZAIR6c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 12:58:32 -0500
In-Reply-To: <49677074.5090802@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Eric Dumazet a =E9crit :
>> David Miller a =E9crit :
>>> I'm not applying this until someone explains to me why
>>> we should remove this test from the splice receive but
>>> keep it in the tcp_recvmsg() code where it has been
>>> essentially forever.
>=20
> Reading again tcp_recvmsg(), I found it already is able to eat severa=
l skb
> even in nonblocking mode.
>=20
> setsockopt(5, SOL_SOCKET, SO_RCVLOWAT, [61440], 4) =3D 0
> ioctl(5, FIONBIO, [1])                  =3D 0
> poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, -1) =3D 1
> recv(5, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., =
65536, MSG_DONTWAIT) =3D 65536
> write(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,=
 65536) =3D 65536
> poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, -1) =3D 1
> recv(5, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., =
65536, MSG_DONTWAIT) =3D 65536
> write(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,=
 65536) =3D 65536
> poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, -1) =3D 1
> recv(5, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., =
65536, MSG_DONTWAIT) =3D 65536
> write(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,=
 65536) =3D 65536
> poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, -1) =3D 1
> recv(5, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., =
65536, MSG_DONTWAIT) =3D 65536
> write(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,=
 65536) =3D 65536
>=20
>=20
> David, if you referred to code at line 1374 of net/ipv4/tcp.c, I beli=
eve there is
> no issue with it. We really want to break from this loop if !timeo .
>=20
> Willy patch makes splice() behaving like tcp_recvmsg(), but we might =
call
> tcp_cleanup_rbuf() several times, with copied=3D1460 (for each frame =
processed)
>=20
> I wonder if the right fix should be done in tcp_read_sock() : this is=
 the
> one who should eat several skbs IMHO, if we want optimal ACK generati=
on.
>=20
> We break out of its loop at line 1246
>=20
> if (!desc->count) /* this test is always true */
> 	break;
>=20
> (__tcp_splice_read() set count to 0, right before calling tcp_read_so=
ck())
>=20
> So code at line 1246 (tcp_read_sock()) seems wrong, or pessimistic at=
 least.

I tested following patch and got expected result :

- less ACK, and correct rcvbuf adjustments.
- I can fill the Gb link with one flow only, using less than
  10% of the cpu, instead of 40% without patch.

Setting desc->count to 1 seems to be the current practice.
(Example in drivers/scsi/iscsi_tcp.c : iscsi_sw_tcp_data_ready())

******************************************************************
* Note : this patch is wrong, because splice() can now           *
* return  more bytes than asked for (if SPLICE_F_NONBLOCK asked) *
******************************************************************

[PATCH] tcp: splice as many packets as possible at once

As spotted by Willy Tarreau, current splice() from tcp socket to pipe i=
s not
optimal. It processes at most one segment per call.
This results in low performance and very high overhead due to syscall r=
ate
when splicing from interfaces which do not support LRO.

Willy provided a patch inside tcp_splice_read(), but a better fix
is to let tcp_read_sock() process as many segments as possible, so
that tcp_rcv_space_adjust() and tcp_cleanup_rbuf() are called once
per syscall.

With this change, splice() behaves like tcp_recvmsg(), being able
to consume many skbs in one system call.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bd6ff90..15bd67b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -533,6 +533,9 @@ static int __tcp_splice_read(struct sock *sk, struc=
t tcp_splice_state *tss)
 		.arg.data =3D tss,
 	};
=20
+	if (tss->flags & SPLICE_F_NONBLOCK)
+		rd_desc.count =3D 1; /* we want as many segments as possible */
+
 	return tcp_read_sock(sk, &rd_desc, tcp_splice_data_recv);
 }
=20

