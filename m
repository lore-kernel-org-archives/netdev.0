From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Tue, 07 Aug 2007 15:37:30 -0700
Message-ID: <adasl6vq8d1.fsf@cisco.com>
References: <20070805.232423.21363072.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2-in.cisco.com ([171.71.176.71]:9289 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbXHGWhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 18:37:32 -0400
In-Reply-To: <20070805.232423.21363072.davem@davemloft.net> (David Miller's message of "Sun, 05 Aug 2007 23:24:23 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for looking at ipoib... overall looks fine, just a few comments.

 > --- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
 > +++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
 > @@ -281,63 +281,58 @@ static void ipoib_ib_handle_tx_wc(struct net_device *dev, struct ib_wc *wc)
 >  			   wc->status, wr_id, wc->vendor_err);
 >  }
 >  
 > -int ipoib_poll(struct net_device *dev, int *budget)
 > +int ipoib_poll(struct napi_struct *napi, int budget)

 > +poll_more:
 > +	while (done < budget) {
 > +		int max = (budget - done);
 > +
 >  		t = min(IPOIB_NUM_WC, max);

I think this is the only place where max is used now.  Might as well
kill it and put budget-done in directly.  That would get rid of the
strange-looking parens in the "max =" line too.

 >  		n = ib_poll_cq(priv->cq, t, priv->ibwc);
 >  
 > -		for (i = 0; i < n; ++i) {
 > +		for (i = 0; i < n; i++) {

it might be nicer to avoid noise like this in the patch.

 > +	if (done < budget) {
 > +		netif_rx_complete(dev, napi);
 >  		if (unlikely(ib_req_notify_cq(priv->cq,
 >  					      IB_CQ_NEXT_COMP |
 >  					      IB_CQ_REPORT_MISSED_EVENTS)) &&
 > -		    netif_rx_reschedule(dev, 0))
 > -			return 1;
 > -
 > -		return 0;
 > +		    netif_rx_reschedule(napi))
 > +			goto poll_more;

this goto back to the polling loop is a change in behavior.  When we
were tuning NAPI, we found that returning in the missed event case and
letting the NAPI core call the poll routine later actually performed
better, because it allowed more work to pile up.

So could the code just look like:

		netif_rx_complete(dev, napi);
 		if (unlikely(ib_req_notify_cq(priv->cq,
 					      IB_CQ_NEXT_COMP |
 					      IB_CQ_REPORT_MISSED_EVENTS)))
			netif_rx_reschedule(napi);

and then just return done in all cases?

It doesn't seem like the return value of netif_rx_reschedule() matters
in what we would want to do.  The only thing it's used for in the old
code is to decide what the poll routine should return.

 - R.
