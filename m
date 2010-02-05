From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 2/6] Bluetooth: Fix sleeping function in RFCOMM within invalid context
Date: Fri,  5 Feb 2010 12:05:35 -0800
Message-ID: <485f1eff73a7b932fd3abb0dfcf804e1a1f59025.1265399549.git.marcel@holtmann.org>
References: <cover.1265399549.git.marcel@holtmann.org>
 <1038a00b458997661bcd0e780a24dc280a8841fc.1265399549.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54200 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901Ab0BEUGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 15:06:44 -0500
In-Reply-To: <1038a00b458997661bcd0e780a24dc280a8841fc.1265399549.git.marcel@holtmann.org>
In-Reply-To: <cover.1265399549.git.marcel@holtmann.org>
References: <cover.1265399549.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the commit 9e726b17422bade75fba94e625cd35fd1353e682 the
rfcomm_session_put() gets accidentially called from a timeout
callback and results in this:

BUG: sleeping function called from invalid context at net/core/sock.c:1897
in_atomic(): 1, irqs_disabled(): 0, pid: 0, name: swapper
Pid: 0, comm: swapper Tainted: P           2.6.32 #31
Call Trace:
 <IRQ>  [<ffffffff81036455>] __might_sleep+0xf8/0xfa
 [<ffffffff8138ef1d>] lock_sock_nested+0x29/0xc4
 [<ffffffffa03921b3>] lock_sock+0xb/0xd [l2cap]
 [<ffffffffa03948e6>] l2cap_sock_shutdown+0x1c/0x76 [l2cap]
 [<ffffffff8106adea>] ? clockevents_program_event+0x75/0x7e
 [<ffffffff8106bea2>] ? tick_dev_program_event+0x37/0xa5
 [<ffffffffa0394967>] l2cap_sock_release+0x27/0x67 [l2cap]
 [<ffffffff8138c971>] sock_release+0x1a/0x67
 [<ffffffffa03d2492>] rfcomm_session_del+0x34/0x53 [rfcomm]
 [<ffffffffa03d24c5>] rfcomm_session_put+0x14/0x16 [rfcomm]
 [<ffffffffa03d28b4>] rfcomm_session_timeout+0xe/0x1a [rfcomm]
 [<ffffffff810554a8>] run_timer_softirq+0x1e2/0x29a
 [<ffffffffa03d28a6>] ? rfcomm_session_timeout+0x0/0x1a [rfcomm]
 [<ffffffff8104e0f6>] __do_softirq+0xfe/0x1c5
 [<ffffffff8100e8ce>] ? timer_interrupt+0x1a/0x21
 [<ffffffff8100cc4c>] call_softirq+0x1c/0x28
 [<ffffffff8100e05b>] do_softirq+0x33/0x6b
 [<ffffffff8104daf6>] irq_exit+0x36/0x85
 [<ffffffff8100d7a9>] do_IRQ+0xa6/0xbd
 [<ffffffff8100c493>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff812585b3>] ? acpi_idle_enter_bm+0x269/0x294
 [<ffffffff812585a9>] ? acpi_idle_enter_bm+0x25f/0x294
 [<ffffffff81373ddc>] ? cpuidle_idle_call+0x97/0x107
 [<ffffffff8100aca0>] ? cpu_idle+0x53/0xaa
 [<ffffffff81429006>] ? rest_init+0x7a/0x7c
 [<ffffffff8177bc8c>] ? start_kernel+0x389/0x394
 [<ffffffff8177b29c>] ? x86_64_start_reservations+0xac/0xb0
 [<ffffffff8177b384>] ? x86_64_start_kernel+0xe4/0xeb

To fix this, the rfcomm_session_put() needs to be moved out of
rfcomm_session_timeout() into rfcomm_process_sessions(). In that
context it is perfectly fine to sleep and disconnect the socket.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
Tested-by: David John <davidjon@xenontk.org>
---
 net/bluetooth/rfcomm/core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index fc5ee32..2b50637 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -252,7 +252,6 @@ static void rfcomm_session_timeout(unsigned long arg)
 	BT_DBG("session %p state %ld", s, s->state);
 
 	set_bit(RFCOMM_TIMED_OUT, &s->flags);
-	rfcomm_session_put(s);
 	rfcomm_schedule(RFCOMM_SCHED_TIMEO);
 }
 
@@ -1920,6 +1919,7 @@ static inline void rfcomm_process_sessions(void)
 		if (test_and_clear_bit(RFCOMM_TIMED_OUT, &s->flags)) {
 			s->state = BT_DISCONN;
 			rfcomm_send_disc(s, 0);
+			rfcomm_session_put(s);
 			continue;
 		}
 
-- 
1.6.6

