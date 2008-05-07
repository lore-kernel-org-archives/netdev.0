From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/7][MAC80211]: Fix sleeping allocation under lock in mesh_path_node_copy.
Date: Wed, 07 May 2008 19:51:51 +0400
Message-ID: <4821D017.9050606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The mesh_path_node_copy() can be called like this:
mesh_path_add
 `- write_lock(&pathtbl_resize_lock); /* ! */
 `- mesh_table_grow
     `- ->copy_node
           `- mesh_path_node_copy

thus, the GFP_KERNEL is not suitable here.

The acceptable fix, I suppose, is make this allocation GPF_ATOMIC -
the mpath_node being allocated is 4 pointers, i.e. this allocation
is small enough to survive even under a moderate memory pressure.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---
 net/mac80211/mesh_pathtbl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index fe1ceee..1154398 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -469,7 +469,7 @@ static int mesh_path_node_copy(struct hlist_node *p, struct mesh_table *newtbl)
 	struct mpath_node *node, *new_node;
 	u32 hash_idx;
 
-	new_node = kmalloc(sizeof(struct mpath_node), GFP_KERNEL);
+	new_node = kmalloc(sizeof(struct mpath_node), GFP_ATOMIC);
 	if (new_node == NULL)
 		return -ENOMEM;
 
-- 
1.5.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
