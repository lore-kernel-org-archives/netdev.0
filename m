From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: fix /proc/net/snmp as memory corruptor
Date: Sat, 08 Nov 2008 21:46:36 +0100
Message-ID: <4915FAAC.1010905@cosmosbay.com>
References: <OF6C282093.F9856B9A-ON882574FB.006C580F-882574FB.006D3BF5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>, alan@lxorguk.ukuu.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Eric Sesterhenn <snakebyte@gmx.de>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:42106 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbYKHUrI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 15:47:08 -0500
In-Reply-To: <OF6C282093.F9856B9A-ON882574FB.006C580F-882574FB.006D3BF5@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens a =E9crit :
> Oh, that was me! Thank you, Alexey!
>=20
>> This should be fixed as well, or multiple threads reading /proc/net/=
snmp
>> could get mixed results without proper locking.
>=20
> I don't believe locking is an issue here. If the values
> change between the first and second tests, being counters,
> they are still nonzero. If they are different in different
> threads, it reflects an actual change in the counter. So
> I'm not sure what you're talking about here.

If you are not sure what I am talking about, then you should probably
not use static variables at all. I found this fix quite obvious...

>=20
> I don't think they should be on the stack (obviously, or
> I wouldn't have written it this way). So, FWIW, I like
> Alexey's fix, which is what the code should've been.

You apparently missed the fact that with your new code, we can have mor=
e than
16 different ICMP counters > 0.

thread 1 on CPU 1
-----------------

- fills 16 indexes in static table
- print them. good.

- fills *next* 16 indexes in static table
=2E.. preempted by some IRQ or something....

thread 2 on CPU 2
------------------

fills 16 indexes in static table, overwriting
the values that thread 1 was trying to put.
=2E..

thread 1:

print the values of thread 2.
(it will probably prints a copy of its first line)

bang : User application missed some critical information.


>=20
> For Alexey's patch:
>=20
> Acked-by: David L Stevens <dlstevens@us.ibm.com>

