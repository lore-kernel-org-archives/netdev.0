From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] batman-adv: Use kasprintf
Date: Sun, 29 Jun 2014 00:06:29 +0530
Message-ID: <20140628183628.GA9946@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kasprintf combines kmalloc and sprintf, and takes care of the size
calculation itself.

The semantic patch that makes this change is as follows:

// <smpl>
@@
expression a,flag;
expression list args;
statement S;
@@

  a =
-  \(kmalloc\|kzalloc\)(...,flag)
+  kasprintf(flag,args)
  <... when != a
  if (a == NULL || ...) S
  ...>
- sprintf(a,args);
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 net/batman-adv/sysfs.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index fc47baa..f40cb04 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -900,32 +900,24 @@ int batadv_throw_uevent(struct batadv_priv *bat_priv, enum batadv_uev_type type,
 
 	bat_kobj = &bat_priv->soft_iface->dev.kobj;
 
-	uevent_env[0] = kmalloc(strlen(BATADV_UEV_TYPE_VAR) +
-				strlen(batadv_uev_type_str[type]) + 1,
-				GFP_ATOMIC);
+	uevent_env[0] = kasprintf(GFP_ATOMIC,
+				  "%s%s", BATADV_UEV_TYPE_VAR,
+				  batadv_uev_type_str[type]);
 	if (!uevent_env[0])
 		goto out;
 
-	sprintf(uevent_env[0], "%s%s", BATADV_UEV_TYPE_VAR,
-		batadv_uev_type_str[type]);
-
-	uevent_env[1] = kmalloc(strlen(BATADV_UEV_ACTION_VAR) +
-				strlen(batadv_uev_action_str[action]) + 1,
-				GFP_ATOMIC);
+	uevent_env[1] = kasprintf(GFP_ATOMIC,
+				  "%s%s", BATADV_UEV_ACTION_VAR,
+				  batadv_uev_action_str[action]);
 	if (!uevent_env[1])
 		goto out;
 
-	sprintf(uevent_env[1], "%s%s", BATADV_UEV_ACTION_VAR,
-		batadv_uev_action_str[action]);
-
 	/* If the event is DEL, ignore the data field */
 	if (action != BATADV_UEV_DEL) {
-		uevent_env[2] = kmalloc(strlen(BATADV_UEV_DATA_VAR) +
-					strlen(data) + 1, GFP_ATOMIC);
+		uevent_env[2] = kasprintf(GFP_ATOMIC,
+					  "%s%s", BATADV_UEV_DATA_VAR, data);
 		if (!uevent_env[2])
 			goto out;
-
-		sprintf(uevent_env[2], "%s%s", BATADV_UEV_DATA_VAR, data);
 	}
 
 	ret = kobject_uevent_env(bat_kobj, KOBJ_CHANGE, uevent_env);
-- 
1.9.1
