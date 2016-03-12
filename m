From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: userns, netns, and quick physical memory consumption by
 unprivileged user
Date: Sat, 12 Mar 2016 12:41:40 +0100
Message-ID: <20160312114140.GA2023@salvia>
References: <m3d1rclioc.fsf@gmail.com>
 <m3r3fhhx4c.fsf@gmail.com>
 <20160311153406.GB6620@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Yuriy M. Kaminskiy" <yumkam@gmail.com>, netdev@vger.kernel.org,
	containers@lists.osdl.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160311153406.GB6620@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 11, 2016 at 04:34:06PM +0100, Florian Westphal wrote:
> Yuriy M. Kaminskiy <yumkam@gmail.com> wrote:
> > BTW, all those hash/conntrack/etc default sizes was calculated from
> > physical memory size in assumption there will be only *one* instance of
> > those tables. Obviously, introduction of network namespaces (and
> > especially unprivileged user-ns) thrown this assumption in the window
> > (and here comes that "falling back to vmalloc" message again; in pre-netns
> > world, those tables were allocated *once* on early system startup, with
> > typically plenty of free and unfragmented memory).
> 
> No idea how to fix this expect by removing conntrack support in net
> namespaces completely.
> 
> I'd disallow all write accesses to skb->nfct (NAT, CONNMARK,
> CONNSECMARK, ...) and then no longer clear skb->nfct when forwarding
> packet from init_ns to container.
> 
> Containers could then still test conntrack as seen from init namespace pov
> in PREROUTING/FORWARD/INPUT (but not OUTPUT, obviously).
> 
> [ OUTPUT *might* be doable as well by allowing NEW creation in output
>   but skipping nat and deferring the confirmation/commit of the new
>   entry to the table until skb leaves initns ]
> 
> We could key conntrack entries to initns conntrack table
> instead of adding one new table per netns, but seems like this only
> replaces one problem with a new one (filling/blocking initns table from
> another netns).

We can add a global perns limit in terms of conntrack entries that can
only be set via CAP_NET_ADMIN from the initns. Thus, we avoid the
filling/blocking from another netns, or hide this knob to
unpriviledged userns somehow.

In the previous netfilter workshop I remember we agreed on going
towards having a single conntrack table for netns, so I suggest we
follow that direction.
