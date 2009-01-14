From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: maximum buffer size for splice(2) tcp->pipe?
Date: Wed, 14 Jan 2009 11:17:57 +0100
Message-ID: <496DBBD5.7080109@cosmosbay.com>
References: <E1LKrp3-004Tub-IR@intern.SerNet.DE> <20090113123702.ad29cd13.akpm@linux-foundation.org> <496D2078.9080302@cosmosbay.com> <E1LN0MC-00DaJs-M2@intern.SerNet.DE> <496DACBE.3030701@cosmosbay.com> <E1LN2Vu-00DluN-6Z@intern.SerNet.DE>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Steven French <sfrench@us.ibm.com>,
	Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org
To: Volker.Lendecke@SerNet.DE
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54281 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbZANKSt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 05:18:49 -0500
In-Reply-To: <E1LN2Vu-00DluN-6Z@intern.SerNet.DE>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Volker Lendecke a =E9crit :
> On Wed, Jan 14, 2009 at 10:13:34AM +0100, Eric Dumazet wrote:
>> for (;;) {
>> 	struct pollfd pfd;
>> 	pfd.fd =3D socket;
>> 	pfd.events =3D POLLIN;
>> 	if (poll(&pfd, 1, -1) !=3D 1)
>> 		continue;
>> 	res =3D splice(socket, NULL, pipefds[1], NULL, 65536, SPLICE_F_MOVE=
|SPLICE_F_NONBLOCK);
>> 	if (res > 0)
>> 		nwritten =3D splice(pipefds[0], NULL, file_fd, NULL, res, SPLICE_F=
_MOVE|SPLICE_F_MORE);
>> }
>=20
> Doesn't this reduce performance again? I thought the whole
> point of splice() was to increase performance by avoiding
> memory copies. If I have to do a poll syscall for each call
> to splice, doesn't the context switch eat that performance
> advantage again?
>=20
> Or was splice designed only for multi-threaded applications
> (which at least Samba is not)?
>=20
> Volker

splice() avoids memory copies yes, but on typical 1460 bytes
frames its a small gain.

But if no data is available on socket,
you still have to wait (and have a context switch later).

Waiting in poll() or splice() has same context switch cost.

Only cost is the extra syscall of course, but it is mandatory
if you want to avoid a possible deadlock in current splice()
implementation.

