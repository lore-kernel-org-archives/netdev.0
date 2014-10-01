From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: vnet_start_xmit() must hold a refcnt
 on port.
Date: Wed, 01 Oct 2014 15:06:12 -0400
Message-ID: <542C50A4.30304@oracle.com>
References: <20141001185622.GI17706@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	davem@davemloft.net, raghuram.kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50779 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbaJATGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:06:18 -0400
In-Reply-To: <20141001185622.GI17706@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/01/2014 02:56 PM, Sowmini Varadhan wrote:

> -	list_for_each_entry(port, &vp->port_list, list) {
> -		if (!port->switch_port)
> -			continue;
> -		if (!port_is_up(port))
> -			continue;
> +	port = vp->switch_port;
> +	if (port != NULL && port_is_up(port)) {
> +		vnet_hold(port);
>  		return port;
>  	}
>  	return NULL;

This "vp->switch_port" addition doesn't appear to be related to the port refcnt
change, and doesn't allow for multiple switch ports.

						+-DLS


> @@ -1581,10 +1621,12 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
>  	port->switch_port = switch_port;
>  
>  	spin_lock_irqsave(&vp->lock, flags);
> -	if (switch_port)
> +	if (switch_port) {
> +		vp->switch_port = port;
>  		list_add(&port->list, &vp->port_list);

...and here.

> -	else
> +	} else {
>  		list_add_tail(&port->list, &vp->port_list);
> +	}
>  	hlist_add_head(&port->hash, &vp->port_hash[vnet_hashfn(port->raddr)]);
>  	spin_unlock_irqrestore(&vp->lock, flags);
>  
> @@ -1631,11 +1673,14 @@ static int vnet_port_remove(struct vio_dev *vdev)
>  		 */
>  		spin_lock_irqsave(&vp->lock, flags);
>  		port->flags |= VNET_PORT_DEAD;
> +		if (port->switch_port)
> +			vp->switch_port = NULL;
>  		list_del(&port->list);
>  		hlist_del(&port->hash);

..and here.
