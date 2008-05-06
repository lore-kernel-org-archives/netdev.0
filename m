From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/4][MAC80211]: Fix potential scheduling while atomic in mesh_path_add.
Date: Tue, 06 May 2008 18:51:31 +0400
Message-ID: <48207073.6010600@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Calling synchronize_rcu() under write-lock-ed pathtbl_resize_lock may
result in this warning (and other side effects).

It looks safe just dropping this lock before calling synchronize_rcu.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---
 net/mac80211/mesh_pathtbl.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 1d2d051..99c2d36 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -220,9 +220,10 @@ endadd:
 			return -ENOMEM;
 		}
 		rcu_assign_pointer(mesh_paths, newtbl);
+		write_unlock(&pathtbl_resize_lock);
+
 		synchronize_rcu();
 		mesh_table_free(oldtbl, false);
-		write_unlock(&pathtbl_resize_lock);
 	}
 endadd2:
 	return err;
-- 
1.5.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
