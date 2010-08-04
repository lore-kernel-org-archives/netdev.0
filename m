From: David Howells <dhowells@redhat.com>
Subject: [PATCH] RxRPC: Fix a potential deadlock between the call resend_timer
	and state_lock
Date: Wed, 04 Aug 2010 13:34:17 +0100
Message-ID: <20100804123417.29580.95095.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Howells <dhowells@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932381Ab0HDMeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 08:34:21 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o74CYLhq025197
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 4 Aug 2010 08:34:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RxRPC can potentially deadlock as rxrpc_resend_time_expired() wants to get
call->state_lock so that it can alter the state of an RxRPC call.  However, its
caller (call_timer_fn()) has an apparent lock on the timer struct.

The problem is that rxrpc_resend_time_expired() isn't permitted to lock
call->state_lock as this could cause a deadlock against rxrpc_send_abort() as
that takes state_lock and then attempts to delete the resend timer by calling
del_timer_sync().

The deadlock can occur because del_timer_sync() will sit there forever waiting
for rxrpc_resend_time_expired() to return, but the latter may then wait for
call->state_lock, which rxrpc_send_abort() holds around del_timer_sync()...

This leads to a warning appearing in the kernel log that looks something like
the attached.

It should be sufficient to simply dispense with the locks.  It doesn't matter
if we set the resend timer expired event bit and queue the event processor
whilst we're changing state to one where the resend timer is irrelevant as the
event can just be ignored by the processor thereafter.


=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.35-rc3-cachefs+ #115
-------------------------------------------------------
swapper/0 is trying to acquire lock:
 (&call->state_lock){++--..}, at: [<ffffffffa00200d4>] rxrpc_resend_time_expired+0x56/0x96 [af_rxrpc]

but task is already holding lock:
 (&call->resend_timer){+.-...}, at: [<ffffffff8103b675>] run_timer_softirq+0x182/0x2a5

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&call->resend_timer){+.-...}:
       [<ffffffff810560bc>] __lock_acquire+0x889/0x8fa
       [<ffffffff81056184>] lock_acquire+0x57/0x6d
       [<ffffffff8103bb9c>] del_timer_sync+0x3c/0x86
       [<ffffffffa002bb7a>] rxrpc_send_abort+0x50/0x97 [af_rxrpc]
       [<ffffffffa002bdd9>] rxrpc_kernel_abort_call+0xa1/0xdd [af_rxrpc]
       [<ffffffffa0061588>] afs_deliver_to_call+0x129/0x368 [kafs]
       [<ffffffffa006181b>] afs_process_async_call+0x54/0xff [kafs]
       [<ffffffff8104261d>] worker_thread+0x1ef/0x2e2
       [<ffffffff81045f47>] kthread+0x7a/0x82
       [<ffffffff81002cd4>] kernel_thread_helper+0x4/0x10

-> #0 (&call->state_lock){++--..}:
       [<ffffffff81055237>] validate_chain+0x727/0xd23
       [<ffffffff810560bc>] __lock_acquire+0x889/0x8fa
       [<ffffffff81056184>] lock_acquire+0x57/0x6d
       [<ffffffff813e6b69>] _raw_read_lock_bh+0x34/0x43
       [<ffffffffa00200d4>] rxrpc_resend_time_expired+0x56/0x96 [af_rxrpc]
       [<ffffffff8103b6e6>] run_timer_softirq+0x1f3/0x2a5
       [<ffffffff81036828>] __do_softirq+0xa2/0x13e
       [<ffffffff81002dcc>] call_softirq+0x1c/0x28
       [<ffffffff810049f0>] do_softirq+0x38/0x80
       [<ffffffff810361a2>] irq_exit+0x45/0x47
       [<ffffffff81018fb3>] smp_apic_timer_interrupt+0x88/0x96
       [<ffffffff81002893>] apic_timer_interrupt+0x13/0x20
       [<ffffffff810011ac>] cpu_idle+0x4d/0x83
       [<ffffffff813e06f3>] start_secondary+0x1bd/0x1c1

