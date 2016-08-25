From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC 1/3] tcp: randomize tcp timestamp offsets for each
 connection
Date: Thu, 25 Aug 2016 11:06:02 +0200
Message-ID: <20160825090602.GA30509@breakpoint.cc>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
 <1471524527-10029-2-git-send-email-fw@strlen.de>
 <1471537092.29842.62.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:49152 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933159AbcHYJGE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 05:06:04 -0400
Content-Disposition: inline
In-Reply-To: <1471537092.29842.62.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-08-18 at 14:48 +0200, Florian Westphal wrote:
> > commit ceaa1fef65a7c2e ("tcp: adding a per-socket timestamp offset")
> > added the main infrastructure that is needed for per-connection
> > randomization, in particular writing/reading the on-wire tcp header
> > format takes the offset into account so rest of stack can use normal
> > tcp_time_stamp (jiffies).
> > 
> > So only two items are left:
> >  - add a tsoffset for request sockets
> >  - extend the tcp isn generator to also return another 32bit number
> >  in addition to the ISN.
> > 
> > Re-use of ISN generator also means timestamps are still monotonically
> > increasing for same connection quadruple.
> 
> I like the idea, but the implementation looks a bit complex.
> 
> Instead of initializing tsoffset to 0, we could simply use
> 
> jhash(src_addr, dst_addr, boot_time_rnd)
> 
> This way, even syncookies would be handled, and we do not need to
> increase tcp_request_sock size.

So I gave this a try and it does avoid this tcp_request_sock increase,
but I feel that getting boot_time_rnd is too easy.

I tried a few other ideas but nothing satisfying/simpler came out of it
(e.g. i tried to also hash the isn but that gets scaled w. current
 clock so it doesn't work).

Are you more concerned wrt. complexity or the reqsk increase?

One could use tfo boolean padding in the struct to avoid size increase
(1 bit tfo_listener, 31 for tsoff).

I would then split this patch in two (one to add tsoff to reqsk, one
to add the randomization).

The only other alternative I see is to eat 2nd md5_transform and
add a tso_offset function to secure_seq.c -- but I don't like that
either.

Any other idea?
