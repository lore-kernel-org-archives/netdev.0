From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Slow connection with RTL8168b/8111b
Date: Sat, 24 Feb 2007 12:41:47 +0100
Message-ID: <20070224114147.GA2282@electric-eye.fr.zoreil.com>
References: <88ab4080702210744s1ccf0c8cr504c4f007cc11062@mail.gmail.com> <20070222080633.GA6612@electric-eye.fr.zoreil.com> <88ab4080702240315r320a0adeq4baa6d8fb140f22b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: Dirk <biecie547@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43154 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992AbXBXLoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Feb 2007 06:44:22 -0500
Content-Disposition: inline
In-Reply-To: <88ab4080702240315r320a0adeq4baa6d8fb140f22b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dirk <biecie547@gmail.com> :
[...]
> I tried running 2.6.21-rc1 with the patch you mentioned, but it still
> has thesame speed problem. Building the driver with or without NAPI
> support makes no difference.

Thanks for testing.

Can you try the patch below on top of:

http://www.fr.zoreil.com/people/francois/misc/20070223-2.6.21-rc1-r8169-test.patch

Don't hurry: it's saturday. :o)

This patch fixes two problems:

  - Call unregister_netdev() before pci_disable_msi() to fix
    BUG_ON(irq_has_action(dev->first_msi_irq)) in drivers/pci/msi.c:658

  - Call RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb) in rtl_hw_start_8168()
    I don't know why, I have no specification of this device, I
    simply used the try & error method.

Signed-off-by: Bernhard Walle <bwalle@suse.de>

---
 drivers/net/r8169.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.21-rc1/drivers/net/r8169.c
===================================================================
--- linux-2.6.21-rc1.orig/drivers/net/r8169.c
+++ linux-2.6.21-rc1/drivers/net/r8169.c
@@ -1795,10 +1795,10 @@ static void __devexit rtl8169_remove_one
 
 	flush_scheduled_work();
 
+	unregister_netdev(dev);
 	if (tp->msi)
 		pci_disable_msi(pdev);
 	tp->msi = 0;
-	unregister_netdev(dev);
 	rtl8169_release_board(pdev, dev, tp->mmio_addr);
 	pci_set_drvdata(pdev, NULL);
 }
@@ -2060,6 +2060,7 @@ static void rtl_hw_start_8168(struct net
 		tp->intr_event &= ~RxOverflow;
 	}
 
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
