From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 05/15] batman-adv: Distributed ARP Table - add ARP parsing functions
Date: Wed, 25 Apr 2012 15:27:01 +0200
Message-ID: <1335360431-30027-6-git-send-email-ordex@autistici.org>
References: <1335360431-30027-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:38847 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607Ab2DYN0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 09:26:21 -0400
In-Reply-To: <1335360431-30027-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ARP messages are now parsed to make it possible to trigger special actions
depending on their types (snooping).

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/distributed-arp-table.c |  123 ++++++++++++++++++++++++++++++++
 net/batman-adv/distributed-arp-table.h |   10 +++
 net/batman-adv/packet.h                |    5 +-
 3 files changed, 137 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 0078478..682fb1e 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -30,6 +30,75 @@
 #include "types.h"
 #include "unicast.h"
 
+#ifdef CONFIG_BATMAN_ADV_DEBUG
+
+static void bat_dbg_arp(struct bat_priv *bat_priv, struct sk_buff *skb,
+			uint16_t type, int hdr_size, char *msg)
+{
+	struct unicast_4addr_packet *unicast_4addr_packet;
+
+	if (msg)
+		bat_dbg(DBG_DAT, bat_priv, "%s\n", msg);
+
+	bat_dbg(DBG_DAT, bat_priv, "ARP MSG = [src: %pM-%pI4 dst: %pM-%pI4]\n",
+		ARP_HW_SRC(skb, hdr_size), &ARP_IP_SRC(skb, hdr_size),
+		ARP_HW_DST(skb, hdr_size), &ARP_IP_DST(skb, hdr_size));
+
+	if (hdr_size == 0)
+		return;
+
+	/* if the AP packet is encapsulated in a batman packet, let's print some
+	 * debug messages
+	 */
+	unicast_4addr_packet = (struct unicast_4addr_packet *)skb->data;
+
+	switch (unicast_4addr_packet->u.header.packet_type) {
+	case BAT_UNICAST:
+		bat_dbg(DBG_DAT, bat_priv,
+			"* encapsulated within a UNICAST packet\n");
+		break;
+	case BAT_UNICAST_4ADDR:
+		bat_dbg(DBG_DAT, bat_priv,
+			"* encapsulated within a UNICAST_4ADDR packet (src: %pM)\n",
+			unicast_4addr_packet->src);
+		switch (unicast_4addr_packet->subtype) {
+		case BAT_P_DAT_DHT_PUT:
+			bat_dbg(DBG_DAT, bat_priv, "* type: DAT_DHT_PUT\n");
+			break;
+		case BAT_P_DAT_DHT_GET:
+			bat_dbg(DBG_DAT, bat_priv, "* type: DAT_DHT_GET\n");
+			break;
+		case BAT_P_DAT_CACHE_REPLY:
+			bat_dbg(DBG_DAT, bat_priv, "* type: DAT_CACHE_REPLY\n");
+			break;
+		case BAT_P_DATA:
+			bat_dbg(DBG_DAT, bat_priv, "* type: DATA\n");
+			break;
+		default:
+			bat_dbg(DBG_DAT, bat_priv, "* type: Unknown!\n");
+		}
+		break;
+	case BAT_BCAST:
+		bat_dbg(DBG_DAT, bat_priv,
+			"* encapsulated within a BCAST packet (src: %pM)\n",
+			((struct bcast_packet *)unicast_4addr_packet)->orig);
+		break;
+	default:
+		bat_dbg(DBG_DAT, bat_priv,
+			"* encapsulated within an unknown packet type (0x%x)\n",
+			unicast_4addr_packet->u.header.packet_type);
+	}
+}
+
+#else
+
+static void bat_dbg_arp(struct bat_priv *bat_priv, struct sk_buff *skb,
+			uint16_t type, int hdr_size, char *msg)
+{
+}
+
+#endif /* CONFIG_BATMAN_ADV_DEBUG */
+
 static bool is_orig_node_eligible(struct dht_candidate *res, int select,
 				  dat_addr_t tmp_max, dat_addr_t max,
 				  dat_addr_t last_max,
@@ -205,3 +274,57 @@ out:
 	kfree(cand);
 	return ret;
 }
+
+/* Returns arphdr->ar_op if the skb contains a valid ARP packet, otherwise
+ * returns 0
+ */
+static uint16_t arp_get_type(struct bat_priv *bat_priv, struct sk_buff *skb,
+			     int hdr_size)
+{
+	struct arphdr *arphdr;
+	struct ethhdr *ethhdr;
+	uint32_t ip_src, ip_dst;
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
+	 * IP information */
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
+	 * will simply ignore it */
+	ip_src = ARP_IP_SRC(skb, hdr_size);
+	ip_dst = ARP_IP_DST(skb, hdr_size);
+	if (ipv4_is_loopback(ip_src) || ipv4_is_multicast(ip_src) ||
+	    ipv4_is_loopback(ip_dst) || ipv4_is_multicast(ip_dst))
+		goto out;
+
+	type = ntohs(arphdr->ar_op);
+out:
+	return type;
+}
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index 94ee0fd..cdd0484 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -25,8 +25,18 @@
 #include "types.h"
 #include "originator.h"
 
+#include <linux/if_arp.h>
+
 #define DAT_ADDR_MAX biggest_unsigned_int(dat_addr_t)
 
+#define ARP_HW_SRC(skb, hdr_size) ((uint8_t *)(skb->data + hdr_size) + \
+				   ETH_HLEN + sizeof(struct arphdr))
+#define ARP_IP_SRC(skb, hdr_size) (*(uint32_t *)(ARP_HW_SRC(skb, hdr_size) + \
+				   ETH_ALEN))
+#define ARP_HW_DST(skb, hdr_size) (ARP_HW_SRC(skb, hdr_size) + ETH_ALEN + 4)
+#define ARP_IP_DST(skb, hdr_size) (*(uint32_t *)(ARP_HW_SRC(skb, hdr_size) + \
+				   ETH_ALEN * 2 + 4))
+
 /* hash function to choose an entry in a hash table of given size.
  * hash algorithm from http://en.wikipedia.org/wiki/Hash_table
  */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index e9f5184..c4533c4 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -37,7 +37,10 @@ enum bat_packettype {
 };
 
 enum bat_subtype {
-	BAT_P_DATA		= 0x01
+	BAT_P_DATA		= 0x01,
+	BAT_P_DAT_DHT_GET	= 0x02,
+	BAT_P_DAT_DHT_PUT	= 0x03,
+	BAT_P_DAT_CACHE_REPLY	= 0x04
 };
 
 /* this file is included by batctl which needs these defines */
-- 
1.7.9.4
