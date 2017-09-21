From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH net-next 09/14] gtp: Allow configuring GTP interface as
 standalone
Date: Thu, 21 Sep 2017 23:12:53 +0800
Message-ID: <20170921151253.4udm54dcq7x3ed4q@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-10-tom@quantonium.net>
 <a6d1dad0-e922-2913-d4c8-592d403ee1cb@tpip.net>
 <CALx6S3771X4QUm2mJG=aJJ0f4Tm98NpGA7060vF1P8iuCPgicQ@mail.gmail.com>
 <56e339a8-fa2d-6f8d-a89c-c0f3f242763a@tpip.net>
 <CAPDqMeq1tLi=NkLyqma2OEHQi-fYEYeTU-8th9WKoZaeWiM0Rw@mail.gmail.com>
 <20170921001313.n2uo56oxmphcvd5g@nataraja>
 <CAPDqMeox74aEdV5_cr7HJ=kh0-etLdFE-u5=g8OqRzmS8OjOuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Schultz <aschultz@tpip.net>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit Seth <rohit@quantonium.net>
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:39191 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751726AbdIUPjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 11:39:01 -0400
Content-Disposition: inline
In-Reply-To: <CAPDqMeox74aEdV5_cr7HJ=kh0-etLdFE-u5=g8OqRzmS8OjOuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Wed, Sep 20, 2017 at 05:55:01PM -0700, Tom Herbert wrote:
> You have the point of view of someone who has a lot of experience
> dealing with this protocol. Try to imagine if you were some random
> kernel network programmer with no experience in the area. If they
> happen to find a one-off bug and want to do the right thing by running
> a test, you want to make that as easy as possible. 

Agreed.  But we're not talking abut fixing a random bug in your patch
series, but we're talking about adding significant new features - and
those features need to be tested in real use caes, not just in an
artificial test setup that holds assumptions that are not true.

To improve performance, or to fix simple bugs that only affect the
processing of the GTP-U G-PDU, a much more limited and hence
"unrealistic" test scenario is probably sufficient/acceptable.

> From that perspective, building protocol specific libraries and
> finding the right cmd line to run is significant hoops (I can attest
> to this).

I understand your argument.  But then, there is actually quite some
tools to help you (see further below), as well as the wiki page at
http://osmocom.org/projects/linux-kernel-gtp-u/wiki/Basic_Testing

Of course, existing tools and existing wiki pages also only document
existing features of the kernel code :)

Yes, the documentation could be better.  But then, how much more can you
expect from somebody who's doing this mostly for fun and who - despite
working in his dayjob on FOSS cellular projects - has no single
commercial project/context that uses the kernel GTP code.

In any case, working on a specific protocol or technology will require
that you understand that technology to some extent, including the
available tools.  There's always a learning curve involved.

> There are other examples in the kernel of systems bigger than GTP that
> require a whole lot of effort just to run a simple test; you'll notice
> for those it's rare that best developers ever bother to look at them
> unless they're making a global change that affects the code. We don't
> want GTP to take be like that!

I'm all for following your argument.  My point is simply: You cannot
develop code solely based on mock-ups without any 'realistic' test
scenarios.  Otherwise you will end up with something that works only in
your artificial lab setup, and follows all the best practises of the way
how the Linux kernel traditionally approaches tunneling implementations,
but it will never work/interop in the real world.

And I'm very strongly opposed to merging code where we have not been
able to show that it will inter-operate in at least one realistic
scenario.  This would raise wrong expectations with users and all sorts
of downstream problems.

So let's say we merge your IPv6 support as-is, and kernels get released
+ shipped with it.  Later on, we find that in order to turn it into a
standards-compliant implementation together with all the required bits
in userspace and on the control plane, we need to change some parts of
it, particularly those parts that affect the netlink or any other
exposed userspace interface.  At that point, we cannot change the
interface as the kernel has a strict rule of never breaking userspace
ABI.  But we must change it in order to make it work in the real world.
So what do we do?  Add lots of cruft in order to emulate backwards
compatibility?

> So the forward looking question now is how to get to be able to run a
> "realistic setup"?

You can run this realistic setup entirely using Osmocom components.

For running a 2G network: OsmoBTS+OsmoNITB+OsmoSGSN
For running a 3G network: OsmoHNBGW+OsmoMSC+OsmoHLR+OsmoSGSN

Both above stacks/combinations will provide you with GTP-C and GTP-U
against a GGSN.  As GGSN, you can then use either OpenGGSN, or OsmoGGSN,
or ergw.  For OpenGGSN and ergw, this will work with kernel GTP today,
for those features present in kernel GTP (i.e. IPv4-only).

In both cases you need some RF hardware.  I'm happy to contribute
related hardware (and support getting it set up) free of charge from my
company sysmocom to anyone who has a realistic prospect of either
* integrating your IPv6 support or other significant feature patches with
  libgtpnl + OsmoGGSN (at which point you can run a complete setup with
  real phones to verify it works end-to-end)
* building and documenting or operating a continuous integration setup
  that would run tests on each new kernel version (or net-next, or
  whatever tree makes sense) to help us catch any regressions as the
  code proceeds

In order to have a smaller, but still realistic test scenario, I
implemented a series of GTP tests in
http://git.osmocom.org/osmo-ttcn3-hacks/tree/ggsn_tests/GGSN_Tests.ttcn

This code basically emulates the combination of everything from Phone to
SGSN, so that you have only two entities:
* the implementation under test = IUT (a GGSN implementing GTP-C + GTP-U)
* the test itself (GGSN_Test) executing against the IUT

The code so far implements PDP context activation + address allocation
for IPv4-only and IPv6-only cases and can be run against a GGSN
implementing those.  The IPv6-only PDP context unit tests include the
convoluted two-phase address assignment including sending the router
solicitation from the simulated phone as well as verifying the router
advertisement sent in response from the GGSN.

Yes, I know they're written in an unknown niche programming language
called TTCN-3, but this was the best tool at hand for the job I could
find, and the tests are open source as is the Eclipse Titan toolchain
for compiling it.

We even have a Dockerfile that will build you a docker container
containing the compiled GGSN_test at
http://git.osmocom.org/docker-playground/tree/ggsn-test

That docker container is used by a jenkins build test job to test
current OsmoGGSN master every night against the test suite.

I was stupid enough to break the testsuite with an accidential commit,
so tests between August 27th and today failed.  I've just reverted that
accident - don't let that mistake of mine mislead you.

I'm happy to contribute further to this by adding actual user-IP GTP-U
functional testing beyond the router soliciatation/advertisement to it.

So my suggestion in terms of a "realistic testbed without having to
configure + run dozens of programs and using real RF + phones" is to use
that testsuite.

What one cannot get around is having to implement support for new
features added on the kernel side such as IPv6 in libgtpnl and at least
one of the GGSN's using it, sorry.  Without that, there is no way to
know if that code would do anything useful.  You simply cannot
realistically test GTP-U alone without GTP-C.

I'd love to offer help on this, but it's really impossible right now.
I'm on holidays on a motorbike tour through rural Taiwan's mountains,
had to deal with a flat tire today, have limited connectivity and am
already cutting down hard on sleep every night to be able to respond to
the absolute minimally required work e-mails.  And review/follow-up to
your much appreciated patch series the last couple of days has also used
a lot of (unexpected not scheduled for) time.  I'm not complaining, I'm
just saying I am really not able to contribute more to this effort right
now beyond my review, the offer of free hardware for a real cellular
network, and the extension of the test cases for GTP-U beyond the
already implemented very important IPv6 address allocation/assignment
which I believe your current code would not pass.

Regards,
	Harald

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
