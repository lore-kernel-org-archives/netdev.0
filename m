From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/5] sfc: Reverse initial buffer table allocation
 to allow for later resizing
Date: Thu, 23 Feb 2012 17:41:08 +0000
Message-ID: <1330018868.2511.4.camel@bwh-desktop>
References: <1330018734.2511.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7278 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753373Ab2BWRlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 12:41:11 -0500
In-Reply-To: <1330018734.2511.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a very simple way of allocating buffer table entries to
queues, which is just to take the next one available.  The extra
channels are the highest numbered channels but they need to be
allocated the lowest entries so that the traffic channels can be
allocated new entries without any collisions.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index ac571cf..c7004dc 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -585,7 +585,12 @@ static int efx_probe_channels(struct efx_nic *efx)
 	/* Restart special buffer allocation */
 	efx->next_buffer_table = 0;
 
-	efx_for_each_channel(channel, efx) {
+	/* Probe channels in reverse, so that any 'extra' channels
+	 * use the start of the buffer table. This allows the traffic
+	 * channels to be resized without moving them or wasting the
+	 * entries before them.
+	 */
+	efx_for_each_channel_rev(channel, efx) {
 		rc = efx_probe_channel(channel);
 		if (rc) {
 			netif_err(efx, probe, efx->net_dev,
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
