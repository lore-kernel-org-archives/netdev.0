From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: reduce number of reference taken on sk_refcnt
Date: Thu, 21 May 2009 11:07:19 +0200
Message-ID: <4A1519C7.3090901@cosmosbay.com>
References: <4A067D9E.7050706@cosmosbay.com>	<4A0685A0.8020002@cosmosbay.com>	<4A06B064.9080801@cosmosbay.com> <20090518.215823.98238538.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, satoru.satoh@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56996 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbZEUJHj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 05:07:39 -0400
In-Reply-To: <20090518.215823.98238538.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sun, 10 May 2009 12:45:56 +0200
>=20
>> Patch follows for RFC only (not Signed-of...), and based on net-next=
-2.6=20
>=20
> Thanks for the analysis.
>=20
>> @@ -922,10 +922,13 @@ static inline int tcp_prequeue(struct sock *sk=
, struct sk_buff *skb)
>>  	} else if (skb_queue_len(&tp->ucopy.prequeue) =3D=3D 1) {
>>  		wake_up_interruptible_poll(sk->sk_sleep,
>>  					   POLLIN | POLLRDNORM | POLLRDBAND);
>> -		if (!inet_csk_ack_scheduled(sk))
>> +		if (!inet_csk_ack_scheduled(sk)) {
>> +			unsigned int delay =3D (3 * tcp_rto_min(sk)) / 4;
>> +
>> +			delay =3D min(inet_csk(sk)->icsk_ack.ato, delay);
>>  			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
>> -						  (3 * tcp_rto_min(sk)) / 4,
>> -						  TCP_RTO_MAX);
>> +						  delay, TCP_RTO_MAX);
>> +		}
>>  	}
>>  	return 1;
>=20
> I think this code is trying to aggressively stretch the ACK when
> prequeueing.  In order to make sure there is enough time to get
> the process on the CPU and send a response, and thus piggyback
> the ACK.
>=20
> If that turns out not to really matter, or matter less than your
> problem, then we can make your change and I'm all for it.

This change gave me about 15% increase in bandwidth in a multiflow
tcp benchmark. But this optimization worked because tasks could be
wakeup and send their answer in the same jiffies, and 'rearming'
the xmit timer with the same value...

(135.000 messages received/sent per second in my benchmark, with 60 flo=
ws)

mod_timer() has special heuristic to avoid calling __mod_timer()

int mod_timer(struct timer_list *timer, unsigned long expires)
{
        /*
         * This is a common optimization triggered by the
         * networking code - if the timer is re-modified
         * to be the same thing then just return:
         */
        if (timer->expires =3D=3D expires && timer_pending(timer))
                return 1;

        return __mod_timer(timer, expires, false);
}

with HZ=3D1000, and real applications (using more than 1 msec to proces=
s the request),
I suppose this kind of optimization is unlikely to happen,
so we might extend mod_timer() heuristic to avoid changing timer->expir=
es
if the new value is almost the same than previous, and not "exactly the=
 same value"

int mod_timer_unexact(struct timer_list *timer, unsigned long expires, =
long maxerror)
{
        /*
         * This is a common optimization triggered by the
         * networking code - if the timer is re-modified
         * to be about the same thing then just return:
         */
        if (timer_pending(timer)) {
		long delta =3D expires - timer->expires;

		if (delta <=3D maxerror && delta >=3D -maxerror)
	                return 1;
	}
        return __mod_timer(timer, expires, false);
}



But to be effective, prequeue needs a blocked task
for each flow, and modern daemons prefer to use poll/epoll and
prequeue is thus not used.

Another possibility would be to use a different timer for prequeue=20
exclusive use instead of sharing xmit_timer.



