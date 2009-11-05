From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: set SPLICE_F_NONBLOCK after first buffer has been
 spliced
Date: Thu, 05 Nov 2009 15:11:45 +0100
Message-ID: <4AF2DD21.8060604@gmail.com>
References: <20091105095947.32131.99768.stgit@rabbit.intern.cm-ag> <4AF2A929.3000201@gmail.com> <20091105105749.GA4901@rabbit.intern.cm-ag> <4AF2B551.6010302@gmail.com> <20091105132352.GA14453@rabbit.intern.cm-ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, jens.axboe@oracle.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: Max Kellermann <mk@cm4all.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56594 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756205AbZKEOLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 09:11:54 -0500
In-Reply-To: <20091105132352.GA14453@rabbit.intern.cm-ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Max Kellermann a =E9crit :
> On 2009/11/05 12:21, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Max Kellermann a =E9crit :
>>> Do you think that a splice() should block if the socket is readable
>>> and the pipe is writable according to select()?
>>>
>> Yes, this is perfectly legal
>>
>> select() can return "OK to write on fd",
>> and still, write(fd, buffer, 10000000) is supposer/allowed to block =
if fd is not O_NDELAY
>=20
>>From the select() manpage: "those in writefds will be watched to see
> if a write will not block"
>=20
>>From the poll() manpage: "Writing now will not block."
>=20
> This looks unambiguous to me, and contradicts with your thesis.  Can
> you provide sources?
>=20
> What is your interpretation of the guarantees provided by select() an=
d
> poll()?  Which byte count is "ok" to write after POLLOUT, and how muc=
h
> is "too much"?  How does the application know?

It cannot, therefore an application uses O_NDELAY to avoid blocking.

Try following program if you are not convinced

#include <unistd.h>
#include <sys/poll.h>
#include <stdio.h>

char buffer[1000000];

int main(int argc, char *argv[])
{
	int fds[2];
	struct pollfd pfd;
	int res;
=09
	pipe(fds);
	pfd.fd =3D fds[1];
	pfd.events =3D POLLOUT;
	res =3D poll(&pfd, 1, -1);
	if (res > 0 && pfd.revents & POLLOUT)
		printf("OK to write on pipe\n");
	write(fds[1], buffer, sizeof(buffer)); // why it blocks, did poll() li=
ed ???
	return 0;
}



> I understand your patch, but I don't understand the conflict with my
> patch.  Can you describe a breakage caused by my patch?

I only pointed out that using splice(tcp -> pipe) and blocking on pipe
_can_ block, even on _first_ frame received from tcp, as you discovered=
=2E


Your only choices to avoid a deadlock are :
1) to use SPLICE_F_NONBLOCK.
2) Using a second thread to read the pipe and empty it. First thread wi=
ll
   happily transfert 1000000 bytes in one syscall...
3) or limit your splice(... len, flags) length to 16 (16 buffers of one=
 byte
   in pathological cases)

Your patch basically makes SPLICE_F_NONBLOCK option always set (choice =
1) above)

So users wanting option 3) are stuck. You force them to use a poll()/se=
lect()
thing while they dont want to poll : They have a producer thread(s), an=
d a consumer
thread(s).

producer()
{
	while (1)
		splice(tcp, &offset, pfds[1], NULL, 10000000,
		       SPLICE_F_MORE | SPLICE_F_MOVE);
}

Why in the first place have an option if it is always set ?
