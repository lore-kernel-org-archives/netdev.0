From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] smsc75xx: only set mac address once on bind
Date: Mon, 10 Dec 2012 17:00:07 -0600
Message-ID: <1355180407.19156.32.camel@dcbw.foobar.com>
References: <1355137279-2695-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bjorn Mork <bjorn@mork.no>
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595Ab2LJW7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 17:59:03 -0500
In-Reply-To: <1355137279-2695-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-10 at 11:01 +0000, Steve Glendinning wrote:
> This patch changes when we decide what the device's MAC address
> is from per ifconfig up to once when the device is connected.
> 
> Without this patch, a manually forced device MAC is overwritten
> on ifconfig down/up.  Also devices that have no EEPROM are
> assigned a new random address on ifconfig down/up instead of
> persisting the same one.

Does this mean that on devices without EEPROM, ifconfig XXX
down/ifconfig XXX up will generate a *new* random address?  That seems a
bit odd; why wouldn't the first random address generated for the device
persist until either (a) changed by ifconfig or (b) device was
disconnected?

Dan

> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
> Reported-by: Robert Cunningham <rcunningham@nsmsurveillance.com>
> Cc: Bjorn Mork <bjorn@mork.no>
> Cc: Dan Williams <dcbw@redhat.com>
> ---
>  drivers/net/usb/smsc75xx.c |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
> index 1cbd936..251a335 100644
> --- a/drivers/net/usb/smsc75xx.c
> +++ b/drivers/net/usb/smsc75xx.c
> @@ -1054,8 +1054,6 @@ static int smsc75xx_reset(struct usbnet *dev)
>  
>  	netif_dbg(dev, ifup, dev->net, "PHY reset complete\n");
>  
> -	smsc75xx_init_mac_address(dev);
> -
>  	ret = smsc75xx_set_mac_address(dev);
>  	if (ret < 0) {
>  		netdev_warn(dev->net, "Failed to set mac address\n");
> @@ -1422,6 +1420,14 @@ static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
>  	dev->net->hw_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  		NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_RXCSUM;
>  
> +	ret = smsc75xx_wait_ready(dev, 0);
> +	if (ret < 0) {
> +		netdev_warn(dev->net, "device not ready in smsc75xx_bind\n");
> +		return ret;
> +	}
> +
> +	smsc75xx_init_mac_address(dev);
> +
>  	/* Init all registers */
>  	ret = smsc75xx_reset(dev);
>  	if (ret < 0) {
