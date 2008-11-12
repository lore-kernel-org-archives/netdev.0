From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 04:11:43 -0800 (PST)
Message-ID: <20081112.041143.11487260.davem@davemloft.net>
References: <20081112.014923.68124784.davem@davemloft.net>
	<1226487710.6834.53.camel@localhost.localdomain>
	<20081112.035240.226243372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50302
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751525AbYKLMLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 07:11:43 -0500
In-Reply-To: <20081112.035240.226243372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 12 Nov 2008 03:52:40 -0800 (PST)

> Ok, Jesper, please try two things for me, leave the debugging patch
> in there for all the tests:
> 
> 1) Retrigger the problem (with or without MSI, doesn't matter) but
>    add back in that test I asked you to try last week.  The one
>    where the "if (++rp->mark_counter == rp->mark_freq)" condition
>    test in niu_start_xmit() is commented out, so that the
>    "mrk |= TX_DESC_MARK;" statement always runs.
> 
>    Get me the log dump produced by that scenerio.
> 
> 2) Next, simply comment out the:
> 
> 	if (unlikely(!(cs & (TX_CS_MK | TX_CS_MMK))))
> 		goto out;
> 
>    lines in niu_tx_work().
> 
> Let's see what new info we can get out of this.

These tests are still useful for me, so please perform them,
but I think I've found the bug.

I am guessing you're running a 32-bit x86 kernel.

In such a case the driver has to define a local readq()
and writeq() implementation.

What I provide for NIU right now reads the upper 32-bits
then the lower 32-bits of the register.

Guess what that does?  The packet counters live in the upper
32-bits and the MARK bits live in the lower 32-bits of the
TX_CS register.

So it first reads the packet counters, and as a side effect that
clears the MARK bits in the TX_CS register.  So when we read the lower
32-bits the MARK bits are always seen as zero.

BzzaaarT!

So the following patch should fix this bug.  writeq() should
be OK as-is, so doesn't need a similar change.

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 9acb5d7..d8463b1 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -51,8 +51,7 @@ MODULE_VERSION(DRV_MODULE_VERSION);
 #ifndef readq
 static u64 readq(void __iomem *reg)
 {
-	return (((u64)readl(reg + 0x4UL) << 32) |
-		(u64)readl(reg));
+	return ((u64) readl(reg)) | (((u64) readl(reg + 4UL)) << 32);
 }
 
 static void writeq(u64 val, void __iomem *reg)
