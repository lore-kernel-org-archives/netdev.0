From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] IPv6 recursive locking
Date: Sun, 17 Feb 2008 18:41:24 -0800 (PST)
Message-ID: <20080217.184124.193855419.davem@davemloft.net>
References: <20080217141229.GB1677@nereid>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kristof@provost-engineering.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47217
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753808AbYBRCks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2008 21:40:48 -0500
In-Reply-To: <20080217141229.GB1677@nereid>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristof Provost <Kristof@provost-engineering.be>
Date: Sun, 17 Feb 2008 14:12:29 +0000

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Hi,
> 
> I'm running the current git (1309d4e68497184d2fd87e892ddf14076c2bda98) 
> without problems. While I was toying with IPv6 on my local network I managed 
> to completely hang my machine whenever it receives or sends a neighbour
> sollictation. At least, I think that's the cause. It started as soon as I 
> installed radvd on the router. The included trace seems to point in the same
> direction.
> 
> The machine is a Dell Latitude D505 (so x86). Network interfaces are e100 and
> ipw2200 (firmware not loaded). I'm currently using the e100.
> 
> I'll try to bisect it but here's the trace already. Let me know if
> there's anything else you'd like to know.

I've committed the following revert to fix this, the race bug
will need another solution, perhaps the one which uses skb_copy().

commit 9ff566074689e3aed1488780b97714ec43ba361d
Author: David S. Miller <davem@davemloft.net>
Date:   Sun Feb 17 18:39:54 2008 -0800

    Revert "[NDISC]: Fix race in generic address resolution"
    
    This reverts commit 69cc64d8d92bf852f933e90c888dfff083bd4fc9.
    
    It causes recursive locking in IPV6 because unlike other
    neighbour layer clients, it even needs neighbour cache
    entries to send neighbour soliciation messages :-(
    
    We'll have to find another way to fix this race.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 7bb6a9a..a16cf1e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -834,12 +834,18 @@ static void neigh_timer_handler(unsigned long arg)
 	}
 	if (neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) {
 		struct sk_buff *skb = skb_peek(&neigh->arp_queue);
-
+		/* keep skb alive even if arp_queue overflows */
+		if (skb)
+			skb_get(skb);
+		write_unlock(&neigh->lock);
 		neigh->ops->solicit(neigh, skb);
 		atomic_inc(&neigh->probes);
-	}
+		if (skb)
+			kfree_skb(skb);
+	} else {
 out:
-	write_unlock(&neigh->lock);
+		write_unlock(&neigh->lock);
+	}
 
 	if (notify)
 		neigh_update_notify(neigh);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c663fa5..8e17f65 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -368,6 +368,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 		if (!(neigh->nud_state&NUD_VALID))
 			printk(KERN_DEBUG "trying to ucast probe in NUD_INVALID\n");
 		dst_ha = neigh->ha;
+		read_lock_bh(&neigh->lock);
 	} else if ((probes -= neigh->parms->app_probes) < 0) {
 #ifdef CONFIG_ARPD
 		neigh_app_ns(neigh);
@@ -377,6 +378,8 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 
 	arp_send(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
 		 dst_ha, dev->dev_addr, NULL);
+	if (dst_ha)
+		read_unlock_bh(&neigh->lock);
 }
 
 static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)

