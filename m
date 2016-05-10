From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 05/17] batman-adv: add detection for complex bridge loops
Date: Wed, 11 May 2016 03:29:53 +0800
Message-ID: <1462908605-27412-6-git-send-email-a@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@open-mesh.com>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:23370 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752472AbcEJTbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:31:10 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@open-mesh.com>

There are network setups where the current bridge loop avoidance can't
detect bridge loops. The minimal setup affected would consist of two
LANs and two separate meshes, connected in a ring like that:

   A...(mesh1)...B
   |             |
 (LAN1)        (LAN2)
   |             |
   C...(mesh2)...D

Since both the meshes and backbones are separate, the bridge loop
avoidance has not enough information to detect and avoid the loop
in this case. Even if these scenarios can't be fixed easily,
these kind of loops can be detected.

This patch implements a periodic check (running every 60 seconds for
now) which sends a broadcast frame with a random MAC address on
each backbone VLAN. If a broadcast frame with the same MAC address
is received shortly after on the mesh, we know that there must be a
loop and report that incident as well as throw an uevent to let others
handle that problem.

Signed-off-by: Simon Wunderlich <simon.wunderlich@open-mesh.com>
[sven@narfation.org: fix conflicts with current version]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bridge_loop_avoidance.c | 139 +++++++++++++++++++++++++++++++++
 net/batman-adv/main.h                  |   4 +
 net/batman-adv/packet.h                |   1 +
 net/batman-adv/sysfs.c                 |   6 +-
 net/batman-adv/types.h                 |   8 ++
 5 files changed, 156 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 2c9aa671a49b..5064ae5e9b34 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -50,6 +50,7 @@
 #include "hash.h"
 #include "originator.h"
 #include "packet.h"
+#include "sysfs.h"
 #include "translation-table.h"
 
 static const u8 batadv_announce_mac[4] = {0x43, 0x05, 0x43, 0x05};
@@ -407,6 +408,14 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, u8 *mac,
 			   ethhdr->h_source, ethhdr->h_dest,
 			   BATADV_PRINT_VID(vid));
 		break;
+	case BATADV_CLAIM_TYPE_LOOPDETECT:
+		ether_addr_copy(ethhdr->h_source, mac);
+		batadv_dbg(BATADV_DBG_BLA, bat_priv,
+			   "bla_send_claim(): LOOPDETECT of %pM to %pM on vid %d\n",
+			   ethhdr->h_source, ethhdr->h_dest,
+			   BATADV_PRINT_VID(vid));
+
+		break;
 	}
 
 	if (vid & BATADV_VLAN_HAS_TAG)
@@ -427,6 +436,36 @@ out:
 }
 
 /**
+ * batadv_bla_loopdetect_report - worker for reporting the loop
+ * @work: work queue item
+ *
+ * Throws an uevent, as the loopdetect check function can't do that itself
+ * since the kernel may sleep while throwing uevents.
+ */
+static void batadv_bla_loopdetect_report(struct work_struct *work)
+{
+	struct batadv_bla_backbone_gw *backbone_gw;
+	struct batadv_priv *bat_priv;
+	char vid_str[6] = { '\0' };
+
+	backbone_gw = container_of(work, struct batadv_bla_backbone_gw,
+				   report_work);
+	bat_priv = backbone_gw->bat_priv;
+
+	batadv_info(bat_priv->soft_iface,
+		    "Possible loop on VLAN %d detected which can't be handled by BLA - please check your network setup!\n",
+		    BATADV_PRINT_VID(backbone_gw->vid));
+	snprintf(vid_str, sizeof(vid_str), "%d",
+		 BATADV_PRINT_VID(backbone_gw->vid));
+	vid_str[sizeof(vid_str) - 1] = 0;
+
+	batadv_throw_uevent(bat_priv, BATADV_UEV_BLA, BATADV_UEV_LOOPDETECT,
+			    vid_str);
+
+	batadv_backbone_gw_put(backbone_gw);
+}
+
+/**
  * batadv_bla_get_backbone_gw - finds or creates a backbone gateway
  * @bat_priv: the bat priv with all the soft interface information
  * @orig: the mac address of the originator
@@ -464,6 +503,7 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, u8 *orig,
 	atomic_set(&entry->request_sent, 0);
 	atomic_set(&entry->wait_periods, 0);
 	ether_addr_copy(entry->orig, orig);
+	INIT_WORK(&entry->report_work, batadv_bla_loopdetect_report);
 
 	/* one for the hash, one for returning */
 	kref_init(&entry->refcount);
@@ -1060,6 +1100,10 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	if (vlan_depth > 1)
 		return 1;
 
+	/* Let the loopdetect frames on the mesh in any case. */
+	if (bla_dst->type == BATADV_CLAIM_TYPE_LOOPDETECT)
+		return 0;
+
 	/* check if it is a claim frame. */
 	ret = batadv_check_claim_group(bat_priv, primary_if, hw_src, hw_dst,
 				       ethhdr);
