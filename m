From: Paolo Valente <paolo.valente@unimore.it>
Subject: Re: [PATCH] pkt_sched: QFQ Plus: fair-queueing service at DRR cost
Date: Wed, 21 Nov 2012 10:45:14 +0100
Message-ID: <50ACA2AA.1020206@unimore.it>
References: <20121120174513.GA21618@paolo-ThinkPad-W520> <20121120.135409.1810847883436963918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121120.135409.1810847883436963918.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Il 20/11/2012 19:54, David Miller ha scritto:
> From: Paolo Valente <paolo.valente@unimore.it>
> Date: Tue, 20 Nov 2012 18:45:13 +0100
>
>> -	struct sk_buff *skb;
>> +	struct sk_buff *skb = NULL;
>
> This is not really an improvement,
Sorry for trying this silly short cut
  now the compiler can think
> that NULL is passed eventually into qdisc_bstats_update().
>
> Please make the logic easier for the compiler to digest.
>
> For example, restructure the top-level logic into something like:
>
> 	skb = NULL;
> 	if (!list_empty(&in_serv_agg->active))
> 		skb = qfq_peek_skb(in_serv_agg, &cl, &len);
> 	else
> 		len = 0; /* no more active classes in the in-service agg */
>
> 	if (len == 0 || in_serv_agg->budget < len) {
>   ...
> 		/*
> 		 * If we get here, there are other aggregates queued:
> 		 * choose the new aggregate to serve.
> 		 */
> 		in_serv_agg = q->in_serv_agg = qfq_choose_next_agg(q);
> 		skb = qfq_peek_skb(in_serv_agg, &cl, &len);
> 	}
> 	if (!skb)
> 		return NULL;
>
> That way it is clearer, to both humans and the compiler, what is
> going on here.
>
Got it. Actually, if the first qfq_peek_skb returns NULL, then the 
example version that you are proposing apparently may behave in a 
different way than the original one: in your proposal the scheduler 
tries to switch to a new aggregate and may return a non-NULL value, 
whereas the original version would immediately return NULL. I guess that 
this slightly different behavior is fine as well, and I am preparing a 
new patch that integrates these changes.
> Thanks.
>


-- 
-----------------------------------------------------------
| Paolo Valente              |                            |
| Algogroup                  |                            |
| Dip. Ing. Informazione     | tel:   +39 059 2056318     |
| Via Vignolese 905/b        | fax:   +39 059 2056129     |
| 41125 Modena - Italy       |                            |
|     home:  http://algo.ing.unimo.it/people/paolo/       |
-----------------------------------------------------------
