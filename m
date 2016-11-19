From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 8/8] batman-adv: fix rare race conditions on interface removal
Date: Sat, 19 Nov 2016 14:35:28 +0100
Message-ID: <20161119133528.1379-9-sw@simonwunderlich.de>
References: <20161119133528.1379-1-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:49984 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752885AbcKSNff (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 08:35:35 -0500
In-Reply-To: <20161119133528.1379-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Lüssing <linus.luessing@c0d3.blue>

In rare cases during shutdown the following general protection fault can
happen:

  general protection fault: 0000 [#1] SMP
  Modules linked in: batman_adv(O-) [...]
  CPU: 3 PID: 1714 Comm: rmmod Tainted: G           O    4.6.0-rc6+ #1
  [...]
  Call Trace:
   [<ffffffffa0363294>] batadv_hardif_disable_interface+0x29a/0x3a6 [batman_adv]
   [<ffffffffa0373db4>] batadv_softif_destroy_netlink+0x4b/0xa4 [batman_adv]
   [<ffffffff813b52f3>] __rtnl_link_unregister+0x48/0x92
   [<ffffffff813b9240>] rtnl_link_unregister+0xc1/0xdb
   [<ffffffff8108547c>] ? bit_waitqueue+0x87/0x87
   [<ffffffffa03850d2>] batadv_exit+0x1a/0xf48 [batman_adv]
   [<ffffffff810c26f9>] SyS_delete_module+0x136/0x1b0
   [<ffffffff8144dc65>] entry_SYSCALL_64_fastpath+0x18/0xa8
   [<ffffffff8108aaca>] ? trace_hardirqs_off_caller+0x37/0xa6
  Code: 89 f7 e8 21 bd 0d e1 4d 85 e4 75 0e 31 f6 48 c7 c7 50 d7 3b a0 e8 50 16 f2 e0 49 8b 9c 24 28 01 00 00 48 85 db 0f 84 b2 00 00 00 <48> 8b 03 4d 85 ed 48 89 45 c8 74 09 4c 39 ab f8 00 00 00 75 1c
  RIP  [<ffffffffa0371852>] batadv_purge_outstanding_packets+0x1c8/0x291 [batman_adv]
   RSP <ffff88001da5fd78>
  ---[ end trace 803b9bdc6a4a952b ]---
  Kernel panic - not syncing: Fatal exception in interrupt
  Kernel Offset: disabled
  ---[ end Kernel panic - not syncing: Fatal exception in interrupt

It does not happen often, but may potentially happen when frequently
shutting down and reinitializing an interface. With some carefully
placed msleep()s/mdelay()s it can be reproduced easily.

The issue is, that on interface removal, any still running worker thread
of a forwarding packet will race with the interface purging routine to
free a forwarding packet. Temporarily giving up a spin-lock to be able
to sleep in the purging routine is not safe.

Furthermore, there is a potential general protection fault not just for
the purging side shown above, but also on the worker side: Temporarily
removing a forw_packet from the according forw_{bcast,bat}_list will make
it impossible for the purging routine to catch and cancel it.

 # How this patch tries to fix it:

With this patch we split the queue purging into three steps: Step 1),
removing forward packets from the queue of an interface and by that
claim it as our responsibility to free.

Step 2), we are either lucky to cancel a pending worker before it starts
to run. Or if it is already running, we wait and let it do its thing,
except two things:

Through the claiming in step 1) we prevent workers from a) re-arming
themselves. And b) prevent workers from freeing packets which we still
hold in the interface purging routine.

Finally, step 3, we are sure that no forwarding packets are pending or
even running anymore on the interface to remove. We can then safely free
the claimed forwarding packets.

Signed-off-by: Linus Lüssing <linus.luessing@c0d3.blue>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_iv_ogm.c |  19 +--
 net/batman-adv/send.c       | 283 +++++++++++++++++++++++++++++++++-----------
 net/batman-adv/send.h       |   5 +
 net/batman-adv/types.h      |   2 +
 4 files changed, 227 insertions(+), 82 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 36d8818..f00f666 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -717,17 +717,10 @@ static void batadv_iv_ogm_aggregate_new(const unsigned char *packet_buff,
 	if (direct_link)
 		forw_packet_aggr->direct_link_flags |= 1;
 
-	/* add new packet to packet list */
-	spin_lock_bh(&bat_priv->forw_bat_list_lock);
-	hlist_add_head(&forw_packet_aggr->list, &bat_priv->forw_bat_list);
-	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
-
-	/* start timer for this packet */
 	INIT_DELAYED_WORK(&forw_packet_aggr->delayed_work,
 			  batadv_iv_send_outstanding_bat_ogm_packet);
-	queue_delayed_work(batadv_event_workqueue,
-			   &forw_packet_aggr->delayed_work,
-			   send_time - jiffies);
+
+	batadv_forw_packet_ogmv1_queue(bat_priv, forw_packet_aggr, send_time);
 }
 
 /* aggregate a new packet into the existing ogm packet */
