From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next 0/6] net: hip04: fix some problem for hip04 drivers
Date: Wed, 15 Apr 2015 16:25:53 +0200
Message-ID: <3635761.IYy1QBa93a@wuerfel>
References: <1429101008-9464-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, grant.likely@linaro.org,
	sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	zhangfei.gao@linaro.org, joe@perches.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:54291 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbbDOO0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 10:26:32 -0400
In-Reply-To: <1429101008-9464-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 15 April 2015 20:30:02 Ding Tianhong wrote:
> The patches series was used to fix the issues of the hip04 driver, and added
> some optimizations according to some good suggestion. 
> 
> 

Thanks, that looks much better, except for patch 4 that I commented on.

I had at some point sent a patch that is archived at
http://lists.infradead.org/pipermail/linux-arm-kernel/2015-January/318120.html

I believe that one is also still needed, but I have not tested whether it
is correct. Can you have a look at the patch from back then and see if it
works, of if you find something wrong about it?

I'm sending the unmodified patch from then here again for you to apply
or comment. It will have to be rebased on top of your current changes.

	Arnd

8<----
Subject: [PATCH] net/hip04: refactor interrupt masking

The hip04 ethernet driver currently acknowledges all interrupts directly
in the interrupt handler, and leaves all interrupts except the RX data
enabled the whole time. This causes multiple problems:

- When more packets come in between the original interrupt and the
  NAPI poll function, we will get an extraneous RX interrupt as soon
  as interrupts are enabled again.

- The two error interrupts are by definition combining all errors that
  may have happened since the last time they were handled, but just
  acknowledging the irq without dealing with the cause of the condition
  makes it come back immediately. In particular, when NAPI is intentionally
  stalling the rx queue, this causes a storm of "rx dropped" messages.  

- The access to the 'reg_inten' field in hip_priv is used for serializing
  access, but is in fact racy itself.

To deal with these issues, the driver is changed to only acknowledge
the IRQ at the point when it is being handled. The RX interrupts now get
acked right before reading the number of received frames to keep spurious
interrupts to the absolute minimum without losing interrupts.

As there is no tx-complete interrupt, only an informational tx-dropped
one, we now ack that in the tx reclaim handler, hoping that clearing
the descriptors has also eliminated the error condition.

The only place that reads the reg_inten now just relies on
napi_schedule_prep() to return whether NAPI is active or not, and
the poll() function is then going to ack and reenabled the IRQ if
necessary.

Finally, when we disable interrupts, they are now all disabled
together, in order to simplify the logic and to avoid getting
rx-dropped interrupts when NAPI is in control of the rx queue.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 525214ef5984..83773247a368 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -56,6 +56,8 @@
 #define RCV_DROP                       BIT(7)
 #define TX_DROP                                BIT(6)
 #define DEF_INT_ERR                    (RCV_NOBUF | RCV_DROP | TX_DROP)
+#define DEF_INT_RX                     (RCV_INT | RCV_NOBUF | RCV_DROP)
+#define DEF_INT_TX                     (TX_DROP)
 #define DEF_INT_MASK                   (RCV_INT | DEF_INT_ERR)
 
 /* TX descriptor config */
@@ -154,7 +156,6 @@ struct hip04_priv {
        unsigned int port;
        unsigned int speed;
        unsigned int duplex;
-       unsigned int reg_inten;
 
        struct napi_struct napi;
        struct net_device *ndev;
@@ -303,17 +304,15 @@ static void hip04_mac_enable(struct net_device *ndev)
        val |= GE_RX_PORT_EN | GE_TX_PORT_EN;
        writel_relaxed(val, priv->base + GE_PORT_EN);
 
-       /* clear rx int */
-       val = RCV_INT;
-       writel_relaxed(val, priv->base + PPE_RINT);
+       /* clear prior interrupts */
+       writel_relaxed(DEF_INT_MASK, priv->base + PPE_RINT);
 
        /* config recv int */
        val = GE_RX_INT_THRESHOLD | GE_RX_TIMEOUT;
        writel_relaxed(val, priv->base + PPE_CFG_RX_PKT_INT);
 
        /* enable interrupt */
-       priv->reg_inten = DEF_INT_MASK;
-       writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
+       writel_relaxed(DEF_INT_MASK, priv->base + PPE_INTEN);
 }
 
 static void hip04_mac_disable(struct net_device *ndev)
@@ -322,8 +321,7 @@ static void hip04_mac_disable(struct net_device *ndev)
        u32 val;
 
        /* disable int */
