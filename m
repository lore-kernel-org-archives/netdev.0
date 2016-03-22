From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/sctp: stack-out-of-bounds in sctp_getsockopt
Date: Tue, 22 Mar 2016 08:21:28 -0700
Message-ID: <1458660088.10868.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <56f16034.890c620a.e04dc.ffffc770@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Baozeng Ding <sploving1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34417 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbcCVPVc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 11:21:32 -0400
In-Reply-To: <56f16034.890c620a.e04dc.ffffc770@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-22 at 23:08 +0800, Baozeng Ding wrote:
> Hi all,
> 
> The following program triggers an out-of-bounds bug in
> sctp_getsockopt. The kernel version is 4.5 (on Mar 16
> commit 09fd671ccb2475436bd5f597f751ca4a7d177aea). 
> 
> ==================================================================
> BUG: KASAN: stack-out-of-bounds in string+0x1ef/0x200 at addr
> ffff88003ae679e0
> Read of size 1 by task syz-executor/19753
> page:ffffea0000eb99c0 count:0 mapcount:0 mapping:          (null)
> index:0x0
> flags: 0x1fffc0000000000()
> page dumped because: kasan: bad access detected
> CPU: 3 PID: 19753 Comm: syz-executor Not tainted 4.5.0+ #8
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
>  0000000000000003 ffff88003ae67578 ffffffff82945051 ffff88003ae67608
>  ffff88003ae679e0 0000000000000096 dffffc0000000000 ffff88003ae675f8
>  ffffffff81709f88 000000000000030d 0000000000000000 0000000000000286
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff82945051>] dump_stack+0xb3/0x112 lib/dump_stack.c:51
>  [<     inline     >] print_address_description mm/kasan/report.c:150
>  [<ffffffff81709f88>] kasan_report_error+0x4f8/0x530 mm/kasan/report.c:236
>  [<ffffffff8140785b>] ? __lock_acquire+0x15fb/0x5dd0 kernel/locking/lockdep.c:3226
>  [<     inline     >] kasan_report mm/kasan/report.c:259
>  [<ffffffff81709ffe>] __asan_report_load1_noabort+0x3e/0x40 mm/kasan/report.c:277
>  [<ffffffff8296613f>] ? string+0x1ef/0x200 lib/vsprintf.c:591
>  [<ffffffff8296613f>] string+0x1ef/0x200 lib/vsprintf.c:591
>  [<ffffffff8296f103>] vsnprintf+0xb83/0x1900 lib/vsprintf.c:2049
>  [<ffffffff8296e580>] ? pointer+0xab0/0xab0 lib/vsprintf.c:1584
>  [<ffffffff813456f2>] __request_module+0x132/0x6b0 kernel/kmod.c:146
>  [<ffffffff814056b0>] ? mark_held_locks+0xd0/0x130 kernel/locking/lockdep.c:2552
>  [<ffffffff813455c0>] ? call_usermodehelper_setup+0x2b0/0x2b0 kernel/kmod.c:530
>  [<ffffffff85da47b0>] ? mutex_lock_interruptible_nested+0x980/0x980
>  [<ffffffff8168fed4>] ? __might_fault+0xe4/0x1d0 mm/memory.c:3833
>  [<ffffffff8538f74c>] find_inlist_lock.constprop.17+0x10c/0x210 net/bridge/netfilter/ebtables.c:347
>  [<     inline     >] find_table_lock net/bridge/netfilter/ebtables.c:356
>  [<ffffffff853904ab>] do_ebt_get_ctl+0x13b/0x540 net/bridge/netfilter/ebtables.c:1524
>  [<ffffffff85390370>] ? copy_everything_to_user+0x600/0x600 net/bridge/netfilter/ebtables.c:1455
>  [<     inline     >] ? __mutex_unlock_common_slowpath kernel/locking/mutex.c:751
>  [<ffffffff85da6799>] ? __mutex_unlock_slowpath+0x239/0x3f0 kernel/locking/mutex.c:762
>  [<ffffffff85da6959>] ? mutex_unlock+0x9/0x10 kernel/locking/mutex.c:437
>  [<ffffffff84dea126>] ? nf_sockopt_find+0x1a6/0x220 net/netfilter/nf_sockopt.c:87
>  [<     inline     >] nf_sockopt net/netfilter/nf_sockopt.c:103
>  [<ffffffff84dea20d>] nf_getsockopt+0x6d/0xc0 net/netfilter/nf_sockopt.c:121
>  [<ffffffff84fadf05>] ip_getsockopt+0x135/0x190 net/ipv4/ip_sockglue.c:1523
>  [<ffffffff84faddd0>] ? do_ip_getsockopt+0x1520/0x1520 net/ipv4/ip_sockglue.c:1353
>  [<     inline     >] ? wake_up_process kernel/sched/core.c:2024
>  [<ffffffff8138bcc2>] ? wake_up_q+0x82/0xe0 kernel/sched/core.c:416
>  [<     inline     >] ? atomic_dec_and_test /arch/x86/include/asm/atomic.h:117
>  [<     inline     >] ? mmdrop include/linux/sched.h:2611
>  [<ffffffff814a3310>] ? drop_futex_key_refs.isra.13+0x70/0xe0 kernel/futex.c:444
>  [<ffffffff8583a4dd>] sctp_getsockopt+0x18d/0x3f40 net/sctp/socket.c:5964
>  [<ffffffff8140785b>] ? __lock_acquire+0x15fb/0x5dd0 kernel/locking/lockdep.c:3226
>  [<ffffffff8583a350>] ? sctp_do_peeloff+0x2b0/0x2b0 net/sctp/socket.c:4434
>  [<ffffffff81406260>] ? debug_check_no_locks_freed+0x290/0x290 kernel/locking/lockdep.c:4104
>  [<     inline     >] ? rcu_read_unlock include/linux/rcupdate.h:922
>  [<ffffffff817b398c>] ? __fget+0x20c/0x3b0 fs/file.c:712
>  [<     inline     >] ? rcu_lock_release include/linux/rcupdate.h:491
>  [<     inline     >] ? rcu_read_unlock include/linux/rcupdate.h:926
>  [<ffffffff817b39b5>] ? __fget+0x235/0x3b0 fs/file.c:712
>  [<ffffffff817b37c7>] ? __fget+0x47/0x3b0 fs/file.c:696
>  [<ffffffff817b3c11>] ? __fget_light+0xa1/0x1f0 fs/file.c:759
>  [<ffffffff84c3a695>] sock_common_getsockopt+0x95/0xd0 net/core/sock.c:2579
>  [<     inline     >] SYSC_getsockopt net/socket.c:1783
>  [<ffffffff84c37e12>] SyS_getsockopt+0x142/0x230 net/socket.c:1765
>  [<ffffffff84c37cd0>] ? SyS_setsockopt+0x240/0x240 net/socket.c:1752
>  [<ffffffff85dab922>] ? entry_SYSCALL_64_fastpath+0x5/0xc1 arch/x86/entry/entry_64.S:191
>  [<ffffffff81003017>] ? trace_hardirqs_on_thunk+0x17/0x19 arch/x86/entry/thunk_64.S:39
>  [<ffffffff85dab940>] entry_SYSCALL_64_fastpath+0x23/0xc1 arch/x86/entry/entry_64.S:207
> Memory state around the buggy address:
>  ffff88003ae67880: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  ffff88003ae67900: 00 f1 f1 f1 f1 04 f4 f4 f4 f2 f2 f2 f2 00 00 00
> >ffff88003ae67980: 00 00 00 00 00 00 00 00 00 00 00 00 f4 f3 f3 f3
>                                                        ^
>  ffff88003ae67a00: f3 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  ffff88003ae67a80: f1 f1 f1 f1 04 f4 f4 f4 f3 f3 f3 f3 00 00 00 00
> ==================================================================
> 
> #include <unistd.h>
> #include <sys/syscall.h>
> #include <netinet/in.h>
> #include <string.h>
> #include <stdint.h>
> #include <sys/mman.h>
> #include <sys/socket.h>
> 
> int main()
> {
>         int sock = 0;
>         int sock_dup = 0;
>         mmap((void *)0x20000000ul, 0x5000ul, PROT_READ|PROT_WRITE,
> MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0);
>         sock = socket(AF_INET, SOCK_STREAM, IPPROTO_SCTP);
>         sock_dup = dup(sock);
>         memcpy((void*)0x20000bf3,"\xac\x71\x93\x68\x02\xb3\xd1\x86\x52\xf1\xf0\x18\x09\x56\xc6\x98\x6f\x8e\x74\xb7\x17\xd4\x3a\x64\x51\x68\x13\x2d\x25\xba\x6d\x3f\x74\x68\x84\x89\x04\xd1\xa6\xe2\x7d\xaf\xfa\xd9\xce\x52\xbe\x6f\xb6\xe3\xff\x92\x35\xa1\x88\x4a\x68\x27\xaa\x25\xf8\xc1\xd5\x3b\xe5\x69\x11\x4f\x75\x4c\xe9\xff\x8b\x86\x53\x20\xb7\x10\xa2\x62\xcc\xc3\x06\x85\xde\x3e\x1c\x5a\x62\x3a\x2d\x0d\x0b\x0c\xb2\xac\x75\x42\x4d\x82\x3f\x7b\xf7\x28\xea\x2d\xff\x42\xa8\xdf\xb3\x49\x1a\xfd\xae\x2c\xd4\x35\x8e\x96\xb3\xe1\x0a\x92\x56\xb7\xde\xe8\x9e\xc3\x9e\x88\x79\xc4\x71\x46\x27\xf4\x9e\x85\xf4\x8f\x1f\x9a\xe5\x7e\x02\x09\x34\x80\x1e\x87\xa8\x9a\xce\xac\xfb\x43\x07\xdf\x15\xe8\x71\x9a\xa3\x80\x18\x1b\x15\xbd\x57\xb6\xc1\x73\x6e\xb1\x28\x3a\x01\xd5\x8e\x15\x85\xbd\x52\xdf\xfa\x64\xaa\x13\x0e
 \x2f\x64\x05\x11\xce\x79\x8b\xa8\x02\x29\x7f\x72\x0f\x37\x89\xb4\x54\x0b\x09\x02\x75\xc2\x8e\xd7\xcd\x7e\xfb\x4f\x72\xf1\x47\xea\xa2\x2a\xc3\xc4\xe9\x70\xfe\xa5\x80\x88\x21\x33\xcf\x13\x66\x98\x23\x10\x5c\xa4\xbd\xee\xc0\xb4\xdd\xfb\xff\xf2\x38\xab\xca\x36\x62\x35\x84\xe4\x73\x5c\xc7\x3e\x72\x2e\x17\x43\x6f\x85\x45\x4f\x82\x62\x0d\x77\xae\xcb\xe1\x8f\xe8\xf0\x84\x3e\x62\x8b\x70\x2b\x55\xb5\xa7\x13\xcf\xa1\x78\x77\x82\xe2\xb7\x1c\x65\x7f\xb5\x79\x73\x01\x07\xd1\x9f\x45\x6a\xbb\x3d\xbf\xc8\x71\x5b\x9f\x30\xc7\xb9\xb8\x53\x9f\xe1\xba\xb6\x78\x9e\x05\x75\xa3\x55\xb1\x26\x96\xa9\xb2\x82\xce\x81\x5c\x8a\x18\xb3\x4b\x0c\x18\x8c\xf2\x7c\x09\xde\xcb\xcf\x78\x22\x58\xf6\x15\xf6\xf7\x48\xda\x08\x75\xd4\xc1\x20\xc3\x18\x2e\x89\xe8\x5b\x48\xd9\xbc\x1f\xbb\xed\x31\xaf\x12\x4d\xcd\x46\x60\xa0\xef\x0e\x
 2e\x21\x1d\x2b\x68\x75\xb9\x42\x5e\xd7\xae\x35\x46\xe9\x06\x63\x1d\x3c\xd6\x9c\x14\x3b\x09\x29\x49\x70\xb9\xe1\xe0\x09\x45\x41\x62\x0c\xff\x5a\x77\xbe\x31\xa6\x03\x94\x92\xde\x41\x99\xfa\x68\x99\x74\xbb\x0a\x3d\xac\x9c\x7e\x00\x6b\xcd\xc1\x83\xa7\xc5\x63\xdd\x10\xea\x59\x27\xdc\x02\x98\xd6\x43\x20\x24\x4e\xc0\xdc\xa2\x98\xdf\x3e\xaf\x61\x35\xa0\x95\x3f\x9a\xaa\x7d\xe9\xe9\x0d\xe5\x97\x66\x1a\x9f\xbf\x56\xc8\x37\x84\x18\x2b\xd2\xcd\xd6\xb3\x19\xd8\x4a\x30\x6e\xcb\x99\x1c\xe9\x0f\xdb\xca\x30\xe1\xe2\x90\xba\xb9\x61\x00\xbf\xeb\xad\x6a\xc8\x52\xea\x1a\x92\x05\x0c\x3b\x78\x82\x01\xac\xfd\x88\x6c\xca\xe2\xfb\xe7\x0f\xcc\x75\x9c\x98\x12\x26\xcf\xa6\x80\x02\x35\xdf\x6e\xe1\x11\x1d\xa7\x30\x17\x38\x41\xd9\x81\x55\x1a\x1e\xd1\xfe\x60\xbf\xef\x09\x25\xc0\xdb\x9f\xc4\xc6\x54\x1a\x85\x36\x85\x05\xb3
 \x9f\x2c\xc5\xcd\x12\x51\xef\xbe\x10\x79\xbf\x11\x00\x47\x0d\x9c\x14\x43\x1a\x46\xea\xd1\x34\x2e\x10\x6b\xa4\x3c\x25\x21\xe3\xb9\x15\x78\x6c\x40\x87\x90\xf7\x93\x5a\x66\x5f\x0a\x76\xff\xc2\xe2\x14\x35\x88\x47\xa1\x33\x5b\x8f\x3d\xc5\x89\xb7\xf9\x8a\x40\xf0\x1e\xc9\x30\xcd\xd8\x96\x41\x78\x58\x97\x49\xc8\x50\x61\x36\x8f\x7e\x44\x41\xc0\x84\xbb\x35\xf0\x63\xa9\xc2\x2a\xbd\xcc\x4b\xab\x8b\x16\x33\xc0\x66\xbf\x47\x62\x9b\xc4\x47\x2d\x68\x83\xca\xe3\x52\x79\xd7\xe0\x61\x80\x15\xf1\x90\x83\xa2\xbb\x4c\xe5\x8b\x50\xc8\x1b\x68\x7b\xee\x57\xdc\x54\xfa\x90\xf1\xf5\xec\x7d\x93\xe0\x80\x74\x06\xbe\xac\xc8\x85\x4d\xe8\xbf\xd3\xdd\x34\x55\xc4\xbf\x2f\x24\x19\xad\x86\x1e\x69\x2b\x6c\x3f\x00\xe8\x4b\xbb\x99\xcf\x17\x99\x00\x9d\x6c\x70\x57\xcc\x35\xee\x07\x87\x25\x8c\x0c\x8b\x9b\x38\x15\xcc\x05\x6f\xf8\x
 16\x78\x0b\x41\xfa\x23\x96\xc0\x79\xf8\xb7\xf0\x2b\x60\x7e\x98\xe3\x7b\xab\x80\x1f\x0d\xbf\xf6\x7e\x37\x06\xf1\x11\x42\x38\x2a\x70\xdf\xa4\xca\xf5\xf3\xf4\x7d\xca\x10\x0c\xd5\xe2\x90\xa0\x15\xde\xc2\x61\xa2\x88\xea\x32\x37\x97\x83\xd0\x4c\xad\xe2\xae\x9b\x53\xa2\xc2\x54\x0c\xbd\xe1\x50\x3b\x15\xd4\xb1\xa9\x41\x6e\x18\x2e\x30\x3f\x91\x03\x81\x86\x8c\x5c\x1f\x76\x51\x92\xf5\xb5\xb2\xc3\x16\x01\xef\xe3\x9e\xb1\x92\x0e\x0e\xcb\x20\x7f\x10\x29\x08\x6e\x15\x3d\x1e\x7c\x70\xf5\xb5\x3c\x56\x15\x3c\x59\xe6\xe7\x9e\x16\xcd\xfc\x8e\xfa\x12\x99\xbb\x07\xaa\xd7\x1c\xd0\xae\x93\x4c\xba\x16\x5d\x0c\xed\x1d\x02\x87\xcd\x38\x31\xc6\x10\x42\xe1\x46\x4e\xa3\xae\xb6\xda\xb6\xb0\x49\x55\x89\x57\xe6\xac\xe3\xbf\xb5\x5c\x59\x93\x0d\x21\x35\xdd\x57\x8c\x04\x15\x91\x05\x69\x4a\xdb\x5e\xcb\x4d\xa3\x5d\xa8\x7e\x95
 \x9e\x9d\x95\x61\xc9\x1c\xdd\x66\x0a\x76\x18\xbb\x59\x6a\xa5\xc0\xf2\xb8\x2f\xa9\x4c\xa8\xb3\x2b\xa3\x8a\xbf\x5c\xe8\x18\x3d\x7f\x0e\x2f\xe9\x06\xf9\xb6\xcc\x60\xcc\x38\x6c\x9a\x78\xa7\x7c\x61",
> 1037);
>         getsockopt(sock_dup, IPPROTO_IP, 0x81,  (void *)0x20000bf3ul,
> (socklen_t *)0x20003000ul);        
>         return 0;
> }
> 
> Best Regards,
> 
> Baozeng Ding

More likely a netfilter bug in net/bridge/netfilter/ebtables.c
