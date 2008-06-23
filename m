From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH] hfsc: add link layer overhead adaption
Date: Mon, 23 Jun 2008 14:24:17 +0300
Message-ID: <20080623142417.9gxuu3y9r4084s4c@hayate.ip6>
References: <20080623102514.15821.13979.stgit@fate.lan>
	<485F81B2.7000107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:36983 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbYFWLYT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 07:24:19 -0400
In-Reply-To: <485F81B2.7000107@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Patrick McHardy <kaber@trash.net>:

> Jussi Kivilinna wrote:
>> CBQ and HTB have options for emulating overhead of underlying link layer
>> (mpu/overhead/linklayer options). This patch makes sch_hfsc use rate table
>> to emulate link layer overhead.
>>
>> Patch uses rate table to convert packet length to emulated link layer packet
>> length using qdisc_l2t() in get_linklayer_len(). Converted packet length is
>> passed to hfsc calculations instead of real. If rate table isn't passed to
>> kernel, hfsc works as before.
>>
>> diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
>> index fdfaa3f..94fd130 100644
>> --- a/net/sched/sch_hfsc.c
>> +++ b/net/sched/sch_hfsc.c
>> +/* convert packet length to link layer packet length */
>> +static unsigned int get_linklayer_len(struct hfsc_class *cl,   
>> unsigned int len)
>> +{
>> +	u64 ll_len;
>> +	if (likely(len) && unlikely(cl->rtab)) {
>> +		ll_len = qdisc_l2t(cl->rtab, len);
>> +		if (unlikely(cl->rtab->rate.rate != PSCHED_TICKS_PER_SEC))
>> +			ll_len = div_u64(ll_len * cl->rtab->rate.rate,
>> +							PSCHED_TICKS_PER_SEC);
>> +		return (unsigned int)ll_len;
>> +	}
>> +	return len;
>> +}
>
> This looks like an abuse of rate tables, which usually convert
> packet sizes to transmission times. You undo that above using
> expensive calculations.
>
> I think this should be done by performing the length calculation
> in the kernel directly.

Yes, it's abuse, and actually table is created using false rate (rate  
= PSCHED_TICKS_PER_SEC) so div_u64 is avoided. Div_u64 is there just  
in case something goes wrong in userspace. Using rate table allows  
changes/updates to link layer emulation with only userspace updates  
avoiding, but maybe abuse of rate table isn't right way to do this  
after all.

So would it be better if I add 'length table' to kernel&userspace and  
use it instead?

  - Jussi


