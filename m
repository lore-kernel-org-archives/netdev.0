From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 net-next] net: pkt_sched: PIE AQM scheme
Date: Sat, 28 Sep 2013 10:03:42 -0700
Message-ID: <1380387822.3596.3.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380333383-9507-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	Mythili Prabhu <mysuryan@cisco.com>,
	Dave Taht <dave.taht@bufferbloat.net>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:46898 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388Ab3I1RDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 13:03:44 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so3794287pbb.38
        for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 10:03:43 -0700 (PDT)
In-Reply-To: <1380333383-9507-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-27 at 18:56 -0700, Vijay Subramanian wrote:

> +static int pie_qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> +{
> +	struct pie_sched_data *q = qdisc_priv(sch);
> +
> +	if (unlikely(qdisc_qlen(sch) >= sch->limit))
> +		goto out;
> +

...

> +out:
> +	q->stats.overlimit++;
> +	qdisc_drop(skb, sch);
> +	return NET_XMIT_CN;  /*indicate congestion*/
> +}


If a Qdisc drops a packet because sch->limit is hit, you must :

return qdisc_drop(skb, sch);

So that NET_XMIT_DROP is returned, not NET_XMIT_CN.

This packet was dropped for sure.

vi +96 net/sched/sch_api.c

   ---enqueue

   enqueue returns 0, if packet was enqueued successfully.
   If packet (this one or another one) was dropped, it returns
   not zero error code.
   NET_XMIT_DROP        - this packet dropped
     Expected action: do not backoff, but wait until queue will clear.
   NET_XMIT_CN          - probably this packet enqueued, but another one dropped.
     Expected action: backoff or ignore
   NET_XMIT_POLICED     - dropped by police.
     Expected action: backoff or error to real-time apps.
