From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 09 Jan 2009 08:28:09 +0100
Message-ID: <4966FC89.8040006@cosmosbay.com>
References: <20090108173028.GA22531@1wt.eu> <49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com> <20090109070415.GA27758@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44118 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbZAIH2x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 02:28:53 -0500
In-Reply-To: <20090109070415.GA27758@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau a =E9crit :
> On Fri, Jan 09, 2009 at 07:47:16AM +0100, Eric Dumazet wrote:
>>> I'm not applying this until someone explains to me why
>>> we should remove this test from the splice receive but
>>> keep it in the tcp_recvmsg() code where it has been
>>> essentially forever.
>> I found this patch usefull in my testings, but had a feeling somethi=
ng
>> was not complete. If the goal is to reduce number of splice() calls,
>> we also should reduce number of wakeups. If splice() is used in non
>> blocking mode, nothing we can do here of course, since the applicati=
on
>> will use a poll()/select()/epoll() event before calling splice(). A
>> good setting of SO_RCVLOWAT to (16*PAGE_SIZE)/2 might improve things=
=2E
>>
>> I tested this on current tree and it is not working : we still have
>> one wakeup for each frame (ethernet link is a 100 Mb/s one)
>=20
> Well, it simply means that data are not coming in fast enough compare=
d to
> the tiny amount of work you have to perform to forward them, there's =
nothing
> wrong with that. It is important in my opinion not to wait for *enoug=
h* data
> to come in, otherwise it might become impossible to forward small chu=
nks.
> I mean, if there are only 300 bytes left to forward, we must not wait
> indefinitely for more data to come, we must forward those 300 bytes.
>=20
> In your case below, it simply means that the performance improvement =
brought
> by splice will be really minor because you'll just avoid 2 memory cop=
ies,
> which are ridiculously cheap at 100 Mbps. If you would change your pr=
ogram
> to use recv/send, you would observe the exact same pattern, because a=
s soon
> as poll() wakes you up, you still only have one frame in the system b=
uffers.
> On a small machine I have here (geode 500 MHz), I easily have multipl=
e
> frames queued at 100 Mbps because when epoll() wakes me up, I have tr=
affic
> on something like 10-100 sockets, and by the time I process the first=
 ones,
> the later have time to queue up more data.

My point is to use Gigabit links or 10Gb links and hundred or thousand =
of flows :)

But if it doesnt work on a single flow, it wont work on many :)

I tried my test program with a Gb link, one flow, and got splice() call=
s returns 23000 bytes
in average, using a litle too much of CPU : If poll() could wait a litl=
e bit more, CPU
could be available for other tasks.

If the application uses setsockopt(sock, SOL_SOCKET, SO_RCVLOWAT, [3276=
8], 4), it
would be good if kernel was smart enough and could reduce number of wak=
eups.

(Next blocking point is the fixed limit of 16 pages per pipe, but thats=
 another story)

>=20
>> About tcp_recvmsg(), we might also remove the "!timeo" test as well,
>> more testings are needed.
>=20
> No right now we can't (we must move it somewhere else at least). Beca=
use
> once at least one byte has been received (copied !=3D 0), no other ch=
eck
> will break out of the loop (or at least I have not found it).
>=20

Of course we cant remove the test totally, but change the logic so that=
 several skb
might be used/consumed per tcp_recvmsg() call, like your patch did for =
splice()

Lets focus on functional changes, not on implementation details :)


