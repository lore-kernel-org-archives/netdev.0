From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH v2] vmxnet3: Enable GRO support.
Date: Fri, 24 Jun 2011 17:24:35 -0700
Message-ID: <1308961475-25055-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Shreyas Bhatewara <sbhatewara@vmware.com>,
	Scott Goldman <scottjg@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:35457 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab1FYAYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 20:24:43 -0400
Received: by mail-pz0-f46.google.com with SMTP id 9so2060171pzk.19
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 17:24:42 -0700 (PDT)
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
CC: Scott Goldman <scottjg@vmware.com>
CC: VMware PV-Drivers <pv-drivers@vmware.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
This applies on top of my previous vmxnet3 patch
"vmxnet3: Convert to new vlan model."

v2: Only use GRO when LRO is not active as suggested by Scott Goldman.
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index c84b1dd..2c14736 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1234,7 +1234,10 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 			if (unlikely(rcd->ts))
 				__vlan_hwaccel_put_tag(skb, rcd->tci);
 
-			netif_receive_skb(skb);
+			if (adapter->netdev->features & NETIF_F_LRO)
+				netif_receive_skb(skb);
+			else
+				napi_gro_receive(&rq->napi, skb);
 
 			ctx->skb = NULL;
 		}
-- 
1.7.4.1

