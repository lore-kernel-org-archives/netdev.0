From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next] net/sched: cls_flower: Set the filter Hardware device for all use-cases
Date: Sun,  4 Dec 2016 15:25:19 +0200
Message-ID: <1480857919-25194-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48719 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750778AbcLDOVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 09:21:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check if the returned device from tcf_exts_get_dev function supports tc
offload and in case the rule can't be offloaded, set the filter hw_dev
parameter to the original device given by the user.

The filter hw_device parameter should always be set by fl_hw_replace_filter
function, since this pointer is used by dump stats and destroy
filter for each flower rule (offloaded or not).

Fixes: 7091d8c7055d ('net/sched: cls_flower: Add offload support using egress Hardware device')
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reported-by: Simon Horman <horms@verge.net.au>
---
 net/sched/cls_flower.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index c5cea78..29a9e6d 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -236,8 +236,11 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	int err;
 
 	if (!tc_can_offload(dev, tp)) {
-		if (tcf_exts_get_dev(dev, &f->exts, &f->hw_dev))
+		if (tcf_exts_get_dev(dev, &f->exts, &f->hw_dev) ||
+		    (f->hw_dev && !tc_can_offload(f->hw_dev, tp))) {
+			f->hw_dev = dev;
 			return tc_skip_sw(f->flags) ? -EINVAL : 0;
+		}
 		dev = f->hw_dev;
 		tc->egress_dev = true;
 	} else {
-- 
1.8.3.1
