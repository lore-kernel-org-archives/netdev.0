From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 3/7] openvswitch: Fix skb leak in ovs_fragment()
Date: Thu,  1 Oct 2015 13:53:26 -0700
Message-ID: <1443732810-38746-4-git-send-email-joestringer@nicira.com>
References: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, jesse@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If ovs_fragment() was unable to fragment the skb due to an L2 header
that exceeds the supported length, skbs would be leaked. Fix the bug.

Fixes: 7f8a436 "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2: Drop if condition, return in success case.
---
 net/openvswitch/actions.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e23a61c..4cb93f9 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -684,7 +684,7 @@ static void ovs_fragment(struct vport *vport, struct sk_buff *skb, u16 mru,
 {
 	if (skb_network_offset(skb) > MAX_L2_LEN) {
 		OVS_NLERR(1, "L2 header too long to fragment");
-		return;
+		goto err;
 	}
 
 	if (ethertype == htons(ETH_P_IP)) {
@@ -708,8 +708,7 @@ static void ovs_fragment(struct vport *vport, struct sk_buff *skb, u16 mru,
 		struct rt6_info ovs_rt;
 
 		if (!v6ops) {
-			kfree_skb(skb);
-			return;
+			goto err;
 		}
 
 		prepare_frag(vport, skb);
@@ -728,8 +727,12 @@ static void ovs_fragment(struct vport *vport, struct sk_buff *skb, u16 mru,
 		WARN_ONCE(1, "Failed fragment ->%s: eth=%04x, MRU=%d, MTU=%d.",
 			  ovs_vport_name(vport), ntohs(ethertype), mru,
 			  vport->dev->mtu);
-		kfree_skb(skb);
+		goto err;
 	}
+
+	return;
+err:
+	kfree_skb(skb);
 }
 
 static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
-- 
2.1.4
