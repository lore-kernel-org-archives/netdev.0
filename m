From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/3) 8139too -- configurable receive ring
Date: Wed, 19 Nov 2003 14:38:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031119143807.0b05a0be.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>,
        OGAWA Hirofumi
 <hirofumi@mail.parknet.co.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For net-drivers-2.5-exp:  Make the receive window configurable and go
back to the original 32K by default.

diff -Nru a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c	Wed Nov 19 14:34:02 2003
+++ b/drivers/net/8139too.c	Wed Nov 19 14:34:02 2003
@@ -128,13 +128,6 @@
 #define USE_IO_OPS 1
 #endif
 
-/* use a 16K rx ring buffer instead of the default 64K */
-#if defined(CONFIG_SH_DREAMCAST) || defined(CONFIG_EMBEDDED)
-#define USE_BUF16K 1
-#else
-#define USE_BUF64K 1
-#endif
-
 /* define to 1 to enable copious debugging info */
 #undef RTL8139_DEBUG
 
@@ -173,20 +166,12 @@
 /* bitmapped message enable number */
 static int debug = -1;
 
-/* Size of the in-memory receive ring. */
-/* 0==8K, 1==16K, 2==32K, 3==64K */
-#ifdef USE_BUF16K
-#define RX_BUF_LEN_IDX	1
-#elif defined(USE_BUF32K)
-#define RX_BUF_LEN_IDX	2
-#else
-#define RX_BUF_LEN_IDX	3
-#endif
-
-#define RX_BUF_LEN	(8192 << RX_BUF_LEN_IDX)
+/* Ring size is now a config option */
+#define RX_BUF_LEN	(8192 << CONFIG_8139_RXBUF_IDX)
 #define RX_BUF_PAD	16
 #define RX_BUF_WRAP_PAD 2048 /* spare padding to handle lack of packet wrap */
-#ifdef USE_BUF64K
+
+#if RX_BUF_LEN == 65536
 #define RX_BUF_TOT_LEN	RX_BUF_LEN
 #else
 #define RX_BUF_TOT_LEN	(RX_BUF_LEN + RX_BUF_PAD + RX_BUF_WRAP_PAD)
@@ -703,23 +688,28 @@
 	PCIErr | PCSTimeout | RxUnderrun |
 	TxErr | TxOK | RxErr ;
 
-#ifdef USE_BUF16K 
+#if CONFIG_8139_RXBUF_IDX == 0
+static const unsigned int rtl8139_rx_config =
+	RxCfgRcv8K | RxNoWrap |
+	(RX_FIFO_THRESH << RxCfgFIFOShift) |
+	(RX_DMA_BURST << RxCfgDMAShift);
+#elif CONFIG_8139_RXBUF_IDX == 1
 static const unsigned int rtl8139_rx_config =
 	RxCfgRcv16K | RxNoWrap |
 	(RX_FIFO_THRESH << RxCfgFIFOShift) |
 	(RX_DMA_BURST << RxCfgDMAShift);
-#elif defined(USE_BUF32K)
+#elif CONFIG_8139_RXBUF_IDX == 2
 static const unsigned int rtl8139_rx_config =
 	RxCfgRcv32K | RxNoWrap |
 	(RX_FIFO_THRESH << RxCfgFIFOShift) |
 	(RX_DMA_BURST << RxCfgDMAShift);
-#elif defined(USE_BUF64K)
+#elif CONFIG_8139_RXBUF_IDX == 3
 static const unsigned int rtl8139_rx_config =
 	RxCfgRcv64K |
 	(RX_FIFO_THRESH << RxCfgFIFOShift) |
 	(RX_DMA_BURST << RxCfgDMAShift);
 #else
-#error "Need to define receive buffer window"
+#error "Invalid configuration for 8139_RXBUF_IDX"
 #endif
 
 static const unsigned int rtl8139_tx_config =
@@ -1916,26 +1906,26 @@
 #endif
 }
 
+#if CONFIG_8139_RXBUF_IDX == 3
 static __inline__ void wrap_copy(struct sk_buff *skb, const unsigned char *ring,
 				 u32 offset, unsigned int size)
 {
-#ifdef USE_BUF64K
 	u32 left = RX_BUF_LEN - offset;
 
 	if (size > left) {
 		memcpy(skb->data, ring + offset, left);
 		memcpy(skb->data+left, ring, size - left);
 	} else
-#endif
 		memcpy(skb->data, ring + offset, size);
 }
+#endif
 
 static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 		      int budget)
 {
 	void *ioaddr = tp->mmio_addr;
 	int received = 0;
-	const unsigned char *rx_ring = tp->rx_ring;
+	unsigned char *rx_ring = tp->rx_ring;
 	unsigned int cur_rx = tp->cur_rx;
 
 	DPRINTK ("%s: In rtl8139_rx(), current %4.4x BufAddr %4.4x,"
@@ -2002,8 +1992,11 @@
 		if (likely(skb)) {
 			skb->dev = dev;
 			skb_reserve (skb, 2);	/* 16 byte align the IP fields. */
+#if CONFIG_8139_RXBUF_IDX == 3
 			wrap_copy(skb, rx_ring, ring_offset+4, pkt_size);
-
+#else
+			eth_copy_and_sum (skb, &rx_ring[ring_offset + 4], pkt_size, 0);
+#endif
 			skb_put (skb, pkt_size);
 
 			skb->protocol = eth_type_trans (skb, dev);
diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	Wed Nov 19 14:34:02 2003
+++ b/drivers/net/Kconfig	Wed Nov 19 14:34:02 2003
@@ -1564,6 +1564,24 @@
 	  experience problems, you can enable this option to restore the
 	  old RX-reset behavior.  If unsure, say N.
 
+config 8139_RXBUF_IDX
+	int "Receive ring size (0 => 8K, 1 => 16K, 2 => 32K, 3 => 64K)"
+	depends on 8139TOO
+	range 0 3
+	default 1 if EMBEDDED || SH_DREAMCAST
+	default 2
+	help
+	   The 8139too driver has a fixed area of memory for receiving data.
+	   The default value is adequate for most systems. The 64KB 
+	   ring size has hardware issues that may cause problems.
+	   Values:
+		0  => 8 KB 
+		1  => 16 KB embedded systems
+		2  => 32 KB default for most systems
+		3  => 64 KB 
+	   If unsure, use the default 2.
+
+
 config SIS900
 	tristate "SiS 900/7016 PCI Fast Ethernet Adapter support"
 	depends on NET_PCI && PCI
