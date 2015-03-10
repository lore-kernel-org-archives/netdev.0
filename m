From: Yongbae Park <yongbae2@gmail.com>
Subject: [PATCH] net: WIZnet drivers: enable interrupts after napi_complete()
Date: Tue, 10 Mar 2015 11:35:07 +0900
Message-ID: <1425954907-30417-1-git-send-email-yongbae2@gmail.com>
Cc: davem@davemloft.net, nicolas.ferre@atmel.com, tklauser@distanz.ch,
	wsa@the-dreams.de, varkabhadram@gmail.com, netdev@vger.kernel.org
To: msink@permonline.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34451 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbbCJCeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 22:34:11 -0400
Received: by paceu11 with SMTP id eu11so63475892pac.1
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 19:34:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt is enabled before napi_complete(). A network timeout
occurs if the interrupt handler is called before napi_complete().

Fix the bug by enabling the interrupt after napi_complete().

Signed-off-by: Yongbae Park <yongbae2@gmail.com>
---
 drivers/net/ethernet/wiznet/w5100.c | 4 ++--
 drivers/net/ethernet/wiznet/w5300.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index a495931..43daa6a 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -498,9 +498,9 @@ static int w5100_napi_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (rx_count < budget) {
-		w5100_write(priv, W5100_IMR, IR_S0);
-		mmiowb();
 		napi_complete(napi);
+		w5100_write(priv, W5100_IMR, IR_S0);
+		mmiowb();		
 	}
 
 	return rx_count;
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 09322d9..4b31000 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -418,9 +418,9 @@ static int w5300_napi_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (rx_count < budget) {
+		napi_complete(napi);
 		w5300_write(priv, W5300_IMR, IR_S0);
 		mmiowb();
-		napi_complete(napi);
 	}
 
 	return rx_count;
-- 
1.9.1
