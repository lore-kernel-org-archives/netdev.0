From: Bryan Wu <bryan.wu@analog.com>
Subject: Re: [PATCH try#2] Blackfin ethernet driver: on chip ethernet MAC
	controller driver
Date: Sun, 15 Jul 2007 20:07:44 +0800
Message-ID: <1184501264.3140.71.camel@roc-laptop>
References: <1184491629.3140.59.camel@roc-laptop>
	 <200707151236.51779.mb@bu3sch.de>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bryan.wu@analog.com, Mike Frysinger <vapier.adi@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:42296 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757453AbXGOMHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 08:07:51 -0400
In-Reply-To: <200707151236.51779.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-07-15 at 12:36 +0200, Michael Buesch wrote:
> On Sunday 15 July 2007 11:27:09 Bryan Wu wrote:
> > +#if defined(CONFIG_BFIN_MAC_USE_L1)
> > +# define bfin_mac_alloc(dma_handle, size)  l1_data_sram_zalloc(size)
> > +# define bfin_mac_free(dma_handle, ptr)    l1_data_sram_free(ptr)
> > +#else
> > +# define bfin_mac_alloc(dma_handle, size) \
> > +	 dma_alloc_coherent(NULL, size, dma_handle, GFP_NORMAL)
> 
> What is GFP_NORMAL? It's not defined in latest linus' tree.
> I think you should use GFP_KERNEL, if you can sleep, or GFP_ATOMIC,
> if you can't.
> 

Yes, it should be GFP_KERNEL, i missed up with ZONE_NORMAL and ZONE_DMA.

> The rest looks OK. Except the endianess issues. It might be no
> issue on the hardware this runs on, but in favour of "clean code"
> you might use leXX_to_cpu and friends anyway. :)
> This kind of bugs is done so often, even in places where it _does_
> matter. So, at least for the human reader, the leXX_to_cpu stuff
> says that you really understood what you were doing when writing
> the code. The current code says (to me), that it works by
> accident, somehow, although it seems you knew what you were doing. :)
> 

As you know, this driver is original developed by Luke Yang. Now I am
maintaining it.
I just don't understand in this driver where should use leXX_to_cpu()
and where should
use cpu_to_leXX(). please give me some comments about the following
change:

---
@@ -483,9 +487,12 @@
 
 void setup_mac_addr(u8 * mac_addr)
 {
+	u32 addr_low = le32_to_cpu(*(u32 *) & mac_addr[0]);
+	u16 addr_hi = le16_to_cpu(*(u16 *) & mac_addr[4]);
+
 	/* this depends on a little-endian machine */
-	bfin_write_EMAC_ADDRLO(*(u32 *) & mac_addr[0]);
-	bfin_write_EMAC_ADDRHI(*(u16 *) & mac_addr[4]);
+	bfin_write_EMAC_ADDRLO(addr_low);
+	bfin_write_EMAC_ADDRHI(addr_hi);
 }
 
 static void adjust_tx_list(void)
@@ -866,10 +873,10 @@
 	int retval;
 
 	/* Grab the MAC address in the MAC */
-	*(u32 *) (&(dev->dev_addr[0])) = bfin_read_EMAC_ADDRLO();
-	*(u16 *) (&(dev->dev_addr[4])) = (u16) bfin_read_EMAC_ADDRHI();
+	*(u32 *) (&(dev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
+	*(u16 *) (&(dev->dev_addr[4])) = cpu_to_le16((u16) bfin_read_EMAC_ADDRHI());
---

Thanks
- Bryan Wu
