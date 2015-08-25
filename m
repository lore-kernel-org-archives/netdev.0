From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 13/15] batman-adv: Add lockdep_asserts for documented external locks
Date: Tue, 25 Aug 2015 13:02:37 +0200
Message-ID: <1440500559-28368-14-git-send-email-antonio@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:12596 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753890AbbHYLa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:30:58 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Some functions already have documentation about locks they require inside
their kerneldoc header. These can be directly tested during runtime using
the lockdep asserts.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/fragmentation.c     | 3 +++
 net/batman-adv/multicast.c         | 6 ++++++
 net/batman-adv/translation-table.c | 2 ++
 3 files changed, 11 insertions(+)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index ec5f7bc..700c96c 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -25,6 +25,7 @@
 #include <linux/if_ether.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
+#include <linux/lockdep.h>
 #include <linux/netdevice.h>
 #include <linux/pkt_sched.h>
 #include <linux/skbuff.h>
@@ -112,6 +113,8 @@ static int batadv_frag_size_limit(void)
 static bool batadv_frag_init_chain(struct batadv_frag_table_entry *chain,
 				   u16 seqno)
 {
+	lockdep_assert_held(&chain->lock);
+
 	if (chain->seqno == seqno)
 		return false;
 
diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 410f34c..eb76386 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -609,6 +609,8 @@ static void batadv_mcast_want_unsnoop_update(struct batadv_priv *bat_priv,
 	struct hlist_node *node = &orig->mcast_want_all_unsnoopables_node;
 	struct hlist_head *head = &bat_priv->mcast.want_all_unsnoopables_list;
 
+	lockdep_assert_held(&orig->mcast_handler_lock);
+
 	/* switched from flag unset to set */
 	if (mcast_flags & BATADV_MCAST_WANT_ALL_UNSNOOPABLES &&
 	    !(orig->mcast_flags & BATADV_MCAST_WANT_ALL_UNSNOOPABLES)) {
@@ -652,6 +654,8 @@ static void batadv_mcast_want_ipv4_update(struct batadv_priv *bat_priv,
 	struct hlist_node *node = &orig->mcast_want_all_ipv4_node;
 	struct hlist_head *head = &bat_priv->mcast.want_all_ipv4_list;
 
+	lockdep_assert_held(&orig->mcast_handler_lock);
+
 	/* switched from flag unset to set */
 	if (mcast_flags & BATADV_MCAST_WANT_ALL_IPV4 &&
 	    !(orig->mcast_flags & BATADV_MCAST_WANT_ALL_IPV4)) {
@@ -695,6 +699,8 @@ static void batadv_mcast_want_ipv6_update(struct batadv_priv *bat_priv,
 	struct hlist_node *node = &orig->mcast_want_all_ipv6_node;
 	struct hlist_head *head = &bat_priv->mcast.want_all_ipv6_list;
 
+	lockdep_assert_held(&orig->mcast_handler_lock);
+
 	/* switched from flag unset to set */
 	if (mcast_flags & BATADV_MCAST_WANT_ALL_IPV6 &&
 	    !(orig->mcast_flags & BATADV_MCAST_WANT_ALL_IPV6)) {
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 79cee7b..4228b10 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -3271,6 +3271,8 @@ static void batadv_tt_local_purge_pending_clients(struct batadv_priv *bat_priv)
  */
 static void batadv_tt_local_commit_changes_nolock(struct batadv_priv *bat_priv)
 {
+	lockdep_assert_held(&bat_priv->tt.commit_lock);
+
 	/* Update multicast addresses in local translation table */
 	batadv_mcast_mla_update(bat_priv);
 
-- 
2.5.0
