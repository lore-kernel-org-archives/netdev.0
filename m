From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2/3] NetXen: Support per PCI-function interrupt mask registers
Date: Sun, 1 Jul 2007 00:17:33 +0200
Message-ID: <200707010017.33917.mb@bu3sch.de>
References: <20070630203844.256007454@netxen.com> <20070630204423.353697018@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob@netxen.com
To: dhananjay.phadke@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:45125
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953AbXF3WSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 18:18:15 -0400
In-Reply-To: <20070630204423.353697018@netxen.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 30 June 2007 22:38:46 dhananjay.phadke@gmail.com wrote:
> This patch updates the various access routines to access different
> control and status settings present in different register locations.
> This will fix problems related to working of different ports in
> multi Port card.
> 
> Signed-off by: Dhananjay Phadke <dhananjay@netxen.com>
> Signed-off by: Milan Bag <mbag@netxen.com>

> +	/* Window = 0 or 1 */
> +	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
> +		do {
> +			writel(0xffffffff, (void *)
> +				(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_STATUS)));
> +			mask = readl((void *)
> +					(pci_base_offset(adapter, ISR_INT_VECTOR)));

I think you should add a small delay into this loop. Otherwise
it depends on the speed of the CPU (and chipset) how big the total
timeout (32) of the loop is. Could be too small on fast systems.
Something like:
			if (!(mask & 0x80))
				break;
			udelay(10);
			} while (++count < 32);
and drop the next line.

> +		} while (((mask & 0x80) != 0) && (++count < 32));
> +
> +		if ((mask & 0x80) != 0) {
> +			printk(KERN_NOTICE "Could not disable interrupt completely\n");
> +		}
> +	}
> +
> +	DPRINTK(1, INFO, "Done with Disable Int\n");
> +
> +	return;
>  }

-- 
Greetings Michael.
