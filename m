From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: always set num queues
 if possible
Date: Tue, 15 Sep 2015 11:59:57 +0100
Message-ID: <55F7FA2D.5040701@citrix.com>
References: <1442266096.3494.15.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
To: "Charles (Chas) Williams" <3chas3@gmail.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:56148 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818AbbIOLAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 07:00:00 -0400
In-Reply-To: <1442266096.3494.15.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/09/15 22:28, Charles (Chas) Williams wrote:
> The xen store preserves this information across module invocations.
> If you insmod netfront with two queues and later insmod again with one
> queue, the backend will still believe you asked for two queues.

Can you rewrite the commit message to be clearer?

"If netfront connects with 2 (or more) queues and then reconnects with
only 1 queue it fails to delete or rewrite the multi-queue-num-queues
key and netback will try to use the wrong number of queues.

Always write the num-queues field if the backend has multi-queue support."

> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1819,11 +1819,7 @@ again:
>  		goto destroy_ring;
>  	}
>  
> -	if (num_queues == 1) {
> -		err = write_queue_xenstore_keys(&info->queues[0], &xbt, 0); /* flat */
> -		if (err)
> -			goto abort_transaction_no_dev_fatal;
> -	} else {
> +	if (xenbus_exists(xbt, dev->nodename, "multi-queue-num-queues")) {
>  		/* Write the number of queues */
>  		err = xenbus_printf(xbt, dev->nodename, "multi-queue-num-queues",
>  				    "%u", num_queues);

Isn't this broken?  It looks like it won't write the
multi-queue-num-queues key the first time around.

It think this should be conditional on multi-queue-max-queues existing
(which is written by the backend if multi-queue is supported).

David
