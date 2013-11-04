From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH/RFC net] ipv6: fix fragmentation bug
Date: Mon,  4 Nov 2013 10:26:14 +0100
Message-ID: <1383557174-19424-2-git-send-email-alex.aring@gmail.com>
References: <1383557174-19424-1-git-send-email-alex.aring@gmail.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:50637 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab3KDJ0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 04:26:24 -0500
Received: by mail-ee0-f43.google.com with SMTP id b47so965396eek.30
        for <netdev@vger.kernel.org>; Mon, 04 Nov 2013 01:26:23 -0800 (PST)
In-Reply-To: <1383557174-19424-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a very poor 6lowpan wireless connection I got this:

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

I think we need to drop skb_dst_drop(skb) in ip6_frag_queue because we
send a icmp6_send in the expire function "ip6_expire_frag_queue":

icmpv6_send(fq->q.fragments, ICMPV6_TIME_EXCEED, ICMPV6_EXC_FRAGTIME,
0);

and it can be that the skb is already freed. This null pointer
dereference occurs when the timer expires.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ipv6/reassembly.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index cc85a9b..6463ae0 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -352,7 +352,6 @@ found:
 		return res;
 	}
 
-	skb_dst_drop(skb);
 	inet_frag_lru_move(&fq->q);
 	return -1;
 
-- 
1.8.4.2
