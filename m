From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] be2net: fix a race in be_xmit()
Date: Fri, 08 Jun 2012 10:59:59 +0200
Message-ID: <1339145999.6001.62.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Sathya Perla <sathya.perla@emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33025 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932177Ab2FHJAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 05:00:03 -0400
Received: by eeit10 with SMTP id t10so917629eei.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 02:00:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As soon as hardware is notified of a transmit, we no longer can assume
skb can be dereferenced, as TX completion might have freed the packet.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 08efd30..fdb50ce 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -736,6 +736,8 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 
 	copied = make_tx_wrbs(adapter, txq, skb, wrb_cnt, dummy_wrb);
 	if (copied) {
+		int gso_segs = skb_shinfo(skb)->gso_segs;
+
 		/* record the sent skb in the sent_skb table */
 		BUG_ON(txo->sent_skb_list[start]);
 		txo->sent_skb_list[start] = skb;
@@ -753,8 +755,7 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 
 		be_txq_notify(adapter, txq->id, wrb_cnt);
 
-		be_tx_stats_update(txo, wrb_cnt, copied,
-				skb_shinfo(skb)->gso_segs, stopped);
+		be_tx_stats_update(txo, wrb_cnt, copied, gso_segs, stopped);
 	} else {
 		txq->head = start;
 		dev_kfree_skb_any(skb);
