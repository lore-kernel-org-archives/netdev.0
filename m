From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] batman-adv: Use kasprintf
Date: Sat, 28 Jun 2014 12:13:01 -0700
Message-ID: <1403982781.9064.33.camel@joe-AO725>
References: <20140628183628.GA9946@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: Himangi Saraogi <himangi774@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140628183628.GA9946@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-06-29 at 00:06 +0530, Himangi Saraogi wrote:
> kasprintf combines kmalloc and sprintf, and takes care of the size
> calculation itself.

Nice.  A small conversion to remove
unnecessary initializations, avoid calling
kfree with known NULL pointers, and save a
few bytes of code space woud be:
---
 net/batman-adv/sysfs.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index f40cb04..d6fba94 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -896,7 +896,7 @@ int batadv_throw_uevent(struct batadv_priv *bat_priv, enum batadv_uev_type type,
 {
 	int ret = -ENOMEM;
 	struct kobject *bat_kobj;
-	char *uevent_env[4] = { NULL, NULL, NULL, NULL };
+	char *uevent_env[3];
 
 	bat_kobj = &bat_priv->soft_iface->dev.kobj;
 
@@ -910,22 +910,23 @@ int batadv_throw_uevent(struct batadv_priv *bat_priv, enum batadv_uev_type type,
 				  "%s%s", BATADV_UEV_ACTION_VAR,
 				  batadv_uev_action_str[action]);
 	if (!uevent_env[1])
-		goto out;
+		goto out0;
 
 	/* If the event is DEL, ignore the data field */
 	if (action != BATADV_UEV_DEL) {
 		uevent_env[2] = kasprintf(GFP_ATOMIC,
 					  "%s%s", BATADV_UEV_DATA_VAR, data);
 		if (!uevent_env[2])
-			goto out;
+			goto out1;
 	}
 
 	ret = kobject_uevent_env(bat_kobj, KOBJ_CHANGE, uevent_env);
-out:
-	kfree(uevent_env[0]);
-	kfree(uevent_env[1]);
 	kfree(uevent_env[2]);
-
+out1:
+	kfree(uevent_env[1]);
+out0:
+	kfree(uevent_env[0]);
+out:
 	if (ret)
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Impossible to send uevent for (%s,%s,%s) event (err: %d)\n",
