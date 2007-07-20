From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 10/10] ps3: reduce allocation size of rx skb buffers
Date: Fri, 20 Jul 2007 17:39:25 +0900
Message-ID: <20070720173613.67A4.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW3.Sony.CO.JP ([137.153.0.15]:57627 "EHLO mgw3.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbXGTIja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 04:39:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduced allocation size for rx skb buffers, from 2308 bytes to 
1356 per buffer.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |   45 ++++++++++++++++++++++++++++++++++++--------
 drivers/net/ps3_gelic_net.h |   12 ++++++-----
 2 files changed, 44 insertions(+), 13 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -917,31 +917,60 @@ static int gelic_net_decode_one_descr(st
 		goto refill;
 	}
 
-	if ((status != GELIC_NET_DESCR_COMPLETE) &&
-	    (status != GELIC_NET_DESCR_FRAME_END)) {
+	if (status == GELIC_NET_DESCR_BUFFER_FULL) {
+		/*
+		 * Buffer full would occur if and only if
+		 * the frame length was longer than the size of this
+		 * descriptor's buffer.  If the frame length was equal
+		 * to or shorter than buffer'size, FRAME_END condition
+		 * would occur.
+		 * Anyway this frame was longer than the MTU,
+		 * just drop it.
+		 */
+		dev_info(ctodev(card), "overlength frame\n");
+		goto refill;
+	}
+	/*
+	 * descriptoers any other than FRAME_END here should
+	 * be treated as error.
+	 */
+	if (status != GELIC_NET_DESCR_FRAME_END) {
 		dev_dbg(ctodev(card), "RX descriptor with state %x\n",
 			status);
 		goto refill;
 	}
 
 	/* ok, we've got a packet in descr */
-	gelic_net_pass_skb_up(descr, card); /* 1: skb_up sccess */
-
+	gelic_net_pass_skb_up(descr, card);
 refill:
-	descr->next_descr_addr = 0; /* unlink the descr */
+	/*
+	 * So that always DMAC can see the end
+	 * of the descriptor chain to avoid
+	 * from unwanted DMAC overrun.
+	 */
+	descr->next_descr_addr = 0;
 
 	/* change the descriptor state: */
 	gelic_net_set_descr_status(descr, GELIC_NET_DESCR_NOT_IN_USE);
 
-	/* refill one desc
-	 * FIXME: this can fail, but for now, just leave this
-	 * descriptor without skb
+	/*
+	 * this call can fail, but for now, just leave this
+	 * decriptor without skb
 	 */
 	gelic_net_prepare_rx_descr(card, descr);
+
 	chain->head = descr;
 	chain->tail = descr->next;
+
+	/*
+	 * Set this descriptor the end of the chain.
+	 */
 	descr->prev->next_descr_addr = descr->bus_addr;
 
+	/*
+	 * If dmac chain was met, DMAC stopped.
+	 * thus re-enable it
+	 */
 	if (dmac_chain_ended) {
 		card->rx_dma_restart_required = 1;
 		dev_dbg(ctodev(card), "reenable rx dma scheduled\n");
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -32,8 +32,8 @@
 #define GELIC_NET_RX_DESCRIPTORS        128 /* num of descriptors */
 #define GELIC_NET_TX_DESCRIPTORS        128 /* num of descriptors */
 
-#define GELIC_NET_MAX_MTU               2308
-#define GELIC_NET_MIN_MTU               64
+#define GELIC_NET_MAX_MTU               VLAN_ETH_FRAME_LEN
+#define GELIC_NET_MIN_MTU               VLAN_ETH_ZLEN
 #define GELIC_NET_RXBUF_ALIGN           128
 #define GELIC_NET_RX_CSUM_DEFAULT       1 /* hw chksum */
 #define GELIC_NET_WATCHDOG_TIMEOUT      5*HZ
@@ -81,7 +81,8 @@ enum gelic_net_int1_status {
 					    */
 #define GELIC_NET_RXVLNPKT	0x00200000 /* VLAN packet */
 /* bit 20..16 reserved */
-#define GELIC_NET_RXRECNUM	0x0000ff00 /* reception receipt number */
+#define GELIC_NET_RXRRECNUM	0x0000ff00 /* reception receipt number */
+#define GELIC_NET_RXRRECNUM_SHIFT	8
 /* bit 7..0 reserved */
 
 #define GELIC_NET_TXDESC_TAIL		0
@@ -129,13 +130,14 @@ enum gelic_net_int1_status {
 
 
 enum gelic_net_descr_status {
-	GELIC_NET_DESCR_COMPLETE            = 0x00, /* used in rx and tx */
+	GELIC_NET_DESCR_COMPLETE            = 0x00, /* used in tx */
+	GELIC_NET_DESCR_BUFFER_FULL         = 0x00, /* used in rx */
 	GELIC_NET_DESCR_RESPONSE_ERROR      = 0x01, /* used in rx and tx */
 	GELIC_NET_DESCR_PROTECTION_ERROR    = 0x02, /* used in rx and tx */
 	GELIC_NET_DESCR_FRAME_END           = 0x04, /* used in rx */
 	GELIC_NET_DESCR_FORCE_END           = 0x05, /* used in rx and tx */
 	GELIC_NET_DESCR_CARDOWNED           = 0x0a, /* used in rx and tx */
-	GELIC_NET_DESCR_NOT_IN_USE                  /* any other value */
+	GELIC_NET_DESCR_NOT_IN_USE          = 0x0b  /* any other value */
 };
 /* for lv1_net_control */
 #define GELIC_NET_GET_MAC_ADDRESS               0x0000000000000001

--
Masakazu MOKUNO

