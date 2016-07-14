From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH v2 08/10] net: sched: pfifo_fast use alf_queue
Date: Thu, 14 Jul 2016 16:42:08 -0700
Message-ID: <20160714234207.GA93671@ast-mbp.thefacebook.com>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
 <20160714062312.8270.65942.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, jhs@mojatatu.com, eric.dumazet@gmail.com,
	brouer@redhat.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33383 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbcGNXmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 19:42:13 -0400
Received: by mail-pf0-f193.google.com with SMTP id i6so5134902pfe.0
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 16:42:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160714062312.8270.65942.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 11:23:12PM -0700, John Fastabend wrote:
> This converts the pfifo_fast qdisc to use the alf_queue enqueue and
> dequeue routines then sets the NOLOCK bit.
> 
> This also removes the logic used to pick the next band to dequeue from
> and instead just checks each alf_queue for packets from top priority
> to lowest. This might need to be a bit more clever but seems to work
> for now.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/sch_generic.c |  131 +++++++++++++++++++++++++++--------------------

>  static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
>  			      struct sk_buff **to_free)
>  {
> -	return qdisc_drop(skb, qdisc, to_free);
> +	err = skb_array_produce_bh(q, skb);
..
>  static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
>  {
> +		skb = skb_array_consume_bh(q);

For this particular qdisc the performance gain should come from
granularityof spin_lock, right?
Before we were taking the lock much earlier. Here we keep the lock,
but for the very short time.
        original pps        lockless        diff
        1       1418168             1269450         -148718
        2       1587390             1553408         -33982
        4       1084961             1683639         +598678
        8       989636              1522723         +533087
        12      1014018             1348172         +334154
so perf for 1 cpu case is mainly due to array vs list,
since number of locks is still the same and there is no collision ?
but then why shorter lock give higher overhead in multi cpu cases?
That would have been the main target for performance improvement?

Looks like mq gets the most benefit, because it's lockless internally
which makes sense.
In general I think this is the right direction where tc infra should move to.
I'm only not sure whether it's worth converting pfifo to skb_array.
Probably alf queue would have been a better alternative.
