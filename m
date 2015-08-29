From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net-next] openvswitch: Fix conntrack compilation without mark.
Date: Fri, 28 Aug 2015 19:22:11 -0700
Message-ID: <1440814931-29059-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, simon.horman@netronome.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix build with !CONFIG_NF_CONNTRACK_MARK && CONFIG_OPENVSWITCH_CONNTRACK

Fixes: 182e304 ("openvswitch: Allow matching on conntrack mark")
Reported-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/conntrack.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 886bd27..e8e524a 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -100,6 +100,15 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info ctinfo)
 	return ct_state;
 }
 
+static u32 ovs_ct_get_mark(const struct nf_conn *ct)
+{
+#if IS_ENABLED(CONFIG_NF_CONNTRACK_MARK)
+	return ct ? ct->mark : 0;
+#else
+	return 0;
+#endif
+}
+
 static void ovs_ct_get_label(const struct nf_conn *ct,
 			     struct ovs_key_ct_label *label)
 {
@@ -124,7 +133,7 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 {
 	key->ct.state = state;
 	key->ct.zone = zone->id;
-	key->ct.mark = ct ? ct->mark : 0;
+	key->ct.mark = ovs_ct_get_mark(ct);
 	ovs_ct_get_label(ct, &key->ct.label);
 }
 
@@ -180,12 +189,11 @@ int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
 static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
 			   u32 ct_mark, u32 mask)
 {
+#if IS_ENABLED(CONFIG_NF_CONNTRACK_MARK)
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
 	u32 new_mark;
 
-	if (!IS_ENABLED(CONFIG_NF_CONNTRACK_MARK))
-		return -ENOTSUPP;
 
 	/* The connection could be invalid, in which case set_mark is no-op. */
 	ct = nf_ct_get(skb, &ctinfo);
@@ -200,6 +208,9 @@ static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
 	}
 
 	return 0;
+#else
+	return -ENOTSUPP;
+#endif
 }
 
 static int ovs_ct_set_label(struct sk_buff *skb, struct sw_flow_key *key,
-- 
2.1.4
