From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v3 net 1/2] net/sched: act_vlan: Push skb->data to mac_header prior calling skb_vlan_*() functions
Date: Thu, 29 Sep 2016 12:10:40 +0300
Message-ID: <1475140241-23586-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Pravin Shelar <pshelar@ovn.org>, Jiri Pirko <jiri@mellanox.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34065 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933488AbcI2JLI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 05:11:08 -0400
Received: by mail-wm0-f67.google.com with SMTP id w72so1053833wmf.1
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 02:11:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generic skb_vlan_push/skb_vlan_pop functions don't properly handle the
case where the input skb data pointer does not point at the mac header:

- They're doing push/pop, but fail to properly unwind data back to its
  original location.
  For example, in the skb_vlan_push case, any subsequent
  'skb_push(skb, skb->mac_len)' calls make the skb->data point 4 bytes
  BEFORE start of frame, leading to bogus frames that may be transmitted.

- They update rcsum per the added/removed 4 bytes tag.
  Alas if data is originally after the vlan/eth headers, then these
  bytes were already pulled out of the csum.

OTOH calling skb_vlan_push/skb_vlan_pop with skb->data at mac_header
present no issues.

act_vlan is the only caller to skb_vlan_*() that has skb->data pointing
at network header (upon ingress).
Other calles (ovs, bpf) already adjust skb->data at mac_header.

This patch fixes act_vlan to point to the mac_header prior calling
skb_vlan_*() functions, as other callers do.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Pravin Shelar <pshelar@ovn.org>
Cc: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/act_vlan.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index 691409de3e..4ffc6c13a5 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -36,6 +36,12 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
 	bstats_update(&v->tcf_bstats, skb);
 	action = v->tcf_action;
 
+	/* Ensure 'data' points at mac_header prior calling vlan manipulating
+	 * functions.
+	 */
+	if (skb_at_tc_ingress(skb))
+		skb_push_rcsum(skb, skb->mac_len);
+
 	switch (v->tcfv_action) {
 	case TCA_VLAN_ACT_POP:
 		err = skb_vlan_pop(skb);
@@ -57,6 +63,9 @@ drop:
 	action = TC_ACT_SHOT;
 	v->tcf_qstats.drops++;
 unlock:
+	if (skb_at_tc_ingress(skb))
+		skb_pull_rcsum(skb, skb->mac_len);
+
 	spin_unlock(&v->tcf_lock);
 	return action;
 }
-- 
2.7.4
