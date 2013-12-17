From: Sathya Perla <sathya.perla@emulex.com>
Subject: [RFC] net: distribute vxlan tunneled traffic across multiple TXQs
Date: Tue, 17 Dec 2013 14:10:26 +0530
Message-ID: <1387269626-12463-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:55259 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab3LQIgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 03:36:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX traffic is distributed across multiple TXQs using skb->sk->sk_hash.
For vxlan skbs, the reference to the original socket (skb->sk) is replaced
with vxlan-sk. Because of this all tunneled traffic ends up only on one TXQ.

This patch uses the skb->rxhash field to carry the original sk->sk_hash
value so that it can be used by netdev layer to pick a TXQ. If this approach
is agreeable then we can change the name of skb->rxhash to skb->hash so that
it can be used in both RX and TX paths.

But, after a TXQ is picked based on the skb->rxhash for tunneled traffic,
it's index cannot be recorded in the original socket as it's reference
is no longer available in skb. So, the TXQ-index would need to be
computed (from skb->rxhash) for each skb. Any ideas on how this can be
avoided?

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/vxlan.c       |    2 ++
 net/core/flow_dissector.c |    6 ++++--
 net/ipv4/ip_tunnel_core.c |    1 -
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 58f6a0c..f4e4a83 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1572,6 +1572,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	uh->len = htons(skb->len);
 	uh->check = 0;
 
+	if (skb->sk && skb->sk->sk_hash)
+		skb->rxhash = skb->sk->sk_hash;
 	vxlan_set_owner(vs->sock->sk, skb);
 
 	err = handle_offloads(skb);
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index d6ef173..5a5ae5a 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -260,7 +260,9 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 		qcount = dev->tc_to_txq[tc].count;
 	}
 
-	if (skb->sk && skb->sk->sk_hash)
+	if (skb->encapsulation && skb->rxhash)
+		hash = skb->rxhash;
+	else if (skb->sk && skb->sk->sk_hash)
 		hash = skb->sk->sk_hash;
 	else
 		hash = (__force u16) skb->protocol;
@@ -383,7 +385,7 @@ u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
 		if (new_index < 0)
 			new_index = skb_tx_hash(dev, skb);
 
-		if (queue_index != new_index && sk &&
+		if (queue_index != new_index && sk && !skb->encapsulation &&
 		    rcu_access_pointer(sk->sk_dst_cache))
 			sk_tx_queue_set(sk, new_index);
 
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 42ffbc8..183313b 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -56,7 +56,6 @@ int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 
 	skb_scrub_packet(skb, xnet);
 
-	skb->rxhash = 0;
 	skb_dst_set(skb, &rt->dst);
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
-- 
1.7.1
