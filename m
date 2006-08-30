From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: NAPI: netif_rx_reschedule() ??
Date: Wed, 30 Aug 2006 16:12:19 -0700
Message-ID: <20060830161219.7878bada@localhost.localdomain>
References: <adau03tlvx8.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27546 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751610AbWH3XM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 19:12:28 -0400
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adau03tlvx8.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2006 15:07:31 -0700
Roland Dreier <rdreier@cisco.com> wrote:

> I'm looking at updating IP-over-InfiniBand to use NAPI, and due to the
> way IB works, the driver is going to be susceptible to the rotting
> packet problem.  It seems I'm going to have to call netif_rx_reschedule().

Looking at it, I'm not sure netif_rx_reschedule was well thought out.
It shouldn't be inlined if many places start using it.

> However I'm confused about a couple of things, and there are only two
> uses of netif_rx_reschedule() in the kernel, so I'm a little stuck.
> 
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

The undo should really be handled by the caller, not in netif_rx_reschedule.
The existing interface assumes you have already deducted N from your quota
and so it needs to be put back.

> 
> 2. What is the return value supposed to be used for?  ibmveth.c
>    returns from the poll method if netif_rx_reschedule() returns 0 (ie
>    the poll was already scheduled); ibm_emac_mal.c jumps back to
>    repoll regardless of the return value, and NAPI_HOWTO.txt has
> 
> 	if (ring_has_new_packet() && netif_rx_reschedule(dev, received)) {
> 		disable_rx_and_rxnobufs()
> 		goto restart_poll
> 	} while (rx_status_is_set);
> 
>    which is not particularly enlightening to say the least...
>    if (...) {...} while (...) ?!
> 
>    It's not clear to me why the driver would want to do something
>    different depending on whether the NAPI poll was already scheduled
>    or not.

If poll is already scheduled, then after leaving this poll call,
another will occur.  If the poll routine just went ahead and rescanned
that would work as well. The important part is not to leave the
poll routine without being in one of these states:
	* all work is done, and hardware is empty and/or will interrupt for more.
	* some work was done, and device left on poll_list with softirq raised




-- 
Stephen Hemminger <shemminger@osdl.org>
