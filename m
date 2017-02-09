From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/4] net/sched: cls_flower: Use skip flags to reflect HW offload status
Date: Thu,  9 Feb 2017 16:18:05 +0200
Message-ID: <1486649888-2786-2-git-send-email-ogerlitz@mellanox.com>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirva@vadai.me>, netdev@vger.kernel.org,
        Paul Blakey <paulb@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52547 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752778AbdBIOS1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:18:27 -0500
In-Reply-To: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>

Currently there is no way of querying whether a filter is
offloaded to HW or not when using both policy (no flag).

Reuse the skip flags to show the insertion status by setting
the skip_hw flag in case the filter wasn't offloaded.

Signed-off-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 0826c8e..90e4490 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -252,7 +252,10 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 		if (tcf_exts_get_dev(dev, &f->exts, &f->hw_dev) ||
 		    (f->hw_dev && !tc_can_offload(f->hw_dev, tp))) {
 			f->hw_dev = dev;
-			return tc_skip_sw(f->flags) ? -EINVAL : 0;
+			if (tc_skip_sw(f->flags))
+				return -EINVAL;
+			f->flags |= TCA_CLS_FLAGS_SKIP_HW;
+			return 0;
 		}
 		dev = f->hw_dev;
 		tc->egress_dev = true;
@@ -276,6 +279,8 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 
 	if (tc_skip_sw(f->flags))
 		return err;
+	if (err)
+		f->flags |= TCA_CLS_FLAGS_SKIP_HW;
 	return 0;
 }
 
-- 
2.3.7
