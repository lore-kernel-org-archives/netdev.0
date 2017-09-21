From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 00/14] gtp: Additional feature support
Date: Thu, 21 Sep 2017 23:38:39 +0800
Message-ID: <20170921153839.qe37gyv727c6xgdi@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919124352.l4k67ygb6xt4eloq@nataraja>
 <CALx6S35n-V3d00SyV=Lz97KPq=CSCmOaerXpFBYSknKtdiwYug@mail.gmail.com>
 <20170919231947.bt4am3els3p26l6p@nataraja>
 <CAPDqMep60z-7QhAQAyBk_mZbqHgV8=tkn=v6BxRwK0hqMX4+tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit Seth <rohit@quantonium.net>
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:39186 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751678AbdIUPjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 11:39:01 -0400
Content-Disposition: inline
In-Reply-To: <CAPDqMep60z-7QhAQAyBk_mZbqHgV8=tkn=v6BxRwK0hqMX4+tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Tue, Sep 19, 2017 at 04:47:11PM -0700, Tom Herbert wrote:
> On Tue, Sep 19, 2017 at 4:19 PM, Harald Welte <laforge@gnumonks.org> wrote:
>
> > I think there has to be a clear plan/architecture on how to implement
> > those bits in terms of the kernel/userspace split, and at least a proof
> > of concept implementation that we can show works with some real phones
> > out there - otherwise there's no point in having IPv6 support that works
> > well with some custom tools.
> >
> OTOH, I will argue that the GTP patches should never have been allowed
> in the kernel in the first place without IPv6 support! ;-) 

Well, it could be shown that the code works with integration to OpenGGSN
(and later ergw, and now OsmoGGSN) and works within a complete 3GPP
network.  So we were not merging something that we hypothesized it would
work once the rest would be implemented, but we could actually show it
was working before it got merged.

> I think the best plan forward is to get the IPv6 data path running
> that so can demonstrate a functional GTP/IPv6 datapath 

Yes, but a functional "datapath" (= GTP-U) unfortunately includes the
way how address allocation/assignment is done.  Putting something into
the mainline kernel that we know will for sure not work/interop in a
real scenario is not a good idea.  I think what's worse than not
supporting a feature is to implying support for it while actually
doing it in an incomplete/incompliant way.

So from my point of view, what's needed is
* making sure router advertisement/solicitation are covered in some
  way, either by doing it in the kernel or having a clear strategy how
  it could be done from userspace while not a) introducing races regarding
  who owns the sequence numbers
* making sure the implementation covers entire /64 prefixes for each
  PDP context and not single addresses.  That is non-negotiable and
  mandatory by 3GPP specs.

> Since "real" configuration path doesn't use the path to set up a
> standalone interface, I would presume that that will be fleshed when
> someone has cycles and expertise to work on both sides of the problem.

The configuration will be different, yes. but we need to ensure that the
actual *implementation* of the data path does what it is expected to do,
no matter who configures it via which interface.

> Even if this requires structural changes to how IPv6 is managed in
> GTP, I doubt that the fundamental TX/RX, GRO/GSO data paths will
> change much.  In other words, please consider this to be a step on an
> evolutionary path. More work is required to reach the ultimate
> deployable solution.

Agreed. But then I'm still against merging something that we know for
sure will not be compatible with real-world use case.  It should be kept
out of mainline until we are sure of that, at the very least
theoretically, but even better which we can prove in practise will do
what it claims to do.

> As for testing on real phones, that is cannot be a requirement for a
> kernel feature. 

GTP is not implemented on phones.  GTP is implemented only inside the
fixed (land-side) of the cellular network.  However, the inner IP data
originates from phones, and large parts of what you see on GTP
originates from phones in a different format.  The inner IP data inside
GTP-U originates from phones.  And that's where address configuration
for IPv6 works.

> If you expect Linux community to support this, then we
> need a way to be develop and test on commodity PC hardware. 

I'm not arguing you need to run any of the code on a different
architecture such as a phone.  I'm arguing for you to run a cellular
network including the kernel GTP code, and then use that cellular
network from a real phone.  This is the only way to know for sure you
interoperate.  See my other mail related to the Open Soruce based
configurations for both 2G and 3G that can be used for this.

As a replacement, one can e.g. look at protocol traces of real phones
and then simulate the behavior of one or several different phones and
implement that as test caess.  This is what I did in the GGSN_Test
pointed out in my other mail in this thread.  And btw, all I've asked is
for showing it works with *one* phone model at all.  I'm not talking
about the various different implementation specifics, such as whether or
not the phone will insist on using neighbor solicitation and mandate
neighbor advertisement (on a point-to-point link, how absurd!) after
the (mandatory) router discovery.

> That is one of the major values of creating a standalone interface
> configuration-- we can test the datapath just like any other
> encapsulation supported by the kernel.

Well, you cannot.  You might be able to do some benchmarking to compare
if an old version of the kernel gtp driver will perform better or worse
than some optimizations introduced.  But you can *not* have a realistic
functional test that will tell you if your implementation is 'valid'.
I'm not even talking about being 'complete' here, but simply about being
broken or not.  Or test whether it will interoperate.  Particularly for
IPv6 this is impossible, due to the conflated way of involving both
GTP-C and GTP-U with router advertisement+solicitation for PDP context
activation, as outlined several times in this thread.

I wish it was simpler, but I haven't created GTP, sorry :)

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
