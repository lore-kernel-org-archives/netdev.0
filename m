From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 3/3] net: mvneta: Introduce a software TSO implementation
Date: Wed, 7 May 2014 08:04:25 +0200
Message-ID: <20140507060425.GE8325@1wt.eu>
References: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com> <1397170682-19138-4-git-send-email-ezequiel.garcia@free-electrons.com> <20140505144702.GB12693@arch.cereza>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, cmetcalf@tilera.com,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Simon Guinot <sguinot@lacie.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:33858 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750946AbaEGGFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 02:05:01 -0400
Content-Disposition: inline
In-Reply-To: <20140505144702.GB12693@arch.cereza>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ezequiel,

On Mon, May 05, 2014 at 11:47:02AM -0300, Ezequiel Garcia wrote:
> Hi all,
> 
> On 10 Apr 07:58 PM, Ezequiel Garcia wrote:
> [..]
> > +
> > +	/* Calculate expected number of TX descriptors */
> > +	desc_count = skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_frags;
> > +	if ((txq->count + desc_count) >= txq->size)
> > +		return 0;
> > +
> 
> Is this calculus correct? Does it give the accurate number of needed
> descriptors or is it an approximation?
> 
> Tilera's tilegx driver does a much stricter descriptor count (see
> tso_count_edescs). This functions loops through the skb_frag_t fragments
> as it's done later in the data egress, hence strictly counting the
> needed descriptors.
> 
> However, as it's a much heavier routine than the one shown above,
> I'm wondering if we can get away without it.
> 
> Willy, Any ideas here?

I think we don't absolutely need to have the exact value, provided we
don't fall into the case where we cannot send a single skb with an
empty queue. Here we have 532 tx descriptors max, which means that
with an MSS below 246 bytes, we may fall into this situation.

Eric pointed out commit 7e6d06f0de3f7 which applies a limit on the
number of segments for the sfc driver, I think you should take a look
at it. I haven't played with gso_max_segs yet, but there are clear
explanations in the commit message and in the comments that can serve
as a nice starting point.

Hoping this helps :-/

Willy
