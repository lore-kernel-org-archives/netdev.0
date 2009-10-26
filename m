From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Mon, 26 Oct 2009 15:55:10 +0100
Message-ID: <4AE5B84E.8040505@gmail.com>
References: <200910252158.53921.opurdila@ixiacom.com> <4AE53382.8020308@gmail.com> <OF703F980D.0971407E-ON6525765B.00458CCA-6525765B.00481976@in.ibm.com> <200910261631.44666.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33054 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbZJZOzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 10:55:22 -0400
In-Reply-To: <200910261631.44666.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> On Monday 26 October 2009 15:07:31 you wrote:
>> Eric Dumazet wrote on 10/26/2009 10:58:34 AM:
>>> In fact, new10 should be the 'perfect' hash for the "eth%d"
>>> netdev use, not jhash (way more expensive in cpu cycles BTW)
>>>
>>> Most linux machines in the world have less than 10 interfaces, jhas=
h
>>> would be really overkill.
>>>
>>>
>>> Thanks
>>>
>>>
>>> [PATCH net-next-2.6] netdev: better dev_name_hash
>> Changing Eric's test program to pass a multiplier to string_hash()
>> and calling string_hash with multipler=3D<2 - 63> confirms that 10
>> is almost always the best number for varying netdev names. I print
>> the number of times perfect 64 was scored, and for most passed
>> device names, the best is for n=3D10, followed by n=3D5 and others.
>> Almost the worst was n=3D31, slightly better was n=3D17.
>>
>> But other variables matter too, like fewer entries (4K or 1K) but
>> above values for are still better compared to n=3D31.
>>
>=20
> Hmm, I've found out that it very much depends on the name as well:
>=20
> 0 - orig, 1 - jhash, 2 - new10, 3 - new17, 4 - new31
>=20
> $ ./dev_name_hash ixint 16000 0 16
> score 24741
> $ ./dev_name_hash ixint 16000 1 16
> score 17949
> $ ./dev_name_hash ixint 16000 2 16
> score 16000
> $ ./dev_name_hash ixint 16000 3 16
> score 16715
> $ ./dev_name_hash ixint 16000 4 16
> score 18125
>=20
>=20
> $ ./dev_name_hash ixunc 16000 0 16
> score 24741
> $ ./dev_name_hash ixunc 16000 1 16
> score 17904
> $ ./dev_name_hash ixunc 16000 2 16
> score 22180
> $ ./dev_name_hash ixunc 16000 3 16
> score 17065

> $ ./dev_name_hash ixunc 16000 4 16
> score 18038

This is because you chose a 65536 slots hash table, to store 16000 elem=
ents

The ideal function should be :

$ ./dev_name_hash ixunc 16000 5 16
score 16000

unsigned int dev_name_hash_new10bis(const char *name)
{
	unsigned hash =3D 0;
	int len =3D strnlen(name, IFNAMSIZ);
	int i;

	for (i =3D 0; i < len; ++i)
		hash =3D 10 * hash + (name[i] - '0');
	return hash;
}

But should we really care ?


