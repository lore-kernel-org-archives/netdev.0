From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast
 groups
Date: Fri, 15 Jul 2011 18:03:57 +0200
Message-ID: <20110715160357.GC1407585@jupiter.n2.diac24.net>
References: <BANLkTi=jnxBu6WzAOTxHD+e_O1qYKE2m=g@mail.gmail.com>
 <CAEJpZP1cr4B9qX6gH9O4iXwWvEdxs2aebL21FnX1BE0dJPHrEw@mail.gmail.com>
 <20110711082755.0b38a15a@nehalam.ftrdhcpuser.net>
 <20110712113643.GC616804@jupiter.n2.diac24.net>
 <CAEJpZP1Da=G3--jThbaj5H4+H+836quXXEfGXtBwdPewr-Pjrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	davem@davemloft.net
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:57891 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753018Ab1GOQEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 12:04:09 -0400
Content-Disposition: inline
In-Reply-To: <CAEJpZP1Da=G3--jThbaj5H4+H+836quXXEfGXtBwdPewr-Pjrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2011 at 04:44:50PM +0100, Nick Carter wrote:
> On 12 July 2011 12:36, David Lamparter <equinox@diac24.net> wrote:
> > On Mon, Jul 11, 2011 at 08:27:55AM -0700, Stephen Hemminger wrote:
> >> I am still undecided on this. Understand the need, but don't like idea
> >> of bridge behaving in non-conforming manner. Will see if IEEE 802 committee
> >> has any input.
> >
> > The patch doesn't make the bridge behave nonconformant. The default mask
> > is 0, which just keeps the old behaviour.
>
> Also as David points out in his review, after these diffs are applied
> we will be able to remove this
> @@ -166,6 +166,9 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb)
>                if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
>                        goto forward;
> Which is non-standard.

Actually, no, we might not be able to remove this (sorry for stating the
opposite earlier). If we remove this, we can cause loops if we are a
STP-disabled bridge on a STP-enabled ethernet. We would form a STP
blackhole, causing more than one switch to assume responsibility for
forwarding packets to our segment...

While we could shift the burden for making a correct configuration onto
the admin or the userspace tools (by setting the mask to 1 on a no-STP
bridge), this would be a major change from previous behaviour and
(more or less) count as regression.

Either way I would consider removing that line a rather dangerous
change. We didn't remove that line, let's stick with it and everything
will stay as it used to be :)

> So these diffs enable us to change the existing non-conforming
> behaviour to a conforming one.
>
> > If you set the lowest 3 bits, yes, you can break your network.

Btw, a kernel warning for this would be useful i think, at least once.
"You should only enable the lowest 3 bits for sniffing bridges." or so.


-David

