From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next] enic: Fix 64 bit divide on 32bit system
Date: Mon, 26 May 2014 15:52:43 +0530
Message-ID: <1401099763-2427-1-git-send-email-_govind@gmx.com>
Cc: arnd@arndb.de, David.Laight@aculab.com, gvaradar@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Neel Patel <neepatel@cisco.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:64367 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834AbaEZKYV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2014 06:24:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Division of a 32 bit number by a 64 bit number causes the following link
error introduced by
7c2ce6e60f703 "enic: Add support for adaptive interrupt coalescing"

drivers/built-in.o: In function `enic_poll_msix':
enic_main.c:(.text+0x48710a): undefined reference to `__udivdi3'
make: *** [vmlinux] Error 1

Since numerator is 32 bit, convert denominator to 32 bit accordingly.

Fixes: 7c2ce6e60f703 ("enic: Add support for adaptive interrupt coalescing")
Reported-by: Jim Davis <jim.epost@gmail.com>
Cc: Christian Benvenuti <benve@cisco.com>
Cc: Sujith Sankar <ssujith@cisco.com>
Cc: Neel Patel <neepatel@cisco.com>
Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 0d8995c..d5a220d 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1217,7 +1217,7 @@ static void enic_calc_int_moderation(struct enic *enic, struct vnic_rq *rq)
 	 */
 
 	traffic <<= 3;
-	traffic /= delta;
+	traffic = delta > UINT_MAX ? 0 : traffic / (u32)delta;
 
 	for (index = 0; index < ENIC_MAX_COALESCE_TIMERS; index++)
 		if (traffic < mod_table[index].rx_rate)
-- 
1.9.2
