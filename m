From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Mon, 09 Mar 2009 07:36:57 +0100
Message-ID: <49B4B909.7050002@cosmosbay.com>
References: <49AE3DA9.2020103@cosmosbay.com>	<49B2266C.9050701@cosmosbay.com>	<49B3F655.6030308@cosmosbay.com> <20090308.194922.267426196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kchang@athenacr.com, netdev@vger.kernel.org,
	cl@linux-foundation.org, bmb@athenacr.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39179 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbZCIGhp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 02:37:45 -0400
In-Reply-To: <20090308.194922.267426196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sun, 08 Mar 2009 17:46:13 +0100
>=20
>> +	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep)) {
>> +		if (in_softirq()) {
>> +			if (!softirq_del(&sk->sk_del, sock_readable_defer))
>> +				goto unlock;
>> +			return;
>> +		}
>=20
> This is interesting.
>=20
> I think you should make softirq_del() more flexible.  Make it the
> socket's job to make sure it doesn't try to defer different
> functions, and put the onus on locking there as well.
>=20
> The cmpxchg() and all of this checking is just wasted work.
>=20
> I'd really like to get rid of that callback lock too, then we'd
> really be in business. :-)

=46irst thanks for your review David.

I chose cmpxchg() because I needed some form of exclusion here.
I first added a spinlock inside "struct softirq_del" then I realize
I could use cmpxchg() instead and keep the structure small. As the
synchronization is only needed at queueing time, we could pass
the address of a spinlock XXX to sofirq_del() call.

Also, when an event was queued for later invocation, I also needed to k=
eep
a reference on "struct socket" to make sure it doesnt disappear before
the invocation. Not all sockets are RCU guarded (we added RCU only for=20
some protocols (TCP, UDP ...). So I found keeping a read_lock
on callback was the easyest thing to do. I now realize we might
overflow preempt_count, so special care is needed.

About your first point, maybe we should make sofirq_del() (poor name I =
confess)
only have one argument (pointer to struct softirq_del), and initialize
the function pointer at socket init time. That would insure "struct sof=
tirq_del"
is associated to one callback only. cmpxchg() test would have to be
done on "next" field then (or use the spinlock XXX)

I am not sure output path needs such tricks, since threads are rarely
blocking on output : We dont trigger 400.000 wakeups per second ?

Another point : I did a tbench test and got 2517 MB/s with the patch,
instead of 2538 MB/s (using Linus 2.6 git tree), thats ~ 0.8 % regressi=
on
for this workload.

