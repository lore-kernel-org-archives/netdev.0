From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44.c box lockup fix (netconsole): ratelimit NAPI poll
 error message
Date: Mon, 30 Nov 2009 00:15:41 -0800 (PST)
Message-ID: <20091130.001541.134590904.davem@davemloft.net>
References: <20091125213546.GA6168@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, dave@thedillows.org, mb@bu3sch.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andi@lisas.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753253AbZK3IPg@vger.kernel.org>
In-Reply-To: <20091125213546.GA6168@rhlx01.hs-esslingen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Mohr <andi@lisas.de>
Date: Wed, 25 Nov 2009 22:35:46 +0100

> See
> http://bugzilla.kernel.org/show_bug.cgi?id=14691
> for background information.

The patch below is what I'll check in to fix this, thanks.

As for the r8169 side, that case is much more complicated
to fix.  That driver messes with the interrupt masking
before the NAPI schedule check, instead of after it's
sure that NAPI isn't already scheduled like b44 does.

Therefore we might need to undo that programming or move
it into the code block where __napi_schedule() is actually
invoked.

I'll queue this b44 patch up for -stable too.

b44: Fix wedge when using netconsole.

Fixes kernel bugzilla #14691

Due to the way netpoll works, it is perfectly legal to see
NAPI already scheduled when new device events are pending
in b44_interrupt().

So logging a message about it is wrong and in fact harmful.

Based upon a patch by Andreas Mohr.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/b44.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index e046943..2a91323 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -912,9 +912,6 @@ static irqreturn_t b44_interrupt(int irq, void *dev_id)
 			bp->istat = istat;
 			__b44_disable_ints(bp);
 			__napi_schedule(&bp->napi);
-		} else {
-			printk(KERN_ERR PFX "%s: Error, poll already scheduled\n",
-			       dev->name);
 		}
 
 irq_ack:
-- 
1.6.5
