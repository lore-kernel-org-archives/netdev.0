From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] fast_hash: clobber registers correctly for
 inline function use
Date: Fri, 14 Nov 2014 21:04:11 +0100
Message-ID: <1415995451.15154.54.camel@localhost>
References: <1415978022.15154.31.camel@localhost>
	 <1415979181.17262.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1415979978.15154.41.camel@localhost>
	 <20141114.133829.1437047454714311242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, pshelar@nicira.com, jesse@nicira.com,
	jay.vosburgh@canonical.com, discuss@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:43297 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161693AbaKNUEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 15:04:14 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 2E92520B83
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 15:04:14 -0500 (EST)
In-Reply-To: <20141114.133829.1437047454714311242.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-11-14 at 13:38 -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Fri, 14 Nov 2014 16:46:18 +0100
> 
> > I would still like to see the current proposed fix getting applied and
> > we can do this on-top. The inline call after this patch reassembles a
> > direct function call, so besides the long list of clobbers, it should
> > still be pretty fast.
> 
> I would rather revert the change entirely until it is implemented
> properly.
> 
> Also, I am strongly of the opinion that this is a mis-use of the
> alternative call interface.  It was never intended to be used for
> things that can make real function calls.

I tend to disagree. Grepping e.g. shows

        alternative_call_2(copy_user_generic_unrolled,
                         copy_user_generic_string,
                         X86_FEATURE_REP_GOOD,
                         copy_user_enhanced_fast_string,
                         X86_FEATURE_ERMS,
                         ASM_OUTPUT2("=a" (ret), "=D" (to), "=S" (from),
                                     "=d" (len)),
                         "1" (to), "2" (from), "3" (len)
                         : "memory", "rcx", "r8", "r9", "r10", "r11");


(it has a few less clobbers because it has more output operands)

I just tried to come up with some macros which lets you abstract away
the clobber list, but in the end it somehow has to look exactly like
that. The double-colon syntax also makes it difficult to come up with
something that let's us use varargs for that.

> You can add a million clobbers, or a trampoline, it's still using a
> facility in a manner for which it was not designed.

The full clobber list for a function call which would always clear
registers like we would have in a normal non-inlined function call would
look like this:

#define FUNC_CLOBBER LIST "memory", "cc", "rax", "rdi", "rsi", "rdx", "rcx", "r8", "r9", "r10", "r11"

(reference in arch/x86/include/asm/calling.h).

> This means a new interface with a new name and with capabilities
> explicitly supporting this case are in order.

It try to implicitly embed the clobber list, would something like that
be ok?

Thanks,
Hannes
