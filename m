From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 2/3] net: cls_u32: move TC offload feature bit
 into cls_u32 offload logic
Date: Fri, 26 Feb 2016 07:54:13 -0800
Message-ID: <20160226155413.5338.47761.stgit@john-Precision-Tower-5810>
References: <20160226154858.5338.90569.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: jiri@resnulli.us, john.fastabend@gmail.com, daniel@iogearbox.net,
	simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34743 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700AbcBZPyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 10:54:32 -0500
Received: by mail-pf0-f173.google.com with SMTP id x65so54063569pfb.1
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 07:54:32 -0800 (PST)
In-Reply-To: <20160226154858.5338.90569.stgit@john-Precision-Tower-5810>
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
 include/net/pkt_cls.h                         |    3 +++
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
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index e64d20b..6096e96 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -394,6 +394,9 @@ struct tc_cls_u32_offload {
 
 static inline bool tc_should_offload(struct net_device *dev)
 {
+	if (!(dev->features & NETIF_F_HW_TC))
+		return false;
+
 	return dev->netdev_ops->ndo_setup_tc;
 }
 
