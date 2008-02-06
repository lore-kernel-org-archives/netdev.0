From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RFC] race in generic address resolution
Date: Tue, 05 Feb 2008 20:51:54 -0800 (PST)
Message-ID: <20080205.205154.153345843.davem@davemloft.net>
References: <20080204142717.GA11020@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44307
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758088AbYBFEvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 23:51:25 -0500
In-Reply-To: <20080204142717.GA11020@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Blaschka <frank.blaschka@de.ibm.com>
Date: Mon, 4 Feb 2008 15:27:17 +0100

> I'm running a SMP maschine (2 CPUs) configured as a router. During heavy
> traffic kernel dies with following message: 
> 
>     <2>kernel BUG at /home/autobuild/BUILD/linux-2.6.23-20080125/net/core/skbuff.c:648!
 ...
> Following patch fixes the problem but I do not know if it is a good sollution.
> 
> From: Frank Blaschka <frank.blaschka@de.ibm.com>
> 
> neigh_update sends skb from neigh->arp_queue while
> neigh_timer_handler has increased skbs refcount and calls
> solicit with the skb. Do not send neighbour skbs
> marked for solicit (skb_shared).
> 
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Thanks for finding this bug.

I'm fine with your approach as a temporary fix, but there is a slight
problem with your patch.  If the skb is shared we have to free it if
we don't pass it on to ->output(), otherwise this creates a leak.

In the longer term, this is an unfortunate limitation.  The
->solicit() code just wants to look at a few header fields to
determine how to construct the solicitation request.

What's funny is that we added these skb_get() calls for
the solications exactly to deal with this race condition.

I considered various ways to fix this.  The simplest is probably just
to skb_copy() in the ->solicit() case.  Solicitation is a rare event
so it's not big deal to copy the packet until the neighbour is
resolved.

The other option is holding the write lock on neigh->lock during the
->solicit() call.  I looked at all of the ndisc_ops implementations
and this seems workable.  The only case that needs special care is the
IPV4 ARP implementation of arp_solicit().  It wants to take
neigh->lock as a reader to protect the header entry in neigh->ha
during the emission of the soliciation.  We can simply remove the read
lock calls to take care of that since holding the lock as a writer at
the caller providers a superset of the protection afforded by the
existing read locking.

The rest of the ->solicit() implementations don't care whether
the neigh is locked or not.

Can you see if this version of the patch fixes your problem?

Thanks!

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index a16cf1e..7bb6a9a 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -834,18 +834,12 @@ static void neigh_timer_handler(unsigned long arg)
 	}
 	if (neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) {
 		struct sk_buff *skb = skb_peek(&neigh->arp_queue);
-		/* keep skb alive even if arp_queue overflows */
-		if (skb)
-			skb_get(skb);
-		write_unlock(&neigh->lock);
+
 		neigh->ops->solicit(neigh, skb);
 		atomic_inc(&neigh->probes);
-		if (skb)
-			kfree_skb(skb);
-	} else {
-out:
-		write_unlock(&neigh->lock);
 	}
+out:
+	write_unlock(&neigh->lock);
 
 	if (notify)
 		neigh_update_notify(neigh);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 8e17f65..c663fa5 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -368,7 +368,6 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 		if (!(neigh->nud_state&NUD_VALID))
 			printk(KERN_DEBUG "trying to ucast probe in NUD_INVALID\n");
 		dst_ha = neigh->ha;
-		read_lock_bh(&neigh->lock);
 	} else if ((probes -= neigh->parms->app_probes) < 0) {
 #ifdef CONFIG_ARPD
 		neigh_app_ns(neigh);
@@ -378,8 +377,6 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 	arp_send(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
 		 dst_ha, dev->dev_addr, NULL);
-	if (dst_ha)
-		read_unlock_bh(&neigh->lock);
 }
 
 static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
