From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC(v2) net-next 08/13] ipv6: Do not deoend on rt->n in ip6_dst_lookup_tail().
Date: Wed, 16 Jan 2013 21:27:28 +0900
Message-ID: <50F69CB0.8040900@linux-ipv6.org>
References: <50F587CF.1090306@linux-ipv6.org> <50F64D96.4090709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:42527 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751558Ab3APM1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 07:27:30 -0500
In-Reply-To: <50F64D96.4090709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang wrote:
> s/deoend/depend/ in $subject...
> 
> On 01/16/2013 12:46 AM, YOSHIFUJI Hideaki wrote:
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> ---
>>   net/ipv6/ip6_output.c |    8 ++++++--
>>   1 file changed, 6 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
>> index 9fc5d1d..b2fe048 100644
>> --- a/net/ipv6/ip6_output.c
>> +++ b/net/ipv6/ip6_output.c
>> @@ -921,8 +921,12 @@ static int ip6_dst_lookup_tail(struct sock *sk,
>>   	 * dst entry of the nexthop router
>>   	 */
>>   	rt = (struct rt6_info *) *dst;
>> -	n = rt->n;
>> -	if (n && !(n->nud_state & NUD_VALID)) {
>> +	rcu_read_lock_bh();
>> +	n = __ipv6_neigh_lookup_noref(rt->dst.dev, rt6_nexthop(rt, &fl6->daddr));
>> +	err = n && !(n->nud_state & NUD_VALID) ? -EINVAL : 0;
>> +	rcu_read_unlock_bh();
>> +
>> +	if (err) {
> 
> Are you sure the logic here equals?
> 
> In the original code, we could return 0 even we enter this if branch,
> but after your patch, it seems it will return -EINVAL?
> 

err is always updated after the branch, or return 0;

--yoshfuji
