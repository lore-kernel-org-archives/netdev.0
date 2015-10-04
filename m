From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 03/20] bridge: netlink: export bridge id
Date: Sun,  4 Oct 2015 14:23:30 +0200
Message-ID: <1443961427-15085-4-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, shm@cumulusnetworks.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
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

Add IFLA_BR_BRIDGE_ID and export br->bridge_id via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 1 +
 net/bridge/br_netlink.c      | 9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 03814371df44..748495438a8b 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -234,6 +234,7 @@ enum {
 	IFLA_BR_VLAN_PROTOCOL,
 	IFLA_BR_GROUP_FWD_MASK,
 	IFLA_BR_ROOT_ID,
+	IFLA_BR_BRIDGE_ID,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 7a3692469db6..a63f944a7f12 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -855,6 +855,7 @@ static size_t br_get_size(const struct net_device *brdev)
 #endif
 	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_GROUP_FWD_MASK */
 	       nla_total_size(sizeof(struct ifla_bridge_id)) +   /* IFLA_BR_ROOT_ID */
+	       nla_total_size(sizeof(struct ifla_bridge_id)) +   /* IFLA_BR_BRIDGE_ID */
 	       0;
 }
 
@@ -869,11 +870,14 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	u16 priority = (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1];
 	u16 group_fwd_mask = br->group_fwd_mask;
 	u8 vlan_enabled = br_vlan_enabled(br);
-	struct ifla_bridge_id root_id;
+	struct ifla_bridge_id root_id, bridge_id;
 
+	memset(&bridge_id, 0, sizeof(bridge_id));
 	memset(&root_id, 0, sizeof(root_id));
 	memcpy(root_id.prio, br->designated_root.prio, sizeof(root_id.prio));
 	memcpy(root_id.addr, br->designated_root.addr, sizeof(root_id.addr));
+	memcpy(bridge_id.prio, br->bridge_id.prio, sizeof(bridge_id.prio));
+	memcpy(bridge_id.addr, br->bridge_id.addr, sizeof(bridge_id.addr));
 
 	if (nla_put_u32(skb, IFLA_BR_FORWARD_DELAY, forward_delay) ||
 	    nla_put_u32(skb, IFLA_BR_HELLO_TIME, hello_time) ||
@@ -883,7 +887,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u16(skb, IFLA_BR_PRIORITY, priority) ||
 	    nla_put_u8(skb, IFLA_BR_VLAN_FILTERING, vlan_enabled) ||
 	    nla_put_u16(skb, IFLA_BR_GROUP_FWD_MASK, group_fwd_mask) ||
-	    nla_put(skb, IFLA_BR_ROOT_ID, sizeof(root_id), &root_id))
+	    nla_put(skb, IFLA_BR_ROOT_ID, sizeof(root_id), &root_id) ||
+	    nla_put(skb, IFLA_BR_BRIDGE_ID, sizeof(bridge_id), &bridge_id))
 		return -EMSGSIZE;
 
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-- 
2.4.3
