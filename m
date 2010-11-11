From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Thu, 11 Nov 2010 08:40:58 -0800
Message-ID: <4CDC1C9A.3070102@candelatech.com>
References: <1289403709.2860.216.camel@edumazet-laptop>	 <4CDAD8C8.20807@candelatech.com>	 <1289411027.2860.248.camel@edumazet-laptop>	 <4CDADC17.6070506@candelatech.com>	 <1289413120.2469.12.camel@edumazet-laptop>	 <4CDAE713.7020309@candelatech.com>	 <1289421187.2469.127.camel@edumazet-laptop> <4CDB1021.507@candelatech.com>	 <1289427705.17691.52.camel@edumazet-laptop>	 <4CDB226A.8080903@candelatech.com>	 <1289432184.17691.141.camel@edumazet-laptop>	 <4CDB2EBC.2090905@candelatech.com> <1289459012.17691.1001.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44109 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754510Ab0KKQlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 11:41:00 -0500
In-Reply-To: <1289459012.17691.1001.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2010 11:03 PM, Eric Dumazet wrote:
> Le mercredi 10 novembre 2010 =C3=A0 15:46 -0800, Ben Greear a =C3=A9c=
rit :
>> On 11/10/2010 03:36 PM, Eric Dumazet wrote:
>>> Le mercredi 10 novembre 2010 =C3=A0 14:53 -0800, Ben Greear a =C3=A9=
crit :
>>>
>>>> I did similar, and then wrote extra code to detect a 64-bit kernel=
 and if
>>>> so assume that the counters wrap at 64 bits so I didn't have to po=
ll so
>>>> often to make sure I didn't miss a wrap for a 10G NIC.  If instead=
 one wraps at 33
>>>> bits and the other at 36, there is no way for me to deal with the =
wrap
>>>> properly w/out explicitly knowing about that 33 and 36.
>>>>
>>>
>>> How do you define 'wrap around' ? Maybe your definition is wrong.
>>
>> Maybe so.  My algorithm looks like:
>>
>>    // uint64 accum;
>>    // uint32 old;
>>    // uint32 new;
>>    if (old>  new) {
>>        // This assumes counters wrap at 32 bits (ie, 0xFFFFFFFF).
>>        accum +=3D ((uint32)(0xFFFFFFFF) - old) + new;
>>    }
>>    else if (old<  new) {
>>        accum +=3D new - old;
>>    }
>>    old =3D new;
>>
>> ...
>>
>> Is there some way I can do this w/out the (0xFFFFFFFF - old),
>> and thus the assumption of 32-bit counters?
>>
>
> Yes, please take a look at RRD for an example, then you can adapt to
> your needs.
>
> <quote>
>
> http://www.mrtg.org/rrdtool/tut/rrdtutorial.en.html
>
> At the time of writing this document, RRDtool knows of counters that =
are
> either 32 bits or 64 bits of size. These counters can handle the
> following different values:
>
>   - 32 bits: 0 ..           4294967295
>   - 64 bits: 0 .. 18446744073709551615
>
> If these numbers look strange to you, you can view them in their
> hexadecimal form:
>
>   - 32 bits: 0 ..         FFFFFFFF
>   - 64 bits: 0 .. FFFFFFFFFFFFFFFF
>
> RRDtool handles both counters the same. If an overflow occurs and the
> delta would be negative, RRDtool first adds the maximum of a small
> counter + 1 to the delta. If the delta is still negative, it had to b=
e
> the large counter that wrapped. Add the maximum possible value of the
> large counter + 1 and subtract the erroneously added small value.
>
> There is a risk in this: suppose the large counter wrapped while addi=
ng
> a huge delta, it could happen, theoretically, that adding the smaller
> value would make the delta positive. In this unlikely case the result=
s
> would not be correct. The increase should be nearly as high as the
> maximum counter value for that to happen, so chances are you would ha=
ve
> several other problems as well and this particular problem would not
> even be worth thinking about. Even though, I did include an example, =
so
> you can judge for yourself.

So, they assume counters are exactly 32 or 64 bits.
Your example of the 36-bit counter would break their
assumptions of 32 or 64 bits.

I agree that you can guess if the counter is 32 or 64, at least with to=
day's
hardware and relatively normal poll times, and the requirement that the
counters can ONLY be 32 or 64 bits.  I still consider it a kludge to
return 32 bit counters in stats64, however.  Would you consider
a patch to have netlink pay attention to whether the stats are 32 or
64 (based on a flag returned from dev_get_stats perhaps)?

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