@@ -1265,6 +1309,26 @@ void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 }
 
 /**
+ * batadv_bla_send_loopdetect - send a loopdetect frame
+ * @bat_priv: the bat priv with all the soft interface information
+ * @backbone_gw: the backbone gateway for which a loop should be detected
+ *
+ * To detect loops that the bridge loop avoidance can't handle, send a loop
+ * detection packet on the backbone. Unlike other BLA frames, this frame will
+ * be allowed on the mesh by other nodes. If it is received on the mesh, this
+ * indicates that there is a loop.
+ */
+static void
+batadv_bla_send_loopdetect(struct batadv_priv *bat_priv,
+			   struct batadv_bla_backbone_gw *backbone_gw)
+{
+	batadv_dbg(BATADV_DBG_BLA, bat_priv, "Send loopdetect frame for vid %d\n",
+		   backbone_gw->vid);
+	batadv_bla_send_claim(bat_priv, bat_priv->bla.loopdetect_addr,
+			      backbone_gw->vid, BATADV_CLAIM_TYPE_LOOPDETECT);
+}
+
+/**
  * batadv_bla_status_update - purge bla interfaces if necessary
  * @net_dev: the soft interface net device
  */
@@ -1301,6 +1365,7 @@ static void batadv_bla_periodic_work(struct work_struct *work)
 	struct batadv_bla_backbone_gw *backbone_gw;
 	struct batadv_hashtable *hash;
 	struct batadv_hard_iface *primary_if;
+	bool send_loopdetect = false;
 	int i;
 
 	delayed_work = to_delayed_work(work);
@@ -1316,6 +1381,22 @@ static void batadv_bla_periodic_work(struct work_struct *work)
 	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
 		goto out;
 
+	if (atomic_dec_and_test(&bat_priv->bla.loopdetect_next)) {
+		/* set a new random mac address for the next bridge loop
+		 * detection frames. Set the locally administered bit to avoid
+		 * collisions with users mac addresses.
+		 */
+		random_ether_addr(bat_priv->bla.loopdetect_addr);
+		bat_priv->bla.loopdetect_addr[0] = 0xba;
+		bat_priv->bla.loopdetect_addr[1] = 0xbe;
+		bat_priv->bla.loopdetect_lasttime = jiffies;
+		atomic_set(&bat_priv->bla.loopdetect_next,
+			   BATADV_BLA_LOOPDETECT_PERIODS);
+
+		/* mark for sending loop detect on all VLANs */
+		send_loopdetect = true;
+	}
+
 	hash = bat_priv->bla.backbone_hash;
 	if (!hash)
 		goto out;
@@ -1332,6 +1413,9 @@ static void batadv_bla_periodic_work(struct work_struct *work)
 			backbone_gw->lasttime = jiffies;
 
 			batadv_bla_send_announce(bat_priv, backbone_gw);
+			if (send_loopdetect)
+				batadv_bla_send_loopdetect(bat_priv,
+							   backbone_gw);
 
 			/* request_sent is only set after creation to avoid
 			 * problems when we are not yet known as backbone gw
@@ -1405,6 +1489,9 @@ int batadv_bla_init(struct batadv_priv *bat_priv)
 		bat_priv->bla.bcast_duplist[i].entrytime = entrytime;
 	bat_priv->bla.bcast_duplist_curr = 0;
 
+	atomic_set(&bat_priv->bla.loopdetect_next,
+		   BATADV_BLA_LOOPDETECT_PERIODS);
+
 	if (bat_priv->bla.claim_hash)
 		return 0;
 
@@ -1602,6 +1689,55 @@ void batadv_bla_free(struct batadv_priv *bat_priv)
 }
 
 /**
+ * batadv_bla_loopdetect_check - check and handle a detected loop
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: the packet to check
+ * @primary_if: interface where the request came on
+ * @vid: the VLAN ID of the frame
+ *
+ * Checks if this packet is a loop detect frame which has been sent by us,
+ * throw an uevent and log the event if that is the case.
+ *
+ * Return: true if it is a loop detect frame which is to be dropped, false
+ * otherwise.
+ */
+static bool
+batadv_bla_loopdetect_check(struct batadv_priv *bat_priv, struct sk_buff *skb,
+			    struct batadv_hard_iface *primary_if,
+			    unsigned short vid)
+{
+	struct batadv_bla_backbone_gw *backbone_gw;
+	struct ethhdr *ethhdr;
+
+	ethhdr = eth_hdr(skb);
+
+	/* Only check for the MAC address and skip more checks here for
+	 * performance reasons - this function is on the hotpath, after all.
+	 */
+	if (!batadv_compare_eth(ethhdr->h_source,
+				bat_priv->bla.loopdetect_addr))
+		return false;
+
+	/* If the packet came too late, don't forward it on the mesh
+	 * but don't consider that as loop. It might be a coincidence.
+	 */
+	if (batadv_has_timed_out(bat_priv->bla.loopdetect_lasttime,
+				 BATADV_BLA_LOOPDETECT_TIMEOUT))
+		return true;
+
+	backbone_gw = batadv_bla_get_backbone_gw(bat_priv,
+						 primary_if->net_dev->dev_addr,
+						 vid, true);
+	if (unlikely(!backbone_gw))
+		return true;
+
+	queue_work(batadv_event_workqueue, &backbone_gw->report_work);
+	/* backbone_gw is unreferenced in the report work function function */
+
+	return true;
+}
+
+/**
  * batadv_bla_rx - check packets coming from the mesh.
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: the frame to be checked
@@ -1634,6 +1770,9 @@ int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb,
 	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
 		goto allow;
 
+	if (batadv_bla_loopdetect_check(bat_priv, skb, primary_if, vid))
+		goto handled;
+
 	if (unlikely(atomic_read(&bat_priv->bla.num_requests)))
 		/* don't allow broadcasts while requests are in flight */
 		if (is_multicast_ether_addr(ethhdr->h_dest) && is_bcast)
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 07a6042d0ad6..090c6f0f2398 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -120,6 +120,8 @@
 #define BATADV_BLA_BACKBONE_TIMEOUT	(BATADV_BLA_PERIOD_LENGTH * 6)
 #define BATADV_BLA_CLAIM_TIMEOUT	(BATADV_BLA_PERIOD_LENGTH * 10)
 #define BATADV_BLA_WAIT_PERIODS		3