@@ -1789,9 +1782,6 @@ static void batadv_iv_send_outstanding_bat_ogm_packet(struct work_struct *work)
 	forw_packet = container_of(delayed_work, struct batadv_forw_packet,
 				   delayed_work);
 	bat_priv = netdev_priv(forw_packet->if_incoming->soft_iface);
-	spin_lock_bh(&bat_priv->forw_bat_list_lock);
-	hlist_del(&forw_packet->list);
-	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
 
 	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_DEACTIVATING) {
 		dropped = true;
@@ -1813,7 +1803,10 @@ static void batadv_iv_send_outstanding_bat_ogm_packet(struct work_struct *work)
 		batadv_iv_ogm_schedule(forw_packet->if_incoming);
 
 out:
-	batadv_forw_packet_free(forw_packet, dropped);
+	/* do we get something for free()? */
+	if (batadv_forw_packet_steal(forw_packet,
+				     &bat_priv->forw_bat_list_lock))
+		batadv_forw_packet_free(forw_packet, dropped);
 }
 
 static int batadv_iv_ogm_receive(struct sk_buff *skb,
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 9ea272e..49021b7 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -19,6 +19,7 @@
 #include "main.h"
 
 #include <linux/atomic.h>
+#include <linux/bug.h>
 #include <linux/byteorder/generic.h>
 #include <linux/errno.h>
 #include <linux/etherdevice.h>
@@ -520,6 +521,8 @@ batadv_forw_packet_alloc(struct batadv_hard_iface *if_incoming,
 	if (if_outgoing)
 		kref_get(&if_outgoing->refcount);
 
+	INIT_HLIST_NODE(&forw_packet->list);
+	INIT_HLIST_NODE(&forw_packet->cleanup_list);
 	forw_packet->skb = NULL;
 	forw_packet->queue_left = queue_left;
 	forw_packet->if_incoming = if_incoming;
@@ -535,19 +538,191 @@ batadv_forw_packet_alloc(struct batadv_hard_iface *if_incoming,
 	return NULL;
 }
 
+/**
+ * batadv_forw_packet_was_stolen - check whether someone stole this packet
+ * @forw_packet: the forwarding packet to check
+ *
+ * This function checks whether the given forwarding packet was claimed by
+ * someone else for free().
+ *
+ * Return: True if someone stole it, false otherwise.
+ */
+static bool
+batadv_forw_packet_was_stolen(struct batadv_forw_packet *forw_packet)
+{
+	return !hlist_unhashed(&forw_packet->cleanup_list);
+}
+
+/**
+ * batadv_forw_packet_steal - claim a forw_packet for free()
+ * @forw_packet: the forwarding packet to steal
+ * @lock: a key to the store to steal from (e.g. forw_{bat,bcast}_list_lock)
+ *
+ * This function tries to steal a specific forw_packet from global
+ * visibility for the purpose of getting it for free(). That means
+ * the caller is *not* allowed to requeue it afterwards.
+ *
+ * Return: True if stealing was successful. False if someone else stole it
+ * before us.
+ */
+bool batadv_forw_packet_steal(struct batadv_forw_packet *forw_packet,
+			      spinlock_t *lock)
+{
+	/* did purging routine steal it earlier? */
+	spin_lock_bh(lock);
+	if (batadv_forw_packet_was_stolen(forw_packet)) {
+		spin_unlock_bh(lock);
+		return false;
+	}
+
+	hlist_del_init(&forw_packet->list);
+
+	/* Just to spot misuse of this function */
+	hlist_add_fake(&forw_packet->cleanup_list);
+
+	spin_unlock_bh(lock);
+	return true;
+}
+
+/**
+ * batadv_forw_packet_list_steal - claim a list of forward packets for free()
+ * @forw_list: the to be stolen forward packets
+ * @cleanup_list: a backup pointer, to be able to dispose the packet later
+ * @hard_iface: the interface to steal forward packets from
+ *
+ * This function claims responsibility to free any forw_packet queued on the
+ * given hard_iface. If hard_iface is NULL forwarding packets on all hard
+ * interfaces will be claimed.
+ *
+ * The packets are being moved from the forw_list to the cleanup_list and
+ * by that allows already running threads to notice the claiming.
+ */
 static void
-_batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
-				 struct batadv_forw_packet *forw_packet,
-				 unsigned long send_time)
+batadv_forw_packet_list_steal(struct hlist_head *forw_list,
+			      struct hlist_head *cleanup_list,
+			      const struct batadv_hard_iface *hard_iface)
 {
-	/* add new packet to packet list */
-	spin_lock_bh(&bat_priv->forw_bcast_list_lock);
-	hlist_add_head(&forw_packet->list, &bat_priv->forw_bcast_list);
-	spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
+	struct batadv_forw_packet *forw_packet;
+	struct hlist_node *safe_tmp_node;
+
+	hlist_for_each_entry_safe(forw_packet, safe_tmp_node,
+				  forw_list, list) {
+		/* if purge_outstanding_packets() was called with an argument
+		 * we delete only packets belonging to the given interface
+		 */
+		if (hard_iface &&
+		    (forw_packet->if_incoming != hard_iface) &&
+		    (forw_packet->if_outgoing != hard_iface))
+			continue;
+
+		hlist_del(&forw_packet->list);
+		hlist_add_head(&forw_packet->cleanup_list, cleanup_list);
+	}
+}
+
+/**
+ * batadv_forw_packet_list_free - free a list of forward packets
+ * @head: a list of to be freed forw_packets
+ *
+ * This function cancels the scheduling of any packet in the provided list,
+ * waits for any possibly running packet forwarding thread to finish and
+ * finally, safely frees this forward packet.
+ *
+ * This function might sleep.
+ */
+static void batadv_forw_packet_list_free(struct hlist_head *head)
+{
+	struct batadv_forw_packet *forw_packet;
+	struct hlist_node *safe_tmp_node;
+
+	hlist_for_each_entry_safe(forw_packet, safe_tmp_node, head,
+				  cleanup_list) {
+		cancel_delayed_work_sync(&forw_packet->delayed_work);
 
-	/* start timer for this packet */
-	queue_delayed_work(batadv_event_workqueue, &forw_packet->delayed_work,
-			   send_time);
+		hlist_del(&forw_packet->cleanup_list);
+		batadv_forw_packet_free(forw_packet, true);
+	}
+}
+
+/**
+ * batadv_forw_packet_queue - try to queue a forwarding packet
+ * @forw_packet: the forwarding packet to queue
+ * @lock: a key to the store (e.g. forw_{bat,bcast}_list_lock)
+ * @head: the shelve to queue it on (e.g. forw_{bat,bcast}_list)
+ * @send_time: timestamp (jiffies) when the packet is to be sent
+ *
+ * This function tries to (re)queue a forwarding packet. Requeuing
+ * is prevented if the according interface is shutting down
+ * (e.g. if batadv_forw_packet_list_steal() was called for this
+ * packet earlier).
+ *
+ * Calling batadv_forw_packet_queue() after a call to
+ * batadv_forw_packet_steal() is forbidden!
+ *
+ * Caller needs to ensure that forw_packet->delayed_work was initialized.
+ */
+static void batadv_forw_packet_queue(struct batadv_forw_packet *forw_packet,
+				     spinlock_t *lock, struct hlist_head *head,
+				     unsigned long send_time)
+{
+	spin_lock_bh(lock);
+
+	/* did purging routine steal it from us? */
+	if (batadv_forw_packet_was_stolen(forw_packet)) {
+		/* If you got it for free() without trouble, then
+		 * don't get back into the queue after stealing...
+		 */
+		WARN_ONCE(hlist_fake(&forw_packet->cleanup_list),
+			  "Requeuing after batadv_forw_packet_steal() not allowed!\n");
+
+		spin_unlock_bh(lock);
+		return;
+	}
+
+	hlist_del_init(&forw_packet->list);
+	hlist_add_head(&forw_packet->list, head);
+
+	queue_delayed_work(batadv_event_workqueue,
+			   &forw_packet->delayed_work,
+			   send_time - jiffies);
+	spin_unlock_bh(lock);
+}
+
+/**
+ * batadv_forw_packet_bcast_queue - try to queue a broadcast packet
+ * @bat_priv: the bat priv with all the soft interface information
+ * @forw_packet: the forwarding packet to queue
+ * @send_time: timestamp (jiffies) when the packet is to be sent
+ *
+ * This function tries to (re)queue a broadcast packet.
+ *
+ * Caller needs to ensure that forw_packet->delayed_work was initialized.
+ */
+static void
+batadv_forw_packet_bcast_queue(struct batadv_priv *bat_priv,
+			       struct batadv_forw_packet *forw_packet,
+			       unsigned long send_time)
+{
+	batadv_forw_packet_queue(forw_packet, &bat_priv->forw_bcast_list_lock,
+				 &bat_priv->forw_bcast_list, send_time);
+}
+
+/**
+ * batadv_forw_packet_ogmv1_queue - try to queue an OGMv1 packet
+ * @bat_priv: the bat priv with all the soft interface information
+ * @forw_packet: the forwarding packet to queue
+ * @send_time: timestamp (jiffies) when the packet is to be sent
+ *
+ * This function tries to (re)queue an OGMv1 packet.
+ *
+ * Caller needs to ensure that forw_packet->delayed_work was initialized.
+ */
+void batadv_forw_packet_ogmv1_queue(struct batadv_priv *bat_priv,
+				    struct batadv_forw_packet *forw_packet,
+				    unsigned long send_time)
+{
+	batadv_forw_packet_queue(forw_packet, &bat_priv->forw_bat_list_lock,
+				 &bat_priv->forw_bat_list, send_time);
 }
 
 /**
@@ -600,7 +775,7 @@ int batadv_add_bcast_packet_to_list(struct batadv_priv *bat_priv,
 	INIT_DELAYED_WORK(&forw_packet->delayed_work,
 			  batadv_send_outstanding_bcast_packet);
 
-	_batadv_add_bcast_packet_to_list(bat_priv, forw_packet, delay);
+	batadv_forw_packet_bcast_queue(bat_priv, forw_packet, jiffies + delay);
 	return NETDEV_TX_OK;
 
 err_packet_free:
@@ -619,6 +794,7 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 	struct sk_buff *skb1;
 	struct net_device *soft_iface;
 	struct batadv_priv *bat_priv;
+	unsigned long send_time = jiffies + msecs_to_jiffies(5);
 	bool dropped = false;
 	u8 *neigh_addr;
 	u8 *orig_neigh;
@@ -630,10 +806,6 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 	soft_iface = forw_packet->if_incoming->soft_iface;
 	bat_priv = netdev_priv(soft_iface);
 
-	spin_lock_bh(&bat_priv->forw_bcast_list_lock);
-	hlist_del(&forw_packet->list);
-	spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
-
 	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_DEACTIVATING) {
 		dropped = true;
 		goto out;
@@ -714,22 +886,34 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 
 	/* if we still have some more bcasts to send */
 	if (forw_packet->num_packets < BATADV_NUM_BCASTS_MAX) {
-		_batadv_add_bcast_packet_to_list(bat_priv, forw_packet,
-						 msecs_to_jiffies(5));
+		batadv_forw_packet_bcast_queue(bat_priv, forw_packet,
+					       send_time);
 		return;
 	}
 
 out:
-	batadv_forw_packet_free(forw_packet, dropped);
+	/* do we get something for free()? */
+	if (batadv_forw_packet_steal(forw_packet,
+				     &bat_priv->forw_bcast_list_lock))
+		batadv_forw_packet_free(forw_packet, dropped);
 }
 
