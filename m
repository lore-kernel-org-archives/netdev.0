From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/26] etherdevice.h & bridge: netfilter: Add and use ether_addr_equal_masked
Date: Wed,  6 Jul 2016 16:24:05 +0200
Message-ID: <1467815048-2240-24-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>

There are code duplications of a masked ethernet address comparison here
so make it a separate function instead.

Miscellanea:

o Neaten alignment of FWINV macro uses to make it clearer for the reader

Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/etherdevice.h     | 23 +++++++++++++++++++
 net/bridge/netfilter/ebt_arp.c  | 17 +++++---------
 net/bridge/netfilter/ebt_stp.c  | 49 ++++++++++++++++++-----------------------
 net/bridge/netfilter/ebtables.c | 17 +++++---------
 4 files changed, 57 insertions(+), 49 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 37ff4a6..6fec9e8 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -374,6 +374,29 @@ static inline bool ether_addr_equal_unaligned(const u8 *addr1, const u8 *addr2)
 }
 
 /**
+ * ether_addr_equal_masked - Compare two Ethernet addresses with a mask
+ * @addr1: Pointer to a six-byte array containing the 1st Ethernet address
+ * @addr2: Pointer to a six-byte array containing the 2nd Ethernet address
+ * @mask: Pointer to a six-byte array containing the Ethernet address bitmask
+ *
+ * Compare two Ethernet addresses with a mask, returns true if for every bit
+ * set in the bitmask the equivalent bits in the ethernet addresses are equal.
+ * Using a mask with all bits set is a slower ether_addr_equal.
+ */
+static inline bool ether_addr_equal_masked(const u8 *addr1, const u8 *addr2,
+					   const u8 *mask)
+{
+	int i;
+
+	for (i = 0; i < ETH_ALEN; i++) {
+		if ((addr1[i] ^ addr2[i]) & mask[i])
+			return false;
+	}
+
+	return true;
+}
+
+/**
  * is_etherdev_addr - Tell if given Ethernet address belongs to the device.
  * @dev: Pointer to a device structure
  * @addr: Pointer to a six-byte array containing the Ethernet address
diff --git a/net/bridge/netfilter/ebt_arp.c b/net/bridge/netfilter/ebt_arp.c
index cd457b8..cca0a89 100644
--- a/net/bridge/netfilter/ebt_arp.c
+++ b/net/bridge/netfilter/ebt_arp.c
@@ -65,7 +65,6 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (info->bitmask & (EBT_ARP_SRC_MAC | EBT_ARP_DST_MAC)) {
 		const unsigned char *mp;
 		unsigned char _mac[ETH_ALEN];
-		uint8_t verdict, i;
 
 		if (ah->ar_hln != ETH_ALEN || ah->ar_hrd != htons(ARPHRD_ETHER))
 			return false;
@@ -74,11 +73,9 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 						sizeof(_mac), &_mac);
 			if (mp == NULL)
 				return false;
-			verdict = 0;
-			for (i = 0; i < 6; i++)
-				verdict |= (mp[i] ^ info->smaddr[i]) &
-				       info->smmsk[i];
-			if (FWINV(verdict != 0, EBT_ARP_SRC_MAC))
+			if (FWINV(!ether_addr_equal_masked(mp, info->smaddr,
+							   info->smmsk),
+				  EBT_ARP_SRC_MAC))
 				return false;
 		}
 
@@ -88,11 +85,9 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 						sizeof(_mac), &_mac);
 			if (mp == NULL)
 				return false;
-			verdict = 0;
-			for (i = 0; i < 6; i++)
-				verdict |= (mp[i] ^ info->dmaddr[i]) &
-					info->dmmsk[i];
-			if (FWINV(verdict != 0, EBT_ARP_DST_MAC))
+			if (FWINV(!ether_addr_equal_masked(mp, info->dmaddr,
+							   info->dmmsk),
+				  EBT_ARP_DST_MAC))
 				return false;
 		}
 	}
diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index e77f90b..45f73d5 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -46,7 +46,6 @@ static bool ebt_filter_config(const struct ebt_stp_info *info,
 	const struct ebt_stp_config_info *c;
 	u16 v16;
 	u32 v32;
-	int verdict, i;
 
 	c = &info->config;
 	if ((info->bitmask & EBT_STP_FLAGS) &&
@@ -54,66 +53,62 @@ static bool ebt_filter_config(const struct ebt_stp_info *info,
 		return false;
 	if (info->bitmask & EBT_STP_ROOTPRIO) {
 		v16 = NR16(stpc->root);
-		if (FWINV(v16 < c->root_priol ||
-		    v16 > c->root_priou, EBT_STP_ROOTPRIO))
+		if (FWINV(v16 < c->root_priol || v16 > c->root_priou,
+			  EBT_STP_ROOTPRIO))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_ROOTADDR) {
-		verdict = 0;
-		for (i = 0; i < 6; i++)
-			verdict |= (stpc->root[2+i] ^ c->root_addr[i]) &
-				   c->root_addrmsk[i];
-		if (FWINV(verdict != 0, EBT_STP_ROOTADDR))
+		if (FWINV(!ether_addr_equal_masked(&stpc->root[2], c->root_addr,
+						   c->root_addrmsk),
+			  EBT_STP_ROOTADDR))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_ROOTCOST) {
 		v32 = NR32(stpc->root_cost);
-		if (FWINV(v32 < c->root_costl ||
-		    v32 > c->root_costu, EBT_STP_ROOTCOST))
+		if (FWINV(v32 < c->root_costl || v32 > c->root_costu,
+			  EBT_STP_ROOTCOST))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_SENDERPRIO) {
 		v16 = NR16(stpc->sender);
-		if (FWINV(v16 < c->sender_priol ||
-		    v16 > c->sender_priou, EBT_STP_SENDERPRIO))
+		if (FWINV(v16 < c->sender_priol || v16 > c->sender_priou,
+			  EBT_STP_SENDERPRIO))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_SENDERADDR) {
-		verdict = 0;
-		for (i = 0; i < 6; i++)
-			verdict |= (stpc->sender[2+i] ^ c->sender_addr[i]) &
-				   c->sender_addrmsk[i];
-		if (FWINV(verdict != 0, EBT_STP_SENDERADDR))
+		if (FWINV(!ether_addr_equal_masked(&stpc->sender[2],
+						   c->sender_addr,
+						   c->sender_addrmsk),
+			  EBT_STP_SENDERADDR))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_PORT) {
 		v16 = NR16(stpc->port);
-		if (FWINV(v16 < c->portl ||
-		    v16 > c->portu, EBT_STP_PORT))
+		if (FWINV(v16 < c->portl || v16 > c->portu, EBT_STP_PORT))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_MSGAGE) {
 		v16 = NR16(stpc->msg_age);
-		if (FWINV(v16 < c->msg_agel ||
-		    v16 > c->msg_ageu, EBT_STP_MSGAGE))
+		if (FWINV(v16 < c->msg_agel || v16 > c->msg_ageu,
+			  EBT_STP_MSGAGE))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_MAXAGE) {
 		v16 = NR16(stpc->max_age);
-		if (FWINV(v16 < c->max_agel ||
-		    v16 > c->max_ageu, EBT_STP_MAXAGE))
+		if (FWINV(v16 < c->max_agel || v16 > c->max_ageu,
+			  EBT_STP_MAXAGE))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_HELLOTIME) {
 		v16 = NR16(stpc->hello_time);
-		if (FWINV(v16 < c->hello_timel ||
-		    v16 > c->hello_timeu, EBT_STP_HELLOTIME))
+		if (FWINV(v16 < c->hello_timel || v16 > c->hello_timeu,
+			  EBT_STP_HELLOTIME))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_FWDD) {
 		v16 = NR16(stpc->forward_delay);
-		if (FWINV(v16 < c->forward_delayl ||
-		    v16 > c->forward_delayu, EBT_STP_FWDD))
+		if (FWINV(v16 < c->forward_delayl || v16 > c->forward_delayu,
+			  EBT_STP_FWDD))
 			return false;
 	}
 	return true;
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 5a61f35..5721a25 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -130,7 +130,6 @@ ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
 	const struct ethhdr *h = eth_hdr(skb);
 	const struct net_bridge_port *p;
 	__be16 ethproto;
-	int verdict, i;
 
 	if (skb_vlan_tag_present(skb))
 		ethproto = htons(ETH_P_8021Q);
@@ -157,19 +156,15 @@ ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
 		return 1;
 
 	if (e->bitmask & EBT_SOURCEMAC) {
-		verdict = 0;
-		for (i = 0; i < 6; i++)
-			verdict |= (h->h_source[i] ^ e->sourcemac[i]) &
-			   e->sourcemsk[i];
-		if (FWINV2(verdict != 0, EBT_ISOURCE))
+		if (FWINV2(!ether_addr_equal_masked(h->h_source,
+						    e->sourcemac, e->sourcemsk),
+			   EBT_ISOURCE))
 			return 1;
 	}
 	if (e->bitmask & EBT_DESTMAC) {
-		verdict = 0;
-		for (i = 0; i < 6; i++)
-			verdict |= (h->h_dest[i] ^ e->destmac[i]) &
-			   e->destmsk[i];
-		if (FWINV2(verdict != 0, EBT_IDEST))
+		if (FWINV2(!ether_addr_equal_masked(h->h_dest,
+						    e->destmac, e->destmsk),
+			   EBT_IDEST))
 			return 1;
 	}
 	return 0;
-- 
2.1.4

