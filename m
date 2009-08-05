From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] net: Fix spinlock use in alloc_netdev_mq()
Date: Wed, 5 Aug 2009 10:13:27 -0700
Message-ID: <20090805101327.2c49cc62.akpm@linux-foundation.org>
References: <20090804.125742.32009006.davem@davemloft.net>
	<20090805070205.GA8741@elte.hu>
	<20090805071411.GA9217@elte.hu>
	<20090805071658.GA14073@elte.hu>
	<20090805084746.GA3897@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50050 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934516AbZHEROZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 13:14:25 -0400
In-Reply-To: <20090805084746.GA3897@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Aug 2009 10:47:47 +0200 Jiri Pirko <jpirko@redhat.com> wrote:

> >it's using an zero-initialized spinlock. This is a side-effect of:
> >
> >        dev_unicast_init(dev);
> >
> >in alloc_netdev_mq() making use of dev->addr_list_lock.
> >
> >The device has just been allocated freshly, it's not accessible
> >anywhere yet so no locking is needed at all - in fact it's wrong
> >to lock it here (the lock isnt initialized yet).
> 
> Yes this looks like the right approach. Sorry for this bug :(

Really?

> >--- a/net/core/dev.c
> >+++ b/net/core/dev.c
> >@@ -4007,9 +4007,7 @@ static void dev_unicast_flush(struct net_device *dev)
> > 
> > static void dev_unicast_init(struct net_device *dev)
> > {
> >-	netif_addr_lock_bh(dev);
> > 	__hw_addr_init(&dev->uc);
> >-	netif_addr_unlock_bh(dev);
> > }

This means that the net_device is still floating around for quite a
long time with an uninitialised spinlock, so it will be quite easy for
the same problem to reoccur as the code evolves.

It would be more robust were we to initialise that lock close to the
netdev's allocation site.

