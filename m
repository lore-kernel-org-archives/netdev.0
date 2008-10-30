From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Thu, 30 Oct 2008 19:56:36 +0100
Message-ID: <490A0364.3040902@cosmosbay.com>
References: <20081009231759.GA8664@tservice.net.ru>	<20081010115518.GA3159@tservice.net.ru>	<20081010115725.GD19487@elte.hu>	<200810250025.35734.rjw@sisk.pl>	<20081026112924.GA29258@ioremap.net>	<20081026122300.GA30905@ioremap.net> <20081030111526.7d9bb0f8@extreme> <490A0054.2030903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@elte.hu>,
	Evgeniy Polyakov <s0mbre@tservice.net.ru>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Mike Galbraith <efault@gmx.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:33777 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbYJ3S5e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 14:57:34 -0400
In-Reply-To: <490A0054.2030903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Stephen Hemminger a =E9crit :
>> Has anyone looked into the impact of port randomization on this=20
>> benchmark.
>> If it is generating lots of sockets quickly there could be an impact=
:
>>   * port randomization causes available port space to get filled=20
>> non-uniformly
>>     and what was once a linear scan may have to walk over existing p=
orts.
>>     (This could be improved by a hint bitmap)
>>
>>   * port randomization adds at least one modulus operation per socke=
t
>>     creation. This could be optimized by using a loop instead.
>=20
>=20
>=20
> tbench setups one socket per client, then send/receive lot of message=
s=20
> on this socket.
>=20
> Connection setup time can be ignored for the tbench regression analys=
is
>=20

Hum, re-reading your question, I feel you might have a valid point afte=
r all :)

Not because of connection setup time, but because the rwlocks used on t=
cp hash table.

tcp sessions used on this tbench test might now be on the same cache li=
nes,
because of port randomization or so.

CPUS might do cache-line ping pongs on those rwlocks.

# netstat -tn|grep 7003
tcp        0     59 127.0.0.1:37248         127.0.0.1:7003          EST=
ABLISHED
tcp        0     71 127.0.0.1:7003          127.0.0.1:37252         EST=
ABLISHED
tcp        0      0 127.0.0.1:37251         127.0.0.1:7003          EST=
ABLISHED
tcp        0   4155 127.0.0.1:7003          127.0.0.1:37249         EST=
ABLISHED
tcp        0     55 127.0.0.1:7003          127.0.0.1:37248         EST=
ABLISHED
tcp        0      0 127.0.0.1:37252         127.0.0.1:7003          EST=
ABLISHED
tcp        0      0 127.0.0.1:37249         127.0.0.1:7003          EST=
ABLISHED
tcp        0     59 127.0.0.1:37246         127.0.0.1:7003          EST=
ABLISHED
tcp        0      0 127.0.0.1:37250         127.0.0.1:7003          EST=
ABLISHED
tcp       71      0 127.0.0.1:37245         127.0.0.1:7003          EST=
ABLISHED
tcp        0      0 127.0.0.1:37244         127.0.0.1:7003          EST=
ABLISHED
tcp        0     87 127.0.0.1:7003          127.0.0.1:37250         EST=
ABLISHED
tcp        0   4155 127.0.0.1:7003          127.0.0.1:37251         EST=
ABLISHED
tcp        0   4155 127.0.0.1:7003          127.0.0.1:37246         EST=
ABLISHED
tcp        0     71 127.0.0.1:7003          127.0.0.1:37245         EST=
ABLISHED
tcp        0   4155 127.0.0.1:7003          127.0.0.1:37244         EST=
ABLISHED

We use a jhash, so normally we could expect a really random split of ha=
sh values
for all these sessions, but it would be worth to check :)

You know understand why we want to avoid those rwlocks Stephen, and swi=
tch to RCU...

