From: Yinghai Lu <yinghai@kernel.org>
Subject: [PATCH] forcedeth: don't clear nic_poll_irq too early
Date: Thu, 05 Feb 2009 21:00:30 -0800
Message-ID: <498BC3EE.3070209@kernel.org>
References: <498BC3A8.9040203@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:32770 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbZBFFCA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 00:02:00 -0500
In-Reply-To: <498BC3A8.9040203@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Impact: fix bug

for msix, we still need that flag to enable irq respectively

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 drivers/net/forcedeth.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

Index: linux-2.6/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.orig/drivers/net/forcedeth.c
+++ linux-2.6/drivers/net/forcedeth.c
@@ -4057,8 +4057,6 @@ static void nv_do_nic_poll(unsigned long
 			mask |= NVREG_IRQ_OTHER;
 		}
 	}
-	np->nic_poll_irq = 0;
-
 	/* disable_irq() contains synchronize_irq, thus no irq handler can run now */
 
 	if (np->recover_error) {
@@ -4096,11 +4094,11 @@ static void nv_do_nic_poll(unsigned long
 		}
 	}
 
-
 	writel(mask, base + NvRegIrqMask);
 	pci_push(base);
 
 	if (!using_multi_irqs(dev)) {
+		np->nic_poll_irq = 0;
 		if (nv_optimized(np))
 			nv_nic_irq_optimized(0, dev);
 		else
@@ -4111,18 +4109,22 @@ static void nv_do_nic_poll(unsigned long
 			enable_irq_lockdep(np->pci_dev->irq);
 	} else {
 		if (np->nic_poll_irq & NVREG_IRQ_RX_ALL) {
+			np->nic_poll_irq &= ~NVREG_IRQ_RX_ALL;
 			nv_nic_irq_rx(0, dev);
 			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 		}
 		if (np->nic_poll_irq & NVREG_IRQ_TX_ALL) {
+			np->nic_poll_irq &= ~NVREG_IRQ_TX_ALL;
 			nv_nic_irq_tx(0, dev);
 			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector);
 		}
 		if (np->nic_poll_irq & NVREG_IRQ_OTHER) {
+			np->nic_poll_irq &= ~NVREG_IRQ_OTHER;
 			nv_nic_irq_other(0, dev);
 			enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector);
 		}
 	}
+
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
