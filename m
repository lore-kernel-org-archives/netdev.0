From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/9] PCI: revise VPD access interface (rev3)
Date: Thu, 25 Sep 2008 18:58:52 +0100
Message-ID: <1222365532.8641.86.camel@achroite>
References: <20080925164851.694359776@vyatta.com>
	 <20080925165223.268510251@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Ivan Vecera <ivecera@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:56580 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753198AbYIYR67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 13:58:59 -0400
In-Reply-To: <20080925165223.268510251@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-09-25 at 09:48 -0700, Stephen Hemminger wrote:
[...]
> -static int pci_vpd_pci22_write(struct pci_dev *dev, int pos, int size,
> -			       const char *buf)
> +static ssize_t pci_vpd_pci22_write(struct pci_dev *dev, loff_t pos, size_t count,
> +				   const void *arg)
>  {
>  	struct pci_vpd_pci22 *vpd =
>  		container_of(dev->vpd, struct pci_vpd_pci22, base);
> -	u32 val;
> +	const u8 *buf = arg;
> +	loff_t end = pos + count;

count should be (count & ~3)

>  	int ret = 0;
>  
> -	if (pos < 0 || pos > vpd->base.len || pos & 3 ||
> -	    size > vpd->base.len - pos || size < 4)
> +	if (pos > vpd->base.len || pos & 3)
>  		return -EINVAL;

Why did you remove the tests for pos < 0 and size > vpd->base.len - pos?
I know write_vpd_attr() checks these but you're about to add other
callers.

[...]
>  out:
>  	mutex_unlock(&vpd->lock);
> -	if (ret < 0)
> -		return ret;
> -
> -	return 4;
> +	return ret ? ret : count;
>  }
[...]

count should be (count & ~3)

Alternately you could treat (count & 3) != 0 as invalid.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

