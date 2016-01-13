From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 09/12] net: sched: pfifo_fast use alf_queue
Date: Wed, 13 Jan 2016 10:18:09 -0800
Message-ID: <569694E1.6000109@gmail.com>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>	<20151230175420.26257.868.stgit@john-Precision-Tower-5810> <20160113.112459.133519495867760481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, john.r.fastabend@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35275 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbcAMSSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 13:18:24 -0500
Received: by mail-pf0-f195.google.com with SMTP id 65so6355705pff.2
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 10:18:24 -0800 (PST)
In-Reply-To: <20160113.112459.133519495867760481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-13 08:24 AM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Wed, 30 Dec 2015 09:54:20 -0800
> 
>> This also removes the logic used to pick the next band to dequeue
>> from and instead just checks each alf_queue for packets from
>> top priority to lowest. This might need to be a bit more clever
>> but seems to work for now.
> 
> I suspect we won't need to be more clever, there's only 3 bands
> after all and the head/tail tests should be fast enough.
> 

Even with alf_dequeue operation dequeueing a single skb at a time and
iterating over the bands as I did here I see a perf improvement
on my desktop here,

threads 	     mq + pfifo_fast

		before		after

1		1.70 Mpps	 2.00 Mpps
2		3.15 Mpps	 3.90 Mpps
4		4.70 Mpps	 6.98 Mpps
8		9.57 Mpps	11.62 Mpps

This is using my pktgen patch previously posted and bulking set to
0 in both cases. This doesn't really say anything about the contention
cases, etc so I'll do some more testing before the merge window opens.
Also my kernel isn't really optimized I had some of the kernel hacking
stuff enabled, etc. It at least looks promising though and dequeueing
more than a single skb out of pfifo_fast should help.

Something like,

static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
{
        struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
        struct sk_buff *skb[8+1];
        int band, n = 0, i;

        skb[0] = NULL;

        for (band = 0; band < PFIFO_FAST_BANDS && !skb[0]; band++) {
                struct alf_queue *q = band2list(priv, band);

                if (alf_queue_empty(q))
                        continue;

                n = alf_mc_dequeue(q, skb, 8); <-- 4, 8, or something
        }

.John
