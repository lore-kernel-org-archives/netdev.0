From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC(v2) net-next 01/13] ndisc: Refer/Update neigh->updated with
 write lock.
Date: Wed, 16 Jan 2013 23:04:39 +0900
Message-ID: <50F6B377.5000005@linux-ipv6.org>
References: <50F58777.7080209@linux-ipv6.org> <50F64A3C.9040605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:42641 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754096Ab3APOEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 09:04:40 -0500
In-Reply-To: <50F64A3C.9040605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang wrote:
> On 01/16/2013 12:44 AM, YOSHIFUJI Hideaki wrote:
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> ---
>>   net/ipv6/route.c |   12 ++++++++----
>>   1 file changed, 8 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 7c34c01..1341f68 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -499,22 +499,26 @@ static void rt6_probe(struct rt6_info *rt)
>>   	 * to no more than one per minute.
>>   	 */
>>   	neigh = rt ? rt->n : NULL;
>> -	if (!neigh || (neigh->nud_state & NUD_VALID))
>> +	if (!neigh)
>> +		return;
>> +	write_lock_bh(&neigh->lock);
>> +	if (neigh->nud_state & NUD_VALID) {
>> +		write_unlock_bh(&neigh->lock);
>>   		return;
>> -	read_lock_bh(&neigh->lock);
>> +	}
>>   	if (!(neigh->nud_state & NUD_VALID) &&
>>   	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
>>   		struct in6_addr mcaddr;
>>   		struct in6_addr *target;
>>   
>>   		neigh->updated = jiffies;
>> -		read_unlock_bh(&neigh->lock);
>> +		write_unlock_bh(&neigh->lock);
> 
> This looks like a bug fix, which deserves a separated patch rather than
> in this rt->n removal series.

Because the series depends on this, it is included here so far.

--yoshfuji
