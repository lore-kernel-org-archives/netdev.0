From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: [PATCH] ppc: Fix BPF JIT for ABIv2
Date: Fri, 17 Jun 2016 10:00:43 -0300
Message-ID: <20160617130042.GO3516@indiana.gru.redhat.com>
References: <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <3rWKtT2tSrz9t2G@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, Matt Evans <matt@ozlabs.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@fb.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: Michael Ellerman <mpe@ellerman.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3rWKtT2tSrz9t2G@ozlabs.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 17, 2016 at 10:53:21PM +1000, Michael Ellerman wrote:
> On Tue, 2016-07-06 at 13:32:23 UTC, "Naveen N. Rao" wrote:
> > diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
> > new file mode 100644
> > index 0000000..954ff53
> > --- /dev/null
> > +++ b/arch/powerpc/net/bpf_jit_comp64.c
> > @@ -0,0 +1,956 @@
> ...
> > +
> > +static void bpf_jit_fill_ill_insns(void *area, unsigned int size)
> > +{
> > +	int *p = area;
> > +
> > +	/* Fill whole space with trap instructions */
> > +	while (p < (int *)((char *)area + size))
> > +		*p++ = BREAKPOINT_INSTRUCTION;
> > +}
> 
> This breaks the build for some configs, presumably you're missing a header:
> 
>   arch/powerpc/net/bpf_jit_comp64.c:30:10: error: 'BREAKPOINT_INSTRUCTION' undeclared (first use in this function)
> 
> http://kisskb.ellerman.id.au/kisskb/buildresult/12720611/
> 
> cheers

Hi, Michael and Naveen.

I noticed independently that there is a problem with BPF JIT and ABIv2, and
worked out the patch below before I noticed Naveen's patchset and the latest
changes in ppc tree for a better way to check for ABI versions.

However, since the issue described below affect mainline and stable kernels,
would you consider applying it before merging your two patchsets, so that we can
more easily backport the fix?

Thanks.
Cascardo.

---
>From a984dc02b6317a1d3a3c2302385adba5227be5bd Mon Sep 17 00:00:00 2001
From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Date: Wed, 15 Jun 2016 13:22:12 -0300
Subject: [PATCH] ppc: Fix BPF JIT for ABIv2

ABIv2 used for ppc64le does not use function descriptors. Without this patch,
whenever BPF JIT is enabled, we get a crash as below.

