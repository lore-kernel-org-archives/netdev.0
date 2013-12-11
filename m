From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 3/8] sfc: Rate-limit log message for PTP packets without
 a matching timestamp event
Date: Wed, 11 Dec 2013 01:55:49 +0000
Message-ID: <1386726949.1516.241.camel@bwh-desktop.uk.level5networks.com>
References: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40974 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829Ab3LKBzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 20:55:52 -0500
In-Reply-To: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of a flood of PTP packets, the timestamp peripheral and MC
firmware on the SFN[56]322F boards may not be able to provide
timestamp events for all packets.  Don't complain too much about this.

Fixes: 7c236c43b838 ('sfc: Add support for IEEE-1588 PTP')
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 8b2cf783217c..8c665f1b5480 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -717,8 +717,9 @@ static bool efx_ptp_process_events(struct efx_nic *efx, struct sk_buff_head *q)
 			__skb_queue_tail(q, skb);
 		} else if (time_after(jiffies, match->expiry)) {
 			match->state = PTP_PACKET_STATE_TIMED_OUT;
-			netif_warn(efx, rx_err, efx->net_dev,
-				   "PTP packet - no timestamp seen\n");
+			if (net_ratelimit())
+				netif_warn(efx, rx_err, efx->net_dev,
+					   "PTP packet - no timestamp seen\n");
 			__skb_queue_tail(q, skb);
 		} else {
 			/* Replace unprocessed entry and stop */


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