+#define BATADV_BLA_LOOPDETECT_PERIODS	6
+#define BATADV_BLA_LOOPDETECT_TIMEOUT	3000	/* 3 seconds */
 
 #define BATADV_DUPLIST_SIZE		16
 #define BATADV_DUPLIST_TIMEOUT		500	/* 500 ms */
@@ -142,10 +144,12 @@ enum batadv_uev_action {
 	BATADV_UEV_ADD = 0,
 	BATADV_UEV_DEL,
 	BATADV_UEV_CHANGE,
+	BATADV_UEV_LOOPDETECT,
 };
 
 enum batadv_uev_type {
 	BATADV_UEV_GW = 0,
+	BATADV_UEV_BLA,
 };
 
 #define BATADV_GW_THRESHOLD	50
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 0796dfdfbb60..372128ddb474 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -175,6 +175,7 @@ enum batadv_bla_claimframe {
 	BATADV_CLAIM_TYPE_UNCLAIM	= 0x01,
 	BATADV_CLAIM_TYPE_ANNOUNCE	= 0x02,
 	BATADV_CLAIM_TYPE_REQUEST	= 0x03,
+	BATADV_CLAIM_TYPE_LOOPDETECT	= 0x04,
 };
 
 /**
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 6b1e54f3250a..414b2074165f 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -116,11 +116,13 @@ batadv_kobj_to_vlan(struct batadv_priv *bat_priv, struct kobject *obj)
 static char *batadv_uev_action_str[] = {
 	"add",
 	"del",
-	"change"
+	"change",
+	"loopdetect",
 };
 
 static char *batadv_uev_type_str[] = {
-	"gw"
+	"gw",
+	"bla",
 };
 
 /* Use this, if you have customized show and store functions for vlan attrs */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 1e47fbe8bb7b..6a577f4f8ba7 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -657,6 +657,9 @@ struct batadv_priv_tt {
  * @num_requests: number of bla requests in flight
  * @claim_hash: hash table containing mesh nodes this host has claimed
  * @backbone_hash: hash table containing all detected backbone gateways
+ * @loopdetect_addr: MAC address used for own loopdetection frames
+ * @loopdetect_lasttime: time when the loopdetection frames were sent
+ * @loopdetect_next: how many periods to wait for the next loopdetect process
  * @bcast_duplist: recently received broadcast packets array (for broadcast
  *  duplicate suppression)
  * @bcast_duplist_curr: index of last broadcast packet added to bcast_duplist
@@ -668,6 +671,9 @@ struct batadv_priv_bla {
 	atomic_t num_requests;
 	struct batadv_hashtable *claim_hash;
 	struct batadv_hashtable *backbone_hash;
+	u8 loopdetect_addr[ETH_ALEN];
+	unsigned long loopdetect_lasttime;
+	atomic_t loopdetect_next;
 	struct batadv_bcast_duplist_entry bcast_duplist[BATADV_DUPLIST_SIZE];
 	int bcast_duplist_curr;
 	/* protects bcast_duplist & bcast_duplist_curr */
@@ -1012,6 +1018,7 @@ struct batadv_socket_packet {
  *  resolved
  * @crc: crc16 checksum over all claims
  * @crc_lock: lock protecting crc
+ * @report_work: work struct for reporting detected loops
  * @refcount: number of contexts the object is used
  * @rcu: struct used for freeing in an RCU-safe manner
  */
@@ -1025,6 +1032,7 @@ struct batadv_bla_backbone_gw {
 	atomic_t request_sent;
 	u16 crc;
 	spinlock_t crc_lock; /* protects crc */
+	struct work_struct report_work;
 	struct kref refcount;
 	struct rcu_head rcu;
 };
-- 
2.8.2
