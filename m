From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Multicast packet loss
Date: Tue, 17 Mar 2009 12:08:48 +0100
Message-ID: <49BF84C0.2000808@cosmosbay.com>
References: <49B4B909.7050002@cosmosbay.com>	 <20090313.145152.121603300.davem@davemloft.net>	 <49BADE87.40407@cosmosbay.com>	 <20090313.153851.11725991.davem@davemloft.net>	 <49BED109.3020504@cosmosbay.com> <1237284716.5189.284.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kchang@athenacr.com,
	netdev@vger.kernel.org, cl@linux-foundation.org, bmb@athenacr.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41689 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498AbZCQLNF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 07:13:05 -0400
In-Reply-To: <1237284716.5189.284.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra a =E9crit :
> On Mon, 2009-03-16 at 23:22 +0100, Eric Dumazet wrote:
>=20
>> Here is the last incantation of the patch, that of course should be
>> split in two parts and better Changelog for further discussion on lk=
ml.
>=20
> I read the entire thread up to now, and I still don't really understa=
nd
> the Changelog, sorry :(

Sure, I should have taken more time, will repost this in a couple of ho=
urs,
with nice CHangelogs and split patches.

>=20
>> [PATCH] softirq: Introduce mechanism to defer wakeups
>>
>> Some network workloads need to call scheduler too many times. For ex=
ample,
>> each received multicast frame can wakeup many threads. ksoftirqd is =
then
>> not able to drain NIC RX queues in time and we get frame losses and =
high
>> latencies.
>>
>> This patch adds an infrastructure to delay work done in
>> sock_def_readable() at end of do_softirq(). This needs to
>> make available current->softirq_context even if !CONFIG_TRACE_IRQFLA=
GS
>=20
> How does that solve the wakeup issue?

Apparently, on SMP machines this actually helps a lot, in case of multi=
cast
trafic handled by many subscribers. skb_cloning involves atomic ops on
route cache entries, and if we wakeup threads as we currently do, they
start to consume skb while the feeder is still doing skb clones for
other sockets. Many cache line ping pongs are slowing down the softirq.

I will post the test program to reproduce the problem.

>=20
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>> ---
>=20
>> --- a/kernel/softirq.c
>> +++ b/kernel/softirq.c
>> @@ -158,6 +158,42 @@ void local_bh_enable_ip(unsigned long ip)
>>  }
>>  EXPORT_SYMBOL(local_bh_enable_ip);
>> =20
>> +
>> +#define SOFTIRQ_DELAY_END (struct softirq_delay *)1L
>> +static DEFINE_PER_CPU(struct softirq_delay *, softirq_delay_head) =3D=
 {
>> +	SOFTIRQ_DELAY_END
>> +};
>=20
> Why the magic termination value? Can't we NULL terminate the list

Yes we can, you are right.

>=20
>> +
>> +/*
>> + * Caller must disable preemption, and take care of appropriate
>> + * locking and refcounting
>> + */
>=20
> Shouldn't we call it __softirq_delay_queue() if the caller needs to
> disabled preemption?

I was wondering if some BUG_ON() can be added to crash if preemption is=
 enabled
at this point. Could not find an existing check,
doing again the 'if (running_from_softirq())'" test might be overkill,
should I document caller should do :

skeleton :

    lock_my_data(data); /* barrier here */
    sdel =3D &data->sdel;
    if (running_from_softirq()) {
	if (softirq_delay_queue(sdel)) {
		hold a refcount on data;
	} else {
		/* already queued, nothing to do */
	}
    } else {
	/* cannot queue the work , must do it right now */
	do_work(data);
    }
    release_my_data(data);
}

>=20
> Futhermore, don't we always require the caller to take care of lifeti=
me
> issues when we queue something?

You mean comment is too verbose... or=20

