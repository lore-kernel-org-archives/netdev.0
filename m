From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 09 Jan 2009 16:42:44 +0100
Message-ID: <49677074.5090802@cosmosbay.com>
References: <20090108173028.GA22531@1wt.eu>	<49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@zeus.com, w@1wt.eu, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:37896 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbZAIPnj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 10:43:39 -0500
In-Reply-To: <4966F2F4.9080901@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> I'm not applying this until someone explains to me why
>> we should remove this test from the splice receive but
>> keep it in the tcp_recvmsg() code where it has been
>> essentially forever.

Reading again tcp_recvmsg(), I found it already is able to eat several =
skb
even in nonblocking mode.

setsockopt(5, SOL_SOCKET, SO_RCVLOWAT, [61440], 4) =3D 0
ioctl(5, FIONBIO, [1])                  =3D 0
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, -1) =3D 1
recv(5, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 65=
536, MSG_DONTWAIT) =3D 65536
write(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 6=
5536) =3D 65536
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, -1) =3D 1
recv(5, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 65=
536, MSG_DONTWAIT) =3D 65536
write(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 6=
5536) =3D 65536
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, -1) =3D 1
recv(5, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 65=
536, MSG_DONTWAIT) =3D 65536
write(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 6=
5536) =3D 65536
poll([{fd=3D5, events=3DPOLLIN, revents=3DPOLLIN}], 1, -1) =3D 1
recv(5, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 65=
536, MSG_DONTWAIT) =3D 65536
write(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 6=
5536) =3D 65536


David, if you referred to code at line 1374 of net/ipv4/tcp.c, I believ=
e there is
no issue with it. We really want to break from this loop if !timeo .

Willy patch makes splice() behaving like tcp_recvmsg(), but we might ca=
ll
tcp_cleanup_rbuf() several times, with copied=3D1460 (for each frame pr=
ocessed)

I wonder if the right fix should be done in tcp_read_sock() : this is t=
he
one who should eat several skbs IMHO, if we want optimal ACK generation=
=2E

We break out of its loop at line 1246

if (!desc->count) /* this test is always true */
	break;

(__tcp_splice_read() set count to 0, right before calling tcp_read_sock=
())

So code at line 1246 (tcp_read_sock()) seems wrong, or pessimistic at l=
east.



