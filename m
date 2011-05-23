From: akpm@linux-foundation.org
Subject: [patch 1/1] net/irda: convert bfin_sir to common Blackfin UART header
Date: Mon, 23 May 2011 15:17:09 -0700
Message-ID: <201105232217.p4NMH9uH015477@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	vapier@gentoo.org, davem@davemloft.net
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57467 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934232Ab1EWWRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 18:17:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>

No need to duplicate these defines now that the common Blackfin code has
unified these for all UART devices.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/irda/bfin_sir.c |   59 +++++++++++++++----------------
 drivers/net/irda/bfin_sir.h |   63 ++--------------------------------
 2 files changed, 33 insertions(+), 89 deletions(-)

diff -puN drivers/net/irda/bfin_sir.c~net-irda-convert-bfin_sir-to-common-blackfin-uart-header drivers/net/irda/bfin_sir.c
--- a/drivers/net/irda/bfin_sir.c~net-irda-convert-bfin_sir-to-common-blackfin-uart-header
+++ a/drivers/net/irda/bfin_sir.c
@@ -67,27 +67,27 @@ static void bfin_sir_stop_tx(struct bfin
 	disable_dma(port->tx_dma_channel);
 #endif
 
-	while (!(SIR_UART_GET_LSR(port) & THRE)) {
+	while (!(UART_GET_LSR(port) & THRE)) {
 		cpu_relax();
 		continue;
 	}
 
-	SIR_UART_STOP_TX(port);
+	UART_CLEAR_IER(port, ETBEI);
 }
 
 static void bfin_sir_enable_tx(struct bfin_sir_port *port)
 {
-	SIR_UART_ENABLE_TX(port);
+	UART_SET_IER(port, ETBEI);
 }
 
 static void bfin_sir_stop_rx(struct bfin_sir_port *port)
 {
-	SIR_UART_STOP_RX(port);
+	UART_CLEAR_IER(port, ERBFI);
 }
 
 static void bfin_sir_enable_rx(struct bfin_sir_port *port)
 {
-	SIR_UART_ENABLE_RX(port);
+	UART_SET_IER(port, ERBFI);
 }
 
 static int bfin_sir_set_speed(struct bfin_sir_port *port, int speed)
@@ -116,7 +116,7 @@ static int bfin_sir_set_speed(struct bfi
 
 		do {
 			udelay(utime);
-			lsr = SIR_UART_GET_LSR(port);
+			lsr = UART_GET_LSR(port);
 		} while (!(lsr & TEMT) && count--);
 
 		/* The useconds for 1 bits to transmit */
@@ -125,27 +125,27 @@ static int bfin_sir_set_speed(struct bfi
 		/* Clear UCEN bit to reset the UART state machine
 		 * and control registers
 		 */
-		val = SIR_UART_GET_GCTL(port);
+		val = UART_GET_GCTL(port);
 		val &= ~UCEN;
-		SIR_UART_PUT_GCTL(port, val);
+		UART_PUT_GCTL(port, val);
 
 		/* Set DLAB in LCR to Access THR RBR IER */
-		SIR_UART_SET_DLAB(port);
+		UART_SET_DLAB(port);
 		SSYNC();
 
-		SIR_UART_PUT_DLL(port, quot & 0xFF);
-		SIR_UART_PUT_DLH(port, (quot >> 8) & 0xFF);
+		UART_PUT_DLL(port, quot & 0xFF);
+		UART_PUT_DLH(port, (quot >> 8) & 0xFF);
 		SSYNC();
 
 		/* Clear DLAB in LCR */
-		SIR_UART_CLEAR_DLAB(port);
+		UART_CLEAR_DLAB(port);
 		SSYNC();
 
-		SIR_UART_PUT_LCR(port, lcr);
+		UART_PUT_LCR(port, lcr);
 
-		val = SIR_UART_GET_GCTL(port);
+		val = UART_GET_GCTL(port);
 		val |= UCEN;
-		SIR_UART_PUT_GCTL(port, val);
+		UART_PUT_GCTL(port, val);
 
 		ret = 0;
 		break;
@@ -154,12 +154,12 @@ static int bfin_sir_set_speed(struct bfi
 		break;
 	}
 
-	val = SIR_UART_GET_GCTL(port);
+	val = UART_GET_GCTL(port);
 	/* If not add the 'RPOLC', we can't catch the receive interrupt.
 	 * It's related with the HW layout and the IR transiver.
 	 */
 	val |= IREN | RPOLC;
-	SIR_UART_PUT_GCTL(port, val);
+	UART_PUT_GCTL(port, val);
 	return ret;
 }
 
@@ -168,7 +168,7 @@ static int bfin_sir_is_receiving(struct 
 	struct bfin_sir_self *self = netdev_priv(dev);
 	struct bfin_sir_port *port = self->sir_port;
 
-	if (!(SIR_UART_GET_IER(port) & ERBFI))
+	if (!(UART_GET_IER(port) & ERBFI))
 		return 0;
 	return self->rx_buff.state != OUTSIDE_FRAME;
 }
@@ -182,7 +182,7 @@ static void bfin_sir_tx_chars(struct net
 
 	if (self->tx_buff.len != 0) {
 		chr = *(self->tx_buff.data);
-		SIR_UART_PUT_CHAR(port, chr);
+		UART_PUT_CHAR(port, chr);
 		self->tx_buff.data++;
 		self->tx_buff.len--;
 	} else {
@@ -206,8 +206,8 @@ static void bfin_sir_rx_chars(struct net
 	struct bfin_sir_port *port = self->sir_port;
 	unsigned char ch;
 
-	SIR_UART_CLEAR_LSR(port);
-	ch = SIR_UART_GET_CHAR(port);
+	UART_CLEAR_LSR(port);
+	ch = UART_GET_CHAR(port);
 	async_unwrap_char(dev, &self->stats, &self->rx_buff, ch);
 	dev->last_rx = jiffies;
 }
@@ -219,7 +219,7 @@ static irqreturn_t bfin_sir_rx_int(int i
 	struct bfin_sir_port *port = self->sir_port;
 
 	spin_lock(&self->lock);
-	while ((SIR_UART_GET_LSR(port) & DR))
+	while ((UART_GET_LSR(port) & DR))
 		bfin_sir_rx_chars(dev);
 	spin_unlock(&self->lock);
 
@@ -233,7 +233,7 @@ static irqreturn_t bfin_sir_tx_int(int i
 	struct bfin_sir_port *port = self->sir_port;
 
 	spin_lock(&self->lock);
-	if (SIR_UART_GET_LSR(port) & THRE)
+	if (UART_GET_LSR(port) & THRE)
 		bfin_sir_tx_chars(dev);
 	spin_unlock(&self->lock);
 
@@ -312,7 +312,7 @@ static void bfin_sir_dma_rx_chars(struct
 	struct bfin_sir_port *port = self->sir_port;
 	int i;
 
-	SIR_UART_CLEAR_LSR(port);
+	UART_CLEAR_LSR(port);
 
 	for (i = port->rx_dma_buf.head; i < port->rx_dma_buf.tail; i++)
 		async_unwrap_char(dev, &self->stats, &self->rx_buff, port->rx_dma_buf.buf[i]);
@@ -430,11 +430,10 @@ static void bfin_sir_shutdown(struct bfi
 	unsigned short val;
 
 	bfin_sir_stop_rx(port);
-	SIR_UART_DISABLE_INTS(port);
 
-	val = SIR_UART_GET_GCTL(port);
+	val = UART_GET_GCTL(port);
 	val &= ~(UCEN | IREN | RPOLC);
-	SIR_UART_PUT_GCTL(port, val);
+	UART_PUT_GCTL(port, val);
 
 #ifdef CONFIG_SIR_BFIN_DMA
 	disable_dma(port->tx_dma_channel);
@@ -518,12 +517,12 @@ static void bfin_sir_send_work(struct wo
 	 * sending data. We also can set the speed, which will
 	 * reset all the UART.
 	 */
-	val = SIR_UART_GET_GCTL(port);
+	val = UART_GET_GCTL(port);
 	val &= ~(IREN | RPOLC);
-	SIR_UART_PUT_GCTL(port, val);
+	UART_PUT_GCTL(port, val);
 	SSYNC();
 	val |= IREN | RPOLC;
-	SIR_UART_PUT_GCTL(port, val);
+	UART_PUT_GCTL(port, val);
 	SSYNC();
 	/* bfin_sir_set_speed(port, self->speed); */
 
diff -puN drivers/net/irda/bfin_sir.h~net-irda-convert-bfin_sir-to-common-blackfin-uart-header drivers/net/irda/bfin_sir.h
--- a/drivers/net/irda/bfin_sir.h~net-irda-convert-bfin_sir-to-common-blackfin-uart-header
+++ a/drivers/net/irda/bfin_sir.h
@@ -26,7 +26,6 @@
 #include <asm/cacheflush.h>
 #include <asm/dma.h>
 #include <asm/portmux.h>
-#include <mach/bfin_serial_5xx.h>
 #undef DRIVER_NAME
 
 #ifdef CONFIG_SIR_BFIN_DMA
@@ -83,64 +82,10 @@ struct bfin_sir_self {
 
 #define DRIVER_NAME "bfin_sir"
 
-#define SIR_UART_GET_CHAR(port)    bfin_read16((port)->membase + OFFSET_RBR)
-#define SIR_UART_GET_DLL(port)     bfin_read16((port)->membase + OFFSET_DLL)
-#define SIR_UART_GET_DLH(port)     bfin_read16((port)->membase + OFFSET_DLH)
-#define SIR_UART_GET_LCR(port)     bfin_read16((port)->membase + OFFSET_LCR)
-#define SIR_UART_GET_GCTL(port)    bfin_read16((port)->membase + OFFSET_GCTL)
-
-#define SIR_UART_PUT_CHAR(port, v) bfin_write16(((port)->membase + OFFSET_THR), v)
-#define SIR_UART_PUT_DLL(port, v)  bfin_write16(((port)->membase + OFFSET_DLL), v)
-#define SIR_UART_PUT_DLH(port, v)  bfin_write16(((port)->membase + OFFSET_DLH), v)
-#define SIR_UART_PUT_LCR(port, v)  bfin_write16(((port)->membase + OFFSET_LCR), v)
-#define SIR_UART_PUT_GCTL(port, v) bfin_write16(((port)->membase + OFFSET_GCTL), v)
-
-#ifdef CONFIG_BF54x
-#define SIR_UART_GET_LSR(port)     bfin_read16((port)->membase + OFFSET_LSR)
-#define SIR_UART_GET_IER(port)     bfin_read16((port)->membase + OFFSET_IER_SET)
-#define SIR_UART_SET_IER(port, v)  bfin_write16(((port)->membase + OFFSET_IER_SET), v)
-#define SIR_UART_CLEAR_IER(port, v) bfin_write16(((port)->membase + OFFSET_IER_CLEAR), v)
-#define SIR_UART_PUT_LSR(port, v)  bfin_write16(((port)->membase + OFFSET_LSR), v)
-#define SIR_UART_CLEAR_LSR(port)   bfin_write16(((port)->membase + OFFSET_LSR), -1)
-
-#define SIR_UART_SET_DLAB(port)
-#define SIR_UART_CLEAR_DLAB(port)
-
-#define SIR_UART_ENABLE_INTS(port, v) SIR_UART_SET_IER(port, v)
-#define SIR_UART_DISABLE_INTS(port)   SIR_UART_CLEAR_IER(port, 0xF)
-#define SIR_UART_STOP_TX(port)     do { SIR_UART_PUT_LSR(port, TFI); SIR_UART_CLEAR_IER(port, ETBEI); } while (0)
-#define SIR_UART_ENABLE_TX(port)   do { SIR_UART_SET_IER(port, ETBEI); } while (0)
-#define SIR_UART_STOP_RX(port)     do { SIR_UART_CLEAR_IER(port, ERBFI); } while (0)
-#define SIR_UART_ENABLE_RX(port)   do { SIR_UART_SET_IER(port, ERBFI); } while (0)
-#else
-
-#define SIR_UART_GET_IIR(port)     bfin_read16((port)->membase + OFFSET_IIR)
-#define SIR_UART_GET_IER(port)     bfin_read16((port)->membase + OFFSET_IER)
-#define SIR_UART_PUT_IER(port, v)  bfin_write16(((port)->membase + OFFSET_IER), v)
-
-#define SIR_UART_SET_DLAB(port)    do { SIR_UART_PUT_LCR(port, SIR_UART_GET_LCR(port) | DLAB); } while (0)
-#define SIR_UART_CLEAR_DLAB(port)  do { SIR_UART_PUT_LCR(port, SIR_UART_GET_LCR(port) & ~DLAB); } while (0)
-
-#define SIR_UART_ENABLE_INTS(port, v) SIR_UART_PUT_IER(port, v)
-#define SIR_UART_DISABLE_INTS(port)   SIR_UART_PUT_IER(port, 0)
-#define SIR_UART_STOP_TX(port)     do { SIR_UART_PUT_IER(port, SIR_UART_GET_IER(port) & ~ETBEI); } while (0)
-#define SIR_UART_ENABLE_TX(port)   do { SIR_UART_PUT_IER(port, SIR_UART_GET_IER(port) | ETBEI); } while (0)
-#define SIR_UART_STOP_RX(port)     do { SIR_UART_PUT_IER(port, SIR_UART_GET_IER(port) & ~ERBFI); } while (0)
-#define SIR_UART_ENABLE_RX(port)   do { SIR_UART_PUT_IER(port, SIR_UART_GET_IER(port) | ERBFI); } while (0)
-
-static inline unsigned int SIR_UART_GET_LSR(struct bfin_sir_port *port)
-{
-	unsigned int lsr = bfin_read16(port->membase + OFFSET_LSR);
-	port->lsr |= (lsr & (BI|FE|PE|OE));
-	return lsr | port->lsr;
-}
-
-static inline void SIR_UART_CLEAR_LSR(struct bfin_sir_port *port)
-{
-	port->lsr = 0;
-	bfin_read16(port->membase + OFFSET_LSR);
-}
-#endif
+#define port_membase(port)     (((struct bfin_sir_port *)(port))->membase)
+#define get_lsr_cache(port)    (((struct bfin_sir_port *)(port))->lsr)
+#define put_lsr_cache(port, v) (((struct bfin_sir_port *)(port))->lsr = (v))
+#include <asm/bfin_serial.h>
 
 static const unsigned short per[][4] = {
 	/* rx pin      tx pin     NULL  uart_number */
_
