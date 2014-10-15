From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv3 RFC net-next 1/4] sunvnet: NAPIfy sunvnet
Date: Wed, 15 Oct 2014 13:17:40 -0400
Message-ID: <543EAC34.1010502@oracle.com>
References: <20141015164252.GB11840@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	davem@davemloft.net, bob.picco@oracle.com, dwight.engen@oracle.com,
	raghuram.kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30552 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbaJORRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 13:17:47 -0400
In-Reply-To: <20141015164252.GB11840@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/15/2014 12:42 PM, Sowmini Varadhan wrote:

> @@ -274,6 +276,7 @@ static struct sk_buff *alloc_and_align_skb(struct net_device *dev,
>  	return skb;
>  }
>  
> +/* reads in exactly one sk_buff */
>  static int vnet_rx_one(struct vnet_port *port, unsigned int len,
>  		       struct ldc_trans_cookie *cookies, int ncookies)
>  {

I'm not sure this comment adds any clarity.

	return PTR_ERR(desc);
>  
> @@ -444,6 +446,7 @@ static int vnet_walk_rx_one(struct vnet_port *port,
>  	       desc->cookies[0].cookie_addr,
>  	       desc->cookies[0].cookie_size);
>  
> +	/* read in one packet */
>  	err = vnet_rx_one(port, desc->size, desc->cookies, desc->ncookies);
>  	if (err == -ECONNRESET)
>  		return err;

or this one.

> @@ -456,10 +459,11 @@ static int vnet_walk_rx_one(struct vnet_port *port,
>  }
>  
>  static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
> -			u32 start, u32 end)
> +			u32 start, u32 end, int *npkts, int budget)
>  {
>  	struct vio_driver_state *vio = &port->vio;
>  	int ack_start = -1, ack_end = -1;
> +	int send_ack = 1;
>  
>  	end = (end == (u32) -1) ? prev_idx(start, dr) : next_idx(end, dr);
>  

suggest making this a "bool send_ack;" with below change.

> @@ -471,6 +475,7 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
>  			return err;
>  		if (err != 0)
>  			break;
> +		(*npkts)++;
>  		if (ack_start == -1)
>  			ack_start = start;
>  		ack_end = start;
> @@ -482,13 +487,26 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
>  				return err;
>  			ack_start = -1;
>  		}
> +		if ((*npkts) >= budget) {
> +			send_ack = 0;
> +			break;
> +		}
>  	}

suggest:
		send_ack = (*nkpts) < budget;
		if (!send_ack)
			break;


> @@ -591,9 +612,8 @@ static int handle_mcast(struct vnet_port *port, void *msgbuf)
>  	return 0;
>  }
>  
> -static void maybe_tx_wakeup(unsigned long param)
> +static void maybe_tx_wakeup(struct vnet *vp)
>  {
> -	struct vnet *vp = (struct vnet *)param;
>  	struct net_device *dev = vp->dev;
>  
>  	netif_tx_lock(dev);

Isn't this a function type conflict for tasklet_init()?

					+-DLS
