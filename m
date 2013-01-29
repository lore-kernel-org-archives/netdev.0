From: Dmitry Torokhov <dtor@vmware.com>
Subject: Re: [Pv-drivers] [PATCH] vmxnet3: set carrier state properly on probe
Date: Tue, 29 Jan 2013 11:53:57 -0800
Message-ID: <5442446.qe2SbG26dU@dtor-d630.eng.vmware.com>
References: <1359147253-7204-1-git-send-email-nhorman@tuxdriver.com> <20130129190952.GB14044@hmsreliant.think-freely.org> <1359487030.4144.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Neil Horman <nhorman@tuxdriver.com>, pv-drivers@vmware.com,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:35467 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753229Ab3A2Tx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 14:53:58 -0500
In-Reply-To: <1359487030.4144.10.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, January 29, 2013 07:17:10 PM Ben Hutchings wrote:
> On Tue, 2013-01-29 at 14:09 -0500, Neil Horman wrote:
> > On Tue, Jan 29, 2013 at 10:54:28AM -0800, Dmitry Torokhov wrote:
> > > On Tuesday, January 29, 2013 05:54:11 PM Ben Hutchings wrote:
> > > > On Fri, 2013-01-25 at 15:54 -0500, Neil Horman wrote:
> > > > > vmxnet3 fails to set netif_carrier_off on probe, meaning that when
> > > > > an
> > > > > interface is opened the __LINK_STATE_NOCARRIER bit is already
> > > > > cleared,
> > > > > and so /sys/class/net/<ifname>/operstate remains in the unknown
> > > > > state.
> > > > > Correct this by setting netif_carrier_off on probe, like other
> > > > > drivers
> > > > > do.
> > > > > 
> > > > > Also, while we're at it, lets remove the netif_carrier_ok checks
> > > > > from the
> > > > > link_state_update function, as that check is atomically contained
> > > > > within
> > > > > the netif_carrier_[on|off] functions anyway
> > > > > 
> > > > > Tested successfully by myself
> > > > > 
> > > > > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > > > > CC: "David S. Miller" <davem@davemloft.net>
> > > > > CC: "VMware, Inc." <pv-drivers@vmware.com>
> > > > > ---
> > > > > 
> > > > >  drivers/net/vmxnet3/vmxnet3_drv.c | 7 +++----
> > > > >  1 file changed, 3 insertions(+), 4 deletions(-)
> > > > > 
> > > > > diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> > > > > b/drivers/net/vmxnet3/vmxnet3_drv.c index b1c90f8..66c26a9 100644
> > > > > --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> > > > > +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> > > > 
> > > > [...]
> > > > 
> > > > > @@ -3067,6 +3065,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
> > > > > 
> > > > >  		goto err_register;
> > > > >  	
> > > > >  	}
> > > > > 
> > > > > +	netif_carrier_off(netdev);
> > > > > 
> > > > >  	vmxnet3_check_link(adapter, false);
> > > > >  	return 0;
> > > > 
> > > > You should do this before calling register_netdev(), otherwise the
> > > > link
> > > > state change can race with vmxnet3_open().
> > > 
> > > Hmm, is it safe to do before the network device is registered? The rest
> > > of the drivers (e1000, tg3, etc) seem to be doing netif_carrier_off()
> > > in open() rather than probe() and then do link checks.
> > 
> > It appears to be safe to me, at least for the netif_carrier_off case, as
> > theres a check to effecitvely just set the NOCARRIER bit if the device is
> > in UNREGISTERED state.
> 
> Right, I made this work properly a little while ago (commit
> 8f4cccbbd92f).  Previous best practice was to call netif_carrier_off()
> after registration, but userland could still see the wrong operstate
> because linkwatch updates it asynchronously.

Ah, OK I see. Thank you for the explanation.

Thanks,
Dmitry
