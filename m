From: "Ben Menchaca (ben@bigfootnetworks.com)" <ben@bigfootnetworks.com>
Subject: [RFC PATCH] gianfar: fix undo of reserve()
Date: Wed, 24 Mar 2010 08:05:02 -0700
Message-ID: <A6A1774AFD79E346AE6D49A33CB294530DC19FC4@EX-BE-017-SFO.shared.themessagecenter.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.themessagecenter.com ([208.113.96.229]:1732 "EHLO
	out02.themessagecenter.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755792Ab0CXPFM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 11:05:12 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Menchaca <ben@bigfootnetworks.com>

Fix undo of reserve() before RX recycle

gfar_new_skb reserve()s space in the SKB to align it.  If an error occurs,
and the skb needs to be returned to the RX recycle queue, the current code
attempts to reset head, but did not reset tail.  This patch remembers the
alignment amount, and reverses the reserve() when needed.

Signed-off-by: Ben Menchaca <ben@bigfootnetworks.com>
---
 drivers/net/gianfar.c |    5 +++--
 drivers/net/gianfar.h |    6 ++++++
 2 files changed, 9 insertions(+), 2 deletions(-)

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
index 3d72dc4..06044dd 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -566,6 +566,12 @@ struct rxfcb {
 	u16	vlctl;	/* VLAN control word */
 };
 
+struct gianfar_skb_cb {
+	int alignamount;
+};
+
+#define GFAR_CB(skb) ((struct gianfar_skb_cb *)((skb)->cb))
+
 struct rmon_mib
 {
 	u32	tr64;	/* 0x.680 - Transmit and Receive 64-byte Frame Counter */
--

