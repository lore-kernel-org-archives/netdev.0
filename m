From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/sched: cls_flower: Avoid attempt to delete from hw a flow which was not offloaded
Date: Wed, 25 Oct 2017 16:44:40 +0300
Message-ID: <1508939080-22317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        mlxsw@mellanox.com, Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59300 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751162AbdJYNop (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 09:44:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we failed to offload a flow to HW, we should not be attempting to delete
it from the HW. Also, on this case, we should be err-ing only if the flow is
not is SW, fix both issues.

Fixes: 717503b9cf57 ('net: sched: convert cls_flower->egress_dev users to tc_setup_cb_egdev infra')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/sched/cls_flower.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 16f58ab..b98e0cb 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -230,15 +230,12 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 
 	err = tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
 			       &cls_flower, skip_sw);
-	if (err < 0) {
-		fl_hw_destroy_filter(tp, f);
-		return err;
-	} else if (err > 0) {
+
+	if (err > 0)
 		f->flags |= TCA_CLS_FLAGS_IN_HW;
-	}
 
-	if (skip_sw && !(f->flags & TCA_CLS_FLAGS_IN_HW))
-		return -EINVAL;
+	if (skip_sw)
+		return err;
 
 	return 0;
 }
-- 
2.5.5
