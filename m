From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] fast_hash: clobber registers correctly for
 inline function use
Date: Fri, 14 Nov 2014 23:37:42 +0100
Message-ID: <1416004662.15154.76.camel@localhost>
References: <1415978022.15154.31.camel@localhost>
	 <1415979181.17262.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1415979978.15154.41.camel@localhost>
	 <20141114.133829.1437047454714311242.davem@davemloft.net>
	 <1415995451.15154.54.camel@localhost> <17658.1415996115@famine>
	 <1415997309.15154.59.camel@localhost> <18948.1416003002@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, ogerlitz@mellanox.com, pshelar@nicira.com,
	jesse@nicira.com, discuss@openvswitch.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:54103 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754838AbaKNWhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 17:37:45 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 77F9620BB8
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 17:37:44 -0500 (EST)
In-Reply-To: <18948.1416003002@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

On Fr, 2014-11-14 at 14:10 -0800, Jay Vosburgh wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> [...]
> >I created it via the function calling convention documented in
> >arch/x86/include/asm/calling.h, so I specified each register which a
> >function is allowed to clobber with.
> >
> >I currently cannot see how I can resolve the invalid constraints error
> >easily. :(
> >
> >So either go with my first patch, which I puts the alternative_call
> >switch point into its own function without ever inlining or the patch
> >needs to be reverted. :/
> 
> 	As a data point, I tested the first patch as well, and the
> system does not panic with it in place.  Inspection shows that it's
> using %r14 in place of %r8 in the prior (crashing) implementation.

Yes, I also could reproduce your oops and the first unoffical patch  and
the first offical one both fixed it. After that, I thought that just
adding more clobbers cannot introduce bugs, so I only did compile
testing until I hit a window where gcc got mad with the excessive use of
clobbered registers but haven't tested the inline call sites that much
(sorry). :(

> 	Disassembly of the call site (on the non-sse4_1 system) in
> ovs_flow_tbl_insert with the first patch applied looks like this:
> 
> 0xffffffffa00b6bb9 <ovs_flow_tbl_insert+0xb9>:	mov    %r15,0x348(%r14)
> 0xffffffffa00b6bc0 <ovs_flow_tbl_insert+0xc0>:	movzwl 0x28(%r15),%ecx
> 0xffffffffa00b6bc5 <ovs_flow_tbl_insert+0xc5>:	movzwl 0x2a(%r15),%esi
> 0xffffffffa00b6bca <ovs_flow_tbl_insert+0xca>:	movzwl %cx,%eax
> 0xffffffffa00b6bcd <ovs_flow_tbl_insert+0xcd>:	sub    %ecx,%esi
> 0xffffffffa00b6bcf <ovs_flow_tbl_insert+0xcf>:	lea    0x38(%r14,%rax,1),%rdi
> 0xffffffffa00b6bd4 <ovs_flow_tbl_insert+0xd4>:	sar    $0x2,%esi
> 0xffffffffa00b6bd7 <ovs_flow_tbl_insert+0xd7>:	callq  0xffffffff813a7810 <__jhash2>
> 0xffffffffa00b6bdc <ovs_flow_tbl_insert+0xdc>:	mov    %eax,0x30(%r14)
> 0xffffffffa00b6be0 <ovs_flow_tbl_insert+0xe0>:	mov    (%rbx),%r13
> 0xffffffffa00b6be3 <ovs_flow_tbl_insert+0xe3>:	mov    %r14,%rsi
> 0xffffffffa00b6be6 <ovs_flow_tbl_insert+0xe6>:	mov    %r13,%rdi
> 0xffffffffa00b6be9 <ovs_flow_tbl_insert+0xe9>:	callq  0xffffffffa00b61a0 <table_instance_insert>
> 
> 	Compared to the panicking version's function:
> 
> 0xffffffffa01a55c9 <ovs_flow_tbl_insert+0xb9>:  mov    %r15,0x348(%r8)
> 0xffffffffa01a55d0 <ovs_flow_tbl_insert+0xc0>:  movzwl 0x28(%r15),%ecx
> 0xffffffffa01a55d5 <ovs_flow_tbl_insert+0xc5>:  movzwl 0x2a(%r15),%esi
> 0xffffffffa01a55da <ovs_flow_tbl_insert+0xca>:  movzwl %cx,%eax
> 0xffffffffa01a55dd <ovs_flow_tbl_insert+0xcd>:  sub    %ecx,%esi
> 0xffffffffa01a55df <ovs_flow_tbl_insert+0xcf>:  lea    0x38(%r8,%rax,1),%rdi
> 0xffffffffa01a55e4 <ovs_flow_tbl_insert+0xd4>:  sar    $0x2,%esi
> 0xffffffffa01a55e7 <ovs_flow_tbl_insert+0xd7>:  callq  0xffffffff813a75c0 <__jhash2>
> 0xffffffffa01a55ec <ovs_flow_tbl_insert+0xdc>:  mov    %eax,0x30(%r8)
> 0xffffffffa01a55f0 <ovs_flow_tbl_insert+0xe0>:  mov    (%rbx),%r13
> 0xffffffffa01a55f3 <ovs_flow_tbl_insert+0xe3>:  mov    %r8,%rsi
> 0xffffffffa01a55f6 <ovs_flow_tbl_insert+0xe6>:  mov    %r13,%rdi
> 0xffffffffa01a55f9 <ovs_flow_tbl_insert+0xe9>:  callq  0xffffffffa01a4ba0 <table_instance_insert>
> 
> 	It appears to generate the same instructions, but allocates
> registers differently (using %r14 instead of %r8).

Exactly and that makes sense. While %r8 must be available for the callee
to be clobbered with, %r14 must be saved by the callee and restored
before returning. So you pass the responsibility down to the other
functions, which tries not to touch %r14 because it knows it will have
to generate code for saving and restoring.

That's the reason why I actually like the the static inline clobbering
approach so much, it gives gcc possibilities to move around the
save/restore cycles and decide itself just by aligning which registers
to use.

Also the first version does work flawlessly (which I didn't send as a
patch but only as a diff in the mail). Here gcc synthesizes a full
function call which has the same effect as the long clobber list, only
it does chain two calls right behind each other.

> 	The __jhash2 disassembly appears to be unchanged between the two
> versions.

Thanks for looking into this!

It is actually pretty hairy to come up with a good solution for this,
because with the alternative interface you are only allowed to alter one
instruction. jump_tables also don't work because I currently have the
opinion that they do the switch way too late. I absolutely don't want to
have inserts into a hashtable with different hashing functions depending
how early during boot they took place.

Bye,
Hannes
