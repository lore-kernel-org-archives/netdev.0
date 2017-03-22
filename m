From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 7/9] netvsc: remove unnecessary lock on shutdown
Date: Wed, 22 Mar 2017 14:51:03 -0700
Message-ID: <20170322215105.1059-8-sthemmin@microsoft.com>
References: <20170322215105.1059-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36340 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751346AbdCVVvW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:51:22 -0400
Received: by mail-pf0-f171.google.com with SMTP id o126so96928094pfb.3
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 14:51:21 -0700 (PDT)
In-Reply-To: <20170322215105.1059-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The channel inbound lock was not being used at all by the netvsc
device, but the spin_lock was helpful by providing necessary
barrier before waiting.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/rndis_filter.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 3bd5447277ad..cd7b83707e04 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -926,8 +926,6 @@ static void rndis_filter_halt_device(struct rndis_device *dev)
 	struct rndis_halt_request *halt;
 	struct net_device_context *net_device_ctx = netdev_priv(dev->ndev);
 	struct netvsc_device *nvdev = net_device_ctx->nvdev;
-	struct hv_device *hdev = net_device_ctx->device_ctx;
-	ulong flags;
 
 	/* Attempt to do a rndis device halt */
 	request = get_rndis_request(dev, RNDIS_MSG_HALT,
@@ -945,9 +943,10 @@ static void rndis_filter_halt_device(struct rndis_device *dev)
 	dev->state = RNDIS_DEV_UNINITIALIZED;
 
 cleanup:
-	spin_lock_irqsave(&hdev->channel->inbound_lock, flags);
 	nvdev->destroy = true;
-	spin_unlock_irqrestore(&hdev->channel->inbound_lock, flags);
+
+	/* Force flag to be ordered before waiting */
+	wmb();
 
 	/* Wait for all send completions */
 	wait_event(nvdev->wait_drain, netvsc_device_idle(nvdev));
-- 
2.11.0
