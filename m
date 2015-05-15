From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next 0/3] tc state machinery cleanups
Date: Fri, 15 May 2015 13:59:59 +0200
Message-ID: <20150515115959.GG6179@breakpoint.cc>
References: <1431679850-31896-1-git-send-email-fw@strlen.de>
 <5555DA48.6010208@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48444 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934130AbbEOMAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 08:00:02 -0400
Content-Disposition: inline
In-Reply-To: <5555DA48.6010208@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 05/15/15 04:50, Florian Westphal wrote:
> >This series prepares removal of tc_verd member from sk_buff.
> >
> >It simplifies tc state machinery to what is required to keep current
> >mirred/ifb combinations working.
> >
> >I tested a few scenarios, namely:
> >
> >1 - htb based shaping on egress
> >2 - netem attached to ifb with mirred redirect from ingress qdisc
> >3 - mirred to different egress device
> >4 - mirred to ifb egress device with qdiscs set up on ifb
> >     to provide illusion of 'single' transmit interface for traffic shaping
> >
> >After this series tc_verd is only used by ifb to skip actions on egress.
> >
> >Part #2 of this series will remove tc_verd completely.
> 
> The major goal here is to release some of the bits that are
> no longer in use. I am for that but struggling with the unintended
> consequence of changing readability or subtle meanings.
> I brought this up last time when you removed the 1-bit macro.
> Think of someone who read the code 6  months ago.
> It would be useful to keep readability for the rest of the code the
> way it was - change the definition of the macros.
> This sounds doable because 8 contigous bits are going to be available.

Yes, its doable.  But I specifically wanted to have one "skb state", i.e.
no combinations of bit indicators.

> Therefore, I suggest the initial effort should be to find ways to
> co-locate the bits and save the 8  bits and unless necessary keep
> the code readability.

I could add that as an intermediate step, but see no real gain.

> More on readability and subtle meanings:
> A noun like "skb_tc_state" is not a good choice. Those two bits
> carry location indicators and are intended to define source
> and destination endpoints.

Not anymore.  Its really a processing state, overlaps are not possible.
If its FROM_INGRESS then it means mirred wants ifb to return it to
ingress.

If its FROM_EGRESS then it means mirred wants ifb to transmit it to
device the mirred action was attached to.

If its AT_INGRESS, then it means skb is being processed during rx
processing (sch_ingress), so mirred needs to push back l2 header.

If its 0, its normal egress path.
No other states are possible.

I named it tc_state initially but that is "git grep" unfriendly, hence
skb_ prefix.

I'm open to a better name instead of skb_tc_state.

> Also note: ifb and mirred are using the location metadata
> bits - they are _not_ the owners of those bits or the only
> potential users.

Hmm, afaics they are the only users.

> Any of the blocks can consume or produce the metadatum
> in order to aid policy traversal. You can use those two as examples
> of existing blocks that do so - but annotating the code as such is
> inaccurate.

It documents what they're being used for.
And there haven't been any other users so far.

I'll have a stab at keeping all of the macros intact, but I don't
see (yet?) what the gain is.
