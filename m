From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: Fix corrupted queue_mapping
Date: Fri, 08 Jun 2012 09:48:58 +0200
Message-ID: <1339141738.6001.49.camel@edumazet-glaptop>
References: <1339135057.6001.20.camel@edumazet-glaptop>
	 <20120607.230216.2014005732863772019.davem@davemloft.net>
	 <1339135881.6001.25.camel@edumazet-glaptop>
	 <20120607.231501.463746858434969001.davem@davemloft.net>
	 <1339138040.6001.39.camel@edumazet-glaptop>
	 <1339140238.6001.42.camel@edumazet-glaptop>  <4FD1ACE1.4050005@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36203 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757826Ab2FHHtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 03:49:04 -0400
Received: by eeit10 with SMTP id t10so852012eei.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 00:49:03 -0700 (PDT)
In-Reply-To: <4FD1ACE1.4050005@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-08 at 00:42 -0700, John Fastabend wrote:
> On 6/8/2012 12:23 AM, Eric Dumazet wrote:
> > On Fri, 2012-06-08 at 08:47 +0200, Eric Dumazet wrote:
> >> On Thu, 2012-06-07 at 23:15 -0700, David Miller wrote:
> >>> From: Eric Dumazet <eric.dumazet@gmail.com>
> >>> Date: Fri, 08 Jun 2012 08:11:21 +0200
> >>>
> >>>> On Thu, 2012-06-07 at 23:02 -0700, David Miller wrote:
> >>>>> Hmmm, isn't that what qdisc_skb_cb is for?  And even private data is
> >>>>> explicitly allocated:
> >>>>>
> >>>>>>   	unsigned char		data[24];
> >>>>>
> >>>>> there. :-)
> >>>>>
> >>>>
> >>>> Yes, but some other layers can use the same trick so it might collide.
> >>>>
> >>>> Inserting the bond field in qdisc_skb_cb (level0) is safer.
> >>>
> >>> Do you suggest that Infiniband does the same thing? :-)
> >>
> >> I wonder if another way to solve this is not letting ndo_select_queue()
> >> method the responsibility to call skb_set_queue_mapping() itself ?
> >>
> >> (ie removing skb_set_queue_mapping() done in dev_pick_tx())
> >>
> >> bonding would not have to save/restore skb queue mapping ?
> >>
> >> Partial patch : (we have to audit all ndo_select_queue()
> >>
> >> diff --git a/net/core/dev.c b/net/core/dev.c
> >> index cd09819..c6c92d5 100644
> >> --- a/net/core/dev.c
> >> +++ b/net/core/dev.c
> >> @@ -2368,6 +2368,7 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
> >>
> >>   	if (dev->real_num_tx_queues == 1)
> >>   		queue_index = 0;
> >> +		skb_set_queue_mapping(skb, queue_index);
> >>   	else if (ops->ndo_select_queue) {
> >>   		queue_index = ops->ndo_select_queue(dev, skb);
> >>   		queue_index = dev_cap_txqueue(dev, queue_index);
> >> @@ -2391,9 +2392,9 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
> >>   					sk_tx_queue_set(sk, queue_index);
> >>   			}
> >>   		}
> >> +		skb_set_queue_mapping(skb, queue_index);
> >>   	}
> >>
> >> -	skb_set_queue_mapping(skb, queue_index);
> >>   	return netdev_get_tx_queue(dev, queue_index);
> >>   }
> >>
> >>
> >
> >
> > I must say I dont understand dev_pick_tx() anymore.
> >
> > It seems to ignore skb->queue_mapping (unless device provides its own
> > ndo_select_queue() and this functions is aware of skb->queue_mapping, as
> > correctly done in ixgbe)
> >
> > So commit fff3269907897ee (tcp: reflect SYN queue_mapping into SYNACK
> > packets) works on ixgbe, but probably not on other multiqueue devices.
> >
> > This sounds like a regression to me.
> >
> >
> >
> 
> Well it would get picked up via skb_tx_hash(),
> 
>          else if (ops->ndo_select_queue) {
> 		[...]
>          } else {
>                  struct sock *sk = skb->sk;
>                  queue_index = sk_tx_queue_get(sk);
> 
>                  if (queue_index < 0 || skb->ooo_okay ||
>                      queue_index >= dev->real_num_tx_queues) {
>                          int old_index = queue_index;
> 
>                          queue_index = get_xps_queue(dev, skb);
>                          if (queue_index < 0)
>                                  queue_index = skb_tx_hash(dev, skb);
> 	[...]
> 
> 
> So think this might be OK.

Yes, it sounds like sk setting (sk->sk_tx_queue_mapping) has precedence
over skb->queue_mapping.

Not sure how it works for UDP workload for example.
