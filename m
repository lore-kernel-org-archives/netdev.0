From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] gianfar: Do not reuse pages from emergency reserve
Date: Wed, 18 Jan 2017 19:44:42 -0800
Message-ID: <1484797482.16328.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Claudiu Manoil <claudiu.manoil@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36810 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751996AbdASDpM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 22:45:12 -0500
Received: by mail-pf0-f193.google.com with SMTP id 19so2353973pfo.3
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 19:44:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

A driver using dev_alloc_page() must not reuse a page that had to
use emergency memory reserve.

Otherwise all packets using this page will be immediately dropped,
unless for very specific sockets having SOCK_MEMALLOC bit set.

This issue might be hard to debug, because only a fraction of the RX
ring buffer would suffer from drops.

Fixes: 75354148ce69 ("gianfar: Add paged allocation and Rx S/G")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index a6e7afa878befd1abe00404b2cd4becfa174d103..c1b6716679208a69bc66f017a68e5b6e35c60064 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2948,7 +2948,7 @@ static bool gfar_add_rx_frag(struct gfar_rx_buff *rxb, u32 lstatus,
 	}
 
 	/* try reuse page */
-	if (unlikely(page_count(page) != 1))
+	if (unlikely(page_count(page) != 1 || page_is_pfmemalloc(page)))
 		return false;
 
 	/* change offset to the other half */
