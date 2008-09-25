From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] hso for error -22 (-EINVAL) printk's
Date: Wed, 24 Sep 2008 22:10:31 -0400
Message-ID: <48DAF317.4040704@garzik.org>
References: <48CFC7C1.6020301@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
To: Denis Joseph Barrow <D.Barow@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56471 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753104AbYIYCKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 22:10:35 -0400
In-Reply-To: <48CFC7C1.6020301@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis Joseph Barrow wrote:
> Added check for IFF_UP in hso_resume, this should eliminate -EINVAL (-22)
> errors caused from urb's being submitted twice, once by hso_resume
> & once in hso_net_open, if suspend/resume USB power saving  mode is enabled
> Signed-off-by: Denis Joseph Barrow <D.Barow@option.com>
> ---
> Index: linux-2.6.27-rc6/drivers/net/usb/hso.c
> ===================================================================
> --- linux-2.6.27-rc6.orig/drivers/net/usb/hso.c	2008-09-16 16:17:11.000000000 +0200
> +++ linux-2.6.27-rc6/drivers/net/usb/hso.c	2008-09-16 16:32:05.000000000 +0200
> @@ -2606,18 +2606,21 @@
>  		if (network_table[i] &&
>  		    (network_table[i]->interface == iface)) {
>  			hso_net = dev2net(network_table[i]);
> -			/* First transmit any lingering data, then restart the
> -			 * device. */
> -			if (hso_net->skb_tx_buf) {
> -				dev_dbg(&iface->dev,
> -					"Transmitting lingering data\n");
> -				hso_net_start_xmit(hso_net->skb_tx_buf,
> -						   hso_net->net);
> -				hso_net->skb_tx_buf = NULL;
> +			if (hso_net->flags & IFF_UP) {
> +				/* First transmit any lingering data,
> +				   then restart the device. */
> +				if (hso_net->skb_tx_buf) {
> +					dev_dbg(&iface->dev,
> +						"Transmitting"
> +						" lingering data\n");
> +					hso_net_start_xmit(hso_net->skb_tx_buf,
> +							   hso_net->net);
> +					hso_net->skb_tx_buf = NULL;
> +				}
> +				result = hso_start_net_device(network_table[i]);
> +				if (result)
> +					goto out;

you should be checking netif_running() not IFF_UP


