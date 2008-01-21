From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bugme-new] [Bug 9778] New: unregister_netdevice: waiting for [device] to become free
Date: Mon, 21 Jan 2008 17:36:31 +0300
Message-ID: <20080121143630.GA3498@2ka.mipt.ru>
References: <bug-9778-10286@http.bugzilla.kernel.org/> <20080119165802.2846a28e.akpm@linux-foundation.org> <20080120.023027.85710827.davem@davemloft.net> <20080121121445.GA29459@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, xemul@openvz.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	nigel@suspend2.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47888 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752954AbYAUOhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 09:37:03 -0500
Content-Disposition: inline
In-Reply-To: <20080121121445.GA29459@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2008 at 03:14:45PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> It looks like patch is still valid.
> Here is a problem description as I undestood.
> 
> When new device (let's talk about ethernet, since that is what I tested)
> is being turned on, it gets neigh_parms entry allocated for it via
> inetdev_init(), which is called for NETDEV_REGISTER inetdev event.
> This entry is stored in arp_tbl table and is in_dev->arp_parms.
> 
> When later new arp entry is created, device is provided into
> arp_constructor(), which clones (increase reference counter) device's
> in_dev->arp_parms and puts it into provided neighbour entry.
> 
> When later we remove device, its in_dev->arp_parms's reference counter
> is high enough (it is equal to number of arp entries found on given
> device plu one), so neigh_parms_destroy() is not called. Later all
> neighbour entries are flushed by garbage collector and reference counter
> for that parm hits zero and device can be removed.
> 
> I will think about how to fix the problem nicely or if this patch still
> can be simplified/dropped, but so far it looks valid. Maybe this
> analysis will help someone to fix problem first.

Yes, patch is valid, and there is a (very noticeble) race between
neighbour processing and parm release - parm still can be accessed after
device was fully freed (as with old behaviour when dev_pu() was called
from neigh_parms_release()), although no one access it, so the simplest
solution is to move dev_put() under the table lock and allow to access
parms->dev only under table lock and always check if it is non-null.
So I propose a following patch as a simplest solution for the current
time.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index a4f2618..410b7e7 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -34,6 +34,11 @@ struct neighbour;
 
 struct neigh_parms
 {
+	/*
+	 * This device is only allowed to be accessed under table lock (bh turned off)
+	 * and while device is alive. After parm was released, it will be set to NULL
+	 * and has to be always checked before accessed.
+	 */
 	struct net_device *dev;
 	struct neigh_parms *next;
 	int	(*neigh_setup)(struct neighbour *);
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index cc8a2f1..5076acd 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1315,7 +1315,12 @@ void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms)
 		if (*p == parms) {
 			*p = parms->next;
 			parms->dead = 1;
+			if (parms->dev) {
+				dev_put(parms->dev);
+				parms->dev = NULL;
+			}
 			write_unlock_bh(&tbl->lock);
+
 			call_rcu(&parms->rcu_head, neigh_rcu_free_parms);
 			return;
 		}
@@ -1326,8 +1331,6 @@ void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms)
 
 void neigh_parms_destroy(struct neigh_parms *parms)
 {
-	if (parms->dev)
-		dev_put(parms->dev);
 	kfree(parms);
 }
 

-- 
	Evgeniy Polyakov
