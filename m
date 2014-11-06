From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 06/14] openvswitch: refactor do_output() to move NULL check out of fast path
Date: Thu,  6 Nov 2014 01:19:19 -0800
Message-ID: <1415265559-1698-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:56810 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751934AbaKFJTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 04:19:21 -0500
Received: by mail-pa0-f50.google.com with SMTP id eu11so875975pac.37
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 01:19:21 -0800 (PST)
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
