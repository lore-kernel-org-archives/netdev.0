From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 5/7] openvswitch: Reject ct_state unsupported bits
Date: Tue, 29 Sep 2015 15:39:38 -0700
Message-ID: <1443566380-22640-6-git-send-email-joestringer@nicira.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previously, if userspace specified ct_state bits in the flow key which
are currently undefined (and therefore unsupported), then they would be
ignored. This could cause unexpected behaviour in future if userspace is
extended to support additional bits but attempts to communicate with the
current version of the kernel. This patch rectifies the situation by
rejecting such ct_state bits.

Fixes: 7f8a436 "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/conntrack.h    | 12 ++++++++++++
 net/openvswitch/flow_netlink.c |  6 ++++++
 2 files changed, 18 insertions(+)

diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index 43f5dd7..c658d95 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -34,6 +34,13 @@ int ovs_ct_execute(struct net *, struct sk_buff *, struct sw_flow_key *,
 void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key);
 int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb);
 void ovs_ct_free_action(const struct nlattr *a);
+
+static inline bool ovs_ct_state_supported(u8 state)
+{
+	return !(state & ~(OVS_CS_F_NEW | OVS_CS_F_ESTABLISHED |
+			 OVS_CS_F_RELATED | OVS_CS_F_REPLY_DIR |
+			 OVS_CS_F_INVALID | OVS_CS_F_TRACKED));
+}
 #else
 #include <linux/errno.h>
 
@@ -46,6 +53,11 @@ static inline bool ovs_ct_verify(struct net *net, int attr)
 	return false;
 }
 
+static inline bool ovs_ct_state_supported(u8 state)
+{
+	return false;
+}
+
 static inline int ovs_ct_copy_action(struct net *net, const struct nlattr *nla,
 				     const struct sw_flow_key *key,
 				     struct sw_flow_actions **acts, bool log)
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index ea82cd5..c4917c9 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -816,6 +816,12 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 	    ovs_ct_verify(net, OVS_KEY_ATTR_CT_STATE)) {
 		u8 ct_state = nla_get_u8(a[OVS_KEY_ATTR_CT_STATE]);
 
+		if (!is_mask && !ovs_ct_state_supported(ct_state)) {
+			OVS_NLERR(log, "ct_state flags %02x unsupported",
+				  ct_state);
+			return -EINVAL;
+		}
+
 		SW_FLOW_KEY_PUT(match, ct.state, ct_state, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_STATE);
 	}
-- 
2.1.4
