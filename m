From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 7/8] net: Add calaulation of non folded IPV6
 pseudo header checksum
Date: Thu, 30 Oct 2014 18:54:20 +0200
Message-ID: <54526D3C.2040604@mellanox.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com> <1414685216-28907-8-git-send-email-ogerlitz@mellanox.com> <063D6719AE5E284EB5DD2968C1650D6D1C9E2415@AcuExch.aculab.com> <5452682B.2030802@mellanox.com> <063D6719AE5E284EB5DD2968C1650D6D1C9E2497@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:43124 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759794AbaJ3Qy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 12:54:29 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9E2497@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2014 6:39 PM, David Laight wrote:
> From: Or Gerlitz [mailto:ogerlitz@mellanox.com]
>> On 10/30/2014 6:25 PM, David Laight wrote:
>>>>> +static inline __wsum csum_ipv6_magic_nofold(const struct in6_addr *saddr,
>>>>> +					    const struct in6_addr *daddr,
>>>>> +					    __u32 len, unsigned short proto,
>>>>> +					    __wsum sum)
>>>>> +{
>>>>> +	__wsum res = sum;
>>>>> +
>>>>> +	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[0]);
>>>>> +	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[1]);
>>>>> +	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[2]);
>>>>> +	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[3]);
>>>>> +	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[0]);
>>>>> +	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[1]);
>>>>> +	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[2]);
>>>>> +	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[3]);
>>> That probably generates a very long dependency chain.
>>>
>> Could you clarify this comment a bit?
> csum_add() probably generates a 32bit 'add with carry' instruction.
> So the above generates 8 instructions that have to be executed in series
> (dependencies on the register and the carry flag).
>
> On a 64bit cpu there are other options, eg adding 32bit values into
> several 64bit registers, then adding those together and finally
> collapsing the value to 32 then 16 bits.
>
> Maybe __wsum does end up being 64bit (not looked), but gcc won't
> generate a 'tree' of additions, it will still generate a dependency chain.
>
> Hopefully the software 'checksum a buffer' function is written to
> avoid these problems.

OK, talking to Matan, hecame up with this super-quick (compile tested 
only) alternative, is
this what you were advocating for?


Or.


diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index c45d690..cadffdc 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -46,6 +46,19 @@ static inline __wsum csum_ipv6_magic_nofold(const 
struct in6_addr *saddr,
                                             __u32 len, unsigned short 
proto,
                                             __wsum sum)
  {
+       sum = csum_partial(saddr, sizeof(saddr->in6_u.u6_addr32), sum);
+       sum = csum_partial(saddr, sizeof(daddr->in6_u.u6_addr32), sum);
+       sum = csum_add(sum, (__force __wsum)htonl(len));
+       sum = csum_add(sum, (__force __wsum)htons(proto));
+
+       return sum;
+}
