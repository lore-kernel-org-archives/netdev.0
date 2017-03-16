From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/3] netvsc: add comments about callback's and NAPI
Date: Thu, 16 Mar 2017 16:12:38 -0700
Message-ID: <20170316231239.12996-3-sthemmin@microsoft.com>
References: <20170316231239.12996-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net, haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33134 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752191AbdCPXMv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 19:12:51 -0400
Received: by mail-pf0-f181.google.com with SMTP id w189so31015878pfb.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 16:12:50 -0700 (PDT)
In-Reply-To: <20170316231239.12996-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add some short description of how callback's and NAPI interoperate.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 0a2e9bd98d2c..989b7cd99380 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1209,6 +1209,10 @@ static struct hv_device *netvsc_channel_to_device(struct vmbus_channel *channel)
 	return primary ? primary->device_obj : channel->device_obj;
 }
 
+/* Network processing softirq
+ * Process data in incoming ring buffer from host
+ * Stops when ring is empty or budget is met or exceeded.
+ */
 int netvsc_poll(struct napi_struct *napi, int budget)
 {
 	struct netvsc_channel *nvchan
@@ -1238,7 +1242,11 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 	}
 	hv_pkt_iter_close(channel);
 
-	/* If ring is empty and NAPI is not doing polling */
+	/* If budget was not exhausted and
+	 * not doing busy poll
+	 * then re-enable host interrupts
+	 *  and reschedule if ring is not empty.
+	 */
 	if (work_done < budget &&
 	    napi_complete_done(napi, work_done) &&
 	    hv_end_read(&channel->inbound) != 0)
@@ -1248,6 +1256,9 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+/* Call back when data is available in host ring buffer.
+ * Processing is deferred until network softirq (NAPI)
+ */
 void netvsc_channel_cb(void *context)
 {
 	struct netvsc_channel *nvchan = context;
-- 
2.11.0
