From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/13] atm: Convert compare_ether_addr to ether_addr_equal
Date: Tue,  8 May 2012 21:56:50 -0700
Message-ID: <c113ba8aac3d761556f7322aecccb080a1d3bbce.1336538938.git.joe@perches.com>
References: <cover.1336538937.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1336538937.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the new bool function ether_addr_equal to add
some clarity and reduce the likelihood for misuse
of compare_ether_addr for sorting.

Done via cocci script:

$ cat compare_ether_addr.cocci
@@
expression a,b;
@@
-	!compare_ether_addr(a, b)
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	compare_ether_addr(a, b)
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) == 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) != 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) == 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) != 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!!ether_addr_equal(a, b)
+	ether_addr_equal(a, b)

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/lec.c |    6 +++---
 net/atm/mpc.c |    3 +--
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index f1964ca..bb35cb7 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1255,7 +1255,7 @@ static int lane2_associate_req(struct net_device *dev, const u8 *lan_dst,
 	struct sk_buff *skb;
 	struct lec_priv *priv = netdev_priv(dev);
 
-	if (compare_ether_addr(lan_dst, dev->dev_addr))
+	if (!ether_addr_equal(lan_dst, dev->dev_addr))
 		return 0;	/* not our mac address */
 
 	kfree(priv->tlvs);	/* NULL if there was no previous association */
@@ -1662,7 +1662,7 @@ static struct lec_arp_table *lec_arp_find(struct lec_priv *priv,
 
 	head = &priv->lec_arp_tables[HASH(mac_addr[ETH_ALEN - 1])];
 	hlist_for_each_entry(entry, node, head, next) {
-		if (!compare_ether_addr(mac_addr, entry->mac_addr))
+		if (ether_addr_equal(mac_addr, entry->mac_addr))
 			return entry;
 	}
 	return NULL;
@@ -1849,7 +1849,7 @@ static struct atm_vcc *lec_arp_resolve(struct lec_priv *priv,
 		case 1:
 			return priv->mcast_vcc;
 		case 2:	/* LANE2 wants arp for multicast addresses */
-			if (!compare_ether_addr(mac_to_find, bus_mac))
+			if (ether_addr_equal(mac_to_find, bus_mac))
 				return priv->mcast_vcc;
 			break;
 		default:
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index aa97240..d4cc1be 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -592,8 +592,7 @@ static netdev_tx_t mpc_send_packet(struct sk_buff *skb,
 		goto non_ip;
 
 	while (i < mpc->number_of_mps_macs) {
-		if (!compare_ether_addr(eth->h_dest,
-					(mpc->mps_macs + i*ETH_ALEN)))
+		if (ether_addr_equal(eth->h_dest, mpc->mps_macs + i * ETH_ALEN))
 			if (send_via_shortcut(skb, mpc) == 0) /* try shortcut */
 				return NETDEV_TX_OK;
 		i++;
-- 
1.7.8.111.gad25c.dirty
