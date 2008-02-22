From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: lockdep warning
Date: Fri, 22 Feb 2008 14:20:40 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802221420250.30955@jikos.suse.cz>
References: <20080222104049.BD95A93C12F@tippex.mynet.homeunix.org>
 <Pine.LNX.4.64.0802221214020.7699@twin.jikos.cz>
 <20080222131608.7FC1E93C12F@tippex.mynet.homeunix.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Anders Eriksson <aeriksson@fastmail.fm>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:45800 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758658AbYBVNUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2008 08:20:41 -0500
In-Reply-To: <20080222131608.7FC1E93C12F@tippex.mynet.homeunix.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Feb 2008, Anders Eriksson wrote:

> > This needs to be CCed to netdev.
> > Any chance that
> > 	git revert 69cc64d8d92
> > makes this report go away? 
> I'll have to install a git repo to check, or maybe you can send me the diff to 
> reverse vs. 2.6.25-rc2?

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
