From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH] vlan: lockdep subclass for ppp _xmit_lock Re: ppp_generic: fix lockdep warning
Date: Wed, 9 May 2007 11:35:37 +0200
Message-ID: <20070509093536.GA2436@ff.dom.local>
References: <200704260727.l3Q7RTxG023970@shell0.pdx.osdl.net> <20070426.013911.69219176.davem@davemloft.net> <20070426104950.GA3145@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, jura@netams.com,
	paulus@samba.org, greearb@candelatech.com, mostrows@speakeasy.net,
	davem@davemloft.net
To: "Yuriy N\. Shkandybin" <jura@netams.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:44122 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754069AbXEIJ3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 05:29:17 -0400
Content-Disposition: inline
In-Reply-To: <20070426104950.GA3145@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 12:49:50PM +0200, Jarek Poplawski wrote:
...
> But there is also a second, very similar lockdep report,
> probably also false (lockdep cannot see the difference
> between locks of two different, I hope, vlan devices),
> which needs more work:
> a) vlan should use different lockdep lock subclasses or
> classes for each device, which would require quite a lot
> of static memory reserved, probably only to silence
> lockdep,
> b) pppoe could change the way of sending packets, so
> the locks of ppp_generic were not seen by lockdep
> with so many variants; I'm not sure the maintainer of
> pppoe likes this idea;
> 
> Doing a) should be enough, I guess; doing b) is easier
> but, probably, the similar is possible elsewhere, too.
...
> Currently I think about some change in lockdep, to track
> something like different vlans with less memory, but I'm
> not sure it'll work, yet.

After rethinking there is the 3-rd way (as usual):

c) vlan should use different lockdep lock subclasses or
classes for different types of devices, used at the same
time.

This patch is intended for testing, so should be applied
after some confirmation. (It should be safe anyway.)

If this works, the previous lockdep patch on ppp_generic
should be really superfluous.

Yuriy, could you try this patch, please?
This is done on 2.6.21, but could be applied to current -mm
or -git, too. If you prefere some other version, let me know.

Regards,
Jarek P.
--->

This patch's aim is to let lockdep see ppp devs as different
from others (default), and it's OK to take: _xmit_lock of vlan
and _xmit_lock of ppp with reverse order provided vlan _xmit_locks
are bound to different devs (ppp and e.g. eth).

> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.21-rc6-mm1 #4
> -------------------------------------------------------
> pppd/14305 is trying to acquire lock:
>  (&vlan_netdev_xmit_lock_key){-...}, at: [<ffffffff8022f90b>]
> dev_queue_xmit+0x26b/0x300
> 
> but task is already holding lock:
>  (&pch->downl#2){-+..}, at: [<ffffffff80388d3c>] ppp_push+0x5f/0xa7
> 
> which lock already depends on the new lock.
    
Reported & tested by: "Yuriy N. Shkandybin" <jura@netams.com>
Cc: Ben Greear <greearb@candelatech.com>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michal Ostrowski <mostrows@speakeasy.net>
Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp 2.6.21-/net/8021q/vlan.c 2.6.21/net/8021q/vlan.c
--- 2.6.21-/net/8021q/vlan.c	2007-05-01 12:43:39.000000000 +0200
+++ 2.6.21/net/8021q/vlan.c	2007-05-07 21:09:30.000000000 +0200
@@ -535,7 +535,13 @@ static struct net_device *register_vlan_
 	if (register_netdevice(new_dev))
 		goto out_free_newdev;
 
-	lockdep_set_class(&new_dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
+	if (unlikely(real_dev->type == ARPHRD_PPP))
+		/* pppoe uses two different kinds of _xmit_lock for ppp & eth */
+		lockdep_set_class_and_subclass(&new_dev->_xmit_lock,
+					       &vlan_netdev_xmit_lock_key, 1);
+	else
+		lockdep_set_class(&new_dev->_xmit_lock,
+				  &vlan_netdev_xmit_lock_key);
 
 	new_dev->iflink = real_dev->ifindex;
 	vlan_transfer_operstate(real_dev, new_dev);
