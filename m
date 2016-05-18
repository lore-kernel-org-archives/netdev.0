From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 4/8] batman-adv: Fix unexpected free of bcast_own on add_if error
Date: Wed, 18 May 2016 13:04:48 +0800
Message-ID: <1463547892-11290-5-git-send-email-a@unstable.cc>
References: <1463547892-11290-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:19075 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751899AbcERFGR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 01:06:17 -0400
In-Reply-To: <1463547892-11290-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The function batadv_iv_ogm_orig_add_if allocates new buffers for bcast_own
and bcast_own_sum. It is expected that these buffers are unchanged in case
either bcast_own or bcast_own_sum couldn't be resized.

But the error handling of this function frees the already resized buffer
for bcast_own when the allocation of the new bcast_own_sum buffer failed.
This will lead to an invalid memory access when some code will try to
access bcast_own.

Instead the resized new bcast_own buffer has to be kept. This will not lead
to problems because the size of the buffer was only increased and therefore
no user of the buffer will try to access bytes outside of the new buffer.

Fixes: d0015fdd3d2c ("batman-adv: provide orig_node routing API")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 7f98a9d39883..1b5bbafc0fa3 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -157,10 +157,8 @@ static int batadv_iv_ogm_orig_add_if(struct batadv_orig_node *orig_node,
 	orig_node->bat_iv.bcast_own = data_ptr;
 
 	data_ptr = kmalloc_array(max_if_num, sizeof(u8), GFP_ATOMIC);
-	if (!data_ptr) {
-		kfree(orig_node->bat_iv.bcast_own);
+	if (!data_ptr)
 		goto unlock;
-	}
 
 	memcpy(data_ptr, orig_node->bat_iv.bcast_own_sum,
 	       (max_if_num - 1) * sizeof(u8));
-- 
2.8.2