other info that might help us debug this:

1 lock held by swapper/0:
 #0:  (&call->resend_timer){+.-...}, at: [<ffffffff8103b675>] run_timer_softirq+0x182/0x2a5

stack backtrace:
Pid: 0, comm: swapper Not tainted 2.6.35-rc3-cachefs+ #115
Call Trace:
 <IRQ>  [<ffffffff81054414>] print_circular_bug+0xae/0xbd
 [<ffffffff81055237>] validate_chain+0x727/0xd23
 [<ffffffff810560bc>] __lock_acquire+0x889/0x8fa
 [<ffffffff810539a7>] ? mark_lock+0x42f/0x51f
 [<ffffffff81056184>] lock_acquire+0x57/0x6d
 [<ffffffffa00200d4>] ? rxrpc_resend_time_expired+0x56/0x96 [af_rxrpc]
 [<ffffffff813e6b69>] _raw_read_lock_bh+0x34/0x43
 [<ffffffffa00200d4>] ? rxrpc_resend_time_expired+0x56/0x96 [af_rxrpc]
 [<ffffffffa00200d4>] rxrpc_resend_time_expired+0x56/0x96 [af_rxrpc]
 [<ffffffff8103b6e6>] run_timer_softirq+0x1f3/0x2a5
 [<ffffffff8103b675>] ? run_timer_softirq+0x182/0x2a5
 [<ffffffffa002007e>] ? rxrpc_resend_time_expired+0x0/0x96 [af_rxrpc]
 [<ffffffff810367ef>] ? __do_softirq+0x69/0x13e
 [<ffffffff81036828>] __do_softirq+0xa2/0x13e
 [<ffffffff81002dcc>] call_softirq+0x1c/0x28
 [<ffffffff810049f0>] do_softirq+0x38/0x80
 [<ffffffff810361a2>] irq_exit+0x45/0x47
 [<ffffffff81018fb3>] smp_apic_timer_interrupt+0x88/0x96
 [<ffffffff81002893>] apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff81049de1>] ? __atomic_notifier_call_chain+0x0/0x86
 [<ffffffff8100955b>] ? mwait_idle+0x6e/0x78
 [<ffffffff81009552>] ? mwait_idle+0x65/0x78
 [<ffffffff810011ac>] cpu_idle+0x4d/0x83
 [<ffffffff813e06f3>] start_secondary+0x1bd/0x1c1

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-ack.c  |    3 +++
 net/rxrpc/ar-call.c |    6 ++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 2714da1..b6ffe4e 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -245,6 +245,9 @@ static void rxrpc_resend_timer(struct rxrpc_call *call)
 	_enter("%d,%d,%d",
 	       call->acks_tail, call->acks_unacked, call->acks_head);
 
+	if (call->state >= RXRPC_CALL_COMPLETE)
+		return;
+
 	resend = 0;
 	resend_at = 0;
 
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index 909d092..bf656c2 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -786,6 +786,7 @@ static void rxrpc_call_life_expired(unsigned long _call)
 
 /*
  * handle resend timer expiry
+ * - may not take call->state_lock as this can deadlock against del_timer_sync()
  */
 static void rxrpc_resend_time_expired(unsigned long _call)
 {
@@ -796,12 +797,9 @@ static void rxrpc_resend_time_expired(unsigned long _call)
 	if (call->state >= RXRPC_CALL_COMPLETE)
 		return;
 
-	read_lock_bh(&call->state_lock);
 	clear_bit(RXRPC_CALL_RUN_RTIMER, &call->flags);
-	if (call->state < RXRPC_CALL_COMPLETE &&
-	    !test_and_set_bit(RXRPC_CALL_RESEND_TIMER, &call->events))
+	if (!test_and_set_bit(RXRPC_CALL_RESEND_TIMER, &call->events))
 		rxrpc_queue_call(call);
-	read_unlock_bh(&call->state_lock);
 }
 
 /*

