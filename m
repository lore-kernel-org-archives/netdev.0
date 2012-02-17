From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 05/10] batman-adv: Move is_out_of_time() to main.h for general use
Date: Fri, 17 Feb 2012 15:18:25 +0800
Message-ID: <1329463110-856-6-git-send-email-lindner_marek@yahoo.de>
References: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm3-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.228]:20102 "HELO
	nm3-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751611Ab2BQHTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 02:19:19 -0500
In-Reply-To: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

Both translation tables and network coding use timeouts to do house
keeping, so we might as well share the function used to compare a
timestamp+timeout with current time.

=46or readability and simplicity, the function is renamed to
has_timed_out() and uses time_is_before_jiffies() instead of
time_after().

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/main.h              |   11 +++++++++++
 net/batman-adv/translation-table.c |   32 ++++++++++++----------------=
----
 2 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 86354e0..f9c659b 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -202,6 +202,17 @@ static inline int compare_eth(const void *data1, c=
onst void *data2)
 	return (memcmp(data1, data2, ETH_ALEN) =3D=3D 0 ? 1 : 0);
 }
=20
+/**
+ * has_timed_out - compares current time (jiffies) and timestamp + tim=
eout
+ * @timestamp:		base value to compare with (in jiffies)
+ * @timeout:		added to base value before comparing (in milliseconds)
+ *
+ * Returns true if current time is after timestamp + timeout
+ */
+static inline bool has_timed_out(unsigned long timestamp, unsigned int=
 timeout)
+{
+	return time_is_before_jiffies(timestamp + msecs_to_jiffies(timeout));
+}
=20
 #define atomic_dec_not_zero(v)	atomic_add_unless((v), -1, 0)
=20
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
index bc518fc..a84e804 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -108,14 +108,6 @@ static struct tt_global_entry *tt_global_hash_find=
(struct bat_priv *bat_priv,
=20
 }
=20
-static bool is_out_of_time(unsigned long starting_time, unsigned long =
timeout)
-{
-	unsigned long deadline;
-	deadline =3D starting_time + msecs_to_jiffies(timeout);
-
-	return time_after(jiffies, deadline);
-}
-
 static void tt_local_entry_free_ref(struct tt_local_entry *tt_local_en=
try)
 {
 	if (atomic_dec_and_test(&tt_local_entry->common.refcount))
@@ -420,8 +412,8 @@ static void tt_local_purge(struct bat_priv *bat_pri=
v)
 			if (tt_local_entry->common.flags & TT_CLIENT_PENDING)
 				continue;
=20
-			if (!is_out_of_time(tt_local_entry->last_seen,
-					    TT_LOCAL_TIMEOUT * 1000))
+			if (!has_timed_out(tt_local_entry->last_seen,
+					   TT_LOCAL_TIMEOUT * 1000))
 				continue;
=20
 			tt_local_set_pending(bat_priv, tt_local_entry,
@@ -758,8 +750,8 @@ static void tt_global_roam_purge(struct bat_priv *b=
at_priv)
 						       common);
 			if (!(tt_global_entry->common.flags & TT_CLIENT_ROAM))
 				continue;
-			if (!is_out_of_time(tt_global_entry->roam_at,
-					    TT_CLIENT_ROAM_TIMEOUT * 1000))
+			if (!has_timed_out(tt_global_entry->roam_at,
+					   TT_CLIENT_ROAM_TIMEOUT * 1000))
 				continue;
=20
 			bat_dbg(DBG_TT, bat_priv, "Deleting global "
@@ -978,8 +970,8 @@ static void tt_req_purge(struct bat_priv *bat_priv)
=20
 	spin_lock_bh(&bat_priv->tt_req_list_lock);
 	list_for_each_entry_safe(node, safe, &bat_priv->tt_req_list, list) {
-		if (is_out_of_time(node->issued_at,
-		    TT_REQUEST_TIMEOUT * 1000)) {
+		if (has_timed_out(node->issued_at,
+				  TT_REQUEST_TIMEOUT * 1000)) {
 			list_del(&node->list);
 			kfree(node);
 		}
@@ -997,8 +989,8 @@ static struct tt_req_node *new_tt_req_node(struct b=
at_priv *bat_priv,
 	spin_lock_bh(&bat_priv->tt_req_list_lock);
 	list_for_each_entry(tt_req_node_tmp, &bat_priv->tt_req_list, list) {
 		if (compare_eth(tt_req_node_tmp, orig_node) &&
-		    !is_out_of_time(tt_req_node_tmp->issued_at,
-				    TT_REQUEST_TIMEOUT * 1000))
+		    !has_timed_out(tt_req_node_tmp->issued_at,
+				   TT_REQUEST_TIMEOUT * 1000))
 			goto unlock;
 	}
=20
@@ -1591,8 +1583,8 @@ static void tt_roam_purge(struct bat_priv *bat_pr=
iv)
=20
 	spin_lock_bh(&bat_priv->tt_roam_list_lock);
 	list_for_each_entry_safe(node, safe, &bat_priv->tt_roam_list, list) {
-		if (!is_out_of_time(node->first_time,
-				    ROAMING_MAX_TIME * 1000))
+		if (!has_timed_out(node->first_time,
+				   ROAMING_MAX_TIME * 1000))
 			continue;
=20
 		list_del(&node->list);
@@ -1619,8 +1611,8 @@ static bool tt_check_roam_count(struct bat_priv *=
bat_priv,
 		if (!compare_eth(tt_roam_node->addr, client))
 			continue;
=20
-		if (is_out_of_time(tt_roam_node->first_time,
-				   ROAMING_MAX_TIME * 1000))
+		if (has_timed_out(tt_roam_node->first_time,
+				  ROAMING_MAX_TIME * 1000))
 			continue;
=20
 		if (!atomic_dec_not_zero(&tt_roam_node->counter))
--=20
1.7.9
