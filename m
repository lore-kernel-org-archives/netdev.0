From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: tcp: move to timewait when receiving data
 post active-close
Date: Wed, 18 Nov 2015 16:36:21 +0100
Message-ID: <20151118153621.GA5860@breakpoint.cc>
References: <1447859024-1040-1-git-send-email-fw@strlen.de>
 <1447860480.22599.151.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	marcelo.leitner@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46012 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755008AbbKRPgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 10:36:23 -0500
Content-Disposition: inline
In-Reply-To: <1447860480.22599.151.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-11-18 at 16:03 +0100, Florian Westphal wrote:
> > RFC 1122, 4.2.2.13:
> >  [..] if new data is received after CLOSE is called, its TCP
> >  SHOULD send a RST to show that data was lost.
> > 
> >  When a connection is closed actively, it MUST linger in
> >  TIME-WAIT state [..].
> > 
> > We reset a connection, but destroy state immediately.
> > 
> > After discussing this with Hannes, we decided it was preferable
> > to also move to TW state to avoid immediate port reuse.
> > 
> > packetdrill testcase:
> > 
> > 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
> > 0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> > 0.000 bind(3, ..., ...) = 0
> > 0.000 listen(3, 1) = 0
> > 0.100 < S 0:0(0) win 29200 <mss 1460>
> > 0.100 > S. 0:0(0) ack 1 <mss 1460>
> > 0.200 < . 1:1(0) ack 1 win 257
> > 0.200 accept(3, ..., ...) = 4
> > // close our side.
> > 0.210 close(4) = 0
> > // we should expect to see FIN now, sk moves to FIN_WAIT_1
> > 0.210 > F. 1:1(0) ack 1 win 29200
> > // receive data, but sk already closed -> Reset
> > 0.300 < P. 1:1001(1000) ack 1 win 46
> > 0.300 > R 1:1(0) win 0


> This packetdrill test shows nothing special regarding your patch, it
> should work right now with current kernels ???

Yes, but we kill the socket.

I should have added

0.400 `ss -nito state time-wait`

as last line...

Before patch: no output
after patch: tw socket shown.

The on-wire behavior doesn't change unless further packets arrive.
Old behaviour: more RST
New behaviour: acks+tw timer restart

Sorry for the confusion.
