From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net] bridge: Fix inability to add non-vlan fdb entry
Date: Mon,  9 Feb 2015 20:16:17 +0900
Message-ID: <1423480577-9473-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
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

Bridge's default_pvid adds a vid by default, by which we cannot add a
non-vlan fdb entry by default, because br_fdb_add() adds fdb entries for
all vlans instead of a non-vlan one when any vlan is configured.

 # ip link add br0 type bridge
 # ip link set eth0 master br0
 # bridge fdb add 12:34:56:78:90:ab dev eth0 master temp
 # bridge fdb show brport eth0 | grep 12:34:56:78:90:ab
 12:34:56:78:90:ab dev eth0 vlan 1 static

We expect a non-vlan fdb entry as well as vlan 1:
 12:34:56:78:90:ab dev eth0 static

To fix this, we need to insert a non-vlan fdb entry if vlan is not
specified, even when any vlan is configured.

Fixes: 5be5a2df40f0 ("bridge: Add filtering support for default_pvid")
Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_fdb.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index cc36e59..c041f99 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -840,10 +840,9 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		/* VID was specified, so use it. */
 		err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
 	} else {
-		if (!pv || bitmap_empty(pv->vlan_bitmap, VLAN_N_VID)) {
-			err = __br_fdb_add(ndm, p, addr, nlh_flags, 0);
+		err = __br_fdb_add(ndm, p, addr, nlh_flags, 0);
+		if (err || !pv)
 			goto out;
-		}
 
 		/* We have vlans configured on this port and user didn't
 		 * specify a VLAN.  To be nice, add/update entry for every
@@ -911,16 +910,15 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 
 		err = __br_fdb_delete(p, addr, vid);
 	} else {
-		if (!pv || bitmap_empty(pv->vlan_bitmap, VLAN_N_VID)) {
-			err = __br_fdb_delete(p, addr, 0);
+		err = -ENOENT;
+		err &= __br_fdb_delete(p, addr, 0);
+		if (!pv)
 			goto out;
-		}
 
 		/* We have vlans configured on this port and user didn't
 		 * specify a VLAN.  To be nice, add/update entry for every
 		 * vlan on this port.
 		 */
-		err = -ENOENT;
 		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
 			err &= __br_fdb_delete(p, addr, vid);
 		}
-- 
1.8.1.2
