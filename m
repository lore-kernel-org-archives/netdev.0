From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] vxlan: distribute vxlan tunneled traffic
 across multiple TXQs
Date: Tue, 24 Dec 2013 10:39:06 -0800
Message-ID: <1387910346.12212.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387803413-22152-1-git-send-email-sathya.perla@emulex.com>
	 <20131223112854.572b11aa@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sathya Perla <sathya.perla@emulex.com>, netdev@vger.kernel.org,
	edumazet@google.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:39757 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241Ab3LXSjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 13:39:09 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so6772687pab.35
        for <netdev@vger.kernel.org>; Tue, 24 Dec 2013 10:39:09 -0800 (PST)
In-Reply-To: <20131223112854.572b11aa@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-23 at 11:28 -0800, Stephen Hemminger wrote:

> The idea is good, but without the destructor there is nothing to keep
> the UDP socket from being destroyed while packet is being sent on another
> CPU.

I see no requirement of holding a reference on the vxlan UDP socket in
transmit path.

At the time vxlan_set_owner() is called, nothing requires access to the
socket anymore. If you believe its needed, then its already too late.

Sathya, your patch is a step in the right direction, but the skb_clone()
thing should be done a bit differently.

The trick would be to avoid the skb_clone() for the last
vxlan_xmit_one() call.

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 249e01c5600c..3a1e2cee7c6e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1366,20 +1366,6 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
-static void vxlan_sock_put(struct sk_buff *skb)
-{
-	sock_put(skb->sk);
-}
-
-/* On transmit, associate with the tunnel socket */
-static void vxlan_set_owner(struct sock *sk, struct sk_buff *skb)
-{
-	skb_orphan(skb);
-	sock_hold(sk);
-	skb->sk = sk;
-	skb->destructor = vxlan_sock_put;
-}
-
 /* Compute source port for outgoing packet
  *   first choice to use L4 flow hash since it will spread
  *     better and maybe available from hardware
@@ -1499,8 +1485,6 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	ip6h->daddr	  = *daddr;
 	ip6h->saddr	  = *saddr;
 
-	vxlan_set_owner(vs->sock->sk, skb);
-
 	err = handle_offloads(skb);
 	if (err)
 		return err;
@@ -1557,8 +1541,6 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	uh->len = htons(skb->len);
 	uh->check = 0;
 
-	vxlan_set_owner(vs->sock->sk, skb);
-
 	err = handle_offloads(skb);
 	if (err)
 		return err;
@@ -1770,7 +1752,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct ethhdr *eth;
 	bool did_rsc = false;
-	struct vxlan_rdst *rdst;
+	struct vxlan_rdst *rdst, *fdst = NULL;
 	struct vxlan_fdb *f;
 
 	skb_reset_mac_header(skb);
@@ -1812,7 +1794,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 				vxlan_fdb_miss(vxlan, eth->h_dest);
 
 			dev->stats.tx_dropped++;
-			dev_kfree_skb(skb);
+			kfree_skb(skb);
 			return NETDEV_TX_OK;
 		}
 	}
@@ -1820,12 +1802,19 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	list_for_each_entry_rcu(rdst, &f->remotes, list) {
 		struct sk_buff *skb1;
 
+		if (!fdst) {
+			fdst = rdst;
+			continue;
+		}
 		skb1 = skb_clone(skb, GFP_ATOMIC);
 		if (skb1)
 			vxlan_xmit_one(skb1, dev, rdst, did_rsc);
 	}
 
-	dev_kfree_skb(skb);
+	if (fdst)
+		vxlan_xmit_one(skb, dev, fdst, did_rsc);
+	else
+		kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
 
