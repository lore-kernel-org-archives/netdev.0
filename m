From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 4/5] netvsc: signal host if receive ring is emptied
Date: Tue, 25 Jul 2017 13:04:21 -0700
Message-ID: <20170725200422.13795-5-sthemmin@microsoft.com>
References: <20170725200422.13795-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35007 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753785AbdGYUEa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 16:04:30 -0400
Received: by mail-pf0-f172.google.com with SMTP id h29so27206281pfd.2
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 13:04:30 -0700 (PDT)
In-Reply-To: <20170725200422.13795-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Latency improvement related to NAPI conversion.
If all packets are processed from receive ring then need
to signal host.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 03c1fec762c7..f5d7cae6ba70 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1189,10 +1189,15 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 		nvchan->desc = hv_pkt_iter_next(channel, nvchan->desc);
 	}
 
-	/* If send of  pending receive completions suceeded
-	 *   and did not exhaust NAPI budget
+	/* if ring is empty, signal host */
+	if (!nvchan->desc)
+		hv_pkt_iter_close(channel);
+
+	/* If send of pending receive completions suceeded
+	 *   and did not exhaust NAPI budget this time
 	 *   and not doing busy poll
-	 * then reschedule if more data has arrived from host
+	 * then re-enable host interrupts
+	 *     and reschedule if ring is not empty.
 	 */
 	if (send_recv_completions(net_device, channel, q_idx) == 0 &&
 	    work_done < budget &&
-- 
2.11.0
