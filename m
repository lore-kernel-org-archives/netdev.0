From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] net/sched: Fix actions list corruption when adding offloaded tc flows
Date: Tue, 24 Oct 2017 08:58:02 +0300
Message-ID: <1508824682-5088-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com,
        Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40550 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751363AbdJXF6P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 01:58:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to commit b3f55bdda8df, the networking core doesn't wire an in-place
actions list the when the low level driver is called to offload the flow,
but all low level drivers do that (call tcf_exts_to_list()) in their
offloading "add" logic.

Now, the in-place list is set in the core which goes over the list in a loop,
but also by the hw driver when their offloading code is invoked indirectly:

	cls_xxx add flow -> tc_setup_cb_call -> tc_exts_setup_cb_egdev_call -> hw driver

which messes up the core list instance upon driver return. Fix that by avoiding
in-place list on the net core code that deals with adding flows.

Fixes: b3f55bdda8df ('net: sched: introduce per-egress action device callbacks')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index cdfdc24..0e96cda 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -1184,14 +1184,13 @@ static int tc_exts_setup_cb_egdev_call(struct tcf_exts *exts,
 #ifdef CONFIG_NET_CLS_ACT
 	const struct tc_action *a;
 	struct net_device *dev;
-	LIST_HEAD(actions);
-	int ret;
+	int i, ret;
 
 	if (!tcf_exts_has_actions(exts))
 		return 0;
 
-	tcf_exts_to_list(exts, &actions);
-	list_for_each_entry(a, &actions, list) {
+	for (i = 0; i < exts->nr_actions; i++) {
+		a = exts->actions[i];
 		if (!a->ops->get_dev)
 			continue;
 		dev = a->ops->get_dev(a);
-- 
2.3.7
