From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Lockup with 2.6.9-ac15 related to netconsole
Date: Wed, 22 Dec 2004 13:39:41 +0100
Message-ID: <20041222123940.GA4241@electric-eye.fr.zoreil.com>
References: <20041221002218.GA1487@electric-eye.fr.zoreil.com> <20041221005521.GD5974@waste.org> <52121.192.102.214.6.1103624620.squirrel@webmail.wetlettuce.com> <20041221123727.GA13606@electric-eye.fr.zoreil.com> <49295.192.102.214.6.1103635762.squirrel@webmail.wetlettuce.com> <20041221204853.GA20869@electric-eye.fr.zoreil.com> <20041221212737.GK5974@waste.org> <20041221225831.GA20910@electric-eye.fr.zoreil.com> <41C93FAB.9090708@trash.net> <41C9525F.4070805@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>,
	Mark Broadbent <markb@wetlettuce.com>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261979AbULVMmR@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41C9525F.4070805@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> :
[...]
> at least the queued messages ordered. But you need to grab
> dev->queue_lock, otherwise you risk corrupting qdisc internal data.
> You should probably also deal with the noqueue-qdisc, which doesn't
> have an enqueue function. So it should look something like this:

If I am not mistaken, a failure on spin_trylock + the test on
xmit_lock_owner imply that it is safe to directly handle the
queue. It means that qdisc_run() has been interrupted on the
current cpu and the other paths seem fine as well. Counter-example
is welcome (no joke).

Of course the patch is completely ugly and violates any layering
principle one could think of. It was not submitted for inclusion :o)

> while (!spin_trylock(&np->dev->xmit_lock)) {
> 	if (np->dev->xmit_lock_owner == smp_processor_id()) {
> 		struct Qdisc *q;
> 
> 		rcu_read_lock();
> 		q = rcu_dereference(dev->qdisc);
> 		if (q->enqueue) {
> 			spin_lock(&dev->queue_lock);

I'd expect it to deadlock if dev_queue_xmit -> qdisc_run is interrupted
on the current cpu and a printk is issued as dev->queue_lock will have
been taken elsewhere.

--
Ueimor
