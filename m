From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 1/2] tcp: remove per-destination timestamp cache
Date: Thu, 16 Mar 2017 17:05:44 +0100
Message-ID: <20170316160544.GD15641@1wt.eu>
References: <20170315203046.158791-1-soheil.kdev@gmail.com>
 <20170315.154044.170788541865531834.davem@davemloft.net>
 <20170315225508.GB14761@1wt.eu>
 <58CA778D.9020208@5t9.de>
 <CADVnQy=Bxs-e-KxQsA8nPSfm9fVtogouxCRdgmrR0WyBkMS=Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lutz Vieweg <lvml@5t9.de>, David Miller <davem@davemloft.net>,
        Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Florian Westphal <fw@strlen.de>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:33416 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752636AbdCPQGs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Mar 2017 12:06:48 -0400
Content-Disposition: inline
In-Reply-To: <CADVnQy=Bxs-e-KxQsA8nPSfm9fVtogouxCRdgmrR0WyBkMS=Xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neal,

On Thu, Mar 16, 2017 at 11:40:52AM -0400, Neal Cardwell wrote:
> On Thu, Mar 16, 2017 at 7:31 AM, Lutz Vieweg <lvml@5t9.de> wrote:
> >
> > On 03/15/2017 11:55 PM, Willy Tarreau wrote:
> >>
> >> At least I can say I've seen many people enable it without understanding its impact, confusing it
> >> with tcp_tw_reuse, and copy-pasting it from random blogs and complaining about issues in
> >> production.
> >
> >
> > I currently wonder: What it the correct advise to an operator who needs
> > to run one server instance that is meant to accept thousands of new,
> > short-lived TCP connections per minute?
> 
> Note that for this to be a problem there would have to be thousands of
> new, short-lived TCP connections per minute from a single source IP
> address to a single destination IP address. Normal client software
> should not be doing this. AFAIK this is pretty rare, unless someone is
> running a load test or has an overly-aggressive monitoring system. NAT
> boxes or proxies with that kind of traffic should be running with
> multiple public source IPs.

In fact it's the regular stuff with reverse-proxies. You can scan the
whole source port range every second. But when enabling timestamps, you
benefit from PAWS and you don't have any problem anymore, everything
works pretty well.

> But if/when the problem occurs, then the feasible solutions I'm aware
> of, in approximate descending order of preference, are:
> 
> (1) use longer connections from the client side (browsers and RPC libraries are
>     usually pretty good about keeping connections open for a long time, so this
>     is usually sufficient)
> 
> (2) have the client do the close(), so the client is the side to carry the
>     TIME_WAIT state

That's impossible for proxies, as you can't connect again from the same
source port, causing the performances to be divided by more than 100. What
proxies have to do when they're forced to close first an outgoing connection
is to set SO_LINGER to (0,0) so that an RST is used and the source port can
be reused. But as you guess, if that RST gets lost, then next opening is
not that beautiful : either [SYN, ACK, RST, pause, SYN, SYN-ACK, ACK] or
[SYN, RST, pause SYN, SYN-ACK, ACK] depending on whether the SYN appears
in the previous window or not.

> (3) have the server use SO_LINGER with a timeout of 0, so that
>     the connection is closed with a RST and the server carries no
>     TIME_WAIT state

The problem is that it also kills the tail data.

Quite frankly, the only issues I'm used to see are with clients closing
first and with reusing source connections. As soon as timestamps are
enabled on both sides and people don't blindly play with tcp_tw_recycle,
I really never face any connection issue.

Willy
