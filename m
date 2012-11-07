From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 07/12] batman-adv: Distributed ARP Table - add ARP parsing functions
Date: Wed,  7 Nov 2012 20:11:37 +0100
Message-ID: <1352315502-20324-8-git-send-email-ordex@autistici.org>
References: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:44643 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408Ab2KGTMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 14:12:35 -0500
In-Reply-To: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ARP messages are now parsed to make it possible to trigger special actions
depending on their types (snooping).

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/Kconfig                 |   4 +-
 net/batman-adv/distributed-arp-table.c | 202 +++++++++++++++++++++++++++++++++
 net/batman-adv/distributed-arp-table.h |   2 +
 net/batman-adv/packet.h                |   8 +-
 4 files changed, 213 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index 53f5244..e77f805 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -4,7 +4,7 @@
 
 config BATMAN_ADV
 	tristate "B.A.T.M.A.N. Advanced Meshing Protocol"
-	depends on NET
+	depends on NET && INET
 	select CRC16
         default n
 	help
@@ -16,7 +16,7 @@ config BATMAN_ADV
 
 config BATMAN_ADV_BLA
 	bool "Bridge Loop Avoidance"
-	depends on BATMAN_ADV && INET
+	depends on BATMAN_ADV
 	default y
 	help
 	  This option enables BLA (Bridge Loop Avoidance), a mechanism
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 2ef90e3..49a213c 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -21,6 +21,7 @@
 #include <linux/if_arp.h>
 
 #include "main.h"
+#include "hash.h"
 #include "distributed-arp-table.h"
 #include "hard-interface.h"
 #include "originator.h"
