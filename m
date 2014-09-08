From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next v2 2/2] Re-check for a VIO_DESC_READY data
 descriptor after short udelay()
Date: Mon, 8 Sep 2014 10:03:24 -0400
Message-ID: <20140908140324.GE31377@oracle.com>
References: <20140902162029.GC31516@oracle.com>
 <5405EFE7.4090302@oracle.com>
 <20140904.223648.559995846094457545.davem@davemloft.net>
 <20140905134758.GB1256@oracle.com>
 <20140906210253.GA5710@oracle.com>
 <540DB314.3090809@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	raghuram.kothakota@oracle.com
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27336 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbaIHODc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 10:03:32 -0400
Content-Disposition: inline
In-Reply-To: <540DB314.3090809@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/08/14 09:45), David L Stevens wrote:

First off, please don't drop email ids from the original email. 
I've re-added Raghuram Kothakota to fix that initial omission.

Second, this thread originally came up with your suggestion that
we shold move the wmb() down one line. I looked at this, and consulted
a few folks, all of whom agree that that is probably incorrect. 

As Bob Picco pointed out to me:
" Placing the wmb() after probably won't have any negative consequences
  BUT could. Suppose the compiler reorders the stores and the d->hdr.state
  store occurs before another part of the descriptor. We HV trap,
  and the trap doesn't flush the store buffer. The consumer could then
  see VIO_DESC_READY before the cookies arrray is updated. It would depend
  on how many cache lines are spanned by vio_net_desc and the store buffer
  organization."
thus I would be cautious about doing that.

> I'm no mb expert, and I know of no symptoms, but it appears to be saying that
> load reordering could result in a race where the READY flag could be set with
> old data in other descriptor fields due to loading them in a different order --
> something it says wmb() on another CPU explicitly does not prevent.

Please see the explanation that I, and Raghuram offered.
The wmb() assures that the stores of the cookie state are
ordered correctly by the consumer. The next store is for VIO_DESC_READY
and the consumer will not proceed to read cookie state until this
is visible. Thus no rmb() is needed. 

On its side, the consumer resets the hdr.state to DONE after it
consumes the cookies, and the DRING_STOPPLED announcement further
informs the producer that the descriptor is available. 

Hope that helps. If you think there is some sequence where this
is insufficient, please explain with details.

>
> The particular case would be adding to the ring at the same time the
> other side
> is removing from the ring, so no locks or LDC traffic would affect it.
> 
> So, it appears to me we have a missing rmb() that is needed and I
> don't know what
> leads you to believe it isn't.
> 
> 							+-DLS
