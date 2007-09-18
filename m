From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/2] IPoIB: Fix unregister_netdev hang
Date: Tue, 18 Sep 2007 07:27:24 -0700
Message-ID: <adalkb4kq0j.fsf@cisco.com>
References: <20070918111803.1769.60619.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org,
	davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:24103 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755274AbXIRO1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 10:27:31 -0400
In-Reply-To: <20070918111803.1769.60619.sendpatchset@localhost.localdomain> (Krishna Kumar's message of "Tue, 18 Sep 2007 16:48:03 +0530")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for testing on ehca...

 > While using IPoIB over EHCA (rc6 bits), unregister_netdev hangs with

I don't think you're actually using rc6 bits, since in your patch you have:

 > -poll_more:

and I think that is only in Dave's net-2.6.24 tree now, right?

 > The problem is that the poll handler does netif_rx_complete (which
 > does a dev_put) followed by netif_rx_reschedule() to schedule for
 > more receives (which again does a dev_put). This reduces refcount to
 > < 0 (depending on how many times netif_rx_complete followed by
 > netif_rx_reschedule was called).

Dave, the real problem seems to be that netif_rx_recschedule() calls
__napi_schedule() rather than __netif_rx_schedule(), so it misses the
call to dev_hold() that is needed to balance the dev_put() in
netif_rx_complete().  The current netif_rx_reschedule() looks like it
really should be napi_reschedule(), and we need a new function that
takes a netdev too.  Or am I misunderstanding the refcounting?

I'll send a patch once I've had some breakfast and had a chance to at
least compile it...

Krishna, unfortunately your proposed fix has a race:

 > -		netif_rx_complete(dev, napi);
 > -		if (unlikely(ib_req_notify_cq(priv->cq,
 > -					      IB_CQ_NEXT_COMP |
 > -					      IB_CQ_REPORT_MISSED_EVENTS)) &&
 > -		    netif_rx_reschedule(napi))
 > -			goto poll_more;
 > +		if (likely(!ib_req_notify_cq(priv->cq,
 > +					     IB_CQ_NEXT_COMP |
 > +					     IB_CQ_REPORT_MISSED_EVENTS)))

It is possible for an interrupt to happen immediately right here,
before the netif_rx_complete(), so that netif_rx_schedule() gets
called while we are still on the poll list.

 > +			netif_rx_complete(dev, napi);

 - R.
