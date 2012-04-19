From: Yevgen Pronenko <yevgen.pronenko@sonymobile.com>
Subject: Re: NULL pointer dereference at __ip_route_output_key
Date: Thu, 19 Apr 2012 16:58:52 +0200
Message-ID: <4F90282C.5020104@sonymobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seldrel01.sonyericsson.com ([212.209.106.2]:17815 "EHLO
	seldrel01.sonyericsson.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753783Ab2DSPI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 11:08:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

> 2798 of net/ipv4/route.c:
>
>> dev_out = FIB_RES_DEV(res);
 >> fl4->flowi4_oif = dev_out->ifindex;
>
> and we are thus OOPS'ing on the dev_out->ifindex.
>
> Unfortunately I've never seen a report like this. If the reporter
> can reproduce, you can try to extract more information by doing
> something like this right after the dev_out assignment:

I observed a crash in exactly the same place recently.

wlan: disconnected
Unable to handle kernel NULL pointer dereference at virtual address 00000070
cfg80211: Calling CRDA to update world regulatory domain
pgd = d67a4000
[00000070] *pgd=9f144831, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#1] PREEMPT SMP
Modules linked in: wlan(P) cfg80211 [last unloaded: wlan]
CPU: 0    Tainted: P        W    (3.0.8+1.0.21100-01783-gb40b976 #1)
PC is at __ip_route_output_key+0x49c/0x78c
LR is at fib_rules_lookup+0x16c/0x174
pc : [<c05fb848>]    lr : [<c05bcaf4>]    psr: 60000013
sp : d6899bb0  ip : d6899bc4  fp : 00000000
r10: 00000000  r9 : 00000000  r8 : 479047c2
r7 : 00000000  r6 : 00000000  r5 : d6899bc4  r4 : d6899c64
r3 : cdc04600  r2 : 0415c05e  r1 : cdc04600  r0 : fa2410ac
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 10c5787d  Table: 9daa406a  DAC: 00000015
...
[<c05fb848>] (__ip_route_output_key+0x49c/0x78c) from [<c05fbb4c>] 
(ip_route_output_flow+0x14/0x50)
[<c05fbb4c>] (ip_route_output_flow+0x14/0x50) from [<c0623ff0>] 
(udp_sendmsg+0x358/0x72c)
[<c0623ff0>] (udp_sendmsg+0x358/0x72c) from [<c06701b4>] 
(udpv6_sendmsg+0x154/0x8d8)
[<c06701b4>] (udpv6_sendmsg+0x154/0x8d8) from [<c062b8a0>] 
(inet_sendmsg+0xac/0xb4)
[<c062b8a0>] (inet_sendmsg+0xac/0xb4) from [<c0597ed4>] 
(sock_sendmsg+0xa0/0xbc)
[<c0597ed4>] (sock_sendmsg+0xa0/0xbc) from [<c05985ec>] 
(sys_sendto+0xbc/0xfc)
[<c05985ec>] (sys_sendto+0xbc/0xfc) from [<c0105e60>] 
(ret_fast_syscall+0x0/0x30)

Analyzing the dump I found that FIB_RES_DEV(res) macros in the line 
mentioned above returned NULL.
I was able to dump a content of related structures in memory:

res: struct fib_result {
     prefixlen = 0 '\000',
     nh_sel = 0 '\000',
     type = 1 '\001',
     scope = 0 '\000',
     struct fib_info *fi = 0xcdc04600
         -> {
             fib_hash = {
                 next = 0x100100,
                 pprev = 0x200200
             },
             fib_lhash = {
                 next = 0x0,
                 pprev = 0x0
             },
             fib_net = 0xc0da8000,
             fib_treeref = 0,
             fib_clntref = {
                 counter = 0
             },
             fib_flags = 0,
             fib_dead = 1 '\001',
             fib_protocol = 3 '\003',
             fib_scope = 0 '\000',
             fib_prefsrc = 0,
             fib_priority = 314,
             fib_metrics = 0xc0da88a0,
             fib_nhs = 1,
             rcu = {
                 next = 0xc9df30e8,
                 func = 0x34
             },
             fib_nh = 0xcdc0463c
         }
     struct fib_table *table = 0xd88684c0
      -> {
             tb_hlist = {
                 next = 0x0,
                 pprev = 0xd9ab5bf8
             },
             tb_id = 254,
             tb_default = -1,
             tb_num_default = 1,
             tb_data = 0xd88684d4
         }
     struct list_head *fa_head = 0xd7e13554
      -> {
             next = 0xd7e13554,
             prev = 0xd7e13554
         }
     struct fib_rule *r = 0xd7e05300
      -> {
             list = {
                 next = 0xd7e05780,
                 prev = 0xd9b13500
             },
             refcnt = {
                 counter = 1
             },
             iifindex = 0,
             oifindex = 0,
             mark = 0,
             mark_mask = 0,
             pref = 32766,
             flags = 0,
             table = 254,
             action = 1 '\001',
             target = 0,
             ctarget = 0x0,
             iifname = 
"\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000",
             oifname = 
"\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000",
             rcu = {
                 next = 0x0,
                 func = 0
             },
             fr_net = 0xc0da8000
         }
}

Here is the content of res.fi->fib_nh:

struct fib_nh {
     nh_dev = 0x0,
     nh_hash = {
         next = 0x100100,
         pprev = 0x200200
     },
     nh_parent = 0xcdc04600,
     nh_flags = 0,
     nh_scope = 253 '\375',
     nh_oif = 14,
     nh_gw = 18878636,
     nh_saddr = 4196667564,
     nh_saddr_genid = 68534366
}

As you can see, there is a NULL in res.fi->fib_nh.nh_dev. One more thing 
which looks suspicious for me is that res.fi->fib_dead is 1 here. And 
the crash happened just after shutting down a WLAN interface (the last 
string in the kernel log was "wlan: disconnected").

Having that, is it possible there is a race between network resources 
deallocation and a route lookup procedure?

The crash was observed only once and I am not able to reproduce it, but 
I have a crash dump, so I can grep it for additional information (kernel 
logs, values of variables, etc).

Here is the basic information about the system:
      RELEASE: 3.0.8+1.0.21100-01783-gb40b976
      VERSION: #1 SMP PREEMPT Thu Apr 12 06:19:58 2012
      MACHINE: armv7l  (unknown Mhz)


Yevgen Pronenko.
