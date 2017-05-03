From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 06/15] netvsc: prefetch the first incoming ring element
Date: Wed,  3 May 2017 16:01:08 -0700
Message-ID: <20170503230117.20070-7-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35597 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752205AbdECXB1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:27 -0400
Received: by mail-pg0-f52.google.com with SMTP id o3so1961169pgn.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:27 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In interrupt handler, prefetch the first incoming ring element
so that it is in cache by the time NAPI poll gets to it.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index ee5f8c520977..cee8e020ac56 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -29,6 +29,8 @@
 #include <linux/netdevice.h>
 #include <linux/if_ether.h>
 #include <linux/vmalloc.h>
+#include <linux/prefetch.h>
+
 #include <asm/sync_bitops.h>
 
 #include "hyperv_net.h"
@@ -1280,10 +1282,15 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 void netvsc_channel_cb(void *context)
 {
 	struct netvsc_channel *nvchan = context;
+	struct vmbus_channel *channel = nvchan->channel;
+	struct hv_ring_buffer_info *rbi = &channel->inbound;
+
+	/* preload first vmpacket descriptor */
+	prefetch(hv_get_ring_buffer(rbi) + rbi->priv_read_index);
 
 	if (napi_schedule_prep(&nvchan->napi)) {
 		/* disable interupts from host */
-		hv_begin_read(&nvchan->channel->inbound);
+		hv_begin_read(rbi);
 
 		__napi_schedule(&nvchan->napi);
 	}
-- 
2.11.0
