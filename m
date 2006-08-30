From: Roland Dreier <rdreier@cisco.com>
Subject: NAPI: netif_rx_reschedule() ??
Date: Wed, 30 Aug 2006 15:07:31 -0700
Message-ID: <adau03tlvx8.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:13117 "EHLO
	sj-iport-1.cisco.com") by vger.kernel.org with ESMTP
	id S932162AbWH3WHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 18:07:33 -0400
Received: from sj-core-1.cisco.com (sj-core-1.cisco.com [171.71.177.237])
	by sj-dkim-2.cisco.com (8.12.11.20060308/8.12.11) with ESMTP id k7UM7W6V009886
	for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 15:07:32 -0700
Received: from xbh-sjc-211.amer.cisco.com (xbh-sjc-211.cisco.com [171.70.151.144])
	by sj-core-1.cisco.com (8.12.10/8.12.6) with ESMTP id k7UM7WQX002557
	for <netdev@vger.kernel.org>; Wed, 30 Aug 2006 15:07:32 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm looking at updating IP-over-InfiniBand to use NAPI, and due to the
way IB works, the driver is going to be susceptible to the rotting
packet problem.  It seems I'm going to have to call netif_rx_reschedule().

However I'm confused about a couple of things, and there are only two
uses of netif_rx_reschedule() in the kernel, so I'm a little stuck.

1. What is the intent of the second, 'undo' parameter?  For example,
   ibmveth.c does

	if(ibmveth_rxq_pending_buffer(adapter) && netif_rx_reschedule(netdev, frames_processed))
	{
		lpar_rc = h_vio_signal(adapter->vdev->unit_address, VIO_IRQ_DISABLE);
		ibmveth_assert(lpar_rc == H_SUCCESS);
		more_work = 1;
		goto restart_poll;
	}

   but it only does

	netdev->quota -= frames_processed;

   _after_ that block (and the jump back to restart_poll).  So the
   whole things seems fishy: netdev->quota goes up by the number of
   frames processed??

2. What is the return value supposed to be used for?  ibmveth.c
   returns from the poll method if netif_rx_reschedule() returns 0 (ie
   the poll was already scheduled); ibm_emac_mal.c jumps back to
   repoll regardless of the return value, and NAPI_HOWTO.txt has

	if (ring_has_new_packet() && netif_rx_reschedule(dev, received)) {
		disable_rx_and_rxnobufs()
		goto restart_poll
	} while (rx_status_is_set);

   which is not particularly enlightening to say the least...
   if (...) {...} while (...) ?!

   It's not clear to me why the driver would want to do something
   different depending on whether the NAPI poll was already scheduled
   or not.

Thanks,
  Roland
