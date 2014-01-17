From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] sch_htb: let skb->priority refer to non-leaf class
Date: Fri, 17 Jan 2014 16:53:33 +0400
Message-ID: <52D927CD.4080403@cogentembedded.com>
References: <1389883519.4703.5.camel@azathoth.dev.smoothwall.net>	 <1389889520.31367.403.camel@edumazet-glaptop2.roam.corp.google.com> <1389953999.4698.18.camel@azathoth.dev.smoothwall.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Harry Mason <harry.mason@smoothwall.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:54642 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbaAQMx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 07:53:28 -0500
Received: by mail-la0-f46.google.com with SMTP id b8so3583718lan.33
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 04:53:27 -0800 (PST)
In-Reply-To: <1389953999.4698.18.camel@azathoth.dev.smoothwall.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 17-01-2014 14:19, Harry Mason wrote:

> If the class in skb->priority is not a leaf, apply filters from the
> selected class, not the qdisc. This lets netfilter or user space
> partially classify the packet.

> Signed-off-by: Harry Mason <harry.mason@smoothwall.net>
> ---

> On Thu, 2014-01-16 at 08:25 -0800, Eric Dumazet wrote:
>> On Thu, 2014-01-16 at 14:45 +0000, Harry Mason wrote:

>>> + /* Start with inner filter chain if a non-leaf class is selected */
>>> + if (cl)
>>> +     tcf = cl->filter_list;
>>> + else
>>> +     tcf = q->filter_list;

>> Could this break some existing htb setups ?

> I think it is unlikely. Setting skb->priority to a non-leaf class would
> be equivalent to setting it to the base qdisc. In theory an application
> might rely on this if it expects the classes to be dynamic, but adding
> a filter could restore the old behaviour.

> To me this is intuitively how it should behave, and reproduces what would
> happen if a tc filter instead of netfilter had first assigned the
> non-leaf class.

>> Also we test cl being NULL at line 222, it would be nice to not
>> test it again...

> Updated below.

>   net/sched/sch_htb.c |   10 +++++++---
>   1 file changed, 7 insertions(+), 3 deletions(-)

> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 717b210..8073d92 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -219,11 +219,15 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
>   	if (skb->priority == sch->handle)
>   		return HTB_DIRECT;	/* X:0 (direct flow) selected */
>   	cl = htb_find(skb->priority, sch);
> -	if (cl && cl->level == 0)
> -		return cl;
> +	if (cl) {
> +		if (cl->level == 0)
> +			return cl;
> +		/* Start with inner filter chain if a non-leaf class is selected */
> +		tcf = cl->filter_list;
> +	} else
> +		tcf = q->filter_list;

    There should be {} in the *else* arm, since it's in another arm of *if* 
already -- see Documentation/CodingStyle.

WBR, Sergei
