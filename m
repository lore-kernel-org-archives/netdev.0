From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [patch for 2.6.27? 01/10] e100: adapt to the reworked PCI PM
Date: Mon, 22 Sep 2008 23:41:04 +0200
Message-ID: <200809222341.05137.rjw@sisk.pl>
References: <200809222110.m8MLAFYm029864@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, elendil@planet.nl,
	jbarnes@virtuousgeek.org, jeffrey.t.kirsher@intel.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:35681 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753018AbYIVVfm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 17:35:42 -0400
In-Reply-To: <200809222110.m8MLAFYm029864@imap1.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 22 of September 2008, akpm@linux-foundation.org wrote:
> From: "Rafael J. Wysocki" <rjw@sisk.pl>
> 
> Adapt the e100 driver to the reworked PCI PM
> 
> * Use device_set_wakeup_enable() and friends as needed
> * Use pci_pme_active() to clear PME_Status and disable PME#

Well, this part has already been merged. :-)

> * Use the observation that it is sufficient to call pci_enable_wake()
>   once, unless it fails

The rest wouldn't hurt in .27, but it can wait for .28 just as well IMO.

> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Tested-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Barnes <jbarnes@virtuousgeek.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Frans Pop <elendil@planet.nl>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/e100.c |   16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
> 
> diff -puN drivers/net/e100.c~e100-adapt-to-the-reworked-pci-pm drivers/net/e100.c
> --- a/drivers/net/e100.c~e100-adapt-to-the-reworked-pci-pm
> +++ a/drivers/net/e100.c
> @@ -2211,7 +2211,8 @@ static int e100_set_wol(struct net_devic
>  {
>  	struct nic *nic = netdev_priv(netdev);
>  
> -	if(wol->wolopts != WAKE_MAGIC && wol->wolopts != 0)
> +	if ((wol->wolopts && wol->wolopts != WAKE_MAGIC) ||
> +	    !device_can_wakeup(&nic->pdev->dev))
>  		return -EOPNOTSUPP;
>  
>  	if(wol->wolopts)
> @@ -2219,6 +2220,8 @@ static int e100_set_wol(struct net_devic
>  	else
>  		nic->flags &= ~wol_magic;
>  
> +	device_set_wakeup_enable(&nic->pdev->dev, wol->wolopts);
> +
>  	e100_exec_cb(nic, NULL, e100_configure);
>  
>  	return 0;
> @@ -2623,8 +2626,10 @@ static int __devinit e100_probe(struct p
>  
>  	/* Wol magic packet can be enabled from eeprom */
>  	if((nic->mac >= mac_82558_D101_A4) &&
> -	   (nic->eeprom[eeprom_id] & eeprom_id_wol))
> +	   (nic->eeprom[eeprom_id] & eeprom_id_wol)) {
>  		nic->flags |= wol_magic;
> +		device_set_wakeup_enable(&pdev->dev, true);
> +	}
>  
>  	/* ack any pending wake events, disable PME */
>  	pci_pme_active(pdev, false);
> @@ -2683,11 +2688,10 @@ static int e100_suspend(struct pci_dev *
>  	pci_save_state(pdev);
>  
>  	if ((nic->flags & wol_magic) | e100_asf(nic)) {
> -		pci_enable_wake(pdev, PCI_D3hot, 1);
> -		pci_enable_wake(pdev, PCI_D3cold, 1);
> +		if (pci_enable_wake(pdev, PCI_D3cold, true))
> +			pci_enable_wake(pdev, PCI_D3hot, true);
>  	} else {
> -		pci_enable_wake(pdev, PCI_D3hot, 0);
> -		pci_enable_wake(pdev, PCI_D3cold, 0);
> +		pci_enable_wake(pdev, PCI_D3hot, false);
>  	}
>  
>  	pci_disable_device(pdev);
> _
> 
> 


