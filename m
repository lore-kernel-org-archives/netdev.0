From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] e100: Fix workqueue race
Date: Fri, 22 Jan 2010 09:07:31 +0000
Message-ID: <20100122090731.GC6200@ff.dom.local>
References: <20100121164801.416170b9@linux.intel.com> <20100122084200.GB6200@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: Alan Cox <alan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f223.google.com ([209.85.220.223]:52301 "EHLO
	mail-fx0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab0AVJHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 04:07:39 -0500
Received: by fxm23 with SMTP id 23so1050290fxm.38
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 01:07:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100122084200.GB6200@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 22, 2010 at 08:42:00AM +0000, Jarek Poplawski wrote:
> On 21-01-2010 17:48, Alan Cox wrote:
> > (Incidentally this doesn't seem to be the only net driver that looks
> > suspect here)
> > 
> > e100: Fix the TX workqueue race
> > 
> > From: Alan Cox <alan@linux.intel.com>
> > 
> > Nothing stops the workqueue being left to run in parallel with close or a
> > few other operations. This causes double unmaps and the like.
> > 
> > See kerneloops.org #1041230 for an example
> > 
> > Signed-off-by: Alan Cox <alan@linux.intel.com>
> > ---
> > 
> >  drivers/net/e100.c |   13 +++++++++++--
> >  1 files changed, 11 insertions(+), 2 deletions(-)
> > 
> > 
> > diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> > index 5c7a155..5e02e4f 100644
> > --- a/drivers/net/e100.c
> > +++ b/drivers/net/e100.c
> > @@ -2232,7 +2232,7 @@ err_rx_clean_list:
> >  	return err;
> >  }
> >  
> > -static void e100_down(struct nic *nic)
> > +static void e100_do_down(struct nic *nic)
> >  {
> >  	/* wait here for poll to complete */
> >  	napi_disable(&nic->napi);
> > @@ -2245,6 +2245,15 @@ static void e100_down(struct nic *nic)
> >  	e100_rx_clean_list(nic);
> >  }
> >  
> > +/* For the non TX timeout case we want to kill the tx timeout before
> > +   we do this otherwise a parallel tx timeout will make a nasty mess. */
> > +
> > +static void e100_down(struct nic *nic)
> > +{
> > +	cancel_work_sync(&nic->tx_timeout_task);
> 
> Can't tx_timeout_task be triggered just between these two calls here?

More exactly: except when this is called from dev_close(), where it
should work OK. (At least until tx_timeout_task doesn't take any lock
held here - especially rtnl_lock.)

Jarek P.

> 
> > +	e100_do_down(nic);
> > +}
> > +
> >  static void e100_tx_timeout(struct net_device *netdev)
> >  {
> >  	struct nic *nic = netdev_priv(netdev);
> > @@ -2261,7 +2270,7 @@ static void e100_tx_timeout_task(struct work_struct *work)
> >  
> >  	DPRINTK(TX_ERR, DEBUG, "scb.status=0x%02X\n",
> >  		ioread8(&nic->csr->scb.status));
> > -	e100_down(netdev_priv(netdev));
> > +	e100_do_down(netdev_priv(netdev));
> >  	e100_up(netdev_priv(netdev));
> >  }
> >  
> > --
