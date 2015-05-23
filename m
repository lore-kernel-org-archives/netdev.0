From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCHv3 net-next] bridge: allow setting hash_max + multicast_router
 if interface is down
Date: Sat, 23 May 2015 03:12:34 +0200
Message-ID: <1432343554-3493-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Satish Ashok <sashok@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	roopa <roopa@cumulusnetworks.com>,
	Cong Wang <cwang@twopensource.com>
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

Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
---
Changelog v3:
* Readded two breaks (cosmetic / for future safety reasons)

Changelog v2:
* remove another now unnecessary -ENOENT initialization
* consistently initialize to -EINVAL, allowing to shorten two switch-ca=
ses

 net/bridge/br_multicast.c |   24 +++---------------------
 1 file changed, 3 insertions(+), 21 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2d69d5c..28a87c2 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1772,11 +1772,9 @@ out:
=20
 int br_multicast_set_router(struct net_bridge *br, unsigned long val)
 {
-	int err =3D -ENOENT;
+	int err =3D -EINVAL;
=20
 	spin_lock_bh(&br->multicast_lock);
-	if (!netif_running(br->dev))
-		goto unlock;
=20
 	switch (val) {
 	case 0:
@@ -1787,13 +1785,8 @@ int br_multicast_set_router(struct net_bridge *b=
r, unsigned long val)
 		br->multicast_router =3D val;
 		err =3D 0;
 		break;
-
-	default:
-		err =3D -EINVAL;
-		break;
 	}
=20
-unlock:
 	spin_unlock_bh(&br->multicast_lock);
=20
 	return err;
@@ -1802,11 +1795,9 @@ unlock:
 int br_multicast_set_port_router(struct net_bridge_port *p, unsigned l=
ong val)
 {
 	struct net_bridge *br =3D p->br;
-	int err =3D -ENOENT;
+	int err =3D -EINVAL;
=20
 	spin_lock(&br->multicast_lock);
-	if (!netif_running(br->dev) || p->state =3D=3D BR_STATE_DISABLED)
-		goto unlock;
=20
 	switch (val) {
 	case 0:
@@ -1828,13 +1819,8 @@ int br_multicast_set_port_router(struct net_brid=
ge_port *p, unsigned long val)
=20
 		br_multicast_add_router(br, p);
 		break;
-
-	default:
-		err =3D -EINVAL;
-		break;
 	}
=20
-unlock:
 	spin_unlock(&br->multicast_lock);
=20
 	return err;
@@ -1939,15 +1925,11 @@ unlock:
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
