From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/1] net: hold sock reference while processing tx
 timestamps
Date: Thu, 13 Oct 2011 06:51:41 +0200
Message-ID: <20111013045141.GA1943@netboy.at.omicron.at>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
 <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
 <1318447673.3933.47.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51261 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062Ab1JMEvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 00:51:41 -0400
Received: by eye27 with SMTP id 27so1440748eye.19
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2011 21:51:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1318447673.3933.47.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2011 at 09:27:53PM +0200, Johannes Berg wrote:
> On Wed, 2011-10-12 at 20:36 +0200, Richard Cochran wrote:
> > The pair of functions,
> > 
> >  * skb_clone_tx_timestamp()
> >  * skb_complete_tx_timestamp()
...
> 
> This still needs a fix to the PHY driver right? It has a case that can
> kfree_skb() the skb instead of passing it back to
> complete_tx_timestamp().

Yes, right, will do.

> > -	if (!hwtstamps)
> > +	if (!hwtstamps) {
> > +		sock_put(sk);
> > +		kfree_skb(skb);
> >  		return;
> > +	}
> 
> Is that right w/o skb->sk = NULL?

I think it is okay. In clone/complete, we use skb->sk in a special
way, just to remember the socket. Within kfree_skb, only the
skb->destructor would possibly use skb->sk, and that function pointer
is NULL (after the clone in the Tx path).

> FWIW I just decided to do it the other way around in mac80211 -- keep
> the original SKB that's charged to the socket for the error queue, and
> use a clone to actually do the TX.

In this case, we must clone, I think. The Ethernet MAC driver will
call the clone_tx_timetstamp hook just before freeing the original
skb.

Thanks,
Richard
