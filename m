From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v3 08/11] openvswitch: Free skb(s) on recirculation error
Date: Wed, 16 Jul 2014 00:32:28 -0700
Message-ID: <1405495948-2163-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:52045 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S934044AbaGPHc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 03:32:28 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so772278pdj.2
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 00:32:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

This patch attempts to ensure that skb(s) are always freed (once)
if an error occurs in execute_recirc(). It does so in two ways:

1. Ensure that execute_recirc() always consimes skb passed to it.
   Specifically, free the skb if the call to ovs_flow_extract() fails.

2. Return from the recirc case in execute_recirc() whenever
   the skb has not been cloned immediately above.

This is only the case if the action is both the last action and the
keep_skb parameter of execute_recirc is not true.  As it is the last
action and the skb is consumed one way or another by execute_recirc() it
is correct to return here.  In particular this avoids the possibility of
the skb, which has been consumed by execute_recirc() from being freed.

Conversely if this is not the case then the skb has been cloned
and the clone has been consumed by execute_recirc().
This leads to three sub-cases:
* If execute_recirc() returned an error code then the original skb
  will be freed by the error handling code below the case statement in
  do_execute_actions().
* If this is not the last action then action processing will continue,
  using the original skb.
* If this is the last action then it must also be the case that keep_skb
  is true (otherwise the skb would not have been cloned). Thus
  do_execute_actions() will return without freeing the original skb.

Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 8875697..f131d69 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -529,8 +529,10 @@ static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 	int err;
 
 	err = ovs_flow_extract(skb, p->port_no, &recirc_key);
-	if (err)
+	if (err) {
+		kfree_skb(skb);
 		return err;
+	}
 
 	recirc_key.ovs_flow_hash = hash;
 	recirc_key.recirc_id = nla_get_u32(a);
@@ -602,7 +604,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			err = execute_recirc(dp, recirc_skb, a);
 			__this_cpu_dec(net_xmit_recursion);
 
-			if (last_action || err)
+			if (recirc_skb == skb)
 				return err;
 
 			break;
-- 
1.9.3
