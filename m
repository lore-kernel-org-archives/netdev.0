From: Ulf Samuelsson <netdev@emagii.com>
Subject: NULL pointer dereference when closing socket on a 4.1 kernel
Date: Fri, 26 Aug 2016 20:58:25 +0200
Message-ID: <3d9fb717-578d-2a53-004e-566ba42c3463@emagii.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ste-pvt-msa2.bahnhof.se ([213.80.101.71]:10473 "EHLO
        ste-pvt-msa2.bahnhof.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752026AbcHZS64 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:58:56 -0400
Received: from localhost (localhost [127.0.0.1])
        by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTP id B3C613F68B
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 20:58:25 +0200 (CEST)
Received: from ste-pvt-msa2.bahnhof.se ([127.0.0.1])
        by localhost (ste-pvt-msa2.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id ECWnJCq3ixT9 for <netdev@vger.kernel.org>;
        Fri, 26 Aug 2016 20:58:25 +0200 (CEST)
Received: from [10.175.196.210] (h-169-62.a454.priv.bahnhof.se [37.123.169.62])
        (Authenticated sender: mb782575)
        by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTPA id 1B4623F61F
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 20:58:25 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Getting a NULL pointer crash when a socket is closed.

[  593.173973] Unable to handle kernel NULL pointer dereference at 
virtual address 00000010
[  593.182079] pgd = e416ed00
[  593.184789] [00000010] *pgd=1b3a2003, *pmd=1ac47003, *pte=00000000
[  593.191029] Internal error: Oops: 207 [#1] PREEMPT SMP ARM

The crash occurs in net/ipv4/ip_output.c:__ip_make_skb when calling dst_mtu

if (inet->pmtudisc == IP_PMTUDISC_DO ||
     inet->pmtudisc == IP_PMTUDISC_PROBE ||
     (skb->len <= dst_mtu(&rt->dst) &&
     ip_dont_fragment(sk, &rt->dst)))
          df = htons(IP_DF);

dst_mtu uses its parameter as a pointer to a struct and accesses "ops" 
which is 16 bytes from the beginning of the struct, and the crash is on 
address 00000010.

So rt->dst appears to be NULL.

As far as I understand "rt->dst" is supposed to contained a cache entry 
of the route for a message using corking.

I.E: an UDP packet is created by a number of writes which at the end is 
collected to create the packet.

rt->dst is earlier assigned from "inet_sk(sk)->cork.base.dst"

The dst field is supposed to be initiated when you start creating the
corked packet, but I have read comments that as a cache it can also be
invalidated and that you have to refresh it using ip_route_output_flow.

Typical use (in udp_sendmsg)

rt = ip_route_output_flow(net, fl4, sk);

I have read other comments that the dst cache was abandoned already in 
linux-3.x but there seems still to be code around ????

Have noticed that in all crashes, another CPU seems to be closing down 
another process.

The route is supposed to be initiated when the first part of the
corked message is created.
Does it make sense that the route is invalidated before the packet is sent?

If closing down a process, invalidating the page tables would affect 
this, then I would expect to get an invalid access (non-NULL), so I am 
not convinced that this causes the crash. Any ideas?


CPU0:
[  593.191261] [<c082b51c>] (__ip_make_skb) from [<c082b78c>] 
(ip_push_pending_frames+0x14/0x28)
[<c082b78c>] (ip_push_pending_frames) from [<c082ba9c>]
                                     (ip_send_unicast_reply+0x200/0x224)
[<c082ba9c>] (ip_send_unicast_reply) from [<c0846614>]
                                     (tcp_v4_send_reset+0x17c/0x240)
[<c0846614>] (tcp_v4_send_reset) from [<c0846b0c>]
                                     (tcp_v4_do_rcv+0xa4/0x3d8)
[<c0846b0c>] (tcp_v4_do_rcv) from [<c07a6624>](release_sock+0x6c/0x164)
[<c07a6624>] (release_sock)  from [<c08362e0>] (tcp_close+0xb0/0x490)
[<c08362e0>] (tcp_close)     from [<c085c53c>] (inet_release+0x44/0x70)
[<c085c53c>] (inet_release)  from [<c07a20e0>] (sock_release+0x20/0xac)
[<c07a20e0>] (sock_release)  from [<c07a2178>] (sock_close+0xc/0x14)
[<c07a2178>] (sock_close)    from [<c05195e8>] (__fput+0x80/0x1c8)
[<c05195e8>] (__fput)  from [<c0442b34>] (task_work_run+0xb0/0xe8)
[<c0442b34>] (task_work_run) from [<c0413030>]
                                   (do_work_pending+0xa0/0xec)
[<c0413030>] (do_work_pending) from [<c040f68c>]
                                   (work_pending+0xc/0x20)


CPU1:

[<c0414180>] (__irq_svc) from [<c0504360>] (page_remove_rmap+0x84/0xc4)
[<c0504360>] (page_remove_rmap) from [<c04f99dc>]
                                 (unmap_single_vma+0x3d4/0x674)
[<c04f99dc>] (unmap_single_vma) from [<c04fa608>] (unmap_vmas+0x54/0x68)
[<c04fa608>] (unmap_vmas) from [<c0501c5c>] (exit_mmap+0xe4/0x1f0)
[<c0501c5c>] (exit_mmap) from [<c042603c>] (mmput+0x4c/0x118)
[<c042603c>] (mmput) from [<c051dd70>] (flush_old_exec+0x494/0x5bc)
[<c051dd70>] (flush_old_exec) from [<c05634d4>]
                                 (load_elf_binary+0x298/0x10d8)
[<c05634d4>] (load_elf_binary) from [<c051d510>]
                                 (search_binary_handler+0x80/0x1bc)
[<c051d510>] (search_binary_handler) from [<c0561b08>]
                                 (load_script+0x228/0x244)
[<c0561b08>] (load_script) from [<c051d510>]
                                 (search_binary_handler+0x80/0x1bc)
[<c051d510>] (search_binary_handler) from [<c051e79c>]
                                 (do_execveat_common+0x4f0/0x6dc)
[<c051e79c>] (do_execveat_common) from [<c051ec0c>]
                                 (SyS_execve+0x30/0x38)
[<c051ec0c>] (SyS_execve) from [<c040f7d4>]
                                	(__sys_trace_return+0x0/0x2c)
CPU1: stopping

Best Regards,
Ulf Samuelsson
