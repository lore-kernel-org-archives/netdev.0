From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 2/4] net: cls_u32: move TC offload feature bit into
 cls_u32 offload logic
Date: Tue, 23 Feb 2016 11:02:56 -0800
Message-ID: <20160223190256.5970.25013.stgit@john-Precision-Tower-5810>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: jiri@resnulli.us, john.fastabend@gmail.com, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36493 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975AbcBWTDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 14:03:16 -0500
Received: by mail-pf0-f180.google.com with SMTP id e127so117091155pfe.3
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 11:03:15 -0800 (PST)
In-Reply-To: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the original series drivers would get offload requests for cls_u32
rules even if the feature bit is disabled. This meant the driver had
to do a boiler plate check on the feature bit before adding/deleting
the rule.

This patch lifts the check into the core code and removes it from the
driver specific case.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 ---
 net/sched/cls_u32.c                           |    3 +++
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cf4b729..b893ff8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8400,9 +8400,6 @@ int __ixgbe_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 
 	if (TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS) &&
 	    tc->type == TC_SETUP_CLSU32) {
-		if (!(dev->features & NETIF_F_HW_TC))
-			return -EINVAL;
-
 		switch (tc->cls_u32->command) {
 		case TC_CLSU32_NEW_KNODE:
 		case TC_CLSU32_REPLACE_KNODE:
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 1f31929..f766bcb 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -427,6 +427,9 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 
 static bool u32_should_offload(struct net_device *dev)
 {
+	if (!(dev->features & NETIF_F_HW_TC))
+		return false;
+
 	return dev->netdev_ops->ndo_setup_tc;
 }
 
