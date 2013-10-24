From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Deadlock in BPF JIT functions when running upowerd?
Date: Wed, 23 Oct 2013 23:25:13 -0700
Message-ID: <1382595913.7572.40.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131024011734.GA14083@birch.djwong.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131024011734.GA14083@birch.djwong.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-23 at 18:17 -0700, Darrick J. Wong wrote:
> Hi,
> 
> I've been observing a softlockup with 3.11.6 and 3.12-rc6.  It looks like
> there's a deadlock occurring on purge_lock in __purge_vmap_area_lazy().  In
> short, the BPF JIT code has been changed[1] to call set_memory_r[ow]() when
> compiling and freeing JIT bytecode memory.  It seems that it's possible for
> upowerd to be compiling some BPF program and call __purge_vmap_area_lazy, then
> the timer interrupt comes in (due to the IPI?) and a softirq calls
> bpf_jit_free, which also calls __purge_vmap_area_lazy.
> 
> I'm not really sure who's at fault here--is this a BPF bug?
> 
> [1] 314beb9bcabfd6b4542ccbced2402af2c6f6142a
>     "x86: bpf_jit_comp: secure bpf jit against spraying attacks"
> 
> --D
> 
> Here's what 3.11.6 spits out; the 3.12-rc6 message has the same traceback.
> 
> [   52.370437] BUG: soft lockup - CPU#3 stuck for 22s! [upowerd:8359]
> [   52.370440] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat_ipv4 xt_conntrack xt_CHECKSUM iptable_mangle fuse tun microcode nfsd nfs_acl exportfs auth_rpcgss nfs lockd sunrpc af_packet xt_physdev xt_hl ip6t_rt nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT xt_sctp xt_limit xt_tcpudp xt_addrtype nf_conntrack_ipv4 nf_defrag_ipv4 xt_state ip6table_filter ip6_tables nf_conntrack_netbios_ns nf_conntrack_broadcast nf_nat_ftp nf_nat nf_conntrack_ftp nf_conntrack iptable_filter ip_tables x_tables sch_fq_codel bridge stp llc lpc_ich mfd_core loop bcache dm_crypt zlib_deflate libcrc32c firewire_ohci firewire_core usb_storage mpt2sas scsi_transport_sas raid_class
> [   52.370471] CPU: 3 PID: 8359 Comm: upowerd Not tainted 3.11.6-60-flax #1
> [   52.370472] Hardware name: OEM OEM/131-GT-E767, BIOS 6.00 PG 08/25/2011
> [   52.370474] task: ffff8806621f9700 ti: ffff88064b6a0000 task.ti: ffff88064b6a0000
> [   52.370475] RIP: 0010:[<ffffffff816b5a22>]  [<ffffffff816b5a22>] _raw_spin_lock+0x32/0x40
> [   52.370480] RSP: 0018:ffff88067fc63c10  EFLAGS: 00000297
> [   52.370481] RAX: 0000000000000061 RBX: ffff88065a318600 RCX: 0000000000000000
> [   52.370483] RDX: 0000000000000062 RSI: ffff88067fc63ce0 RDI: ffffffff81ea42bc
> [   52.370484] RBP: ffff88067fc63c10 R08: ffffffff81cdd608 R09: 0000000000000000
> [   52.370485] R10: ffff88067fc6d8e0 R11: 0000000000000000 R12: ffff88067fc63b88
> [   52.370486] R13: ffffffff816b7a47 R14: ffff88067fc63c10 R15: ffff88067fc63cd8
> [   52.370487] FS:  00007f55fff297c0(0000) GS:ffff88067fc60000(0000) knlGS:0000000000000000
> [   52.370488] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   52.370489] CR2: 00007f55fff47000 CR3: 000000065dd10000 CR4: 00000000000007e0
> [   52.370490] Stack:
> [   52.370491]  ffff88067fc63cb0 ffffffff811955fd 0000000000000096 0000000000000347
> [   52.370494]  00000000000003c1 0000000000000001 0000000000000000 0000000000000000
> [   52.370496]  0000000000000033 ffff88067fc63c58 ffff88067fc63c58 0000000000000001
> [   52.370499] Call Trace:
> [   52.370500]  <IRQ> 
> [   52.370501]  [<ffffffff811955fd>] __purge_vmap_area_lazy+0x12d/0x4c0
> [   52.370507]  [<ffffffff8119612c>] vm_unmap_aliases+0x17c/0x190
> [   52.370512]  [<ffffffff81079814>] change_page_attr_set_clr+0xb4/0x4a0
> [   52.370516]  [<ffffffff810a927e>] ? irq_exit+0x7e/0xb0
> [   52.370519]  [<ffffffff81048e44>] ? smp_irq_work_interrupt+0x34/0x40
> [   52.370522]  [<ffffffff81079d8f>] set_memory_rw+0x2f/0x40
> [   52.370525]  [<ffffffff810a0a7c>] bpf_jit_free+0x2c/0x40
> [   52.370528]  [<ffffffff815f48aa>] sk_filter_release_rcu+0x1a/0x30
> [   52.370532]  [<ffffffff811262d2>] rcu_process_callbacks+0x1e2/0x5b0
> [   52.370535]  [<ffffffff810c9999>] ? enqueue_hrtimer+0x39/0xf0
> [   52.370537]  [<ffffffff810a8f20>] __do_softirq+0xe0/0x2f0
> [   52.370541]  [<ffffffff816b851c>] call_softirq+0x1c/0x30
> [   52.370543]  [<ffffffff81046155>] do_softirq+0x55/0x90
> [   52.370545]  [<ffffffff810a928e>] irq_exit+0x8e/0xb0
> [   52.370547]  [<ffffffff816b8b0a>] smp_apic_timer_interrupt+0x4a/0x60
> [   52.370549]  [<ffffffff816b7a47>] apic_timer_interrupt+0x67/0x70
> [   52.370550]  <EOI> 
> [   52.370552]  [<ffffffff8106eeb4>] ? default_send_IPI_mask_allbutself_phys+0xb4/0xe0
> [   52.370559]  [<ffffffff81188af7>] ? handle_pte_fault+0x567/0x920
> [   52.370561]  [<ffffffff8107cf30>] ? rbt_memtype_copy_nth_element+0xc0/0xc0
> [   52.370563]  [<ffffffff81072057>] physflat_send_IPI_allbutself+0x17/0x20
> [   52.370566]  [<ffffffff8106a992>] native_send_call_func_ipi+0x72/0x80
> [   52.370568]  [<ffffffff8107cf30>] ? rbt_memtype_copy_nth_element+0xc0/0xc0
> [   52.370570]  [<ffffffff81105834>] smp_call_function_many+0x1f4/0x290
> [   52.370572]  [<ffffffff81105a8a>] smp_call_function+0x3a/0x60
> [   52.370574]  [<ffffffff8107cf30>] ? rbt_memtype_copy_nth_element+0xc0/0xc0
> [   52.370576]  [<ffffffff81105b18>] on_each_cpu+0x38/0x80
> [   52.370578]  [<ffffffff8107d59d>] flush_tlb_kernel_range+0x6d/0x70
> [   52.370581]  [<ffffffff81195916>] __purge_vmap_area_lazy+0x446/0x4c0
> [   52.370584]  [<ffffffff81228e85>] ? ext4_file_open+0x75/0x1b0
> [   52.370586]  [<ffffffff8119612c>] vm_unmap_aliases+0x17c/0x190
> [   52.370590]  [<ffffffff81079814>] change_page_attr_set_clr+0xb4/0x4a0
> [   52.370592]  [<ffffffff81196ac2>] ? map_vm_area+0x32/0x50
> [   52.370595]  [<ffffffff81197761>] ? __vmalloc_node_range+0x121/0x1f0
> [   52.370597]  [<ffffffff810a08ab>] ? bpf_jit_compile+0x105b/0x1200
> [   52.370600]  [<ffffffff81079d4f>] set_memory_ro+0x2f/0x40
> [   52.370602]  [<ffffffff810744ca>] ? module_alloc+0x5a/0x60
> [   52.370604]  [<ffffffff810a081c>] bpf_jit_compile+0xfcc/0x1200
> [   52.370607]  [<ffffffff811aa75b>] ? __kmalloc+0x18b/0x1f0
> [   52.370610]  [<ffffffff811aa606>] ? __kmalloc+0x36/0x1f0
> [   52.370612]  [<ffffffff815f4b43>] ? sk_chk_filter+0x283/0x390
> [   52.370614]  [<ffffffff815f4d4b>] sk_attach_filter+0xfb/0x1b0
> [   52.370617]  [<ffffffff815d071d>] sock_setsockopt+0x4fd/0x900
> [   52.370620]  [<ffffffff811d2342>] ? fget_light+0x92/0x100
> [   52.370623]  [<ffffffff815cbdd6>] SyS_setsockopt+0xc6/0xd0
> [   52.370625]  [<ffffffff816b6dc6>] system_call_fastpath+0x1a/0x1f
> [   52.370626] Code: 89 e5 65 48 8b 04 25 f0 b8 00 00 83 80 44 e0 ff ff 01 b8 00 01 00 00 f0 66 0f c1 07 0f b6 d4 38 c2 74 0f 66 0f 1f 44 00 00 f3 90 <0f> b6 07 38 d0 75 f7 5d c3 0f 1f 44 00 00 66 66 66 66 90 55 48 

Could you try latest tree, as it includes :

commit d45ed4a4e33ae103053c0a53d280014e7101bb5c
Author: Alexei Starovoitov <ast@plumgrid.com>
Date:   Fri Oct 4 00:14:06 2013 -0700

    net: fix unsafe set_memory_rw from softirq
    


Thanks !
