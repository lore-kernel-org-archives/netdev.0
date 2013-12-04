From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net v4 1/2] net: sched: tbf: fix calculation of max_size
Date: Wed, 4 Dec 2013 09:53:02 +0800
Message-ID: <529E8AFE.30906@huawei.com>
References: <1386041214-72744-1-git-send-email-yangyingliang@huawei.com>			 <1386041214-72744-2-git-send-email-yangyingliang@huawei.com>		 <1386046793.30495.12.camel@edumazet-glaptop2.roam.corp.google.com>		 <529D8BC7.4050005@huawei.com>	 <1386058339.30495.19.camel@edumazet-glaptop2.roam.corp.google.com>	 <529DA8C1.4000504@huawei.com> <529DC163.5090403@huawei.com> <1386082293.30495.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<brouer@redhat.com>, <jpirko@redhat.com>, <jbrouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:64799 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146Ab3LDBxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 20:53:16 -0500
In-Reply-To: <1386082293.30495.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/3 22:51, Eric Dumazet wrote:
> On Tue, 2013-12-03 at 19:32 +0800, Yang Yingliang wrote:
> 
>>>
>>>>
>>>> TSO packet of 64KB -> about 45 frames if MSS=1448, 45*1514 = 68130 bytes
>>
>> Maybe MAX_PKT_LEN should be much bigger. Hmm, I'm uncertain how big is the proper value.
>>
> 
> Thats the thing : When user is able to compute the appropriate burst and
> give precise instructions to the kernel, why tbf would reduce it to
> whatever fixed threshold ?
> 
> If I set 200000 as a burst, I do not want tbf use 65536 or even less.
> 
> If tbf rounds my 200000 to 199800, its fine.
> 
> You had problems to set burst to appropriate values, but most other
> users did that fine.
> 
> tbf_segment() is an attempt to help for very low rates, to not overcome
> the small bursts (as low as 2000 bytes) programmed on atbf qdisc, but
> for high rates, we _definitely_ want to avoid segmentation as hell.
> 

Thanks for your opinions!
>From your opinions, how about calculating burst directly with q->buffer and psched_ns_t2l().

I did it in my v1 patch:

/* Time to Length, convert time in ns to length in bytes
 * to determinate how many bytes can be sent in given time.
 */
static inline u64 psched_ns_t2l(const struct psched_ratecfg *r,
				u64 time_in_ns)
{
	u64 len = time_in_ns;
	u8 shift = r->shift;
	bool is_div = false;

	/* The formula is :
	 * len = (time_in_ns << shift) / mult
	 * when time_in_ns does shift, it would overflow.
	 * If overflow happens first time, do division.
	 * Then do shift. If it happens again,
	 * set lenth to ~0ULL.
	 */
	while (shift) {
		if (len & (1ULL << 63)) {
			if (!is_div) {
				len = div64_u64(len, r->mult);
				is_div = true;
			} else {
				/* overflow happens */
				len = ~0ULL;
				is_div = true;
				break;
			}
		}
		len <<= 1;
		shift--;
	}
	if (!is_div)
		len = div64_u64(len, r->mult);

	if (unlikely(r->linklayer == TC_LINKLAYER_ATM))
		len = (len / 53) * 48;

	if (len > r->overhead)
		len -= r->overhead;
	else
		len = 0;

	return len;
}
max_size = min_t(u64, psched_ns_t2l(&q->rate, q->buffer), ~0);

Regards,
Yang
