From: Rui Santos <rsantos@grupopie.com>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Tue, 16 Jun 2009 20:32:31 +0100
Message-ID: <4A37F34F.5010404@grupopie.com>
References: <20090525.225503.173348268.davem@davemloft.net>	<200905262022.24593.mb@bu3sch.de>	<20090526.145211.37114439.davem@davemloft.net> <20090526.151410.109935435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090002030105010006010303"
Cc: mb@bu3sch.de, dave@thedillows.org, michael.riepe@googlemail.com,
	romieu@fr.zoreil.com, m.bueker@berlin.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759228AbZFPTcm@vger.kernel.org>
In-Reply-To: <20090526.151410.109935435.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090002030105010006010303
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 26 May 2009 14:52:11 -0700 (PDT)
>
>   
>> From: Michael Buesch <mb@bu3sch.de>
>> Date: Tue, 26 May 2009 20:22:23 +0200
>>
>>     
>>> I didn't notice a CC:stable.
>>> I think this should also go to stable.
>>> Does somebody take care?
>>>       
>> I'll queue it up.
>>     
>
> Actually, this patch doesn't even remotely come close to applying
> to 2.6.29.4
>
> So if someone wants this in -stable, they need to respin this against
> that tree and (if wanted) 2.6.27.x -stable as well.
>   
Hi David,

Here is a patch for the 2.6.27.25 kernel. Could you please queue it up
to the -stable tree ?

With this patch applied I got no more problems on this XID 24a00000 chip.
Also, for this chip to work I also had to apply this patch:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=9389523a77be0a7e01d957c836733b5c9d5530a1
( with a few changes )
This patch was the first to be committed after the release of 2.6.27 and
it only seems to add support for a few extra NICs.

Thanks a lot for you initial patch.
>
>
>   

-- 

Regards,
Rui Santos



--------------090002030105010006010303
Content-Type: text/x-patch;
 name="msi-r8169-2.6.27.25.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="msi-r8169-2.6.27.25.patch"

diff -upr linux-2.6.27.25.ori/drivers/net/r8169.c linux-2.6.27.25.new/drivers/net/r8169.c
--- linux-2.6.27.25.ori/drivers/net/r8169.c	2009-06-16 17:14:05.000000000 +0100
+++ linux-2.6.27.25.new/drivers/net/r8169.c	2009-06-16 17:41:03.000000000 +0100
@@ -2851,54 +2851,64 @@ static irqreturn_t rtl8169_interrupt(int
 	int handled = 0;
 	int status;
 
+	/* loop handling interrupts until we have no new ones or
+	 * we hit a invalid/hotplug case.
+	 */
 	status = RTL_R16(IntrStatus);
+	while (status && status != 0xffff) {
+		handled = 1;
 
-	/* hotplug/major error/no more work/shared irq */
-	if ((status == 0xffff) || !status)
-		goto out;
-
-	handled = 1;
-
-	if (unlikely(!netif_running(dev))) {
-		rtl8169_asic_down(ioaddr);
-		goto out;
-	}
+		/* Handle all of the error cases first. These will reset
+		 * the chip, so just exit the loop.
+		 */
+		if (unlikely(!netif_running(dev))) {
+			rtl8169_asic_down(ioaddr);
+			break;
+		}
 
-	status &= tp->intr_mask;
-	RTL_W16(IntrStatus,
-		(status & RxFIFOOver) ? (status | RxOverflow) : status);
-
-	if (!(status & tp->intr_event))
-		goto out;
-
-	/* Work around for rx fifo overflow */
-	if (unlikely(status & RxFIFOOver) &&
-	    (tp->mac_version == RTL_GIGA_MAC_VER_11)) {
-		netif_stop_queue(dev);
-		rtl8169_tx_timeout(dev);
-		goto out;
-	}
+		/* Work around for rx fifo overflow */
+		if (unlikely(status & RxFIFOOver) &&
+		(tp->mac_version == RTL_GIGA_MAC_VER_11)) {
+			netif_stop_queue(dev);
+			rtl8169_tx_timeout(dev);
+			break;
+		}
 
-	if (unlikely(status & SYSErr)) {
-		rtl8169_pcierr_interrupt(dev);
-		goto out;
-	}
+		if (unlikely(status & SYSErr)) {
+			rtl8169_pcierr_interrupt(dev);
+			break;
+		}
 
-	if (status & LinkChg)
-		rtl8169_check_link_status(dev, tp, ioaddr);
+		if (status & LinkChg)
+			rtl8169_check_link_status(dev, tp, ioaddr);
 
-	if (status & tp->napi_event) {
-		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
-		tp->intr_mask = ~tp->napi_event;
-
-		if (likely(netif_rx_schedule_prep(dev, &tp->napi)))
-			__netif_rx_schedule(dev, &tp->napi);
-		else if (netif_msg_intr(tp)) {
-			printk(KERN_INFO "%s: interrupt %04x in poll\n",
-			       dev->name, status);
+		/* We need to see the lastest version of tp->intr_mask to
+		 * avoid ignoring an MSI interrupt and having to wait for
+		 * another event which may never come.
+		 */
+		smp_rmb();
+		if (status & tp->intr_mask & tp->napi_event) {
+			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
+			tp->intr_mask = ~tp->napi_event;
+
+			if (likely(napi_schedule_prep(&tp->napi)))
+				__napi_schedule(&tp->napi);
+			else if (netif_msg_intr(tp)) {
+				printk(KERN_INFO "%s: interrupt %04x in poll\n",
+			       	dev->name, status);
+			}
 		}
+
+		/* We only get a new MSI interrupt when all active irq
+		 * sources on the chip have been acknowledged. So, ack
+		 * everything we've seen and check if new sources have become
+		 * active to avoid blocking all interrupts from the chip.
+		 */
+		RTL_W16(IntrStatus,
+			(status & RxFIFOOver) ? (status | RxOverflow) : status);
+		status = RTL_R16(IntrStatus);
 	}
-out:
+
 	return IRQ_RETVAL(handled);
 }
 
@@ -2914,13 +2924,15 @@ static int rtl8169_poll(struct napi_stru
 
 	if (work_done < budget) {
 		netif_rx_complete(dev, napi);
-		tp->intr_mask = 0xffff;
-		/*
-		 * 20040426: the barrier is not strictly required but the
-		 * behavior of the irq handler could be less predictable
-		 * without it. Btw, the lack of flush for the posted pci
-		 * write is safe - FR
+
+		/* We need for force the visibility of tp->intr_mask
+		 * for other CPUs, as we can loose an MSI interrupt
+		 * and potentially wait for a retransmit timeout if we don't.
+		 * The posted write to IntrMask is safe, as it will
+		 * eventually make it to the chip and we won't loose anything
+		 * until it does.
 		 */
+		tp->intr_mask = 0xffff;
 		smp_wmb();
 		RTL_W16(IntrMask, tp->intr_event);
 	}

--------------090002030105010006010303--
