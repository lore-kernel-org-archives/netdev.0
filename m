From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCHv2 net-next] bridge: allow setting hash_max +
 multicast_router if interface is down
Date: Fri, 22 May 2015 15:32:37 +0200
Message-ID: <1432301557-6928-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Wilson Kok <wkok@cumulusnetworks.com>
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	roopa <roopa@cumulusnetworks.com>, Cong Wang <cwang@twopensource.com>
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
Changelog v2:
* remove another now unnecessary -ENOENT initialization
* consistently initialize to -EINVAL, allowing to shorten two switch-case=
s

 net/bridge/br_multicast.c |   26 +++-----------------------
 1 file changed, 3 insertions(+), 23 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2d69d5c..9955fa4 100644
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
@@ -1786,14 +1784,8 @@ int br_multicast_set_router(struct net_bridge *br,=
 unsigned long val)
 	case 1:
 		br->multicast_router =3D val;
 		err =3D 0;
-		break;
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
@@ -1802,11 +1794,9 @@ unlock:
 int br_multicast_set_port_router(struct net_bridge_port *p, unsigned lon=
g val)
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
@@ -1827,14 +1817,8 @@ int br_multicast_set_port_router(struct net_bridge=
_port *p, unsigned long val)
 			break;
=20
 		br_multicast_add_router(br, p);
-		break;
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
@@ -1939,15 +1923,11 @@ unlock:
=20
 int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val)
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
