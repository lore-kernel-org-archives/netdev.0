From: Phil Sutter <phil@nwl.cc>
Subject: Re: linux-next: Tree for Aug 6 [ wireless | iwlwifi | mac80211 ? ]
Date: Thu, 8 Aug 2013 23:13:58 +0200
Message-ID: <20130808211404.467E620819@mail.nwl.cc>
References: <CA+icZUXpZaHu-FjR6FGnbkG0XEkiukEgYYbDmrSjdqNz4rWCNg@mail.gmail.com>
 <1375816128.8219.28.camel@jlt4.sipsolutions.net>
 <CA+icZUXaTYVc_iv3hny6Je9mVdX8KCVpFSNBeukS+Fh-347Wvw@mail.gmail.com>
 <1375816715.8219.29.camel@jlt4.sipsolutions.net>
 <CA+icZUXdAjEDgu2XrA4Dg2hsLDJYdFTCpJwiW6=ZUgULe2noyw@mail.gmail.com>
 <CA+icZUVmokQ1fKmtbuPyp7f5Z2wdFYfjG5HCAm4Kue7efyKV8w@mail.gmail.com>
 <20130806213006.078C72210F@mail.nwl.cc>
 <CA+icZUVk1HM-VVYcARvY7p5KBYz0YcY9+rW8s-nKPTeVYh4tgw@mail.gmail.com>
 <1375825538.10459.1.camel@jlt4.sipsolutions.net>
 <1375826322.10459.6.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sedat.dilek@gmail.com, David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	wireless <linux-wireless@vger.kernel.org>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:44889 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966555Ab3HHVOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 17:14:31 -0400
Content-Disposition: inline
In-Reply-To: <1375826322.10459.6.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 11:58:42PM +0200, Johannes Berg wrote:
> On Tue, 2013-08-06 at 23:45 +0200, Johannes Berg wrote:
> 
> > I think skb->protocol is probably getting set up wrong, and just putting
> > back the last two lines
> > 
> >         skb->protocol = proto;
> >         skb->dev = dev;
> > 
> > is probably sufficient to fix wifi. If skb->protocol isn't set to
> > ETH_P_PAE, then we'd drop the packet in the wifi stack - might be worth
> > printing out what it's set to at the point where the skb->protocol
> > assignment above was removed.
> > 
> > I'm trying to wrap my head around all this right now but I don't yet see
> > how the code after the patch would not get skb->protocol correct.
> 
> Actually, I think that's not it, but the code now behaves totally
> differently?
> 
> Say this is the frame data with two points marked:
> 
> (1)                   (2)
>  | dst | src | ethtype | ... |
> 
> As I understand it (in my admittedly rather tired state), previously we
> had
> 
> skb_network_header() == (1)
> skb_mac_header()     == (1)
> skb->data            == (1)
> 
> After calling eth_type_trans(), we get
> 
> skb_network_header() == (1)
> skb_mac_header()     == (1)
> skb->data            == (2)
> 
> I think? Maybe I'm totally confused though.

Yes, indeed. And it's the explanation for at least some of the problems
that arose with my doubtful change:

Leaving my patch in place and reverting the above pointer by calling
skb_push() after eth_type_trans(), the busybox DHCP client on my testing
machine is functional again.

But as Dave has gone this path already (although in a different way) and
it aparently didn't fix the wifi problem, there may be something else as
well. Interestingly, my skb_push() hack from above fixes wpa_supplicant
for me as well. So I will test Dave's patch myself tomorrow and search
for the difference if I get the same result as Sedat.

Best wishes, Phil
