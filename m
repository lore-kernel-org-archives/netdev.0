From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: MSI interrupts and disable_irq
Date: Sun, 14 Oct 2007 09:15:35 +0200
Message-ID: <4711C217.2010605@colorfullife.com>
References: <46FC15A9.1070803@nvidia.com> <46FDBCB4.9090802@pobox.com>	 <4710901F.8010206@colorfullife.com> <86802c440710132259o6e82f6s4bed7b25bd5636e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050200000607050106040705"
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	nedev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ev1s-75-125-39-150.ev1servers.net ([75.125.39.150]:40685 "EHLO
	colorfullife.mysite.adiungo.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751458AbXJNHQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 03:16:37 -0400
In-Reply-To: <86802c440710132259o6e82f6s4bed7b25bd5636e9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050200000607050106040705
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Yinghai Lu wrote:
> On 10/13/07, Manfred Spraul <manfred@colorfullife.com> wrote:
>   
>> Someone around with a MSI capable board? The forcedeth driver does
>>     dev->irq = pci_dev->irq
>> in nv_probe(), especially before pci_enable_msi().
>> Does pci_enable_msi() change pci_dev->irq? Then we would disable the
>> wrong interrupt....
>>     
>
> the request_irq==>setup_irq will make dev->irq = pci_dev->irq.
>
>   
Where is that?
Otherwise I would propose the attached patch. My board is not 
MSI-capable, thus I can't test it myself.

--
    Manfred

--------------050200000607050106040705
Content-Type: text/plain;
 name="patch-forcedeth-msi"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-msi"

--- 2.6/drivers/net/forcedeth.c	2007-10-07 17:33:18.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2007-10-13 11:34:20.000000000 +0200
@@ -988,7 +988,7 @@
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
-			enable_irq(dev->irq);
+			enable_irq(np->pci_dev->irq);
 	} else {
 		enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 		enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector);
@@ -1004,7 +1004,7 @@
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
-			disable_irq(dev->irq);
+			disable_irq(np->pci_dev->irq);
 	} else {
 		disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 		disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector);
@@ -1601,7 +1601,7 @@
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
-			disable_irq(dev->irq);
+			disable_irq(np->pci_dev->irq);
 	} else {
 		disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 	}
@@ -1619,7 +1619,7 @@
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
-			enable_irq(dev->irq);
+			enable_irq(np->pci_dev->irq);
 	} else {
 		enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 	}
@@ -3557,10 +3557,12 @@
 	if (ret != 0 && np->msi_flags & NV_MSI_CAPABLE) {
 		if ((ret = pci_enable_msi(np->pci_dev)) == 0) {
 			np->msi_flags |= NV_MSI_ENABLED;
+			dev->irq = np->pci_dev->irq;
 			if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev) != 0) {
 				printk(KERN_INFO "forcedeth: request_irq failed %d\n", ret);
 				pci_disable_msi(np->pci_dev);
 				np->msi_flags &= ~NV_MSI_ENABLED;
+				dev->irq = np->pci_dev->irq;
 				goto out_err;
 			}
 
@@ -3623,7 +3625,7 @@
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			disable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
-			disable_irq_lockdep(dev->irq);
+			disable_irq_lockdep(np->pci_dev->irq);
 		mask = np->irqmask;
 	} else {
 		if (np->nic_poll_irq & NVREG_IRQ_RX_ALL) {
@@ -3641,6 +3643,8 @@
 	}
 	np->nic_poll_irq = 0;
 
+	/* disable_irq() contains synchronize_irq, thus no irq handler can run now */
+
 	if (np->recover_error) {
 		np->recover_error = 0;
 		printk(KERN_INFO "forcedeth: MAC in recoverable error state\n");
@@ -3677,7 +3681,6 @@
 		}
 	}
 
-	/* FIXME: Do we need synchronize_irq(dev->irq) here? */
 
 	writel(mask, base + NvRegIrqMask);
 	pci_push(base);
@@ -3690,7 +3693,7 @@
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
-			enable_irq_lockdep(dev->irq);
+			enable_irq_lockdep(np->pci_dev->irq);
 	} else {
 		if (np->nic_poll_irq & NVREG_IRQ_RX_ALL) {
 			nv_nic_irq_rx(0, dev);
@@ -4943,7 +4946,7 @@
 	np->in_shutdown = 1;
 	spin_unlock_irq(&np->lock);
 	netif_poll_disable(dev);
-	synchronize_irq(dev->irq);
+	synchronize_irq(np->pci_dev->irq);
 
 	del_timer_sync(&np->oom_kick);
 	del_timer_sync(&np->nic_poll);

--------------050200000607050106040705--
