From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv4 net 2/6] openvswitch: Fix skb leak in ovs_fragment()
Date: Tue,  6 Oct 2015 10:59:57 -0700
Message-ID: <1444154401-18029-3-git-send-email-joestringer@nicira.com>
References: <1444154401-18029-1-git-send-email-joestringer@nicira.com>
Cc: davem@davemloft.net, pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34658 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727AbbJFSAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 14:00:30 -0400
Received: by padhy16 with SMTP id hy16so76642097pad.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 11:00:30 -0700 (PDT)
In-Reply-To: <1444154401-18029-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If ovs_fragment() was unable to fragment the skb due to an L2 header
that exceeds the supported length, skbs would be leaked. Fix the bug.

Fixes: 7f8a436eaa2c "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
v4: Extend "fixes" hash in commit message.
v3: Acked.
v2: Drop if condition by returning in success case.
---
 net/openvswitch/actions.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e23a61cc3d5c..4cb93f92d6be 100644
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