+/**
+ * batadv_purge_outstanding_packets - stop/purge scheduled bcast/OGMv1 packets
+ * @bat_priv: the bat priv with all the soft interface information
+ * @hard_iface: the hard interface to cancel and purge bcast/ogm packets on
+ *
+ * This method cancels and purges any broadcast and OGMv1 packet on the given
+ * hard_iface. If hard_iface is NULL, broadcast and OGMv1 packets on all hard
+ * interfaces will be canceled and purged.
+ *
+ * This function might sleep.
+ */
 void
 batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
 				 const struct batadv_hard_iface *hard_iface)
 {
-	struct batadv_forw_packet *forw_packet;
-	struct hlist_node *safe_tmp_node;
-	bool pending;
+	struct hlist_head head = HLIST_HEAD_INIT;
 
 	if (hard_iface)
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
@@ -739,57 +923,18 @@ batadv_purge_outstanding_packets(struct batadv_priv *bat_priv,
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "purge_outstanding_packets()\n");
 
-	/* free bcast list */
+	/* claim bcast list for free() */
 	spin_lock_bh(&bat_priv->forw_bcast_list_lock);
-	hlist_for_each_entry_safe(forw_packet, safe_tmp_node,
-				  &bat_priv->forw_bcast_list, list) {
-		/* if purge_outstanding_packets() was called with an argument
-		 * we delete only packets belonging to the given interface
-		 */
-		if ((hard_iface) &&
-		    (forw_packet->if_incoming != hard_iface) &&
-		    (forw_packet->if_outgoing != hard_iface))
-			continue;
-
-		spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
-
-		/* batadv_send_outstanding_bcast_packet() will lock the list to
-		 * delete the item from the list
-		 */
-		pending = cancel_delayed_work_sync(&forw_packet->delayed_work);
-		spin_lock_bh(&bat_priv->forw_bcast_list_lock);
-
-		if (pending) {
-			hlist_del(&forw_packet->list);
-			batadv_forw_packet_free(forw_packet, true);
-		}
-	}
+	batadv_forw_packet_list_steal(&bat_priv->forw_bcast_list, &head,
+				      hard_iface);
 	spin_unlock_bh(&bat_priv->forw_bcast_list_lock);
 
-	/* free batman packet list */
+	/* claim batman packet list for free() */
 	spin_lock_bh(&bat_priv->forw_bat_list_lock);
-	hlist_for_each_entry_safe(forw_packet, safe_tmp_node,
-				  &bat_priv->forw_bat_list, list) {
-		/* if purge_outstanding_packets() was called with an argument
-		 * we delete only packets belonging to the given interface
-		 */
-		if ((hard_iface) &&
-		    (forw_packet->if_incoming != hard_iface) &&
-		    (forw_packet->if_outgoing != hard_iface))
-			continue;
-
-		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
-
-		/* send_outstanding_bat_packet() will lock the list to
-		 * delete the item from the list
-		 */
-		pending = cancel_delayed_work_sync(&forw_packet->delayed_work);
-		spin_lock_bh(&bat_priv->forw_bat_list_lock);
-
-		if (pending) {
-			hlist_del(&forw_packet->list);
-			batadv_forw_packet_free(forw_packet, true);
-		}
-	}
+	batadv_forw_packet_list_steal(&bat_priv->forw_bat_list, &head,
+				      hard_iface);
 	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
+
+	/* then cancel or wait for packet workers to finish and free */
+	batadv_forw_packet_list_free(&head);
 }
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index c580194..a94e1e8 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -21,6 +21,7 @@
 #include "main.h"
 
 #include <linux/compiler.h>
