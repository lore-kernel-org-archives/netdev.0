From: Oleg Nesterov <oleg@redhat.com>
Subject: net/ && prepare_to_wait_exclusive()
Date: Wed, 14 May 2014 20:40:59 +0200
Message-ID: <20140514184059.GA9730@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I know almost nothing about networking and of course I do not understand
this code. So I can be easily wrong, but (at least) unix_wait_for_peer()
looks wrong wrt prepare_to_wait_exclusive(), and ignoring the potential
optimizations it needs

	-	finish_wait(&u->peer_wait, &wait);
	+	abort_exclusive_wait(..., TASK_INTERRUPTIBLE, NULL);

change?

Suppose that unix_recvq_full(X) == true and 2 threads, T1 and T2, are
sleeping in unix_dgram_sendmsg().

Another thread does read(X) and this empties ->sk_receive_queue so that
the next read(X) will block. We should wake up at least one thread.

The reader does wake_up_interruptible_sync_poll() and this is
__wake_up_common(nr_exclusive => 1), so this (say) wakes T1 up.

Suppose that this wake_up() races with (to simplify) SIGKILL and thus
T1 writes nothing and exits.

Now, the reader does another read(X) and blocks, ->sk_receive_queue is
empty, we have the writer T2 but it is still blocked too?

Or I completely misread this code?


(On a related note... looks like ___wait_event() is not complicated^W
 clever enough to implement wait_event_interruptible_exclusive_timeout)

Oleg.
