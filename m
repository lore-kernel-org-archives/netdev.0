From: Nicolae Rosia <nicolae.rosia@gmail.com>
Subject: Re: macb napi strange behavior
Date: Fri, 26 Jun 2015 20:50:30 +0300
Message-ID: <CAH=tA9F+hhKvbGaTb7j9km4niRR3K89MEgjz=aah9rB4A_tG4A@mail.gmail.com>
References: <CAH=tA9FfYh_XSg7y=TujXwuvrjvgg+hOY1j_UOyJNK5mrwaBCw@mail.gmail.com>
	<5581C27C.4040408@ni.com>
	<CAH=tA9HCqKgSFwMczRJ1hb=Sjb1H5XFg00ddRq=BW+_8OZ0ARQ@mail.gmail.com>
	<CAGVrzcZxPqyp3CDLc-UQejtVg1QVv5OBuGLQNVSrtfG9H1OUnA@mail.gmail.com>
	<20150620164332.GA2505@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Jaeden Amero <jaeden.amero@ni.com>,
	netdev <netdev@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Josh Cartwright <joshc@ni.com>,
	"David S. Miller" <davem@davemloft.net>,
	Bogdan Chifor <chiforbogdan86@gmail.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:36814 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbbFZRuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 13:50:32 -0400
Received: by lacny3 with SMTP id ny3so67931371lac.3
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 10:50:30 -0700 (PDT)
In-Reply-To: <20150620164332.GA2505@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I gave it a shot. Can you please take a look?
I don't know how to deal with multiple queues since Zynq 7000 has one
queue per interface.
I get a performance improvement of over 110 Mbps in IP forwarding (680
Mbps vs 570 Mbps) and a massive reduction of interrupts.

Patch below.

From: Nicolae Rosia <nicolae.rosia@certsign.ro>
Date: Fri, 26 Jun 2015 19:44:50 +0300
Subject: [PATCH] macb: use tx napi

---
 drivers/net/ethernet/cadence/macb.c | 37 ++++++++++++++++++++++++++++++++++---
 1 file changed, 34 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c
b/drivers/net/ethernet/cadence/macb.c
index 30eedb1..2a3ecf7 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -602,10 +602,13 @@ static void macb_tx_interrupt(struct macb_queue *queue)
 {
     unsigned int tail;
     unsigned int head;
+#if 0
     u32 status;
+#endif
     struct macb *bp = queue->bp;
     u16 queue_index = queue - bp->queues;

+#if 0
     status = macb_readl(bp, TSR);
     macb_writel(bp, TSR, status);

@@ -614,6 +617,7 @@ static void macb_tx_interrupt(struct macb_queue *queue)

     netdev_vdbg(bp->dev, "macb_tx_interrupt status = 0x%03lx\n",
         (unsigned long)status);
+#endif

     head = queue->tx_head;
     for (tail = queue->tx_tail; tail != head; tail++) {
@@ -951,12 +955,17 @@ static int macb_poll(struct napi_struct *napi, int budget)
     status = macb_readl(bp, RSR);
     macb_writel(bp, RSR, status);

-    work_done = 0;
+    status = macb_readl(bp, TSR);
+    if (status) {
+        macb_writel(bp, TSR, status);
+        macb_tx_interrupt(&bp->queues[0]);
+    }

     netdev_vdbg(bp->dev, "poll: status = %08lx, budget = %d\n",
            (unsigned long)status, budget);

     work_done = bp->macbgem_ops.mog_rx(bp, budget);
+
     if (work_done < budget) {
         napi_complete(napi);

@@ -969,6 +978,16 @@ static int macb_poll(struct napi_struct *napi, int budget)
         } else {
             macb_writel(bp, IER, MACB_RX_INT_FLAGS);
         }
+
+        /* Packets received while interrupts were disabled */
+        status = macb_readl(bp, TSR);
+        if (status) {
+            if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+                macb_writel(bp, ISR, MACB_BIT(TCOMP));
+            napi_reschedule(napi);
+        } else {
+            macb_writel(bp, IER, MACB_TX_INT_FLAGS);
+        }
     }

     /* TODO: Handle errors */
@@ -1029,8 +1048,17 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
             break;
         }

-        if (status & MACB_BIT(TCOMP))
-            macb_tx_interrupt(queue);
+        if (status & MACB_BIT(TCOMP)) {
+            /* disable tx interrupts */
+            queue_writel(queue, IDR, MACB_TX_INT_FLAGS);
+            if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+                queue_writel(queue, ISR, MACB_BIT(TCOMP));
+
+            if (napi_schedule_prep(&bp->napi)) {
+                netdev_vdbg(bp->dev, "scheduling TX softirq\n");
+                __napi_schedule(&bp->napi);
+            }
+        }

         /*
          * Link change detection isn't possible with RMII, so we'll
@@ -2348,6 +2376,7 @@ static int macb_probe(struct platform_device *pdev)
     }

     macb_probe_queues(mem, &queue_mask, &num_queues);
+    dev_err(&pdev->dev, "queue count: %d.\n", num_queues);
     dev = alloc_etherdev_mq(sizeof(*bp), num_queues);
     if (!dev)
         goto err_out_disable_clocks;
@@ -2377,6 +2406,8 @@ static int macb_probe(struct platform_device *pdev)
         if (!(queue_mask & (1 << hw_q)))
             continue;

+        dev_err(&pdev->dev, "queue index: %d\n", q);
+
         queue = &bp->queues[q];
         queue->bp = bp;
         if (hw_q) {
-- 
2.1.0

On Sat, Jun 20, 2015 at 7:43 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Florian Fainelli <f.fainelli@gmail.com> :
> [...]
>> Typically, NAPI is used at the receive side of the Ethernet NIC/driver
>> to lower the hard/soft interrupt context switch, although there is
>> nothing that prevent you to implement a similar scheme for the
>> transmit side. Usually, for transmit you will be submitting one packet
>> for transmission and get a completion interrupt, so without interrupt
>> coalescing (software or hardware) you can end-up with 1 interrupt per
>> packet transmitted.
>
> The wording is a bit shy: there is a long standing policy to move
> everything to NAPI context (as well as go mostly lockless, etc.).
>
> Any taker to move macb Tx processing to NAPI context or should I consider it ?
>
> --
> Ueimor