+#include <linux/spinlock.h>
 #include <linux/types.h>
 
 #include "packet.h"
@@ -34,6 +35,10 @@ batadv_forw_packet_alloc(struct batadv_hard_iface *if_incoming,
 			 struct batadv_hard_iface *if_outgoing,
 			 atomic_t *queue_left,
 			 struct batadv_priv *bat_priv);
+bool batadv_forw_packet_steal(struct batadv_forw_packet *packet, spinlock_t *l);
+void batadv_forw_packet_ogmv1_queue(struct batadv_priv *bat_priv,
+				    struct batadv_forw_packet *forw_packet,
+				    unsigned long send_time);
 
 int batadv_send_skb_to_orig(struct sk_buff *skb,
 			    struct batadv_orig_node *orig_node,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index caa00a5..e913aee 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1385,6 +1385,7 @@ struct batadv_skb_cb {
 /**
  * struct batadv_forw_packet - structure for bcast packets to be sent/forwarded
  * @list: list node for batadv_priv::forw_{bat,bcast}_list
+ * @cleanup_list: list node for purging functions
  * @send_time: execution time for delayed_work (packet sending)
  * @own: bool for locally generated packets (local OGMs are re-scheduled after
  *  sending)
@@ -1401,6 +1402,7 @@ struct batadv_skb_cb {
  */
 struct batadv_forw_packet {
 	struct hlist_node list;
+	struct hlist_node cleanup_list;
 	unsigned long send_time;
 	u8 own;
 	struct sk_buff *skb;
-- 
2.10.2
