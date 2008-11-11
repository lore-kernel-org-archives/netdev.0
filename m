From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bnx2: fix poll_controller method so that proper
	structures are passed and all rx queues are checked
Date: Tue, 11 Nov 2008 12:37:08 -0500
Message-ID: <20081111173708.GC30481@hmsreliant.think-freely.org>
References: <20081111140055.GA30481@hmsreliant.think-freely.org> <C27F8246C663564A84BB7AB343977242151F4B18B9@IRVEXCHCCR01.corp.ad.broadcom.com> <20081111164634.GB30481@hmsreliant.think-freely.org> <1226423350.23218.9.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jgarzik@pobox.com" <jgarzik@pobox.com>,
	"'davem@davemloft.net'" <davem@davemloft.net>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41908 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbYKKRjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 12:39:15 -0500
Content-Disposition: inline
In-Reply-To: <1226423350.23218.9.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2008 at 09:09:10AM -0800, Michael Chan wrote:
> 
> On Tue, 2008-11-11 at 08:46 -0800, Neil Horman wrote:
> > On Tue, Nov 11, 2008 at 07:12:13AM -0800, Michael Chan wrote:
> > > Neil Horman wrote:
> > > > diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> > > > index 430d430..9e1f0e3 100644
> > > > --- a/drivers/net/bnx2.c
> > > > +++ b/drivers/net/bnx2.c
> > > > @@ -7203,10 +7203,12 @@ bnx2_change_mtu(struct net_device
> > > > *dev, int new_mtu)
> > > >  static void
> > > >  poll_bnx2(struct net_device *dev)
> > > >  {
> > > > +     int i;
> > > >       struct bnx2 *bp = netdev_priv(dev);
> > > >
> > > >       disable_irq(bp->pdev->irq);
> > > > -     bnx2_interrupt(bp->pdev->irq, dev);
> > > > +     for (i = 0; i < bp->irq_nvecs; i++)
> > > > +             bnx2_interrupt(bp->pdev->irq, &bp->bnx2_napi[i]);
> > > 
> > > Neil, thanks for the patch.
> > > 
> > > We should probably pass bp->irq_tbl[i].vector as 1st parameter
> > > for correctness, even though it doesn't really matter in this
> > > case since it is not used by bnx2_interrupt().
> > > 
> > I thought we overwrote pdev->irq with the value from irq_tbl when we registered
> > for msi interrupts?
> > 
> 
> In MSI and INTA mode, we store pdev->irq into irq_tbl[0].vector.  In
> MSI-X mode, we'll have multiple vectors in the irq_tbl entries and
> pdev->irq is no longer relevant.  So to be correct when we have multiple
> vectors, the irq_tbl values should be used.
> 
> Thanks.
> 


Copy that.  Here you go, followon patch to change how we pass the irq vector to
bnx2_interrupt.  Doesn't do anything super-usefull, but good for the sake of
correctness

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 bnx2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 9e1f0e3..cad8b7a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7208,7 +7208,7 @@ poll_bnx2(struct net_device *dev)
 
 	disable_irq(bp->pdev->irq);
 	for (i = 0; i < bp->irq_nvecs; i++)
-		bnx2_interrupt(bp->pdev->irq, &bp->bnx2_napi[i]);
+		bnx2_interrupt(bp->irq_tbl[i].vector, &bp->bnx2_napi[i]);
 	enable_irq(bp->pdev->irq);
 }
 #endif
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
