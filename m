From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: sctp: kernel memory overwrite attempt detected in
 sctp_getsockopt_assoc_stats
Date: Sun, 15 Jan 2017 15:35:15 -0500
Message-ID: <20170115203515.GA6274@neilslaptop.think-freely.org>
References: <CACT4Y+ZDPa+spEh6P_ip9=hsNfeZ8KJfwJu5jTrPKVkGJUaZSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vladislav Yasevich <vyasevich@gmail.com>,
        David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Kees Cook <keescook@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZDPa+spEh6P_ip9=hsNfeZ8KJfwJu5jTrPKVkGJUaZSg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 15, 2017 at 06:29:59PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> I've enabled CONFIG_HARDENED_USERCOPY_PAGESPAN on syzkaller fuzzer and
> now I am seeing lots of:
> 
If I'm not mistaken, its because thats specifically what that option does.  From
the Kconfig:
onfig HARDENED_USERCOPY_PAGESPAN
        bool "Refuse to copy allocations that span multiple pages"
        depends on HARDENED_USERCOPY
        depends on EXPERT
        help
          When a multi-page allocation is done without __GFP_COMP,
          hardened usercopy will reject attempts to copy it. There are,
          however, several cases of this in the kernel that have not all
          been removed. This config is intended to be used only while
          trying to find such users.

So, if the fuzzer does a setsockopt and the data it passes crosses a page
boundary, it seems like this will get triggered.  Based on the fact that its
only used to find users that do this, it seems like not the sort of thing that
you want enabled while running a fuzzer that might do it arbitrarily.

Regards
Neil


> usercopy: kernel memory overwrite attempt detected to ffff8801a74f6f10
> (<spans multiple pages>) (256 bytes)
> 
> kernel BUG at mm/usercopy.c:75!
> invalid opcode: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 1 PID: 15686 Comm: syz-executor3 Not tainted 4.9.0 #1
> Hardware name: Google Google Compute Engine/Google Compute Engine,
> BIOS Google 01/01/2011
> task: ffff8801c89b2500 task.stack: ffff8801a74f0000
> RIP: 0010:[<ffffffff81a1b041>]  [<ffffffff81a1b041>] report_usercopy
> mm/usercopy.c:67 [inline]
> RIP: 0010:[<ffffffff81a1b041>]  [<ffffffff81a1b041>]
> __check_object_size+0x2d1/0x9ec mm/usercopy.c:278
> RSP: 0018:ffff8801a74f6cd0  EFLAGS: 00010286
> RAX: 000000000000006b RBX: ffffffff84500120 RCX: 0000000000000000
> RDX: 000000000000006b RSI: ffffffff815a7791 RDI: ffffed0034e9ed8c
> RBP: ffff8801a74f6e48 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000001 R12: ffff8801a74f6f10
> R13: 0000000000000100 R14: ffffffff845000e0 R15: ffff8801a74f700f
> FS:  00007f80918de700(0000) GS:ffff8801dc100000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020058ffc CR3: 00000001cc1cc000 CR4: 00000000001406e0
> Stack:
>  ffffffff8598fcc8 0000000000000000 000077ff80000000 ffffea0005c99608
>  ffffffff844fff40 ffffffff844fff40 0000000041b58ab3 ffffffff84ae0fa0
>  ffffffff81a1ad70 ffff8801c89b2500 dead000000000100 ffffffff814d4425
> Call Trace:
>  [<ffffffff83e4ece9>] check_object_size include/linux/thread_info.h:129 [inline]
>  [<ffffffff83e4ece9>] copy_from_user arch/x86/include/asm/uaccess.h:692 [inline]
>  [<ffffffff83e4ece9>] sctp_getsockopt_assoc_stats+0x169/0xa10
> net/sctp/socket.c:6182
>  [<ffffffff83e5cc52>] sctp_getsockopt+0x1af2/0x66a0 net/sctp/socket.c:6556
>  [<ffffffff834f92c5>] sock_common_getsockopt+0x95/0xd0 net/core/sock.c:2649
>  [<ffffffff834f4910>] SYSC_getsockopt net/socket.c:1788 [inline]
>  [<ffffffff834f4910>] SyS_getsockopt+0x240/0x380 net/socket.c:1770
>  [<ffffffff81009798>] do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:280
>  [<ffffffff84370a49>] entry_SYSCALL64_slow_path+0x25/0x25
> Code: b0 fe ff ff e8 e1 25 ce ff 48 8b 85 b0 fe ff ff 4d 89 e9 4c 89
> e1 4c 89 f2 48 89 de 48 c7 c7 a0 01 50 84 49 89 c0 e8 51 d9 e0 ff <0f>
> 0b e8 b8 25 ce ff 4c 89 f2 4c 89 ee 4c 89 e7 e8 6a 1b fc ff
> RIP  [<ffffffff81a1b041>] report_usercopy mm/usercopy.c:67 [inline]
> RIP  [<ffffffff81a1b041>] __check_object_size+0x2d1/0x9ec mm/usercopy.c:278
>  RSP <ffff8801a74f6cd0>
> ---[ end trace 5e438996b2c0b35d ]---
> 
> 
> I am not sure why check_object_size flags this an a bug,
> copy_from_user copies into a stack object:
> 
> static int sctp_getsockopt_assoc_stats(struct sock *sk, int len,
>                                        char __user *optval,
>                                        int __user *optlen)
> {
>         struct sctp_assoc_stats sas;
>         len = min_t(size_t, len, sizeof(sas));
>         if (copy_from_user(&sas, optval, len))
>                 return -EFAULT;
> 
> Kees, can this be a false positive?
> 
> On commit f4d3935e4f4884ba80561db5549394afb8eef8f7.
> 
