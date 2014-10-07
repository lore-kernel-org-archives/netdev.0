From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Quota in __qdisc_run()
Date: Tue, 7 Oct 2014 20:03:29 +0200
Message-ID: <20141007200329.5d20a27e@redhat.com>
References: <20141007153050.792c9743@redhat.com>
	<1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
	<1412694080.11091.131.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141007.131938.1410434352331637585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, therbert@google.com, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk,
	brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753608AbaJGSWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 14:22:34 -0400
In-Reply-To: <20141007.131938.1410434352331637585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Oct 2014 13:19:38 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 07 Oct 2014 08:01:20 -0700
> 
> > On Tue, 2014-10-07 at 16:43 +0200, Hannes Frederic Sowa wrote:
> > 
> >> This needs to be:
> >> 
> >> do
> >>    ...
> >> while ((iskb = iskb->next))
> > 
> > I do not feel needed to break the bulk dequeue at precise quota
> > boundary. These quotas are advisory, and bql prefers to get its full
> > budget for appropriate feedback from TX completion.
> > 
> > Quota was a packet quota, which was quite irrelevant if segmentation had
> > to be done, so I would just let the dequeue be done so that we benefit
> > from optimal xmit_more.
> 
> Yes, this makes sense, do a full qdisc_restart() cycle without boundaries,
> then check how much quota was used afterwards to guard the outermost loop.

According to my measurements, at 10Gbit/s TCP_STREAM test the BQL limit
is 381528 bytes / 1514 = 252 packets, that will (potentially) be bulk
dequeued at once (with your version of the patch).

It seems to have the potential to exceed the weight_p(64) quite a lot.
And with e.g. TX ring size 512, we also also challenge the drivers at
this early adoption phase of tailptr writes.  Just saying...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
