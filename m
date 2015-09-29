From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 3/7] openvswitch: Fix skb leak in ovs_fragment()
Date: Tue, 29 Sep 2015 15:39:36 -0700
Message-ID: <1443566380-22640-4-git-send-email-joestringer@nicira.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35546 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbbI2WkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:40:03 -0400
Received: by pacfv12 with SMTP id fv12so18820905pac.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:40:02 -0700 (PDT)
In-Reply-To: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If ovs_fragment() was unable to fragment the skb due to an L2 header
that exceeds the supported length, skbs would be leaked. Fix the bug.

Fixes: 7f8a436 "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/actions.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e23a61c..e1afbd1 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -684,7 +684,7 @@ static void ovs_fragment(struct vport *vport, struct sk_buff *skb, u16 mru,
 {
 	if (skb_network_offset(skb) > MAX_L2_LEN) {
 		OVS_NLERR(1, "L2 header too long to fragment");
-		return;
+		goto out;
 	}
 
 	if (ethertype == htons(ETH_P_IP)) {
@@ -708,8 +708,7 @@ static void ovs_fragment(struct vport *vport, struct sk_buff *skb, u16 mru,
 		struct rt6_info ovs_rt;
 
 		if (!v6ops) {
-			kfree_skb(skb);
-			return;
+			goto out;
 		}
 
 		prepare_frag(vport, skb);
@@ -728,8 +727,14 @@ static void ovs_fragment(struct vport *vport, struct sk_buff *skb, u16 mru,
 		WARN_ONCE(1, "Failed fragment ->%s: eth=%04x, MRU=%d, MTU=%d.",
 			  ovs_vport_name(vport), ntohs(ethertype), mru,
 			  vport->dev->mtu);
-		kfree_skb(skb);
+		goto out;
 	}
+
+	skb = NULL;
+
+out:
+	if (skb)
+		kfree_skb(skb);
 }
 
 static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
-- 
2.1.4
