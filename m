From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] tg3: fix ring init when there are more TX than RX channels
Date: Tue, 25 Nov 2014 14:21:11 -0200
Message-ID: <1416932471-8744-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: prashant@broadcom.com, mchan@broadcom.com,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:33910 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbaKYQVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:21:25 -0500
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Tue, 25 Nov 2014 14:21:24 -0200
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 06D191DC0050
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 11:20:27 -0500 (EST)
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAPGL98m56557614
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 14:21:09 -0200
Received: from d24av03.br.ibm.com (localhost [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAPGLKAE022669
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 14:21:21 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If TX channels are set to 4 and RX channels are set to less than 4,
using ethtool -L, the driver will try to initialize more RX channels
than it has allocated, causing an oops.

This fix only initializes the RX ring if it has been allocated.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index dbb41c19..77f8f83 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8563,7 +8563,8 @@ static int tg3_init_rings(struct tg3 *tp)
 		if (tnapi->rx_rcb)
 			memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
 
-		if (tg3_rx_prodring_alloc(tp, &tnapi->prodring)) {
+		if (tnapi->prodring.rx_std &&
+		    tg3_rx_prodring_alloc(tp, &tnapi->prodring)) {
 			tg3_free_rings(tp);
 			return -ENOMEM;
 		}
-- 
1.7.10.4
