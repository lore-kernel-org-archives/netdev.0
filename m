From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] enic: fix adaptive irq coalescing on 32-bit
Date: Fri, 23 May 2014 09:51:11 +0200
Message-ID: <10713072.kCczZxGWdQ@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Sujith Sankar <ssujith@cisco.com>, Neel Patel <neepatel@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	"David S. Miller" <davem@davemloft.net>,
	Christian Benvenuti <benve@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:58781 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbaEWHvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 03:51:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

7c2ce6e60f703 "enic: Add support for adaptive interrupt coalescing"
introduced a 64-bit division that causes a link error on all 32-bit
machines:

drivers/built-in.o: In function `enic_poll_msix':
:(.text+0x54ff00): undefined reference to `__aeabi_uldivmod'

Since we are dividing another 32-bit value and are only interested
in the approximate range here, it should always be safe to limit
the delta to an u32 value.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
----
I haven't seen another report of this bug, just ignore this
mail if it was already fixed.

Also, there may be better ways to solve this.

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 0d8995c..ad2fac2 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1217,7 +1217,7 @@ static void enic_calc_int_moderation(struct enic *enic, struct vnic_rq *rq)
 	 */
 
 	traffic <<= 3;
-	traffic /= delta;
+	traffic /= min_t(u32, delta, UINT_MAX);
 
 	for (index = 0; index < ENIC_MAX_COALESCE_TIMERS; index++)
 		if (traffic < mod_table[index].rx_rate)
