From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Fri, 07 Oct 2011 19:40:22 +0200
Message-ID: <1318009222.3988.28.camel@jlt3.sipsolutions.net>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
	 <20111007.133356.489094996618032061.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:43605 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753716Ab1JGRk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 13:40:26 -0400
In-Reply-To: <20111007.133356.489094996618032061.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-10-07 at 13:33 -0400, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Fri, 07 Oct 2011 19:11:41 +0200
> 
> > From: Johannes Berg <johannes.berg@intel.com>
> > 
> > skb->sk is obviously required to be non-NULL
> > when we get into skb_complete_tx_timestamp().
> > sock_queue_err_skb() will call skb_orphan()
> > first thing which sets skb->sk = NULL itself.
> > This may crash if the skb is still charged to
> > the socket (skb->destructor is sk_wfree).
> > 
> > The assignment here thus seems to not only be
> > pointless (due to the skb_orphan() call) but
> > also dangerous (due to the crash).
> > 
> > Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> 
> It looks like skb_clone_tx_timestamp() sets clone->sk without any
> proper refcounting, so I bet this NULL'ing it out is working
> around that bug.

You're right. But this bug can actually trigger another way: The only
user of this is dp83640_txtstamp() which might do kfree_skb() on this
skb, in which case that'll likely crash trying to clean up the sk.

johannes
