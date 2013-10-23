From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: [PATCH 13/16] batman-adv: improve the TT component
	to support runtime flag changes
Date: Wed, 23 Oct 2013 18:05:00 +0200
Message-ID: <1382544303-2694-14-git-send-email-antonio@meshcoding.com>
References: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
 Antonio Quartulli <antonio-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1382544303-2694-1-git-send-email-antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Antonio Quartulli <antonio-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>

Some flags (i.e. the WIFI flag) may change after that the
related client has already been announced. However it is
useful to informa the rest of the network about this change.

Add a runtime-flag-switch detection mechanism and
re-announce the related TT entry to advertise the new flag
value.

This mechanism can be easily exploited by future flags that
may need the same treatment.

Signed-off-by: Antonio Quartulli <antonio-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
---
 net/batman-adv/translation-table.c | 25 ++++++++++++++++++++++++-
 net/batman-adv/types.h             |  6 ++++++
 2 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index b0fe177..267780f 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -358,6 +358,13 @@ static void batadv_tt_local_event(struct batadv_priv *bat_priv,
 			goto del;
 		if (del_op_requested && !del_op_entry)
 			goto del;
+
+		/* this is a second add in the same originator interval. It
+		 * means that flags have been changed: update them!
+		 */
+		if (!del_op_requested && !del_op_entry)
+			entry->change.flags = flags;
+
 		continue;
 del:
 		list_del(&entry->list);
@@ -482,6 +489,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	struct batadv_tt_orig_list_entry *orig_entry;
 	int hash_added, table_size, packet_size_max;
 	bool ret = false, roamed_back = false;
+	uint8_t remote_flags;
 
 	if (ifindex != BATADV_NULL_IFINDEX)
 		in_dev = dev_get_by_index(&init_net, ifindex);
@@ -596,8 +604,23 @@ check_roaming:
 		}
 	}
 
-	ret = true;
+	/* store the current remote flags before altering them. This helps
+	 * understanding is flags are changing or not
+	 */
+	remote_flags = tt_local->common.flags & BATADV_TT_REMOTE_MASK;
+
+	if (batadv_is_wifi_netdev(in_dev))
+		tt_local->common.flags |= BATADV_TT_CLIENT_WIFI;
+	else
+		tt_local->common.flags &= ~BATADV_TT_CLIENT_WIFI;
 
+	/* if any "dynamic" flag has been modified, resend an ADD event for this
+	 * entry so that all the nodes can get the new flags
+	 */
+	if (remote_flags ^ (tt_local->common.flags & BATADV_TT_REMOTE_MASK))
+		batadv_tt_local_event(bat_priv, tt_local, BATADV_NO_FLAGS);
+
+	ret = true;
 out:
 	if (in_dev)
 		dev_put(in_dev);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 04b6b0b..61297b6 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -36,6 +36,12 @@
 #endif /* CONFIG_BATMAN_ADV_DAT */
 
 /**
+ * BATADV_TT_REMOTE_MASK - bitmask selecting the flags that are sent over the
+ *  wire only
+ */
+#define BATADV_TT_REMOTE_MASK	0x00FF
+
+/**
  * struct batadv_hard_iface_bat_iv - per hard interface B.A.T.M.A.N. IV data
  * @ogm_buff: buffer holding the OGM packet
  * @ogm_buff_len: length of the OGM packet buffer
-- 
1.8.4