@@ -142,6 +143,59 @@ static int batadv_compare_dat(const struct hlist_node *node, const void *data2)
 }
 
 /**
+ * batadv_arp_hw_src - extract the hw_src field from an ARP packet
+ * @skb: ARP packet
+ * @hdr_size: size of the possible header before the ARP packet
+ *
+ * Returns the value of the hw_src field in the ARP packet
+ */
+static uint8_t *batadv_arp_hw_src(struct sk_buff *skb, int hdr_size)
+{
+	uint8_t *addr;
+
+	addr = (uint8_t *)(skb->data + hdr_size);
+	addr += ETH_HLEN + sizeof(struct arphdr);
+
+	return addr;
+}
+
+/**
+ * batadv_arp_ip_src - extract the ip_src field from an ARP packet
+ * @skb: ARP packet
+ * @hdr_size: size of the possible header before the ARP packet
+ *
+ * Returns the value of the ip_src field in the ARP packet
+ */
+static __be32 batadv_arp_ip_src(struct sk_buff *skb, int hdr_size)
+{
+	return *(__be32 *)(batadv_arp_hw_src(skb, hdr_size) + ETH_ALEN);
+}
+
+/**
+ * batadv_arp_hw_dst - extract the hw_dst field from an ARP packet
+ * @skb: ARP packet
+ * @hdr_size: size of the possible header before the ARP packet
+ *
+ * Returns the value of the hw_dst field in the ARP packet
+ */
+static uint8_t *batadv_arp_hw_dst(struct sk_buff *skb, int hdr_size)
+{
+	return batadv_arp_hw_src(skb, hdr_size) + ETH_ALEN + 4;
+}
+
+/**
+ * batadv_arp_ip_dst - extract the ip_dst field from an ARP packet
+ * @skb: ARP packet
+ * @hdr_size: size of the possible header before the ARP packet
+ *
+ * Returns the value of the ip_dst field in the ARP packet
+ */
+static __be32 batadv_arp_ip_dst(struct sk_buff *skb, int hdr_size)
+{
+	return *(__be32 *)(batadv_arp_hw_src(skb, hdr_size) + ETH_ALEN * 2 + 4);
+}
+
+/**
  * batadv_hash_dat - compute the hash value for an IP address
  * @data: data to hash
  * @size: size of the hash table
@@ -257,6 +311,93 @@ out:
 		batadv_dat_entry_free_ref(dat_entry);
 }
 
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+
+/**
+ * batadv_dbg_arp - print a debug message containing all the ARP packet details
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: ARP packet
+ * @type: ARP type
+ * @hdr_size: size of the possible header before the ARP packet
+ * @msg: message to print together with the debugging information
+ */
+static void batadv_dbg_arp(struct batadv_priv *bat_priv, struct sk_buff *skb,
+			   uint16_t type, int hdr_size, char *msg)
+{
+	struct batadv_unicast_4addr_packet *unicast_4addr_packet;
+	struct batadv_bcast_packet *bcast_pkt;
+	uint8_t *orig_addr;
+	__be32 ip_src, ip_dst;
+
+	if (msg)
+		batadv_dbg(BATADV_DBG_DAT, bat_priv, "%s\n", msg);
+
+	ip_src = batadv_arp_ip_src(skb, hdr_size);
+	ip_dst = batadv_arp_ip_dst(skb, hdr_size);
+	batadv_dbg(BATADV_DBG_DAT, bat_priv,
+		   "ARP MSG = [src: %pM-%pI4 dst: %pM-%pI4]\n",
+		   batadv_arp_hw_src(skb, hdr_size), &ip_src,
+		   batadv_arp_hw_dst(skb, hdr_size), &ip_dst);
+
+	if (hdr_size == 0)
+		return;
+
+	/* if the ARP packet is encapsulated in a batman packet, let's print
+	 * some debug messages
+	 */
+	unicast_4addr_packet = (struct batadv_unicast_4addr_packet *)skb->data;
+
+	switch (unicast_4addr_packet->u.header.packet_type) {
+	case BATADV_UNICAST:
+		batadv_dbg(BATADV_DBG_DAT, bat_priv,
+			   "* encapsulated within a UNICAST packet\n");
+		break;
+	case BATADV_UNICAST_4ADDR:
+		batadv_dbg(BATADV_DBG_DAT, bat_priv,
+			   "* encapsulated within a UNICAST_4ADDR packet (src: %pM)\n",
+			   unicast_4addr_packet->src);
+		switch (unicast_4addr_packet->subtype) {
+		case BATADV_P_DAT_DHT_PUT:
+			batadv_dbg(BATADV_DBG_DAT, bat_priv, "* type: DAT_DHT_PUT\n");
+			break;
+		case BATADV_P_DAT_DHT_GET:
+			batadv_dbg(BATADV_DBG_DAT, bat_priv, "* type: DAT_DHT_GET\n");
+			break;
+		case BATADV_P_DAT_CACHE_REPLY:
+			batadv_dbg(BATADV_DBG_DAT, bat_priv,
+				   "* type: DAT_CACHE_REPLY\n");
+			break;
+		case BATADV_P_DATA:
+			batadv_dbg(BATADV_DBG_DAT, bat_priv, "* type: DATA\n");
+			break;
+		default:
+			batadv_dbg(BATADV_DBG_DAT, bat_priv, "* type: Unknown (%u)!\n",
+				   unicast_4addr_packet->u.header.packet_type);
+		}
+		break;
+	case BATADV_BCAST:
+		bcast_pkt = (struct batadv_bcast_packet *)unicast_4addr_packet;
+		orig_addr = bcast_pkt->orig;
+		batadv_dbg(BATADV_DBG_DAT, bat_priv,
+			   "* encapsulated within a BCAST packet (src: %pM)\n",
+			   orig_addr);
+		break;
+	default:
+		batadv_dbg(BATADV_DBG_DAT, bat_priv,
+			   "* encapsulated within an unknown packet type (0x%x)\n",
+			   unicast_4addr_packet->u.header.packet_type);
+	}
+}
+
+#else
+
+static void batadv_dbg_arp(struct batadv_priv *bat_priv, struct sk_buff *skb,
+			   uint16_t type, int hdr_size, char *msg)
+{
+}
+
+#endif /* CONFIG_BATMAN_ADV_DEBUG */
+
 /**
  * batadv_is_orig_node_eligible - check whether a node can be a DHT candidate
  * @res: the array with the already selected candidates
@@ -564,3 +705,64 @@ out:
 		batadv_hardif_free_ref(primary_if);
 	return 0;
 }
+
+/**
+ * batadv_arp_get_type - parse an ARP packet and gets the type
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: packet to analyse
+ * @hdr_size: size of the possible header before the ARP packet in the skb
+ *
+ * Returns the ARP type if the skb contains a valid ARP packet, 0 otherwise
+ */
+static uint16_t batadv_arp_get_type(struct batadv_priv *bat_priv,
+				    struct sk_buff *skb, int hdr_size)
+{
+	struct arphdr *arphdr;
+	struct ethhdr *ethhdr;
+	__be32 ip_src, ip_dst;
+	uint16_t type = 0;
+
+	/* pull the ethernet header */
+	if (unlikely(!pskb_may_pull(skb, hdr_size + ETH_HLEN)))
+		goto out;
+
+	ethhdr = (struct ethhdr *)(skb->data + hdr_size);
+
+	if (ethhdr->h_proto != htons(ETH_P_ARP))
+		goto out;
+
+	/* pull the ARP payload */
+	if (unlikely(!pskb_may_pull(skb, hdr_size + ETH_HLEN +
+				    arp_hdr_len(skb->dev))))
+		goto out;
+
+	arphdr = (struct arphdr *)(skb->data + hdr_size + ETH_HLEN);
+
+	/* Check whether the ARP packet carries a valid
+	 * IP information
+	 */
+	if (arphdr->ar_hrd != htons(ARPHRD_ETHER))
+		goto out;
+
+	if (arphdr->ar_pro != htons(ETH_P_IP))
+		goto out;
+
+	if (arphdr->ar_hln != ETH_ALEN)
+		goto out;
+
+	if (arphdr->ar_pln != 4)
+		goto out;
+
+	/* Check for bad reply/request. If the ARP message is not sane, DAT
+	 * will simply ignore it
+	 */
+	ip_src = batadv_arp_ip_src(skb, hdr_size);
+	ip_dst = batadv_arp_ip_dst(skb, hdr_size);
+	if (ipv4_is_loopback(ip_src) || ipv4_is_multicast(ip_src) ||
+	    ipv4_is_loopback(ip_dst) || ipv4_is_multicast(ip_dst))
+		goto out;
+
+	type = ntohs(arphdr->ar_op);
+out:
+	return type;
+}
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index 1b88303..f4e282a 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -23,6 +23,8 @@
 #include "types.h"
 #include "originator.h"
 
+#include <linux/if_arp.h>
+
 #define BATADV_DAT_ADDR_MAX ((batadv_dat_addr_t)~(batadv_dat_addr_t)0)
 
 /**
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 0f8dcf3..df548ed 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -37,9 +37,15 @@ enum batadv_packettype {
 /**
  * enum batadv_subtype - packet subtype for unicast4addr
  * @BATADV_P_DATA: user payload
+ * @BATADV_P_DAT_DHT_GET: DHT request message
+ * @BATADV_P_DAT_DHT_PUT: DHT store message
+ * @BATADV_P_DAT_CACHE_REPLY: ARP reply generated by DAT
  */
 enum batadv_subtype {
-	BATADV_P_DATA		= 0x01,
+	BATADV_P_DATA			= 0x01,
+	BATADV_P_DAT_DHT_GET		= 0x02,
+	BATADV_P_DAT_DHT_PUT		= 0x03,
+	BATADV_P_DAT_CACHE_REPLY	= 0x04,
 };
 
 /* this file is included by batctl which needs these defines */
-- 
1.8.0
