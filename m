From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 4/20][BNX2]: Fix race conditions when calling
 register_netdev().
Date: Wed, 02 May 2007 18:13:12 -0700
Message-ID: <1178154792.4820.124.camel@dell>
References: <1178068447.4820.40.camel@dell>
 <463838CA.6060002@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1626 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767286AbXECA0O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 20:26:14 -0400
In-Reply-To: <463838CA.6060002@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-02 at 03:07 -0400, Jeff Garzik wrote:
> Michael Chan wrote:
> >  
> > @@ -6195,6 +6197,18 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
> >  	dev->poll_controller = poll_bnx2;
> >  #endif
> >  
> > +	pci_set_drvdata(pdev, dev);
> > +
> > +	memcpy(dev->dev_addr, bp->mac_addr, 6);
> > +	memcpy(dev->perm_addr, bp->mac_addr, 6);
> > +	bp->name = board_info[ent->driver_data].name;
> > +
> > +	dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
> > +#ifdef BCM_VLAN
> > +	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> > +#endif
> > +	dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN;
> > +
> >  	if ((rc = register_netdev(dev))) {
> >  		dev_err(&pdev->dev, "Cannot register net device\n");
> >  		if (bp->regview)
> > @@ -6206,11 +6220,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
> >  		return rc;
> >  	}
> >  
> > -	pci_set_drvdata(pdev, dev);
> > -
> > -	memcpy(dev->dev_addr, bp->mac_addr, 6);
> > -	memcpy(dev->perm_addr, bp->mac_addr, 6);
> > -	bp->name = board_info[ent->driver_data].name,
> 
> NAK.  Since you move the pci_set_drvdata() call, you must now add a call 
> to pci_set_drvdata(pdev, NULL) on error.

It is not obvious in the patch, but it already (unnecessarily) calls
pci_set_drvdata(pdev, NULL) if register_netdev() fails in the driver
today.

