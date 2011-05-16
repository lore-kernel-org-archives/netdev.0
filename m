From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] sfc: Fix oops in register dump after mapping change
Date: Mon, 16 May 2011 17:13:49 +0100
Message-ID: <1305562429.2885.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26148 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756688Ab1EPQNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 12:13:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 747df2258b1b9a2e25929ef496262c339c380009 ('sfc: Always map MCDI
shared memory as uncacheable') introduced a separate mapping for the
MCDI shared memory (MC_TREG_SMEM).  This means we can no longer easily
include it in the register dump.  Since it is not particularly useful
in debugging, substitute a recognisable dummy value.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
'ethtool -d' on a Siena controller will now result in an 'oops'.  This
is not a huge problem because I suspect I'm the only one actually
actually using this feature.  The patch is against net-2.6 because the
above commit has not yet been merged into net-next-2.6, but I don't
particularly mind if this misses 2.6.39.

Ben.

 drivers/net/sfc/nic.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 10f1cb7..9b29a8d 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1937,6 +1937,13 @@ void efx_nic_get_regs(struct efx_nic *efx, void *buf)
 
 		size = min_t(size_t, table->step, 16);
 
+		if (table->offset >= efx->type->mem_map_size) {
+			/* No longer mapped; return dummy data */
+			memcpy(buf, "\xde\xc0\xad\xde", 4);
+			buf += table->rows * size;
+			continue;
+		}
+
 		for (i = 0; i < table->rows; i++) {
 			switch (table->step) {
 			case 4: /* 32-bit register or SRAM */
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

