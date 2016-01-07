From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH] batman-adv: Fix invalid read while copying bat_iv.bcast_own
Date: Thu,  7 Jan 2016 15:26:27 +0800
Message-ID: <1452151587-25547-2-git-send-email-a@unstable.cc>
References: <1452151587-25547-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:5781 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773AbcAGH2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 02:28:19 -0500
In-Reply-To: <1452151587-25547-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batadv_iv_ogm_orig_del_if removes a part of the bcast_own which previously
belonged to the now removed interface. This is done by copying all data
which comes before the removed interface and then appending all the data
which comes after the removed interface.

The address calculation for the position of the data which comes after the
removed interface assumed that the bat_iv.bcast_own is a pointer to a
single byte datatype. But it is a pointer to unsigned long and thus the
calculated position was wrong off factor sizeof(unsigned long).

Fixes: 83a8342678a0 ("more basic routing code added (forwarding packets /
bitarray added)")

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 912d9c3..aa94b4e 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -185,7 +185,8 @@ unlock:
 static int batadv_iv_ogm_orig_del_if(struct batadv_orig_node *orig_node,
 				     int max_if_num, int del_if_num)
 {
-	int chunk_size,  ret = -ENOMEM, if_offset;
+	int ret = -ENOMEM;
+	size_t chunk_size, if_offset;
 	void *data_ptr = NULL;
 
 	spin_lock_bh(&orig_node->bat_iv.ogm_cnt_lock);
@@ -203,8 +204,9 @@ static int batadv_iv_ogm_orig_del_if(struct batadv_orig_node *orig_node,
 	memcpy(data_ptr, orig_node->bat_iv.bcast_own, del_if_num * chunk_size);
 
 	/* copy second part */
+	if_offset = (del_if_num + 1) * chunk_size;
 	memcpy((char *)data_ptr + del_if_num * chunk_size,
-	       orig_node->bat_iv.bcast_own + ((del_if_num + 1) * chunk_size),
+	       (uint8_t *)orig_node->bat_iv.bcast_own + if_offset,
 	       (max_if_num - del_if_num) * chunk_size);
 
 free_bcast_own:
-- 
2.7.0
