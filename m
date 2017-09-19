From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: do not disable/enable BH in bpf_map_free_id()
Date: Tue, 19 Sep 2017 22:51:36 +0200
Message-ID: <59C18358.3080608@iogearbox.net>
References: <1505837759.29839.64.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>,
        Alexei Starovoitov <ast@kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57414 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751521AbdISUvl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 16:51:41 -0400
In-Reply-To: <1505837759.29839.64.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2017 06:15 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> syzkaller reported following splat [1]
>
> Since hard irq are disabled by the caller, bpf_map_free_id()
> should not try to enable/disable BH.
>
> Another solution would be to change htab_map_delete_elem() to
> defer the free_htab_elem() call after
> raw_spin_unlock_irqrestore(&b->lock, flags), but this might be not
> enough to cover other code paths.
>
> [1]
> WARNING: CPU: 1 PID: 8052 at kernel/softirq.c:161 __local_bh_enable_ip
> +0x1e/0x160 kernel/softirq.c:161
> Kernel panic - not syncing: panic_on_warn set ...
>
> CPU: 1 PID: 8052 Comm: syz-executor1 Not tainted 4.13.0-next-20170915+
> #23
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>   __dump_stack lib/dump_stack.c:16 [inline]
>   dump_stack+0x194/0x257 lib/dump_stack.c:52
>   panic+0x1e4/0x417 kernel/panic.c:181
>   __warn+0x1c4/0x1d9 kernel/panic.c:542
>   report_bug+0x211/0x2d0 lib/bug.c:183
>   fixup_bug+0x40/0x90 arch/x86/kernel/traps.c:178
>   do_trap_no_signal arch/x86/kernel/traps.c:212 [inline]
>   do_trap+0x260/0x390 arch/x86/kernel/traps.c:261
>   do_error_trap+0x120/0x390 arch/x86/kernel/traps.c:298
>   do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:311
>   invalid_op+0x18/0x20 arch/x86/entry/entry_64.S:905
> RIP: 0010:__local_bh_enable_ip+0x1e/0x160 kernel/softirq.c:161
> RSP: 0018:ffff8801cdcd7748 EFLAGS: 00010046
> RAX: 0000000000000082 RBX: 0000000000000201 RCX: 0000000000000000
> RDX: 1ffffffff0b5933c RSI: 0000000000000201 RDI: ffffffff85ac99e0
> RBP: ffff8801cdcd7758 R08: ffffffff85b87158 R09: 1ffff10039b9aec6
> R10: ffff8801c99f24c0 R11: 0000000000000002 R12: ffffffff817b0b47
> R13: dffffc0000000000 R14: ffff8801cdcd77e8 R15: 0000000000000001
>   __raw_spin_unlock_bh include/linux/spinlock_api_smp.h:176 [inline]
>   _raw_spin_unlock_bh+0x30/0x40 kernel/locking/spinlock.c:207
>   spin_unlock_bh include/linux/spinlock.h:361 [inline]
>   bpf_map_free_id kernel/bpf/syscall.c:197 [inline]
>   __bpf_map_put+0x267/0x320 kernel/bpf/syscall.c:227
>   bpf_map_put+0x1a/0x20 kernel/bpf/syscall.c:235
>   bpf_map_fd_put_ptr+0x15/0x20 kernel/bpf/map_in_map.c:96
>   free_htab_elem+0xc3/0x1b0 kernel/bpf/hashtab.c:658
>   htab_map_delete_elem+0x74d/0x970 kernel/bpf/hashtab.c:1063
>   map_delete_elem kernel/bpf/syscall.c:633 [inline]
>   SYSC_bpf kernel/bpf/syscall.c:1479 [inline]
>   SyS_bpf+0x2188/0x46a0 kernel/bpf/syscall.c:1451
>   entry_SYSCALL_64_fastpath+0x1f/0xbe
>
> Fixes: f3f1c054c288 ("bpf: Introduce bpf_map ID")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Martin KaFai Lau <kafai@fb.com>

Thanks for the fix, Eric!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
