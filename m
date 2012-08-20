From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression with poll(2)
Date: Mon, 20 Aug 2012 10:07:53 +0200
Message-ID: <1345450073.5158.272.camel@edumazet-glaptop>
References: <alpine.DEB.2.00.1208151226250.15721@cobra.newdream.net>
	 <alpine.DEB.2.00.1208191051150.15570@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mgorman@suse.de, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
	neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu,
	emunson@mgebm.net, sebastian@breakpoint.cc, cl@linux.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Sage Weil <sage@inktank.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1208191051150.15570@cobra.newdream.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-08-19 at 11:49 -0700, Sage Weil wrote:
> I've bisected and identified this commit:
> 
>     netvm: propagate page->pfmemalloc to skb
>     
>     The skb->pfmemalloc flag gets set to true iff during the slab allocation
>     of data in __alloc_skb that the the PFMEMALLOC reserves were used.  If the
>     packet is fragmented, it is possible that pages will be allocated from the
>     PFMEMALLOC reserve without propagating this information to the skb.  This
>     patch propagates page->pfmemalloc from pages allocated for fragments to
>     the skb.
>     
>     Signed-off-by: Mel Gorman <mgorman@suse.de>
>     Acked-by: David S. Miller <davem@davemloft.net>
>     Cc: Neil Brown <neilb@suse.de>
>     Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
>     Cc: Mike Christie <michaelc@cs.wisc.edu>
>     Cc: Eric B Munson <emunson@mgebm.net>
>     Cc: Eric Dumazet <eric.dumazet@gmail.com>
>     Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
>     Cc: Mel Gorman <mgorman@suse.de>
>     Cc: Christoph Lameter <cl@linux.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> I've retested several times and confirmed that this change leads to the 
> breakage, and also confirmed that reverting it on top of -rc1 also fixes 
> the problem.
> 
> I've also added some additional instrumentation to my code and confirmed 
> that the process is blocking on poll(2) while netstat is reporting 
> data available on the socket.
> 
> What can I do to help track this down?
> 
> Thanks!
> sage
> 
> 
> On Wed, 15 Aug 2012, Sage Weil wrote:
> 
> > I'm experiencing a stall with Ceph daemons communicating over TCP that 
> > occurs reliably with 3.6-rc1 (and linus/master) but not 3.5.  The basic 
> > situation is:
> > 
> >  - the socket is two processes communicating over TCP on the same host, e.g. 
> > 
> > tcp        0 2164849 10.214.132.38:6801      10.214.132.38:51729     ESTABLISHED
> > 
> >  - one end writes a bunch of data in
> >  - the other end consumes data, but at some point stalls.
> >  - reads are nonblocking, e.g.
> > 
> >   int got = ::recv( sd, buf, len, MSG_DONTWAIT );
> > 
> >  and between those calls we wait with
> > 
> >   struct pollfd pfd;
> >   short evmask;
> >   pfd.fd = sd;
> >   pfd.events = POLLIN;
> > #if defined(__linux__)
> >   pfd.events |= POLLRDHUP;
> > #endif
> > 
> >   if (poll(&pfd, 1, msgr->timeout) <= 0)
> >     return -1;
> > 
> >  - in my case the timeout is ~15 minutes.  at that point it errors out, 
> > and the daemons reconnect and continue for a while until hitting this 
> > again.
> > 
> >  - at the time of the stall, the reading process is blocked on that 
> > poll(2) call.  There are a bunch of threads stuck on poll(2), some of them 
> > stuck and some not, but they all have stacks like
> > 
> > [<ffffffff8118f6f9>] poll_schedule_timeout+0x49/0x70
> > [<ffffffff81190baf>] do_sys_poll+0x35f/0x4c0
> > [<ffffffff81190deb>] sys_poll+0x6b/0x100
> > [<ffffffff8163d369>] system_call_fastpath+0x16/0x1b
> > 
> >  - you'll note that the netstat output shows data queued:
> > 
> > tcp        0 1163264 10.214.132.36:6807      10.214.132.36:41738     ESTABLISHED
> > tcp        0 1622016 10.214.132.36:41738     10.214.132.36:6807      ESTABLISHED
> > 

In this netstat output, we can see some data in output queues, but no
data on receive queues. poll() is OK.

Some TCP frames are not properly delivered, even after a retransmit.

( to see useful stats/counters : ss -emoi dst 10.214.132.36)

For loopback transmits, skbs are taken from the output queue, cloned and
feeded to local stack.

If they have the pfmemalloc bit, they wont be delivered to normal
sockets, but dropped.

tcp_sendmsg() seems to be able to queue skbs with pfmemalloc set to
true, and this makes no sense to me.
