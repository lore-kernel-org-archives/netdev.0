From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports sg
 dma
Date: Wed, 31 Jul 2013 05:47:07 -0700
Message-ID: <20130731124707.GA30635@kroah.com>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
 <1375267909-30373-5-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Neukum <oneukum@suse.de>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:55854 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab3GaMpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 08:45:50 -0400
Content-Disposition: inline
In-Reply-To: <1375267909-30373-5-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 06:51:49PM +0800, Ming Lei wrote:
> This patch enables 'can_dma_sg' flag for ax88179_178a device
> if the attached host controller supports building packet from
> discontinuous buffers(DMA SG is possible), so both frame header
> and skb data buffers can be passed to usb stack via urb->sg,
> then skb data copy can be saved.
> 
> With the patch, CPU utilization decreased much in iperf test at
> client mode.

What is "much"?

> --- a/drivers/net/usb/ax88179_178a.c
> +++ b/drivers/net/usb/ax88179_178a.c
> @@ -1031,12 +1031,20 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
>  	dev->mii.phy_id = 0x03;
>  	dev->mii.supports_gmii = 1;
>  
> +	if (dev->udev->bus->no_sg_limit)
> +		dev->can_dma_sg = 1;

I don't feel comfortable with USB drivers poking about in the USB host
controller structures like this.  If we really do this, please provide a
function call for it to make to determine this.

But even then, is this really something that we want/need to do at all?
If only some xhci controller support this, we will start to see more
driver-specific changes just to handle one type of host controller.  Why
not have the USB core handle it instead and if the host controller can
not do sg lists like this, fall back to a slower implementation?

thanks,

greg k-h
