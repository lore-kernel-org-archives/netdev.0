From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] net: bridge: fix dest lookup when vlan proto doesn't match
Date: Thu, 13 Jul 2017 16:09:10 +0300
Message-ID: <1499951350-2087-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: makita.toshiaki@lab.ntt.co.jp, roopa@cumulusnetworks.com,
        davem@davemloft.net, anitha@cumulusnetworks.com,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36117 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751244AbdGMNJr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 09:09:47 -0400
Received: by mail-wm0-f45.google.com with SMTP id 62so23141222wmw.1
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 06:09:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With 802.1ad support the vlan_ingress code started checking for vlan
protocol mismatch which causes the current tag to be inserted and the
bridge vlan protocol & pvid to be set. The vlan tag insertion changes
the skb mac_header and thus the lookup mac dest pointer which was loaded
prior to calling br_allowed_ingress in br_handle_frame_finish is VLAN_HLEN
bytes off now, pointing to the last two bytes of the destination mac and
the first four of the source mac causing lookups to always fail and
broadcasting all such packets to all ports. Same thing happens for locally
originated packets when passing via br_dev_xmit. So load the dest pointer
after the vlan checks and possible skb change.

Fixes: 8580e2117c06 ("bridge: Prepare for 802.1ad vlan filtering support")
Reported-by: Anitha Narasimha Murthy <anitha@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_device.c | 3 ++-
 net/bridge/br_input.c  | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index f0f3447e8aa4..861ae2a165f4 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -34,11 +34,11 @@ static struct lock_class_key bridge_netdev_addr_lock_key;
 netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
-	const unsigned char *dest = skb->data;
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct pcpu_sw_netstats *brstats = this_cpu_ptr(br->stats);
 	const struct nf_br_ops *nf_ops;
+	const unsigned char *dest;
 	u16 vid = 0;
 
 	rcu_read_lock();
@@ -61,6 +61,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!br_allowed_ingress(br, br_vlan_group_rcu(br), skb, &vid))
 		goto out;
 
+	dest = eth_hdr(skb)->h_dest;
 	if (is_broadcast_ether_addr(dest)) {
 		br_flood(br, skb, BR_PKT_BROADCAST, false, true);
 	} else if (is_multicast_ether_addr(dest)) {
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 013f2290bfa5..7637f58c1226 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -131,11 +131,11 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
-	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	enum br_pkt_type pkt_type = BR_PKT_UNICAST;
 	struct net_bridge_fdb_entry *dst = NULL;
 	struct net_bridge_mdb_entry *mdst;
 	bool local_rcv, mcast_hit = false;
+	const unsigned char *dest;
 	struct net_bridge *br;
 	u16 vid = 0;
 
@@ -153,6 +153,7 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 		br_fdb_update(br, p, eth_hdr(skb)->h_source, vid, false);
 
 	local_rcv = !!(br->dev->flags & IFF_PROMISC);
+	dest = eth_hdr(skb)->h_dest;
 	if (is_multicast_ether_addr(dest)) {
 		/* by definition the broadcast is also a multicast address */
 		if (is_broadcast_ether_addr(dest)) {
-- 
2.1.4
