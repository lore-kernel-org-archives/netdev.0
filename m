From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC net-next PATCH] macvtap: Add packet capture support
Date: Wed, 20 Nov 2013 13:04:09 -0500
Message-ID: <1384970649-29839-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753916Ab3KTSEP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 13:04:15 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rAKI4Drk021319
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 13:04:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently it is impossible to capture traffic when using a macvtap
device.  The reason is that all capture handling is done either in
dev_hard_start_xmit() or in __netif_receive_skb_core().  Macvtap
currenlty doesn't use dev_hard_start_xmit(), and at the time the
packet traverses __netif_receive_skb_core, the skb->dev is set to
the lower-level device that doesn't end up matching macvtap.

To solve the issue, use dev_hard_start_xmit() on the output path.
On the input path, it is toughter to solve since macvtap ends up
consuming the skb so there is nothing more left for
__netif_receive_skb_core() to do.  A simple solution is to
pull the code that delivers things to the taps/captures into
its own function and allow macvtap to call it from its receive
routine.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
This is only an RFC.  I'd like to solicit comments on this simple
approach.  A more complicated solution would have been to give
macvtap its own rx_handler and return RX_HANDLER_ANOTHER during
receive operation to make the packet go through another round of
capturing and hit the macvtap rx_handler.  I thought this would
hurt performance too much for no real gain.

Thanks
-vlad

 drivers/net/macvtap.c     |  4 +++-
 include/linux/netdevice.h |  2 ++
 net/core/dev.c            | 33 ++++++++++++++++++++++++++-------
 3 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index dc76670..0ed8fae 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -334,6 +334,7 @@ drop:
  */
 static int macvtap_receive(struct sk_buff *skb)
 {
+	netif_receive_skb_taps(skb, true);
 	skb_push(skb, ETH_HLEN);
 	return macvtap_forward(skb->dev, skb);
 }
@@ -727,8 +728,9 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
 	}
 	if (vlan) {
+		skb->dev = vlan->dev;
 		local_bh_disable();
-		macvlan_start_xmit(skb, vlan->dev);
+		dev_hard_start_xmit(skb, vlan->dev, NULL, NULL);
 		local_bh_enable();
 	} else {
 		kfree_skb(skb);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8b3de7c..84880eb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2383,6 +2383,8 @@ void dev_kfree_skb_any(struct sk_buff *skb);
 int netif_rx(struct sk_buff *skb);
 int netif_rx_ni(struct sk_buff *skb);
 int netif_receive_skb(struct sk_buff *skb);
+struct packet_type *netif_receive_skb_taps(struct sk_buff *skb,
+					   bool last_deliver);
 gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb);
 void napi_gro_flush(struct napi_struct *napi, bool flush_old);
 struct sk_buff *napi_get_frags(struct napi_struct *napi);
diff --git a/net/core/dev.c b/net/core/dev.c
index da9c5e1..50f0ac4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3484,6 +3484,31 @@ static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
 	}
 }
 
+struct packet_type *netif_receive_skb_taps(struct sk_buff *skb,
+					   bool last_deliver)
+{
+	struct packet_type *ptype, *pt_prev = NULL;
+	struct net_device *orig_dev;
+
+	if (list_empty(&ptype_all))
+		return NULL;
+
+	orig_dev = skb->dev;
+	list_for_each_entry_rcu(ptype, &ptype_all, list) {
+		if (!ptype->dev || ptype->dev == skb->dev) {
+			if (pt_prev)
+				deliver_skb(skb, pt_prev, orig_dev);
+			pt_prev = ptype;
+		}
+	}
+
+	if (last_deliver && pt_prev)
+		deliver_skb(skb, pt_prev, orig_dev);
+
+	return pt_prev;
+}
+EXPORT_SYMBOL_GPL(netif_receive_skb_taps);
+
 static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 {
 	struct packet_type *ptype, *pt_prev;
@@ -3535,13 +3560,7 @@ another_round:
 	if (pfmemalloc)
 		goto skip_taps;
 
-	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (!ptype->dev || ptype->dev == skb->dev) {
-			if (pt_prev)
-				ret = deliver_skb(skb, pt_prev, orig_dev);
-			pt_prev = ptype;
-		}
-	}
+	pt_prev = netif_receive_skb_taps(skb, false);
 
 skip_taps:
 #ifdef CONFIG_NET_CLS_ACT
-- 
1.8.4.2
