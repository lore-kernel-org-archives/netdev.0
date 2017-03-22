From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 9/9] netvsc: fix and cleanup rndis_filter_set_packet_filter
Date: Wed, 22 Mar 2017 14:51:05 -0700
Message-ID: <20170322215105.1059-10-sthemmin@microsoft.com>
References: <20170322215105.1059-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36346 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751153AbdCVVva (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:51:30 -0400
Received: by mail-pf0-f182.google.com with SMTP id o126so96928330pfb.3
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 14:51:23 -0700 (PDT)
In-Reply-To: <20170322215105.1059-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix warning from unused set_complete variable. And rearrange code
to eliminate unnecessary goto's.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/rndis_filter.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index cd7b83707e04..91b3bcfd9acb 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -819,16 +819,14 @@ int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter)
 {
 	struct rndis_request *request;
 	struct rndis_set_request *set;
-	struct rndis_set_complete *set_complete;
 	int ret;
 
 	request = get_rndis_request(dev, RNDIS_MSG_SET,
 			RNDIS_MESSAGE_SIZE(struct rndis_set_request) +
 			sizeof(u32));
-	if (!request) {
-		ret = -ENOMEM;
-		goto cleanup;
-	}
+	if (!request)
+		return -ENOMEM;
+
 
 	/* Setup the rndis set */
 	set = &request->request_msg.msg.set_req;
@@ -840,15 +838,11 @@ int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter)
 	       &new_filter, sizeof(u32));
 
 	ret = rndis_filter_send_request(dev, request);
-	if (ret != 0)
-		goto cleanup;
+	if (ret == 0)
+		wait_for_completion(&request->wait_event);
 
-	wait_for_completion(&request->wait_event);
+	put_rndis_request(dev, request);
 
-	set_complete = &request->response_msg.msg.set_complete;
-cleanup:
-	if (request)
-		put_rndis_request(dev, request);
 	return ret;
 }
 
-- 
2.11.0
