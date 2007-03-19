From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Mon, 19 Mar 2007 12:33:05 -0700
Message-ID: <45FEE571.9060302@goop.org>
References: <20070316.023331.59468179.davem@davemloft.net> <45FB005D.9060809@goop.org> <1174127638.8897.75.camel@localhost.localdomain> <20070318.003309.71088169.davem@davemloft.net> <20070318120814.GA45869@muc.de> <1174272469.11680.23.camel@localhost.localdomain> <m1648xxf93.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@muc.de>,
	David Miller <davem@davemloft.net>, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, zach@vmware.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:33109 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752245AbXCSTdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 15:33:10 -0400
In-Reply-To: <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> On Mon, 19 Mar 2007, Eric W. Biederman wrote:
>   
>> True.  You can use all of the call clobbered registers.
>>     
>
> Quite often, the biggest single win of inlining is not so much the code 
> size (although if done right, that will be smaller too), but the fact that 
> inlining DOES NOT CLOBBER AS MANY REGISTERS!
>   

Yes, that's something that we've been conscious of when designing the
pv_ops patching mechanism.  As it stands, each time you emit a call to a
pv-ops operation, it not only stores the start and end of the patchable
area, but also which registers are available for clobbering at that
callsite by the patched-in code.  For things like sti/cli, where the
surrounding code expects nothing to be clobbered, we make sure that the
regs are preserved on the pv-ops side, even though there's a call to a
normal C function in the middle.  That gives in the pvops backend the
flexibility to patch over that site with either some inline code or a
call out to some function which doesn't necessarily clobber the full
caller-save set (or even any registers).

> In short: people here seem to think that inlining is about avoiding the 
> call/ret sequence. Not so. The real advantages of inlining are elsewhere.
>   

Yes.  Probably the biggest win of inlining is constant propagation into
the inline function, but register-use flexibility is good small-scale
win (vs the micro-scale call/ret elimination).

> Side note, you can certainly fix things like this at least in theory, but 
> it requires:
>
>  - the "call" instruction that is used instead of the inlining should 
>    basically have no callee-clobbers. Any paravirt_ops called this way
>    should have a special calling sequence where they simple save and 
>    restore all the registers they use.
>
>    This is usually not that bad. Just create a per-architecture wrapper 
>    function that saves/restores anything that the C calling convention on 
>    that architecture says is clobbered by calls.
>   

Most of the places we intercept are normal C calls anyway, so this isn't
a big issue.  Its mainly the places where we replace single instructions
that this will have a big effect.

The trouble with this is that we're back to having to have special
wrappers around each call to hide the normal C calling convention from
the compiler, so that it knows that it has more registers to play with. 
This was the main complaint about the original version of the patch,
because it all looks very ugly.

>  - if the function has arguments, and the inlined sequence can take the 
>    arguments in arbitrary registers, you are going to penalize the inlined 
>    sequence anyway (by forcing some fixed arbitrary register allocation 
>    policy).This thing is largely unfixable without some really extreme 
>    compiler games (like post-processing the assembler output and having 
>    different entry-points depending on where the arguments are..)
>   

Yeah, that doesn't sound like much fun.  I think using the normal
regparm calling convention will be OK.  Aside from some slightly longer
instruction encodings, all the registers are more or less
interchangeable anyway.

> .. it will obviously depend on how thngs are done whether these things are 
> useful or not. But it does mean that it's always a good idea to just have 
> a config option of "turn off all the paravirt crap, because it *does* add 
> overhead, and replacing instructions on the fly doesn't make that 
> overhead go away".

Yes, there's a big switch to turn all this off.  It would be nice if we
could get things to the point that it isn't necessary to have (ie,
running on bare hardware really is indistinguishable either way), but
we're a fair way from being able to prove that.  In the meantime, the
goal is to try to keep the source-level changes a local as possible so
that maintaining the CONFIG_PARAVIRT vs non-PARAVIRT distinction is
straightforward.


    J
