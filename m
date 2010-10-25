From: Ben Greear <greearb@candelatech.com>
Subject: [PATCH 2.6.36/stable] vlan:  Fix crash when hwaccel rx pkt for non-existant vlan.
Date: Mon, 25 Oct 2010 15:52:46 -0700
Message-ID: <1288047166-5660-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35543 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab0JYWwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 18:52:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vlan_hwaccel_do_receive code expected skb->dev to always
be a vlan device, but if the NIC was promisc, and the VLAN
for a particular VID was not configured, then this method
could receive a packet where skb->dev was NOT a vlan
device.  This caused access of bad memory and a crash.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---

This passes some quick testing, but it needs review, as
I have not messed with the VLAN code in a while and might
be missing something.

:100644 100644 0eb96f7... 2883d0e... M	net/8021q/vlan_core.c
:100644 100644 660dd41... 5dc45b9... M	net/core/dev.c
 net/8021q/vlan_core.c |   12 +++++++++---
 net/core/dev.c        |    5 +++--
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 0eb96f7..2883d0e 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -43,10 +43,16 @@ int vlan_hwaccel_do_receive(struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	struct vlan_rx_stats     *rx_stats;
 
-	skb->dev = vlan_dev_info(dev)->real_dev;
-	netif_nit_deliver(skb);
+	if (is_vlan_dev(dev)) {
+		skb->dev = vlan_dev_info(dev)->real_dev;
+		netif_nit_deliver(skb);
+		skb->dev = dev;
+	} else {
+		netif_nit_deliver(skb);
+		skb->pkt_type = PACKET_OTHERHOST;
+		return 0;
+	}
 
-	skb->dev = dev;
 	skb->priority = vlan_get_ingress_priority(dev, skb->vlan_tci);
 	skb->vlan_tci = 0;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 660dd41..5dc45b9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2828,8 +2828,9 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	if (!netdev_tstamp_prequeue)
 		net_timestamp_check(skb);
 
-	if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
-		return NET_RX_SUCCESS;
+	if (vlan_tx_tag_present(skb))
+		/* This method cannot fail at this time. */
+		vlan_hwaccel_do_receive(skb);
 
 	/* if we've gotten here through NAPI, check netpoll */
 	if (netpoll_receive_skb(skb))
-- 
1.6.2.5

