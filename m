From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/9] Make dev_hard_start_xmit() work fundamentall on
 lists
Date: Tue, 2 Sep 2014 09:51:20 +0200
Message-ID: <20140902095120.5651ce24@redhat.com>
References: <20140901.152430.1711925724234542172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9493 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272AbaIBHvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 03:51:23 -0400
In-Reply-To: <20140901.152430.1711925724234542172.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Sep 2014 15:24:30 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> After this patch set, dev_hard_start_xmit() will work fundemantally
> on any and all SKB lists.

This is really excellent work, thank you!
dev_hard_start_xmit() looks so clean now :-)

 
> This opens the path for a clean implementation of pulling multiple
> packets out during qdisc_restart(), and then passing that blob
> in one shot to dev_hard_start_xmit().

Sounds perfect.  I'll start to experiment with qdisc stuff.

> And with those two issues out of the way, it should now be trivial to
> build experiments on top of this patch set, all of the framework
> should be there now.  You could do something as simple as:

As xmit_list()/dev_hard_start_xmit() depend on all SKBs belonging to
the same TXQ, below code should also take this into account.

Thus, bulk dequeue will only see the benefit (of taking the qdisc lock
less) when packets are for the same TXQ.  But I guess this is a good
design choice, as this makes the rest of the code simpler to work with.

> 	skb = q->dequeue(q);
> 	if (skb)
> 		skb = validate_xmit_skb(skb, qdisc_dev(q));
> 	if (skb) {
> 		struct sk_buff *new, *head = skb;
> 		int limit = 5;
> 
> 		do {
> 			new = q->dequeue(q);
> 			if (new)
> 				new = validate_xmit_skb(new, qdisc_dev(q));
> 			if (new) {
> 				skb->next = new;
> 				skb = new;
> 			}
> 		} while (new && --limit);
> 		skb = head;
> 	}
> 
> inside of the else branch of dequeue_skb().
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
