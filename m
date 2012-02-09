From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: 3.0: unexpected route cache entry for wrong segment?
Date: Thu, 09 Feb 2012 22:37:55 +0400
Message-ID: <4F341283.1020904@msgid.tls.msk.ru>
References: <4F33FC0E.4020701@msgid.tls.msk.ru> <1328809519.6099.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:51571 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754136Ab2BISh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 13:37:59 -0500
In-Reply-To: <1328809519.6099.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.02.2012 21:45, Eric Dumazet wrote:
> Le jeudi 09 f=C3=A9vrier 2012 =C3=A0 21:02 +0400, Michael Tokarev a =C3=
=A9crit :
[]
>> The issue however is that, in our case, I can't reproduce
>> this problem at all using the way described by Ivan Zahariev
>> in the last message: sending redirects from the geateay for
>> "random" addresses does not make corresponding "persistent"
>> cache entries, once the route on the gw gets removed, that
>> IP address starts working again from the machine in question.
>>
>> So now we have only one IP address that behaves like this,
>> and I can't get other addresses to repeat its behavour.
>>
>> The problem appeared suddenly, while the network was in
>> use.
>>
>> What is also interesting here is that the gateway should
>> never send a redirect like that because it has explicit
>> route for that network pointing to entirely different
>> machine.
[]
>> What is also very interesting is that this problem with
>> this single IP address affects ALL lxc machines on this
>> host at once, and the host itself:
>>
>>  host$ ip neigh
>>  192.168.177.35 dev tls-br lladdr 6c:f0:49:9d:f2:0c STALE
>>  192.168.19.166 dev tls-br  FAILED
>>  192.168.177.38 dev tls-br lladdr 38:60:77:25:3f:9c STALE
>>  192.168.177.5 dev tls-br lladdr 00:90:27:30:6d:1c DELAY
>>  ...
>>
>> (after trying to ping it).
>>
>> Each "subdivision" on this host has its own arp table, but
>> every subdivision (host itself or any of it lxc guests which
>> all have similar config) always tries to reach thiis very
>> IP address directly.
>>
>>  otherLXCguest$ ip n
>>  192.168.19.166 dev eth0  INCOMPLETE
>>  192.168.177.15 dev eth0 lladdr 00:1f:c6:ef:e5:1b STALE
>>  192.168.177.5 dev eth0 lladdr 00:90:27:30:6d:1c DELAY
>>
>> So.. it looks like something does not work right across
>> namespaces.
>>
>> Any clue what's going on?
>>
>> Thank you!
>=20
> Did you try to apply by hand commits :
>=20
> 7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae   // added in 3.2
> (route: fix ICMP redirect validation)
>=20
> and
> 9cc20b268a5a14f5e57b8ad405a83513ab0d78dc
> (ipv4: fix redirect handling)

I haven't tried anything yet, as mentioned above: this prob
just appeared today, out of the sudden, and what's the most
important (imho) is that I can not reproduce it.  The host
hasn't been rebooted, I were thinking about maybe some
experiments with it before doing anything else.

But I blocked this specific IP address on the gateway and the
cached entry expired after 10 minutes (that host tried to
check mail every minute so no doubt the inactivity timer
never triggered).  So at least one difference in behavour is
now gone.

What bothers me more are 3 other issues I see around this:

1. Why this specific IP were cached to start with?  I don't
  expect any ICMP redirects for that network at all, and no
  spoofing or malicious traffic either.

2. I can't reproduce the issue while forcing ICMP redirects.
 Maybe my original prob was not due to a redirect but due to
 something else?  I dunno.

3. Why it affects whole host and all numerous different/separate
 network namespaces on it?  _All_ lxc containers started thinking
 this IP is reachable on the local subnet, at once, even those
 who never ever tried to send any packets to that IP before!

And in another email you wrote:

> Oh well, please forgive my stupid questions.
>
> David is currently working on backporting to 3.0 all necessary fixes =
for
> this exact problem.

I haven't tried to even reboot the host.  Because, well, even if
I'll do, I've no way to verify if the problem is fixed or not,
or even if it is the same problem or something else.  The namespace
thing here is most interesting imho.

But at least now I know why it hasn't been appeared in 3.0 stable :)

Thank you!

/mjt
