From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] r8169: don't call napi_disable if not doing NAPI
Date: Fri, 26 Oct 2007 11:33:05 -0700
Message-ID: <20071026113305.57dea765@freepuppy.rosehill>
References: <alpine.LFD.0.999.0710232057080.30120@woody.linux-foundation.org>
	<1193232344.32208.0.camel@localhost>
	<20071024142759.GA13657@elte.hu>
	<1193241191.14314.8.camel@localhost>
	<20071024155521.GA16690@elte.hu>
	<1193242267.6914.6.camel@twins>
	<1193378269.17910.4.camel@localhost>
	<20071026063733.GA12426@elte.hu>
	<20071026094833.539a69aa@freepuppy.rosehill>
	<20071026175613.GA18770@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Romano Giannetti <romanol@upcomillas.es>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52250 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753956AbXJZSe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 14:34:56 -0400
In-Reply-To: <20071026175613.GA18770@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't call napi_disable if not configured.
And make sure that any misuse of napi_xxx in future fails
with a compile error.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/r8169.c	2007-10-24 21:38:43.000000000 -0700
+++ b/drivers/net/r8169.c	2007-10-26 11:27:02.000000000 -0700
@@ -392,7 +392,9 @@ struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device */
 	struct net_device *dev;
+#ifdef CONFIG_R8169_NAPI
 	struct napi_struct napi;
+#endif
 	spinlock_t lock;		/* spin lock flag */
 	u32 msg_enable;
 	int chipset;
@@ -2989,13 +2991,16 @@ static void rtl8169_down(struct net_devi
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned int poll_locked = 0;
 	unsigned int intrmask;
 
 	rtl8169_delete_timer(dev);
 
 	netif_stop_queue(dev);
 
+#ifdef CONFIG_R8169_NAPI
+	napi_disable(&tp->napi);
+#endif
+
 core_down:
 	spin_lock_irq(&tp->lock);
 
@@ -3009,11 +3014,6 @@ core_down:
 
 	synchronize_irq(dev->irq);
 
-	if (!poll_locked) {
-		napi_disable(&tp->napi);
-		poll_locked++;
-	}
-
 	/* Give a racing hard_start_xmit a few cycles to complete. */
 	synchronize_sched();  /* FIXME: should this be synchronize_irq()? */
 
