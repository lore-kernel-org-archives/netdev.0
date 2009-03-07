From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Sat, 07 Mar 2009 08:46:52 +0100
Message-ID: <49B2266C.9050701@cosmosbay.com>
References: <20090204012144.GC3650@localhost.localdomain>	<49A6CE39.5050200@athenacr.com>	<49A8FAFF.7060104@cosmosbay.com> <20090304.001646.100690134.davem@davemloft.net> <49AE3DA9.2020103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	cl@linux-foundation.org, Brian Bloniarz <bmb@athenacr.com>
To: kchang@athenacr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54071 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbZCGHrJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 02:47:09 -0500
In-Reply-To: <49AE3DA9.2020103@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Sat, 28 Feb 2009 09:51:11 +0100
>>
>>> David, this is a preliminary work, not meant for inclusion as is,
>>> comments are welcome.
>>>
>>> [PATCH] net: sk_forward_alloc becomes an atomic_t
>>>
>>> Commit 95766fff6b9a78d11fc2d3812dd035381690b55d
>>> (UDP: Add memory accounting) introduced a regression for high rate =
UDP flows,
>>> because of extra lock_sock() in udp_recvmsg()
>>>
>>> In order to reduce need for lock_sock() in UDP receive path, we mig=
ht need
>>> to declare sk_forward_alloc as an atomic_t.
>>>
>>> udp_recvmsg() can avoid a lock_sock()/release_sock() pair.
>>>
>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>> This adds new overhead for TCP which has to hold the socket
>> lock for other reasons in these paths.
>>
>> I don't get how an atomic_t operation is cheaper than a
>> lock_sock/release_sock.  Is it the case that in many
>> executions of these paths only atomic_read()'s are necessary?
>>
>> I actually think this scheme is racy.  There is a reason we
>> have to hold the socket lock when doing memory scheduling.
>> Two threads can get in there and say "hey I have enough space
>> already" even though only enough space is allocated for one
>> of their requests.
>>
>> What did I miss? :)
>>
>=20
> I believe you are right, and in fact was about to post a "dont look a=
t this patch"
> since it doesnt help the multicast reception at all, I redone tests m=
ore carefuly=20
> and got nothing but noise.
>=20
> We have a cache line ping pong mess here, and need more thinking.
>=20
> I rewrote Kenny prog to use non blocking sockets.
>=20
> Receivers are doing :
>=20
>         int delay =3D 50;
> 	fcntl(s, F_SETFL, O_NDELAY);
>         while(1)
>         {
>             struct sockaddr_in from;
>             socklen_t fromlen =3D sizeof(from);
>             res =3D recvfrom(s, buf, 1000, 0, (struct sockaddr*)&from=
, &fromlen);
>             if (res =3D=3D -1) {
>                       delay++;
>                       usleep(delay);
>                       continue;
>             }
>             if (delay > 40)
>                 delay--;
>             ++npackets;
>=20
> With this litle user space change and 8 receivers on my dual quad cor=
e, softirqd
> only takes 8% of one cpu and no drops at all (instead of 100% cpu and=
 30% drops)
>=20
> So this is definitly a problem mixing scheduler cache line ping pongs=
 with network
> stack cache line ping pongs.
>=20
> We could reorder fields so that fewer cache lines are touched by the =
softirq processing,
> I tried this but still got packet drops.
>=20
>=20
>=20

I have more questions :

What is the maximum latency you can afford on the delivery of the packe=
t(s) ?

Are user apps using real time scheduling ?

I had an idea, that keep cpu handling NIC interrupts only delivering pa=
ckets to
socket queues, and not messing with scheduler : fast queueing, and wake=
ing up
a workqueue (on another cpu) to perform the scheduler work. But that me=
ans
some extra latency (in the order of 2 or 3 us I guess)

We could enter in this mode automatically, if the NIC rx handler *see* =
more than
N packets are waiting in NIC queue : In case of moderate or light trafi=
c, no
extra latency would be necessary. This would mean some changes in NIC d=
river.

Hum, then, if NIC rx handler is run beside the ksoftirqd, we already kn=
ow
we are in a stress situation, so maybe no driver changes are necessary =
:
Just test if we run ksoftirqd...


