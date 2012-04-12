From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] ks8851: Fix missing mutex_lock/unlock
Date: Thu, 12 Apr 2012 18:19:40 -0300
Message-ID: <20120412181940.7140ecb2@asterix.rh>
References: <1334261204-8554-1-git-send-email-mjr@cs.wisc.edu>
	<4F873C58.3000104@codeaurora.org>
	<20120412175945.1bbdd9bb@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Boyd <sboyd@codeaurora.org>, mjr@cs.wisc.edu,
	davem@davemloft.net, ben@simtec.co.uk, netdev@vger.kernel.org
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39808 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755993Ab2DLVUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 17:20:01 -0400
In-Reply-To: <20120412175945.1bbdd9bb@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Apr 2012 17:59:45 -0300
Flavio Leitner <fbl@redhat.com> wrote:

> On Thu, 12 Apr 2012 13:34:32 -0700
> Stephen Boyd <sboyd@codeaurora.org> wrote:
> 
> > On 04/12/12 13:06, mjr@cs.wisc.edu wrote:
> > > From: Matt Renzelmann <mjr@cs.wisc.edu>
> > >
> > > All calls to ks8851_rdreg* and ks8851_wrreg* should be protected with
> > > the driver's lock mutex.  A spurious interrupt may otherwise cause a
> > > crash.
> > >
> > > Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
> > > ---
> > >
> > > Thank you, Mr. Leitner, for providing feedback.  I agree with your
> > > changes and have updated the patch to reflect them.  I apologize for
> > > missing the driver name in the title -- I've updated the patch with
> > > that information as well.  Please let me know if there is anything
> > > else I should fix/change.
> > >
> > >  drivers/net/ethernet/micrel/ks8851.c |    8 ++++++--
> > >  1 files changed, 6 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
> > > index c722aa6..20237dc 100644
> > > --- a/drivers/net/ethernet/micrel/ks8851.c
> > > +++ b/drivers/net/ethernet/micrel/ks8851.c
> > > @@ -1417,6 +1417,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
> > >  {
> > >  	struct net_device *ndev;
> > >  	struct ks8851_net *ks;
> > > +	int result;
> > >  	int ret;
> > >  
> > >  	ndev = alloc_etherdev(sizeof(struct ks8851_net));
> > > @@ -1515,9 +1516,12 @@ static int __devinit ks8851_probe(struct spi_device *spi)
> > >  		goto err_netdev;
> > >  	}
> > >  
> > > +	mutex_lock(&ks->lock);
> > > +	result = CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER));
> > > +	mutex_unlock(&ks->lock);
> > > +
> > >  	netdev_info(ndev, "revision %d, MAC %pM, IRQ %d, %s EEPROM\n",
> > > -		    CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
> > > -		    ndev->dev_addr, ndev->irq,
> > > +		    result, ndev->dev_addr, ndev->irq,
> > >  		    ks->rc_ccr & CCR_EEPROM ? "has" : "no");
> > >  
> > >  	return 0;
> > 
> > This register is already read in the probe function and the lock is not
> > held there so you seem to have missed a couple. I would guess it doesn't
> > really matter tha we don't grab the lock though because the device isn't
> > actively sending/receiving packets. How about this instead?
> 
> I believe that's because the IRQ isn't reserved yet, so there is no problem.

So, what about this instead:

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index c722aa6..7137f47 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1417,6 +1417,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 {
 	struct net_device *ndev;
 	struct ks8851_net *ks;
+	unsigned int cider;
 	int ret;
 
 	ndev = alloc_etherdev(sizeof(struct ks8851_net));
@@ -1485,7 +1486,8 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 
 	/* simple check for a valid chip being connected to the bus */
 
-	if ((ks8851_rdreg16(ks, KS_CIDER) & ~CIDER_REV_MASK) != CIDER_ID) {
+	cider = ks8851_rdreg16(ks, KS_CIDER);
+	if ((cider & ~CIDER_REV_MASK) != CIDER_ID) {
 		dev_err(&spi->dev, "failed to read device ID\n");
 		ret = -ENODEV;
 		goto err_id;
@@ -1516,7 +1518,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 	}
 
 	netdev_info(ndev, "revision %d, MAC %pM, IRQ %d, %s EEPROM\n",
-		    CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
+		    CIDER_REV_GET(cider),
 		    ndev->dev_addr, ndev->irq,
 		    ks->rc_ccr & CCR_EEPROM ? "has" : "no");
 

fbl
