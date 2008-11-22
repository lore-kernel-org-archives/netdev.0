From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] eth: Declare an optimized compare_ether_addr_64bits()
 function
Date: Sat, 22 Nov 2008 08:30:30 +0100
Message-ID: <4927B516.9060804@cosmosbay.com>
References: <4927B275.1030407@cosmosbay.com> <20081121232232.0c2454f2@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:51969 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312AbYKVHae convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 02:30:34 -0500
In-Reply-To: <20081121232232.0c2454f2@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> On Sat, 22 Nov 2008 08:19:17 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>> Hello David, this is a resend of a patch previously sent in a=20
>> "tbench regression ..." thread on lkml
>>
>> We should also address the problem of skb_pull(skb, ETH_HLEN);
>> in eth_type_trans() :
>>
>> Being not inlined, this force eth_type_trans() to be a non
>> leaf function, that cost precious cpu cycles on many arches.
>>
>> Thank you
>>
>> [PATCH] eth: Declare an optimized compare_ether_addr_64bits() functi=
on
>>
>> Linus mentioned we could try to perform long word operations, even
>> on potentially unaligned addresses, on x86 at least.
>>
>> I tried this idea and got nice assembly on 32 bits:
>>
>> 158:   33 82 38 01 00 00       xor    0x138(%edx),%eax
>> 15e:   33 8a 34 01 00 00       xor    0x134(%edx),%ecx
>> 164:   c1 e0 10                shl    $0x10,%eax
>> 167:   09 c1                   or     %eax,%ecx
>> 169:   74 0b                   je     176 <eth_type_trans+0x87>
>>
>> And very nice assembly on 64 bits of course (one xor, one shl)
>>
>> Nice oprofile improvement in eth_type_trans(), 0.17 % instead of 0.4=
1 %,
>> expected since we remove 8 instructions on a fast path.
>>
>> This patch implements a compare_ether_addr_64bits() function,
>> that handles the case of x86 cpus, but might be used on other arches=
 as well,
>> if their potential misaligned long word reads are not expensive.
>>
>=20
> Why invent another function? Why not just have compare_ether_addr() b=
e
> as optimized as possible, could even set it up to be overloadable by
> asm code.

Because I am not sure we can fetch 8 bytes from addr1 & addr2 from all
call sites. Better be safe, and convert each call sites after an audit.
Then, when fully audited, rename the function ?