-       priv->reg_inten &= ~(DEF_INT_MASK);
-       writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
+       writel_relaxed(0, priv->base + PPE_INTEN);
 
        /* disable tx & rx */
        val = readl_relaxed(priv->base + GE_PORT_EN);
@@ -403,6 +401,8 @@ static int hip04_tx_reclaim(struct net_device *ndev, bool force)
        priv->tx_tail = tx_tail;
        smp_wmb(); /* Ensure tx_tail visible to xmit */
 
+       writel_relaxed(DEF_INT_TX, priv->base + PPE_RINT);
+
 out:
        if (pkts_compl || bytes_compl)
                netdev_completed_queue(ndev, pkts_compl, bytes_compl);
@@ -458,9 +458,7 @@ static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
        if (count >= priv->tx_coalesce_frames) {
                if (napi_schedule_prep(&priv->napi)) {
                        /* disable rx interrupt and timer */
-                       priv->reg_inten &= ~(RCV_INT);
-                       writel_relaxed(DEF_INT_MASK & ~RCV_INT,
-                                      priv->base + PPE_INTEN);
+                       writel_relaxed(0, priv->base + PPE_INTEN);
                        hrtimer_cancel(&priv->tx_coalesce_timer);
                        __napi_schedule(&priv->napi);
                }
@@ -478,7 +476,7 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
        struct hip04_priv *priv = container_of(napi, struct hip04_priv, napi);
        struct net_device *ndev = priv->ndev;
        struct net_device_stats *stats = &ndev->stats;
-       unsigned int cnt = hip04_recv_cnt(priv);
+       unsigned int cnt;
        struct rx_desc *desc;
        struct sk_buff *skb;
        unsigned char *buf;
@@ -489,6 +487,10 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
        u16 len;
        u32 err;
 
+       /* acknowledge interrupts and read status */
+       writel_relaxed(DEF_INT_RX, priv->base + PPE_RINT);
+       cnt = hip04_recv_cnt(priv);
+
        while (cnt && !last) {
                buf = priv->rx_buf[priv->rx_head];
                skb = build_skb(buf, priv->rx_buf_size);
@@ -539,11 +541,8 @@ static int hip04_rx_poll(struct napi_struct *napi, int budget)
                        cnt = hip04_recv_cnt(priv);
        }
 
-       if (!(priv->reg_inten & RCV_INT)) {
-               /* enable rx interrupt */
-               priv->reg_inten |= RCV_INT;
-               writel_relaxed(priv->reg_inten, priv->base + PPE_INTEN);
-       }
+       /* enable rx interrupt */
+       writel_relaxed(DEF_INT_MASK, priv->base + PPE_INTEN);
        napi_complete(napi);
 done:
        /* clean up tx descriptors and start a new timer if necessary */
@@ -564,23 +563,21 @@ static irqreturn_t hip04_mac_interrupt(int irq, void *dev_id)
        if (!ists)
                return IRQ_NONE;
 
-       writel_relaxed(DEF_INT_MASK, priv->base + PPE_RINT);
-
        if (unlikely(ists & DEF_INT_ERR)) {
-               if (ists & (RCV_NOBUF | RCV_DROP))
+               if (ists & (RCV_NOBUF | RCV_DROP)) {
                        stats->rx_errors++;
                        stats->rx_dropped++;
-                       netdev_err(ndev, "rx drop\n");
+                       netdev_dbg(ndev, "rx drop\n");
+               }
                if (ists & TX_DROP) {
                        stats->tx_dropped++;
-                       netdev_err(ndev, "tx drop\n");
+                       netdev_dbg(ndev, "tx drop\n");
                }
        }
 
-       if (ists & RCV_INT && napi_schedule_prep(&priv->napi)) {
-               /* disable rx interrupt */
-               priv->reg_inten &= ~(RCV_INT);
-               writel_relaxed(DEF_INT_MASK & ~RCV_INT, priv->base + PPE_INTEN);
+       if (napi_schedule_prep(&priv->napi)) {
+               /* disable interrupt */
+               writel_relaxed(0, priv->base + PPE_INTEN);
                hrtimer_cancel(&priv->tx_coalesce_timer);
                __napi_schedule(&priv->napi);
        }
@@ -596,8 +593,7 @@ enum hrtimer_restart tx_done(struct hrtimer *hrtimer)
 
        if (napi_schedule_prep(&priv->napi)) {
                /* disable rx interrupt */
-               priv->reg_inten &= ~(RCV_INT);
-               writel_relaxed(DEF_INT_MASK & ~RCV_INT, priv->base + PPE_INTEN);
+               writel_relaxed(0, priv->base + PPE_INTEN);
                __napi_schedule(&priv->napi);
        }
 
