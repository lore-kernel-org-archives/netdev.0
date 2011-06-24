From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH] vmxnet3: Enable GRO support.
Date: Fri, 24 Jun 2011 13:33:25 -0700
Message-ID: <1308947605-4300-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Shreyas Bhatewara <sbhatewara@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:48557 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199Ab1FXUdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 16:33:32 -0400
Received: by pvg12 with SMTP id 12so1916770pvg.19
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 13:33:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When receiving packets from another guest on the same hypervisor, it's
generally possible to receive large packets because no segmentation is
necessary and these packets are handled by LRO.  However, when doing
routing or bridging we must disable LRO and lose this benefit.  In
these cases GRO can still be used and it is very effective because the
packets which are segmented in the hypervisor are received very close
together and can easily be merged.

CC: Shreyas Bhatewara <sbhatewara@vmware.com>
CC: VMware PV-Drivers <pv-drivers@vmware.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
This applies on top of my previous vmxnet3 patch
"vmxnet3: Convert to new vlan model."
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index c84b1dd..5353429 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1234,7 +1234,7 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 			if (unlikely(rcd->ts))
 				__vlan_hwaccel_put_tag(skb, rcd->tci);
 
-			netif_receive_skb(skb);
+			napi_gro_receive(&rq->napi, skb);
 
 			ctx->skb = NULL;
 		}
-- 
1.7.4.1

