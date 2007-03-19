From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: Mon, 19 Mar 2007 11:57:28 +0100
Message-ID: <200703191157.29780.ak@suse.de>
References: <20070316.023331.59468179.davem@davemloft.net> <20070318193030.GB71548@muc.de> <45FDCF52.4000805@goop.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Andi Kleen <ak@muc.de>,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	chrisw@sous-sol.org, virtualization@lists.osdl.org,
	anthony@codemonkey.ws, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, mingo@elte.hu
To: virtualization@lists.linux-foundation.org, jbeulich@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48221 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752634AbXCSLA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 07:00:56 -0400
In-Reply-To: <45FDCF52.4000805@goop.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 19 March 2007 00:46, Jeremy Fitzhardinge wrote:
> Andi Kleen wrote:
> > Yes. All inline assembly tells gcc what registers are clobbered
> > and it fills in the tables. Hand clobbering in inline assembly cannot
> > be expressed with the current toolchain, so we moved all those
> > out of line.
> >
> > But again I'm not sure it will work anyways. For once you would
> > need large padding around the calls anyways for inline replacement --
> > how would you generate that? I expect you would need to put the calls
> > into asm() again and with that a custom annotiation format looks
> > reasonable.
>
> Inlining is most important for very small code: sti, cli, pushf;pop eax,
> etc (in many cases, no-ops).  We'd have at least 5 bytes to work in, and
> maybe more if there are surrounding push/pops to be consumed.
>
> For example, say we wanted to put a general call for sti into entry.S,
> where its expected it won't touch any registers.  In that case, we'd
> have a sequence like:
>
>     push %eax
>     push %ecx
>     push %edx
>     call paravirt_cli
>     pop %edx
>     pop %ecx
>     pop %eax

This cannot right now be expressed as inline assembly in the unwinder at all 
because there is no way to inject the push/pops into the compiler generated
ehframe tables.

[BTW I plan to resubmit the unwinder with some changes]

>
>
> If we parse the relocs, then we'd find the reference to paravirt_cli.
> If we look at the byte before and see 0xe8, then we can see if its a
> call.  If we then work out in each direction and see matched push/pops,
> then we know what registers can be trashed in the call.  This also
> allows us to determine the callsite size, and therefore how much space
> we need for inlining.

gcc normally doesn't generate push/pops around directly around the
call site, but somewhere else due to the way its register allocator works.
It can be anywhere in the function or even not there at all if the register
didn't contain anything useful. And they're not necessarily push/pops of 
course.

So you would need to write it as inline assembly. I'm not sure it would
be significantly cleaner than just having tables then.

> So in this case, we see that there are 5 bytes for the call and a
> further 6 bytes of push/pops available for inlining.
>
> Of course this is hand-written code anyway, so there's no particular
> burden to having some extra metadata stashed away in another section.
> For compiler-generated code, we know that it's already expecting
> standard C ABI calling conventions.  The downside, of course, is that
> only the 5 byte call space is available for inline patching.

It's unlikely you can do much useful in 5 bytes I guess.

Regarding cli/sti: i've been actually thinking about changing it in the
non paravirt kernel. IIRC most save_flags/restore_flags are inside
spin_lock_irqsave/restore() and that is a separate function anyways
so a little larger special case code is ok as long as it is not slower. 
There is some evidence that at least on P4 a software cli/sti flag without 
pushf/popf would be faster.

-Andi

