From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC 1/3] tcp: randomize tcp timestamp offsets for each
 connection
Date: Fri, 19 Aug 2016 00:32:19 +0200
Message-ID: <20160818223219.GB3789@breakpoint.cc>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
 <1471524527-10029-2-git-send-email-fw@strlen.de>
 <1471537092.29842.62.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:54286 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753237AbcHSCLm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 22:11:42 -0400
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

True, however I think it would be fairly easy to discover
boot_time_rnd given a few outputs, as jhash is not cryptograhic hash, no?

If thats not a concern I can just use jhash (not taking ports
into account doesn't seem to be a problem).

Alternatively (if tcp_request_sock increase/complexity is a problem)
I could either call the isn generator again, or add an extra function
for it (again using md5), I did not do this because I was afraid
it would be too expensive to do two md5 calculations.

Thanks for reviewing!

For cookies I had planned to just extend the cookie sha1 similar
to isn generator here, alternatives welcome.
