From: Greg Banks <gnb@sgi.com>
Subject: Race between neigh_timer_handler and neigh_event_send
Date: Tue, 5 Oct 2004 20:15:32 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005101532.GA935@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Cc: Linux Network Development List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

G'day,

I was running a UDP load test from 4 CPUs though a single NIC
to a single peer, and encountered an oops...

Unable to handle kernel NULL pointer dereference (address 000000000000000c)
ttcp[29920]: Oops 11012296146944 [1]
Modules linked in:

Pid: 29920, CPU 3, comm:                 ttcp
psr : 0000121008026018 ifs : 8000000000000593 ip  : [<a000000100770131>]    Not tainted
ip is at arp_solicit+0x131/0x380
unat: 0000000000000000 pfs : 0000000000000593 rsc : 0000000000000003
rnat: 0000000000064400 bsps: 000000000007cf90 pr  : 00046918155aa625
ldrs: 0000000000000000 ccv : 0000000080000000 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a000000100770110 b6  : a000000100003320 b7  : a00000010078eac0
f6  : 1003e0000000000000140 f7  : 1003e006666a6565db265
f8  : 1003e0000000000019000 f9  : 1003e0000000000000140
f10 : 1003e00000000064003e7 f11 : 1003e00000000000005be
r1  : a000000100da8a00 r2  : a000000100bae580 r3  : 0000000000000000
r8  : 0000000000000002 r9  : 00000000f801a8c0 r10 : 00000000000000fe
r11 : 0000000000000000 r12 : e00000304070f910 r13 : e000003040708000
r14 : 0000000000000001 r15 : 0000000000000000 r16 : 0000000000000000
r17 : e00000b07bc08d24 r18 : e00000b07bc08d98 r19 : 000000000000000c
r20 : 0000000000000000 r21 : e00000300f99ccfa r22 : 0000000000000002
r23 : e00000304070f918 r24 : e00000304070f912 r25 : 0000000000000002
r26 : e00000b07bc08d24 r27 : 0000000000000000 r28 : e00000b07bc08d2c
r29 : 0000000000000001 r30 : 0000000000000000 r31 : e00000b07bc08d90

Call Trace:
 [<a000000100019f00>] show_stack+0x80/0xa0
                                sp=e00000304070f4d0 bsp=e000003040709540
 [<a00000010001a7d0>] show_regs+0x850/0x860
                                sp=e00000304070f6a0 bsp=e0000030407094e0
 [<a00000010003f630>] die+0x170/0x220
                                sp=e00000304070f6b0 bsp=e0000030407094a8
 [<a0000001000612a0>] ia64_do_page_fault+0x380/0x9c0
                                sp=e00000304070f6b0 bsp=e000003040709448
 [<a000000100012300>] ia64_leave_kernel+0x0/0x260
                                sp=e00000304070f740 bsp=e000003040709448
 [<a000000100770130>] arp_solicit+0x130/0x380
                                sp=e00000304070f910 bsp=e0000030407093a8
 [<a0000001006f4490>] neigh_timer_handler+0x490/0x6a0
                                sp=e00000304070f910 bsp=e000003040709350
 [<a0000001000eb320>] run_timer_softirq+0x240/0x3a0
                                sp=e00000304070f920 bsp=e0000030407092e0
 [<a0000001000e0190>] __do_softirq+0x250/0x2a0
                                sp=e00000304070f940 bsp=e000003040709258
 [<a0000001000e0260>] do_softirq+0x80/0xe0
                                sp=e00000304070f940 bsp=e000003040709200
 [<a000000100018d30>] ia64_handle_irq+0x190/0x1c0
                                sp=e00000304070f940 bsp=e0000030407091c0
 [<a000000100012300>] ia64_leave_kernel+0x0/0x260
                                sp=e00000304070f940 bsp=e0000030407091c0
 [<a000000100723c70>] ip_push_pending_frames+0x850/0xa60
                                sp=e00000304070fb10 bsp=e000003040709138
 [<a00000010076b2f0>] udp_push_pending_frames+0x2b0/0x440
                                sp=e00000304070fb20 bsp=e0000030407090d8
 [<a00000010076bb70>] udp_sendmsg+0x690/0xe60
                                sp=e00000304070fb20 bsp=e000003040709008
 [<a00000010077d800>] inet_sendmsg+0xa0/0xe0
                                sp=e00000304070fbe0 bsp=e000003040708fc8
 [<a0000001006cff70>] sock_sendmsg+0x170/0x1c0
                                sp=e00000304070fbe0 bsp=e000003040708f98
 [<a0000001006d3210>] sys_sendto+0x170/0x200
                                sp=e00000304070fd50 bsp=e000003040708f08
 [<a000000100012180>] ia64_ret_from_syscall+0x0/0x20
                                sp=e00000304070fe30 bsp=e000003040708f08
 [<a000000000004000>] 0xa000000000004000
                                sp=e000003040710000 bsp=e000003040708f08

It turned out that arp_solicit() was dereferencing bogus pointers
from inside an sk_buff, which had been freed by neigh_event_send()
to keep neigh->arp_queue within its maximum length of 3, in between
neigh_timer_handler() dropping neigh->lock and calling arp_solicit().

The attached patch appears to fix it; tracing indicates the race has
occurred 3 times in my current test without oopsing.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.

--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=gnb-neigh-race

Fix a race between neigh_timer_handler() calling down to arp_solicit()
with an sk_buff peeked from the head of the neigh->arp_queue, and
neigh_event_send() unqueuing and freeing the head of the same queue
because it's reached the maximum length of 3, by taking an extra
sk_buff reference while holding neigh->lock.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>

Index: linux/net/core/neighbour.c
===================================================================
--- linux.orig/net/core/neighbour.c	2004-10-04 14:36:05.%N +1000
+++ linux/net/core/neighbour.c	2004-10-05 19:31:00.%N +1000
@@ -805,9 +805,15 @@ static void neigh_timer_handler(unsigned
 		add_timer(&neigh->timer);
 	}
 	if (neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) {
+		struct sk_buff *skb = skb_peek(&neigh->arp_queue);
+		/* keep skb alive even if arp_queue overflows */
+		if (skb)
+			skb_get(skb);
 		write_unlock(&neigh->lock);
-		neigh->ops->solicit(neigh, skb_peek(&neigh->arp_queue));
+		neigh->ops->solicit(neigh, skb);
 		atomic_inc(&neigh->probes);
+		if (skb)
+			kfree_skb(skb);
 	} else {
 out:
 		write_unlock(&neigh->lock);

--k1lZvvs/B4yU6o8G--
