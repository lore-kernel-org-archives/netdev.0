From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bnx2x: fix possible panic under memory stress
Date: Thu, 26 Jun 2014 00:44:02 -0700
Message-ID: <1403768642.374.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Michel Lespinasse <walken@google.com>,
	Ariel Elior <ariel.elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:50933 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754564AbaFZHoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 03:44:08 -0400
Received: by mail-wi0-f177.google.com with SMTP id r20so471381wiv.16
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 00:44:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While it is legal to kfree(NULL), it is not wise to use :
put_page(virt_to_head_page(NULL))

 BUG: unable to handle kernel paging request at ffffeba400000000
 IP: [<ffffffffc01f5928>] virt_to_head_page+0x36/0x44 [bnx2x]

Reported-by: Michel Lespinasse <walken@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ariel Elior <ariel.elior@qlogic.com>
Fixes: d46d132cc021 ("bnx2x: use netdev_alloc_frag()")
---
This is a stable candidate, bug added in linux-3.8

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 47c5814114e1..4b875da1c7ed 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -797,7 +797,8 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		return;
 	}
-	bnx2x_frag_free(fp, new_data);
+	if (new_data)
+		bnx2x_frag_free(fp, new_data);
 drop:
 	/* drop the packet and keep the buffer in the bin */
 	DP(NETIF_MSG_RX_STATUS,
