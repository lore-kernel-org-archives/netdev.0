From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH] Revert "bridge: only expire the mdb entry when
	query is received"
Date: Sun, 20 Oct 2013 00:58:57 +0200
Message-ID: <1382223537-10844-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Cong Wang <amwang@redhat.com>, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

While this commit was a good attempt to fix issues occuring when no
multicast querier is present, this commit still has two more issues:

1) There are cases where mdb entries do not expire even if there is a
querier present. The bridge will unnecessarily continue flooding
multicast packets on the according ports.

2) Never removing an mdb entry could be exploited for a Denial of
Service by an attacker on the local link, slowly, but steadily eating up
all memory.

Actually, this commit became obsolete with
"bridge: disable snooping if there is no querier" (b00589af3b)
which included fixes for a few more cases.

Therefore reverting the following commits (the commit stated in the
commit message plus three of its follow up fixes):

---
Revert "bridge: update mdb expiration timer upon reports."
This reverts commit f144febd93d5ee534fdf23505ab091b2b9088edc.
Revert "bridge: do not call setup_timer() multiple times"
This reverts commit 1faabf2aab1fdaa1ace4e8c829d1b9cf7bfec2f1.
Revert "bridge: fix some kernel warning in multicast timer"
This reverts commit c7e8e8a8f7a70b343ca1e0f90a31e35ab2d16de1.
Revert "bridge: only expire the mdb entry when query is received"
This reverts commit 9f00b2e7cf241fa389733d41b615efdaa2cb0f5b.
---

CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_mdb.c       |    2 +-
 net/bridge/br_multicast.c |   47 ++++++++++++++++++++++++++-------------=
------
 net/bridge/br_private.h   |    1 -
 3 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 85a09bb..b7b1914 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -453,7 +453,7 @@ static int __br_mdb_del(struct net_bridge *br, struct=
 br_mdb_entry *entry)
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
 		err =3D 0;
=20
-		if (!mp->ports && !mp->mglist && mp->timer_armed &&
+		if (!mp->ports && !mp->mglist &&
 		    netif_running(br->dev))
 			mod_timer(&mp->timer, jiffies);
 		break;
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 1085f21..8b0b610 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -272,7 +272,7 @@ static void br_multicast_del_pg(struct net_bridge *br=
,
 		del_timer(&p->timer);
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
=20
-		if (!mp->ports && !mp->mglist && mp->timer_armed &&
+		if (!mp->ports && !mp->mglist &&
 		    netif_running(br->dev))
 			mod_timer(&mp->timer, jiffies);
=20
@@ -611,9 +611,6 @@ rehash:
 		break;
=20
 	default:
-		/* If we have an existing entry, update it's expire timer */
-		mod_timer(&mp->timer,
-			  jiffies + br->multicast_membership_interval);
 		goto out;
 	}
=20
@@ -623,7 +620,6 @@ rehash:
=20
 	mp->br =3D br;
 	mp->addr =3D *group;
-
 	setup_timer(&mp->timer, br_multicast_group_expired,
 		    (unsigned long)mp);
=20
@@ -663,6 +659,7 @@ static int br_multicast_add_group(struct net_bridge *=
br,
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
 	struct net_bridge_port_group __rcu **pp;
+	unsigned long now =3D jiffies;
 	int err;
=20
 	spin_lock(&br->multicast_lock);
@@ -677,18 +674,15 @@ static int br_multicast_add_group(struct net_bridge=
 *br,
=20
 	if (!port) {
 		mp->mglist =3D true;
+		mod_timer(&mp->timer, now + br->multicast_membership_interval);
 		goto out;
 	}
=20
 	for (pp =3D &mp->ports;
 	     (p =3D mlock_dereference(*pp, br)) !=3D NULL;
 	     pp =3D &p->next) {
-		if (p->port =3D=3D port) {
-			/* We already have a portgroup, update the timer.  */
-			mod_timer(&p->timer,
-				  jiffies + br->multicast_membership_interval);
-			goto out;
-		}
+		if (p->port =3D=3D port)
+			goto found;
 		if ((unsigned long)p->port < (unsigned long)port)
 			break;
 	}
@@ -699,6 +693,8 @@ static int br_multicast_add_group(struct net_bridge *=
br,
 	rcu_assign_pointer(*pp, p);
 	br_mdb_notify(br->dev, port, group, RTM_NEWMDB);
=20
+found:
+	mod_timer(&p->timer, now + br->multicast_membership_interval);
 out:
 	err =3D 0;
=20
@@ -1198,9 +1194,6 @@ static int br_ip4_multicast_query(struct net_bridge=
 *br,
 	if (!mp)
 		goto out;
=20
-	mod_timer(&mp->timer, now + br->multicast_membership_interval);
-	mp->timer_armed =3D true;
-
 	max_delay *=3D br->multicast_last_member_count;
=20
 	if (mp->mglist &&
@@ -1277,9 +1270,6 @@ static int br_ip6_multicast_query(struct net_bridge=
 *br,
 	if (!mp)
 		goto out;
=20
-	mod_timer(&mp->timer, now + br->multicast_membership_interval);
-	mp->timer_armed =3D true;
-
 	max_delay *=3D br->multicast_last_member_count;
 	if (mp->mglist &&
 	    (timer_pending(&mp->timer) ?
@@ -1365,7 +1355,7 @@ static void br_multicast_leave_group(struct net_bri=
dge *br,
 			call_rcu_bh(&p->rcu, br_multicast_free_pg);
 			br_mdb_notify(br->dev, port, group, RTM_DELMDB);
=20
-			if (!mp->ports && !mp->mglist && mp->timer_armed &&
+			if (!mp->ports && !mp->mglist &&
 			    netif_running(br->dev))
 				mod_timer(&mp->timer, jiffies);
 		}
@@ -1377,12 +1367,30 @@ static void br_multicast_leave_group(struct net_b=
ridge *br,
 		     br->multicast_last_member_interval;
=20
 	if (!port) {
-		if (mp->mglist && mp->timer_armed &&
+		if (mp->mglist &&
 		    (timer_pending(&mp->timer) ?
 		     time_after(mp->timer.expires, time) :
 		     try_to_del_timer_sync(&mp->timer) >=3D 0)) {
 			mod_timer(&mp->timer, time);
 		}
+
+		goto out;
+	}
+
+	for (p =3D mlock_dereference(mp->ports, br);
+	     p !=3D NULL;
+	     p =3D mlock_dereference(p->next, br)) {
+		if (p->port !=3D port)
+			continue;
+
+		if (!hlist_unhashed(&p->mglist) &&
+		    (timer_pending(&p->timer) ?
+		     time_after(p->timer.expires, time) :
+		     try_to_del_timer_sync(&p->timer) >=3D 0)) {
+			mod_timer(&p->timer, time);
+		}
+
+		break;
 	}
 out:
 	spin_unlock(&br->multicast_lock);
@@ -1805,7 +1813,6 @@ void br_multicast_stop(struct net_bridge *br)
 		hlist_for_each_entry_safe(mp, n, &mdb->mhash[i],
 					  hlist[ver]) {
 			del_timer(&mp->timer);
-			mp->timer_armed =3D false;
 			call_rcu_bh(&mp->rcu, br_multicast_free_group);
 		}
 	}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 7ca2ae4..e14c33b 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -126,7 +126,6 @@ struct net_bridge_mdb_entry
 	struct timer_list		timer;
 	struct br_ip			addr;
 	bool				mglist;
-	bool				timer_armed;
 };
=20
 struct net_bridge_mdb_htable
--=20
1.7.10.4
