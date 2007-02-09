From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 7962] New: oops in port_carrier_check
Date: Fri, 9 Feb 2007 09:52:04 -0800
Message-ID: <20070209095204.7f43a964@oldman>
References: <20070207140916.088b1073@oldman>
	<20070209074211.GA1631@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@bugzilla.kernel.org>, pterjan@gmail.com
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:33695 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992464AbXBIRwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 12:52:17 -0500
In-Reply-To: <20070209074211.GA1631@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Feb 2007 08:42:11 +0100
Jarek Poplawski <jarkao2@o2.pl> wrote:

> On 07-02-2007 23:09, Stephen Hemminger wrote:
> > On Wed, 7 Feb 2007 12:52:16 -0800
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> ...
> >> Feb  7 21:20:18 plop kernel: BUG: unable to handle kernel paging request at
> >> virtual address 6b6b6b6b
> >> Feb  7 21:20:18 plop kernel:  printing eip:
> >> Feb  7 21:20:18 plop kernel: *pde = 00000000
> >> Feb  7 21:20:18 plop kernel: Oops: 0000 [#1]
> >> Feb  7 21:20:18 plop kernel: CPU:    0
> >> Feb  7 21:20:19 plop kernel: EIP:    0060:[pg0+814360305/1067136000]    Not
> >> tainted VLI
> >> Feb  7 21:20:19 plop kernel: EIP:    0060:[<f0eed6f1>]    Not tainted VLI
> >> Feb  7 21:20:19 plop kernel: EFLAGS: 00010202   (2.6.20.0.rc7-1mdv #1)
> >> Feb  7 21:20:19 plop kernel: EIP is at port_carrier_check+0x22/0x75 [bridge]
> >> Feb  7 21:20:19 plop kernel: eax: 6b6b6b6b   ebx: 6b6b6b6b   ecx: 00000000  
> 
> I think it's caused by pending delayed workqueue
> trying to use dev after kfree (POISON_FREE in eax, ebx). 
> 
> > static void port_carrier_check(struct work_struct *work)
> > {
> >        struct net_bridge_port *p;
> >        struct net_device *dev;
> >        struct net_bridge *br;
> >
> >        dev = container_of(work, struct net_bridge_port,
> >                           carrier_check.work)->dev;
> >        work_release(work);
> >
> >        rtnl_lock();
> >        p = dev->br_port;
> >        if (!p)
> >                goto done;
> >        br = p->br;
> >
> >        if (netif_carrier_ok(dev))
> >                p->path_cost = port_cost(dev);
> >
> >        if (br->dev->flags & IFF_UP) {
> 
> My investigation seems to point at this line (p == ebx
> but not NULL because of mem debugging on, probably).
> 

The carrier_check is canceled by removal of port from bridge.
Perhaps there is something broken in rcu assumptions under Qemu
