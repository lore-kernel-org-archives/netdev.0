From: Flavio Leitner <fbl@redhat.com>
Subject: Re: Deliver skbs to intermediate interfaces, when using cascaded
 rx-handlers
Date: Wed, 26 Feb 2014 15:18:57 -0300
Message-ID: <20140226181857.GA7943@t520>
References: <20140221100158.GA19594@gmail.com>
 <20140221171034.GA2488@localhost.localdomain>
 <20140224072223.GA20295@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tobias Waldekranz <tobias@waldekranz.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17644 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbaBZSTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Feb 2014 13:19:00 -0500
Content-Disposition: inline
In-Reply-To: <20140224072223.GA20295@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 24, 2014 at 08:22:23AM +0100, Tobias Waldekranz wrote:
> On Fri, Feb 21, 2014 at 02:10:35PM -0300, Flavio Leitner wrote:
> > On Fri, Feb 21, 2014 at 11:01:58AM +0100, Tobias Waldekranz wrote:
> > > I have a system with the following configuration:
> > > 
> > >    * eth0 is a regular Ethernet MAC, connected to a hardware switch.
> > >    * port[1-4] are the in-kernel representation of the switch.
> > >    * team0 is a regular team-interface which bonds port1 and port2.
> > > 
> > >       +-------+
> > >       | team0 |
> > >       +---+---+
> > >           |
> > >      +----+----+
> > >      |         |
> > >  +---+---+ +---+---+ +-------+ +-------+
> > >  | port1 | | port2 | | port3 | | port4 | 
> > >  +---+---+ +---+---+ +---+---+ +---+---+
> > >      |         |         |         |
> > >      +---------+----+----+---------+
> > >                     |
> > >                 +---+---+
> > >                 | eth0  |
> > >                 +-------+
> > > 
> > > Both the switch and the team driver attaches rx-handlers to their
> > > lower layers. The problem is that team expects LACP frames that
> > > are intercepted by team0, to also be delivered to the port interface
> > > by __netif_receive_skb_core (in the final iteration of the registered
> > > protocols). However in this case, when two rx-handlers are cascaded,
> > > the skb will be delivered to eth0, since that is the original device
> > > (orig_dev).
> > 
> > Indeed. It is not possible to update orig_dev, so it is stuck
> > on eth0 regardless of all the stacked interfaces.
> > 
> > > There are a few ways this can be solved as far as i can see:
> > > 
> > >    1. Introduce a new rx-handler return code that specifies that
> > >    skb->dev has been altered, like RX_HANDLER_ANOTHER, and that we
> > >    also want to change orig_dev to this new device.
> > 
> > But then you need to know which rx-handler will run next, because
> > the orig_dev might still be implicit wanted.
> 
> The next rx-handler is resolved by looking at skb->dev->rx_handler, so
> that shouldn't be a problem. Or am I missing something?

Yes, but all rx_handlers assume that orig_dev is intact and will be
delivered at the end. That will change with this solution and I don't
know if it can break any rx-handler.


> > >    2. Change the switch driver to return RX_HANDLER_CONSUMED and then
> > >    queue the skb all over again, though I am afraid that this will eat
> > >    some cycles.
> > 
> > Before queue again, you need to update skb->dev, right? This seems
> > similar to (1).
> 
> Exactly. It is very similar. The difference is that I would have to
> call netif_rx and go through a lot of code again, instead of taking
> the fast path via the another_round-loop in __netif_receive_skb_core.

Right.

> > >    3. Keep track of all traversed interfaces and change the final
> > >    protocol iteration to deliver the skb to all intermediate devices.
> > 
> > That's what I thought too.
> 
> Ok, so if I provide such a patch, you think it would have a good
> chance of getting accepted?

Well, the final word comes from David and certainly you will need
to justify why fixing DSA isn't enough.

> What are the performance implications of deliver_skb-ing the packet to
> each intermediate layer? Considering that most of those packets will
> probably not be of interest to anyone.

Good question.

fbl
