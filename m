From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 4/4] net/sched: cls_bpf: Use skip flags to reflect HW offload status
Date: Thu,  9 Feb 2017 16:18:08 +0200
Message-ID: <1486649888-2786-5-git-send-email-ogerlitz@mellanox.com>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirva@vadai.me>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53540 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752796AbdBIOZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:25:02 -0500
In-Reply-To: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is no way of querying whether a filter is
offloaded to HW or not when using both policy (no flag).

Reuse the skip flags to show the insertion status by setting
the skip_hw flag in case the filter wasn't offloaded.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/sched/cls_bpf.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index d9c9701..91ba90d 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -185,14 +185,23 @@ static int cls_bpf_offload(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 			return -EINVAL;
 		}
 	} else {
-		if (!tc_should_offload(dev, tp, prog->gen_flags))
-			return skip_sw ? -EINVAL : 0;
+		if (!tc_should_offload(dev, tp, prog->gen_flags)) {
+			if (tc_skip_sw(prog->gen_flags))
+				return -EINVAL;
+			prog->gen_flags |= TCA_CLS_FLAGS_SKIP_HW;
+			return 0;
+		}
 		cmd = TC_CLSBPF_ADD;
 	}
 
 	ret = cls_bpf_offload_cmd(tp, obj, cmd);
-	if (ret)
-		return skip_sw ? ret : 0;
+
+	if (ret) {
+		if (skip_sw)
+			return ret;
+		prog->gen_flags |= TCA_CLS_FLAGS_SKIP_HW;
+		return 0;
+	}
 
 	obj->offloaded = true;
 	if (oldprog)
-- 
2.3.7
