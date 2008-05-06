From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/4][MAC80211]: Fix not checked kmalloc() result.
Date: Tue, 06 May 2008 18:49:02 +0400
Message-ID: <48206FDE.4040704@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60446 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754248AbYEFOwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 10:52:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new_node kmallocation is not checked for success, so add
this check.

BTW, it also happens under the read_lock.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/mac80211/mesh_pathtbl.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 727aa52..1d2d051 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -164,13 +164,19 @@ int mesh_path_add(u8 *dst, struct net_device *dev)
 		err = -ENOMEM;
 		goto endadd2;
 	}
+	new_node = kmalloc(sizeof(struct mpath_node), GFP_KERNEL);
+	if (!new_node) {
+		kfree(new_mpath);
+		atomic_dec(&sdata->u.sta.mpaths);
+		err = -ENOMEM;
+		goto endadd2;
+	}
 
 	read_lock(&pathtbl_resize_lock);
 	memcpy(new_mpath->dst, dst, ETH_ALEN);
 	new_mpath->dev = dev;
 	new_mpath->flags = 0;
 	skb_queue_head_init(&new_mpath->frame_queue);
-	new_node = kmalloc(sizeof(struct mpath_node), GFP_KERNEL);
 	new_node->mpath = new_mpath;
 	new_mpath->timer.data = (unsigned long) new_mpath;
 	new_mpath->timer.function = mesh_path_timer;
-- 
1.5.3.4

