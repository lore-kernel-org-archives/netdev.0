From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 2/8] sfc: batch up RX delivery on EF10
Date: Tue, 19 Apr 2016 10:20:40 -0700
Message-ID: <1461086440.10638.208.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5716338E.4050003@solarflare.com>
	 <57163404.2000507@solarflare.com>
	 <1461077257.10638.185.camel@edumazet-glaptop3.roam.corp.google.com>
	 <57165E73.60402@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33595 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbcDSRUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 13:20:40 -0400
Received: by mail-pf0-f179.google.com with SMTP id 184so8833220pff.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 10:20:40 -0700 (PDT)
In-Reply-To: <57165E73.60402@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-19 at 17:36 +0100, Edward Cree wrote:

> > We have to really invent something better, like a real pipeline, instead
> > of hacks like this, adding complexity everywhere.
> I'm not sure what you mean by 'a real pipeline' in this context, could you
> elaborate?
> 
> > Have you tested this on cpus with tiny caches, like 32KB ?
> I haven't.  Is the concern here that the first packet's headers (we read 128
> bytes into the linear area) and/or skb will get pushed out of the dcache as
> we process further packets?
> 
> At least for sfc, it's highly unlikely that these cards will be used in low-
> powered systems.  For the more general case, I suppose the answer would be a
> tunable to set the maximum length of the RX list to less than the NAPI budget.
> Fundamentally this kind of batching is trading dcache usage for icache usage.
> 
> 
> Incidentally, this patch is very similar to what Jesper proposed for mlx5 in
> an RFC back in February: http://article.gmane.org/gmane.linux.network/397379
> So I'm a little surprised this bit is controversial, though I'm not surprised
> the rest of the series is ;)

It seems all the discussions about fast kernel networking these days is
adding yet another queues, code duplication and complexity, batches, and
add latencies, on top of a single NIC RX queue.

Apparently the multiqueue nature of a NIC is obsolete and people want to
process 10+Mpps on a single queue.

But in the end, we do not address fundamental issues, like number of
cache line misses per incoming TCP packet, and per outgoing TCP packet.
(Or UDP if that matters).
Number of atomic ops to synchronize all accesses to common resources.
(memory, queue limits, queues)

Also issues with dealing with all the queues (percpu backlog in
net/core/dev.c, socket backlog, prequeue for TCP, ...)

We could probably get ~100% improvement in UDP if we really cared, just
by changing net/ipv[46]/udp.c, not changing other layers.
