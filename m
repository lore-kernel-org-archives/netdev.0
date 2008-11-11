From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bnx2: fix poll_controller method so that proper
	structures are passed and all rx queues are checked
Date: Tue, 11 Nov 2008 15:58:03 -0500
Message-ID: <20081111185559.GD30481@hmsreliant.think-freely.org>
References: <20081111140055.GA30481@hmsreliant.think-freely.org> <C27F8246C663564A84BB7AB343977242151F4B18B9@IRVEXCHCCR01.corp.ad.broadcom.com> <20081111164634.GB30481@hmsreliant.think-freely.org> <1226423350.23218.9.camel@HP1> <20081111173708.GC30481@hmsreliant.think-freely.org> <1226426364.23218.14.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jgarzik@pobox.com" <jgarzik@pobox.com>,
	"'davem@davemloft.net'" <davem@davemloft.net>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41542 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754701AbYKKVAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 16:00:15 -0500
Content-Disposition: inline
In-Reply-To: <1226426364.23218.14.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2008 at 09:59:24AM -0800, Michael Chan wrote:
> 
> On Tue, 2008-11-11 at 09:37 -0800, Neil Horman wrote:
> > Copy that.  Here you go, followon patch to change how we pass the irq vector to
> > bnx2_interrupt.  Doesn't do anything super-usefull, but good for the sake of
> > correctness
> 
> Sorry, I missed something earlier.  After looking at this more closely,
> we should also move disable_irq() into the loop and call it with the
> same vector values from irq_tbl.
> 

Oops your right, new comprehensive patch, replacing the previous 2.

Fix bnx2 so that netpoll works properly.  Specifically:

1) Fix parameters to bnx2_interrupt to be a struct bnx2_napi rather than a
struct net_device

2) Fix poll_controller method to check every queue in the rx case so frames
aren't missed

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 bnx2.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 430d430..d07e3f1 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7204,10 +7204,13 @@ static void
 poll_bnx2(struct net_device *dev)
 {
 	struct bnx2 *bp = netdev_priv(dev);
+	int i;
 
-	disable_irq(bp->pdev->irq);
-	bnx2_interrupt(bp->pdev->irq, dev);
-	enable_irq(bp->pdev->irq);
+	for (i = 0; i < bp->irq_nvecs; i++) {
+		disable_irq(bp->irq_tbl[i].vector);
+		bnx2_interrupt(bp->irq_tbl[i].vector, &bp->bnx2_napi[i]);
+		enable_irq(bp->irq_tbl[i].vector);
+	}
 }
 #endif
 
-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
