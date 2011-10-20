From: Daniel Turull <daniel.turull@gmail.com>
Subject: Re: [patch] pktgen: bug when calling ndelay in x86 architectures
Date: Thu, 20 Oct 2011 15:22:59 +0200
Message-ID: <4EA020B3.4030208@gmail.com>
References: <4E9D5E1B.3080704@gmail.com>   <1318939007.2657.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <1318946401.23980.6.camel@deadeye>  <1318949264.2657.97.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E9E9963.7090209@gmail.com> <1319019235.3103.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Voravit Tanyingyong <voravit@kth.se>,
	Jens Laas <jens.laas@uadm.uu.se>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59609 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554Ab1JTNXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 09:23:04 -0400
Received: by bkbzt19 with SMTP id zt19so3541782bkb.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 06:23:02 -0700 (PDT)
In-Reply-To: <1319019235.3103.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I tested the patch and it works well.


On 10/19/2011 12:13 PM, Eric Dumazet wrote:
> Le mercredi 19 octobre 2011 =C3=A0 11:33 +0200, Daniel Turull a =C3=A9=
crit :
>> Hi,
>> then if we want to use the spin more often.
>> maybe we can increase the constant from 100000 (0.1ms) to 1000000 (1=
ms)?
>> How was the current value chosen?
>>
>=20
> Based on user needs ;)

I think if we increase the constant to 1ms, we will reduce the jitter i=
f we have
a rate between 1kpps and 10 kpps, but I guess is not a big deal.

I've plot this new graph with this patch:
http://tslab.ssvl.kth.se/pktgen/img/inter_eric1.eps

>=20
>> I did some measurements of the inter-arrival time between packets
>> and with bigger values the maximal is reduced in the rates between
>> 2kpps and 20kpps.
>>
>=20
> ndelay()/udelay() have some inaccuracies, for 'long' values, because =
of
> rounding errors.
>=20
> If we spin, just call ktime_now() in a loop until spin_until is
> reached...
>=20
> That way you get max possible resolution, given kernel time service
> constraints.
>=20
> Untested patch :
>=20
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 38d6577..5c7e900 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -2145,9 +2145,11 @@ static void spin(struct pktgen_dev *pkt_dev, k=
time_t spin_until)
>  	}
> =20
>  	start_time =3D ktime_now();
> -	if (remaining < 100000)
> -		ndelay(remaining);	/* really small just spin */
> -	else {
> +	if (remaining < 100000) {
> +		do {
> +			end_time =3D ktime_now();
> +		} while (ktime_lt(end_time, spin_until));
> +	} else {
>  		/* see do_nanosleep */
>  		hrtimer_init_sleeper(&t, current);
>  		do {
> @@ -2162,8 +2164,8 @@ static void spin(struct pktgen_dev *pkt_dev, kt=
ime_t spin_until)
>  			hrtimer_cancel(&t.timer);
>  		} while (t.task && pkt_dev->running && !signal_pending(current));
>  		__set_current_state(TASK_RUNNING);
> +		end_time =3D ktime_now();
>  	}
> -	end_time =3D ktime_now();
> =20
>  	pkt_dev->idle_acc +=3D ktime_to_ns(ktime_sub(end_time, start_time))=
;
>  	pkt_dev->next_tx =3D ktime_add_ns(spin_until, pkt_dev->delay);
>=20
>=20

Daniel
