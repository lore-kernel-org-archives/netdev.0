From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [net-next PATCH V3-evictor] net: frag evictor, avoid killing
 warm frag queues
Date: Thu, 06 Dec 2012 14:55:00 +0100
Message-ID: <1354802100.20888.242.camel@localhost>
References: <1354319937.20109.285.camel@edumazet-glaptop>
	 <20121204133007.20215.52566.stgit@dragon>
	 <1354699462.20888.207.camel@localhost>
	 <1354796760.20888.217.camel@localhost>
	 <20121206123248.GA24493@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754771Ab2LFNzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2012 08:55:48 -0500
In-Reply-To: <20121206123248.GA24493@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-06 at 13:32 +0100, Florian Westphal wrote:
> Jesper Dangaard Brouer <jbrouer@redhat.com> wrote:
> > CPUs are fighting for the same LRU head (inet_frag_queue) element,
> > which is bad for scalability.  We could fix this by unlinking the
> > element once a CPU graps it, but it would require us to change a
> > read_lock to a write_lock, thus we might not gain much performance.
> > 
> > I already (implicit) fix this is a later patch, where I'm moving the
> > LRU lists to be per CPU.  So, I don't know if it's worth fixing.
> 
> Do you think its worth trying to remove the lru list altogether and
> just evict from the hash in a round-robin fashion instead?

Perhaps.  But do note my bashing of the LRU list were wrong.  I planned
to explain that in a separate mail, but basically I were causing a DoS
attack with incomplete fragments on my self, because I had disabled
Ethernet flow-control.  Which led me to some false assumptions on the
LRU list behavior (sorry).

The LRU might be the correct solution after all.  If I enable Ethernet
flow-control again, then I have a hard time "activating" the evictor
code (with thresh 4M/3M) .  I'll need a separate DoS program, which can
send incomplete fragments (in back-to-back bursts) to provoke the
evictor and LRU.

My cheap DoS reproducer-hack is to disable Ethernet flow-control on only
one interface (out of 3), to cause packet drops and the incomplete
fragments. The current preliminary results is that the two other
interfaces still gets packets through, we don't get the zero throughput
situation.
 Two interfaces and no DoS: 15342 Mbit/s
 Three interfaces and DoS:   7355 Mbit/s

The reduction might look big, but you have to take into account, that
"activating" the evictor code, is also causing scalability issues of its
own (which could account for the performance drop it self).

--Jesper
