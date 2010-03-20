From: "Ben Menchaca (ben@bigfootnetworks.com)" <ben@bigfootnetworks.com>
Subject: Gianfar: RX Recycle skb->len error
Date: Sat, 20 Mar 2010 12:54:59 -0700
Message-ID: <A6A1774AFD79E346AE6D49A33CB294530DC19EB5@EX-BE-017-SFO.shared.themessagecenter.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.themessagecenter.com ([208.113.96.229]:3722 "EHLO
	out02.themessagecenter.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750808Ab0CTUAi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Mar 2010 16:00:38 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing some random skb data length errors on RX after long-running, full-gigabit traffic.  First, my debugging and solution are based on the following invariant assumption:
(skb->tail - skb->data) == skb->len

If this is wrong, please educate.

After some tracing, here is where the error packets seem to originate:
1.  We are cleaning rx, in gfar_clean_rx_ring;
2.  A new RX skb is drawn from the rx_recycle queue, and obey the above invariant (so, in gfar_new_skb(), __skb_dequeue returns an skb);
3.  At this point skb_reserve is called, which moves data and tail by the same calculated alignamount;
4.  So, newskb is not NULL.  However, !(bdp->status & RXBD_LAST) || (bdp->status & RXBD_ERR)) is evaluates to true;
5.  Since newskb is not NULL, we arrive at the else if (skb), which is true;
6.  skb->data = skb->head + NET_SKB_PAD is applied, and then the skb is requeued for recycling.

At this point, skb->data != skb->tail, but skb->len == 0.  When this skb is used for the next RX, it is causing issues later when we skb_put trailers, and then trust skb->len.

I would propose something like:

--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2540,6 +2540,7 @@ 
				 * recycle list.
 				 */
 				skb->data = skb->head + NET_SKB_PAD;
+				skb_reset_tail_pointer(skb);
				__skb_queue_head(&priv->rx_recycle, skb);
			}
		} else {

Ben Menchaca
Bigfoot Networks

