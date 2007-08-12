From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Sun, 12 Aug 2007 12:27:09 +0200
Message-ID: <cbbe196cd30095e13e96762a6ddfd9a0@kernel.crashing.org>
References: <20070808230733.GA17270@shell.boston.redhat.com> <alpine.LFD.0.999.0708082116060.25146@woody.linux-foundation.org> <46BAC2BE.1090106@redhat.com> <46BB508B.7050601@redhat.com> <alpine.LFD.0.999.0708091055080.25146@woody.linux-foundation.org> <1186683646.9669.20.camel@localhost> <a599bc5062d557db46496f0d7c7886b0@kernel.crashing.org> <alpine.LFD.0.999.0708112305170.30176@woody.linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wjiang@resilience.com, wensong@linux-vs.org,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	ak@suse.de, cfriesen@nortel.com, netdev@vger.kernel.org,
	horms@verge.net.au, akpm@linux-foundation.org,
	schwidefsky@de.ibm.com, Chuck Ebbert <cebbert@redhat.com>,
	davem@davemloft.net, zlynx@acm.org, Chris Snook <csnook@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45514 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754570AbXHLK2l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 06:28:41 -0400
In-Reply-To: <alpine.LFD.0.999.0708112305170.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Note that last line.
>
> Segher, how about you just accept that Linux uses gcc as per reality, 
> and
> that sometimes the reality is different from your expectations?
>
> "+m" works.

It works _most of the time_.  Ask Martin.  Oh you don't even have to,
he told you two mails ago.  My last mail simply pointed out that this
isn't a GCC bug, but merely documented behaviour.  Well okay, it was
documented only after people found problems with it; it is an edge
case and pretty hard to trigger (impossible to trigger on RISC
architectures, and not very likely on x86 either, for different
reasons).

Since "realistic" people keep using "+m" anyhow, current GCC has added
a workaround that splits "+m" into an "=m" and an "m" constraint.  It
likely will be accepted as a permanent feature.  However, that 
workaround
doesn't yet exist on some of the compilers Linux still allows building
with (but the problem does).

> We use it. It's better than the alternatives.

How is this better than simply writing the slightly more verbose
asm("..." : "=m"(XX) : "m"(XX)) ?  It's a few more characters.
asm() is hard to write (correctly) anyway.  I don't see the problem.

> Pointing to stale documentation doesn't change anything.

It's not "stale" documentation, it's freshly built from GCC mainline.
It's also not "stale" in the sense that it isn't updated; in fact,
the email I pointed to is from a thread where a change in this exact
paragraph in the documentation was suggested (a couple of weeks ago).

> The same is true of accesses through a volatile pointer. The kernel has
> done that for a *loong* time (all MMIO IO is done that way),

(All MMIO on certain architectures).  This however is a completely
different case; there _is_ no underlying C object declared anywhere,
so no way can GCC prove that that object isn't volatile, so it _has_
to assume it is.

Also, in case of e.g. readb(), if the compiler can prove the resulting
value isn't used it doesn't have to perform the access at all -- the
documentation (again, not "stale" documentation) points this out quite
literally.

> and it's
> totally pointless to say that "volatile" isn't guaranteed to do what it
> does.

I actually asked a couple of other GCC developers last night, and
they all agreed with me.  If you look at historic GCC problem reports
(I pointed at a few earlier in these threads) you would see that the
situation is far from clear.

> It works, and quite frankly, if it didn't work, it would be a gcc
> BUG.

How can it be a bug, if the semantics you think are guaranteed are
guaranteed in your (and others') minds only?

Of course, GCC likes to cater to its users, and tries to make things
work the way the programmer probably intended.  However it a) cannot
*actually* read your mind, it just looks that way; b) it _also_ has
to implement the _correct_ semantics of volatile; c) since this isn't
part of any C version (no, not GNU99 or similar either), sometimes
GCC developers do not think about what some people expect the compiler
should do with such code, but just implement the requirements they
*know* exist.  And that's when "BUGs" happen.

If you want GCC to do what you want it to do instead of what it does,
why not file an enhancement request?  <http://gcc.gnu.org/bugzilla>.

To save you the trouble, I just did: <gcc.gnu.org/PR33053>.  Let's
see what comes from it.

> And again, this is not a "C standard" issue. It's a "sane 
> implementation"
> issue.

Maybe what you consider sane isn't as clear-cut as you think?  I'm
not alone with this opinion, as the mailing lists archives readily
show.

> Linux expects the compiler to be sane.

And the compiler expects the code it is asked to translate to
be reasonably sane.  Nothing new here.  The compiler is more
forgiving than the Linux code, IMHO; that's why I suggested
using the obviously correct asm implementation of the atomic
get/set, rather than using the not-so-obviously-correct and
error-prone volatile thing.  The semantics of the asm() are
exactly the semantics you expect from an atomic get/set, while
that of the volatile implementation are *not*; and on top of
that it is very well-tested well-understood technology.

> If it isn't, that's not our problem.

What, if the compiler doesn't work as you expect, like a silent
miscompilation, or even only the compiler ICEs, that is not a
problem for users and/or developers of Linux?  Interesting
opinion.  I'd rather stay clear of known pitfalls.

> gcc *is* sane,

Yes, it is.

> and I don't see why you constantly act as if it wasn't.

I guess I didn't express myself clearly enough then.  Hopefully
some other people _did_ understand what I meant.  In very harsh
words: "not all (proposed) kernel code is sane".


Segher

