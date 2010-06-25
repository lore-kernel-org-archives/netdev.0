From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/8] netpoll: Allow netpoll_setup/cleanup recursion
Date: Fri, 25 Jun 2010 10:08:56 +0200
Message-ID: <1277453336.22715.2154.camel@twins>
References: <20100624182123.45264dfe.akpm@linux-foundation.org>
	 <20100624.203006.35035648.davem@davemloft.net>
	 <20100624205059.a28756b0.akpm@linux-foundation.org>
	 <20100624.212713.242141362.davem@davemloft.net>
	 <20100624214204.a85c8ba2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, herbert@gondor.hengli.com.au,
	mst@redhat.com, frzhang@redhat.com, netdev@vger.kernel.org,
	amwang@redhat.com, shemminger@vyatta.com, mpm@selenic.com,
	paulmck@linux.vnet.ibm.com, mingo@elte.hu
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48291 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268Ab0FYIRL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 04:17:11 -0400
In-Reply-To: <20100624214204.a85c8ba2.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-06-24 at 21:42 -0700, Andrew Morton wrote:
> That being said, I wonder why Herbert didn't hit this in his testing. 
> I suspect that he'd enabled lockdep, which hid the bug.  I haven't
> worked out _why_ lockdep hides the double-mutex_unlock bug, but it's a
> pretty bad thing to do. 

Most weird indeed, lockdep is supposed so shout its lungs out when
someone wants to unlock a lock that isn't actually owned by him (and it
not being locked at all certainly implies you're not the owner).

In fact, the below patch results in the below splat -- its also
something that's tested by the locking self-test:

/*
 * Double unlock:
 */
#define E()                                     \
                                                \
        LOCK(A);                                \
        UNLOCK(A);                              \
        UNLOCK(A); /* fail */


---
 kernel/timer.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/kernel/timer.c b/kernel/timer.c
index ee3f116..0496f71 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -1334,6 +1334,8 @@ SYSCALL_DEFINE0(getpid)
 	return task_tgid_vnr(current);
 }
 
+static DEFINE_MUTEX(foo);
+
 /*
  * Accessing ->real_parent is not SMP-safe, it could
  * change from under us. However, we can use a stale
@@ -1344,6 +1346,10 @@ SYSCALL_DEFINE0(getppid)
 {
 	int pid;
 
+	mutex_lock(&foo);
+	mutex_unlock(&foo);
+	mutex_unlock(&foo);
+
 	rcu_read_lock();
 	pid = task_tgid_vnr(current->real_parent);
 	rcu_read_unlock();



=====================================
[ BUG: bad unlock balance detected! ]
-------------------------------------
init/1 is trying to release lock (foo) at:
[<ffffffff815bf3b6>] mutex_unlock+0xe/0x10
but there are no more locks to release!

other info that might help us debug this:
no locks held by init/1.

stack backtrace:
Pid: 1, comm: init Not tainted 2.6.35-rc3-tip-01034-g5205803-dirty #399
Call Trace:
 [<ffffffff815bf3b6>] ? mutex_unlock+0xe/0x10
 [<ffffffff8106d718>] print_unlock_inbalance_bug+0xd6/0xe1
 [<ffffffff815bf3b6>] ? mutex_unlock+0xe/0x10
 [<ffffffff8106e8c6>] lock_release+0xdb/0x196
 [<ffffffff815bf32f>] __mutex_unlock_slowpath+0xc1/0x13a
 [<ffffffff815bf3b6>] mutex_unlock+0xe/0x10
 [<ffffffff8104f262>] sys_getppid+0x34/0xd8
 [<ffffffff81002cdb>] system_call_fastpath+0x16/0x1b

