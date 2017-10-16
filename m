From: David Ahern <dsahern@gmail.com>
Subject: WARNING in tcp_update_reordering
Date: Mon, 16 Oct 2017 16:38:15 -0600
Message-ID: <5cd139e4-5a50-ba99-d54a-cfe06ccee3e9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:45826 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752209AbdJPWiR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 18:38:17 -0400
Received: by mail-pg0-f43.google.com with SMTP id b192so7968439pga.2
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 15:38:17 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I need to throw this one over the fence. I triggered the trace below
testing changes to the tcp tracepoint. It is not readily reproducible
and does not appear to be correlated to the perf session.

Triggered by the following:
  ssh into VM and run 'top -d1'
  in host, drop tcp packets:
    $ sudo iptables -I INPUT -i br1 -p tcp -j DROP
  and then 5 - 7 seconds later remove the rule:
    $ sudo iptables -D INPUT -i br1 -p tcp -j DROP

[   73.695849] ------------[ cut here ]------------
[   73.697258] WARNING: CPU: 1 PID: 0 at
/home/dsa/kernel-2.git/net/ipv4/tcp_input.c:889
tcp_update_reordering+0x4/0x72
[   73.700306] Modules linked in: vrf
[   73.701316] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.14.0-rc4+ #43
[   73.703170] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[   73.706040] task: ffff88003e132180 task.stack: ffffc90000078000
[   73.707769] RIP: 0010:tcp_update_reordering+0x4/0x72
[   73.709209] RSP: 0018:ffff88003fd039c0 EFLAGS: 00010282
[   73.710702] RAX: 0000000000000004 RBX: ffff88003c7be800 RCX:
0000000000000004
[   73.711797] RDX: 0000000000000000 RSI: 00000000fffffffb RDI:
ffff88003c7be800
[   73.712809] RBP: ffff88003fd03a38 R08: 0000000000000000 R09:
0000000000000000
[   73.713831] R10: ffff88003fd03a90 R11: 0000000000000000 R12:
ffff88003fd03a90
[   73.714846] R13: 0000000000000000 R14: ffff88003c7bef40 R15:
ffff88003c7bef48
[   73.715871] FS:  0000000000000000(0000) GS:ffff88003fd00000(0000)
knlGS:0000000000000000
[   73.717016] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   73.717823] CR2: 000056441f284000 CR3: 000000003d7ba002 CR4:
00000000000606e0
[   73.718834] Call Trace:
[   73.719193]  <IRQ>
[   73.719497]  ? tcp_sacktag_write_queue+0x533/0x5ab
[   73.720180]  ? tcp_mtu_to_mss+0xd/0x1c
[   73.720718]  tcp_ack+0x320/0xd21
[   73.721189]  tcp_rcv_established+0x251/0x2c2
[   73.721799]  tcp_v4_do_rcv+0x9a/0x169
[   73.722328]  tcp_v4_rcv+0x55c/0x7bb
[   73.722841]  ip_local_deliver_finish+0xc0/0x141
[   73.723486]  ip_local_deliver+0xa5/0xae
[   73.724038]  ? xfrm4_policy_check.constprop.10+0x52/0x52
[   73.724787]  ip_rcv_finish+0x2de/0x35c
[   73.725326]  ip_rcv+0x271/0x2ea
[   73.725787]  ? deliver_ptype_list_skb+0x48/0x69
[   73.726430]  __netif_receive_skb_core+0x326/0x54a
[   73.727112]  ? kvm_clock_read+0x1e/0x20
[   73.727664]  ? kvm_clock_get_cycles+0x9/0xb
[   73.728257]  __netif_receive_skb+0x16/0x6d
[   73.728837]  ? __netif_receive_skb+0x16/0x6d
[   73.729446]  netif_receive_skb_internal+0x4d/0xa3
[   73.730116]  napi_gro_receive+0x75/0xcc
[   73.730667]  receive_buf+0xa05/0xa16
[   73.731192]  ? vring_unmap_one+0x1a/0x68
[   73.731754]  virtnet_poll+0x103/0x1b1
[   73.732284]  net_rx_action+0xdb/0x249
[   73.732814]  __do_softirq+0xfc/0x26b
[   73.733332]  irq_exit+0x51/0x92
[   73.733788]  do_IRQ+0x98/0xb0
[   73.734225]  common_interrupt+0x93/0x93
[   73.734779]  </IRQ>
[   73.735095] RIP: 0010:native_safe_halt+0x6/0x8
[   73.735726] RSP: 0018:ffffc9000007bea8 EFLAGS: 00000246 ORIG_RAX:
ffffffffffffff6e
[   73.736784] RAX: 0000000000000000 RBX: 0000000000000000 RCX:
ffff88003fd10ca0
[   73.737776] RDX: 00000000000101ba RSI: 0000000000000001 RDI:
0000000000000001
[   73.738780] RBP: ffffc9000007bea8 R08: ffff88003d48a900 R09:
0000000000000200
[   73.739777] R10: 0000000000000003 R11: 0000000000000001 R12:
0000000000000000
[   73.740779] R13: ffff88003e132180 R14: ffff88003e132180 R15:
ffff88003e132180
[   73.741781]  default_idle+0x1a/0x2d
[   73.742285]  arch_cpu_idle+0xa/0xc
[   73.742784]  default_idle_call+0x19/0x1b
[   73.743352]  do_idle+0xd7/0x1a9
[   73.743807]  cpu_startup_entry+0x1a/0x1c
[   73.744371]  start_secondary+0x11e/0x120
[   73.744930]  secondary_startup_64+0xa5/0xa5
[   73.745526] Code: 02 74 0b 48 c7 87 e0 06 00 00 00 00 00 00 8a 97 2c
06 00 00 83 e0 0d c1 e0 04 5d 83 e2 0f 09 d0 88 87 2c 06 00 00 c3 85 f6
79 03 <0f> ff c3 3b b7 10 06 00 00 55 48 89 e5 41 54 41 89 d4 53 48 89
[   73.748142] ---[ end trace 730e0fcd13f383bc ]---
