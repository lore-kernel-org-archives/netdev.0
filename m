From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/3] r8169: code clean-up
Date: Fri, 18 Feb 2005 00:28:04 +0100
Message-ID: <20050217232804.GA4992@electric-eye.fr.zoreil.com>
References: <200502161823.43562.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200502161823.43562.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
> This patch removes netif_poll_disable if NAPI is not enabled (otherwise 
> adapter will hang while changing MTUs).

I am currently running a non-napi r8169 on x86/sparc64 based on 2.6.11-rc4
+ patches in Jeff's netdev and it apparently does not mind change of mtu.

How am I supposed to make it hang ?

> This patch also fixes a possible skb alignment overrun,

Ok. Added some bits, see below.

> and fixes the rx skb allocation error logging. It also 

Ok. I'd rather see it as shown below though (cuts some code and more
ppc-friendly unsigned ints).

> removes an unnecessary define,

Ok.

> adds a link down notification, and cleans up 

Ok. I'll netif_msg it before someone else complains that the driver
is too verbose.

----------------------8<-----------------------------------------

Fix rx skb allocation error logging

Signed arithmetic is not required as rtl8169_rx_fill() return belongs
to the [0; NUM_RX_DESC] interval.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-400 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-400	2005-02-17 21:50:09.820173216 +0100
+++ b/drivers/net/r8169.c	2005-02-17 22:00:00.210450784 +0100
@@ -2156,8 +2156,8 @@ static int
 rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 		     void __iomem *ioaddr)
 {
-	unsigned int cur_rx, rx_left, count;
-	int delta;
+	unsigned int cur_rx, rx_left;
+	unsigned int delta, count;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
@@ -2225,10 +2225,8 @@ rtl8169_rx_interrupt(struct net_device *
 	tp->cur_rx = cur_rx;
 
 	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
-	if (delta < 0) {
+	if (!delta && count)
 		printk(KERN_INFO "%s: no Rx buffer allocated\n", dev->name);
-		delta = 0;
-	}
 	tp->dirty_rx += delta;
 
 	/*

_

Nail an overrun in skb alignment and remove the relevant magic variable.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-410 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-410	2005-02-17 22:13:04.209897364 +0100
+++ b/drivers/net/r8169.c	2005-02-17 22:17:25.747969121 +0100
@@ -1697,11 +1697,11 @@ static int rtl8169_alloc_rx_skb(struct p
 	dma_addr_t mapping;
 	int ret = 0;
 
-	skb = dev_alloc_skb(rx_buf_sz);
+	skb = dev_alloc_skb(rx_buf_sz + NET_IP_ALIGN);
 	if (!skb)
 		goto err_out;
 
-	skb_reserve(skb, 2);
+	skb_reserve(skb, NET_IP_ALIGN);
 	*sk_buff = skb;
 
 	mapping = pci_map_single(pdev, skb->tail, rx_buf_sz,
@@ -2140,9 +2140,9 @@ static inline int rtl8169_try_rx_copy(st
 	if (pkt_size < rx_copybreak) {
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(pkt_size + 2);
+		skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
 		if (skb) {
-			skb_reserve(skb, 2);
+			skb_reserve(skb, NET_IP_ALIGN);
 			eth_copy_and_sum(skb, sk_buff[0]->tail, pkt_size, 0);
 			*sk_buff = skb;
 			rtl8169_return_to_asic(desc, rx_buf_sz);

_


--
Ueimor
