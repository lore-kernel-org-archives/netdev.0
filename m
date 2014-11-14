From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net-next] fast_hash: clobber registers correctly for inline function use
Date: Fri, 14 Nov 2014 12:15:15 -0800
Message-ID: <17658.1415996115@famine>
References: <1415978022.15154.31.camel@localhost> <1415979181.17262.45.camel@edumazet-glaptop2.roam.corp.google.com> <1415979978.15154.41.camel@localhost> <20141114.133829.1437047454714311242.davem@davemloft.net> <1415995451.15154.54.camel@localhost>
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, ogerlitz@mellanox.com, pshelar@nicira.com,
	jesse@nicira.com, discuss@openvswitch.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:50889 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161184AbaKNUP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 15:15:28 -0500
In-reply-to: <1415995451.15154.54.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

>On Fr, 2014-11-14 at 13:38 -0500, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Fri, 14 Nov 2014 16:46:18 +0100
>> 
>> > I would still like to see the current proposed fix getting applied and
>> > we can do this on-top. The inline call after this patch reassembles a
>> > direct function call, so besides the long list of clobbers, it should
>> > still be pretty fast.
>> 
>> I would rather revert the change entirely until it is implemented
>> properly.
>> 
>> Also, I am strongly of the opinion that this is a mis-use of the
>> alternative call interface.  It was never intended to be used for
>> things that can make real function calls.
>
>I tend to disagree. Grepping e.g. shows
>
>        alternative_call_2(copy_user_generic_unrolled,
>                         copy_user_generic_string,
>                         X86_FEATURE_REP_GOOD,
>                         copy_user_enhanced_fast_string,
>                         X86_FEATURE_ERMS,
>                         ASM_OUTPUT2("=a" (ret), "=D" (to), "=S" (from),
>                                     "=d" (len)),
>                         "1" (to), "2" (from), "3" (len)
>                         : "memory", "rcx", "r8", "r9", "r10", "r11");
>
>
>(it has a few less clobbers because it has more output operands)

	As those functions (copy_user_generic_unrolled, et al) are all
in assembly language, presumably the list of clobbered registers can be
had via inspection.

	For the arch_fast_hash2 case, the functions (__intel_crc4_2_hash
and __jash2) are both written in C, so how would the clobber list be
created?

	-J

>I just tried to come up with some macros which lets you abstract away
>the clobber list, but in the end it somehow has to look exactly like
>that. The double-colon syntax also makes it difficult to come up with
>something that let's us use varargs for that.
>
>> You can add a million clobbers, or a trampoline, it's still using a
>> facility in a manner for which it was not designed.
>
>The full clobber list for a function call which would always clear
>registers like we would have in a normal non-inlined function call would
>look like this:
>
>#define FUNC_CLOBBER LIST "memory", "cc", "rax", "rdi", "rsi", "rdx", "rcx", "r8", "r9", "r10", "r11"
>
>(reference in arch/x86/include/asm/calling.h).
>
>> This means a new interface with a new name and with capabilities
>> explicitly supporting this case are in order.
>
>It try to implicitly embed the clobber list, would something like that
>be ok?
>
>Thanks,
>Hannes

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
