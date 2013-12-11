From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 5/8] sfc: Maintain current frequency adjustment when
 applying a time offset
Date: Wed, 11 Dec 2013 01:56:43 +0000
Message-ID: <1386727003.1516.243.camel@bwh-desktop.uk.level5networks.com>
References: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41008 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829Ab3LKB4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 20:56:46 -0500
In-Reply-To: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a single MCDI PTP operation for setting the frequency
adjustment and applying a time offset to the hardware clock.  When
applying a time offset we should not change the frequency adjustment.

These two operations can now be requested separately but this requires
a flash firmware update.  Keep using the single operation, but
remember and repeat the previous frequency adjustment.

Fixes: 7c236c43b838 ('sfc: Add support for IEEE-1588 PTP')
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 9bd99edf3f95..3dd39dcfe36b 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1426,7 +1426,7 @@ static int efx_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 	if (rc != 0)
 		return rc;
 
-	ptp_data->current_adjfreq = delta;
+	ptp_data->current_adjfreq = adjustment_ns;
 	return 0;
 }
 
@@ -1441,7 +1441,7 @@ static int efx_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_ADJUST);
 	MCDI_SET_DWORD(inbuf, PTP_IN_PERIPH_ID, 0);
-	MCDI_SET_QWORD(inbuf, PTP_IN_ADJUST_FREQ, 0);
+	MCDI_SET_QWORD(inbuf, PTP_IN_ADJUST_FREQ, ptp_data->current_adjfreq);
 	MCDI_SET_DWORD(inbuf, PTP_IN_ADJUST_SECONDS, (u32)delta_ts.tv_sec);
 	MCDI_SET_DWORD(inbuf, PTP_IN_ADJUST_NANOSECONDS, (u32)delta_ts.tv_nsec);
 	return efx_mcdi_rpc(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
