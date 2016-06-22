From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/6] ppc: ebpf/jit: Implement JIT compiler for extended
 BPF
Date: Wed, 22 Jun 2016 18:02:40 +0530
Message-ID: <20160622123239.GK8886@naverao1-tp.localdomain>
References: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <1466591863.29871.1.camel@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, Matt Evans <matt@ozlabs.org>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	Paul Mackerras <paulus@samba.org>,
	Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: Michael Ellerman <mpe@ellerman.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1466591863.29871.1.camel@ellerman.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/06/22 08:37PM, Michael Ellerman wrote:
> On Tue, 2016-06-07 at 19:02 +0530, Naveen N. Rao wrote:
> 
> > PPC64 eBPF JIT compiler.
> > 
> > Enable with:
> > echo 1 > /proc/sys/net/core/bpf_jit_enable
> > or
> > echo 2 > /proc/sys/net/core/bpf_jit_enable
> > 
> > ... to see the generated JIT code. This can further be processed with
> > tools/net/bpf_jit_disasm.
> > 
> > With CONFIG_TEST_BPF=m and 'modprobe test_bpf':
> > test_bpf: Summary: 305 PASSED, 0 FAILED, [297/297 JIT'ed]
> > 
> > ... on both ppc64 BE and LE.
> > 
> > The details of the approach are documented through various comments in
> > the code.
> 
> This is crashing for me on a Cell machine, not sure why at a glance:
> 
> 
> test_bpf: #250 JMP_JSET_X: if (0x3 & 0xffffffff) return 1 jited:1 14 PASS
> test_bpf: #251 JMP_JA: Jump, gap, jump, ... jited:1 15 PASS
> test_bpf: #252 BPF_MAXINSNS: Maximum possible literals 
> Unable to handle kernel paging request for data at address 0xd000000007b20000
> Faulting instruction address: 0xc000000000667b6c
> cpu 0x0: Vector: 300 (Data Access) at [c0000007f83bf3a0]
>     pc: c000000000667b6c: .flush_icache_range+0x3c/0x84
>     lr: c000000000082354: .bpf_int_jit_compile+0x1fc/0x2c8
>     sp: c0000007f83bf620
>    msr: 900000000200b032
>    dar: d000000007b20000
>  dsisr: 40000000
>   current = 0xc0000007f8249580
>   paca    = 0xc00000000fff0000	 softe: 0	 irq_happened: 0x01
>     pid   = 1822, comm = insmod
> Linux version 4.7.0-rc3-00061-g007c99b9d8c1 (michael@ka3.ozlabs.ibm.com) (gcc version 6.1.0 (GCC) ) #3 SMP Wed Jun 22 19:22:23 AEST 2016
> enter ? for help
> [link register   ] c000000000082354 .bpf_int_jit_compile+0x1fc/0x2c8
> [c0000007f83bf620] c0000000000822fc .bpf_int_jit_compile+0x1a4/0x2c8 (unreliable)
> [c0000007f83bf700] c00000000013cda4 .bpf_prog_select_runtime+0x24/0x108
> [c0000007f83bf780] c000000000548918 .bpf_prepare_filter+0x9b0/0x9e8
> [c0000007f83bf830] c0000000005489d4 .bpf_prog_create+0x84/0xd0
> [c0000007f83bf8c0] d000000003b21158 .test_bpf_init+0x28c/0x83c [test_bpf]
> [c0000007f83bfa00] c00000000000a7b4 .do_one_initcall+0x5c/0x1c0
> [c0000007f83bfae0] c000000000669058 .do_init_module+0x80/0x21c
> [c0000007f83bfb80] c00000000011e3a0 .load_module+0x2028/0x23a8
> [c0000007f83bfd20] c00000000011e898 .SyS_init_module+0x178/0x1b0
> [c0000007f83bfe30] c000000000009220 system_call+0x38/0x110
> --- Exception: c01 (System Call) at 000000000ff5e0c4
> SP (ffde0960) is in userspace
> 0:mon> r
> R00 = 000000000000c01c   R16 = 0000000000000000
> R01 = c0000007f83bf620   R17 = 00000000024000c0
> R02 = c00000000094ce00   R18 = 0000000000000000
> R03 = d000000007b10000   R19 = d000000003c32df0
> R04 = d000000007b40338   R20 = c00000000072b488

Wow. I can't actually understand why this did not trigger for me. We are 
sending incorrect values into flush_icache_range(). So the first page is 
being flushed properly, but we are faulting trying to access another 
page. Patch forthcoming.

Thanks,
Naveen
 
