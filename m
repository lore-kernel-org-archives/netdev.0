From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net] bridge: Don't insert unnecessary local fdb
	entry on changing mac address
Date: Tue,  7 Jun 2016 19:14:17 +0900
Message-ID: <1465294457-2785-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S. Miller" <davem@davemloft.net>,
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

The missing br_vlan_should_use() test caused creation of an unneeded
local fdb entry on changing mac address of a bridge device when there is
a vlan which is configured on a bridge port but not on the bridge
device.

Fixes: 2594e9064a57 ("bridge: vlan: add per-vlan struct and move to rhashtables")
Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_fdb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index dcea4f4..c18080a 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -279,6 +279,8 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	 * change from under us.
 	 */
 	list_for_each_entry(v, &vg->vlan_list, vlist) {
+		if (!br_vlan_should_use(v))
+			continue;
 		f = __br_fdb_get(br, br->dev->dev_addr, v->vid);
 		if (f && f->is_local && !f->dst)
 			fdb_delete_local(br, NULL, f);
-- 
1.8.3.1
