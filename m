From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] bridge: netfilter: Use ether_addr_copy
Date: Sun, 23 Feb 2014 00:05:26 -0800
Message-ID: <8ffb523682d29d344873ad09b9c27faddcb90b5f.1393142669.git.joe@perches.com>
References: <06d3e7e463c2bbfa8b5264e67daace1181ada090.1393142669.git.joe@perches.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Bart De Schuymer <bart.de.schuymer@pandora.be>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <06d3e7e463c2bbfa8b5264e67daace1181ada090.1393142669.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the uses of memcpy to ether_addr_copy because
for some architectures it is smaller and faster.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/bridge/br_netfilter.c           | 2 +-
 net/bridge/netfilter/ebt_among.c    | 2 +-
 net/bridge/netfilter/ebt_dnat.c     | 2 +-
 net/bridge/netfilter/ebt_redirect.c | 6 +++---
 net/bridge/netfilter/ebt_snat.c     | 2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index b008c59..df0f114 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -506,7 +506,7 @@ bridged_dnat:
 					       1);
 				return 0;
 			}
-			memcpy(eth_hdr(skb)->h_dest, dev->dev_addr, ETH_ALEN);
+			ether_addr_copy(eth_hdr(skb)->h_dest, dev->dev_addr);
 			skb->pkt_type = PACKET_HOST;
 		}
 	} else {
diff --git a/net/bridge/netfilter/ebt_among.c b/net/bridge/netfilter/ebt_among.c
index 3fb3c84..9024283 100644
--- a/net/bridge/netfilter/ebt_among.c
+++ b/net/bridge/netfilter/ebt_among.c
@@ -28,7 +28,7 @@ static bool ebt_mac_wormhash_contains(const struct ebt_mac_wormhash *wh,
 	uint32_t cmp[2] = { 0, 0 };
 	int key = ((const unsigned char *)mac)[5];
 
-	memcpy(((char *) cmp) + 2, mac, ETH_ALEN);
+	ether_addr_copy(((char *) cmp) + 2, mac);
 	start = wh->table[key];
 	limit = wh->table[key + 1];
 	if (ip) {
diff --git a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
index c59f7bf..4e0b0c3 100644
--- a/net/bridge/netfilter/ebt_dnat.c
+++ b/net/bridge/netfilter/ebt_dnat.c
@@ -22,7 +22,7 @@ ebt_dnat_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	if (!skb_make_writable(skb, 0))
 		return EBT_DROP;
 
-	memcpy(eth_hdr(skb)->h_dest, info->mac, ETH_ALEN);
+	ether_addr_copy(eth_hdr(skb)->h_dest, info->mac);
 	return info->target;
 }
 
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index 46624bb..20396499 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -25,10 +25,10 @@ ebt_redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
 
 	if (par->hooknum != NF_BR_BROUTING)
 		/* rcu_read_lock()ed by nf_hook_slow */
-		memcpy(eth_hdr(skb)->h_dest,
-		       br_port_get_rcu(par->in)->br->dev->dev_addr, ETH_ALEN);
+		ether_addr_copy(eth_hdr(skb)->h_dest,
+				br_port_get_rcu(par->in)->br->dev->dev_addr);
 	else
-		memcpy(eth_hdr(skb)->h_dest, par->in->dev_addr, ETH_ALEN);
+		ether_addr_copy(eth_hdr(skb)->h_dest, par->in->dev_addr);
 	skb->pkt_type = PACKET_HOST;
 	return info->target;
 }
diff --git a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
index 0f6b118..e56ccd0 100644
--- a/net/bridge/netfilter/ebt_snat.c
+++ b/net/bridge/netfilter/ebt_snat.c
@@ -24,7 +24,7 @@ ebt_snat_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	if (!skb_make_writable(skb, 0))
 		return EBT_DROP;
 
-	memcpy(eth_hdr(skb)->h_source, info->mac, ETH_ALEN);
+	ether_addr_copy(eth_hdr(skb)->h_source, info->mac);
 	if (!(info->target & NAT_ARP_BIT) &&
 	    eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) {
 		const struct arphdr *ap;
-- 
1.8.1.2.459.gbcd45b4.dirty
