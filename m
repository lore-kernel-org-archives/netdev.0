From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sch_htb: let skb->priority refer to non-leaf class
Date: Thu, 16 Jan 2014 08:25:20 -0800
Message-ID: <1389889520.31367.403.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389883519.4703.5.camel@azathoth.dev.smoothwall.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@mojatatu.com>,
	linux-netdev <netdev@vger.kernel.org>
To: Harry Mason <harry.mason@smoothwall.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:51229 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbaAPQZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 11:25:28 -0500
Received: by mail-pd0-f172.google.com with SMTP id z10so2803231pdj.3
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 08:25:27 -0800 (PST)
In-Reply-To: <1389883519.4703.5.camel@azathoth.dev.smoothwall.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-16 at 14:45 +0000, Harry Mason wrote:
> If the class in skb->priority is not a leaf, apply filters from the
> selected class, not the qdisc. This allows netfilter or user space
> to partially classify the packet and tc filters to finish it off.
> 
> Signed-off-by: Harry Mason <harry.mason@smoothwall.net>
> ---
>  net/sched/sch_htb.c |    8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 717b210..e50ab65 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -223,7 +223,13 @@ static struct htb_class *htb_classify(struct
> sk_buff *skb, struct Qdisc *sch,
>         return cl;
> 
>     *qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
> -   tcf = q->filter_list;
> +
> +   /* Start with inner filter chain if a non-leaf class is selected */
> +   if (cl)
> +       tcf = cl->filter_list;
> +   else
> +       tcf = q->filter_list;
> +

Interesting idea.

Could this break some existing htb setups ?

Also we test cl being NULL at line 222, it would be nice to not test it
again...
