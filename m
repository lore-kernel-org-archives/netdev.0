From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] dql: add a burst attribute
Date: Tue, 30 Sep 2014 08:41:00 -0700
Message-ID: <1412091660.30721.93.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140930085114.24043.81310.stgit@dragon>
	 <1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140930134655.GA24565@breakpoint.cc>
	 <1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140930152651.GC24565@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33230 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbaI3PlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 11:41:04 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so1002219pde.36
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 08:41:03 -0700 (PDT)
In-Reply-To: <20140930152651.GC24565@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 17:26 +0200, Florian Westphal wrote:

> So you're saying that a bulk dequeue should just grab as many skbs
> as possible until no more available or dql_avail exhausted?
> 

This was certainly the intent.


> The "magic" value was just to be conservative and not induce any
> hol blocking, which is also why Jesper reduced it again in the latest
> submission.

Think about whats happening here.

BQL controls the optimal queue _in_ the NIC TX ring, given latencies and
throughput goals.

Once packets are queued in the NIC TX ring, there is no way a high prio
packet can be injected ahead of them, unless NIC has separate TX ring
for different prio already.

There is no need redoing this in another layer. BQL logic was hard to
setup and tune, I have no idea why you want to reinvent it.

> 
> Then, we might later be able to remove the TSO restriction and switch
> to a pure byte-based limit

Why later ? If it is not needed now, it should not be added 'to be safe'

> .
> 
> (I don't think having a packet-based count makes sense once tso/gso
>  skbs can be bulk dequeued).

So do not add this limit, so that we can spot bugs ahead of time.

If some NIC wants a 'doorbell at least once every 8 packets', then the
NIC driver should be fixed.
