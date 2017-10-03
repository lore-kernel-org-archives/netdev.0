From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/3] bridge: suppress arp pkts on BR_NEIGH_SUPPRESS ports
Date: Tue,  3 Oct 2017 11:21:15 -0700
Message-ID: <1507054876-16746-3-git-send-email-roopa@cumulusnetworks.com>
References: <1507054876-16746-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:49331 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750797AbdJCSVY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 14:21:24 -0400
Received: by mail-pg0-f42.google.com with SMTP id v13so5166927pgq.6
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 11:21:24 -0700 (PDT)
In-Reply-To: <1507054876-16746-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch avoids flooding and proxies arp packets
for BR_NEIGH_SUPPRESS ports.

Moves existing br_do_proxy_arp to br_do_proxy_suppress_arp
to support both proxy arp and neigh suppress.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_arp_nd_proxy.c | 184 +++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_device.c       |   9 +++
 net/bridge/br_input.c        |  63 ++-------------
 net/bridge/br_private.h      |   3 +
 4 files changed, 201 insertions(+), 58 deletions(-)

diff --git a/net/bridge/br_arp_nd_proxy.c b/net/bridge/br_arp_nd_proxy.c
index f889ad5..1177547 100644
--- a/net/bridge/br_arp_nd_proxy.c
+++ b/net/bridge/br_arp_nd_proxy.c
@@ -14,6 +14,13 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/neighbour.h>
+#include <net/arp.h>
+#include <linux/if_vlan.h>
+#include <linux/inetdevice.h>
+#include <net/addrconf.h>
 #include "br_private.h"
 
 void br_recalculate_neigh_suppress_enabled(struct net_bridge *br)
@@ -30,3 +37,180 @@ void br_recalculate_neigh_suppress_enabled(struct net_bridge *br)
 
 	br->neigh_suppress_enabled = neigh_suppress;
 }
