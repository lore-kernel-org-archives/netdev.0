From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/sched: cls_flower: Set egress_dev mark when calling into the HW driver
Date: Mon, 16 Oct 2017 12:19:48 +0300
Message-ID: <1508145588-29959-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        mlxsw@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35336 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750914AbdJPJUA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 05:20:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7091d8c '(net/sched: cls_flower: Add offload support using egress
Hardware device') made sure (when fl_hw_replace_filter is called) to put
the egress_dev mark on persisent structure instance. Hence, following calls
into the HW driver for stats and deletion will note it and act accordingly.

With commit de4784ca030f this property is lost and hence when called,
the HW driver failes to operate (stats, delete) on the offloaded flow.

Fix it by setting the egress_dev flag whenever the ingress device is
different from the hw device since this is exactly the condition under
which we're calling into the HW driver through the egress port net-device.

Fixes: de4784ca030f ('net: sched: get rid of struct tc_to_netdev')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Roi Dayan <roid@mellanox.com>
---

Hi Dave, the bug was introduced in 4.14-rc1 but later the related
code was changed in net-next, hence the fix must not go to net-next, Or.

 net/sched/cls_flower.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index d230cb4..b480d7c 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -234,6 +234,7 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 	tc_cls_common_offload_init(&cls_flower.common, tp);
 	cls_flower.command = TC_CLSFLOWER_DESTROY;
 	cls_flower.cookie = (unsigned long) f;
+	cls_flower.egress_dev = f->hw_dev != tp->q->dev_queue->dev;
 
 	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER, &cls_flower);
 }
@@ -289,6 +290,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	cls_flower.command = TC_CLSFLOWER_STATS;
 	cls_flower.cookie = (unsigned long) f;
 	cls_flower.exts = &f->exts;
+	cls_flower.egress_dev = f->hw_dev != tp->q->dev_queue->dev;
 
 	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
 				      &cls_flower);
-- 
2.3.7