>=20
>> +int softirq_delay_queue(struct softirq_delay *sdel)
>> +{
>> +	if (!sdel->next) {
>> +		sdel->next =3D __get_cpu_var(softirq_delay_head);
>> +		__get_cpu_var(softirq_delay_head) =3D sdel;
>> +		return 1;
>> +	}
>> +	return 0;
>> +}
>> +
>> +/*
>> + * Because locking is provided by subsystem, please note
>> + * that sdel->func(sdel) is responsible for setting sdel->next to N=
ULL
>> + */
>> +static void softirq_delay_exec(void)
>> +{
>> +	struct softirq_delay *sdel;
>> +
>> +	while ((sdel =3D __get_cpu_var(softirq_delay_head)) !=3D SOFTIRQ_D=
ELAY_END) {
>> +		__get_cpu_var(softirq_delay_head) =3D sdel->next;
>> +		sdel->func(sdel);	/*	sdel->next =3D NULL;*/
>> +		}
>> +}
>=20
> Why can't we write:
>=20
>   struct softirq_delay *sdel, *next;
>=20
>   sdel =3D __get_cpu_var(softirq_delay_head);
>   __get_cpu_var(softirq_delay_head) =3D NULL;
>=20
>   while (sdel) {
>     next =3D sdel->next;
>     sdel->func(sdel);
>     sdel =3D next;
>   }
>=20
> Why does it matter what happens to sdel->next? we've done the callbac=
k.
>=20
> Aah, the crux is in the re-use policy.. that most certainly does dese=
rve
> a comment.

Hum, so my comment was not verbose enough :)

>=20
> How about we make sdel->next point to itself in the init case?
>=20
> Then we can write:
>=20
>   while (sdel) {
>     next =3D sdel->next;
>     sdel->next =3D sdel;
>     sdel->func(sdel);
>     sdel =3D next;
>   }
>=20
> and have the enqueue bit look like:
>=20
> int __softirq_delay_queue(struct softirq_delay *sdel)
> {
>   struct softirq_delay **head;
>=20
>   if (sdel->next !=3D sdel)
>     return 0;

Yes we could do that

>=20
>   head =3D &__get_cpu_var(softirq_delay_head);
>   sdel->next =3D *head;
>   *head =3D sdel;
>   return 1;
> }
>     =20
>> @@ -1691,6 +1694,43 @@ static void sock_def_readable(struct sock *sk=
, int len)
>>  	read_unlock(&sk->sk_callback_lock);
>>  }
>> =20
>> +/*
>> + * helper function called by softirq_delay_exec(),
>> + * if inet_def_readable() queued us.
>> + */
>> +static void sock_readable_defer(struct softirq_delay *sdel)
>> +{
>> +	struct sock *sk =3D container_of(sdel, struct sock, sk_delay);
>> +
>> +	sdel->next =3D NULL;
>> +	/*
>> +	 * At this point, we dont own a lock on socket, only a reference.
>> +	 * We must commit above write, or another cpu could miss a wakeup
>> +	 */
>> +	smp_wmb();
>=20
> Where's the matching barrier?

Check softirq_delay_exec(void) comment, where I stated synchronization =
had
to be done by the subsystem.

In this socket case, caller of softirq_delay_exec() has a lock on socke=
t.

Problem is I dont want to get this lock again in sock_readable_defer() =
callback

if sdel->next is not committed, another cpu could call _softirq_delay_q=
ueue() and
find sdel->next being not null (or !=3D sdel with your suggestion). The=
n next->func()
wont be called as it should (or called litle bit too soon)

So matching barrier is on "lock_my_data(data)" in previous skeleton ?

>=20
>> +	sock_def_readable(sk, 0);
>> +	sock_put(sk);
>> +}
>> +
>> +/*
>> + * Custom version of sock_def_readable()
>> + * We want to defer scheduler processing at the end of do_softirq()
>> + * Called with socket locked.
>> + */
>> +void inet_def_readable(struct sock *sk, int len)
>> +{
>> +	if (running_from_softirq()) {
>> +		if (softirq_delay_queue(&sk->sk_delay))
>> +			/*
>> +			 * If we queued this socket, take a reference on it
>> +			 * Caller owns socket lock, so write to sk_delay.next
>> +			 * will be committed before unlock.
>> +			 */
>> +			sock_hold(sk);
>> +	} else
>> +		sock_def_readable(sk, len);
>> +}
>=20
> OK, so the idea is to handle a bunch of packets and instead of waking=
 N
> threads for each packet, only wake them once at the end of the batch?
>=20
> Sounds like a sensible idea..=20

Idea is to batch wakeups() yes, and if we receive several packets for
the same socket(s), we reduce number of wakeups to one. In the multicas=
t stress
situation of Athena CR, it really helps, no packets dropped instead of
30%

Thanks Peter

