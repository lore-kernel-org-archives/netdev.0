From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Thu, 27 Nov 2003 17:34:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128013408.GD73661@gaz.sfgoth.com>
References: <1069934643.2393.0.camel@teapot.felipe-alfaro.com> <20031127.210953.116254624.yoshfuji@linux-ipv6.org> <20031127194602.A25015@flint.arm.linux.org.uk> <20031128.045413.133305490.yoshfuji@linux-ipv6.org> <20031127200041.B25015@flint.arm.linux.org.uk> <1069970770.2138.10.camel@teapot.felipe-alfaro.com> <20031127221928.F25015@flint.arm.linux.org.uk> <20031127223348.G25015@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>,
        "YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B" <yoshfuji@linux-ipv6.org>,
        davem@redhat.com,
        Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031127223348.G25015@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Russell King wrote:
> Sorry, bad example.  Hmm, from a glance around, it seems that all of
> the places which use strncpy() implicitly zero the buffer prior to
> using strncpy().
> 
> This means that the x86 strncpy is doing unnecessary zeroing.  I do
> remember Alan complaining about the last set of strlcpy() stuff
> introducing information leaks - maybe those got fixed though.

The problem is that most places you're filling in an array in a struct.
So even if you use strncpy() everywhere you can still get bitten if the
compiler inserts any padding for alignment on some architecture (since
even if you fully initialize each char[] array in the structure using
strncpy you might still leak info in padding bytes)

The safest thing to do in these cases is:
  1. memset() the array before you start
  2. strlcpy() for filling each char[] array (since strncpy would just
     re-zero those bytes it's wasteful)

Yes, the full memset() is a small waste, but its safe.  In 99% of these
cases we're talking about some weird ioctl() or something that's way off
the fast path anyways.

I pointed this out some months ago and someone (forgot who) replied that
there shouldn't be any padding in any struct exported from the kernel.
They added a compiler warning for structure padding in the -mm series for
a few days, but I guess it caused so many warnings that they took it right
out again, so I believe that there ARE plenty of places that user-visible
struct's get padded by the ABI of some platforms.  If there's some difinitive
evidence that padding never happens I'd like to see it.

-Mitch
