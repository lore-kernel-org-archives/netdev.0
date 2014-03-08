From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] vmxnet3: fix netpoll race condition
Date: Sat, 8 Mar 2014 09:36:59 -0500
Message-ID: <20140308143659.GB10653@hmsreliant.think-freely.org>
References: <1394227527-31082-1-git-send-email-nhorman@tuxdriver.com>
 <739029197.38929769.1394255661208.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "VMware, Inc." <pv-drivers@vmware.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44592 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaCHOhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 09:37:07 -0500
Content-Disposition: inline
In-Reply-To: <739029197.38929769.1394255661208.JavaMail.root@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 07, 2014 at 09:14:21PM -0800, Shreyas Bhatewara wrote:
> Thanks for the patch Neil. 
> 
> 
> > --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> > +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> > @@ -1762,11 +1762,13 @@ vmxnet3_netpoll(struct net_device *netdev)
> >  {
> >  	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> >  
> > -	if (adapter->intr.mask_mode == VMXNET3_IMM_ACTIVE)
> > -		vmxnet3_disable_all_intrs(adapter);
> > -
> > -	vmxnet3_do_poll(adapter, adapter->rx_queue[0].rx_ring[0].size);
> > -	vmxnet3_enable_all_intrs(adapter);
> > +	switch (adapter->intr.type) {
> > +	case VMXNET3_IT_MSIX:
> > +		vmxnet3_msix_rx(0, &adapter->rx_queue[0]);
> 
> This should be called for each rx queue, just calling it for
> 1st queue does not suffice.
You're right, I'll fix that up.

> Also there should be a break; here
> 
that too. thanks
Neil

> 
> > +	case VMXNET3_IT_MSI:
> > +	default:
> > +		vmxnet3_intr(0, adapter->netdev);
> > +	}
> 
