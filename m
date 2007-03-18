From: David Miller <davem@davemloft.net>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Sun, 18 Mar 2007 00:33:09 -0700 (PDT)
Message-ID: <20070318.003309.71088169.davem@davemloft.net>
References: <20070316.023331.59468179.davem@davemloft.net>
	<45FB005D.9060809@goop.org>
	<1174127638.8897.75.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, mingo@elte.hu, ak@muc.de,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, zach@vmware.com, anthony@codemonkey.ws,
	torvalds@linux-foundation.org, netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753108AbXCRHdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 03:33:09 -0400
In-Reply-To: <1174127638.8897.75.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 17 Mar 2007 21:33:58 +1100

> On Fri, 2007-03-16 at 13:38 -0700, Jeremy Fitzhardinge wrote:
> > David Miller wrote:
> > > Perhaps the problem can be dealt with using ELF relocations.
> > >
> > > There is another case, discussed yesterday on netdev, where run-time
> > > resolution of ELF relocations would be useful (for
> > > very-very-very-read-only variables) so if it can solve this problem
> > > too it would be nice to have a generic infrastructure for it.
> > 
> > That's an interesting idea.  Have you or anyone else looked at what it
> > would take to code up?
> > 
> > For this case, I guess you'd walk the relocs looking for references into
> > the paravirt_ops structure.  You'd need to check that was a reference
> > from an indirect jump or call instruction, which would identify a
> > patchable callsite.  The offset into the pv_ops structure would identify
> > which operation is involved.
> 
> I wrote a whole email on ways to do this, BUT...

The idea is _NOT_ that you go look for references to the paravirt_ops
members structure, that would be stupid and you wouldn't be able to
use the most efficient addressing mode on a given cpu, you'd be
patching up indirect calls and crap like that.  Just say no...

Instead you get rid of paravirt ops completely, and you call functions
whose symbol name will not resolve in the initial kernel link.

You do an initial link of the kernel, look for the unresolved symbols
in the ELF relocation tables (just like the linker does), and put
those references into a table that is use to patch things up and you
can use standard ELF relocation code to handle this, exactly like code
we already have for module loading in the kernel already.

This idea is about 15 years old, sparc32 has been doing exactly this
via something called "btfixup" to handle the page table, TLB, and
cache differences of 15 different cpu+cache type combinations.

> #define pv_patch(call, args...) \
> 	asm volatile("8888:"); 
> 	call(args);
> 	asm volatile("8889:"
> 	 [ stuff to put 8889, 8888 and call in fixup section ]

Please, use ELF and it's powerful and clean existing way to
do this please. :-)

> > What are the netdev requirements?
> 
> Reading Ben LaHaise's (very cool!) patch, it's not clear that using
> reloc postprocessing is going to be clearer than open-coding it as he
> has done.

Ben's case can be handled in the same way.  Just do not define the
symbols, pre-link, look for the references in the relocation tables,
and run through that when you do the set_very_readonly() or
install_paravirt_ops() thing.
