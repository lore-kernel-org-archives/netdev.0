From: David Miller <davem@davemloft.net>
Subject: Re: __bad_udelay in network driver breaks build
Date: Mon, 25 Oct 2010 13:05:13 -0700 (PDT)
Message-ID: <20101025.130513.102558756.davem@davemloft.net>
References: <20101018115230.GA27565@basil.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51349
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756468Ab0JYUEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 16:04:50 -0400
In-Reply-To: <20101018115230.GA27565@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 18 Oct 2010 13:52:30 +0200

> 
> Current Linus master x86-64 allyesconfig fails with
> 
> drivers/built-in.o: In function `tms380tr_chipset_init':
> tms380tr.c:(.text+0x10f02de): undefined reference to `__bad_udelay'
> tms380tr.c:(.text+0x10f03ab): undefined reference to `__bad_udelay'
> tms380tr.c:(.text+0x10f0400): undefined reference to `__bad_udelay'
> tms380tr.c:(.text+0x10f07b2): undefined reference to `__bad_udelay'
> tms380tr.c:(.text+0x10f08ed): undefined reference to `__bad_udelay'
> make[2]: *** [.tmp_vmlinux1] Error 1

Let me know if this fixes things:

--------------------
tms380tr: Use mdelay() in tms380tr_wait().

This driver tries to do up to half-second udelay()
calls, which overflows on x86-64.

Reported-by: Andi Kleen <andi@firstfloor.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tokenring/tms380tr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index 663b886..7930203 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -1220,7 +1220,7 @@ void tms380tr_wait(unsigned long time)
 		tmp = schedule_timeout_interruptible(tmp);
 	} while(time_after(tmp, jiffies));
 #else
-	udelay(time);
+	mdelay(time / 1000);
 #endif
 }
 
-- 
1.7.3.2

