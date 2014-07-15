From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 10/11] openvswitch: Add skb_clone NULL check in the recirc action.
Date: Tue, 15 Jul 2014 10:15:39 -0700
Message-ID: <1405444539-17145-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:36189 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758763AbaGORPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 13:15:43 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so4067486pdj.36
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 10:15:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

The main change is to fix a bug where the NULL check after skb clone()
call is missing.  The fix is to return 0 whenever skb_clone()
failed to create a clone so that we can continue with rest of actions.

Reported-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 2b11473..5920512 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -624,10 +624,13 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 				break;
 			}
 
-			if (!last_action(a, rem))
+			if (!last_action(a, rem)) {
 				recirc_skb = skb_clone(skb, GFP_ATOMIC);
-			else
+				if (!recirc_skb)
+					return 0;
+			} else {
 				recirc_skb = skb;
+			}
 
 			__this_cpu_inc(net_xmit_recursion);
 			err = execute_recirc(dp, recirc_skb, a);
-- 
1.9.3
