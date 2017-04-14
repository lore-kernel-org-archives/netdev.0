From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Fri, 14 Apr 2017 12:41:07 -0700
Message-ID: <20170414194105.GA51147@ast-mbp.thefacebook.com>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
 <20170413042036.GA46229@ast-mbp.thefacebook.com>
 <1492063856.19193.4.camel@sipsolutions.net>
 <20170413.113810.703136630867928001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36566 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752122AbdDNTlM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 15:41:12 -0400
Content-Disposition: inline
In-Reply-To: <20170413.113810.703136630867928001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 11:38:10AM -0400, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Thu, 13 Apr 2017 08:10:56 +0200
> 
> > On Wed, 2017-04-12 at 21:20 -0700, Alexei Starovoitov wrote:
> > 
> >> > +	if (skb_linearize(skb))
> >> > +		goto do_drop;
> >> 
> >> when we discussed supporting jumbo frames in XDP, the idea
> >> was that the program would need to look at first 3+k bytes only
> >> and the rest of the packet will be in non-contiguous pages.
> >> If we do that, it means that XDP program would have to assume
> >> that the packet is more than [data, data_end] and this range
> >> only covers linear part.
> >> If that's the future, we don't need to linearize the skb here
> >> and can let the program access headlen only.
> > 
> > I'm not sure how you think that would work - at least with our (wifi)
> > driver, the headlen should be maybe ETH_HLEN or so at this point. We'd
> > let the program know that it can only look at so much, but then the
> > program can't do anything at all with those frames. At some point then
> > we go back to bpf_skb_load_bytes() being necessary in one form or
> > another, no?
> 
> Agreed, this is completely unusable.  Some wired ethernet drivers do the
> same exact thing.

ahh. i thought all drivers do at least copy-break (256) bytes or copy
get_headlen or build_skb the whole thing.
Since wireless does eth_hlen, then yeah, skb_linearize() is the only way.
I guess any driver that would care about XDP performance would either
implement in-driver XDP or make sure that skb_linearize() doesn't
happen in generic XDP by doing build_skb() with the whole packet.
The driver can be smart and avoid doing copy-break if generic XDP is on.
