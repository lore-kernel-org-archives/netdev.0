From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH net-next-2.6] sched: use xps information for qdisc NUMA
 affinity
Date: Tue, 30 Nov 2010 12:01:53 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1011301152240.10832@jbrandeb-desk1.amr.corp.intel.com>
References: <AANLkTimU+7aY0DZrnBtL=BsP_qGpCsBw0d4TCKOJSzRL@mail.gmail.com> <20101130.104834.112604433.davem@davemloft.net> <1291144047.2904.224.camel@edumazet-laptop> <20101130.112106.183035811.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:40354 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755764Ab0K3UBz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 15:01:55 -0500
In-Reply-To: <20101130.112106.183035811.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 30 Nov 2010, David Miller wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 30 Nov 2010 20:07:27 +0100
> 
> [ Jesse CC:'d ]
> 
> > netdev struct itself is shared by all cpus, so there is no real choice,
> > unless you know one netdev will be used by a restricted set of
> > cpus/nodes... Probably very unlikely in practice.
> 
> Unfortunately Jesse has found non-trivial gains by NUMA localizing the
> netdev struct during routing tests in soome configurations.

Thanks Dave, given the results I can see with current upstream (at least 
igb) I don't think that netdev access is hurting performance unless the 
driver is unwisely accessing netdev structs for write on multiple cpus 
simultaneously.

I think the trick is to have drivers that are concerned with this kind of 
thing have a "hot path struct" that is used at runtime.  Since the cache 
on the numa systems will still cache remote node memory for read, if it is 
not written to, then the read data will be housed on each cpus' L3.
 
> > We could change (only on NUMA setups maybe)
> > 
> > struct netdev_queue *_tx;
> > 
> > to a
> > 
> > struct netdev_queue **_tx;
> > 
> > and allocate each "struct netdev_queue" on appropriate node, but adding
> > one indirection level might be overkill...

I agree probably overkill.

> > For very hot small structures, (one or two cache lines), I am not sure
> > its worth the pain.
> 
> Jesse, do you think this would help the case you were testing?

I would be glad to test, but I am currently seeing pretty good results 
with upstream igb.  I'll retest with latest kernel and with 
# taskset 1 insmod igb.ko
echo 2 > /proc/irq/<igb irqs>/smp_affinity

(1 and 2 are different sockets on my machine)
