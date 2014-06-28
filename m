From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] batman-adv: Use kasprintf
Date: Sat, 28 Jun 2014 13:11:36 -0700
Message-ID: <1403986296.9064.45.camel@joe-AO725>
References: <20140628183628.GA9946@himangi-Dell>
	 <1403982781.9064.33.camel@joe-AO725> <53AF1C42.6000108@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Himangi Saraogi <himangi774@gmail.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	"David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53AF1C42.6000108@meshcoding.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-06-28 at 21:49 +0200, Antonio Quartulli wrote:
> Hi all,
> 
> On 28/06/14 21:13, Joe Perches wrote:
> > diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
[]
> > @@ -896,7 +896,7 @@ int batadv_throw_uevent(struct batadv_priv *bat_priv, enum batadv_uev_type type,
> >  {
> >  	int ret = -ENOMEM;
> >  	struct kobject *bat_kobj;
> > -	char *uevent_env[4] = { NULL, NULL, NULL, NULL };
> > +	char *uevent_env[3];
> 
> 
> Joe, why are you shortening this? kobject_uevent_env() expect a
> NULL-terminating array (that is the forth cell).

Hi Antonio, sorry, I didn't know about the last NULL
being required.  It looked to me more like an
oversight in the code instead of a required NULL.

> And how is this change reducing the code space?

Removing unnecessary initializations reduces
object code size.

> For what concerns the labels, we use this pattern mostly all over the
> code: one single label/exit-point with the related NULL checks. Do you
> think that we can improve something by changing this? (I am not talking
> about the fastpath here).

Not calling known unnecessary kfree calls helps a
little.  Certainly, it'd be more valuable in any
fast path area.

Other than that, it was an unsigned suggestion
not a formal patch submission.

Ignore it or improve it as you see fit.

cheers, Joe

Maybe:
---
 net/batman-adv/sysfs.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index f40cb04..90c245e 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -896,7 +896,7 @@ int batadv_throw_uevent(struct batadv_priv *bat_priv, enum batadv_uev_type type,
 {
 	int ret = -ENOMEM;
 	struct kobject *bat_kobj;
-	char *uevent_env[4] = { NULL, NULL, NULL, NULL };
+	char *uevent_env[4];
 
 	bat_kobj = &bat_priv->soft_iface->dev.kobj;
 
@@ -910,22 +910,26 @@ int batadv_throw_uevent(struct batadv_priv *bat_priv, enum batadv_uev_type type,
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
 
+	uevent_env[3] = NULL;
+
 	ret = kobject_uevent_env(bat_kobj, KOBJ_CHANGE, uevent_env);
-out:
-	kfree(uevent_env[0]);
-	kfree(uevent_env[1]);
-	kfree(uevent_env[2]);
 
+	kfree(uevent_env[2]);
+out1:
+	kfree(uevent_env[1]);
+out0:
+	kfree(uevent_env[0]);
+out:
 	if (ret)
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "Impossible to send uevent for (%s,%s,%s) event (err: %d)\n",
