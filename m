From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH v2 08/10] net: sched: pfifo_fast use alf_queue
Date: Fri, 15 Jul 2016 12:09:36 +0200
Message-ID: <20160715120936.0b339b2a@redhat.com>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
	<20160714062312.8270.65942.stgit@john-Precision-Tower-5810>
	<20160714171148.3bb7b47b@redhat.com>
	<578829C7.8060604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org, brouer@redhat.com,
	"Michael S. Tsirkin" <mst@redhat.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34922 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753094AbcGOKJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 06:09:41 -0400
In-Reply-To: <578829C7.8060604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jul 2016 17:09:43 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> >>  static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
> >>  			      struct sk_buff **to_free)
> >>  {
> >> -	if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) {
> >> -		int band = prio2band[skb->priority & TC_PRIO_MAX];
> >> -		struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
> >> -		struct sk_buff_head *list = band2list(priv, band);
> >> -
> >> -		priv->bitmap |= (1 << band);
> >> -		qdisc->q.qlen++;
> >> -		return __qdisc_enqueue_tail(skb, qdisc, list);
> >> -	}
> >> +	int band = prio2band[skb->priority & TC_PRIO_MAX];
> >> +	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
> >> +	struct skb_array *q = band2list(priv, band);
> >> +	int err;
> >>  
> >> -	return qdisc_drop(skb, qdisc, to_free);
> >> +	err = skb_array_produce_bh(q, skb);  
> > 
> > Do you need the _bh variant here?  (Doesn't the qdisc run with BH disabled?)
> > 
> >   
> 
> Yep its inside rcu_read_lock_bh().

The call rcu_read_lock_bh() already disabled BH (local_bh_disable()).
Thus, you can use the normal variants of skb_array_produce(), it is
(approx 20 cycles) faster than the _bh variant...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
