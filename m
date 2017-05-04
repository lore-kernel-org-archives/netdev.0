From: Daniel J Blueman <daniel@quora.org>
Subject: Re: [4.9.13] use after free in ipv4_mtu
Date: Thu, 4 May 2017 09:30:48 +0800
Message-ID: <CAMVG2styFdOcp2hT=VBApWWNFv2Ssn8AgC_M0M1JhLB2uKQnhQ@mail.gmail.com>
References: <CAMVG2ssDe2NMOZzeTF77H1zEEh3dBuT75bS6f81Tqd+3v_4J+g@mail.gmail.com>
 <1488460104.9415.325.camel@edumazet-glaptop3.roam.corp.google.com>
 <1488461281.9415.327.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAMVG2styKvhUkVnhkFJ-B427sgnbxsBN8rJfE=wFd3wtXYXvrg@mail.gmail.com> <1488807904.9415.375.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Stephen Hemminger <shemminger@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:35256 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932169AbdEDBau (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 21:30:50 -0400
Received: by mail-ua0-f196.google.com with SMTP id e28so4707uah.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 18:30:50 -0700 (PDT)
In-Reply-To: <1488807904.9415.375.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 March 2017 at 21:45, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-03-06 at 14:33 +0800, Daniel J Blueman wrote:
>> On 2 March 2017 at 21:28, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Thu, 2017-03-02 at 05:08 -0800, Eric Dumazet wrote:
>> >
>> >> Thanks for the report !
>> >>
>> >> This patch should solve this precise issue, but we need more work.
>> >>
>> >> We need to audit all __sk_dst_get() and make sure they are inside an
>> >> rcu_read_lock()/rcu_read_unlock() section.
>> >>
>> >> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> >> index 22548b5f05cbe5a655e0c53df2d31c5cc2e8a702..517963e1cb6eb9d70fcd71f44262813c3378759f 100644
>> >> --- a/net/ipv4/tcp_output.c
>> >> +++ b/net/ipv4/tcp_output.c
>> >> @@ -1459,7 +1459,7 @@ EXPORT_SYMBOL(tcp_sync_mss);
>> >>  unsigned int tcp_current_mss(struct sock *sk)
>> >>  {
>> >>       const struct tcp_sock *tp = tcp_sk(sk);
>> >> -     const struct dst_entry *dst = __sk_dst_get(sk);
>> >> +     const struct dst_entry *dst;
>> >>       u32 mss_now;
>> >>       unsigned int header_len;
>> >>       struct tcp_out_options opts;
>> >> @@ -1467,11 +1467,14 @@ unsigned int tcp_current_mss(struct sock *sk)
>> >>
>> >>       mss_now = tp->mss_cache;
>> >>
>> >> +     rcu_read_lock();
>> >> +     dst = __sk_dst_get(sk);
>> >>       if (dst) {
>> >>               u32 mtu = dst_mtu(dst);
>> >>               if (mtu != inet_csk(sk)->icsk_pmtu_cookie)
>> >>                       mss_now = tcp_sync_mss(sk, mtu);
>> >>       }
>> >> +     rcu_read_unlock();
>> >>
>> >>       header_len = tcp_established_options(sk, NULL, &opts, &md5) +
>> >>                    sizeof(struct tcphdr);
>> >
>> > Normally TCP sockets sk_dst_cache can only be changed if the thread
>> > doing the change owns the socket.
>> >
>> > I have not yet understood which point was breaking the rule yet.
>>
>> Great work Eric! I have been unable to reproduce the KASAN warning
>> with this patch.
>>
>> Reported-by: Daniel J Blueman <daniel@quora.org>
>> Tested-by: Daniel J Blueman <daniel@quora.org>
>>
>> I do change the network queueing discipline and related at runtime [1]
>> which may be triggering this, though I did think I saw the KASAN
>> report only after resuming from suspend. rf(un)kill and other tweaking
>> may have been involved too.
>>
>> Thanks,
>>   Dan
>
> Thanks Daniel, but this bandaid patch should not be needed.
>
> Somehow another point in the stack is at fault and needs to be
> identified.
>
> Otherwise we'll keep adding works around.
>
> Since net-next is soon to be re-opened, I will submit patches adding
> more lockdep assisted checks.

I am still seeing the same KASAN issue on 4.9.25; let me know if any
debug or testing would help. Thanks Eric!

https://quora.org/linux/ipv4_mtu/vmlinux
https://quora.org/linux/ipv4_mtu/config

[19515.180104] BUG: KASAN: use-after-free in ipv4_mtu+0x25d/0x320 at
addr ffff88040d6fecc4
[19515.180108] Read of size 4 by task Socket Thread/3299
[19515.180113] CPU: 7 PID: 3299 Comm: Socket Thread Tainted: G    BU
       4.9.25-debug+ #5
[19515.180115] Hardware name: Dell Inc. XPS 15 9550/0N7TVV, BIOS
1.2.21 02/17/2017
[19515.180127]  ffff8803f55a77d0 ffffffff9ce404b1 ffff88042d803800
ffff88040d6fecc0
[19515.180133]  ffff8803f55a77f8 ffffffff9c7e2751 ffff8803f55a7890
ffff88040d6fecc0
[19515.180137]  ffff88042d803800 ffff8803f55a7880 ffffffff9c7e29ea
ffff8803f55a7828
[19515.180140] Call Trace:
[19515.180148]  [<ffffffff9ce404b1>] dump_stack+0x63/0x82
[19515.180154]  [<ffffffff9c7e2751>] kasan_object_err+0x21/0x70
[19515.180158]  [<ffffffff9c7e29ea>] kasan_report_error+0x1fa/0x500
[19515.180162]  [<ffffffff9dced48d>] ? schedule+0x8d/0x1a0
[19515.180168]  [<ffffffff9c4f561e>] ? get_futex_key+0x64e/0xbb0
[19515.180174]  [<ffffffff9c40a1ab>] ? update_cfs_rq_load_avg+0x89b/0x1520
[19515.180177]  [<ffffffff9c7e2e31>] __asan_report_load4_noabort+0x61/0x70
[19515.180180]  [<ffffffff9d9ace2d>] ? ipv4_mtu+0x25d/0x320
[19515.180182]  [<ffffffff9d9ace2d>] ipv4_mtu+0x25d/0x320
[19515.180187]  [<ffffffff9da44693>] tcp_current_mss+0x133/0x270
[19515.180190]  [<ffffffff9da44560>] ? tcp_mtu_to_mss+0x280/0x280
[19515.180193]  [<ffffffff9c40eeb9>] ? select_idle_sibling+0x29/0xaa0
[19515.180195]  [<ffffffff9c4f6284>] ? futex_wait_setup+0x1d4/0x300
[19515.180198]  [<ffffffff9c424f81>] ? enqueue_task_fair+0x261/0x2760
[19515.180201]  [<ffffffff9d9f99e4>] tcp_send_mss+0x24/0x2b0
[19515.180203]  [<ffffffff9da09809>] tcp_sendmsg+0x3d9/0x3530
[19515.180208]  [<ffffffff9c3f018d>] ? ttwu_do_wakeup+0x1d/0x2c0
[19515.180211]  [<ffffffff9c3f0539>] ? ttwu_do_activate+0x109/0x180
[19515.180213]  [<ffffffff9da09430>] ? tcp_sendpage+0x1cc0/0x1cc0
[19515.180216]  [<ffffffff9c3f3a27>] ? wake_up_q+0x87/0xe0
[19515.180219]  [<ffffffff9c4fb707>] ? do_futex+0xf87/0x1730
[19515.180222]  [<ffffffff9dac9d90>] ? inet_gso_segment+0x1340/0x1340
[19515.180224]  [<ffffffff9daca1b0>] ? inet_recvmsg+0x420/0x420
[19515.180226]  [<ffffffff9daca3c7>] inet_sendmsg+0x217/0x3c0
[19515.180228]  [<ffffffff9daca1b0>] ? inet_recvmsg+0x420/0x420
[19515.180232]  [<ffffffff9d87752a>] sock_sendmsg+0xba/0xf0
[19515.180234]  [<ffffffff9d8785ef>] SYSC_sendto+0x1df/0x330
[19515.180236]  [<ffffffff9d878410>] ? SYSC_connect+0x2d0/0x2d0
[19515.180243]  [<ffffffff9d872794>] ? sock_ioctl+0x284/0x3a0
[19515.180248]  [<ffffffff9c87e3ef>] ? do_vfs_ioctl+0x1af/0xf60
[19515.180250]  [<ffffffff9c87e240>] ? ioctl_preallocate+0x1e0/0x1e0
[19515.180253]  [<ffffffff9c4fbfa4>] ? SyS_futex+0xf4/0x2a0
[19515.180259]  [<ffffffff9c8436b4>] ? vfs_read+0x254/0x2f0
[19515.180261]  [<ffffffff9c4fbeb0>] ? do_futex+0x1730/0x1730
[19515.180265]  [<ffffffff9c84705c>] ? SyS_read+0x11c/0x1c0
[19515.180267]  [<ffffffff9d87a31e>] SyS_sendto+0xe/0x10
[19515.180271]  [<ffffffff9dcf897b>] entry_SYSCALL_64_fastpath+0x1e/0xad
[19515.180274] Object at ffff88040d6fecc0, in cache kmalloc-64 size: 64
[19515.180277] Allocated:
[19515.180279] PID = 2326
[19515.180287]  save_stack_trace+0x1b/0x20
[19515.180291]  save_stack+0x46/0xd0
[19515.180293]  kasan_kmalloc+0xad/0xe0
[19515.180295]  kmem_cache_alloc_trace+0xe8/0x1e0
[19515.180298]  fib_create_info+0x917/0x3fc0
[19515.180300]  fib_table_insert+0x1d4/0x1c90
[19515.180302]  inet_rtm_newroute+0xfb/0x180
[19515.180306]  rtnetlink_rcv_msg+0x249/0x6a0
[19515.180312]  netlink_rcv_skb+0x247/0x350
[19515.180314]  rtnetlink_rcv+0x28/0x30
[19515.180316]  netlink_unicast+0x419/0x5c0
[19515.180318]  netlink_sendmsg+0x8a7/0xb60
[19515.180319]  sock_sendmsg+0xba/0xf0
[19515.180321]  ___sys_sendmsg+0x697/0x860
[19515.180323]  __sys_sendmsg+0xd5/0x170
[19515.180324]  SyS_sendmsg+0x12/0x20
[19515.180327]  entry_SYSCALL_64_fastpath+0x1e/0xad
[19515.180327] Freed:
[19515.180329] PID = 0
[19515.180333]  save_stack_trace+0x1b/0x20
[19515.180340]  save_stack+0x46/0xd0
[19515.180345]  kasan_slab_free+0x71/0xb0
[19515.180347]  kfree+0x8c/0x1a0
[19515.180353]  free_fib_info_rcu+0x558/0x760
[19515.180358]  rcu_process_callbacks+0x968/0x1000
[19515.180361]  __do_softirq+0x1a9/0x538
[19515.180361] Memory state around the buggy address:
[19515.180367]  ffff88040d6feb80: fc fc fc fc 00 00 00 00 00 00 00 00
fc fc fc fc
[19515.180369]  ffff88040d6fec00: fb fb fb fb fb fb fb fb fc fc fc fc
fb fb fb fb
[19515.180371] >ffff88040d6fec80: fb fb fb fb fc fc fc fc fb fb fb fb
fb fb fb fb
[19515.180373]                                            ^
[19515.180375]  ffff88040d6fed00: fc fc fc fc fb fb fb fb fb fb fb fb
fc fc fc fc
[19515.180378]  ffff88040d6fed80: 00 00 00 00 00 00 00 00 fc fc fc fc
fb fb fb fb
-- 
Daniel J Blueman
