From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 04/10] AOE: use rcu to find network device
Date: Thu, 12 Nov 2009 09:10:48 -0800
Message-ID: <20091112091048.00d00d1b@nehalam>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.409162953@vyatta.com>
	<8ffe0a1df67d13a45a413f40d00dd80a@coraid.com>
	<20091110150617.0e6920f0@nehalam>
	<20091110155316.2c3d7b6e@nehalam>
	<e160a17e366ae2f676df822db1e62bc2@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: karaluh@karaluh.pl, ecashin@coraid.com, roel.kluin@gmail.com,
	harvey.harrison@gmail.com, bzolnier@gmail.com,
	netdev@vger.kernel.org
To: Ed Cashin <ecashin@coraid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33691 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753355AbZKLRLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2009 12:11:09 -0500
In-Reply-To: <e160a17e366ae2f676df822db1e62bc2@coraid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Nov 2009 09:33:16 -0500
Ed Cashin <ecashin@coraid.com> wrote:

> Thanks again for providing this patch to help get things started.
> It's very helpful.  I appreciate the way it reflects and fits into the
> rest of the driver, too.
> 
> In the patch, there's a loop around getif, ejectif inside the new
> aoecmd_flushnet function:
> 
>   void aoecmd_flushnet(struct aoedev *d, struct net_device *nd)
>   {
>   	struct aoetgt **tt, **te;
>   	tt = d->targets;
>   	te = tt + NTARGETS;
>   	for (; tt < te && *tt; tt++) {
>   		struct aoetgt *t = *tt;
>   		struct aoeif *ifp;
>   
>   		while ( (ifp = getif(t, nd)) )
>   			ejectif(t, ifp);
>   	}
>   }
> 
> ... but an "if" seems appropriate, since duplicates are avoided when
> network devices are added in aoecmd_cfg_rsp:
> 
>   	ifp = getif(t, skb->dev);
>   	if (!ifp) {
>   		ifp = addif(t, skb->dev);

Yeah if works, wasn't sure if you could have multiples.

> 
> If there's some other reason for it to be "while" in aoecmd_flushnet
> that I'm missing, please let me know.
> 
> Regarding the new aoe_device_event function,
> 
>   /* Callback on change of state of network device. */
>   static int aoe_device_event(struct notifier_block *unused,
>   			    unsigned long event, void *ptr)
>   {
>   	struct net_device *nd = ptr;
>   
>   	if (is_aoe_netif(nd) && event == NETDEV_UNREGISTER)
>   		aoedev_ejectnet(nd);
>   
>   	return NOTIFY_DONE;
>   }
> 
> ...  the is_aoe_netif function really answers the question, "Are we
> allowed by the user to do AoE on this local network interface?" The
> user can modify the list of allowable interfaces at runtime via sysfs,
> as it's a module parameter.  So I don't think we can use is_aoe_netif
> in the new aoe_device_event function.  We should eject a net_device in
> this handler even if the user has decided not to use it for AoE.
> Please let me know if I'm missing the point.

Ok, you know the code better, I just wanted to avoid doing unnecessary work.

> You said that,
> 
>   > It needs to:
>   > 
>   > 1. Get a device ref count when it remembers a device: (ie addif)
>   > 2. Install a notifier that looks for device removal events
>   > 3. In notifier, remove interface, including flushing all pending
>   >    skb's for that device.
> 
> For 3, does the starter patch flush all pending skbs?  Perhaps you
> could elaborate on what you had in mind?

I wasn't sure if you ended up queuing skb's, but it looks like the
code queues requests not skb's.  But you may need to disable preempt
over code the work queue code that processes requests, to make sure
that device doesn't disappear while doing stuff.

> 
> I am trying to find the best way for the aoe driver to handle the
> situation where ther are no usable local network interfaces.  It does
> seem to me that the user would benefit from a notice letting them know
> that they're trying to do AoE without any usable ethernet.  I'm
> thinking that doing something like a printk_once would be appropriate.

Since it is emulating a block device, why not propgate error back
up the stack like a disk that's offline.



-- 
