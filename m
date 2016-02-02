From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Keystone 2 boards boot failure
Date: Wed, 03 Feb 2016 00:26:13 +0100
Message-ID: <10700980.gTvMTB9pzv@wuerfel>
References: <56B0DE61.2000704@ti.com> <7911064.Pij4S9Q1yj@wuerfel> <56B134D6.101@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: m-karicheri2@ti.com, netdev@vger.kernel.org, w-kwok2@ti.com,
	davem@davemloft.net
To: Franklin Cooper <fcooper@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:63018 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbcBBX0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 18:26:23 -0500
In-Reply-To: <56B134D6.101@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 02 February 2016 16:59:34 Franklin Cooper wrote:
> On 02/02/2016 03:26 PM, Arnd Bergmann wrote:
> > On Tuesday 02 February 2016 15:01:33 Franklin S Cooper Jr. wrote:
> >>
> >> Yes. Here is a boot log on the latest master with the below
> >> three patches reverted.
> >> http://pastebin.com/W7RWSHpE (Working)
> >>
> >> I reverted these three patches. The two latest patches seem
> >> to be trying to correct/expand upon the last patch on this list.
> >>
> >> commit 958d104e3d40eef5148c402887138f6594ff7e1e
> >> netcp: fix regression in receive processing
> >>
> >> commit 9dd2d6c5c9755b160fe0111bcdad9491676feea8
> >> netcp: add more __le32 annotations
> >>
> >> commit 899077791403ff7a2d8cfaa87bd1a82d729463e2
> >> netcp: try to reduce type confusion in descriptors
> >>
> > 
> > The middle patch should have no effect on generated code, so I'm ignoring
> > that for now.
> > 
> > The next thing to rule out is an endianess bug. I assume you
> > are running this on with a little-endian kernel, correct? If
> > you are running big-endian, the base assumption that the driver needs
> > to swap the data was flawed and that portion needs to be done.
> > 
> > If you are running little-endian 32-bit, please try the partial
> > revert below, which just undoes the attempt to make it work with
> > 64-bit kernels.
> 
> Keystone 2 devices are little-endian 32-bit devices.

I meant the kernel you are running on it, not the hardware.
You should always be able to run both a big-endian kernel and
a littl-endian kernel on any ARMv7 machine, and a couple of
platforms use 64-bit physical addresses even on 32-bit machines
(with the normal 32-bit instruction set).

I wasn't completely sure if there are already keystone-derived
products with 64-bit CPU cores, but I guess the driver would
fail really badly on those (with or without the patch).

> This partial revert fixes the boot problem for me.

Ok.


I tried to create a smaller version and stumbled over
a typo, maybe that's the whole problem. Can you try this one:

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index c61d66d38634..8490804416dd 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -167,7 +167,7 @@ static void set_pad_info(u32 pad0, u32 pad1, u32 pad2, struct knav_dma_desc *des
 {
 	desc->pad[0] = cpu_to_le32(pad0);
 	desc->pad[1] = cpu_to_le32(pad1);
-	desc->pad[2] = cpu_to_le32(pad1);
+	desc->pad[2] = cpu_to_le32(pad2);
 }
 
 static void set_org_pkt_info(dma_addr_t buff, u32 buff_len,


	Arnd
