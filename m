From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Sun, 27 Mar 2005 16:50:35 +0200
Message-ID: <20050327145035.GH4053@g5.random>
References: <20050324113312W.fujita.tomonori@lab.ntt.co.jp> <1111633846.1548.318.camel@beastie> <20050324215922.GT14202@opteron.random> <424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org> <20050327060403.GE4053@g5.random> <20050327063848.GB15453@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Christie <michaelc@cs.wisc.edu>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        James.Bottomley@HansenPartnership.com, netdev@oss.sgi.com
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20050327063848.GB15453@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 26, 2005 at 10:38:48PM -0800, Matt Mackall wrote:
> What if the number of packets queued by the time we reach the softirq
> side of the stack exceeds the available buffers?

That means they weren't for the iscsi socket and they will be discarded
right away (instead of queueing them in the sock).

> Imagine that we've got heavy DNS and iSCSI on the same box and that the box
> gets wedged in OOM such that it can't answer DNS queries. But we can't
> distinguish at receive time between DNS and iSCSI. As iSCSI is TCP, it

We don't care about performance here, if we're under a flood
attack it'll take a long time but as long as you keep discarding them
right away as soon as you notice the reservation wasn't for the current
sock, it should keep making progress and not deadlock anymore.

This is a deadlock vs non-deadlock issue, how fast the other packets
arrives is a secondary issue, we're in a slow path.

> will send repeat ACKs at relatively long intervals but the DNS clients
> will potentially continue to hammer the machine, filling the reserve
> buffers and starving out the ACKs. We've got to essentially be able to

They won't emtpy it, since they will be released immediatly. From the
ack standpoint it'll be like packet loss due network congestion, infact
this sounds close to network congestion.

> say "we are OOM, drop all traffic to sockets not flagged for storage"
> and do so quickly enough that we can eventually get the ACKs.

To do that you've to reserve a NIC for that. But the whole point of the
algo I proposed is to work fine with shared NIC to avoid the deadlock
too (it won't resolve it in a high performant way, but the issue is that
it won't be a deadlock condition anymore). And if the reserved buffer is
huge likely you won't lose many packets at all.
