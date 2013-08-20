From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [net PATCH] bridge: Use the correct bit length for bitmap functions
 in the VLAN code
Date: Tue, 20 Aug 2013 17:10:18 +0900
Message-ID: <1376986218.5740.9.camel@ubuntu-vm-makita>
References: <1376986060.5740.7.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:45360 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab3HTJEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 05:04:49 -0400
In-Reply-To: <1376986060.5740.7.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VLAN code needs to know the length of the per-port VLAN bitmap to
perform its most basic operations (retrieving VLAN informations, removing
VLANs, forwarding database manipulation, etc). Unfortunately, in the
current implementation we are using a macro that indicates the bitmap
size in longs in places where the size in bits is expected, which in
some cases can cause what appear to be random failures.
Use the correct macro.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_fdb.c     | 10 +++++-----
 net/bridge/br_netlink.c |  4 ++--
 net/bridge/br_vlan.c    |  4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 60aca91..ffd5874 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -161,7 +161,7 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	if (!pv)
 		return;
 
-	for_each_set_bit_from(vid, pv->vlan_bitmap, BR_VLAN_BITMAP_LEN) {
+	for_each_set_bit_from(vid, pv->vlan_bitmap, VLAN_N_VID) {
 		f = __br_fdb_get(br, br->dev->dev_addr, vid);
 		if (f && f->is_local && !f->dst)
 			fdb_delete(br, f);
@@ -730,7 +730,7 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		/* VID was specified, so use it. */
 		err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
 	} else {
-		if (!pv || bitmap_empty(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN)) {
+		if (!pv || bitmap_empty(pv->vlan_bitmap, VLAN_N_VID)) {
 			err = __br_fdb_add(ndm, p, addr, nlh_flags, 0);
 			goto out;
 		}
@@ -739,7 +739,7 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		 * specify a VLAN.  To be nice, add/update entry for every
 		 * vlan on this port.
 		 */
-		for_each_set_bit(vid, pv->vlan_bitmap, BR_VLAN_BITMAP_LEN) {
+		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
 			err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
 			if (err)
 				goto out;
@@ -817,7 +817,7 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 
 		err = __br_fdb_delete(p, addr, vid);
 	} else {
-		if (!pv || bitmap_empty(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN)) {
+		if (!pv || bitmap_empty(pv->vlan_bitmap, VLAN_N_VID)) {
 			err = __br_fdb_delete(p, addr, 0);
 			goto out;
 		}
@@ -827,7 +827,7 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 		 * vlan on this port.
 		 */
 		err = -ENOENT;
-		for_each_set_bit(vid, pv->vlan_bitmap, BR_VLAN_BITMAP_LEN) {
+		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
 			err &= __br_fdb_delete(p, addr, vid);
 		}
 	}
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 1fc30ab..b9259ef 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -132,7 +132,7 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 		else
 			pv = br_get_vlan_info(br);
 
-		if (!pv || bitmap_empty(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN))
+		if (!pv || bitmap_empty(pv->vlan_bitmap, VLAN_N_VID))
 			goto done;
 
 		af = nla_nest_start(skb, IFLA_AF_SPEC);
@@ -140,7 +140,7 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 			goto nla_put_failure;
 
 		pvid = br_get_pvid(pv);
-		for_each_set_bit(vid, pv->vlan_bitmap, BR_VLAN_BITMAP_LEN) {
+		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
 			vinfo.vid = vid;
 			vinfo.flags = 0;
 			if (vid == pvid)
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index bd58b45..9a9ffe7 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -108,7 +108,7 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 
 	clear_bit(vid, v->vlan_bitmap);
 	v->num_vlans--;
-	if (bitmap_empty(v->vlan_bitmap, BR_VLAN_BITMAP_LEN)) {
+	if (bitmap_empty(v->vlan_bitmap, VLAN_N_VID)) {
 		if (v->port_idx)
 			rcu_assign_pointer(v->parent.port->vlan_info, NULL);
 		else
@@ -122,7 +122,7 @@ static void __vlan_flush(struct net_port_vlans *v)
 {
 	smp_wmb();
 	v->pvid = 0;
-	bitmap_zero(v->vlan_bitmap, BR_VLAN_BITMAP_LEN);
+	bitmap_zero(v->vlan_bitmap, VLAN_N_VID);
 	if (v->port_idx)
 		rcu_assign_pointer(v->parent.port->vlan_info, NULL);
 	else
-- 
1.8.1.2
