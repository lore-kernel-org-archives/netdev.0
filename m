From: "Ben Menchaca (ben@bigfootnetworks.com)" <ben@bigfootnetworks.com>
Subject: RE: Gianfar: RX Recycle skb->len error
Date: Tue, 23 Mar 2010 07:16:58 -0700
Message-ID: <A6A1774AFD79E346AE6D49A33CB294530DC19F4A@EX-BE-017-SFO.shared.themessagecenter.com>
References: <20100321.214642.67901344.davem@davemloft.net>
 <20100322172446.GA32758@oksana.dev.rtsoft.ru>
 <A6A1774AFD79E346AE6D49A33CB294530DC19F18@EX-BE-017-SFO.shared.themessagecenter.com>
 <20100322.203053.37576243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "avorontsov@ru.mvista.com" <avorontsov@ru.mvista.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sandeep.Kumar@freescale.com" <Sandeep.Kumar@freescale.com>,
	"kumar.gala@freescale.com" <kumar.gala@freescale.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.themessagecenter.com ([208.113.96.229]:2103 "EHLO
	out02.themessagecenter.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753525Ab0CWORF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Mar 2010 10:17:05 -0400
In-Reply-To: <20100322.203053.37576243.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There's no need to make this so complicated.  Just remember the
> value and then refer to it later, when needed.

Thanks for the sanity adjustment!  As suggested, then...hope to hear from FS soon.

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b671555..669de02 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2393,6 +2393,7 @@ struct sk_buff * gfar_new_skb(struct net_device *dev)
 	 * as many bytes as needed to align the data properly
 	 */
 	skb_reserve(skb, alignamount);
+	GFAR_CB(skb)->alignamount = alignamount;
 
 	return skb;
 }
@@ -2533,13 +2534,13 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 				newskb = skb;
 			else if (skb) {
 				/*
-				 * We need to reset ->data to what it
+				 * We need to un-reserve() the skb to what it
 				 * was before gfar_new_skb() re-aligned
 				 * it to an RXBUF_ALIGNMENT boundary
 				 * before we put the skb back on the
 				 * recycle list.
 				 */
-				skb->data = skb->head + NET_SKB_PAD;
+				skb_reserve(skb, -GFAR_CB(skb)->alignamount);
 				__skb_queue_head(&priv->rx_recycle, skb);
 			}
 		} else {
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 3d72dc4..3ae2c77 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -566,6 +566,12 @@ struct rxfcb {
 	u16	vlctl;	/* VLAN control word */
 };
 
+struct gfar_skb_cb {
+        int alignamount;
+};
+
+#define GFAR_CB(skb) ((struct gfar_skb_cb *)((skb)->cb))
+
 struct rmon_mib
 {
 	u32	tr64;	/* 0x.680 - Transmit and Receive 64-byte Frame Counter */




