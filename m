From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: de2104x: fix power management
Date: Sat, 25 Sep 2010 13:16:56 -0400
Message-ID: <4C9E2E88.3080101@pobox.com>
References: <201009251157.07197.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:40511 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753597Ab0IYRRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 13:17:00 -0400
In-Reply-To: <201009251157.07197.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2010 05:57 AM, Ondrej Zary wrote:
> At least my 21041 cards come out of suspend with bus mastering disabled so
> they did not work after resume(no data transferred).
> After adding pci_set_master(), the driver oopsed immediately on resume -
> because de_clean_rings() is called on suspend but de_init_rings() call
> was missing in resume.
>
> Also disable link (reset SIA) before sleep (de4x5 does this too).
>
> Signed-off-by: Ondrej Zary<linux@rainbow-software.org>
>
> --- linux-2.6.36-rc3-/drivers/net/tulip/de2104x.c	2010-09-25 11:27:26.000000000 +0200
> +++ linux-2.6.36-rc3/drivers/net/tulip/de2104x.c	2010-09-25 11:29:22.000000000 +0200
> @@ -1231,6 +1231,7 @@ static void de_adapter_sleep (struct de_
>   	if (de->de21040)
>   		return;
>
> +	dw32(CSR13, 0); /* Reset phy */
>   	pci_read_config_dword(de->pdev, PCIPM,&pmctl);
>   	pmctl |= PM_Sleep;
>   	pci_write_config_dword(de->pdev, PCIPM, pmctl);
> @@ -2166,6 +2167,8 @@ static int de_resume (struct pci_dev *pd
>   		dev_err(&dev->dev, "pci_enable_device failed in resume\n");
>   		goto out;
>   	}
> +	pci_set_master(pdev);
> +	de_init_rings(de);
>   	de_init_hw(de);
>   out_attach:
>   	netif_device_attach(dev);

Acked-by: Jeff Garzik <jgarzik@redhat.com>

IMO suspend/resume could use another look; if netif_running is false 
(interface is down), de2104x does not put the PCI device to sleep, which 
seems strange.

I also wonder if rtnl_lock() couldn't be eliminated, as other net 
drivers don't need it in suspend/resume.

