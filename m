From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH 2/3] cnic: Don't take cnic_dev_lock in
 cnic_alloc_uio_rings()
Date: Fri, 30 May 2014 22:40:09 -0700
Message-ID: <1401514810.9728.163.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1401491923-5480-1-git-send-email-mchan@broadcom.com>
	 <1401491923-5480-2-git-send-email-mchan@broadcom.com>
	 <1401491923-5480-3-git-send-email-mchan@broadcom.com>
	 <20140530225048.GA24100@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<nhorman@tuxdriver.com>
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:34857 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbaEaFkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2014 01:40:11 -0400
In-Reply-To: <20140530225048.GA24100@f1.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-30 at 15:50 -0700, Benjamin Poirier wrote: 
> On 2014/05/30 16:18, Michael Chan wrote:
> > We are allocating memory with GFP_KERNEL under spinlock.  Since this is
> > the only call manipulating the cnic_udev_list and it is always under
> > rtnl_lock, cnic_dev_lock can be safely removed.
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > ---
> >  drivers/net/ethernet/broadcom/cnic.c |    6 ------
> >  1 files changed, 0 insertions(+), 6 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
> > index 7f40a2c..4ebab75 100644
> > --- a/drivers/net/ethernet/broadcom/cnic.c
> > +++ b/drivers/net/ethernet/broadcom/cnic.c
> > @@ -1039,21 +1039,17 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
> >  	struct cnic_local *cp = dev->cnic_priv;
> >  	struct cnic_uio_dev *udev;
> >  
> > -	read_lock(&cnic_dev_lock);
> >  	list_for_each_entry(udev, &cnic_udev_list, list) {
> >  		if (udev->pdev == dev->pcidev) {
> >  			udev->dev = dev;
> >  			if (__cnic_alloc_uio_rings(udev, pages)) {
> >  				udev->dev = NULL;
> > -				read_unlock(&cnic_dev_lock);
> >  				return -ENOMEM;
> >  			}
> >  			cp->udev = udev;
> > -			read_unlock(&cnic_dev_lock);
> >  			return 0;
> >  		}
> >  	}
> > -	read_unlock(&cnic_dev_lock);
> >  
> >  	udev = kzalloc(sizeof(struct cnic_uio_dev), GFP_ATOMIC);
> 
> Oh, and you could also make the above GFP_KERNEL. Sorry for not
> mentioning it in my previous mail.

Thanks for pointing this out.  We can do that in a separate patch.  It
is related but not part of this bug fix.
