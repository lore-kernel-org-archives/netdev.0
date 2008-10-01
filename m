From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration - V2
Date: Wed, 1 Oct 2008 21:48:25 +0200
Message-ID: <20081001194825.GA2520@ami.dom.local>
References: <48E24341.5050609@bull.net> <20081001.025935.257260146.davem@davemloft.net> <48E34C82.2040306@fr.ibm.com> <20081001.031243.255655293.davem@davemloft.net> <20081001141432.470106980@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.186]:15223 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462AbYJATsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 15:48:33 -0400
Received: by gv-out-0910.google.com with SMTP id e6so168433gvc.37
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2008 12:48:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081001141432.470106980@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 01, 2008 at 04:14:35PM +0200, Benjamin Thery wrote:
> This is the second version of a patch aimed at fixing a deadlock that
> can occur when unregistering net devices. 
> 
> This new version of the patch ensures the garbage collector 
> dst_gc_task() is run when waiting in netdev_wait_allrefs(), by calling
> it in the netdevice notifier dst_dev_event() when receiving a 
> NETDEV_UNREGISTER event.
> 
> Thanks to Jarek Poplawski for proposing this fix.

Not at all! Actually, I'm sorry for this mess... (Read below.)

> (The previous version proposed to replace in linkwatch_event()
> the call to rntl_unlock() by __rtnl_lock())
...
> --- net-next-2.6.orig/net/core/dst.c
> +++ net-next-2.6/net/core/dst.c
> @@ -328,6 +328,10 @@ static int dst_dev_event(struct notifier
>  			dst_ifdown(dst, dev, event != NETDEV_DOWN);
>  		}
>  		mutex_unlock(&dst_gc_mutex);
> +
> +		if (event == NETDEV_UNREGISTER &&
> +		    cancel_delayed_work(&dst_gc_work))
> +			dst_gc_task(&dst_gc_work.work);

Hmm... It seems this shouldn't work yet: cancel_delayed_work() can only
kill this while on timer, but not when queued and maybe blocked already.
Probably cancel_delayed_work_sync() should be considered instead, but
since this needs more checking, and David is waiting for this, I think
it's safer to use this previous (__rtnl_unlock) patch for now
(especially for -stable).

Thanks,
Jarek P.
