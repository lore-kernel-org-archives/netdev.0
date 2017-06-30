From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH RFC 0/2] kproxy: Kernel Proxy
Date: Fri, 30 Jun 2017 06:30:25 +0200
Message-ID: <20170630043025.GA10841@1wt.eu>
References: <1498760825-8516-1-git-send-email-tom@herbertland.com>
 <20170629195402.GA10048@1wt.eu>
 <CALx6S369XPs_6Ap9H8yZCW+XL1pAbJx9XhNdpZ36hpQCEvs-3w@mail.gmail.com>
 <20170629205806.GA10285@1wt.eu>
 <CALx6S36rQAe=yWAd_K4fnNGNgZ-gQbQ6K_p8RDmN+5CsKGogsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:53822 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751746AbdF3Eac (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 00:30:32 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S36rQAe=yWAd_K4fnNGNgZ-gQbQ6K_p8RDmN+5CsKGogsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 04:43:28PM -0700, Tom Herbert wrote:
> On Thu, Jun 29, 2017 at 1:58 PM, Willy Tarreau <w@1wt.eu> wrote:
> > On Thu, Jun 29, 2017 at 01:40:26PM -0700, Tom Herbert wrote:
> >> > In fact that's not much what I observe in field. In practice, large
> >> > data streams are cheaply relayed using splice(), I could achieve
> >> > 60 Gbps of HTTP forwarding via HAProxy on a 4-core xeon 2 years ago.
> >> > And when you use SSL, the cost of the copy to/from kernel is small
> >> > compared to all the crypto operations surrounding this.
> >> >
> >> Right, getting rid of the extra crypto operations and so called "SSL
> >> inspection" is the ultimate goal this is going towards.
> >
> > Yep but in order to take decisions at L7 you need to decapsulate SSL.
> >
> Decapsulate or decrypt? There's a big difference... :-) I'm am aiming
> to just have to decapsulate.

Sorry, but what difference do you make ? For me "decapsulate" means
"extract the next level layer", and for SSL it means you need to decrypt.

> >
> >> Performance is relevant because we
> >> potentially want security applied to every message in every
> >> communication in a containerized data center. Putting the userspace
> >> hop in the datapath of every packet is know to be problematic, not
> >> just for the performance hit  also because it increases the attack
> >> surface on users' privacy.
> >
> > While I totally agree on the performance hit when inspecting each packet,
> > I fail to see the relation with users' privacy. In fact under some
> > circumstances it can even be the opposite. For example, using something
> > like kTLS for a TCP/HTTP proxy can result in cleartext being observable
> > in strace while it's not visible when TLS is terminated in userland because
> > all you see are openssl's read()/write() operations. Maybe you have specific
> > attacks in mind ?
> >
> No, just the normal problem of making yet one more tool systematically
> have access to user data.

OK.

> >> > Regarding kernel-side protocol parsing, there's an unfortunate trend
> >> > at moving more and more protocols to userland due to these protocols
> >> > evolving very quickly. At least you'll want to find a way to provide
> >> > these parsers from userspace, which will inevitably come with its set
> >> > of problems or limitations :-/
> >> >
> >> That's why everything is going BPF now ;-)
> >
> > Yes, I knew you were going to suggest this :-)  I'm still prudent on it
> > to be honnest. I don't think it would be that easy to implement an HPACK
> > encoder/decoder using BPF. And even regarding just plain HTTP parsing,
> > certain very small operations in haproxy's parser can quickly result in
> > a 10% performance degradation when improperly optimized (ie: changing a
> > "likely", altering branch prediction, or cache walk patterns when using
> > arrays to evaluate character classes faster). But for general usage I
> > indeed think it should be OK.
> >
> HTTP might qualify as a special case, and I believe there's already
> been some work to put http in kernel by Alexander Krizhanovsky and
> others. In this case maybe http parse could be front end before BPF.

It could indeed be an option. We've seen this with Tux in the past.

> Although, pretty clear we'll need regex in BPF if we want use it with
> http.

I think so as well. And some loop-like operations (foreach or stuff like
this so that they remain bounded).

Willy
