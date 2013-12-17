From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net v2 9/9] bridge: Prevent possible race condition in br_fdb_change_mac_address
Date: Tue, 17 Dec 2013 21:03:41 +0900
Message-ID: <1387281821-21342-10-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:54902 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab3LQME0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 07:04:26 -0500
In-Reply-To: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_fdb_change_mac_address() calls fdb_insert()/fdb_delete() without
br->hash_lock.

These hash list updates are racy with br_fdb_update()/br_fdb_cleanup().

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_fdb.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 38cd29d..05fb8da 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -191,6 +191,8 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	struct net_port_vlans *pv;
 	u16 vid = 0;
 
+	spin_lock_bh(&br->hash_lock);
+
 	/* If old entry was unassociated with any port, then delete it. */
 	f = __br_fdb_get(br, br->dev->dev_addr, 0);
 	if (f && f->is_local && !f->dst)
@@ -204,7 +206,7 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	 */
 	pv = br_get_vlan_info(br);
 	if (!pv)
-		return;
+		goto out;
 
 	for_each_set_bit_from(vid, pv->vlan_bitmap, VLAN_N_VID) {
 		f = __br_fdb_get(br, br->dev->dev_addr, vid);
@@ -212,6 +214,8 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 			fdb_delete_local(br, NULL, f);
 		fdb_insert(br, NULL, newaddr, vid);
 	}
+out:
+	spin_unlock_bh(&br->hash_lock);
 }
 
 void br_fdb_cleanup(unsigned long _data)
-- 
1.8.1.2
