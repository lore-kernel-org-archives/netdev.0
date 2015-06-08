From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Mon, 8 Jun 2015 10:53:09 -0600
Message-ID: <20150608165309.GA3042@obsidianresearch.com>
References: <1432850150.114391.56.camel@redhat.com>
 <556ED0D5.8010502@mellanox.com>
 <20150603161447.GC12073@obsidianresearch.com>
 <CAJ3xEMjM53sYuEgQV3WPaN4WErk_YcojPY2zBcmq-+3W2dfD+A@mail.gmail.com>
 <20150603195325.GC7902@obsidianresearch.com>
 <CAJ3xEMiO+hEzOJ2oJ5G-mmBeaX4ZHvUyhNSAzsrRDui6dFjvCg@mail.gmail.com>
 <20150603234811.GA15128@obsidianresearch.com>
 <556FEF25.80409@mellanox.com>
 <20150604164058.GB27699@obsidianresearch.com>
 <557549C2.2080605@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:60734 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278AbbFHQxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2015 12:53:14 -0400
Content-Disposition: inline
In-Reply-To: <557549C2.2080605@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 08, 2015 at 10:52:34AM +0300, Haggai Eran wrote:
> On 04/06/2015 19:40, Jason Gunthorpe wrote:
> > Discussion idea: Can we actually use the netstack to process the
> > RDMA-CM packets? It looks like the netstack wants a skb to do this
> > mid-layer work, so rdma-cm would have to synthesize a skb for the CM
> > packets and pass it through netdev to apply all the transformations
> > and access the various internal states (eg from ipvlan, bonding,
> > etc). rdma-cm would have to 'catch' the skb once it is done traveling
> > and resume its normal processing. Very similar to your notion of using
> > UDP, but without any on-the-wire change.
> > 
> > This would fit in that same ingress spot I suggested adding the
> > routing lookup, instead of routing we want the full stack to have a go
> > at figuring out the final netdev.
> > 
> > This seems the most general because it will work for all the *vlan
> > type drivers, bonding, and all of the RDMA technologies. (each would
> > have a slightly different way to make the skb, but same basic idea)
> > 
> > Lots and lots of details to do that, but conceptually it seems pretty
> > solid?
> 
> The problem is that the network stack can do all sort of changes to the
> packets (like NAT), and it may be the case that the hardware can't
> reflect these changes later on when creating a QP.

Yes, I am aware of that, but there are also alot of things netdev can
do that we can realize, like netfilter rules to block packets, for
instance

Ignoring NAT is a bad choice as well, the best would be to drop on
NAT. It would be easy to detect if the netstack mangled the REQ skb
packet, for instance.

We can't track netdev after the QP is created, but totally ignoring
one thing and while re-implementing others seems like a bad idea, long
term...

> I think it would be best to stick with resolving the net_dev using
> the request parameters, and the simpler routing lookup. This way
> RDMA CM remains in control, and if the user configures routing in an
> unexpected way, it can just block the request.

As I said, I think that is fine for the immediate IB support, but when
you start talking about roce and emulating macvlan and ipvlan.. Then
it starts to look really bad. At least think it through carefully
before posting those series.

Jason
