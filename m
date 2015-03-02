From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH RFC 08/14] net: wireless: mac80211: shrink
 ieee80211_tx_info
Date: Mon, 02 Mar 2015 20:18:49 +0100
Message-ID: <1425323929.1906.12.camel@sipsolutions.net>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
	 <1425318028-26531-9-git-send-email-fw@strlen.de>
	 <1425322425.1906.4.camel@sipsolutions.net>
	 <20150302190316.GB9762@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51908 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880AbbCBTS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 14:18:58 -0500
In-Reply-To: <20150302190316.GB9762@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-02 at 20:03 +0100, Florian Westphal wrote:

> Eventually reducing skb size to make it fit into 3 cachelines again even
> on 64bit architectures.  For that 40 bytes need to go.

That seems like a worthy goal I guess (I guess you should've copied a
patch 0/N to us).

> > Mind you - we are actually acutely out of space and would rather have
> > *more*, not less.
> 
> :-(
> 
> I'm not familiar with mac80211, aside from that it seemed to me
> that 40 byte cb would be doable, given enough work.

Right now it is, mostly, yes.

> Where are to main problems, exactly?

Well, that depends. Right now clearly we're not really using all of it
as you saw (even if this patch moving bits here and there is really
ugly) but there are multiple things:
 1) Of course mac80211 isn't static, it keeps getting developed! Right
now for
    example we need to fix single TCP flow throughput over wifi, and for
that we
    need a timestamp. That won't even fit into skb->cb any more right
now; we'll
    probably be able to get away with (ab)using skb->tstamp or doing
reshuffling
    similar to yours to get some space, but that's just lucky this time.
 2) We're actually out of flags that are kept from TX generation to TX
    destruction and it's almost certain that we'll need to add more
things.

Also, we already do a lot of bit twiddling here, doing it even more
makes the code even harder to follow. It's bad enough as is if you ask
me.

> I known that pushing something into ->cb is a lot easier than e.g. keeping
> extra state on stack, but, IMO cb should really only be used when you
> need to associate data strictly with an skb so that this data is still
> availabe even when skb gets queued somewehere.

Right, and we do that. We've in the past moved out data from here to
elsewhere, but it's extremely tedious and error-prone, and I'm not sure
we have much that we can possibly move now, since we do need to hang on
to SKBs in many cases like client powersaving etc.

> Is there a document somewhere that lists all of the per-skb data that
> mac80211 needs to store (or wants to store)?

Not really, sorry.

> +                                       enum mac80211_tx_control_flags flags:2;
> +                                       /* used for BUILD_BUG_ON validation that ->flags won't
> +                                        * overlap with jiffies below */
> +                                       char flags_end[0];

That "jiffies" should probably say "other members (currently jiffies)"
or something ... I got a bit confused here.

johannes
