From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: sched: consolidate tc_classify{,_compat}
Date: Wed, 26 Aug 2015 14:54:05 -0700
Message-ID: <55DE357D.7010800@plumgrid.com>
References: <3dfe133299d033dfa52bcf63d846f3f91b56d30c.1440620622.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:32801 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbbHZVyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 17:54:07 -0400
Received: by ykll84 with SMTP id l84so1011079ykl.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 14:54:07 -0700 (PDT)
In-Reply-To: <3dfe133299d033dfa52bcf63d846f3f91b56d30c.1440620622.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/26/15 2:00 PM, Daniel Borkmann wrote:
> For classifiers getting invoked via tc_classify(), we always need an
> extra function call into tc_classify_compat(), as both are being
> exported as symbols and tc_classify() itself doesn't do much except
> handling of reclassifications when tp->classify() returned with
> TC_ACT_RECLASSIFY.
>
> CBQ and ATM are the only qdiscs that directly call into tc_classify_compat(),
> all others use tc_classify(). When tc actions are being configured
> out in the kernel, tc_classify() effectively does nothing besides
> delegating.
>
> We could spare this layer and consolidate both functions. pktgen on
> single CPU constantly pushing skbs directly into the netif_receive_skb()
> path with a dummy classifier on ingress qdisc attached, improves
> slightly from 22.3Mpps to 23.1Mpps.

Nice improvement!

> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>   include/net/pkt_sched.h  |  4 +---
>   net/core/dev.c           |  2 +-
>   net/sched/sch_api.c      | 55 ++++++++++++++++++++++--------------------------
>   net/sched/sch_atm.c      |  2 +-
>   net/sched/sch_cbq.c      |  2 +-
>   net/sched/sch_choke.c    |  2 +-
>   net/sched/sch_drr.c      |  2 +-
>   net/sched/sch_dsmark.c   |  2 +-
>   net/sched/sch_fq_codel.c |  2 +-
>   net/sched/sch_hfsc.c     |  2 +-
>   net/sched/sch_htb.c      |  2 +-
>   net/sched/sch_multiq.c   |  2 +-
>   net/sched/sch_prio.c     |  2 +-
>   net/sched/sch_qfq.c      |  2 +-
>   net/sched/sch_sfb.c      |  2 +-
>   net/sched/sch_sfq.c      |  2 +-

probably 'static inline' helper with default compat_mode=false
could have reduced the size of the diff, but I guess it's ok as it is.

> +#ifdef CONFIG_NET_CLS_ACT
> +		if (unlikely(err == TC_ACT_RECLASSIFY &&
> +			     !compat_mode))

why line break? even single line would be well below 80 char limit...

> -		if (unlikely(limit++ >= MAX_REC_LOOP)) {
> -			net_notice_ratelimited("%s: packet reclassify loop rule prio %u protocol %02x\n",
> -					       tp->q->ops->id,
> -					       tp->prio & 0xffff,
> -					       ntohs(tp->protocol));
> -			return TC_ACT_SHOT;
> -		}
> -		goto reclassify;
> +reset:
> +	if (unlikely(limit++ >= MAX_REC_LOOP)) {
> +		net_notice_ratelimited("%s: reclassify loop, rule prio %u, "
> +				       "protocol %02x\n", tp->q->ops->id,
> +				       tp->prio & 0xffff, ntohs(tp->protocol));

why drop 'packet' and add two extra ',' in the message ?
Not a big deal, just why bother?
Also breaking strings is not advised, since it hurts grepping.
Other than that.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
