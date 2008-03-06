From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 6 Mar 2008 15:57:30 +0200
Message-ID: <20080306135625.M25627@visp.net.lb>
References: <20080224222035.M62480@visp.net.lb> <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:52655 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759029AbYCFN5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 08:57:43 -0500
In-Reply-To: <20080306134015.GA4571@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am able to reproduce this warning over this relatively simple shell script
on my Gentoo PC (2.6.25-rc3).
http://www.nuclearcat.com/files/bug_feb.txt

Probably it will help to debug issue for more experienced developers. Note:
it appears not immediately, second time i tested, it's appeared after while,
but in matter of seconds.

Note - it can stop traffic on PC completely. It is also seems crashed my 
desktop PC, i am not able to execute "tc qdisc del dev eth0 root".
The system hang completely. I had few similar issues on my PPPoE servers 
(with different scripts for shapers), that system hang, and even "reboot -f" 
doesn't work sometimes.


On Thu, 6 Mar 2008 13:40:15 +0000, Jarek Poplawski wrote
> On Wed, Mar 05, 2008 at 12:45:51PM +0200, Denys Fedoryshchenko wrote:
> > I did test on vanilla 2.6.25-rc3, on clean Gentoo distro and got 
> > similar message. The strange thing, message appeared not immediately 
after 
> > launching script, but after few seconds.
> > 
> > Scripts is the same. I have same message on another script, used for ppp 
> > shaper.
> > 
> > [   10.536424] =======================================================
> > [   10.536424] [ INFO: possible circular locking dependency detected ]
> > [   10.536424] 2.6.25-rc3-devel #3
> > [   10.536424] -------------------------------------------------------
> > [   10.536424] swapper/0 is trying to acquire lock:
> > [   10.536424]  (&dev->queue_lock){-+..}, at: [<c0299b4a>] 
> > dev_queue_xmit+0x175/0x2f3
> > [   10.536424]
> > [   10.536424] but task is already holding lock:
> > [   10.536424]  (&p->tcfc_lock){-+..}, at: [<f8a67154>] tcf_mirred+0x20/
0x178 
> > [act_mirred]
> > [   10.536424]
> > [   10.536424] which lock already depends on the new lock.
> ....
> 
> Hi,
> 
> I'm not sure this lockdep report is because of this, but there is
> really a problem with lock order while using sch_ingress with
> act_mirred: dev->queue_lock is taken after dev->ingress_lock, so
> reversely to e.g. qdisc_lock_tree(). This shouldn't be a problem
> when one of the devices is ifb yet.
> 
> Regards,
> Jarek P.
> 
> Here is a patch for testing:
> 
> ---
> 
>  drivers/net/ifb.c |   19 +++++++++++++++++++
>  1 files changed, 19 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index 15949d3..2bc71df 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -227,6 +227,22 @@ static struct rtnl_link_ops ifb_link_ops 
> __read_mostly = { module_param(numifbs, int, 0); 
> MODULE_PARM_DESC(numifbs, "Number of ifb devices");
> 
> +#ifdef CONFIG_DEBUG_LOCK_ALLOC
> +/*
> + * dev_ifb->queue_lock is usually taken after dev->ingress_lock,
> + * so let's tell lockdep it's different from dev->queue_lock
> + */
> +static struct lock_class_key ifb_queue_lock_key;
> +static inline void ifb_set_lock_class(spinlock_t *lock)
> +{
> +	lockdep_set_class(lock, &ifb_queue_lock_key);
> +}
> +#else
> +static inline void ifb_set_lock_class(spinlock_t *lock)
> +{
> +}
> +#endif	/* CONFIG_DEBUG_LOCK_ALLOC */
> +
>  static int __init ifb_init_one(int index)
>  {
>  	struct net_device *dev_ifb;
> @@ -246,6 +262,9 @@ static int __init ifb_init_one(int index)
>  	err = register_netdevice(dev_ifb);
>  	if (err < 0)
>  		goto err;
> +
> +	ifb_set_lock_class(&dev_ifb->queue_lock);
> +
>  	return 0;
> 
>  err:


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

