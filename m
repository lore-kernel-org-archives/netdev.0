From: =?unknown-8bit?B?RnJhbsOnb2lz?= Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix broken register writes
Date: Wed, 31 Mar 2010 22:27:48 +0200
Message-ID: <20100331202748.GB3228@electric-eye.fr.zoreil.com>
References: <4BAE6C92.2060801@iki.fi>
 <20100327211133.GA3624@electric-eye.fr.zoreil.com>
 <1269732054.8653.155.camel@localhost>
 <20100327.163005.28815553.davem@davemloft.net>
 <20100328003143.GA8501@electric-eye.fr.zoreil.com>
 <1269737245.8653.162.camel@localhost>
 <20100328212858.GA4220@electric-eye.fr.zoreil.com>
 <20100328221924.GG30031@ZenIV.linux.org.uk>
 <20100329010346.GH30031@ZenIV.linux.org.uk>
 <20100329021730.GI30031@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	ivecera@redhat.com, netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 55.58.140-88.rev.gaoland.net ([88.140.58.55]:60379 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756880Ab0CaU2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 16:28:30 -0400
Content-Disposition: inline
In-Reply-To: <20100329021730.GI30031@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro <viro@ZenIV.linux.org.uk> :
[...]
> BTW, patch from upthread doesn't help on that box, and neither does
> simple reordering of MAC0 and MAC4 writes.  Adding reads of MAC0 and
> MAC4 after corresponding writes seems to work.

Does something like the patch below work too ?

I'd like to factor out the posted PCI write commits.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9674005..8d1ab0f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -542,6 +542,11 @@ static int rtl8169_poll(struct napi_struct *napi, int budget);
 static const unsigned int rtl8169_rx_config =
 	(RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
 
+static void r816x_pci_write_commit(void __iomem *ioaddr)
+{
+	RTL_R8(ChipCmd);
+}
+
 static void mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 {
 	int i;
@@ -2825,8 +2830,13 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 	spin_lock_irq(&tp->lock);
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
+
 	RTL_W32(MAC4, high);
+	r816x_pci_write_commit(ioaddr);
+
 	RTL_W32(MAC0, low);
+	r816x_pci_write_commit(ioaddr);
+
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	spin_unlock_irq(&tp->lock);
