From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net v5 1/2] net: sched: tbf: fix calculation of max_size
Date: Fri, 6 Dec 2013 10:24:30 +0800
Message-ID: <52A1355E.5070301@huawei.com>
References: <1386227457-86900-1-git-send-email-yangyingliang@huawei.com>	 <1386227457-86900-2-git-send-email-yangyingliang@huawei.com> <1386245729.30495.167.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<brouer@redhat.com>, <jpirko@redhat.com>, <jbrouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:58893 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753579Ab3LFC0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 21:26:14 -0500
In-Reply-To: <1386245729.30495.167.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Eric
Thanks for your reviewing and advice!

On 2013/12/5 20:15, Eric Dumazet wrote:
> On Thu, 2013-12-05 at 15:10 +0800, Yang Yingliang wrote:
>>
>> Suggested-by: Jesper Dangaard Brouer <jbrouer@redhat.com>
>> Suggested-by: Eric Dumazet <edumazet@google.com>
> 
> No, I did not suggest this patch.

You suggested that

	if (qopt->rate.linklayer == TC_LINKLAYER_UNAWARE)
	    qdisc_put_rtab(qdisc_get_rtab(&qopt->rate,
				          tb[TCA_TBF_RTAB]));

so I added your suggestion.

> 
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>> ---
>>  include/net/sch_generic.h | 46 ++++++++++++++++++++++++++++
>>  net/sched/sch_tbf.c       | 76 ++++++++++++++++++++---------------------------
>>  2 files changed, 79 insertions(+), 43 deletions(-)
>>
>> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
>> index d0a6321..8da64f3 100644
>> --- a/include/net/sch_generic.h
>> +++ b/include/net/sch_generic.h
>> @@ -701,6 +701,52 @@ static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
>>  	return ((u64)len * r->mult) >> r->shift;
>>  }
>>  
>> +/* Time to Length, convert time in ns to length in bytes
>> + * to determinate how many bytes can be sent in given time.
>> + */
>> +static inline u64 psched_ns_t2l(const struct psched_ratecfg *r,
>> +				u64 time_in_ns)
> 
> inline ?
> 
> Really ? 
> 
> This is management path, there is no point inlining this.
> 
>> +{
>> +	u64 len = time_in_ns;
>> +	u8 shift = r->shift;
>> +	bool is_div = false;
>> +
>> +	/* The formula is :
>> +	 * len = (time_in_ns << shift) / mult
>> +	 * when time_in_ns does shift, it would overflow.
>> +	 * If overflow happens first time, do division.
>> +	 * Then do shift. If it happens again,
>> +	 * set lenth to ~0ULL.
>> +	 */
>> +	while (shift) {
>> +		if (len & (1ULL << 63)) {
>> +			if (!is_div) {
>> +				len = div64_u64(len, r->mult);
>> +				is_div = true;
>> +			} else {
>> +				/* overflow happens */
>> +				len = ~0ULL;
>> +				is_div = true;
>> +				break;
>> +			}
>> +		}
>> +		len <<= 1;
>> +		shift--;
>> +	}
>> +	if (!is_div)
>> +		len = div64_u64(len, r->mult);
> 
> Thats terrible.
> 
> Given that the intended formula was :
> 
> time_in_ns = (NSEC_PER_SEC * len) / rate_bps;
> 
> This translates to following optimal C code
> 
> u64 len = time_in_ns * r->rate_bytes_ps;
> do_div(len, NSEC_PER_SEC);
> 
> Why do you use r->shift and r->mult which are optimized for the reverse
> operation in fast path (no divide), I do not know.

The formula to calculate tokens is :

(len * r->mult) >> r->shift

so I tried to use r->shift and r->mult to calculate the len.

Your way looks better, I'll change it in v6.

> 
>> +	max_size = min_t(u64, psched_ns_t2l(&q->rate, q->buffer), ~0U); 
>> +
>> +	if (qopt->peakrate.rate) {
>>  		if (tb[TCA_TBF_PRATE64])
>>  			prate64 = nla_get_u64(tb[TCA_TBF_PRATE64]);
>> -		psched_ratecfg_precompute(&q->peak, &ptab->rate, prate64);
>> +		psched_ratecfg_precompute(&q->peak, &qopt->peakrate, prate64);
>> +		if (q->peak.rate_bytes_ps <= q->rate.rate_bytes_ps) {
>> +			pr_err("Peakrate must be higher than rate!\n");
> 
> Do not add messages like that without rate limiting them.
> 
> Plus there is no context, we know nothing.

OK, I'll use pr_warn_ratelimited instead.

Regards,
Yang
