From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] bridge: fdb: rearrange
	net_bridge_fdb_entry
Date: Thu, 27 Aug 2015 14:19:20 -0700
Message-ID: <1440710360-5390-1-git-send-email-razor@blackwall.org>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org, davem@davemloft.net
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

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

While looking into fixing the local entries scalability issue I noticed
that the structure is badly arranged because vlan_id would fall in a
second cache line while keeping rcu which is used only when deleting
in the first, so re-arrange the structure and push rcu to the end so we
can get 16 bytes which can be used for other fields (by pushing rcu
fully in the second 64 byte chunk). With this change all the core
necessary information when doing fdb lookups will be available in a
single cache line.

pahole before (note vlan_id):
struct net_bridge_fdb_entry {
	struct hlist_node          hlist;                /*     0    16 */
	struct net_bridge_port *   dst;                  /*    16     8 */
	struct callback_head       rcu;                  /*    24    16 */
	long unsigned int          updated;              /*    40     8 */
	long unsigned int          used;                 /*    48     8 */
	mac_addr                   addr;                 /*    56     6 */
	unsigned char              is_local:1;           /*    62: 7  1 */
	unsigned char              is_static:1;          /*    62: 6  1 */
	unsigned char              added_by_user:1;      /*    62: 5  1 */
	unsigned char              added_by_external_learn:1; /*    62: 4  1 */

	/* XXX 4 bits hole, try to pack */
	/* XXX 1 byte hole, try to pack */

	/* --- cacheline 1 boundary (64 bytes) --- */
	__u16                      vlan_id;              /*    64     2 */

	/* size: 72, cachelines: 2, members: 11 */
	/* sum members: 65, holes: 1, sum holes: 1 */
	/* bit holes: 1, sum bit holes: 4 bits */
	/* padding: 6 */
	/* last cacheline: 8 bytes */
}

pahole after (note vlan_id):
struct net_bridge_fdb_entry {
	struct hlist_node          hlist;                /*     0    16 */
	struct net_bridge_port *   dst;                  /*    16     8 */
	long unsigned int          updated;              /*    24     8 */
	long unsigned int          used;                 /*    32     8 */
	mac_addr                   addr;                 /*    40     6 */
	__u16                      vlan_id;              /*    46     2 */
	unsigned char              is_local:1;           /*    48: 7  1 */
	unsigned char              is_static:1;          /*    48: 6  1 */
	unsigned char              added_by_user:1;      /*    48: 5  1 */
	unsigned char              added_by_external_learn:1; /*    48: 4  1 */

	/* XXX 4 bits hole, try to pack */
	/* XXX 7 bytes hole, try to pack */

	struct callback_head       rcu;                  /*    56    16 */
	/* --- cacheline 1 boundary (64 bytes) was 8 bytes ago --- */

	/* size: 72, cachelines: 2, members: 11 */
	/* sum members: 65, holes: 1, sum holes: 7 */
	/* bit holes: 1, sum bit holes: 4 bits */
	/* last cacheline: 8 bytes */
}

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_private.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 3d95647039d0..8c97a22b1790 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -95,15 +95,15 @@ struct net_bridge_fdb_entry
 	struct hlist_node		hlist;
 	struct net_bridge_port		*dst;
 
-	struct rcu_head			rcu;
 	unsigned long			updated;
 	unsigned long			used;
 	mac_addr			addr;
+	__u16				vlan_id;
 	unsigned char			is_local:1,
 					is_static:1,
 					added_by_user:1,
 					added_by_external_learn:1;
-	__u16				vlan_id;
+	struct rcu_head			rcu;
 };
 
 struct net_bridge_port_group {
-- 
2.4.3
