From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v2] bridge: netlink: add support for
	vlan_filtering attribute
Date: Fri,  7 Aug 2015 19:40:45 +0300
Message-ID: <1438965645-7841-1-git-send-email-razor@blackwall.org>
References: <1438964658-2904-1-git-send-email-razor@blackwall.org>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1438964658-2904-1-git-send-email-razor@blackwall.org>
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

This patch adds the ability to toggle the vlan filtering support via
netlink. Since we're already running with rtnl in .changelink() we don't
need to take any additional locks.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: return EOPNOTSUPP when vlan filtering isn't configured and can't be
    toggled

I'll post the iproute2 patch if this one gets accepted.

 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 14 +++++++++++++-
 net/bridge/br_private.h      |  7 +++++++
 net/bridge/br_vlan.c         | 18 ++++++++++++------
 4 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ea047480a1f0..7531815bf88a 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -230,6 +230,7 @@ enum {
 	IFLA_BR_AGEING_TIME,
 	IFLA_BR_STP_STATE,
 	IFLA_BR_PRIORITY,
+	IFLA_BR_VLAN_FILTERING,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 91a2e08c2bb8..6eb683d8e0c5 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -724,6 +724,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_AGEING_TIME] = { .type = NLA_U32 },
 	[IFLA_BR_STP_STATE] = { .type = NLA_U32 },
 	[IFLA_BR_PRIORITY] = { .type = NLA_U16 },
+	[IFLA_BR_VLAN_FILTERING] = { .type = NLA_U8 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -771,6 +772,14 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 		br_stp_set_bridge_priority(br, priority);
 	}
 
+	if (data[IFLA_BR_VLAN_FILTERING]) {
+		u8 vlan_filter = nla_get_u8(data[IFLA_BR_VLAN_FILTERING]);
+
+		err = __br_vlan_filter_toggle(br, vlan_filter);
+		if (err)
+			return err;
+	}
+
 	return 0;
 }
 
@@ -782,6 +791,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_AGEING_TIME */
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_STP_STATE */
 	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_PRIORITY */
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_VLAN_FILTERING */
 	       0;
 }
 
@@ -794,13 +804,15 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	u32 ageing_time = jiffies_to_clock_t(br->ageing_time);
 	u32 stp_enabled = br->stp_enabled;
 	u16 priority = (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1];
+	u8 vlan_enabled = br_vlan_enabled(br);
 
 	if (nla_put_u32(skb, IFLA_BR_FORWARD_DELAY, forward_delay) ||
 	    nla_put_u32(skb, IFLA_BR_HELLO_TIME, hello_time) ||
 	    nla_put_u32(skb, IFLA_BR_MAX_AGE, age_time) ||
 	    nla_put_u32(skb, IFLA_BR_AGEING_TIME, ageing_time) ||
 	    nla_put_u32(skb, IFLA_BR_STP_STATE, stp_enabled) ||
-	    nla_put_u16(skb, IFLA_BR_PRIORITY, priority))
+	    nla_put_u16(skb, IFLA_BR_PRIORITY, priority) ||
+	    nla_put_u8(skb, IFLA_BR_VLAN_FILTERING, vlan_enabled))
 		return -EMSGSIZE;
 
 	return 0;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index e2cb359f9dd3..3d95647039d0 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -614,6 +614,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid);
 void br_vlan_flush(struct net_bridge *br);
 bool br_vlan_find(struct net_bridge *br, u16 vid);
 void br_recalculate_fwd_mask(struct net_bridge *br);
+int __br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
 int br_vlan_set_proto(struct net_bridge *br, unsigned long val);
 int br_vlan_init(struct net_bridge *br);
@@ -771,6 +772,12 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 {
 	return 0;
 }
+
+static inline int __br_vlan_filter_toggle(struct net_bridge *br,
+					  unsigned long val)
+{
+	return -EOPNOTSUPP;
+}
 #endif
 
 struct nf_br_ops {
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 0d41f81838ff..3cef6892c0bb 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -468,21 +468,27 @@ void br_recalculate_fwd_mask(struct net_bridge *br)
 					      ~(1u << br->group_addr[5]);
 }
 
-int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
+int __br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
 {
-	if (!rtnl_trylock())
-		return restart_syscall();
-
 	if (br->vlan_enabled == val)
-		goto unlock;
+		return 0;
 
 	br->vlan_enabled = val;
 	br_manage_promisc(br);
 	recalculate_group_addr(br);
 	br_recalculate_fwd_mask(br);
 
-unlock:
+	return 0;
+}
+
+int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
+{
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	__br_vlan_filter_toggle(br, val);
 	rtnl_unlock();
+
 	return 0;
 }
 
-- 
2.4.3