+
+static void br_arp_send(struct net_bridge_port *p, int type, int ptype,
+			__be32 dest_ip, struct net_device *dev,
+			__be32 src_ip, const unsigned char *dest_hw,
+			const unsigned char *src_hw,
+			const unsigned char *target_hw,
+			__be16 vlan_proto, u16 vlan_tci)
+{
+	struct sk_buff *skb;
+
+	netdev_dbg(dev, "arp send dev %s dst %pI4 dst_hw %pM src %pI4 src_hw %pM\n",
+		   dev->name, &dest_ip, dest_hw, &src_ip, src_hw);
+
+	if (!vlan_tci) {
+		arp_send(type, ptype, dest_ip, dev, src_ip,
+			 dest_hw, src_hw, target_hw);
+		return;
+	}
+
+	skb = arp_create(type, ptype, dest_ip, dev, src_ip,
+			 dest_hw, src_hw, target_hw);
+	if (!skb)
+		return;
+
+	if (p) {
+		struct net_bridge_vlan_group *vg;
+		u16 pvid;
+
+		vg = nbp_vlan_group_rcu(p);
+		pvid = br_get_pvid(vg);
+		if (pvid == vlan_tci)
+			vlan_tci = 0;
+	}
+
+	if (vlan_tci) {
+		skb = vlan_insert_tag_set_proto(skb, vlan_proto,
+						vlan_tci);
+		if (!skb) {
+			net_err_ratelimited("%s: failed to insert VLAN tag\n",
+					    __func__);
+			return;
+		}
+	}
+
+	arp_xmit(skb);
+}
+
+static int br_chk_addr_ip(struct net_device *dev, void *data)
+{
+	__be32 ip = *(__be32 *)data;
+	struct in_device *in_dev;
+	__be32 addr = 0;
+
+	in_dev = __in_dev_get_rcu(dev);
+	if (in_dev)
+		addr = inet_confirm_addr(dev_net(dev), in_dev, 0, ip,
+					 RT_SCOPE_HOST);
+
+	if (addr == ip)
+		return 1;
+
+	return 0;
+}
+
+static bool br_is_local_ip(struct net_device *dev, __be32 ip)
+{
+	if (br_chk_addr_ip(dev, &ip))
+		return true;
+
+	/* check if ip is configured on upper dev */
+	if (netdev_walk_all_upper_dev_rcu(dev, br_chk_addr_ip, &ip))
+		return true;
+
+	return false;
+}
+
+void br_do_proxy_suppress_arp(struct sk_buff *skb, struct net_bridge *br,
+			      u16 vid, struct net_bridge_port *p)
+{
+	struct net_device *dev = br->dev;
+	struct net_device *vlandev = dev;
+	struct neighbour *n;
+	struct arphdr *parp;
+	u8 *arpptr, *sha;
+	__be32 sip, tip;
+
+	BR_INPUT_SKB_CB(skb)->proxyarp_replied = false;
+
+	if ((dev->flags & IFF_NOARP) ||
+	    !pskb_may_pull(skb, arp_hdr_len(dev)))
+		return;
+
+	parp = arp_hdr(skb);
+
+	if (parp->ar_pro != htons(ETH_P_IP) ||
+	    parp->ar_hln != dev->addr_len ||
+	    parp->ar_pln != 4)
+		return;
+
+	arpptr = (u8 *)parp + sizeof(struct arphdr);
+	sha = arpptr;
+	arpptr += dev->addr_len;	/* sha */
+	memcpy(&sip, arpptr, sizeof(sip));
+	arpptr += sizeof(sip);
+	arpptr += dev->addr_len;	/* tha */
+	memcpy(&tip, arpptr, sizeof(tip));
+
+	if (ipv4_is_loopback(tip) ||
+	    ipv4_is_multicast(tip))
+		return;
+
+	if (br->neigh_suppress_enabled) {
+		if (p && (p->flags & BR_NEIGH_SUPPRESS))
+			return;
+		if (ipv4_is_zeronet(sip) || sip == tip) {
+			/* prevent flooding to neigh suppress ports */
+			BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
+			return;
+		}
+	}
+
+	if (parp->ar_op != htons(ARPOP_REQUEST))
+		return;
+
+	if (vid != 0) {
+		vlandev = __vlan_find_dev_deep_rcu(br->dev, skb->vlan_proto,
+						   vid);
+		if (!vlandev)
+			return;
+	}
+
+	if (br->neigh_suppress_enabled && br_is_local_ip(vlandev, tip)) {
+		/* its our local ip, so don't proxy reply
+		 * and don't forward to neigh suppress ports
+		 */
+		BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
+		return;
+	}
+
+	n = neigh_lookup(&arp_tbl, &tip, vlandev);
+	if (n) {
+		struct net_bridge_fdb_entry *f;
+
+		if (!(n->nud_state & NUD_VALID)) {
+			neigh_release(n);
+			return;
+		}
+
+		f = br_fdb_find_rcu(br, n->ha, vid);
+		if (f) {
+			bool replied = false;
+
+			if ((p && (p->flags & BR_PROXYARP)) ||
+			    (f->dst && ((f->dst->flags & BR_PROXYARP_WIFI) ||
+				       (f->dst->flags & BR_NEIGH_SUPPRESS)))) {
+				if (!vid)
+					br_arp_send(p, ARPOP_REPLY, ETH_P_ARP,
+						    sip, skb->dev, tip, sha,
+						    n->ha, sha, 0, 0);
+				else
+					br_arp_send(p, ARPOP_REPLY, ETH_P_ARP,
+						    sip, skb->dev, tip, sha,
+						    n->ha, sha, skb->vlan_proto,
+						    skb_vlan_tag_get(skb));
+				replied = true;
+			}
+
+			/* If we have replied or as long as we know the
+			 * mac, indicate to arp replied
+			 */
+			if (replied || br->neigh_suppress_enabled)
+				BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
+		}
+
+		neigh_release(n);
+	}
+}
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index f6b6a92..53d1456 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -39,6 +39,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct pcpu_sw_netstats *brstats = this_cpu_ptr(br->stats);
 	const struct nf_br_ops *nf_ops;
 	const unsigned char *dest;
+	struct ethhdr *eth;
 	u16 vid = 0;
 
 	rcu_read_lock();
@@ -57,11 +58,19 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
 
 	skb_reset_mac_header(skb);
