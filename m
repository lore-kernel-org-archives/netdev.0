From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: always set num
 queues if possible
Date: Tue, 15 Sep 2015 10:37:47 -0400
Message-ID: <1442327867.3494.17.camel@gmail.com>
References: <1442266096.3494.15.camel@gmail.com>
	 <55F7FA2D.5040701@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:32769 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619AbbIOOhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 10:37:50 -0400
Received: by qkdw123 with SMTP id w123so72790087qkd.0
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 07:37:48 -0700 (PDT)
In-Reply-To: <55F7FA2D.5040701@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-15 at 11:59 +0100, David Vrabel wrote:
> On 14/09/15 22:28, Charles (Chas) Williams wrote:
> > The xen store preserves this information across module invocations.
> > If you insmod netfront with two queues and later insmod again with one
> > queue, the backend will still believe you asked for two queues.
> 
> Can you rewrite the commit message to be clearer?
> 
> "If netfront connects with 2 (or more) queues and then reconnects with
> only 1 queue it fails to delete or rewrite the multi-queue-num-queues
> key and netback will try to use the wrong number of queues.
> 
> Always write the num-queues field if the backend has multi-queue support."

Yes I can do that.

> 
> > --- a/drivers/net/xen-netfront.c
> > +++ b/drivers/net/xen-netfront.c
> > @@ -1819,11 +1819,7 @@ again:
> >  		goto destroy_ring;
> >  	}
> >  
> > -	if (num_queues == 1) {
> > -		err = write_queue_xenstore_keys(&info->queues[0], &xbt, 0); /* flat */
> > -		if (err)
> > -			goto abort_transaction_no_dev_fatal;
> > -	} else {
> > +	if (xenbus_exists(xbt, dev->nodename, "multi-queue-num-queues")) {
> >  		/* Write the number of queues */
> >  		err = xenbus_printf(xbt, dev->nodename, "multi-queue-num-queues",
> >  				    "%u", num_queues);
> 
> Isn't this broken?  It looks like it won't write the
> multi-queue-num-queues key the first time around.
> 
> It think this should be conditional on multi-queue-max-queues existing
> (which is written by the backend if multi-queue is supported).

You are right.  I am testing against the wrong key here.  I should have
tested for multi-queue-max-queues.
