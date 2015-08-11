From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH 1/3] net: make default tx_queue_len configurable
Date: Tue, 11 Aug 2015 18:23:35 +0200
Message-ID: <20150811162335.GB32353@orbit.nwl.cc>
References: <1438203103-27013-2-git-send-email-phil@nwl.cc>
 <20150729210618.GF32705@breakpoint.cc>
 <20150729213428.GC15554@orbit.nwl.cc>
 <20150729.143731.834219016906219771.davem@davemloft.net>
 <20150811174807.3e00b4da@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, cwang@twopensource.com,
	eric.dumazet@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:42034 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965076AbbHKQXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 12:23:37 -0400
Content-Disposition: inline
In-Reply-To: <20150811174807.3e00b4da@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 05:48:07PM +0200, Jesper Dangaard Brouer wrote:
> 
> On Wed, 29 Jul 2015 14:37:31 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> [...]
> > Which is that there are devices (virtual or whatever) which don't want
> > a qdisc attached no matter what.  Flag those devices as such and
> > adjust the qdisc attachment logic to check that new flag.
> 
> I agree on the approach DaveM are suggesting.
> 
> But virtual devices must support getting a qdisc attached.  I know of
> many companies depending on this behavior.   Some times people just get
> hit by this "strange" zero len issues when they happen to use
> pfifo_fast as leaf node.

That was just how I (purposely mis-)interpreted David's suggestion.

> > Anything is better than hacking the queue len.
> 
> The hole problem comes from the double meaning of the queue len. e.g.
> that value 0 have special meaning, but only during assigning the
> default qdisc.  And pfifo_fast will use queue len zero if assigned.
> 
> (proposed solution:)
> 
> As DaveM also suggested, I would likely use a device flag to indicate
> the device does not require any qdisc, and not assign any qdisc
> (actually "noqueue") in case the default qdisc is chosen for this
> device.
> 
> This should solve the problem for veth. And then we should cleanup all
> the virtual devices, adding this flag and changing the
> dev->tx_queue_len to the default value (e.g. remove setting it to zero).

I have an unfinished solution in the oven, but being kept busy with
other things for now. The action plan is as follows:

1) Introduce IFF_NO_QUEUE net_device->priv_flag.
2) Have attach_default_qdiscs() and attach_one_default_qdisc() treat
   IFF_NO_QUEUE as alternative to tx_queue_len == 0.
3) Add warning to register_netdevice() if tx_queue_len == 0.
4) Change virtual NIC drivers to set IFF_NO_QUEUE and leave tx_queue_len
   alone.
5) Eventually drop all special handling for tx_queue_len == 0.

I am currently somewhere in 2) and need to implement 4) for veth as PoC to
check if 2) suffices in all situations we want. Not sure if 3) is
desireable at all or if there are valid cases for a literally zero
length TX queue length.

Cheers, Phil
