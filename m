From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] vxlan: keep original skb ownership
Date: Mon, 06 Jan 2014 09:54:31 -0800
Message-ID: <1389030871.12212.203.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387803413-22152-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	stephen@networkplumber.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:64176 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601AbaAFRye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 12:54:34 -0500
Received: by mail-yh0-f54.google.com with SMTP id z12so3726112yhz.13
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 09:54:33 -0800 (PST)
In-Reply-To: <1387803413-22152-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Sathya Perla posted a patch trying to address following problem :

<quote>
 The vxlan driver sets itself as the socket owner for all the TX flows
 it encapsulates (using vxlan_set_owner()) and assigns it's own skb
 destructor. This causes all tunneled traffic to land up on only one TXQ
 as all encapsulated skbs refer to the vxlan socket and not the original
 socket.  Also, the vxlan skb destructor breaks some functionality for
 tunneled traffic like wmem accounting and as TCP small queues and
 FQ/pacing packet scheduler.
</quote>

I reworked Sathya patch and added some explanations.

vxlan_xmit() can avoid one skb_clone()/dev_kfree_skb() pair
and gain better drop monitor accuracy, by calling kfree_skb() when
appropriate.

The UDP socket used by vxlan to perform encapsulation of xmit packets
do not need to be alive while packets leave vxlan code. Its better
to keep original socket ownership to get proper feedback from qdisc and
NIC layers.

We use skb->sk to 

A) control amount of bytes/packets queued on behalf of a socket, but
prior vxlan code did the skb->sk transfert without any limit/control
on vxlan socket sk_sndbuf.

B) security purposes (as selinux) or netfilter uses, and I do not think
anything is prepared to handle vxlan stacked case in this area.

By not changing ownership, vxlan tunnels behave like other tunnels.
As Stephen mentioned, we might do the same change in L2TP.

Reported-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |   31 ++++++++++---------------------
 1 file changed, 10 insertions(+), 21 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 474a99ed0222..ab2e92eec949 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1381,20 +1381,6 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
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
@@ -1514,8 +1500,6 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	ip6h->daddr	  = *daddr;
 	ip6h->saddr	  = *saddr;
 
-	vxlan_set_owner(vs->sock->sk, skb);
-
 	err = handle_offloads(skb);
 	if (err)
 		return err;
@@ -1572,8 +1556,6 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	uh->len = htons(skb->len);
 	uh->check = 0;
 
-	vxlan_set_owner(vs->sock->sk, skb);
-
 	err = handle_offloads(skb);
 	if (err)
 		return err;
@@ -1786,7 +1768,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct ethhdr *eth;
 	bool did_rsc = false;
-	struct vxlan_rdst *rdst;
+	struct vxlan_rdst *rdst, *fdst = NULL;
 	struct vxlan_fdb *f;
 
 	skb_reset_mac_header(skb);
@@ -1828,7 +1810,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 				vxlan_fdb_miss(vxlan, eth->h_dest);
 
 			dev->stats.tx_dropped++;
-			dev_kfree_skb(skb);
+			kfree_skb(skb);
 			return NETDEV_TX_OK;
 		}
 	}
@@ -1836,12 +1818,19 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
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
 
