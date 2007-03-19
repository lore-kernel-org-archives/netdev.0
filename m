From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Mon, 19 Mar 2007 10:58:29 -0700
Message-ID: <45FECF45.7010705@goop.org>
References: <20070316.023331.59468179.davem@davemloft.net> <20070318193030.GB71548@muc.de> <45FDCF52.4000805@goop.org> <200703191157.29780.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, jbeulich@novell.com,
	Andi Kleen <ak@muc.de>, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, chrisw@sous-sol.org,
	virtualization@lists.osdl.org, anthony@codemonkey.ws,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	mingo@elte.hu
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:45057 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030413AbXCSR6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 13:58:31 -0400
In-Reply-To: <200703191157.29780.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>>
>>     push %eax
>>     push %ecx
>>     push %edx
>>     call paravirt_cli
>>     pop %edx
>>     pop %ecx
>>     pop %eax
>>     
>
> This cannot right now be expressed as inline assembly in the unwinder at all 
> because there is no way to inject the push/pops into the compiler generated
> ehframe tables.
>   

I was thinking more of entry.S rather than inline asms.  The only ones I
can think of which would be relevant are the interrupt operations in
spinlocks, and even then we get a bit more leeway.

> gcc normally doesn't generate push/pops around directly around the
> call site, but somewhere else due to the way its register allocator works.
> It can be anywhere in the function or even not there at all if the register
> didn't contain anything useful. And they're not necessarily push/pops of 
> course.
>   

Right, I'm not making any assumptions about what gcc generates for
calls, other than assuming it uses a standard "call X" direct call
instruction.

> So you would need to write it as inline assembly. I'm not sure it would
> be significantly cleaner than just having tables then.
>   

No, my intention is that the vast majority of pv_ops uses, which are
calls from C code, would simply be normal C calls, syntatically and
semantically.

> It's unlikely you can do much useful in 5 bytes I guess.
>   

I think the main value is retaining non-PARAVIRT native performance
levels.  In the native case, the inlined instructions amount to 1 or 2
bytes, and having small patch sites is an advantage because there's less
space wasted on nops.  My understanding is that a direct call has almost
zero overhead on modern processors, because both the call and the return
can be completely predicted and prefetched, so the threshhold at which
you make inline vs call tradeoff is pretty small.

> Regarding cli/sti: i've been actually thinking about changing it in the
> non paravirt kernel. IIRC most save_flags/restore_flags are inside
> spin_lock_irqsave/restore() and that is a separate function anyways
> so a little larger special case code is ok as long as it is not slower. 
> There is some evidence that at least on P4 a software cli/sti flag without 
> pushf/popf would be faster.
>   

There are also the ones in entry.S.  I suppose spinlocks do get used
more than syscalls and interrupts.


    J
