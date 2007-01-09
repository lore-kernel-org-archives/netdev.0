From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [PATCH 5/5] fixing errors handling during pci_driver resume stage [serial]
Date: Tue, 9 Jan 2007 12:27:53 +0000
Message-ID: <20070109122752.GA26337@flint.arm.linux.org.uk>
References: <87ps9omv3t.fsf@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	devel@openvz.org, linux-pci@atrey.karlin.mff.cuni.cz,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([217.147.92.249]:3073 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbXAIM2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 07:28:09 -0500
To: Dmitriy Monakhov <dmonakhov@openvz.org>
Content-Disposition: inline
In-Reply-To: <87ps9omv3t.fsf@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 09, 2007 at 12:01:58PM +0300, Dmitriy Monakhov wrote:
> serial pci drivers have to return correct error code during resume stage in
> case of errors.

Sigh.  *hate* *hate* *hate*.

> diff --git a/drivers/serial/8250_pci.c b/drivers/serial/8250_pci.c
> index 52e2e64..e26e4a6 100644
> --- a/drivers/serial/8250_pci.c
> +++ b/drivers/serial/8250_pci.c
> @@ -1805,6 +1805,7 @@ static int pciserial_suspend_one(struct
>  static int pciserial_resume_one(struct pci_dev *dev)
>  {
>  	struct serial_private *priv = pci_get_drvdata(dev);
> +	int err;
>  
>  	pci_set_power_state(dev, PCI_D0);
>  	pci_restore_state(dev);
> @@ -1813,7 +1814,12 @@ static int pciserial_resume_one(struct p
>  		/*
>  		 * The device may have been disabled.  Re-enable it.
>  		 */
> -		pci_enable_device(dev);
> +		err = pci_enable_device(dev);
> +		if (err) {
> +			dev_err(&dev->dev, "Cannot enable PCI device, "
> +				"aborting.\n");
> +			return err;
> +		}
>  
>  		pciserial_resume_ports(priv);
>  	}

So if pci_enable_device() fails, what do we do with the still suspended
serial port?  Does it clean up that state?  Probably not.

Look, merely going around bunging this stupid "oh lets propagate the
error" crap into the kernel doesn't actually fix _anything_.  In fact
it potentially _hides_ the warnings produced by __must_check which
give a hint that _something_ needs to be done to _properly_ fix the
problem.

And by "properly", I mean not just merely propagating the error.

In this particular case, the above may result in resources not being
freed.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:
