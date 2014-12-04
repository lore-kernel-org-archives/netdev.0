From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] arch_fast_hash: avoid indirect function calls
 and implement hash in asm
Date: Thu, 04 Dec 2014 20:32:06 +0100
Message-ID: <1417721526.5386.39.camel@localhost>
References: <e77237174e1b8d743ef5171e05abde82bc54af37.1417696901.git.hannes@stressinduktion.org>
	 <15333.1417721231@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:59750 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932315AbaLDTcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 14:32:09 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 559FD223D9
	for <netdev@vger.kernel.org>; Thu,  4 Dec 2014 14:32:08 -0500 (EST)
In-Reply-To: <15333.1417721231@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

On Do, 2014-12-04 at 11:27 -0800, Jay Vosburgh wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
> >By default the arch_fast_hash hashing function pointers are initialized
> >to jhash(2). If during boot-up a CPU with SSE4.2 is detected they get
> >updated to the CRC32 ones. This dispatching scheme incurs a function
> >pointer lookup and indirect call for every hashing operation.
> >
> >To keep the number of clobbered registers short the hashing primitives
> >are implemented in assembler. This makes it easier to do the dispatch
> >by alternative_call.
> 
> 	I have tested this on the same system that panicked with the
> original (now reverted) implementation (commit e5a2c8999576 "fast_hash:
> avoid indirect function calls"), and it functions correctly and does not
> panic.
> 
> 	I looked at the disassembly, and, as a data point, on a
> non-SSE4.2 system, the code generated is not as efficient as Hannes'
> original test patch, found here:
> 
> http://comments.gmane.org/gmane.linux.network/338430
> 
> 	which produced code as follows:
> 
> 0xffffffffa00b6bb9 <ovs_flow_tbl_insert+0xb9>:  mov    %r15,0x348(%r14)
> 0xffffffffa00b6bc0 <ovs_flow_tbl_insert+0xc0>:  movzwl 0x28(%r15),%ecx
> 0xffffffffa00b6bc5 <ovs_flow_tbl_insert+0xc5>:  movzwl 0x2a(%r15),%esi
> 0xffffffffa00b6bca <ovs_flow_tbl_insert+0xca>:  movzwl %cx,%eax
> 0xffffffffa00b6bcd <ovs_flow_tbl_insert+0xcd>:  sub    %ecx,%esi
> 0xffffffffa00b6bcf <ovs_flow_tbl_insert+0xcf>:  lea    0x38(%r14,%rax,1),%rdi
> 0xffffffffa00b6bd4 <ovs_flow_tbl_insert+0xd4>:  sar    $0x2,%esi
> 0xffffffffa00b6bd7 <ovs_flow_tbl_insert+0xd7>:  callq  0xffffffff813a7810 <__jhash2>
> 0xffffffffa00b6bdc <ovs_flow_tbl_insert+0xdc>:  mov    %eax,0x30(%r14)
> 0xffffffffa00b6be0 <ovs_flow_tbl_insert+0xe0>:  mov    (%rbx),%r13
> 0xffffffffa00b6be3 <ovs_flow_tbl_insert+0xe3>:  mov    %r14,%rsi
> 0xffffffffa00b6be6 <ovs_flow_tbl_insert+0xe6>:  mov    %r13,%rdi
> 0xffffffffa00b6be9 <ovs_flow_tbl_insert+0xe9>:  callq  0xffffffffa00b61a0 <table_instance_insert>
> 
> 	This patch's code ends up as follows:
> 
> 0xffffffffa01b5a57 <ovs_flow_tbl_insert+0xb7>:	mov    %r15,0x348(%rcx)
> 0xffffffffa01b5a5e <ovs_flow_tbl_insert+0xbe>:	movzwl 0x28(%r15),%eax
> 0xffffffffa01b5a63 <ovs_flow_tbl_insert+0xc3>:	movzwl 0x2a(%r15),%esi
> 0xffffffffa01b5a68 <ovs_flow_tbl_insert+0xc8>:	movzwl %ax,%edx
> 0xffffffffa01b5a6b <ovs_flow_tbl_insert+0xcb>:	sub    %eax,%esi
> 0xffffffffa01b5a6d <ovs_flow_tbl_insert+0xcd>:	lea    0x38(%rcx,%rdx,1),%rdi
> 0xffffffffa01b5a72 <ovs_flow_tbl_insert+0xd2>:	xor    %edx,%edx
> 0xffffffffa01b5a74 <ovs_flow_tbl_insert+0xd4>:	sar    $0x2,%esi
> 0xffffffffa01b5a77 <ovs_flow_tbl_insert+0xd7>:	callq  0xffffffff813ae9f0 <__jhash_trampoline>
> 0xffffffffa01b5a7c <ovs_flow_tbl_insert+0xdc>:	mov    %eax,0x30(%rcx)
> 0xffffffffa01b5a7f <ovs_flow_tbl_insert+0xdf>:	mov    (%rbx),%r13
> 0xffffffffa01b5a82 <ovs_flow_tbl_insert+0xe2>:	mov    %rcx,%rsi
> 0xffffffffa01b5a85 <ovs_flow_tbl_insert+0xe5>:	mov    %r13,%rdi
> 0xffffffffa01b5a88 <ovs_flow_tbl_insert+0xe8>:	callq  0xffffffffa01b5030 <table_instance_insert>
> 
> 0xffffffff813ae9f0 <__jhash_trampoline>:	push   %rcx
> 0xffffffff813ae9f1 <__jhash_trampoline+0x1>:	push   %r8
> 0xffffffff813ae9f3 <__jhash_trampoline+0x3>:	push   %r9
> 0xffffffff813ae9f5 <__jhash_trampoline+0x5>:	push   %r10
> 0xffffffff813ae9f7 <__jhash_trampoline+0x7>:	push   %r11
> 0xffffffff813ae9f9 <__jhash_trampoline+0x9>:	callq  0xffffffff813ae8a0 <__jhash>
> 0xffffffff813ae9fe <__jhash_trampoline+0xe>:	pop    %r11
> 0xffffffff813aea00 <__jhash_trampoline+0x10>:	pop    %r10
> 0xffffffff813aea02 <__jhash_trampoline+0x12>:	pop    %r9
> 0xffffffff813aea04 <__jhash_trampoline+0x14>:	pop    %r8
> 0xffffffff813aea06 <__jhash_trampoline+0x16>:	pop    %rcx
> 0xffffffff813aea07 <__jhash_trampoline+0x17>:	retq   
> 
> 	In any event, this new patch does work correctly in my test that
> originally failed, and it's debatable how much optimizing for old
> systems is worthwhile.

Yes, that is expected. I also don't have a good idea on how to improve
the hashing on non-SSE4.2 systems in a reasonable amount of time.

> 	I only tested the non-SSE4.2 (i.e., old system) portion on
> x86_64.

I tried every possible setup this time, especially with openvswitch. I
covered ia32 with and without SSE4.2 as well as x86_64 and it always
behaved correctly. Last time the problem was that the static inline
didn't become a function in OVS, but during the testing with rhashtable
it got synthesized into a normal C call because of the indirect
reference.

Thanks a lot,
Hannes
