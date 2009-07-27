From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC] Idea about increasing efficency of skb allocation in network
	devices
Date: Sun, 26 Jul 2009 20:36:09 -0400
Message-ID: <20090727003609.GA30438@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45635 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754463AbZG0AgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 20:36:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	I've been thinking of an idea lately, and I'm starting to tinker with
implementation, so I thought before I went to far down any one path, I'd like to
solicit for comments on it, just to avoid early design errors and the like.
Please find my proposal below.  Feel free to openly ridicule it if you think its
completely off base or pointless.  Any and all criticizm welcome.  Thanks!

Problem Statement:
	Currently the networking stack receive path consists of a set of
producers (the network drivers which allocate skbs to receive on the wire data
into), and a set of consumers (user space applications and other networking
devices which free those skbs when their use is finished).  These consumers and
producders are dynamic (additional consumers and producers can be added alsmot
at will within the system).  Currently, there exists an potential inefficiency
in this receive path when using NUMA systems. Given that allocation of skb data
buffers is done with only minimal regard to the NUMA node on which a producer
exists (following standard vm policy in which we try to allocate on the local
node first), it is entirely possible that a consumer of this frame data will
exist on a different NUMA node than the node on which it was allocated. This
disparity leads to slower copying when an application attempts to copy this data
from the kernel, as it must cross a greater number of memory bridges.

Proposed solution:
	Since Network devices dma their memory into a provided DMA buffer (which
can usually be at an arbitrary location, as they must cross potentially several
pci busses to reach any memory location), I'm postulating that it would increase
our receive path efficiency to provide a hint to the driver layer as to which
node to allocate an skb data buffer on.  This hint would be determined by a
feedback mechanism.  I was thinking that we could provide a callback function
via the skb, that accepted the skb and the originating net_device.  This
callback can track statistics on which numa nodes consume (read: copy data from)
skbs that were produced by specific net devices.  Then, when in the future that
netdevice allocates a new skb (perhaps via netdev_alloc_skb), we can use that
statistical profile to determine if the data buffer should be allocated on the
local node, or on a remote node instead.  Ideally, this 'consumer based
allocation bias' would allow us to reduce the amount of time it takes to
transfer recieved buffers to user space and make the overall receive path more
efficient.  I see lots of opportunity here to develop tools to measure the
speedup this might provide (perhaps via ftrace plugins), as well as various
algorithms to better predict how to allocate skb's on various nodes.

	
	Obviously, the code is going to do the talking here, but I wanted to get
the idea out there so that I anyone who wanted to could point out anything
obvious that would lead to the conclusion that I was nuts.  Feel free to tear it
all apart, or, on the off chance that this has legs, suggestions for
improvements/features that you might like.

Thanks!
Neil

