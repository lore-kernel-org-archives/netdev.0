From: Jon D Mason <jonmason@us.ibm.com>
Subject: Re: [PATCH] r8169 NAPI addition
Date: Fri, 23 Apr 2004 17:27:17 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF8334CD5C.3FE962A9-ON87256E7F.0052C6D7-86256E7F.007AED3E@us.ibm.com>
References: <20040423011834.A3232@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040423011834.A3232@electric-eye.fr.zoreil.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon D Mason <jonmason@us.ibm.com> :
[...]
--- r8169.c              2004-04-18 22:51:33.000000000 -0500
+++ r8169.c              2004-04-22 08:08:57.526577048 -0500
[...]
@@ -1692,6 +1737,31 @@ static struct net_device_stats *rtl8169_
                 return &tp->stats;
 }
 
+#ifdef CONFIG_R8169_NAPI
+static int rtl8169_poll(struct net_device *dev, int *budget)
+{
+                u32 status, work_done = 0, work_to_do = min(*budget, 
dev->quota);
+                struct rtl8169_private *tp = dev->priv;
+                void *ioaddr = tp->mmio_addr;
+ 
+                work_done = rtl8169_rx_interrupt(dev, tp, ioaddr);
+ 
+                *budget -= work_done;
+                dev->quota -= work_done;
+ 
+                if ((work_done < work_to_do) || !netif_running(dev)) {

> Packets are received here.
> Tx interrupt is issued.
> --> Interrupts status register is completely cleared by the irq handler 
<--
> There are pending Rx packets.
> r8169_poll() is not activated by the irq handler.
>
> --> Pending Rx packets may wait long.

+                                netif_rx_complete(dev);
+                                status = RTL_R16(IntrStatus);
+                                if (!status) {
+                                                RTL_W16(IntrMask, 
rtl8169_intr_mask);
+                                                status = 
RTL_R16(IntrMask);
+                                } 

> The previous lines imply that if, according to IntrStatus, there is 
pending
> Rx work but no pending Tx work, the Rx interrupts are kept disabled.

The above was a poor attempt to solve what I thought was the problem you 
were describing before.  The Interrupt Mask should be fully restored 
regardless of pending interrupts.  Will do.

> If I am not mistaken (1:55 AM here), either 1) you do not clear the RX
> related bits of IntrStatus in r8169_interrupt() but you clear it in
> rtl8169_poll() and you add local_irq_{en/dis}able() to rtl8169_poll()
> (ala 8139cp.c) or 2) you modify r8169_interrupt() so that it can signal
> to rtl8169_poll() that it cleared itself the Rx bits of IntrStatus 
whereas
> rtl8169_poll() was running (ala epic100-netdev).
>
>If you hesitate, go for 1). 2) works but I have not benchmarketed it yet 
:o)

I have a few different ideas that I think will solve the problem, but I 
need to think them out first.  I will let you know.  Also, thanks for all 
of your help, hopefully I can get this working properly soon.

>
>If you have doubts regarding your Tx part, feel free to send any code.

I can send you my code, but it might be better to do off the list (as not 
to spam everyone). :-)

Thanks,
Jon