[root@ibm-p8-kvm-05-guest-02 ~]# echo 2 > /proc/sys/net/core/bpf_jit_enable
[root@ibm-p8-kvm-05-guest-02 ~]# tcpdump -n -i eth0 tcp port 22
device eth0 entered promiscuous mode
Pass 1: shrink = 0, seen = 0x0
Pass 2: shrink = 0, seen = 0x0
flen=1 proglen=8 pass=3 image=d000000005bb9018 from=tcpdump pid=11387
JIT code: 00000000: 00 00 60 38 20 00 80 4e
Pass 1: shrink = 0, seen = 0x30000
Pass 2: shrink = 0, seen = 0x30000
flen=20 proglen=524 pass=3 image=d000000005bbd018 from=tcpdump pid=11387
JIT code: 00000000: a6 02 08 7c 10 00 01 f8 70 ff c1 f9 78 ff e1 f9
JIT code: 00000010: e1 fe 21 f8 7c 00 e3 80 78 00 e3 81 50 78 e7 7d
JIT code: 00000020: c8 00 c3 e9 00 00 a0 38 00 c0 e0 3c c6 07 e7 78
JIT code: 00000030: 08 00 e7 64 54 1b e7 60 a6 03 e8 7c 0c 00 c0 38
JIT code: 00000040: 21 00 80 4e b0 01 80 41 00 00 00 60 dd 86 e0 38
JIT code: 00000050: 01 00 e7 3c 40 38 04 7c 9c 00 82 40 00 00 00 60
JIT code: 00000060: 00 c0 e0 3c c6 07 e7 78 08 00 e7 64 70 1b e7 60
JIT code: 00000070: a6 03 e8 7c 14 00 c0 38 21 00 80 4e 78 01 80 41
JIT code: 00000080: 00 00 00 60 06 00 04 28 68 01 82 40 00 00 00 60
JIT code: 00000090: 00 c0 e0 3c c6 07 e7 78 08 00 e7 64 54 1b e7 60
JIT code: 000000a0: a6 03 e8 7c 36 00 c0 38 21 00 80 4e 48 01 80 41
JIT code: 000000b0: 00 00 00 60 16 00 04 28 2c 01 82 41 00 00 00 60
JIT code: 000000c0: 00 c0 e0 3c c6 07 e7 78 08 00 e7 64 54 1b e7 60
JIT code: 000000d0: a6 03 e8 7c 38 00 c0 38 21 00 80 4e 18 01 80 41
JIT code: 000000e0: 00 00 00 60 16 00 04 28 fc 00 82 41 00 00 00 60
JIT code: 000000f0: 00 01 00 48 00 08 04 28 f8 00 82 40 00 00 00 60
JIT code: 00000100: 00 c0 e0 3c c6 07 e7 78 08 00 e7 64 70 1b e7 60
JIT code: 00000110: a6 03 e8 7c 17 00 c0 38 21 00 80 4e d8 00 80 41
JIT code: 00000120: 00 00 00 60 06 00 04 28 c8 00 82 40 00 00 00 60
JIT code: 00000130: 00 c0 e0 3c c6 07 e7 78 08 00 e7 64 54 1b e7 60
JIT code: 00000140: a6 03 e8 7c 14 00 c0 38 21 00 80 4e a8 00 80 41
JIT code: 00000150: 00 00 00 60 ff 1f 87 70 98 00 82 40 00 00 00 60
JIT code: 00000160: 00 c0 e0 3c c6 07 e7 78 08 00 e7 64 88 1b e7 60
JIT code: 00000170: a6 03 e8 7c 0e 00 c0 38 21 00 80 4e 78 00 80 41
JIT code: 00000180: 00 00 00 60 00 c0 e0 3c c6 07 e7 78 08 00 e7 64
JIT code: 00000190: 4c 1b e7 60 a6 03 e8 7c 0e 00 c5 38 21 00 80 4e
JIT code: 000001a0: 54 00 80 41 00 00 00 60 16 00 04 28 38 00 82 41
JIT code: 000001b0: 00 00 00 60 00 c0 e0 3c c6 07 e7 78 08 00 e7 64
JIT code: 000001c0: 4c 1b e7 60 a6 03 e8 7c 10 00 c5 38 21 00 80 4e
JIT code: 000001d0: 24 00 80 41 00 00 00 60 16 00 04 28 14 00 82 40
JIT code: 000001e0: 00 00 00 60 ff ff 60 38 01 00 63 3c 08 00 00 48
JIT code: 000001f0: 00 00 60 38 20 01 21 38 10 00 01 e8 a6 03 08 7c
JIT code: 00000200: 70 ff c1 e9 78 ff e1 e9 20 00 80 4e
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
Oops: Exception in kernel mode, sig: 4 [#1]
SMP NR_CPUS=32 NUMA pSeries
Modules linked in: virtio_balloon nfsd ip_tables x_tables autofs4 xfs libcrc32c virtio_console virtio_net virtio_pci virtio_ring virtio
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.7.0-rc3-00009-gdb06d75 #1
task: c0000004a9254500 ti: c0000004bffe4000 task.ti: c0000004a9260000
NIP: d000000005bbd000 LR: c0000000008bcad8 CTR: d000000005bbd000
REGS: c0000004bffe76d0 TRAP: 0700   Not tainted  (4.7.0-rc3-00009-gdb06d75)
MSR: 8000000000089033 <SF,EE,ME,IR,DR,RI,LE>  CR: 28002028  XER: 00000000
CFAR: c0000000008bcad4 SOFTE: 1
GPR00: c0000000008c18dc c0000004bffe7950 c000000000f19900 c0000004a9d98600
GPR04: d000000005bbb028 000000000000005c c000000002977000 000000000000004e
GPR08: 000000000000005c d000000005bbd000 0000000000000000 0000000000000700
GPR12: d000000005bbd000 c00000000fff8400 c000000000f21c38 f0000000104a3ac0
GPR16: 0000000000000000 c0000004a5b7e808 c000000002977831 c000000002977834
GPR20: c000000000f23040 0000000000000001 000000000000dd86 0000000000000000
GPR24: ffffffff80000000 000000000000005c c000000002977000 000000000000004e
GPR28: c0000004a5ede28e c000000002977000 c000000002848000 c0000004a9d98600
NIP [d000000005bbd000] 0xd000000005bbd000
LR [c0000000008bcad8] run_filter+0x48/0x90
Call Trace:
[c0000004bffe7950] [c0000004bffe7980] 0xc0000004bffe7980 (unreliable)
[c0000004bffe7970] [c0000000008c18dc] tpacket_rcv+0x13c/0x9d0
[c0000004bffe7a60] [c0000000007f060c] __netif_receive_skb_core+0x22c/0xb00
[c0000004bffe7b30] [c0000000007f3cfc] netif_receive_skb_internal+0x2c/0xc0
[c0000004bffe7b70] [c0000000007f524c] napi_gro_receive+0x11c/0x220
[c0000004bffe7bb0] [d0000000056e252c] virtnet_receive+0x2fc/0x940 [virtio_net]
[c0000004bffe7cc0] [d0000000056e2ba0] virtnet_poll+0x30/0xf0 [virtio_net]
[c0000004bffe7d00] [c0000000007f4878] net_rx_action+0x2d8/0x450
[c0000004bffe7e10] [c0000000000ae464] __do_softirq+0x164/0x3d0
[c0000004bffe7f00] [c0000000000aea68] irq_exit+0xc8/0x100
[c0000004bffe7f20] [c000000000010a98] __do_irq+0x98/0x200
[c0000004bffe7f90] [c000000000022274] call_do_irq+0x14/0x24
[c0000004a9263a00] [c000000000010c94] do_IRQ+0x94/0x110
[c0000004a9263a50] [c0000000000025d8] hardware_interrupt_common+0x158/0x180
--- interrupt: 501 at plpar_hcall_norets+0x1c/0x28
    LR = check_and_cede_processor+0x2c/0x40
[c0000004a9263d40] [c0000004a9263d90] 0xc0000004a9263d90 (unreliable)
[c0000004a9263da0] [c000000000799b90] shared_cede_loop+0x60/0x170
[c0000004a9263de0] [c0000000007974b4] cpuidle_enter_state+0xb4/0x380
[c0000004a9263e40] [c0000000000f5f84] call_cpuidle+0x44/0x80
[c0000004a9263e60] [c0000000000f64b0] cpu_startup_entry+0x380/0x450
[c0000004a9263f20] [c00000000003de94] start_secondary+0x304/0x350
[c0000004a9263f90] [c000000000008b6c] start_secondary_prolog+0x10/0x14
Instruction dump:
XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX
XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX
---[ end trace cc80130850d8e991 ]---

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
---
 arch/powerpc/net/bpf_jit.h      | 2 +-
 arch/powerpc/net/bpf_jit_comp.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index 889fd19..28b89ed 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -70,7 +70,7 @@ DECLARE_LOAD_FUNC(sk_load_half);
 DECLARE_LOAD_FUNC(sk_load_byte);
 DECLARE_LOAD_FUNC(sk_load_byte_msh);
 
-#ifdef CONFIG_PPC64
+#if defined(CONFIG_PPC64) && (!defined(_CALL_ELF) || _CALL_ELF != 2)
 #define FUNCTION_DESCR_SIZE	24
 #else
 #define FUNCTION_DESCR_SIZE	0
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 2d66a84..035b887 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -664,7 +664,7 @@ void bpf_jit_compile(struct bpf_prog *fp)
 
 	if (image) {
 		bpf_flush_icache(code_base, code_base + (proglen/4));
-#ifdef CONFIG_PPC64
+#if defined(CONFIG_PPC64) && (!defined(_CALL_ELF) || _CALL_ELF != 2)
 		/* Function descriptor nastiness: Address + TOC */
 		((u64 *)image)[0] = (u64)code_base;
 		((u64 *)image)[1] = local_paca->kernel_toc;
-- 
2.5.5
