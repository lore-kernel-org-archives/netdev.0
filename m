From: Tzungder Lin <tzungder@gmail.com>
Subject: Probably a flaw in Linux rtl8139 driver FYI
Date: Sat, 18 Apr 2009 20:40:11 +0800
Message-ID: <528f811a0904180540t15489826n99cf8143fe105463@mail.gmail.com>
References: <528f811a0904170008q34b5cde1l810fb22f78eefaf7@mail.gmail.com>
	 <528f811a0904170010w2b2c8b34j698b255331f78765@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:38717 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbZDRMkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 08:40:12 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1277237rvb.1
        for <netdev@vger.kernel.org>; Sat, 18 Apr 2009 05:40:11 -0700 (PDT)
In-Reply-To: <528f811a0904170010w2b2c8b34j698b255331f78765@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Sirs,

Hello, I am jon from Taiwan.
First I want to thank you for your great contributions of open source.
Thank you for your 8139 driver to make our world better.

Here is what happens:
While I am debugging our Embedded Linux SoC I found a flaw in Linux
8139 driver (8139too.c) ,probably.
If I attack (interval < 10ms) the driver with broadcast packets
(mac.destaddr == ff:ff:ff:ff:ff:ff) when network interface up (ifconfig
eth0 up) at the first time, the kernel space memory will be corrupted
(overwrited with packet content) start from 0xc03e8800.
Then kernel panics.

Here is what I discovered:
While ifconfig eth0 up kernel calls open() of 8139 driver(8139too.c).
In rtl8139_hw_start() of rtl8139_open(), 8139 driver enable RX before
setting up the DMA buffer
address.
Therefore in this interval where RX was enabled and DMA buffer address
is not yet set up, any incoming broadcast packet would be send to a strange
physical address: 0x003e8800 which is the default value of DMA buffer address.
Unfortunately, this address is in Linux kernel used by kmem_cache functions.
So, kernel panics. I have tried to fix the driver by setting up DMA
buffer address
before RX enabled and everything is fine.

I have checked 8139too.c in both 2.4.x kernel and 2.6.x kernel, they
both have the same initial flow.
Here is a simple patch to show you what I found.

--- 8139too.c   2007-12-13 15:54:26.000000000 +0800
+++ 8139too_patch.c     2009-04-17 14:56:27.000000000 +0800
@@ -1382,6 +1382,10 @@
       RTL_W32_F (MAC0 + 0, cpu_to_le32 (*(u32 *) (dev->dev_addr + 0)));
       RTL_W32_F (MAC0 + 4, cpu_to_le32 (*(u32 *) (dev->dev_addr + 4)));

+       /* init Rx ring buffer DMA address */
+       /* init before Rx enabled to avoid broadcast packet attack in
this interval */
+       RTL_W32_F (RxBuf, tp->rx_ring_dma);
+
       /* Must enable Tx/Rx before setting transfer thresholds! */
       RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);

@@ -1405,8 +1409,6 @@
       /* Lock Config[01234] and BMCR register writes */
       RTL_W8 (Cfg9346, Cfg9346_Lock);

-       /* init Rx ring buffer DMA address */
-       RTL_W32_F (RxBuf, tp->rx_ring_dma);

       /* init Tx buffer DMA addresses */
       for (i = 0; i < NUM_TX_DESC; i++)

Hope this can make the driver more robust.
FYR
Thanks a lot!

Regards
 Jonathan Lin @Taiwan
 2009.4.18
