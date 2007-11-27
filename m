From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: net_rx_action/NAPI oops [PATCH]
Date: Tue, 27 Nov 2007 19:52:24 +0100
Message-ID: <18252.26472.319078.165019@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:53098 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756571AbXK0TYv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 14:24:51 -0500
Received: from robur.slu.se (robur.slu.se [130.238.98.12])
	by mx1.slu.se (8.13.7/8.13.6) with ESMTP id lARJCwo0026443
	for <netdev@vger.kernel.org>; Tue, 27 Nov 2007 20:12:58 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello!

I've discovered a bug while testing the new multiQ NAPI code. In hi-load 
situations when we take down an interface we get a kernel panic. The
oops is below.

>From what I see this happens when driver does napi_disable() and clears
NAPI_STATE_SCHED. In net_rx_action there is a check for work == weight 
a sort indirect test but that's now not enough to cover the load situation. 
where we have NAPI_STATE_SCHED cleared by e1000_down in my case and still 
full quota. Latest git but I'll guess the is the same in all later kernels.
There might be different solutions... one variant is below:

Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

diff --git a/net/core/dev.c b/net/core/dev.c
index 043e2f8..1031233 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2207,7 +2207,7 @@ static void net_rx_action(struct softirq_action *h)
 		 * still "owns" the NAPI instance and therefore can
 		 * move the instance around on the list at-will.
 		 */
-		if (unlikely(work == weight))
+		if (unlikely(work == weight) && (test_bit(NAPI_STATE_SCHED, &n->state)))
 			list_move_tail(&n->poll_list, list);
 
 		netpoll_poll_unlock(have);


Cheers
					--ro


labb:/# ifconfig  eth0 down 

BUG: unable to handle kernel paging request at virtual address 00100104
printing eip: c0433d67 *pde = 00000000 
Oops: 0002 [#1] SMP 
Modules linked in:

Pid: 4, comm: ksoftirqd/0 Not tainted (2.6.24-rc3bifrost-gb3664d45-dirty #32)
EIP: 0060:[<c0433d67>] EFLAGS: 00010046 CPU: 0
EIP is at net_rx_action+0x107/0x120
EAX: 00100100 EBX: f757d4e0 ECX: c200d334 EDX: 00200200
ESI: 00000040 EDI: c200d334 EBP: 000000ec ESP: f7c6bf78
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process ksoftirqd/0 (pid: 4, ti=f7c6a000 task=f7c58ab0 task.ti=f7c6a000)
Stack: c0236217 c200ce9c c200ce9c 00000000 fffcf892 00000040 00000005 c05b2a98 
       c0603e60 00000008 c022a275 00000000 c06066c0 c06066c0 00000246 00000000 
       c022a5e0 00000000 c022a327 c06066c0 c022a636 fffffffc 00000000 c02384f2 
Call Trace:
 [<c0236217>] __rcu_process_callbacks+0x107/0x190
 [<c022a275>] __do_softirq+0x75/0xf0
 [<c022a5e0>] ksoftirqd+0x0/0xd0
 [<c022a327>] do_softirq+0x37/0x40
 [<c022a636>] ksoftirqd+0x56/0xd0
 [<c02384f2>] kthread+0x42/0x70
 [<c02384b0>] kthread+0x0/0x70
 [<c02039df>] kernel_thread_helper+0x7/0x18
 =======================
Code: 88 8c 52 c0 e8 4b 1d df ff e8 96 0c dd ff c7 05 64 7d 63 c0 01 00 00 00 e9 61 ff ff ff 8d b4
 26 00 00 00 00 8b 03 8b 53 04 89 f9 <89> 50 04 89 02 89 d8 8b 57 04 e8 5a 34 eb ff e9 4a ff ff ff
 90 
EIP: [<c0433d67>] net_rx_action+0x107/0x120 SS:ESP 0068:f7c6bf78
Kernel panic - not syncing: Fatal exception in interrupt
