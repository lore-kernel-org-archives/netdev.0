From: Florian Westphal <fw@strlen.de>
Subject: Re: userns, netns, and quick physical memory consumption by
 unprivileged user
Date: Fri, 11 Mar 2016 16:34:06 +0100
Message-ID: <20160311153406.GB6620@breakpoint.cc>
References: <m3d1rclioc.fsf@gmail.com>
 <m3r3fhhx4c.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	linux-kernel@vger.kernel.org
To: "Yuriy M. Kaminskiy" <yumkam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m3r3fhhx4c.fsf@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yuriy M. Kaminskiy <yumkam@gmail.com> wrote:
> BTW, all those hash/conntrack/etc default sizes was calculated from
> physical memory size in assumption there will be only *one* instance of
> those tables. Obviously, introduction of network namespaces (and
> especially unprivileged user-ns) thrown this assumption in the window
> (and here comes that "falling back to vmalloc" message again; in pre-netns
> world, those tables were allocated *once* on early system startup, with
> typically plenty of free and unfragmented memory).

No idea how to fix this expect by removing conntrack support in net
namespaces completely.

I'd disallow all write accesses to skb->nfct (NAT, CONNMARK,
CONNSECMARK, ...) and then no longer clear skb->nfct when forwarding
packet from init_ns to container.

Containers could then still test conntrack as seen from init namespace pov
in PREROUTING/FORWARD/INPUT (but not OUTPUT, obviously).

[ OUTPUT *might* be doable as well by allowing NEW creation in output
  but skipping nat and deferring the confirmation/commit of the new
  entry to the table until skb leaves initns ]

We could key conntrack entries to initns conntrack table
instead of adding one new table per netns, but seems like this only
replaces one problem with a new one (filling/blocking initns table from
another netns).

Maybe we could go with a compromise and skip/disallow conntrack in
unpriv userns only?
