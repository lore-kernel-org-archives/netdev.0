From: David Miller <davem@davemloft.net>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Mon, 19 Mar 2007 12:46:36 -0700 (PDT)
Message-ID: <20070319.124636.59653632.davem@davemloft.net>
References: <1174272469.11680.23.camel@localhost.localdomain>
	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>
	<45FEE010.1050103@goop.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rusty@rustcorp.com.au, ak@muc.de,
	mingo@elte.hu, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, chrisw@sous-sol.org,
	zach@vmware.com, anthony@codemonkey.ws,
	torvalds@linux-foundation.org, netdev@vger.kernel.org
To: jeremy@goop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752722AbXCSTqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 15:46:36 -0400
In-Reply-To: <45FEE010.1050103@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Mon, 19 Mar 2007 12:10:08 -0700

> All this is doable; I'd probably end up hacking boot/compressed/relocs.c
> to generate the appropriate reloc table.  My main concern is hacking the
> kernel build process itself; I'm unsure of what it would actually take
> to implement all this.

32-bit Sparc's btfixup might be usable as a guide.

Another point worth making is that for function calls you
can fix things up lazily if you want.

So you link, build the reloc tables, then link in a *.o file that
does provide the functions in the form of stubs.  The stubs intercept
the call, and patch the callsite, then revector to the real handler.

I don't like this idea actually because it essentially means you
either:

1) Only allow one setting of the operations

OR

2) Need to have code which walks the whole reloc table anyways
   to handle settings after the first so you can revector
   everyone back to the stubs and lazy reloc properly again

In fact forget I mentioned this idea :)

As another note, I do agree with Linus about the register usage
arguments.  It is important.  I think it's been mentioned but what you
could do is save nothing (so that "sti" and "cli" are just that and
cost nothing), but the more complicated versions save and restore
enough registers to operate.

It all depends upon what you're trying to do.  For example, it's
easy to use patching to make different PTE layouts be supportable
in the same kernel image.  We do this on sparc64 since sun4v
has a different PTE layout than sun4u, you can see the code in
asm-sparc64/pgtable.h for details (search for "sun4v_*_patch")
