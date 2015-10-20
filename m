From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net 1/4] openvswitch: Reject ct_state masks for unknown bits
Date: Mon, 19 Oct 2015 19:18:57 -0700
Message-ID: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
Cc: tgraf@suug.ch, jrajahalme@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36186 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbbJTCTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 22:19:08 -0400
Received: by pacfv9 with SMTP id fv9so4999486pac.3
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 19:19:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, 0-bits are generated in ct_state where the bit position is
undefined, and matches are accepted on these bit-positions. If userspace
requests to match the 0-value for this bit then it may expect only a
subset of traffic to match this value, whereas currently all packets
will have this bit set to 0. Fix this by rejecting such masks.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
v2: Remove extraneous ovs_ct_supported() function declaration.
    Acked.
v3: Acked.
---
 net/openvswitch/conntrack.h    | 16 +++++-----------
 net/openvswitch/flow_netlink.c |  5 ++++-
 2 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index da8714942c95..82e0dfc66028 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -35,12 +35,9 @@ void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key);
 int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb);
 void ovs_ct_free_action(const struct nlattr *a);
 
-static inline bool ovs_ct_state_supported(u32 state)
-{
-	return !(state & ~(OVS_CS_F_NEW | OVS_CS_F_ESTABLISHED |
-			 OVS_CS_F_RELATED | OVS_CS_F_REPLY_DIR |
-			 OVS_CS_F_INVALID | OVS_CS_F_TRACKED));
-}
+#define CT_SUPPORTED_MASK (OVS_CS_F_NEW | OVS_CS_F_ESTABLISHED | \
+			   OVS_CS_F_RELATED | OVS_CS_F_REPLY_DIR | \
+			   OVS_CS_F_INVALID | OVS_CS_F_TRACKED)
 #else
 #include <linux/errno.h>
 
@@ -53,11 +50,6 @@ static inline bool ovs_ct_verify(struct net *net, int attr)
 	return false;
 }
 
-static inline bool ovs_ct_state_supported(u32 state)
-{
-	return false;
-}
-
 static inline int ovs_ct_copy_action(struct net *net, const struct nlattr *nla,
 				     const struct sw_flow_key *key,
 				     struct sw_flow_actions **acts, bool log)
@@ -94,5 +86,7 @@ static inline int ovs_ct_put_key(const struct sw_flow_key *key,
 }
 
 static inline void ovs_ct_free_action(const struct nlattr *a) { }
+
+#define CT_SUPPORTED_MASK 0
 #endif /* CONFIG_NF_CONNTRACK */
 #endif /* ovs_conntrack.h */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 171a691f1c32..bd710bc37469 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -816,7 +816,7 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 	    ovs_ct_verify(net, OVS_KEY_ATTR_CT_STATE)) {
 		u32 ct_state = nla_get_u32(a[OVS_KEY_ATTR_CT_STATE]);
 
-		if (!is_mask && !ovs_ct_state_supported(ct_state)) {
+		if (ct_state & ~CT_SUPPORTED_MASK) {
 			OVS_NLERR(log, "ct_state flags %08x unsupported",
 				  ct_state);
 			return -EINVAL;
@@ -1099,6 +1099,9 @@ static void nlattr_set(struct nlattr *attr, u8 val,
 		} else {
 			memset(nla_data(nla), val, nla_len(nla));
 		}
+
+		if (nla_type(nla) == OVS_KEY_ATTR_CT_STATE)
+			*(u32 *)nla_data(nla) &= CT_SUPPORTED_MASK;
 	}
 }
 
-- 
2.1.4
