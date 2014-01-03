From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net] bridge: Fix crash with vlan filtering and tcpdump
Date: Fri,  3 Jan 2014 11:12:33 -0500
Message-ID: <1388765553-12965-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27583 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863AbaACQMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 11:12:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the vlan filtering is enabled on the bridge, but
the filter is not configured on the bridge device itself,
running tcpdump on the bridge device will result in a
an Ooops with NULL pointer dereference.  The reason
is that br_pass_frame_up() will bypass the vlan
check because promisc flag is set.  It will then try
to get the table pointer and process the packet based
on the table.  Since the table pointer is NULL, we oops.
Catch this special condition in br_handle_vlan().

Reported-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_input.c | 11 ++++++-----
 net/bridge/br_vlan.c  | 12 ++++++++++++
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 7e73c32..67fbea0 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -29,6 +29,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	struct net_device *indev, *brdev = BR_INPUT_SKB_CB(skb)->brdev;
 	struct net_bridge *br = netdev_priv(brdev);
 	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
+	struct net_port_vlans *pv;
 
 	u64_stats_update_begin(&brstats->syncp);
 	brstats->rx_packets++;
@@ -39,18 +40,18 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	 * packet is allowed except in promisc modue when someone
 	 * may be running packet capture.
 	 */
+	pv = br_get_vlan_info(br);
 	if (!(brdev->flags & IFF_PROMISC) &&
-	    !br_allowed_egress(br, br_get_vlan_info(br), skb)) {
+	    !br_allowed_egress(br, pv, skb)) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
 
-	skb = br_handle_vlan(br, br_get_vlan_info(br), skb);
-	if (!skb)
-		return NET_RX_DROP;
-
 	indev = skb->dev;
 	skb->dev = brdev;
+	skb = br_handle_vlan(br, pv, skb);
+	if (!skb)
+		return NET_RX_DROP;
 
 	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
 		       netif_receive_skb);
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index af5ebd1..ea0c29b 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -144,6 +144,18 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 	if (!br->vlan_enabled)
 		goto out;
 
+	/* Vlan filter table must be configrured at this point.  The
+	 * only exception is the bridge is set in promisc mode and the
+	 * packet is destined for the bridge device.  In this case
+	 * pass the packet as is.
+	 */
+	if (!pv) {
+       		if ((br->dev->flags & IFF_PROMISC) && skb->dev == br->dev)
+			goto out;
+		else
+			BUG();
+	}
+
 	/* At this point, we know that the frame was filtered and contains
 	 * a valid vlan id.  If the vlan id is set in the untagged bitmap,
 	 * send untagged; otherwise, send taged.
-- 
1.8.4.2
