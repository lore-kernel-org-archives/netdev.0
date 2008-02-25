From: David Miller <davem@davemloft.net>
Subject: Re: lockdep warnings in ipv6
Date: Sun, 24 Feb 2008 17:16:25 -0800 (PST)
Message-ID: <20080224.171625.193730295.davem@davemloft.net>
References: <Pine.LNX.4.64.0802241307310.15321@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jengelh@computergmbh.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53902
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756331AbYBYBPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 20:15:44 -0500
In-Reply-To: <Pine.LNX.4.64.0802241307310.15321@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@computergmbh.de>
Date: Sun, 24 Feb 2008 13:10:58 +0100 (CET)

> when doing IPv6 (ping6, ssh otherhost, etc.), lockdep spews a warning in 
> 2.6.25-rc2 on the target. CONFIG_..._FRAME_POINTER is off,

We reverted the change which causes this, and it results
in real bonafide lockups too :-)

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
