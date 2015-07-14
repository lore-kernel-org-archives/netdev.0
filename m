From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: mmap()ed AF_NETLINK: lockdep and sleep-in-atomic warnings
Date: Tue, 14 Jul 2015 11:40:40 -0700
Message-ID: <20150714114040.58dd5bf5@urahara>
References: <20150713131825.GA16186@node.dhcp.inet.fi>
	<CAHA+R7OPHFjL83RKkTmso3s25_f7TKA=HhFKU_yOnRhsn1WxQg@mail.gmail.com>
	<20150714093825.GC20597@pox.localdomain>
	<20150714095037.GB25674@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Cong Wang <cwang@twopensource.com>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150714095037.GB25674@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Jul 2015 11:50:37 +0200
Florian Westphal <fw@strlen.de> wrote:

> Thomas Graf <tgraf@suug.ch> wrote:
> > On 07/13/15 at 10:11pm, Cong Wang wrote:
> > > Caused by:
> > > 
> > > commit 21e4902aea80ef35afc00ee8d2abdea4f519b7f7
> > > Author: Thomas Graf <tgraf@suug.ch>
> > > Date:   Fri Jan 2 23:00:22 2015 +0100
> > > 
> > >     netlink: Lockless lookup with RCU grace period in socket release
> > > 
> > >     Defers the release of the socket reference using call_rcu() to
> > >     allow using an RCU read-side protected call to rhashtable_lookup()
> > > 
> > >     This restores behaviour and performance gains as previously
> > >     introduced by e341694 ("netlink: Convert netlink_lookup() to use
> > >     RCU protected hash table") without the side effect of severely
> > >     delayed socket destruction.
> > > 
> > >     Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > >     Signed-off-by: David S. Miller <davem@davemloft.net>
> > > 
> > > 
> > > We can't hold mutex lock in a rcu callback, perhaps we could
> > > defer the mmap ring cleanup to a workqueue.
> > 
> > The socket should be dead at this point. It might be simpler to
> > add a netlink_release_ring() function which doesn't require
> > locking at all. It would also get rid of all the special handling
> > for closing vs. non-closing.
> 
> Do you know of any users of mmap'd netlink?
> Support for this was never added to libmnl; given the fact that netlink
> mmap doesn't have any advantages vs. socket interface i'd just revert it
> (or mark CONFIG_NETLINK_MMAP broken -- although I don't see
>  how the unconditional copy on tx could ever be avoided).

We use netlink mmap because it gives slightly better performance
when processing a route flap.
