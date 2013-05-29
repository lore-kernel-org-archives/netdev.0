From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 02/21] batman-adv: send each broadcast only once on non-wireless interfaces
Date: Wed, 29 May 2013 02:59:27 +0200
Message-ID: <1369789186-3600-3-git-send-email-ordex@autistici.org>
References: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:43818 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759062Ab3E2BBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 21:01:46 -0400
In-Reply-To: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

While it makes sense to send each broadcast thrice on 802.11 (WLAN) interfaces
as broadcasts are often unreliable on these, there is no reason to do so on
other interface types.

The increased the overhead can be harmful on low-bandwidth links like VPN
connections over slow internet lines, therefore it is better to reduce the
number of broadcast packets sent on non-wireless links to one.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c | 4 ++++
 net/batman-adv/main.h           | 5 +++++
 net/batman-adv/send.c           | 5 ++++-
 net/batman-adv/types.h          | 2 ++
 4 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index d5ec67b..4a76ed6 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -593,6 +593,10 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 	INIT_WORK(&hard_iface->cleanup_work,
 		  batadv_hardif_remove_interface_finish);
 
+	hard_iface->num_bcasts = BATADV_NUM_BCASTS_DEFAULT;
+	if (batadv_is_wifi_netdev(net_dev))
+		hard_iface->num_bcasts = BATADV_NUM_BCASTS_WIRELESS;
+
 	/* extra reference for return */
 	atomic_set(&hard_iface->refcount, 2);
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 59a0d6a..ea1a3ba 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -76,6 +76,11 @@
 
 #define BATADV_LOG_BUF_LEN 8192	  /* has to be a power of 2 */
 
+/* number of packets to send for broadcasts on different interface types */
+#define BATADV_NUM_BCASTS_DEFAULT 1
+#define BATADV_NUM_BCASTS_WIRELESS 3
+#define BATADV_NUM_BCASTS_MAX 3
+
 /* msecs after which an ARP_REQUEST is sent in broadcast as fallback */
 #define ARP_REQ_DELAY 250
 /* numbers of originator to contact for any PUT/GET DHT operation */
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 263cfd1..eb16b04 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -260,6 +260,9 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
+		if (forw_packet->num_packets >= hard_iface->num_bcasts)
+			continue;
+
 		/* send a copy of the saved skb */
 		skb1 = skb_clone(forw_packet->skb, GFP_ATOMIC);
 		if (skb1)
@@ -271,7 +274,7 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 	forw_packet->num_packets++;
 
 	/* if we still have some more bcasts to send */
-	if (forw_packet->num_packets < 3) {
+	if (forw_packet->num_packets < BATADV_NUM_BCASTS_MAX) {
 		_batadv_add_bcast_packet_to_list(bat_priv, forw_packet,
 						 msecs_to_jiffies(5));
 		return;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index aba8364..5f542bd 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -61,6 +61,7 @@ struct batadv_hard_iface_bat_iv {
  * @if_status: status of the interface for batman-adv
  * @net_dev: pointer to the net_device
  * @frag_seqno: last fragment sequence number sent by this interface
+ * @num_bcasts: number of payload re-broadcasts on this interface (ARQ)
  * @hardif_obj: kobject of the per interface sysfs "mesh" directory
  * @refcount: number of contexts the object is used
  * @batman_adv_ptype: packet type describing packets that should be processed by
@@ -76,6 +77,7 @@ struct batadv_hard_iface {
 	char if_status;
 	struct net_device *net_dev;
 	atomic_t frag_seqno;
+	uint8_t num_bcasts;
 	struct kobject *hardif_obj;
 	atomic_t refcount;
 	struct packet_type batman_adv_ptype;
-- 
1.8.1.5
