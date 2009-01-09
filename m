From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 09 Jan 2009 07:47:16 +0100
Message-ID: <4966F2F4.9080901@cosmosbay.com>
References: <20090108173028.GA22531@1wt.eu>	<49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@zeus.com, w@1wt.eu, jarkao2@gmail.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:41922 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbZAIGsJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 01:48:09 -0500
In-Reply-To: <20090108.135515.85489589.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Ben Mansell <ben@zeus.com>
> Date: Thu, 08 Jan 2009 21:50:44 +0000
>=20
>>> From fafe76713523c8e9767805cfdc7b73323d7bf180 Mon Sep 17 00:00:00 2=
001
>>> From: Willy Tarreau <w@1wt.eu>
>>> Date: Thu, 8 Jan 2009 17:10:13 +0100
>>> Subject: [PATCH] tcp: splice as many packets as possible at once
>>> Currently, in non-blocking mode, tcp_splice_read() returns after
>>> splicing one segment regardless of the len argument. This results
>>> in low performance and very high overhead due to syscall rate when
>>> splicing from interfaces which do not support LRO.
>>> The fix simply consists in not breaking out of the loop after the
>>> first read. That way, we can read up to the size requested by the
>>> caller and still return when there is no data left.
>>> Performance has significantly improved with this fix, with the
>>> number of calls to splice() divided by about 20, and CPU usage
>>> dropped from 100% to 75%.
>>>
>> I get similar results with my testing here. Benchmarking an applicat=
ion with this patch shows that more than one packet is being splice()d =
in at once, as a result I see a doubling in throughput.
>>
>> Tested-by: Ben Mansell <ben@zeus.com>
>=20
> I'm not applying this until someone explains to me why
> we should remove this test from the splice receive but
> keep it in the tcp_recvmsg() code where it has been
> essentially forever.

I found this patch usefull in my testings, but had a feeling something
was not complete. If the goal is to reduce number of splice() calls,
we also should reduce number of wakeups. If splice() is used in non
blocking mode, nothing we can do here of course, since the application
will use a poll()/select()/epoll() event before calling splice(). A
good setting of SO_RCVLOWAT to (16*PAGE_SIZE)/2 might improve things.

I tested this on current tree and it is not working : we still have
one wakeup for each frame (ethernet link is a 100 Mb/s one)

bind(6, {sa_family=3DAF_INET, sin_port=3Dhtons(4711), sin_addr=3Dinet_a=
ddr("0.0.0.0")}, 16) =3D 0
listen(6, 5)                            =3D 0
accept(6, 0, NULL)                      =3D 7
setsockopt(7, SOL_SOCKET, SO_RCVLOWAT, [32768], 4) =3D 0
poll([{fd=3D7, events=3DPOLLIN, revents=3DPOLLIN|POLLERR|POLLHUP}], 1, =
-1) =3D 1
splice(0x7, 0, 0x4, 0, 0x10000, 0x3)    =3D 1024
splice(0x3, 0, 0x5, 0, 0x400, 0x5)      =3D 1024
poll([{fd=3D7, events=3DPOLLIN, revents=3DPOLLIN|POLLERR|POLLHUP}], 1, =
-1) =3D 1
splice(0x7, 0, 0x4, 0, 0x10000, 0x3)    =3D 1460
splice(0x3, 0, 0x5, 0, 0x5b4, 0x5)      =3D 1460
poll([{fd=3D7, events=3DPOLLIN, revents=3DPOLLIN|POLLERR|POLLHUP}], 1, =
-1) =3D 1
splice(0x7, 0, 0x4, 0, 0x10000, 0x3)    =3D 1460
splice(0x3, 0, 0x5, 0, 0x5b4, 0x5)      =3D 1460
poll([{fd=3D7, events=3DPOLLIN, revents=3DPOLLIN|POLLERR|POLLHUP}], 1, =
-1) =3D 1
splice(0x7, 0, 0x4, 0, 0x10000, 0x3)    =3D 1460
splice(0x3, 0, 0x5, 0, 0x5b4, 0x5)      =3D 1460
poll([{fd=3D7, events=3DPOLLIN, revents=3DPOLLIN|POLLERR|POLLHUP}], 1, =
-1) =3D 1
splice(0x7, 0, 0x4, 0, 0x10000, 0x3)    =3D 1460
splice(0x3, 0, 0x5, 0, 0x5b4, 0x5)      =3D 1460
poll([{fd=3D7, events=3DPOLLIN, revents=3DPOLLIN|POLLERR|POLLHUP}], 1, =
-1) =3D 1
splice(0x7, 0, 0x4, 0, 0x10000, 0x3)    =3D 1460
splice(0x3, 0, 0x5, 0, 0x5b4, 0x5)      =3D 1460


About tcp_recvmsg(), we might also remove the "!timeo" test as well,
more testings are needed. But remind that if an application provides
a large buffer to tcp_recvmsg() call, removing the test will reduce
the number of syscalls but might use more DCACHE. It could reduce
performance on old cpus. With splice() call, we expect to not
copy memory and trash DCACHE, and pipe buffers being limited to 16,
we cope with a limited working set.=20



