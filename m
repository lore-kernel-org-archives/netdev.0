From: "David S. Miller" <davem@redhat.com>
Subject: Re: e100 "Ferguson" release
Date: Sun, 3 Aug 2003 20:08:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030803200851.7d46a605.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com>
	<3F2CA65F.8060105@pobox.com>
	<3F2CBA71.2070503@candelatech.com>
	<20030803003239.4257ef24.davem@redhat.com>
	<3F2DCE56.6030601@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, jgarzik@pobox.com, scott.feldman@intel.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <3F2DCE56.6030601@pacbell.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 03 Aug 2003 20:09:10 -0700
David Brownell <david-b@pacbell.net> wrote:

> David S. Miller wrote:
> >>Although I have not tried this latest patch, the existing e100 and e1000 in
> >>2.4.21 seldom seem to return true to this method:  netif_queue_stopped(odev),
> >>even when the next hard_start_xmit() call fails.
> > 
> > 
> > Returning an error from hard_start_xmit() from normal ethernet
> > drivers is, frankly, a driver bug and should never happen.
> 
> What's "normal" mean?

One that can manage it's own TX resources.

> With the current USB stack, network adapters tend to need
> memory allocations there.  Those can fail, though it seems
> that's not very common.  Doesn't seem like a bug, for all
> that I'd rather see the those paths be zero-alloc in 2.7.

Any particular reason why the SKB data itself can't be
mapped directly?  We created all of these DMA mapping
abstractions remember? :-)

Another option is to pre-allocate, such that while the TX
queue is awake we know we have enough resources to send any
given packet.  Then in ->hard_start_xmit() after using a buffer
we allocate a replacement buffer, if this fails in such a way
that a subsequent ->hard_start_xmit() could possibly fail, we
do netif_stop_queue().

Look to tg3 to see what I'm talking about in general.
netif_stop_queue() is done at the moment at which it may be possible
that we cannot accept the queueing of a TX packet.  This means that
when TX entries available <= MAX_SKB_FRAGS + 1, we stop the queue.
This guarentees that we will always be able to handle any packet given
to us via ->hard_start_xmit().