+	eth = eth_hdr(skb);
 	skb_pull(skb, ETH_HLEN);
 
 	if (!br_allowed_ingress(br, br_vlan_group_rcu(br), skb, &vid))
 		goto out;
 
+	if (IS_ENABLED(CONFIG_INET) &&
+	    (eth->h_proto == htons(ETH_P_ARP) ||
+	     eth->h_proto == htons(ETH_P_RARP)) &&
+	    br->neigh_suppress_enabled) {
+		br_do_proxy_suppress_arp(skb, br, vid, NULL);
+	}
+
 	dest = eth_hdr(skb)->h_dest;
 	if (is_broadcast_ether_addr(dest)) {
 		br_flood(br, skb, BR_PKT_BROADCAST, false, true);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 7cb6137..4b8d2ec 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -71,62 +71,6 @@ static int br_pass_frame_up(struct sk_buff *skb)
 		       br_netif_receive_skb);
 }
 
-static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
-			    u16 vid, struct net_bridge_port *p)
-{
-	struct net_device *dev = br->dev;
-	struct neighbour *n;
-	struct arphdr *parp;
-	u8 *arpptr, *sha;
-	__be32 sip, tip;
-
-	BR_INPUT_SKB_CB(skb)->proxyarp_replied = false;
-
-	if ((dev->flags & IFF_NOARP) ||
-	    !pskb_may_pull(skb, arp_hdr_len(dev)))
-		return;
-
-	parp = arp_hdr(skb);
-
-	if (parp->ar_pro != htons(ETH_P_IP) ||
-	    parp->ar_op != htons(ARPOP_REQUEST) ||
-	    parp->ar_hln != dev->addr_len ||
-	    parp->ar_pln != 4)
-		return;
-
-	arpptr = (u8 *)parp + sizeof(struct arphdr);
-	sha = arpptr;
-	arpptr += dev->addr_len;	/* sha */
-	memcpy(&sip, arpptr, sizeof(sip));
-	arpptr += sizeof(sip);
-	arpptr += dev->addr_len;	/* tha */
-	memcpy(&tip, arpptr, sizeof(tip));
-
-	if (ipv4_is_loopback(tip) ||
-	    ipv4_is_multicast(tip))
-		return;
-
-	n = neigh_lookup(&arp_tbl, &tip, dev);
-	if (n) {
-		struct net_bridge_fdb_entry *f;
-
-		if (!(n->nud_state & NUD_VALID)) {
-			neigh_release(n);
-			return;
-		}
-
-		f = br_fdb_find_rcu(br, n->ha, vid);
-		if (f && ((p->flags & BR_PROXYARP) ||
-			  (f->dst && (f->dst->flags & BR_PROXYARP_WIFI)))) {
-			arp_send(ARPOP_REPLY, ETH_P_ARP, sip, skb->dev, tip,
-				 sha, n->ha, sha);
-			BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
-		}
-
-		neigh_release(n);
-	}
-}
-
 /* note: already called with rcu_read_lock */
 int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
@@ -171,8 +115,11 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 
 	BR_INPUT_SKB_CB(skb)->brdev = br->dev;
 
-	if (IS_ENABLED(CONFIG_INET) && skb->protocol == htons(ETH_P_ARP))
-		br_do_proxy_arp(skb, br, vid, p);
+	if (IS_ENABLED(CONFIG_INET) &&
+	    (skb->protocol == htons(ETH_P_ARP) ||
+	     skb->protocol == htons(ETH_P_RARP))) {
+		br_do_proxy_suppress_arp(skb, br, vid, p);
+	}
 
 	switch (pkt_type) {
 	case BR_PKT_MULTICAST:
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f47332e..bb095dc 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -1139,5 +1139,8 @@ static inline void br_switchdev_frame_unmark(struct sk_buff *skb)
 }
 #endif /* CONFIG_NET_SWITCHDEV */
 
+/* br_arp_nd_proxy.c */
 void br_recalculate_neigh_suppress_enabled(struct net_bridge *br);
+void br_do_proxy_suppress_arp(struct sk_buff *skb, struct net_bridge *br,
+			      u16 vid, struct net_bridge_port *p);
 #endif
-- 
2.1.4
