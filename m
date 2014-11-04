From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 06/14] openvswitch: refactor do_output() to move NULL check out of fast path
Date: Mon,  3 Nov 2014 22:01:20 -0800
Message-ID: <1415080880-1808-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog001.obsmtp.com ([74.125.150.42]:58701 "HELO
	na6sys009bog001.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752091AbaKEUBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:01:39 -0500
Received: by mail-pd0-f170.google.com with SMTP id z10so1375548pdj.15
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 12:01:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

skb_clone() NULL check is implemented in do_output(), as past of the
common (fast) path. Refactoring so that NULL check is done in the
slow path, immediately after skb_clone() is called.

Besides optimization, this change also improves code readability by
making the skb_clone() NULL check consistent within OVS datapath
module.

Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 930b1b6..9fd33c0 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -551,21 +551,14 @@ static int set_sctp(struct sk_buff *skb,
 	return 0;
 }
 
-static int do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
+static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
 {
-	struct vport *vport;
+	struct vport *vport = ovs_vport_rcu(dp, out_port);
 
-	if (unlikely(!skb))
-		return -ENOMEM;
-
-	vport = ovs_vport_rcu(dp, out_port);
-	if (unlikely(!vport)) {
+	if (likely(vport))
+		ovs_vport_send(vport, skb);
+	else
 		kfree_skb(skb);
-		return -ENODEV;
-	}
-
-	ovs_vport_send(vport, skb);
-	return 0;
 }
 
 static int output_userspace(struct datapath *dp, struct sk_buff *skb,
@@ -768,8 +761,12 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	     a = nla_next(a, &rem)) {
 		int err = 0;
 
-		if (prev_port != -1) {
-			do_output(dp, skb_clone(skb, GFP_ATOMIC), prev_port);
+		if (unlikely(prev_port != -1)) {
+			struct sk_buff *out_skb = skb_clone(skb, GFP_ATOMIC);
+
+			if (out_skb)
+				do_output(dp, out_skb, prev_port);
+
 			prev_port = -1;
 		}
 
-- 
1.9.3
