From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT]: Networking
Date: Wed, 5 Aug 2009 09:14:11 +0200
Message-ID: <20090805071411.GA9217@elte.hu>
References: <20090804.125742.32009006.davem@davemloft.net> <20090805070205.GA8741@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:39623 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933520AbZHEHO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 03:14:28 -0400
Content-Disposition: inline
In-Reply-To: <20090805070205.GA8741@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> FYI, -tip testing found that these bits trigger a missing lockdep 
> annotation warning:

it's apparently using an zero-initialized spinlock. This is a 
side-effect of:

        dev_unicast_init(dev);

in alloc_netdev_mq() making use of dev->addr_list_lock.

Wouldnt the patch below be the right fix? The device has just been 
allocated freshly, it's not accessible anywhere yet so no locking is 
needed at all - in fact it's wrong to lock it here (the lock isnt 
initialized yet).

This bug was apparently introduced via:

| commit a6ac65db2329e7685299666f5f7b6093c7b0f3a0
| Author: Jiri Pirko <jpirko@redhat.com>
| Date:   Thu Jul 30 01:06:12 2009 +0000
|
|     net: restore the original spinlock to protect unicast list

it needlessly added new locking and apparently nobody ran this patch 
with lockdep.

	Ingo

Index: linux2/net/core/dev.c
===================================================================
--- linux2.orig/net/core/dev.c
+++ linux2/net/core/dev.c
@@ -4007,9 +4007,7 @@ static void dev_unicast_flush(struct net
 
 static void dev_unicast_init(struct net_device *dev)
 {
-	netif_addr_lock_bh(dev);
 	__hw_addr_init(&dev->uc);
-	netif_addr_unlock_bh(dev);
 }
 
 
