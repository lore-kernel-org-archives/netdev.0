From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 3/9] net: frag, move LRU list maintenance
 outside of rwlock
Date: Thu, 29 Nov 2012 09:43:24 -0800
Message-ID: <1354211004.3299.12.camel@edumazet-glaptop>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161137.17754.48002.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:36254 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331Ab2K2Rn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 12:43:27 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so5358423dak.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 09:43:27 -0800 (PST)
In-Reply-To: <20121129161137.17754.48002.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 17:12 +0100, Jesper Dangaard Brouer wrote:
> Updating the fragmentation queues LRU (Least-Recently-Used) list,
> required taking the hash writer lock.  However, the LRU list isn't
> tied to the hash at all, so we can use a separate lock for it.
> 
> This change, in it self, does not improve performance significantly.
> But its part of making the fragmentation code scale.


I would just remove the LRU completely.

All this stuff is 20 years old, we dont need it anymore now we can use
more than 64KB of memory. The design was OK on !SMP

Here is what I would suggest :

Use a schem with a hash table of 256 (or 1024) slots.

Each slot/bucket has : 
  - Its own spinlock.
  - List of items
  - A limit of 5 (or so) elems in the list.

No more LRU, no more rehash (thanks to jhash and the random seed at boot
or first frag created), no more reader-writer lock.

Use a percpu_counter to implement ipfrag_low_thresh/ipfrag_high_thresh
