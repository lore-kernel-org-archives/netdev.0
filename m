From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 02/20] bridge: netlink: export root id
Date: Sun,  4 Oct 2015 14:23:29 +0200
Message-ID: <1443961427-15085-3-git-send-email-razor@blackwall.org>
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

Add IFLA_BR_ROOT_ID and export br->designated_root via netlink. For this
purpose add struct ifla_bridge_id that would represent struct bridge_id.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 6 ++++++
 net/bridge/br_netlink.c      | 9 ++++++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index f7f480613555..03814371df44 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -233,11 +233,17 @@ enum {
 	IFLA_BR_VLAN_FILTERING,
 	IFLA_BR_VLAN_PROTOCOL,
 	IFLA_BR_GROUP_FWD_MASK,
+	IFLA_BR_ROOT_ID,
 	__IFLA_BR_MAX,
 };
 
 #define IFLA_BR_MAX	(__IFLA_BR_MAX - 1)
 
+struct ifla_bridge_id {
+	__u8	prio[2];
+	__u8	addr[6]; /* ETH_ALEN */
+};
+
 enum {
 	BRIDGE_MODE_UNSPEC,
 	BRIDGE_MODE_HAIRPIN,
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 39b201a2bc12..7a3692469db6 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -854,6 +854,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(__be16)) +	/* IFLA_BR_VLAN_PROTOCOL */
 #endif
 	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_GROUP_FWD_MASK */
+	       nla_total_size(sizeof(struct ifla_bridge_id)) +   /* IFLA_BR_ROOT_ID */
 	       0;
 }
 
@@ -868,6 +869,11 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	u16 priority = (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1];
 	u16 group_fwd_mask = br->group_fwd_mask;
 	u8 vlan_enabled = br_vlan_enabled(br);
+	struct ifla_bridge_id root_id;
+
+	memset(&root_id, 0, sizeof(root_id));
+	memcpy(root_id.prio, br->designated_root.prio, sizeof(root_id.prio));
+	memcpy(root_id.addr, br->designated_root.addr, sizeof(root_id.addr));
 
 	if (nla_put_u32(skb, IFLA_BR_FORWARD_DELAY, forward_delay) ||
 	    nla_put_u32(skb, IFLA_BR_HELLO_TIME, hello_time) ||
@@ -876,7 +882,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u32(skb, IFLA_BR_STP_STATE, stp_enabled) ||
 	    nla_put_u16(skb, IFLA_BR_PRIORITY, priority) ||
 	    nla_put_u8(skb, IFLA_BR_VLAN_FILTERING, vlan_enabled) ||
-	    nla_put_u16(skb, IFLA_BR_GROUP_FWD_MASK, group_fwd_mask))
+	    nla_put_u16(skb, IFLA_BR_GROUP_FWD_MASK, group_fwd_mask) ||
+	    nla_put(skb, IFLA_BR_ROOT_ID, sizeof(root_id), &root_id))
 		return -EMSGSIZE;
 
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-- 
2.4.3
