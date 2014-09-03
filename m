From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] qdisc: validate frames going through the
 direct_xmit path
Date: Wed, 03 Sep 2014 08:22:07 -0700
Message-ID: <1409757727.26422.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140902225548.885.79277.stgit@ahduyck-bv4.jf.intel.com>
	 <20140903114841.19969.22671.stgit@dragon>
	 <1409751805.26422.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140903155213.62ff4eff@redhat.com> <20140903162628.3d05f113@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35889 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756108AbaICPWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 11:22:14 -0400
Received: by mail-pa0-f44.google.com with SMTP id rd3so17822340pab.3
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 08:22:09 -0700 (PDT)
In-Reply-To: <20140903162628.3d05f113@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-03 at 16:26 +0200, Jesper Dangaard Brouer wrote:
> On Wed, 3 Sep 2014 15:52:13 +0200
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
> > On Wed, 03 Sep 2014 06:43:25 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> > > 
> > > Jesper, you missed another spot, when there is no qdisc on the device.
> > > 
> > > __dev_queue_xmit() calls dev_hard_start_xmit() around line 2886
> > > 
> > > Could we try to not add a myriad of small patches ?
> > > 
> > > Some of us will need to backport all of them.
> > 
> > I'm in the same backport situation ;-)
> > 
> > I'll send a V2 of this patch, with missed spot...
> 
> (to avoid doing too many patches)
> 
> In the code below (from __dev_queue_xmit()), I've added validate_xmit_skb().
> (dev_hard_start_xmit() can handle if it is a NULL ptr)
> 
> 	HARD_TX_LOCK(dev, txq, cpu);
> 	if (!netif_xmit_stopped(txq)) {
> 		skb = validate_xmit_skb(skb, dev);
> 		__this_cpu_inc(xmit_recursion);
> 		skb = dev_hard_start_xmit(skb, dev, txq, &rc);
> 		__this_cpu_dec(xmit_recursion);
> 		if (dev_xmit_complete(rc)) {
> 			HARD_TX_UNLOCK(dev, txq);
> 			goto out;
> 		}
> 	}
> 	HARD_TX_UNLOCK(dev, txq);
> 	net_crit_ratelimited("Virtual device %s asks to queue packet!\n",
> 					     dev->name);
> BUT shouldn't we also handle if dev_hard_start_xmit() returns an skb pointer,
> which means that there were skb's left on the skb list.  Due to the rc
> value "returned" in this case, we should see the net_crit_ratelimited()
> msg, but we don't handle freeing these SKBs.
> 
> Any recommentations?
> 

First I would do the validate_xmit_skb() before HARD_TX_LOCK(dev, txq,
cpu)

Then, if we have skbs that could not be transmitted, we need to free
them (and possibly account the drops on the device tx_dropped). Logging
a one time message would be enough.

Thanks
