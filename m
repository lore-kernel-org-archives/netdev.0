From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net] sfc: fix potential stack corruption from running past
 stat bitmask
Date: Fri, 26 Aug 2016 11:19:34 +0100
Message-ID: <0798c3e7-d8a1-3826-204d-2cbb0375205d@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:51199 "EHLO
        nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752998AbcHZKTr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 06:19:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

On 32-bit systems, mask is only an array of 3 longs, not 4, so don't try
to write to mask[3].
Also include build-time checks in case the size of the bitmask changes.

Fixes: 3c36a2aded8c ("sfc: display vadaptor statistics for all interfaces")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 1f30912..6e0a4f2 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1304,13 +1304,14 @@ static void efx_ef10_get_stat_mask(struct efx_nic *efx, unsigned long *mask)
 	}
 
 #if BITS_PER_LONG == 64
+	BUILD_BUG_ON(BITS_TO_LONGS(EF10_STAT_COUNT) != 2);
 	mask[0] = raw_mask[0];
 	mask[1] = raw_mask[1];
 #else
+	BUILD_BUG_ON(BITS_TO_LONGS(EF10_STAT_COUNT) != 3);
 	mask[0] = raw_mask[0] & 0xffffffff;
 	mask[1] = raw_mask[0] >> 32;
 	mask[2] = raw_mask[1] & 0xffffffff;
-	mask[3] = raw_mask[1] >> 32;
 #endif
 }
 
