From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/sched: cls_flower: Don't err on HW flow add failure unless we're on skip_sw
Date: Wed, 25 Oct 2017 17:38:33 +0300
Message-ID: <1508942313-544-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        mlxsw@mellanox.com, Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44918 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750823AbdJYOij (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:38:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we failed to offload a flow to HW, we should be err-ing only if skip_sw
is set, otherwise this should go unnoted.

Fixes: 717503b9cf57 ('net: sched: convert cls_flower->egress_dev users to tc_setup_cb_egdev infra')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/sched/cls_flower.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 16f58ab..ae2b5c6 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -230,12 +230,10 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 
 	err = tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
 			       &cls_flower, skip_sw);
-	if (err < 0) {
+	if (err < 0)
 		fl_hw_destroy_filter(tp, f);
-		return err;
-	} else if (err > 0) {
+	else if (err > 0)
 		f->flags |= TCA_CLS_FLAGS_IN_HW;
-	}
 
 	if (skip_sw && !(f->flags & TCA_CLS_FLAGS_IN_HW))
 		return -EINVAL;
-- 
2.5.5
