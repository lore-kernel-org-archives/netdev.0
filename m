From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : rt_check_expire() can take a long time, add a cond_resched()
Date: Thu, 15 Nov 2007 09:25:59 +0100
Message-ID: <473C0297.5090004@cosmosbay.com>
References: <473B69D5.2050805@cosmosbay.com> <p73r6isc6ev.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:42084 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757336AbXKOI0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 03:26:11 -0500
In-Reply-To: <p73r6isc6ev.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen a =E9crit :
> Eric Dumazet <dada1@cosmosbay.com> writes:
>> Using a "if (need_resched())" test before calling "cond_resched();" =
is
>> necessary to avoid spending too much time doing the resched check.
>=20
> The only difference between cond_resched() and if (need_resched())
> cond_resched() is one function call less and one might_sleep less. If
> the might_sleep or the function call are really problems (did you
> measure it? -- i doubt it somewhat) then it would be better to fix th=
e
> generic code to either inline that or supply a __cond_resched()
> without might_sleep.

Please note that :

if (need_resched())
     cond_resched();

will re-test need_resched() once cond_resched() is called.

So it may sound unnecessary but in the rt_check_expire() case, with a l=
oop=20
potentially doing XXX.XXX iterations, being able to bypass the function=
 call=20
is a clear win (in my bench case, 25 ms instead of 88 ms). Impact on I-=
cache=20
is irrelevant here as this rt_check_expires() runs once every 60 sec.

I think the actual cond_resched() is fine for other uses in the kernel,=
 that=20
are not used in a loop : In the general case, kernel text size should b=
e as=20
small as possible to reduce I-cache pressure, so a function call is bet=
ter=20
than an inline.

>=20
> A cheaper change might have been to just limit the number of buckets
> scanned.
>=20

Well, not in some particular cases, when there are 3 millions of routes=
 for=20
example in the cache. We really want to scan/free them eventually :)

An admin already has the possibility to tune=20
/proc/sys/net/ipv4/route/gc_interval and /proc/sys/net/ipv4/route/gc_ti=
meout,=20
so on a big cache, it will probably set gc_interval to 1 instead of 60

Next step will be to move "ip route flush cache" and rt_secret_rebuild(=
)=20
handling from softirq to process context too, since this still can kill=
 a machine.

