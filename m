From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] Fix SCTP failure with ipv6 source address routing
Date: Sat, 17 Apr 2010 20:17:13 -0400
Message-ID: <4BCA4F89.4030208@windriver.com>
References: <1271198256-20477-1-git-send-email-paul.gortmaker@windriver.com> <4BC510A2.1070105@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38231 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755904Ab0DRARR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 20:17:17 -0400
In-Reply-To: <4BC510A2.1070105@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-04-13 08:47 PM, Vlad Yasevich wrote:
> 
> 
> Paul Gortmaker wrote:
>> From: Weixing Shi<Weixing.Shi@windriver.com>
>>
>> Given the below test case, using source address routing, SCTP
>> does not work.
>>
>> Node-A:
>>    1)ifconfig eth0 inet6 add 2001:1::1/64
>>    2)ip -6 rule add from 2001:1::1 table 100 pref 100
>>    3)ip -6 route add 2001:2::1 dev eth0 table 100
>>    4)sctp_darn -H 2001:1::1 -P 250 -l&
>>
>> Node-B:
>>    1)ifconfig eth0 inet6 add 2001:2::1/64
>>    2)ip -6 rule add from 2001:2::1 table 100 pref 100
>>    3)ip -6 route add 2001:1::1 dev eth0 table 100
>>    4)sctp_darn -H 2001:2::1 -P 250 -h 2001:1::1 -p 250 -s
>>
>> Root cause:
>>    Node-A and Node-B use source address routing, and in the
>>    begining, the source address will be NULL.  So SCTP will search
>>    the routing table by the destination address (because it is using
>>    the source address routing table), and hence the resulting dst_entry
>>    will be NULL.
>>
>> Solution:
>>    After SCTP gets the correct source address, then we search for
>>    dst_entry again, and then we will get the correct value.
> 
> The problem here is that ipv6 route lookup code in sctp doesn't bother
> searching for the source address, unlike the v4 route lookup code.
> 
> Compare sctp_v4_get_dst() and sctp_v6_get_dst.  The v4 version bends over
> backwards trying to get the correct route, while the v6 version simple does
> a single lookup and returns the result.
> 
> The v6 route lookup code needs to be fixed to take into account the bound
> address list.

Thanks for the feedback -- we'll take a look and see if we can
fix it as per your recommendation and re-test.

Paul.

> 
> -vlad
> 	
>>
>> Signed-off-by: Weixing Shi<Weixing.Shi@windriver.com>
>> Signed-off-by: Paul Gortmaker<paul.gortmaker@windriver.com>
>> ---
>>   net/sctp/transport.c |   11 +++++++++--
>>   1 files changed, 9 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
>> index be4d63d..b5ae18c 100644
>> --- a/net/sctp/transport.c
>> +++ b/net/sctp/transport.c
>> @@ -295,9 +295,16 @@ void sctp_transport_route(struct sctp_transport *transport,
>>
>>   	if (saddr)
>>   		memcpy(&transport->saddr, saddr, sizeof(union sctp_addr));
>> -	else
>> +	else {
>>   		af->get_saddr(opt, asoc, dst, daddr,&transport->saddr);
>> -
>> +		/* When using source address routing, since dst was
>> +		 * looked up prior to filling in the source address, dst
>> +		 * needs to be looked up again to get the correct dst
>> +		 */
>> +		if (dst)
>> +			dst_release(dst);
>> +		dst = af->get_dst(asoc, daddr,&transport->saddr);
>> +	}
>>   	transport->dst = dst;
>>   	if ((transport->param_flags&  SPP_PMTUD_DISABLE)&&  transport->pathmtu) {
>>   		return;

