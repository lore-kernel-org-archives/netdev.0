From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V3-evictor] net: frag evictor, avoid killing
 warm frag queues
Date: Tue, 04 Dec 2012 06:47:27 -0800
Message-ID: <1354632447.1388.150.camel@edumazet-glaptop>
References: <1354319937.20109.285.camel@edumazet-glaptop>
	 <20121204133007.20215.52566.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64571 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764Ab2LDOra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 09:47:30 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so2882037pbc.19
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2012 06:47:30 -0800 (PST)
In-Reply-To: <20121204133007.20215.52566.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-04 at 14:30 +0100, Jesper Dangaard Brouer wrote:
> The fragmentation evictor system have a very unfortunate eviction
> system for killing fragment, when the system is put under pressure.
> 
> If packets are coming in too fast, the evictor code kills "warm"
> fragments too quickly.  Resulting in close to zero throughput, as
> fragments are killed before they have a chance to complete
> 
> This is related to the bad interaction with the LRU (Least Recently
> Used) list.  Under load the LRU list sort-of changes meaning/behavior.
> When the LRU head is very new/warm, then the head is most likely the
> one with most fragments and the tail (latest used or added element)
> with least.
> 
> Solved by, introducing a creation "jiffie" timestamp (creation_ts).
> If the element is tried evicted in same jiffie, then perform tail drop
> on the LRU list instead.
> 
> Signed-off-by: Jesper Dangaard Brouer <jbrouer@redhat.com>

This would only 'work' if a reassembled packet can be done/completed
under one jiffie.

For 64KB packets, this means 100Mb link wont be able to deliver a
reassembled packet under IP frags load if HZ=1000

LRU goal is to be able to select the oldest inet_frag_queue, because in
typical networks, packet losses are really happening and this is why
some packets wont complete their reassembly. They naturally will be
found on LRU head, and they probably are very fat (for example a single
packet was lost for the inet_frag_queue)

Choosing the most recent inet_frag_queue is exactly the opposite
strategy. We pay the huge cost of maintaining a central LRU, and we
exactly misuse it.

As long as an inet_frag_queue receives new fragments and is moved to the
LRU tail, its a candidate for being kept, not a candidate for being
evicted.

Only when an inet_frag_queue is the oldest one, it becomes a candidate
for eviction.

I think you are trying to solve a configuration/tuning problem by
changing a valid strategy.

Whats wrong with admitting high_thresh/low_thresh default values should
be updated, now some people apparently want to use IP fragments in
production ?

Lets say we allow to use 1 % of memory for frags, instead of the current
256 KB limit, which was chosen decades ago.

Only in very severe DOS attacks, LRU head 'creation_ts' would possibly
be <= 1ms. And under severe DOS attacks, I am afraid there is nothing we
can do.

(We could eventually avoid LRU hassle and chose instead a random drop
strategy)

high_thresh/low_thresh should be changed from 'int' to 'long' as well,
so that a 64bit host could use more than 2GB for frag storage.
