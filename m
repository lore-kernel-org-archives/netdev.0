From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net 4/6] openvswitch: Reject ct_state unsupported bits
Date: Mon,  5 Oct 2015 15:23:17 -0700
Message-ID: <1444083799-57090-5-git-send-email-joestringer@nicira.com>
References: <1444083799-57090-1-git-send-email-joestringer@nicira.com>
Cc: davem@davemloft.net, pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34253 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbbJEWXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 18:23:30 -0400
Received: by padhy16 with SMTP id hy16so48484574pad.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 15:23:29 -0700 (PDT)
In-Reply-To: <1444083799-57090-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, if userspace specified ct_state bits in the flow key which
are currently undefined (and therefore unsupported), then they would be
ignored. This could cause unexpected behaviour in future if userspace is
extended to support additional bits but attempts to communicate with the
current version of the kernel. This patch rectifies the situation by
rejecting such ct_state bits.

Fixes: 7f8a436 "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
v3: No change.
v2: Acked.
---
 net/openvswitch/conntrack.h    | 12 ++++++++++++
 net/openvswitch/flow_netlink.c |  6 ++++++
 2 files changed, 18 insertions(+)

diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index 6bd603c6a031..d6eca8394254 100644
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
index a60e3b7684bc..d47b5c5c640e 100644
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
