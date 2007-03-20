From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: many sockets, slow sendto
Date: Tue, 20 Mar 2007 23:48:38 +0100
Message-ID: <460064C6.5030302@cosmosbay.com>
References: <E1HObHK-0000WB-00@osiris.swi.hu>	<20070306182039.GJ25760@galon.ev-en.org>	<45FF185B.4070007@fw.hu> <20070319.161611.70218081.davem@davemloft.net> <4600592E.80605@fw.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, baruch@ev-en.org,
	netdev@vger.kernel.org
To: Zacco <zacco@fw.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:37675 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbXCTWs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 18:48:57 -0400
In-Reply-To: <4600592E.80605@fw.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zacco a =E9crit :
> Hi,
>=20
> David Miller wrote:
>> From: Zacco <zacco@fw.hu>
>> Date: Tue, 20 Mar 2007 00:10:19 +0100
>>
>> =20
>>> As you recommended, I used oprofile and it turned out that the=20
>>> __udp4_lib_lookup function spent most of the time. There is a udp=20
>>> hash table and the sockets are sought based on the 7 LSBs of the=20
>>> destination port number. So what happened is now quite obvious: I h=
ad=20
>>> many thousands of sockets, all with the same destination port, thus=
=20
>>> linked in the same slot of this hash table. I tried using different=
=20
>>> ports and it
>>> was much faster then.
>>>    =20
>>
>> There isn't much we can do here.  I bet your destination address
>> is unchanging just like your destination ports.
>>  =20
> As I'm simulating independent users on one host, each user has a=20
> different IP address, but each with the same port. So unlike the port=
,=20
> the address is changing, basically it's a huge A-class range.
>=20
>> UDP apps can and do bind to specific destination addresses and
>> ports, but the source side is usually wild-carded.
>>  =20
> Right, usually it is, but in my case the source addresses are also=20
> bound, otherwise the source address would be the primary address of t=
he=20
> physical interface; however, I need to simulate users as if they were=
 on=20
> separate hosts.
>> Are both the source address and port fully specified for your
>> sockets?  Maybe we can do something using if that's the case...
>>  =20
> You made me curious.  :)  What do you have in mind?

Currently, udp_hash[UDP_HTABLE_SIZE] is using a hash function based on =
dport=20
number only.

In your case, as you use a single port value, all sockets are in a sing=
le slot=20
of this hash table :
To find the good socket, __udp4_lib_lookup() has to search in a list wi=
th=20
thousands of elements. Not that good, isnt it ? :(

As udp_hash is protected by a single rw_lock, I guess we could convert =
the=20
hash table to a RB-tree, with a key being : (dport, daddr)

At lookup time, we could do :

1) A full lookup with (dport, daddr)
2) if not found, a lookup with wildcard : (dport, 0)

I dont know if this is OK, because I dont know if it is possible to hav=
e=20
several UDP sockets with the same (dport, daddr)

It would be more scalable. But still the rw_lock is not very SMP friend=
ly...


