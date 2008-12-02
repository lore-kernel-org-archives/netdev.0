From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] enc28j60: Fix sporadic packet loss
Date: Tue, 2 Dec 2008 14:50:46 +0200
Message-ID: <20081202125046.GD24490@diamond.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shachar Shemesh <shachar@lingnu.com>, netdev@vger.kernel.org
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:48531 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075AbYLBNPN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 08:15:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packet data read from the RX buffer the when the RSV is at the end of the RX 
buffer does not warp around. This causes packet loss, as the actual data is 
never read. Fix this by calculating the right packet data location.

Thanks to Shachar Shemesh for suggesting the fix.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>

---

--- drivers/net/enc28j60.c-git	2008-12-02 14:30:10.000000000 +0200
+++ drivers/net/enc28j60.c	2008-12-02 14:41:51.000000000 +0200
@@ -568,6 +568,17 @@ static u16 erxrdpt_workaround(u16 next_p
 	return erxrdpt;
 }
 
+/*
+ * Calculate wrap arround when reading beyond the end of the RX buffer
+ */
+static u16 rx_packet_start(u16 ptr)
+{
+	if (ptr + RSV_SIZE > RXEND_INIT)
+		return (ptr + RSV_SIZE) - (RXEND_INIT - RXSTART_INIT + 1);
+	else
+		return ptr;
+}
+
 static void nolock_rxfifo_init(struct enc28j60_net *priv, u16 start, u16 end)
 {
 	u16 erxrdpt;
@@ -938,8 +949,9 @@ static void enc28j60_hw_rx(struct net_de
 			skb->dev = ndev;
 			skb_reserve(skb, NET_IP_ALIGN);
 			/* copy the packet from the receive buffer */
-			enc28j60_mem_read(priv, priv->next_pk_ptr + sizeof(rsv),
-					len, skb_put(skb, len));
+			enc28j60_mem_read(priv,
+				rx_packet_start(priv->next_pk_ptr),
+				len, skb_put(skb, len));
 			if (netif_msg_pktdata(priv))
 				dump_packet(__func__, skb->len, skb->data);
 			skb->protocol = eth_type_trans(skb, ndev);

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
