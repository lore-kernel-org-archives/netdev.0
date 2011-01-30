From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 4/4] batman-adv: Make vis info stack traversal threadsafe
Date: Sun, 30 Jan 2011 13:11:44 +0100
Message-ID: <1296389504-11208-5-git-send-email-sven@narfation.org>
References: <1296389504-11208-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:45227 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753815Ab1A3MMA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jan 2011 07:12:00 -0500
In-Reply-To: <1296389504-11208-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The batman-adv vis server has to a stack which stores all information
about packets which should be send later. This stack is protected
with a spinlock that is used to prevent concurrent write access to it.

The send_vis_packets function has to take all elements from the stack
and send them to other hosts over the primary interface. The send will
be initiated without the lock which protects the stack.

The implementation using list_for_each_entry_safe has the problem that
it stores the next element as "safe ptr" to allow the deletion of the
current element in the list. The list may be modified during the
unlock/lock pair in the loop body which may make the safe pointer
not pointing to correct next element.

It is safer to remove and use the first element from the stack until no
elements are available. This does not need reduntant information which
would have to be validated each time the lock was removed.

Reported-by: Russell Senior <russell@personaltelco.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/vis.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 988296c..de1022c 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -816,7 +816,7 @@ static void send_vis_packets(struct work_struct *work)
 		container_of(work, struct delayed_work, work);
 	struct bat_priv *bat_priv =
 		container_of(delayed_work, struct bat_priv, vis_work);
-	struct vis_info *info, *temp;
+	struct vis_info *info;
 
 	spin_lock_bh(&bat_priv->vis_hash_lock);
 	purge_vis_packets(bat_priv);
@@ -826,8 +826,9 @@ static void send_vis_packets(struct work_struct *work)
 		send_list_add(bat_priv, bat_priv->my_vis_info);
 	}
 
-	list_for_each_entry_safe(info, temp, &bat_priv->vis_send_list,
-				 send_list) {
+	while (!list_empty(&bat_priv->vis_send_list)) {
+		info = list_first_entry(&bat_priv->vis_send_list,
+					typeof(*info), send_list);
 
 		kref_get(&info->refcount);
 		spin_unlock_bh(&bat_priv->vis_hash_lock);
-- 
1.7.2.3

