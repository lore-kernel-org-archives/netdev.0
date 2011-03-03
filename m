From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Bug inkvm_set_irq
Date: Thu, 3 Mar 2011 16:47:15 +0200
Message-ID: <20110303144715.GA12400@redhat.com>
References: <4D67714A.2050100@univ-nantes.fr>
 <20110227170031.GC17973@redhat.com>
 <4D6B634E.9090801@univ-nantes.fr>
 <20110228101139.GD28006@redhat.com>
 <4D6B7BAB.9070907@univ-nantes.fr>
 <20110228113939.GH28006@redhat.com>
 <4D6BBB88.5060709@univ-nantes.fr>
 <4D6C22E8.2020007@univ-nantes.fr>
 <20110301070333.GA5972@redhat.com>
 <4D6D0510.4060300@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D6D0510.4060300@univ-nantes.fr>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 01, 2011 at 03:39:12PM +0100, Jean-Philippe Menil wrote:
> so this time the bug is:
> 
> [17882.612303] BUG: unable to handle kernel paging request at
> 0000000000002458
> [17882.612342] IP: [<ffffffffa03898a0>] kvm_set_irq+0x30/0x140 [kvm]
> 
> markup_oops give me this:
> 
> root@ayrshire:~# cat bug-0103.txt | perl markup_oops.pl -m
> /lib/modules/2.6.37.2-dsiun-110105+/kernel/arch/x86/kvm/kvm.ko
> /boot/vmlinuz-2.6.37.2-dsiun-110105+
> vmaoffset = 18446744072102621184 ffffffffa0389871:	48 89 e5   	mov
> %rsp,%rbp
>  ffffffffa0389874:	41 57                	push   %r15
>  ffffffffa0389876:	41 89 cf             	mov    %ecx,%r15d  |  %r15
> => 1  %ecx = 1
>  ffffffffa0389879:	41 56                	push   %r14        |  %r14
> => ffffffffa038aad0
>  ffffffffa038987b:	41 55                	push   %r13
>  ffffffffa038987d:	49 89 fd             	mov    %rdi,%r13   |  %edi
> = 0  %r13 => 0
>  ffffffffa0389880:	41 54                	push   %r12        |  %r12 => 0
>  ffffffffa0389882:	53                   	push   %rbx
>  ffffffffa0389883:	89 d3                	mov    %edx,%ebx   |  %ebx => 1a
>  ffffffffa0389885:	48 81 ec a8 00 00 00 	sub    $0xa8,%rsp
>  ffffffffa038988c:	8b 15 00 00 00 00    	mov    0x0(%rip),%edx
> # ffffffffa0389892 <kvm_set_irq+0x22>
>  ffffffffa0389892:	89 b5 3c ff ff ff    	mov    %esi,-0xc4(%rbp) |
> %esi = 0
>  ffffffffa0389898:	85 d2                	test   %edx,%edx   |  %edx => 0
>  ffffffffa038989a:	0f 85 d5 00 00 00    	jne    ffffffffa0389975
> <kvm_set_irq+0x105>
> *ffffffffa03898a0:	49 8b 85 58 24 00 00 	mov    0x2458(%r13),%rax |
> %eax = 0  %r13 = 0 <--- faulting instruction
>  ffffffffa03898a7:	3b 98 28 01 00 00    	cmp    0x128(%rax),%ebx
>  ffffffffa03898ad:	73 61                	jae    ffffffffa0389910
> <kvm_set_irq+0xa0>
>  ffffffffa03898af:	89 db                	mov    %ebx,%ebx
>  ffffffffa03898b1:	48 8b 84 d8 30 01 00 	mov    0x130(%rax,%rbx,8),%rax
>  ffffffffa03898b8:	00
>  ffffffffa03898b9:	48 85 c0             	test   %rax,%rax
>  ffffffffa03898bc:	74 52                	je     ffffffffa0389910
> <kvm_set_irq+0xa0>
>  ffffffffa03898be:	48 8d 95 40 ff ff ff 	lea    -0xc0(%rbp),%rdx
>  ffffffffa03898c5:	31 db                	xor    %ebx,%ebx
>  ffffffffa03898c7:	48 8b 08             	mov    (%rax),%rcx
>  ffffffffa03898ca:	83 c3 01             	add    $0x1,%ebx
>  ffffffffa03898cd:	0f 18 09             	prefetcht0 (%rcx)
>  ffffffffa03898d0:	48 8b 48 e0          	mov    -0x20(%rax),%rcx
>  ffffffffa03898d4:	48 89 0a             	mov    %rcx,(%rdx)
>  ffffffffa03898d7:	48 8b 48 e8          	mov    -0x18(%rax),%rcx
>  ffffffffa03898db:	48 89 4a 08          	mov    %rcx,0x8(%rdx)
>  ffffffffa03898df:	48 8b 48 f0          	mov    -0x10(%rax),%rcx
>  ffffffffa03898e3:	48 89 4a 10          	mov    %rcx,0x10(%rdx)
>  ffffffffa03898e7:	48 8b 48 f8          	mov    -0x8(%rax),%rcx
>  ffffffffa03898eb:	48 89 4a 18          	mov    %rcx,0x18(%rdx)
> 
> wich correspond to offset 68a0 (from objdump):
> 
> kvm_set_irq():
> /usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:161
>     68a0:       49 8b 85 58 24 00 00    mov    0x2458(%r13),%rax
> /usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:162
>     68a7:       3b 98 28 01 00 00       cmp    0x128(%rax),%ebx
> 
> root@ayrshire:~# addr2line -e
> /lib/modules/2.6.37.2-dsiun-110105+/kernel/arch/x86/kvm/kvm.ko
> 0x68a0
> /usr/src/GIT/linux-2.6-stable/arch/x86/kvm/../../../virt/kvm/irq_comm.c:161
> 
> So here kvm->irq_routing is null.
> 
> How can it be?
> 
> Regards.

Not null, this seems to be invalid.
I suspect use after free where the kvm pointer is
pointing at some random memory. Use after free?
Could you please try enabling a slab debugger,
recompile and rerun the test?

-- 
MST
