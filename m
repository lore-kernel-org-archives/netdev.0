From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] bpf: make jited programs visible in traces
Date: Mon, 20 Feb 2017 11:05:32 -0800
Message-ID: <1487617532.1311.113.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1487279499.git.daniel@iogearbox.net>
         <36bb0882151c63dcf7c624f52bf92db8adbfb80a.1487279499.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ast@kernel.org,
        linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <36bb0882151c63dcf7c624f52bf92db8adbfb80a.1487279499.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-02-16 at 22:24 +0100, Daniel Borkmann wrote:
> Long standing issue with JITed programs is that stack traces from
> function tracing check whether a given address is kernel code
> through {__,}kernel_text_address(), which checks for code in core
> kernel, modules and dynamically allocated ftrace trampolines. But
> what is still missing is BPF JITed programs (interpreted programs
> are not an issue as __bpf_prog_run() will be attributed to them),
> thus when a stack trace is triggered, the code walking the stack
> won't see any of the JITed ones. The same for address correlation
> done from user space via reading /proc/kallsyms. This is read by
> tools like perf, but the latter is also useful for permanent live
> tracing with eBPF itself in combination with stack maps when other
> eBPF types are part of the callchain. See offwaketime example on
> dumping stack from a map.
> 
> This work tries to tackle that issue by making the addresses and
> symbols known to the kernel. The lookup from *kernel_text_address()
> is implemented through a latched RB tree that can be read under
> RCU in fast-path that is also shared for symbol/size/offset lookup
> for a specific given address in kallsyms. The slow-path iteration
> through all symbols in the seq file done via RCU list, which holds
> a tiny fraction of all exported ksyms, usually below 0.1 percent.
> Function symbols are exported as bpf_prog_<tag>, in order to aide
> debugging and attribution. This facility is currently enabled for
> root-only when bpf_jit_kallsyms is set to 1, and disabled if hardening
> is active in any mode. The rationale behind this is that still a lot
> of systems ship with world read permissions on kallsyms thus addresses
> should not get suddenly exposed for them. If that situation gets
> much better in future, we always have the option to change the
> default on this. Likewise, unprivileged programs are not allowed
> to add entries there either, but that is less of a concern as most
> such programs types relevant in this context are for root-only anyway.
> If enabled, call graphs and stack traces will then show a correct
> attribution; one example is illustrated below, where the trace is
> now visible in tooling such as perf script --kallsyms=/proc/kallsyms
> and friends.
> 
> Before:
> 
>   7fff8166889d bpf_clone_redirect+0x80007f0020ed (/lib/modules/4.9.0-rc8+/build/vmlinux)
>          f5d80 __sendmsg_nocancel+0xffff006451f1a007 (/usr/lib64/libc-2.18.so)
> 
> After:
> 
>   7fff816688b7 bpf_clone_redirect+0x80007f002107 (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fffa0575728 bpf_prog_33c45a467c9e061a+0x8000600020fb (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fffa07ef1fc cls_bpf_classify+0x8000600020dc (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff81678b68 tc_classify+0x80007f002078 (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff8164d40b __netif_receive_skb_core+0x80007f0025fb (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff8164d718 __netif_receive_skb+0x80007f002018 (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff8164e565 process_backlog+0x80007f002095 (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff8164dc71 net_rx_action+0x80007f002231 (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff81767461 __softirqentry_text_start+0x80007f0020d1 (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff817658ac do_softirq_own_stack+0x80007f00201c (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff810a2c20 do_softirq+0x80007f002050 (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff810a2cb5 __local_bh_enable_ip+0x80007f002085 (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff8168d452 ip_finish_output2+0x80007f002152 (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff8168ea3d ip_finish_output+0x80007f00217d (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff8168f2af ip_output+0x80007f00203f (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   [...]
>   7fff81005854 do_syscall_64+0x80007f002054 (/lib/modules/4.9.0-rc8+/build/vmlinux)
>   7fff817649eb return_from_SYSCALL_64+0x80007f002000 (/lib/modules/4.9.0-rc8+/build/vmlinux)
>          f5d80 __sendmsg_nocancel+0xffff01c484812007 (/usr/lib64/libc-2.18.so)
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> ---

Latest net-next tree dies on my hosts, and my bisection came to this
commit.

[   90.045546] BUG: unable to handle kernel paging request at
ffff881fef01a000^M
[   90.052535] IP: __tlb_remove_page_size+0x57/0x90^M
[   90.057152] PGD 2247067 ^M
[   90.057153] PUD 1fdaadc063 ^M
[   90.059691] PMD 1fefb0b063 ^M
[   90.062491] PTE 8000001fef01a161^M
[   90.065287] ^M
[   90.070011] Oops: 0003 [#1] SMP^M
[   90.073478] gsmi: Log Shutdown Reason 0x03^M
[   90.077584] Modules linked in: w1_therm wire cdc_acm ehci_pci
ehci_hcd mlx4_en ib_uverbs mlx4_ib ib_core mlx4_core^M
[   90.087972] CPU: 34 PID: 9747 Comm: sshd Not tainted 4.10.0-smp-DEV
#14^M
[   90.101580] task: ffff881fda56a300 task.stack: ffffc900337d4000^M
[   90.107515] RIP: 0010:__tlb_remove_page_size+0x57/0x90^M
[   90.112651] RSP: 0018:ffffc900337d7c98 EFLAGS: 00010202^M
[   90.117896] RAX: ffff881fef01a000 RBX: ffffc900337d7df8 RCX:
0000000000000001^M
[   90.125086] RDX: ffff880000000000 RSI: 0000000000000011 RDI:
ffff88207fffe4c0^M
[   90.132234] RBP: ffffc900337d7ca0 R08: 0000000000000010 R09:
ffffc900337d7bd8^M
[   90.139371] R10: 0000000000000020 R11: 0000000000000001 R12:
ffff881fda064520^M
[   90.146544] R13: ffffea00ffb28f40 R14: 00007f84584a5000 R15:
ffffc900337d7df8^M
[   90.153703] FS:  0000000000000000(0000) GS:ffff881fffd80000(0000)
knlGS:0000000000000000^M
[   90.161802] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033^M
[   90.167548] CR2: ffff881fef01a000 CR3: 0000000001c09000 CR4:
00000000001406e0^M
[   90.174680] Call Trace:^M
[   90.177144]  unmap_page_range+0x679/0x840^M
[   90.181154]  unmap_single_vma+0x7f/0xf0^M
[   90.184984]  unmap_vmas+0x4a/0xa0^M
[   90.188292]  exit_mmap+0xa2/0x160^M
[   90.191605]  mmput+0x3d/0x100^M[   90.194584]  do_exit+0x325/0xbc0^M
[   90.197810]  ? vfs_read+0x95/0x140^M
[   90.201230]  do_group_exit+0x49/0xc0^M
[   90.204818]  SyS_exit_group+0x14/0x20^M
[   90.208492]  entry_SYSCALL_64_fastpath+0x13/0x94^M
[   90.213127] RIP: 0033:0x7f8457b10279^M
[   90.216723] RSP: 002b:00007ffef283a8f0 EFLAGS: 00000246 ORIG_RAX:
00000000000000e7^M
[   90.224286] RAX: ffffffffffffffda RBX: 000055692c599640 RCX:
00007f8457b10279^M
[   90.231432] RDX: 0000000000000000 RSI: 00000000000000ff RDI:
00000000000000ff^M
[   90.238575] RBP: 00007ffef283a9f0 R08: 000000000000003c R09:
00000000000000e7^M
[   90.245728] R10: ffffffffffffff90 R11: 0000000000000246 R12:
000055692c599640^M
[   90.252875] R13: 0000000000002614 R14: 000000000000ac60 R15:
00007ffef283aa90^M
[   90.260018] Code: 89 47 20 31 c0 c3 83 7f 78 13 74 45 55 53 31 f6
48 89 fb bf 00 02 00 01 48 8d 6c 24 08 e8 c2 05 fd ff 48 85 c0 74 30
83 43 78 01 <48> c7 00 00 00 00 00 c7 40 08 00 00 00 00 c7 40 0c fe 01
00 00 ^M
[   90.278939] RIP: __tlb_remove_page_size+0x57/0x90 RSP:
ffffc900337d7c98^M
[   90.285550] CR2: ffff881fef01a000^M
