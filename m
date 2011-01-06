From: Simon Horman <horms@verge.net.au>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Thu, 6 Jan 2011 21:29:02 +0900
Message-ID: <20110106122859.GA13253@verge.net.au>
References: <20110106093312.GA1564@verge.net.au>
 <20110106102755.GC12142@redhat.com>
 <20110106113052.GA2541@verge.net.au>
 <20110106120722.GD12142@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	Jesse Gross <jesse@nicira.com>, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:33062 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312Ab1AFM3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 07:29:07 -0500
Content-Disposition: inline
In-Reply-To: <20110106120722.GD12142@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 06, 2011 at 02:07:22PM +0200, Michael S. Tsirkin wrote:
> On Thu, Jan 06, 2011 at 08:30:52PM +0900, Simon Horman wrote:
> > On Thu, Jan 06, 2011 at 12:27:55PM +0200, Michael S. Tsirkin wrote:
> > > On Thu, Jan 06, 2011 at 06:33:12PM +0900, Simon Horman wrote:
> > > > Hi,
> > > > 
> > > > Back in October I reported that I noticed a problem whereby flow control
> > > > breaks down when openvswitch is configured to mirror a port[1].
> > > 
> > > Apropos the UDP flow control.  See this
> > > http://www.spinics.net/lists/netdev/msg150806.html
> > > for some problems it introduces.
> > > Unfortunately UDP does not have built-in flow control.
> > > At some level it's just conceptually broken:
> > > it's not present in physical networks so why should
> > > we try and emulate it in a virtual network?
> > > 
> > > 
> > > Specifically, when you do:
> > > # netperf -c -4 -t UDP_STREAM -H 172.17.60.218 -l 30 -- -m 1472
> > > You are asking: what happens if I push data faster than it can be received?
> > > But why is this an interesting question?
> > > Ask 'what is the maximum rate at which I can send data with %X packet
> > > loss' or 'what is the packet loss at rate Y Gb/s'. netperf has
> > > -b and -w flags for this. It needs to be configured
> > > with --enable-intervals=yes for them to work.
> > > 
> > > If you pose the questions this way the problem of pacing
> > > the execution just goes away.
> > 
> > I am aware that UDP inherently lacks flow control.
> 
> Everyone's is aware of that, but this is always followed by a 'however'
> :).
> 
> > The aspect of flow control that I am interested in is situations where the
> > guest can create large amounts of work for the host. However, it seems that
> > in the case of virtio with vhostnet that the CPU utilisation seems to be
> > almost entirely attributable to the vhost and qemu-system processes.  And
> > in the case of virtio without vhost net the CPU is used by the qemu-system
> > process. In both case I assume that I could use a cgroup or something
> > similar to limit the guests.
> 
> cgroups, yes. the vhost process inherits the cgroups
> from the qemu process so you can limit them all.
> 
> If you are after limiting the max troughput of the guest
> you can do this with cgroups as well.

Do you mean a CPU cgroup or something else?

> > Assuming all of that is true then from a resource control problem point of
> > view, which is mostly what I am concerned about, the problem goes away.
> > However, I still think that it would be nice to resolve the situation I
> > described.
> 
> We need to articulate what's wrong here, otherwise we won't
> be able to resolve the situation. We are sending UDP packets
> as fast as we can and some receivers can't cope. Is this the problem?
> We have made attempts to add a pseudo flow control in the past
> in an attempt to make UDP on the same host work better.
> Maybe they help some but they also sure introduce problems.

In the case where port mirroring is not active, which is the
usual case, to some extent there is flow control in place due to
(as Eric Dumazet pointed out) the socket buffer.

When port mirroring is activated the flow control operates based
only on one port - which can't be controlled by the administrator
in an obvious way.

I think that it would be more intuitive if flow control was
based on sending a packet to all ports rather than just one.

Though now I think about it some more, perhaps this isn't the best either.
For instance the case where data was being sent to dummy0 and suddenly
adding a mirror on eth1 slowed everything down.

So perhaps there needs to be another knob to tune when setting
up port-mirroring. Or perhaps the current situation isn't so bad.
