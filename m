From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH] Fix sorting of SACK blocks
Date: Thu, 25 Jan 2007 21:08:28 +0200
Message-ID: <20070125190828.GC22455@galon.ev-en.org>
References: <20070125182903.GA22455@galon.ev-en.org> <20070125103610.4cf616a6@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@osdl.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:40377
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030493AbXAYTIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 14:08:32 -0500
Content-Disposition: inline
In-Reply-To: <20070125103610.4cf616a6@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Stephen Hemminger <shemminger@linux-foundation.org> [070125 20:47]:
> On Thu, 25 Jan 2007 20:29:03 +0200
> Baruch Even <baruch@ev-en.org> wrote:
> 
> > The sorting of SACK blocks actually munges them rather than sort, causing the
> > TCP stack to ignore some SACK information and breaking the assumption of
> > ordered SACK blocks after sorting.
> > 
> > The sort takes the data from a second buffer which isn't moved causing
> > subsequent data moves to occur from the wrong location. The fix is to
> > use a temporary buffer as a normal sort does.
> > 
> > Signed-Off-By: Baruch Even <baruch@ev-en.org>
> > 
> > diff -X 2.6-rc6/Documentation/dontdiff -ur 2.6-rc6/net/ipv4/tcp_input.c 2.6-mod/net/ipv4/tcp_input.c
> > --- 2.6-rc6/net/ipv4/tcp_input.c	2007-01-25 19:04:20.000000000 +0200
> > +++ 2.6-mod/net/ipv4/tcp_input.c	2007-01-25 19:52:04.000000000 +0200
> > @@ -1011,10 +1011,11 @@
> >  			for (j = 0; j < i; j++){
> >  				if (after(ntohl(sp[j].start_seq),
> >  					  ntohl(sp[j+1].start_seq))){
> > -					sp[j].start_seq = htonl(tp->recv_sack_cache[j+1].start_seq);
> > -					sp[j].end_seq = htonl(tp->recv_sack_cache[j+1].end_seq);
> > -					sp[j+1].start_seq = htonl(tp->recv_sack_cache[j].start_seq);
> > -					sp[j+1].end_seq = htonl(tp->recv_sack_cache[j].end_seq);
> > +					struct tcp_sack_block_wire tmp;
> > +
> > +					tmp = sp[j];
> > +					sp[j] = sp[j+1];
> > +					sp[j+1] = tmp;
> >  				}
> >  
> >  			}
> 
> This looks okay, but is there a test case that can be run?

There is nothing visible that shows the problem, the only option is to
add some code to print the SACK blocks after sorting and run it over a
large BDP connection that can be saturated. You'll obviously need to
have several holes, I believe that the bug will be visible when you have
ACK packets with three SACK blocks where the first block is the highest
which should be the normal case.

Cheers,
Baruch
