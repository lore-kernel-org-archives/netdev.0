From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] pci: fix kexec with power state D3
Date: Sun, 8 Mar 2009 11:08:23 +0100
Message-ID: <200903081108.24541.rjw@sisk.pl>
References: <49B1F934.5050006@kernel.org> <4807377b0903062318q15ba52a7n82d4c9399b8a7fa8@mail.gmail.com> <49B37D38.7060304@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, linux-pci@vger.kernel.org,
	pm list <linux-pm@lists.linux-foundation.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:33336 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891AbZCHKIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Mar 2009 06:08:16 -0400
In-Reply-To: <49B37D38.7060304@kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 08 March 2009, Yinghai Lu wrote:
> 
> Impact: second kernel by kexec will have some pci devices working
> 
> Found one system with 82575EB, in the kernel that is kexeced, probe igb
> failed with -2.
> 
> it looks like the same behavior happened on forcedeth.
> try to check system_state to make sure if put it on D3

This is not enough, because the PM code doesn't change system_state and
it uses pci_set_power_state too.

> Jesse Brandeburg said that we should do that check in core code instead of
> every device driver.

Well, I'm not really sure.  The drivers are where the bug is.

> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> 
> ---
>  drivers/pci/pci.c |   17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> Index: linux-2.6/drivers/pci/pci.c
> ===================================================================
> --- linux-2.6.orig/drivers/pci/pci.c
> +++ linux-2.6/drivers/pci/pci.c
> @@ -593,6 +593,14 @@ int pci_set_power_state(struct pci_dev *
>  	if (state == PCI_D3hot && (dev->dev_flags & PCI_DEV_FLAGS_NO_D3))
>  		return 0;
>  
> +	/*
> +	 * Apparently it is not possible to reinitialise from D3 hot,
> +	 * only put the device into D3 if we really go for poweroff.
> +	 */
> +	if (system_state != SYSTEM_POWER_OFF &&
> +	    (state == PCI_D3hot || state == PCI_D3cold))
> +		return 0;
> +

This breaks suspend/hibernation, doesn't it?  Surely, we want to put devices
into D3 when going for suspend, for example.

That's apart from the fact that the 'state == PCI_D3cold' is redundant.

>  	error = pci_raw_set_power_state(dev, state, true);
>  
>  	if (state > PCI_D0 && platform_pci_power_manageable(dev)) {
> @@ -1124,6 +1132,15 @@ int pci_enable_wake(struct pci_dev *dev,
>  	int error = 0;
>  	bool pme_done = false;
>  
> +	/*
> +	 * Apparently it is not possible to reinitialise from D3 hot,
> +	 * only put the device into D3 if we really go for poweroff.
> +	 * we only need to enable wake when we are going to power off
> +	 */
> +	if (enable && system_state != SYSTEM_POWER_OFF &&
> +	    (state == PCI_D3hot || state == PCI_D3cold))
> +		return 0;
> +
>  	if (enable && !device_may_wakeup(&dev->dev))
>  		return -EINVAL;

I don't like this at all, sorry.

I thought we were supposed to avoid using system_state in such a way,
apart from the other things.

Thanks,
Rafael
