From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: NAPI: netif_rx_reschedule() ??
Date: Fri, 1 Sep 2006 03:54:54 +0400
Message-ID: <20060831235454.GA13068@ms2.inr.ac.ru>
References: <adau03tlvx8.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:60320 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932492AbWHaXy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 19:54:58 -0400
To: Roland Dreier <rdreier@cisco.com>
Content-Disposition: inline
In-Reply-To: <adau03tlvx8.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> However I'm confused about a couple of things, and there are only two
> uses of netif_rx_reschedule() in the kernel, so I'm a little stuck.

First, do not believe to even single bit of code or docs about
netif_rx_reschedule(). It was used once in the first version of NAPI
for 3com driver (which did not go to mainstream) and was left to rot. :-)


> 1. What is the intent of the second, 'undo' parameter?  For example,
>    ibmveth.c does
> 
> 	if(ibmveth_rxq_pending_buffer(adapter) && netif_rx_reschedule(netdev, frames_processed))
> 	{
> 		lpar_rc = h_vio_signal(adapter->vdev->unit_address, VIO_IRQ_DISABLE);
> 		ibmveth_assert(lpar_rc == H_SUCCESS);
> 		more_work = 1;
> 		goto restart_poll;
> 	}
> 
>    but it only does
> 
> 	netdev->quota -= frames_processed;
> 
>    _after_ that block (and the jump back to restart_poll).  So the
>    whole things seems fishy: netdev->quota goes up by the number of
>    frames processed??

It is broken. netdev->quota MUST not be touched after netif_rx_complete().
Authors improved coding style, moving it closer to update of *budget
and it is wrong. First, because it is changed in an absolutely unserialized
context, second... you noticed.


>    It's not clear to me why the driver would want to do something
>    different depending on whether the NAPI poll was already scheduled
>    or not.

netif_rx_complete() released control. ->poll can be reentered on another
CPU after this.

If netif_rx_reschedule() fails, it means that ->poll must exit, because
poll was already rescheduled.

If it succeds, it means current thread got control back. Changes made
before netif_rx_complete(), becuase we were going to exit, (netdev->quota etc)
are undone and loop can be restarted.

To be honest, I do not recollect everything. F.e. scheduling softirq
in netif_rx_reschedule() looks like a cut-n-paste bug.

Alexey
