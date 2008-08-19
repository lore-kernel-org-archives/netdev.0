From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] forcedeth: Fix kexec regression
Date: Tue, 19 Aug 2008 22:49:46 +0200
Message-ID: <200808192249.48316.rjw@sisk.pl>
References: <1218954333-12819-1-git-send-email-yhlu.kernel@gmail.com> <200808192045.54779.rjw@sisk.pl> <20080819133757.ce60f364.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, davem@davemloft.net, yhlu.kernel@gmail.com,
	mingo@elte.hu, ebiederm@xmission.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jbarnes@virtuousgeek.org, simon@fire.lp0.eu
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:54837 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752593AbYHSUqn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 16:46:43 -0400
In-Reply-To: <20080819133757.ce60f364.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, 19 of August 2008, Andrew Morton wrote:
> On Tue, 19 Aug 2008 20:45:53 +0200
> "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> 
> > From: Rafael J. Wysocki <rjw@sisk.pl>
> > 
> > forcedeth: Fix kexec regression
> > 
> > Fix regression tracked as
> > http://bugzilla.kernel.org/show_bug.cgi?id=11361 and
> > caused by commit f735a2a1a4f2a0f5cd823ce323e82675990469e2
> > ("[netdrvr] forcedeth: setup wake-on-lan before shutting down")
> > that makes network adapters integrated into the NVidia
> > MCP55 chipsets fail to work in kexeced kernels.  The problem appears
> > to be that if the adapter is put into D3_hot during ->shutdown(),
> > it cannot be brought back into D0 after kexec (ref.
> > http://marc.info/?l=linux-kernel&m=121900062814967&w=4).  Therefore,
> > only put forcedeth into D3 during ->shutdown() if the system is to be
> > powered off.
> > 
> > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> > Tested-by: Yinghai Lu <yhlu.kernel@gmail.com>
> > ---
> >  drivers/net/forcedeth.c |    8 +++++---
> >  1 file changed, 5 insertions(+), 3 deletions(-)
> > 
> > Index: linux-2.6/drivers/net/forcedeth.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/forcedeth.c
> > +++ linux-2.6/drivers/net/forcedeth.c
> > @@ -5975,10 +5975,12 @@ static void nv_shutdown(struct pci_dev *
> >  	if (netif_running(dev))
> >  		nv_close(dev);
> >  
> > -	pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> > -	pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
> >  	pci_disable_device(pdev);
> > -	pci_set_power_state(pdev, PCI_D3hot);
> > +	if (system_state == SYSTEM_POWER_OFF) {
> > +		if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
> > +			pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> > +		pci_set_power_state(pdev, PCI_D3hot);
> > +	}
> >  }
> >  #else
> >  #define nv_suspend NULL
> 
> hm, I wonder if this has any relation to
> forcedeth-add-pci_enable_device-to-nv_resume.patch:

There may be a connection, but we need a confirmation that kexec works on the
affected boxes with MSI disabled.  However, the $subject patch makes sense
even if that's the case IMO.

Anyway, the patch below fixes things for Simon only if MSI are disabled.

> From: Simon Arlott <simon@fire.lp0.eu>
> 
> My NIC stops working after resuming from standby, it's not receiving any
> interrupts.
> 
> Commit 25d90810ff49d2a63475776f24c74c6bb49b045f ([netdrvr] forcedeth:
> reorder suspend/resume code) introduces pci_disable_device to nv_suspend,
> but there's no corresponding pci_enable_device in nv_resume - so I added
> one (copied from e1000).  This results in interrupts being re-enabled
> after suspend.
> 
> However, the NIC (10de:0373) still doesn't work after resume.
> 
> Cc: Tobias Diedrich <ranma+kernel@tdiedrich.de>
> Cc: Jeff Garzik <jgarzik@redhat.com>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/forcedeth.c |    7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff -puN drivers/net/forcedeth.c~forcedeth-add-pci_enable_device-to-nv_resume drivers/net/forcedeth.c
> --- a/drivers/net/forcedeth.c~forcedeth-add-pci_enable_device-to-nv_resume
> +++ a/drivers/net/forcedeth.c
> @@ -5960,6 +5960,13 @@ static int nv_resume(struct pci_dev *pde
>  
>  	pci_set_power_state(pdev, PCI_D0);
>  	pci_restore_state(pdev);
> +	rc = pci_enable_device(pdev);
> +	if (rc) {
> +		printk(KERN_ERR "forcedeth: Cannot enable PCI device from suspend\n");
> +		return rc;
> +	}
> +	pci_set_master(pdev);
> +
>  	/* ack any pending wake events, disable PME */
>  	pci_enable_wake(pdev, PCI_D0, 0);
>  
> _
