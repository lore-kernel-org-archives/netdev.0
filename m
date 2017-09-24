From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 09/14] gtp: Allow configuring GTP interface as
 standalone
Date: Sun, 24 Sep 2017 10:16:26 +0800
Message-ID: <20170924021626.b37zlwsomlibtnfs@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-10-tom@quantonium.net>
 <a6d1dad0-e922-2913-d4c8-592d403ee1cb@tpip.net>
 <CALx6S3771X4QUm2mJG=aJJ0f4Tm98NpGA7060vF1P8iuCPgicQ@mail.gmail.com>
 <56e339a8-fa2d-6f8d-a89c-c0f3f242763a@tpip.net>
 <CAPDqMeq1tLi=NkLyqma2OEHQi-fYEYeTU-8th9WKoZaeWiM0Rw@mail.gmail.com>
 <20170921001313.n2uo56oxmphcvd5g@nataraja>
 <CAPDqMeox74aEdV5_cr7HJ=kh0-etLdFE-u5=g8OqRzmS8OjOuQ@mail.gmail.com>
 <20170921151253.4udm54dcq7x3ed4q@nataraja>
 <CAPDqMeq69rjzPh8jo-G9gKT26h-br4OrE0yxTJGk97qRgX0K2A@mail.gmail.com>
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
Received: from ganesha.gnumonks.org ([213.95.27.120]:60458 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751355AbdIXCUO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 22:20:14 -0400
Content-Disposition: inline
In-Reply-To: <CAPDqMeq69rjzPh8jo-G9gKT26h-br4OrE0yxTJGk97qRgX0K2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Thu, Sep 21, 2017 at 09:43:02AM -0700, Tom Herbert wrote:
> Please see the cover letter for the original GTP kernel patches dated
> May 10, 2016. My first question on those was "Is there a timeline for
> adding IPv6 support?". To which Pablo replied that there was a
> preliminary patch for it that has not been released. 

I'll suggest Pablo to comment on that.  I don't recall the details at
that time, I was only involved in the earliest development of the module
and then handed over.

> If you don't like my patches or don't think that can be adapted to
> fully support the GTP specification, that's fine. 

It's not about "not liking".  I'm very happy about contributions,
including (of course) yours.  It's about making sure that code we merge
into the kernel GTP driver will actually be usable to create a
standards-compliant GTP application or not.

There's no use in merging an IPv6 support patch if already by code
review it can be shown that it's impossible to create a spec-compliant
implementation using that patch.  To me, that would be "merging IPv6
support so we can check off a box on a management form or marketing
sheet", but not for any practical value.

> But then you need to provide a viable alternative.

Why do *I* have to provide a viable alternative?  Who says that *I* have
an obligation to do so?  A (co-)maintainer of a given driver doesn't
have the obligation of implementing any feature as requested.

Community based collaborative development only gets those things done
that people contribute.  I have already contributed almost a decade of
my life to creating Free Software implementations of cellular protocol
stacks, and it continues to be the center of my work and spare time.
GTP is only one protocol layer on one of those stacks.

Pablo, Andreas and I have contributed a Linux kernel implementation that
currently only implements IPv4.  This implementation can by anyone
extended to support IPv6, and as you see from this e-mail thread, there
is interest in helping this along by
* providing code review (even at times when it's personally difficult
  for me)
* providing free hardware for setting up a "private cellular network"
  to test interoperability
* providing testing tools for validation in absence of such a cellular
  network

> We are at the point where a kernel networking feature that only
> supports IPv4 when it could support IPv6 must be considered
> incomplete.

I agree it is incomplete.  There's no doubt about that.  But then,
even the current "incomplete" implementation is working and can be used
to operate an interoperable, spec-compatible IPv4 GGSN.  So it serves a
practical purpose.  All I'm asking is that any IPv6 support patches are
developed with that same practical purpose in mind.

Going through the cover letter of your series again:

>  - IPv6 support

Cannot be merged as-is, see lengthy review discussion

> - Configurable networking interfaces so that GTP kernel can be
>   used and tested without needing GSN network emulation (i.e. no user
>   space daemon needed).
> - Port numbers are configurable

As I indicated, I'm not fundamentally opposed to it, but I'm wondering
how much value they bring in reality.  Andreas has raised the valid
concern that we're adding code that is not used in production setups or
by any of the userspace implementations using this tunneling module.
The code gets more complex and gets code paths that will not be
exercised/tested.

Nevertheless, if it helps you to work on GTP, we can merge them from my
point of view - unless Pablo and/or Andreas object more strongly.

> - GSO,GRO
> - A facility that allows application specific GSO callbacks

Fine with me, but I think you need to convince other folks about the
"application specific GSO" and the usage of the upper bits of
shinfo(skb)->gso_type.

>  - Control of zero UDP checksums

Same as above, Dave was raising some question about it, not sure if
his concern remains.

>  - Addition of a dst_cache in the GTP structure

Fine with me.


As for the patches touching gtp.c:

* 04/14 udp recv clean up:
	fine with me, but kbuild robot complaint?
	On a minor note, I think you're mixing two unrelated topics:
	Separating the UDP receive functions and conversion to gro_cells,
	which violates the "one patch per feature" rule.  I'd still
	merge it, but would prefer two separate patches

* 05/14 Remove special mtu handling
	Pending your rework

* 06/14 Eliminate pktinfo and add port configuration
	I don't like the combination of a non-functional "cosmetic"
	refactoring of removing a data structure with the introduction
	of a new feature.  Makes it harder to review, impossible to
	merge only one of the two.  For the rationale of introducing the
	gtp_pktinfo struct, see
	http://git.osmocom.org/osmo-gtp-kernel/commit/?id=3bc7019c7afd06b5c7d94e5621728d092b82bb85
	it was actually intended to make IPv6 support easier, but the
	partial IPv6 support was removed before mainline submission.

* 07/14 Support encapsulation of IPv6 packets
	Not acceptable in its current form, see extensive review

* 08/14 Support encpasulating over IPv6
	No concerns in principle. Pending you making it dependent on AF
	of socket

* 09/14 Allow configuring GTP interface as standalone
	Can be merged unless strong objection from Pablo/Andreas (see above)

* 10/14 Add support for devnet
	No concerns from my side

* 12/14 Configuration for zero UDP checksum
	Up to Dave, he raised a question on it

* 13/14 Support for GRO
	No concerns from my side

* 14/14 GSO support
	No concerns from my side

BTW: Where have the iproute2/ip patches been posted, which you mention
in your cover page of the patch series?

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
