From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: improve error handling when a remote
 crashes
Date: Mon, 26 Jan 2015 14:54:03 -0500
Message-ID: <20150126195403.GE6437@oracle.com>
References: <54C6911B.5040501@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29384 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753818AbbAZTyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 14:54:07 -0500
Content-Disposition: inline
In-Reply-To: <54C6911B.5040501@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




> @@ -934,36 +933,36 @@ static struct sk_buff *vnet_clean_tx_ring(struct vnet_port *port,
>  
>  	*pending = 0;
>  
> -	txi = dr->prod-1;
> -	if (txi < 0)
> -		txi = VNET_TX_RING_SIZE-1;
> -
> +	txi = dr->prod;

As I understand it, this starts at dr->prod and goes through all
descriptors, cleaning up !READY descriptors as it goes around.

I think you'll have a higher reclaim rate for finding !READY if you
started at dr->cons instead: dr->cons is the one that was last ACK'ed,
and that ack would only have been sent after the peer had marked the 
descriptor as DONE. (consumer would have had a chance to read more
descriptors, by the time the tx-reclaim loop goes around) 

> +		if (port->tx_bufs[txi].skb) {
> +			if (d->hdr.state != VIO_DESC_DONE)
> +				pr_warn("invalid ring buffer state %d\n",
> +					d->hdr.state);

I would even suggest skipping the pr_warn (maybe make it a viodbg
instead) as it might alarm the end-user (who cannot really do 
anything about it other than call us anyway :-)).

>  			   dr->cookies, dr->ncookies);
> +	if (active_freed)
> +		pr_warn("%s: active transmit buffers freed for remote %pM\n",
> +			dev->name, port->raddr);

Same comment as above.

In general, I think we need some sysfs/ethtool  bean-counters/statistics
for sunvnet, to keep track of this sort of thing efficiently in 
a production env without triggering red-herrings calls.

--Sowmini
