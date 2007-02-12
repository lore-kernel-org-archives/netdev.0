From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 7962] New: oops in port_carrier_check
Date: Mon, 12 Feb 2007 07:44:46 +0100
Message-ID: <20070212064446.GA1651@ff.dom.local>
References: <20070207140916.088b1073@oldman> <20070209074211.GA1631@ff.dom.local> <20070209095204.7f43a964@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@bugzilla.kernel.org>, pterjan@gmail.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:50912 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933038AbXBLGlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 01:41:39 -0500
Content-Disposition: inline
In-Reply-To: <20070209095204.7f43a964@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 09, 2007 at 09:52:04AM -0800, Stephen Hemminger wrote:
> On Fri, 9 Feb 2007 08:42:11 +0100
> Jarek Poplawski <jarkao2@o2.pl> wrote:
> 
> > On 07-02-2007 23:09, Stephen Hemminger wrote:
> > > On Wed, 7 Feb 2007 12:52:16 -0800
> > > Andrew Morton <akpm@linux-foundation.org> wrote:
> > ...
> > >> Feb  7 21:20:18 plop kernel: BUG: unable to handle kernel paging request at
> > >> virtual address 6b6b6b6b
> > >> Feb  7 21:20:18 plop kernel:  printing eip:
> > >> Feb  7 21:20:18 plop kernel: *pde = 00000000
> > >> Feb  7 21:20:18 plop kernel: Oops: 0000 [#1]
> > >> Feb  7 21:20:18 plop kernel: CPU:    0
> > >> Feb  7 21:20:19 plop kernel: EIP:    0060:[pg0+814360305/1067136000]    Not
> > >> tainted VLI
> > >> Feb  7 21:20:19 plop kernel: EIP:    0060:[<f0eed6f1>]    Not tainted VLI
> > >> Feb  7 21:20:19 plop kernel: EFLAGS: 00010202   (2.6.20.0.rc7-1mdv #1)
> > >> Feb  7 21:20:19 plop kernel: EIP is at port_carrier_check+0x22/0x75 [bridge]
> > >> Feb  7 21:20:19 plop kernel: eax: 6b6b6b6b   ebx: 6b6b6b6b   ecx: 00000000  
> > 
> > I think it's caused by pending delayed workqueue
> > trying to use dev after kfree (POISON_FREE in eax, ebx). 
> > 
> > > static void port_carrier_check(struct work_struct *work)
> > > {
> > >        struct net_bridge_port *p;
> > >        struct net_device *dev;
> > >        struct net_bridge *br;
> > >
> > >        dev = container_of(work, struct net_bridge_port,
> > >                           carrier_check.work)->dev;
> > >        work_release(work);
> > >
> > >        rtnl_lock();
> > >        p = dev->br_port;
> > >        if (!p)
> > >                goto done;
> > >        br = p->br;
> > >
> > >        if (netif_carrier_ok(dev))
> > >                p->path_cost = port_cost(dev);
> > >
> > >        if (br->dev->flags & IFF_UP) {
> > 
> > My investigation seems to point at this line (p == ebx
> > but not NULL because of mem debugging on, probably).

Sorry, I overpasted. This is the line:

-->        br = p->br;

> The carrier_check is canceled by removal of port from bridge.
> Perhaps there is something broken in rcu assumptions under Qemu

If you mean this:

> static void del_nbp(struct net_bridge_port *p)
> {
> ...
>        cancel_delayed_work(&p->carrier_check);

it's not sufficient. According to workqueue.h:

> /*
>  * Kill off a pending schedule_delayed_work().  Note that the work callback
>  * function may still be running on return from cancel_delayed_work().  Run
>  * flush_scheduled_work() to wait on it.
>  */
> static inline int cancel_delayed_work(struct delayed_work *work)

I can't see how rcu could help here with this pointer
to dev passed on to delayed_work (out of any rcu block).

IMHO dev_hold/dev_put (or something alike) is needed here.

Regards,
Jarek P.
