From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3: unable to handle null pointer dereference [Re: Linux
 2.6.21-rc6]
Date: Fri, 06 Apr 2007 15:57:13 -0700
Message-ID: <1175900233.7911.87.camel@dell>
References: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
 <20070406214014.GF3346@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"LKML" <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: "Nishanth Aravamudan" <nacc@us.ibm.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3204 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933165AbXDFWMV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 18:12:21 -0400
In-Reply-To: <20070406214014.GF3346@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-04-06 at 14:40 -0700, Nishanth Aravamudan wrote:

> 2.6.21-rc5 is ok. 2.6.21-rc6 results in
> 
> [   14.241665] Unable to handle kernel NULL pointer dereference (address 0000000000000000)

Sorry, I think this should fix it:

[TG3]: Fix crash during tg3_init_one().

The driver will crash when the chip has been initialized by EFI before
tg3_init_one().  In this case, the driver will call tg3_chip_reset()
before allocating consistent memory.

The bug is fixed by checking for tp->hw_status before accessing it
during tg3_chip_reset().

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0acee9f..256969e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4834,8 +4834,10 @@ static int tg3_chip_reset(struct tg3 *tp)
 	 * sharing or irqpoll.
 	 */
 	tp->tg3_flags |= TG3_FLAG_CHIP_RESETTING;
-	tp->hw_status->status = 0;
-	tp->hw_status->status_tag = 0;
+	if (tp->hw_status) {
+		tp->hw_status->status = 0;
+		tp->hw_status->status_tag = 0;
+	}
 	tp->last_tag = 0;
 	smp_mb();
 	synchronize_irq(tp->pdev->irq);




