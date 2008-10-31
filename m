From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next] tg3: inconsistent interrupt value reported
Date: Fri, 31 Oct 2008 11:54:22 -0400
Message-ID: <20081031155421.GB6181@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, davem@davemloft.net
To: mcarlson@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38482 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751538AbYJaPya (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 11:54:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Systems that use MSI do not report the correct 'Interrupt' value in
ifconfig output.  This patch sets dev->irq after initializing the
interrupt as the value will change when using MSI.

I suspect this is a problem with a lot of drivers, so I'll snoop around
and post some more patches if needed.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 tg3.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index eb9f8f3..fa95e99 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7892,6 +7892,7 @@ static int tg3_request_irq(struct tg3 *tp)
 	irq_handler_t fn;
 	unsigned long flags;
 	struct net_device *dev = tp->dev;
+	int ret;
 
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
 		fn = tg3_msi;
@@ -7904,7 +7905,9 @@ static int tg3_request_irq(struct tg3 *tp)
 			fn = tg3_interrupt_tagged;
 		flags = IRQF_SHARED | IRQF_SAMPLE_RANDOM;
 	}
-	return (request_irq(tp->pdev->irq, fn, flags, dev->name, dev));
+	ret = request_irq(tp->pdev->irq, fn, flags, dev->name, dev);
+	dev->irq = tp->pdev->irq;
+	return ret;
 }
 
 static int tg3_test_interrupt(struct tg3 *tp)
