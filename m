From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 2/2] vlan: Do not put vlan headers back on bridge and macvlan ports
Date: Mon, 16 Nov 2015 15:43:45 -0500
Message-ID: <1447706625-25979-3-git-send-email-vyasevic@redhat.com>
References: <1447706625-25979-1-git-send-email-vyasevic@redhat.com>
Cc: phil@nwl.cc, kaber@trash.net,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35784 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbbKPUn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:43:56 -0500
Received: by qgec40 with SMTP id c40so58327707qge.2
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 12:43:55 -0800 (PST)
In-Reply-To: <1447706625-25979-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a vlan is configured with REORDER_HEADER set to 0, the vlan
header is put back into the packet and makes it appear that
the vlan header is still there even after it's been processed.
This posses a problem for bridge and macvlan ports.  The packets
passed to those device may be forwarded and at the time of the
forward, vlan headers end up being unexpectedly present.

With the patch, we make sure that we do not put the vlan header
back (when REORDER_HEADER is 0) if a bridge or macvlan has
been configured on top of the vlan device.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/linux/netdevice.h | 5 +++++
 net/8021q/vlan_core.c     | 4 +++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2d15e38..2f9d47e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3842,6 +3842,11 @@ static inline bool netif_is_bridge_master(const struct net_device *dev)
 	return dev->priv_flags & IFF_EBRIDGE;
 }
 
+static inline bool netif_is_bridge_port(const struct net_device *dev)
+{
+	return dev->priv_flags & IFF_BRIDGE_PORT;
+}
+
 static inline bool netif_is_ovs_master(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_OPENVSWITCH;
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 61bf2a0..c2c9a0f 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -30,7 +30,9 @@ bool vlan_do_receive(struct sk_buff **skbp)
 			skb->pkt_type = PACKET_HOST;
 	}
 
-	if (!(vlan_dev_priv(vlan_dev)->flags & VLAN_FLAG_REORDER_HDR)) {
+	if (!(vlan_dev_priv(vlan_dev)->flags & VLAN_FLAG_REORDER_HDR) &&
+	    !netif_is_macvlan_port(vlan_dev) &&
+	    !netif_is_bridge_port(vlan_dev)) {
 		unsigned int offset = skb->data - skb_mac_header(skb);
 
 		/*
-- 
1.9.3
