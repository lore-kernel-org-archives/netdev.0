From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Panic with demuxed ipv4 multicast udp sockets on 4.0.4
Date: Fri, 10 Jul 2015 13:31:28 -0700
Message-ID: <CALCkm3c0ic4ixAr25RLOb+Bk9qNjfTLraTwCAjuj29qUj1pRpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kernel-team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35850 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933007AbbGJUbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 16:31:49 -0400
Received: by qgeg89 with SMTP id g89so134593616qge.3
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2015 13:31:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey everyone,

There's some kind of nasty condition in which sk_rx_dst points to an
apparently garbage datastructure and it's blowing up in the early
demux code because dst->ops is NULL.  The packet in question was for
bit torrent local peer discovery
https://en.wikipedia.org/wiki/Local_Peer_Discovery .  We're seeing
this on about a 1/200 chance of panic per day.

crash> bt
PID: 1899532  TASK: ffff88000826cf00  CPU: 9   COMMAND: "hhvm.node.1"
 #0 [ffff88047fc23990] machine_kexec at ffffffff8103bf05
 #1 [ffff88047fc239e0] crash_kexec at ffffffff810cb4e8
 #2 [ffff88047fc23ab0] oops_end at ffffffff81006468
 #3 [ffff88047fc23ae0] no_context at ffffffff8167aac1
 #4 [ffff88047fc23b40] __bad_area_nosemaphore at ffffffff8167acb9
 #5 [ffff88047fc23b90] bad_area_nosemaphore at ffffffff8167aceb
 #6 [ffff88047fc23ba0] __do_page_fault at ffffffff81044ac5
 #7 [ffff88047fc23c10] do_page_fault at ffffffff81044eec
 #8 [ffff88047fc23c20] page_fault at ffffffff81686c02
    [exception RIP: udp_v4_early_demux+481]
    RIP: ffffffff816249a1  RSP: ffff88047fc23cd8  RFLAGS: 00010246
    RAX: ffff880248ee4500  RBX: 000000000000093a  RCX: 0000000000000002
    RDX: 0000000000000000  RSI: 0000000000000000  RDI: ffff880248ee4500
    RBP: ffff88047fc23d48   R8: 0000000000000000   R9: 0000000000000000
    R10: 0000000000000001  R11: ffffc9000199f3a0  R12: ffff88006f8a6300
    R13: ffffffff81cbb1c0  R14: 0000000000000001  R15: ffff880474798f00
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
 #9 [ffff88047fc23cd0] udp_v4_early_demux at ffffffff81624bb3
#10 [ffff88047fc23d50] ip_rcv_finish at ffffffff815f3055
#11 [ffff88047fc23d80] ip_rcv at ffffffff815f3952
#12 [ffff88047fc23dc0] __netif_receive_skb_core at ffffffff815b96d4
#13 [ffff88047fc23e30] __netif_receive_skb at ffffffff815b9911
#14 [ffff88047fc23e50] process_backlog at ffffffff815b99f0
#15 [ffff88047fc23ea0] net_rx_action at ffffffff815ba1e8
#16 [ffff88047fc23f30] __do_softirq at ffffffff81054ce6
#17 [ffff88047fc23f90] irq_exit at ffffffff81055075
#18 [ffff88047fc23fa0] smp_call_function_single_interrupt at ffffffff810319f5
#19 [ffff88047fc23fb0] call_function_single_interrupt at ffffffff8168637a
--- <IRQ stack> ---
#20 [ffff8800792dff58] call_function_single_interrupt at ffffffff8168637a
    RIP: 00000000006e7b4c  RSP: 00007f4c8ba38b80  RFLAGS: 00000216
    RAX: 000000000000006b  RBX: ffffffff816851f2  RCX: 00007f49f4de84d6
    RDX: 00007f49f4de84d8  RSI: 00007f48dbcce731  RDI: 0000000000000000
    RBP: 00007f4c8ba38bd0   R8: 000000000000006b   R9: 00000000ffffffff
    R10: 00007f48dbcce737  R11: 00007f49f4de84e0  R12: 00007f4adab85198
    R13: 0000000000000014  R14: 00007f4adaaa4c00  R15: 0000000000000000
    ORIG_RAX: ffffffffffffff04  CS: 0033  SS: 002b
crash> print *(struct *dst_entry)0xffff880248ee4500
A syntax error in expression, near `*dst_entry)0xffff880248ee4500'.
gdb: gdb request failed: print *(struct *dst_entry)0xffff880248ee4500
crash> print *(struct dst_entry*)0xffff880248ee4500
$1 = {
  callback_head = {
    next = 0xffff880248ee4d00,
    func = 0x0
  },
  child = 0x13eacdfb7df67f6b,
  dev = 0xffff880113975d00,
  ops = 0x0,
  _metrics = 13729079323838086211,
  expires = 103079215104,
  path = 0x24c8d3baa,
  from = 0x0,
  xfrm = 0x600000000,
  input = 0x0,
  output = 0x0,
  flags = 5536,
  pending_confirm = 33114,
  error = -1,
  obsolete = -1,
  header_len = 0,
  trailer_len = 0,
  tclassid = 0,
  __pad_to_align_refcnt = {0, 704374636708},
  __refcnt = {
    counter = 14
  },
  __use = 2097153,
  lastuse = 536576,
  {
    next = 0x0,
    rt_next = 0x0,
    rt6_next = 0x0,
    dn_next = 0x0
  }
}

-- 
Alex Gartrell <agartrell@fb.com>
