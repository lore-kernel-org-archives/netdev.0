From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] cleanup large frame handling for natsemi.c
Date: Sun, 20 Jun 2004 18:43:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D5BE9B.9040106@colorfullife.com>
References: <40D57FC3.9040008@colorfullife.com> <20040620163036.GD16038@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030406000600000305080208"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20040620163036.GD16038@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030406000600000305080208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Garzik wrote:

>On Sun, Jun 20, 2004 at 02:14:59PM +0200, Manfred Spraul wrote:
>  
>
>>Jeff, could you apply it? I've stress tested vlan for an hour with 
>>tbench and parallel kernel compiles, not obvious problems.
>>    
>>
>
>I would if you had actually included a patch ;-)
>
>  
>
Ups, sorry. Here's the patch.

--
    Manfred

--------------030406000600000305080208
Content-Type: text/plain;
 name="patch-natsemi-long"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-natsemi-long"

--- 2.6/drivers/net/natsemi.c	2004-06-20 11:24:02.959200463 +0200
+++ build-2.6/drivers/net/natsemi.c	2004-06-20 12:11:31.170607816 +0200
@@ -236,7 +236,14 @@
 #define NATSEMI_REGS_SIZE	(NATSEMI_NREGS * sizeof(u32))
 #define NATSEMI_EEPROM_SIZE	24 /* 12 16-bit values */
 
-#define PKT_BUF_SZ		1536 /* Size of each temporary Rx buffer. */
+/* Buffer sizes:
+ * The nic writes 32-bit values, even if the upper bytes of
+ * a 32-bit value are beyond the end of the buffer.
+ */
+#define NATSEMI_HEADERS		22	/* 2*mac,type,vlan,crc */
+#define NATSEMI_PADDING		64	/* 2 bytes should be sufficient */
+#define NATSEMI_LONGPKT		1518	/* limit for long packets */
+#define NATSEMI_RX_LIMIT	2046	/* maximum supported by hardware */
 
 /* These identify the driver base version and may not be removed. */
 static char version[] __devinitdata =
@@ -1688,7 +1695,7 @@
 	 */
 	np->rx_config = RxMxdma_256 | 0x20;
 	/* if receive ring now has bigger buffers than normal, enable jumbo */
-	if (np->rx_buf_sz > PKT_BUF_SZ)
+	if (np->rx_buf_sz > NATSEMI_LONGPKT)
 		np->rx_config |= RxAcceptLong;
 
 	writel(np->rx_config, ioaddr + RxConfig);
@@ -1870,7 +1877,7 @@
 		struct sk_buff *skb;
 		int entry = np->dirty_rx % RX_RING_SIZE;
 		if (np->rx_skbuff[entry] == NULL) {
-			unsigned int buflen = np->rx_buf_sz + RX_OFFSET;
+			unsigned int buflen = np->rx_buf_sz+NATSEMI_PADDING;
 			skb = dev_alloc_skb(buflen);
 			np->rx_skbuff[entry] = skb;
 			if (skb == NULL)
@@ -1909,9 +1916,13 @@
 	np->dirty_rx = 0;
 	np->cur_rx = RX_RING_SIZE;
 	np->oom = 0;
-	np->rx_buf_sz = PKT_BUF_SZ;
-	if (dev->mtu > ETH_DATA_LEN)
-		np->rx_buf_sz += dev->mtu - ETH_DATA_LEN;
+	if (dev->mtu <= ETH_DATA_LEN)
+		np->rx_buf_sz = ETH_DATA_LEN + NATSEMI_HEADERS;
+	else
+		np->rx_buf_sz = dev->mtu + NATSEMI_HEADERS;
+	if (np->rx_buf_sz > NATSEMI_RX_LIMIT)
+		np->rx_buf_sz = NATSEMI_RX_LIMIT;
+
 	np->rx_head_desc = &np->rx_ring[0];
 
 	/* Please be carefull before changing this loop - at least gcc-2.95.1
@@ -1949,7 +1960,7 @@
 static void drain_ring(struct net_device *dev)
 {
 	struct netdev_private *np = dev->priv;
-	unsigned int buflen = np->rx_buf_sz + RX_OFFSET;
+	unsigned int buflen = np->rx_buf_sz;
 	int i;
 
 	/* Free all the skbuffs in the Rx queue. */
@@ -2154,7 +2165,7 @@
 	int entry = np->cur_rx % RX_RING_SIZE;
 	int boguscnt = np->dirty_rx + RX_RING_SIZE - np->cur_rx;
 	s32 desc_status = le32_to_cpu(np->rx_head_desc->cmd_status);
-	unsigned int buflen = np->rx_buf_sz + RX_OFFSET;
+	unsigned int buflen = np->rx_buf_sz;
 
 	/* If the driver owns the next entry it's a new packet. Send it up. */
 	while (desc_status < 0) { /* e.g. & DescOwn */
@@ -2881,6 +2892,7 @@
 	}
 	return 0;
 }
+
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct mii_ioctl_data *data = if_mii(rq);

--------------030406000600000305080208--
