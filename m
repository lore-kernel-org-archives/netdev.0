From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [net-next PATCH V3-evictor] net: frag evictor, avoid killing
 warm frag queues
Date: Thu, 06 Dec 2012 13:26:00 +0100
Message-ID: <1354796760.20888.217.camel@localhost>
References: <1354319937.20109.285.camel@edumazet-glaptop>
	 <20121204133007.20215.52566.stgit@dragon>
	 <1354699462.20888.207.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26090 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423364Ab2LFM0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2012 07:26:46 -0500
In-Reply-To: <1354699462.20888.207.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-05 at 10:24 +0100, Jesper Dangaard Brouer wrote:
> 
> The previous evictor patch of letting new fragments enter, worked
> amazingly well.  But I suspect, this might also be related to a
> bug/problem in the evictor loop (which were being hidden by that
> patch).

The evictor loop does not contain a bug, just a SMP scalability issue
(which is fixed by later patches).  The first evictor patch, which
does not let new fragments enter, only worked amazingly well because
its hiding this (and other) scalability issues, and implicit allowing
frags already "in" to exceed the mem usage for 1 jiffie.  Thus,
invalidating the patch, as the improvement were only a side effect.


> My new *theory* is that the evictor loop, will be looping too much, if
> it finds a fragment which is INET_FRAG_COMPLETE ... in that case, we
> don't advance the LRU list, and thus will pickup the exact same
> inet_frag_queue again in the loop... to get out of the loop we need
> another CPU or packet to change the LRU list for us... I'll test that
> theory... (its could also be CPUs fighting over the same LRU head
> element that cause this) ... more to come...

The above theory does happen, but does not cause excessive looping.
The CPUs are just fighting about who gets to free the inet_frag_queue
and who gets to unlink it from its data structures (I guess, resulting
cache bouncing between CPUs).

CPUs are fighting for the same LRU head (inet_frag_queue) element,
which is bad for scalability.  We could fix this by unlinking the
element once a CPU graps it, but it would require us to change a
read_lock to a write_lock, thus we might not gain much performance.

I already (implicit) fix this is a later patch, where I'm moving the
LRU lists to be per CPU.  So, I don't know if it's worth fixing.


(And yes, I'm using thresh 4Mb/3Mb as my default setting now, but I'm
also experimenting with other thresh sizes)

p.s. Thank you Eric for being so persistent, so I realized this patch
were not good.  We can hopefully now, move on to the other patches,
which fixes the real scalability issues.

--Jesper
