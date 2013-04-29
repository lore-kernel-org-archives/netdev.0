From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][net-next] gianfar: Fix reported sent bytes to BQL for
 Tx timestamping
Date: Mon, 29 Apr 2013 08:23:29 -0700
Message-ID: <1367249009.8964.312.camel@edumazet-glaptop>
References: <1367240268-32609-1-git-send-email-claudiu.manoil@freescale.com>
	 <1367243593.8964.306.camel@edumazet-glaptop>
	 <517E8354.1010503@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:49590 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444Ab3D2PXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 11:23:37 -0400
Received: by mail-da0-f53.google.com with SMTP id n34so2976298dal.12
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 08:23:36 -0700 (PDT)
In-Reply-To: <517E8354.1010503@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-29 at 17:27 +0300, Claudiu Manoil wrote:
> Hi,
> 
> Unfortunately fixing this the other way around would imply changes
> in both xmit and clean_tx, and additional overhead in clean_tx.
> On xmit skb->len gets incremented with FCB_LEN and/or TXPAL_LEN,
> on a case by case basis. This would imply to add extra checks on
> clean_tx to identify whether only FCB_LEN has been added, or
> FCB+TXPAL or neither, all these just to report the bytes on wire
> for BQL.
> Does BQL really need to measure the bytes-on-wire or the bytes consumed
> for buffering?

Yes.

What about :

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2375a01..bb727e1 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2065,6 +2065,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 bufaddr;
 	unsigned long flags;
 	unsigned int nr_frags, nr_txbds, length, fcb_length = GMAC_FCB_LEN;
+	unsigned int len;
 
 	/* TOE=1 frames larger than 2500 bytes may see excess delays
 	 * before start of transmission.
@@ -2130,7 +2131,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Update transmit stats */
-	tx_queue->stats.tx_bytes += skb->len;
+	len = skb->len;
+	tx_queue->stats.tx_bytes += len;
 	tx_queue->stats.tx_packets++;
 
 	txbdp = txbdp_start = tx_queue->cur_tx;
@@ -2231,7 +2233,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | skb_headlen(skb);
 	}
 
-	netdev_tx_sent_queue(txq, skb->len);
+	netdev_tx_sent_queue(txq, len);
 
 	/* We can work in parallel with gfar_clean_tx_ring(), except
 	 * when modifying num_txbdfree. Note that we didn't grab the lock
