From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 08 Jul 2011 11:06:59 -0700 (PDT)
Message-ID: <20110708.110659.1816173367050101549.davem@davemloft.net>
References: <mj+md-20110708.173556.16517.nikam@ucw.cz>
	<20110708.104739.169518036069870432.davem@davemloft.net>
	<CABrhC0kaRCpvmKw=TdPZ+7dRFzdcrjF7hoc-VhbtAfXu=WBU_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mj@ucw.cz, netdev@vger.kernel.org
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab1GHSHF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 14:07:05 -0400
In-Reply-To: <CABrhC0kaRCpvmKw=TdPZ+7dRFzdcrjF7hoc-VhbtAfXu=WBU_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: John Heffner <johnwheffner@gmail.com>
Date: Fri, 8 Jul 2011 14:03:45 -0400

> On Fri, Jul 8, 2011 at 1:47 PM, David Miller <davem@davemloft.net> wr=
ote:
>> From: Martin Mares <mj@ucw.cz>
>> Date: Fri, 8 Jul 2011 19:40:55 +0200
>>
>>> The hash function is linear, so it can be reduced to:
>>>
>>> =A0 =A0 =A0 a =3D key ^ dev->ifindex
>>> =A0 =A0 =A0 return (a >> 8) ^ (a >> 16) ^ (a >> 24) =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 // (1)
>>> =A0 =A0 =A0 =A0 =A0 =A0^ (hash_rnd >> 8) ^ (hash_rnd >> 16) ^ (hash=
_rnd >> 24) =A0 =A0// (2)
>>
>> Is this really the same? =A0The inclusion of a full 32-bit xor
>> with hash_rnd before folding was intentional, so that the
>> final folding occurs on a completely "random" value.
>=20
> Martin's reduction looks exactly correct to me.

Ok, there was also an unintended bug in my original patch,
I lost the bottom 8 bits in the fold, the hash function
should instead be:

+static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u3=
2 hash_rnd)
+{
+	u32 val =3D key ^ dev->ifindex ^ hash_rnd;
+
+	return val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24);
+}
