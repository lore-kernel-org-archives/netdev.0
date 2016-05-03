From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 15/15] batman-adv: Split batadv_iv_ogm_orig_del_if function
Date: Wed,  4 May 2016 06:23:50 +0800
Message-ID: <1462314230-16257-16-git-send-email-a@unstable.cc>
References: <1462314230-16257-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:5950 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756436AbcECWk4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:40:56 -0400
In-Reply-To: <1462314230-16257-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batadv_iv_ogm_orig_del_if handles two different buffers bcast_own and
bcast_own_sum which should be resized. The error handling two for
allocating these buffers causes the complexity of this function. This can
be avoided completely when the function is split into a main function
handling the locking, freeing and call of the subfunctions.

The subfunction can then independently handle the resize of the buffers.
This also allows to easily reuse the old buffer (which always is larger) in
case a smaller buffer could not be allocated without increasing the code
complexity.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c | 131 ++++++++++++++++++++++++++++----------------
 1 file changed, 84 insertions(+), 47 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 682fcaec56e6..8c1710bba803 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -32,6 +32,7 @@
 #include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/kref.h>
+#include <linux/lockdep.h>
 #include <linux/netdevice.h>
 #include <linux/pkt_sched.h>
 #include <linux/printk.h>
@@ -175,6 +176,79 @@ unlock:
 }
 
 /**
+ * batadv_iv_ogm_drop_bcast_own_entry - drop section of bcast_own
+ * @orig_node: the orig_node that has to be changed
+ * @max_if_num: the current amount of interfaces
+ * @del_if_num: the index of the interface being removed
+ */
+static void
+batadv_iv_ogm_drop_bcast_own_entry(struct batadv_orig_node *orig_node,
+				   int max_if_num, int del_if_num)
+{
+	size_t chunk_size;
+	size_t if_offset;
+	void *data_ptr;
+
+	lockdep_assert_held(&orig_node->bat_iv.ogm_cnt_lock);
+
+	chunk_size = sizeof(unsigned long) * BATADV_NUM_WORDS;
+	data_ptr = kmalloc_array(max_if_num, chunk_size, GFP_ATOMIC);
+	if (!data_ptr)
+		/* use old buffer when new one could not be allocated */
+		data_ptr = orig_node->bat_iv.bcast_own;
+
+	/* copy first part */
+	memmove(data_ptr, orig_node->bat_iv.bcast_own, del_if_num * chunk_size);
+
+	/* copy second part */
+	if_offset = (del_if_num + 1) * chunk_size;
+	memmove((char *)data_ptr + del_if_num * chunk_size,
+		(uint8_t *)orig_node->bat_iv.bcast_own + if_offset,
+		(max_if_num - del_if_num) * chunk_size);
+
+	/* bcast_own was shrunk down in new buffer; free old one */
+	if (orig_node->bat_iv.bcast_own != data_ptr) {
+		kfree(orig_node->bat_iv.bcast_own);
+		orig_node->bat_iv.bcast_own = data_ptr;
+	}
+}
+
+/**
+ * batadv_iv_ogm_drop_bcast_own_sum_entry - drop section of bcast_own_sum
+ * @orig_node: the orig_node that has to be changed
+ * @max_if_num: the current amount of interfaces
+ * @del_if_num: the index of the interface being removed
+ */
+static void
+batadv_iv_ogm_drop_bcast_own_sum_entry(struct batadv_orig_node *orig_node,
+				       int max_if_num, int del_if_num)
+{
+	size_t if_offset;
+	void *data_ptr;
+
+	lockdep_assert_held(&orig_node->bat_iv.ogm_cnt_lock);
+
+	data_ptr = kmalloc_array(max_if_num, sizeof(u8), GFP_ATOMIC);
+	if (!data_ptr)
+		/* use old buffer when new one could not be allocated */
+		data_ptr = orig_node->bat_iv.bcast_own_sum;
+
+	memmove(data_ptr, orig_node->bat_iv.bcast_own_sum,
+		del_if_num * sizeof(u8));
+
+	if_offset = (del_if_num + 1) * sizeof(u8);
+	memmove((char *)data_ptr + del_if_num * sizeof(u8),
+		orig_node->bat_iv.bcast_own_sum + if_offset,
+		(max_if_num - del_if_num) * sizeof(u8));
+
+	/* bcast_own_sum was shrunk down in new buffer; free old one */
+	if (orig_node->bat_iv.bcast_own_sum != data_ptr) {
+		kfree(orig_node->bat_iv.bcast_own_sum);
+		orig_node->bat_iv.bcast_own_sum = data_ptr;
+	}
+}
+
+/**
  * batadv_iv_ogm_orig_del_if - change the private structures of the orig_node to
  *  exclude the removed interface
  * @orig_node: the orig_node that has to be changed
@@ -186,60 +260,23 @@ unlock:
 static int batadv_iv_ogm_orig_del_if(struct batadv_orig_node *orig_node,
 				     int max_if_num, int del_if_num)
 {
-	int ret = -ENOMEM;
-	size_t chunk_size, if_offset;
-	void *data_ptr = NULL;
-
 	spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 
-	/* last interface was removed */
-	if (max_if_num == 0)
-		goto free_bcast_own;
-
-	chunk_size = sizeof(unsigned long) * BATADV_NUM_WORDS;
-	data_ptr = kmalloc_array(max_if_num, chunk_size, GFP_ATOMIC);
-	if (!data_ptr)
-		goto unlock;
-
-	/* copy first part */
-	memcpy(data_ptr, orig_node->bat_iv.bcast_own, del_if_num * chunk_size);
-
-	/* copy second part */
-	if_offset = (del_if_num + 1) * chunk_size;
-	memcpy((char *)data_ptr + del_if_num * chunk_size,
-	       (uint8_t *)orig_node->bat_iv.bcast_own + if_offset,
-	       (max_if_num - del_if_num) * chunk_size);
-
-free_bcast_own:
-	kfree(orig_node->bat_iv.bcast_own);
-	orig_node->bat_iv.bcast_own = data_ptr;
-
-	if (max_if_num == 0)
-		goto free_own_sum;
-
-	data_ptr = kmalloc_array(max_if_num, sizeof(u8), GFP_ATOMIC);
-	if (!data_ptr) {
+	if (max_if_num == 0) {
 		kfree(orig_node->bat_iv.bcast_own);
-		goto unlock;
+		kfree(orig_node->bat_iv.bcast_own_sum);
+		orig_node->bat_iv.bcast_own = NULL;
+		orig_node->bat_iv.bcast_own_sum = NULL;
+	} else {
+		batadv_iv_ogm_drop_bcast_own_entry(orig_node, max_if_num,
+						   del_if_num);
+		batadv_iv_ogm_drop_bcast_own_sum_entry(orig_node, max_if_num,
+						       del_if_num);
 	}
 
-	memcpy(data_ptr, orig_node->bat_iv.bcast_own_sum,
-	       del_if_num * sizeof(u8));
-
-	if_offset = (del_if_num + 1) * sizeof(u8);
-	memcpy((char *)data_ptr + del_if_num * sizeof(u8),
-	       orig_node->bat_iv.bcast_own_sum + if_offset,
-	       (max_if_num - del_if_num) * sizeof(u8));
-
-free_own_sum:
-	kfree(orig_node->bat_iv.bcast_own_sum);
-	orig_node->bat_iv.bcast_own_sum = data_ptr;
-
-	ret = 0;
-unlock:
 	spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 
-	return ret;
+	return 0;
 }
 
 /**
-- 
2.8.2
