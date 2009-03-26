From: Adam Richter <adam_richter2004@yahoo.com>
Subject: Re: 2.6.29 forcedeth hang W/O NAPI enabled
Date: Thu, 26 Mar 2009 16:29:24 -0700 (PDT)
Message-ID: <56812.58166.qm@web57708.mail.re3.yahoo.com>
References: <20090326065825.GA15730@gondor.apana.org.au>
Reply-To: adam_richter2004@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, berkley@cs.wustl.edu
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web57708.mail.re3.yahoo.com ([68.142.236.71]:37924 "HELO
	web57708.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754544AbZCZX32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 19:29:28 -0400
In-Reply-To: <20090326065825.GA15730@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 3/25/09, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Thanks for testing! Since you also have a forcedeth card,
> could
> you try rebuilding your kernel with FORCEDETH_NAPI enabled
> and
> see if that is stable?

It works so far, doing "ping -f" for more than five minutes while I
browse the web, but bear in mind that I was not able to reproduce the
problem earlier with FORCEDETH_NAPI on demand.  I only saw an ethernet lock up with NAPI enabled once (with the original 2.6.29 code).  I
will let you know if the lockup occurs with your code. 

Just to be clear which version I am now testing, I have attached a
copy of process_backlog() from my net/core/dev.c.

Adam



static int process_backlog(struct napi_struct *napi, int quota)
{
	int work = 0;
	struct softnet_data *queue = &__get_cpu_var(softnet_data);
	unsigned long start_time = jiffies;

	napi->weight = weight_p;
	do {
		struct sk_buff *skb;

		local_irq_disable();
		skb = __skb_dequeue(&queue->input_pkt_queue);
		if (!skb) {
			list_del(&napi->poll_list);
			clear_bit(NAPI_STATE_SCHED, &napi->state);
			local_irq_enable();
			break;
		}
		local_irq_enable();

		napi_gro_receive(napi, skb);
	} while (++work < quota && jiffies == start_time);

	napi_gro_flush(napi);

	return work;
}



      
