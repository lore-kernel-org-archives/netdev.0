From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 06 Dec 2006 13:01:54 +0000
Message-ID: <1165410114.5253.218.camel@pmac.infradead.org>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk>
	 <1165148731.12649.51.camel@pmac.infradead.org>
	 <20061204091341.GM8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Joseph S. Myers" <joseph@codesourcery.com>,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:43282 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760554AbWLFNCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 08:02:00 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061204091341.GM8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-12-04 at 10:13 +0100, Thomas Graf wrote:
> Userspace is not supposd to directly include kernel headers, instead
> it has to make local copies and compile against them.

No. It was _never_ sensible to simply declare that userspace "shall not
use kernel headers" in the absence of any serious alternative. It was
always just a cop-out.

Historically, there were a number of efforts to provide 'sanitised'
kernel headers which are needed for userspace to build against. Various
people forked headers from the kernel at different times, got burned out
at different times, took different approaches w.r.t. how much abuse of
kernel-private stuff should be permitted. We ended up with a bunch of
inconsistent sets of 'kernel headers' each done differently and updated
sporadically.

Thankfully, this is no longer the case. The kernel now has a
'headers_install' make target which spits out those headers which are
suitable for userspace, sanitised by removing anything within
__KERNEL__. We have a _consistent_, up to date set of headers which
distributions can use for building glibc and other system libraries and
tools. Some distributions are already shipping like that; others are
still working on doing so.

> Binary compatibility is always guaranteed but in times of development
> within a stable tree it's wrong to assume that headers never change.
>
> I do not agree with the change to include if_addr.h in rtnetlink.h.
> The point is to move bits apart and have multiple small pieces
> of header files defining a specific rtnetlink family which are a
> lot easier to maintain for both kernel and userspace than one giant
> rtnetlink.h for everything.

That makes some sense, but we need to be more careful about making
incompatible changes in the headers which we export -- it's no longer
acceptable to just toss a pile of crap over the wall and declare it to
be someone else's problem.

That isn't to say that we should _never_ make such changes, but we
should at least make sure we think about it and make sure that glibc
adapts to cope, _before_ people start to see build failures.

> > I suspect that if the IF{L,}A_{PAYLOAD,RTA} macros aren't used in the
> > kernel then the best answer is for glibc to define those for itself.
> 
> Right, if they did it right they would only have noticed when they
> updated the kernel headers to some newer versions and only had to
> move the bits to some compat header.

No. They _are_ doing it right -- they're running 'make headers_install'
against the 2.6.19 kernel and only _now_ are they finding that we broke
it without even the courtesy of a warning, let alone any consultation.

If _we_ had done it right, then they would have been warned when we
decided to change this, and we wouldn't have just released 2.6.19 with
changes which break the glibc build.

-- 
dwmw2

