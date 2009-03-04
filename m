From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Wed, 04 Mar 2009 09:36:57 +0100
Message-ID: <49AE3DA9.2020103@cosmosbay.com>
References: <20090204012144.GC3650@localhost.localdomain>	<49A6CE39.5050200@athenacr.com>	<49A8FAFF.7060104@cosmosbay.com> <20090304.001646.100690134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kchang@athenacr.com, netdev@vger.kernel.org,
	cl@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59281 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbZCDIhj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 03:37:39 -0500
In-Reply-To: <20090304.001646.100690134.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sat, 28 Feb 2009 09:51:11 +0100
>=20
>> David, this is a preliminary work, not meant for inclusion as is,
>> comments are welcome.
>>
>> [PATCH] net: sk_forward_alloc becomes an atomic_t
>>
>> Commit 95766fff6b9a78d11fc2d3812dd035381690b55d
>> (UDP: Add memory accounting) introduced a regression for high rate U=
DP flows,
>> because of extra lock_sock() in udp_recvmsg()
>>
>> In order to reduce need for lock_sock() in UDP receive path, we migh=
t need
>> to declare sk_forward_alloc as an atomic_t.
>>
>> udp_recvmsg() can avoid a lock_sock()/release_sock() pair.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> This adds new overhead for TCP which has to hold the socket
> lock for other reasons in these paths.
>=20
> I don't get how an atomic_t operation is cheaper than a
> lock_sock/release_sock.  Is it the case that in many
> executions of these paths only atomic_read()'s are necessary?
>=20
> I actually think this scheme is racy.  There is a reason we
> have to hold the socket lock when doing memory scheduling.
> Two threads can get in there and say "hey I have enough space
> already" even though only enough space is allocated for one
> of their requests.
>=20
> What did I miss? :)
>=20

I believe you are right, and in fact was about to post a "dont look at =
this patch"
since it doesnt help the multicast reception at all, I redone tests mor=
e carefuly=20
and got nothing but noise.

We have a cache line ping pong mess here, and need more thinking.

I rewrote Kenny prog to use non blocking sockets.

Receivers are doing :

        int delay =3D 50;
	fcntl(s, F_SETFL, O_NDELAY);
        while(1)
        {
            struct sockaddr_in from;
            socklen_t fromlen =3D sizeof(from);
            res =3D recvfrom(s, buf, 1000, 0, (struct sockaddr*)&from, =
&fromlen);
            if (res =3D=3D -1) {
                      delay++;
                      usleep(delay);
                      continue;
            }
            if (delay > 40)
                delay--;
            ++npackets;

With this litle user space change and 8 receivers on my dual quad core,=
 softirqd
only takes 8% of one cpu and no drops at all (instead of 100% cpu and 3=
0% drops)

So this is definitly a problem mixing scheduler cache line ping pongs w=
ith network
stack cache line ping pongs.

We could reorder fields so that fewer cache lines are touched by the so=
ftirq processing,
I tried this but still got packet drops.


