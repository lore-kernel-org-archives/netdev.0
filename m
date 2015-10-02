From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 1/4] bridge: vlan: use rcu list for the
	ordered vlan list
Date: Fri,  2 Oct 2015 15:05:10 +0200
Message-ID: <1443791113-12738-2-git-send-email-razor@blackwall.org>
References: <1443791113-12738-1-git-send-email-razor@blackwall.org>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, vyasevich@gmail.com
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1443791113-12738-1-git-send-email-razor@blackwall.org>
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

When I did the conversion to rhashtable I missed the required locking of
one important user of the vlan list - br_get_link_af_size_filtered()
which is called:
br_ifinfo_notify() -> br_nlmsg_size() -> br_get_link_af_size_filtered()
and the notifications can be sent without holding rtnl. Before this
conversion the function relied on using rcu and since we already use rcu to
destroy the vlans, we can simply migrate the list to use the rcu helpers.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_netlink.c | 10 ++++++++--
 net/bridge/br_vlan.c    |  4 ++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index c64dcad11662..c3186198d46d 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -34,7 +34,7 @@ static int __get_num_vlan_infos(struct net_bridge_vlan_group *vg,
 
 	pvid = br_get_pvid(vg);
 	/* Count number of vlan infos */
-	list_for_each_entry(v, &vg->vlan_list, vlist) {
+	list_for_each_entry_rcu(v, &vg->vlan_list, vlist) {
 		flags = 0;
 		/* only a context, bridge vlan not activated */
 		if (!br_vlan_should_use(v))
@@ -76,13 +76,19 @@ initvars:
 static int br_get_num_vlan_infos(struct net_bridge_vlan_group *vg,
 				 u32 filter_mask)
 {
+	int num_vlans;
+
 	if (!vg)
 		return 0;
 
 	if (filter_mask & RTEXT_FILTER_BRVLAN)
 		return vg->num_vlans;
 
-	return __get_num_vlan_infos(vg, filter_mask);
+	rcu_read_lock();
+	num_vlans = __get_num_vlan_infos(vg, filter_mask);
+	rcu_read_unlock();
+
+	return num_vlans;
 }
 
 static size_t br_get_link_af_size_filtered(const struct net_device *dev,
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 75214a51cf0e..106d3f890b73 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -110,12 +110,12 @@ static void __vlan_add_list(struct net_bridge_vlan *v)
 		else
 			break;
 	}
-	list_add(&v->vlist, hpos);
+	list_add_rcu(&v->vlist, hpos);
 }
 
 static void __vlan_del_list(struct net_bridge_vlan *v)
 {
-	list_del(&v->vlist);
+	list_del_rcu(&v->vlist);
 }
 
 static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
-- 
2.4.3
