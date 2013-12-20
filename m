From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] arc_emac: fix potential use after free
Date: Thu, 19 Dec 2013 18:10:40 -0800
Message-ID: <1387505440.19078.419.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387504737.19078.416.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:46199 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932089Ab3LTCKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 21:10:42 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so99281pab.9
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 18:10:41 -0800 (PST)
In-Reply-To: <1387504737.19078.416.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>

skb_tx_timestamp(skb) should be called _before_ TX completion
has a chance to trigger, otherwise it is too late and we access
freed memory.

Fixes: e4f2379db6c6 ("ethernet/arc/arc_emac - Add new driver")
From: Eric Dumazet <edumazet@google.com>
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Cc: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/arc/emac_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index b2ffad1304d2..248baf6273fb 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -565,6 +565,8 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	/* Make sure pointer to data buffer is set */
 	wmb();
 
+	skb_tx_timestamp(skb);
+
 	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
 
 	/* Increment index to point to the next BD */
@@ -579,8 +581,6 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 
 	arc_reg_set(priv, R_STATUS, TXPL_MASK);
 
-	skb_tx_timestamp(skb);
-
 	return NETDEV_TX_OK;
 }
 
