From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] hfsc: add link layer overhead adaption
Date: Mon, 23 Jun 2008 12:57:54 +0200
Message-ID: <485F81B2.7000107@trash.net>
References: <20080623102514.15821.13979.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45242 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754998AbYFWK56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 06:57:58 -0400
In-Reply-To: <20080623102514.15821.13979.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> CBQ and HTB have options for emulating overhead of underlying link layer
> (mpu/overhead/linklayer options). This patch makes sch_hfsc use rate table
> to emulate link layer overhead.
> 
> Patch uses rate table to convert packet length to emulated link layer packet
> length using qdisc_l2t() in get_linklayer_len(). Converted packet length is
> passed to hfsc calculations instead of real. If rate table isn't passed to
> kernel, hfsc works as before.
> 
> diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
> index fdfaa3f..94fd130 100644
> --- a/net/sched/sch_hfsc.c
> +++ b/net/sched/sch_hfsc.c
> +/* convert packet length to link layer packet length */
> +static unsigned int get_linklayer_len(struct hfsc_class *cl, unsigned int len)
> +{
> +	u64 ll_len;
> +	if (likely(len) && unlikely(cl->rtab)) {
> +		ll_len = qdisc_l2t(cl->rtab, len);
> +		if (unlikely(cl->rtab->rate.rate != PSCHED_TICKS_PER_SEC))
> +			ll_len = div_u64(ll_len * cl->rtab->rate.rate,
> +							PSCHED_TICKS_PER_SEC);
> +		return (unsigned int)ll_len;
> +	}
> +	return len;
> +}

This looks like an abuse of rate tables, which usually convert
packet sizes to transmission times. You undo that above using
expensive calculations.

I think this should be done by performing the length calculation
in the kernel directly.
