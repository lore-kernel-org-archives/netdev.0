From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 23:25:01 -0700 (PDT)
Message-ID: <20060426.232501.119306252.davem@davemloft.net>
References: <200604261147.34221.kelly@au.ibm.com>
	<20060426.003335.26972263.davem@davemloft.net>
	<200604271331.37073.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12494
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964962AbWD0GZS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 02:25:18 -0400
To: kelly@au1.ibm.com
In-Reply-To: <200604271331.37073.kelly@au.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kelly Daly <kelly@au1.ibm.com>
Date: Thu, 27 Apr 2006 13:31:37 +1000

> It should be quite trivial to resize this pool using RCU.

Yes, a lot of this stuff can use RCU, in particular the channel
demux is a prime candidate.

There are some non-trivial issues wrt. synchronizing the net
channel lookup state with socket state changes (socket moves to
close or whatever).  This reminds me that we had some nice TCP
hash table RCU patches that Ben LaHaise posted at one point and
that slipped through the cracks.  That took care of all the event
ordering issues, it seemed at the time, and is something we need
to get back on track with.

> The tail pointers are an excellent idea - and they certainly fix a
> lot of compatibility issues that we side-stepped (we were going for
> the "make it work" approach rather than the "make it right" -
> figured we could get to that bit later =P ).

Start simple, we can keep mucking with the interfaces over and over
again as we move from simple netif_receive_skb() channels out to the
more complex socket demux style channel.

This is a big and long project, there are no style points for trying
to go all the way in the first pass :-)

> We approached this from the understanding that an intelligent NIC
> will be able to transition directly to userspace, which is a major
> win.  0 copies to userspace would be sweet.  I think we can still
> achieve this using your scheme without *too* much pain.

Understood.  What's your basic idea?  Just make the buffers in the
pool large enough to fit the SKB encapsulation at the end?

Note that this will change a lot of the assumptions currently in
your buffer handling code about buffer reuse and such.

So the idea in your scheme is to give the buffer pools to the NIC
in a per-channel way via a simple descriptor table?  And the u32's
are arbitrary keys that index into this descriptor table, right?

I would suggest just sticking to the simple global input queue.
Solve the easy problems and the buffering model first.  Then we
can port drivers and people can bang on the basic infrastructure.
Take my SKB encapsulator in my vj-2.6 tree once you've transformed
your buffer pools to accomodate.

I'll actually sit back and let you do that, I'm actually coming around
more to your scheme in some regards :-)  I'll sit and think about some
of the heavier issues we'll hit in the next phase and once you have
a cut at the current phase I'll work on a tg3 driver port.

Thanks!
