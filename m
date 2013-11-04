From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH/RFC net] ipv6: probably fragmentation bug
Date: Mon,  4 Nov 2013 10:26:13 +0100
Message-ID: <1383557174-19424-1-git-send-email-alex.aring@gmail.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:42387 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774Ab3KDJ00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 04:26:26 -0500
Received: by mail-ee0-f41.google.com with SMTP id e53so981648eek.0
        for <netdev@vger.kernel.org>; Mon, 04 Nov 2013 01:26:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I currently working for 6lowpan and try to use the fragmentation api like in ipv6.

Maybe I do something wrong with using the api but I don't catch any mistakes and
my sk_buff is already sent to the ipv6 layer correctly.

In a very poor connection with high payload(which is good for testing) I got a nullpointer
dereference when the fragmentation expire timer occurs.

BUG: unable to handle kernel NULL pointer dereference
at 0000000c
IP: [<c0389538>] _decode_session6+0x4f/0x1db
*pde = 00000000
Oops: 0000 [#1] SMP
Modules linked in:
CPU: 0 PID: 0 Comm: swapper/0 Not tainted
3.12.0-rc6-12694-g9ce9a7b-dirty #194
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
task: c05007e8 ti: c7808000 task.ti: c04f6000
EIP: 0060:[<c0389538>] EFLAGS: 00210246 CPU: 0
EIP is at _decode_session6+0x4f/0x1db
EAX: 00000000 EBX: c5e602e0 ECX: 00000000 EDX: c5e65c3d
ESI: c5e602e0 EDI: c7809ee8 EBP: c7809eac ESP: c7809e70
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: 0000000c CR3: 07b31000 CR4: 00000690
Stack:
 00000005 00282c6c 00000001 c05232dc c5e602e0 c0095bc0 c051de00 c0360508
 c7809eac c5e602e0 c5e602e0 c037ef65 00000001 c795aa60 c795aa60 00000000
 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
Call Trace:
 [<c0360508>] ? __xfrm_decode_session+0x22/0x2f
 [<c037ef65>] ? icmpv6_route_lookup+0xa9/0x119
 [<c037f396>] ? icmp6_send+0x3c1/0x4bf
 [<c037efd5>] ? icmpv6_route_lookup+0x119/0x119
 [<c038cea6>] ? icmpv6_send+0x17/0x1a
 [<c0382fbd>] ? ip6_expire_frag_queue+0x10a/0x11b
 [<c0382fce>] ? ip6_expire_frag_queue+0x11b/0x11b
 [<c0127eda>] ? call_timer_fn.isra.28+0x13/0x58
 [<c01280bf>] ? run_timer_softirq+0x11a/0x14d
 [<c0124097>] ? __do_softirq+0x95/0x13c

Maybe this occurs because I did some mistakes in my current 6lowpan fragmentation
implementation. That's why I sending it to this mailinglist... or maybe I found a bug.

The patch fix this issue you can find the removal of skb_dst_drop(skb) which
was comming in on commit id: 97599dc792b45b1669c3cdb9a4b365aad0232f65

Maybe this wasn't a correct solution. We need the sk_buff sometimes when the expire occurs to call
the icmp6_send function.

Regards Alex

Alexander Aring (1):
  ipv6: fix fragmentation bug

 net/ipv6/reassembly.c | 1 -
 1 file changed, 1 deletion(-)

-- 
1.8.4.2
