From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [RFC PATCH net-next] bridge: allow setting hash_max +
 multicast_router if interface is down
Date: Thu, 21 May 2015 04:59:22 +0200
Message-ID: <1432177162-9573-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Network managers like netifd (used in OpenWRT for instance) try to
configure interface options after creation but before setting the
interface up.

Unfortunately the sysfs / bridge currently only allows to configure the
hash_max and multicast_router options when the bridge interface is up.
But since br_multicast_init() doesn't start any timers and only sets
default values and initializes timers it should be save to reconfigure
the default values after that, before things actually get active after
the bridge is set up.

With this patch hash_max and multicast_router attributes can be
changed even if the according bridge (port) is down, just like other
other bridge (port) attributes allow too.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
---

I'm currently a little unsure about a few things (that's why I'm sendin=
g
this as an RFC):

* For i=3Dbr_multicast_init(), e=3Dbr_multicast_enable() and
  s=3Dbr_multicast_stop() is the order i->e->s->e->s->e->... always
  ensured by the netdev API? Will this work even if I have
  many fast and wild calls to "ip link set up dev br0" and
  "ip link set down dev br0" and some changes to hash_max and
  multicast_router in between?

* Might calls to br_multicast_add_router() via br_multicast_enable_port=
()
  cause unintended side-effects?

* (maybe independent of this patch: )
  Can fast changes to the multicast_router attribute of a bridge (port)
  cause race conditions because a del_timer() instead of a
  del_timer_sync() is used in br_multicast_set_{port,}router()?
  (or: why does br_multicast_stop() use del_timer_sync() while
   br_multicast_disable_port() doesn't?)

* @Herbert: Do you remember whether there was a reason for
  checking netif_running() or the bridge port state which
  I might have overlooked?


PS: Running this patch didn't create any crashes for me so far
and multicast traffic still runs fine. No locust infestation in sight
yet either. Still careful though :P.

 net/bridge/br_multicast.c |   15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2d69d5c..066199e 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1775,8 +1775,6 @@ int br_multicast_set_router(struct net_bridge *br=
, unsigned long val)
 	int err =3D -ENOENT;
=20
 	spin_lock_bh(&br->multicast_lock);
-	if (!netif_running(br->dev))
-		goto unlock;
=20
 	switch (val) {
 	case 0:
@@ -1793,7 +1791,6 @@ int br_multicast_set_router(struct net_bridge *br=
, unsigned long val)
 		break;
 	}
=20
-unlock:
 	spin_unlock_bh(&br->multicast_lock);
=20
 	return err;
@@ -1802,18 +1799,15 @@ unlock:
 int br_multicast_set_port_router(struct net_bridge_port *p, unsigned l=
ong val)
 {
 	struct net_bridge *br =3D p->br;
-	int err =3D -ENOENT;
+	int err =3D 0;
=20
 	spin_lock(&br->multicast_lock);
-	if (!netif_running(br->dev) || p->state =3D=3D BR_STATE_DISABLED)
-		goto unlock;
=20
 	switch (val) {
 	case 0:
 	case 1:
 	case 2:
 		p->multicast_router =3D val;
-		err =3D 0;
=20
 		if (val < 2 && !hlist_unhashed(&p->rlist))
 			hlist_del_init_rcu(&p->rlist);
@@ -1834,7 +1828,6 @@ int br_multicast_set_port_router(struct net_bridg=
e_port *p, unsigned long val)
 		break;
 	}
=20
-unlock:
 	spin_unlock(&br->multicast_lock);
=20
 	return err;
@@ -1939,15 +1932,11 @@ unlock:
=20
 int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val=
)
 {
-	int err =3D -ENOENT;
+	int err =3D -EINVAL;
 	u32 old;
 	struct net_bridge_mdb_htable *mdb;
=20
 	spin_lock_bh(&br->multicast_lock);
-	if (!netif_running(br->dev))
-		goto unlock;
-
-	err =3D -EINVAL;
 	if (!is_power_of_2(val))
 		goto unlock;
=20
--=20
1.7.10.4
