From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH (take 2)] vlan: lockdep class for ppp _xmit_lock Re: ppp_generic: fix lockdep warning
Date: Wed, 9 May 2007 15:13:38 +0200
Message-ID: <20070509131337.GA3177@ff.dom.local>
References: <20070426.013911.69219176.davem@davemloft.net> <20070426104950.GA3145@ff.dom.local> <20070509093536.GA2436@ff.dom.local> <20070509.023224.31601789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jura@netams.com, akpm@linux-foundation.org, netdev@vger.kernel.org,
	paulus@samba.org, greearb@candelatech.com, mostrows@speakeasy.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:54603 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755568AbXEINHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 09:07:18 -0400
Content-Disposition: inline
In-Reply-To: <20070509.023224.31601789.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 09, 2007 at 02:32:24AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@o2.pl>
> Date: Wed, 9 May 2007 11:35:37 +0200
> 
> > After rethinking there is the 3-rd way (as usual):
> > 
> > c) vlan should use different lockdep lock subclasses or
> > classes for different types of devices, used at the same
> > time.
> 
> Perhaps we should just bite the bullet and use a seperate
> unique lock class for ->_xmit_lock of each device type.
> 
> We are going to find more cases like this one, for sure.
> 

Theoretically subclasses are intended for this, and there
are 6 free places still. Practically lockdep treats subclasses
differently sometimes (e.g., now, it seems, it cannot see a real
recursion error inside a subclass). So, it's mainly a problem
of some static memory wasting or saving (unless it should be
subclassed yet - then no question).

Here is "your way" alternative, preferred version - I hope Yuriy
isn't bored with this testing yet!

Of course, I see nothing against you or somebody else doing
or re-doing this all as needed.

Regards,
Jarek P.
---> (take 2)

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

The final idea to use separate classes by David Miller.

Reported & tested by: "Yuriy N. Shkandybin" <jura@netams.com>
Cc: Ben Greear <greearb@candelatech.com>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michal Ostrowski <mostrows@speakeasy.net>
Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp 2.6.21-git7-/net/8021q/vlan.c 2.6.21/net/8021q/vlan.c
--- 2.6.21-git7-/net/8021q/vlan.c	2007-05-01 12:43:39.000000000 +0200
+++ 2.6.21/net/8021q/vlan.c	2007-05-09 14:46:12.000000000 +0200
@@ -376,6 +376,8 @@ static void vlan_transfer_operstate(cons
  */
 static struct lock_class_key vlan_netdev_xmit_lock_key;
 
+/* pppoe uses two different kinds of _xmit_lock for ppp & eth */
+static struct lock_class_key vlan_ppp_xmit_lock_key;
 
 /*  Attach a VLAN device to a mac address (ie Ethernet Card).
  *  Returns the device that was created, or NULL if there was
@@ -535,7 +537,12 @@ static struct net_device *register_vlan_
 	if (register_netdevice(new_dev))
 		goto out_free_newdev;
 
-	lockdep_set_class(&new_dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
+	if (unlikely(real_dev->type == ARPHRD_PPP))
+		lockdep_set_class(&new_dev->_xmit_lock,
+				  &vlan_ppp_xmit_lock_key);
+	else
+		lockdep_set_class(&new_dev->_xmit_lock,
+				  &vlan_netdev_xmit_lock_key);
 
 	new_dev->iflink = real_dev->ifindex;
 	vlan_transfer_operstate(real_dev, new_dev);
